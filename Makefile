BUILD_FOLDER?=.build
PROJECT?=ResourceKit
RELEASE_BINARY_FOLDER?=$(BUILD_FOLDER)/release/$(PROJECT)

build:
	swift build

release:
	swift build --disable-sandbox -c release -Xswiftc -static-stdlib
	open ./.build/x86_64-apple-macosx10.10/release/

clean:
	swift package clean
	rm -rf $(BUILD_FOLDER) $(PROJECT).xcodeproj

xcode:
	swift package generate-xcodeproj
