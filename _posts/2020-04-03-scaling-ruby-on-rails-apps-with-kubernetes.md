---
author: Matt Sears
title: Scaling Ruby on Rails Apps with Kubernetes
date: 2020-04-03
layout: post
categories: ruby
---

In the [second](/articles/2020/04/08/deploying-ruby-on-rails-apps-on-kubernetes) part of this series, we have a working
Rails application up and running in our cluster with a load balancer to boot. In
this post, we're going to explore how to scale and manage our Rails application
running in our cluster.<!--more-->

### Scaling up

This is where things really pay off. Scaling up (and down) has never been
easier. We can add new instances (Pods) of our application with a single command
`kubectl scale`. Let's add a new task to our `kube.rake` that will take one
argument for the number of servers we want to run.

~~~ruby
desc "Set the number of instances to run in the cluster"
task :scale, [:count] => [:environment] do |t, args|
  kubectl "scale deployments/myapp-deployment --replicas #{args[:count]}"
end
~~~

Let's say we're expecting a big rush of sales this weekend and we need some
extra horsepower to handle the requests. Let's scale our servers to five instead
of two. Very cool!

~~~bash
$rake kube:scale[5]
deployment.apps/myapp-deployment scaled

$rake kube:list
...
default         myapp-deployment-644fcb756b-j94f2        1/1     Running   0          9s
default         myapp-deployment-644fcb756b-lnvjn        1/1     Running   0          2d19h
default         myapp-deployment-644fcb756b-pfcsj        1/1     Running   0          9s
default         myapp-deployment-644fcb756b-q6fbg        1/1     Running   0          9s
default         myapp-deployment-644fcb756b-smrjw        1/1     Running   0          2d19h
...
~~~

And we have three new instances running bring the total to five. And we can easily scale back down with `rake kube:scale[2]`.

### Scaling on Autopilot

What if we don't want to scale manually? Kubernetes makes autoscaling very
simple. We can add a
[HorizontalPodAutoscaler](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)
that will continously check the server stats and determine if it needs more pods
running.

~~~yaml

# ./kube/autoscaler.yml

apiVersion: autoscaling/v2beta2
kind: HorizontalPodAutoscaler
metadata:
  name: myapp
  namespace: default
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: myapp-deployment
  minReplicas: 2
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
~~~

From now on, anytime the CPU reaches 70% utilization on average, our cluster
will spin up new pods automatically. Set it and forget it.

### Executing tasks with Jobs

Kubernete has a built-in way to execute a command via a
[Job](https://kubernetes.io/docs/concepts/workloads/controllers/jobs-run-to-completion/). A
job in Kubernetes is a supervisor for pods carrying out batch processes, that
is, a process that runs for a certain time to completion. In our case, we're
going to run database migrations via a Job. Let's create new configuration for
our migration job:

~~~yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: migrate
  labels:
    app: myapp
    tier: app
spec:
  ttlSecondsAfterFinished: 100
  template:
    spec:
      restartPolicy: Never
      imagePullSecrets:
        - name: regcred
      containers:
        - name: myapp
          image: littlelines/myapp:build
          imagePullPolicy: IfNotPresent
          command:
            - bundle
            - exec
            - rake
            - db:migrate
          env:
          - name: SECRET_KEY_BASE
            value: '$SECRET_KEY_BASE'
          - name: RAILS_ENV
            value: '$RAILS_ENV'
          - name: DATABASE_USERNAME
            value: '$DATABASE_USERNAME'
          - name: DATABASE_PASSWORD
            value: '$DATABASE_PASSWORD'
          - name: DATABASE_HOST
            value: '$DATABASE_HOST'
          - name: DATABASE_PORT
            value: '$DATABASE_PORT'
~~~

This looks very similar to our depoyment configuration. That's because we need
to do a lot of similar things to get the application up and running. The most
interesting piece in our Job configuration is the `command` block. As you can
see, this how we tell Kubernetes to run our database migrations. Let's add a new
task to our [Rake file](https://gist.github.com/mattsears/9a5ab09a3ca7861c3daa0d24ca335fed) for running the migration job.

~~~ruby
desc "Migrates the Rails database"
task :migrate do
  apply "kube/job-migrate.yml"
end
~~~

Now, let's run it:

    $ rake kube:migrate
    job.batch/migrate created

What happens is kubernetes will create a new pod, pull our docker image down,
and run our rails migration command. When a Job completes, they aren't deleted
right away. They're kept around so we can still check the logs for errors,
warnings, or other diagnostic output. Since we have `ttlSecondsAfterFinished`
set to 100 in our job file, the pod will be eligible to be automatically
deleted, 100 seconds after it finishes.

### Inspect log files in production

Probably the most common way to debug production issues is looking at the log
files for exceptions. Things are a little complicated now since we have the
application running on multiple instances. In our case, it's most likely something
that our Rails app is needing that we haven't addressed such as connection
issues with the database, missing environment variables, etc.

Luckily for us, Kubernetes collects logs from Pods by monitoring their STDOUT
and STDERR streams. Since Rails 5, we can log to STDOUT in production
environment through introduction of new environment variable
RAILS_LOG_TO_STDOUT. If you recall from our `deployment.yml`, we have the
environment variable RAILS_LOG_TO_STDOUT set to true. By setting
RAILS_LOG_TO_STDOUT to any value we should have the production logs directed to
STDOUT. Let's go back to your [Rake file](https://gist.github.com/mattsears/9a5ab09a3ca7861c3daa0d24ca335fed) and add a new task:

~~~ruby
desc "Tail log files from our app running in the cluster"
task :logs do
  exec 'kubectl logs -f -l app=myapp --all-containers'
end
~~~

Note, we're using the `exec` because it will replace the current process and can
capture STDOUT allowing us to view the logs in real-time. Now we can run
`kube:logs` and it will print the last few lines of all the Rails applications
running in the cluster. Since we have two pods running, we specify the app name,
`myapp` in this case, so Kubernetes knows to get all the log files matching that
app name.

    $ rake kube:logs

    * Version 2.9.0 (ruby 2.4.6)
    * Min threads: 5, max threads: 5
    * Environment: production
    * Listening on tcp://0.0.0.0:3000

This is very handy since we can now see what's going on in the Pods!

### Logging into the Pod

When production issues happen or when we're first setting up our infrastructure,
I often want to login into the server and run a few commands either for
diagnostics or to fix the issue to get the application running again. The big
question here is, since we have multiple pods running our application, how to
log into them? Well, you can't log into all of them, but you can log into one of
them and since the pods are running the identical Rails application, any one of
them will do. No surprise here, we want to write a rake task to help us with
this because, we're going to need to log into the server multiple times
throughout the lifespan of the application.

First, we need to find a Pod run our Rails application to work with. Pod names
change every time we deploy so we can't hard code the pod name. Let's create a
method in our [Rake file](https://gist.github.com/mattsears/9a5ab09a3ca7861c3daa0d24ca335fed) called `find_first_pod_name` that will find the pod name.

~~~ruby
def find_first_pod_name
  `kubectl get pods|grep myapp-deployment|awk '{print $1}'|head -n 1`.to_s.strip
end
~~~

This method calls `kubectl get pods` that returns a list of pods running in the
cluster and filters the list that matches those running our application i.e `myapp-deployment`.

~~~
$ kubectl get pods

NAMESPACE       NAME                                        READY   STATUS
cert-manager    cert-manager-57cdd66b-vvwjj                 1/1     Running
cert-manager    cert-manager-cainjector-79f4496665-tdmxj    1/1     Running
cert-manager    cert-manager-webhook-6d57dbf4f-r9brk        1/1     Running
default         myapp-deployment-644fcb756b-lnvjn           1/1     Running
default         myapp-deployment-644fcb756b-smrjw           1/1     Running
ingress-nginx   nginx-ingress-controller-7f74f657bd-96ghr   1/1     Running
~~~

Running `find_first_pod_name` will return `myapp-deployment-644fcb756b-lnvjn` as
the result and that's all we need. Let's put it use in the new `shell` task:

~~~ruby
desc "Open a session to a pod on the cluster"
task :shell do
  exec "kubectl exec -it #{find_first_pod_name} bash"
end
~~~

Here we're again using Kubernetes' `exec` and Ruby's `exec` to run a command on
pod that will replace our current process running. In this case, we're calling
`bash` to give us a unix shell on the pod. This command will take us right to
the root of our Rails application running on the pod.

~~~
$ rake kube:shell

root@myapp-deployment-644fcb756b-lnvjn:/app# ls -l
total 92
-rw-r--r--  1 root root 2064 Apr 1 23:45 Dockerfile
-rw-r--r--  1 root root 1699 Apr 1 23:45 Gemfile
-rw-r--r--  1 root root 9431 Apr 1 23:45 Gemfile.lock
-rw-r--r--  1 root root 3841 Apr 1 23:45 README.md
-rw-r--r--  1 root root  273 Apr 1 23:45 Rakefile
drwxr-xr-x 10 root root 4096 Apr 1 23:45 app
drwxr-xr-x  6 root root 4096 Apr 1 23:45 config
-rw-r--r--  1 root root  158 Apr 1 23:45 config.ru
drwxr-xr-x  3 root root 4096 Apr 1 23:45 db
drwxr-xr-x  2 root root 4096 Apr 1 23:45 doc
drwxr-xr-x  2 root root 4096 Apr 1 23:45 kube
drwxr-xr-x  4 root root 4096 Apr 1 23:45 lib
drwxr-xr-x  1 root root 4096 Apr 1 00:18 log
drwxr-xr-x  1 root root 4096 Apr 1 23:49 public
drwxr-xr-x  5 root root 4096 Apr 1 23:45 script
drwxr-xr-x  5 root root 4096 Apr 1 23:45 test
drwxr-xr-x  1 root root 4096 Apr 1 23:49 tmp
drwxr-xr-x  5 root root 4096 Apr 1 23:46 vendor
~~~

How cool is that!? With the combination of Kubernetes' `exec` and Ruby's `exec` and our `find_first_pod_name` method, we can add many helpful tasks that we can run anytime on our application.

### More miscellaneous and helpful tasks

I want to round out this post with a few more rake tasks to give you a better
idea on how we can expand on the work we've already done.

Run any command on a pod with the `run` task:

~~~bash
desc "Runs a command in the server"
task :run, [:command] => [:environment] do |t, args|
   kubectl "exec -it #{find_first_pod_name} echo $(#{args[:command]})"
end

$ rake kube:run['bundle exec rake sales_report:deliver']
Sales Report Sent!
~~~

Open a rails console session on a production rails application:

~~~bash
desc "Run rails console on a pod"
task :console do
  system "kubectl exec -it #{find_first_pod_name} bundle exec rails console"
end

$ rake kube:console
Loading production environment (Rails 5.2.2)
irb(main):001:0> User.count
  (2.3ms)  SELECT COUNT(*) FROM "users"
=> 1
~~~

Print all the environment variables on our production application sorted alphabetically:

~~~bash
desc "Print the environment variables"
task :config do
  system "kubectl exec -it #{find_first_pod_name} printenv | sort"
end

$ rake kube:config
AWS_ACCESS_KEY=AKIXXXXXXXXXXXXXXXXXXXXX
AWS_REGION=us-east-2
AWS_S3_BUCKET=myapp-bucket
AWS_SECRET_ACCESS_KEY=+j1XXXXXXXXXXXXXX
...
~~~

Get the idea? Let's take one final look at the tasks we created with our rake file:

~~~bash
rake -T | grep kube
rake kube:config                    # Print the environment variables
rake kube:console                   # Run rails console on a pod
rake kube:deploy                    # Rollout a new deployment
rake kube:list                      # Print useful information aout our Kubernete setup
rake kube:logs                      # Tail log from server
rake kube:migrate                   # Migrates the Rails database
rake kube:run[command]              # Runs a command in the server
rake kube:scale[count]              # Set the number of instances to run in the cluster
rake kube:setup                     # Apply our Kubernete configurations to our cluster
rake kube:shell                     # Open a session to a pod on the cluster
~~~

If you familar with Heroku, Capistrano, or Mina, some of these commands may look
familiar to you. By combining Ruby on Rails, Kubernetes and Rake, I hope I've
been able to illustrate how we can setup, deploy, and scale our Rails
application running on Kubernetes using the tools we're already familiar with.
