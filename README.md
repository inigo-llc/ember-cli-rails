# trailhead

A rails template and build script for working with [ember-cli](https://github.com/stefanpenner/ember-cli)
and deploying with a rails api / backend. The goal is to allow ember-cli to be
in charge of building and testing your ember app, and rails to be in charge of
building and testing your rails app.


## Dependencies
You will need the usual [development setup](https://github.com/wildland/guides#setting-up-your-development-enviroment):


## Usage
```bash
$ rails new <app-name> -m https://raw.githubusercontent.com/wildland/trailhead/master/template.rb --database=postgresql --skip-spring --skip-turbolinks -J
```

You now have a rails project with an ember-cli project within it.

See the `README.md` inside the project for additional information.
