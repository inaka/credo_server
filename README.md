# CredoServer

[![Build Status](https://travis-ci.org/inaka/credo_server.svg?branch=master)](https://travis-ci.org/inaka/credo_server)
[![Coverage Status](https://coveralls.io/repos/github/inaka/credo_server/badge.svg?branch=master)](https://coveralls.io/github/inaka/credo_server?branch=master)
[![Deps Status](https://beta.hexfaktor.org/badge/all/github/inaka/credo_server.svg)](https://beta.hexfaktor.org/github/inaka/credo_server)

Server for running Credo on Github Pull Requests.

To start your own server:

  1. You need to set all environment variables needed. See [dev.exs](https://github.com/inaka/credo_server/blob/master/config/dev.exs)
  2. Install dependencies with `mix deps.get`
  3. Create database with `mix ecto.create`
  4. Run migrations with `mix ecto.migrate`
  5. Start app with `iex -S mix`

## Contact Us

If you find any **bugs** or have a **problem** while using this library, please
[open an issue](https://github.com/inaka/credo_server/issues/new) in this repo (or a pull request :)).

And you can check all of our open-source projects at
[inaka.github.io](http://inaka.github.io)
