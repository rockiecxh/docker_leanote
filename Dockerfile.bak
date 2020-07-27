FROM mongo

# Preparing
ENV SITEURL=http://localhost:9000
ENV ADMINUSER=admin
ENV LANG=en-us
ENV DAYS=3
COPY leanote-linux-amd64-v2.6.1.bin.tar.gz /data/
COPY entrypoint.sh /usr/local/bin/

RUN set -ex; \
    apt-get update; \
    apt-get install -y --no-install-recommends wget tar vim; \
    apt-get install -y xvfb libXrender* libfontconfig*; \
    apt-get install -y \
        fonts-arphic-bkai00mp \
        fonts-arphic-bsmi00lp \
        fonts-arphic-gbsn00lp \
        fonts-arphic-gkai00mp \
        fonts-arphic-ukai \
        fonts-arphic-uming \
        ttf-wqy-zenhei \
        ttf-wqy-microhei \
        xfonts-wqy; \
        xfonts-75dpi; \
    apt purge -y wkhtmltopdf; \
    wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.jessie_amd64.deb; \
    dpkg -i wkhtmltox_0.12.5-1.jessie_amd64.deb; \
    rm -f wkhtmltox_0.12.5-1.jessie_amd64.deb;\
    rm -rf /var/lib/apt/lists/*; \

# Leanote Installing
RUN tar zxf /data/leanote-linux-amd64-v2.6.1.bin.tar.gz -C /data/; \
        mkdir /data_tmp; \
        mv /data/leanote-linux-amd64-v2.6.1.bin.tar.gz /data_tmp/leanote-linux-amd64-v2.6.1.bin.tar.gz; \
        chmod a+x /data/leanote/bin/run.sh; \
        # Security Setting on Leanote Wiki
        SECRET="`cat /dev/urandom | tr -dc A-Za-z0-9 | head -c64 | sed 's/[ \r\b]/a/g'`"; \
        sed -i "s/V85ZzBeTnzpsHyjQX4zukbQ8qqtju9y2aDM55VWxAH9Qop19poekx3xkcDVvrD0y/$SECRET/g" /data/leanote/conf/app.conf; \
        # Timezone Setting
        rm -f /etc/localtime; \
        ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime; \
        rm -f /etc/timezone; \
        echo "Asia/Shanghai" >> /etc/timezone; \
        # Backup & Restore DIR
        mkdir /data/backup; \
        mkdir /data/restore; \
        # Script Initializing
        chmod a+x /usr/local/bin/entrypoint.sh

# Port Setting
EXPOSE 9000

# Script
ENTRYPOINT ["entrypoint.sh"]
