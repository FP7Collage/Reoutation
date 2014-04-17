#!/bin/sh
./node_modules/coffee-script/bin/coffee main.coffee --reputations http://reputations.playgen.org --gaminomics http://gaminomics.playgen.org
echo 'Reputation broke yo' | mail -s 'A gift from the gods' lex@playgen.com
