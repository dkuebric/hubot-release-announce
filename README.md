# Hubot Release Announce

A simple Hubot plugin used at AppNeta to send release announcement emails from GitHub PRs.

## Configuration

You'll need to have (nearly) all of the following ENV vars set for this to work:
* `HUBOT_GITHUB_TOKEN`
* `HUBOT_GITHUB_USER`
* `HUBOT_GITHUB_API` - defaults to https://api.github.com
* `HUBOT_RELEASE_DEFAULT_REPO` - defaults to `dankosaur/hubot-release-announce`
* `HUBOT_RELEASE_MAIL_FROM`
* `HUBOT_RELEASE_MAIL_TO`
* `HUBOT_RELEASE_SMTP_HOST`
* `HUBOT_RELEASE_SMTP_USER`
* `HUBOT_RELEASE_SMTP_PASS`

## Usage

* `hubot release announce [repo/pr-id]` - Sends a release email based on the text of the PR.  Repo name is optional; defaults to tracelons.
* `ubot release preview [repo/pr-id]` - Prints out what you're about to email.

### Examples
```
hubot release preview appneta/node-traceview/9
hubot release announce 9
