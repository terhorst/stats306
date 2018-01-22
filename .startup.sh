#!/bin/sh
rm -rf stats306_master
git clone https://github.com/terhorst/stats306 stats306_clean
chmod -R 555 stats306_master
echo "stats306_clean will be deleted and replaced with a fresh copy of https://github.com/terhorst/stats306 after each login. Be sure to save you work elsewhere if you want it to persist between logins." > README.txt
