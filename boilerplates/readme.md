# <app-name>
Repository for the <app-name> project

## Development Instructions
### System requirements
- Ruby <ruby-version>
- Node <node-version>

### Enviromental variables
*none*

### Getting started
[Quick Start](https://github.com/wildland/guides#setting-up-your-development-enviroment) for getting development machine setup.

1. Run `bundle install` to install all dependencies
1. Run `rake wildland:db` (wildland_dev_tools needs updated to support a non-bower workflow)
1. Navigate to the ember directory `cd app-ember`
1. Run `yarn install`
1. Navigate back to the main directory and run `foreman start`

### Getting work done
[Wildland guide](https://github.com/wildland/) for getting work done.

## Production Requirements
### Enviroment varables
- `SECRET_KEY_BASE`
- `SKIP_EMBER=true`

