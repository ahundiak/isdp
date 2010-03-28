/* 
  ABSTRACT

  This is the parent class for all graphics objects.


  HISTORY

  SDM 12/24/85 : Creation Date
  MAS 03/24/86 : Altered for new features
  MAS 09/01/87 : Changed for release 1.1
  AIC 04/24/91 : Added level (moved from GRvg)
  AIC 07/04/91 : Added GR[put/get/chg]name (moved from GRvg)
  AIC 02/05/92 : Added channel_pass for FEM.
  SCW 05/06/92 : Conversion to ANSI
  SPR 06/29/93 : Added GRadd_to_display_list message
  CMD 07/21/93 : Added and rejected GRisparent
  Sud 01/30/95 : Added and rejected GRanalyze_element
*/

class specification GRgraphics (1:1) of Root;

#include <stdio.h>
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "OMindex.h"
#include "OMerrordef.h"
#include "OMlimits.h"
#include "igrdef.h"
#include "madef.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"
#include "lcdef.h"
#include "lc.h"
#include "dpstruct.h"
#include "report.h"
#include "GRchanpass.h"

/*------------------ INSTANCE DATA SECTION -------------------*/

instance GRgraphics
{
  IGRshort properties;
  IGRshort level;
};


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

message GRgetprops
(
  IGRlong *msg;
  IGRshort *props;
);

message GRgethprops
(
  IGRlong *msg;
  IGRuint *props;
);

message GRgetrang
(
  IGRlong *msg;
  IGRshort *matrix_type;
  IGRmatrix matrix;
  IGRboolean *world;
  GRrange range;
);

message GRlevelcount
(
  IGRlong *msg;
  IGRint *byte_count;
  IGRint *object_count;
);

message GRchgprops
(
  IGRlong *msg;
  IGRshort *action;
  IGRshort *props;
);

reject
  GRgetrang,
  GRlevelcount,
  GRgetprops,
  GRgethprops,
  GRchgprops;

#ifndef BASE_EMS

message GRgetname
(
  IGRlong *msg;
  IGRchar *name;
);

message GRprismrel
(
  IGRlong *msg;
  IGRshort *mx_type;
  IGRmatrix matrix;
  IGRlong *prism_rel;
  IGRshort *type_prism;
  IGRchar *prism;
  IGRlong *relationship;
);

message GRlocate
(
  struct GRlc_cvl *cvl;
  OM_p_KEY_DESC range_key;
);

message GRlocate_processing
(
  IGRlong *msg;
  struct GRlc_cvl *cvl;
  struct GRlc_path *path;
  IGRint *path_position;
  IGRint *owner_eligible;
  IGRint *component_eligible;
);

message GRputname
(
  IGRlong *msg;
  IGRchar *name;
);

message GRchgname
(
  IGRlong *msg;
  struct GRmd_env *env;
  IGRchar *name;
);

message GRlocaldp
(
  IGRlong *msg;
  IGRshort *type;
  IGRmatrix matrix;
  struct GRparms *parms;
  enum GRdpmode *mode;
  struct GRid *display_info;
  IGRshort *display_location;
  IGRshort *display_flag;
);

message GRgetobjinfo
(
  IGRlong *msg;
  struct GRobj_info *info;
);

message GRapprojpt
(
  IGRlong *msg;
  IGRshort *matrix_type;
  IGRmatrix matrix;
  struct GRparms *locate_parms;
  struct IGRline *boreline;
  IGRpoint proj_pt;
  struct GRparms *proj_parms;
);

message GRptproject
(
  IGRlong *msg;
  IGRshort *matrix_type;
  IGRmatrix matrix;
  IGRpoint point;
  IGRpoint proj_pt;
  struct GRparms *proj_parms;
);

message GRlnproject
(
  IGRlong *msg;
  IGRshort *matrix_type;
  IGRmatrix matrix;
  struct IGRline *line;
  IGRpoint ln_pt;
  IGRpoint proj_pt;
  IGRdouble *t;
  struct GRparms *proj_parms;
);

message GRdisyourself
(
  IGRlong *msg;
  IGRshort *mx_type;
  IGRmatrix matrix;
  enum GRdpmode *mode;
  struct IGRaltdisplay *alt_symb;
  struct DP_information *sp_info;
  OM_p_KEY_DESC range_key;
);

message GRcopy
(
  IGRlong *msg;
  struct GRmd_env *obj_dsenv;
  struct GRmd_env *new_dsenv;
  GRobjid *newobjid;
);

message GRcptform
(
  IGRlong *msg;
  struct GRmd_env *md_env;
  IGRmatrix matrix;
  struct GRmd_env *new_env;
  GRobjid *newobjid;
);

message GRclip
(
  IGRlong *msg;
  struct GRmd_env *cur_env;
  struct GRmd_env *target_env;
  IGRchar *prism;
  struct GRid *inside_id;
  struct GRid *outside_id;
  struct GRid *ovl_id;
  IGRlong *clip_flags;
);

message GRdelete
(
  IGRlong *msg;
  struct GRmd_env *md_env;
);

message GRdisplay
(
  IGRlong *msg;
  IGRshort *type;
  IGRmatrix matrix;
  enum GRdpmode *mode;
  struct GRid *display_info;
);

message GRxform
(
  IGRlong *msg;
  struct GRmd_env *md_env;
  IGRshort *matrix_type;
  IGRmatrix matrix;
  GRobjid *newobjid;
);

message GRconstruct
(
  struct GRvg_construct *arglist;
);

message GRaltconstruct
(
  struct GRvg_construct *arglist;
);

message GRformatele
(
  IGRlong *msg;
  struct GRmd_env *md_env;
  IGRchar *dgn_buf;
  IGRchar *bs_buf;
  IGRchar *ele_buf;
  IGRint *ele_size;
  IGRint *file_des;
  IGRdouble *max_overflow;
  IGRdouble *scale_factor;
);

message GRplotyourself
(
  IGRlong *msg;
  struct GRmd_env *md_env;
  IGRchar *dgn_buf;
  IGRchar *bs_buf;
  IGRchar *ele_buf;
  IGRint *ele_size;
  IGRint *file_des;
  IGRdouble *max_overflow;
  struct GRid *id_info;
  IGRdouble *scale_factor;
);

message GRaddwrng
(
  IGRlong *msg;
  struct GRmd_env *md_info;
);

message GRremwrng
(
  IGRlong *msg;
  struct GRmd_env *md_info;
);

message GRgentform
(
  IGRlong *msg;
  struct GRmd_env *md_env;
  IGRint (*tform_function)();
  IGRchar *info;
  GRobjid *newobjid;
);

message GRcpforundo
(
  IGRlong *msg;
  struct GRmd_env *obj_env;
  struct GRmd_env *new_env;
  IGRboolean *delete;
  GRobjid *new_objid;
);

message GRundocp
(
  IGRlong *msg;
  struct GRmd_env *env;
  IGRboolean *delete;
);

message GRfunction
(
  IGRlong *msg;
  IGRint (*user_function)();
  IGRchar *user_info;
);

message GRidchanged
(
  IGRlong *msg;
  IGRshort *num_ids;
  struct GRid *newids;
);

message GRptprocess
(
  IGRlong *msg;
  IGRshort *matrix_type;
  IGRmatrix matrix;
  IGRdouble *acc_tolerance;
  IGRpoint point;
  IGRpoint proj_pt;
  struct GRparms *proj_parms;
);

message GRlnprocess
(
  IGRlong *msg;
  IGRshort *matrix_type;
  IGRmatrix matrix;
  IGRdouble *acc_tolerance;
  struct IGRline *line;
  IGRpoint ln_pt;
  IGRpoint proj_pt;
  IGRdouble *t;
  struct GRparms *proj_parms;
);
 
message GRplotprep
(
  IGRlong *msg;
  struct GRmd_env *cur_env;
  struct GRmd_env *target_env;
  IGRshort *num_prisms;
  struct IGRcv_prism *prism_array;
  struct GRid *set_id;
  IGRlong *begin_index;
  IGRlong *end_index;
);

message GRrcopy
(
  IGRlong *msg;
  struct GRmd_env *obj_dsenv;
  struct GRmd_env *new_dsenv;
  GRobjid *newobjid;
);

message GRreport_defaults
(
  IGRlong *msg;
  IGRchar *form;
  IGRint *label;
  IGRint *list_size;
  struct GRreport_processor *processor;
);

message GRreport
(
  IGRlong *msg;
  struct GRmd_env *md_env;
  IGRint *list_size;
  struct GRreport_item *list;
  struct GRreport_processor *processor;
);

message GRupdate_gadgets
(
  IGRlong *msg;
  IGRchar *form_ptr;
);

message GRchannel_pass
(
  GR_S_PATH_LIST path[];
  int num_levels;
  OM_p_MESSAGE msg;
);

message EMvalidate
(
  IGRlong *msg;
  struct GRmd_env *mod_info;
  IGRchar *geom;
  GRobjid *cancer;
  IGRushort *option;
  IGRchar *objinfo;
  IGRchar *ioptr;
);
                
message GRadd_to_display_list
(
  IGRlong *msg;
  IGRboolean is_hidden_line;
);

message GRisparent
(
  IGRlong *msg;
  IGRboolean *isparent;
);

message GRanalyze_element
(
  IGRlong *msg;
  struct GRmd_env *md_env;
  FILE *rep_file_ptr;
  enum GRanalyze_types *analyze_option;
);

/*
  DESCRIPTION

  The following message prints the contents of this object into the FILE
  (which could be stderr or stdout). The printing is done with the left
  margin indented by 'num_indent'. If 'include_super_class' is TRUE, then
  the contents of it's super classes are also printed. This is useful when
  implementing this method for classes that have rejected the instance data
  of some of the super class. Also, if 'print_full_format' is FALSE then the
  object may decide not to print all the contents (eg: the actual geometry
  may not be printed. Only the control and attribute information may be
  printed). The interpretation of this latter flag is left to the implementing
  class.

  All objects connected to this object have their ids printed. Their contents
  are not printed.
*/

message GRprint
(
  FILE *file;
  IGRint num_indent;
  IGRboolean print_super_class;
  IGRboolean print_full_format; 
);

/*
  DESCRIPTION

  The following message reads data from FILE into this object. The data is
  expected to be limited to this class alone and not it's super classes if
  flag -- 'read_super_class' is FALSE. Also, if the flag -- 'read_full_format'
  is FALSE the data is expected to be limited to this class's short format.

  This method will connect this object to the object id's being read in.
  First the connections on the particular channel are destroyed and then
  these new connections esatblished.
*/

message GRread
(
  FILE *file;
  IGRboolean read_super_class;
  IGRboolean read_full_format;
);

reject
  GRprismrel,
  GRlocate,
  GRlocate_processing,
  GRapprojpt,
  GRptproject,
  GRlnproject,
  GRdisyourself,
  GRxform, 
  GRconstruct,
  GRformatele,
  GRplotyourself,
  GRaddwrng,
  GRremwrng,
  GRaltconstruct,
  GRreport_defaults,
  GRreport,
  GRupdate_gadgets,
  EMvalidate,
  GRisparent,
  GRclip,
  GRanalyze_element;

override 
  debug; 

#endif

end specification GRgraphics;
