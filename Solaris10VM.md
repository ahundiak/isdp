# Introduction #

Add your content here.


### DHPC ###

Try building a machine from scratch using DHCP.  First attempt will be done at home.

Solaris 10 Willow 03 DHCP, 540MB, 10GB, Bridged

Interface is e1000g0

Something is up with the laptop, could not get the graphic started.  Try reducing screen resolution.  Went from 1600x1200 to 1280x1024.  Same thing on the second try.  Screen goes to a gray background, no windows or what not.  Wonder if the iso image got messed up or maybe because the client got updated from 6.5.0 to 6.5.2.

Might have just been using the passport drive.  I downloaded Solaris 10 5/09 onto the laptop disk.  Seems to have started ok.

Need domain name: ingrnet (or ingrnet.com?)
Need address of DNS server

Under windows used: ipconfig /all

DNS Search list : left empty

Got a DNS error but accepted it anyways.  Did not ask for netmask.  Accepted defaults for everything else.

Did not ask for node name.  End up with welcome to unknown.

Select Java or CDE from the login screen, change with Session Menu from Desktop login screen.  Not yet ready to try the Java desktop.  CDE is depreciated and will be removed.

Came up with xSun.  Loaded vmware stuff.  Resulution look reasonable until a reboot.
Ended changing host resolution to 1200x1600 and choosing same resolution (option 13) using vmware.

Change the hostname
[Change Host Name](http://forums.devshed.com/unix-help-35/changing-hostname-and-ip-on-solaris-10t-343047.html)
Changing the hostname now only requires editing these files:

  1. /etc/hosts - change unknown to willow 3
  1. /etc/nodename - create the file then add willow3 as first line
  1. /etc/hostname.<interface name> - edit the file and add willow3 as line

Seemed to work ok, ping outside computers
# cat resolv.conf
domain hsd1.al.comcast.net.
nameserver 68.87.68.166
nameserver 68.87.74.166

See what happens when it starts at work
# cat /etc/hosts
#
# Internet host table
#
::1             localhost
127.0.0.1       localhost
192.168.1.107   willow3 # Added by DHCP

Added loghost to hosts willow3 line just to see if it would stick. Nope it does not.

Brought it in to work, rebooted and it came up on the intergraph domain.  Pretty cool.  The only thing really left is to get it to work viw VPN.  Also need to try in the lab.

### Trying Java desktop ###

# useradd -u 115 -g users -d /export/home/ahundiak -s /bin/ksh -c "Art Hundiak" -m ahundiak
UX: useradd: WARNING: ahundiak has no permissions to use /export/home/ahundiak.

Tried running smpatch update on willow, loaded a bunch of patches but eventually ran out of /usr/tmp space.  Generally want to run smpatch in single user mode.  Rather than fight the disk space issue I just rolled things back for now.  20GB is just not enough I guess.  And I'm not going to fool with trying to repartition the disk.

/etc/defaultrouter contains 129.135.192.1
/etc/hostname.e1000g0 willow  (maybe should be inet willow?)
/etc/hosts      129.135.195.85  willow  loghost
/etc/netmasks   129.135.192.0   255.255.252.0
/etc/nsswitch.conf files for everything but dns
/etc/resolv.conf
> domain ingrnet.com
> nameserver 129.135.251.148
> nameserver 129.135.251.149

Try this to get a root ksh shell
http://itknowledgeexchange.techtarget.com/linux-lotus-domino/solaris-10-ksh-and-root/



### In the lab ###
Took the laptop with the dhcp machine in to the lab.  DHCP worke as expected and I could ping the lab machines but not the avondale machines.  I set the defaultrouter and added the S98doit, rebooted, and I could get to Avondale.

Used vmware to suspend the machine, went back to ingrnet, dhcp was still set for the lab.