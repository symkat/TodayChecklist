## Development

Login to the server as root and run `systemctl stop todaychecklist`

Login to the server as manager and run `morbo script/todaychecklist --listen http://127.0.0.1:8080`

## Admin Commands

| Command          | Description                                             |
| ---------------- | ------------------------------------------------------- |
| dbc              | Conect to the psql database                             |
| db\_dump         | Dump the database                                       |
| export\_template | Given a template id, dump the template as a JSON object |
| import\_template | Given a JSON file, import the template from it          |
| flip\_admin      | Given an email address, mark the person as an admin     |

Commands are given as arguments to `script/todaychecklist`.

