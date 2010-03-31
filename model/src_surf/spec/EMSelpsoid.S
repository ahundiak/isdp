/*
  ABSTRACT

  This is an abstract class which represents surfaces that
  are ellipsoids.


  HISTORY

  05/29/91        msm     Override GRreport, GRreport_defaults,
                          GRupdate_gadgets.
                          Removed Override GRloadform and GRgetsfsize.
  05/16/88        dhm     Overrode GRloadform and GRgetsfsize.
  23 Mar 88       AIC     Override EMgetRuleLineTable.
  13 October 87   AIC     Conversion to EMS 1.1
                          Subclass EMSquadaric and EMSrevconic.
  rlw     05/28/87        override getobjin
  AIC     03/20/87        Creation Date
*/

class specification EMSelpsoid (2:0) of EMSrevol;

# include "EMSellpsd.h"

/*--------------- MESSAGE DECLARATION SECTION ----------------*/

override
  EMgetRuleLineTable;

#ifndef BASE_EMS

message EMelpsd
(
  struct EMesellpsd1 *method_1;
  struct EMesellpsd2 *method_2;
  struct GRvg_construct *construct_list;
  IGRlong *msg;
);

override 
  GRreport,
  GRreport_defaults,
  GRupdate_gadgets,
  EMget_natedge_info,
  EMget_params;

#endif

end specification EMSelpsoid;
