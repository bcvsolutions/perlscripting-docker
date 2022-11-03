#!/bin/bash

# If you need to do something extra special, you can script it yourself.
# Files are taken from startPerl.d/ in alphabetical order and SOURCED into this bash.
# Sourcing allows you to operate one the whole env if you need - this is a difference
# from runOnce.d and runEvery.d scripts which are just executed, not sourced.
# This is invoked every time the container starts.
echo "[$0] Sourcing files in order: $(ls $RUNSCRIPTS_PATH/startPerl.d | tr '\n' ' ')";
for f in $(ls "$RUNSCRIPTS_PATH/startPerl.d"); do
  echo "[$0] Sourcing file $f";
  . "$RUNSCRIPTS_PATH/startPerl.d/$f";
done

echo "[$0] Starting entrypoint.sh script...";
sudo -Eu perlscripting /opt/scripts/entrypoint.sh
