# scribe

**Scribe** allows you to setup migrations for your Elixir projects.

[![Build Status](https://secure.travis-ci.org/rramsden/scribe.png?branch=master)](http://travis-ci.org/rramsden/scribe)

## Usage

Add scribe and postgres as mix dependencies. Note: Scribe only
supports postgres at the moment, if you want to use another database adapter please 
contribute!

    defp deps do
    [ {:scribe, github: "rramsden/scribe"},
      {:pgsql, github: "semiocast/pgsql"} ]
    end

Initialize a mix project with scribe

    mix scribe.init #=> CREATE db/migrations
                    CREATE db/scribe.conf
                    CREATE lib/my_module/tasks/db.ex
                    
    mix compile # needed to run custom mix tasks

Add your database settings in db/scribe.conf

    [
      adapter: "postgres",
      host: "localhost",
      database: "database",
      user: "user",
      password: "password"
    ]

Run a Mix Task

    mix db.migration some_migration_name # create a migration
    mix db.migrate # run migrations
    mix db.drop # drop database
    mix db.create # create database
