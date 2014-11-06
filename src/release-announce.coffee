# Description:
#    Send an email about a pull request denoting a release which has shipped.
#
# Dependencies:
#   github, nodemailer, marked
#
# Configuration:
#   HUBOT_GITHUB_TOKEN
#   HUBOT_GITHUB_USER
#   HUBOT_GITHUB_API
#   HUBOT_RELEASE_DEFAULT_REPO
#   HUBOT_RELEASE_MAIL_FROM
#   HUBOT_RELEASE_MAIL_TO
#   HUBOT_RELEASE_SMTP_HOST
#   HUBOT_RELEASE_SMTP_USER
#   HUBOT_RELEASE_SMTP_PASS
#   HUBOT_RELEASE_SUBJECT_PREFIX
#
# Commands:
#   hubot release announce [repo/pr-id] - Sends a release email based on the text of the PR.  Repo name is optional; defaults to tracelons.
#   hubot release preview [repo/pr-id] - Prints out what you're about to email.
#
# Notes:
#   HUBOT_GITHUB_API allows you to set a custom URL path (for Github enterprise users)
#
# Author:
#   dankosaur

module.exports = (robot) ->
    # depends
    github = require("githubot")(robot)
    nodemailer = require("nodemailer")
    marked = require("marked")

    # env vars
    unless (url_api_base = process.env.HUBOT_GITHUB_API)?
        url_api_base = "https://api.github.com"
    unless (default_repo = process.env.HUBOT_RELEASE_DEFAULT_REPO)?
        throw new Error("dankosaur/hubot-release-announce")
    unless (from_email = process.env.HUBOT_RELEASE_MAIL_FROM)?
        throw new Error("HUBOT_RELEASE_MAIL_FROM required")
    unless (to_email = process.env.HUBOT_RELEASE_MAIL_TO)?
        throw new Error("HUBOT_RELEASE_MAIL_TO required")
    unless (smtp_host = process.env.HUBOT_RELEASE_SMTP_HOST)?
        throw new Error("HUBOT_RELEASE_STMP_HOST required")
    unless (smtp_user = process.env.HUBOT_RELEASE_SMTP_USER)?
        throw new Error("HUBOT_RELEASE_STMP_USER required")
    unless (smtp_pass = process.env.HUBOT_RELEASE_SMTP_PASS)?
        throw new Error("HUBOT_RELEASE_STMP_PASS required")
    if process.env.HUBOT_RELEASE_SUBJECT_PREFIX?
        subject_prefix = process.env.HUBOT_RELEASE_SUBJECT_PREFIX
    else
        subject_prefix = "[release]"

    # email transport
    mailer = nodemailer.createTransport
                service: "SMTP"
                host: smtp_host
                port: 25
                auth:
                    user: smtp_user
                    pass: smtp_pass

    robot.respond /release\s+(announce|preview)\s+(.+)/i, (msg) ->
        mode = msg.match[1]

        # parse repo / PR input value
        parts = msg.match[2].split "/"
        if parts.length == 3
            repo = parts[0] + "/" + parts[1]
            pr = parts[2]
        else
            repo = default_repo
            pr = parts[0]

        api_url = "#{url_api_base}/repos/#{repo}/issues/#{pr}"

        github.get api_url, (pull) ->

            # validate response
            if not pull
                msg.send "PR not found."
            else if not pull.pull_request
                msg.send "Not a PR."
            else
                # construct email
                base_issue_url = "https://github.com/#{repo}/issues"
                pr_url = "https://github.com/#{repo}/pull/#{pr}"
                linked_body = pull.body.replace /#(\d+)/g, (match) ->
                    num = match.slice 1
                    link = "#{base_issue_url}/#{num}"
                    "[##{num}](#{link})"

                email_subject = "#{subject_prefix} #{pull.title}"
                email_body = "### #{pull.title}\n\n#{linked_body}\n\n[#{pr_url}](#{pr_url})"

                mail =
                    from: from_email
                    to: to_email
                    subject: email_subject
                    text: email_body
                    html: marked(email_body)

                if mode == "preview"
                    msg.send email_subject + "\n" + email_body
                else
                    mailer.sendMail mail, (error, response) ->
                        if error
                            msg.send "Error sending email: #{error}"
                        else
                            msg.send "Sent release announcement for #{pr} to #{to_email}"
