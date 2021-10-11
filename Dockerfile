FROM ubuntu:focal-20210921

LABEL maintainer="Ralf Geschke <ralf@kuerbis.org>"

LABEL last_changed="2021-10-11"

# necessary to set default timezone Etc/UTC
ENV DEBIAN_FRONTEND noninteractive 
ENV LANG en_US.utf8

# Install PHP 8.0 with some libraries
RUN apt-get update \
	&& apt-get -y upgrade \
	&& apt-get -y dist-upgrade \
	&& apt-get install -y ca-certificates \
	&& apt-get install -y --no-install-recommends \
	&& apt-get install -y locales software-properties-common \
	&& add-apt-repository -y ppa:ondrej/php \
	&& apt-get update \
	#&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
	&& apt-get install -y git ssmtp wget \
	&& apt-get install -y php8.0-fpm \
	php8.0-curl php8.0-mysql php8.0-intl \
    php8.0-mbstring php8.0-bz2 php8.0-pgsql php8.0-xml php8.0-xsl php8.0-sqlite3 \
	php8.0-opcache php8.0-zip php8.0-gd php8.0-redis php8.0-memcache php8.0-memcached \
	php8.0-mongodb php8.0-mcrypt php8.0-bcmath php8.0-protobuf php8.0-imagick \
	&& rm -rf /var/lib/apt/lists/* 
	
	#\
#	&& cp /usr/share/zoneinfo/Etc/UTC /etc/localtime
# php-recode


# Install composer
COPY install-composer.sh /tmp 
RUN cd /tmp/ \
  && sh install-composer.sh \
	&& mv /tmp/composer.phar /usr/local/bin/composer \
	&& rm install-composer.sh

# taken from official Docker PHP image
RUN set -ex \
	&& cd /etc/php/8.0/fpm \
	&& mkdir /run/php \
	&& { \
	echo '[global]'; \
	echo 'error_log = /proc/self/fd/2'; \
	echo; \
	echo '[www]'; \
	echo '; if we send this to /proc/self/fd/1, it never appears'; \
	echo 'access.log = /proc/self/fd/2'; \
	echo; \
	echo 'clear_env = no'; \
	echo; \
	echo '; Ensure worker stdout and stderr are sent to the main error log.'; \
	echo 'catch_workers_output = yes'; \
	} | tee pool.d/docker.conf \
	&& { \
	echo '[global]'; \
	echo 'daemonize = no'; \
	echo; \
	echo '[www]'; \
	echo 'listen = [::]:9000'; \
	} | tee pool.d/zz-docker.conf


WORKDIR /usr/share/nginx/html

EXPOSE 9000

CMD ["php-fpm8.0"]
