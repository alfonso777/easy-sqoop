## Overview
It's a Sqoop framework to ingest data (big data) from relational databases in a easy way and hiding many configurations and details. 

### Quick Start
The configurations of connection, security (via _Hadoop Credential_), source databases and tables and so on are defined in a file with properties extension.
The `env` argument is the configuration name file (extension is ignored). The following are descriptions and examples of parameters:
```
One or more variables are undefined. Required options: --env, --sourcetable.
Optional options: --mode, --splitby, --hivetable, --format, --extraoptions.
Remarks:
  - Valid mode values: FULL or PARTIIONED. FULL is a default value.
  - Supported formats: parquetfile, textfile, sequencefile and avrodatafile.
  - The --partitionkey and --partitionvalue options are required when the mode is PARTIIONED.
  - The default format is parquet
  - The --extraoptions option is useful to pass sqoop commands.
    Example: --extraoptions "--map-column-java column1=String,column2=Long --where \"id<123456\" "
Examples:
sh sqoop-import.sh --env cerner --sourcetable table1
sh sqoop-import.sh --env dwhiae --sourcetable tableabc --hivetable tableabc1
sh sqoop-import.sh --env cerner --sourcetable tableabc --splitby column1 --extraoptions "--map-column-java column1=String,column2=Long"
sh sqoop-import.sh --env cerner --mode PARTITIONED --sourcetable table1 --partitionkey dataingestion --partitionvalue 2019-06-07
```
