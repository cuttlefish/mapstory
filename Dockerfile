FROM mapstory/python-gdal
MAINTAINER Tyler Battle <tbattle@boundlessgeo.com>

ENV MEDIA_ROOT /var/lib/mapstory/media
ENV STATIC_ROOT /var/lib/mapstory/static
ENV APP_PATH /srv
ENV TMP /tmp
ENV DJANGO_PORT 8000

WORKDIR $TMP

# Install tools
RUN set -ex \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        unzip \
    && rm -rf /var/lib/apt/lists/*

# Install misc libs
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libgeos-dev \
        libjpeg-dev \
        libxml2-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Node and related tools
RUN set -ex \
    && curl -sL https://deb.nodesource.com/setup_6.x | bash - \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        nodejs \
    && npm install -g bower grunt \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir paver

#RUN mkdir -p $MEDIA_ROOT && chown www-data $MEDIA_ROOT
#RUN mkdir -p $STATIC_ROOT && chown www-data $STATIC_ROOT

### Copy Django app and install python dependencies
RUN adduser --disabled-password --gecos '' mapstory
RUN chown mapstory $APP_PATH
RUN mkdir -p $MEDIA_ROOT && chown mapstory $MEDIA_ROOT
RUN mkdir -p $STATIC_ROOT && chown mapstory $STATIC_ROOT
USER mapstory
WORKDIR $APP_PATH

# Fetch GeoNode
RUN set -ex \
    && wget https://github.com/MapStory/geonode/archive/master.zip \
    && unzip master.zip \
    && mv geonode-master geonode \
    && rm master.zip
RUN sed -i 's/Paver==1.2.1/Paver==1.2.4/' $APP_PATH/geonode/setup.py

WORKDIR $APP_PATH/mapstory
COPY requirements.txt ./
USER root

# Fetch MapLoom
RUN set -ex \
    && wget https://github.com/MapStory/django-maploom/archive/composer.zip \
    && unzip composer.zip \
    && cp -r django-maploom-composer/maploom /usr/local/lib/python2.7/maploom \
    && rm composer.zip
RUN pip install --no-cache-dir -r requirements.txt

# cache these
USER mapstory
WORKDIR $APP_PATH/geonode/geonode/static
RUN set -ex \
    && npm install \
    && bower install
COPY mapstory/static $APP_PATH/mapstory/mapstory/static
RUN set -ex \
    && npm install \
    && bower install
USER root
WORKDIR $APP_PATH/mapstory

COPY . .
RUN pip install --no-deps --no-cache-dir -r requirements.txt
RUN mv ./docker/django/local_settings.py ./mapstory/settings
RUN chown -R mapstory:mapstory $APP_PATH/mapstory

USER mapstory
WORKDIR $APP_PATH/geonode/geonode/static
RUN set -ex \
    && npm install \
    && bower install \
    && grunt copy

WORKDIR $APP_PATH/mapstory/mapstory/static
RUN set -ex \
    && npm install \
    && bower install \
    && grunt less \
    && grunt copy

USER root
RUN chown -R mapstory:mapstory $STATIC_ROOT
RUN chown -R mapstory:mapstory $MEDIA_ROOT

USER mapstory
VOLUME $STATIC_ROOT
VOLUME $MEDIA_ROOT
WORKDIR $APP_PATH/mapstory/
EXPOSE $DJANGO_PORT
ENTRYPOINT ["docker/django/run.sh"]
CMD ["--init-db", "--collect-static", "--reindex", "--serve"]