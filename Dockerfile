FROM openjdk:8-jre-slim

ENV KAFKA_HOME=/opt/kafka \ 
    KAFKA_VERSION=2.7.0 \
    SCALA_VERSION=2.13 
ENV PATH $PATH:$KAFKA_HOME/bin

RUN  apt-get update  && \ 
     apt-get install -y wget vim net-tools && \ 
     rm -rf /var/lib/apt/lists/* && \
     wget https://archive.apache.org/dist/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz -O  /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz && \
     tar xfz /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz -C  /opt && \ 
     rm /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz && \
     ln -s /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION} ${KAFKA_HOME} 
COPY  ./*.sh /usr/bin
RUN     chmod a+x /usr/bin/start-kafka.sh  

EXPOSE 9092 

# ENTRYPOINT  ["$KAFKA_HOME/bin/kafka-server-start.sh" "$KAFKA_HOME/config/server.properties" ]
# CMD ["$KAFKA_HOME/bin/kafka-server-start.sh" "$KAFKA_HOME/config/server.properties" ]
CMD ["start-kafka.sh"]
