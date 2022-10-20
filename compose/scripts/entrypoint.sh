#!/bin/bash

/usr/local/bin/perl -Tw <<EOF
print "This is a template entrypoint script.\n";
print "Entrypoint script is called upon container start.\n";
print "Here, you should only call the 'perl ...' binary.\n";
print "Everything else should be set up beforehand in runscripts.\n";
EOF
