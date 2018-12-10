#######################################################"
################### Run test ##########################"
#######################################################"

echo "Running test..."
mkdir results

client=$(hostname)
echo $client > results/client_info.txt
echo $(hostname -I) >> results/client_info.txt
echo $(curl icanhazip.com) >> results/client_info.txt
echo $(curl -L http://169.254.169.254/opc/v1/instance) > results/metadata.json

cqlsh $(echo $nodes | tr ',' ' ' | awk '{print $1}') -e "show version; select * from system.peers;" > results/dse_info.txt

# create stress.yaml
cat << EOF > stress.yaml
### Schema Specifications ### #
#
# user profile=stress.yaml ops\(insert=1\) n=10m cl=ONE no-warmup -rate threads=50
#   -insert visits=fixed\(100\) -pop seq=1..100k contents=SORTED
#
# ^ will write 100k partitions with 100 rows each in sorted order

# Keyspace Name
keyspace: stress

# The CQL for creating a keyspace (optional if it already exists)
keyspace_definition: |
  CREATE KEYSPACE stress WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 3}  AND durable_writes = true;;

table: uac

# The CQL for creating a table you wish to stress (optional if it already exists)
table_definition: |
  CREATE TABLE stress.uac (
      id text PRIMARY KEY,
      device_id text,
      first_seen timestamp,
      last_seen timestamp,
      most_recent_edna_result text,
      payment_instrument_id text,
      uai_id text
  ) WITH bloom_filter_fp_chance = 0.01
      AND caching = '{"keys":"ALL", "rows_per_partition":"NONE"}'
      AND comment = ''
      AND compaction = {'class': 'org.apache.cassandra.db.compaction.SizeTieredCompactionStrategy'}
      AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
      AND dclocal_read_repair_chance = 0.1
      AND default_time_to_live = 0
      AND gc_grace_seconds = 864000
      AND max_index_interval = 2048
      AND memtable_flush_period_in_ms = 0
      AND min_index_interval = 128
      AND read_repair_chance = 0.0
      AND speculative_retry = '99.0PERCENTILE';

### Column Distribution Specifications ###
columnspec:
  - name: id
    population: uniform(10..20) # 10-20 chars population: uniform(1..10)
  - name: device_id
    population: uniform(10..20)
  - name: first_seen
    size: uniform(20..40)
  - name: last_seen
    population: uniform(20..40)
  - name: most_recent_edna_result
    population: uniform(10..20)
  - name: payment_instrument_id
    population: uniform(10..20)
  - name: uai_id
    population: uniform(10..20)

### Batch Ratio Distribution Specifications ###
insert:
  partitions: fixed(1)
  select: fixed(1)/100 # Inserts will be single row batchtype: UNLOGGED

# A list of queries you wish to run against the schema #
queries:
  query_by_id:
    cql: SELECT first_seen, last_seen, payment_instrument_id FROM uac WHERE id = ? LIMIT 10
    fields: samerow
EOF

# insert 50M rows
cassandra-stress user profile=stress.yaml ops\(insert=10\) \
   n=50m cl=ONE no-warmup -mode native cql3 protocolVersion=3 -errors ignore \
   -rate threads=350 -pop seq=1..14000000 contents=SORTED -insert visits=fixed\(100\) \
   -node $nodes -log file=load.log \
   hdrfile=load.hdr -graph file=load.html \
   title=load

# brief warmuo
cassandra-stress user profile=stress.yaml ops\(insert=15,query_by_id=5\) \
   duration=5m cl=QUORUM no-warmup -mode native cql3 protocolVersion=3 -errors ignore \
   -rate threads=350 -pop seq=1..14000000 contents=SORTED -insert visits=fixed\(100\) \
   -node $nodes -log file=warm.log \
   hdrfile=warm.hdr -graph file=warm.html \
   title=warm

# actual test
cassandra-stress user profile=stress.yaml ops\(insert=15,query_by_id=5\) \
  duration=30m cl=QUORUM no-warmup -mode native cql3 protocolVersion=3 -errors ignore \
  -rate threads=350 -pop seq=1..14000000 contents=SORTED -insert visits=fixed\(100\) \
  -node $nodes -log file=test.log \
  hdrfile=test.hdr -graph file=test.html \
  title=test

cp stress.yaml ./results/
mv *.log *.html *.hdr ./results/

echo "Uploading results..."
for file in $(ls results); do
  curl -X PUT --data-binary "@./results/$file" "$par$test_name/$client/$file"
done;

echo "Done"
