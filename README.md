## Brief Setup Instructions 

There are more detailed setup instructions in `Assignment-0` and the other directories. The 424 Detailed Slides (http://www.cs.umd.edu/~amol/cmsc724-spring2022/424-All-Slides.pdf) go through SQL and MongoDB syntax both in sufficient detail if you need (we won't cover the entire syntax in class).

1. Clone the GitHub Class Repository to get started (there are more detailed instructions in `Assignment-0` README):
`git clone https://github.com/umddb/cmsc424-fall2021.git`

1. You can load the systems directly on your machines (easier on Linux or Mac), but to make things easier, we have provided a Dockerfile to create a virtual image with
PostgreSQL, MongoDB, and Apache Spark pre-loaded.
    - Install Docker Desktop: https://www.docker.com/products/docker-desktop
    - In the top-level directory, run: `docker build -t "cmsc724" .`
    - Confirm that the image was created successfully with `docker images`
    - Run the docker image: `docker run --rm -ti -p 8888:8888 -p 8881:8881 -p 5432:5432 -v /Users/amol/git/cmsc724-spring2022:/data cmsc724:latest`. Make sure to replace "/Users/amol/..." with the correct path for you. You may also have to fiddle with the port mappings if you already have things running on port 8888 or 5432.
    - The above commands mounts the local directory into `/data` on the virtual machine.
    - Assuming it ran successfully, you should be logged in as `root` in the docker container, and you should see the shell.
    - NOTE: you will be logged in as `root`.
    - You need to start PostgreSQL Server: /etc/init.d/postgresql start
    - At this point, you should be able to use psql: `psql socialnewtork`
    - Start Jupyter: `jupyter-notebook --port=8888 --allow-root --no-browser --ip=0.0.0.0`
    - On your host machine, you should be able to visit the URL directly (we did the port mapping above when running Docker).
    - As soon as you exit the Docker container, the machine will shut down -- so only changes you have made in the /data directory will persist.

1. For MongoDB, following needs to be done after loading (I haven't been able to figure out how to do these in Dockerfile itself).
    - Start the MongoDB server: `systemctl start mongod.service`
    - Load customers (run from `/data`): `mongoimport --db "analytics" --collection "customers" /data/Assignment-2/sample_analytics/customers.json`
    - Load accounts: `mongoimport --db "analytics" --collection "accounts" /data/Assignment-2/sample_analytics/accounts.json`
    - Load transactions: `mongoimport --db "analytics" --collection "transactions" /data/Assignment-2/sample_analytics/transactions.json`

1. For Spark, see the instructions in `Assignment-3` README file for setup.

1. *If you are having trouble installing Docker or somewhere in the steps above, you can also just install the software directly by going through the commands listed in
the Dockerfile*
