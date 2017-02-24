# Simple-ish Makefile for building LOVE packages to multiple architectures and publishing to itch.io.
#
# Useful targets:
#
#   all - build for Windows, OSX, and LOVE bundle
#   publish - deploy the build to itch.io
#   publish-status - print the itch.io status
#
# The itch publishing stuff uses itch's "butler" mechanism. Read more at https://itch.io/docs/butler/
#
# This build environment is set up with the following things in mind:
#
#   top-level game directory is in src/
#   baked assets live in src/assets/
#   there's a script called ./update-art.sh that automatically bakes assets from raw_assets/
#
# Implementing that for your own needs is left as an exercise to the reader. :)

# itch.io target
TARGET="fluffy/colorful-critter"

# build directory
DEST=build

# Application name
NAME=ColorfulCritter

# LOVE version to fetch and build against
LOVE_VERSION=0.10.2

.PHONY: clean all
.PHONY: publish publish-love publish-osx publish-win32 publish-win64 publish-status
.PHONY: love-bundle osx win32 win64
.PHONY: assets

all: love-bundle osx win32 win64

clean:
	rm -rf build

publish: publish-love publish-osx publish-win32 publish-win64 publish-status

publish-status:
	butler status $(TARGET)

assets: $(DEST)/.assets
$(DEST)/.assets: $(shell find raw_assets -name '*.png' -or -name '*.wav')
	mkdir -p $(DEST)
	./update-art.sh
	touch $(@)

# .love bundle
love-bundle: $(DEST)/love/$(NAME).love
$(DEST)/love/$(NAME).love: $(shell find src -type f) $(DEST)/.assets
	mkdir -p $(DEST)/love
	cd src && zip -9r ../$(@) .

publish-love: $(DEST)/.published-love
$(DEST)/.published-love: $(DEST)/love/$(NAME).love
	butler push $(DEST)/love $(TARGET):love-bundle && touch $(@)

# macOS version
osx: $(DEST)/osx/$(NAME).app
$(DEST)/osx/$(NAME).app: $(DEST)/love/$(NAME).love $(wildcard osx/*) $(DEST)/deps/love.app/Contents/MacOS/love
	mkdir -p $(DEST)/osx
	rm -rf $(@)
	cp -r "$(DEST)/deps/love.app" $(@) && \
	cp osx/Info.plist $(@)/Contents && \
	cp $(DEST)/love/$(NAME).love $(@)/Contents/Resources

publish-osx: $(DEST)/.published-osx
$(DEST)/.published-osx: $(DEST)/osx/$(NAME).app
	butler push $(DEST)/osx $(TARGET):osx && touch $(@)

# OSX build dependencies
$(DEST)/deps/love.app/Contents/MacOS/love:
	mkdir -p $(DEST)/deps/ && \
	cd $(DEST)/deps && \
	wget https://bitbucket.org/rude/love/downloads/love-0.10.2-macosx-x64.zip && \
	unzip love-$(LOVE_VERSION)-macosx-x64.zip

# Windows build dependencies
WIN32_ROOT=$(DEST)/deps/love-$(LOVE_VERSION)-win32
WIN64_ROOT=$(DEST)/deps/love-$(LOVE_VERSION)-win64

$(WIN32_ROOT)/love.exe:
	mkdir -p $(DEST)/deps/ && \
	cd $(DEST)/deps && \
	wget https://bitbucket.org/rude/love/downloads/love-$(LOVE_VERSION)-win32.zip && \
	unzip love-$(LOVE_VERSION)-win32.zip

$(WIN64_ROOT)/love.exe:
	mkdir -p $(DEST)/deps/ && \
	cd $(DEST)/deps && \
	wget https://bitbucket.org/rude/love/downloads/love-$(LOVE_VERSION)-win64.zip && \
	unzip love-$(LOVE_VERSION)-win64.zip

# Win32 version
win32: $(DEST)/win32/$(NAME).exe
$(DEST)/win32/$(NAME).exe: $(WIN32_ROOT)/love.exe $(DEST)/love/$(NAME).love
	mkdir -p $(DEST)/win32
	cp -r $(wildcard $(WIN32_ROOT)/*.dll) $(WIN32_ROOT)/license.txt $(DEST)/win32
	cat $(^) > $(@)

publish-win32: $(DEST)/.published-win32
$(DEST)/.published-win32: $(DEST)/win32/$(NAME).exe
	butler push $(DEST)/win32 $(TARGET):win32 && touch $(@)

# Win64 version
win64: $(DEST)/win64/$(NAME).exe
$(DEST)/win64/$(NAME).exe: $(WIN64_ROOT)/love.exe $(DEST)/love/$(NAME).love
	mkdir -p $(DEST)/win64
	cp -r $(wildcard $(WIN64_ROOT)/*.dll) $(WIN64_ROOT)/license.txt $(DEST)/win64
	cat $(^) > $(@)

publish-win64: $(DEST)/.published-win64
$(DEST)/.published-win64: $(DEST)/win64/$(NAME).exe
	butler push $(DEST)/win64 $(TARGET):win64 && touch $(@)

