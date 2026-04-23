FROM maven:3.9.9-eclipse-temurin-11 AS maven-runtime

FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ARG CHROME_VERSION=114.0.5735.90-1
ARG CHROMEDRIVER_VERSION=114.0.5735.90

ENV TZ=UTC
ENV JAVA_HOME=/opt/java/openjdk
ENV MAVEN_HOME=/opt/maven
ENV PATH=${JAVA_HOME}/bin:${MAVEN_HOME}/bin:/usr/local/bin:${PATH}
ENV CHROME_BIN=/usr/bin/google-chrome
ENV WEBDRIVER_CHROME_DRIVER=/usr/local/bin/chromedriver
ENV CPROCSP_HOME=/opt/cprocsp

RUN apt-get update && apt-get install -y --no-install-recommends \
    alien \
    bash \
    ca-certificates \
    curl \
    fonts-liberation \
    gnupg \
    lsb-base \
    lsb-core \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libc6 \
    libcairo2 \
    libcups2 \
    libdbus-1-3 \
    libdrm2 \
    libexpat1 \
    libfontconfig1 \
    libgbm1 \
    libgcc-s1 \
    libglib2.0-0 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libstdc++6 \
    libu2f-udev \
    libvulkan1 \
    libx11-6 \
    libx11-xcb1 \
    libxcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxkbcommon0 \
    libxrandr2 \
    libxrender1 \
    libxshmfence1 \
    procps \
    unzip \
    wget \
    xdg-utils \
    && rm -rf /var/lib/apt/lists/*

COPY docker/install-cryptopro.sh /usr/local/bin/install-cryptopro.sh
COPY docker/import-cryptopro-materials.sh /usr/local/bin/import-cryptopro-materials.sh
COPY docker/container-entrypoint.sh /usr/local/bin/container-entrypoint.sh
COPY src/main/resources/google-chrome-stable_114.0.5735.90-1_amd64.deb /tmp/browser/google-chrome-stable_114.0.5735.90-1_amd64.deb

COPY --from=maven-runtime /opt/java/openjdk /opt/java/openjdk
COPY --from=maven-runtime /usr/share/maven /opt/maven

RUN mkdir -p /tmp/chrome && \
    apt-get update && \
    apt-get install -y /tmp/browser/google-chrome-stable_114.0.5735.90-1_amd64.deb && \
    wget -q -O /tmp/chromedriver.zip "https://chromedriver.storage.googleapis.com/${CHROMEDRIVER_VERSION}/chromedriver_linux64.zip" && \
    unzip -q /tmp/chromedriver.zip -d /tmp/chromedriver && \
    install -m 0755 /tmp/chromedriver/chromedriver /usr/local/bin/chromedriver && \
    chmod +x /usr/local/bin/install-cryptopro.sh /usr/local/bin/import-cryptopro-materials.sh /usr/local/bin/container-entrypoint.sh && \
    rm -rf /tmp/chrome /tmp/browser /tmp/chromedriver /tmp/chromedriver.zip /var/lib/apt/lists/*

COPY cryptopro/ /tmp/cryptopro/

RUN /usr/local/bin/install-cryptopro.sh /tmp/cryptopro && rm -rf /tmp/cryptopro

WORKDIR /workspace

ENTRYPOINT ["/usr/local/bin/container-entrypoint.sh"]
CMD ["bash"]
