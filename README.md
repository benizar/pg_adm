# pg_adm

- [Introduction](#introduction)
  - [Postgres xtensions](#postgres-extensions)
  - [Contributing](#contributing)
- [Getting started](#getting-started)
  - [Using Dockers](#using-dockers)
  - [Install the extension](#install-the-extension)
  - [Dependencies](#dependencies)
- [Acknowledgements](#acknowledgements)
- [TODOs](#todos)


# Introduction

A PostgreSQL extension compiling different administration tools.


## Postgres Extensions

PostgreSQL is an object-relational database management system (ORDBMS) with an emphasis on extensibility and standards-compliance [[source](https://en.wikipedia.org/wiki/PostgreSQL)].

Apart from the PostgreSQL official documentation you can check the [PostgreSQL Extension Network](http://pgxn.org/) for additional information about extensions.

## Contributing

- Send a pull request with your awesome features and bug fixes
- Help users resolve their [issues](../../issues?q=is%3Aopen+is%3Aissue).


# Getting started

## Using dockers

Automated builds of the image are available on [Dockerhub](https://hub.docker.com/r/benizar/pg_adm) and is the recommended method of installation.

```bash
docker pull benizar/pg_adm
```

Alternatively you can build the image yourself.

```bash
docker build -t benizar/pg_adm github.com/benizar/pg_adm
```

Start this image using:

```bash
docker run --name pg_adm -itd --restart always \
  --publish 5432:5432
  --volume /srv/docker/postgresql:/var/lib/postgresql \
  benizar/pg_adm
```

*Alternatively, you can use the sample [docker-compose.yml](docker-compose.yml) file to start the container using [Docker Compose](https://docs.docker.com/compose/)*


For debugging and maintenance purposes you may want access the containers shell. If you are using Docker version `1.3.0` or higher you can access a running containers shell by starting `bash` using `docker exec`:

```bash
docker exec -it pg_adm bash
```


## Install the extension

To build pg_adm:

    make
    make install
    make installcheck

If you encounter an error such as:

    "Makefile", line 8: Need an operator

You need to use GNU make, which may well be installed on your system as
`gmake`:

    gmake
    gmake install
    gmake installcheck

If you encounter an error such as:

    make: pg_config: Command not found

Be sure that you have `pg_config` installed and in your path. If you used a
package management system such as RPM to install PostgreSQL, be sure that the
`-devel` package is also installed. If necessary tell the build process where
to find it:

    env PG_CONFIG=/path/to/pg_config make && make installcheck && make install

If you encounter an error such as:

    ERROR:  must be owner of database regression

You need to run the test suite using a super user, such as the default "postgres" super user:

    make installcheck PGUSER=postgres

If that doesn't work, for testing purposes you also can do:

    sudo -u postgres createuser -s $USER

Once the extension is installed, you can add it to a database. If you're running PostgreSQL 9.1.0 or greater, it's a simple as connecting to a database as a super user and running:

    CREATE EXTENSION pg_adm SCHEMA adm;

pg_adm will be installed in its own schema, with all its objects. If you want to install semver and all of its supporting objects into a specific schema, use the `PGOPTIONS` environment variable to specify the schema, like so:

    PGOPTIONS=--search_path=extensions psql -d mydb -f semver.sql

## Dependencies

The `pg_adm` extension depends on other postgres extensions. See the `pg_adm.control` file.



# Acknowledgements

Most of the provided tools are available from different projects:

- [postgresql wiki](https://wiki.postgresql.org)
- [pgx_scripts](https://github.com/pgexperts/pgx_scripts)
- [postgres_useful](https://github.com/eddienko/postgres/blob/master/utils/postgres_useful.sql)
- [pgpermisions](https://github.com/Gibheer/pgpermissions)


# TODOs:

Check the following resources: 

- [pg_cheat_funcs](https://github.com/MasaoFujii/pg_cheat_funcs) for PGLZ data compresion.



