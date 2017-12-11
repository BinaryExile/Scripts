#!/bin/bash
X=$(gsettings list-recursively | grep "scaling-factor uint32")
string="My long string"
if [[ $X == *"1"* ]]; then
	gsettings set org.gnome.desktop.interface scaling-factor 2
else
	gsettings set org.gnome.desktop.interface scaling-factor 1
fi
echo "Remember to Change burp - User options -> display -> font size (12 or 14)"
