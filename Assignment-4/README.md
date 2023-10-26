# Assignment 4, CMSC724, Spring 2022, Due Friday April 8, 2022

*The assignment is to be done by yourself.*

This assignment focuses on understanding the ANALYZE capabilities provided by PostgreSQL, and on query rewrite stuff.

Like most other database systems, PostgreSQL allows you to analyze query execution plans, and tune the execution. 
The main PostgreSQL commands are EXPLAIN and EXPLAIN ANALYZE. The first one simply prints out 
the plan, but the second one also runs the query and compares the estimated values with 
actual values observed during execution.

An important accompanying command is `VACUUM ANALYZE`; this recalculates all the statistics used by PostgreSQL optimizer.

The assignment here is to answer a few questions using these tools. For the questions, see Gradescope.

Two of the questions use the same database that you used for Assignment 1.

A few of the questions use a larger social network dataset -- the load file is `populate_sn_med.sql`. 
You should load this into a separate database using (`createdb sn_med` followed by `psql -f populate_sn_med.sql`).

A few of the question use a modified TPC-H Benchmark database.
More details on this database are available at: [TPC-H](http://www.tpc.org/tpch)

To load the database:
- Use `createdb tpch` to create a new database.
- Run: `psql -f tpch/tpch-load.sql tpch` from the `Assignment-4` directory (if you run from somewhere else, you may need to modify the paths in `tpch-load.sql` file.

![TPC-H Schema](tpch-schema.png)
