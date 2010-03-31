/*
  ABSTRACT

  This class represents composite surfaces that result from projecting
  a planar composite curve along the normal to the plane of the
  composite curve.


  HISTORY

  08/10/88        dhm     Override GRgetsfsize and GRloadform.
  14 October 87   AIC     Creation Date.
*/

class specification EMSprjcompsf (1:0) of EMSswcompsf;

/*------------------ INSTANCE DATA SECTION -------------------*/

override 
  GRvg;

/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

override
  EMoffset,
  GRreport,
  GRreport_defaults,
  GRupdate_gadgets;

#endif

end specification EMSprjcompsf;
