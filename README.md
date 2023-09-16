# Setup

The repo is forked from https://github.com/vbabak/docker-mysql-master-slave

to launch the replicas, execute:

```
sudo ./build.sh
```

This will create 3 replicas of a master.

# Results

1. Stopping the slave:
```docker stop slave1```
I've tried to test the insert speed, same as the replication outcome - it seems to me it had no visible effect. The replication continues fine, as expected.
2. Deleting the last column: kinda no effect on replication. "kinda" since you actually have different data on slaves, which brings you inconsistencies while reading, although the replication per se works fine.
3. Delete the column in the middle: breaks the replication on a given slave, although I don't see errors from its container. The reason for fail is the broken order of columns - and that differentiates this case from deleting a column from the end.
