FROM mongo

# Preparing
ENV SITEURL=http://localhost:9000
ENV ADMINUSER=admin
ENV LANG=zh-cn
ENV DAYS=3

COPY leanote-linux-amd64-v2.6.1.bin.tar.gz /data/
COPY wkhtmltox-0.12.4_linux-generic-amd64.tar.gz /data/
COPY entrypoint.sh /usr/local/bin/
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

        # download wkhtmltopdf
RUN tar zxf /data/wkhtmltox-0.12.4_linux-generic-amd64.tar.gz -C /; \
        ls -l /wkhtmltox; \
        mv /data/wkhtmltox-0.12.4_linux-generic-amd64.tar.gz /data_tmp/wkhtmltox-0.12.4_linux-generic-amd64.tar.gz; \
        cp /wkhtmltox/bin/wkhtmltopdf /usr/bin/wkhtmltopdf; \
        chmod +x /usr/bin/wkhtmltopdf; 

RUN set -ex; \
    apt-get update; \
    apt-get install -y --no-install-recommends wget tar vim; \
    # install font
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
    fc-cache \
    && apt-get clean && rm -rf /var/lib/apt/lists/* \
	# Wrapper for xvfb
    && \
    echo '#!/usr/bin/env sh\n\
Xvfb :0 -screen 0 1024x768x24 -ac +extension GLX +render -noreset & \n\
DISPLAY=:0.0 wkhtmltopdf $@ \n\
killall Xvfb\
' > /usr/bin/wkhtmltopdf2 && \
    chmod +x /usr/bin/wkhtmltopdf2
    
	
# Port Setting
EXPOSE 9000

# Script
ENTRYPOINT ["entrypoint.sh"]
