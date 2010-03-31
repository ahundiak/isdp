/*
  DESCRIPTION

  This is an instantiable class defining associative cylinder
  surface.


  HISTORY

  Creation : jhw : 04/20/91
*/

class specification EMAelpsoid (2:0) of EMAsubbs, EMSelpsoid;

/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

override
  EMconstruct_associative,
  EMdim,
  EMdimparam;

#endif

end specification EMAelpsoid;
