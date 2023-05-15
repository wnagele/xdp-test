FROM rust AS build

RUN rustup install stable && \
    rustup install nightly && \
    rustup component add rust-src --toolchain nightly-x86_64-unknown-linux-gnu && \
    cargo install bpf-linker

RUN mkdir /build
WORKDIR /build
COPY . .
RUN cargo xtask build-ebpf --release && \
    cargo build --release


FROM rust
RUN apt update && apt -y install inetutils-ping
COPY --from=build /build/target/release/xdp-test /
ENV RUST_LOG=info
ENTRYPOINT [ "/xdp-test" ]