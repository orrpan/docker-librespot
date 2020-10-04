FROM debian as builder

RUN apt update
RUN apt install -y git build-essential libasound2-dev curl pkg-config git
RUN curl https://sh.rustup.rs -sSf > rustup.sh
RUN sh rustup.sh -y

RUN git clone https://github.com/librespot-org/librespot.git
RUN cd librespot && /root/.cargo/bin/cargo build --release



FROM debian:stable-slim as release
RUN useradd librespot
COPY --from=builder  /librespot/target/release/librespot /usr/bin/librespot
RUN apt update && apt install -y libasound2-dev && rm -r /var/cache/apt

USER librespot
ENTRYPOINT ["/usr/bin/librespot"]
CMD ["-n","LibreSpot Docker"]
