/* 
  ABSTRACT

  The vector graphics class defines a common set of 
  symbology information contained in all geometric 
  class definitions.

  HISTORY
        
  KMO 03/24/86 : Creation date.
  MAS 09/03/87 : Altered to 1.1 version
  AIC 04/24/91 : Removed level (moved to GRgraphics)
  AIC 07/04/91 : Removed GR[put/get/chg]name (moved to GRgraphics)
  SCW 05/06/92 : Converted to ANSI
  Sud 01/30/95 : Override Granalyze_element
*/

class specification GRvg (1:1) of GRgraphics,GRnotify,GRconnector;

#include "EMmsg_obj.h"
#include "emsdattyp.h"
#include "emsinter.h"

/*------------------ INSTANCE DATA SECTION -------------------*/

instance GRvg
{
    struct IGRdisplay display_attr;     
};

taggable;


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

message GRgeomprops
(
  IGRlong *msg;
  IGRshort *mat_type;
  IGRmatrix matrix;
  struct GRprops *properties;
);

message GRgetattr
(
  IGRlong *msg;
  IGRchar *attr;
);

message GRgetsymb
(
  IGRlong *msg;
  struct GRsymbology *symb;
);

message GRgenabsg
(
  IGRlong *msg;
  IGRshort *matrix_type;
  IGRmatrix matrix;
  IGRchar **absgptr;
);

message GRgetgeom
(
  IGRlong *msg;
  IGRshort *matrix_type;
  IGRmatrix matrix;
  IGRchar *geometry;
);

message GRgetsize
(
  IGRlong *msg;
  IGRshort *matrix_type;
  IGRmatrix matrix;
  IGRlong *size;
);

message GRputsymb
(
  IGRlong *msg;
  struct GRsymbology *symb;
);

message GRdetplane
(
  IGRlong *msg;
  IGRshort *matrix_type;
  IGRmatrix matrix;
  struct IGRplane *plane;
);

reject
  GRgenabsg,
  GRgeomprops,
  GRgetgeom,
  GRgetattr,
  GRdetplane,
  GRgetsize;

override
  GRgetprops,
  GRgethprops,
  GRgetrang,
  GRlevelcount,
  GRchgprops;

#ifndef BASE_EMS

message GRclipto
(
  IGRlong *msg;
  IGRchar *classname;
);
 

message GRgetexgeom
(
  IGRlong *msg;
  IGRshort *matrix_type;
  IGRmatrix matrix;
  IGRchar *geometry;
);

message GRgetexsize
(
  IGRlong *msg;
  IGRshort *mx_type;
  IGRmatrix matrix;
  IGRlong *size;
);

message GRkeypoint
(
  IGRlong *msg;
  IGRshort *matrix_type;
  IGRmatrix matrix;
  struct IGRline *boreline;
  IGRpoint keypoint;
  struct GRparms *key_parm;
);

message GRmodify
(
  IGRlong *msg;
  struct GRmd_env *md_env;
  struct GRparms *parms;
  IGRpoint point;
  struct IGRline *boreline;
  GRobjid *new_objid;
);

message GRprojpt
(
  IGRlong *msg;
  IGRshort *matrix_type;
  IGRmatrix matrix;
  struct GRparms *locate_parms;
  IGRpoint point;
  IGRpoint proj_pt;
  struct GRparms *proj_parms;
);

message GRpostabsg
(
  IGRlong *msg;
  struct GRmd_env *md_env;
  struct GRpost_info *info;
  IGRchar *absptr;
  GRobjid *newobjid;
);

message GRptdis
(
  IGRlong *msg;
  IGRshort *matrix_type;
  IGRmatrix matrix;
  IGRpoint point;
  IGRdouble *distance;
);

message GRputattr
(
  IGRlong *msg;
  IGRchar *attr;
);

message GRchghprops
(
  IGRlong *msg;
  IGRshort *action;
  IGRint *mask;
);

message GRchgcolor
(
  IGRlong *msg;
  IGRuint *rgb_value;
  IGRushort *color;
);

message GRchgdp
(
  IGRlong *msg;
  struct IGRdisplay *dp_info;
);

message GRchglevel
(
  IGRlong *msg;
  IGRshort *level;
);

message GRchgstyle
(
  IGRlong *msg;
  IGRuchar *style;
);

message GRchgweight
(
  IGRlong *msg;
  IGRuchar *weight;
);

message GRcenter
(
  IGRlong *msg;
  IGRshort *mat_type;
  IGRmatrix matrix;
  IGRpoint center;
);

message GRcentcurv
(
  IGRlong *msg;
  IGRshort *mat_type;
  IGRmatrix matrix;
  struct GRparms *u;
  IGRpoint center;
);

message GRstretch
(
  IGRlong *msg;
  struct GRmd_env *md_env;
  IGRshort *type_prism;
  IGRchar *prism;
  IGRmatrix xform_matrix;
  GRobjid *objid;
);

message EMpratpt
(
  IGRlong *msg;
  IGRshort *mat_type;
  IGRmatrix matrix;
  IGRpoint wpoint_xyz;
  IGRdouble point_parametric[];
  IGRint *num_parameters;
);

message EMptatpr
(
  IGRlong *msg;
  IGRshort *mat_type;
  IGRmatrix matrix;
  IGRdouble point_parametric[];
  IGRint num_parameters;
  IGRpoint wpoint_xyz;
);

message GRfragment
(
  IGRlong *msg;
  struct GRmd_env *env;
  struct GRid *owner;
  struct GRmd_env *new_env;
);

message GRcoplanar
(
  IGRlong *msg;
  IGRshort *matrix_type;
  IGRmatrix matrix;
  IGRshort *num_objects;
  GRobjid *objid_ids;
  IGRdouble *tolerance;
  struct IGRplane *plane;
);

message GRinplane
(
  IGRlong *msg;
  IGRshort *matrix_type;
  IGRmatrix matrix;
  struct IGRplane *plane;
  IGRdouble *tolerance;
  IGRshort *rel;
);

message GRputrang
(
  IGRlong *msg;
  GRrange range;
);

message GRdynmod
(
  IGRlong *msg;
  IGRshort *mat_type;
  IGRmatrix matrix;
  struct GRparms *modpt;
  IGRpoint point;
  enum GRdyn_flag *action;
  IGRchar *buff;
  IGRboolean (*func)();
);

message EMintplane
(
  struct GRvg_construct *construct_list;
  struct IGRplane *plane;
  struct GRlc_info *located_object;
  IGRint *num_of_intersections;
  struct GRid **ptr_to_resulting_intersections;
  IGRint *msg;
);

message EMgetpoles
(
  IGRlong *msg;
  IGRshort *mat_type;
  IGRmatrix mat;
  IGRlong *frominx;
  IGRlong *offset;
  IGRdouble *buff;
  IGRlong buff_size;
  IGRlong *ret_num;
  IGRboolean *is_reg;
);

message DEdisyourself
(
  long *msg;
  short *type;
  IGRmatrix matrix;
  enum GRdpmode *mode;
  struct IGRaltdisplay *alt_symb;
  struct DP_information *sp_info;
  OM_p_KEY_DESC *key;
);

reject
  GRclipto,
  GRkeypoint,
  GRmodify,
  GRpostabsg, 
  GRputattr,
  GRcentcurv,
  GRcenter,
  EMpratpt,
  EMptatpr,
  EMintplane,
  EMgetpoles,
  GRinplane,
  GRdynmod, 
  GRfragment;

override 
  GRapprojpt,
  GRplotyourself,
  GRformatele,
  GRaddwrng,
  GRremwrng,
  debug,
  GRlocate,
  GRlocate_processing,
  GRanalyze_element,
  GRprint,
  GRread;

#endif

end specification GRvg;
