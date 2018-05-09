BUILD_FOLDER?=.build
PROJECT?=ResourceKit
RELEASE_BINARY_FOLDER?=$(BUILD_FOLDER)/release/$(PROJECT)

build:
	swift build

release:
	swift build -c release -Xswiftc -static-stdlib
	zip ResourceKit.zip ./.build/x86_64-apple-macosx10.10/release/ResourceKit
	open .

clean:
	swift package clean
	rm -rf $(BUILD_FOLDER) $(PROJECT).xcodeproj

xcode:
	swift package generate-xcodeproj
