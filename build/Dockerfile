ARG         ALPINE_IMAGE="alpine:latest"

FROM        ${ALPINE_IMAGE}

LABEL       maintainer="https://github.com/unimock"

RUN         apk add --upgrade --no-cache \
                    shadow \
                    vim \
                    bash \
                    bash-completion \
                    rsync \
                    openssh \
                    tree \
                    curl \
                    tzdata \
                    micro \
                    git \
                    perl \
                    sudo
#            rm -rf /var/cache/apk/*
RUN ln -sf /usr/bin/vim /usr/bin/vi

RUN sed -i "s/#PermitRootLogin.*/PermitRootLogin no/" /etc/ssh/sshd_config
RUN sed -i "s#\/bin\/ash#/bin/bash#g" /etc/passwd

RUN echo "Welcome to your sshd workspace !"                                         > /etc/motd && \
    echo " "                                                                       >> /etc/motd && \
    echo "available utils: git, vi, micro, tree, curl, rsync, sendemail"           >> /etc/motd && \
    echo " "                                                                       >> /etc/motd && \
    echo " ! Use share-pw instead of passwd to store your ssh-password persistent" >> /etc/motd && \
    echo " ! Only your home directory us saved permanently."                       >> /etc/motd && \
    echo ""                                                                        >> /etc/motd



RUN wget http://caspian.dotconf.net/menu/Software/SendEmail/sendEmail-v156.zip && \
    unzip sendEmail-v156.zip sendEmail.pl && rm -f sendEmail-v156.zip && \
    mv /sendEmail.pl /usr/bin/sendemail

COPY        entry.sh /
COPY        conf.d/etc/ /etc/
RUN         chmod a+x /entry.sh
COPY        share-pw /usr/local/bin
RUN chmod a+x /usr/local/bin/*
EXPOSE      22
VOLUME      ["/home"] 755 root:root
ENTRYPOINT  ["/entry.sh"]
