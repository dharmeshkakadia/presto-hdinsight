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
This will connect to hive metastore via [hive connector](https://prestodb.io/docs/current/connector/hive.html). On a N worker node cluster, you will have N-2 presto worker nodes and 1 coordinator node. The setup also configures [TPCH connector](https://prestodb.io/docs/current/connector/tpch.html), so you can run TPCH queries directly.

# Airpal
To optinally install [airpal](https://github.com/airbnb/airpal), 

1. SSH to the cluster and run the following command to know address of the presto server
    ```
    sudo slider registry  --name presto1 --getexp presto
    ```
    You will see output like following, note the IP:Port.
    ```
    {
      "coordinator_address" : [ {
        "value" : "10.0.0.11:9090",
        "level" : "application",
        "updatedTime" : "Sat Feb 25 05:45:14 UTC 2017"
      }
    ```

2. Click [here](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fdharmeshkakadia%2Fpresto-hdinsight%2Fmaster%2Fairpal-deploy.json) the below link to add an edge node to the cluster where airpal is going to be installed. Provide Clustername, EdgeNodeSize and PrestoAddress (noted above). 

To access the airpal, go to azure portal, your cluster and navigate to Applications and click on portal. You have to login with cluster login credentials.

## FAQ
### Is this Microsoft supported product? 
No.

### Does it work with Windows Azure Storage Blob (WASB)?
Yes.

### Does it work with [Azure Data Lake Store (ADLS)](https://azure.microsoft.com/en-us/services/data-lake-store/)?
Not yet.

### How do I customize presto installation?
If you want to customize presto (change the memory settings, change connectors etc.), 

1. Create a presto cluster without customization following the steps above.

2. SSH to the cluster and specify your customizations. The configuration file is located at ``/var/lib/presto/presto-hdinsight-master/appConfig-default.json`` 

3. Stop and destroy the current running instance of presto.
    ```
    sudo slider stop presto1 --force
    sudo slider destroy presto1 --force
    ```

4. Start a new instance of presto with the customizations.
    ```
    sudo slider create presto1 --template /var/lib/presto/presto-hdinsight-master/appConfig-default.json --resources /var/lib/presto/presto-hdinsight-master/resources-default.json
    ```
    
5. Wait for the new instance to be ready and note presto coordinator address.
    ```
    sudo slider registry --name presto1 --getexp presto
    ```

### How do I run TPCDS on presto?
    Follow https://github.com/dharmeshkakadia/tpcds-datagen-as-hive-query/blob/master/README.md#how-do-i-run-the-queries-with-presto
    
