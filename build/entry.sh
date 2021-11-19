#!/bin/bash

set -e

# enable debug mode if desired
if [[ "${DEBUG}" == "true" ]]; then 
    set -x
fi

cp -f /usr/share/zoneinfo/${TIMEZONE} /etc/localtime

USERS=$( echo "${USERS//\"}" )
for USER in $USERS ; do
  SSHD_USER="$(echo "${USER}"  | cut -d ':' -f 1)"
  SSHD_UID="$(echo "${USER}"   | cut -d ':' -f 2)"
  SSHD_GROUP="$(echo "${USER}" | cut -d ':' -f 3)"
  SSHD_GID="$(echo "${USER}"   | cut -d ':' -f 4)"
  echo "user=${SSHD_USER} uid=${SSHD_UID} group=${SSHD_GROUP} gid=${SSHD_GID}"
  #
  # store ssh host keys persistent in .sshd directory
  #
  if  ls /home/${SSHD_USER}/.sshd/ssh_host_* 1> /dev/null 2>&1; then
    cp -a /home/${SSHD_USER}/.sshd/ssh_host_*   /etc/ssh
  fi
  # Generate Host keys, if required
  if ! ls /etc/ssh/ssh_host_* 1> /dev/null 2>&1; then
      ssh-keygen -A
      mkdir -p /home/${SSHD_USER}/.sshd/
      cp -a /etc/ssh/ssh_host_rsa_key* /home/${SSHD_USER}/.sshd/
  fi
  # add 
  if getent group "${SSHD_GID}" &>/dev/null ; then
    echo "gid=${SSHD_GID} already exists!!!"
  else
    addgroup -g "${SSHD_GID}" "${SSHD_GROUP}"
  fi
  adduser -s "/bin/bash" -D -u "${SSHD_UID}" -G "${SSHD_GROUP}" "${SSHD_USER}"
  echo "${SSHD_USER} ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers
  chmod -v 0700 /home/${SSHD_USER}/.sshd
  
  if [ ! -f /home/${SSHD_USER}/.sshd/shadow ] ; then
    PW=$(hexdump -e '"%02x"' -n 8 /dev/urandom)
    echo "${SSHD_USER}:${PW}" | chpasswd &>/dev/null
    echo "your initial ssh-password: $PW"                        > /home/${SSHD_USER}/initial-sshd-password.txt
    echo "Please login and change your password with share-pw " >> /home/${SSHD_USER}/initial-sshd-password.txt
    grep "^${SSHD_USER}:" /etc/shadow | cut -d: -f2 > /home/${SSHD_USER}/.sshd/shadow
  fi
  chmod 600 /home/${SSHD_USER}/.sshd/shadow
  HASH=$( cat /home/${SSHD_USER}/.sshd/shadow )
  usermod -p "$HASH" ${SSHD_USER}
  chown -Rv ${SSHD_USER}:${SSHD_GROUP} /home/${SSHD_USER}/.sshd
  chmod -v 0700 /home/${SSHD_USER}/.sshd
  #
  # prepare .ssh directory
  #
  mkdir -p /home/${SSHD_USER}/.ssh
  touch /home/${SSHD_USER}/.ssh/authorized_keys
  chmod -v 0600 /home/${SSHD_USER}/.ssh/authorized_keys
  chmod -v 0700 /home/${SSHD_USER}/.ssh
  chown -Rv ${SSHD_USER}:${SSHD_GROUP} /home/${SSHD_USER}/.ssh
done

exec /usr/sbin/sshd -D -e "$@"
