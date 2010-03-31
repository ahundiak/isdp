/*
  DESCRIPTION

    Objects of this class implement the radial/diameter constraint for
    representing radial/diameter dimension. A bit in the properties
    field indicates whether the value stored is a radius or a diameter.
*/

class specification SKradial (2:0) of SKifptpt;

#ifndef BASE_EMS

override SKcreate_geom;

#endif

end specification SKradial;

