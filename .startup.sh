#!/bin/sh
rm -rf stats306_master
git clone https://github.com/terhorst/stats306 stats306_master
chmod -R 555 stats306_master
echo "stats306_master will be deleted and replaced with a fresh copy of \nhttps://github.com/terhorst/stats306 after each login. Be sure to save your \nwork elsewhere if you want it to persist between logins." > README.txt
