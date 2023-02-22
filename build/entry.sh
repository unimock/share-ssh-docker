#!/bin/bash

set -e

# enable debug mode if desired
if [[ "${DEBUG}" == "true" ]]; then 
    set -x
fi

cp -f /usr/share/zoneinfo/${TIMEZONE} /etc/localtime

if [ "${DOCKER_HOST}" != "" ] ; then
  echo "declare -x DOCKER_HOST=${DOCKER_HOST}" > /etc/profile.d/docker.sh
fi

# store SWAKS_PARAM
mkdir -p /var/server
echo "SERVER_SWAKS_PARAM=\"${SWAKS_PARAM}\""  >>/var/server/environment

mkdir -p /var/sshd/
USERS=$( echo "${USERS//\"}" )
for USER in $USERS ; do
  _USER=$(echo "${USER}"  | cut -d ':' -f 1)
  FI=/var/sshd/${_USER}.config
  echo SSHD_USER=$(echo "${USER}"  | cut -d ':' -f 1) >> $FI
  echo SSHD_UID=$(echo "${USER}"   | cut -d ':' -f 2) >> $FI
  echo SSHD_GROUP=$(echo "${USER}" | cut -d ':' -f 3) >> $FI
  echo SSHD_GID=$(echo "${USER}"   | cut -d ':' -f 4) >> $FI
  echo SSHD_PORT=$(echo "${USER}"  | cut -d ':' -f 5) >> $FI
  echo SSHD_MAIL=$(echo "${USER}"  | cut -d ':' -f 6) >> $FI
  . $FI
  echo "user=${SSHD_USER} uid=${SSHD_UID} group=${SSHD_GROUP} gid=${SSHD_GID} port=${SSHD_PORT}"
  #
  # store ssh host keys persistent in .sshd directory
  #
  if  ls /home/${SSHD_USER}/.sshd/ssh_host_* 1> /dev/null 2>&1; then
    cp -a /home/${SSHD_USER}/.sshd/ssh_host_*   /etc/ssh
  fi
  # Generate Host keys, if required
  ssh-keygen -A
  mkdir -p /home/${SSHD_USER}/.sshd/
  cp -a /etc/ssh/ssh_host_* /home/${SSHD_USER}/.sshd/
  # add 
  if getent group "${SSHD_GID}" &>/dev/null ; then
    echo "gid=${SSHD_GID} already exists!!!"
  else
    addgroup -g "${SSHD_GID}" "${SSHD_GROUP}"
  fi
  if getent passwd "${SSHD_USER}" &>/dev/null ; then
    echo "user=${SSHD_USER} already exists!!!"
  else
    adduser -s "/bin/bash" -D -u "${SSHD_UID}" -G "${SSHD_GROUP}" "${SSHD_USER}"
    echo "${SSHD_USER} ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers
  fi
  chmod -v 0700 /home/${SSHD_USER}/.sshd
  
  FI=/home/${SSHD_USER}/.sshd/shadow
  if [ ! -f $FI ] ; then
    PW=$(hexdump -e '"%02x"' -n 8 /dev/urandom)
    echo "${SSHD_USER}:${PW}" | chpasswd &>/dev/null
    grep "^${SSHD_USER}:" /etc/shadow | cut -d: -f2 > $FI
    echo "$PW"                          > /home/${SSHD_USER}/.sshd/initial_ssh_password.txt
  fi
  #
  # create README.md
  #
  FI=/home/${SSHD_USER}/.sshd/README.md
  cp /desc.md $FI
  sed -i -e "s|\[SSHD_USER\]|${SSHD_USER}|g"         $FI
  sed -i -e "s|\[SSHD_HOME\]|/home/${SSHD_USER}|g"   $FI
  sed -i -e "s|\[SSHD_UID\]|${SSHD_UID}|g"           $FI
  sed -i -e "s|\[SSHD_GID\]|${SSHD_GID}|g"           $FI
  sed -i -e "s|\[SSHD_PORT\]|${SSHD_PORT}|g"         $FI
  sed -i -e "s|\[SSHD_HNAME\]|`hostname`|g"   $FI
  sed -i -e "s|\[SSHD_DOMAIN\]|`hostname -d`|g"   $FI

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
  #
  # prepare gist directory
  #
  mkdir -p /home/${SSHD_USER}/gist/browse
  chown -v ${SSHD_USER}:${SSHD_GROUP} /home/${SSHD_USER}/gist /home/${SSHD_USER}/gist/browse
  #
  # prepare client script
  #
  FI=/home/${SSHD_USER}/.sshd/scli-linux
  cp /scli-linux $FI
  sed -i -e "s|\[SSHD_USER\]|${SSHD_USER}|g"         $FI
  sed -i -e "s|\[SSHD_HOME\]|/home/${SSHD_USER}|g"   $FI
  sed -i -e "s|\[SSHD_UID\]|${SSHD_UID}|g"           $FI
  sed -i -e "s|\[SSHD_GID\]|${SSHD_GID}|g"           $FI
  sed -i -e "s|\[SSHD_PORT\]|${SSHD_PORT}|g"         $FI
  sed -i -e "s|\[SSHD_HNAME\]|`hostname`|g"          $FI
  sed -i -e "s|\[SSHD_DOMAIN\]|`hostname -d`|g"      $FI
  chown -v  ${SSHD_USER}:${SSHD_GROUP} $FI
  chmod  u+x $FI

done

exec /usr/sbin/sshd -D -e "$@"
