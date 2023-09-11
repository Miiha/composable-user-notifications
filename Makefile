CONFIG = debug
PLATFORM_IOS = iOS Simulator,id=$(call udid_for,iPhone,iOS-16)
PLATFORM_MACOS = macOS
PLATFORM_MAC_CATALYST = macOS,variant=Mac Catalyst
PLATFORM_TVOS = tvOS Simulator,id=$(call udid_for,TV,tvOS-16)
PLATFORM_WATCHOS = watchOS Simulator,id=$(call udid_for,Watch,watchOS-9)

default: swift-test

build-all-platforms:
	for platform in \
	  "$(PLATFORM_IOS)" \
	  "$(PLATFORM_MACOS)" \
	  "$(PLATFORM_MAC_CATALYST)" \
	  "$(PLATFORM_TVOS)" \
	  "$(PLATFORM_WATCHOS)"; \
	do \
		xcrun xcodebuild build \
			-workspace ComposableUserNotifications.xcworkspace \
			-scheme ComposableUserNotifications \
			-configuration $(CONFIG) \
			-destination platform="$$platform" || exit 1; \
	done;

build-for-library-evolution:
	swift build \
		-c release \
		--target ComposableUserNotifications \
		-Xswiftc -emit-module-interface \
		-Xswiftc -enable-library-evolution

format:
	swift format \
		--ignore-unparsable-files \
		--in-place \
		--recursive \
		./Package.swift ./Sources ./Tests

test-example:
	xcrun xcodebuild test \
		-workspace ComposableUserNotifications.xcworkspace \
		-scheme Example \
		-destination platform="${PLATFORM_IOS}" || exit 1; \

test-swift:
	swift test
	swift test -c release

.PHONY: test-example test-swift build-for-library-evolution format

define udid_for
$(shell xcrun simctl list --json devices available $(1) | jq -r '.devices | to_entries | map(select(.value | add)) | sort_by(.key) | .[] | select(.key | contains("$(2)")) | .value | last.udid')
endef
