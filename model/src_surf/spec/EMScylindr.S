/*
  ABSTRACT

  This class represents surfaces that are cylinders.

 
  HISTORY

  05/24/91    msm     Overrode GRreport, GRreport_defaults, GRupdate_gadgets.
                      Removed override GRloadform and GRgetsfsize.
  01 Aug 88   RV	    Removed EMsurfintgrl override.
  05/16/88    dhm     Overrode GRloadform and GRgetsfsize.
  03 May 88   AIC     Removed inheritance of EMget_netedge_info.
  12/03/87    PP      Replaced EMget_cylinder_props with EMget_params.
  13 Oct 87   AIC     Conversion to EMS 1.1
                      Subclass EMScone, and rename struct 'rad'
                      to 'EMSradius'.
  gk 21-may-87    override EMsurfintgrl method
  JBK 06-MAY-1987 : removed override of EMintplane_notrim
  RLW     09/21/86 : The beginning
*/

class specification EMScylindr (2:0) of EMSelpcyl, EMScone;

# include "EMSstruct.h" 

/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

message EMcylinder_by_axis_n_radius
(
  struct GRvg_construct *arglist;
  IGRpoint pnt1;
  IGRpoint pnt2;
  struct EMSradius *radius;
);

override
  GRreport,
  GRreport_defaults,
  GRupdate_gadgets,
  EMget_natedge_info,
  EMget_params,
  EMget_int_data;

#endif

end specification EMScylindr;
