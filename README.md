# BlueZ MIDI COPR Automation

This repository provides automated building and distribution of BlueZ with enhanced MIDI support for Fedora via COPR (Community Build System).

## Features

- **Automated COPR Management**: Automatically detects new Fedora versions and BlueZ updates
- **Docker-based Builds**: Works on any platform with Docker (including GitHub Actions)
- **Enhanced MIDI Support**: BlueZ configured with experimental MIDI features
- **PipeWire Integration**: Support for modern audio systems
- **CI/CD Ready**: GitHub Actions workflow for automated builds

## Quick Start

### Prerequisites

- Docker or Podman
- COPR account and API token (for submissions)

### Local Usage

1. **Clone and build**:
   ```bash
   git clone <repository-url>
   cd bluez-midi-copr
   chmod +x docker-wrapper.sh
   ```

2. **Update spec for a Fedora version**:
   ```bash
   ./docker-wrapper.sh update-spec fedora-42
   ```

3. **Prepare COPR submission**:
   ```bash
   ./docker-wrapper.sh prepare-submission fedora-42
   ```

4. **Run full automation**:
   ```bash
   ./docker-wrapper.sh automation
   ```

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

### GitHub Actions Setup

For automated builds in GitHub Actions:

1. **Set up COPR credentials**:
   - Go to your repository Settings → Secrets and variables → Actions
   - Add these secrets:
     - `COPR_LOGIN`: Your COPR login name
     - `COPR_TOKEN`: Your COPR API token
   - Add this variable:
     - `COPR_OWNER`: Your COPR username (optional, defaults to repository owner)

2. **Configure the workflow**:
   - The workflow runs daily at 6 AM UTC
   - Manual runs can be triggered from the Actions tab
   - Specific Fedora versions can be built manually

3. **Monitor builds**:
   - Check the Actions tab for build status
   - Artifacts include generated spec files and submission directories
   - Build logs show detailed progress

## Architecture

### Docker-based Approach

The system uses Docker to provide a consistent Fedora environment for:
- Downloading Fedora source RPMs
- Extracting and modifying spec files  
- Preparing COPR submissions

This approach works reliably on Ubuntu GitHub runners while maintaining compatibility with Fedora packaging tools.

### Automation Logic

The automation script (`bluez-midi-automation.sh`) implements:

1. **Version Detection**: Checks for new Fedora versions via COPR API
2. **COPR Management**: Automatically adds new Fedora versions to the COPR project
3. **Update Checking**: Monitors BlueZ package versions in Fedora repositories
4. **Build Submission**: Automatically builds and submits updates when available
5. **State Tracking**: Maintains state to avoid duplicate builds

## File Structure

```
├── Dockerfile                    # Fedora-based build environment
├── docker-wrapper.sh            # Docker command wrapper  
├── bluez-midi-automation.sh      # Main automation logic
├── update-bluez-spec.sh          # Spec file modification
├── prepare-copr-submission.sh    # COPR submission preparation
├── get-copr-chroots.sh          # Available chroots query
├── config.env                   # Configuration settings
└── .github/workflows/           # GitHub Actions automation
```

## Manual Operations
