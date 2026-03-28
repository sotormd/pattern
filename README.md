# pattern

Atomic, image-based systems with A/B updates, provisioned using Nix.

> pattern is not a distro, but provides a base module for building your own
> systems! See [Explanation](#explanation) for more information.

# Contents

1. [Features](#features)
2. [Explanation](#explanation)
3. [Demonstration](#demonstration)
4. [Usage](#usage)
5. [Options](#options)

# Features

- [x] Base image generated using `systemd-repart`
- [x] Verity on erofs root Nix Store using `systemd-veritysetup`
- [x] Expandable TPMv2 LUKS-encrypted persistent partition using
      `systemd-repart`
- [x] Signed A/B store updates using `systemd-sysupdate`
- [x] Optional unprivileged user setup on first boot using `systemd-homed`
- [x] Optional distrobox, bubblewrap and xdg-dbus-proxy to install and sandbox
      apps
- [x] Optional minimal GNOME desktop

# Explanation

pattern provides a base module which can be used to implement concepts from
[Fitting Everything Together](https://0pointer.net/blog/fitting-everything-together.html)
using Nix!

**pattern is primarily developed for my own personal use. Its design and
priorities are driven by my requirements. The documentation is written to help
me create new systems.**

pattern primarily ships the `nixosModules.pattern` which you can import in your
NixOS configuration to combine with usual options from the NixOS modules system
to build your own base images. See [Usage](#usage) for more information.

pattern also provides some of its own options to configure aspects of the
`nixosModules.pattern`. See [Options](#options) for all included options.

This repository also contains a demonstration system. See
[Demonstration](#demonstration) for more information.

# Demonstration

This section covers using the demonstration system. See [Usage](#usage) for
building your own systems.

The configuration for the demonstration system is in
[`demo/demo.nix`](./demo/demo.nix).

> The demonstration system is ONLY FOR DEMONSTRATION of some of pattern's
> features and is unusable in real environments.

1. Download and verify the `demo_0.0.1.raw` base image from the
   [Releases section](https://github.com/sotormd/pattern/releases/tag/demo).

2. Expand the image to create space for the encrypted persistent partition:

   ```bash
   chmod +w demo_0.0.1.raw
   qemu-img resize -f raw demo_0.0.1.raw "+50G"
   ```

3. Boot the image using the included run-demo package, or using QEMU/KVM
   yourself:

   ```bash
   nix run github:sotormd/pattern#run-demo -- demo_0.0.1.raw
   ```

4. You will be logged in as root automatically. The default root password is
   `demo`. This can be changed using `passwd`:

   ```bash
   passwd
   ```

5. The demo image has a persistent `/etc`, `/home`, `/srv` and `/var`. New users
   can be created normally using `useradd`:

   ```bash
   useradd foo
   ```

6. A demonstration update release is also included. To use this update:

   ```bash
   updatectl check
   updatectl update
   ```

7. Reboot and you will be able to boot into `demo_0.0.2`. The only change is
   that the `fastfetch` package is installed. This can be verified by running
   it:

   ```bash
   fastfetch
   ```

# Usage

This section covers using pattern to build your own base images.

1. Add pattern to your flake inputs:

   ```nix
   inputs.pattern.url = "github:sotormd/pattern";
   ```

2. Create a NixOS configuration output and add
   `inputs.pattern.nixosModules.pattern`. Example:

   ```nix
   outputs = { self, ... }@inputs: {
       nixosConfigurations.mySystem = inputs.nixpkgs.lib.nixosSystem {
           system = "x86_64-linux";
           modules = [
               inputs.pattern.nixosModules.pattern # add this
               ./configuration.nix  # rest of your configuration
           ];
       };
   };
   ```

3. Configure your system by making changes like you would to any other NixOS
   configuration. Make sure to add modules that your hardware may require. You
   may also want to set an initial root password.

4. Set the options required by pattern. See [Options](#options) for more
   information. Some of the options are compulsory.

5. You probably want to generate GPG signing keys so that `systemd-sysupdate`
   can verify against them. You can use your own keys or use the included script
   to generate new ones:

   ```bash
   nix run github:sotormd/pattern#gen-keyring -- mySystem
   ```

   This will create `mySystem-gpg/` and `mySystem-pubring.pgp`.

   Remember to pass `mySystem-pubring.pgp` to `pattern.image.updates.pubring`
   via [Options](#options) to embed it in the base image.

   `mySystem-gpg/` contains the private key and should be kept secret.

6. Once you are done, you can build your base image:

   ```nix
   nix build .#nixosConfigurations.mySystem.config.pattern.release
   ```

7. To create the final signed release artifact:

   ```bash
   nix run github:sotormd/pattern#sign-release -- ./result ./mySystem-gpg
   ```

   This creates the final release in `./pattern-release`

8. The `./pattern-release` directory will include a full base image + individual
   partitions. The individual partitions are for updating the system. To install
   your base system, we will use the full image. This full raw image can be
   written to a disk using `dd` and booted from.

9. While serving updates, just upload the contents of `./pattern-release` to
   your update server.

# Options

This section documents the options provided by `nixosModules.pattern`.

All options are available under the `pattern` namespace.

## `pattern.image`

Options related to image identity and updates.

### `pattern.image.id`

- **Type:** `string`
- **Required:** yes

A unique identifier for the image.

This is used to distinguish different systems when performing updates. It should
remain consistent across releases of the same system.

### `pattern.image.version`

- **Type:** `string`
- **Required:** yes

The version of the image.

Used by the update system to determine whether a newer version is available and
to label boot entries.

### `pattern.image.updates.url`

- **Type:** `string`
- **Required:** yes

The base URL used by `systemd-sysupdate` to fetch updates.

pattern does not impose any restrictions on how updates are delivered. Any
transport may be used as long as updates are compatible with
`systemd-sysupdate`.

### `pattern.image.updates.pubring`

- **Type:** `path`
- **Required:** yes

The path to the public GPG key used by `systemd-sysupdate` to verify updates.

## `pattern.partitions`

Options related to partition layout and persistence.

### `pattern.partitions.disk`

- **Type:** `string`
- **Required:** yes

The target disk device used when generating the image (e.g. `/dev/sda`).

This is used by `systemd-repart` when creating the partition layout.

### `pattern.partitions.sizes`

Defines the sizes of partitions created in the base image.

All values are strings and should follow `systemd-repart` size syntax (e.g.
`512M`, `1G`).

#### `pattern.partitions.sizes.esp`

- **Type:** `string`
- **Required:** yes

Size of the EFI System Partition (ESP).

#### `pattern.partitions.sizes.verity`

- **Type:** `string`
- **Required:** yes

Size of the verity hash partition used for root filesystem integrity.

#### `pattern.partitions.sizes.usr`

- **Type:** `string`
- **Required:** yes

Size of the root (`/usr`) filesystem image.

### `pattern.partitions.persist`

Controls which directories are persisted across reboots.

By default, the root filesystem is ephemeral. Enabling persistence for a
directory ensures it is stored on a separate writable partition.

All options are booleans and `false` by default.

#### `pattern.partitions.persist.etc`

Persist `/etc`.

#### `pattern.partitions.persist.home`

Persist `/home`.

#### `pattern.partitions.persist.srv`

Persist `/srv`.

#### `pattern.partitions.persist.var`

Persist `/var`.

## `pattern.debug`

- **Type:** `boolean`
- **Default:** `true`

Enables root autologin for debugging purposes.

This should be disabled for production systems.

## `pattern.userspace`

Optional userspace features provided by pattern.

These are disabled by default. Users are free to implement their own userspace
environment.

### `pattern.userspace.homed`

- **Type:** `boolean`
- **Default:** `false`

Enable `systemd-homed` for user management. Also allows setting up a main
unprivileged user on first boot.

### `pattern.userspace.desktop`

- **Type:** `boolean`
- **Default:** `false`

Enable a minimal desktop environment.

### `pattern.userspace.distrobox`

- **Type:** `boolean`
- **Default:** `false`

Enable `distrobox` for managing application containers.

### `pattern.userspace.sandboxing`

- **Type:** `boolean`
- **Default:** `false`

Enable additional sandboxing tools such as `bubblewrap` and `xdg-dbus-proxy`.

## Notes

- pattern provides a base system only. Many aspects (such as update transport
  and application model) are intentionally left to the user.
