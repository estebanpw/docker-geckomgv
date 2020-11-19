#!/usr/bin/env bash

#source /externaltool/GeckoMGVvenv/bin/activate

echo "Starting supervisord"
supervisord -c /etc/supervisor/conf.d/supervisord.conf
service supervisor start

echo "Starting geckomgv"
supervisorctl start geckomgv

echo "Logging"
tail -f /tmp/supervisord.log /externaltool/geckomgv/geckomgv.log
