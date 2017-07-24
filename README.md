Dokumentation bisheriger Workflow:

1. Repository git@github.com:Neanderfunk/ansible.git enthält Daten zur Erstellung von site.conf, site.mk, modules, aliases.json
	* Eingabedaten stehen vars/sites.yml.in, templates/\*-v2016.2.x.j2 (für Branch v2016.2.x)
	* Wenn vars/sites.yml.in angepasst wurde, muss ./gensites-yml.py aufgerufen werden
	* Um site.conf, site.mk, modules neu zu erstellen muss ". ansible.ffnef.env; ansible-playbook -e branch=v2016.2.x gensites.yml" aufgerufen werden
	* Die Dateien landen dann in out/sites/ und können von da in die passende Branch von dem Repo site-ffnef aufgerufen werden

2. Repository git@github.com:Neanderfunk/site-ffnef.git enthält die Dateien, welche die Konfiguration der Gluon-Images bestimmen
	* Diese sollten im Regelfall nicht manuell bearbeitet werden

3. Repository git@github.com:Neanderfunk/build-gluon.git enthält das Skript build.sh um Gluon für Neanderfunk zu bauen
   * Dieses erhält als 1. Parameter eine Revision, die derzeit nicht verwendet wird und als zweiten Parameter die Branch, die derzeit lediglich bestimmt, in welchem Verzeichnis das Bauen stattfindet.
   * So kann das Skript z.B. mit "/bin/sh -v v2016.2.x/build.sh x v2016.2.x" aufgerufen werden.
   * Anmerkung: Ursprünglich wurde das Skript so konstruiert, dass es innerhalb von Buildbot aufgerufen werden kann, dieser wird aber tatsächlich nicht mehr verwendet.
