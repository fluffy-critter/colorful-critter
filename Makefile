TARGET="fluffy/colorful-critter"
DEST=build
NAME=ColorfulCritter
LOVE_VERSION=0.10.2

.PHONY: clean all
.PHONY: publish publish-love publish-osx publish-win32 publish-win64 publish-status
.PHONY: love-bundle osx win32 win64

all: love-bundle osx win32 win64

clean:
	rm -rf build

publish: publish-love publish-osx publish-win32 publish-win64 publish-status

publish-status:
	butler status $(TARGET)

# .love bundle
love-bundle: $(DEST)/love/$(NAME).love
$(DEST)/love/$(NAME).love: $(shell find src -type f) $(shell find raw_assets -type f)
	./update-art.sh
	mkdir -p $(DEST)/love
	cd src && zip -9r ../$(@) .

publish-love: $(DEST)/.published-love
$(DEST)/.published-love: $(DEST)/love/$(NAME).love
	butler push $(DEST)/love $(TARGET):love-bundle
	touch $(@)

# macOS version
osx: $(DEST)/osx/$(NAME).app
$(DEST)/osx/$(NAME).app: $(DEST)/love/$(NAME).love $(wildcard osx/*) $(DEST)/love.app/Contents/MacOS/love
	mkdir -p $(DEST)/osx
	rm -rf $(@)
	cp -r "$(DEST)/love.app" $(@)
	cp osx/Info.plist $(@)/Contents
	cp $(DEST)/love/$(NAME).love $(@)/Contents/Resources

publish-osx: $(DEST)/.published-osx
$(DEST)/.published-osx: $(DEST)/osx/$(NAME).app
	butler push $(DEST)/osx $(TARGET):osx
	touch $(@)

# OSX build dependencies
$(DEST)/love.app/Contents/MacOS/love:
	wget -O $(DEST)/love-$(LOVE_VERSION)-macosx-x64.zip https://bitbucket.org/rude/love/downloads/love-0.10.2-macosx-x64.zip
	cd $(DEST) && unzip love-$(LOVE_VERSION)-macosx-x64.zip

# Windows build dependencies
WIN32_ROOT=$(DEST)/love-$(LOVE_VERSION)-win32
WIN64_ROOT=$(DEST)/love-$(LOVE_VERSION)-win64

$(WIN32_ROOT)/love.exe:
	wget -O $(DEST)/love-$(LOVE_VERSION)-win32.zip https://bitbucket.org/rude/love/downloads/love-$(LOVE_VERSION)-win32.zip
	cd $(DEST) && unzip love-$(LOVE_VERSION)-win32.zip

$(WIN64_ROOT)/love.exe:
	wget -O $(DEST)/love-$(LOVE_VERSION)-win64.zip https://bitbucket.org/rude/love/downloads/love-$(LOVE_VERSION)-win64.zip
	cd $(DEST) && unzip love-$(LOVE_VERSION)-win64.zip

# Win32 version
win32: $(DEST)/win32/$(NAME).exe
$(DEST)/win32/$(NAME).exe: $(WIN32_ROOT)/love.exe $(DEST)/love/$(NAME).love
	mkdir -p $(DEST)/win32
	cp -r $(wildcard $(WIN32_ROOT)/*.dll) $(WIN32_ROOT)/license.txt $(DEST)/win32
	cat $(^) > $(@)

publish-win32: $(DEST)/.published-win32
$(DEST)/.published-win32: $(DEST)/win32/$(NAME).exe
	butler push $(DEST)/win32 $(TARGET):win32
	touch $(@)

# Win64 version
win64: $(DEST)/win64/$(NAME).exe
$(DEST)/win64/$(NAME).exe: $(WIN64_ROOT)/love.exe $(DEST)/love/$(NAME).love
	mkdir -p $(DEST)/win64
	cp -r $(wildcard $(WIN64_ROOT)/*.dll) $(WIN64_ROOT)/license.txt $(DEST)/win64
	cat $(^) > $(@)

publish-win64: $(DEST)/.published-win64
$(DEST)/.published-win64: $(DEST)/win64/$(NAME).exe
	butler push $(DEST)/win64 $(TARGET):win64
	touch $(@)

