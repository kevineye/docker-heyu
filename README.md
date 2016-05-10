[![](https://imagelayers.io/badge/kevineye/heyu:latest.svg)](https://imagelayers.io/?images=kevineye/heyu:latest 'Get your own badge on imagelayers.io')

This is a dockerized [heyu](http://www.heyu.org/) for controlling and monitoring X10 home automation devices via a CM11A module.

## Setup

Run this to generate some config files:

    docker run --rm -v /your/config/dir:/etc/heyu kevineye/heyu
    
Copy `x10config.sample` to `x10.sched.sample` and to `x10.conf` and `x10.sched` and edit your configuration.

## Run

    docker run -d \
        -v /your/config/dir:/etc/heyu \
        -v /etc/localtime:/etc/localtime \
        --device /dev/ttyUSB0 \
        -p 8080:80
        kevineye/heyu

The device can be configured in the `x10.conf` file.

## REST Web Services

If you map port 80, you can query and control heyu via the following web services:

 * **GET /{code}** - query the status of a device (e.g. `A1`). Returns text/plain body of `ON` or `OFF`. Codes are case sensitive.
 * **POST /{code}** - switch the device on or off (e.g. `A1`). POST body must be `ON` or `OFF`. Codes and body are case sensitive.
 * **POST /{housecode}** - switch all devices of the given house code (e.g. `A`) on or off. POST body must be `ON` or `OFF`. Codes and body are case sensitive.
 * **POST or GET /macro/{name}** - run a macro defined in `x10.sched`.
 
You may also add some minimal security by supplying the `URL_KEY` environment variable (choose a long, random string), which will prefix the key before each endpoint (e.g. /_<URL_KEY>_/A1).
