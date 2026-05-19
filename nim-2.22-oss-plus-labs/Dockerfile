FROM nginx:stable-bookworm

RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    procps \
    psmisc \
    gnupg2 \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

COPY nginx.conf /etc/nginx/nginx.conf
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 80 8081

ENTRYPOINT ["/entrypoint.sh"]