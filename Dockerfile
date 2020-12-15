FROM alpine:3.12 as build

ARG librespot_version=064359c26e0e0d29a820a542bb2e48bc237b3b49


RUN apk --no-cache --virtual add \
    git \
    alsa-lib-dev \
    pulseaudio-dev \
    cargo 

RUN git clone https://github.com/librespot-org/librespot.git librespot
RUN git -C librespot checkout $librespot_version
RUN cargo build --jobs $(grep -c ^processor /proc/cpuinfo) --release --features "pulseaudio-backend"

FROM alpine:3.12

COPY --from=build /librespot/target/release/librespot /usr/bin/librespot

RUN adduser -S librespot -G audio

RUN apk add --no-cache\
    libpulse \
    alsa-lib

USER librespot
ENTRYPOINT ["/usr/bin/librespot"]
CMD ["-n","LibreSpot Docker"]
