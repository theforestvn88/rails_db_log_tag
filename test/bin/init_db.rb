#!/usr/bin/env ruby

`sqlite3 test/db/primary.sqlite3 'CREATE TABLE IF NOT EXISTS developers (name VARCHAR (255))'`
`sqlite3 test/db/primary_shard_one.sqlite3 'CREATE TABLE IF NOT EXISTS developers (name VARCHAR (255))'`