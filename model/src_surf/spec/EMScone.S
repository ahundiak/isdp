/*
  ABSTRACT

  This class represents surfaces that are cones.


  HISTORY

  05/23/91        msm Overrode GRreport, GRreport_defaults, GRupdate_gadgets.
                      Removed override for GRloadform and GRgetsfsize.

  22 Jun 1989     jBk Added documentation for EMcone message.

  01/11/89        rlw Overrode EMget_int_data.

  05/16/88        dhm Overrode GRloadform and GRgetsfsize.

  23 March 88     AIC Override EMgetRuleLineTable.

  10 March 88     AIC Support surface of projection format.

  12/03/87        PP  Replaced erstwhile EMget_cone_props with
                      EMget_params

  13 October 87   AIC Conversion to EMS 1.1
                      Subclass EMSrevol and EMSprjconic.

  RLW     09/21/86 : The beginning
*/

class specification EMScone (2:0) of EMSelpcone, EMSrevol;

/*--------------- MESSAGE DECLARATION SECTION ----------------*/

from EMSelpcone inherit
  EMgetRuleLineTable;

override
  EMgetbsdef,
  GRgetsize,
  GRgenabsg;

#ifndef BASE_EMS

message EMcone
(
  IGRint *rc;
  struct GRvg_construct *arglist;
  IGRpoint points[];
  IGRdouble *radius;
);

override
  EMget_int_data,
  GRreport,
  GRreport_defaults,
  GRupdate_gadgets,
  EMmodifiedClass,
  GRxform,
  EMget_natedge_info,
  EMget_params;

#endif

end specification EMScone;
