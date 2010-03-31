/*
  DESCRIPTION 

    This is a interface class for sets of equal constraints. This object
    collects all of the individual equal constraints created at a given time.
    All of the graphics for its equal constraints is owned by it.
*/

class specification SKifequal (2:0) of SKequal, SKifimplicit;

from SKequal inherit
  SKcreate_geom;

#ifndef BASE_EMS

override 
  SKinit;

#endif

end specification SKifequal;
