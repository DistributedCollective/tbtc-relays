FROM python:3.7-alpine3.11

RUN pip install pipenv

ENV PYENV_HOME="/usr/local/pyenv"

RUN apk add --no-cache --update \
    git \
    bash \
    libffi-dev \
    openssl-dev \
    bzip2-dev \
    zlib-dev \
    readline-dev \
    sqlite-dev \
    build-base \
    nodejs npm

RUN npm install pm2 -g

RUN git clone --depth 1 https://github.com/pyenv/pyenv.git $PYENV_HOME && \
    rm -rfv $PYENV_HOME/.git

ENV PATH $PYENV_HOME/shims:$PYENV_HOME/bin:$PATH

RUN pip install --upgrade pip && pyenv rehash

WORKDIR /app

COPY Pipfile .
RUN pipenv install --python=$(pyenv which python3.7)

COPY . .
COPY entrypoint.sh .

RUN git clone https://github.com/rumblefishdev/tbtc-rsk-proxy.git proxy
RUN cd proxy/node-http-proxy && npm install
RUN cd proxy && npm install

ENTRYPOINT ["./entrypoint.sh"]
