install-nix-determinate:
    #!/usr/bin/bash
    curl -fsSL --proto '=https' --tlsv1.2 https://install.determinate.systems/nix | sh -s -- install --determinate --no-confirm

install-eidokali-flatpaks:
    #!/usr/bin/bash
    flatpak remote-add --if-not-exists --system flathub https://flathub.org/repo/flathub.flatpakrepo
    TARGET_FLATPAK_FILE="${TARGET_FLATPAK_FILE:-${HOME}/.config/eidokali/flatpaks.list}"
    xargs flatpak --system -y install --or-update < $TARGET_FLATPAK_FILE

install-eidokali-gnome-extensions:
    #!/usr/bin/bash
    set -euo pipefail

    die() { echo "❌ $*" >&2; exit 1; }

    # Extensions to install (extension UUIDs)
    EXTENSIONS=(
        "system-monitor-next@paradoxxx.zero.gmail.com"
        "lockkeys@febueldo.test"
    )

    # Check if gnome-extensions command exists
    command -v gnome-extensions >/dev/null 2>&1 || die "gnome-extensions command not found"

    echo "🔎 Installing GNOME extensions..."

    for ext_uuid in "${EXTENSIONS[@]}"; do
        echo "⬇️  Processing extension: $ext_uuid"

        # Extract extension ID from UUID (part before @)
        ext_id="${ext_uuid%%@*}"

        # Download extension from extensions.gnome.org
        TEMP_DIR=$(mktemp -d)
        trap 'rm -rf "$TEMP_DIR"' EXIT

        # Get the extension info and download URL
        SHELL_VERSION=$(gnome-shell --version | grep -oP '\d+\.\d+' | head -n1 | cut -d. -f1)

        echo "🌐 Fetching extension info for GNOME Shell $SHELL_VERSION..."

        # Download extension metadata
        METADATA_URL="https://extensions.gnome.org/extension-info/?uuid=${ext_uuid}&shell_version=${SHELL_VERSION}"

        if ! wget -q -O "${TEMP_DIR}/info.json" "$METADATA_URL"; then
            echo "⚠️  Failed to fetch info for $ext_uuid (skipping)"
            continue
        fi

        # Extract download URL from JSON
        DOWNLOAD_URL=$(grep -Po '"download_url"\s*:\s*"\K[^"]+' "${TEMP_DIR}/info.json" | head -n1)

        if [[ -z "$DOWNLOAD_URL" ]]; then
            echo "⚠️  No download URL found for $ext_uuid (skipping)"
            continue
        fi

        # Make it a full URL
        DOWNLOAD_URL="https://extensions.gnome.org${DOWNLOAD_URL}"

        echo "⬇️  Downloading from: $DOWNLOAD_URL"

        # Download the extension
        if ! wget -q -O "${TEMP_DIR}/extension.zip" "$DOWNLOAD_URL"; then
            echo "⚠️  Failed to download $ext_uuid (skipping)"
            continue
        fi

        # Install the extension
        EXT_DIR="${HOME}/.local/share/gnome-shell/extensions/${ext_uuid}"
        mkdir -p "$EXT_DIR"

        if unzip -q -o "${TEMP_DIR}/extension.zip" -d "$EXT_DIR"; then
            echo "✅ Installed: $ext_uuid"

            # Compile schemas if they exist
            if [[ -d "${EXT_DIR}/schemas" ]]; then
                echo "🔧 Compiling GSettings schemas..."
                glib-compile-schemas "${EXT_DIR}/schemas/" || echo "⚠️  Schema compilation failed (extension may not work properly)"
            fi

            # Enable the extension
            gnome-extensions enable "$ext_uuid" 2>/dev/null || echo "ℹ️  Extension installed but not enabled (may require restart)"
        else
            echo "⚠️  Failed to extract $ext_uuid (skipping)"
        fi

        echo ""
        rm -rf "$TEMP_DIR"
    done

    echo "🎉 All extensions processed! Log out and back in to activate them."

post-install-setup: install-eidokali-flatpaks install-eidokali-gnome-extensions install-nix-determinate
    #!/usr/bin/bash
    ujust install-system-flatpaks
    ujust install-jetbrains-toolbox
    expect << EOF
    set timeout 2
    spawn ujust bluefin-cli
    expect "enable disable cancel"
    send "enable\r"
    expect {
        "already configured" {
            expect "enable disable cancel"
            send "\003"
        }
        "Installation Complete" {
            expect eof
        }
    }
    EOF

install-firefox-extensions EXTENSIONS_FILE="${HOME}/.config/eidokali/firefox-extensions.list":
    #!/usr/bin/bash
    set -euo pipefail

    die() { echo "❌ $*" >&2; exit 1; }

    # Validate extensions file exists
    [[ -f "{{ EXTENSIONS_FILE }}" ]] || die "Extensions file '{{ EXTENSIONS_FILE }}' not found."

    # Locate the active Flatpak Firefox profile
    PROFILE_ROOT="${HOME}/.var/app/org.mozilla.firefox/.mozilla/firefox"
    [[ -d "$PROFILE_ROOT" ]] || die "Firefox profile root not found – is Flatpak Firefox installed?"

    # Find active profile (prefer .default-release)
    PROFILE_DIR=$(ls "$PROFILE_ROOT" | grep -E '\.default(-release)?$' | head -n1 || \
                  ls "$PROFILE_ROOT" | head -n1)
    [[ -n "$PROFILE_DIR" ]] || die "No Firefox profile directories found."

    EXT_DIR="${PROFILE_ROOT}/${PROFILE_DIR}/extensions"
    mkdir -p "$EXT_DIR"

    echo "🔎 Using Firefox profile: ${PROFILE_DIR}"

    # Create temp directory
    TMPDIR=$(mktemp -d)
    trap 'rm -rf "$TMPDIR"' EXIT

    # Process each URL from the file
    while IFS= read -r url || [[ -n "$url" ]]; do
        # Skip empty lines and comments
        [[ -z "$url" || "$url" =~ ^[[:space:]]*# ]] && continue

        echo "⬇️  Downloading extension from: $url"

        # Download to temp file
        temp_xpi="${TMPDIR}/$(date +%s%N).xpi"
        wget -q -O "$temp_xpi" "$url" || die "Failed to download $url"

        # Extract extension ID from manifest.json
        if command -v jq >/dev/null 2>&1; then
            ext_id=$(unzip -p "$temp_xpi" manifest.json | \
                     jq -r '.applications?.gecko?.id // .browser_specific_settings?.gecko?.id // .id' | \
                     grep -v '^null$') || die "Could not extract ID from $url"
        else
            ext_id=$(unzip -p "$temp_xpi" manifest.json | \
                     grep -Po '"id"\s*:\s*"\K[^"]+') || die "Could not extract ID from $url (install jq for better parsing)"
        fi

        echo "🆔 Extension ID: $ext_id"

        # Copy to extensions directory
        cp -f "$temp_xpi" "${EXT_DIR}/${ext_id}.xpi"
        echo "✅ Installed: ${ext_id}.xpi"
        echo ""
    done < "{{ EXTENSIONS_FILE }}"

    echo "🎉 All extensions installed! Restart Firefox to activate them."
    echo "   Run: flatpak run org.mozilla.firefox"

install-chromium-extensions EXTENSIONS_FILE="${HOME}/.config/eidokali/chromium-extensions.list":
    #!/usr/bin/bash
    set -euo pipefail

    die() { echo "❌ $*" >&2; exit 1; }

    # Validate extensions file exists
    [[ -f "{{ EXTENSIONS_FILE }}" ]] || die "Extensions file '{{ EXTENSIONS_FILE }}' not found."

    # Locate the Flatpak Chromium preferences directory
    CHROMIUM_ROOT="${HOME}/.var/app/org.chromium.Chromium/config/chromium"
    [[ -d "$CHROMIUM_ROOT" ]] || die "Chromium config not found – is Flatpak Chromium installed?"

    # Create External Extensions directory
    EXT_DIR="${CHROMIUM_ROOT}/External Extensions"
    mkdir -p "$EXT_DIR"

    echo "🔎 Using Chromium external extensions directory"

    # Process each extension ID from the file
    while IFS= read -r ext_id || [[ -n "$ext_id" ]]; do
        # Skip empty lines and comments
        [[ -z "$ext_id" || "$ext_id" =~ ^[[:space:]]*# ]] && continue

        # Trim whitespace
        ext_id=$(echo "$ext_id" | xargs)

        echo "📦 Adding extension: $ext_id"

        # Create JSON file for external extension
        cat > "${EXT_DIR}/${ext_id}.json" <<EOF
        {
          "external_update_url": "https://clients2.google.com/service/update2/crx"
        }
        EOF

        echo "✅ Configured: ${ext_id}.json"
        echo ""
    done < "{{ EXTENSIONS_FILE }}"

    echo "🎉 All extensions configured! Restart Chromium to install them."
    echo "   Run: flatpak run org.chromium.Chromium"
    echo ""
    echo "ℹ️  Note: Extensions will be downloaded from Chrome Web Store on next launch."
