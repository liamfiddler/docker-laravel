# ------------------------------------------------------------------------------
# Start with the official Ubuntu 14.04 base image
# ------------------------------------------------------------------------------

FROM ubuntu:14.04

MAINTAINER LiamFiddler <design+docker@liamfiddler.com>

# Set correct environment variables
ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive

# Use Supervisor to run and manage all other services
CMD ["/usr/local/bin/supervisord", "-c", "/etc/supervisord.conf"]

# Update and install required packages
RUN apt-get update && apt-get install -y \
	curl \
	libcurl3 \
	libcurl3-dev \
	php5-curl \
	python \
	cron \
	openssh-server \
	nano nginx \
	php5-fpm \
	php5-cli \
	php5-mcrypt \
	php5-mysqlnd \
	mysql-client \
	git

# ------------------------------------------------------------------------------
# Provision the server
# ------------------------------------------------------------------------------

# Make the web directory
RUN mkdir /share
RUN sudo chown -R www-data:www-data /share

# Make supervisor directories
RUN mkdir -p /etc/supervisord/
RUN mkdir /var/log/supervisord

# Copy supervisor conf files
COPY provision/conf/supervisor.conf /etc/supervisord.conf
COPY provision/service/* /etc/supervisord/

# Supervisor and Superlance
RUN curl https://bootstrap.pypa.io/ez_setup.py -o - | python
RUN easy_install supervisor
RUN easy_install superlance

# SSH daemon
RUN mkdir /var/run/sshd
RUN sed -i "s/#PasswordAuthentication yes/PasswordAuthentication no/" /etc/ssh/sshd_config

# SSH directories
RUN mkdir -p /root/.ssh
RUN chmod 700 /root/.ssh
RUN chown root:root /root/.ssh

# SSH keys
COPY provision/keys/config /root/.ssh/config
RUN chmod 600 /root/.ssh/config

# copy a development default site configuration
COPY provision/conf/nginx-default /etc/nginx/sites-available/default

# disable 'daemonize' in Nginx (because we use Supervisor instead)
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# copy FPM and CLI PHP configurations
COPY provision/conf/php.fpm.ini /etc/php5/fpm/php.ini
COPY provision/conf/php.cli.ini /etc/php5/cli/php.ini

# enable PHP mcrypt extension
RUN php5enmod mcrypt

# disable 'daemonize' in php5-fpm (because we use supervisor instead)
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf

# Node & NPM
RUN curl -sL https://deb.nodesource.com/setup_0.12 | sudo bash -
RUN sudo apt-get install -y nodejs

# install the latest version of Composer
RUN php -r "readfile('https://getcomposer.org/installer');" | php
RUN mv composer.phar /usr/local/bin/composer

# ------------------------------------------------------------------------------
# Prepare image for use
# ------------------------------------------------------------------------------

# Expose volumes
VOLUME ["/share"]

# Expose ports
EXPOSE 80 22

# ------------------------------------------------------------------------------
# Set locale (support UTF-8 in the container terminal)
# ------------------------------------------------------------------------------

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# ------------------------------------------------------------------------------
# Clean up
# ------------------------------------------------------------------------------

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
