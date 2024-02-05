#!/usr/bin/env bash
mkdir /etc/lightdm/lightdm.conf.d/
echo -e "[Seat:*]\ngreeter-hide-users=false" > /etc/lightdm/lightdm.conf.d/01_my.conf