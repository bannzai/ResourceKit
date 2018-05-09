BUILD_FOLDER?=.build
PROJECT?=ResourceKit
RELEASE_BINARY_FOLDER?=$(BUILD_FOLDER)/release/$(PROJECT)

build:
	swift build

release:
	swift build -c release -Xswiftc -static-stdlib

clean:
	swift package clean
	rm -rf $(BUILD_FOLDER) $(PROJECT).xcodeproj

xcode:
	swift package generate-xcodeproj
