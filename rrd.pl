####################################################################
#Auteur Said Hamdane                                               #
#2 novembre 2020                                                   #
#                                                                  #
#Objectif: Analyser le trafic entrant sur une interface non        #
#connectée à Internet à toutes les 5 minutes sur une période d'une #
#heure en générant un graphique.                                   #
####################################################################

#!/usr/bin/perl

#Variables de l'intervalle de temps.
my $temps_initial = time();
my $temps_final = $temps_initial + 3600;

#Fonction concernant la creation de trafic.
sub valeur_snmp {

    my @snmp = ("snmpwalk -Oqv -v2c -c public 192.168.198.128 ifInOctets.8 > snmpwalk");
    system @snmp;

    my $fichier = 'snmpwalk1';

	open(FH, '<', $fichier) or die $!;

	my $valeur = <FH>;

	close(FH);

	return $valeur;

}

#Creation de la base de donnees.
print "Veuillez patientez pendant que nous vérifions les informations de la base de donnees \n\n";
my @creation_donnees = ("rrdtool create trafic.rrd --start $temps_initial DS:trafic:COUNTER:600:0:11 RRA:AVERAGE:0.5:2:12");
system @creation_donnees;

#Somell permettant à la base de données de se creer avant de l'utiliser.
sleep(5);

#Boucle permettant d'effectuer le script dans un lapse de temps d'une heure.
while ( time() <= $temps_final ) {

	my $valeur_a_jour = valeur_snmp();
	my $temps_a_jour = time();

	#Mise à jour des données du trafic.
	my @rrdtool_a_jour = ("rrdtool update trafic.rrd $temps_a_jour:$valeur_a_jour");
	system @rrdtool_a_jour;

	print "temps:$temps_a_jour \n";
	print "valeurs:$valeur_a_Jour \n\n";

	#Opération consistant à générer la moyenne des valeurs.
	my @moyenne_rrd = ("rrdtool fetch trafic.rrd AVERAGE --start $temps_initial");
	system @moyenne_rrd;

	#Sommeil permettant d'effectuer l'affichage des données à chaque cinq minutes.
	sleep(300);
}

#Création du graphique représentant le trafic.
my @graphique = ("rrdtool graph graphique.png --end now --start end-3600s DEF:input=trafic.rrd:trafic:AVERAGE AREA:inputif9DDFD3:Trafic -v kbits/s -t trafic_entrant;");
system @graphique;