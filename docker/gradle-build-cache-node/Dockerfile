# 1. Specify the platform and base image.
# We use eclipse-temurin JRE 21 (required by cache node >= 19.0) on Alpine Linux for arm64.
FROM eclipse-temurin:21.0.8_9-jre-alpine

# 2. Set Arguments for the download
# This makes it easy to update the version in one place.
ARG JAR_VERSION=21.2
ARG DOWNLOAD_URL=https://docs.gradle.com/build-cache-node/jar/build-cache-node-${JAR_VERSION}.jar
ARG DEST_JAR_NAME=develocity-build-cache-node.jar

# 3. Set a working directory
WORKDIR /app

# 4. Download the Develocity Build Cache Node JAR file
# We install wget, download the file, rename it, and then remove wget to keep the image clean.
RUN apk add --no-cache wget \
    && wget -O ${DEST_JAR_NAME} ${DOWNLOAD_URL} \
    && apk del wget

# 5. Create and declare the data directory as a volume.
# This is where the cache node stores all its data and configuration.
# The node expects its config file at /data/conf/config.yaml
# You MUST mount a host directory to this volume at runtime.
VOLUME /data

# 6. Expose the default ports
# Port 5071: Main data port for Gradle/Maven
# Port 6011: Bazel remote caching port
EXPOSE 5071
EXPOSE 6011

# 7. Define the command to run the application
# We use ENTRYPOINT for the immutable part (the java command).
ENTRYPOINT ["java", "-jar", "develocity-build-cache-node.jar"]

# 8. Set the default subcommand to 'start' and point to the data directory.
# This will be appended to the ENTRYPOINT.
# The container will run: java -jar develocity-build-cache-node.jar start --data-dir=/data
CMD ["start", "--data-dir=/data"]
