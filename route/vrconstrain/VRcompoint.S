/*
ABSTRACT 

This class implement a constrain between plane.
The only constrain implemented today is the "common point"
between several planes
*/


class specification VRcompoint (1:0) of VRconc,NDnodein;

from VRconc inherit NDget_virtual_objects, NDcompute_node, NDplace;

override VRget_nb_constrain,VRget_constrain;

end specification VRcompoint;
