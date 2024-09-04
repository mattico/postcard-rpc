#!/usr/bin/env bash

# TODO: I should be a CI check, but I'm not yet.
set -euxo pipefail

rustup target add \
    thumbv6m-none-eabi \
    thumbv7em-none-eabihf \
    wasm32-unknown-unknown

# Host + STD checks
cargo check \
    --manifest-path source/postcard-rpc/Cargo.toml \
    --no-default-features
cargo test \
    --manifest-path source/postcard-rpc/Cargo.toml \
    --no-default-features

# Host + all non-wasm host-client impls
cargo check \
    --manifest-path source/postcard-rpc/Cargo.toml \
    --no-default-features \
    --features=use-std,cobs-serial,raw-nusb
cargo test \
    --manifest-path source/postcard-rpc/Cargo.toml \
    --no-default-features \
    --features=use-std,cobs-serial,raw-nusb

# Host + wasm host-client impls
RUSTFLAGS="--cfg=web_sys_unstable_apis" \
    cargo check \
        --manifest-path source/postcard-rpc/Cargo.toml \
        --no-default-features \
        --features=use-std,webusb \
        --target wasm32-unknown-unknown
RUSTFLAGS="--cfg=web_sys_unstable_apis" \
    cargo build \
        --manifest-path source/postcard-rpc/Cargo.toml \
        --no-default-features \
        --features=use-std,webusb \
        --target wasm32-unknown-unknown

# Embedded + embassy server impl
cargo check \
    --manifest-path source/postcard-rpc/Cargo.toml \
    --no-default-features \
    --features=embassy-usb-0_3-server \
    --target thumbv7em-none-eabihf
cargo build \
    --manifest-path source/postcard-rpc/Cargo.toml \
    --no-default-features \
    --features=embassy-usb-0_3-server \
    --target thumbv7em-none-eabihf

# Example projects
cargo build \
    --manifest-path example/workbook-host/Cargo.toml
cargo build \
    --manifest-path example/firmware/Cargo.toml \
    --target thumbv6m-none-eabi

# Test Project
cargo test \
    --manifest-path source/postcard-rpc-test/Cargo.toml
