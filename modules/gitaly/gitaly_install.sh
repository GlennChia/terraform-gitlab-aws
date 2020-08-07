#! /bin/bash

# Install the ssm agent
mkdir /tmp/ssm
cd /tmp/ssm
wget https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_amd64/amazon-ssm-agent.deb
sudo dpkg -i amazon-ssm-agent.deb
sudo systemctl enable amazon-ssm-agent

# Configure Gitaly
sudo su
sudo apt-get update
sudo apt-get install -y curl openssh-server ca-certificates
curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.deb.sh | sudo bash
sudo apt-get install gitlab-ee=13.2.3-ee.0
cd /etc/gitlab
sed -i "s/# gitaly\['auth_token'\] = .*/gitaly\['auth_token'\] = \"${gitaly_token}\"/" gitlab.rb
echo "gitlab_shell['secret_token'] = \"${secret_token}\"" >> gitlab.rb
sed -i "s/# postgresql\['enable'\] = .*/postgresql\['enable'\] = false/" gitlab.rb
sed -i "s/# redis\['enable'\] = .*/redis\['enable'\] = false/" gitlab.rb
sed -i "s/# nginx\['enable'\] = .*/nginx\['enable'\] = false/" gitlab.rb
sed -i "s/# puma\['enable'\] = .*/puma\['enable'\] = false/" gitlab.rb
sed -i "s/# sidekiq\['enable'\] = .*/sidekiq\['enable'\] = false/" gitlab.rb
sed -i "s/# gitlab_workhorse\['enable'\] = .*/gitlab_workhorse\['enable'\] = false/" gitlab.rb
sed -i "s/# grafana\['enable'\] = .*/grafana\['enable'\] = false/" gitlab.rb
sed -i "s/# gitlab_exporter\['enable'\] = .*/gitlab_exporter\['enable'\] = false/" gitlab.rb

# Disable the following if you run a separate monitoring node
# sed -i "s/# alertmanager\['enable'\] = .*/alertmanager\['enable'\] = false/" gitlab.rb
# sed -i "s/# prometheus\['enable'\] = .*/prometheus\['enable'\] = false/" gitlab.rb
# Otherwise
sed -i "s/# prometheus\['listen_address'\] = .*/prometheus\['listen_address'\] = '0.0.0.0:9090'/" gitlab.rb
sed -i "s/# prometheus\['monitor_kubernetes'\] = .*/prometheus\['monitor_kubernetes'\] = false/" gitlab.rb
# If you don't want to run monitoring services uncomment the following (not recommended)
# sed -i "s/# node_exporter\['enable'\] = .*/node_exporter\['enable'\] = false/" gitlab.rb

# Prevent database connections during 'gitlab-ctl reconfigure'
sed -i "s/# gitlab_rails\['rake_cache_clear'\] = .*/gitlab_rails\['rake_cache_clear'\] = false/" gitlab.rb
sed -i "s/# gitlab_rails\['auto_migrate'\] = .*/gitlab_rails\['auto_migrate'\] = false/" gitlab.rb

# Configure the gitlab-shell API callback URL. Without this, `git push` will fail. This can be your 'front door' GitLab URL or an internal loadbalancer.
if [[ ${visibility} = "private" ]]
then
  echo "gitlab_rails['internal_api_url'] = 'http://${lb_dns_name}'" >> gitlab.rb
elif [[ ${visibility} = "public" ]]
then
  # Sometimes Terraform uses the old URL. Manually verify this
  echo "gitlab_rails['internal_api_url'] = 'http://${instance_dns_name}'" >> gitlab.rb
fi

# Make Gitaly accept connections on all network interfaces. You must use firewalls to restrict access to this address/port.
# Comment out following line if you only want to support TLS connections
sed -i "s/# gitaly\['listen_addr'\] = .*/gitaly\['listen_addr'\] = \"0.0.0.0:8075\"/" gitlab.rb

# Additional requirements
perl -i -pe "BEGIN{undef $/;} s/# git_data_dirs\(\{.*?# \}\)/git_data_dirs({\n  \"default\" => {\n    \"path\" => \"\/var\/opt\/gitlab\/git-data\"\n  },\n  \"storage1\"  => {\n    \"path\" => \"\/mnt\/gitlab\/git-data\"\n  },\n})/smg" gitlab.rb

sudo gitlab-ctl reconfigure
# Confirm that Gitaly can perform callbacks to the GitLab internal API. 
# sudo /opt/gitlab/embedded/service/gitlab-shell/bin/check -config /opt/gitlab/embedded/service/gitlab-shell/config.yml