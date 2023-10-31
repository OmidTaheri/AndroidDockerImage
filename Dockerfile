FROM ubuntu:20.04

MAINTAINER Omid Taheri <m.omidtaheri@gmail.com>

ARG GRADLE_VERSION=8.2.1
ARG SDK_TOOLS_VERSION=9477386
ARG DEBIAN_FRONTEND=noninteractive


ENV ANDROID_HOME "/android-sdk-linux"
ENV PATH "$PATH:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools:/opt/gradle/gradle-${GRADLE_VERSION}/bin"

# Set environment variables for SDKMAN
ENV SDKMAN_DIR="/sdkman"
ENV PATH="$SDKMAN_DIR/bin:$PATH"
ENV SDKMAN_CANDIDATES_HOME="$SDKMAN_DIR/candidates"

RUN apt-get update \
	&& apt-get upgrade -y \
	&& apt-get install -y git jq wget unzip curl zip openjdk-17-jdk python3 python3-pip \
	&& apt-get clean

# Install SDKMAN
RUN curl -s "https://get.sdkman.io" | bash

# Source SDKMAN And Install Kotlin using SDKMAN
RUN bash -c "source $SDKMAN_DIR/bin/sdkman-init.sh && sdk install kotlin"

# Source SDKMAN And Install kscript using SDKMAN
RUN bash -c "source $SDKMAN_DIR/bin/sdkman-init.sh && sdk install kscript"

# Add kscript executable to the PATH
ENV PATH="$SDKMAN_CANDIDATES_HOME/kotlin/current/bin:$SDKMAN_CANDIDATES_HOME/kscript/current/bin:$PATH"


 RUN wget --output-document=gradle-${GRADLE_VERSION}-all.zip https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-all.zip \
         && mkdir -p /opt/gradle \
         && unzip gradle-${GRADLE_VERSION}-all.zip -d /opt/gradle \
         && rm ./gradle-${GRADLE_VERSION}-all.zip \
         && mkdir -p ${ANDROID_HOME} \
         && wget --output-document=android-sdk.zip https://dl.google.com/android/repository/commandlinetools-linux-${SDK_TOOLS_VERSION}_latest.zip \
         && unzip ./android-sdk.zip -d ${ANDROID_HOME} \
         && rm ./android-sdk.zip \
         && mkdir -p ~/.android \
         && touch ~/.android/repositories.cfg

 RUN yes | ${ANDROID_HOME}/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} --licenses \
         && ${ANDROID_HOME}/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} --update

 ADD packages.txt .

 RUN while read -r package; do PACKAGES="${PACKAGES}${package} "; done < ./packages.txt && \
     ${ANDROID_HOME}/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} ${PACKAGES}

