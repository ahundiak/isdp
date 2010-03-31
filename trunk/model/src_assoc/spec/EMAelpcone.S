/*
  DESCRIPTION

  This is an instantiable class defining associative cylinder
  surface.


  HISTORY

  Creation                    : jhw : 04/20/91
  Added EMdim and EMdimparam  : jhw : 06/10/90
*/

class specification EMAelpcone (2:0) of EMAsubbs, EMSelpcone;

/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

override
  EMconstruct_associative,
  EMdim,
  EMdimparam;

#endif

end specification EMAelpcone;
