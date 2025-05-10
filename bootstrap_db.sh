#!/bin/bash

# MYSQL command to execute
MYSQL_COMMANDS="
DROP TABLE IF EXISTS snippets;
DROP TABLE IF EXISTS sessions;
DROP TABLE IF EXISTS users;
DROP USER IF EXISTS 'web'@'%';
CREATE TABLE IF NOT EXISTS snippets (
    id INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(100) NOT NULL,
    content TEXT NOT NULL,
    created DATETIME NOT NULL,
    expires DATETIME NOT NULL
);

-- Add an index on the created column.
CREATE INDEX idx_snippets_created ON snippets(created);

-- Add some dummy records (which we'll use in the next couple of chapters).
INSERT INTO snippets (title, content, created, expires) VALUES (
    'An old silent pond',
    'An old silent pond...\nA frog jumps into the pond,\nsplash! Silence again.\n\n– Matsuo Bashō',
    UTC_TIMESTAMP(),
    DATE_ADD(UTC_TIMESTAMP(), INTERVAL 365 DAY)
);

INSERT INTO snippets (title, content, created, expires) VALUES (
    'Over the wintry forest',
    'Over the wintry\nforest, winds howl in rage\nwith no leaves to blow.\n\n– Natsume Soseki',
    UTC_TIMESTAMP(),
    DATE_ADD(UTC_TIMESTAMP(), INTERVAL 365 DAY)
);

INSERT INTO snippets (title, content, created, expires) VALUES (
    'First autumn morning',
    'First autumn morning\nthe mirror I stare into\nshows my father''s face.\n\n– Murakami Kijo',
    UTC_TIMESTAMP(),
    DATE_ADD(UTC_TIMESTAMP(), INTERVAL 7 DAY)
);

CREATE TABLE IF NOT EXISTS sessions (
    token CHAR(43) PRIMARY KEY,
    data BLOB NOT NULL,
    expiry TIMESTAMP(6) NOT NULL
);
CREATE INDEX sessions_expiry_idx ON sessions (expiry);

CREATE TABLE IF NOT EXISTS users (
    id INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    hashed_password CHAR(60) NOT NULL,
    created DATETIME NOT NULL
);

ALTER TABLE users ADD CONSTRAINT users_uc_email UNIQUE (email);
CREATE USER 'web'@'%' IDENTIFIED BY 'pass';
GRANT SELECT, INSERT, UPDATE, DELETE ON snippetbox.* TO 'web';
"

POSTGRES_COMMANDS="
GRANT CREATE ON DATABASE greenlight TO greenlight;
ALTER DATABASE greenlight OWNER TO greenlight;
CREATE EXTENSION IF NOT EXISTS citext;
"

# Execute the SQL in the Docker container
docker exec -i mysql mysql -uroot -proot snippetbox -e "$MYSQL_COMMANDS"
docker exec -i postgres psql -U greenlight -d greenlight -e -c "$POSTGRES_COMMANDS"
migrate -path=./migrations -database=postgres://greenlight:pa55word@localhost/greenlight?sslmode=disable up

