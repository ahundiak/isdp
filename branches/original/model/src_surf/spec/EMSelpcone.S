/*
  ABSTRACT

  This class represents surfaces that are elliptical cones.


  HISTORY

  05/28/91        msm     Override GRreport, GRreport_defaults, 
                          GRupdate_gadgets. Removed override GRloadform and
                          GRgetsfsize.
  22 Jun 1989 jBk Added mention of returned completion code
                  EMS_I_FlatConeGeneralSf for message
                  EMconstruct_elliptical_cone.

  05/16/88        dhm     Overrode GRloadform and GRgetsfsize.

  AIC     23 Mar 88       Override EMgetRuleLineTable.

  12/02/87        PP      Replaced EMget_elliptical_cone_props with
                          EMget_params

  13 October 87   AIC     Conversion to EMS 1.1
                          Subclass EMScone.

  rlw     05/28/87        override getobjin

  AIC     03/20/87        Creation Date
*/

class specification EMSelpcone (2:0) of EMSproject;

/*--------------- MESSAGE DECLARATION SECTION ----------------*/

override
  EMgetRuleLineTable;


#ifndef BASE_EMS

message EMconstruct_elliptical_cone
(
  IGRlong *EMmsg;
  struct GRvg_construct *construct_list;
  IGRpoint base_center;
  IGRvector major_axis;
  IGRvector minor_axis;
  IGRvector height;
  IGRdouble scale;
);

override
  GRreport,
  GRreport_defaults,
  GRupdate_gadgets,
  EMget_natedge_info,
  EMget_params;

#endif

end specification EMSelpcone;
