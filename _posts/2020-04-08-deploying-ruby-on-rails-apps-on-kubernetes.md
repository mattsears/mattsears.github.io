---
author: Matt Sears
title: Deploying Ruby on Rails Apps on Kubernetes
date: 2020-04-08
layout: post
categories: ruby
---

In [Part 1](/articles/2020/04/13/getting-started-with-ruby-on-rails-and-kubernetes) in this series, we've setup our accounts,
installed the required tools we need to deploy our Rails application to a
Kubernetes cluster. We've even started working on our [Rake file](https://gist.github.com/mattsears/9a5ab09a3ca7861c3daa0d24ca335fed) that we're using
to document our steps and interface with our cluster. In this post, we'll expand
our Rake file to deploy our application to the cluster. In this walkthrough,
we'll accomplish the following:<!--more-->

1. Deploy two instances of our Rails application to the cluster.
2. Setup a load balancer to direct traffic to our running Rails applications
3. Enable SSL on your website with Let's Encrypt.

### An introduction to Kubernetes components

A Kubernetes cluster is made up of components and are created through a
declarative way using Yaml files, which as Rubyist, we're already familiar
with. We're going to store our Yaml files in the root directory of our Rails
application called `/kube`. All we need to get our website up and running is
seven Yaml files:

~~~
$ ls -la kube/

certificate.yml
cluster-issuer.yml
deployment.yml
ingress.yml
job-migrate.yml
secret-digital-ocean.yml
service.yml
~~~

We'll expand on all of the above. First up, is a
[Service](https://kubernetes.io/docs/concepts/services-networking/service/). A
Service is going to expose our application (running as Pods). To put simply, the
Service tells our cluster what port our application is going to run on and
allows connections to it.

~~~yaml
# kube/service.yml

apiVersion: v1
kind: Service
metadata:
  name: myapp-service
spec:
  ports:
    - port: 3000
  selector:
    app: myapp
    tier: app

~~~

Pretty simple, right? Let's revisit our [Rake file](https://gist.github.com/mattsears/9a5ab09a3ca7861c3daa0d24ca335fed) and add a task that will apply
our Service component to our cluster. We're going to add a `setup` task that
will be responsible for applying all our configuration files to the
cluster. Kubernetes is smart enough to know if a configuration file has changed
or not. If the configuration file hasn't change our cluster will simply ignore
it.

~~~ruby
# lib/tasks/kube.rake

desc 'Apply our Kubernete components'
task :setup do
  kubectl "apply -f #{Rails.root}/kube/service.yml"
end
~~~

In the root of our Rails application, let's run the `setup` task and see what happens


~~~bash
$ rake kube:setup
service/myapp-service created

$ rake kube:list
...
NAMESPACE     NAME               TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
default       kubernetes         ClusterIP   10.245.0.1      <none>        443/TCP     3h34m
default       myapp-service      ClusterIP   10.245.89.220   <none>        3000/TCP    2m19s
kube-system   kube-dns           ClusterIP   10.245.0.10     <none>        53/UDP      3h34m
...
~~~

As you can see, Kubernetes assigned our service an IP address and the port
number we wanted. Now it's time to get your Rails app running in the cluster on
that port number with the Docker image we built in part one of this series.

### Kubernetes component: Deployment

Here we're introducing a new configuration to our setup. A
[Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/). This
is where the magic really happens. Our deployment configuration tells our
cluster a few things:

1. The location of our Docker image we built (DockerHub in our case).
1. The port number the Rails application is running on.
1. The environment variables it needs to run.
1. The number of pods, or instances to start (Two in our case).

~~~yaml
# ./kube/deployment.yml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-deployment
  labels:
    app: myapp
    tier: app
spec:
  replicas: 2
  minReadySeconds: 5
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
  selector:
    matchLabels:
      app: myapp
      tier: app
  template:
    metadata:
      labels:
        app: rubytags
        tier: app
    spec:
      imagePullSecrets:
        - name: docker-registry
      containers:
      - name: myapp
        image: littlelines/myapp
        imagePullPolicy: Always
        ports:
        - containerPort: 3000
        env:
        - name: RAILS_LOG_TO_STDOUT
          value: 'true'
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

### Some notes about environment variables

One sticky point with Kubernetes is that it doesn't really have a great way with
dealing with sensitive data in our configuration files locally. We don't want to
save database passwords for example in our yaml files because eventually we want
to commit these files to Github. Following a suggestion in a Github
[issue](https://github.com/kubernetes/kubernetes/issues/52787) about this
predicament, we can use the `envsubst` command-line tool to substitute the
placeholders in `deployment.yml` with real values.

In our Development configuration, you can see that we have placeholders for our
environment variables such as `$DATABASE_USERNAME`. We need a way to substitute
that with the real database user name when we apply this configuration to the
cluster. We can again call on our Rake task to help us with this.

Since we're in a Rails application already, most likely we're already using
environment variables and also likely is that we have the
[dotenv](https://github.com/bkeepers/dotenv) gem installed too. We can create a
new `.env` file in the root directory called `.env.production.cluser`. These
will hold the environment variables needed for our production server. For now,
let's add our database user name:

~~~ruby
# ./.env.production.cluster

DATABASE_USERNAME="deployer"

~~~

It's important that we add this file to our `.gitignore` file so that we don't
check it into source control. In our [Rake file](https://gist.github.com/mattsears/9a5ab09a3ca7861c3daa0d24ca335fed) we can tell `dotenv` which `.env`
file to look for by adding this line near the top of our Rake file.


~~~ruby
Dotenv.load('.env.production.cluster')
~~~

Now we have environment variables to work with, we can use `envsubst` command line tool to
substitute our placeholders in our configuration files. This is how we would traditionally do this on the command line:

    $ export DATABASE_USERNAME='deployer'
    $ envsubst < kube/deployment.yml | kubectl apply -f -

That's going to be too cumbersome to write each time. Plus we want it to
pull values from our `.env.production.cluser` file. So let's update our Rake
task to make this simpler. We're going to write a `apply` method that will to
the heavy lift for us.

~~~ruby
def apply(configuration)
  if File.file?(configuration)
    puts %x{envsubst < #{configuration} | kubectl apply -f -}
  else
    kubectl "apply -f #{configuration}"
  end
end
~~~

Great. Now we can simply add all the production environment variables to our
`.env.production.cluster` file and our new `apply` method with substitute the
placeholders in the Deployment file will those values.

But, we have one more thing to take care of first. You may have noticed the
`imagePullSecrets` key in our configuration file, this is a special key that we
need in order for our cluster to authenticate with Docker Hub so that it can
pull our Docker image into it and run it. To add our DockerHub credentials to
the cluster we can execute the following command:

    $ kubectl create secret docker-registry regcred --docker-server=<your-registry-server> --docker-username=<your-name> --docker-password=<your-pword> --docker-email=<your-email>

Rather than having to remember this, again we can add this to our [Rake file](https://gist.github.com/mattsears/9a5ab09a3ca7861c3daa0d24ca335fed) and make use of our new environment variable support. We'll add this to our `rake kube:setup` task:

~~~ruby
desc 'Apply our Kubernete configurations to our cluster'
task :setup do
  # Store our Docker Hub credentials in the cluster so that we can pull our Docker image
  sh %Q(
    kubectl create secret docker-registry regcred \
      --docker-server=#{ENV['DOCKER_REGISTRY_SERVER']} \
      --docker-username=#{ENV['DOCKER_USERNAME']} \
      --docker-password=#{ENV['DOCKER_PASSWORD']} \
      --docker-email=#{ENV['DOCKER_EMAIL']} \
      || true # <-- prevent error hear from exiting our rake task
  )
  # Apply our Service component
  apply "kube/service.yml"

  # Apply our Deployment component
  apply "kube/deployment.yml"
end
~~~

Pulling it all together, our `rake kube:setup` task adds our Docker Hub
credentials to the cluster and applies our Service and Deployment
configuration. If all went well, we should have two Pods with our Rails
application.

~~~
NAMESPACE     NAME                                 READY   STATUS    RESTARTS   AGE
default       myapp-deployment-76c674bb79-4jw9b    1/1     Running   0          21m
default       myapp-deployment-76c674bb79-6xbnz    1/1     Running   0          21m
~~~

This is a huge step. At this point, we have our Rails application running in a
cluster! But, how can we see the application running in the browser? We need two
things: One, a web server running on port 80 that will connect to our
application running on port 3000 and two, a load balancer to accept incoming
requests from the internet and distribute them equally between our two running
applications.

Lucky for us, Kubernetes has a built‑in configuration for load balancing, called
[Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/),
that defines rules for external connectivity to our services. We simply need to
build a Ingress component that will tell how to connect to our service. We're
going to be using the [Nginx Ingress
Controller](https://www.nginx.com/products/nginx/kubernetes-ingress-controller/)
for both our web server and for load balancing.

### Kubernetes component: Ingress

~~~yaml
# kube/ingress.yml
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: myapp-ingress
  namespace: default
  annotations:
    kubernetes.io/ingress.class: nginx
spec:
  tls:
  - hosts:
    - $DNS_WEBSITE
    secretName: myapp-tls
  rules:
  - host: $DNS_WEBSITE
    http:
      paths:
      - path: /
        backend:
          serviceName: myapp-service
          servicePort: 3000
~~~

Remember, we'll need to add `DNS_WEBSITE` environment variable e.g. myapp.com to `env.production.cluster` so that
`envsubst` will replace it before sending it to the cluster. Now let's add a
couple more commands our [Rake file's](https://gist.github.com/mattsears/9a5ab09a3ca7861c3daa0d24ca335fed) `setup` task:

    # Install Nginx Ingress Controller on our cluster.
    apply "https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/mandatory.yaml"

    # Add the load balancer:
    apply "https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/cloud-generic.yaml"

    # Apply our Ingress that will connect the new load balancer to our service
    apply "kube/ingress.yml"

Let's take a look at the results:

~~~
$ kubectl get pods -n ingress-nginx

NAME            TYPE           CLUSTER-IP       EXTERNAL-IP      PORT(S)
ingress-nginx   LoadBalancer   10.245.87.228   159.89.252.115   80:30979/TCP,443:31642/TCP

$ kubectl get services -n ingress-nginx

NAME               HOSTS        ADDRESS          PORTS     AGE
myapp-ingress      myapp.com    159.89.252.250   80, 443   22m

~~~

As you can see we have a new load balancer with an IP address! This is the
external IP we can used to load the application. We take this time to update our
DNS records and point our domain, 'myapp.com' in this case, to this new ip
address. And since we have our service running with the host reflecting the
correct domain name, our Nginx configuration is setup to accept requests for
this host address.

### Securing our website with Let's Encrypt SSL certificates

Now it's time to secure our connection so that your application will run under
SSL. To do this, we'll be using [cert-manager](https://cert-manager.io) to
manage certificates. It will ensure certificates are valid and up to date, and
attempt to renew certificates automatically.

In order to create a SSL certificate, we first need a
[Certificate](https://kubernetes.io/docs/concepts/cluster-administration/certificates/)
component to tell Let's Encrypt what website domain we want to encrypt.

~~~yaml
# kube/certificate.yml

apiVersion: cert-manager.io/v1alpha2
kind: Certificate
metadata:
  name: myapp-tls
  namespace: default
spec:
  secretName: myapp-tls
  issuerRef:
    name: letsencrypt-prod
  dnsNames:
  - $DNS_WEBSITE
  issuerRef:
    kind: ClusterIssuer
    name: letsencrypt-prod
~~~

And a [Cluster Issuer](https://cert-manager.io/docs/concepts/issuer/) component
to issue to certificate. This includes our domain name and how we're going to
verify that we are the owners of our domain.

~~~yaml
# kube/cluster-issuer.yml

apiVersion: cert-manager.io/v1alpha2
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: $ADMIN_EMAIL
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - selector:
        dnsZones:
          - $DNS_WEBSITE
      dns01:
        digitalocean:
          tokenSecretRef:
            name: digitalocean-dns
            key: access-token
~~~

In order for cert-manager to begin issuing certificates, the ClusterIssuer needs
a way to validate we are the owner of the domain. In my case, DigitalOcean is
managing the DNS records for my domain so I'm using my API token that I've
previously created to authenticate as documented
[here](https://cert-manager.io/docs/configuration/acme/dns01/digitalocean/).

~~~
apiVersion: v1
kind: Secret
metadata:
  name: digitalocean-dns
  namespace: cert-manager
data:
  access-token: ${DIGITAL_OCEAN_TOKEN}
~~~

Our token must be decoded in our cluster first.

    $ echo -n 'EXAMPLE_DIGITAL_OCEAN_TOKEN' | base64

    # Add our tokent to .env.production.cluster
    DIGITAL_OCEAN_TOKEN='RVhBTXXXXXXXXOIYIHHMX09DRUFOX1RPS0VO'


Finally let's update our `rake kube:setup` task and run it. It will now install
cert-manager and add our DigitalOcean token, Certificate, and ClusterIssuer to
our cluster:

~~~ruby
# Install cert-manager
kubectl 'create namespace cert-manager'
apply "https://github.com/jetstack/cert-manager/releases/download/v0.14.0/cert-manager.yaml"

# Add the Digital Ocean token to the cluster
apply "kube/secret-digital-ocean.yml"

# Add our certificate
apply "kube/certificate.yml"

# Add the certificate issuer
apply "kube/cluster-issuer.yml"
~~~

After running `rake kube:setup`, the cert-manager should have made a API call to
the DigitalOcean API with our decoded token and verified that our domain name
e.g myapp.com is managed in my DigitalOcean account and is valid. This process
is a little tricky at first and I spent a lot of time getting this to work. I
recommend reading up on the
[ACME](https://cert-manager.io/docs/configuration/acme/) documentation on
Solving Challenges. I've found that the
[DNS01](https://cert-manager.io/docs/configuration/acme/dns01/) challenge
providers work better if you're using a supported providers such as Cloudflare,
Amazon's Route53, and DigitalOcean.

If cert-manager is able to successfully verify the domain name ownership, it will issue a brand new certificate. We see it by running `describe certifiate`

~~~
$ kubectl describe certificate

Name:         myapp-tls
Namespace:    default
Labels:       <none>
Annotations:  kubectl.kubernetes.io/last-applied-configuration:
                {"apiVersion":"cert-manager.io/v1alpha2","kind":"Certificate","metadata":{"annotations":{},"name":"myapp-tls","namespace":"default"},"s...
API Version:  cert-manager.io/v1alpha3
Kind:         Certificate
Metadata:
  Creation Timestamp:  2020-04-03T01:56:12Z
  Generation:          1
  Resource Version:    224072
  Self Link:           /apis/cert-manager.io/v1alpha3/namespaces/default/certificates/myapp-tls
  UID:                 6195af34-1306-4985-bae3-757e7b90c35c
Spec:
  Dns Names:
    myapp.co
  Issuer Ref:
    Kind:       ClusterIssuer
    Name:       letsencrypt-prod
  Secret Name:  myapp-tls
Status:
  Conditions:
    Last Transition Time:  2020-04-10T01:57:17Z
    Message:               Certificate is up to date and has not expired
    Reason:                Ready
    Status:                True
    Type:                  Ready
  Not After:               2020-07-10T00:57:16Z
Events:                    <none>
~~~

Now we can load our website in a browser and boom, our website running and is
secured! At this point, we have a working website running in a Kubernetes
cluster and we have a good set of rake tasks that makes it easy to deploy new
updates. Checkout the next part in this series: [Scaling Ruby on Rails Apps with
Kubernetes](/articles/2020/04/03/scaling-ruby-on-rails-apps-with-kubernetes) to
learn how easy it is to scale your application has usage grows.
