FROM scoobadog/alpine-s6:3.5
MAINTAINER Janne K <0x022b@gmail.com>

RUN \
addgroup -S openvpn && \
adduser -SD -s /sbin/nologin -h /var/lib/openvpn \
	-g openvpn -G openvpn openvpn && \
apk --update-cache --upgrade add \
	iptables \
	ip6tables \
	openvpn && \
rm -rf /tmp/* /var/tmp/* /var/cache/apk/* /root/.cache

COPY rootfs/ /
