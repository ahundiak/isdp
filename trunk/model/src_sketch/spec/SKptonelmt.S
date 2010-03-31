/*
  DESCRIPTION

   This class defines a point lying on an element constraint. The point
   is constrained to lie on that element. The elements currently supported
   are lines and arcs/circles.
*/

class specification SKptonelmt (2:0) of SKifimplicit;

#ifndef BASE_EMS

override
 GRgetobjinfo,
 SKinit, SKcreate_geom;

#endif

end specification SKptonelmt;
