class implementation VDCmdMngMV;



#include <stdio.h>
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "FI.h"
#include "asmacros.h"
#include "exmacros.h"
#include "msdef.h"
#include "msmacros.h"
#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "griomacros.h"
#include "growner.h"

#include "coparamac.h"
#include "grdpbmacros.h"

#include "igrdef.h"
#include "dpdef.h"
#include "dpmacros.h"

#include "nddef.h"
#include "ACrg_collect.h"
#include "AS_status.h"
#include "acrepdef.h"

#include "lcdef.h"
#include "lc.h"
#include "grgsmacros.h"

#include "vderrmacros.h"
#include "vdvvoldef.h"
#include "vdmdlvwdef.h"
#include "vdvvolmacros.h"
#include "vdmemmacros.h"

%safe
#include "VX_FIproto.h"
  static int x_pos = -1,y_pos = -1;
%endsafe

extern  OMuword   OPP_NDnode_class_id;

from  VDviewvol  import   VDvv_give_solid;
from  VDmdlview  import   VDmv_give_name_desc;
from  NDnode	 import   NDget_objects;
from  NDnode	 import   NDdelete;
from  GRgraphics import   GRdisplay;

/****************************************************************************/
/*	STATE TABLE AREA 						*****/
/****************************************************************************/


#define _start 0
#define _form_operations 1
#define _locate_solid 2
#define _form_oper1 3

method check_and_create_a_view_vol ( long * sts )
{
  int		  status = OM_S_SUCCESS;

long			msg, sts1;
char			vvol_solid;
int			ii, jj, num_vvol;
struct  GRid		*vvol_id_list = NULL,
			solid_id, new_vvol_id;
enum  GRdpmode		dpmode;
struct GRmd_env		solid_env,
			*vvol_envs = NULL;
char			**vvol_names = NULL,
			**vvol_desc  = NULL,
			vv_name[VD_MAX_VOL_NAME_LEN],
			vv_desc[VD_MAX_VOL_DESC_LEN],
			found;
struct GRobj_env	loc_solid;

    status = OM_S_SUCCESS;

    loc_solid.obj_id.objid  = me->event1.located_object[0].located_obj.objid;
    loc_solid.obj_id.osnum  = me->event1.located_object[0].located_obj.osnum;
    loc_solid.mod_env       = me->event1.located_object[0].module_info;

    __DBGpr_obj( "Solid object", loc_solid.obj_id );

    sts1 = vd$get_vvol_list ( msg	 = &msg,
			      num_vvol   = &num_vvol,
			      vvol_ids   = &vvol_id_list,
			      vvol_env   = &vvol_envs,
			      vvol_names = &vvol_names,
			      vvol_desc  = &vvol_desc	);

    vvol_solid = FALSE;
    for ( ii=0; ii<num_vvol; ii++)
    {
	sts1 = om$send( msg = message VDviewvol.VDvv_give_solid (
					&msg, &solid_id, &solid_env ),
			targetid = vvol_id_list[ii].objid,
			targetos = vvol_id_list[ii].osnum );
	if ( !(sts1&1) ) continue; /* the file may not be active */
	VDS_ERR_RPT ( "VDviewvol.VDvv_give_solid", sts1, msg, VD_VERBOSE );

	if ( solid_id.objid == loc_solid.obj_id.objid &&
	     solid_id.osnum == loc_solid.obj_id.osnum    )
	{
	   vvol_solid = TRUE;
	   break;
	}
    }

    if ( vvol_solid )
    {
/*
      *sts = MSFAIL;
      ex$message ( in_buff = "Located Solid is already another View Volume",
		   field   = ERROR_FIELD,
		   justification = CENTER_JUS );
*/
      sts1 = om$send ( msg = message VDCmdMngMV.set_instance_dimension(
				me->num_vvol+1, me->num_qry ),
			 targetid = my_id );

      sts1 = om$send ( msg = message VDCmdMngMV.add_to_vv_qry_list(
				VD_VVOL, &vvol_id_list[ii], &vvol_envs[ii],
				vvol_names[ii], vvol_desc[ii] ),
			 targetid = my_id );

      sts1 = om$send ( msg = message VDCmdMngMV.set_crt_mdf_list_fld
					( &msg ),
			 targetid = my_id );
      *sts = MSSUCC;
    }
    else
    {
	jj = 1;

	do
	{
	   found = FALSE;
	   sprintf( vv_name, "view_vol_%d", jj );
	   for(ii=0; ii<num_vvol; ii++)
	     if ( !strcmp(vv_name, vvol_names[ii]) )
	     {
		found = TRUE;
		break;
	     }
	   jj++;
	} while ( found );

	strcpy( vv_desc, "Generated while creating model view" );
	sts1 = VDconstruct_viewvol ( &msg,
				     &loc_solid.obj_id,
				     &loc_solid.mod_env,
				     vv_name,
				     vv_desc,
				     &new_vvol_id  );

	sts1 = om$send ( msg = message VDCmdMngMV.add_to_created_vvlist (
					new_vvol_id ),
			 targetid = my_id );

	sts1 = om$send ( msg = message VDCmdMngMV.set_instance_dimension(
				me->num_vvol+1, me->num_qry ),
			 targetid = my_id );

	sts1 = om$send ( msg = message VDCmdMngMV.add_to_vv_qry_list(
				VD_VVOL, &new_vvol_id, &me->ModuleInfo,
				vv_name, vv_desc ),
			 targetid = my_id );

	sts1 = om$send ( msg = message VDCmdMngMV.set_crt_mdf_list_fld
					( &msg ),
			 targetid = my_id );

	*sts = MSSUCC;
  }

  dpmode = GRbdhe;
  sts1 = om$send ( msg = message GRgraphics.GRdisplay (
					&msg,
					&loc_solid.mod_env.md_env.matrix_type,
					loc_solid.mod_env.md_env.matrix,
					&dpmode,
					&me->ModuleInfo.md_id ),
			targetid = loc_solid.obj_id.objid,
			targetos = loc_solid.obj_id.osnum  );

  if ( vvol_id_list ) free (vvol_id_list);
  if ( vvol_envs )  free ( vvol_envs );
  if ( vvol_names ) sts1 = vd$free_str_list (	str_list = vvol_names,
						num_str  = num_vvol );
  if ( vvol_desc ) sts1 = vd$free_str_list  (	str_list = vvol_desc,
						num_str  = num_vvol );

  goto quit;

quit:
  return OM_S_SUCCESS;
}

method get_mdlvw_list ( long * sts )
{
  int		  status = OM_S_SUCCESS;


long			msg, sts1;
struct  GRid		TmpId;
char			mdlvw_name[VD_MAX_MV_NAME_LEN],
			mdlvw_desc[VD_MAX_MV_DESC_LEN],
			mdlvw_used;
int			ii, jj, count;

int			nbMdlvw, startpos;
struct GRid		*mdlvIds = NULL;
struct GRmd_env		*mdlvEnvs = NULL, TmpEnv;
char			**mdlvNames = NULL,
			**mdlvDesc = NULL;

   status = OM_S_SUCCESS;

   sts1 = VDgetMVlist( &msg, &nbMdlvw, &mdlvIds, &mdlvEnvs, &mdlvNames, 
		       &mdlvDesc );
   VDS_ERR_HNDLR ( "VDgetMVlist", sts1, msg, VD_VERBOSE, wrapup );
   if ( nbMdlvw == 0 )
   {
     me->num_mdlvw = 0;
     goto wrapup;
   }

   me->num_mdlvw = nbMdlvw;

   if ( nbMdlvw > VD_INIT_DIM )
   {
	sts1 = om$vla_set_dimension( varray	=  me->mdlvw_ids,
				     size	=  nbMdlvw );

	sts1 = om$vla_set_dimension( varray	=  me->mdlvw_envs,
				     size	=  nbMdlvw );

	sts1 = om$vla_set_dimension( varray	=  me->mdlvw_names,
				     size	=  nbMdlvw );

	sts1 = om$vla_set_dimension( varray	=  me->mdlvw_desc,
				     size	=  nbMdlvw );

	sts1 = om$vla_set_dimension( varray	=  me->mdlvw_used,
				     size	=  nbMdlvw );
   }

   for( ii=0; ii<nbMdlvw; ii++ )
   {
	me->mdlvw_ids[ii]  = mdlvIds[ii];
	me->mdlvw_envs[ii] = mdlvEnvs[ii];

	if ( mdlvIds[ii].osnum == me->MdlvwMgr.osnum )
	{
	   strcpy( me->mdlvw_names[ii], mdlvNames[ii] );
	   count = 0;
	   sts1 = om$send ( msg = message NDnode.NDget_objects (
						ND_CHILDREN,
						NULL,
						0,
						NULL,
						0,
						OM_K_MAXINT,
						&count ),
			 targetid = mdlvIds[ii].objid,
			 targetos = mdlvIds[ii].osnum );
		VDS_ERR_CONTINUE("NDnode.NDget_objects", sts1, 1, VD_VERBOSE);
		if ( count > 0 ) me->mdlvw_used[ii] = TRUE;
	}
	else
	{
	   startpos = strlen ( mdlvNames[ii] );
	   if ( startpos + 5  >  VD_MAX_MV_NAME_LEN - 1 )
			startpos = VD_MAX_MV_NAME_LEN - 6;
	   strcpy( me->mdlvw_names[ii], mdlvNames[ii] );
	   strcat( &(me->mdlvw_names[ii][startpos]), "[ref]");
	   me->mdlvw_used[ii] = FALSE;
	}
	strcpy( me->mdlvw_desc[ii],  mdlvDesc[ii] );
   }

   /*
    * sort model views by name
    */
   for( ii=0; ii< me->num_mdlvw-1; ii++ )
      for ( jj=ii+1;  jj< me->num_mdlvw; jj++ )
	  if ( strcmp( me->mdlvw_names[ii], me->mdlvw_names[jj]) > 0 )
	  {
	     strcpy ( mdlvw_name, me->mdlvw_names[ii] );
	     strcpy ( mdlvw_desc, me->mdlvw_desc[ii] );
	     TmpId = me->mdlvw_ids[ii];
	     TmpEnv = me->mdlvw_envs[ii];
	     mdlvw_used = me->mdlvw_used[ii];

	     strcpy ( me->mdlvw_names[ii], me->mdlvw_names[jj] );
	     strcpy ( me->mdlvw_desc[ii], me->mdlvw_desc[jj] );
	     me->mdlvw_ids[ii] = me->mdlvw_ids[jj];
	     me->mdlvw_envs[ii] = me->mdlvw_envs[jj];
	     me->mdlvw_used[ii] = me->mdlvw_used[jj];

	     strcpy ( me->mdlvw_names[jj], mdlvw_name );
	     strcpy ( me->mdlvw_desc[jj], mdlvw_desc );
	     me->mdlvw_ids[jj] = TmpId;
	     me->mdlvw_envs[jj] = TmpEnv;
	     me->mdlvw_used[jj] = mdlvw_used;
	  } /* if strcmp( */


wrapup:
   if ( mdlvIds )  free ( mdlvIds );
   if ( mdlvEnvs ) free ( mdlvEnvs );
   if ( mdlvNames ) sts1 = vd$free_str_list (	str_list = mdlvNames,
						num_str  = nbMdlvw   );
   if ( mdlvDesc )  sts1 = vd$free_str_list ( 	str_list = mdlvDesc,
						num_str  = nbMdlvw  );
   goto quit;

quit:
  return OM_S_SUCCESS;
}

method set_manag_form ( long * sts )
{
  int		  status = OM_S_SUCCESS;

int ii;


   /*
    *  sets list on the form.
    *  unselects last row.
    *  select and display is done by highlight_solid.
    */

   status = OM_S_SUCCESS;

   *sts = MSSUCC;

   FIfld_set_max_num_rows( FP_MGR, VD_MV_LIST_FLD, me->num_mdlvw );
   FIfld_set_num_rows ( FP_MGR, VD_MV_LIST_FLD, me->num_mdlvw );

   for ( ii=0; ii<me->num_mdlvw; ii++)
   {
     FIfld_set_text( FP_MGR, VD_MV_LIST_FLD, ii, 0, me->mdlvw_names[ii], FALSE);
     FIfld_set_text( FP_MGR, VD_MV_LIST_FLD, ii, 1, me->mdlvw_desc[ii], FALSE );
     if ( me->mdlvw_used[ii] )
	FIfld_set_text ( FP_MGR, VD_MV_LIST_FLD, ii, 2, "y", FALSE );
     else
	FIfld_set_text ( FP_MGR, VD_MV_LIST_FLD, ii, 2, "", FALSE );
   }

   if ( me->num_mdlvw > 0 )
   {
      FIfld_set_select( FP_MGR, VD_MV_LIST_FLD, me->num_mdlvw-1, 0, FALSE );
      FIfld_set_select( FP_MGR, VD_MV_LIST_FLD, me->num_mdlvw-1, 1, FALSE );
   }


   goto quit;

quit:
  return OM_S_SUCCESS;
}

method clean_up ( long * sts )
{
  int		  status = OM_S_SUCCESS;

OMuint		  	num_mdlvw;
OM_S_CHANSELECT	  	to_components;

   status = om$make_chanselect (  channame = "GRcmpowner.to_components",
				  p_chanselect = &to_components );

   status = om$get_channel_count( objid		=   me->MdlvwMgr.objid,
				osnum		=   me->MdlvwMgr.osnum,
				p_chanselect	=   &to_components,
				count		=   &num_mdlvw );
   __DBGpr_int( "No. of model views", num_mdlvw );

   if ( !num_mdlvw )
   {
	status = om$send ( msg = message Root.delete (0),
			 targetid = me->MdlvwMgr.objid,
			 targetos = me->MdlvwMgr.osnum  );
   }

   goto quit;

quit:
  return OM_S_SUCCESS;
}

method set_form_pos ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   status = OM_S_SUCCESS;

   if(x_pos != -1 && y_pos != -1)
   {
	FIf_set_location ( me->forms[0].form_ptr, x_pos, y_pos );
	FIf_set_location ( me->forms[1].form_ptr, x_pos, y_pos );
   }

  *sts = MSSUCC;

  goto quit;

quit:
  return OM_S_SUCCESS;
}

method save_form_pos ( long * sts )
{
  int		  status = OM_S_SUCCESS;


  status = OM_S_SUCCESS;

  FIf_get_location(me->forms[0].form_ptr,&x_pos,&y_pos);

  *sts = MSSUCC;

  goto quit;

quit:
  return OM_S_SUCCESS;
}

method create_mv_mgr_if_not_created ( long * sts )
{
  int		  status = OM_S_SUCCESS;


     status = VDget_mdlvw_mgr ( NULL, &me->MdlvwMgr );

     if ( !(status&1) )  status = VDcrt_mdlvw_mgr();

     status = VDget_mdlvw_mgr ( NULL, &me->MdlvwMgr );

     goto quit;

quit:
  return OM_S_SUCCESS;
}

method init_instance ( long * sts )
{
  int		  status = OM_S_SUCCESS;


#if 0
  struct GRlc_locate	loc_attributes;

  strcpy( loc_attributes.classes, "GRgraphics" );

  /*
   * locate attributes of copy command
   */
  loc_attributes.properties = LC_RW | LC_LC_ONLY | LC_DP_ONLY;
  loc_attributes.owner_action = LC_READ | LC_REF_OBJECTS;

  sts = gr$gsput_locate_criteria ( msg = &msg,
				   attributes = &loc_attributes );
#endif

  status = OM_S_SUCCESS;

  me->hilited_mv_nb = -1;
  me->num_vvol = 0;
  me->num_qry = 0;

  me->nbVVcreated = 0;
  me->last_sel_mdlv = -1;

  goto quit;

quit:
  return OM_S_SUCCESS;
}

method set_instance_dimension ( int  nb_vvol;  int  nb_qry )
{
  int		  status = OM_S_SUCCESS;

long	sts;

   status = OM_S_SUCCESS;

   if ( nb_vvol > VD_INIT_DIM )
   {
	sts = om$vla_set_dimension ( varray	= me->vvol_ids,
				     size	= nb_vvol  );

	sts = om$vla_set_dimension ( varray	= me->vvol_envs,
				     size	= nb_vvol  );

	sts = om$vla_set_dimension ( varray	= me->vvol_names,
				     size	= nb_vvol  );

	sts = om$vla_set_dimension ( varray	= me->vvol_desc,
				     size	= nb_vvol  );

   }

   if ( nb_qry > VD_INIT_DIM )
   {
	sts = om$vla_set_dimension ( varray	= me->qry_ids,
				     size	= nb_qry  );

	sts = om$vla_set_dimension ( varray	= me->qry_envs,
				     size	= nb_qry  );

	sts = om$vla_set_dimension ( varray	= me->qry_names,
				     size	= nb_qry  );

	sts = om$vla_set_dimension ( varray	= me->qry_desc,
				     size	= nb_qry  );

   }

   goto quit;

quit:
  return OM_S_SUCCESS;
}

method copy_to_instance (
 int		 num_vvol;
 struct GRid	 *vvol_ids;
 struct GRmd_env *vvol_envs;
 char		 **vvol_names;
 char		 **vvol_desc;
 int		 num_qry;
 struct GRid	 *qry_ids;
 struct GRmd_env *qry_envs;
 char		 **qry_names;
 char		 **qry_desc;
)
{
  int		  status = OM_S_SUCCESS;

int	ii;

 status = OM_S_SUCCESS;

 me->num_vvol = num_vvol;
 for(ii=0; ii<num_vvol; ii++)
 {
    if ( vvol_ids ) me->vvol_ids[ii] = vvol_ids[ii];
    if ( vvol_envs ) me->vvol_envs[ii] = vvol_envs[ii];
    if ( vvol_names )  strcpy( me->vvol_names[ii], vvol_names[ii] );
    if ( vvol_desc )  strcpy( me->vvol_desc[ii], vvol_desc[ii] );
 }

 me->num_qry = num_qry;
 for(ii=0; ii<num_qry; ii++)
 {
    if ( qry_ids ) me->qry_ids[ii] = qry_ids[ii];
    if ( qry_envs ) me->qry_envs[ii] = qry_envs[ii];
    if ( qry_names )  strcpy( me->qry_names[ii], qry_names[ii] );
    if ( qry_desc )  strcpy( me->qry_desc[ii], qry_desc[ii] );
 }

 goto quit;

quit:
  return OM_S_SUCCESS;
}

method set_crt_mdf_list_fld ( long * sts )
{
  int		  status = OM_S_SUCCESS;

int  ii;
char filename[15];


	status = OM_S_SUCCESS;

	FIfld_set_max_num_rows ( FP_MV, VD_VV_LIST_FLD,	me->num_vvol );
	FIfld_set_num_rows ( FP_MV, VD_VV_LIST_FLD, me->num_vvol );
	FIfld_set_max_num_rows ( FP_MV, VD_QRY_LIST_FLD, me->num_qry );
	FIfld_set_num_rows ( FP_MV, VD_QRY_LIST_FLD, me->num_qry );

	for(ii=0; ii<me->num_vvol; ii++)
	{
	  FIfld_set_text( FP_MV, VD_VV_LIST_FLD, ii, 0,
						me->vvol_names[ii], FALSE );
	  FIfld_set_text( FP_MV, VD_VV_LIST_FLD, ii, 1,
						me->vvol_desc[ii], FALSE );
	  FIfld_set_select( FP_MV, VD_VV_LIST_FLD, ii, 0, FALSE );
	  FIfld_set_select( FP_MV, VD_VV_LIST_FLD, ii, 1, FALSE );

	  status = VDget_filename_from_os ( me->vvol_ids[ii].osnum,
					    filename );
	  if ( !(status&1) ) continue;
	  FIfld_set_text( FP_MV, VD_VV_LIST_FLD, ii, 2, filename, FALSE );
	  FIfld_set_select( FP_MV, VD_VV_LIST_FLD, ii, 2, FALSE );
	}

 	for(ii=0; ii<me->num_qry; ii++)
	{
	  FIfld_set_text( FP_MV, VD_QRY_LIST_FLD, ii, 0,
						me->qry_names[ii], FALSE );
	  FIfld_set_text( FP_MV, VD_QRY_LIST_FLD, ii, 1,
						me->qry_desc[ii], FALSE );
	  FIfld_set_select( FP_MV, VD_QRY_LIST_FLD, ii, 0, FALSE );
	  FIfld_set_select( FP_MV, VD_QRY_LIST_FLD, ii, 1, FALSE );

	  status = VDget_filename_from_os ( me->qry_ids[ii].osnum,
					    filename );
	  if ( !(status&1) ) continue;
	  FIfld_set_text( FP_MV, VD_QRY_LIST_FLD, ii, 2, filename, FALSE );
	  FIfld_set_select( FP_MV, VD_QRY_LIST_FLD, ii, 2, FALSE );
	}

	goto quit;

quit:
  return OM_S_SUCCESS;
}

method add_to_vv_qry_list (
 char		 vv_qry_flag;
 struct GRid	 *objid;
 struct GRmd_env *objenv;
 char		 *name;
 char		 *desc
)
{
  int		  status = OM_S_SUCCESS;

int ii;

 status = OM_S_SUCCESS;

 if ( vv_qry_flag == VD_VVOL )
 {
    /* check if vvol to be added is already in the list */
    if ( !objid )
    {
	/* can not check if already in list */
	goto quit;
    }

    for(ii=0; ii<me->num_vvol; ii++)
    {
       if ( objid->objid == me->vvol_ids[ii].objid &&
	    objid->osnum == me->vvol_ids[ii].osnum    )  goto quit;
    }

    status = om$send ( msg = message VDCmdMngMV.set_instance_dimension (
					me->num_vvol+1, me->num_qry ),
		       targetid = my_id );

    if ( objid )  me->vvol_ids[me->num_vvol] = *objid;
    if ( objenv )  me->vvol_envs[me->num_vvol] = *objenv;
    if ( name )  strcpy( me->vvol_names[me->num_vvol], name );
    if ( desc )  strcpy( me->vvol_desc[me->num_vvol], desc );
    (me->num_vvol)++;
 }
 else
 {
    /* check if qry to be added is already in the list */
    if ( !objid )
    {
	/* can not check if already in list */
	goto quit;
    }

    for(ii=0; ii<me->num_qry; ii++)
    {
       if ( objid->objid == me->qry_ids[ii].objid &&
	    objid->osnum == me->qry_ids[ii].osnum    )  goto quit;
    }

    status = om$send ( msg = message VDCmdMngMV.set_instance_dimension (
					me->num_vvol, me->num_qry+1 ),
		       targetid = my_id );

    if ( objid )  me->qry_ids[me->num_qry] = *objid;
    if ( objenv )  me->qry_envs[me->num_qry] = *objenv;
    if ( name )  strcpy( me->qry_names[me->num_qry], name );
    if ( desc )  strcpy( me->qry_desc[me->num_qry], desc );
    (me->num_qry)++;
 }

 goto quit;

quit:
  return OM_S_SUCCESS;
}

method delete_from_vv_qry_list (
 char		 vv_qry_flag;
 int		 vv_qry_ind;
)
{
  int		  status = OM_S_SUCCESS;

int	ii;


  status = OM_S_SUCCESS;

  if ( vv_qry_flag == VD_VVOL )
  {
     if ( vv_qry_ind < 0 || vv_qry_ind >= me->num_vvol ) goto quit;
     for( ii = vv_qry_ind; ii<me->num_vvol-1; ii++ )
     {
	me->vvol_ids[ii] = me->vvol_ids[ii+1];
	me->vvol_envs[ii] = me->vvol_envs[ii+1];
	strcpy( me->vvol_names[ii], me->vvol_names[ii+1] );
	strcpy( me->vvol_desc[ii], me->vvol_desc[ii+1] );
     }
     (me->num_vvol)--;
  }
  else
  {
     if ( vv_qry_ind < 0 || vv_qry_ind >= me->num_qry ) goto quit;
     for( ii = vv_qry_ind; ii<me->num_qry-1; ii++)
     {
	me->qry_ids[ii] = me->qry_ids[ii+1];
	me->qry_envs[ii] = me->qry_envs[ii+1];
	strcpy( me->qry_names[ii], me->qry_names[ii+1] );
	strcpy( me->qry_desc[ii], me->qry_desc[ii+1] );
     }
     (me->num_qry)--;
  }

  goto quit;

quit:
  return OM_S_SUCCESS;
}

method enable_crt_gadgets ( long * sts )
{
  int		  status = OM_S_SUCCESS;


   status = OM_S_SUCCESS;

   FIg_enable ( FP_MV, FI_ACCEPT );
   FIg_enable ( FP_MV, FI_CANCEL );
   FIg_enable ( FP_MV, FI_EXECUTE );

   goto quit;

quit:
  return OM_S_SUCCESS;
}

method add_to_created_vvlist ( struct GRid new_vvol )
{
  int		  status = OM_S_SUCCESS;

long   sts;

   status = OM_S_SUCCESS;

   me->nbVVcreated += 1;

   sts = om$vla_set_dimension ( varray	= me->createdVVlist,
			        size	= me->nbVVcreated  );

   me->createdVVlist[me->nbVVcreated-1] = new_vvol;

   goto quit;

quit:
  return OM_S_SUCCESS;
}

method delete_created_vvs ( long * sts )
{
  int		  status = OM_S_SUCCESS;

long  sts1;
int   ii;

  status = OM_S_SUCCESS;

  for(ii=0; ii<me->nbVVcreated; ii++)
  {
     sts1 = om$send ( msg = message NDnode.NDdelete ( &me->ModuleInfo ),
		      targetid = me->createdVVlist[ii].objid,
		      targetos = me->createdVVlist[ii].osnum   );
     VDS_ERR_CONTINUE ( "NDnode.NDdelete", sts1, 1, VD_VERBOSE );
  }

  me->nbVVcreated = 0;

  goto quit;

quit:
  return OM_S_SUCCESS;
}

end implementation VDCmdMngMV;
