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
                    sudo \
                    util-linux-misc \
                    file \
                    perl-net-ssleay

#            rm -rf /var/cache/apk/*

RUN apk add swaks --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing/

RUN ln -sf /usr/bin/vim /usr/bin/vi ; ln -sf /usr/bin/nc /usr/bin/netcat

RUN sed -i "s/#PermitRootLogin.*/PermitRootLogin no/" /etc/ssh/sshd_config
RUN sed -i "s#\/bin\/ash#/bin/bash#g" /etc/passwd

RUN echo "Welcome to your sshd workspace!"                                                          > /etc/motd && \
    echo " "                                                                                       >> /etc/motd && \
    echo "Available utils: git, tig, vim, vimdiff, micro, tree, curl, rsync, swaks, openssl, gnupg, nc" >> /etc/motd && \
    echo " "                                                                                       >> /etc/motd

COPY ./desc.md /
COPY ./scli-linux /

COPY        entry.sh /
COPY        conf.d/etc/ /etc/
RUN         chmod a+x /entry.sh
RUN         mv /usr/bin/passwd /usr/bin/passwd.orig
COPY        passwd /usr/bin
RUN         chmod a+x /usr/bin/passwd
RUN         chmod u+s /bin/ping /usr/bin/traceroute

COPY        bin /usr/local/bin
RUN         chmod a+x usr/local/bin/*

EXPOSE      22
VOLUME      ["/home"]
ENTRYPOINT  ["/entry.sh"]
