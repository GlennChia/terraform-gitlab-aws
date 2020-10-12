#! /bin/bash

# Install the ssm agent
mkdir /tmp/ssm
cd /tmp/ssm
wget https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_amd64/amazon-ssm-agent.deb
sudo dpkg -i amazon-ssm-agent.deb
sudo systemctl enable amazon-ssm-agent

# Configure Gitlab
sudo su
sudo apt-get update
sudo apt-get install -y curl openssh-server ca-certificates
curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.deb.sh | sudo bash
sudo apt-get install gitlab-ee=13.2.3-ee.0
cd /etc/gitlab
sed -i "s/# letsencrypt\['enable'\] = nil/letsencrypt\['enable'\] = false/" gitlab.rb

# Install the pg_trgm extension for PostgreSQL
sudo /opt/gitlab/embedded/bin/psql -U gitlab -h ${rds_address} -d gitlabhq_production
${rds_password}
# Once inside the database
CREATE EXTENSION pg_trgm;
CREATE EXTENSION btree_gist;
\q

# Configure GitLab to connect to PostgreSQL and Redis
if [[ ${visibility} = "private" ]]
then
  sed -i "s+external_url 'http://gitlab.example.com'+external_url 'http://${dns_name}'+" gitlab.rb
elif [[ ${visibility} = "public" ]]
then
  export HOST_NAME=$(curl http://169.254.169.254/latest/meta-data/public-hostname)
  sed -i "s+external_url 'http://gitlab.example.com'+external_url 'http://$HOST_NAME'+" gitlab.rb
fi
sed -i "s/# postgresql\['enable'\] = true/postgresql\['enable'\] = false/" gitlab.rb
sed -i "s/# gitlab_rails\['db_adapter'\]/gitlab_rails\['db_adapter'\]/" gitlab.rb
sed -i "s/# gitlab_rails\['db_encoding'\]/gitlab_rails\['db_encoding'\]/" gitlab.rb
sed -i "s/# gitlab_rails\['db_database'\] = .*/gitlab_rails\['db_database'\] = \"${rds_name}\"/" gitlab.rb
sed -i "s/# gitlab_rails\['db_username'\] = .*/gitlab_rails\['db_username'\] = \"${rds_username}\"/" gitlab.rb
sed -i "s/# gitlab_rails\['db_password'\] = .*/gitlab_rails\['db_password'\] = \"${rds_password}\"/" gitlab.rb
sed -i "s/# gitlab_rails\['db_host'\] = .*/gitlab_rails\['db_host'\] = \"${rds_address}\"/" gitlab.rb
sed -i "s/# redis\['enable'\] = true/redis\['enable'\] = false/" gitlab.rb
sed -i "s/# gitlab_rails\['redis_host'\] = .*/gitlab_rails\['redis_host'\] = \"${redis_address}\"/" gitlab.rb
sed -i "s/# gitlab_rails\['redis_port'\]/gitlab_rails\['redis_port'\]/" gitlab.rb

# Configure S3 integration
sed -i "s/gitlab_rails\['object_store'\]\['enabled'\] = false/gitlab_rails\['object_store'\]\['enabled'\] = true/" gitlab.rb
sed -i "s/gitlab_rails\['object_store'\]\['proxy_download'\] = false/gitlab_rails\['object_store'\]\['proxy_download'\] = true/" gitlab.rb
sed -i "s/gitlab_rails\['object_store'\]\['connection'\] = {}/gitlab_rails\['object_store'\]\['connection'\] = \{\n  'provider' => 'AWS',\n  'region' => '${region}',\n  'use_iam_profile' => true\n\}/" gitlab.rb
sed -i "s/gitlab_rails\['object_store'\]\['objects'\]\['artifacts'\]\['bucket'\] = nil/gitlab_rails\['object_store'\]\['objects'\]\['artifacts'\]\['bucket'\] = '${artifacts_bucket}'/" gitlab.rb
sed -i "s/gitlab_rails\['object_store'\]\['objects'\]\['external_diffs'\]\['bucket'\] = nil/gitlab_rails\['object_store'\]\['objects'\]\['external_diffs'\]\['bucket'\] = '${external_diffs_bucket}'/" gitlab.rb
sed -i "s/gitlab_rails\['object_store'\]\['objects'\]\['lfs'\]\['bucket'\] = nil/gitlab_rails\['object_store'\]\['objects'\]\['lfs'\]\['bucket'\] = '${lfs_objects_bucket}'/" gitlab.rb
sed -i "s/gitlab_rails\['object_store'\]\['objects'\]\['uploads'\]\['bucket'\] = nil/gitlab_rails\['object_store'\]\['objects'\]\['uploads'\]\['bucket'\] = '${uploads_bucket}'/" gitlab.rb
sed -i "s/gitlab_rails\['object_store'\]\['objects'\]\['packages'\]\['bucket'\] = nil/gitlab_rails\['object_store'\]\['objects'\]\['packages'\]\['bucket'\] = '${packages_bucket}'/" gitlab.rb
sed -i "s/gitlab_rails\['object_store'\]\['objects'\]\['dependency_proxy'\]\['bucket'\] = nil/gitlab_rails\['object_store'\]\['objects'\]\['dependency_proxy'\]\['bucket'\] = '${dependency_proxy_bucket}'/" gitlab.rb
sed -i "s/gitlab_rails\['object_store'\]\['objects'\]\['terraform_state'\]\['bucket'\] = nil/gitlab_rails\['object_store'\]\['objects'\]\['terraform_state'\]\['bucket'\] = '${terraform_state_bucket}'/" gitlab.rb

# Configure Gitaly client
if [[ ${gitaly_config} = "instance" ]]
then
  sed -i "s/# gitlab_rails\['gitaly_token'\] = .*/gitlab_rails\['gitaly_token'\] = \"${gitaly_token}\"/" gitlab.rb
  perl -i -pe "BEGIN{undef $/;} s/# git_data_dirs\(\{.*?# \}\)/git_data_dirs({\n  \"default\" => { \"gitaly_address\" => \"tcp:\/\/${gitaly_address1}:8075\" },\n  \"storage1\" => { \"gitaly_address\" => \"tcp:\/\/${gitaly_address1}:8075\" },\n})/smg" gitlab.rb
elif [[ ${gitaly_config} = "clustered" ]]
then
  sed -i "s/# gitaly\['enable'\] = true/gitaly\['enable'\] = false/" gitlab.rb
  perl -i -pe "BEGIN{undef $/;} s/# git_data_dirs\(\{.*?# \}\)/git_data_dirs({\n  \"default\" => {\n    \"gitaly_address\" => \"tcp:\/\/${prafect_loadbalancer_dns_name}:2305\",\n    \"gitaly_token\" => \"${praefect_external_token}\"\n  }\n})/smg" gitlab.rb
  perl -i -pe "BEGIN{undef $/;} s/# prometheus\['scrape_configs'] = \[.*?# ]/prometheus['scrape_configs'] = [\n  {\n    'job_name' => 'praefect',\n    'static_configs' => [\n      'targets' => [\n        '${praefect_address1}:9652',\n        '${praefect_address2}:9652',\n        '${praefect_address3}:9652'\n      ]\n    ]\n  },\n  {\n    'job_name' => 'praefect-gitaly',\n    'static_configs' => [\n      'targets' => [\n        '${gitaly_address1}:9236',\n        '${gitaly_address2}:9236',\n        '${gitaly_address3}:9236'\n      ]\n    ]\n  }\n]/smg" gitlab.rb
fi
echo "gitlab_shell['secret_token'] = \"${secret_token}\"" >> gitlab.rb

# Configure Prometheus 
sed -i "s/# prometheus\['enable'\] = .*/prometheus\['enable'\] = true/" gitlab.rb
sed -i "s/# prometheus\['listen_address'\] = .*/prometheus\['listen_address'\] = ':9090'/" gitlab.rb

# Configure grafana
sed -i "s/# grafana\['disable_login_form'\] = .*/grafana\['disable_login_form'\] = false/" gitlab.rb
sed -i "s/# grafana\['admin_password'\] = .*/grafana\['admin_password'\] = '${grafana_password}'/" gitlab.rb

# Configure host keys
sudo mkdir /etc/ssh_static
sudo cp -R /etc/ssh/* /etc/ssh_static
cd /etc/ssh_static
sed -i "s+HostKey /etc/ssh+HostKey /etc/ssh_static+" sshd_config

sudo gitlab-ctl reconfigure
gitlab-rake gitlab:lfs:migrate


# Run a check and a service status to make sure everything has been setup correctly
# sudo gitlab-rake gitlab:check
# sudo gitlab-ctl status
# sudo gitlab-rake gitlab:gitaly:check