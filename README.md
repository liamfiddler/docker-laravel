# Docker Laravel

The Dockerfile and associated setup files for a Laravel Docker container.

The following packages are installed:
- Nginx 1.7
- PHP 7.0
- PHP GD, Mcrypt, Sqlite, MySQL, and Opcache
- Redis (as a LRU cache)
- NPM

All process are managed by Supervisor.

Mount your Laravel project to /share

