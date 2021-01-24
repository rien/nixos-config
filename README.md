# Rien's nixos-config

I try to keep a somewhat sane structure:

- [machines](./machines/): specific configurations for each machine, usually paired with a hardware configuration. This wil mostly import configurations from other files.
- [modules](./modules/): modules which are
- [services](./services/): specific services which are be cherry picked for each machine.
- [secrets](./secrets/): configuration files not meant to be world-readable on the machine.

## Licensing

Note that some configuration is based on [charvp's nixos-config](https://github.com/charvp/nixos-config/) which is licensed under the [Hippocratic License](https://firstdonoharm.dev/). Hence, assume this repository is dual licensed under the MIT and Hippocratic license. Please refer to [charvp's license](https://github.com/charvp/nixos-config/blob/master/license.md) for more information.
