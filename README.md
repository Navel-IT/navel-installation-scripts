navel-installation-scripts
==================

This collection of scripts provides a unified interface for installing Navel projects on different Linux distributions.

Each project has a corresponding script for it's installation. For exemple navel-scheduler has `navel-scheduler-installer.sh`.

Prepare
-------

You must have `git`, `bash` and `perl` (>= 5.10, with core modules) installed to begin an installation.

```bash
git clone https://github.com/navel-it/navel-installation-scripts.git

cd navel-installation-scripts/

bash navel-something-installer.sh # show available options

bash navel-something-installer.sh
```

Install
------

```bash
bash navel-something-installer.sh master # install navel-something from http://github.com/navel-it/navel-something.git@master

bash navel-something-installer.sh devel # install navel-something from http://github.com/navel-it/navel-something.git@devel
```