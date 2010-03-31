/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION

    This is the instantiable class for infinite plane (or datum plane)
    parameters and sets any additional protocols for the same. 

  HISTORY

    SS  :  03/14/91  :  Creation
*/

class specification EMSparampl (2:0) of EMSparamgm;

instance EMSparampl
  {
  IGRpoint plane_pt;
  IGRvector plane_vec;
  };

override 
  DMsrc,
  GRgraphics;

/*
override
  NDupdate,
  EMconstruct,
  EMgetgeom,
  EMdisplay,
  EMsolve;
*/
end specification EMSparampl;
