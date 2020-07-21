#! /bin/bash

# Install the ssm agent
mkdir /tmp/ssm
cd /tmp/ssm
wget https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_amd64/amazon-ssm-agent.deb
sudo dpkg -i amazon-ssm-agent.deb
sudo systemctl enable amazon-ssm-agent

# GitLab install starts here
sudo su
cd /etc/gitlab
sed -i "s/# letsencrypt\['enable'\] = nil/letsencrypt\['enable'\] = false/" gitlab.rb
sudo gitlab-ctl reconfigure

# Install the pg_trgm extension for PostgreSQL
sudo /opt/gitlab/embedded/bin/psql -U gitlab -h ${rds_address} -d gitlabhq_production
${rds_password}
# Once inside the database
CREATE EXTENSION pg_trgm;
\q

# Configure GitLab to connect to PostgreSQL and Redis
# Comment out the following 2 lines if using a load balancer
export HOST_NAME=$(curl http://169.254.169.254/latest/meta-data/public-hostname)
sed -i "s+external_url 'http://ec2.*.amazonaws.com'+external_url 'http://$HOST_NAME'+" gitlab.rb
# sed -i "s+external_url 'http://ec2.*.amazonaws.com'+external_url 'http://${dns_name}'+" gitlab.rb
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

sudo gitlab-ctl reconfigure
gitlab-rake gitlab:lfs:migrate
# Run a check and a service status to make sure everything has been setup correctly
# sudo gitlab-rake gitlab:check
# sudo gitlab-ctl status