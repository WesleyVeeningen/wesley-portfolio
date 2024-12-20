FROM debian:buster-slim

# args from env
ARG HOST_GROUP_ID
ARG HOST_USER_ID

# Configurable
ARG TZ=Europe/Amsterdam

RUN apt-get update && apt-get install -y \
    supervisor \
    mariadb-client \
    cron \
    gzip \
    netcat-openbsd \
 && rm -rf /var/lib/apt/lists/*

ENV BACKUP_INTERVAL_HOURS 4
ENV BACKUPS_TO_KEEP 4
ENV SECONDS_WAIT_TIMEOUT 60
ENV MYSQL_PASSWORD mysql
ENV MYSQL_USER mysql
ENV MYSQL_HOSTNAME mysql
ENV MYSQL_PORT 3306

COPY backup-scripts /opt/backup-scripts

# Set timezone data for the rest of the build (and for run state).
RUN export TZ=${TZ}; \
	ln -snf /usr/share/zoneinfo/$TZ /etc/localtime;  \
	echo "${TZ}" > /etc/timezone
ENV TZ=${TZ}

# Install a developer account.
RUN addgroup --gid $HOST_GROUP_ID developers; \
	adduser --uid=$HOST_USER_ID --gid=$HOST_GROUP_ID --disabled-password --gecos "" developer; \
	echo "developer ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN mkdir /backup
VOLUME /backup

WORKDIR /

COPY ./startup.sh /root/startup.sh
RUN chmod 755 /root/startup.sh

RUN touch /var/log/cron.log; \
    chgrp developers /var/log/cron.log; \
    chmod g+w /var/log/cron.log

# Use supervisord to control multiple startups.
COPY ./supervisord.conf /etc/supervisor/supervisord.conf

CMD ["/usr/bin/supervisord"]
