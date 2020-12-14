FROM debian as builder
ARG librespot_version=064359c26e0e0d29a820a542bb2e48bc237b3b49

RUN apt update
RUN apt install -y git build-essential libasound2-dev curl pkg-config git libpulse-dev
RUN curl https://sh.rustup.rs -sSf > rustup.sh
RUN sh rustup.sh -y

RUN git clone https://github.com/librespot-org/librespot.git
RUN git -C librespot checkout $librespot_version
RUN cd librespot && /root/.cargo/bin/cargo build --release --features "alsa-backend,pulseaudio-backend"



FROM debian:stable-slim as release
RUN useradd librespot
RUN usermod -a -G audio librespot
COPY --from=builder  /librespot/target/release/librespot /usr/bin/librespot
RUN apt update && apt install -y libasound2 libpulse0 && rm -r /var/cache/apt

USER librespot
ENTRYPOINT ["/usr/bin/librespot"]
CMD ["-n","LibreSpot Docker"]
