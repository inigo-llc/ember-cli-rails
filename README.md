# trailhead

A rails template and build script for working with [ember-cli](https://github.com/stefanpenner/ember-cli)
and deploying with a rails api / backend. The goal is to allow ember-cli to be
in charge of building and testing your ember app, and rails to be in charge of
building and testing your rails app.


## Dependencies

You will need the usual [development setup](https://github.com/wildland/guides#setting-up-your-development-enviroment):
- git
- ruby (2.3.1)
  - bundler
  - rails
- node (v4.5.0)
  - npm
  - bower
  - ember-cli

## Usage
Ensure that you have `rails 4.2.x` installed in your global gems. You can check this with `rails -v`.
You can install this with `gem install rails -v 4.2.7`.

Ensure that you have `ember 1.13.13` installed in your global npm. You can check this with `ember -v`.
You can install this with `npm install -g ember-cli@1.13.13`.

```bash
$ rails new <app-name> -m https://raw.githubusercontent.com/wildland/trailhead/master/template.rb --database=postgresql --skip-spring --skip-turbolinks -J
```

You now have a rails project with an ember-cli project within it.

See the `README.md` inside the project for additional information.
