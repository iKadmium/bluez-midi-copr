# Makefile for BlueZ MIDI COPR development

PACKAGE_NAME := bluez-midi
SPEC_FILE := $(PACKAGE_NAME).spec
VERSION := $(shell grep "^Version:" $(SPEC_FILE) | awk '{print $$2}')
RELEASE := $(shell grep "^Release:" $(SPEC_FILE) | awk '{print $$2}' | cut -d'%' -f1)

# COPR project settings
COPR_PROJECT := bluez-midi
COPR_CHROOTS := fedora-39-x86_64 fedora-40-x86_64

.PHONY: help prep sources srpm build-local upload-copr clean

help:
	@echo "Available targets:"
	@echo "  prep         - Prepare build environment"
	@echo "  sources      - Download source files"
	@echo "  srpm         - Build source RPM"
	@echo "  build-local  - Build package locally with mock"
	@echo "  upload-copr  - Upload to COPR"
	@echo "  clean        - Clean build artifacts"
	@echo "  lint         - Run rpmlint on spec file"

prep:
	@echo "Preparing build environment..."
	rpmdev-setuptree
	@echo "Build environment ready."

sources:
	@echo "Downloading sources for version $(VERSION)..."
	spectool -g -R $(SPEC_FILE)
	@echo "Sources downloaded."

srpm: sources
	@echo "Building source RPM..."
	rpmbuild -bs $(SPEC_FILE)
	@echo "Source RPM built: ~/rpmbuild/SRPMS/$(PACKAGE_NAME)-$(VERSION)-$(RELEASE).src.rpm"

build-local: srpm
	@echo "Building package locally with mock..."
	mock -r fedora-39-x86_64 ~/rpmbuild/SRPMS/$(PACKAGE_NAME)-$(VERSION)-$(RELEASE).src.rpm
	@echo "Local build complete."

upload-copr: srpm
	@echo "Uploading to COPR project $(COPR_PROJECT)..."
	copr-cli build $(COPR_PROJECT) ~/rpmbuild/SRPMS/$(PACKAGE_NAME)-$(VERSION)-$(RELEASE).src.rpm
	@echo "Upload to COPR initiated."

create-copr:
	@echo "Creating COPR project $(COPR_PROJECT)..."
	copr-cli create $(COPR_PROJECT) --chroot $(COPR_CHROOTS) \
		--description "BlueZ with enhanced MIDI support" \
		--instructions "Enhanced BlueZ package with better MIDI support for modern audio systems"

lint:
	@echo "Running rpmlint on spec file..."
	rpmlint $(SPEC_FILE)

clean:
	@echo "Cleaning build artifacts..."
	rm -rf ~/rpmbuild/BUILD/bluez-*
	rm -rf ~/rpmbuild/BUILDROOT/$(PACKAGE_NAME)-*
	rm -f ~/rpmbuild/SRPMS/$(PACKAGE_NAME)-*
	rm -f ~/rpmbuild/RPMS/*/$(PACKAGE_NAME)-*
	@echo "Clean complete."
