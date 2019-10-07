actions :run

attribute :elastic_url, :kind_of => String, :required => true
attribute :user, :kind_of => String, :required => false, :default => nil
attribute :password, :kind_of => String, :required => false, :default => nil

attribute :systemd, :kind_of => [TrueClass, FalseClass], :required => true

default_action :run
