CXX ?= g++
ROOT_CONFIG ?= root-config
CPPFLAGS += $(shell $(ROOT_CONFIG) --cflags)
CXXFLAGS ?= -O2 -g -Wall -Wextra -Wpedantic
LDLIBS += $(shell $(ROOT_CONFIG) --libs)
OUTPUT ?= ../pic/4

EXERCISES := ex3_1 ex3_2 ex3_3 ex3_4 ex3_5 ex3_6
TARGETS := $(addprefix bin/,$(EXERCISES))

.PHONY: all run macros clean
all: $(TARGETS)

bin/%: macros/%.C src/main.cc include/HW4Common.h | bin
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -DHW4_ENTRY=$* \
		src/main.cc $< $(LDFLAGS) $(LDLIBS) -o $@

bin:
	mkdir -p $@

run: all
	bash run_all.sh "$(OUTPUT)" bin

macros:
	bash run_all.sh "$(OUTPUT)"

clean:
	rm -f $(TARGETS)
