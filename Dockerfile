FROM php:8.1-apache

# Install required dependencies
RUN apt-get update && apt-get install -y \
    unzip libaio1 wget gnupg build-essential && \
    rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV ORACLE_VERSION=21_9
ENV ORACLE_HOME=/usr/lib/oracle/${ORACLE_VERSION}/client64
ENV LD_LIBRARY_PATH=${ORACLE_HOME}
ENV PATH=${ORACLE_HOME}/bin:$PATH

# Create directory for Oracle client
RUN mkdir -p /opt/oracle && mkdir -p ${ORACLE_HOME}

# Download and install Oracle Instant Client Basic & SDK
RUN cd /opt/oracle && \
    wget https://download.oracle.com/otn_software/linux/instantclient/219000/instantclient-basic-linux.x64-21.9.0.0.0dbru.zip && \
    wget https://download.oracle.com/otn_software/linux/instantclient/219000/instantclient-sdk-linux.x64-21.9.0.0.0dbru.zip && \
    unzip instantclient-basic-linux.x64-21.9.0.0.0dbru.zip && \
    unzip instantclient-sdk-linux.x64-21.9.0.0.0dbru.zip && \
    mv instantclient_*/* ${ORACLE_HOME}/ && \
    ln -s ${ORACLE_HOME}/libclntsh.so.21.1 ${ORACLE_HOME}/libclntsh.so || true && \
    echo "${ORACLE_HOME}" > /etc/ld.so.conf.d/oracle-instantclient.conf && \
    ldconfig

# Install OCI8 extension with SDK path
RUN echo "instantclient,${ORACLE_HOME}" | pecl install oci8-3.2.1 && \
    docker-php-ext-enable oci8

# Enable Apache rewrite module
RUN a2enmod rewrite

WORKDIR /var/www/html
