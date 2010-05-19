/* $Id: VDct1Basej.I,v 1.2 2001/01/11 22:21:09 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/imp/VDct1Basej.I
 *
 * Description: Tree Object
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1Basej.I,v $
 *      Revision 1.2  2001/01/11 22:21:09  art
 *      sp merge
 *
# Revision 1.1  2000/08/14  13:17:08  pinnacle
# ah
#
# Revision 1.2  1999/12/08  19:37:34  pinnacle
# ah
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
#include "VDobj.h"
#include "VDchn.h"

#define MSG_STR "VDct1Base "

/* -------------------------------------------
 * Some tracing capability
 */
static int traceFlag;

IGRstat VDct1BasejSetTraceFlag(IGRint flag)
{
  traceFlag = flag;
  return 1;
}

extern IGRboolean ASbroadcast_in_progress;

/* -------------------------------------------
 * GRgraphics
 */
method GRgetprops
(
  IGRlong *msg;
  IGRshort *props;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRgraphics",my_id,"GRgetprops");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRgethprops
(
  IGRlong *msg;
  IGRuint *props;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRgraphics",my_id,"GRgethprops");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRgetrang
(
  IGRlong *msg;
  IGRshort *matrix_type;
  IGRmatrix matrix;
  IGRboolean *world;
  GRrange range;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRgraphics",my_id,"GRgetrang");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRlevelcount
(
  IGRlong *msg;
  IGRint *byte_count;
  IGRint *object_count;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRgraphics",my_id,"GRlevelcount");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRchgprops
(
  IGRlong *msg;
  IGRshort *action;
  IGRshort *props;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRgraphics",my_id,"GRchgprops");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRgetname
(
  IGRlong *msg;
  IGRchar *name;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRgraphics",my_id,"GRgetname");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRprismrel
(
  IGRlong *msg;
  IGRshort *mx_type;
  IGRmatrix matrix;
  IGRlong *prism_rel;
  IGRshort *type_prism;
  IGRchar *prism;
  IGRlong *relationship;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRgraphics",my_id,"GRprismrel");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRlocate
(
  struct GRlc_cvl *cvl;
  OM_p_KEY_DESC range_key;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRgraphics",my_id,"GRlocate");
  return OM_W_ABORT;
}

method GRlocate_processing
(
  IGRlong          *msg;
  struct GRlc_cvl  *cvl;
  struct GRlc_path *path;
  IGRint           *path_position;
  IGRint           *owner_eligible;
  IGRint           *component_eligible;
)
{
  if (traceFlag) {    
    printf("%s %s %d %s\n",MSG_STR,"GRgraphics",my_id,"GRlocate_processing");
  }
  
  return om$send(msg = message VDSroot.
                 GRlocate_processing(msg,cvl,path,
				     path_position,
				     owner_eligible,
				     component_eligible),
	         mode = OM_e_wrt_message,
	         targetid = my_id);
}

/* -----------------------------------------------
 * 11 Aug 2000 - Used to name the manager object 
 * because nodes are really directories
 */
method GRputname
(
  IGRlong *msg;
  IGRchar *name;
)
{
  if (traceFlag) {  
    printf("%s %s %d %s %s\n",MSG_STR,"GRgraphics",my_id,"GRputname",name);
  }
  return om$send(msg = message VDSroot.
                 GRputname(msg,name),
	         mode = OM_e_wrt_message,
	         targetid = my_id);
}

method GRchgname
(
  IGRlong *msg;
  struct GRmd_env *env;
  IGRchar *name;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRgraphics",my_id,"GRchgname");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRlocaldp
(
  IGRlong *msg;
  IGRshort *type;
  IGRmatrix matrix;
  struct GRparms *parms;
  enum GRdpmode *mode;
  struct GRid *display_info;
  IGRshort *display_location;
  IGRshort *display_flag;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRgraphics",my_id,"GRlocaldp");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRgetobjinfo
(
  IGRlong *msg;
  struct GRobj_info *info;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRgraphics",my_id,"GRgetobjinfo");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRapprojpt
(
  IGRlong *msg;
  IGRshort *matrix_type;
  IGRmatrix matrix;
  struct GRparms *locate_parms;
  struct IGRline *boreline;
  IGRpoint proj_pt;
  struct GRparms *proj_parms;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRgraphics",my_id,"GRapprojpt");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRptproject
(
  IGRlong *msg;
  IGRshort *matrix_type;
  IGRmatrix matrix;
  IGRpoint point;
  IGRpoint proj_pt;
  struct GRparms *proj_parms;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRgraphics",my_id,"GRptproject");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRlnproject
(
  IGRlong *msg;
  IGRshort *matrix_type;
  IGRmatrix matrix;
  struct IGRline *line;
  IGRpoint ln_pt;
  IGRpoint proj_pt;
  IGRdouble *t;
  struct GRparms *proj_parms;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRgraphics",my_id,"GRlnproject");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

/* ------------------------------------------------------------
 * Originally had this off when doing the locate filter
 *
 * Need to turn it on for graphic owners
 */
method GRdisyourself
(
  IGRlong               *msg;
  IGRshort              *mx_type;
  IGRmatrix              matrix;
  enum   GRdpmode       *mode;
  struct IGRaltdisplay  *alt_symb;
  struct DP_information *sp_info;
  OM_p_KEY_DESC          range_key;
)
{
  if (traceFlag) { 
    printf("%s %s %d %s\n",MSG_STR,"GRgraphics",my_id,"GRdisyourself");
  }
#if 1
  return om$send(msg = message VDSroot.
                 GRdisyourself(msg,
			       mx_type,
			       matrix,
			       mode,
			       alt_symb,
			       sp_info,
			       range_key),
	         mode = OM_e_wrt_message,
	         targetid = my_id);
#endif
#if 0
  *msg = MSSUCC;
  return OM_S_SUCCESS;
#endif

}

method GRcopy
(
  IGRlong *msg;
  struct GRmd_env *obj_dsenv;
  struct GRmd_env *new_dsenv;
  GRobjid *newobjid;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRgraphics",my_id,"GRcopy");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRcptform
(
  IGRlong *msg;
  struct GRmd_env *md_env;
  IGRmatrix matrix;
  struct GRmd_env *new_env;
  GRobjid *newobjid;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRgraphics",my_id,"GRcptform");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRclip
(
  IGRlong *msg;
  struct GRmd_env *cur_env;
  struct GRmd_env *target_env;
  IGRchar *prism;
  struct GRid *inside_id;
  struct GRid *outside_id;
  struct GRid *ovl_id;
  IGRlong *clip_flags;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRgraphics",my_id,"GRclip");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

/* -----------------------------------------------------
 * When being used as a foot, this can be called 
 * Needs to delete it's components 
 */
method GRdelete
(
  IGRlong *msg;
  struct GRmd_env *md_env;
)
{
  if (traceFlag) {
    printf("%s %s %d %s %d\n",MSG_STR,"GRgraphics",my_id,"GRdelete",me->vdclaType);
  }
  if (me->vdclaType != 66) {  
    *msg = MSFAIL;
    return OM_W_ABORT;
  }
  return om$send(msg = message VDSroot.
                 GRdelete(msg,md_env),
	         mode = OM_e_wrt_message,
	         targetid = my_id);
  
}

/* --------------------------------------
 * Might need to process this one as well 
 * for owner components
 */
method GRdisplay
(
  IGRlong *msg;
  IGRshort *type;
  IGRmatrix matrix;
  enum GRdpmode *mode;
  struct GRid *display_info;
)
{
  if (traceFlag) {  
    printf("%s %s %d %s\n",MSG_STR,"GRgraphics",my_id,"GRdisplay");
  }
  
  *msg = MSSUCC;
  return OM_S_SUCCESS;
}

method GRxform
(
  IGRlong *msg;
  struct GRmd_env *md_env;
  IGRshort *matrix_type;
  IGRmatrix matrix;
  GRobjid *newobjid;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRgraphics",my_id,"GRxform");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRconstruct
(
  struct GRvg_construct *arglist;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRgraphics",my_id,"GRconstruct");
  return OM_W_ABORT;
}

method GRaltconstruct
(
  struct GRvg_construct *arglist;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRgraphics",my_id,"GRaltconstruct");
  return OM_W_ABORT;
}

method GRformatele
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
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRgraphics",my_id,"GRformatele");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRplotyourself
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
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRgraphics",my_id,"GRplotyourself");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

/* --------------------------------------------------------------
 * Type 66 macro foot
 */
method GRaddwrng
(
  IGRlong *msg;
  struct GRmd_env *md_info;
)
{
  if (traceFlag) {    
    printf("%s %s %d %s\n",MSG_STR,"GRgraphics",my_id,"GRaddwrng");
  }
  if (me->vdclaType != 66 ) {
    *msg = MSFAIL;
    return OM_W_ABORT;
  }
  
  return om$send(msg = message VDSroot.
                 GRaddwrng(msg,md_info),
	         mode = OM_e_wrt_message,
	         targetid = my_id);
  
}

/* -----------------------------------------------
 * Used for type 66 macro foot
 */
method GRremwrng
(
  IGRlong *msg;
  struct GRmd_env *md_info;
)
{
  if (traceFlag) {    
    printf("%s %s %d %s\n",MSG_STR,"GRgraphics",my_id,"GRremwrng");
  }
  return om$send(msg = message VDSroot.
                 GRremwrng(msg,md_info),
	         mode = OM_e_wrt_message,
	         targetid = my_id);
}

method GRgentform
(
  IGRlong *msg;
  struct GRmd_env *md_env;
  IGRint (*tform_function)();
  IGRchar *info;
  GRobjid *newobjid;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRgraphics",my_id,"GRgentform");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRcpforundo
(
  IGRlong *msg;
  struct GRmd_env *obj_env;
  struct GRmd_env *new_env;
  IGRboolean *delete;
  GRobjid *new_objid;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRgraphics",my_id,"GRcpforundo");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRundocp
(
  IGRlong *msg;
  struct GRmd_env *env;
  IGRboolean *delete;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRgraphics",my_id,"GRundocp");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRfunction
(
  IGRlong *msg;
  IGRint (*user_function)();
  IGRchar *user_info;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRgraphics",my_id,"GRfunction");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRidchanged
(
  IGRlong *msg;
  IGRshort *num_ids;
  struct GRid *newids;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRgraphics",my_id,"GRidchanged");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRptprocess
(
  IGRlong *msg;
  IGRshort *matrix_type;
  IGRmatrix matrix;
  IGRdouble *acc_tolerance;
  IGRpoint point;
  IGRpoint proj_pt;
  struct GRparms *proj_parms;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRgraphics",my_id,"GRptprocess");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRlnprocess
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
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRgraphics",my_id,"GRlnprocess");
  *msg = MSFAIL;
  return OM_W_ABORT;
}
 
method GRplotprep
(
  IGRlong *msg;
  struct GRmd_env *cur_env;
  struct GRmd_env *target_env;
  IGRshort *num_prisms;
  struct IGRcv_prism *prism_array;
  struct GRid *set_id;
  IGRlong *begin_index;
  IGRlong *end_index;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRgraphics",my_id,"GRplotprep");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRrcopy
(
  IGRlong *msg;
  struct GRmd_env *obj_dsenv;
  struct GRmd_env *new_dsenv;
  GRobjid *newobjid;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRgraphics",my_id,"GRrcopy");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRreport_defaults
(
  IGRlong *msg;
  IGRchar *form;
  IGRint *label;
  IGRint *list_size;
  struct GRreport_processor *processor;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRgraphics",my_id,"GRreport_defaults");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRreport
(
  IGRlong *msg;
  struct GRmd_env *md_env;
  IGRint *list_size;
  struct GRreport_item *list;
  struct GRreport_processor *processor;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRgraphics",my_id,"GRreport");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRupdate_gadgets
(
  IGRlong *msg;
  IGRchar *form_ptr;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRgraphics",my_id,"GRupdate_gadgets");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRchannel_pass
(
  GR_S_PATH_LIST path[];
  int num_levels;
  OM_p_MESSAGE msg;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRgraphics",my_id,"GRchannel_pass");
  return OM_W_ABORT;
}

method EMvalidate
(
  IGRlong *msg;
  struct GRmd_env *mod_info;
  IGRchar *geom;
  GRobjid *cancer;
  IGRushort *option;
  IGRchar *objinfo;
  IGRchar *ioptr;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRgraphics",my_id,"EMvalidate");
  *msg = MSFAIL;
  return OM_W_ABORT;
}
                
method GRadd_to_display_list
(
  IGRlong *msg;
  IGRboolean is_hidden_line;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRgraphics",my_id,"GRadd_to_display_list");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRisparent
(
  IGRlong *msg;
  IGRboolean *isparent;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRgraphics",my_id,"GRisparent");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRanalyze_element
(
  IGRlong *msg;
  struct GRmd_env *md_env;
  FILE *rep_file_ptr;
  enum GRanalyze_types *analyze_option;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRgraphics",my_id,"GRanalyze_element");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRprint
(
  FILE *file;
  IGRint num_indent;
  IGRboolean print_super_class;
  IGRboolean print_full_format; 
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRgraphics",my_id,"GRprint");
  return OM_W_ABORT;
}

method GRread
(
  FILE *file;
  IGRboolean read_super_class;
  IGRboolean read_full_format;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRgraphics",my_id,"GRread");
  return OM_W_ABORT;
}

/* -------------------------------------------------------
 * Specific listener for type 66 object
 */
IGRstat VDct1BaseGRnotifylis66(TGRid *baseID, IGRlong op)
{
  IGRstat retFlag = 0;
  TGRid   lisID;
  IGRint  cnt;
  
  // Get list of listeners
  vdchn$GetList(objID = baseID,
		chnIDx = VDCHN_IDX_CT1_TO_NOTIFY,
		maxCnt = 1,
		cnt    = &cnt,
		outIDs = &lisID);
  if (cnt == 0) goto wrapup;

  printf("VDct1BaseGRnotifylis66 received\n");
  vdobj$Print(objID = &lisID);

  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -------------------------------------------------------
 * GRlistener
 */
method GRnotifylis
(
  IGRlong *msg;
  IGRlong *OMmsg;
  IGRlong *mask;
  OM_S_MESSAGE *graphics_msg;
)
{ 
  IGRint  traceFlagx = traceFlag;
  IGRlong op = *mask;
  TGRid   baseID;
 
  /* ----------------------------------------
   * Custom handle the macro 66
   */
  if (me->vdclaType == 66) {
    baseID.objid = my_id;
    baseID.osnum = OM_Gw_current_OS;
    VDct1BaseGRnotifylis66(&baseID, op);
    *msg = MSSUCC;
    return OM_S_SUCCESS;
  }
  
  traceFlagx = 1;
  if (traceFlagx) {

    switch(op) {
    case GR_GEOM_XFORMED :
     printf("VDct1Base.GRnotifylis %d GR_GEOM_XFORMED\n",my_id);
     break;

    case GR_GEOM_MODIFIED :
      printf("VDct1Base.GRnotifylis %d GR_GEOM_MODIFIED",my_id);
      break;

    case GR_GEOM_POSTED :
      printf("VDct1Base.GRnotifylis %d GR_GEOM_MODIFIED\n",my_id);
      break;

    case GR_DELETED :
      printf("VDct1Base.GRnotifylis %d GR_DELETED\n",my_id);
      break;

    case GR_ATTR_MODIFIED :
      printf("VDct1Base.GRnotifylis %d GR_ATTR_MODIFIED\n",my_id);
      break;

    case GR_CHANNEL_USED :
      //printf("VDct1Base.GRnotifylis %d GR_CHANNEL_USED\n",my_id);
      break;

    default:
      // printf("OTHER %08X\n",op);
      break;
    } /* end of switch */
  }

  if(ASbroadcast_in_progress) {
    if (traceFlagx) printf("ASbroadcast_in_progress\n");
    return(OM_S_SUCCESS);
  }

  // ASsuper_construct(); need to find out what this does sometime

  
  // Process it

  return( OM_S_SUCCESS );
}

/* --------------------------------------------------------
 * GRnotify
 */
method GRntfyconn
(
  IGRlong         *msg;
  struct GRid     *listeners_id;
  OM_S_CHANSELECT *listeners_chan;
  IGRint          *listeners_index;
  IGRboolean      *make_tagged_connect;
  GRspacenum      *tagged_os;
)
{
  if (traceFlag) { 
    printf("%s %s %d %s\n",MSG_STR,"GRnotify",my_id,"GRntfyconn");
  }
  return om$send(msg = message VDSroot.
                 GRntfyconn(msg,
                            listeners_id,
                            listeners_chan,
                            listeners_index,
                            make_tagged_connect,
                            tagged_os),
	         mode = OM_e_wrt_message,
	         targetid = my_id);

}

method GRntfydisconn
(
  IGRlong         *msg;
  struct GRid     *listeners_id;
  OM_S_CHANSELECT *listeners_chan;
)
{
  if (traceFlag) {
    printf("%s %s %d %s\n",MSG_STR,"GRnotify",my_id,"GRntfydisconn");
  }
  return om$send(msg = message VDSroot.
                 GRntfydisconn(msg,
                            listeners_id,
                            listeners_chan),
	         mode = OM_e_wrt_message,
	         targetid = my_id);
}

/* --------------------------------------------------------------
 * Gets called when the node is to become the parent
 * of some other isdp object
 */
method GRmksource
(
  IGRlong      *msg;
  struct GRid *context;
  GRspacenum   target_os;
  struct GRid *source;
  IGRint       option;
)
{
  if (traceFlag) {
    printf("%s %s %d %s\n",MSG_STR,"GRnotify",my_id,"GRmksource");
  }
  
  return om$send(msg = message VDSroot.
                 GRmksource(msg,
                            context,
			    target_os,
			    source,
                            option),
	         mode     = OM_e_wrt_message,
	         targetid = my_id);
}

/* --------------------------------------------------------
 * GRconnector
 *
 * Called when used as a foot
 */
method GRrigidconn
(
  IGRlong *msg;
  TGRid   *owners_id;
  IGRlong *owners_index;
)
{
  if (traceFlag) {    
    printf("%s %s %d %s\n",MSG_STR,"GRconnector",my_id,"GRrigidconn");
  }
  
  return om$send(msg = message VDSroot.
                 GRrigidconn(msg,owners_id,owners_index),
	         mode     = OM_e_wrt_message,
	         targetid = my_id);

}

/* -----------------------------------------------------------------
 * Gets called when adding a node to a GR save set during locates
 */
method GRflexconn
(
  IGRlong *msg;
  IGRlong *flag;
  TGRid   *owners_id;
  IGRlong *owners_index;
  IGRlong *graphics_index;
)
{
  if (traceFlag) { 
    printf("%s %s %d %s\n",MSG_STR,"GRconnector",my_id,"GRflexconn");
  }
  return om$send(msg = message VDSroot.
                 GRflexconn(msg,
                            flag,
                            owners_id,
                            owners_index,
                            graphics_index),
	         mode = OM_e_wrt_message,
	         targetid = my_id);

}

method GRdisconn
(
  IGRlong *msg;
  TGRid   *owners_id;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRconnector",my_id,"GRdisconn");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

/* --------------------------------------------------
 * GRvg
 */
method GRgeomprops
(
  IGRlong *msg;
  IGRshort *mat_type;
  IGRmatrix matrix;
  struct GRprops *properties;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRvg",my_id,"GRgeomprops");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRgetattr
(
  IGRlong *msg;
  IGRchar *attr;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRvg",my_id,"GRgetattr");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

/* ---------------------------------------------------------
 * Used for foot macro during locate process
 */
method GRgetsymb
(
  IGRlong *msg;
  struct GRsymbology *symb;
)
{
  if (traceFlag) {    
    printf("%s %s %d %s\n",MSG_STR,"GRvg",my_id,"GRgetsymb");
  }
  return om$send(msg = message VDSroot.
                 GRgetsymb(msg,symb),
	         mode = OM_e_wrt_message,
	         targetid = my_id);
}

method GRgenabsg
(
  IGRlong *msg;
  IGRshort *matrix_type;
  IGRmatrix matrix;
  IGRchar **absgptr;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRvg",my_id,"GRgenabsg");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRgetgeom
(
  IGRlong *msg;
  IGRshort *matrix_type;
  IGRmatrix matrix;
  IGRchar *geometry;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRvg",my_id,"GRgetgeom");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRgetsize
(
  IGRlong *msg;
  IGRshort *matrix_type;
  IGRmatrix matrix;
  IGRlong *size;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRvg",my_id,"GRgetsize");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRputsymb
(
  IGRlong *msg;
  struct GRsymbology *symb;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRvg",my_id,"GRputsymb");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRdetplane
(
  IGRlong *msg;
  IGRshort *matrix_type;
  IGRmatrix matrix;
  struct IGRplane *plane;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRvg",my_id,"GRdetplane");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRclipto
(
  IGRlong *msg;
  IGRchar *classname;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRvg",my_id,"GRclipto");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRgetexgeom
(
  IGRlong *msg;
  IGRshort *matrix_type;
  IGRmatrix matrix;
  IGRchar *geometry;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRvg",my_id,"GRgetexgeom");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRgetexsize
(
  IGRlong *msg;
  IGRshort *mx_type;
  IGRmatrix matrix;
  IGRlong *size;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRvg",my_id,"GRgetexsize");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRkeypoint
(
  IGRlong *msg;
  IGRshort *matrix_type;
  IGRmatrix matrix;
  struct IGRline *boreline;
  IGRpoint keypoint;
  struct GRparms *key_parm;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRvg",my_id,"GRkeypoint");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRmodify
(
  IGRlong *msg;
  struct GRmd_env *md_env;
  struct GRparms *parms;
  IGRpoint point;
  struct IGRline *boreline;
  GRobjid *new_objid;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRvg",my_id,"GRmodify");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRprojpt
(
  IGRlong *msg;
  IGRshort *matrix_type;
  IGRmatrix matrix;
  struct GRparms *locate_parms;
  IGRpoint point;
  IGRpoint proj_pt;
  struct GRparms *proj_parms;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRvg",my_id,"GRprojpt");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRpostabsg
(
  IGRlong *msg;
  struct GRmd_env *md_env;
  struct GRpost_info *info;
  IGRchar *absptr;
  GRobjid *newobjid;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRvg",my_id,"GRpostabsg");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRptdis
(
  IGRlong *msg;
  IGRshort *matrix_type;
  IGRmatrix matrix;
  IGRpoint point;
  IGRdouble *distance;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRvg",my_id,"GRptdis");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRputattr
(
  IGRlong *msg;
  IGRchar *attr;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRvg",my_id,"GRputattr");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRchghprops
(
  IGRlong *msg;
  IGRshort *action;
  IGRint *mask;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRvg",my_id,"GRchghprops");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRchgcolor
(
  IGRlong *msg;
  IGRuint *rgb_value;
  IGRushort *color;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRvg",my_id,"GRchgcolor");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRchgdp
(
  IGRlong *msg;
  struct IGRdisplay *dp_info;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRvg",my_id,"GRchgdp");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRchglevel
(
  IGRlong *msg;
  IGRshort *level;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRvg",my_id,"GRchglevel");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRchgstyle
(
  IGRlong *msg;
  IGRuchar *style;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRvg",my_id,"GRchgstyle");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRchgweight
(
  IGRlong *msg;
  IGRuchar *weight;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRvg",my_id,"GRchgweight");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRcenter
(
  IGRlong *msg;
  IGRshort *mat_type;
  IGRmatrix matrix;
  IGRpoint center;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRvg",my_id,"GRcenter");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRcentcurv
(
  IGRlong *msg;
  IGRshort *mat_type;
  IGRmatrix matrix;
  struct GRparms *u;
  IGRpoint center;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRvg",my_id,"GRcentcurv");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRstretch
(
  IGRlong *msg;
  struct GRmd_env *md_env;
  IGRshort *type_prism;
  IGRchar *prism;
  IGRmatrix xform_matrix;
  GRobjid *objid;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRvg",my_id,"GRstretch");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method EMpratpt
(
  IGRlong *msg;
  IGRshort *mat_type;
  IGRmatrix matrix;
  IGRpoint wpoint_xyz;
  IGRdouble point_parametric[];
  IGRint *num_parameters;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRvg",my_id,"EMpratpt");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method EMptatpr
(
  IGRlong *msg;
  IGRshort *mat_type;
  IGRmatrix matrix;
  IGRdouble point_parametric[];
  IGRint num_parameters;
  IGRpoint wpoint_xyz;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRvg",my_id,"EMptatpr");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRfragment
(
  IGRlong *msg;
  struct GRmd_env *env;
  struct GRid *owner;
  struct GRmd_env *new_env;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRvg",my_id,"GRfragment");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRcoplanar
(
  IGRlong *msg;
  IGRshort *matrix_type;
  IGRmatrix matrix;
  IGRshort *num_objects;
  GRobjid *objid_ids;
  IGRdouble *tolerance;
  struct IGRplane *plane;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRvg",my_id,"GRcoplanar");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRinplane
(
  IGRlong *msg;
  IGRshort *matrix_type;
  IGRmatrix matrix;
  struct IGRplane *plane;
  IGRdouble *tolerance;
  IGRshort *rel;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRvg",my_id,"GRinplane");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRputrang
(
  IGRlong *msg;
  GRrange range;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRvg",my_id,"GRputrang");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRdynmod
(
  IGRlong *msg;
  IGRshort *mat_type;
  IGRmatrix matrix;
  struct GRparms *modpt;
  IGRpoint point;
  enum GRdyn_flag *action;
  IGRchar *buff;
  IGRboolean (*func)();
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRvg",my_id,"GRdynmod");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method EMintplane
(
  struct GRvg_construct *construct_list;
  struct IGRplane *plane;
  struct GRlc_info *located_object;
  IGRint *num_of_intersections;
  struct GRid **ptr_to_resulting_intersections;
  IGRint *msg;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRvg",my_id,"EMintplane");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method EMgetpoles
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
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRvg",my_id,"EMgetpoles");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method DEdisyourself
(
  long *msg;
  short *type;
  IGRmatrix matrix;
  enum GRdpmode *mode;
  struct IGRaltdisplay *alt_symb;
  struct DP_information *sp_info;
  OM_p_KEY_DESC *key;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRvg",my_id,"DEdisyourself");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

/* --------------------------------------------------------
 * GRcmpowner Type 66 macro foot
 */
method GRlocate_owner
(
  IGRlong          *msg;
  struct GRlc_cvl  *cvl;
  struct GRlc_path *path;
  IGRint           *path_position;
)
{
  if (traceFlag) {    
    printf("%s %s %d %s\n",MSG_STR,"GRcmpowner",my_id,"GRlocate_owner");
  }
#if 1
  return om$send(msg = message VDSroot.
                 GRlocate_owner(msg,cvl,path,path_position),
	         mode = OM_e_wrt_message,
	         targetid = my_id);
#endif
#if 0
  *msg = MSFAIL;
  return OM_W_ABORT;
#endif
}


method GRownaddwrng
(
  IGRlong *msg;
  struct GRmd_env *mod_env;
  GRobjid *objid;
  GRrange range;
)
{
  if (traceFlag) {    
    printf("%s %s %d %s\n",MSG_STR,"GRcmpowner",my_id,"GRownaddwrng");
  }
  return om$send(msg = message VDSroot.
                 GRownaddwrng(msg,mod_env,objid,range),
	         mode = OM_e_wrt_message,
	         targetid = my_id);
}

/* -----------------------------------------------
 * Type 66 macro foot
 */
method GRownremwrng
(
  IGRlong *msg;
  struct GRmd_env *mod_env;
  GRobjid *objid;
  GRrange range;
)
{
  if (traceFlag) {  
    printf("%s %s %d %s\n",MSG_STR,"GRcmpowner",my_id,"GRownremwrng");
  }  
  return om$send(msg = message VDSroot.
                 GRownremwrng(msg,mod_env,objid,range),
	         mode = OM_e_wrt_message,
	         targetid = my_id);
}

/* -----------------------------------------------
 * Type 66 macro foot
 */
method GRcomponent_disconnecting
(
  IGRlong         *msg;
  struct GRmd_env *mod_env;
  struct GRid     *comp_id;
)
{
  if (traceFlag) {    
    printf("%s %s %d %s\n",MSG_STR,"GRcmpowner",my_id,"GRcomponent_disconnecting");
  }
  return om$send(msg = message VDSroot.
                 GRcomponent_disconnecting(msg,mod_env,comp_id),
	         mode = OM_e_wrt_message,
	         targetid = my_id);
}

method GRrigid_connecting
(
  IGRlong *msg;
  struct GRid *go_id;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRcmpowner",my_id,"GRrigid_connecting");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRcomponent_idchanged
(
  IGRlong *msg;
  IGRshort *num_comp_ids;
  struct GRid *comp_ids;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRcmpowner",my_id,"GRcomponent_idchanged");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

/* -------------------------------------------------------------------------
 * GRowner
 */
method GRget_owner_properties
(
  IGRlong *msg;
  IGRshort *properties;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRowner",my_id,"GRget_owner_properties");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRget_channel_type
(
  IGRlong *msg;
  IGRint *type;
  IGRint *conn_type;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRowner",my_id,"GRget_channel_type");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

/* -----------------------------------------------
 * Called when being used as an owner
 * And displaying the graphics
 */
method GRget_context
(
  IGRlong *msg;
  struct GRmd_env *mod_env;
  struct GRmd_env *cmp_mod_env;
)
{
  if (traceFlag) {    
    printf("%s %s %d %s\n",MSG_STR,"GRowner",my_id,"GRget_context");
  }
  
  return om$send(msg = message VDSroot.
                 GRget_context(msg,mod_env,cmp_mod_env),
	         mode = OM_e_wrt_message,
	         targetid = my_id);
}

/* -----------------------------------------------
 * Called when being being displayed
 */
method GRget_matrix
(
  IGRlong *msg;
  IGRshort *matrix_type;
  IGRmatrix matrix;
  IGRshort *cmp_matrix_type;
  IGRmatrix cmp_matrix;
)
{
  if (traceFlag) {    
    printf("%s %s %d %s\n",MSG_STR,"GRowner",my_id,"GRget_matrix");
  }
  
  return om$send(msg = message VDSroot.
                 GRget_matrix(msg,matrix_type,matrix,cmp_matrix_type,cmp_matrix),
	         mode = OM_e_wrt_message,
	         targetid = my_id);
}

method GRchg_owner_properties
(
  IGRlong *msg;
  IGRint action;
  IGRshort *mask;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRowner",my_id,"GRchg_owner_properties");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRget_number_components
(
  IGRlong *msg;
  IGRint *count;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRowner",my_id,"GRget_number_components");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRget_components
(
  IGRlong *msg;
  struct GRmd_env *mod_env;
  struct GRid objects[];
  IGRint number_objects;
  IGRint *count;
  IGRint from_obj;
  IGRint to_obj;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRowner",my_id,"GRget_components");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRprismrel_owner
(
  IGRlong *msg;
  IGRshort *mx_type;
  IGRmatrix matrix;
  IGRlong *prism_rel;
  struct GRid *component_id;
  IGRlong *component_rel;
  IGRshort *type_prism;
  IGRchar *prism;
  IGRlong *relationship;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRowner",my_id,"GRprismrel_owner");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

/* ------------------------------------------------------
 * Used for macro foot
 */
method GRget_locate_properties
(
  IGRlong *msg;
  IGRint  *properties;
)
{
  if (traceFlag) {    
    printf("%s %s %d %s\n",MSG_STR,"GRowner",my_id,"GRget_locate_properties");
  }  
  return om$send(msg = message VDSroot.
                 GRget_locate_properties(msg,properties),
	         mode = OM_e_wrt_message,
	         targetid = my_id);
}

method GRdrop
(
  IGRlong *msg;
  struct GRmd_env *mod_env;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRowner",my_id,"GRdrop");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRremove_components
(
  IGRlong *msg;
  struct GRmd_env *mod_env;
  IGRint *num_objects;
  struct GRobj_env objects[];
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRowner",my_id,"GRremove_components");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRadd_components
(
  IGRlong *msg;
  struct GRmd_env *mod_env;
  IGRint *num_objects;
  struct GRobj_env objects[];
  IGRint own_index[];
  IGRint go_index[];
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRowner",my_id,"GRadd_components");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRdelete_owner
(
  IGRlong *msg;
  struct GRmd_env *mod_env;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRowner",my_id,"GRdelete_owner");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRcopy_owner
(
  IGRlong *msg;
  struct GRmd_env *mod_env;
  struct GRmd_env *target_env;
  GRobjid *owner_id;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRowner",my_id,"GRcopy_owner");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRxform_owner
(
  IGRlong *msg;
  struct GRmd_env *md_env;
  IGRshort *matrix_type;
  IGRmatrix matrix;
  GRobjid *newobjid;
  IGRint *cont;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRowner",my_id,"GRxform_owner");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRpost_clip_owner
(
  IGRlong *msg;
  struct GRmd_env *mod_env;
  struct GRmd_env *target_env;
  IGRchar *prism;
  struct GRid *inside_id;
  struct GRid *outside_id;
  struct GRid *overlap_id;
  IGRlong *clip_flag;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRowner",my_id,"GRpost_clip_owner");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRreplace
(
  IGRlong *msg;
  struct GRmd_env *mod_env;
  struct GRmd_env *lib_env;
  struct GRid *def_id;
  struct GRid *new_id;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRowner",my_id,"GRreplace");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRis_component_removeable
(
  IGRlong *msg;
  struct GRmd_env *mod_env;
  struct GRid *comp_id;
  IGRint *flag;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRowner",my_id,"GRis_component_removeable");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRadd_to_active_owner
(
  IGRlong *msg;
  struct GRmd_env *mod_env;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRowner",my_id,"GRadd_to_active_owner");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRset_active_owner
(
  IGRlong *msg;
  struct GRmd_env *mod_env;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRowner",my_id,"GRset_active_owner");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRclear_active_owner
(
  IGRlong *msg;
  struct GRmd_env *mod_env;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRowner",my_id,"GRclear_active_owner");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRget_siblings
(
  IGRlong *msg;
  IGRushort opts;
  IGRint *num_siblings;
  struct GRid **siblings;
  IGRint num_buff;
  struct GRid *buff;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRowner",my_id,"GRget_siblings");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

method GRpass_messg
(
  IGRlong *msg;
  IGRushort opts;
  OM_E_WRT_FLAG wrt_flag;
  OM_p_MESSAGE messg;
  struct GRmdenv_info *my_mdenv_info;
  OM_p_CLASSLIST yes_classes;
  OM_p_CLASSLIST no_classes;
  IGRboolean (*eligfunc)();
  IGRchar *eligfunc_args;
  IGRint depth;
)
{
  printf("%s %s %d %s\n",MSG_STR,"GRowner",my_id,"GRpass_messg");
  *msg = MSFAIL;
  return OM_W_ABORT;
}

end implementation VDct1Base;
