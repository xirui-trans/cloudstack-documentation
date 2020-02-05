make clean
make gettext
sphinx-intl update-txconfig-resources --pot-dir source/locale/pot --transifex-project-name apache-cloudstack-installation-rtd --locale-dir source/locale
tx push -s
tx pull -l en
sphinx-intl build --locale-dir source/locale
make -e SPHINXOPTS="-D language='en'" html