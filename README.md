# Docker Laravel

The Dockerfile and associated setup files for a Laravel or Lumen Docker container.

![](https://images.microbadger.com/badges/version/liamfiddler/docker-laravel.svg) ![](https://images.microbadger.com/badges/image/liamfiddler/docker-laravel.svg)

### Packages

The following packages are installed:
- Nginx
- PHP (with GD, Mcrypt, Sqlite, MySQL, and Opcache)
- Redis (configured as a LRU cache)
- NPM

Processes are managed by Supervisor.

A cron job has been set up which will call the Laravel scheduler once per minute.

Before using Redis with Laravel, you will need to install the `predis/predis`
package via Composer. Refer to the [Laravel Redis documentation](https://laravel.com/docs/master/redis).


### Adding your website files

ADD/COPY your Laravel/Lumen project to the `/share` directory in your
Dockerfile, or if you are not extending this container you can mount
your local directory to `/share` as a volume.


### Executing Artisan commands when the container is run

Any [Supervisor program:x config files](http://supervisord.org/configuration.html#program-x-section-values)
you ADD/COPY to the `/etc/supervisord/` directory will be automatically run when
the container starts. Make sure the filename ends with `.conf`.


### Usage for non-Laravel or Lumen projects

If you want to use this container for a generic PHP project you can mount
your project to the `/share/public` directory.

You should also remove the Laravel cron job that runs every minute
by adding the following command to your Dockerfile:

```
RUN rm /etc/cron.d/laravel
```


### Terminal access

SSH is not configured in this container, it is assumed you will gain access
via the following command:

```
docker exec -it YOUR_CONTAINER_NAME bash
```

Once you are in you will need to set the `TERM` environment otherwise some
commands, like `clear` or `nano`, will fail.

```
export TERM=xterm
```


### Opcache

PHP Opcache has been enabled and configured to revalidate every 60 seconds.
For local development you may wish to disable Opcache:

```
docker exec -it YOUR_CONTAINER_NAME bash -c "sed -i 's/opcache.enable=1/opcache.enable=0/g' /etc/php/7.0/fpm/php.ini && sed -i 's/opcache.revalidate_freq=60/opcache.revalidate_freq=0/g' /etc/php/7.0/fpm/php.ini && supervisorctl reload"
```
