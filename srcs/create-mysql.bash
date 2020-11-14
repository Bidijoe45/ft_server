#!/bin/bash

mysql -uroot <<MYSQL_SCRIPT
CREATE DATABASE wptest;
CREATE USER 'apavel'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON wptest.* TO 'apavel'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

echo "MySQL user created."
