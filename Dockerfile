FROM debian:stretch-slim
LABEL MAINTAINER frappe

USER root
# Generate locale C.UTF-8 for mariadb and general locale data
ENV LANG C.UTF-8

RUN apt-get update \
  && apt-get install -y python3-dev python3-pip python3-setuptools python3-tk redis-tools redis-server libffi-dev  \
     libssl-dev libjpeg62-turbo-dev libxrender1 libxext6 libfreetype6-dev zlib1g-dev libsasl2-dev libldap2-dev libtiff5-dev \
     xfonts-75dpi xfonts-base tcl8.6-dev tk8.6-dev curl git sudo software-properties-common nano nginx yarn cron wkhtmltopdf \
     mariadb-client mariadb-common \
  && curl https://deb.nodesource.com/node_10.x/pool/main/n/nodejs/nodejs_10.15.3-1nodesource1_amd64.deb > node.deb \
  && dpkg -i node.deb \
  && rm node.deb \
  && npm install -g yarn \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN pip3 install --upgrade setuptools pip && rm -rf ~/.cache/pip

RUN useradd -ms /bin/bash -G sudo frappe && printf '# User rules for frappe\nfrappe ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/frappe

USER frappe
WORKDIR /home/frappe

# Add some bench files
COPY --chown=frappe:frappe ./conf/frappe/ /home/frappe/frappe-bench-settings/

RUN git clone -b master https://github.com/frappe/bench.git bench-repo

USER root
# Install bench
RUN pip3 install -e git+https://github.com/frappe/bench.git#egg=bench \
  && rm -rf ~/.cache/pip \
  && chown -R frappe:frappe /home/frappe/*

USER frappe
RUN mkdir -p /home/frappe/frappe-bench
WORKDIR /home/frappe/frappe-bench