FROM fedora:latest

# Install required packages for BlueZ spec processing and COPR
RUN dnf update -y && \
    dnf install -y \
        cpio \
        curl \
        jq \
        copr-cli \
        python3-pip \
        awk \
        && \
    dnf clean all

# Create workspace directory
WORKDIR /workspace

# Copy scripts
COPY scripts ./scripts
COPY *.sh ./
RUN chmod +x ./scripts/chroots/*.sh && \
    chmod +x ./scripts/spec/*.sh && \
    chmod +x *.sh

# Create spec directory
RUN mkdir -p spec

# Set default command
ENTRYPOINT ["bash", "./update.sh"]