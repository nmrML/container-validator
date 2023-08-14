FROM ubuntu:18.04

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
            apt-get install -y libqt4-dev  libqtwebkit-dev \
              cmake g++ libsvm-dev libglpk-dev zlib1g-dev libbz2-dev autoconf libtool doxygen patch subversion

RUN ln -s /usr/bin/make /usr/bin/gmake

COPY OpenMS/contrib /OpenMS/contrib
WORKDIR /OpenMS/contrib
RUN for F in BOOST XERCESC SEQAN; do cmake -DBOOST_USE_STATIC=NO -DBUILD_TYPE=$F . ; done

COPY OpenMS/OpenMS-nmrML /OpenMS/OpenMS-nmrML
WORKDIR /OpenMS/OpenMS-nmrML
RUN cmake --fresh  -DCMAKE_FIND_ROOT_PATH=/OpenMS/contrib .

## This is known to fail, hence the true
RUN make -j 4 FileInfo || true
RUN make -j 4 SemanticValidator || true
RUN /usr/bin/c++    -fopenmp -O3 -DNDEBUG  -Wl,--copy-dt-needed-entries -rdynamic -fopenmp CMakeFiles/FileInfo.dir/source/APPLICATIONS/TOPP/FileInfo.C.o  -o bin/FileInfo -Wl,-rpath,/OpenMS/OpenMS-nmrML/lib -lQtOpenGL -lQtGui -lQtSvg -lQtWebKit -lQtTest -lQtXml -lQtSql -lQtNetwork lib/libOpenMS.so -lQtGui -lQtOpenGL -lQtSvg -lQtWebKit -lQtTest -lQtXml -lQtSql -lQtNetwork lib/libOpenSwathAlgo.so /OpenMS/contrib/lib/libgsl.a /OpenMS/contrib/lib/libgslcblas.a -lsvm -lm /OpenMS/contrib/lib/libxerces-c.a /OpenMS/contrib/lib/libboost_iostreams-mt.a /OpenMS/contrib/lib/libboost_date_time-mt.a /OpenMS/contrib/lib/libboost_math_c99-mt.a /OpenMS/contrib/lib/libboost_regex-mt.a -lbz2 -lz -lglpk
RUN /usr/bin/c++    -fopenmp -O3 -DNDEBUG  -Wl,--copy-dt-needed-entries -rdynamic -fopenmp CMakeFiles/SemanticValidator.dir/source/APPLICATIONS/UTILS/SemanticValidator.C.o  -o bin/SemanticValidator -Wl,-rpath,/OpenMS/OpenMS-nmrML/lib -lQtOpenGL -lQtGui -lQtSvg -lQtWebKit -lQtTest -lQtXml -lQtSql -lQtNetwork lib/libOpenMS.so -lQtGui -lQtOpenGL -lQtSvg -lQtWebKit -lQtTest -lQtXml -lQtSql -lQtNetwork lib/libOpenSwathAlgo.so /OpenMS/contrib/lib/libgsl.a /OpenMS/contrib/lib/libgslcblas.a -lsvm -lm /OpenMS/contrib/lib/libxerces-c.a /OpenMS/contrib/lib/libboost_iostreams-mt.a /OpenMS/contrib/lib/libboost_date_time-mt.a /OpenMS/contrib/lib/libboost_math_c99-mt.a /OpenMS/contrib/lib/libboost_regex-mt.a -lbz2 -lz -lglpk


### Now the runtime environment
FROM ubuntu:18.04

COPY --from=0 /OpenMS/OpenMS-nmrML/bin /OpenMS/OpenMS-nmrML/bin
COPY --from=0 /OpenMS/OpenMS-nmrML/lib /OpenMS/OpenMS-nmrML/lib
COPY --from=0 /OpenMS/OpenMS-nmrML/share /OpenMS/OpenMS-nmrML/share
ENV OPENMS_DATA_PATH=/OpenMS/OpenMS-nmrML/share

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
            apt-get install -y libqt4-network libqt4-sql libqtcore4 libqtgui4 \
              libglpk40 libsvm3 zlib1g libgomp1 \
              apache2 libapache2-mod-php

# Smoke test
RUN /OpenMS/OpenMS-nmrML/bin/FileInfo --help

ENV PHP_INI_DIR /usr/local/etc/php
RUN set -eux; \
	mkdir -p "$PHP_INI_DIR/conf.d"

ENV APACHE_CONFDIR /etc/apache2
ENV APACHE_ENVVARS $APACHE_CONFDIR/envvars

RUN set -eux; \
# generically convert lines like
#   export APACHE_RUN_USER=www-data
# into
#   : ${APACHE_RUN_USER:=www-data}
#   export APACHE_RUN_USER
# so that they can be overridden at runtime ("-e APACHE_RUN_USER=...")
	sed -ri 's/^export ([^=]+)=(.*)$/: ${\1:=\2}\nexport \1/' "$APACHE_ENVVARS"; \
	\
# setup directories and permissions
	. "$APACHE_ENVVARS"; \
	for dir in \
		"$APACHE_LOCK_DIR" \
		"$APACHE_RUN_DIR" \
		"$APACHE_LOG_DIR" \
	; do \
		rm -rvf "$dir"; \
		mkdir -p "$dir"; \
		chown "$APACHE_RUN_USER:$APACHE_RUN_GROUP" "$dir"; \
# allow running as an arbitrary user (https://github.com/docker-library/php/issues/743)
		chmod 1777 "$dir"; \
	done; \
	\
# delete the "index.html" that installing Apache drops in here
	rm -rvf /var/www/html/*; \
	\
# logs should go to stdout / stderr
	ln -sfT /dev/stderr "$APACHE_LOG_DIR/error.log"; \
	ln -sfT /dev/stdout "$APACHE_LOG_DIR/access.log"; \
	ln -sfT /dev/stdout "$APACHE_LOG_DIR/other_vhosts_access.log"; \
	chown -R --no-dereference "$APACHE_RUN_USER:$APACHE_RUN_GROUP" "$APACHE_LOG_DIR"

# Apache + PHP requires preforking Apache for best results
RUN a2dismod mpm_event && a2enmod mpm_prefork

# PHP files should be handled by PHP, and should be preferred over any other file type
RUN { \
		echo '<FilesMatch \.php$>'; \
		echo '\tSetHandler application/x-httpd-php'; \
		echo '</FilesMatch>'; \
		echo; \
		echo 'DirectoryIndex disabled'; \
		echo 'DirectoryIndex index.php index.html'; \
		echo; \
		echo '<Directory /var/www/>'; \
		echo '\tOptions -Indexes'; \
		echo '\tAllowOverride All'; \
		echo '</Directory>'; \
	} | tee "$APACHE_CONFDIR/conf-available/docker-php.conf" \
	&& a2enconf docker-php

WORKDIR /var/www/html
## Copy the validator and CV+Mapping
COPY src/nmrML-validator nmrML-validator
COPY nmrML /nmrML

RUN set -eux; \
# smoke test
	php --version

COPY apache2-foreground /usr/local/bin/
COPY docker-php-entrypoint  /usr/local/bin/
ENTRYPOINT ["docker-php-entrypoint"]
# https://httpd.apache.org/docs/2.4/stopping.html#gracefulstop
STOPSIGNAL SIGWINCH

EXPOSE 80
CMD ["apache2-foreground"]
