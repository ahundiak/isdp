#
# Default setup file
# This file is tailored to puget styles
# The struct file is visedges A all others are visedges B

#verbose;

include "setup1.vd";	# equipment
#include "setup2.vd";	# envelope processing equipment
include "setup2.vr";	# route  pipe components
include "setup3.vr";	# route  hvac  components
include "setup1.vs";	# struct components
include "setup1.gr";	# cells and symbols and macros

#Larry- I modified the setup1.vd and removed the entry for const 
#and added it to setup1.gr. The setup1.gr is the last setup file
#read. When the AVP process runs if it sees 
#   const (definition="*",view-criterion="graphics") 
#before it sees (hvac/pipe/stiffener/etc)  then all these elements 
#will be processed twice. Making it the last entry read will prevent
#it from processing twice and allowing processing of all macros correctly.  

