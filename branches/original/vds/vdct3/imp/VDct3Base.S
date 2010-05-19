/* $Id: VDct3Base.S,v 1.1.1.1 2001/01/04 21:08:02 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct3/imp/VDct3Base.S
 *
 * Description: Tree Object
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct3Base.S,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:02  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1999/06/29  18:27:04  pinnacle
# ct
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/28/99  ah      Creation
 ***************************************************************************/

class specification VDct3Base(1:0) of GRlistener,VDlnk,VDcol,VDcla,VDSroot;

instance VDct3Base
{
  // Allow it to be a listener as well
  channel {
    (many_to_many,
     rel_ordered,
     initial   = 1,
     increment = 1)
  } to_notify;    
};

/* ------------------------------------------------------------------------
 * GRgraphics
 */
override 
  GRgetprops,
  GRgethprops,
  GRgetrang,
  GRlevelcount,
  GRchgprops,
  GRgetname,
  GRprismrel,
  GRlocate,
  GRlocate_processing,
  GRputname,
  GRchgname,
  GRlocaldp,
  GRgetobjinfo,
  GRapprojpt,
  GRptproject,
  GRlnproject,
  GRdisyourself,
  GRcopy,
  GRcptform,
  GRclip,
  GRdelete,
  GRdisplay,
  GRxform,
  GRconstruct,
  GRaltconstruct,
  GRformatele,
  GRplotyourself,
  GRaddwrng,
  GRremwrng,
  GRgentform,
  GRcpforundo,
  GRundocp,
  GRfunction,
  GRidchanged,
  GRptprocess,
  GRlnprocess,
  GRplotprep,
  GRrcopy,
  GRreport_defaults,
  GRreport,
  GRupdate_gadgets,
  GRchannel_pass,
  EMvalidate,
  GRadd_to_display_list,
  GRisparent,
  GRanalyze_element,
  GRprint,
  GRread;

/* -----------------------------------------------------------
 * GRlistener
 */
override 
  GRnotifylis;

/* -------------------------------------------------------------------------
 * GRnotify
 */
override
  GRntfyconn,
  GRntfydisconn,
  GRmksource;

/* -------------------------------------------------------------------------
 * GRconnector
 */
override
  GRrigidconn,
  GRflexconn,
  GRdisconn; 

/* -------------------------------------------------------------------------
 * GRvg
 */
override
  GRgeomprops,
  GRgetattr,
  GRgetsymb,
  GRgenabsg,
  GRgetgeom,
  GRgetsize,
  GRputsymb,
  GRdetplane,
  GRclipto,
  GRgetexgeom,
  GRgetexsize,
  GRkeypoint,
  GRmodify,
  GRprojpt,
  GRpostabsg,
  GRptdis,
  GRputattr,
  GRchghprops,
  GRchgcolor,
  GRchgdp,
  GRchglevel,
  GRchgstyle,
  GRchgweight,
  GRcenter,
  GRcentcurv,
  GRstretch,
  EMpratpt,
  EMptatpr,
  GRfragment,
  GRcoplanar,
  GRinplane,
  GRputrang,
  GRdynmod,
  EMintplane,
  EMgetpoles,
  DEdisyourself;
 
/* -------------------------------------------------------------------------
 * GRcmpowner
 */
override
  GRlocate_owner,
  GRownaddwrng,
  GRownremwrng,
  GRcomponent_disconnecting,
  GRrigid_connecting,
  GRcomponent_idchanged;

/* -------------------------------------------------------------------------
 * GRowner
 */
override 
  GRget_owner_properties,
  GRget_channel_type,
  GRget_context,
  GRget_matrix,
  GRchg_owner_properties,
  GRget_number_components,
  GRget_components,
  GRprismrel_owner,
  GRget_locate_properties,
  GRdrop,
  GRremove_components,
  GRadd_components,
  GRdelete_owner,
  GRcopy_owner,
  GRxform_owner,
  GRpost_clip_owner,
  GRreplace,
  GRis_component_removeable,
  GRadd_to_active_owner,
  GRset_active_owner,
  GRclear_active_owner,
  GRget_siblings,
  GRpass_messg;


/* ------------------------------------------------
 * NDmacro
 */
override
  ACin_macro_def,
  ACbecome_macro,
  ACgive_structure,
  ACreturn_foot,
  ACgive_foot,
  ACtest_foot,
  ACcopy_to_Groot,
  ACconsume,
  ACunconsume,
  ACntf_consume,
  ACntf_unconsume,
  ACtest_consumed,
  ACbubble_up,
  ACpass_up,
  ACbecome_foot,
  ACmap_from_visible,
  ACcompute_node;

/* -----------------------------------------------
 * NDnode
 */
override
  NDget_objects,
  NDget_virtual_objects,
  NDconnect_graph,
  NDconnect,
  NDdisconnect,
  NDchange_connect,
  NDupdate,
  NDcompute_node,
  NDs_compute_node,
  NDchange_node,
  NDgive_structure,
  NDprint,
  NDprint_root,
  NDdelete,
  NDplace,
  NDget_state,
  NDchg_state,
  NDparent_deleted,
  NDrm_assoc,
  NDmove_to_root,
  NDchildren_deleted,
  NDdisplay,
  NDselect_copy,
  NDcopy_graph,
  NDcopy,
  NDnotify_connect,
  NDnotify_disconnect,
  NDpossible_parent,
  NDcopy_to_tmp_root,
  NDmove_to_tmp_clone,
  NDcopy_to_root,
  NDmake_source,
  ASreturn_go,
  NDsleep,
  NDattach_to_cs,
  NDdetach_from_cs,
  NDattach_to_track_pt,
  NDdetach_from_track_pt,
  NDget_parent_type,
  NDctl_parent_type,
  NDdrawing_copy_geom,
  NDdrawing_copy_attr,
  NDparent_rf_detached;

/* ----------------------------------------------------------
 * ASnode
 */
override
  ACgive_path,
  ACconnect_pretend,
  ACconnect_pretendin,
  ASconstruct_go,
  ASpossible_parent,
  ASget_opt_ind,
  ASadd_opt,
  ASpoststr;

/* ----------------------------------------------------------
 * ACcpx
 */
override
  find_macro,
  ACload_macro,
  ACattach,
  ACfind_exp_temp_obj,
  ACfind_exp_temp_struct,
  ACdrop,
  ACbuild_rtn_str,
  ACtbuild_rtn_str,
  ACfree_rtn_str,
  ACload_temp_feet,
  ACfind_temp_obj,
  ACfind_temp_struct,
  ACrebuild,
  ACfind_go;

/* --------------------------------------------------
 * ACdb_info
 */
override
  ACset_db_info,
  ACget_db_info,
  ACget_db_info_and_def,
  ACadd_to_dir,
  ACset_serial_no,
  ACput_serial_no,
  ACcheckin_candidate,
  ACadd_to_list,
  ACadd_to_list_1,
  ACgive_db_structure;

/* --------------------------------------------------
 * Root
 */
override
  debug,
  delete,
  connect, 
  disconnect,
  wild_disconnect,		
  move_chan,
  copy_chan,
  unknown,
  range_disconnect,
  set_operation,
  ARwrite,
  ARread;

/* ---------------------------------------------------
 * IGRdir
 */
override
  i_find,
  init,
  ls,
  find,
  add,
//  remove,  Not sure why
  translate,
  unindex,
  dump,
  pass;

/* -----------------------------------------------
 * ACncpx
 */
override 
  ACcontext_compute,
  ACcontext_compute_feet,
  ACchange_feet,
  ACconstruct_feet,
  ACmplace,
  ACmplace_from_def,
  ACmroot_place,
  ACindex_in,
  ACset_NV_rep,
  ACput_NV_rep,
  ACget_NV_rep,
  ACput_rep,
  ACget_rep,
  ACget_STATE,
  ACchg_STATE,
  ACchange_node,
  ACinstanciate_template_feet,
  DIgive_output;

/* ------------------------------------------
 * VDSroot 
 */
override 
  VDget_trans_table_entries,
  VDget_prefix_name,
  VDSgetUsrAttributes,
  VDSmodUsrAttributes,
  VDreviewParameters,
  VDgetParameters,
  VDSgetCompDesc,
  VDGetModel,
  VDGetGraphMac,
  VDPostYourselfToDb,
  VDgetObjDef,
  VDcreate,
  VDprint,
  VDcompute,
  VDGetProduct,
  VDGetCenterLine,
  VDgetAttrDrivenSymb,
  VDputAttrDrivenSymb,
  VDdescribeOutput,
  VDExecutePpl,
  VDprocAttr,
  VDGetParamsId;

end specification VDct3Base;


