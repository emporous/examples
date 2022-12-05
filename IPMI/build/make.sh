#!/bin/sh
sudo podman run --privileged -v .:/profile ghcr.io/uor-framework/examples/archiso:latest mkarchiso -v -w /tmp -o /profile/out /profile
