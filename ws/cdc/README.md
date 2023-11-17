## Change data capture workflow from ybdb to postgres

Run the following from `connector-config` shell

### create cdc stream at the source

```
yb-admin -master_addresses 127.0.0.1:7100 create_change_data_stream ysql.yugabyte
```

### create ybdb source connector

```
export STREAM_ID=$(yb-admin -master_addresses 127.0.0.1:7100 list_change_data_streams | grep stream_id | awk '{print $2}' | sed s/\"//g)

curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d '{
  "name": "ybsource",
  "config": {
    "tasks.max": "1",
    "connector.class": "io.debezium.connector.yugabytedb.YugabyteDBConnector",
    "topics_regex": "'${TOPIC_PREFIX}'.'${SCHEMA}'.(.*)",
    "database.hostname": "'$HOST'",
    "database.master.addresses": "'$MASTERS'",
    "database.port": "'${YSQL_SOCK}'",
    "database.user": "'${SRC_USER}'",
    "database.password": "'${SRC_SECRET}'",
    "database.dbname": "'${SRC_DB_OBJECT}'",
    "database.server.name": "'${TOPIC_PREFIX}'",
    "snapshot.mode": "initial",
    "database.streamid": "'${STREAM_ID}'",
    "table.include.list": "'${SCHEMA}'.*",
    "new.table.poll.interval.ms":"5000",
    "auto.add.new.tables": "true",
    "errors.retry.timeout": "2000",
    "errors.tolerance": "all",
    "errors.log.enable": "true",
    "errors.log.include.messages": "true"
  }
}'
```

### create postgres sink connector
```
curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d '{
  "name": "pgsink",
  "config": {
      "connector.class": "io.confluent.connect.jdbc.JdbcSinkConnector",
      "tasks.max": "1",
      "topics.regex": "'${TOPIC_PREFIX}'.'${SCHEMA}'.(.*)",
      "dialect.name": "PostgreSqlDatabaseDialect",
      "connection.url": "jdbc:postgresql://localhost:5432/postgres?user='${TAR_USER}'&password='${TAR_SECRET}'",
      "auto.create": "true",
      "auto.evolve": "true",
      "insert.mode": "upsert",
      "pk.mode": "record_key",
      "delete.enabled": "true",
      "transforms": "dropPrefix, unwrap",
      "transforms.dropPrefix.type": "org.apache.kafka.connect.transforms.RegexRouter",
      "transforms.dropPrefix.regex": "'${TOPIC_PREFIX}'.'${SCHEMA}'.(.*)",
      "transforms.dropPrefix.replacement": "'\$1'",
      "transforms.unwrap.type": "io.debezium.connector.yugabytedb.transforms.YBExtractNewRecordState",
      "transforms.unwrap.drop.tombstones": "false",
      "errors.retry.timeout": "2000",
      "errors.log.enable": "true",
      "errors.log.include.messages": "true"
   }
}'
```