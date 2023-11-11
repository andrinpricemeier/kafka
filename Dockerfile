FROM owlab/oracle-jdk8-arm64

ENV KAFKA_VERSION=2.8.0 KAFKA_SCALA_VERSION=2.13 JMX_PORT=7203
ENV KAFKA_RELEASE_ARCHIVE kafka_${KAFKA_SCALA_VERSION}-${KAFKA_VERSION}.tgz

RUN mkdir /kafka /data /logs

# Download Kafka binary distribution
ADD https://downloads.apache.org/kafka/${KAFKA_VERSION}/${KAFKA_RELEASE_ARCHIVE} /tmp/

WORKDIR /tmp

# Install Kafka to /kafka
RUN tar -zx -C /kafka --strip-components=1 -f ${KAFKA_RELEASE_ARCHIVE} && \
  rm -rf kafka_*

ADD config /kafka/config
ADD start.sh /kafka/start.sh

# Set up a user to run Kafka
RUN groupadd kafka && \
  useradd -d /kafka -g kafka -s /bin/false kafka && \
  chown -R kafka:kafka /kafka /data /logs && \
  chmod 755 /kafka/start.sh
USER kafka
ENV PATH /kafka/bin:$PATH
WORKDIR /kafka

# broker, jmx
EXPOSE 9092 ${JMX_PORT}
VOLUME [ "/data", "/logs" ]

