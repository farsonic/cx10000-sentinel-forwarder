# Use an official Ubuntu image
FROM ubuntu:22.04

# Set noninteractive mode to avoid tzdata prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies, geoipupdate, redis-tools, and Python
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3 \
        python3-pip \
        python3-setuptools \
        python3-wheel \
        gcc \
        libmaxminddb0 \
        libmaxminddb-dev \
        mmdb-bin \
        geoipupdate \
        redis-tools \
        ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Upgrade pip to avoid dependency resolution issues
RUN pip3 install --no-cache-dir --upgrade pip

# Set working directory
WORKDIR /app

# Copy and install Python dependencies
COPY requirements.txt requirements.txt
RUN pip3 install --no-cache-dir -r requirements.txt

# Copy the Python script and entrypoint script into the container
COPY syslog_forwarder.py syslog_forwarder.py
COPY entrypoint.sh entrypoint.sh

# Ensure the entrypoint script is executable
RUN chmod +x entrypoint.sh

# Expose the UDP port
EXPOSE 5514/udp

# Set environment variables defaults (override these at runtime as needed)
ENV WORKSPACE_ID=your_workspace_id
ENV SHARED_KEY=your_shared_key
ENV LOG_TYPE=PensandoFlowLog
ENV MAPPORT=True
ENV MAXMIND_ENABLED=True
ENV MAXMIND_DB_PATH=GeoLite2-City.mmdb
ENV MAX_BATCH_SIZE=25
ENV UDP_IP=0.0.0.0
ENV UDP_PORT=5514

# GeoIP configuration environment variables
ENV MAXMIND_ACCOUNT_ID=12345
ENV MAXMIND_LICENSE_KEY=12345
ENV MAXMIND_EDITION_IDS="GeoLite2-ASN GeoLite2-City GeoLite2-Country"

# Set the entrypoint to run our script
ENTRYPOINT ["./entrypoint.sh"]
