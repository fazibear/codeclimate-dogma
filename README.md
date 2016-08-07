# Code Climate Dogma Engine [![Build Status](https://travis-ci.org/fazibear/codeclimate-dogma.svg?branch=master)](https://travis-ci.org/fazibear/codeclimate-dogma)

Code Climate engine for [Dogma](https://github.com/lpil/dogma) a code style linter for [Elixir Language](http://elixir-lang.org/).

## Configure

You can configure this engine in `config/dogma.exs` file within you project. More informations is available [here](https://github.com/lpil/dogma/blob/master/docs/configuration.md).

Also you can add follwing options in .codeclimate.yml:

```yml
engines:
  dogma:
    enabled: true
    config:
      override:
        line_length:
          max_length: 666
      exclude:
       - /web/
```
