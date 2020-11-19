# Docker for GECKO-MGV (pistacho.ac.uma.es)
#
# VERSION       0.1

FROM ubuntu:18.04

MAINTAINER Esteban P. Wohlfeil, estebanpw@uma.es


# Install make
RUN DEBIAN_FRONTEND=noninteractive apt-get -qq update
RUN DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y build-essential

# Install supervisor
RUN DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y supervisor 
RUN mkdir -p /var/log/supervisor

# Copy supervisord configuration file
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Install git, python, venv
RUN DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y git
RUN DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y python virtualenv

# Add GECKO-MGV user and switch to it
RUN useradd -ms /bin/bash geckouser

# Create folder for GECKO-MGV and change permissions
RUN mkdir /externaltool
RUN chown geckouser /externaltool
USER geckouser

# Install GECKO-MGV
RUN git clone https://github.com/Sergiodiaz53/GeckoMGV.git /externaltool/geckomgv
WORKDIR /externaltool/geckomgv
RUN virtualenv -p python2.7 /externaltool/GeckoMGVvenv
RUN . /externaltool/GeckoMGVvenv/bin/activate && pip install django==1.7.9 django-forms-builder django_extensions

## Make necessary seds first
RUN sed -i '/from django.urls import reverse/c\from django.core.urlresolvers import reverse' /externaltool/GeckoMGVvenv/lib/python2.7/site-packages/django_extensions/admin/widgets.py

## Configure GECKO-MGV
RUN . /externaltool/GeckoMGVvenv/bin/activate && python2.7 /externaltool/geckomgv/manage.py migrate
# A super user is already available. See README. 
#RUN . /externaltool/GeckoMGVvenv/bin/activate && echo "from django.contrib.auth.models import User; User.objects.create_superuser('admin', 'admin@example.com', 'pass')" | python2.7 /externaltool/geckomgv/manage.py shell
ADD src/db.sqlite3 .

USER root

# Mark folders as imported from the host.
VOLUME ["/export/", "/data/", "/var/lib/docker"]

# Expose port 80 (webserver), 21 (FTP server), 8800 (Proxy)
EXPOSE :80
EXPOSE :21
EXPOSE :8800
EXPOSE :8080

# Add script with custom startup
ADD startup.sh /usr/bin/startup

# Autostart script that is invoked during container start
CMD ["/usr/bin/startup"]
