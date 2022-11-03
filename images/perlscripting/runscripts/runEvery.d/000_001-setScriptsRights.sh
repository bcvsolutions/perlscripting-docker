#!/bin/bash
echo "[$0] Setting correct rights and ownership for PERL scripts ...";

chown perlscripting:perlscripting "$SCRIPT_HOME";
chmod 750 "$SCRIPT_HOME";

find /opt/scripts -mindepth 1 -maxdepth 5 -exec chown -v root:perlscripting {} \;
find /opt/scripts -mindepth 1 -maxdepth 5 -type d -exec chmod -v 755 {} \;
find /opt/scripts -maxdepth 5 -type f -exec chmod -v 644 {} \;
chmod -v 755 /opt/scripts/entrypoint.sh
