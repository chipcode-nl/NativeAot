# Dockerfile for .NET 8.0 
# https://hub.docker.com/_/microsoft-dotnet-aspnet/
#
# Author      : Carl van Heezik
# Revision    : 1.0
# Date         : 2023-10-13
FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:9.0-preview AS build 
ARG UID
ARG GID

RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get -y install sudo
RUN apt-get -y install clang zlib1g-dev
RUN adduser --uid $UID --gid $GID developer
RUN echo 'developer ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

USER developer