/*
  ABSTRACT

  This class represents classes that exist to help other objects.

  
  HISTORY

  09 December 87  AIC     Creation Date
  01 April 91     SCW     Bumped version counter, Added props to the
                          class instance data, and brought up the
                          following messages from EMSgradata:
                          EMexecuteCurveFunction, EMlocate, EMkeypoint,
                          EMdisplay, EMreset, EMset_props.
  11 June 91      Jack    Added method EMdel_hrz_cusp which will be
                          overridden at EMShorizon and EMScusp to 
                          delete my_id.  Other classes that inherit
                          it will just return success.
  11 June 91      SCW     Added EMcreator_undoing message.
  13 June 91      Jack    Added EMget_the_edges message.
  04 July 91      Jack    Added EMcheck_orientation.
  13 August 91    Jack    Added struct GRid *obj parm to the
                          message EMcheck_orientation.
  16 Sep 91       Jack    Added struct GRmdenv_info *mdenv_info parm to 
                          EMcheck_orientation and EMget_the_edges.
  19 Mar 92       Jack    Moved 3 messages up from EMSgradata to here.
                          EMchangeClass, EMdelete_nat_gradata, and 
                          EMget_class_info.  All are rejected here.
  24 Sep 92       Jack    Moved initial def of EMchangeSurface up from
                          EMSgradata to here so it can be inherited at
                          EMSgraloop and EMSgradata.
*/

class specification EMShelper (1:0) of Root;

# ifndef OMerrordef_include
# include "OMerrordef.h"
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef igetypedef_include
# include "igetypedef.h"
# endif

# ifndef dp_include
# include "dp.h"
# endif

# ifndef gr_include
# include "gr.h"
# endif

# ifndef EMcp_include
# include "EMcp.h"
# endif

/*------------------ INSTANCE DATA SECTION -------------------*/

instance EMShelper
{
  channel
  {
    (rel_ordered,
     many_to_many,
     initial = 1, increment = 1)
    EMSrequester.to_helpers;
  }                to_requesters;

  IGRuchar   props;          
};


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

message EMset_props
(
  IGRlong *EMmsg;
  IGRushort props;
  IGRshort option;
);

#ifndef BASE_EMS

message EMcreator_undoing
(
  IGRlong *EMmsg;
  GRobjid *creator_id;
);

message EMhelperCopy
(
  IGRlong *EMmsg;
  struct GRid *new_geom_id;
  struct EMcp_info *copy_info;
);

message EMhelperConnect
(
  IGRlong *EMmsg;
  GRobjid req_id;
  IGRint index;
);

message EMexecuteCurveFunction
(
  IGRlong *EMmsg;
  struct IGRbsp_surface *surf;
  IGRshort *mx_type;
  IGRmatrix mx;
  GRobjid surf_id;
  IGRint (*f)();
  IGRchar *args;
  IGRushort eligible_edge_type;
);

message EMlocate
(
  IGRlong *EMmsg;
  struct IGRbsp_surface *surface;
  struct GRlc_info *loc_parms;
  struct GRlc_cvl *cvl;
  IGRlong *prism_rel;
  IGRboolean *inside;
  IGRboolean *outside;
  IGRboolean *overlap;
  IGRboolean *was_located;
  struct GRid *window_id;
);

message EMkeypoint
(
  IGRlong *EMmsg;
  struct IGRbsp_surface *surf;
  IGRshort *matrix_type;
  IGRmatrix matrix;
  struct IGRline *boreline;
  IGRdouble *dist;
  IGRpoint keypoint;
  struct GRparms *key_parm;
  struct GRid *window_id;
);

message EMdisplay
(
  IGRlong *msg;
  IGRboolean owner_origin;
  enum GRdpmode *mode;
  struct DP_information *sp_info;
  struct IGResbs *bs_attr;
  struct DPele_header *ele_header;
  IGRshort *mx_type;
  IGRmatrix matrix;
  IGRchar *buffer;
  IGRint buffer_size;
  struct EMSpartolbasis *partol;
  IGRboolean *display_done;
  struct GRid *window_id;
);

message EMreset
(
  IGRlong *EMmsg;
  IGRushort options;
);

message EMget_the_edges
(
  IGRlong *EMmsg;
  IGRshort options;
  IGRdouble *z_vector;
  struct GRmdenv_info *mdenv_info;
  IGRint *num_gralp_edges;
  IGRint *num_horiz_edges;
  IGRint *num_cusp_edges;
  struct GRid **gralp_edges;
  struct GRid **horiz_edges;
  struct GRid **cusp_edges;
);

message EMcheck_orientation
(
  double vector[3];
  struct GRmdenv_info *mdenv_info;
  int *match;
  double *result;
  struct GRid *obj;
);

message EMchangeClass
(
  IGRlong *EMmsg;
  OMuword new_classid;
  OM_p_MESSAGE messg;
  GRobjid *newobjid;
);

message EMchangeSurface
(
  IGRlong *EMmsg;
  GRobjid surface_id;
);

reject
  EMexecuteCurveFunction,
  EMlocate,
  EMkeypoint,
  EMdisplay,
  EMreset,
  EMchangeClass,
  EMget_the_edges;

#endif

end specification EMShelper;
