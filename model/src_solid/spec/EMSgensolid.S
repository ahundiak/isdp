/*
  ABSTRACT

  This class represents a free form solid.


  HISTORY

  4/10/91         jhw     Added override for EMconstruct_associative.
  15 October 87   AIC     Creation Date
*/

class specification EMSgensolid (1:0) of EMSsolid;

/*------------------ INSTANCE DATA SECTION -------------------*/

override GRvg;


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

override 
  EMconstruct_associative,
  EMdim,
  EMdimparam;

#endif

end specification EMSgensolid;
