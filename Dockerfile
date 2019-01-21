FROM maven:3-jdk-8-alpine

# Define the Genny Version
ARG GENNY_VERSION=2.0.1

# Install dependencies
RUN apk update
RUN apk upgrade
RUN apk add git
RUN apk add bash
RUN apk add ncurses
RUN apk add zip

# Add the upgrade script
ADD upgrade.sh /upgrade.sh
RUN chmod +x /upgrade.sh

# Create a directory to store the result
RUN mkdir genny-workspace

# Run the build script
ENV TERM xterm
RUN cd genny-workspace && /upgrade.sh $GENNY_VERSION

# Zip up the release
RUN zip -q -r release.zip genny-workspace
