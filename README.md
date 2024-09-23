README
SCRIPT DE CONFIGURATION DE MSMTP

Ce script permet de configurer automatiquement le client de messagerie msmtp sur un système Linux. Il prend en charge plusieurs services de messagerie populaires (Gmail, GMX, OVH, Infomaniak, Free, Gandi, etc.) et configure à la fois le fichier global /etc/msmtprc et le fichier utilisateur ~/.msmtprc.

FONCTIONNALITÉS : 
. Configure automatiquement un compte de messagerie avec msmtp.Supporte plusieurs services de messagerie populaires.
. Crée un fichier de configuration global dans /etc/msmtprc.
. Crée un fichier de configuration utilisateur dans ~/.msmtprc.
. Assure que les fichiers de configuration et le journal de msmtp ont des permissions sécurisées.
. Gère les permissions de manière sécurisée avec le groupe msmtp_users pour restreindre l'accès aux fichiers sensibles.

Le script génère les fichiers suivants :
/etc/msmtprc : Fichier de configuration global pour msmtp.
~/.msmtprc : Fichier de configuration personnel pour l'utilisateur spécifié.

Permissions :
Les fichiers de configuration sont sécurisés avec des permissions strictes (640 pour /etc/msmtprc et 600 pour ~/.msmtprc).
Un groupe msmtp_users est créé, et l'utilisateur ciblé est ajouté à ce groupe pour lui permettre de lire le fichier journal de msmtp.

NOTES DE SÉCURITÉ : 
Mot de passe en clair : Le mot de passe est stocké en texte clair dans les fichiers de configuration. Pour des raisons de sécurité, il est recommandé de restreindre les permissions de ces fichiers.

EWEMPLE DE CONFIGURATION : 
Voici un exemple de configuration pour un compte Gmail :

#Configuration pour le compte Gmail
account        gmail
auth           plain
host           smtp.gmail.com
port           587
from           user@gmail.com
user           user@gmail.com
password       motdepasse
tls            on
tls_starttls   on

#Définir le compte par défaut
account default : gmail
