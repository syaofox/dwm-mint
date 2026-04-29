#!/bin/bash


DESKTOP_FILE="/usr/share/xsessions/dwm.desktop"

sudo bash -c "cat > $DESKTOP_FILE" <<EOF
[Desktop Entry]
Encoding=UTF-8
Name=Dwm
Comment=Dynamic window manager
Exec=dbus-run-session dwm
Icon=dwm
Type=Application
EOF

echo "Created $DESKTOP_FILE"
exit 0