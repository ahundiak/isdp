/*
  DESCRIPTION

  This is an instantiable class defining associative cylinder
  surface.


  HISTORY

  Creation : PP : 03/02/91
  SRH: 05/21/91 added overrides for EMreport_defaults,
		             EMreport, and  EMupdate.
*/

class specification EMAcylindr (2:0) of EMAsubbs, EMScylindr;

/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

override
  EMgetparam,
  EMconstruct_associative,
  EMdim,
  EMdimparam;

#endif

end specification EMAcylindr;
