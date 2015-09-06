FROM andrewd/nginx-php
MAINTAINER Andrew Dunham <andrew@du.nham.ca>

# Install gitlist dependencies and gitlist
RUN apk add --update git && \
    cd /tmp && \
    curl -LO https://s3.amazonaws.com/gitlist/gitlist-0.5.0.tar.gz && \
    gunzip gitlist-0.5.0.tar.gz && \
    tar xvf gitlist-0.5.0.tar && \
    mv gitlist/* /var/www/ && \
    mkdir /var/www/cache && \
    chmod 0777 /var/www/cache

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
