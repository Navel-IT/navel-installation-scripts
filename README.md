navel-installation-scripts
==========================

This collection of scripts provides a unified interface for installing Navel "main projects" (each of them got a corresponding script) on different Linux distributions.

Usage
-----

```bash
curl -L https://install.perlbrew.pl | bash

git clone https://github.com/navel-it/navel-installation-scripts.git

cd navel-installation-scripts/

bash navel-something-installer.sh # show available options

perlbrew exec --with 5.24.0 navel-something-installer.sh devel # install navel-something from http://github.com/navel-it/navel-something.git@devel
```

Copyright
---------

Copyright (C) 2015 Yoann Le Garff, Nicolas Boquet and Yann Le Bras

License
-------

navel-installation-scripts is licensed under the Apache License, Version 2.0
