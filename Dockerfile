FROM alpine:edge 
MAINTAINER William dos Santos
RUN mkdir -p  /etc/init/
ADD ./scripts/gns3_start.sh /etc/init/gns3_start.sh
RUN chmod 755 /etc/init/gns3_start.sh
ADD ./conf/gns3_server.conf /etc/gns3_server.conf
ADD ./conf/gns3_controller.conf /etc/gns3_controller.conf
RUN sed -n "s/main/testing/p" /etc/apk/repositories >> /etc/apk/repositories && \
    mkdir /data && \
    apk add --no-cache dnsmasq cpulimit bash openssh autossh iptables  dynamips gns3-server qemu-img qemu-system-x86_64 ubridge vpcs iouyap wget 
RUN pip3 install idna 
RUN set -x \
 && mkdir /root/.ssh \
 && chmod 700 /root/.ssh
ADD ./bin/vpcs /usr/bin/vpcs
RUN chmod 755 /usr/bin/vpcs
RUN ssh-keygen -f   /etc/ssh/ssh_host_rsa_key     -N '' -t rsa     \
&&  ssh-keygen -f   /etc/ssh/ssh_host_dsa_key     -N '' -t dsa     \
&&  ssh-keygen -f   /etc/ssh/ssh_host_ecdsa_key   -N '' -t ecdsa   \
&&  ssh-keygen -f   /etc/ssh/ssh_host_ed25519_key -N '' -t ed25519 \
&&  cp -a /etc/ssh  /etc/ssh.default 
RUN sed -ri 's/#HostKey \/etc\/ssh\/ssh_host_key/HostKey \/etc\/ssh\/ssh_host_key/g' /etc/ssh/sshd_config
RUN sed -ir 's/#HostKey \/etc\/ssh\/ssh_host_rsa_key/HostKey \/etc\/ssh\/ssh_host_rsa_key/g' /etc/ssh/sshd_config
RUN sed -ir 's/#HostKey \/etc\/ssh\/ssh_host_dsa_key/HostKey \/etc\/ssh\/ssh_host_dsa_key/g' /etc/ssh/sshd_config
RUN sed -ir 's/#HostKey \/etc\/ssh\/ssh_host_ecdsa_key/HostKey \/etc\/ssh\/ssh_host_ecdsa_key/g' /etc/ssh/sshd_config
RUN sed -ir 's/#HostKey \/etc\/ssh\/ssh_host_ed25519_key/HostKey \/etc\/ssh\/ssh_host_ed25519_key/g' /etc/ssh/sshd_config
RUN adduser -D -s  /bin/ash gns3
RUN mkdir -p /home/gns3/.ssh
RUN echo "gns3:$(tr -dc A-Za-z0-9_ < /dev/urandom | head -c 20 | xargs)"| chpasswd 2>/dev/null
RUN chmod 700 -R  /home/gns3/.ssh
RUN chown -R gns3:gns3 /home/gns3
ENTRYPOINT [ "/etc/init/gns3_start.sh" ]
WORKDIR /etc/init
VOLUME ["/data"]
