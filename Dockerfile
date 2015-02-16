From centos:centos6
# Adapted from Richard Louapre <richard.louapre@marklogic.com>, https://gist.github.com/rlouapre/39f3cf793f27895ae8d2
MAINTAINER Michael Fishkow

#update yum repository and install openssh server
RUN yum update -y && \
   	yum install openssh-server java-1.7.0-openjdk-devel net-tools tar wget unzip -y
 
#generate ssh key
RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key && \
	ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key && \
	sed -ri 's/session    required     pam_loginuid.so/#session    required     pam_loginuid.so/g' /etc/pam.d/sshd && \
	mkdir -p /root/.ssh && chown root.root /root && chmod 700 /root/.ssh
 
#change root password to 123456
RUN echo 'root:123456' | chpasswd
 
WORKDIR /tmp
ADD tmp/MarkLogic-7.0-4.3.x86_64.rpm /tmp/MarkLogic-7.0-4.3.x86_64.rpm
# RUN curl -k -L -O https://www.dropbox.com/s/f4107q87gub1rcm/MarkLogic-7.0-4.3.x86_64.rpm?dl=0
# RUN mv MarkLogic-7.0-4.3.x86_64.rpm?dl=0 MarkLogic-7.0-4.3.x86_64.rpm
RUN yum -y install /tmp/MarkLogic-7.0-4.3.x86_64.rpm
RUN rm /tmp/MarkLogic-7.0-4.3.x86_64.rpm

WORKDIR /tmp
# installs from mysql public repo
ADD tmp/mysql-community-release-el6-5.noarch.rpm /tmp/mysql-community-release-el6-5.noarch.rpm
    yum localinstall mysql-community-release-el6-5.noarch.rpm -y && \
#    yum install mysql-community-server -y && \
    rm /tmp/mysql-community-release-el6-5.noarch.rpm && \
    yum clean all

# Setup supervisor
ADD https://bitbucket.org/pypa/setuptools/raw/bootstrap/ez_setup.py /tmp/ez_setup.py
RUN python /tmp/ez_setup.py
RUN easy_install supervisor
ADD supervisord.conf /etc/supervisord.conf


ENV PATH $PATH:/usr/local/mysql/bin:/usr/local/mysql/scripts

WORKDIR /usr/local/mysql

# define the locations of the data volumes
# mysql data volume
VOLUME /var/lib/mysql

# marklogic default data directory volume for configuration and log files
VOLUME /var/opt/MarkLogic

 
WORKDIR /
# Expose Ports
#   SSH 2022
#   MarkLogic 8000 8001 8002
#   Mysql 3306
EXPOSE 2022 3306 8000 8001 8002

# Run Supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]

# docker run -p 8000:8000 -p 8001:8001 -p 8002:8002 -p 2022:2022 -p 3306 mightycontent/centos6-ml-mysql