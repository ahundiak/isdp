/*
  ABSTRACT

  This is an abstract class which represents surfaces of revolution.
  It stores the geometry as a curve and an axis of revolution.


  HISTORY

  06/06/91        msm     Override GRreport, GRreport_defaults,
                          GRupdate_gadgets.
                          Removed override GRloadform and GRgetsfsize.
  11/10/88        rlw     Override get EMget_int_data method.
  05/16/88        dhm     Overrode GRloadform and GRgetsfsize.
  24 Mar 88       AIC     Support surface of revolution format.
  23 Mar 88       AIC     Override EMgetRuleLineTable.
  13 Oct 87       AIC     Conversion to EMS 1.1
  01/11/88 : sam : Added argument "new_objid" for composite surfaces.
  09/21/87 : rlw : Redocumented this header and the method.
  09/21/86 : rlw : The beginning
*/

class specification EMSrevol (2:0) of EMSsubbs;

/*--------------- MESSAGE DECLARATION SECTION ----------------*/

message EMgetRevolvedFormat
(
  IGRlong *EMmsg;
  IGRboolean cv_header_only;
  IGRshort *mx_type;
  IGRmatrix mx;
  struct IGRbsp_curve *curve;
  IGRdouble *axis;
  IGRboolean *is_360;
  IGRdouble *start_angle;
  IGRdouble *sweep_angle;
  IGRboolean *pos_orient_flag;
);

override
  EMgetbsdef,
  GRgetsize,
  GRgenabsg,
  EMgetRuleLineTable;

#ifndef BASE_EMS

message EMputRevolvedFormat
(
  IGRlong *EMmsg;
  struct GRmd_env *md_env;
  struct GRpost_info *post_info;
  struct IGRbsp_curve *curve;
  IGRdouble *axis;
  IGRboolean is_360;
  IGRdouble start_angle;
  IGRdouble sweep_angle;
  IGRboolean pos_orient_flag;
);

message EMrevolve_curve
(
  struct GRvg_construct *construct_list;
  struct GRlc_info *curve_info;
  struct IGRbsp_curve *curve;
  double axis_line[2][3];
  double start_angle;
  double sweep_angle;
  int is_full_revolution;
  IGRboolean pos_orient_flag;
  OM_S_OBJID *new_objid;
  int *msg;
);
 
override
  EMget_natedge_info,
  GRreport,
  GRreport_defaults, 
  GRupdate_gadgets,
  GRkeypoint,
  GRcentcurv,
  GRxform,
  EMget_int_data,
  EMget_params;

#endif

end specification EMSrevol;
