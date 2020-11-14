
FROM debian:buster

RUN apt-get update

RUN apt-get install -y nginx
RUN apt-get install -y vim

RUN apt-get install -y mariadb-server mariadb-client
RUN apt-get install -y php php-fpm php-common php-mysql php-gd php-cli \
	php-mbstring php-gd php-zip php-curl php-intl php-soap php-xml php-xmlrpc
RUN apt-get install -y wget
RUN wget https://raw.github.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	&& chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp
RUN wp core download --path=var/www/wordpress --allow-root
COPY /srcs/create-mysql.bash /
COPY /srcs/nginx-wp-conf /etc/nginx/sites-available
RUN ln -s /etc/nginx/sites-available/nginx-wp-conf /etc/nginx/sites-enabled/
RUN wget https://files.phpmyadmin.net/phpMyAdmin/4.9.5/phpMyAdmin-4.9.5-all-languages.tar.gz
RUN tar xvf phpMyAdmin-4.9.5-all-languages.tar.gz
RUN mv phpMyAdmin-4.9.5-all-languages var/www/phpmyadmin
RUN chown -R www-data:www-data /var/www
COPY /srcs/self-signed.conf /etc/nginx/snippets/
#COPY /srcs/ssl-params.conf /etc/nginx/snippets/
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key \
	-out /etc/ssl/certs/nginx-selfsigned.crt -subj "/C=ES/ST=Madrid/L=Madrid/O=Org/CN=localhost"
COPY /srcs/index.html /var/www/

CMD service nginx start && \
	service mysql start && \
	service php7.3-fpm start && \
	bash create-mysql.bash && \
	wp config create --dbname=wptest --dbuser=apavel --dbpass=password \
		--path=var/www/wordpress/ --allow-root && \
	wp core install --url=localhost/wordpress --title="Mr Pickles" --admin_user=apavel \
		--admin_password=password --admin_email=pickles@email.com --path=var/www/wordpress/ --allow-root && \
	bash

EXPOSE 80
