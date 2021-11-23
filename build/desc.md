# share-sshd workspace

The ssh workspace is a private alpine docker container.

All changes in the root context are not saved permanently!

Only your home directory *[SSHD_HOME]* will be saved permanently and can be reached via the web interface.

Feel free to work as sudo to install packages with apk,  
but care about your UID=[SSHD_UID] and GID=[SSHD_GID] in your home directory because of the web interface.

If you have any requests for the alpine docker container (utils, ..), let me know.

With the initial setup of your container, a generic ssh password is generated.
You can find the password in *./sshd/initial_ssh_password.txt*.
The password can be changed with ```passwd```.
To work in key mode, enter your pub key in *./.ssh/authorized_keys*.

## ssh-access:

```
ssh -p [SSHD_PORT] [SSHD_USER]@[SSHD_HNAME].[SSHD_DOMAIN]
scp -P [SSHD_PORT] <file> [SSHD_USER]@[SSHD_HNAME].[SSHD_DOMAIN]:
```

## Provide files via http:

Files can be provided for downloads either browsable or non-browsable.
Files in the *./gist* directory are non-browsable, exclude
files in the *./gist/browse* directory are browsable.

### Examples

```
#
# non-browsable:
#
mkdir ./gist/EinOrdner
date > ./gist/EinOrdner/date.txt

wget gist.[SSHD_DOMAIN]/[SSHD_USER]/EinOrdner/date.txt

#
# browsable:
#
mkdir ./gist/browse/NochEinOrdner
date > ./gist/browse/NochEinOrdner/date.txt

firefox gist.[SSHD_DOMAIN]/[SSHD_USER]/browse
```

