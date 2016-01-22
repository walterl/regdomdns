# `regdomdns`

## Introduction

This is a simple script used to update an *existing* DNS record on
[Register Domain SA](https://www.registerdomain.co.za)'s DNS management web
front-end.

It was created to automate the process of associating my home ADSL IP address
with a host name in my domain. This effectively replaces the need for a dynamic
DNS service.


## Requirements

* npm (1.3.10)
  * `npm install coffee-script` (1.9.0)
  * `npm install casperjs` (1.1.0-beta3)

*All versions are those in use at the time of writing. Other versions may also
work.*


## Usage

To update the `dynamic.mydomain.co.za` record to point to the IP `10.0.0.1`:

    $ coffee -o . regdomdns.coffee
    $ casperjs --ssl-protocol=tlsv1 regdomdns.js USERNAME PASSWORD dynamic.mydomain.co.za 10.0.0.1

... where `USERNAME` and `PASSWORD` are your Register Domain login credentials.

The `--ssl-protocol=tlsv1` option is required because PhantomJS (on which
CasperJS is built) defaults to SSLv3 and `https://www.registerdomain.co.za`
(rightly) only supports TLS.

**Note:** This script will only update an existing DNS record, and will NOT
create new ones.


## Automation

This script could be called from a (cron jobbed) shell script similar to the
following:

    #!/bin/bash

    hostname=dynamic.mydomain.co.za
    dnsserver=main.nameserver2.co.za
    public_ip=$(lookup_my_public_ip.sh)
    current_ip=$(dig +short $hostname @$dnsserver)
    regdom_user="admin@mydomain.co.za"
    regdom_pass="l3tmein"

    [ -z "$current_ip" ] && echo "No current IP!" && exit 1
    [ -z "$public_ip" ] && echo "No public IP!" && exit 1

    if [ "$public_ip" != "$current_ip" ]; then
        echo "[current $current_ip] <= [public $public_ip]"
        casperjs --ssl-protocol=tlsv1 $HOME/src/regdomdns/regdomdns.js \
            $regdom_user $regdom_pass $hostname $public_ip
    fi
