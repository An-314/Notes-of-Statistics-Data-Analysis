CXX ?= g++
ROOT_CONFIG ?= root-config
CPPFLAGS += $(shell $(ROOT_CONFIG) --cflags)
CXXFLAGS ?= -O2 -g -Wall -Wextra -Wpedantic
LDLIBS += $(shell $(ROOT_CONFIG) --libs)
OUTPUT ?= ../pic/6
TOYS ?= 2000000
DATA ?= data/ex4_4.csv
TARGETS := bin/ex4_3 bin/ex4_4

.PHONY: all run macros clean
all: $(TARGETS)

bin/ex4_3: src/main43.cc macros/ex4_3.C include/HW6Common.h | bin
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) src/main43.cc macros/ex4_3.C $(LDFLAGS) $(LDLIBS) -o $@

bin/ex4_4: src/main44.cc macros/ex4_4.C include/HW6Common.h | bin
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) src/main44.cc macros/ex4_4.C $(LDFLAGS) $(LDLIBS) -o $@

bin:
	mkdir -p $@

run: all
	./bin/ex4_3 "$(OUTPUT)"
	./bin/ex4_4 "$(OUTPUT)" "$(TOYS)" "$(DATA)"

macros:
	bash run_all.sh "$(OUTPUT)" "$(TOYS)"

clean:
	rm -f $(TARGETS)
