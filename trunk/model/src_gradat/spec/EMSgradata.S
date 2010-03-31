/*
  ABSTRACT

  This class represents graphics data for surfaces. It is used to
  optimize and override graphics operations such as display and
  locate. EMSgradata stores the graphics information about the
  surface as clipped rule lines. It is connected to the surface
  on which it exists and to the Ploop that defines its outter
  boundary.


  HISTORY

  13 October 87   AIC     Creation Date (From EMSfrt).
  12/08/87        RC      Added EMdelete_nat_gradata and
                          EMchangeLoop messages.
  20-Jan-88       SM      added 'eligible_edge_types' argument to
                          EMexecuteCurveFunction.
  14 February 87  AIC     Added prism_rel to argument list of EMlocate.
  17 June 88      SAM     Added EMnotify_surface_range_modify.
  20 October 88   RC      Added messages EMuv_transform,  EMset_props,
                          and EMputRLT.
  02 January 89   AIC     Added EMgetAlternateDisplay message.
  01 April 91     SCW     Removed props from instance data -> moved
                          up to EMShelper, Bumped version counter,
                          Moved the following messages up to the
                          EMShelper class:  EMexecuteCurveFunction,
                          EMlocate, EMdisplay, EMkeypoint, EMreset,
                          EMset_props.
  13 June 91      Jack    Added override of EMget_the_edges message.
                          Originally declared at EMShelper.
  19 Mar 92       Jack    Moved 3 message definitions up from here to 
                          EMShelper.  They are rejected there and 
                          overridden here.  EMchangeClass, 
                          EMdelete_nat_gradata, and EMget_class_info.
  25 Sep 92       Jack    Moved orig def of EMchangeSurface up to 
                          EMShelper.  We will inherit it now.
*/

class specification EMSgradata (1:0) of EMShelper;

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

# ifndef griodef_include
# include "griodef.h"
# endif

# ifndef godef_include
# include "godef.h"
# endif

# ifndef go_include
# include "go.h"
# endif

# ifndef ex_include
# include "ex.h"
# endif

# ifndef grio_include
# include "grio.h"
# endif

# ifndef lcdef_include
# include "lcdef.h"
# endif

# ifndef dp_include
# include "dp.h"
# endif

# ifndef lc_include
# include "lc.h"
# endif

# ifndef dpstruct_include
# include "dpstruct.h"
# endif

# ifndef emsdattyp_include
# include "emsdattyp.h"
# endif

# ifndef emsinter_include
# include "emsinter.h"
# endif

# ifndef EMSbnddef_include
# include "EMSbnddef.h"
# endif

# ifndef EMSbnd_include
# include "EMSbnd.h"
# endif

/*------------------ INSTANCE DATA SECTION -------------------*/

instance EMSgradata
{
  variable IGRdouble        double_data[];  
  variable unsigned short   short_data[];   
  unsigned char             num_u_rules;    
  unsigned char             num_v_rules;    
};


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

message EMgetRLT
(
  IGRlong *EMmsg;
  IGRchar *buffer;
  IGRint buffer_size;
  struct IGResqbs **rlt;
);

#ifndef BASE_EMS

message EMputAlternateDisplay
(
  IGRlong *EMmsg;
  short unsigned    color;
  IGRuchar weight;
  IGRuchar style;
);

message EMgetAlternateDisplay
(
  IGRlong *EMmsg;
  IGRuint *rgb_value;
  short unsigned        *color;
  IGRuchar *weight;
  IGRuchar *style;
  struct IGRaltdisplay *alt_display;
);

message EMgetGraphics
(
  IGRlong *EMmsg;
  IGRchar *rlt_buffer;
  IGRint rlt_buffer_size;
  struct IGResqbs **rlt;
  IGRshort *mx_type;
  IGRmatrix mx;
  GRobjid surf_id;
  struct IGRbsp_surface *in_surface;
  struct IGRbsp_surface **out_surface;
);

message EMupdate
(
  IGRlong *EMmsg;
  IGRshort *mx_type;
  IGRmatrix mx;
  struct IGResqbs **rlt;
  struct IGResbs *bs_attr;
  struct IGRbsp_surface *surface;
  IGRchar *buffer;
  IGRint buffer_size;
  struct EMSpartolbasis *partol;
);

message EMclip
(
  IGRlong *EMmsg;
  struct IGResqbs *rlt;
  struct EMSpartolbasis *partol_basis;
  IGRshort *matrix_type;
  IGRmatrix matrix;
  struct IGRbsp_surface *surface;
);

message EMinit
(
  IGRlong *EMmsg;
  GRobjid surf_id;
  GRobjid loop_id;
);

message EMchangeLoop
(
  IGRlong *EMmsg;
  GRobjid loop_id;
);

message EMnotify_surface_range_modify
(
  IGRlong *EMmsg;
);

message EMuv_transform
(
  IGRlong *EMmsg;
  IGRdouble matrix[16];
  struct EMSpartolbasis *partolbasis;
  IGRshort options;
);

message EMputRLT
(
  IGRlong *EMmsg;
  struct IGResqbs *rlt;
);

message EMdelete_nat_gradata
(
  IGRlong *EMmsg;
);

message EMget_class_info
(
  IGRlong *EMmsg;
  OMuword *gradata_classid;
  OM_p_MESSAGE messg;
);

override
  debug,
  delete,
  EMexecuteCurveFunction,
  EMlocate,
  EMkeypoint,
  EMdisplay,
  EMreset,
  EMchangeClass,
  EMget_the_edges;

#endif

end specification EMSgradata;
