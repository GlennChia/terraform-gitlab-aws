#! /bin/bash

# Install the ssm agent
mkdir /tmp/ssm
cd /tmp/ssm
wget https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_amd64/amazon-ssm-agent.deb
sudo dpkg -i amazon-ssm-agent.deb
sudo systemctl enable amazon-ssm-agent

# Configure Gitaly
cd ~
sudo su
sudo apt-get update
sudo apt-get install -y curl openssh-server ca-certificates
curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.deb.sh | sudo bash
sudo apt-get install gitlab-ee=13.2.3-ee.0
cd /etc/gitlab

# Disable all other services on the Gitaly node
sed -i "s/# postgresql\['enable'\] = true/postgresql\['enable'\] = false/" gitlab.rb
sed -i "s/# redis\['enable'\] = true/redis\['enable'\] = false/" gitlab.rb
sed -i "s/# nginx\['enable'\] = true/nginx\['enable'\] = false/" gitlab.rb
sed -i "s/# grafana\['enable'\] = true/grafana\['enable'\] = false/" gitlab.rb
sed -i "s/# puma\['enable'\] = true/puma\['enable'\] = false/" gitlab.rb
# Sidekiq is not found in the rb file
sed -i "s/# sidekiq\['enable'\] = true/sidekiq\['enable'\] = false/" gitlab.rb
sed -i "s/# gitlab_workhorse\['enable'\] = true/gitlab_workhorse\['enable'\] = false/" gitlab.rb
sed -i "s/# prometheus_monitoring\['enable'\] = true/prometheus_monitoring\['enable'\] = false/" gitlab.rb

# Enable only the Gitaly service
sed -i "s/# gitaly\['enable'\] = true/gitaly\['enable'\] = true/" gitlab.rb
# Enable Prometheus
sed -i "s/# prometheus\['enable'\] = true/prometheus\['enable'\] = true/" gitlab.rb

# Prevent database connections during 'gitlab-ctl reconfigure'
sed -i "s/# gitlab_rails\['rake_cache_clear'\] = true/gitlab_rails\['rake_cache_clear'\] = false/" gitlab.rb
sed -i "s/# gitlab_rails\['auto_migrate'\] = true/gitlab_rails\['auto_migrate'\] = false/" gitlab.rb

# Configure Gitaly to listen on network interfaces
sed -i "s/# gitaly\['listen_addr'\] = .*/gitaly\['listen_addr'\] = '0.0.0.0:8075'/" gitlab.rb
sed -i "s/# gitaly\['prometheus_listen_addr'\] = .*/gitaly\['prometheus_listen_addr'\] = '0.0.0.0:9236'/" gitlab.rb

# Configure a strong auth_token for gitaly. This is an external token
sed -i "s/# gitaly\['auth_token'\] = .*/gitaly\['auth_token'\] = \"${praefect_internal_token}\"/" gitlab.rb

# Configure the GitLab Shell secret_token, and internal_api_url which are needed for git push operations
echo "gitlab_shell['secret_token'] = \"${secret_token}\"" >> gitlab.rb
if [[ ${visibility} = "private" ]]
then
  echo "gitlab_rails['internal_api_url'] = 'http://${lb_dns_name}'" >> gitlab.rb
elif [[ ${visibility} = "public" ]]
then
  # Sometimes Terraform uses the old URL. Manually verify this
  echo "gitlab_rails['internal_api_url'] = 'http://${instance_dns_name}'" >> gitlab.rb
fi
# Configure the storage location for Git data by setting git_data_dirs in /etc/gitlab/gitlab.rb
perl -i -pe "BEGIN{undef $/;} s/# git_data_dirs\(\{.*?# \}\)/git_data_dirs({\n  \"gitaly-1\" => {\n    \"path\" => \"\/var\/opt\/gitlab\/git-data\"\n  },\n  \"gitaly-2\" => {\n    \"path\" => \"\/var\/opt\/gitlab\/git-data\"\n  },\n  \"gitaly-3\" => {\n    \"path\" => \"\/var\/opt\/gitlab\/git-data\"\n  }\n})/smg" gitlab.rb

sudo gitlab-ctl reconfigure
sudo gitlab-ctl restart gitaly

# SSH into each Praefect node and run the Praefect connection checker:
# sudo /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml dial-nodes