FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ARG CHROME_VERSION=114.0.5735.90-1
ARG CHROMEDRIVER_VERSION=114.0.5735.90
ARG MAVEN_VERSION=3.9.9

ENV TZ=UTC
ENV JAVA_HOME=/opt/java/openjdk
ENV MAVEN_HOME=/opt/maven
ENV PATH=${JAVA_HOME}/bin:${MAVEN_HOME}/bin:/usr/local/bin:${PATH}
ENV CHROME_BIN=/usr/bin/google-chrome
ENV WEBDRIVER_CHROME_DRIVER=/usr/local/bin/chromedriver

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    curl \
    fonts-liberation \
    gnupg \
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

RUN mkdir -p /opt/java /opt/maven /tmp/chrome && \
    curl -fsSL "https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u442-b06/OpenJDK8U-jdk_x64_linux_hotspot_8u442b06.tar.gz" \
    | tar -xz -C /opt/java && \
    mv /opt/java/jdk8u442-b06 /opt/java/openjdk && \
    curl -fsSL "https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz" \
    | tar -xz -C /opt/maven --strip-components=1 && \
    wget -q -O /tmp/chrome/google-chrome-stable.deb \
      "https://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_${CHROME_VERSION}_amd64.deb" && \
    apt-get update && \
    apt-get install -y /tmp/chrome/google-chrome-stable.deb && \
    wget -q -O /tmp/chrome/chromedriver.zip \
      "https://chromedriver.storage.googleapis.com/${CHROMEDRIVER_VERSION}/chromedriver_linux64.zip" && \
    unzip /tmp/chrome/chromedriver.zip -d /usr/local/bin/ && \
    chmod +x /usr/local/bin/chromedriver && \
    rm -rf /tmp/chrome /var/lib/apt/lists/*

WORKDIR /workspace

CMD ["bash"]
