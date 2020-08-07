#! /bin/bash

# Install the ssm agent
mkdir /tmp/ssm
cd /tmp/ssm
wget https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_amd64/amazon-ssm-agent.deb
sudo dpkg -i amazon-ssm-agent.deb
sudo systemctl enable amazon-ssm-agent

# GitLab install starts here
sudo su
sudo apt-get update
sudo apt-get install -y curl openssh-server ca-certificates
curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.deb.sh | sudo bash
sudo apt-get install gitlab-ee=13.1.4-ee.0
cd /etc/gitlab
sed -i "s/# letsencrypt\['enable'\] = nil/letsencrypt\['enable'\] = false/" gitlab.rb
sudo gitlab-ctl reconfigure

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
sed -i "s/# gitlab_rails\['db_database'\]/gitlab_rails\['db_database'\]/" gitlab.rb
sed -i "s/# gitlab_rails\['db_username'\]/gitlab_rails\['db_username'\]/" gitlab.rb
sed -i "s/# gitlab_rails\['db_password'\] = .*/gitlab_rails\['db_password'\] = \"${rds_password}\"/" gitlab.rb
sed -i "s/# gitlab_rails\['db_host'\] = .*/gitlab_rails\['db_host'\] = \"${rds_address}\"/" gitlab.rb
sed -i "s/# redis\['enable'\] = true/redis\['enable'\] = false/" gitlab.rb
sed -i "s/# gitlab_rails\['redis_host'\] = .*/gitlab_rails\['redis_host'\] = \"${redis_address}\"/" gitlab.rb
sed -i "s/# gitlab_rails\['redis_port'\]/gitlab_rails\['redis_port'\]/" gitlab.rb
sudo gitlab-ctl reconfigure

# Configure host keys
sudo mkdir /etc/ssh_static
sudo cp -R /etc/ssh/* /etc/ssh_static
cd /etc/ssh_static
sed -i "s+HostKey /etc/ssh+HostKey /etc/ssh_static+" sshd_config

# configure artifacts bucket
cd /etc/gitlab
sed -i "s/# gitlab_rails\['artifacts_enabled'\]/gitlab_rails\['artifacts_enabled'\]/" gitlab.rb
sed -i "s/# gitlab_rails\['artifacts_object_store_enabled'\] = false/gitlab_rails\['artifacts_object_store_enabled'\] = true/" gitlab.rb
sed -i "s/# gitlab_rails\['artifacts_object_store_remote_directory'\] = .*/gitlab_rails\['artifacts_object_store_remote_directory'\] = \"${artifacts_bucket}\"/" gitlab.rb
perl -i -pe "BEGIN{undef $/;} s/# gitlab_rails\['artifacts_object_store_connection.*?# }/gitlab_rails['artifacts_object_store_connection'] = \{\n  'provider' => 'AWS',\n  'region' => '${region}',\n  'use_iam_profile' => true\n\}/smg" gitlab.rb

# configure lfs objects bucket
sed -i "s/# gitlab_rails\['lfs_object_store_enabled'\] = false/gitlab_rails\['lfs_object_store_enabled'\] = true/" gitlab.rb
sed -i "s/# gitlab_rails\['lfs_object_store_remote_directory'\] = .*/gitlab_rails\['lfs_object_store_remote_directory'\] = \"${lfs_objects_bucket}\"/" gitlab.rb
perl -i -pe "BEGIN{undef $/;} s/# gitlab_rails\['lfs_object_store_connection.*?# }/gitlab_rails['lfs_object_store_connection'] = \{\n  'provider' => 'AWS',\n  'region' => '${region}',\n  'use_iam_profile' => true\n\}/smg" gitlab.rb

# Configure uploads storage
sed -i "s/# gitlab_rails\['uploads_object_store_enabled'\] = false/gitlab_rails\['uploads_object_store_enabled'\] = true/" gitlab.rb
sed -i "s/# gitlab_rails\['uploads_object_store_remote_directory'\] = .*/gitlab_rails\['uploads_object_store_remote_directory'\] = \"${uploads_bucket}\"/" gitlab.rb
perl -i -pe "BEGIN{undef $/;} s/# gitlab_rails\['uploads_object_store_connection.*?# }/gitlab_rails['uploads_object_store_connection'] = \{\n  'provider' => 'AWS',\n  'region' => '${region}',\n  'use_iam_profile' => true\n\}/smg" gitlab.rb

# configure packages bucket
sed -i "s/# gitlab_rails\['packages_enabled'\]/gitlab_rails\['packages_enabled'\]/" gitlab.rb
sed -i "s/# gitlab_rails\['packages_storage_path'\]/gitlab_rails\['packages_storage_path'\]/" gitlab.rb
sed -i "s/# gitlab_rails\['packages_object_store_enabled'\] = false/gitlab_rails\['packages_object_store_enabled'\] = true/" gitlab.rb
sed -i "s/# gitlab_rails\['packages_object_store_remote_directory'\] = .*/gitlab_rails\['packages_object_store_remote_directory'\] = \"${packages_bucket}\"/" gitlab.rb
sed -i "s/# gitlab_rails\['packages_object_store_direct_upload'\]/gitlab_rails\['packages_object_store_direct_upload'\]/" gitlab.rb
sed -i "s/# gitlab_rails\['packages_object_store_background_upload'\]/gitlab_rails\['packages_object_store_background_upload'\]/" gitlab.rb
sed -i "s/# gitlab_rails\['packages_object_store_proxy_download'\]/gitlab_rails\['packages_object_store_proxy_download'\]/" gitlab.rb
perl -i -pe "BEGIN{undef $/;} s/# gitlab_rails\['packages_object_store_connection.*?# }/gitlab_rails['packages_object_store_connection'] = \{\n  'provider' => 'AWS',\n  'region' => '${region}',\n  'use_iam_profile' => true\n\}/smg" gitlab.rb

# configure the external diffs_bucket
sed -i "s/# gitlab_rails\['external_diffs_enabled'\] = false/gitlab_rails\['external_diffs_enabled'\] = true/" gitlab.rb
sed -i "s/# gitlab_rails\['external_diffs_object_store_enabled'\] = false/gitlab_rails\['external_diffs_object_store_enabled'\] = true/" gitlab.rb
sed -i "s/# gitlab_rails\['external_diffs_object_store_remote_directory'\] = .*/gitlab_rails\['external_diffs_object_store_remote_directory'\] = \"${external_diffs_bucket}\"/" gitlab.rb
perl -i -pe "BEGIN{undef $/;} s/# gitlab_rails\['external_diffs_object_store_connection.*?# }/gitlab_rails['external_diffs_object_store_connection'] = \{\n  'provider' => 'AWS',\n  'region' => '${region}',\n  'use_iam_profile' => true\n\}/smg" gitlab.rb

# configure dependency proxy_bucket
sed -i "s/# gitlab_rails\['dependency_proxy_enabled'\]/gitlab_rails\['dependency_proxy_enabled'\]/" gitlab.rb
sed -i "s/# gitlab_rails\['dependency_proxy_storage_path'\]/gitlab_rails\['dependency_proxy_storage_path'\]/" gitlab.rb
sed -i "s/# gitlab_rails\['dependency_proxy_object_store_enabled'\] = false/gitlab_rails\['dependency_proxy_object_store_enabled'\] = true/" gitlab.rb
sed -i "s/# gitlab_rails\['dependency_proxy_object_store_remote_directory'\] = .*/gitlab_rails\['dependency_proxy_object_store_remote_directory'\] = \"${dependency_proxy_bucket}\"/" gitlab.rb
sed -i "s/# gitlab_rails\['dependency_proxy_object_store_direct_upload'\]/gitlab_rails\['dependency_proxy_object_store_direct_upload'\]/" gitlab.rb
sed -i "s/# gitlab_rails\['dependency_proxy_object_store_background_upload'\]/gitlab_rails\['dependency_proxy_object_store_background_upload'\]/" gitlab.rb
sed -i "s/# gitlab_rails\['dependency_proxy_object_store_proxy_download'\]/gitlab_rails\['dependency_proxy_object_store_proxy_download'\]/" gitlab.rb
perl -i -pe "BEGIN{undef $/;} s/# gitlab_rails\['dependency_proxy_object_store_connection.*?# }/gitlab_rails['dependency_proxy_object_store_connection'] = \{\n  'provider' => 'AWS',\n  'region' => '${region}',\n  'use_iam_profile' => true\n\}/smg" gitlab.rb

# terraform_state_bucket
sed -i "s/# gitlab_rails\['terraform_state_enabled'\]/gitlab_rails\['terraform_state_enabled'\]/" gitlab.rb
sed -i "s/# gitlab_rails\['terraform_state_object_store_enabled'\] = false/gitlab_rails\['terraform_state_object_store_enabled'\] = true/" gitlab.rb
sed -i "s/# gitlab_rails\['terraform_state_object_store_remote_directory'\] = .*/gitlab_rails\['terraform_state_object_store_remote_directory'\] = \"${terraform_state_bucket}\"/" gitlab.rb
perl -i -pe "BEGIN{undef $/;} s/# gitlab_rails\['terraform_state_object_store_connection.*?# }/gitlab_rails['terraform_state_object_store_connection'] = \{\n  'provider' => 'AWS',\n  'region' => '${region}',\n  'use_iam_profile' => true\n\}/smg" gitlab.rb

# Configure Gitaly client
sed -i "s/# gitlab_rails\['gitaly_token'\] = .*/gitlab_rails\['gitaly_token'\] = \"${gitaly_token}\"/" gitlab.rb
echo "gitlab_shell['secret_token'] = \"${secret_token}\"" >> gitlab.rb
# The step below has to be done manually. Replace gitaly_internal_ip after the gitaly instance is up
perl -i -pe "BEGIN{undef $/;} s/# git_data_dirs\(\{.*?# \}\)/git_data_dirs({\n  \"default\" => { \"gitaly_address\" => \"tcp:\/\/gitaly_internal_ip:8075\" },\n  \"storage1\" => { \"gitaly_address\" => \"tcp:\/\/gitaly_internal_ip:8075\" },\n})/smg" gitlab.rb

# Configure Prometheus 
sed -i "s/# prometheus\['enable'\] = .*/prometheus\['enable'\] = true/" gitlab.rb
sed -i "s/# prometheus\['listen_address'\] = .*/prometheus\['listen_address'\] = ':9090'/" gitlab.rb

# Configure grafana
sed -i "s/# grafana\['disable_login_form'\] = .*/grafana\['disable_login_form'\] = false/" gitlab.rb
sed -i "s/# grafana\['admin_password'\] = .*/grafana\['admin_password'\] = '${grafana_password}'/" gitlab.rb

sudo gitlab-ctl reconfigure
gitlab-rake gitlab:lfs:migrate

# Run a check and a service status to make sure everything has been setup correctly
# sudo gitlab-rake gitlab:check
# sudo gitlab-ctl status
# sudo gitlab-rake gitlab:gitaly:check