#!/bin/sh
# build.sh - build all the builds

TARGET="fluffy/colorful-critter"
DEST=build

.PHONY: clean all publish publish-love publish-osx publish-win32 publish-win64 butler-status

all: build/love/ColorfulCritter.love build/osx/ColorfulCritter.app

clean:
	rm -rf build

publish: publish-love publish-osx

publish-status:
	butler status $(TARGET)

# .love bundle
$(DEST)/love/ColorfulCritter.love: $(shell find src -type f)
	mkdir -p $(DEST)/love
	cd src && zip -9r ../$(@) .

publish-love: $(DEST)/love/ColorfulCritter.love
	butler push $(DEST)/love $(TARGET):love-bundle

# macOS version
$(DEST)/osx/ColorfulCritter.app: $(DEST)/love/ColorfulCritter.love $(wildcard osx/*)
	mkdir -p $(DEST)/osx
	rm -rf $(@)
	cp -r "/Applications/love.app" $(@)
	cp osx/Info.plist $(@)/Contents
	cp $(DEST)/love/ColorfulCritter.love $(@)/Contents/Resources

publish-osx: $(DEST)/osx/ColorfulCritter.app
	butler push $(DEST)/osx $(TARGET):osx
