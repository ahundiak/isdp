/* $Id: VDct1Basei.I,v 1.7 2001/07/25 20:52:27 ylong Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/imp/VDct1Basei.I
 *
 * Description: Tree Object
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1Basei.I,v $
 *      Revision 1.7  2001/07/25 20:52:27  ylong
 *      *** empty log message ***
 *
 *      Revision 1.6  2001/06/29 17:20:29  ylong
 *      TR5398
 *
 *      Revision 1.5  2001/06/26 22:03:28  ylong
 *      TR5337
 *
 *      Revision 1.4  2001/06/01 19:50:24  paul_noel
 *      modified to stop back screen print TR5215
 *
 *      Revision 1.3  2001/06/01 16:15:12  paul_noel
 *      fix message for etl8152 TR5192
 *
 *      Revision 1.2  2001/01/11 22:21:09  art
 *      sp merge
 *
# Revision 1.2  2000/08/25  19:59:44  pinnacle
# ah
#
# Revision 1.1  2000/08/14  13:17:08  pinnacle
# ah
#
# Revision 1.3  1999/12/08  19:37:34  pinnacle
# ah
#
# Revision 1.2  1999/06/30  16:10:28  pinnacle
# ct
#
# Revision 1.1  1999/06/29  18:28:08  pinnacle
# ct
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/28/99  ah      Creation
 ***************************************************************************/

class implementation VDct1Base;

#include "VDtypedef.h"
#include "VDct1.h"
#include "VDppl1.h"
#include "VDobj.h"
#include "v_dbgmacros.h"
#include "v_miscmacros.h"

#define MSG_STR "VDct1Base "

from VDct1Defn import VDctDefnSetName;
from VDct1Defn import VDctDefnSetOccID;

/* -------------------------------------------
 * Some tracing capability
 */
static int traceFlag;

IGRstat VDct1BaseiSetTraceFlag(IGRint flag)
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

/* --------------------------------------------------
 * Standard way to get one attribute at a time
 * 
 * Need to add virtual attributes here like node_name
 *
 * Also need to deal with doubles properly
 */
method ACgive_structure
(
  int               *suc;
  int               *direct_index;
  char              *footName;
  struct ret_struct *rs;
  struct GRmd_env   *md_env;
)
{
  IGRstat  retFlag = 0;
  TVDfld   fld;
  TVDctBaseInfo baseInfo;
  
  TGRid    objID;
  TGRid    pplID;
  IGRint   pplRet;

  IGRchar *p;

  TGRobj_env		modelOE;
  IGRchar		*modName = NULL ;
  
  SetProc( VDct1Base_ACgive_structure ); Begin 

  // Arg Check
  if (rs == NULL)       goto wrapup;
  if (footName == NULL) goto wrapup;

  objID.objid = my_id;
  objID.osnum = OM_Gw_current_OS;

  if (traceFlag) {
    printf("%s %s %d %s %s\n",MSG_STR,"NDmacro",my_id,"ACgive_structure",footName);
  }
  
  // Init
  memset(rs,0,sizeof(Tret_struct));
   
  // If foot name is sarted with SA_MOD, get the value from model
  if( !strncmp(footName,"SA_MOD:", 7) ) {
    	modName = footName + 7;
	goto model_check;
  }

  // Get the attribute
  vdcol$GetAttr(objID = &objID, name = footName, fld = &fld);
  if (*fld.name != 0) {

    vdrs$ToRS(fld = &fld, rs = rs);
    retFlag = 1;
    goto wrapup;
  }

  // Get the base infor for special processing
  vdct1$GetBaseInfo(objID = &objID, baseInfo = &baseInfo);
  if (*baseInfo.setType == 0) goto not_found;
  
  // Might be a special case
  if (!strcmp(footName,VDCT_BASE_NAME_NAME)) {
    rs->type = text_type;
    strcpy(rs->var.text_st.text_string,baseInfo.baseName);
    retFlag = 1;
    goto wrapup;
  }
  if (!strcmp(footName,VDCT_NODE_NAME_NAME)) {
    rs->type = text_type;
    strcpy(rs->var.text_st.text_string,baseInfo.nodeName);
    retFlag = 1;
    goto wrapup;
  }
  if (!strcmp(footName,VDCT_NODE_TYPE_NAME)) {
    rs->type = text_type;
    strcpy(rs->var.text_st.text_string,baseInfo.nodeType);
    retFlag = 1;
    goto wrapup;
  }
  if (!strcmp(footName,VDCT_SET_NAME_NAME)) {
    rs->type = text_type;
    strcpy(rs->var.text_st.text_string,baseInfo.setName);
    retFlag = 1;
    goto wrapup;
  }
  if (!strcmp(footName,VDCT_SET_TYPE_NAME)) {
    rs->type = text_type;
    strcpy(rs->var.text_st.text_string,baseInfo.setType);
    retFlag = 1;
    goto wrapup;
  }
  if (!strcmp(footName,VDCT_SET_TYPE_REV_NAME)) {
    rs->type = text_type;
    strcpy(rs->var.text_st.text_string,baseInfo.setTypeRev);
    retFlag = 1;
    goto wrapup;
  }

  // Process the version a bit
  if (!strcmp(footName,VDCT_NODE_VERSION)) {

    // Get the attribute
    vdcol$GetAttr(objID = &objID, name = VDCT_NODE_VERSION, fld = &fld);
    if (*fld.name != 0) {

      p = strchr(fld.val.txt,' ');
      if (p) *p = 0;
      
      vdrs$ToRS(fld = &fld, rs = rs);
      retFlag = 1;
      goto wrapup;
      
    }
    
  }
  
  // Let the ppl take a whack at it
  vdppl$Load(name = baseInfo.setType, pplID = &pplID);
  if (pplID.objid == NULL_OBJID) goto not_found;

  vdppl$SetData(pplID = &pplID,
                name  = "NODE_ID",
                size  = sizeof(TGRid),
                data  = (IGRchar*)&objID);

  vdppl$SetData(pplID = &pplID,
                name  = "BASE_INFO",
                size  = sizeof(TVDctBaseInfo),
                data  = (IGRchar*)&baseInfo);

  // Use FLD for data transfer
  fld.type = VDFLD_TYPE_NONE;
  strcpy(fld.name,footName);
  vdppl$SetData(pplID = &pplID,
                name  = "FLD",
                size  = sizeof(TVDfld),
                data  = (IGRchar*)&fld);
  
  vdppl$Run(pplID = &pplID, name = "getAttributeValue", ret = &pplRet);

  vdppl$GetData(pplID = &pplID,
                name  = "FLD",
                size  = sizeof(TVDfld),
                data  = (IGRchar*)&fld);
  
  // See if found
  if (fld.type != VDFLD_TYPE_NONE) {
    vdrs$ToRS(fld = &fld, rs = rs);
    retFlag = 1;
    goto wrapup;
  }
  
  // Pass off to vdsroot mainly to handle smart attributes
not_found:
  retFlag =  om$send (	msg	 = message VDSroot.ACgive_structure
					(suc,direct_index,footName,rs,md_env),
			mode     = OM_e_wrt_message,
			targetid = my_id);

  if( !(retFlag & *suc & 1 )){

model_check:

    if( ! modName )	modName = footName ;

    modelOE.obj_id.objid = NULL_OBJID;

    vdct1$GetNodeModelObject (  nodeID  = &objID,
                                modelOE = &modelOE);

    if( modelOE.obj_id.objid != NULL_OBJID )
    {
      retFlag = 0;

      if(vd_$is_ancestry_valid( object  = &modelOE.obj_id,
                                classid = OPP_ACdb_info_class_id ) )
      {
        retFlag = om$send (     msg     = message ACdb_info.ACgive_db_structure
                                                (suc,
                                                direct_index,
                                                modName,
                                                rs,
                                                &modelOE.mod_env),
                                senderid = NULL_OBJID,
                                targetid = modelOE.obj_id.objid,
                                targetos = modelOE.obj_id.osnum);
      }

      if(!(retFlag&*suc&1))
      {
        retFlag =  om$send (    msg      = message VDSroot.ACgive_structure
                                                (suc,
                                                direct_index,
                                                modName,
                                                rs,
                                                &modelOE.mod_env),
                                senderid = NULL_OBJID,
                                targetid = modelOE.obj_id.objid,
                                targetos = modelOE.obj_id.osnum);
      }
    }
  }

wrapup:

  End
  if (retFlag) {  
    if (suc) *suc = MSSUCC;
    return OM_S_SUCCESS;
  }

  if (suc) *suc = MSFAIL;
  return OM_W_ABORT;
}

/* --------------------------------------------------
 * First came up in the bom code
 * when creating a table
 */
method ACreturn_foot
(
  IGRlong     *msg;
  char        *footname;
  struct GRid *foot_obj;
  IGRshort    *mat_type;
  IGRdouble   *matrix;
)
{
  if (traceFlag) {
    printf("%s %s %d %s '%s'\n",MSG_STR,"NDmacro",my_id,"ACreturn_foot",footname);
  }
  
  return om$send(msg = message VDSroot.
                 ACreturn_foot(msg,footname,foot_obj,mat_type,matrix),
	         mode     = OM_e_wrt_message,
	         targetid = my_id);
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
  /* commented print out upon TR5398
  printf("%s %s %d %s\n",MSG_STR,"NDmacro",my_id,"ACtest_consumed");
  */
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

/* -----------------------------------------------
 * Don't think need to do anything when becoming a foot
 */
method ACbecome_foot
(
  long *msg;
  struct GRid *new_id;
  struct GRmd_env *md_env;
)
{
#if 0
  printf("%s %s %d %s\n",MSG_STR,"NDmacro",my_id,"ACbecome_foot");
  *msg = MSFAIL;
  return OM_W_ABORT;
#endif
  *msg = MSSUCC;
  return OM_S_SUCCESS;
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
 * Used when connecting as a foot
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
  if (traceFlag) {  
    printf("%s %s %d %s\n",MSG_STR,"NDnode",my_id,"NDget_objects");
  }
  
  return om$send(msg = message VDSroot.
                 NDget_objects(type,list,size,buffer,ifrom,ito,count),
	         mode     = OM_e_wrt_message,
	         targetid = my_id);
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

/* -----------------------------------------------
 * Called when becoming a foot, not sure why yet
 *
 * Might want to ignore here but with no parents should be harmless
 */
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
  if (traceFlag | count) {
    printf("%s %s %d %s %d %d\n",MSG_STR,"NDnode",my_id,"NDupdate",cn_type,count);
  }
  
  // If no parents then ignore
  if (count <= 0) {
    
    *msg = MSSUCC;
    return OM_S_SUCCESS;
  }
  *msg = MSFAIL;
  return OM_W_ABORT;

#if 0
  return om$send(msg = message VDSroot.
                 NDupdate(msg,cn_type,count,parents,parent_state,context,new_objid,md_env),
	         mode     = OM_e_wrt_message,
	         targetid = my_id);
#endif
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

/* -----------------------------------------------
 * Type 66 macro
 */
method NDdelete
(
  struct GRmd_env *md_env;
)
{
  if (traceFlag) {    
    printf("%s %s %d %s\n",MSG_STR,"NDnode",my_id,"NDdelete");
  }
  return om$send(msg = message VDSroot.
                 NDdelete(md_env),
	         mode     = OM_e_wrt_message,
	         targetid = my_id);
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

/* --------------------------------------------------------------
 * Part of the child connection process
 */
method NDget_state
(
  IGRchar *n_state;
)
{
  if (traceFlag) {    
    printf("%s %s %d %s\n",MSG_STR,"NDnode",my_id,"NDget_state");
  }
  return om$send(msg = message VDSroot.
                 NDget_state(n_state),
	         mode     = OM_e_wrt_message,
	         targetid = my_id);
}

method NDchg_state
(
  IGRchar mask;
  IGRchar n_state;
)
{
  if (traceFlag) {
    printf("%s %s %d %s\n",MSG_STR,"NDnode",my_id,"NDchg_state");
  }
  return om$send(msg = message VDSroot.
                 NDchg_state(mask,n_state),
	         mode     = OM_e_wrt_message,
	         targetid = my_id);
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

/* -----------------------------------------------------------
 * Part of the disconnect process
 */
method NDchildren_deleted
(
  IGRlong   *msg;
  IGRint     count_deleted;
  TGRid      list_deleted [];
  TGRid     *new_obj;
  TGRmd_env *md_env;
)
{
  if (traceFlag) {
    printf("%s %s %d %s\n",MSG_STR,"NDnode",my_id,"NDchildren_deleted");
  }
  
  return om$send(msg = message VDSroot.
                 NDchildren_deleted(msg,count_deleted,list_deleted,new_obj,md_env),
	         mode     = OM_e_wrt_message,
	         targetid = my_id);
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

/* --------------------------------------------------
 * When a child is attached
 */
method NDnotify_connect
(
  TGRid new_connected;
)
{
  if (traceFlag) {
    printf("%s %s %d %s\n",MSG_STR,"NDnode",my_id,"NDnotify_connect");
  }
  return om$send(msg = message VDSroot.
                 NDnotify_connect(new_connected),
	         mode     = OM_e_wrt_message,
	         targetid = my_id);
}

/* ---------------------------------------------------
 * When child is being detached
 */
method NDnotify_disconnect
(
  TGRid previous_connected;
)
{
  if (traceFlag) {
    printf("%s %s %d %s\n",MSG_STR,"NDnode",my_id,"NDnotify_disconnect");
  }
  return om$send(msg = message VDSroot.
                 NDnotify_disconnect(previous_connected),
	         mode     = OM_e_wrt_message,
	         targetid = my_id);
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

/* -------------------------------------------------
 * Part of becoming the parent of an isdp object
 * Called after GRmksource
 */
method NDmake_source
(
  IGRlong     *msg;
  struct GRid *located_obj;
  struct GRid *context;
  char        *path;
  GRspacenum   as_osnum;
  struct GRid *as;
)
{
  if (traceFlag) {  
    printf("%s %s %d %s\n",MSG_STR,"NDnode",my_id,"NDmake_source");
  }
  return om$send(msg = message VDSroot.
                 NDmake_source(msg,
			       located_obj,
			       context,
			       path,
			       as_osnum,
			       as),
	         mode     = OM_e_wrt_message,
	         targetid = my_id);
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
  if (traceFlag) {
    printf("%s %s %d %s\n",MSG_STR,"NDnode",my_id,"NDsleep");
  }
  
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
  if(traceFlag) printf("%s %s %d %s\n",MSG_STR,"ASnode",my_id,"ACconnect_pretend");
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
  if(traceFlag) printf("%s %s %d %s\n",MSG_STR,"ASnode",my_id,"ACconnect_pretendin");
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
  om$construct(classid =  OPP_VDct1Defn_class_id,
	       osnum   =  me->mac_def.osnum,
	       p_objid = &me->mac_def.objid);
  if (me->mac_def.objid == NULL_OBJID) goto wrapup;

  // Set the data
  om$send(msg = message VDct1Defn.VDctDefnSetName(macro_name),
          targetid = me->mac_def.objid,
          targetos = me->mac_def.osnum);

  occID.osnum = VDcurOS;
  occID.objid = my_id;
  om$send(msg = message VDct1Defn.VDctDefnSetOccID(&occID),
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

/* -------------------------------------------------------------
 * This can get called if ACgive_structure does not return an
 * attribute of the given name
 *
 * Just pass it along for now
 */
method ACfind_temp_obj   (int *suc;char *name;    struct GRid *temp_obj)
{
  if (traceFlag) {
    printf("%s %s %d %s %s\n",MSG_STR,"ACcpx",my_id,"ACfind_temp_obj",name);
  }
  return om$send(msg = message VDSroot.
		 ACfind_temp_obj(suc,name,temp_obj),
	         mode     = OM_e_wrt_message,
		 targetid = my_id);
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
  // printf("%s %s %d %s\n",MSG_STR,"ACdb_info",my_id,"ACcheckin_candidate");
  *p_CheckinCandidate = FALSE;
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

/* ----------------------------------------------------------------
 * Used when posting to the database
 * Just pass to the regular routine
 */
method ACgive_db_structure(int *suc,*direct_index;char *footname;
                struct ret_struct *ptr_rst;struct GRmd_env *md_env)
{
  if (traceFlag) {    
    printf("%s %s %d %s\n",MSG_STR,"ACdb_info",my_id,"ACgive_db_structure");
  }
  return om$send(msg = message VDct1Base.
		 ACgive_structure(suc,direct_index,footname,ptr_rst,md_env),
		 targetid = my_id);
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
 *
 * 11 Aug 2000 Called when the Tree Nanager Object Directory
 * is cd'ed to
 *
 * This is where we could get tricky and actually display stuff
 * in the directory commands forms
 */
method i_find (DIint    *status; 
	       DIchar   *my_name;
	       DIchar  **exp_buf;
	       DIint     buf_count;
	       DIint     level;
	       DIint     max_level;
	       DIint    *deep;
	       DIchar ***lines;
	       DIgrid  **grids; 
	       DIint    *count;
	       DIchar    options )
{
  if (traceFlag) {  
    printf("%s %d %s %d\n",MSG_STR,my_id,"i_find",traceFlag);
  }

  return om$send(msg = message VDSroot.
                 i_find(status,my_name,
			exp_buf,buf_count,level,max_level,
			deep,lines,grids,count,options),
	         mode = OM_e_wrt_message,
	         targetid = my_id);
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

/* -----------------------------------------------
 * 11 August 2000 - Called as part of i_find when
 * Displaying the contents of the TreeManager
 * Directory
 */
method dump ( DIint *status; DIchar *reg_exp; OM_p_CLASSLIST classlist;
              DIchar ***lines; DIgrid **grids; 
              DIint *count; DIchar options )
{
  if (traceFlag) {  
    printf("%s %d %s\n",MSG_STR,my_id,"dump");
  }
  return om$send(msg = message VDSroot.
                 dump(status,reg_exp,classlist,lines,grids,count,options),
	         mode = OM_e_wrt_message,
	         targetid = my_id);
  
  //*status = DIR_E_ABORT;
  //return OM_W_ABORT;
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

/* -----------------------------------------------
 * 11 Aug 2000 Called when the IGENOD directory
 * Is first displayed
 *
 * Just a note, maybe sould override IGRdir.remove in
 * next pload, look in ACncpx overrides
 */
method DIgive_output( char *out_s)
{
  if (traceFlag) {  
    printf("%s %d %s\n",MSG_STR,my_id,"DIgive_output");
  }

  // This actually shows up on the directory commands form
  sprintf(out_s,"TreeManager_%d",my_id);
  return OM_S_SUCCESS;

#if 0
  return om$send(msg = message VDSroot.
                 DIgive_output(out_s),
	         mode = OM_e_wrt_message,
	         targetid = my_id);
#endif
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

/* --------------------------------------------------------
 * Actually ends up in vd$review_parameters
 */
method VDreviewParameters(IGRstat    *msg;
		 	  IGRint      nbParams;
			  TACrg_coll *parList;
			  TGRmd_env  *md_env )
{
  if (traceFlag) {  
    printf("%s %d %s\n",MSG_STR,my_id,"VDreviewParameters");
  }
  return om$send(msg = message VDSroot.
                 VDreviewParameters(msg,nbParams,parList,md_env),
	         mode = OM_e_wrt_message,
	         targetid = my_id);
  
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

/* -----------------------------------------------
 * 11 Aug 2000 - Called as part of DIgive_output
 * when IGEnode directory is overridden
 *
 * Might want to actually implement something here
 */
method VDgetObjDef(IGRstat  *msg;
                   VDobjDef *objDef)
{
  if (traceFlag) {  
    printf("%s %d %s\n",MSG_STR,my_id,"VDgetObjDef");
  }
  return om$send(msg = message VDSroot.
                 VDgetObjDef(msg,objDef),
	         mode = OM_e_wrt_message,
	         targetid = my_id);

  // It's an integer based system, track down later
  // strcpy(objDef,"Tree");
  
  //*msg = MSFAIL;
  //return OM_W_ABORT;
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
  if (traceFlag) 
  {
    printf("%s %d %s\n",MSG_STR,my_id,"VDGetProduct");
  }
  return om$send(msg = message VDSroot.
                 VDGetProduct(Pcode,Pname),
	         mode     = OM_e_wrt_message,
	         targetid = my_id);
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

end implementation VDct1Base;
