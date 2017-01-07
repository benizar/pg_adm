#
# Makefile for the extension
# 

EXTENSION      = $(shell grep -m 1 '"name":' META.json | \
               sed -e 's/[[:space:]]*"name":[[:space:]]*"\([^"]*\)",/\1/')
EXTVERSION     = $(shell grep -m 1 '[[:space:]]\{8\}"version":' META.json | \
               sed -e 's/[[:space:]]*"version":[[:space:]]*"\([^"]*\)",\{0,1\}/\1/')


DOCS           = $(wildcard doc/*.md)
TESTS          = $(wildcard test/sql/*.sql)
REGRESS        = $(patsubst test/sql/%.sql,%,$(TESTS))
REGRESS_OPTS   = --inputdir=test --load-language=plpgsql
PG_CONFIG      = pg_config
PG91           = $(shell $(PG_CONFIG) --version | grep -qE " 8\.| 9\.0" && echo no || echo yes)


ifeq ($(PG91),yes)

all: $(EXTENSION)--$(EXTVERSION).sql

$(EXTENSION)--$(EXTVERSION).sql: sql/bloat/*.sql \
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
#TODO:test useless columns 
#sql/columns/*.sql \

	         cat $^ > $@

DATA           = $(wildcard updates/*--*.sql) $(EXTENSION)--$(EXTVERSION).sql
EXTRA_CLEAN    = $(EXTENSION)--$(EXTVERSION).sql

else
$(error Minimum version of PostgreSQL required is 9.1)
endif

PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
