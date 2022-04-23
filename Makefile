.PHONY: build test lint-check lint install doc release clean repo-setup

ifeq ($(CONFIG),)
CONFIG:=Debug
endif

JOBS:=4
BUILD_DIR:=build/$(CONFIG)
INSTALL_DIR:=install/$(CONFIG)
CMAKE_OPTS:=-S. -B$(BUILD_DIR) \
	-DCMAKE_INSTALL_PREFIX=$(INSTALL_DIR) \
	-DCMAKE_BUILD_TYPE=$(CONFIG) \
	-DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
	-DENABLE_TEST_COVERAGE=1 \
	-DCMAKE_TOOLCHAIN_FILE=.local/vcpkg/scripts/buildsystems/vcpkg.cmake \
	-DCMAKE_CXX_STANDARD=20 \
	-DCMAKE_C_STANDARD=11

ifeq ($(CONFIG),Debug)
CXXFLAGS:=-fsanitize=address -fsanitize=undefined -fsanitize=leak -g -O1 -UNDEBUG
CFLAGS:=-fsanitize=address -fsanitize=undefined -fsanitize=leak -g -O1 -UNDEBUG
else
CXXFLAGS:=-DNDEBUG
CFLAGS:=-DNDEBUG
endif

# disable clangd warnings for system header outside header

export VERBOSE=1

.DEFAULT_GOAL=test

repo-setup:
	bash -c "source setup.sh"

$(BUILD_DIR): repo-setup
	env CFLAGS="$(CFLAGS)" CXXFLAGS="$(CXXFLAGS)" cmake $(CMAKE_OPTS)
	rm -f compile_commands.json && ln -sf $(BUILD_DIR)/compile_commands.json compile_commands.json

$(INSTALL_DIR): $(BUILD_DIR)
	source setup.sh && cmake --build $(BUILD_DIR) --target install -- -j $(JOBS)

build: $(BUILD_DIR)
	cmake --build $(BUILD_DIR) -- -j $(JOBS)

test: $(BUILD_DIR) build
	cmake --build $(BUILD_DIR) --target test

install: test
	cmake --build $(BUILD_DIR) --target install -- -j $(JOBS)

release:
	env CONFIG=RelWithDebInfo sh -c "make test && make install"

clean:
	bash -c "source scripts/utils.sh && clean"
