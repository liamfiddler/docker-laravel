# Docker Laravel

The Dockerfile and associated setup files for a Laravel or Lumen Docker container.


### Packages

The following packages are installed:
- Nginx
- PHP (with GD, Mcrypt, Sqlite, MySQL, and Opcache)
- Redis - configured as a LRU cache
- NPM

Processes are managed by Supervisor.

A cron job has been set up which will call the Laravel scheduler once per minute.


### Adding your website files

ADD/COPY your Laravel/Lumen project to the `/share` directory in your 
Dockerfile, or if you are not extending this container you can mount 
your local directory to `/share` as a volume.


### Usage for non-Laravel or Lumen projects

If you want to use this container for a generic PHP project you can mount 
your project to the `/share/public` directory.

You should also remove the Laravel cron job that runs every minute 
by adding the following command to your Dockerfile:

```
RUN rm /etc/cron.d/laravel
```


### Opcache

PHP Opcache has been enabled and configured to revalidate every 60 seconds. 
For local development you may wish to change this to revalidate on every request: 

```
docker exec -it YOUR_CONTAINER_NAME sed -i 's/opcache.revalidate_freq=60/opcache.revalidate_freq=0/g' /etc/php/7.0/fpm/php.ini
```
