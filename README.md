# ember-cli-rails

A rails template and build script for working with [ember-cli](https://github.com/stefanpenner/ember-cli)
and deploying with a rails api / backend. The goal is to allow ember-cli to be
in charge of building and testing your ember app, and rails to be in charge of
building and testing your rails app.


## Dependencies

You will need the usual [development setup](https://github.com/wildland/guides#setting-up-your-development-enviroment):
- git
- ruby
  - bundler
  - rails
- node
  - npm
  - bower
  - ember-cli

## Usage

```bash
$ rails new <app-name> -m https://raw.githubusercontent.com/wildland/ember-cli-rails/master/template.rb --database=postgresql --skip-spring --skip-turbolinks -J
```

You now have a rails project with an ember-cli project within it.

The template will set a catch-all rails route that serves up the ember app.
**You'll need to update your ember app config to set `location: 'hash'` manually
for this to work.** As you add api endpoints to rails be sure to place them
before the catch all route.
