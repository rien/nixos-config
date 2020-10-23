# Rien's nixos-config

I try to keep a somewhat sane structure:

- [machines](./machines/): specific configurations for each machine, usually paired with a hardware configuration. This wil mostly import configurations from other files.
- [conf](./conf/): reusable configuration files which are mostly shared between machines.
- [services](./services/): specific services which are be cherry picked for each machine.
- [secrets](./secrets/): configuration files not meant to be world-readable on the machine.
