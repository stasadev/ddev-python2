[![add-on registry](https://img.shields.io/badge/DDEV-Add--on_Registry-blue)](https://addons.ddev.com)
[![tests](https://github.com/stasadev/ddev-python2/actions/workflows/tests.yml/badge.svg?branch=main)](https://github.com/stasadev/ddev-python2/actions/workflows/tests.yml?query=branch%3Amain)
[![last commit](https://img.shields.io/github/last-commit/stasadev/ddev-python2)](https://github.com/stasadev/ddev-python2/commits)
[![release](https://img.shields.io/github/v/release/stasadev/ddev-python2)](https://github.com/stasadev/ddev-python2/releases/latest)

# DDEV Python 2

## Overview

[Python 2](https://www.python.org/doc/sunset-python-2/) has reached its end of life.

This add-on integrates legacy Python 2 inside the `ddev-webserver` into your [DDEV](https://ddev.com/) project.

It is only needed if your `npm` setup requires Python 2 to build dependencies.

## Installation

```bash
ddev add-on get stasadev/ddev-python2
ddev restart
```

After installation, make sure to commit the `.ddev` directory to version control.

## Usage

| Command | Description |
| ------- | ----------- |
| `ddev exec python2.7` | Run Python 2.7.18 inside the `web` container.<br>Installed at `/usr/bin/python2.7` |
| `ddev exec python` | Run Python 2.7.18 inside the `web` container.<br>Symlink at `/usr/local/bin/python` |

This add-on also installs the `build-essential` package, which is usually required for the `npm build`, see [config.python2.yaml](./config.python2.yaml). Remove or replace the contents of this file if you only need Python 2.

## Credits

**Contributed and maintained by [@stasadev](https://github.com/stasadev)**
