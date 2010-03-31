/*
  DESCRIPTION

  This is an instantiable class defining associative cylinder
  surface.


  HISTORY

  Creation : jhw : 04/20/91
  Aditya : 05/25/95 : Overrode and implemented EMdimparam and EMdim methods.
*/

class specification EMAelpcyl (2:0) of EMAelpcone, EMSelpcyl;

#ifndef BASE_EMS

override
  EMdimparam,
  EMdim;

#endif

end specification EMAelpcyl;
