# This is the default ansible 'hosts' file.
#   - Comments begin with the '#' character
#   - Blank lines are ignored
#   - Groups of hosts are delimited by [header] elements
#   - You can enter hostnames or ip addresses
#   - A hostname/ip can be a member of multiple groups

# Ex 1: Ungrouped hosts, specify before any group headers.

## blue.example.com
## 192.168.100.1

#localhost ansible_connection=local

# Ex 2: A collection of hosts belonging to the 'webservers' group

## [webservers]
## alpha.example.org
## beta.example.org
## 192.168.1.100
## 192.168.1.110

# If you have multiple hosts following a pattern you can specify
# them like this:

## www[001:006].example.com

## [dbservers]
## 
## db01.intranet.mydomain.net
## db02.intranet.mydomain.net
## 10.25.1.56
## 10.25.1.57

# Here's another example of host ranges, this time there are no
## db-[99:101]-node.example.com
#
# Group Vars

[dmz]
phlhflxapnwb005
phlhflxapnwb006
phlhflxapnwb009
[dmz:vars]
ansible_become_method=sudo
proxy=http://proxybc.kmhp.com:9119

[ec2]
hostx ansible_host=35.183.15.179 ansible_user=ec2-user private_ip=172.17.182.250

[control]
phlprlxjmp001 ansible_connection=local
[control:vars]
http_proxy=http://scl-linux_proxy:9119





