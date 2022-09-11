FROM broadinstitute/scala-baseimage:scala-2.12.2

ENV TZ=Europe/Warsaw
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone 
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

EXPOSE 3000
EXPOSE 9000
EXPOSE 80


RUN echo "deb [check-valid-until=no] http://cdn-fastly.deb.debian.org/debian jessie main" > /etc/apt/sources.list.d/jessie.list
RUN echo "deb [check-valid-until=no] http://archive.debian.org/debian jessie-backports main" > /etc/apt/sources.list.d/jessie-backports.list
RUN sed -i '/deb http:\/\/deb.debian.org\/debian jessie-updates main/d' /etc/apt/sources.list
RUN apt-get -o Acquire::Check-Valid-Until=false update

RUN apt-get install -y build-essential curl
RUN curl -sL -o Acquire::Check-Valid-Until=false https://deb.nodesource.com/setup_14.x | bash -
RUN apt-get -o Acquire::Check-Valid-Until=false install -y npm

ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 14.0.0

RUN curl https://raw.githubusercontent.com/creationix/nvm/v0.30.1/install.sh | bash \
    && source $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH      $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

RUN mkdir /usr/app
RUN mkdir /usr/app/log

WORKDIR /usr/app

COPY frontend/shop /usr/app
COPY backend /usr/app
RUN sbt compile
RUN npm install
