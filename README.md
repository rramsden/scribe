# scribe

*Scribe* allows you to setup migrations for your Elixir projects.

[![Build Status](https://secure.travis-ci.org/rramsden/scribe.png?branch=master)](http://travis-ci.org/rramsden/scribe)

# Usage

Add scribe as a mix dependency

    defp deps do
      [{:scribe, github: "rramsden/scribe"}]
    end

Initialize a mix project with scribe

    mix scribe.init #=> CREATE db/migrate
                        CREATE db/scribe.exs

Create a migration

    mix db.migration users_table

Run migrations

    mix db.migrate
