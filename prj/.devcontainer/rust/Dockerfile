FROM debian:bookworm

# Base deps
RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    pkg-config \
    libssl-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Rustup
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Toolchains & tools
RUN rustup default stable \
    && rustup component add rustfmt clippy

WORKDIR /workspace

