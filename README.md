# BlueZ MIDI COPR Development Environment

This repository contains the development environment and packaging files for building a COPR (Community Build System) package of BlueZ with enhanced MIDI support for Fedora.

## Features

- **Dev Container**: Complete Fedora-based development environment
- **Enhanced MIDI Support**: BlueZ configured with experimental MIDI features
- **COPR Integration**: Ready-to-use COPR packaging and build scripts
- **PipeWire Integration**: Support for modern audio systems

## Getting Started

### Prerequisites

- Docker or Podman
- VS Code with Dev Containers extension

### Setup

1. **Open in Dev Container**:

   - Open this repository in VS Code
   - Click "Reopen in Container" when prompted
   - Or use Command Palette: `Dev Containers: Reopen in Container`

2. **Configure COPR**:

   ```bash
   # Copy and edit the COPR configuration
   cp copr-config-template ~/.config/copr
   # Edit with your COPR credentials from https://copr.fedorainfracloud.org/api/
   nano ~/.config/copr
   ```

3. **Create COPR Project**:
   ```bash
   make create-copr
   ```

### Development Workflow

1. **Prepare Build Environment**:

   ```bash
   make prep
   ```

2. **Download Sources**:

   ```bash
   make sources
   ```

3. **Build Source RPM**:

   ```bash
   make srpm
   ```

4. **Test Build Locally**:

   ```bash
   make build-local
   ```

5. **Upload to COPR**:
   ```bash
   make upload-copr
   ```

### Package Details

The `bluez-midi.spec` file configures BlueZ with:

- **Enhanced MIDI Support**: `--enable-midi` and `--enable-experimental`
- **Modern Audio Integration**: PipeWire compatibility
- **Complete Bluetooth Stack**: All standard BlueZ features
- **System Integration**: Proper systemd service configuration

### Key Files

- `.devcontainer/`: Dev container configuration
- `bluez-midi.spec`: RPM spec file for the package
- `Makefile`: Build automation
- `copr-config-template`: COPR configuration template

### Useful Commands

```bash
# Lint the spec file
make lint

# Clean build artifacts
make clean

# Check COPR build status
copr-cli list-builds bluez-midi

# Monitor build logs
copr-cli build-logs <build-id>
```

### MIDI Features

This BlueZ build includes:

- Bluetooth MIDI device support
- Integration with ALSA sequencer
- PipeWire compatibility for modern audio workflows
- Experimental features for enhanced device compatibility

### Troubleshooting

1. **COPR Authentication Issues**:

   - Verify your API token at https://copr.fedorainfracloud.org/api/
   - Check the expiration date in your config

2. **Build Failures**:

   - Check build logs: `copr-cli build-logs <build-id>`
   - Test locally first: `make build-local`
   - Verify dependencies in the spec file

3. **Mock Build Issues**:
   - Ensure you're in the `mock` group: `groups`
   - Check mock configuration: `mock --print-chroot-config`

### Contributing

1. Fork this repository
2. Make your changes
3. Test the build locally
4. Submit a pull request

### Resources

- [COPR Documentation](https://docs.pagure.org/copr.copr/)
- [RPM Packaging Guide](https://rpm-packaging-guide.github.io/)
- [BlueZ Documentation](http://www.bluez.org/documentation/)
- [Fedora Packaging Guidelines](https://docs.fedoraproject.org/en-US/packaging-guidelines/)
