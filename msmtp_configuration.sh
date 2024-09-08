#!/bin/bash

# Vérifier si le script est exécuté en tant que root
if [ "$(id -u)" -ne 0 ]; then
    echo "Veuillez exécuter ce script en tant que root."
    exit 1
fi

# Installer msmtp-mta
echo "Installation de msmtp-mta..."
apt update && apt install -y msmtp msmtp-mta

# Créer le groupe msmtp_users s'il n'existe pas déjà
if ! getent group msmtp_users > /dev/null; then
    echo "Création du groupe msmtp_users..."
    groupadd msmtp_users
fi

# Ajouter l'utilisateur au groupe msmtp_users
read -p "Entrez le nom de l'utilisateur à ajouter au groupe msmtp_users : " utilisateur_cible
usermod -aG msmtp_users "$utilisateur_cible"

# Configurer les droits pour le fichier log
touch /var/log/msmtp
chmod 640 /var/log/msmtp
chown root:msmtp_users /var/log/msmtp

# Variables
FICHIER_CONFIG="/etc/msmtprc"
CONFIG_PAR_DEFAUT="
# Valeurs par défaut pour tous les comptes.
defaults
auth           on
tls            on
tls_starttls   on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
logfile        /var/log/msmtp
"

# Écrire les paramètres par défaut dans /etc/msmtprc
echo "$CONFIG_PAR_DEFAUT" > $FICHIER_CONFIG

# Choisir le compte à configurer
echo "Sélectionnez le compte à configurer :"
echo "1) Gmail"
echo "2) GMX"
echo "3) OVH MX PLAN"
echo "4) OVH E-MAIL PRO"
echo "5) Infomaniak"
echo "6) Mailhog"
echo "7) riseUP"
echo "8) Free"
echo "9) Free2"
echo "10) Gandi"
read -p "Entrez le numéro correspondant à votre choix : " choix

# Demander les informations nécessaires pour chaque compte
read -p "Entrez votre adresse e-mail : " email
read -p "Entrez votre nom d'utilisateur (le plus souvent, votre adresse e-mail complète) : " utilisateur
read -p "Entrez votre mot de passe : " -s mot_de_passe
echo

# Variables de configuration en fonction du choix
case $choix in
    1)
        compte="gmail"
        serveur="smtp.gmail.com"
        port="587"
        ;;
    2)
        compte="gmx"
        serveur="mail.gmx.com"
        port="587"
        tls_nocertcheck="tls_nocertcheck"
        ;;
    3)
        compte="ovh"
        serveur="ssl0.ovh.net"
        port="465"
        ;;
    4)
        compte="ovh"
        serveur="proX.mail.ovh.net"
        port="587"
        ;;
    5)
        compte="infomaniak"
        serveur="mail.infomaniak.com"
        port="587"
        ;;
    6)
        compte="mailhog"
        serveur="localhost"
        port="1024"
        auth="off"
        tls="off"
        tls_starttls="off"
        ;;
    7)
        compte="riseup"
        serveur="smtp.riseup.net"
        port="587"
        ;;
    8)
        compte="free1"
        serveur="smtp.free.fr"
        port="25"
        tls="off"
        auth="off"
        ;;
    9)
        compte="free2"
        serveur="smtp.free.fr"
        port="587"
        auth="off"
        ;;
    10)
        compte="gandi"
        serveur="mail.gandi.net"
        port="587"
        ;;
    *)
        echo "Choix invalide."
        exit 1
        ;;
esac

# Construire le contenu de la configuration pour le compte choisi
config_compte="
# Configuration pour le compte $compte
account        $compte
auth           ${auth:-plain}
host           $serveur
port           $port
from           $email
user           $utilisateur
password       $mot_de_passe
tls            ${tls:-on}
tls_starttls   ${tls_starttls:-on}
${tls_nocertcheck:-}
"

# Écrire la configuration dans /etc/msmtprc
echo "$config_compte" >> $FICHIER_CONFIG

# Définir le compte par défaut
echo "
# Définir le compte par défaut
account default : $compte
" >> $FICHIER_CONFIG

# Restreindre les permissions du fichier de configuration 
chown root:msmtp_users $FICHIER_CONFIG
chmod 640 $FICHIER_CONFIG

# Créer le fichier .msmtprc dans le home de l'utilisateur
REPERTOIRE_UTILISATEUR=$(eval echo ~$utilisateur_cible)
FICHIER_CONFIG_UTILISATEUR="$REPERTOIRE_UTILISATEUR/.msmtprc"

echo "$CONFIG_PAR_DEFAUT" > $FICHIER_CONFIG_UTILISATEUR
echo "$config_compte" >> $FICHIER_CONFIG_UTILISATEUR

# Définir le compte par défaut pour l'utilisateur aussi
echo "
# Définir le compte par défaut
account default : $compte
" >> $FICHIER_CONFIG_UTILISATEUR

# Restreindre les permissions du fichier de configuration de l'utilisateur
chown "$utilisateur_cible:$utilisateur_cible" $FICHIER_CONFIG_UTILISATEUR
chmod 600 $FICHIER_CONFIG_UTILISATEUR

echo "Configuration terminée pour le compte $compte. Les fichiers /etc/msmtprc et $FICHIER_CONFIG_UTILISATEUR ont été mis à jour."
