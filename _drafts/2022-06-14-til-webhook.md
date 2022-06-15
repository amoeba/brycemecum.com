---
layout: post
tags: ["til", "golang", "webhooks", "ci/cd"]
title: "Using the Go webhook package w/ GitHub Actions for minimal CI/CD"
---

I recently needed to set up continuous deployment to a staging server for a project and ended up finding a pretty minimal solution which I liked. In the process, I found a nice [Go](https://go.dev/) package I can see myself using again in the future: [webhook](https://github.com/adnanh/webhook).

From the [webhook README](https://github.com/adnanh/webhook):

> webhook is a lightweight configurable tool written in Go, that allows you to easily create HTTP endpoints (hooks) on your server, which you can use to execute configured commands. You can also pass data from the HTTP request (such as headers, payload or query variables) to your commands. webhook also allows you to specify rules which have to be satisfied in order for the hook to be triggered.

I really like [webhooks](https://en.wikipedia.org/wiki/Webhook) and I'll talk about why I went with a webhook-based solution later on.

## My Actual Problem

On the server I have a number of [NodeJS](https://nodejs.org/en/) applications supervised by [pm2](https://pm2.keymetrics.io/).
The redeploy process for each is basically:

1. SSH into server
2. `cd` into the correct directory
3. Run `git fetch origin && git merge --ff-only origin/main` to update the application's code
4. Run `npm install` and any build commands
5. Run `pm2 restart $APP`

This is a team project so giving everyone credentials to log into the server and restart things is less than ideal but so is everyone having to bug someone who does have credentials to do it for them numerous times a day.
Since the purpose of this staging server is to host the very latest code the team is working on (from a `develop` branch) for the broader team to test, we want to do a re-deploy on every push to `develop`.

## The First Fork in the Road

The project is already using [GitHub](https://github.com) so [GitHub Actions](https://github.com/features/actions) so the first thing to decide was whether to push or pull from the CI/CD pipeline.

I thought about going with push (using [Fabric](https://www.fabfile.org/) or [Ansible](https://www.ansible.com/)) but that would involve giving the pipeline the ability execute commands on the staging server. While it's reasonable to secure the pipeline at some level, I wondered if I couldn't just trigger the re-deloy from the pipeline (pull).

I knew I was looking for a way to receive webhooks on the staging server and execute arbitary commands but I knew I didn't want to write my own solution. A couple of searches later and I stumbled onto [webhook](https://github.com/adnanh/webhook) which is a webhook server that lets you run commands on a remote server.
It supports extra logic on the receiving side to only trigger when the payload contains certain parameters and it provides a simple configuration [Hook[](](https://github.com/adnanh/webhook/blob/master/docs/Hook-Definition.md)https://github.com/adnanh/webhook/blob/master/docs/Hook-Definition.md) syntax to do so.
This means we could trigger commands only if:

1. A push was made to a specific branch
2. The webhook request has a secret key to prove its from a trusted source

Since I was going to expose this to the public-facing Internet, (2) was important.

## The Setup

The staging server is running [Ubuntu](https://ubunut.com) which has a package for [webhook](https://github.com/adnanh/webhook) that automatically sets up a [systemd](https://en.wikipedia.org/wiki/Systemd) service which keeps [webhook](https://github.com/adnanh/webhook) running and pointing a `/etc/webhook.conf` for its [Hook](https://github.com/adnanh/webhook/blob/master/docs/Hook-Definition.md) config.

Once I installed [webhook](https://github.com/adnanh/webhook) via:

```sh
sudo apt install webhook
```

I wrote a shell sript to do the re-deploy:

```sh
#!/bin/sh

git pull || exit
pm2 restart my_app
```

And then edited `/etc/webhook.conf` like so:

```json
[
  {
    "id": "redeploy-my-app",
    "execute-command": "/var/scripts/redeploy-my-app.sh",
    "trigger-rule": {
      "and": [
        {
          "match":
          {
            "type": "payload-hash-sha1",
            "secret": "mysecret",
            "parameter":
            {
              "source": "header",
              "name": "X-Hub-Signature"
            }
          }
        }
      ]
    }
  }
]
```

The above configuration sets up a webhook endpoint that runs `/var/scripts/redeploy-my-app.sh` when a request comes in to the staging server at the path `/hooks/redeploy-my-app` with the HTTP header `X-Hub-Signature` set to the correct value.

The last step is to come up with a pipeline that can trigger our webhooks for us.
I settled on [https://github.com/distributhor/workflow-webhook](https://github.com/distributhor/workflow-webhook) since it looked like it had enough features.
While the project's CI/CD pipeline is more complicated, a basic Workflow to get continuous deploys working might look like this:

{% raw %}
```yaml
name: CD

on:
  push:
    branches: [ "develop" ]

  workflow_dispatch:

jobs:
  redeploy:
    runs-on: ubuntu-latest

    steps:
      - name: Invoke deployment hook
        uses: distributhor/workflow-webhook@v2
        env:
          webhook_url: ${{ secrets.WEBHOOK_URL }}
          webhook_secret: ${{ secrets.WEBHOOK_SECRET }}
```
{% endraw %}

The Workflow uses two secrets, `WEBHOOK_URL` and `WEBHOOK_SECRET`, which I set up under each repository's Settings -> Secrets -> Actions, that set up the URL to send the webhook to and the secret to send with the request in order to ensure only GitHub Actions can trigger a re-deploy using this method.
