/*
  ABSTRACT

  This class represents tori.


  HISTORY

  05/23/91        msm     Override GRreport, Grreport_defaults, 
                          GRupdate_gadgets. Removed override GRloadform and
                          GRgetsfsize.
  05/16/88        dhm     Overrode GRloadform and GRgetsfsize.
  23 Mar 88       AIC     Override EMgetRuleLineTable.
  12/03/87     PP         Replaced erstwhile EMget_torus_props with
                          EMget_params
  13 October 87   AIC     Conversion to EMS 1.1
                           Renamed struct 'rad' to 'EMSradius'
  LST     10/02/86                the beginning
*/

class specification EMStorus (2:0) of EMSrevol;

# include "EMSstruct.h"  

/*--------------- MESSAGE DECLARATION SECTION ----------------*/

override
  EMgetRuleLineTable;

#ifndef BASE_EMS
	
message EMtorus_by_axis_center_rad
(
  struct GRvg_construct *arglist;
  IGRpoint pnt1;
  IGRpoint pnt2;
  IGRpoint center;
  struct EMSradius *radius;
);

override
  GRreport, 
  GRreport_defaults, 
  GRupdate_gadgets,
  EMget_params,
  EMget_natedge_info;
    
#endif

end specification EMStorus;
