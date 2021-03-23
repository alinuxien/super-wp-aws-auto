# WordPress Survitaminé chez AWS avec Supervision Elastic Stack

# Bienvenue sur mon projet de migration vers le Cloud AWS d'un Site Wordpress et de mise en place d'une Supervision Kibana
Il s'agit de 2 projets réalisés, pour le premier en Octobre et Novembre 2020, et pour le second en Février et Mars 2021, dans le cadre de ma formation "Expert DevOps" chez OpenClassRooms.

## Ca fait quoi ?
L'ensemble des scripts permet la création d'une Infrastructure solide chez AWS en vue de l'hébergement d'un Site Web Wordpress, auquel vient s'ajouter la mise en place d'une Supervision Elastic Stack, automatisée elle-aussi.

Pour assurer cette solidité, 2 instances seront utilisées pour servir les pages Web, placées derrière un Load Balancer, auquel s'ajoute un Cluster Memcached et un CDN CloudFront !

Certaines briques sont créées en utilisant des SAAS Amazon, permettant de facilement monter la puissance disponible ( et la facture en conséquence... ). Il s'agit du Cluster MemCached ( Elastic Cache ), du serveur de Base de Données ( RDS MySQL ), et du CND CloudFront.

Il n'y pas de Auto Scaling Group dans ce projet, car hors cadre...

Lorsque les scripts ont terminé leurs oeuvres, il ne reste plus qu'à déposer le contenu d'une sauvegarde de BDD Wordpress, ou commencer à réaliser son site de zéro.

Pour la Supervision, les 2 instances de serveur web sont équipées de FileBeat et MetricBeat. Un cluster ElasticSearch équipé de Kibana est instancié en mode SAAS.

A cela s'ajoute 2 instances LogStash ( 1 par zone de disponibilité pour assurer la disponibilité en cas de défaillance d'une zone ).

MetricBeat envoi les données de métriques des serveurs web directement à ElasticSearch.

Filebeat envoi les données de log à LogStash, qui va les transformer avant de les envoyer à ElasticSearch.

Enfin, Kibana consomme les données de ElasticSearch pour les mettre à disposition dans des Index Pattern, des visualisations et 1 Dashboard Global de Supervision.

En option, 1 environnement de travail virtuel est [disponible ici](https://github.com/alinuxien/terraform)

## Ca ressemble à quoi ?
![Vue Globale de l'Infrastructure Cloud](https://github.com/alinuxien/super-wp-aws-auto/raw/main/MlleC%20Global.png)

## Contenu ?
- 1 dossier `terraform` contenant tout le nécessaire pour la création d'infrastructure
- 1 dossier `ansible` contenant tout le nécessaire pour la configuration des 2 serveurs web
- 1 fichier `mllec-kibana-dashboard.ndjson` contenant le Dashboard Kibana
- 1 fichier `config` contenant de la configuration ssh pour permettre le tunneling avec jump ssh

## J'ai besoin de quoi ?
- 1 nom de domaine, hébergé chez AWS ou n'importe quel provider DNS ( OVH par exemple )
- 1 environnement de travail contenant Terraform et Ansible ( [disponible ici](https://github.com/alinuxien/terraform) )
- 1 compte AWS, et je conseille de créer 1 utilisateur AWS IAM dédié ( pour des raisons de sécurité ) avec les droits de `AdministratorAccess`, configuré dans l'environnement de travail ( `aws configure` )

## Comment ça s'utilise ?
Chez AWS : 

- créez une zone hébergée sur votre nom de domaine ( ou sous-domaine ), service `Route 53`
- notez les noms des 4 serveurs DNS apparus dans l'enregistrement de type `NS`, et réalisez la redirection chez votre provider DNS ( 4 enregistrements de type `NS` aussi, je ne m'étale pas sur ce point )
- créez un certificat AWS ACM, service `Certificate Manager`, avec validation par DNS, avec l'assitance automatique `Route 53` ( puisque c'est maintenant lui qui gère le domaine / sous-domaine )


Ensuite, dans un terminal de l'environnement de travail :

- générez une paire de clés SSH qui seront utilisées pour la création des instances EC2 chez AWS, dans le dossier de votre choix : `ssh-keygen -f chemin-au-choix/nom-de-la-clé-au-choix`
- faites une copie locale de ce dépot :  `git clone https://github.com/alinuxien/super-wp-aws-auto.git`
- allez dans le dossier téléchargé : `cd super-wp-aws-auto`, puis dans le dossier terraform : `cd terraform`
- éditez le fichier `terraform.tfvars` pour le personnaliser, notamment l'emplacement de la paire de clés ( privée et publique ), le nom de la base de données à créer ainsi que l'utilisateur et mot de passe de base de données à créer, l'emplacement de la racine du serveur web ( dépend de l'image AMI utilisée ), et le reste qui est assez explicite.
- ajustez le fichier `config` avec le chemin et le nom que vous avez choisi pour la votre ( remplacez `~/OCR/P10/MlleC/ssh/id_rsa_aws` par `chemin-au-choix/nom-de-la-clé-au-choix` ) dans chacune des 5 entrées, et ensuite placez ce fichier dans votre dossier ssh : `~/.ssh`

Pour information, Terraform utilise 2 fichiers pour gérer les variables : `vars.tf` pour déclarer les variables et éventuellement leur donner une valeur par défaut, et `terraform.tfvars` pour spécifier la valeur des variables si elles n'ont pas valeur par défaut ou changer la valeur par défaut.

- `terraform init` pour initialiser 
- en option : `terraform fmt` pour nettoyer le formatage des fichiers, et `terraform validate` pour s'assurer qu'il n'y pas d'erreur de syntaxe.
- `terraform apply` pour lancer la création, avec confirmation après analyse : `yes`

Terraform va créer toute l'infrastructure, et ensuite lancer les playbooks Ansible pour la gestion de configuration. Enfin, les résultats obtenus s'afficheront dans la console : adresses IP, nom DNS des machines,... Notez bien le `memcached_configuration_endpoint`.

Il ne reste plus qu'à aller naviguer sur le site pour vérifier que tout fonctionne, et aller dans la partie admin, lien `Log in` -> `Settings` -> `WP-FFPC`, pour :

- dans l'onglet `Debug & in-depth`, cocher `Enable X-Pingback header preservation` et `Add X-Cache-Engine header`
- dans l'onglet `Backend settings`, dans `Hosts`, mettre la valeur du `memcached_configuration_endpoint`
- et surtout, cliquer sur le bouton `Save Changes` en bas pour validation 

Pour accéder à Kibana, il faut copier la commande ssh disponible en output de Terraform, et l'exécuter dans un terminal de votre machine ( l'hôte ! pas la VM ! ).

Cette commande ssh met en place un tunneling ssh entre votre machine et l'instance qui héberge Kibana chez AWS, via un jump ssh par le bastion.

A partir de là, vous pouvez accéder à Kibana dans votre navigateur web à l'adresse https://localhost:1443/_plugin/kibana

Le navigateur web va vous signaler un problème de sécurité, qu'il faut ignorer pour continuer sur le site de Kibana.

Pourquoi ? Simplement parce que je n'ai pas déployer de certificat de sécurité pour Kibana, étant donné que le cluster ElasticSearch qui l'héberge n'est pas disponible depuis le web, sauf au travers du bastion SSH, et le tunneling ssh est sécurité et crypté, écartant tout risque d'interception...

Pour mettre en place la Supervision, il faut commencer par gérer les Index Pattern, dans le menu Management -> Stack Management -> Index patterns.

Commencez par supprimer celui nommé `filebeat-*` et définir celui nommé `metricbeat-*` comme Index Pattern par défaut.

Pour finir, vous allez importer le Dashboard fourni ( `mllec-kibana-dashboard.ndjson` ) dans le menu Management -> Stack Management -> Saved objects.

Et voilà! Vous pouvez visualiser le Dashboard dans le menu Kibana -> Dashboard en sélectionnant celui nommé `MlleC - Global`.

En bonus, je vous invite à mettre en place un système d'alerte par Slack, par exemple lorsque le disque dur atteint 95% d'espace occupé ( index `metricbeat-*` et champ `system.filesystem.used.pct` ), ou autre, dans le menu Kibana -> Alerting.

# Et après ?
Au choix, soit vous créez votre site de zéro ( mais ça m'étonnerait avec une infrastructure pareille ), soit vous importez une sauvegarde de votre base de données de votre site Wordpress existant avec votre client mysql favori.

