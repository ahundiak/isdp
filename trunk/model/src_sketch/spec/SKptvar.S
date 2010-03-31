class specification SKptvar (2:0) of SKvariable;

instance SKptvar
  {
  double pt[2];
  };

#ifndef BASE_EMS
message SKupdaterange (IGRlong *msg; IGRdouble xyrange[2][2]);


override
  debug, SKputvar, SKgetvarlist;

#endif

override
SKgetvar;

end specification SKptvar;
