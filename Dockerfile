FROM ubuntu:16.04

# udate and upgrade
RUN apt-get -y update
RUN apt-get -y upgrade

# install neede softwares
RUN apt-get install -y git python3.5 python3-pip python3-dev python3-setuptools libpq-dev apache2 apache2-dev libapache2-mod-wsgi-py3

# upgrade pip
RUN pip3 install --upgrade pip

# pip install virtualenv
RUN pip3 install virtualenv


# GIT AND SSH CONFIGURATION

RUN mkdir -p /root/.ssh

# Copy over private key, and set permissions
COPY ssh/id_rsa /root/.ssh/id_rsa

# Add correct permissions
RUN chmod 400 /root/.ssh/id_rsa

# Create known_hosts
RUN touch /root/.ssh/known_hosts

# Disable strict host key checking for Github
RUN echo "Host github.com\n\tStrictHostKeyChecking no\n" >> /root/.ssh/config

# Add correct permissions to /root/.ssh/config
RUN chmod 400 /root/.ssh/config

# Add github to known_hosts list
RUN ssh-keyscan github.com >> /root/.ssh/known_hosts

WORKDIR /root

# Clone repository
RUN git clone git@github.com:davincif/davincif.com.git --branch release



# DJANGO WEBSITE CONFIGURATION

#upgade setuptools
RUN pip3 install --upgrade setuptools

# Install python3 virtualenv
RUN pip3 install virtualenv

# Create python virtual environment
RUN virtualenv /root/virtualenv/davincif.com

# activate virtual environment
RUN . /root/virtualenv/davincif.com/bin/activate

WORKDIR /root/davincif.com

# Install python dependencies
RUN pip3 install -r requirements.txt

# collect django static files
RUN python3 manage.py collectstatic --noinput

# make media directory
RUN mkdir media


# SETUP APACH SERVER

# adding apache2 config for davincif
COPY davincif.conf /etc/apache2/sites-available/davincif.conf

# activating site davincif
RUN a2ensite davincif


# Expose
EXPOSE 80


# reloading apache
CMD (apache2ctl start)
