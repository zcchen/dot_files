#!/bin/sh

sudo cp ./aria2-rpc@.service /lib/systemd/system/
sudo systemctl daemon-reload

