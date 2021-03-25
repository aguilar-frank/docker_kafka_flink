#!/bin/sh

# Optional ENV variables:
# * BROKER_ID =  This must be set to a unique integer for each broker
# * ZOOKEEPER_CONNECT =  Specifies the ZooKeeper connection string in the form hostname:port where host and port are the host and port of a ZooKeeper server
# * ADVERTISED_LISTENERS = list of listeners with their host/IP and port. This is the metadata that’s passed back to client
# * LISTENERS =  Name of listener used for communication between controller and brokers.
# * LISTENER_SECURITY_PROTOCOL_MAP = security protocol to connect to the broker.
# * ADVERTISED_HOST: the external ip for the container, e.g. `docker-machine ip \`docker-machine active\``
# * ADVERTISED_PORT: the external port for Kafka, e.g. 32000
# * LOG_RETENTION_HOURS: the minimum age of a log file in hours to be eligible for deletion (default is 168, for 1 week)
# * LOG_RETENTION_BYTES: configure the size at which segments are pruned from the log, (default is 1073741824, for 1GB)
# * NUM_PARTITIONS: configure the default number of log partitions per topic
# * LOG_DIRS = The directory where the logs is save




############################# BROKER ID #############################

 # BROKER_ID

if [ ! -z "$BROKER_ID" ]; then
    echo "broker id: $BROKER_ID"
    sed -r -i "s/(broker.id)=(.*)/\1=$BROKER_ID/g" $KAFKA_HOME/config/server.properties
else 
    echo "ERROR: missing mandatory config: BROKER_ID"
    exit 1
fi


############################# Socket Server Settings #############################

 # ADVERTISED_HOST

if [ ! -z "$ADVERTISED_HOST" ]; then
    echo "advertised host: $ADVERTISED_HOST"
    if grep -q "^advertised.host.name" $KAFKA_HOME/config/server.properties; then
        sed -r -i "s/#(advertised.host.name)=(.*)/\1=$ADVERTISED_HOST/g" $KAFKA_HOME/config/server.properties
    else
        echo "advertised.host.name=$ADVERTISED_HOST" >> $KAFKA_HOME/config/server.properties
    fi
fi


 # ADVERTISED_PORT
 
if [ ! -z "$ADVERTISED_PORT" ]; then
    echo "advertised port: $ADVERTISED_PORT"
    if grep -q "^advertised.port" $KAFKA_HOME/config/server.properties; then
        sed -r -i "s/#(advertised.port)=(.*)/\1=$ADVERTISED_PORT/g" $KAFKA_HOME/config/server.properties
        
    else
        echo "advertised.port=$ADVERTISED_PORT" >> $KAFKA_HOME/config/server.properties

    fi
fi



#  LISTENERS = INTERNAL://:9092,EXTERNAL://:PORT

if [ ! -z "$ADVERTISED_PORT"  ]; then
    echo "listeners: $LISTENERS"
    if grep -q "^listeners" $KAFKA_HOME/config/server.properties; then
        sed -r -i "s/#(listeners)=(.*)/\1=INTERNAL://$ADVERTISED_HOST:9092,EXTERNAL://0.0.0.0:$ADVERTISED_PORT/g" $KAFKA_HOME/config/server.properties
    else
         echo "listeners=INTERNAL://$ADVERTISED_HOST:9092,EXTERNAL://0.0.0.0:$ADVERTISED_PORT" >> $KAFKA_HOME/config/server.properties
	
    fi
fi



 # ADVERTISED_LISTENERS = INTERNAL://<HOST>:9092,EXTERNAL://localhost:<PORT>

if [ ! -z "$ADVERTISED_PORT" ]; then
    echo "advertised listeners: $ADVERTISED_PORT"
    if grep -q "^advertised.listeners" $KAFKA_HOME/config/server.properties; then
        sed -r -i "s/#(advertised.listeners)=(.*)/\1=INTERNAL://$ADVERTISED_HOST:9092,EXTERNAL://localhost$ADVERTISED_PORT/g" $KAFKA_HOME/config/server.properties
    else
        echo "advertised.listeners=INTERNAL://$ADVERTISED_HOST:9092,EXTERNAL://localhost:$ADVERTISED_PORT" >> $KAFKA_HOME/config/server.properties

    fi
fi



 # LISTENER_SECURITY_PROTOCOL_MAP

#SECURITY_PROTOCOL_MAP = PLAINTEXT:PLAINTEXT,SSL:SSL,SASL_PLAINTEXT:SASL_PLAINTEXT,SASL_SSL:SASL_SSL

if [ ! -z "$LISTENER_SECURITY_PROTOCOL_MAP"  ]; then
    echo "listener security protocol map: $LISTENER_SECURITY_PROTOCOL_MAP"
    if grep -q "^listener.security.protocol.map" $KAFKA_HOME/config/server.properties; then
        sed -r -i "s/#(listener.security.protocol.map)=(.*)/\1=$LISTENER_SECURITY_PROTOCOL_MAP/g" $KAFKA_HOME/config/server.properties
    else
        echo "listener.security.protocol.map=$LISTENER_SECURITY_PROTOCOL_MAP" >> $KAFKA_HOME/config/server.properties
    fi
fi


 # INTER_BROKER_LISTENER_NAME: INTERNAL 
 
 if [ ! -z "$INTER_BROKER_LISTENER_NAME"  ]; then
    echo "inter broker listener name: $INTER_BROKER_LISTENER_NAME"
    if grep -q "^inter.broker.listener.name" $KAFKA_HOME/config/server.properties; then
        sed -r -i "s/#(inter.broker.listener.name)=(.*)/\1=$INTER_BROKER_LISTENER_NAME/g" $KAFKA_HOME/config/server.properties
    else
        echo "inter.broker.listener.name=$INTER_BROKER_LISTENER_NAME" >> $KAFKA_HOME/config/server.properties
    fi
 fi


############################# Zookeeper #############################

if [ ! -z "$ZOOKEEPER_CONNECT" ]; then
    echo "zookepeer connect: $ZOOKEEPER_CONNECT"
    sed -r -i "s/(zookeeper.connect)=(.*)/\1=$ZOOKEEPER_CONNECT/g" $KAFKA_HOME/config/server.properties
else 
    echo "ERROR: missing mandatory config: ZOOKEEPER_CONNECT"
    exit 1
fi


############################# Log Basics #############################

# directories under which to store log files
# Set new directory for logs
if [ ! -z "$LOG_DIRS" ]; then
    echo "log dirs: $LOG_DIRS"
    mkdir $LOG_DIRS
    sed -r -i "s/(log.dirs)=(.*)/\1=$LOG_DIRS/g" $KAFKA_HOME/config/server.properties
fi


# Allow specification of log retention policies
if [ ! -z "$LOG_RETENTION_HOURS" ]; then
    echo "log retention hours: $LOG_RETENTION_HOURS"
    sed -r -i "s/(log.retention.hours)=(.*)/\1=$LOG_RETENTION_HOURS/g" $KAFKA_HOME/config/server.properties
fi

if [ ! -z "$LOG_RETENTION_BYTES" ]; then
    echo "log retention bytes: $LOG_RETENTION_BYTES"
    sed -r -i "s/#(log.retention.bytes)=(.*)/\1=$LOG_RETENTION_BYTES/g" $KAFKA_HOME/config/server.properties
fi


# Configure the default number of log partitions per topic
if [ ! -z "$NUM_PARTITIONS" ]; then
    echo "default number of partition: $NUM_PARTITIONS"
    sed -r -i "s/(num.partitions)=(.*)/\1=$NUM_PARTITIONS/g" $KAFKA_HOME/config/server.properties
fi


# Enable/disable auto creation of topics
if [ ! -z "$AUTO_CREATE_TOPICS" ]; then
    echo "auto.create.topics.enable: $AUTO_CREATE_TOPICS"
    echo "auto.create.topics.enable=$AUTO_CREATE_TOPICS" >> $KAFKA_HOME/config/server.properties
fi




# Run Kafka
$KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/server.properties
