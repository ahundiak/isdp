/*
  DESCRIPTION

    Instantiable class for points that can be flexibly dimensioned or
    constrained in a piece-wise manner, at differing times during the
    modelling proces. This implies that this point may not be fully defined,
    parameterically speaking, at creation time.
 
  HISTORY

    SS  :  03/15/91  :  Creation
*/

class specification EMSparampt (2:0) of EMSparamgm;

instance EMSparampt
  {
  IGRpoint pt;
  };

override 
  DMsrc,
  GRgraphics,
  GRnotify,
  GRconnector,
  GRvg;

reject  GRchgprops;

override
  NDgive_structure, DMgive_structure, DMgive_src_info,
  GRgenabsg, GRgetobjinfo,
  EMconstruct, EMdisplay, EMgetgeom, EMparam_xform, EMlnmindist;

end specification EMSparampt;
