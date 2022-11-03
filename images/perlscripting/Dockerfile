# FROM perl:5.34
FROM repo.iamappliance.com:8443/centos:7

ENV SCRIPT_HOME /opt/scripts
ENV RUNSCRIPTS_PATH /runscripts

# do initial update and install stuff we need
# RUN apt-get update && apt-get upgrade -y && apt-get install -y sudo
RUN yum install -y epel-release && \
    yum update -y && \
    yum install -y gcc perl perl-devel perl-libwww-perl perl-App-cpanminus perl-B-Lint perl-Data-Dumper perl-DBI perl-DBD-Pg perl-DBD-MySQL perl-LWP-Protocol-https perl-Socket perl-Socket6 perl-SOAP-Lite perl-Switch perl-Test-NoWarnings perl-Test-Simple perl-Try-Tiny perl-YAML-Tiny sudo wget && \
    yum clean all

RUN groupadd -r -g 998 perlscripting && \
    useradd -r -u 999 -s /sbin/nologin -g perlscripting -d "$SCRIPT_HOME" perlscripting && \
    mkdir "$SCRIPT_HOME" && \
    chown perlscripting:perlscripting "$SCRIPT_HOME" && \
    chmod 750 "$SCRIPT_HOME"

# install additionals that we need or find handy
# We use oracle repos directly as per official instructions https://www.oracle.com/cz/database/technologies/instant-client/linux-x86-64-downloads.html: "Instant Client RPMs are also available without click-through from yum.oracle.com for Oracle Linux 8 and Oracle Linux 7. Older RPM packages are available for Oracle Linux 8, Oracle Linux 7 and Oracle Linux 6."
# We can even redistribute such container https://www.oracle.com/docs/tech/instant-client-wp-131479.pdf: "Oracle Corporation offers you, as an Independent Software Vendor (ISV), a freely redistributable license for Instant Client. You can now easily prepackage an Oracle client along with your applications."
ENV INSTCLIENT_VERSION 19.16
ENV ORACLE_HOME "/usr/lib/oracle/19.16/client64"
RUN yum-config-manager --add-repo=https://yum.oracle.com/repo/OracleLinux/OL7/oracle/instantclient/x86_64 && \
    wget https://yum.oracle.com/RPM-GPG-KEY-oracle-ol7 -O /tmp/ol7.gpg && \
    sha256sum /tmp/ol7.gpg | grep -q e9280ce2eae9b06ae3d7aa3601b113d38f379c837221ee07908fe8dd20fedb86 && \
    rpm --import /tmp/ol7.gpg && \
    \
    yum install -y oracle-instantclient${INSTCLIENT_VERSION}-{basic,devel,sqlplus} && \
    yum clean all

RUN cpanm -v install DBD::Oracle~"==1.83"

# copy runscripts
COPY runscripts "$RUNSCRIPTS_PATH/"
RUN find "$RUNSCRIPTS_PATH/" -name "*.sh" -exec chmod -v u+x {} \;

CMD ["/bin/bash","-c","$RUNSCRIPTS_PATH/run.sh"]
