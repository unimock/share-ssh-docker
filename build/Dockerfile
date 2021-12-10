ARG         ALPINE_IMAGE="alpine:edge"

FROM        ${ALPINE_IMAGE}

LABEL       maintainer="https://github.com/unimock"

RUN         apk add --upgrade --no-cache \
                    shadow \
                    vim \
                    vimdiff \
                    bash \
                    bash-completion \
                    rsync \
                    openssh \
                    openssl \
                    gnupg \
                    tree \
                    curl \
                    tzdata \
                    git tig \
                    perl \
                    micro \
                    docker docker-compose \
                    netcat-openbsd \
                    sudo 
#                    swaks
#            rm -rf /var/cache/apk/*
RUN ln -sf /usr/bin/vim /usr/bin/vi ; ln -sf /usr/bin/nc /usr/bin/netcat

RUN sed -i "s/#PermitRootLogin.*/PermitRootLogin no/" /etc/ssh/sshd_config
RUN sed -i "s#\/bin\/ash#/bin/bash#g" /etc/passwd

RUN echo "Welcome to your sshd workspace!"                                                          > /etc/motd && \
    echo " "                                                                                       >> /etc/motd && \
    echo "Available utils: git, tig, vim, vimdiff, micro, tree, curl, rsync, sendemail, openssl, gnupg, nc" >> /etc/motd && \
    echo " "                                                                                       >> /etc/motd

COPY ./desc.md /
COPY ./scli-linux /

RUN wget http://caspian.dotconf.net/menu/Software/SendEmail/sendEmail-v156.zip && \
    unzip sendEmail-v156.zip sendEmail.pl && rm -f sendEmail-v156.zip && \
    mv /sendEmail.pl /usr/bin/sendemail

COPY        entry.sh /
COPY        conf.d/etc/ /etc/
RUN         chmod a+x /entry.sh
RUN         mv /usr/bin/passwd /usr/bin/passwd.orig
COPY        passwd /usr/bin
RUN         chmod a+x /usr/bin/passwd
RUN         chmod u+s /bin/ping /usr/bin/traceroute

EXPOSE      22
VOLUME      ["/home"]
ENTRYPOINT  ["/entry.sh"]
