FROM ubuntu:16.04
MAINTAINER LiamFiddler <design+docker@liamfiddler.com>

# Set correct environment variables
ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive

# Use Supervisor to run and manage all other services
CMD ["/usr/local/bin/supervisord", "-c", "/etc/supervisord.conf"]

# Install required packages
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E5267A6C C300EE8C && \
	echo 'deb http://ppa.launchpad.net/ondrej/php/ubuntu xenial main' > /etc/apt/sources.list.d/ondrej-php7.list && \
	echo 'deb http://ppa.launchpad.net/nginx/development/ubuntu xenial main' > /etc/apt/sources.list.d/nginx.list && \
	apt-get update && apt-get install -y \
		locales \
		libmcrypt-dev \
		libreadline-dev \
		curl \
		libcurl3 \
		libcurl3-dev \
		python \
		cron \
		nano \
		openssl \
		build-essential \
		libssl-dev \
		libxrender-dev \
		git-core \
		libx11-dev \
		libxext-dev \
		libfontconfig1-dev \
		libfreetype6-dev \
		fontconfig \
		nginx \
		php7.2-dev \
		php7.2-fpm \
		php7.2-cli \
		php7.2-gd \
		php7.2-sqlite \
		php7.2-curl \
		php7.2-opcache \
		php7.2-mbstring \
		php7.2-zip \
		php7.2-xml \
		php-pear \
		php7.2-mysql \
		redis-server \
		nodejs \
		npm && \
	mkdir /share && \
	mkdir -p /etc/supervisord/ && \
	mkdir /var/log/supervisord && \
	mkdir /run/php && \
	curl https://bootstrap.pypa.io/ez_setup.py -o - | python && \
	easy_install supervisor && \
	pecl install mcrypt-1.0.1

RUN apt-get install php7.2-soap -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"

# Copy supervisor config files, Laravel cron file, & default site configuration
COPY provision/conf/supervisor.conf /etc/supervisord.conf
COPY provision/service/* /etc/supervisord/
COPY provision/cron/laravel /etc/cron.d/laravel
COPY provision/conf/nginx-default /etc/nginx/sites-available/default

# Configure PHP, Nginx, Redis, and clean up
RUN sed -i 's/;opcache.enable=0/opcache.enable=1/g' /etc/php/7.2/fpm/php.ini && \
	sed -i 's/;opcache.fast_shutdown=0/opcache.fast_shutdown=1/g' /etc/php/7.2/fpm/php.ini && \
	sed -i 's/;opcache.enable_file_override=0/opcache.enable_file_override=1/g' /etc/php/7.2/fpm/php.ini && \
	sed -i 's/;opcache.revalidate_path=0/opcache.revalidate_path=1/g' /etc/php/7.2/fpm/php.ini && \
	sed -i 's/;opcache.save_comments=1/opcache.save_comments=1/g' /etc/php/7.2/fpm/php.ini && \
	sed -i 's/;opcache.revalidate_freq=2/opcache.revalidate_freq=60/g' /etc/php/7.2/fpm/php.ini && \
	echo "extension=mcrypt.so" > /etc/php/7.2/mods-available/mcrypt.ini && \
	ln -s /etc/php/7.2/mods-available/mcrypt.ini /etc/php/7.2/fpm/conf.d/20-mcrypt.ini && \
	ln -s /etc/php/7.2/mods-available/mcrypt.ini /etc/php/7.2/cli/conf.d/20-mcrypt.ini && \
	sed -i 's/pm.max_children = 5/pm.max_children = 12/g' /etc/php/7.2/fpm/pool.d/www.conf && \
	sed -i 's/pm.start_servers = 2/pm.start_servers = 4/g' /etc/php/7.2/fpm/pool.d/www.conf && \
	sed -i 's/pm.min_spare_servers = 1/pm.min_spare_servers = 4/g' /etc/php/7.2/fpm/pool.d/www.conf && \
	sed -i 's/pm.max_spare_servers = 3/pm.max_spare_servers = 8/g' /etc/php/7.2/fpm/pool.d/www.conf && \
	echo "daemon off;" >> /etc/nginx/nginx.conf && \
	sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php/7.2/fpm/php-fpm.conf && \
	sed -i 's/^daemonize yes/daemonize no/' /etc/redis/redis.conf && \
	sed -i 's/^# maxmemory <bytes>/maxmemory 32mb/' /etc/redis/redis.conf && \
	sed -i 's/^# maxmemory-policy volatile-lru/maxmemory-policy allkeys-lru/' /etc/redis/redis.conf && \
	chmod 644 /etc/cron.d/laravel && \
	ln -s /usr/bin/nodejs /usr/bin/node && \
	locale-gen en_US.UTF-8 && \
	apt-get -yq autoremove --purge && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set the language
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Expose volumes and ports
#VOLUME ["/share"]
EXPOSE 80
