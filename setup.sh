sudo apt update
sudo apt install -y libpq5 redis-server nginx supervisor git
wget https://packaging.ckan.org/python-ckan_2.9-py3-focal_amd64.deb
sudo dpkg -i python-ckan_2.9-py3-focal_amd64.deb
sudo apt install -y postgresql
sudo -u postgres createuser -S -D -R -P ckan_default
sudo -u postgres createdb -O ckan_default ckan_default -E utf-8
sudo sed -i '/sqlalchemy.url =/c\sqlalchemy.url = postgresql://ckan_default:123456@localhost/ckan_default' /etc/ckan/default/ckan.ini
sudo sed -i '/ckan.site_url =/c\ckan.site_url = http://35.172.184.129' /etc/ckan/default/ckan.ini
sudo apt install -y solr-tomcat
sudo sed -i '/port="8080"/c\    <Connector port="8983" protocol="HTTP/1.1"' /etc/tomcat9/server.xml
sudo mv /etc/solr/conf/schema.xml /etc/solr/conf/schema.xml.bak
sudo ln -s /usr/lib/ckan/default/src/ckan/ckan/config/solr/schema.xml /etc/solr/conf/schema.xml
sudo service tomcat9 restart
sudo sed -i '/#solr_url =/c\solr_url = http://127.0.0.1:8983/solr' /etc/ckan/default/ckan.ini
sudo ckan db init
sudo supervisorctl reload
sudo service nginx restart
sudo ckan -c /etc/ckan/default/ckan.ini sysadmin add admin email=admin@localhost name=admin
sudo -u postgres createuser -S -D -R -P -l datastore_default
sudo -u postgres createdb -O ckan_default datastore_default -E utf-8
sudo sed -i '/#ckan.datastore.write_url/c\ckan.datastore.write_url = postgresql://ckan_default:123456@localhost/datastore_default' /etc/ckan/default/ckan.ini
sudo sed -i '/#ckan.datastore.read_url/c\ckan.datastore.read_url = postgresql://datastore_default:123456@localhost/datastore_default' /etc/ckan/default/ckan.ini
sudo ckan -c /etc/ckan/default/ckan.ini datastore set-permissions | sudo -u postgres psql --set ON_ERROR_STOP=1
sudo supervisorctl reload
sudo mkdir -p /var/lib/ckan/default
sudo chown www-data /var/lib/ckan/default
sudo chmod u+rwx /var/lib/ckan/default
