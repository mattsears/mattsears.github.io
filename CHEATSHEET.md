
### Create your new post using:

```sh
    $ bundle exec jekyll post "My New Post"
```

### Create your new draft using:

```sh
    $ bundle exec jekyll draft "My new draft"
```

### Rename your draft using:

```sh
$ bundle exec jekyll rename _drafts/my-new-draft.md "My Renamed Draft"
```

```sh
# or rename it back
$ bundle exec jekyll rename _drafts/my-renamed-draft.md "My new draft"
```

### Publish your draft using:

```sh
    $ bundle exec jekyll publish _drafts/my-new-draft.md
```

```sh
    # or specify a specific date on which to publish it
    $ bundle exec jekyll publish _drafts/my-new-draft.md --date 2014-01-24
```

### Rename your post using:

```sh
$ bundle exec jekyll rename _posts/2014-01-24-my-new-draft.md "My New Post"
```

```sh
# or specify a specific date
$ bundle exec jekyll rename _posts/2014-01-24-my-new-post.md "My Old Post" --date "2012-03-04"
```

```sh
# or specify the current date
$ bundle exec jekyll rename _posts/2012-03-04-my-old-post.md "My New Post" --now
```

### Unpublish your post using:

```sh
    $ bundle exec jekyll unpublish _posts/2014-01-24-my-new-draft.md
```
