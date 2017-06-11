FROM centos:7
# REF: https://hub.docker.com/_/centos/

# Production grade MongoDB
MAINTAINER "Ernest G. Wilson II" <ErnestGWilsonII@gmail.com>

# Allow CentOS 7x to run inside a Docker container using systemd
ENV container docker
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
 rm -f /lib/systemd/system/multi-user.target.wants/*;\
 rm -f /etc/systemd/system/*.wants/*;\
 rm -f /lib/systemd/system/local-fs.target.wants/*; \
 rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
 rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
 rm -f /lib/systemd/system/basic.target.wants/*;\
 rm -f /lib/systemd/system/anaconda.target.wants/*;
VOLUME [ "/sys/fs/cgroup" ]

# Install MongoDB
COPY src/mongodb-org-3.4.repo /etc/yum.repos.d/mongodb-org-3.4.repo
RUN yum -y upgrade; yum -y install mongodb-org; yum clean all

# Customize MongoDB
COPY src/mongod-replication.key /etc/ssl/private/mongod-replication.key
COPY src/mongodb.pem /etc/ssl/mongodb.pem
COPY src/mongod.conf /etc/mongod.conf
COPY src/mongod.service /usr/lib/systemd/system/mongod.service
RUN chmod 0400 /etc/ssl/private/mongod-replication.key;\
 chown mongod:root /etc/ssl/private/mongod-replication.key;\
 mkdir -p /data/db;\
 mkdir -p /data/configdb;\
 chown -R mongod:root /data;\
 chmod 0644 /usr/lib/systemd/system/mongod.service;\
 systemctl enable mongod.service;

# Expose MongoDB ports
EXPOSE 27017

# Start systemd services inside Docker container
CMD ["/usr/sbin/init"]

