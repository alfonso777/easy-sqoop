#!/bin/bash

function checking() 
{
  if [[ -z $env || -z $sourcetable ]]; then
    echo 'One or more variables are undefined. Required options: --env, --sourcetable.'
    echo 'Optional options: --mode, --splitby, --hivetable, --format, --extraoptions.'
    echo 'Remarks:'
    echo '  - Valid mode values: FULL '
    echo '  - Supported formats: parquetfile, textfile, sequencefile and avrodatafile.'  
    echo '  - The default format is parquet'
    echo '  - The --extraoptions option is useful to pass sqoop commands.'
    echo '    Example: --extraoptions "--map-column-java column1=String,column2=Long --where \"id<123456\" "'
    echo 'Examples:'
    echo 'sh sqoop-import.sh --env cerner --sourcetable table1'
    echo 'sh sqoop-import.sh --env dwhiae --sourcetable tableabc --hivetable tableabc1'
    echo 'sh sqoop-import.sh --env cerner --sourcetable tableabc --splitby column1 --extraoptions "--map-column-java column1=String,column2=Long"'
    exit 1
  fi

  if [[ $format != "" && $format != "parquetfile" && $format != "textfile" && $format != "sequencefile" && $format != "avrodatafile" ]]; then
    echo "Error: Format $format not supported."
    echo "Supported formats: parquetfile, textfile, sequencefile and avrodatafile."
    exit 1
  fi
}

function print_configuration()
{
  echo "Mode: $MODE "
  echo "JDBC connection: $CONNECTION "
  echo "Table origin: $TABLE_ORIGIN "
  echo "Target database and table: $DB_TARGET.$TARGET_TABLE "
  echo "Split by: $SPLIT_BY_OPTION "
  echo "Format and compress: $FORMAT_COMMAND $COMPRESS_COMMAND "
  echo "Additional Sqoop options: $extraoptions "
}

function full_import()
{
  sqoop import -Dhadoop.security.credential.provider.path=$HADOOP_KEYSTORE \
  --connect $CONNECTION \
  --username $USERNAME \
  --password-alias $CREDENTIAL_ALIAS \
  --table $TABLE_ORIGIN \
  $SPLIT_BY_OPTION \
  --hive-database $DB_TARGET  --hive-table $TARGET_TABLE \
  --hive-overwrite --hive-import --num-mappers $NUM_MAPPERS \
  $FORMAT_COMMAND \
  $COMPRESS_COMMAND \
  $extraoptions \
  --hive-drop-import-delims > sqoop_${sourcetable,,}.out
}

function setup()
{
  CONNECTION=$(get_prop $env 'source.jdbc.url')
  USERNAME=$(get_prop $env 'source.database.username')
  HADOOP_KEYSTORE=$(get_prop $env 'source.database.hadoop.security.keystore')
  CREDENTIAL_ALIAS=$(get_prop $env 'source.database.hadoop.security.credential')

  DB_SOURCE=$(get_prop $env 'source.database.name')
  DB_TARGET=$(get_prop $env 'destiny.database.name')
  
  TABLE_ORIGIN=${sourcetable^^}
  if [ $DB_SOURCE ]; then TABLE_ORIGIN=$DB_SOURCE.$TABLE_ORIGIN; fi
  TARGET_TABLE=${hivetable:-${sourcetable,,}}

  if [ $splitby ]; then SPLIT_BY_OPTION="--split-by $splitby "; else SPLIT_BY_OPTION=""; fi
  
  FORMAT_COMMAND="--as-${format:-parquetfile}"
  if [[ ${format,,} == "parquetfile" || -z ${format} ]]; then
    COMPRESS_COMMAND='--compress --compression-codec org.apache.hadoop.io.compress.SnappyCodec'
  fi

  NUM_MAPPERS=$(get_prop $env 'param.'${sourcetable^^}'.nummap')
  NUM_MAPPERS=${NUM_MAPPERS:-10}

  print_configuration
}

#Loading utilities
source ./utils.sh
#Checking parameters. The default mode is FULL
MODE=${mode:-FULL}
checking

#Parameters setup
setup

#Executing
echo 'Executing full import ...'
full_import
