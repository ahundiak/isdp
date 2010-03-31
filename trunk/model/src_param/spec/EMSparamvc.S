/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION

    This is the instantiable class for direction vectors. One of these,
    together with a point fully define an infinite (or semi-infinite) line.
    Used for centrelines, axes, etc.

  HISTORY

    SS  :  03/14/91  :  Creation
*/

class specification EMSparamvc (2:0) of EMSparamgm;

instance EMSparamvc
  {
  IGRvector vec;
  };

override 
  DMsrc,
  GRgraphics;

reject GRchgprops;

override
  NDgive_structure, DMgive_structure,
  GRgenabsg, GRgetobjinfo,
  EMconstruct, EMdisplay, EMgetgeom, EMparam_xform, EMlnmindist;

end specification EMSparamvc;
