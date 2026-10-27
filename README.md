# Deploy and Host Listmonk on Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/listmonk-newsletters?referralCode=sLjDXb&utm_medium=integration&utm_source=button&utm_campaign=listmonk-newsletters)

[listmonk](https://listmonk.app/) is a fast, self-hosted newsletter and mailing list manager. It handles subscribers, lists, segments, campaign templates, scheduled sends, opt-in, unsubscribes, bounces and analytics from one Go binary. This template runs listmonk 6.2.0 from the official image on its own Postgres 17, creates the admin account on first boot and points every link listmonk sends out at your Railway domain.

## About Hosting Listmonk

The stack is two services: listmonk and Postgres.

- **Upstream's image, pinned.** listmonk runs the official `listmonk/listmonk` image at a fixed release (6.2.0), not `latest`. A thin wrapper ([source](https://github.com/two-workspaces/listmonk)) adds one start script and the Postgres client, nothing else.
- **Admin on first boot.** The database is installed on the first start and the super admin `admin` is created with the generated `LISTMONK_ADMIN_PASSWORD`, so the public URL never shows an open setup page.
- **Links that work.** listmonk keeps its root URL in the database and installs it as `http://localhost:9000`, which would break unsubscribe, tracking and archive links. The first boot sets it to your Railway domain. Later changes in Settings are kept.
- **Migrations on every start.** `listmonk --upgrade` runs before the server starts, so bumping the image version upgrades the database too.
- **Uploads on a volume.** Images you upload for campaigns are stored on a volume at `/listmonk/uploads` and served from your domain.
- **Small.** listmonk idles at about 65 MB of RAM and Postgres at about 50 MB, so the stack fits the Free plan.

## Common Use Cases

- Company newsletters and product update emails to tens of thousands of subscribers
- Transactional and marketing email from your own app through listmonk's API
- Double opt-in signup forms and public archives for a blog, community or open-source project
- Moving off Mailchimp, Sendy or Substack while keeping your list and sending through your own provider

## Dependencies for Listmonk Hosting

- Postgres 17 (included, private network only)
- An email provider for sending (Amazon SES, Postmark, Mailgun, Brevo, Resend or any SMTP server)

### Deployment Dependencies

- [listmonk documentation](https://listmonk.app/docs/)
- [Configuration and environment variables](https://listmonk.app/docs/configuration/)
- [listmonk on GitHub](https://github.com/knadh/listmonk)
- [Template source on GitHub](https://github.com/two-workspaces/listmonk)

### Implementation Details

**Sign in.** When the deploy is green, open your listmonk domain and sign in as `admin` with the password in the listmonk service's `LISTMONK_ADMIN_PASSWORD` variable. The variable is only read on the first boot; change the password in listmonk afterwards (Users).

**Sending email needs SMTP, and Railway only allows SMTP on the Pro plan.** On Free, Trial and Hobby, outbound SMTP is blocked by Railway, so campaigns queue but never leave. Everything else (lists, imports, forms, templates, the API) works on any plan. To send, use the Pro plan, then add your provider under Settings, SMTP and press Test connection. Also set Settings, General, "From" email to an address your provider has verified.

**Bounces.** Settings, Bounces can process bounce webhooks from SES, Postmark, SendGrid and others, or read a bounce mailbox over POP3.

**Custom domains.** Add the domain to the listmonk service in Railway, then change Settings, General, Root URL to it so links in emails use it.

**Upgrading.** Bump the version in the Dockerfile of your fork and redeploy. The start script runs listmonk's migrations first, so back up Postgres before a major version.

**Back up.** Subscribers, campaigns and settings are in Postgres; uploads are on the listmonk volume. Use Railway's volume backups or `pg_dump`.

## Why Deploy Listmonk on Railway?

Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying Listmonk on Railway, you are one step closer to supporting a complete full-stack application with minimal burden. Host your servers, databases, AI agents, and more on Railway.
