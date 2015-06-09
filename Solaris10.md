### Avondale ###

#### NIS ####

In Jul 2010 went to Avondale.  Someone configured NIS on willow in an effort to get connected to the lpd subnet.
This was not really necessary. I also took dev04 and all I had to do was to set the netmasks and ip address.
Configuing for NIS meant that the machine was not usable when unplugged from the network.  No xwindows login at all.
Logged in as console root then:
```
cd /etc
ls ns*
cp nsswitch.conf nsswitch.conf.avd
cp nsswitch.files nsswitch.conf
```
Still seems a bit slow when offline