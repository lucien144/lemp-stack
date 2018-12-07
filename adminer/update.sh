#!/bin/bash
rm latest.php
rm plugins/plugin.php
rm plugins/AdminerColors.php

wget https://www.adminer.org/latest.php

cd plugins/
wget https://raw.github.com/vrana/adminer/master/plugins/plugin.php
wget https://cdn.jsdelivr.net/gh/fprochazka/adminer-colors/AdminerColors.php