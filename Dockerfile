ARG BUILD_FROM
FROM $BUILD_FROM

LABEL io.hass.version="1.0" io.hass.type="addon" io.hass.arch="armhf|aarch64|i386|amd64"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# printer-driver-brlaser specifically called out for Brother printer support
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        sudo \
        locales \
        cups \
        avahi-daemon \
        libnss-mdns \
        dbus \
        colord \
        libcupsimage2 \
        printer-driver-all-enforce \
        openprinting-ppds \
        hpijs-ppds \
        hp-ppd  \
        hplip \
        printer-driver-brlaser \
        cups-pdf \
        gnupg2 \
        lsb-release \
        nano \
        samba \
        bash-completion \
        procps \
        whois \
    && cd /tmp/ && { curl -O "http://github.com/Xemorph/ha-cups-addon/raw/refs/heads/main/epson-inkjet-printer-escpr2_1.2.24_amd64.deb" ; cd -; } \
    && dpkg -i /tmp/epson-inkjet-printer-escpr2_1.2.24_amd64.deb \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

COPY rootfs /

# Add user and disable sudo password checking
RUN useradd \
  --groups=sudo,lp,lpadmin \
  --create-home \
  --home-dir=/home/print \
  --shell=/bin/bash \
  --password=$(mkpasswd print) \
  print \
&& sed -i '/%sudo[[:space:]]/ s/ALL[[:space:]]*$/NOPASSWD:ALL/' /etc/sudoers

EXPOSE 631
RUN chmod a+x /run.sh

CMD ["/run.sh"]
