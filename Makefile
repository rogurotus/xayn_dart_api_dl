###############################
# Common defaults/definitions #
###############################

comma := ,

# Checks two given strings for equality.
eq = $(if $(or $(1),$(2)),$(and $(findstring $(1),$(2)),\
                                $(findstring $(2),$(1))),1)


######################
# Project parameters #
######################

RUST_VER ?= 1.64
RUST_NIGHTLY_VER ?= nightly-2022-10-05


CURRENT_OS ?= $(strip $(or $(os),\
	$(if $(call eq,$(OS),Windows_NT),windows,\
	$(if $(call eq,$(shell uname -s),Darwin),macos,linux))))

LINUX_TARGETS := x86_64-unknown-linux-gnu
MACOS_TARGETS := x86_64-apple-darwin \
                 aarch64-apple-darwin
WINDOWS_TARGETS := x86_64-pc-windows-msvc




###########
# Aliases #
###########

clean: cargo.clean

docs: cargo.doc

fmt: cargo.fmt

lint: cargo.lint 



##################
# Cargo commands #
##################

# Clean built Rust artifacts.
#
# Usage:
#	make cargo.clean

cargo.clean:
	cargo clean


# Generate documentation for project crates.
#
# Usage:
#	make cargo.doc [open=(yes|no)] [clean=(no|yes)] [dev=(no|yes)]

cargo.doc:
ifeq ($(clean),yes)
	@rm -rf target/doc/
endif
	cargo doc --workspace --no-deps \
		$(if $(call eq,$(dev),yes),--document-private-items,) \
		$(if $(call eq,$(open),no),,--open)


# Format Rust sources with rustfmt.
#
# Usage:
#	make cargo.fmt [check=(no|yes)] [dockerized=(no|yes)]

cargo.fmt:
ifeq ($(dockerized),yes)
	docker run --rm --network=host -v "$(PWD)":/app -w /app \
		-u $(shell id -u):$(shell id -g) \
		-v "$(HOME)/.cargo/registry":/usr/local/cargo/registry \
		ghcr.io/instrumentisto/rust:$(RUST_NIGHTLY_VER) \
			make cargo.fmt check=$(check) dockerized=no
else
	cargo +nightly fmt --all $(if $(call eq,$(check),yes),-- --check,)
endif


# Lint Rust sources with Clippy.
#
# Usage:
#	make cargo.lint [dockerized=(no|yes)]

cargo.lint:
ifeq ($(dockerized),yes)
	docker run --rm --network=host -v "$(PWD)":/app -w /app \
		-u $(shell id -u):$(shell id -g) \
		-v "$(HOME)/.cargo/registry":/usr/local/cargo/registry \
		ghcr.io/instrumentisto/rust:$(RUST_VER) \
			make cargo.lint dockerized=no
else
	cargo clippy --workspace -- -D warnings
endif


# Run Rust tests of project.
#
# Usage:
#	make cargo.test

cargo.test:
	cargo test --workspace


##########################
# Documentation commands #
##########################

docs.rust: cargo.doc

