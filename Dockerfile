FROM andrewd/nginx-php
MAINTAINER Andrew Dunham <andrew@du.nham.ca>

# GitList hasn't had a release in a while (~ 2 years), so we pull from master.
ENV GITLIST_REV b507e27862bd97a1f7f62d2ec2e525e72c600898

# Fetch and unpack gitlist
RUN apk add --update git && \
    cd /tmp && \
    curl -L -o gitlist-${GITLIST_REV}.tar.gz https://github.com/klaussilveira/gitlist/archive/${GITLIST_REV}.tar.gz && \
    tar zxvf gitlist-${GITLIST_REV}.tar.gz && \
    mv gitlist-${GITLIST_REV}/* /var/www/ && \
    mkdir -p /var/www/cache && \
    chmod 0777 /var/www/cache

# Install gitlist dependencies
RUN cd /var/www && \
    composer install --no-dev

# Add gitlist config file
ADD config.ini /var/www/config.ini

# Add our init.  This is a giant hack -  on startup, we run this script which
# replaces the user and group IDs of our `php` user with the values passed in.
# This allows that user to then access the repositories that we were given.
ADD init /usr/local/bin/init

# Fix permissions on init, and create a dummy repository so we don't get
# strange errors.
RUN chmod +x /usr/local/bin/init && \
    mkdir -p /repos && \
    cd /repos && \
    git init --bare sentinel

CMD ["/usr/local/bin/init"]
