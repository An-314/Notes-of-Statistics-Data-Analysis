# -------- Cross-platform helpers --------
ifeq ($(OS),Windows_NT)
  define MKDIR_P
    powershell -NoProfile -Command "New-Item -ItemType Directory -Force '$(1)' | Out-Null"
  endef
  define RM_RF
    powershell -NoProfile -Command "if (Test-Path '$(1)') { Remove-Item -Recurse -Force '$(1)' }"
  endef
else
  define MKDIR_P
    mkdir -p '$(1)'
  endef
  define RM_RF
    rm -rf '$(1)'
  endef
endif
# ----------------------------------------

# 基本变量
BUILD_DIR := builds

MAIN_SRC := main.typ
MAIN_PDF := $(BUILD_DIR)/main.pdf

CHAPS := $(wildcard chap*.typ)

PIC_SRC := $(wildcard pic/*.typ)
PIC_PDF := $(patsubst pic/%.typ,pic/builds/%.pdf,$(PIC_SRC))

# HW 部分
HW_SRC := $(wildcard HW/*.typ)
HW_PDF := $(patsubst HW/%.typ,$(BUILD_DIR)/HW/%.pdf,$(HW_SRC))

.PHONY: all clean

all: $(PIC_PDF) $(MAIN_PDF) $(SUMMARY_PDF) $(HW_PDF)

# 编译主文档
$(MAIN_PDF): $(MAIN_SRC) $(CHAPS) $(PIC_PDF)
	$(call MKDIR_P,$(dir $@))
	typst compile $< $@


# 编译每个图片
pic/builds/%.pdf: pic/%.typ
	$(call MKDIR_P,$(dir $@))
	typst compile $< $@

# 编译每个 HW
$(BUILD_DIR)/HW/%.pdf: HW/%.typ
	$(call MKDIR_P,$(dir $@))
	typst compile $< $@

clean:
	$(call RM_RF,$(BUILD_DIR))
	$(call RM_RF,pic/builds)

-include ./notes.mk