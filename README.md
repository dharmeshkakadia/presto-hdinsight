# presto-hdinsight
Run Presto on Azure HDInsight

# TL;DR 
Run a custom [Script Action](https://docs.microsoft.com/en-us/azure/hdinsight/hdinsight-hadoop-customize-cluster-linux) on existing or new HDInsight _hadoop_ cluster (version 3.5 or above) with following as your bash script URI and run it on "HEAD" and "WORKER":
```
https://raw.githubusercontent.com/hdinsight/presto-hdinsight/master/installpresto.sh
```

Now you can SSH to your cluster and start using presto:
```
presto --schema default
```
This will connect to hive metastore via [hive connector](https://prestodb.io/docs/current/connector/hive.html). On a N worker node cluster, you will have N-2 presto worker nodes and 1 coordinator node. The setup also configures [TPCH connector](https://prestodb.io/docs/current/connector/tpch.html), so you can run TPCH queries directly.

If you want to configure additional connectors, you can pass the catalog configurations as a parameter to the custom action script. The syntax is `‘connector1’ : [‘key1=value1’, ‘key2=value2’..], ‘connector2’ : [‘key1=value1’, ‘key2=value2’..]` as described in [presto-yarn](https://prestodb.io/presto-yarn/installation-yarn-configuration-options.html). So, the following string as a parameter will add sqlserver and DocDB connectors with its configurations (notice the "" around the full string):

> " 'cosmosdb': ['connector.name=mongodb','mongodb.seeds=test.documents.azure.com:10255','mongodb.credentials=testuser:secretpassword@prestocollection','mongodb.ssl.enabled=true'],'sqlserver': ['connector.name=sqlserver','connection-url=jdbc:sqlserver://testsqlserver.database.windows.net:1433;database=testdb;user=testuser@testserver;password=secretpassword;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;', 'connection-user=testuser','connection-password=secretpassword'] "

# Airpal
To optionally install [airpal](https://github.com/airbnb/airpal), 

1. SSH to the cluster and run the following command to find out the address of the presto server
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

2. Click [here](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fhdinsight%2Fpresto-hdinsight%2Fmaster%2Fairpal-deploy.json) the below link to add an edge node to the cluster where airpal is going to be installed. Provide Clustername, EdgeNodeSize and PrestoAddress (noted above). 

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
Follow the instructions on [HDInsight-TPCDS](https://github.com/hdinsight/tpcds-datagen-as-hive-query/blob/master/README.md#how-do-i-run-the-queries-with-presto) repo.
    
