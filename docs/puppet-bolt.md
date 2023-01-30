# Puppet Bolt

Install Bolt with:

```
wget https://apt.puppet.com/puppet-tools-release-focal.deb
sudo dpkg -i puppet-tools-release-focal.deb
sudo apt-get update 
sudo apt-get install puppet-bolt
```


If you want to create modules but dont want to publish them to the Puppet Forge, you can just [add the directory to the module path](https://puppet.com/docs/bolt/latest/modules.html#modulepath).
