/* $Id: VDatBase.S,v 1.1.1.1 2001/01/04 21:07:42 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/imp/VDatBase
 *
 * Description: Base Assembly Tree Class
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatBase.S,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:42  cvs
 *      Initial import to CVS
 *
# Revision 1.2  1998/10/11  13:53:52  pinnacle
# ah
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.11  1998/03/22  19:14:48  pinnacle
# AssyTree
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/25/97  ah      Creation
 * 12/14/97  ah      Added dbls,longs and chars
 * 02/22/98  ah      Added NDdelete  
 ***************************************************************************/

/* -----------------------------------------------------------
 * Listener is clever, it does not actually create the channel
 * itself, you have to do it.
 * Copied from ASsource
 */
class specification VDatBase (1:0) of GRlistener,GRnotify,NDnodein;

#include "VDatMaster.h"

instance VDatBase
{
  // Try this, rel_ordered should be better
  channel {(many_to_many,
            rel_ordered,
            initial   = 1,
            increment = 1)} to_notify;    

  /* channel to connect to notify channel of graphic objects  */
  //channel { (many_to_many, initial=1, increment=1) } listeners;
 
  IGRlong  type;
  IGRlong  flag;
  IGRchar  name[40];
  IGRchar  misc[40];
  
  variable TVDatFld   flds[0];
  variable IGRdouble  dbls[0];
  variable IGRlong   longs[0];
  variable IGRchar   chars[0];
};

message getType(IGRlong *info);
message setType(IGRlong  info);

message getFlag(IGRlong *flag);
message setFlag(IGRlong  flag);

message getName(IGRchar *name);
message setName(IGRchar *name);
message getMisc(IGRchar *misc);
message setMisc(IGRchar *misc);

message getAttrByName (IGRchar *name; TVDatFld *fld);
message getAttrByIndex(IGRlong index; TVDatFld *fld);

message getAttrs(TVDatFld *flds; IGRlong *cnt);
message setAttrs(TVDatFld *flds; IGRlong  cnt);
message updAttrs(TVDatFld *flds; IGRlong  cnt);
message delAttrs(TVDatFld *flds; IGRlong  cnt);

message getDbls (IGRdouble *dbls;  IGRlong *cnt);
message setDbls (IGRdouble *dbls;  IGRlong  cnt);
message getLongs(IGRlong   *longs; IGRlong *cnt);
message setLongs(IGRlong   *longs; IGRlong  cnt);
message getChars(IGRchar   *chars; IGRlong *cnt);
message setChars(IGRchar   *chars; IGRlong  cnt);

/* --------------------------------------------------
 * While not actually used by the assembly tree stuff
 * overide a couple of regular messages to allow
 * other code easier access
 */
override ASreturn_go;
override ACgive_structure;

override NDdelete;
override NDdisconnect;
override NDcompute_node;

override GRnotifylis;

/* From NDnodein */
#if 0
override 
  NDget_objects,  
  NDconnect,
  NDdisconnect,
  NDchange_connect,
  NDmove_to_tmp_clone,
  NDget_state,    
  NDchg_state,
  ACin_macro_def,
  ACcompute_node, 
  ACreturn_foot,  
  ACcopy_to_Groot,
  ACconsume,          
  ACunconsume;        
#endif

/* From NDmacro */
#if 0
message ACin_macro_def
(
  IGRint *in_def;
);


message ACbecome_macro
(
  IGRlong *msg;
  IGRint position;
  struct GRmd_env *md_env;
);

message ACgive_structure
(
  int *suc;
  int *direct_index;
  char *footname;
  struct ret_struct *ptr_rst;
  struct GRmd_env *md_env;
);

message ACreturn_foot
(
  IGRlong *msg;
  char *footname;
  struct GRid *foot_obj;
  IGRshort *mat_type;
  IGRdouble *matrix;
);

message ACgive_foot
(
  int *suc;
  char *footname;
  struct GRid *foot_obj;
);

message ACtest_foot
(
  long *suc;
  char *footname;
);

message ACcopy_to_Groot
(
  IGRlong *msg;
  IGRint cp_type;
  struct GRmd_env *md_env;
  struct GRmd_env *new_info;
  struct GRid *newobjid;
);

message ACconsume
(
  IGRlong *msg;
  char *footname;
  int cpy_req;
  struct GRid *cpy_GRid;
  struct GRmd_env *md_env;
);

message ACunconsume
(
  IGRlong *msg;
  char *footname;
);

message ACntf_consume
(
  IGRlong *msg;
);

message ACntf_unconsume
(
  IGRlong *msg;
);

message ACtest_consumed
(
  IGRlong *msg;
);

message ACbubble_up
(
  long *msg;
  char *footname;
  int up_index;
  OM_p_MESSAGE Condition;
  OM_p_MESSAGE Action;
  enum OM_e_wrt_flag delAction;
);

message ACpass_up
(
  long *msg;
  int count;
  struct GRid list [];
  int up_index;
  OM_p_MESSAGE Condition;
  OM_p_MESSAGE Action;
  enum OM_e_wrt_flag delAction;
);

message ACbecome_foot
(
  long *msg;
  struct GRid *new_id;
  struct GRmd_env *md_env;
);

message ACmap_from_visible
(
  OM_S_OBJID **list;
  int *cur_obj_buf;
  int *count;
  int *sz_inst_save;
  int *cur_inst_buf;
  char **inst_save;
);

message ACcompute_node
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
);
#endif

#if 0
message NDget_objects
(
  int type;
  struct GRid *list;
  int size;
  struct GRid **buffer;
  int ifrom;
  int ito;
  int *count;
);

message NDget_virtual_objects
(
  int type;
  struct GRid *list;
  int size;
  struct GRid **buffer;
  int ifrom;
  int ito;
  int *count;
  int *virt_count;
);

message NDconnect_graph
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
);

message NDconnect
(
  int nb_root;
  struct GRid *root;
  struct GRid original;
  IGRint type;
);

message NDdisconnect
(
  int nb_root;
  struct GRid *root;
);

message NDchange_connect
(
  int nb_change;
  struct GRid *old;
  struct GRid *new;
);

message NDupdate
(
  int *msg;
  int cn_type;
  int count;
  struct GRid *parents;
  int * parent_state;
  struct GRid *context;
  struct GRid *new_objid;
  struct GRmd_env *md_env;
);

message NDcompute_node
(
  IGRlong *msg;
  IGRint cn_type;
  IGRint count;
  struct GRid list [];
  struct GRmd_env *md_env;
);

message NDs_compute_node
(
  IGRlong *msg;
  IGRint cn_type;
  struct GRmd_env *md_env;
);

message NDchange_node
(
  struct GRmd_env *obsolete_argument;
);

message NDgive_structure
(
  IGRlong *msg;
  struct ret_struct *str;
  struct GRmd_env *md_env;
);

message NDprint
(
  struct GRmd_env *md_env;
  FILE *stream;
);

message NDprint_root
(
  struct GRmd_env *md_env;
  FILE *stream;
);

message NDdelete
(
  struct GRmd_env *md_env;
);

message NDplace
(
  struct GRas *assoc_list;
  struct GRmd_env *md_env;
  char *go_cnst_lis;
);

message NDget_state
(
  IGRchar *n_state;
);

message NDchg_state
(
  IGRchar mask;
  IGRchar n_state;
);
  
message NDparent_deleted
(
  IGRlong *msg;
  IGRint count_deleted;
  struct GRid list_deleted [];
  struct GRid *new_obj;
  struct GRmd_env *md_env;
);

message NDrm_assoc
(
  long *msg;
  struct GRid *new_object;
  struct GRmd_env *md_env;
);

message NDmove_to_root
(
  IGRlong *msg;
  struct GRid *src_grid;
  struct GRmd_env *md_env;
);

message NDchildren_deleted
(
  IGRlong *msg;
  IGRint count_deleted;
  struct GRid list_deleted [];
  struct GRid *new_obj;
  struct GRmd_env *md_env;
);

message NDdisplay
(
  IGRint obsolet;
  enum GRdpmode mode;
  struct GRmd_env *md_env;
);

message NDselect_copy
(
  long *msg;
  int select_type;
  struct GRid *selected_obj;
  int *info;
  int selected_size;
  int *selected_nb;
);

message NDcopy_graph
(
  IGRlong *msg;
  IGRint cp_type;
  struct GRmd_env *fr_env;
  struct GRmd_env *to_env;
  struct NDcp_list *copied_element;
  int copied_size;
  int my_index;
);
 
message NDcopy
(
  IGRlong *msg;
  IGRint cp_type;
  struct GRmd_env *fr_env;
  struct GRmd_env *to_env;
  struct GRid *newobjid;
);

message NDnotify_connect
(
  struct GRid new_connected;
);

message NDnotify_disconnect
(
  struct GRid previous_connected;
);

message NDpossible_parent
(
  IGRint ifrom;
  IGRint ito;
  IGRint *geom_code;
  IGRint *option_code;
  IGRint *nb_tot;
);
		 
message NDcopy_to_tmp_root
(
  long *msg;
  int cp_type;
  struct GRmd_env *md_env;
  struct GRmd_env *new_info;
  struct GRid *newobjid;
);

message NDmove_to_tmp_clone
(
  long *msg;
  struct GRid *clone;
);

message NDcopy_to_root
(
  IGRlong *msg;
  IGRint cp_type;
  struct GRmd_env *md_env;
  struct GRmd_env *new_info;
  struct GRid *newobjid;
);

message NDmake_source
(
  IGRlong *msg;
  struct GRid *located_obj;
  struct GRid *context;
  char *path;
  GRspacenum as_osnum;
  struct GRid *as;
);
  
message ASreturn_go
(
  struct GRid *go;
  IGRshort *mat_type;
  IGRdouble *matrix;
);

message NDsleep
(
  struct GRmd_env *md_env;
);

message NDattach_to_cs
(
  IGRlong *msg;
  struct GRid cs_grid;
  struct GRid contents_grid;
  struct GRid *as_grid;
  struct GRmd_env *md_env;
);

message NDdetach_from_cs
(
  IGRlong *msg;
  struct GRid cs_grid;
  struct GRid contents_grid;
  struct GRid *as_grid;
  struct GRmd_env *md_env;
);

message NDattach_to_track_pt
(
  IGRlong *msg;
  struct GRid pt_grid;
  struct GRid *as_grid;
  struct GRmd_env *md_env;
);

message NDdetach_from_track_pt
(
  IGRlong *msg;
  struct GRid pt_grid;
  struct GRid *as_grid;
  struct GRmd_env *md_env;
);

message NDget_parent_type
(
  long *msg;
  int *type;
  char *info;
);

message NDctl_parent_type
(
  long *msg;
  int type;
  char *info;
);

message NDdrawing_copy_geom
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
);

message NDdrawing_copy_attr
(
  struct myfeet *attr_name;
  int nb_attr;
  struct GRid *drawing_attr;
  struct GRmd_env *from_env;
  struct GRmd_env *to_env;
);

message NDparent_rf_detached
(
  IGRlong *msg;
  struct GRid *parent_grid;
  struct GRmd_env *md_env;
  struct GRid *new_obj;
);
#endif

end specification VDatBase;







