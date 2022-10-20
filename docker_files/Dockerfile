FROM perl:5.34
RUN cpanm  SOAP::Lite~"==1.27" XML::LibXML~"==2.0207" Data::Dumper~"==2.183" Switch~"==2.17" File::Slurp~"==9999.32" YAML::Tiny~"==1.73" DBI~"==1.643" DBD::Pg~"==3.16.0"
WORKDIR /idm/shell
COPY perl_scripts/vymenik_sync.pl .
COPY perl_scripts/lib lib/
RUN useradd -d /idm/shell -u 1000 vymenik; chown -R vymenik:vymenik /idm/shell
USER vymenik
CMD  /usr/local/bin/perl /idm/shell/vymenik_sync.pl

