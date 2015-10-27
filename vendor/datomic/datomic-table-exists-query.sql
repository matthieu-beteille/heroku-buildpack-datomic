-- Check if datomic table exists
SELECT tablename FROM pg_catalog.pg_tables where tablename = 'xdatomic_kvs';