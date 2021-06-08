FROM ubuntu:focal-20210416

LABEL maintainer="Ralf Geschke <ralf@kuerbis.org>"

LABEL last_changed="2021-06-05"

# necessary to set default timezone Etc/UTC
ENV DEBIAN_FRONTEND noninteractive 
ENV LANG en_US.utf8

# Install PHP 7.4 with some libraries
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
	&& apt-get install -y php7.4-fpm \
	php7.4-curl php7.4-mysql php7.4-intl \
    php7.4-mbstring php7.4-bz2 php7.4-pgsql php7.4-xml php7.4-xsl php7.4-sqlite3 \
	php7.4-opcache php7.4-zip php7.4-gd php7.4-redis php7.4-memcache php7.4-memcached php7.4-json \
	php7.4-mongodb php7.4-mcrypt php7.4-bcmath php7.4-protobuf php7.4-imagick \
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
	&& cd /etc/php/7.4/fpm \
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

CMD ["php-fpm7.4"]
