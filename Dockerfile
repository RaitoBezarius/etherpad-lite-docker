FROM debian:jessie

MAINTAINER Raito Bezarius <masterancpp@gmail.com>

ENV ETHERPAD_VERSION 1.5.6

RUN apt-get update
RUN apt-get install -y curl unzip nodejs-legacy npm postgresql-client
RUN rm -r /var/lib/apt/lists/*

WORKDIR /opt

RUN curl -SL https://github.com/ether/etherpad-lite/archive/release/${ETHERPAD_VERSION}.zip > etherpad.zip
RUN unzip etherpad.zip
RUN rm etherpad.zip
RUN mv etherpad-lite-release-${ETHERPAD_VERSION} etherpad-lite

WORKDIR etherpad-lite

RUN bin/installDeps.sh && rm settings.json
COPY entrypoint.sh /entrypoint.sh

VOLUME /opt/etherpad-lite/var

RUN ln -s ./var/settings.json settings.json

EXPOSE 9001

ENTRYPOINT ["/entrypoint.sh"]
CMD ["bin/run.sh", "--root"]
