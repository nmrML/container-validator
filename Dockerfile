FROM ubuntu:18.04

#FROM debian:bullseye

## Install OpenMS TOPP tools

#RUN cp /etc/apt/sources.list /etc/apt/sources.list.d/sources-src.list
#RUN sed -i 's|deb http|deb-src http|g' /etc/apt/sources.list.d/sources-src.list
#RUN echo "deb http://deb.debian.org/debian buster main contrib" >>/etc/apt/sources.list.d/buster.list
#RUN echo "deb-src http://deb.debian.org/debian buster main contrib" >>/etc/apt/sources.list.d/buster.list

#    apt-get -y install libopenms2.4.0 openms-common=2.4.0-real-1 && \

#RUN apt-get update && \
#    apt-get -y build-dep  libopenms2.4.0 && \
#    apt-get -y install libqt4-dev qdbus=4:4.8.7+dfsg-18+deb10u1 libqtwebkit-dev && \
#    apt-get -y clean && \
#    rm -rf \
#      /var/lib/apt/lists/* \
#      /usr/share/doc \
#      /usr/share/doc-base \
#      /usr/share/man \
#      /usr/share/locale \
#      /usr/share/zoneinfo

#RUN apt-get update && \
#      apt-get -y install libqt4-dev qdbus=4:4.8.7+dfsg-18+deb10u1 libqtwebkit-dev
RUN apt-get update && \
            apt-get -y install libqt4-dev  libqtwebkit-dev

RUN apt-get -y install cmake g++ libboost-regex-dev libboost-iostreams-dev libboost-date-time-dev libboost-math-dev doxygen libxerces-c-dev libsvm-dev libglpk-dev zlib1g-dev libbz2-dev

RUN ln -s /usr/bin/make /usr/bin/gmake

RUN apt-get -y install autoconf libtool

WORKDIR /OpenMS/contrib

# RUN for F in BOOST XERCESC SEQAN ; do cmake -DBOOST_USE_STATIC=NO -DBUILD_TYPE=$F . ; done

# find . -name "*.a" -o -name "*.so" -o -name "*.o" -o "*.lo" -exec rm \{\} \;



# debhelper (>= 9.20151004), dpkg-dev (>= 1.16.1~),  libeigen3-dev, libwildmagic-dev,
# libboost-dev (>= 1.54.0), libboost-iostreams-dev (>= 1.54.0), libboost-date-time-dev (>= 1.54.0), libboost-math-dev (>= 1.54.0),
# libsqlite3-dev, seqan-dev (>= 1.4.1), ,
# cppcheck (>= 1.54), qtbase5-dev (>= 5.7.0), libqt5opengl5-desktop-dev (>= 5.7.0),
# libqt5svg5-dev (>= 5.7.0), coinor-libcbc-dev (>= 2.8.12-1+b2), coinor-libcgl-dev (>= 0.58.9-1+b1), imagemagick, doxygen (>= 1.8.1.2), graphviz,
# texlive-extra-utils, texlive-latex-extra, texlive-latex-recommended, texlive-fonts-extra, texlive-font-utils, texlive-plain-generic, tex-gyre, ghostscript, texlive-fonts-recommended

## Build OpenMS

# COPY OpenMS/OpenMS-nmrML /OpenMS/OpenMS-nmrML
# COPY OpenMS/contrib /OpenMS/contrib

#WORKDIR /OpenMS/contrib
#
#RUN cmake --fresh  -DBUILD_TYPE=XERCESC .
#RUN cmake --fresh  -DBUILD_TYPE=GSL .
#RUN cmake --fresh  -DBUILD_TYPE=SVM .

#  -DBUILD_TYPE="XERCESC"
#WORKDIR /OpenMS/OpenMS-nmrML

## Patch:  ./source/APPLICATIONS/TOPP/executables.cmake
#--- ./source/APPLICATIONS/TOPP/executables.cmake~	2023-08-10 16:31:02.000000000 +0200
#+++ ./source/APPLICATIONS/TOPP/executables.cmake	2023-08-11 12:28:53.170407745 +0200
#@@ -107,6 +107,7 @@
# ## all targets with need linkage against OpenMS_GUI.lib - they also need to appear in the list above)
# set(TOPP_executables_with_GUIlib
# ExecutePipeline
#+PILISIdentification
# )


# RUN rm /OpenMS/OpenMS-nmrML/CMakeCache.txt
#RUN cmake --fresh  -DCMAKE_FIND_ROOT_PATH=/OpenMS/contrib .
#RUN make -j 4 bin/FileInfo
#RUN make -j 4
## Obtain the nmrML schema and mapping files
# https://github.blog/2020-12-21-get-up-to-speed-with-partial-clone-and-shallow-clone/
# RUN git clone --depth=1 --filter=tree:0 --single-branch --branch=master

#     apt-get -y build-dep topp=2.4.0-real-1 && \

#FROM php:8-apache-bullseye

## Copy the validator
#COPY src/ /var/www/html/



## docker run --rm -it -v /home/sneumann/src/nmrML/container-validator/OpenMS/contrib:/OpenMS/contrib -v /home/sneumann/src/nmrML/container-validator/OpenMS/OpenMS-nmrML:/OpenMS/OpenMS-nmrML sneumann/nmrml-validator bash
