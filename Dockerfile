FROM node:8-slim

RUN echo "deb http://archive.debian.org/debian stretch main" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian-security stretch/updates main" >> /etc/apt/sources.list && \
    apt-get update

ENV TINI_VERSION 0.9.0
RUN set -x \
	&& apt-get install -y ca-certificates curl \
		--no-install-recommends \
	&& curl -fSL "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini" -o /usr/local/bin/tini \
	&& chmod +x /usr/local/bin/tini \
	&& tini -h \
	&& rm -rf /var/lib/apt/lists/*

EXPOSE 8081

ENV ME_CONFIG_EDITORTHEME="default" \
    ME_CONFIG_MONGODB_SERVER="mongo" \
    ME_CONFIG_MONGODB_ENABLE_ADMIN="true" \
    ME_CONFIG_BASICAUTH_USERNAME="" \
    ME_CONFIG_BASICAUTH_PASSWORD="" \
    ME_CONFIG_BASICAUTH_USERNAME_FILE="" \
    ME_CONFIG_BASICAUTH_PASSWORD_FILE="" \
    ME_CONFIG_MONGODB_ADMINUSERNAME_FILE="" \
    ME_CONFIG_MONGODB_ADMINPASSWORD_FILE="" \
    ME_CONFIG_MONGODB_AUTH_USERNAME_FILE="" \
    ME_CONFIG_MONGODB_AUTH_PASSWORD_FILE="" \
    ME_CONFIG_MONGODB_CA_FILE="" \
    VCAP_APP_HOST="0.0.0.0"

WORKDIR /app

COPY . /app

RUN cp config.default.js config.js

RUN set -x \
	&& apt-get update && apt-get install -y git --no-install-recommends \
	&& git config --global http.sslVerify false \
	&& npm install \
	&& apt-get purge --auto-remove -y git \
	&& rm -rf /var/lib/apt/lists/*

RUN npm run build

CMD ["tini", "--", "npm", "start"]
