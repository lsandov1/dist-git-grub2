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

all:

push :
	git push

scratch:
	rhpkg build --scratch --target rhel-${RHELVER}-candidate

release:
	rhpkg build --target rhel-${RHELVER}-candidate-pesign

rebase:
	./do-rebase --nocommit fedora-${FEDVER} ${REPO}

rpmspec:
	rpmspec -D "_sourcedir $(shell pwd)" -P grub2.spec

# vim:ft=make
