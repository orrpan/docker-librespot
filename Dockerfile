FROM alpine:3.12
MAINTAINER Oskar Joelsson

ARG librespot_version=064359c26e0e0d29a820a542bb2e48bc237b3b49

WORKDIR /build

RUN apk --upgrade add \
    git \
    alsa-lib-dev \
    pulseaudio-dev \
    cargo 

RUN git clone https://github.com/librespot-org/librespot.git librespot
RUN git -C librespot checkout $librespot_version
RUN cd librespot \
 && cargo build --jobs $(grep -c ^processor /proc/cpuinfo) --release --features "pulseaudio-backend" \
 && mv target/release/librespot /usr/bin/librespot

RUN adduser -S librespot -G audio

RUN apk --purge del \
    git \
    alsa-lib-dev \
    pulseaudio-dev \
    cargo

RUN rm -rf /build

RUN apk --upgrade add \
    libpulse \
    alsa-lib

USER librespot
ENTRYPOINT ["/usr/bin/librespot"]
CMD ["-n","LibreSpot Docker"]
