ARG PHP_VERSION=8.3.6
ARG COMPOSER_VERSION=2.7.4

FROM composer:${COMPOSER_VERSION} as composer-installer

FROM php:$PHP_VERSION-apache-bookworm

# config args
ARG WITH_APCU=yes
ARG APCU_VERSION=5.1.23
ARG WITH_UPLOADPROGRESS=yes
ARG UPLOADPROGRESS_VERSION=2.0.2
ARG WITH_PHPREDIS=no
ARG PHPREDIS_VERSION=6.0.2
ARG WITH_MCRYPT=no
ARG MCRYPT_VERSION=1.0.7
ARG WITH_XDEBUG=no
ARG XDEBUG_VERSION=3.3.2
ARG WITH_YARN=yes
ARG NODE_VERSION=20
ARG WITH_CRON=no
ARG LC_ALL_LANG="en_US"
ARG LC_ALL_ENCODING="UTF-8"
ARG TZ=Europe/Amsterdam
ARG PHP_file_uploads='On'
ARG PHP_upload_max_filesize='64M'
ARG PHP_post_max_size='64M'
ARG PHP_max_execution_time='120'
ARG PHP_memory_limit='256M'
ARG PHP_output_buffering='On'
ARG PHP_opcache_validate_timestamps='0'

# args from env
ARG HOST_GROUP_ID
ARG HOST_USER_ID

RUN set -eux; \
	\
	# Get a package repository.
	apt-get update; \
	\
	# Apt installs package that are needed in RUN state.
	apt-get install -y --no-install-recommends \
	    supervisor \
		mariadb-client \
		msmtp \
		locales \
		bash-completion \
		sudo \
		nano \
		unzip \
		curl \
		wget \
		git \
        gnupg2 \
		iproute2 \
		libpng16-16 \
		libwebp7 \
		libjpeg62-turbo \
		libxpm4 \
		libfreetype6 \
		libzip4 \
		$(if test "$WITH_CRON" = 'yes'; then echo 'cron'; fi) \
	; \
	\
	# Install yarn
	if test "$WITH_YARN" = 'yes'; then \
        # Add Yarn repo to apt
        /usr/bin/curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - ; \
        echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list ; \
        # Add NodeJS repo to apt (script does a apt update)
        /usr/bin/curl -sL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - ;\
        \
        # Install nodejs and yarn
        apt-get install -y --no-install-recommends \
            nodejs \
            yarn \
        ;\
	fi; \
    \
	# Set locale for the rest of the build (and for run state).
	export LC_ALL=${LC_ALL_LANG}.${LC_ALL_ENCODING}; \
	export LANG=${LC_ALL_LANG}.${LC_ALL_ENCODING}; \
	export LANGUAGE=${LC_ALL_LANG}.${LC_ALL_ENCODING}; \
    echo "${LC_ALL} ${LC_ALL_ENCODING}" > /etc/locale.gen; \
    locale-gen ${LC_ALL}; \
    /usr/sbin/update-locale LANG=${LC_ALL}; \
	\
	# Set timezone data for the rest of the build (and for run state).
	export TZ=${TZ}; \
	ln -snf /usr/share/zoneinfo/$TZ /etc/localtime;  \
	echo "${TZ}" > /etc/timezone; \
	\
	# Apt install package that are needed in BUILD state.
	savedAptMark="$(apt-mark showmanual)"; \
	apt-get install -y --no-install-recommends \
		libfreetype6-dev \
		libjpeg-dev \
		libjpeg62-turbo-dev \
		libpng-dev \
		libxpm-dev \
		libpq-dev \
		libzip-dev \
		libwebp-dev \
		libonig-dev \
		$(if test "$WITH_MCRYPT" = 'yes'; then echo 'libmcrypt-dev'; fi) \
	; \
	\
	# Configure gd
	docker-php-ext-configure gd \
		--with-freetype=/usr \
		--with-jpeg=/usr \
		--with-webp=/usr \
		--with-xpm=/usr \
	; \
	\
	# Install often used modules.
	docker-php-ext-install -j "$(nproc)" \
		gd \
		opcache \
		mbstring \
		pdo \
		pdo_mysql \
		pdo_pgsql \
		mysqli \
		zip \
	; \
	\
	# install apcu
	if test "$WITH_APCU" = 'yes'; then \
		pecl install apcu-$APCU_VERSION;\
		docker-php-ext-enable apcu; \
    fi; \
    \
	# install uploadprogress
	if test "$WITH_UPLOADPROGRESS" = 'yes'; then \
		pecl install uploadprogress-$UPLOADPROGRESS_VERSION;\
		docker-php-ext-enable uploadprogress; \
    fi; \
    \
	# Install mcrypt
	if test "$WITH_MCRYPT" = 'yes'; then \
		pecl install mcrypt-$MCRYPT_VERSION; \
		docker-php-ext-enable mcrypt; \
	fi; \
	\
	# Install phpredis
	if test "$WITH_PHPREDIS" = 'yes'; then \
		pecl install redis-$PHPREDIS_VERSION; \
		docker-php-ext-enable redis; \
	fi; \
	\
	# Install xdebug
	if test "$WITH_XDEBUG" = 'yes'; then \
		pecl install xdebug-$XDEBUG_VERSION; \
	fi; \
	\
    # Reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
	apt-mark auto '.*' > /dev/null; \
	apt-mark manual $savedAptMark; \
	ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
		| awk '/=>/ { print $3 }' \
		| sort -u \
		| xargs -r dpkg-query -S \
		| cut -d: -f1 \
		| sort -u \
		| xargs -rt apt-mark manual; \
	\
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	# Cleanup apt repos.
	rm -rf /var/lib/apt/lists/*; \
	\
	# Install a developer account.
	addgroup --gid $HOST_GROUP_ID developers; \
	adduser --uid=$HOST_USER_ID --gid=$HOST_GROUP_ID --disabled-password --gecos "" developer; \
	echo "developer ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set php configs.
RUN { \
		echo 'opcache.memory_consumption = 128'; \
		echo 'opcache.interned_strings_buffer = 8'; \
		echo 'opcache.max_accelerated_files = 4000'; \
		echo 'opcache.revalidate_freq = 0'; \
		echo 'opcache.fast_shutdown = 1'; \
		echo "opcache.validate_timestamps = ${PHP_opcache_validate_timestamps}"; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini
RUN { \
		echo '[mail function]'; \
		echo 'sendmail_path = "/usr/bin/msmtp -t"'; \
	} > /usr/local/etc/php/conf.d/mail.ini
RUN { \
		echo 'memory_limit = -1'; \
		echo 'max_execution_time = 0'; \
	} > /usr/local/etc/php/php-cli.ini
RUN { \
		echo "file_uploads = ${PHP_file_uploads}"; \
		echo "upload_max_filesize = ${PHP_upload_max_filesize}"; \
		echo "post_max_size = ${PHP_post_max_size}"; \
		echo "max_execution_time = ${PHP_max_execution_time}"; \
		echo "memory_limit = ${PHP_memory_limit}"; \
		echo "output_buffering = ${PHP_output_buffering}"; \
	} > /usr/local/etc/php/php.ini
RUN if test "$WITH_XDEBUG" = 'yes'; \
	then \
	    { \
			echo 'zend_extension=xdebug.so'; \
			echo 'xdebug.mode=develop,debug,profile'; \
			echo 'xdebug.discover_client_host=false'; \
			echo 'xdebug.client_host=ide'; \
			echo 'xdebug.client_port=9003'; \
			echo 'xdebug.scream=1'; \
			echo 'xdebug.show_local_vars=0'; \
			echo 'xdebug.max_nesting_level=256'; \
			echo 'xdebug.start_with_request=trigger'; \
			echo 'xdebug.output_dir="/tmp/xdebug-profile"'; \
		} > /usr/local/etc/php/conf.d/xdebug.ini; \
	fi

# Copy mail script
COPY ./msmtprc /etc/msmtprc

# Set environment variables.
ENV LC_ALL=$LC_ALL_LANG.${LC_ALL_ENCODING}
ENV LANG=$LC_ALL_LANG.${LC_ALL_ENCODING}
ENV LANGUAGE=$LC_ALL_LANG.${LC_ALL_ENCODING}
ENV TZ=$TZ
ENV force_color_prompt yes

# Enable apache modules.
RUN a2enmod expires; \
    a2enmod deflate; \
	a2enmod rewrite;

# Copy custom vhost conf.
COPY ./vhost.conf /etc/apache2/sites-available/000-default.conf

# Install composer.
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /tmp
COPY --from=composer-installer /usr/bin/composer /usr/bin/composer-org
COPY ./composer-wrapper.sh /usr/bin/composer

# Install Drush
COPY ./drush /usr/bin/drush
RUN chmod 755 /usr/bin/drush

# Copy scripts for cron and install if needed.
COPY ./crontab /root/crontab
COPY ./write-env.sh /root/write-env.sh
COPY ./set-symlinks.sh /root/set-symlinks.sh
COPY ./write-env-php-ini.sh /root/write-env-php-ini.sh

RUN set -eux; \
	if test "$WITH_CRON" = 'yes'; \
	then \
	    { \
			## copy current environment vars to /etc/environment for cron
			#  on startup.
			echo '[program:write-environment]'; \
			echo 'command = /root/write-env.sh'; \
			echo 'autorestart = false'; \
			echo 'startsecs = 0'; \
			echo ''; \
			# start cron (not in background).
			echo '[program:cron]'; \
			echo 'command = /usr/sbin/cron -f -L 5'; \
			echo 'stdout_logfile = /var/log/cron.log'; \
			echo 'stdout_logfile_maxbytes = 1024000'; \
			echo 'stderr_logfile = /var/log/cron.log'; \
			echo 'stderr_logfile_maxbytes = 1024000'; \
		} > /etc/supervisor/conf.d/cron.conf; \
	    touch /var/log/cron.log; \
		chgrp developers /var/log/cron.log; \
		chmod g+w /var/log/cron.log; \
		crontab -u developer /root/crontab; \
	    chmod 0755 /root/write-env.sh; \
	fi

WORKDIR /var/www/html

COPY ./underconstruction /underconstruction

# Use supervisord to control multiple startups.
COPY ./supervisord.conf /etc/supervisor/supervisord.conf

CMD ["/usr/bin/supervisord"]
