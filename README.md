# ansible role: Transmission Deamon

[![Build Status](https://travis-ci.org/esolitos/ansible-transmission-daemon.svg?branch=master)](https://travis-ci.org/esolitos/ansible-transmission-daemon)

An Ansible Role that installs transmission-daemon and transmission-remote.
Tested on Debian/Ubuntu.

**IMPORTANT:** It is _strongly recomended_ to change the default RPC user and
password, as the default value is `transmission` for both.

## Role Variables

Each entry in the `settings.json` from `transmission-daemon` con be configured,
simply replacing dashes `-` with underscores `_` in the config name, prefixing
it with `transmissiond_`.

**Example:** To change the `incomplete-dir` simply set `transmissiond_incomplete_dir`
in your vars.

The full list of the available settings can be found on the Transmission wiki.

## Dependencies

None.

## Example Playbook

    - hosts: torrent
      vars_files:
        - vars/main.yml
      roles:
        - { role: esolitos.transmissiond }

*Inside `vars/main.yml`*:

    transmissiond_rpc_enabled: false
    transmissiond_incomplete_dir: "/home/myuser/downloads/.incomplete"
    transmissiond_download_dir: "/home/myuser/downloads"
