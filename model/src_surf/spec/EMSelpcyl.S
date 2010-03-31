/*
  ABSTRACT

  This class represents surfaces that are elliptical cylinders.


  HISTORY

  05/29/91    msm     Override GRreport, GRreport_defaults, GRupdate_gadgets.
                      Removed override GRloadform and GRgetsfsize.
  05/16/88    dhm     Overrode GRloadform and GRgetsfsize.
  03 May 88   AIC     Removed inheritance of EMget_natedge_info.
  12/02/87    PP      Replaced EMget_elliptical_cylinder_props with
                      EMget_params.
  13 Oct 87   AIC     Conversion to EMS 1.1
                      Subclass EMSelpcone
  rlw     05/28/87        override getobjin
  AIC     03/20/87        Creation Date
*/

class specification EMSelpcyl (2:0) of EMSelpcone;

/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

override 
  GRreport,
  GRreport_defaults,
  GRupdate_gadgets,
  EMget_natedge_info,
  EMget_params;

#endif

end specification EMSelpcyl;
