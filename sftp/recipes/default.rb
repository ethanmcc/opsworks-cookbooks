chef_gem "ruby-shadow"

group "sftp" do
    gid 502
    group_name "sftp"
    action :create
end

node[:sftp][:users].each do |usr|
    user usr.username do
        home "/home/#{usr.username}"
        password usr.password
        shell "/sbin/nologin"
        action :create
    end

    directory "/home/#{usr.username}" do
        owner "root"
        group "root"
        mode "0755"
    end

    directory "/home/#{usr.username}/upload" do
        owner usr.username
    end

    group "sftp" do
        members usr.username
        action :modify
    end
end

execute "restart_sshd" do
  command "/etc/init.d/sshd restart"
  action :nothing
end

template "/etc/ssh/sshd_config" do
    source "sshd_config.erb"
    owner "root"
    group "root"
    mode "0600"
    action :create
    notifies :run, 'execute[restart_sshd]', :delayed
end
