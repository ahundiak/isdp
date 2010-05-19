class implementation  VDCmdMngVV;

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
#include "vdvvoldef.h"

extern  double  APu_default_to_dbase();

%safe
#include "VX_FIproto.h"
static  int form_state = VD_MNG_VOL_ST;
%endsafe

extern  OMuword  OPP_EMSsubbs_class_id;
extern  OMuword  OPP_EMSsolid_class_id;

from	NDnode	    import  NDdelete;
from    GRgraphics  import  GRdisplay;
from    VDviewvol   import  VDvv_give_solid;
from    VDviewvol   import  VDvv_display_solid;
from    VDviewvol   import  VDvv_set_name_desc;


method  form_notification (
 int	 form_label;
 int	 gadget_label;
 double	 value;
 char	 *form_ptr;
)

{
long		sts1, status, msg;
char		vol_name[VD_MAX_VOL_NAME_LEN],
		vol_desc[VD_MAX_VOL_DESC_LEN];
int		ii, sel_flag, row, pos;
enum GRdpmode	dpmode;


  FIg_set_text ( form_ptr, FI_MSG_FIELD, "" );

  switch ( gadget_label )
  {
      case VD_VVOL_CRT_FLD :
	sts1 = om$send ( msg = message VDCmdMngVV.erase_hilited_solid( &msg ),
			 targetid = my_id );

	me->solid.obj_id.objid = NULL_OBJID;
	FIg_erase ( form_ptr, VD_VVOL_MNG_GRP );
	FIg_display ( form_ptr, VD_VVOL_CRT_MDF_GRP );
	FIg_set_text ( form_ptr, VD_VVOL_VOLNAM_FLD, "" );
	FIg_set_text ( form_ptr, VD_VVOL_DESC_FLD, "");
	FIg_display ( form_ptr, VD_VVOL_CRT_TTL );
	FIg_disable  ( form_ptr, FI_ACCEPT );
	FIg_enable ( form_ptr, FI_CANCEL );
	FIg_enable ( form_ptr, FI_EXECUTE );
        FIg_set_state_off( form_ptr,VD_VVOL_CRT_FLD );
	form_state = VD_CRT_VOL_ST;
	break;

      case VD_VVOL_MDF_FLD :

	for ( ii=0; ii < me->num_vvol; ii++ )
	{
	  FIfld_get_select ( form_ptr, VD_VVOL_LIST_FLD, ii, 0, &sel_flag);
	  if ( sel_flag ) break;
	}

	if ( ii == me->num_vvol )
	   FIg_set_text ( form_ptr,FI_MSG_FIELD, "No View Volume Selected");
	else
	{
	   me->mod_vol_nb = ii;
	   me->solid.obj_id.objid = NULL_OBJID;

	   FIg_set_text ( form_ptr, VD_VVOL_VOLNAM_FLD, me->vvol_names[ii] );
	   FIg_set_text ( form_ptr, VD_VVOL_DESC_FLD, me->vvol_desc[ii] );
	   strcpy( me->mod_vol_name, me->vvol_names[ii] );
	   FIg_erase ( form_ptr, VD_VVOL_MNG_GRP );
	   FIg_display ( form_ptr, VD_VVOL_CRT_MDF_GRP );
	   FIg_display ( form_ptr, VD_VVOL_MDF_TTL );
	   FIg_disable  ( form_ptr, FI_ACCEPT );
	   FIg_enable ( form_ptr, FI_CANCEL );
	   FIg_enable ( form_ptr, FI_EXECUTE );
	   FIg_disable ( form_ptr, VD_VVOL_LOC_SOL );
	   form_state = VD_MDF_VOL_ST;
	}
        FIg_set_state_off( form_ptr,VD_VVOL_MDF_FLD );
	break;

      case VD_VVOL_DLT_FLD :
	for ( ii=0; ii < me->num_vvol; ii++ )
	{
	  FIfld_get_select ( form_ptr, VD_VVOL_LIST_FLD, ii, 0, &sel_flag);
	  if ( sel_flag ) break;
	}

	if ( ii == me->num_vvol )
	    FIg_set_text ( form_ptr, FI_MSG_FIELD,
					"No View Volume selected");
	else if( me->vvol_used[ii] )
	    FIg_set_text ( form_ptr, FI_MSG_FIELD, "View Volume is in use");
	else
	{
	    dpmode = GRbdhe;
	    sts1 = om$send( msg = message VDviewvol.VDvv_display_solid (
							&msg, &dpmode ),
			      targetid = me->vvol_ids[ii].objid,
			      targetos = me->vvol_ids[ii].osnum );
	    VDS_ERR_RPT ( "VDviewvol.VDvv_display_solid", sts1, msg, VD_VERBOSE );

	    sts1 = om$send( msg = message NDnode.NDdelete ( &me->ModuleInfo ),
			      targetid = me->vvol_ids[ii].objid,
			      targetos = me->vvol_ids[ii].osnum );
	    VDS_ERR_RPT ( "NDnode.NDdelete", sts1, 1, VD_VERBOSE );

	    sts1 = om$send ( msg = message VDCmdMngVV.get_vvol_list( &me->ret ),
			    targetid = my_id );
	    sts1 = om$send ( msg = message VDCmdMngVV.set_manag_form( &me->ret),
			    targetid = my_id );
	    sts1 = om$send ( msg = message VDCmdMngVV.highlight_solid( 0 ),
			    targetid = my_id );
	}
	break;

      case VD_VVOL_DIS_FLD :
	break;

      case VD_VVOL_LIST_FLD:
	FIfld_get_active_row ( form_ptr, VD_VVOL_LIST_FLD, &row, &pos );
	if ( row >= me->num_vvol )  break;
	if ( row == me->hilited_vol_nb )
	{
	    /* clicked on row which was selected before (now unselecting) */
	    sts1 = om$send( msg = message VDCmdMngVV.erase_hilited_solid(
							&me->ret ),
			    targetid = my_id );
	}
	else
	{
	   /* clicked on a new row */
	   if ( me->hilited_vol_nb != -1 )
		sts1 = om$send( msg = message VDCmdMngVV.erase_hilited_solid(
							&me->ret ),
			    targetid = my_id );
	    sts1 = om$send( msg = message VDCmdMngVV.highlight_solid( row ),
			    targetid = my_id );
	}
	break;
	
#if 0
        for ( ii=0; ii < me->num_vvol; ii++ )
	{
	  FIfld_get_select ( form_ptr, VD_VVOL_LIST_FLD, ii, 0, &sel_flag);
	  if ( sel_flag )
	  {
	    sts1 = om$send( msg = message VDviewvol.VDvv_give_solid (
					    &msg, &solid_id, &solid_env ),
			      targetid = me->vvol_ids[ii].objid,
			      targetos = me->vvol_ids[ii].osnum );
	    if ( msg == VD_VVOL_SOLID_DELETED )
	    {
		FIg_set_text ( form_ptr, FI_MSG_FIELD,
					 "Parent Volume has been deleted");
		continue;
	    }
	    VDS_ERR_RPT ( "VDviewvol.VDvv_give_solid", sts1, msg, VD_VERBOSE );

	    dpmode = GRhd;
	    sts1 = om$send ( msg = message GRgraphics.GRdisplay (
						&msg,
						&solid_env.md_env.matrix_type,
						solid_env.md_env.matrix,
						&dpmode,
						&me->ModuleInfo.md_id ),
			 targetid = solid_id.objid,
			 targetos = solid_id.osnum );
	  } /* if (sel_flag ) */
	  else
	  {
	    dpmode = GRbdhe;
	    sts1 = om$send( msg = message VDviewvol.VDvv_display_solid (
							&msg, &dpmode ),
			      targetid = me->vvol_ids[ii].objid,
			      targetos = me->vvol_ids[ii].osnum );
	    if ( msg == VD_VVOL_SOLID_DELETED )  continue;
	    VDS_ERR_RPT ( "VDviewvol.VDvv_give_solid", sts1, msg, VD_VERBOSE );

	  } /* else of if ( sel_flag ) */
	}   /* for ( ii=0; ii < me->num_vvol; ii++ ) */
	break;
#endif

      case VD_VVOL_LOC_SOL :
/*
	FIg_disable( form_ptr, VD_VVOL_CRT_MDF_GRP );
*/
	FIg_disable( form_ptr, FI_CANCEL );
	FIg_disable( form_ptr, FI_EXECUTE );
	_put_response ( resp = VD_LOC_SOLID );
	break;


      case VD_VVOL_VOLNAM_FLD :
	/*
	 * make sure another view volume does not exist with the same name
	 */
	FIg_get_text ( form_ptr, VD_VVOL_VOLNAM_FLD, vol_name );
	for (ii=0; ii<me->num_vvol; ii++)
	{
	    if ( !strcmp( vol_name, me->vvol_names[ii] ) )
	    {
		FIg_set_text( form_ptr, FI_MSG_FIELD, 
				"View Volume Name is already in Use" );
		break;
	    }
	}
	break;

      case FI_ACCEPT :
	_put_response ( resp = FORM_FINISHED );
	break;

      case FI_EXECUTE :
	if ( form_state == VD_CRT_VOL_ST )
	{
	   char  name_found;

	   FIg_get_text ( form_ptr, VD_VVOL_VOLNAM_FLD, vol_name );
	   __DBGpr_str ( "vol name", vol_name );

	   /*  make sure that user keyed in a name  */
	   if ( !strcmp(vol_name, "") )
	   {
	     FIg_set_text ( form_ptr, FI_MSG_FIELD, "Please key in name" );
	     break;
	   }
	   FIg_get_text ( form_ptr, VD_VVOL_DESC_FLD, vol_desc );
	   __DBGpr_str ( "vol desc", vol_desc );

	   /* make sure a solid has been located  */
	   if ( me->solid.obj_id.objid == NULL_OBJID )
	   {
	      FIg_set_text ( form_ptr, FI_MSG_FIELD, "Solid not selected" );
	      break;
	   }

	   /* make sure name is unique */
	   name_found = FALSE;
	   for (ii=0; ii<me->num_vvol; ii++)
	   {
	      if ( !strcmp( vol_name, me->vvol_names[ii] ) )
	      {
		name_found = TRUE;
		break;
	      }
	   }
	   if ( name_found )
	   {
		FIg_set_text( form_ptr, FI_MSG_FIELD, 
				"View Volume Name is already in Use" );
		break;
	   }

	   __DBGpr_obj ( "mod id", me->ModuleInfo.md_id );
	   __DBGpr_mat ( "mod mat", me->ModuleInfo.md_env.matrix );

	   sts1 = VDconstruct_viewvol (  &msg,
					 &me->solid.obj_id,
					 &me->solid.mod_env,
					 vol_name,
					 vol_desc,
					 NULL );
	   VDS_ERR_RPT ( "VDconstruct_viewvol", sts1, msg, VD_VERBOSE );
	   dpmode = GRbdhe;
	   sts1 = om$send ( msg = message GRgraphics.GRdisplay (
					&msg,
					&me->solid.mod_env.md_env.matrix_type,
					me->solid.mod_env.md_env.matrix,
					&dpmode,
					&me->ModuleInfo.md_id ),
			 targetid = me->solid.obj_id.objid,
			 targetos = me->solid.obj_id.osnum );

	   /* get latest list */
	   sts1 = om$send ( msg = message VDCmdMngVV.get_vvol_list( &me->ret ),
			    targetid = my_id );

	   me->solid.obj_id.objid = NULL_OBJID;
	   /* there is no break so that cancel is also executed */
	}       /* if ( form_state == VD_CRT_VOL_ST ) */
	else if ( form_state == VD_MDF_VOL_ST )
	{
	   char  name_found;

	   FIg_get_text ( form_ptr, VD_VVOL_VOLNAM_FLD, vol_name );
	   __DBGpr_str ( "vol name", vol_name );

	   /* make sure that user keyed in a name */
	   if ( !strcmp(vol_name, "") )
	   {
	     FIg_set_text ( form_ptr, FI_MSG_FIELD, "Please key in name" );
	     break;
	   }
	   FIg_get_text ( form_ptr, VD_VVOL_DESC_FLD, vol_desc );
	   __DBGpr_str ( "vol desc", vol_desc );

	   /* make sure name is unique */
	   name_found = FALSE;
	   for (ii=0; ii<me->num_vvol; ii++)
	   {
	      if ( ii == me->mod_vol_nb ) continue;
	      if ( !strcmp( vol_name, me->vvol_names[ii] ) )
	      {
		 name_found = TRUE;
		 break;
	      }
	   }
	   if ( name_found )
	   {
		FIg_set_text( form_ptr, FI_MSG_FIELD, 
				"Another View Volume has same name" );
		break;
	   }

	   ii = me->mod_vol_nb;
	   sts1 = om$send ( msg = message VDviewvol.VDvv_set_name_desc(
						&msg,
						vol_name,
						vol_desc  ),
			    targetid = me->vvol_ids[ii].objid,
			    targetos = me->vvol_ids[ii].osnum );
	   VDS_ERR_RPT ("VDviewvol.VDvv_set_name_desc", sts1,msg,VD_VERBOSE );
	   strcpy ( me->mod_vol_name, vol_name );
           
	}
	/* there is no break so that when excute button is pressed for
	   modify, cancel is automatically excuted
        */

      case FI_CANCEL :
	/* get latest list */
	sts1 = om$send ( msg = message VDCmdMngVV.get_vvol_list( &me->ret ),
			    targetid = my_id );
	/* set manag form */
	sts1 = om$send ( msg = message VDCmdMngVV.set_manag_form( &me->ret ),
			    targetid = my_id );
	if ( form_state == VD_CRT_VOL_ST && me->num_vvol > 0 )
	   sts1 = om$send ( msg = message VDCmdMngVV.highlight_solid ( 0 ),
			    targetid = my_id );

	if ( form_state == VD_MDF_VOL_ST )
	{
	   for ( ii=0; ii < me->num_vvol; ii++ )
	      if ( !strcmp ( me->mod_vol_name, me->vvol_names[ii] ) ) break;
	   if ( ii < me->num_vvol )
	   {
	    FIfld_set_select( FP_MGR, VD_VVOL_LIST_FLD, ii, 0, TRUE );
	    FIfld_set_select( FP_MGR, VD_VVOL_LIST_FLD, ii, 1, TRUE );
	   }
	}

	form_state = VD_MNG_VOL_ST;
	FIg_enable ( form_ptr, VD_VVOL_LOC_SOL );
	FIg_erase ( form_ptr, VD_VVOL_CRT_MDF_GRP );
	FIg_erase ( form_ptr, VD_VVOL_CRT_TTL );
	FIg_erase ( form_ptr, VD_VVOL_MDF_TTL );
	FIg_display ( form_ptr, VD_VVOL_MNG_GRP );
	FIg_enable  ( FP_MGR, FI_ACCEPT );
	FIg_disable ( FP_MGR, FI_CANCEL );
	FIg_disable ( FP_MGR, FI_EXECUTE );
	break;

  }

quit:
 return OM_S_SUCCESS;

}

/*

  Doc:  This method highlights given view vol solid.
        If solid is deleted, it displays the message on form.

*/

method highlight_solid ( int vvol_nb )
{
long		msg, sts1;
enum   GRdpmode dpmode;

  sts1 = OM_S_SUCCESS;

  if ( me->num_vvol > 0 && vvol_nb > -1 && vvol_nb < me->num_vvol )
  {
	dpmode = GRhd;
	sts1 = om$send( msg = message VDviewvol.VDvv_display_solid (
							&msg, &dpmode ),
			      targetid = me->vvol_ids[vvol_nb].objid,
			      targetos = me->vvol_ids[vvol_nb].osnum );
	FIfld_set_select( FP_MGR, VD_VVOL_LIST_FLD, vvol_nb, 0, TRUE );
	FIfld_set_select( FP_MGR, VD_VVOL_LIST_FLD, vvol_nb, 1, TRUE );
	me->hilited_vol_nb = vvol_nb;

	if ( msg == VD_VVOL_SOLID_DELETED )
	{
	  FIg_set_text ( FP_MGR, FI_MSG_FIELD,
					 "Parent Volume has been deleted");
	  goto wrapup;
	}
	VDS_ERR_RPT ( "VDviewvol.VDvv_give_solid", sts1, msg, VD_VERBOSE );
  }
  else
	me->hilited_vol_nb = -1;

wrapup:
  return sts1;

}
end implementation  VDCmdMngVV;

