action :install_security do
  bash "install_opendistro_security_plugin" do
    user node['elastic']['user']
    code <<-EOF
    #{node['elastic']['bin_dir']}/elasticsearch-plugin install --batch #{node['elastic']['opendistro_security']['url']}
    chmod +x #{node['elastic']['opendistro_security']['tools_dir']}/*
    EOF
  end

  hopsworks_alt_url = "https://#{private_recipe_ip("hopsworks","default")}:8181" 
  if node.attribute? "hopsworks"
    if node["hopsworks"].attribute? "https" and node["hopsworks"]['https'].attribute? ('port')
      hopsworks_alt_url = "https://#{private_recipe_ip("hopsworks","default")}:#{node['hopsworks']['https']['port']}"
    end
  end
  elastic_crypto_dir = x509_helper.get_crypto_dir(node['elastic']['user-home'])
  kagent_hopsify "Generate x.509" do
    user node['elastic']['user']
    group node['elastic']['group']
    crypto_directory elastic_crypto_dir
    hopsworks_alt_url hopsworks_alt_url
    action :generate_x509
    not_if { conda_helpers.is_upgrade || node["kagent"]["test"] == true }
  end


  elk_crypto_dir = x509_helper.get_crypto_dir(node['elastic']['elk-home'])
  kagent_hopsify "Generate x.509" do
    user node['elastic']['elk-user']
    group node['elastic']['elk-group']
    crypto_directory elk_crypto_dir
    hopsworks_alt_url hopsworks_alt_url
    action :generate_x509
    not_if { conda_helpers.is_upgrade || node["kagent"]["test"] == true }
  end

  kstore_file, tstore_file = x509_helper.get_user_keystores_name(node['elastic']['user'])
  link node['elastic']['opendistro_security']['keystore']['location'] do
    owner node['elastic']['user']
    group node['elastic']['group']
    to "#{elastic_crypto_dir}/#{kstore_file}"
  end

  link node['elastic']['opendistro_security']['truststore']['location'] do
    owner node['elastic']['user']
    group node['elastic']['group']
    to "#{elastic_crypto_dir}/#{tstore_file}"
  end
end
