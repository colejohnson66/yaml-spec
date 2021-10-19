include .common.mk

TESTS ?= $(wildcard test/test-*)

BPAN := .bpan
COMMON := ../yaml-common

TEST_QUICK := \
    test/test-lint-shell.sh \
    test/test-format-markdown.sh \
    test/test-lint-spec.sh \

export MAKE_QUICK :=

export PATH := $(ROOT)/bin:$(PATH)

ifneq (,$(DOCKER))
  export RUN_OR_DOCKER := $(DOCKER)
endif

default:
	@true

quick:
	$(eval override export MAKE_QUICK := true)
	$(eval override export TESTS := $(TEST_QUICK))
	@true

docker-run:
	$(eval override export RUN_OR_DOCKER := force)
	@true

docker-build:
	$(eval override export RUN_OR_DOCKER := force-build)
	@true

verbose:
	$(eval override export RUN_OR_DOCKER_VERBOSE := true)
	@true

files build html site serve publish force diff list-files list-html:
	$(MAKE) -C www $@ QUICK=$(MAKE_QUICK)

format:
	$(MAKE) -C $(SPEC_130) $@

.PHONY: test
test:
	$(MAKE) $(TESTS)
	$(MAKE) clean &>/dev/null

test-noclean: $(TESTS)

edit-spec:
	@$${EDITOR:-vim} $(SPEC_130)/spec.md

edit-spec-dir:
	@$${EDITOR:-vim} $(SPEC_130)

grammar-report:
	@grammar-report < $(SPEC_130)/spec.md | less -FReX

grammar-report-quiet:
	@grammar-report -q < $(SPEC_130)/spec.md | less -FReX

$(TESTS): always
	bash $@

always:

_:
	git worktree prune
	git worktree add $@ $@
	$(MAKE) -C $@ all

docker-push-all: docker-push-jekyll docker-push-marky docker-push-tex

docker-push-jekyll:
	RUN_OR_DOCKER_PUSH=true jekyll-runner

docker-push-marky:
	RUN_OR_DOCKER_PUSH=true markydown-to-kramdown

docker-push-tex:
	RUN_OR_DOCKER_PUSH=true tex-to-img

common:
	cp $(COMMON)/bpan/run-or-docker.bash $(BPAN)/

clean:
	@git worktree prune
	$(MAKE) --no-print-directory -C $(SPEC_122) $@ &>/dev/null
	$(MAKE) --no-print-directory -C $(SPEC_123) $@ &>/dev/null
	$(MAKE) --no-print-directory -C $(SPEC_130) $@ &>/dev/null
	$(MAKE) --no-print-directory -C www $@ &>/dev/null

c: clean
	@echo
	git status --ignored
