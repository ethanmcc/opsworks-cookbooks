chef_gem "ruby-shadow"

group "sftp" do
    gid 502
    group_name "sftp"
    action :create
end

user node[:sftp][:admin_username] do
    home "/home/#{node[:sftp][:admin_username]}"
    action :create
end

directory "/home/#{node[:sftp][:admin_username]}/.ssh" do
    owner node[:sftp][:admin_username]
    mode 00700
    action :create
end

file "/home/#{node[:sftp][:admin_username]}/.ssh/authorized_keys" do
    owner node[:sftp][:admin_username]
    content node[:sftp][:admin_public_key]
    mode 00600
    action :create
end

directory "/var/sftproot" do
    owner "root"
    group "root"
    mode 00755
    action :create
end

node[:sftp][:users].each do |usr|
    user usr.username do
        home "/var/sftproot/#{usr.username}"
        password usr.password
        shell "/sbin/nologin"
        action :create
    end

    directory "/var/sftproot/#{usr.username}" do
        owner "root"
        group "root"
        mode 00755
        action :create
    end

    directory "/var/sftproot/#{usr.username}/upload" do
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
    mode 00600
    action :create
    notifies :run, 'execute[restart_sshd]', :delayed
end
