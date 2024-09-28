# Use a lightweight base image
FROM ubuntu:latest

# Install dependencies
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:libreoffice/ppa && \
    apt-get update && \
    apt-get install -y \
        pandoc \
        jq \
        libreoffice-writer \
        libreoffice-java-common \
        default-jre \
        git \
        curl \
        fonts-dejavu \
        fonts-liberation && \
    fc-cache -f -v

# Set up the working directory
WORKDIR /workspace

# Copy all files from the local directory to the container's working directory
COPY . /workspace/

# Define the default command
CMD ["/bin/bash"]