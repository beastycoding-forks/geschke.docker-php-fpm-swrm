FROM ubuntu:impish-20211102

LABEL maintainer="Ralf Geschke <ralf@kuerbis.org>"

LABEL last_changed="2021-11-15"

# necessary to set default timezone Etc/UTC
ENV DEBIAN_FRONTEND noninteractive 

# Install PHP 8.0 with some libraries
RUN apt-get update \
	&& apt-get -y upgrade \
	&& apt-get -y dist-upgrade \
	&& apt-get install -y ca-certificates \
	&& apt-get install -y --no-install-recommends \
	&& apt-get install -y locales \
	&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
	&& apt-get install -y git ssmtp wget php-fpm \
	php-mysql php-curl php-intl \
	php-mbstring php-bz2 php-pgsql php-xml php-xsl php-sqlite3 \
	php-opcache php-zip php-gd php-redis php-memcache php-zip \
	php-json php-intl \
	&& rm -rf /var/lib/apt/lists/* 
#	&& cp /usr/share/zoneinfo/Etc/UTC /etc/localtime
# php-recode

ENV LANG en_US.utf8

# Install composer
COPY install-composer.sh /tmp 
RUN cd /tmp/ \
  && sh install-composer.sh \
	&& mv /tmp/composer.phar /usr/local/bin/composer \
	&& rm install-composer.sh

# taken from official Docker PHP image
RUN set -ex \
	&& cd /etc/php/8.0/fpm \
	#&& mkdir /run/php \
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
