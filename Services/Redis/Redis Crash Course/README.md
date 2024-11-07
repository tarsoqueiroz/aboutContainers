# Redis Crash Course

The What, Why and How to use Redis as your primary database by TechWorld with Nana

> `https://www.youtube.com/watch?v=OqCK95AS-YE`

## 0:00 - Introduction and Overview

In this Redis crash course, we're going to talk about Redis and how Redis can be used as a primary database for complex applications that need to store data in multiple formats.

1. First we will see what Redis is and its usages as well as why it is suitable for modern complex microservice applications.
2. We will talk about how Redis supports storing multiple data formats for different purposes through its modules.
3. Next we will see how Redis as an in-memory database can persist data and recover from data loss.
4. We'll also talk about how Redis optimizes memory storage cost using Redis on Flash.
5. Then we will see very interesting use cases of scaling Redis and replicating it across multiple geographic regions and
6. Finally since one of the most popular platforms for running microservices is Kubernetes and since running stateful pplications in Kubernetes is a bit challenging, we will see how you can easily run Redis on Kubernetes.

## 1:13 - What is Redis?

- REmote DIctionary Server
- In-memory database
- Used as Cache to improve performance
- Fully-fledged primary database
- Persist multiple data formats

## 1:42 - Use Cases & Benefits of a Multi-Model DB

- Microservice app
- Run and maintain just 1 DB
- Simpler
- Reduced Latency (Faster)

## 4:58 - How Redis works? Redis Modules

Support multiple data types on key-value store:

- Strings
- Sets
- Bitmaps
- Sorted Sets
- Bit Field
- Geospatial
- Hashes
- Hyperlog
- Lists
- Streams

Extend with Redis Modules.

Out-of-the-box Cache.

In-memory DataBase.

## 6:49 - Data Persistence & Durability with Redis (Snapshotting and AOF)

Replicating Redis.

Persist mechanisms:

- Snapshotting (RDB)
- Append Only File (AOF)
- Unify RDB + AOF

Separate Persistent Storage from Data Service.

## 11:14 - Saving Costs with Redis on Flash

- Durability and recovery
- Great performance and speed
- Standard
  - Everything in RAM
- Redis on Flash
  - Hot values (or frequently used) values are stored in RAM
  - Warm values (or infrequently used) values are stored on SSD

## 12:34 - How to scale a Redis database?

1. Clustering
2. Sharding

## 16:41 - High Availability across multiple regions (Active-Active Geo Distribution)

Users geographically distributed:

- We want to distribute our data service close to the users.

Disaster Recovery:

- Switch over to another data center, when one goes down.

Strategy:

1. Replicas of Redis Cluster in different regions
1. Data should be replicated to all clusters
1. Each cluster should be able to accept reads/writes

Active-Active Geo Distribution:

- Each Redis cluster acts as local instances in each region
- Syncers contact remote masters for replication
- Sync is a compressed and secured stream
  - Lower latency
  - Disater recovery
- Redis cluster can update data still independently
- Sync data when connections is re-established

**CRDT** - Conflict-Free Replicated Data Types: Against conflict on multiples set to same key.

## 20:23 - Running Redis in Kubernetes

Operator.

## That's all

...folks!!!
