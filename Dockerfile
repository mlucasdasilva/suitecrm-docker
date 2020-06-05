FROM centos:centos7

RUN ln -snf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime

RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
 && rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm

RUN yum -y update && yum clean all
RUN yum -y install epel-release

RUN yum -y install php71w php71w-opcache php71w-cli php71w-common php71w-gd php71w-intl \
                   php71w-mbstring php71w-mcrypt php71w-mysql php71w-mssql php71w-pdo \
                   php71w-pear php71w-soap php71w-xml php71w-xmlrpc httpd

RUN yum -y install php71w-imap php71w-snmp php71w-ldap

RUN yum -y install mod_ssl

RUN sed -i \
        -e 's~ServerAdmin root@localhost~ServerAdmin mlucasdasilva@yahoo.com.br~g' \
        /etc/httpd/conf/httpd.conf


# Simple startup script to avoid some issues observed with container restart
COPY run-httpd.sh /run-httpd.sh
RUN chmod -v +x /run-httpd.sh

EXPOSE 80 443

## Adiciona driver ODBC para sqlserver

RUN curl -L https://github.com/microsoft/msphpsql/releases/download/v5.6.0/CentOS7-7.1.tar -o CentOS7-7.1.tar     && \
    tar -xvf CentOS7-7.1.tar                                                                                      && \
    rm -rf CentOS7-7.1.tar                                                                                        && \
    cp CentOS7-7.1/php_pdo_sqlsrv_71_nts.so /usr/lib64/php/modules                                                && \
    cp CentOS7-7.1/php_sqlsrv_71_nts.so /usr/lib64/php/modules                                                    && \
    rm -rf CentOS7-7.1

COPY sqlserver.ini /etc/php.d

ENTRYPOINT ["/run-httpd.sh"]

ARG APP_VERSION
ENV SUITECRM_VERSION=${APP_VERSION}
ENV SUITECRM_VERSION=${APP_VERSION:-7.10.18}

RUN ln -snf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime

RUN yum -y update && yum clean all
RUN yum -y install unzip

RUN yum -y install wget

RUN wget https://sourceforge.net/projects/suitecrm/files/SuiteCRM-${SUITECRM_VERSION}.zip
#ADD SuiteCRM-${SUITECRM_VERSION}.zip /.
RUN unzip /SuiteCRM-${SUITECRM_VERSION}.zip && mv SuiteCRM-${SUITECRM_VERSION} /install-suitecrm && rm -f SuiteCRM-${SUITECRM_VERSION}.zip && chown apache:apache -R /install-suitecrm

# Simple install and startup script
COPY entrypoint-suitecrm.sh /entrypoint-suitecrm.sh
RUN chmod -v +x /entrypoint-suitecrm.sh

# Php.ini ajustado para suitecrm 
COPY php.ini /etc/php.ini

EXPOSE 80

ENTRYPOINT ["/entrypoint-suitecrm.sh"]

