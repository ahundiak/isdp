/* $Id: VDct4Basei.I,v 1.1.1.1 2001/01/04 21:08:03 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct4/imp/VDct4Basei.I
 *
 * Description: Tree Object
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct4Basei.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:03  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1999/06/29  18:26:28  pinnacle
# ct
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/28/99  ah      Creation
 ***************************************************************************/

class implementation VDct4Base;

#include	"VDtypedef.h"

#define MSG_STR "VDct4Base "

from VDct4Defn import VDctDefnSetName;
from VDct4Defn import VDctDefnSetOccID;

/* -------------------------------------------
 * Some tracing capability
 */
static int traceFlag;

IGRstat VDct4BaseiSetTraceFlag(IGRint flag)
{
  traceFlag = flag;
  return 1;
}

/* -------------------------------------------
 * NDmacro
 */
method ACin_macro_def
(
  IGRint *in_def;
)
{
  printf("%s %s %d %s\n",MSG_STR,"NDmacro",my_id,"ACin_macro_def");
  return OM_W_ABORT;
}

method ACbecome_macro
(
  IGRlong *msg;
  IGRint position;
  struct GRmd_env *md_env;
)
{
  printf("%s %s %d %s\n",MSG_STR,"NDmacro",my_id,"ACbecome_macro");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method ACgive_structure
(
  int *suc;
  int *direct_index;
  char *footname;
  struct ret_struct *ptr_rst;
  struct GRmd_env *md_env;
)
{
  printf("%s %s %d %s\n",MSG_STR,"NDmacro",my_id,"ACgive_structure");
  *suc = MSFAIL;
  return OM_W_ABORT;
}

method ACreturn_foot
(
  IGRlong *msg;
  char *footname;
  struct GRid *foot_obj;
  IGRshort *mat_type;
  IGRdouble *matrix;
)
{
  printf("%s %s %d %s\n",MSG_STR,"NDmacro",my_id,"ACreturn_foot");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method ACgive_foot
(
  int *suc;
  char *footname;
  struct GRid *foot_obj;
)
{
  printf("%s %s %d %s\n",MSG_STR,"NDmacro",my_id,"ACgive_foot");
  *suc = MSFAIL;
  return OM_W_ABORT;
}

method ACtest_foot
(
  long *suc;
  char *footname;
)
{
  printf("%s %s %d %s\n",MSG_STR,"NDmacro",my_id,"ACtest_foot");
  *suc = MSFAIL;
  return OM_W_ABORT;
}

method ACcopy_to_Groot
(
  IGRlong *msg;
  IGRint cp_type;
  struct GRmd_env *md_env;
  struct GRmd_env *new_info;
  struct GRid *newobjid;
)
{
  printf("%s %s %d %s\n",MSG_STR,"NDmacro",my_id,"ACcopy_to_Groot");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method ACconsume
(
  IGRlong *msg;
  char *footname;
  int cpy_req;
  struct GRid *cpy_GRid;
  struct GRmd_env *md_env;
)
{
  printf("%s %s %d %s\n",MSG_STR,"NDmacro",my_id,"ACconsume");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method ACunconsume
(
  IGRlong *msg;
  char *footname;
)
{
  printf("%s %s %d %s\n",MSG_STR,"NDmacro",my_id,"ACunconsume");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method ACntf_consume
(
  IGRlong *msg;
)
{
  printf("%s %s %d %s\n",MSG_STR,"NDmacro",my_id,"ACntf_consume");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method ACntf_unconsume
(
  IGRlong *msg;
)
{
  printf("%s %s %d %s\n",MSG_STR,"NDmacro",my_id,"ACntf_unconsume");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method ACtest_consumed
(
  IGRlong *msg;
)
{
  printf("%s %s %d %s\n",MSG_STR,"NDmacro",my_id,"ACtest_consumed");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method ACbubble_up
(
  long *msg;
  char *footname;
  int up_index;
  OM_p_MESSAGE Condition;
  OM_p_MESSAGE Action;
  enum OM_e_wrt_flag delAction;
)
{
  printf("%s %s %d %s\n",MSG_STR,"NDmacro",my_id,"ACbubble_up");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method ACpass_up
(
  long *msg;
  int count;
  struct GRid list [];
  int up_index;
  OM_p_MESSAGE Condition;
  OM_p_MESSAGE Action;
  enum OM_e_wrt_flag delAction;
)
{
  printf("%s %s %d %s\n",MSG_STR,"NDmacro",my_id,"ACpass_up");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method ACbecome_foot
(
  long *msg;
  struct GRid *new_id;
  struct GRmd_env *md_env;
)
{
  printf("%s %s %d %s\n",MSG_STR,"NDmacro",my_id,"ACbecome_foot");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method ACmap_from_visible
(
  OM_S_OBJID **list;
  int *cur_obj_buf;
  int *count;
  int *sz_inst_save;
  int *cur_inst_buf;
  char **inst_save;
)
{
  printf("%s %s %d %s\n",MSG_STR,"NDmacro",my_id,"ACmap_from_visible");
  return OM_W_ABORT;
}

method ACcompute_node
(
  IGRlong *msg;
  IGRint cn_type;
  IGRint count;
  struct GRid list [];
  struct GRmd_env *md_env;
  int *prop;
  int *size_inst;
  int *no_go;
  char *inst_save;
)
{
  printf("%s %s %d %s\n",MSG_STR,"NDmacro",my_id,"ACcompute_node");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

/* ------------------------------------
 * NDnode
 */
method NDget_objects
(
  int type;
  struct GRid *list;
  int size;
  struct GRid **buffer;
  int ifrom;
  int ito;
  int *count;
)
{
  printf("%s %s %d %s\n",MSG_STR,"NDnode",my_id,"NDget_objects");
  return OM_W_ABORT;
}

method NDget_virtual_objects
(
  int type;
  struct GRid *list;
  int size;
  struct GRid **buffer;
  int ifrom;
  int ito;
  int *count;
  int *virt_count;
)
{
  printf("%s %s %d %s\n",MSG_STR,"NDnode",my_id,"NDget_virtual_objects");
  return OM_W_ABORT;
}

method NDconnect_graph
(
  IGRlong *msg;
  IGRint cp_type;
  struct GRmd_env *fr_env;
  struct GRmd_env *to_env;
  struct NDcp_list *copied_element;
  int copied_size;
  int nb_root;
  int *root_index;
  int my_index;
)
{
  printf("%s %s %d %s\n",MSG_STR,"NDnode",my_id,"NDconnect_graph");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method NDconnect
(
  int nb_root;
  struct GRid *root;
  struct GRid original;
  IGRint type;
)
{
  printf("%s %s %d %s\n",MSG_STR,"NDnode",my_id,"NDconnect");
  return OM_W_ABORT;
}

method NDdisconnect
(
  int nb_root;
  struct GRid *root;
)
{
  printf("%s %s %d %s\n",MSG_STR,"NDnode",my_id,"NDdisconnect");
  return OM_W_ABORT;
}

method NDchange_connect
(
  int nb_change;
  struct GRid *old;
  struct GRid *new;
)
{
  printf("%s %s %d %s\n",MSG_STR,"NDnode",my_id,"NDchange_connect");
  return OM_W_ABORT;
}

method NDupdate
(
  int *msg;
  int cn_type;
  int count;
  struct GRid *parents;
  int * parent_state;
  struct GRid *context;
  struct GRid *new_objid;
  struct GRmd_env *md_env;
)
{
  printf("%s %s %d %s\n",MSG_STR,"NDnode",my_id,"NDupdate");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method NDcompute_node
(
  IGRlong *msg;
  IGRint cn_type;
  IGRint count;
  struct GRid list [];
  struct GRmd_env *md_env;
)
{
  printf("%s %s %d %s\n",MSG_STR,"NDnode",my_id,"NDcompute_node");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method NDs_compute_node
(
  IGRlong *msg;
  IGRint cn_type;
  struct GRmd_env *md_env;
)
{
  printf("%s %s %d %s\n",MSG_STR,"NDnode",my_id,"NDs_compute_node");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method NDchange_node
(
  struct GRmd_env *obsolete_argument;
)
{
  printf("%s %s %d %s\n",MSG_STR,"NDnode",my_id,"NDchange_node");
  return OM_W_ABORT;
}

method NDgive_structure
(
  IGRlong *msg;
  struct ret_struct *str;
  struct GRmd_env *md_env;
)
{
  printf("%s %s %d %s\n",MSG_STR,"NDnode",my_id,"NDgive_structure");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method NDprint
(
  struct GRmd_env *md_env;
  FILE *stream;
)
{
  printf("%s %s %d %s\n",MSG_STR,"NDnode",my_id,"NDprint");
  return OM_W_ABORT;
}

method NDprint_root
(
  struct GRmd_env *md_env;
  FILE *stream;
)
{
  printf("%s %s %d %s\n",MSG_STR,"NDnode",my_id,"NDprint_root");
  return OM_W_ABORT;
}

method NDdelete
(
  struct GRmd_env *md_env;
)
{
  printf("%s %s %d %s\n",MSG_STR,"NDnode",my_id,"NDdelete");
  return OM_W_ABORT;
}

method NDplace
(
  struct GRas *assoc_list;
  struct GRmd_env *md_env;
  char *go_cnst_lis;
)
{
  printf("%s %s %d %s\n",MSG_STR,"NDnode",my_id,"NDplace");
  return OM_W_ABORT;
}

method NDget_state
(
  IGRchar *n_state;
)
{
  printf("%s %s %d %s\n",MSG_STR,"NDnode",my_id,"NDget_state");
  return OM_W_ABORT;
}

method NDchg_state
(
  IGRchar mask;
  IGRchar n_state;
)
{
  printf("%s %s %d %s\n",MSG_STR,"NDnode",my_id,"NDchg_state");
  return OM_W_ABORT;
}
  
method NDparent_deleted
(
  IGRlong *msg;
  IGRint count_deleted;
  struct GRid list_deleted [];
  struct GRid *new_obj;
  struct GRmd_env *md_env;
)
{
  printf("%s %s %d %s\n",MSG_STR,"NDnode",my_id,"NDparent_deleted");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method NDrm_assoc
(
  long *msg;
  struct GRid *new_object;
  struct GRmd_env *md_env;
)
{
  printf("%s %s %d %s\n",MSG_STR,"NDnode",my_id,"NDrm_assoc");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method NDmove_to_root
(
  IGRlong *msg;
  struct GRid *src_grid;
  struct GRmd_env *md_env;
)
{
  printf("%s %s %d %s\n",MSG_STR,"NDnode",my_id,"NDmove_to_root");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method NDchildren_deleted
(
  IGRlong *msg;
  IGRint count_deleted;
  struct GRid list_deleted [];
  struct GRid *new_obj;
  struct GRmd_env *md_env;
)
{
  printf("%s %s %d %s\n",MSG_STR,"NDnode",my_id,"NDchildren_deleted");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method NDdisplay
(
  IGRint obsolet;
  enum GRdpmode mode;
  struct GRmd_env *md_env;
)
{
  printf("%s %s %d %s\n",MSG_STR,"NDnode",my_id,"NDdisplay");
  return OM_W_ABORT;
}

method NDselect_copy
(
  long *msg;
  int select_type;
  struct GRid *selected_obj;
  int *info;
  int selected_size;
  int *selected_nb;
)
{
  printf("%s %s %d %s\n",MSG_STR,"NDnode",my_id,"NDselect_copy");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method NDcopy_graph
(
  IGRlong *msg;
  IGRint cp_type;
  struct GRmd_env *fr_env;
  struct GRmd_env *to_env;
  struct NDcp_list *copied_element;
  int copied_size;
  int my_index;
)
{
  printf("%s %s %d %s\n",MSG_STR,"NDnode",my_id,"NDcopy_graph");
  *msg = MSFAIL;
  return OM_W_ABORT;
}
 
method NDcopy
(
  IGRlong *msg;
  IGRint cp_type;
  struct GRmd_env *fr_env;
  struct GRmd_env *to_env;
  struct GRid *newobjid;
)
{
  printf("%s %s %d %s\n",MSG_STR,"NDnode",my_id,"NDcopy");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method NDnotify_connect
(
  struct GRid new_connected;
)
{
  printf("%s %s %d %s\n",MSG_STR,"NDnode",my_id,"NDnotify_connect");
  return OM_W_ABORT;
}

method NDnotify_disconnect
(
  struct GRid previous_connected;
)
{
  printf("%s %s %d %s\n",MSG_STR,"NDnode",my_id,"NDnotify_disconnect");
  return OM_W_ABORT;
}

method NDpossible_parent
(
  IGRint ifrom;
  IGRint ito;
  IGRint *geom_code;
  IGRint *option_code;
  IGRint *nb_tot;
)
{
  printf("%s %s %d %s\n",MSG_STR,"NDnode",my_id,"NDpossible_parent");
  return OM_W_ABORT;
}
		 
method NDcopy_to_tmp_root
(
  long *msg;
  int cp_type;
  struct GRmd_env *md_env;
  struct GRmd_env *new_info;
  struct GRid *newobjid;
)
{
  printf("%s %s %d %s\n",MSG_STR,"NDnode",my_id,"NDcopy_to_tmp_root");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method NDmove_to_tmp_clone
(
  long *msg;
  struct GRid *clone;
)
{
  printf("%s %s %d %s\n",MSG_STR,"NDnode",my_id,"NDmove_to_tmp_clone");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method NDcopy_to_root
(
  IGRlong *msg;
  IGRint cp_type;
  struct GRmd_env *md_env;
  struct GRmd_env *new_info;
  struct GRid *newobjid;
)
{
  printf("%s %s %d %s\n",MSG_STR,"NDnode",my_id,"NDcopy_to_root");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method NDmake_source
(
  IGRlong *msg;
  struct GRid *located_obj;
  struct GRid *context;
  char *path;
  GRspacenum as_osnum;
  struct GRid *as;
)
{
  printf("%s %s %d %s\n",MSG_STR,"NDnode",my_id,"NDmake_source");
  *msg = MSFAIL;
  return OM_W_ABORT;
}
  
method ASreturn_go
(
  struct GRid *go;
  IGRshort *mat_type;
  IGRdouble *matrix;
)
{
  printf("%s %s %d %s\n",MSG_STR,"NDnode",my_id,"ASreturn_go");
  return OM_W_ABORT;
}

/* ---------------------------------------------------------
 * Method is called when the file is saved,
 * If passed up the usual macro defination stuff starts up
 *
 * Just return success for this object for now
 */
method NDsleep
(
  struct GRmd_env *md_env;
)
{
  if (traceFlag) printf("%s %s %d %s\n",MSG_STR,"NDnode",my_id,"NDsleep");

  return OM_S_SUCCESS;
#if 0
  return om$send(msg = message VDSroot.
                 NDsleep(md_env),
	         mode = OM_e_wrt_message,
	         targetid = my_id);
#endif
}

method NDattach_to_cs
(
  IGRlong *msg;
  struct GRid cs_grid;
  struct GRid contents_grid;
  struct GRid *as_grid;
  struct GRmd_env *md_env;
)
{
  printf("%s %s %d %s\n",MSG_STR,"NDnode",my_id,"NDattach_to_cs");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method NDdetach_from_cs
(
  IGRlong *msg;
  struct GRid cs_grid;
  struct GRid contents_grid;
  struct GRid *as_grid;
  struct GRmd_env *md_env;
)
{
  printf("%s %s %d %s\n",MSG_STR,"NDnode",my_id,"NDdetach_from_cs");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method NDattach_to_track_pt
(
  IGRlong *msg;
  struct GRid pt_grid;
  struct GRid *as_grid;
  struct GRmd_env *md_env;
)
{
  printf("%s %s %d %s\n",MSG_STR,"NDnode",my_id,"NDattach_to_track_pt");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method NDdetach_from_track_pt
(
  IGRlong *msg;
  struct GRid pt_grid;
  struct GRid *as_grid;
  struct GRmd_env *md_env;
)
{
  printf("%s %s %d %s\n",MSG_STR,"NDnode",my_id,"NDdetach_from_track_pt");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method NDget_parent_type
(
  long *msg;
  int *type;
  char *info;
)
{
  printf("%s %s %d %s\n",MSG_STR,"NDnode",my_id,"NDget_parent_type");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method NDctl_parent_type
(
  long *msg;
  int type;
  char *info;
)
{
  printf("%s %s %d %s\n",MSG_STR,"NDnode",my_id,"NDctl_parent_type");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method NDdrawing_copy_geom
(
  struct GRid *selected_elements;
  int nb_elements;
  struct GRid **drawing_elements;
  int *nb_drawing_elem;
  double *vector;
  double *point;
  int *level;
  struct IGRlbsys *lbsys;
  struct GRmd_env *from_env;
  struct GRmd_env *to_env;
)
{
  printf("%s %s %d %s\n",MSG_STR,"NDnode",my_id,"NDdrawing_copy_geom");
  return OM_W_ABORT;
}

method NDdrawing_copy_attr
(
  struct myfeet *attr_name;
  int nb_attr;
  struct GRid *drawing_attr;
  struct GRmd_env *from_env;
  struct GRmd_env *to_env;
)
{
  printf("%s %s %d %s\n",MSG_STR,"NDnode",my_id,"NDdrawing_copy_attr");
  return OM_W_ABORT;
}

method NDparent_rf_detached
(
  IGRlong *msg;
  struct GRid *parent_grid;
  struct GRmd_env *md_env;
  struct GRid *new_obj;
)
{
  printf("%s %s %d %s\n",MSG_STR,"NDnode",my_id,"NDparent_rf_detached");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

/* ----------------------------------------------------------
 * ASnode
 */
method ACgive_path
(
  IGRint *suc;
  struct GRid *go_obj;
  IGRchar *footname;
)
{
  printf("%s %s %d %s\n",MSG_STR,"ASnode",my_id,"ACgive_path");
  *suc = MSFAIL;
  return OM_W_ABORT;
}

method ACconnect_pretend
(
  IGRint *suc;
  IGRchar *down_scan;
  struct GRid *pret_GRid;
)
{
  printf("%s %s %d %s\n",MSG_STR,"ASnode",my_id,"ACconnect_pretend");
  *suc = MSFAIL;
  return OM_W_ABORT;
}

method ACconnect_pretendin
(
  IGRint *suc;
  IGRchar *down_scan;
  struct GRid *pret_GRid;
  struct GRid *context;
)
{
  printf("%s %s %d %s\n",MSG_STR,"ASnode",my_id,"ACconnect_pretendin");
  *suc = MSFAIL;
  return OM_W_ABORT;
}

method ASconstruct_go
(
  struct GRas *asso_lis;
  struct GRmd_env *md_env;
  IGRchar *go_cnst_lis;
  GRclassid go_classid;
  IGRboolean altconstruct;
)
{
  printf("%s %s %d %s\n",MSG_STR,"ASnode",my_id,"ASconstruct_go");
  return OM_W_ABORT;
}

method ASpossible_parent
(
  IGRint ifrom;
  IGRint ito;
  IGRint *geom_code;
  IGRint *option_code;
  IGRint *track_point;
  IGRint *ref;
  IGRint *plan;
  IGRint *nb_return;
  IGRint *nb_tot;
)
{
  printf("%s %s %d %s\n",MSG_STR,"ASnode",my_id,"ASpossible_parent");
  return OM_W_ABORT;
}

method ASget_opt_ind
(
  IGRint index0;
  IGRint *index_track;
  IGRint *index_ref;
  IGRint *index_plane;
)
{
  printf("%s %s %d %s\n",MSG_STR,"ASnode",my_id," ASget_opt_ind");
  return OM_W_ABORT;
}

method ASadd_opt
(
  struct GRid opt;
  IGRint flag;
  struct GRmd_env *md_env;
)
{
  printf("%s %s %d %s\n",MSG_STR,"ASnode",my_id,"ASadd_opt");
  return OM_W_ABORT;
}

method ASpoststr
(
  IGRlong *msg;
  struct GRmd_env *md_env;
  struct GRpost_info *info;
  IGRshort nb_obj;
  IGRchar **str;
  struct GRid *newobjid;
)
{
  printf("%s %s %d %s\n",MSG_STR,"ASnode",my_id,"ASpoststr");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

/* ----------------------------------------------------------
 * ACcpx
 */
method find_macro
(
  struct GRid *macro
)
{
  IGRstat retFlag = OM_W_ABORT;

  if (traceFlag) printf("%s %s %d %s\n",MSG_STR,"ACcpx",my_id,"find_macro");
  if (macro == NULL) goto wrapup;

  *macro = me->mac_def;
   macro->osnum = VDcurOS;  // Always in same os as the ACcpx
  if (traceFlag) {
    printf("Macro Def %d,%d\n",macro->osnum,macro->objid);
  }
  retFlag = OM_S_SUCCESS;

wrapup:
  return retFlag;
}

method ACload_macro
(
  struct GRid macro
)
{
  if (traceFlag) printf("%s %s %d %s\n",MSG_STR,"ACcpx",my_id,"ACload_macro");
  me->mac_def = macro;
  return OM_S_SUCCESS;
}

method ACattach (int *suc;char *macro_name)
{
  IGRstat retFlag = OM_W_ABORT;
  TGRid   occID;

  if (traceFlag) printf("%s %s %d %s\n",MSG_STR,"ACcpx",my_id,"ACattach");
  if (macro_name == NULL) goto wrapup;

  // Create mac_def object
  me->mac_def.osnum = VDcurOS;
  me->mac_def.objid = NULL_OBJID;
  om$construct(classid =  OPP_VDct4Defn_class_id,
	       osnum   =  me->mac_def.osnum,
	       p_objid = &me->mac_def.objid);
  if (me->mac_def.objid == NULL_OBJID) goto wrapup;

  // Set the data
  om$send(msg = message VDct4Defn.VDctDefnSetName(macro_name),
          targetid = me->mac_def.objid,
          targetos = me->mac_def.osnum);

  occID.osnum = VDcurOS;
  occID.objid = my_id;
  om$send(msg = message VDct4Defn.VDctDefnSetOccID(&occID),
          targetid = me->mac_def.objid,
          targetos = me->mac_def.osnum);

  if (traceFlag) {
    printf("Attached %d,%d\n",me->mac_def.osnum,me->mac_def.objid);
  }

  // Done
  retFlag = OM_S_SUCCESS;

wrapup:
  if (retFlag & 1) *suc = MSSUCC;
  else             *suc = MSFAIL;

  return retFlag;
}

method ACfind_exp_temp_obj   (int *suc,pos;    struct GRid *temp_obj)
{
  printf("%s %s %d %s\n",MSG_STR,"ACcpx",my_id,"ACfind_exp_temp_obj");
  *suc = MSFAIL;
  return OM_W_ABORT;
}

method ACfind_exp_temp_struct(int *suc,pos;
		struct ret_struct *ptr_rst;struct GRmd_env *md_env )
{
  printf("%s %s %d %s\n",MSG_STR,"ACcpx",my_id,"ACfind_exp_temp_struct");
  *suc = MSFAIL;
  return OM_W_ABORT;
}

method ACdrop(struct GRmd_env *md_env)
{
  printf("%s %s %d %s\n",MSG_STR,"ACcpx",my_id,"ACdrop");
  return OM_W_ABORT;
}

method  ACbuild_rtn_str(struct GRmd_env *md_env; int cn_type )
{
  printf("%s %s %d %s\n",MSG_STR,"ACcpx",my_id,"ACbuild_rtn_str");
  return OM_W_ABORT;
}

method  ACtbuild_rtn_str(int tsize;struct GRid *list )
{
  printf("%s %s %d %s\n",MSG_STR,"ACcpx",my_id,"ACtbuild_rtn_str");
  return OM_W_ABORT;
}

method  ACfree_rtn_str()
{
  printf("%s %s %d %s\n",MSG_STR,"ACcpx",my_id,"ACfree_rtn_str");
  return OM_W_ABORT;
}

method  ACload_temp_feet(int tsize;struct GRid *list;struct GRmd_env *md_env)
{
  printf("%s %s %d %s\n",MSG_STR,"ACcpx",my_id,"ACload_temp_feet");
  return OM_W_ABORT;
}

method ACfind_temp_obj   (int *suc;char *name;    struct GRid *temp_obj)
{
  printf("%s %s %d %s\n",MSG_STR,"ACcpx",my_id,"ACfind_temp_obj");
  *suc = MSFAIL;
  return OM_W_ABORT;
}

method ACfind_temp_struct(int *suc;char *name;struct ret_struct *ptr_rst;
			   struct GRmd_env *md_env)
{
  printf("%s %s %d %s\n",MSG_STR,"ACcpx",my_id,"ACfind_temp_struct");
  *suc = MSFAIL;
  return OM_W_ABORT;
}

method ACrebuild(int *suc; struct GRmd_env *md_env)
{
  printf("%s %s %d %s\n",MSG_STR,"ACcpx",my_id,"ACrebuild");
  *suc = MSFAIL;
  return OM_W_ABORT;
}

method ACfind_go(int bf_size,*count; struct GRid **gos_GRid)
{
  printf("%s %s %d %s\n",MSG_STR,"ACcpx",my_id,"ACfind_go");
  return OM_W_ABORT;
}

/* -----------------------------------------------------------
 * ACdb_info
 */
method ACset_db_info(
long 		 *msg; 		/* complection code (O) 		*/
struct ACdb_info *db_info;      /* data base information		*/
)
{
  printf("%s %s %d %s\n",MSG_STR,"ACdb_info",my_id,"ACset_db_info");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method ACget_db_info(

long 		 *msg; 		/* complection code (O) 		*/
struct ACdb_info *db_info;      /* data base information		*/
)
{
  printf("%s %s %d %s\n",MSG_STR,"ACdb_info",my_id,"ACget_db_info");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method ACget_db_info_and_def(
long 		 *msg; 		/* complection code (O) 		*/
struct ACdb_info *db_info;      /* data base information		*/
struct GRid *macro_def;		/* my definition			*/
)
{
  printf("%s %s %d %s\n",MSG_STR,"ACdb_info",my_id,"ACget_db_info_and_def");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method ACadd_to_dir()
{
  printf("%s %s %d %s\n",MSG_STR,"ACdb_info",my_id,"ACadd_to_dir");
  return OM_W_ABORT;
}

method ACset_serial_no()
{
  printf("%s %s %d %s\n",MSG_STR,"ACdb_info",my_id,"ACset_serial_no");
  return OM_W_ABORT;
}

method ACput_serial_no(int serial_no)
{
  printf("%s %s %d %s\n",MSG_STR,"ACdb_info",my_id,"ACput_serial_no");
  return OM_W_ABORT;
}

method ACcheckin_candidate (

IGRint CheckinType;		/* I  VDS_NORMAL_CHECKIN or VDS_FAST_CHECKIN */
IGRint *p_CheckinCandidate)	/* O  TRUE or FALSE depending from the fact
				/*    that the object is candidate or not 
				/*    for the checkin */
{
  printf("%s %s %d %s\n",MSG_STR,"ACdb_info",my_id,"ACcheckin_candidate");
  return OM_W_ABORT;
}

method ACadd_to_list (

struct ACobj_info *p_obj_info;	/* I   list of objects in which to add my_id */
IGRint     	  size;    	/* I   size of the list		       	     */
IGRint            *p_count) 	/* I*O number of objects in the list	     */

{
  printf("%s %s %d %s\n",MSG_STR,"ACdb_info",my_id,"ACadd_to_list");
  return OM_W_ABORT;
}

method ACadd_to_list_1 (

struct ACobj_info_1 *p_obj_info_1; /* I list of objects in which to add my_id */
IGRint     	    size;    	   /* I   size of the list       	      */
IGRint              *p_count) 	   /* I*O number of objects in the list	      */
{
  printf("%s %s %d %s\n",MSG_STR,"ACdb_info",my_id,"ACadd_to_list_1");
  return OM_W_ABORT;
}

method ACgive_db_structure(int *suc,*direct_index;char *footname;
                struct ret_struct *ptr_rst;struct GRmd_env *md_env)
{
  printf("%s %s %d %s\n",MSG_STR,"ACdb_info",my_id,"ACgive_db_structure");
  *suc = MSFAIL;
  return OM_W_ABORT;
}

/* -----------------------------------------------------------
 * Root
 */
method debug
(
)
{
  if (traceFlag) printf("%s %s %d %s\n",MSG_STR,"Root",my_id,"debug");

  return om$send(msg = message VDSroot.
                 debug(),
	         mode = OM_e_wrt_message,
	         targetid = my_id);
}

method delete (int f_defer_flag)
{
  if (traceFlag) { 
    printf("%s %s %d,%d %s\n",MSG_STR,"Root",VDcurOS,my_id,"delete");
  }
  return om$send(msg = message VDSroot.
                 delete(f_defer_flag),
	         mode = OM_e_wrt_message,
	         targetid = my_id);
}

method connect 
(
  OM_S_CHANSELECT to_sel;
  int             to_idx;
  OM_S_OBJID      fr_objid;
  OMuword         fr_os;
  OM_S_CHANSELECT fr_sel;
  int             fr_idx
)
{
  if (traceFlag) printf("%s %s %d %s\n",MSG_STR,"Root",my_id,"connect");
  return om$send(msg = message VDSroot.
                 connect(to_sel,to_idx,fr_objid,fr_os,fr_sel,fr_idx),
	         mode = OM_e_wrt_message,
	         targetid = my_id);
}

method disconnect
(
  OM_S_CHANSELECT to_sel;
  OM_S_OBJID      fr_objid;
  OMuword         fr_os;
  OM_S_CHANSELECT fr_sel
)
{
  if (traceFlag) printf("%s %d %s\n",MSG_STR,"Root",my_id,"disconnect");
  return om$send(msg = message VDSroot.
                 disconnect(to_sel,fr_objid,fr_os,fr_sel),
	         mode = OM_e_wrt_message,
	         targetid = my_id);
}

method wild_disconnect
(
  OM_S_CHANSELECT to_sel
)
{
  if (traceFlag) printf("%s %s %d %s\n",MSG_STR,"Root",my_id,"wild_disconnect");
  return om$send(msg = message VDSroot.
                 wild_disconnect(to_sel),
	         mode = OM_e_wrt_message,
	         targetid = my_id);
}

method move_chan
(
  OM_S_CHANSELECT to_sel;
  OM_S_OBJID      fr_objid;
  OMuword         fr_os;
  OM_S_CHANSELECT fr_sel
)
{
  if (traceFlag) printf("%s %d %s\n",MSG_STR,"Root",my_id,"move_chan");
  return om$send(msg = message VDSroot.
                 move_chan(to_sel,fr_objid,fr_os,fr_sel),
	         mode = OM_e_wrt_message,
	         targetid = my_id);
}
method copy_chan
(
  OM_S_CHANSELECT to_sel;
  OM_S_OBJID      fr_objid;
  OMuword         fr_os;
  OM_S_CHANSELECT fr_sel
)
{
  if (traceFlag) printf("%s %s %d %s\n",MSG_STR,"Root",my_id,"copy_chan");
  return om$send(msg = message VDSroot.
                 copy_chan(to_sel,fr_objid,fr_os,fr_sel),
	         mode = OM_e_wrt_message,
	         targetid = my_id);
}
method unknown
(
  OM_S_MESSAGE *msg
)
{
  if (traceFlag) printf("%s %s %d %s\n",MSG_STR,"Root",my_id,"unknown");
  return om$send(msg = message VDSroot.
                 unknown(msg),
	         mode = OM_e_wrt_message,
	         targetid = my_id);
}
method  range_disconnect
(
  OM_S_CHANSELECT to_sel;
  int             low_idx;
  int             hi_idx
)
{
  if (traceFlag) {
    printf("%s %s %d %s\n",MSG_STR,"Root",my_id,"range_disconnect");
  }
  return om$send(msg = message VDSroot.
                 range_disconnect(to_sel,low_idx,hi_idx),
	         mode = OM_e_wrt_message,
	         targetid = my_id);
}
method set_operation
(
  OM_S_CHANSELECT to_sel;
  OM_S_OBJID      op2_objid;
  OMuword         op2_os;
  OM_S_CHANSELECT op2_sel;
  OM_S_OBJID      op3_objid;
  OMuword         op3_os;
  OM_S_CHANSELECT op3_sel;
  char            operation;
  OMuword         preserve
)
{
  if (traceFlag) {
    printf("%s %s %d %s\n",MSG_STR,"Root",my_id,"set_operation");
  }
  return om$send(msg = message VDSroot.
                 set_operation(to_sel,
                               op2_objid,op2_os,op2_sel,
                               op3_objid,op3_os,op3_sel,
                               operation,preserve),
	         mode = OM_e_wrt_message,
	         targetid = my_id);
}
method ARwrite
(
  int *return_code; 
  int  starting
)
{
  if (traceFlag) {
    printf("%s %s %d %s\n",MSG_STR,"Root",my_id,"ARwrite");
  }
  return om$send(msg = message VDSroot.
                 ARwrite(return_code,starting),
	         mode = OM_e_wrt_message,
	         targetid = my_id);
}
method ARread
(
  int  *return_code; 
  char *keyword 
)
{
  if (traceFlag) {
    printf("%s %s %d %s\n",MSG_STR,"Root",my_id,"ARread");
  }
  return om$send(msg = message VDSroot.
                 ARread(return_code,keyword),
	         mode = OM_e_wrt_message,
	         targetid = my_id);
}

/* ---------------------------------------------------
 * IGRdir
 */
method i_find ( DIint  *status; 
                  DIchar *my_name;
                  DIchar **exp_buf;
                  DIint  buf_count;
                  DIint  level;
                  DIint  max_level;
                  DIint  *deep;
                  DIchar ***lines;
                  DIgrid **grids; 
                  DIint  *count;
                  DIchar options )
{
  printf("%s %d %s\n",MSG_STR,my_id,"i_find");
  *status = DIR_E_ABORT;
  return OM_W_ABORT;
}

method init ( DIint *status )
{
  printf("%s %d %s\n",MSG_STR,my_id,"init");
  *status = DIR_E_ABORT;
  return OM_W_ABORT;
}

method ls ( DIint *status; DIchar *reg_exp; DIchar ***lines; 
              DIint *count; DIchar options )
{
  printf("%s %d %s\n",MSG_STR,my_id,"ls");
  *status = DIR_E_ABORT;
  return OM_W_ABORT;
}


method find ( DIint  *status; DIchar *reg_exp; 
              DIchar ***lines; DIgrid **grids;
              DIint *count; DIint  max_level, *deep; 
              DIchar options )
{
  printf("%s %d %s\n",MSG_STR,my_id,"find");
  *status = DIR_E_ABORT;
  return OM_W_ABORT;
}

method add ( DIint  *status; DIchar *name; DIobjid objid; DIint *p_index )
{
  printf("%s %d %s\n",MSG_STR,my_id,"add");
  *status = DIR_E_ABORT;
  return OM_W_ABORT;
}

#if 0 
method remove ( DIint *status; DIchar *name; DIint index )
{
  printf("%s %d %s\n",MSG_STR,my_id,"remove");
  *status = DIR_E_ABORT;
  return OM_W_ABORT;
}
#endif

method translate ( DIint *status; DIchar *name; DIint index; 
                   DIchar *p_name; DIobjid *objid )
{
  printf("%s %d %s\n",MSG_STR,my_id,"translate");
  *status = DIR_E_ABORT;
  return OM_W_ABORT;
}

method unindex ( DIint *status; DIint *index; DIchar *name; DIobjid objid )
{
  printf("%s %d %s\n",MSG_STR,my_id,"unindex");
  *status = DIR_E_ABORT;
  return OM_W_ABORT;
}

method dump ( DIint *status; DIchar *reg_exp; OM_p_CLASSLIST classlist;
              DIchar ***lines; DIgrid **grids; 
              DIint *count; DIchar options )
{
  printf("%s %d %s\n",MSG_STR,my_id,"dump");
  *status = DIR_E_ABORT;
  return OM_W_ABORT;
}

method pass ( DIint *status; OM_S_MESSAGE msg; OM_E_WRT_FLAG flag;
                DIchar *reg_exp; OM_p_CLASSLIST classlist )
{
  printf("%s %d %s\n",MSG_STR,my_id,"pass");
  *status = DIR_E_ABORT;
  return OM_W_ABORT;
}

/* --------------------------------------------------------
 * ACncpx
 */
method ACcontext_compute(IGRlong *msg; IGRint cn_type;
			 int count ; struct GRid *root;
                         struct GRid *context_obj;
                         struct GRmd_env *md_env)
{
  printf("%s %d %s\n",MSG_STR,my_id,"ACcontext_compute");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method ACcontext_compute_feet(IGRint     count;
			      TGRid 	 context_obj;
			      TGRid 	*feet_list;
			      TGRmd_env *mod_env)
{
  printf("%s %d %s\n",MSG_STR,my_id,"ACcontext_compute_feet");
  return OM_W_ABORT;
}

method ACchange_feet(IGRint    count;
		     TGRid     *feet_list;
		     TGRmd_env *mod_env)
{
  printf("%s %d %s\n",MSG_STR,my_id,"ACchange_feet");
  return OM_W_ABORT;
}

method ACconstruct_feet( IGRlong *msg; IGRint cn_type;
			   IGRint count; struct GRid list []; 
                           struct GRmd_env *md_env;
			   int *fcount; struct GRid  *feet_list)
{
  printf("%s %d %s\n",MSG_STR,my_id,"ACconstruct_feet");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method ACmplace(int *suc,prop;  
                char rep;  char *macro_name;
		int        numb_obj;  
                TGRid     *uplist;
                TGRmd_env *mod_env)
{
  printf("%s %d %s\n",MSG_STR,my_id,"ACmplace");
  *suc = MSFAIL;
  return OM_W_ABORT;
}

method ACmplace_from_def(int   *suc,prop;  
                         char   rep; char *macro_name;
		         int    numb_obj;  
                         TGRid *uplist, *def_occ;
		         TGRmd_env      *mod_env)
{
  printf("%s %d %s\n",MSG_STR,my_id,"ACmplace_from_def");
  *suc = MSFAIL;
  return OM_W_ABORT;
}

method ACmroot_place(int       *suc;                 
                     char       rep,*macro_name;
                     int        numb_obj;             
                     TGRid     *ft_objs;
                     TGRmd_env *md_env)
{
  printf("%s %d %s\n",MSG_STR,my_id,"ACmroot_place");
  *suc = MSFAIL;
  return OM_W_ABORT;
}

method  ACindex_in(char *foot_name;OM_S_MESSAGE *mess)
{
  printf("%s %d %s\n",MSG_STR,my_id,"ACindex_in");
  return OM_W_ABORT;
}

method ACset_NV_rep(unsigned char rep;struct GRmd_env *mod_env)
{
  printf("%s %d %s\n",MSG_STR,my_id,"ACset_NV_rep");
  return OM_W_ABORT;
}

method ACput_NV_rep(unsigned char rep)
{
  printf("%s %d %s\n",MSG_STR,my_id,"ACput_NV_rep");
  return OM_W_ABORT;
}

method ACget_NV_rep(unsigned char *rep)
{
  printf("%s %d %s\n",MSG_STR,my_id,"ACget_NV_rep");
  return OM_W_ABORT;
}

method ACput_rep(int rep,rep_mask)
{
  printf("%s %d %s\n",MSG_STR,my_id,"ACput_rep");
  return OM_W_ABORT;
}

method ACget_rep(int *rep)
{
  printf("%s %d %s\n",MSG_STR,my_id,"ACget_rep");
  return OM_W_ABORT;
}

method ACget_STATE(int *rep)
{
  printf("%s %d %s\n",MSG_STR,my_id,"ACget_STATE");
  return OM_W_ABORT;
}

method ACchg_STATE(int mask,new_state)
{
  printf("%s %d %s\n",MSG_STR,my_id,"ACchg_STATE");
  return OM_W_ABORT;
}

method ACchange_node(struct GRmd_env *no_longer_used)
{
  printf("%s %d %s\n",MSG_STR,my_id,"ACchange_node");
  return OM_W_ABORT;
}

method ACinstanciate_template_feet(long *msg;struct GRid *occurence;
				    int nb_to_instanciate;
				    int rtree_flag)
{
  printf("%s %d %s\n",MSG_STR,my_id,"ACinstanciate_template_feet");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method DIgive_output( char *out_s)
{
  printf("%s %d %s\n",MSG_STR,my_id,"DIgive_output");
  return OM_W_ABORT;
}

/* -----------------------------------------------------------------
 * VDSroot Methods
 */
method VDget_trans_table_entries(IGRstat *msg ;
				 TGRid	 *mainRootID ;
				 IGRchar *cmdName )
{
  printf("%s %d %s\n",MSG_STR,my_id,"VDget_trans_table_entries");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method VDget_prefix_name(IGRstat *msg ;
			 IGRchar *directory ;
			 IGRint	 *real_name ;
			 IGRchar *prefix )
{
  printf("%s %d %s\n",MSG_STR,my_id,"VDget_prefix_name");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method VDSgetUsrAttributes(IGRstat     *msg ;
                           IGRint      *nbAttrs;
                           TACrg_coll **att;
                           TGRmd_env   *md_env )
{
  printf("%s %d %s\n",MSG_STR,my_id,"VDSgetUsrAttributes");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method VDSmodUsrAttributes(IGRstat    *msg ;
                           IGRint      nbAttrs;
                           TACrg_coll *att;
                           TGRmd_env  *md_env )
{
  printf("%s %d %s\n",MSG_STR,my_id,"VDSmodUsrAttributes");
  *msg = MSFAIL;
  return OM_W_ABORT;
}


method VDreviewParameters(IGRstat    *msg;
		 	  IGRint      nbParams;
			  TACrg_coll *parList;
			  TGRmd_env  *md_env )
{
  printf("%s %d %s\n",MSG_STR,my_id,"VDreviewParameters");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method VDgetParameters(IGRstat	   *msg;
		       IGRint	   *nbParams;
		       TACrg_coll **parList;
		       TGRmd_env   *md_env )
{
  printf("%s %d %s\n",MSG_STR,my_id,"VDgetParameters");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method VDSgetCompDesc(IGRstat    *msg;
                      TACrg_coll *Param;
                      TGRmd_env  *md_env)
{
  printf("%s %d %s\n",MSG_STR,my_id,"VDSgetCompDesc");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method VDGetModel(IGRstat    *msg;
                  TGRid      *ModelId ;
                  TGRmd_env  *md_env)
{
  printf("%s %d %s\n",MSG_STR,my_id,"VDGetModel");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method VDGetGraphMac(IGRstat *msg;
		     IGRchar *MacName)
{
  printf("%s %d %s\n",MSG_STR,my_id,"VDGetGraphMac");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method VDPostYourselfToDb(IGRstat *msg;
			  IGRchar *key;
			  IGRint   to_sql;
			  IGRchar *catalog;
			  IGRchar *partid;
			  IGRchar *revision;
			  IGRchar *designRep;
			  IGRint  *delete )
{
  printf("%s %d %s\n",MSG_STR,my_id,"VDPostYourselfDb");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method VDgetObjDef(IGRstat  *msg;
                   VDobjDef *objDef)
{
  printf("%s %d %s\n",MSG_STR,my_id,"VDgetObjDef");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method VDcreate(IGRstat    *msg;
		IGRint	    nbAttr;
		TACrg_coll *Attr;
		IGRchar	   *macroName;
		IGRint	    prop;
		IGRint	    nbParents;
		TGRid      *parents )
{
  printf("%s %d %s\n",MSG_STR,my_id,"VDcreate");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method VDprint(IGRstat* msg)
{
  printf("%s %d %s\n",MSG_STR,my_id,"VDprint");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method VDcompute(IGRstat  *msg;
		 IGRint	  *type)
{
  printf("%s %d %s\n",MSG_STR,my_id,"VDcompute");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method VDGetProduct(IGRshort *Pcode;
                    IGRchar  *Pname)
{
  printf("%s %d %s\n",MSG_STR,my_id,"VDGetProduct");
  return OM_W_ABORT;
}

method VDGetCenterLine(IGRstat   *msg;
		       TGRmd_env *md_env;
		       IGRint	 *count;
		       TGRid	**list)
{
  printf("%s %d %s\n",MSG_STR,my_id,"VDGetCenterLine");
  return OM_W_ABORT;
}

method VDgetAttrDrivenSymb(IGRstat      *msg;
                           IGRchar      *fileName;
                           TGRmd_env    *md_env;
                           TGRsymbology *symb)
 
{
  printf("%s %d %s\n",MSG_STR,my_id,"VDgetAttrDrivenSymb");
  return OM_W_ABORT;
}

method VDputAttrDrivenSymb(IGRstat   *msg;
                           TGRmd_env *md_env;
                           IGRchar   *fileName)
{
  printf("%s %d %s\n",MSG_STR,my_id,"VDputAttrDrivenSymb");
  return OM_W_ABORT;
}

method VDdescribeOutput(IGRstat *msg;
		        IGRchar *nameOfOuput;
			IGRchar *description)
{
  printf("%s %d %s\n",MSG_STR,my_id,"VDdescribeOutput");
  return OM_W_ABORT;
}

method VDExecutePpl(IGRstat     *msg;
                    IGRchar     *file_name;
                    IGRchar     *func_name;
		    TGRmd_env   *md_env;
                    IGRint       IN_count;
                    VD_execRes  *IN_args;
		    IGRint	*OUT_count;
		    VD_execRes **OUT_args)

{
  printf("%s %d %s\n",MSG_STR,my_id,"VDExecutePpl");
  return OM_W_ABORT;
}

method VDprocAttr(IGRstat    *msg; 
    	          TGRmd_env  *md_env;
                  IGRint      flag;  
                  VDprcAttr  *prcAttr)

{
  printf("%s %d %s\n",MSG_STR,my_id,"VDprocAttr");
  return OM_W_ABORT;
}

method VDGetParamsId(IGRstat *msg;    
                      TGRid   *SysParamId;
                      TGRid   *UsrParamId;
                      TGRid   *AddParamId)
{
  printf("%s %d %s\n",MSG_STR,my_id,"VDGetParamsId");
  return OM_W_ABORT;
}

end implementation VDct4Base;
