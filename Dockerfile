FROM debian:jessie
MAINTAINER Matt McCormick <matt.mccormick@kitware.com>

RUN apt-get update

RUN apt-get install -y build-essential
RUN apt-get install -y cmake cmake-curses-gui
RUN apt-get install -y subversion
RUN apt-get install -y git
RUN apt-get install -y ninja-build

RUN apt-get install -y libinsighttoolkit4-dev
RUN apt-get install -y libqt4-dev

RUN mkdir -p /opt/{src,bin}
WORKDIR /opt/src

RUN git clone http://vtk.org/VTK.git
WORKDIR /opt/src/VTK
RUN git checkout v6.1.0
RUN sed -i 's/\/\/#define\ GLX_GLXEXT_LEGACY/#define\ GLX_GLXEXT_LEGACY/g' Rendering/OpenGL/vtkXOpenGLRenderWindow.cxx

RUN echo 'deb-src http://http.debian.net/debian jessie main' >> /etc/apt/sources.list
RUN echo 'deb-src http://http.debian.net/debian jessie-updates main' >> /etc/apt/sources.list
RUN apt-get update
RUN apt-get build-dep -y libvtk6-dev
RUN mkdir -p /opt/bin/VTK
WORKDIR /opt/bin/VTK
RUN cmake -G Ninja \
  -DCMAKE_BUILD_TYPE:STRING=Release \
  -DBUILD_TESTING:BOOL=OFF \
  ../../src/VTK
RUN ninja
RUN ninja install

WORKDIR /opt/src
RUN svn co https://subversion.assembla.com/svn/plus/trunk/PlusLib
RUN mkdir -p /opt/bin/PlusLib
WORKDIR /opt/bin/PlusLib
RUN cmake -G Ninja \
  -DCMAKE_BUILD_TYPE:STRING=Release \
  -DVTK_DIR:PATH=/usr/local/lib/cmake/vtk-6.1/ \
  -DITK_DIR:PATH=/usr/lib/cmake/ITK-4.6 \
  -DPLUS_EXECUTABLE_OUTPUT_PATH=/opt/bin/PlusLib/bin \
  /opt/src/PlusLib
RUN ninja

ENV PATH=/opt/bin/PlusLib/bin:$PATH
