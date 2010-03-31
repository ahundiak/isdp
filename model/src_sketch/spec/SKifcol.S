/*
  DESCRIPTION

    This is a interface class for collinear constraint. This object
    collects all of the collinear constraints created at a given time.
    All of the graphics for its collinear constraints is owned by it.
*/

class specification SKifcol (2:0) of SKcollinear, SKifimplicit;

from SKcollinear inherit
  SKcreate_geom;
  
#ifndef BASE_EMS

override 
  SKinit;

#endif

end specification SKifcol;
