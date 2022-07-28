# TodayChecklist

This is the source code for [TodayChecklist](https://todaychecklist.com/).

## Installation

The `devops/` directory provides a role and playbook for installing and maintaining TodayChecklist.

You will need `ansible-playbook` installed, and this repository checked out to begin installation.  The machine you use ansible-playbook from does not need to be the machine you are installing TodayChecklist on.

TodayChecklist expects to be installed on a Debian 11 server where you have root access over ssh.

Copy `devops/inventory.yml.example` to `devops/inventory.yml`, read through the file and edit to to at least include your hostname.

Ensure that DNS has been updated so that your server can be accessed through the hostname.

Run the following command from within the `devops/` directory:

```bash
ansible-playbook -i inventory.yml site.yml
```

This may take a couple of hours to complete, once it has finished visit http://your-fqdn to create an account.

### SSL

If this instance is going to be used for production traffic, SSL should be enabled.

```bash
certbot run --nginx -d your.domain.name.com --agree-tos --register-unsafely-without-email
```

Certbox will obtain a certificate and rewrite the nginx configuration file to enable SSL and redirect HTTP traffic.  Use -d twice if you want to add another domain, like `www.your.domain.name.com`.

## Development

Login to the server as root and run `systemctl stop todaychecklist`

Login to the server as manager and run `morbo script/todaychecklist --listen http://127.0.0.1:8080`

Changes to files under `/home/manager/todaychecklist/Web/lib` or `/home/manager/todaychecklist/Web/templates` will now cause the server to reload, making development quicker.

## Operations

## Admin Commands

| Command          | Description                                             |
| ---------------- | ------------------------------------------------------- |
| dbc              | Conect to the psql database                             |
| db\_dump         | Dump the database                                       |
| export\_template | Given a template id, dump the template as a JSON object |
| import\_template | Given a JSON file, import the template from it          |
| flip\_admin      | Given an email address, mark the person as an admin     |

Commands are given as arguments to `./script/todaychecklist` when in `/home/manager/todaychecklist/Web`.


