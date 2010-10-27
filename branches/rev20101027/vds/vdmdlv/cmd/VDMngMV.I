class implementation  VDCmdMngMV;

/* -------------------------------------------------------------------------
   Doc : form_notification

   History :
   Nov 5 1994	Raju	Creation
------------------------------------------------------------------------- */

#include "stdio.h"
#include "FI.h"
#include "griodef.h"

#include "parametric.h"
#include "coparadef.h"
#include "coparamac.h"

#include "lcmacros.h"
#include "msdef.h"
#include "msmacros.h"

#include "igrdef.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "EMSaction.h"
#include "vderrmacros.h"
#include "vdsollocdef.h"
#include "vdmdlvwdef.h"

%safe
static  int form_state = VD_MNG_MV_ST;
static	int			static_num_obj;
static  struct  GRobj_env	*stat_obj_list = NULL;
%endsafe

extern  OMuword  OPP_EMSsubbs_class_id;
extern  OMuword  OPP_EMSsolid_class_id;

from	NDnode	    import  NDdelete;
from	NDnode	    import  ASreturn_go;
from    GRgraphics  import  GRdisplay;
from    VDmdlview   import  VDmv_give_vv_qry;
from	VDmdlview   import  VDmv_give_objects;
from	VDmdlview   import  VDmv_modify;
from	VDmdlview   import  VDmv_display_solid;
from	GRgraphics  import  GRchgprops;

method  form_notification (
 int	 form_label;
 int	 gadget_label;
 double	 value;
 char	 *form_ptr;
)

{
long		sts1, status, msg;
int		ii, jj, sel_flag,
		x_pos, y_pos;
enum GRdpmode	dpmode;
struct GRid	solbool;
short		action, props;



 FIg_set_text ( form_ptr, FI_MSG_FIELD, "" );
 if ( form_ptr == FP_MGR )
 {
  switch ( gadget_label )
  {

      case VD_MV_LIST_FLD :
	FIfld_get_active_row ( form_ptr, VD_MV_LIST_FLD, &x_pos, &y_pos );
	if ( x_pos >= me->num_mdlvw )  break;
	if ( x_pos == me->last_sel_mdlv )
	{
	    /* clicked on row which was selected before (now unselecting) */
/*
	    dpmode = GRbdhe;

	    status = om$send( msg = message VDmdlview.VDmv_display_solid (
						&msg, &dpmode ),
		  targetid = me->mdlvw_ids[x_pos].objid,
		  targetos = me->mdlvw_ids[x_pos].osnum,
		  senderid = NULL_OBJID );
	    VDS_ERR_RPT("VDmdlview.VDmv_display_solid",status,msg, VD_VERBOSE );
*/
	    dp$erase_hilite ( msg = &msg );

	    me->last_sel_mdlv = -1;
	}
	else
	{
	   /* clicked on a new row */
/*
	    dpmode = GRbdhe;
	    if ( me->last_sel_mdlv != -1 )
	    {
	      status = om$send( msg = message VDmdlview.VDmv_display_solid (
						&msg, &dpmode ),
		  targetid = me->mdlvw_ids[me->last_sel_mdlv].objid,
		  targetos = me->mdlvw_ids[me->last_sel_mdlv].osnum,
		  senderid = NULL_OBJID );
	      VDS_ERR_RPT("VDmdlview.VDmv_display_solid",status,msg,VD_VERBOSE);
	    }
*/
	    dp$erase_hilite ( msg = &msg );

	    dpmode = GRhd;

	    status = om$send( msg = message NDnode.ASreturn_go (
					&solbool,
					NULL,
					NULL ),
		  targetid = me->mdlvw_ids[x_pos].objid,
		  targetos = me->mdlvw_ids[x_pos].osnum,
		  senderid = NULL_OBJID );
	    VDS_ERR_HNDLR("NDnode.ASreturn_go",status,1, VD_VERBOSE, quit );

	    action = 1;
	    props = GRIS_DISPLAYABLE;
	    status = om$send ( msg = message GRgraphics.GRchgprops (
					&msg, &action, &props ),
			targetid = solbool.objid,
			targetos = solbool.osnum );
	    VDS_ERR_HNDLR("GRgraphics.GRchgprops",status,msg,VD_VERBOSE,quit);

	    ACset_disthruref();
	    status = om$send ( msg = message GRgraphics.GRdisplay (
				&msg,
				&(me->mdlvw_envs[x_pos].md_env.matrix_type),
				me->mdlvw_envs[x_pos].md_env.matrix,
				&dpmode,
				&me->ModuleInfo.md_id ),
		  targetid = solbool.objid,
		  targetos = solbool.osnum  );
	    ACreset_disthruref ();

	    action = 0;
	    props = GRIS_DISPLAYABLE;
	    status = om$send ( msg = message GRgraphics.GRchgprops ( 
					&msg, &action, &props ),
			targetid = solbool.objid,
			targetos = solbool.osnum );
	    VDS_ERR_HNDLR("GRgraphics.GRchgprops",status,msg,VD_VERBOSE,quit);

/*
	    status = om$send( msg = message VDmdlview.VDmv_display_solid (
						&msg, &dpmode ),
		  targetid = me->mdlvw_ids[x_pos].objid,
		  targetos = me->mdlvw_ids[x_pos].osnum,
		  senderid = NULL_OBJID );
	    VDS_ERR_RPT("VDmdlview.VDmv_display_solid", status,msg,VD_VERBOSE );
*/
	    me->last_sel_mdlv = x_pos;
	}
	break;

      case VD_MV_CRT_FLD :
	FIg_set_text ( FP_MV, VD_MV_NAME_FLD, "" );
	FIg_set_text ( FP_MV, VD_MV_DESC_FLD, "" );
	for ( ii=0; ii < me->num_mdlvw; ii++ )
	{
	  FIfld_get_select ( form_ptr, VD_MV_LIST_FLD, ii, 0, &sel_flag);
	  if ( sel_flag ) break;
	}

	if ( ii < me->num_mdlvw )
	{
/*
	   dpmode = GRbdhe;
	   status = om$send( msg = message VDmdlview.VDmv_display_solid (
						&msg, &dpmode ),
		  targetid = me->mdlvw_ids[ii].objid,
		  targetos = me->mdlvw_ids[ii].osnum,
		  senderid = NULL_OBJID );
	   VDS_ERR_RPT("VDmdlview.VDmv_display_solid",status,msg,VD_VERBOSE);
*/
	   dp$erase_hilite ( msg = &msg );

	   FIfld_set_select ( form_ptr, VD_MV_LIST_FLD, ii, 0, FALSE);
	   FIfld_set_select ( form_ptr, VD_MV_LIST_FLD, ii, 1, FALSE);
	   me->last_sel_mdlv = -1;
	}

	FIg_disable ( form_ptr, FI_ACCEPT );
	FIg_disable ( form_ptr, VD_MV_CRT_FLD );
	FIg_disable ( form_ptr, VD_MV_MDF_FLD );
	FIg_disable ( form_ptr, VD_MV_DLT_FLD );
	FIg_erase ( FP_MV, VD_MV_MDF_MV_TXT );
	FIg_display ( FP_MV, VD_MV_CRT_MV_TXT );
	FIf_get_location ( me->forms[0].form_ptr, &x_pos, &y_pos );
	FIf_set_location ( me->forms[1].form_ptr, x_pos, y_pos );
	FIf_display ( FP_MV );
	me->num_vvol = 0;
	me->num_qry  = 0;
	form_state = VD_CRT_MV_ST;

	sts1 = om$send ( msg = message VDCmdMngMV.set_crt_mdf_list_fld
					( &msg ),
			    targetid = my_id );
	break;

      case VD_MV_MDF_FLD :

	for ( ii=0; ii < me->num_mdlvw; ii++ )
	{
	  FIfld_get_select ( form_ptr, VD_MV_LIST_FLD, ii, 0, &sel_flag);
	  if ( sel_flag ) break;
	}

	if ( ii == me->num_mdlvw )
	   FIg_set_text ( form_ptr, FI_MSG_FIELD, "No Model View Selected");
	else
	{
	   int		nb_tot_root,
			nb_root_fnd,
			num_vvol,
			num_qry;
	   struct GRid	*vvol_ids = NULL,
			*qry_ids = NULL;
	   struct GRmd_env *vvol_envs = NULL,
			   *qry_envs = NULL;
	   char		**vvol_names = NULL,
			**vvol_desc = NULL,
			**qry_names = NULL,
			**qry_desc = NULL;

/*
	   dpmode = GRbdhe;
	   status = om$send( msg = message VDmdlview.VDmv_display_solid (
						&msg, &dpmode ),
		  targetid = me->mdlvw_ids[ii].objid,
		  targetos = me->mdlvw_ids[ii].osnum,
		  senderid = NULL_OBJID );
	   VDS_ERR_RPT("VDmdlview.VDmv_display_solid",status,msg,VD_VERBOSE);
*/
	   dp$erase_hilite ( msg = &msg );

	   FIfld_set_select ( form_ptr, VD_MV_LIST_FLD, ii, 0, FALSE);
	   FIfld_set_select ( form_ptr, VD_MV_LIST_FLD, ii, 1, FALSE);
	   me->last_sel_mdlv = -1;

	   me->mod_mv_nb = ii;
	   FIg_disable ( form_ptr, FI_ACCEPT );
	   FIg_disable ( form_ptr, VD_MV_CRT_FLD );
	   FIg_disable ( form_ptr, VD_MV_MDF_FLD );
	   FIg_disable ( form_ptr, VD_MV_DLT_FLD );

	   FIg_set_text ( FP_MV, VD_MV_NAME_FLD, me->mdlvw_names[ii] );
	   FIg_set_text ( FP_MV, VD_MV_DESC_FLD, me->mdlvw_desc[ii] );
	   FIg_erase ( FP_MV, VD_MV_CRT_MV_TXT );
	   FIg_display ( FP_MV, VD_MV_MDF_MV_TXT );
	   form_state = VD_MDF_MV_ST;

	   strcpy( me->mod_mv_name, me->mdlvw_names[ii] );

	   sts1 = om$send ( msg = message VDmdlview.VDmv_give_vv_qry
					( &msg, &nb_tot_root, &nb_root_fnd,
					  &num_vvol, &vvol_ids, &vvol_envs,
					  &vvol_names, &vvol_desc, &num_qry,
				&qry_ids, &qry_envs, &qry_names, &qry_desc ),
			    targetid = me->mdlvw_ids[ii].objid,
			    targetos = me->mdlvw_ids[ii].osnum );
	   VDS_ERR_HNDLR ( "VDmdlview.VDmv_give_vv_qry", sts1, msg,
						VD_VERBOSE, FREE_MEMORY );

	   sts1 = om$send ( msg = message VDCmdMngMV.set_instance_dimension
						( num_vvol, num_qry ),
			    targetid = my_id );

	   sts1 = om$send ( msg = message VDCmdMngMV.copy_to_instance
				  ( num_vvol, vvol_ids, vvol_envs, vvol_names,
				    vvol_desc, num_qry, qry_ids, qry_envs,
				    qry_names, qry_desc ),
			    targetid = my_id );

	   sts1 = om$send ( msg = message VDCmdMngMV.set_crt_mdf_list_fld
					( &msg ),
			    targetid = my_id );

	   if ( me->mdlvw_ids[ii].osnum != me->ModuleInfo.md_id.osnum )
		FIg_set_text ( FP_MV, FI_MSG_FIELD,
			"MdlView from ref file, can not be modified" );

FREE_MEMORY:
	   if ( vvol_ids ) free ( vvol_ids );
	   if ( vvol_envs ) free ( vvol_envs );
	   if ( vvol_names ) VDfree_str_list ( vvol_names, num_vvol );
	   if ( vvol_desc ) VDfree_str_list ( vvol_desc, num_vvol );

	   if ( qry_ids ) free ( qry_ids );
	   if ( qry_envs ) free ( qry_envs );
	   if ( qry_names ) VDfree_str_list ( qry_names , num_qry );
	   if ( qry_desc ) VDfree_str_list ( qry_desc, num_qry );
	   FIf_get_location ( me->forms[0].form_ptr, &x_pos, &y_pos );
	   FIf_set_location ( me->forms[1].form_ptr, x_pos, y_pos );
	   FIf_display ( FP_MV );

	   if ( nb_tot_root != nb_root_fnd )
		FIg_set_text( FP_MV, FI_MSG_FIELD,
		  "Warning : Some of the roots are in inactive ref file(s)" );

	}
	break;

      case VD_MV_DLT_FLD:
	for ( ii=0; ii < me->num_mdlvw; ii++ )
	{
	  FIfld_get_select ( form_ptr, VD_MV_LIST_FLD, ii, 0, &sel_flag);
	  if ( sel_flag ) break;
	}


	if ( ii == me->num_mdlvw )
	   FIg_set_text ( form_ptr, FI_MSG_FIELD, "No Model View Selected");
/* We don't care if it is used or not
	else if( me->mdlvw_used[ii] )
	    FIg_set_text ( form_ptr, FI_MSG_FIELD, "Model View is in use");
*/
	else
	{
	     if ( me->mdlvw_ids[ii].osnum != me->ModuleInfo.md_id.osnum )
	     {
		FIg_set_text ( FP_MGR, FI_MSG_FIELD,
				"MdlView from ref file, can not be deleted" );
		break;
	     }

/*
	     dpmode = GRbdhe;
	     status = om$send( msg = message VDmdlview.VDmv_display_solid (
						&msg, &dpmode ),
		  targetid = me->mdlvw_ids[ii].objid,
		  targetos = me->mdlvw_ids[ii].osnum,
		  senderid = NULL_OBJID );
	     VDS_ERR_RPT("VDmdlview.VDmv_display_solid",status,msg,VD_VERBOSE);
*/
	     dp$erase_hilite ( msg = &msg );

	     FIfld_set_select ( form_ptr, VD_MV_LIST_FLD, ii, 0, FALSE);
	     FIfld_set_select ( form_ptr, VD_MV_LIST_FLD, ii, 1, FALSE);
	     me->last_sel_mdlv = -1;

	    sts1 = om$send( msg = message NDnode.NDdelete ( &me->ModuleInfo ),
			      targetid = me->mdlvw_ids[ii].objid,
			      targetos = me->mdlvw_ids[ii].osnum );
	    VDS_ERR_RPT ( "NDnode.NDdelete", sts1, 1, VD_VERBOSE );

	    sts1 = om$send ( msg = message VDCmdMngMV.get_mdlvw_list( &msg ),
			    targetid = my_id );

	    sts1 = om$send ( msg = message VDCmdMngMV.set_manag_form( &msg ),
			    targetid = my_id );
	}
	break;

      case VD_MV_HLT_FLD:
	for ( ii=0; ii < me->num_mdlvw; ii++ )
	{
	  FIfld_get_select ( form_ptr, VD_MV_LIST_FLD, ii, 0, &sel_flag);
	  if ( sel_flag ) break;
	}

	if ( ii == me->num_mdlvw )
	   FIg_set_text ( form_ptr, FI_MSG_FIELD, "No Model View Selected");
	else
	{
	   sts1 = ex$message (	field  = ERROR_FIELD,
				justification = CENTER_JUS,
				in_buff = "Processing ..."   );

	   static_num_obj = 0;
	   if ( stat_obj_list )
		{ free ( stat_obj_list ); stat_obj_list = NULL; }
	   sts1 = om$send ( msg = message VDmdlview.VDmv_give_objects (
						&msg,
						VD_EL_INSIDE,
						&static_num_obj,
						&stat_obj_list ),
			   targetid = me->mdlvw_ids[ii].objid,
			   targetos = me->mdlvw_ids[ii].osnum );
	   VDS_ERR_HNDLR ( "VDmdlview.VDmv_give_objects", sts1, msg,
						VD_VERBOSE, VD_ERROR1 );
	   dpmode = GRhd;
	   for(jj=0; jj<static_num_obj; jj++)
		sts1 = om$send ( msg = message GRgraphics.GRdisplay (
				&msg,
				&(stat_obj_list[jj].mod_env.md_env.matrix_type),
				stat_obj_list[jj].mod_env.md_env.matrix,
				&dpmode,
				&me->ModuleInfo.md_id ),
			 targetid = stat_obj_list[jj].obj_id.objid,
			 targetos = stat_obj_list[jj].obj_id.osnum );
	}

VD_ERROR1:
	break;

      case VD_MV_DRW_FLD:

	   dpmode = GRbdhe;
	   for(jj=0; jj<static_num_obj; jj++)
		sts1 = om$send ( msg = message GRgraphics.GRdisplay (
				&msg,
				&(stat_obj_list[jj].mod_env.md_env.matrix_type),
				stat_obj_list[jj].mod_env.md_env.matrix,
				&dpmode,
				&me->ModuleInfo.md_id ),
			 targetid = stat_obj_list[jj].obj_id.objid,
			 targetos = stat_obj_list[jj].obj_id.osnum );
	   static_num_obj = 0;
	   if ( stat_obj_list )
		{ free ( stat_obj_list ); stat_obj_list = NULL; }
	   break;


      case FI_ACCEPT:
	dp$erase_hilite ( msg = &msg );
	_put_response ( resp = FORM_FINISHED );
	break;
  }  /* switch ( gadget_label ) */
 }  /* if ( form_ptr == FP_MGR ) */

 if ( form_ptr == FP_MV )
 {
   switch ( gadget_label )
   {
     case VD_SEL_VOL_FROM_LIST :
     {
	int			num_vvol_sel = 0;
	struct GRid		*vvol_ids = NULL;
	struct GRmd_env		*vvol_envs = NULL;
	char			**names = NULL;
	char			**desc = NULL;


	FIg_disable ( FP_MV , FI_ACCEPT );
	FIg_disable ( FP_MV , FI_EXECUTE );
	FIg_disable ( FP_MV , FI_CANCEL );

	sts1 = VDdispVVform (   &msg, ( IGRboolean ) FALSE,
				&num_vvol_sel, &vvol_ids, &vvol_envs,
				&names, &desc );
	__DBGpr_objlist( "sel vvol ids", vvol_ids, num_vvol_sel );
#ifdef VDS_DBG
	for(ii=0; ii<num_vvol_sel; ii++)
	  printf("vvol_name[%d] = [%s]\n", ii, names[ii]);
#endif

	sts1 = om$send ( msg = message VDCmdMngMV.set_instance_dimension(
				me->num_vvol+num_vvol_sel, me->num_qry ),
			 targetid = my_id );

	for(ii=0; ii<num_vvol_sel; ii++)
	{
	   sts1 = om$send ( msg = message VDCmdMngMV.add_to_vv_qry_list(
				VD_VVOL, &vvol_ids[ii], &vvol_envs[ii],
				names[ii], desc[ii] ),
			 targetid = my_id );
	}

	sts1 = om$send ( msg = message VDCmdMngMV.set_crt_mdf_list_fld
					( &msg ),
			 targetid = my_id );
	FIg_enable ( FP_MV , FI_ACCEPT );
	FIg_enable ( FP_MV , FI_EXECUTE );
	FIg_enable ( FP_MV , FI_CANCEL );

/* FREE_VVOL_MEMORY: */
	if ( vvol_ids ) free ( vvol_ids );
	if ( vvol_envs ) free ( vvol_envs );
	if ( names )  VDfree_str_list ( names, num_vvol_sel );
	if ( desc )  VDfree_str_list ( desc, num_vvol_sel );
	break;
     }

     case VD_SEL_QRY_FROM_LIST :
     {
	int			num_qry_sel = 0;
	struct GRid		*qry_ids = NULL;
	struct GRmd_env		*qry_envs = NULL;
	char			**names = NULL;
	char			**desc = NULL;

	FIg_disable ( FP_MV , FI_ACCEPT );
	FIg_disable ( FP_MV , FI_EXECUTE );
	FIg_disable ( FP_MV , FI_CANCEL );
	sts1 = VDdispQryForm     ( &msg, &num_qry_sel, &qry_ids, &qry_envs,
				   &names, &desc );
	__DBGpr_objlist( "sel qry ids", qry_ids, num_qry_sel );
#ifdef VDS_DBG
	for(ii=0; ii<num_qry_sel; ii++)
	  printf("qry_name[%d] = [%s]\n", ii, names[ii]);
#endif

	sts1 = om$send ( msg = message VDCmdMngMV.set_instance_dimension(
				me->num_vvol, me->num_qry + num_qry_sel ),
			 targetid = my_id );

	for(ii=0; ii<num_qry_sel; ii++)
	{
	   sts1 = om$send ( msg = message VDCmdMngMV.add_to_vv_qry_list(
				VD_QRY, &qry_ids[ii], &qry_envs[ii],
				names[ii], desc[ii] ),
			 targetid = my_id );
	}

	sts1 = om$send ( msg = message VDCmdMngMV.set_crt_mdf_list_fld
					( &msg ),
			 targetid = my_id );
	FIg_enable ( FP_MV , FI_ACCEPT );
	FIg_enable ( FP_MV , FI_EXECUTE );
	FIg_enable ( FP_MV , FI_CANCEL );

/* FREE_QRY_MEMORY: */
	if ( qry_ids ) free ( qry_ids );
	if ( qry_envs ) free ( qry_envs );
	if ( names )  VDfree_str_list ( names, num_qry_sel );
	if ( desc )  VDfree_str_list ( desc, num_qry_sel );
	break;
     }

     case VD_LOC_SOL_FLD :
	FIg_disable ( FP_MV, FI_ACCEPT );
	FIg_disable ( FP_MV, FI_EXECUTE );
	FIg_disable ( FP_MV, FI_CANCEL );
	_put_response ( resp = VD_LOC_SOLID_ST );
	break;

     case VD_QRY_RMV_FLD :
	/* do it in reverse order */
	for(ii = me->num_qry -1; ii >= 0; ii--)
	{
	    FIfld_get_select ( FP_MV, VD_QRY_LIST_FLD, ii, 0, &sel_flag);
	    if ( sel_flag )
	    {
		sts1 =
		om$send ( msg = message VDCmdMngMV.delete_from_vv_qry_list(
						VD_QRY, ii ),
			  targetid = my_id );
	    }
	}
	sts1 = om$send ( msg = message VDCmdMngMV.set_crt_mdf_list_fld
					( &msg ),
			 targetid = my_id );
	break;

     case VD_VV_RMV_FLD :
	for(ii = me->num_vvol-1; ii >= 0; ii--)
	{
	    FIfld_get_select ( FP_MV, VD_VV_LIST_FLD, ii, 0, &sel_flag);
	    if ( sel_flag )
	    {
		sts1 = 
		om$send ( msg = message VDCmdMngMV.delete_from_vv_qry_list(
						VD_VVOL, ii ),
			  targetid = my_id );
	    }
	}
	sts1 = om$send ( msg = message VDCmdMngMV.set_crt_mdf_list_fld
					( &msg ),
			 targetid = my_id );
	break;

     case VD_MV_CRT_HLT_FLD :
	{

	   if ( me->num_vvol == 0 )
	   {
	     FIg_set_text( FP_MV, FI_MSG_FIELD,
					"At least one view volume needed" );
	     break;
	   }

	   sts1 = ex$message (	field  = ERROR_FIELD,
				justification = CENTER_JUS,
				in_buff = "Processing ..."   );
	   FIg_set_text ( FP_MV, FI_MSG_FIELD,
				"Locating objects without solid boolean" );

	   static_num_obj = 0;
	   if ( stat_obj_list )
		{ free ( stat_obj_list ); stat_obj_list = NULL; }
	   sts1 =  VDgetMdlvwObjects (  &msg,
					me->num_vvol,
					me->vvol_ids,
					me->vvol_envs,
					me->num_qry,
					me->qry_ids,
					VD_EL_INSIDE,
					&static_num_obj,
					&stat_obj_list );
	   VDS_ERR_HNDLR ( "VDgetMdlvwObjects", sts1, msg,
						VD_VERBOSE, VD_ERROR2 );
	   dpmode = GRhd;
	   for(jj=0; jj<static_num_obj; jj++)
		sts1 = om$send ( msg = message GRgraphics.GRdisplay (
				&msg,
				&(stat_obj_list[jj].mod_env.md_env.matrix_type),
				stat_obj_list[jj].mod_env.md_env.matrix,
				&dpmode,
				&me->ModuleInfo.md_id ),
			 targetid = stat_obj_list[jj].obj_id.objid,
			 targetos = stat_obj_list[jj].obj_id.osnum );
	}
VD_ERROR2:
	break;

      case VD_MV_CRT_DRW_FLD:
	   dpmode = GRbdhe;
	   for(jj=0; jj<static_num_obj; jj++)
		sts1 = om$send ( msg = message GRgraphics.GRdisplay (
				&msg,
				&(stat_obj_list[jj].mod_env.md_env.matrix_type),
				stat_obj_list[jj].mod_env.md_env.matrix,
				&dpmode,
				&me->ModuleInfo.md_id ),
			 targetid = stat_obj_list[jj].obj_id.objid,
			 targetos = stat_obj_list[jj].obj_id.osnum );
	   static_num_obj = 0;
	   if ( stat_obj_list )
		{ free ( stat_obj_list ); stat_obj_list = NULL; }
	   break;

     case FI_EXECUTE:
     case FI_ACCEPT:
	if ( form_state == VD_CRT_MV_ST )
	{
	   char  name_found;
	   char  mv_name[VD_MAX_MV_NAME_LEN],
		 mv_desc[VD_MAX_MV_DESC_LEN];

	   FIg_get_text ( FP_MV, VD_MV_NAME_FLD, mv_name );
	   __DBGpr_str ( "mv name", mv_name );

	   /*  make sure that user keyed in a name  */
	   if ( !strcmp(mv_name, "") )
	   {
	     FIg_set_text ( FP_MV, FI_MSG_FIELD, "Please key in name" );
	     break;
	   }
	   FIg_get_text ( FP_MV, VD_MV_DESC_FLD, mv_desc );
	   __DBGpr_str ( "mv desc", mv_desc );

	   /* make sure at least one view volume has been selected  */
	   if ( me->num_vvol == 0 )
	   {
	      FIg_set_text ( form_ptr, FI_MSG_FIELD,
			"Select at least one view volume" );
	      break;
	   }

	   /* make sure name is unique */
	   name_found = FALSE;
	   for (ii=0; ii<me->num_mdlvw; ii++)
	   {
	      if ( !strcmp( mv_name, me->mdlvw_names[ii] ) )
	      {
		name_found = TRUE;
		break;
	      }
	   }
	   if ( name_found )
	   {
		FIg_set_text( form_ptr, FI_MSG_FIELD, 
				"Model View Name is already in Use" );
		break;
	   }

	   sts1 = VDconstruct_mdlview (  &msg,
					 mv_name,
					 mv_desc,
					 me->num_vvol,
					 me->vvol_ids,
					 me->vvol_envs,
					 me->num_qry,
					 me->qry_ids,
					 me->qry_envs,
					 NULL );	/* mdlvw_id     */
	   VDS_ERR_RPT ( "VDconstruct_mdlview", sts1, msg, VD_VERBOSE );

	   sts1 = om$send ( msg = message VDCmdMngMV.get_mdlvw_list( &msg ),
			    targetid = my_id );

	   sts1 = om$send ( msg = message VDCmdMngMV.set_manag_form( &msg ),
			    targetid = my_id );

	   FIg_set_text ( FP_MV, VD_MV_NAME_FLD, "" );
	   FIg_set_text ( FP_MV, VD_MV_DESC_FLD, "" );

	   if ( gadget_label == FI_EXECUTE )
	   {
	     me->num_vvol = 0;
	     me->num_qry  = 0;
	     sts1 = om$send ( msg = message VDCmdMngMV.set_crt_mdf_list_fld
					( &msg ),
			      targetid = my_id );

	   }
	   else
	   {
	     FIf_erase ( FP_MV );
	     FIg_enable ( FP_MGR, FI_ACCEPT );
	     FIg_enable ( FP_MGR, VD_MV_CRT_FLD );
	     FIg_enable ( FP_MGR, VD_MV_MDF_FLD );
	     FIg_enable ( FP_MGR, VD_MV_DLT_FLD );
	     form_state = VD_MNG_MV_ST;
	   }    /* gadget_label == FI_ACCEPT */
	}       /* if ( form_state == VD_CRT_MV_ST ) */
	else if ( form_state == VD_MDF_MV_ST )
	{
	   char  name_found;
	   char  mv_name[VD_MAX_MV_NAME_LEN],
		 mv_desc[VD_MAX_MV_DESC_LEN];
	   int	 mod_nb;

	   if ( me->mdlvw_ids[me->mod_mv_nb].osnum !=
					me->ModuleInfo.md_id.osnum )
	   {
		FIg_set_text ( FP_MV, FI_MSG_FIELD,
			"MdlView from ref file, can not be modified" );
	        break;
	   }

	   FIg_get_text ( FP_MV, VD_MV_NAME_FLD, mv_name );
	   __DBGpr_str ( "mv name", mv_name );

	   /*  make sure that user keyed in a name  */
	   if ( !strcmp(mv_name, "") )
	   {
	     FIg_set_text ( FP_MV, FI_MSG_FIELD, "Please key in name" );
	     break;
	   }
	   FIg_get_text ( FP_MV, VD_MV_DESC_FLD, mv_desc );
	   __DBGpr_str ( "mv desc", mv_desc );

	   /* make sure at least one view volume has been selected  */
	   if ( me->num_vvol < 0 )
	   {
	      FIg_set_text ( form_ptr, FI_MSG_FIELD,
			"At least one view volume needs to be selected" );
	      break;
	   }

	   /* make sure name is unique */
	   name_found = FALSE;
	   for (ii=0; ii<me->num_mdlvw; ii++)
	   {
	      if ( ii == me->mod_mv_nb ) continue;
	      if ( !strcmp( mv_name, me->mdlvw_names[ii] ) )
	      {
		name_found = TRUE;
		break;
	      }
	   }
	   if ( name_found )
	   {
		FIg_set_text( form_ptr, FI_MSG_FIELD, 
				"Model View Name is already in Use" );
		break;
	   }

	   mod_nb = me->mod_mv_nb;
	   sts1 = om$send ( msg = message VDmdlview.VDmv_modify (
					 &msg,					
					 mv_name,
					 mv_desc,
					 me->num_vvol,
					 me->vvol_ids,
					 me->vvol_envs,
					 me->num_qry,
					 me->qry_ids,
					 me->qry_envs ),
			targetid = me->mdlvw_ids[mod_nb].objid,
			targetos = me->mdlvw_ids[mod_nb].osnum  );
	   VDS_ERR_RPT ( "VDmdlview.VDmv_modify", sts1, msg, VD_VERBOSE );

	   sts1 = om$send ( msg = message VDCmdMngMV.get_mdlvw_list( &msg ),
			    targetid = my_id );

	   sts1 = om$send ( msg = message VDCmdMngMV.set_manag_form( &msg ),
			    targetid = my_id );
	   FIf_erase ( FP_MV );
	   FIg_enable ( FP_MGR, FI_ACCEPT );
	   FIg_enable ( FP_MGR, VD_MV_CRT_FLD );
	   FIg_enable ( FP_MGR, VD_MV_MDF_FLD );
	   FIg_enable ( FP_MGR, VD_MV_DLT_FLD );
	   form_state = VD_MNG_MV_ST;
	}       /* if ( form_state == VD_CRT_MV_ST ) */
	me->nbVVcreated = 0; /* so that the newly created VV will not be
				deleted, when FI_CANCEL is pressed.
			     */
	break;

     case FI_CANCEL :
	FIf_erase ( FP_MV );
	FIg_enable ( FP_MGR, FI_ACCEPT );
	FIg_enable ( FP_MGR, VD_MV_CRT_FLD );
	FIg_enable ( FP_MGR, VD_MV_MDF_FLD );
	FIg_enable ( FP_MGR, VD_MV_DLT_FLD );
	form_state = VD_MNG_MV_ST;
	sts1 = om$send ( msg = message VDCmdMngMV.delete_created_vvs (
								&msg ),
			 targetid = my_id );
	break;
   } /* switch ( gadget_label ) */
 } /* if ( form_ptr == FP_MV ) */

quit:
 return OM_S_SUCCESS;
}


end implementation  VDCmdMngMV;

