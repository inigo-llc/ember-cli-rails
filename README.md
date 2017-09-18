# trailhead

A rails template and build script for working with [ember-cli](https://github.com/stefanpenner/ember-cli)
and deploying with a rails api / backend. The goal is to allow ember-cli to be
in charge of building and testing your ember app, and rails to be in charge of
building and testing your rails app.


## Dependencies

You will need the usual [development setup](https://github.com/wildland/guides#setting-up-your-development-enviroment):
- git (v2.13.x)
- ruby (v2.3.x)
  - bundler (v1.15.x)
  - rails (v4.2.x)
- node (v6.11.x)
  - npm (v5.2.x)
  - bower (v1.8.x)
  - ember-cli (v2.15.x)

## Usage
Ensure that you have `rails 4.2.x` installed in your global gems. You can check this with `rails -v`.
You can install this with `gem install rails -v 4.2.7`.

Ensure that you have `ember-cli 2.15.1` installed in your global npm. You can check this with `ember -v`.
You can install this with `npm install -g ember-cli@2.15.1`.

```bash
$ rails new <app-name> -m https://raw.githubusercontent.com/wildland/trailhead/master/template.rb --database=postgresql --skip-spring --skip-turbolinks -J
```

You now have a rails project with an ember-cli project within it.

See the `README.md` inside the project for additional information.
