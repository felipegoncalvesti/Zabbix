#!/bin/bash

# Instalacao dos pacotes basicos 

apt install screen figlet toilet cowsay -y
figlet -c Zabbix By - Felipe
sleep 3
apt-get -y install vim nano figlet lolcat net-tools curl wget tcpdump
timedatectl set-timezone America/Fortaleza
apt update ; apt upgrade -y

#Instalacao dos Zabbix pacotes do zabbix

figlet -c Iniciando...
sleep 5

figlet -c Install-Zabbix 5.0
sleep 5

wget https://repo.zabbix.com/zabbix/5.0/debian/pool/main/z/zabbix-release/zabbix-release_5.0-2+debian11_all.deb
dpkg -i zabbix-release_5.0-2+debian11_all.deb
apt update
apt install -y zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-agent2

# Instalacao do Banco de dados:

export DEBIAN_FRONTEND=noninteractive

figlet -c Install - Mysql
sleep 5

apt install gnupg lsb-release -y
apt updade
apt install default-mysql-server -y
mysql -uroot -e "CREATE DATABASE zabbix CHARACTER SET utf8 COLLATE utf8_bin";
mysql -uroot -e "CREATE USER 'zabbix'@'localhost' identified by 'zabbix'";
mysql -uroot -e "GRANT ALL ON zabbix.* TO 'zabbix'@'localhost'";

mysql -uroot -e "SHOW DATABASES";
mysql -uroot -e "SELECT host, user FROM mysql.user";
mysql -uroot -e "SHOW GRANTS FOR 'zabbix'@'localhost'";

# Importando o esquema de tabelas

figlet -w 100 -f smmono9 "Importando tabelas!"
figlet -w 100 -f smmono9 "Aguarde, pode demorar."

zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -uroot zabbix

# Ajustando a senha do banco do zabbix no arquivo de configuracao.

sed -i "s/^#\s*\(DBPassword=\).*/\1zabbix/" /etc/zabbix/zabbix_server.conf

systemctl restart zabbix-server

# Ajustando o timezone do apache

sed -i 's/;date.timezone =/date.timezone = America\/Fortaleza/' /etc/php/7.4/apache2/php.ini

service apache2 restart

# Inciando o servicos do zabbix

systemctl start zabbix-server zabbix-agent2 apache2
systemctl enable zabbix-server zabbix-agent2 apache2
systemctl restart zabbix-server zabbix-agent2 apache2

# Instalando pacote de idioma pt-BR

sed -i '/^# *pt_BR.UTF-8 UTF-8/s/^# *//' /etc/locale.gen
locale-gen pt_BR.UTF-8
service apache2 restart

# Instalcao Grafana 

figlet -c Install-Grafana
sleep 5

apt-get install -y adduser libfontconfig1 musl
wget https://dl.grafana.com/enterprise/release/grafana-enterprise_10.0.0_amd64.deb
dpkg -i grafana-enterprise_10.0.0_amd64.deb

grafana-cli plugins install alexanderzobnin-zabbix-app
grafana-cli plugins update alexanderzobnin-zabbix-app
service grafana-server restart

systemctl enable grafana-server.service
service grafana-server start

figlet -c Instalacao Finalizada.
sleep 3

echo "Acesso ao zabbix: http://ip/zabbix"
echo "........"
echo "Usuario:Admin"
echo "Senha: zabbix"
echo "........"
echo "Acesso ao grafana: http://ip:3000"
echo "........"
echo "Usuario: admin"
echo "Senha: admin"
echo "........"
echo "A senha que foi usada no banco de dados do zabbix eh 'zabbix' tudo minusculo, fique a vontade para troca-la."
""