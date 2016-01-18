# Docker Laravel

The Dockerfile and associated setup files for a Laravel or Lumen Docker container.


### Packages

The following packages are installed:
- Nginx 1.7
- PHP 7.0
- PHP GD, Mcrypt, Sqlite, MySQL, and Opcache
- Redis (as a LRU cache)
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
