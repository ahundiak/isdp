/*
  ABSTRACT

  This is an abstract class which represents surfaces that can be
  represented by projecting a planar curve along the normal to
  the plane of the curve.


  HISTORY

  06/05/91    msm     Override GRreport, GRreport_defaults, GRupdate_gadgets.
                      Removed override GRloadform and GRgetsfsize.
  08/10/88    dhm     Override EMget_params.
  08/10/88    dhm     Override GRgetsfsize and GRloadform.
  01 Jun 88   AIC     Consolidated EMgetBaseCurve and
                      EMgetProjection into EMgetProjection.
                      This had to be done to fix reference
                      files for orthagonal cases.
  06 May 88   AIC     Removed planarity argument from
                      EMpjPutProjectedFormat.
  02 May 88   AIC     Added planarity argument to EMpjPutProjectedFormat
  10 Mar 88   AIC     Modified to support projected formats.
  13 Oct 87   AIC     Conversion to EMS 1.1
  05/28/87 : rlw : Changed the placement method (rewrote it)
  09/21/86 : rlw : The beginning
*/

class specification EMSproject (2:0) of EMSsubbs;

/*--------------- MESSAGE DECLARATION SECTION ----------------*/

message EMgetProjection
(
  IGRlong *EMmsg;
  IGRshort *matrix_type;
  IGRmatrix matrix;
  IGRboolean cv_header_only;
  IGRuchar *format;
  union EMSprojectionFormat *projection;
  struct IGRbsp_curve *curve;
);

override
  EMgetbsdef,
  GRgetsize,
  GRgenabsg;

#ifndef BASE_EMS

message EMputProjectedFormat
(
  IGRlong *EMmsg;
  struct GRmd_env *md_env;
  struct GRpost_info *post_info;
  IGRboolean pos_orient_flag;
  struct IGRbsp_curve *curve;
  unsigned char projection_format;
  union EMSprojectionFormat *projection_data;
);

message EMplace_surface_of_projection
(
  struct GRvg_construct *construct;
  struct GRid *curve_id;
  struct GRmd_env *curve_module_info;
  struct IGRbsp_curve *curve_geom;
  IGRuchar curve_type;
  IGRpoint point1;
  IGRpoint point2;
  IGRboolean pos_orient_flag;
  OM_S_OBJID *new_objid;
);

message EMgetDirection
(
  IGRlong *EMmsg;
  struct IGRbsp_surface *my_geom;
  IGRboolean *along_v;
);

override
  EMget_natedge_info,
  GRreport,
  GRreport_defaults, 
  GRupdate_gadgets,
  EMget_params,
  EMmodifiedClass,
  GRxform,
  EMget_int_data;
    
#endif

end specification EMSproject;
