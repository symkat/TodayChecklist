CREATE EXTENSION IF NOT EXISTS citext;

CREATE TABLE person (
    id                          serial          PRIMARY KEY,
    name                        text            not null,
    email                       citext          not null unique,
    stripe_customer_id          text            ,
    is_subscribed               boolean         not null default false,
    is_enabled                  boolean         not null default true,
    is_admin                    boolean         not null default false,
    created_at                  timestamptz     not null default current_timestamp
);

INSERT INTO person ( name, email ) VALUES ( 'System User', 'system@todaychecklist.com' );

-- Settings for a given user.  | Use with care, add things to the data model when you should.
CREATE TABLE person_settings (
    id                          serial          PRIMARY KEY,
    person_id                   int             not null references person(id),
    name                        text            not null,
    value                       json            not null default '{}',
    created_at                  timestamptz     not null default current_timestamp,

    -- Allow ->find_or_new_related()
    CONSTRAINT unq_person_id_name UNIQUE(person_id, name)
);

CREATE TABLE auth_password (
    person_id                   int             not null unique references person(id),
    password                    text            not null,
    salt                        text            not null,
    updated_at                  timestamptz     not null default current_timestamp,
    created_at                  timestamptz     not null default current_timestamp
);

CREATE TABLE auth_token (
    id                          serial          PRIMARY KEY,
    person_id                   int             not null references person(id),
    scope                       text            not null,
    token                       text            not null,
    created_at                  timestamptz     not null default current_timestamp
);

CREATE TABLE template (
    id                          serial          PRIMARY KEY,
    person_id                   int             not null references person(id),
    name                        text            not null,
    description                 text            not null,
    content                     text            not null,
    is_system                   boolean         not null default false,
    created_at                  timestamptz     not null default current_timestamp
);

CREATE TABLE template_var_type (
    id                          serial          PRIMARY KEY,
    name                        text            not null
);

INSERT INTO template_var_type ( name ) VALUES ( 'text'             );
INSERT INTO template_var_type ( name ) VALUES ( 'textbox'          );
INSERT INTO template_var_type ( name ) VALUES ( 'array'            );
INSERT INTO template_var_type ( name ) VALUES ( 'date'             );
INSERT INTO template_var_type ( name ) VALUES ( 'nested_checklist' );

CREATE TABLE template_var (
    id                          serial          PRIMARY KEY,
    template_id                 int             not null references template(id),
    name                        text            not null,
    title                       text            not null,
    description                 text            not null,
    weight                      int             not null default '10',
    template_var_type_id        int             not null references template_var_type(id)
);

CREATE TABLE document (
    id                          serial          PRIMARY KEY,
    person_id                   int             not null references person(id),
    name                        text            ,
    description                 text            ,
    template_id                 int             not null references template(id),
    payload                     json            not null default '{}',
    created_at                  timestamptz     not null default current_timestamp
);


