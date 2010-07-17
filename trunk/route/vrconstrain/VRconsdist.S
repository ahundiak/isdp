/*
ABSTRACT 

This class implement a constrain minimum, maximum or fixed distance between
planes.
*/

class specification VRconsdist (1:0) of VRconc, NDnodein;

from VRconc inherit NDget_virtual_objects, NDcompute_node, NDplace;

override VRget_nb_constrain,VRget_constrain;

override NDmove_to_root;

end specification VRconsdist;
