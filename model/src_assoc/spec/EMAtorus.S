/*
  DESCRIPTION

  This is an instantiable class defining associative general torus
  surface.


  HISTORY

  jhw     4/10/91     creation date
*/

class specification EMAtorus (2:0) of EMAsubbs, EMStorus;

/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

override 
  EMconstruct_associative,
  EMdim,
  EMdimparam;

#endif

end specification EMAtorus;
