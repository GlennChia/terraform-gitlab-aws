#! /bin/bash

# Install the ssm agent
mkdir /tmp/ssm
cd /tmp/ssm
wget https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_amd64/amazon-ssm-agent.deb
sudo dpkg -i amazon-ssm-agent.deb
sudo systemctl enable amazon-ssm-agent

# Create the praefect role
cd ~
sudo /opt/gitlab/embedded/bin/psql -U ${rds_username} -h ${rds_address} -d template1
${rds_password}
CREATE ROLE praefect WITH LOGIN CREATEDB PASSWORD \'${praefect_sql_password}\';
\q
# Create a new database
sudo /opt/gitlab/embedded/bin/psql -U praefect -h ${rds_address} -d template1
${praefect_sql_password}
CREATE DATABASE praefect_production WITH ENCODING=UTF8;
\q

# Configure Gitlab
sudo su
sudo apt-get update
sudo apt-get install -y curl openssh-server ca-certificates
curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.deb.sh | sudo bash
sudo apt-get install gitlab-ee=13.2.3-ee.0
cd /etc/gitlab

# Disable all other services on the Praefect node
sed -i "s/# postgresql\['enable'\] = true/postgresql\['enable'\] = false/" gitlab.rb
sed -i "s/# redis\['enable'\] = true/redis\['enable'\] = false/" gitlab.rb
sed -i "s/# nginx\['enable'\] = true/nginx\['enable'\] = false/" gitlab.rb
sed -i "s/# alertmanager\['enable'\] = true/alertmanager\['enable'\] = false/" gitlab.rb
sed -i "s/# prometheus\['enable'\] = true/prometheus\['enable'\] = false/" gitlab.rb
sed -i "s/# grafana\['enable'\] = true/grafana\['enable'\] = false/" gitlab.rb
sed -i "s/# puma\['enable'\] = true/puma\['enable'\] = false/" gitlab.rb
# Sidekiq is not found in the rb file
sed -i "s/# sidekiq\['enable'\] = true/sidekiq\['enable'\] = false/" gitlab.rb
sed -i "s/# gitlab_workhorse\['enable'\] = true/gitlab_workhorse\['enable'\] = false/" gitlab.rb
sed -i "s/# gitaly\['enable'\] = true/gitaly\['enable'\] = false/" gitlab.rb
# Enable only the Praefect service
sed -i "s/# praefect\['enable'\] = false/praefect\['enable'\] = true/" gitlab.rb
# Prevent database connections during 'gitlab-ctl reconfigure'
sed -i "s/# gitlab_rails\['rake_cache_clear'\] = true/gitlab_rails\['rake_cache_clear'\] = false/" gitlab.rb
sed -i "s/# gitlab_rails\['auto_migrate'\] = true/gitlab_rails\['auto_migrate'\] = false/" gitlab.rb
# Configure Praefect to listen on network interfaces
sed -i "s/# praefect\['listen_addr'\] = .*/praefect\['listen_addr'\] = '0.0.0.0:2305'/" gitlab.rb
sed -i "s/# praefect\['prometheus_listen_addr'\] = .*/praefect\['prometheus_listen_addr'\] = '0.0.0.0:9652'/" gitlab.rb
# Configure a strong auth_token for Praefect. This is an external token
sed -i "s/# praefect\['auth_token'\] = .*/praefect\['auth_token'\] = \"${praefect_external_token}\"/" gitlab.rb
# Configure the Praefect cluster to connect to each Gitaly node in the cluster
sed -i "s/# praefect\['database_host'\] = .*/praefect\['database_host'\] = \"${rds_address}\"/" gitlab.rb
sed -i "s/# praefect\['database_port'\] = .*/praefect\['database_port'\] = 5432/" gitlab.rb
sed -i "s/# praefect\['database_user'\] = .*/praefect\['database_user'\] = 'praefect'/" gitlab.rb
sed -i "s/# praefect\['database_password'\] = .*/praefect\['database_password'\] = \"${praefect_sql_password}\"/" gitlab.rb
sed -i "s/# praefect\['database_dbname'\] = .*/praefect\['database_dbname'\] = 'praefect_production'/" gitlab.rb
# Configure the Praefect cluster to connect to each Gitaly nod
perl -i -pe "BEGIN{undef $/;} s/# praefect\['virtual_storages'] = \{.*?# \}/praefect['virtual_storages'] = {\n  \"default\" => {\n    \"gitaly-1\" => {\n      'address' => 'tcp:\/\/${gitaly_address1}:8075',\n      'token' => '${praefect_internal_token}',\n      'primary' => true\n    },\n    \"gitaly-2\" => {\n      'address' => 'tcp:\/\/${gitaly_address2}:8075',\n      'token' => '${praefect_internal_token}'\n    },\n    \"gitaly-3\" => {\n      'address' => 'tcp:\/\/${gitaly_address3}:8075',\n      'token' => '${praefect_internal_token}'\n    }\n  }\n}/smg" gitlab.rb

sudo gitlab-ctl reconfigure
sudo gitlab-ctl restart praefect

# Verify
# sudo -u git /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml sql-ping