#!/bin/bash
# notifications.sh
# Shows the number of active mako notifications next to the bell

# mako stores notifications via D-Bus; we can use makoctl to list them
# Count active notifications
count=$(makoctl list | wc -l)

if [ "$count" -gt 0 ]; then
    echo " $count"
else
    echo ""
fi
