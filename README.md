# pg_adm

A PostgreSQL extension compiling different administration tools.


## Docker Compose

TODO: Build a compose for development and simple testing.

## Dockerfile

TODO: Build a dockerfile for development and simple testing.

## Documentation

TODO: Build doc/readme.md from all readme.md in this repo and object comments.


## Installation

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

The `pg_adm` extension depends on other postgres extensions. See de `pg_adm.control` file has no dependencies other than PostgreSQL and PL/pgSQL.


## Acknowledgements

Most of the provided tools are available from different projects:

- [postgresql wiki](https://wiki.postgresql.org)
- [pgx_scripts](https://github.com/pgexperts/pgx_scripts)
- [postgres_useful](https://github.com/eddienko/postgres/blob/master/utils/postgres_useful.sql)
- [pgpermisions](https://github.com/Gibheer/pgpermissions)



## TODO:

Check the following resources: 

- [pg_cheat_funcs](https://github.com/MasaoFujii/pg_cheat_funcs) for PGLZ data compresion.



