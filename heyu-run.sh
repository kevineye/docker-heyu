#!/bin/sh

if [ ! -f /etc/heyu/x10.conf ]; then
  cp /etc/heyu.default/* /etc/heyu
  echo "x10config.sample and x10.sched.sample have been copied to your config directory."  1>&2
  echo "Please use them to create x10.conf and x10.sched and re-run." 1>&2
  exit;
fi

heyu engine 1>&2
heyu upload 1>&2
heyu setclock 1>&2

if [ -z "$URL_KEY" ]; then
    export prefix="/"
else
    export prefix="/$URL_KEY/"
fi

macro=$(cat <<'SCRIPT')
REQUEST_URI=$(expr substr "$REQUEST_URI" $(expr length "$prefix") 200)
echo "Access-Control-Allow-Origin: *"
echo
heyu macro "$(expr substr \"$REQUEST_URI\" 8 100 | tr -cd A-Za-z0-9_-)" 1>&2
SCRIPT

getset=$(cat <<'SCRIPT')
REQUEST_URI=$(expr substr "$REQUEST_URI" $(expr length "$prefix") 200)
echo "Access-Control-Allow-Origin: *"
echo
unit_code=$(expr match "$REQUEST_URI" '/\([A-P][01]\{0,1\}[0-9]\)$')
if [ ! -z "$unit_code" ]; then 
    if [ "$REQUEST_METHOD" = "GET" ]; then
        if [ "$(heyu onstate "$unit_code")" '>' 0 ]; then echo ON; else echo OFF; fi
    elif [ "$REQUEST_METHOD" = "POST" ]; then
        body=$(cat)
        if [ "$body" = "ON" ]; then
            heyu on "$unit_code" 1>&2
        else
            heyu off "$unit_code" 1>&2
        fi
    fi
elif [ "$REQUEST_METHOD" = "POST" ]; then
    house_code=$(expr match "$REQUEST_URI" '/\([A-P]\)$')
    if [ ! -z "$house_code" ]; then
        body=$(cat)
        if [ "$body" = "ON" ]; then
            heyu allon "$house_code" 1>&2
        else
            heyu alloff "$house_code" 1>&2
        fi
    fi
fi
SCRIPT

shell2http -cgi -no-index -port 80 -export-vars 'prefix' \
    "${prefix}macro/" "$macro" \
    "$prefix" "$getset" &

heyu monitor
