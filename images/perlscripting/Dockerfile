FROM perl:5.34

ENV SCRIPT_HOME /opt/scripts
ENV RUNSCRIPTS_PATH /runscripts

# do initial update
RUN apt-get update && apt-get upgrade -y && apt-get install -y sudo

# install support for various things we could possibly want
RUN cpanm \
  SOAP::Lite~"==1.27" \
  XML::LibXML~"==2.0207" \
  Data::Dumper~"==2.183" \
  Switch~"==2.17" \
  File::Slurp~"==9999.32" \
  YAML::Tiny~"==1.73" \
  DBI~"==1.643" \
  DBD::Pg~"==3.16.0"

RUN groupadd -r -g 998 perlscripting && \
    useradd -r -u 999 -s /sbin/nologin -g perlscripting -d "$SCRIPT_HOME" perlscripting && \
    mkdir "$SCRIPT_HOME" && \
    chown perlscripting:perlscripting "$SCRIPT_HOME" && \
    chmod 750 "$SCRIPT_HOME"

COPY runscripts "$RUNSCRIPTS_PATH/"
RUN find "$RUNSCRIPTS_PATH/" -name "*.sh" -exec chmod -v u+x {} \;

CMD ["/bin/bash","-c","$RUNSCRIPTS_PATH/run.sh"]
