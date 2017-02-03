# presto-hdinsight
Run Presto on Azure HDInsight

# TL;DR 
Run a cutsom [action script](https://docs.microsoft.com/en-us/azure/hdinsight/hdinsight-hadoop-customize-cluster-linux) on existing or new HDInsight _hadoop_ cluster (version 3.5 or above) with following as your bash script URI and run it on "HEAD" and "WORKER":
```
https://raw.githubusercontent.com/dharmeshkakadia/presto-hdinsight/master/installpresto.sh
```

Now you can SSH to your cluster and start using presto:
```
presto --schema default
```
This will connect to hive metastore via [hive connector](https://prestodb.io/docs/current/connector/hive.html). On a N worker node cluster, you will have N-2 presto worker nodes and 1 coordinator node. The setup also configures [TPCH connector](https://prestodb.io/docs/current/connector/tpch.html), so you can runn TPCH queries directly.

You can access the presto UI at [https://\<your-cluster-name\>.localtunnel.me/](https://your-cluster-name.localtunnel.me/)

## FAQ
### Is this Microsoft supported product? 
No.

### Does it support Windows Azure Storage Blolb (WASB)?
Yes.

### Does it support [Azure Data Lake Store (ADLS)](https://azure.microsoft.com/en-us/services/data-lake-store/)?
Not yet.
