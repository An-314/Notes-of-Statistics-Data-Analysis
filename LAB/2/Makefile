CXX ?= g++
CPPFLAGS += -Iinclude
CXXFLAGS ?= -std=c++17 -O2 -Wall -Wextra -Wpedantic

TARGET := bin/particles
OBJECTS := obj/main.o obj/Particle.o obj/ParticleInfo.o
DEPS := $(OBJECTS:.o=.d)

.PHONY: all run clean
all: $(TARGET)

$(TARGET): $(OBJECTS) | bin
	$(CXX) $(LDFLAGS) $^ $(LDLIBS) -o $@

obj/main.o: main.cc | obj
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -MMD -MP -c $< -o $@

obj/%.o: src/%.cc | obj
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -MMD -MP -c $< -o $@

obj bin:
	mkdir -p $@

run: $(TARGET)
	./$(TARGET)

clean:
	rm -f $(OBJECTS) $(DEPS) $(TARGET)

-include $(DEPS)
