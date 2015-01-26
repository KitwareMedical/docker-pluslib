FROM debian:jessie
MAINTAINER Matt McCormick <matt.mccormick@kitware.com>

RUN apt-get update
RUN apt-get install -y build-essential
RUN apt-get install -y cmake cmake-curses-gui
