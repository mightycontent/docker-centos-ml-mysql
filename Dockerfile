From centos:centos6
# Adapted from Richard Louapre <richard.louapre@marklogic.com>, https://gist.github.com/rlouapre/39f3cf793f27895ae8d2
MAINTAINER Michael Fishkow

#update yum repository and install openssh server
RUN yum update -y && \
   	yum install -y openssh-server
 
#generate ssh key
RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key && \
	ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key && \
	sed -ri 's/session    required     pam_loginuid.so/#session    required     pam_loginuid.so/g' /etc/pam.d/sshd && \
	mkdir -p /root/.ssh && chown root.root /root && chmod 700 /root/.ssh
 
#change root password to 123456
RUN echo 'root:123456' | chpasswd
 
WORKDIR /tmp
ADD build-source/MarkLogic-7.0-4.3.x86_64.rpm /tmp/MarkLogic-7.0-4.3.x86_64.rpm
# RUN curl -k -L -O https://www.dropbox.com/s/f4107q87gub1rcm/MarkLogic-7.0-4.3.x86_64.rpm?dl=0
# RUN mv MarkLogic-7.0-4.3.x86_64.rpm?dl=0 MarkLogic-7.0-4.3.x86_64.rpm
RUN yum -y install /tmp/MarkLogic-7.0-4.3.x86_64.rpm
RUN rm /tmp/MarkLogic-7.0-4.3.x86_64.rpm
# Setup supervisor
ADD https://bitbucket.org/pypa/setuptools/raw/bootstrap/ez_setup.py /tmp/ez_setup.py
RUN python /tmp/ez_setup.py
RUN easy_install supervisor
ADD supervisord.conf /etc/supervisord.conf
 
WORKDIR /
# Expose MarkLogic admin
EXPOSE 2022 8000 8001 8002
# Run Supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
