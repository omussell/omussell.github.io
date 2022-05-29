+++
title = "Blue/Green Deployments with Puppet, NGINX and FreeBSD Jails"
date = 2022-01-01

[taxonomies]
tags = ["homelab"]
+++

At $WORK, we were going through a period of rapid growth and were planning on creating many more web apps. The apps are mainly Django/Python with a few NodeJS apps too. Previously they had been deployed on Debian servers and the deployment process was to SSH onto each app server and run git pull, then restart the processes.


This solution works fine for apps with little traffic, but since we were growing rapidly, we were finding that this architecture wouldnt scale as much as we would like.

At the time we were deciding on a new architecture (2017), the current modern solutions like Docker, Kubernetes and LXC/LXD were still very much in their infancy and not ready for production.

In addition, one of the main gripes with Python apps is that they frequently link to C libraries. So when a new deployment contains a package updated via pip, what can happen is that it requires a new version of an OS package for a C library. Now you not only need to deploy the app, you also need to update the OS too.

## Proposed Architecture
The solution we came up with was to deploy the apps inside FreeBSD jails, control the deployments via Puppet, and handle routing of requests from the load balancer to the correct jail using NGINX.

### FreeBSD Jails
Jails work in a very similar way to LXC/LXD or like Docker but without immutable images. They are containers which share the host kernel but have their own copy of the base OS which runs isolated processes. Each jail can be allocated its own IP address and RW filesystem.

To create a new jail, a filesystem containing the FreeBSD base system is created, the jail.conf files created and then the jail started. A jail runs the same init process tree as it would on bare metal or a VM. Once a jail is running, you can jexec inside the jail to run further commands.

### Puppet
Puppet is a configuration management system. It lets you decide the desired state for a system and it will idempotently change the system to achieve the desired state.

For example, if you wanted to install the NGINX package, make sure the config file was set up correctly and then start the service, you could write Puppet code like:

```ruby
package { 'nginx':
  ensure => 'installed',
}

file { '/etc/nginx/nginx.conf':
  ensure  => 'file',
  content => template('profiles/nginx/nginx.conf.erb'),
}

service { 'nginx':
  ensure => 'running',
  enable => true,
}
```
        
That code is very generic and Puppet will work across multiple OSes and filesystems. You dont have to worry about OS specific actions, Puppet just does it all for you.

### NGINX
With NGINX we can use it both to serve static assets like a web server and as a reverse proxy to the applications. The config can be set to route requests to specific domains or URLs to specific backends. In this case, the backends would be the IP addresses of the jails.

### Putting it all together
I created a basic Puppet type and provider which can check for the presence or absence of jails. This was used in a module which performed the actions to set up the jails.

The jail filesystem would run on ZFS which meant we could create a template dataset and then new jails were just clones of that dataset.

When Puppet ran on the host system, it would perform the following actions in order to create a new jail:

- Download the FreeBSD base files tar.xz
- Create the template ZFS dataset and extract the base files into it
- Create some standard files like resolv.conf and install standard packages like Git and Puppet
- Create a ZFS snapshot of the template dataset
- Clone the template snapshot for the new jail
- Amend the jail.conf to include config for the new jail
- Start the new jail
- Run Puppet inside the jail to provision the app
- Subsequent Puppet runs on the host would amend the NGINX config to route traffic to the new jails IP address.

When creating a new jail, we designated it as the "test" jail which had a specific domain or URL in the NGINX config. So all live traffic would continue to be served by the "live" jail, but any requests to a specific "test" domain/URL would instead be routed to the "test" jail. This meant that the QA department could run their tests in the "test" jail without it affect the "live" jail.

The switchover was accomplished by changing the NGINX config and running nginx -s reload which gracefully reloads the NGINX processes with the new config without dropping any in flight requests.

## End Result
This setup was running fine for years and allowed us to scale well. I wouldn't recommend going this route for future deployments. We spent a lot of time fighting FreeBSD because the support for third-party packages was so poor. We frequently had to reinvent the wheel to get things working.

My recommendations would be:

- If you want to self-host and are a sufficiently large organisation, use Kubernetes.
- If you want to self-host and arent that big, use LXD and pair it with Ansbile or Saltstack.
- If you dont want to self-host, use something like Heroku or Fly.io
