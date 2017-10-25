FROM bitnami/minideb:stretch
MAINTAINER Tyler Battle <tbattle@boundlessgeo.com>

RUN install_packages apt-transport-https wget

RUN set -ex \
    && wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add - \
    && echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-5.x.list \
    && apt-get update \
    && install_packages logstash

