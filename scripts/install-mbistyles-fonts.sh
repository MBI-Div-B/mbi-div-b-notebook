#!/bin/bash

cd /tmp
mdkir firasans
unzip Fira_Sans.zip -d firasans
mkdir -p /usr/share/fonts/truetype/FiraSans
cp firasans/*.ttf /usr/share/fonts/truetype/FiraSans
fc-cache -fv