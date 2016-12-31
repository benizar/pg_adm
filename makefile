
#
# Makefile for pg_adm
# 

EXTENSION = pg_adm
EXTVERSION = $(shell grep default_version $(EXTENSION).control | sed -e "s/default_version[[:space:]]*=[[:space:]]*'\([^']*\)'/\1/")

PG_CONFIG = pg_config
PG95 = $(shell $(PG_CONFIG) --version | egrep " 8\.| 9\.0| 9\.1| 9\.2| 9\.3| 9\.4" > /dev/null && echo no || echo yes)

ifeq ($(PG95),yes)
DOCS = $(wildcard doc/*.md)

#TODO:test columns useless
#sql/columns/*.sql \

all: $(EXTENSION)--$(EXTVERSION).sql

$(EXTENSION)--$(EXTVERSION).sql: sql/schemas.sql \
\
sql/bloat/*.sql \
sql/buffers/*.sql \
sql/clone_objects/*.sql \
sql/dependency_display/*.sql \
sql/disk_usage/*.sql \
sql/explain/*.sql \
sql/extensions/*.sql \
sql/functions/*.sql \
sql/grants/*.sql \
sql/indexes/*.sql \
sql/locking/*.sql \
sql/normalization/*.sql \
sql/pks/*.sql

	cat $^ > $@

DATA = $(wildcard updates/*--*.sql) $(EXTENSION)--$(EXTVERSION).sql
EXTRA_CLEAN = $(EXTENSION)--$(EXTVERSION).sql

else
$(error Minimum version of PostgreSQL required is 9.5.0)
endif

PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)


