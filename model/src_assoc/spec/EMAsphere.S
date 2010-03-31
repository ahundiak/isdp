/*
  DESCRIPTION

  This is an instantiable class defining associative plane.


  HISTORY

  jhw     3/24/91     creation date
*/

class specification EMAsphere (2:0) of EMAsubbs, EMSsphere;

/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

override
  EMconstruct_associative,
  EMdim,
  EMdimparam;

#endif

end specification EMAsphere;
