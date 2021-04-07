FROM fedora:latest

RUN dnf -y install openssh-server git
RUN dnf -y install ed # needed to edit passwd and group
RUN dnf -y install container-selinux
RUN dnf clean all

# setup openssh
RUN sed -i "s/#PasswordAuthentication yes/PasswordAuthentication no/" /etc/ssh/sshd_config
# SSHd 7.4+ (maybe earlier) this is not needed, see
#  https://lists.mindrot.org/pipermail/openssh-unix-dev/2017-August/036168.html
# RUN sed -i 's/#UsePrivilegeSeparation.*$/UsePrivilegeSeparation no/' /etc/ssh/sshd_config

RUN sed -i 's/#Port.*$/Port 22/' /etc/ssh/sshd_config
RUN chmod 775 /var/run
RUN rm -f /var/run/nologin

# setup git user
RUN adduser --system -s /bin/bash -u 1234321 -g 65534 git # uid to replace later
RUN chmod 775 /etc/ssh /home # keep writable for openshift user group (root)
RUN chmod 660 /etc/ssh/sshd_config
RUN chmod 664 /etc/passwd /etc/group # to help uid fix
RUN mkdir -p /home/git
RUN ln -s /home/git /repos # nicer repo url

WORKDIR /home/git/

#RUN mkdir -p /home/git/.ssh && \
#    touch /home/git/.ssh/authorized_keys && \
#    chmod 700 /home/git/.ssh && \
#    chmod 600 /home/git/.ssh/authorized_keys && \
#    mkdir /home/git/sample.git && \
#    git -C /home/git/sample.git init --bare && \
#    ssh-keygen -A

RUN chown -R git:nobody /etc/ssh

RUN chown -R git:nobody /etc/passwd

RUN chown -R git:nobody /etc/group

RUN chown git:nobody /home
RUN chown -R git:nobody /home/git
RUN chmod 775 /home
RUN chmod -R 777 /home/git

RUN chown -R git:nobody /repos

RUN ls -l /
RUN ls -l /home
RUN ls -l /home/git

EXPOSE 22
LABEL Description="sample git server; you need to add your ssh keys after startup; on restart you lose repos by default" Vendor="Red Hat" Version="1.0"

USER git

CMD ["/usr/sbin/sshd", "-D"]
