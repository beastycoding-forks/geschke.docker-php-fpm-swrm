# geschke/php-fpm-swrm

This is a minimalistic php-fpm Docker image based on the official Ubuntu images.  
The image provides different PHP versions as seen below.

## Supported tags

* 7.4-fpm-n, latest - usage of PHP 7.4 included in the Ubuntu distribution. This is the main branch as known before.
* 7.4-fpm-ubuntu20.04-sury-n - PHP 7.4 from deb.sury.org [PPA](https://launchpad.net/~ondrej/+archive/ubuntu/php/) based on Ubuntu 20.04 LTS
* 8.0-fpm-ubuntu20.04-sury-n - PHP 8.0 from deb.sury.org [PPA](https://launchpad.net/~ondrej/+archive/ubuntu/php/) based on Ubuntu 20.04 LTS

n = build number, higher numbers are newer builds

## Usage

To download the image run

    docker pull geschke/php-fpm-swrm

This is a minimalistic approach to build a php-fpm environment. It doesn't
need configuration (and there is currently no way to modify the options
without inheriting the image).
Additional it installs the Composer dependency manager.

This image is intended for running as PHP-FPM backend in a Docker swarm mode environment.

For sure it is possible to start the container with the legacy "docker run" command, as seen in the following example.

To start the container, just run a command like this:
  
    docker run -d --name phpfpm -p 127.0.0.1:9000:9000 \
         --volume /path/to/your/files/on/host:/var/www/html \
         geschke/php-fpm-swrm

In the above example you will start a container named "phpfpm" which mounts
the volume /path/to/your/files/on/host to the internal directory
/var/www/html.
The -p option opens the port 9000 on localhost, so any Proxy or web server
can reach the php-fpm target. If you want to access from another server,
i.e. outside the current machine, just use the -p option without limiting
the host, e.g. -p 9000:9000. But beware if you expose the port like this - without a firewall your php-fpm
installation is open to the world!

## Usage example with Nginx

To use Nginx, set up a configuration like this:

    [...|
    # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
    #
    location ~ \.php$ {
        # Use the tcp connection
        fastcgi_pass 127.0.0.1:9000;
        # ...but not the socket
        #fastcgi_pass unix:/run/php/php7.0-fpm.sock;
        fastcgi_index index.php;
        include fastcgi.conf;
    }
    [...]

The example is from a working configuration of Nginx Ubuntu package. If not
set in the fastcgi.conf, maybe it's necessary to add the following options:

    fastcgi_param  SCRIPT_FILENAME    $document_root$fastcgi_script_name;
    fastcgi_param  SCRIPT_NAME        $fastcgi_script_name;

These options are set as default in the fastcgi.conf file and could be
changed in the location settings.

At last, you have to configure the document root settings. Let's explain by
example. The PHP files on your host are installed in:

    /vol/www/phpapp1

So the volume parameter when starting the container has to be:

    -v /vol/www/phpapp1:/var/www/html

So inside the Docker container any of your PHP files could be reached within
/var/www/html.

Then you have to configure the document root as:

    root /var/www/html;

in your Nginx sites configuration file, e.g.
/etc/nginx/sites-available/default.

You can change this behaviour if you modify the SCRIPT_FILENAME option in
the Nginx fastcgi options.

## Usage example with Docker swarm mode

Have a look at some blog articles at [www.kuerbis.org](https://www.kuerbis.org) (German only, please use Google Translate).

## Credits

This image is based on the official Ubuntu image, the Ubuntu or deb.sury.org PHP packages and uses
some configuration snippets of the official PHP Docker image. Thank you all!
