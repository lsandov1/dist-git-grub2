#
# Makefile
# Peter Jones, 2018-07-11 02:39
#

define get-config
$(shell git config --local --get "grub2.$(1)")
endef

RHELVER ?= $(call get-config, build.rhel-version)
ifeq ($(RHELVER),)
override RHELVER = 8.0
endif

FEDVER ?= $(call get-config, rebase.fedora-version)
ifeq ($(FEDVER),)
override FEDVER = 29
endif

ARCH ?=
ifneq ($(ARCH),)
override ARCH := $(foreach x,$(ARCH), --arch-override=$(x))
endif

# this is wacky because just using wildcard gets the list from before clean
# happens.
SOURCES ?= $(shell ls *.src.rpm)

all:

push :
	git push

clean :
	@rm -vf *.src.rpm

srpm:
	rhpkg srpm

scratch: srpm
	brew build --scratch ${ARCH} rhel-${RHELVER}-candidate $(SOURCES)

release:
	rhpkg build --target rhel-${RHELVER}-candidate-pesign

rebase:
	./do-rebase --nocommit fedora-${FEDVER} ${REPO}

rpmspec:
	rpmspec -D "_sourcedir $(shell pwd)" -P grub2.spec

rebuild: srpm
	rpmbuild --rebuild $(SOURCES)

local prep mockbuild compile :
	rhpkg $@

.PHONY: all push srpm scratch release rebase rpmspec local prep mockbuild compile clean

# vim:ft=make
