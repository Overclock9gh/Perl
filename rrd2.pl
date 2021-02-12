####################################################################
#Auteur Said Hamdane                                               #
#25 novembre 2020                                                  #
#                                                                  #
#Objectif: Analyser le trafic entrant et sortant sur une interface #
#non connectée à Internet à toutes les 5 minutes sur une période   #
#d'une heure.                                                      #
####################################################################

#!/usr/bin/perl

#Variables de l'intervalle de temps.
my $temps_initial = time();
my $temps_final = $temps_initial + 3600;

#Création de la base de données.
print "Veuillez patientez pendant que nous vérifions les informations de la base de données \n\n";
my @creation_donnees = ("rrdtool create trafic.rrd --start $temps_initial --step 300 DS:traficint:C0UNTER:600:0:0 DS:traficext:COUNTER:600:U:U RRA:AVERAGE:0.5:2:12");
system @creation_donnees;

#Sommeil permettant à la base de données de se céer avant de l'utiliser.
sleep(5);

#Boucle permettant d'effectuer le script dans un lapse de temps d'une heure.
while ( time() <= $temps_final ) {

    my $snmp = int('snmpget -Oqv -v2c -c public 192.168.198.129 1.3.6.1.2.1.2.2.1.10.2');
	my $snmp2 = int('snmpget -Oqv -v2c -c public 192.168.198.129 1.3.6.1.2.1.2.2.1.16.2');
	my $temps_a_jour = time();

	#Mise a jour des données du trafic.
	my @rrdtool_a_jour = ("rrdtool update trafic.rrd -t traficint:traficext N:$snmp:$snmp2");
	system @rrdtool_a_jour;

	print "temps:$temps_a_jour \n";
	print "valeurs entrantes:$snmp \n";
	print "valeurs sortantes:$snmp2 \n\n";

	#Opération consistant à générer la moyenne des valeurs.
	my @moyenne_rrd = ("rrdtool fetch trafic.rrd AVERAGE --start $temps_initial");
	system @moyenne_rrd;

	#Sommeil permettant d'effectuer l'affichage des données à chaque cinq minutes.
	sleep(300);
}