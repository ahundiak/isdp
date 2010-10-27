/* $Id: VDCmdDtMsgs.I,v 1.1.1.1 2001/01/04 21:08:36 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vddetail/cmd / VDCmdDtMsgs.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdDtMsgs.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:36  cvs
 *	Initial import to CVS
 *	
# Revision 1.2  2000/03/07  16:06:30  pinnacle
# TR179901164 b ylong
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.2  1996/08/27  18:13:10  pinnacle
# TR179601991
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.12  1996/06/21  13:46:22  pinnacle
# Replaced: vddetail/cmd/VDCmdDtMsgs.I for:  by apazhani for vds.240
#
# Revision 1.11  1996/02/05  06:50:56  pinnacle
# Replaced: vddetail/cmd/VDCmdDtMsgs.I for:  by rgade for vds.240
#
# Revision 1.10  1995/09/11  17:21:04  pinnacle
# Replaced: vddetail/cmd/VDCmdDtMsgs.I for:  by msbraju for vds.240
#
# Revision 1.8  1995/08/28  21:40:40  pinnacle
# Replaced: ./vddetail/cmd/VDCmdDtMsgs.I for:  by azuurhou for vds.240
#
# Revision 1.7  1995/08/04  12:42:14  pinnacle
# Replaced: vddetail/cmd/VDCmdDtMsgs.I for:  by msbraju for vds.240
#
# Revision 1.6  1995/03/22  14:53:40  pinnacle
# Replaced: vddetail/cmd/VDCmdDtMsgs.I by azuurhou
# 
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/11  22:42:50  pinnacle
# updated files
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *      08/27/96        ah              TR179601991
 *	03/07/00	ylong		TR179901164
 *
 * -------------------------------------------------------------------*/

/*
        File    VDCmdDtMsgs.I
        Auteur  Ad Zuurhout
        Date    01-Januari-1992

        Description:
		Method for the form interface with the user.

		- VDdet_init.
		- sleep.
		- wakeup.
		- get_object_environment
		- object_disconnect
		- clear_objects
		- VDdet_display_located
		- VDdet_erase_hilite
		- status_disp
		
        History:
                Creation Date 01-01-92
*/
class implementation VDCmdDetail;

#include <stdio.h>
#include <string.h>
%safe
#include <math.h>
%endsafe

#include "OMerrordef.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "go.h"
#include "growner.h"
#include "execmsg.h"
#include "grmessage.h"
#include "referr.h"
#include "grerr.h"
#include "igrdef.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "exdef.h"
#include "exmacros.h"
#include "grgsdef.h"
#include "grgsmacros.h"
#include "msdef.h"
#include "msmacros.h"
#include "toolco.h"
#include "detailcodef.h"
#include "detailco.h"
#include "AS_status.h"
#include "lcmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "VDdetail.h"
#include "VDmsg.h"
#include "v_miscmacros.h"
#include "vderrmacros.h"

#include "coparamac.h"			/* as$start_fence */

/* include/prototypes */

#define  VD_CHANGE_ZDEPTHS  1

/**
  #include "VDpr_detail.h"
 **/

/* external functions */
from	GRgraphics	import GRdisplay;
from	NDnode		import ASreturn_go;
from	GRgraphics	import GRchgprops;
from	GRgraphics	import GRdelete;
from    GRgraphics	import GRgetrang;
from    GRlinear	import GRgetpolyline;

extern			GRgspass();


/* ********************************************************** */
method VDdet_init ( long * sts )
/* ********************************************************** */
{
/*
 * This method the initialisation of the instance data.
 */
IGRint	i;
GRobjid	cur_id;


  *sts = MSSUCC;
  /*| init object values */
  me->VDdet_obj_env.obj_id.objid	= NULL_OBJID;
  me->VDdet_obj_env.obj_id.osnum	= OM_Gw_current_OS;
  me->VDdet_rev_normal			= 0 ;

  /* get current module environment */
  ex$get_cur_mod( id = &cur_id, osnum = &me->VDcur_os );

  me->VDdet_gragad.objid	= NULL_OBJID;
  me->VDdet_win_id.objid	= NULL_OBJID;
  me->VDdet_gragad.osnum	= me->VDcur_os;
  me->VDdet_win_id.osnum	= me->VDcur_os;
  me->VDdet_obj_name[0]		= '\0';
  me->VDdet_ref_name[0]		= '\0';

  for( i=0; i<15; i++ )		me->VDdet_matrix[i] = 0;

  /* set all levels active */
  for( i=0; i<32; i++) me->VDdet_levels[i] = 0xffffffff;

  /* reference file table and count */
  me->VDdet_refer_cnt 		= 0;
  me->VDdet_space_cnt 		= 0;
  me->VDdet_refer		= NULL;
  me->VDdet_space		= NULL;
  me->VDdet_win_name[0]		= '\0';

  /* set the form information */
  me->VDdet_form_display	= FALSE;
  me->form_requested		= 0;

  /*| initialisation data structure */
  me->fd_data.flag			= FALSE;
  strcpy(me->fd_data.text_scale, VD_DET_DEF_SCALE );
  strcpy(me->fd_data.layer_str, VD_DET_DEF_LAYER );
  me->fd_data.name[0]			= '\0';
  me->fd_data.orient_name[0]		= '\0';
  me->fd_data.volume_name[0]		= '\0';
  me->fd_data.name_desc[0]		= '\0';
  me->fd_data.z_depth[0]		= -10.0;
  me->fd_data.z_depth[1]		= 10.0;
  me->fd_data.usr_z_depth[0]		= -100.0;
  me->fd_data.usr_z_depth[1]		= 100.0;
 
  for(i=0;i<6;i++){
    me->fd_data.vw_volume[i]		= 0.0;
    me->fd_data.dep_volume[i] 		= 0.0;
  }
  for(i=0;i<3;i++){
    me->fd_data.x_vec[i] 		= 0.0;
    me->fd_data.y_vec[i] 		= 0.0;
    me->fd_data.z_vec[i] 		= 0.0;
    me->fd_data.origin[i] 		= 0.0;
    me->VDvec_origin[i] 		= 0.0;
  }
  me->fd_data.toggle			= 0;
  me->fd_data.vol_toggle		= VD_DET_EXTENDED;

  me->fd_data.offset_toggle		= 0;
  me->fd_data.offset_value		= 0.0;

  me->tmpList[VD_Obj_boxId].objid	= NULL_OBJID;
  me->tmpList[VD_Obj_csId].objid	= NULL_OBJID;
  me->tmpList[VD_Obj_arrId].objid	= NULL_OBJID;

/* 
 * TR179601991
 */
  me->m_OldBoxId.objid = NULL_OBJID;
  me->m_OldArrId.objid = NULL_OBJID;
  me->m_OldCsId.objid = NULL_OBJID;

  me->m_UpdateBox = FALSE;
  me->m_UpdateArr = FALSE;
  me->m_UpdateCs  = FALSE;

return( OM_S_SUCCESS );
}

/* ********************************************************** */
method sleep ( int pos )
/* ********************************************************** */
{
int		i, status = OM_S_SUCCESS;
long		sts;
IGRshort	action, props;

  SetProc( VDCmdDetail_sleep ); Begin

  /*
   * look if GRID_ON and GRID_LOCK are still active.
   */
  status =
  _VD_SEND_MY( VDCmdDetail.reset_grid_flags( &sts ));
  as$status( action = RET_STATUS );

  status =
  _VD_SEND_WRT_M( my_id, CEO_LOCATE.sleep(pos));
  as$status(action = RET_STATUS);

  dp$erase_hilite(msg = &sts);

  if( me->VDdet_form_display ){
    if( me->status_display_form_ptr ){
      status = FIf_erase( me->status_display_form_ptr);
      if( status != FI_SUCCESS ){
        printf(" sleep : fct FIf_erase failed\n");
        return(OM_E_ABORT);
      }
    /*  me->form_requested = 0; */
    }
  }

  action = 0;
  props = GRIS_LOCATABLE;
  for( i=0 ; i<VD_Obj_Max ; i++ ){

    if ( me->tmpList[i].objid != NULL_OBJID ){

#ifdef	vdsDEBUG
	VD_ShowObj( me->tmpList +i );
#endif
	sts =
	vd_$bulk_display(	count	= 1,
				dpmode	= GRbe, /* GRbehe */
				grids	= me->tmpList +i,
				theEnv	= &me->ModuleInfo );
	/*
	 * change properties of clipping box to non_displayable, non_locatable
	 */
	status =
	_VD_SEND_OBJ(	me->tmpList[i],
			GRgraphics.GRchgprops ( &sts, &action, &props ));
        VDS_ERR_RPT ( "GRgraphics.GRchgprops", status, sts, VD_VERBOSE );
    }
  }

  UI_prompt("");
  UI_message("");
  UI_status("");

  End ;
  return(OM_S_SUCCESS);
}

/* ********************************************************** */
method wakeup ( int pos )
/* ********************************************************** */
{
int		i, status = OM_S_SUCCESS;
long		sts;
IGRshort	action, props;

/*
printf("Wakeup: %d\n",VD_Obj_Max);
*/

  status =
  _VD_SEND_WRT_M( my_id, CEO_LOCATE.wakeup(pos));
  as$status(action = RET_STATUS);

  /*| update the form if necessary */
  status =
  _VD_SEND_MY( VDCmdDetail.VDupdate_form( &sts, me->VDdet_form_display ));
  as$status();

  /*
   * Redisplay the temporary objects.
   */
  action = 1;
  props = GRIS_LOCATABLE | GRIS_DISPLAYABLE;

  for( i=0 ; i<VD_Obj_Max ; i++ ){

    if ( me->tmpList[i].objid != NULL_OBJID ){

#ifdef	vdsDEBUG
	VD_ShowObj( me->tmpList +i );
#endif
        /*
         * change properties of clipping box to displayable, locatable
         */
        status =
        _VD_SEND_OBJ(   me->tmpList[i],
                        GRgraphics.GRchgprops ( &sts, &action, &props ));
        VDS_ERR_RPT ( "GRgraphics.GRchgprops", status, sts, VD_VERBOSE );

        status =
        vd_$bulk_display(       count   = 1,
				dpmode	= GRbd,	/* GRbdhd */
                                grids   = me->tmpList +i,
                                theEnv  = &me->ModuleInfo );
    }
  }

  status = 
  _VD_SEND_MY( CEO_LOCATE.status_display_button( 1 ));
  return(OM_S_SUCCESS );
}

method  VDdet_del_tmp_obj ( long  *sts )
{
long		i, status;

  SetProc( VDCmdDetail_VDdet_del_tmp_obj ); Begin
  *sts = MSSUCC;

  for( i=0 ; i<VD_Obj_Max ; i++ ){

    if ( me->tmpList[i].objid != NULL_OBJID ){

#ifdef	vdsDEBUG
	VD_ShowObj( me->tmpList +i );
#endif
        status =
        vd_$bulk_display(       count   = 1,
                                dpmode  = GRbe, /* GRbehe */
                                grids   = me->tmpList +i,
                                theEnv  = &me->ModuleInfo );
        status =
        vd_$bulk_delete(	count   = 1,
                                grids   = me->tmpList +i,
                                theEnv  = &me->ModuleInfo );

	if( status ) me->tmpList[i].objid = NULL_OBJID ;
    }
  }
  End ;
  return OM_S_SUCCESS;
}

/* ********************************************************** */
method get_object_environment ( long * sts )
/* ********************************************************** */
{
/*
 * This method checks the selectd object and get the following information
 * of the selected object:
 *	- reference plane.
 *	- object classname and classtype.
 *	- object matrix for the drawing view.
 * The object level will be the only active level in the drawing view.
 */
int		  status = OM_S_SUCCESS;
IGRboolean	resp;
IGRlong		msg;
struct	GRid	gr_obj;
OMuword		sender_class;

  *sts = MSSUCC;
  resp = TRUE;

  gr_obj.objid = NULL_OBJID;
  gr_obj.osnum = me->VDdet_obj_env.obj_id.osnum;

  status = 
  _VD_SEND_OBJN(	me->VDdet_obj_env.obj_id,
			 NDnode.ASreturn_go( &gr_obj, NULL, NULL ));
  if(( status&1) && (gr_obj.objid != NULL_OBJID )){

    /*" found gr_obj : [%d,%d]\n", gr_obj.objid, gr_obj.osnum */
    status =
    om$get_classid(osnum = gr_obj.osnum, 
		   objid = gr_obj.objid, 
		   p_classid = &sender_class );

    if( om$is_ancestry_valid(
			subclassid	= sender_class,
			superclassname	= "GRgraphics") != OM_S_SUCCESS ){

      ex$message( msgnumb = VD_S_InvObjSel );
      as$status( action = GOTO_VALUE, value = wrapup );
    }
    me->VDdet_obj_env.obj_id.objid = gr_obj.objid;
    me->VDdet_obj_env.obj_id.osnum = gr_obj.osnum;
  }

  status =
  om$get_classid(osnum = me->VDdet_obj_env.obj_id.osnum, 
		objid = me->VDdet_obj_env.obj_id.objid, 
		p_classid = &sender_class );
  as$status();

  if( om$is_ancestry_valid(
			subclassid	= sender_class,
			superclassname	= "GRgraphics") != OM_S_SUCCESS ){

    ex$message( msgnumb = VD_S_InvObjSel );
    as$status( action = GOTO_VALUE, value = wrapup );
  }

  resp = VDdet_find_obj_matrix( &msg,	&me->VDdet_obj_env.obj_id,
					me->VDdet_matrix );
  if( ! resp ){
    printf(" get_object_environment : msg VDdet_find_obj_matrix failed\n");
    goto wrapup;
  }

  /* 
   * added for TR179901164
   */
  {
	IGRint	i ;
#ifdef DEBUG
	printf("View matrix:\n");
	for( i = 0; i < 4; i++ ) {\
		printf("\t%f, %f, %f, %f\n",    me->VDdet_matrix[4*i+0],
						me->VDdet_matrix[4*i+1],
						me->VDdet_matrix[4*i+2],
						me->VDdet_matrix[4*i+3]);
	}
#endif
	if( me->VDdet_rev_normal ) {
		for( i = 0; i < 3; i++ ) {
			me->VDdet_matrix[4+i] = - me->VDdet_matrix[4+i] ;
			me->VDdet_matrix[8+i] = - me->VDdet_matrix[8+i] ;
		}
	}
  } /* end TR179901164 */

  *sts = MSSUCC;
  return( OM_S_SUCCESS );

wrapup:
  *sts = MSFAIL;
  return( OM_S_SUCCESS );
}

/* ********************************************************** */
method object_disconnect ( long * sts )
/* ********************************************************** */
{
  int		  status = OM_S_SUCCESS;

/* 
 * This method disconnect the located_chansel to enter with an empty
 * chansel in the method COdetail.construct_drawview.
 * This is only necessay in case we have selected an object from
 * an given reference model( displayed in one of the views ).
 */
OMuint	count = 0;

  status = 
  om$get_channel_count(	objid = my_id,
			p_chanselect = & me->located_chansel,
			count = & count );
  as$status( action = GOTO_VALUE, value = wrapup );

  if( count > 0 ){
    status = 
    om$send(msg = message Root.wild_disconnect( me->located_chansel ),
	    targetid = my_id,
	    senderid = my_id );
    as$status( action = GOTO_VALUE, value = wrapup );
  }

  *sts = MSSUCC;
  return( OM_S_SUCCESS );

wrapup:
  *sts = MSFAIL;
  return( OM_S_SUCCESS );
}

/* ********************************************************** */
method clear_objects ( long * sts )
/* ********************************************************** */
{
  int		  status = OM_S_SUCCESS;

/*
 * This method removes the following temporary objects 
 *	VDdet_gragad,
 *	VDdet_win_id
 *	VDdet_obj_env.obj_id
 */
  /*" gragad : [%d,%d]\n", me->VDdet_gragad.objid, me->VDdet_gragad.osnum */
  /*" window : [%d,%d]\n", me->VDdet_win_id.objid, me->VDdet_win_id.osnum */

/*
  if( me->VDdet_gragad.objid != NULL_OBJID ){
    status =
    _VD_SEND_OBJN( me->VDdet_gragad, Root.delete ( 1 ));
    as$status();
    me->VDdet_gragad.objid = NULL_OBJID;
  }

  if( me->VDdet_win_id.objid != NULL_OBJID ){
    status =
    _VD_SEND_OBJN( me->VDdet_win_id, Root.delete ( 1 ));
    as$status();
    me->VDdet_win_id.objid = NULL_OBJID;
  }
*/

  /* empty the selected object */
  me->VDdet_obj_env.obj_id.objid = NULL_OBJID;

 /* Delete the form -TR#179600141 -Ravi */

  if( me->VDdet_form_display )
    if( me->status_display_form_ptr ){
        status = FIf_erase( me->status_display_form_ptr);
        if( status != FI_SUCCESS ){
        printf(" clear : fct FIf_erase failed\n");
        return(OM_E_ABORT);
        }
	me->VDdet_form_display = FALSE;
   	me->form_requested = 0;
      }


return( OM_S_SUCCESS );
}

/* ********************************************************** */
method VDdet_display_located ( long * sts )
/* ********************************************************** */
{
  int		  status = OM_S_SUCCESS;
/*
 * This method displays the created drawing view.
 */
OMuint	count = 0;

IGRdouble depths[6] = {0,0,0,0,0,0};
IGRdouble tmp_z1, tmp_z2;
IGRdouble new_az, scale;
char      buffer[80], units[80];

    *sts = MSSUCC;

    status = OM_S_SUCCESS;

    /* 
     * We activate the display depths of the window, based on 
     * the z-depths of the drawing view.
     */

    /*
     * get the z depths of the drawing view
     */

    if( me->fd_data.toggle & VD_DET_ZDEPTH_FLAG )
    {
        depths[2] = me->fd_data.usr_z_depth[0] ;
        depths[5] = me->fd_data.usr_z_depth[1] ;
    }
    else
    {
        depths[2] = me->fd_data.z_depth[0] ;
        depths[5] = me->fd_data.z_depth[1] ;
    }

    /*
     * get active z depth of the window
     */

    status = dp$view_vol( msg          = sts,
                          gg_id        = &(me->window_id),
                          new_active_z = &new_az );
    as$status();

    /* printf("\nActive z = %f", new_az); */

    /*
     * get scale factor
     */
    VDdet_get_scale_fact( me->text_scale, &scale );

    /*
     * compute new display depths for the window
     */

    depths[2] = depths[2] * scale + new_az;
    depths[5] = depths[5] * scale + new_az;

    /* printf("\nNew display depths = %f, %f", depths[2], depths[5]); */

    /*
     * activate the new display depths in the window 
     */

    status = dp$view_vol( msg            = sts,
                          gg_id          = &(me->window_id),
                          display_depths = depths,
                          update         = TRUE);
    as$status();

    /*
     * convert the intern values to extern user defined values.
     */

    tmp_z1 = depths[2];
    tmp_z2 = depths[5];

    status = VDdet_conv_int_ext( tmp_z1, &tmp_z1, me->ModuleInfo.md_id.osnum);
    status = VDdet_conv_int_ext( tmp_z2, &tmp_z2, me->ModuleInfo.md_id.osnum);
    status = VDdet_get_def_units( me->ModuleInfo.md_id.osnum, NULL, units );

    /*
     * display the new depths in status field
     */

    sprintf(buffer, "Current Z depths are %g, %g %s ", tmp_z1, tmp_z2, units );
    ex$message(field = 2, in_buff = buffer) ;

    status = 
    om$get_channel_count ( objid = my_id,
			    p_chanselect = & me->located_chansel,
			    count = & count );
    as$status( action = RET_STATUS );

    if( count ){

      status =
      om$send(msg = message GRgraphics.GRdisplay(
					   sts,
					   &me->ModuleInfo.md_env.matrix_type,
					   me->ModuleInfo.md_env.matrix,
					   &me->DisplayMode,
					   &me->ModuleInfo.md_id ),
	       p_chanselect = &me->located_chansel );
      as$status( action = RET_STATUS );
    }       

    return status;
}

/* ********************************************************** */
method VDdet_erase_hilite ( long * sts )
/* ********************************************************** */
{
  int		  status = OM_S_SUCCESS;

/*
 * This method erase the object which are hilighted on the screen.
 */

  /*| erase the object in window */
  status =
  dp$erase_hilite( msg = sts );

  if( ! ( *sts & status & 1) ){
    printf(" VDdet_erase_hilite : macro dp_erase_hilite failed\n");
    as$status( sts = *sts, action = GOTO_VALUE, value = wrapup );
    as$status( action = GOTO_VALUE, value = wrapup );
  }

  *sts = MSSUCC;
  return( OM_S_SUCCESS );

wrapup:
  *sts = MSFAIL;
  return OM_S_SUCCESS;
}


/* ********************************************************** */
method status_disp ( )
/* ********************************************************** */
{
  int		  status = OM_S_SUCCESS;

long	sts1;

  /*| call STATUS_DISP */
  status = 
  _VD_SEND_WRT_M( my_id, super_cmd.status_disp());
  as$status( action = RET_STATUS );
  status = _VD_SEND_MY( VDCmdDetail.VDupdate_form( &sts1, 1 ));
  as$status(action=RET_STATUS);

return(OM_S_SUCCESS );
}

method  VDdet_init_noplane()
{

   me->VDref_os = 6;
   return OM_S_SUCCESS;

}


method  VDdet_set_view_mat(
 long				*msg;
 struct VDdet_formdata		*fd_new;
 char				viewchar;
 double				theta
)
{
double  sintheta, costheta;

  if ( !msg || !fd_new )
  {
	*msg = MSFAIL;
	goto quit;
  }

  *msg = MSSUCC;

  theta = theta * M_PI / 180.0;
  sintheta = sin ( theta );
  costheta = cos ( theta );

  switch ( viewchar )
  {
     case VD_XPOS:				/* when theta = 0.0 */
	fd_new->x_vec[0] = 0.0;			/*  0.0 */
	fd_new->x_vec[1] = -1.0 * costheta;
	fd_new->x_vec[2] = -1.0 * sintheta;
	fd_new->y_vec[0] = 0.0;
	fd_new->y_vec[1] = -1.0 * sintheta;
	fd_new->y_vec[2] = costheta;
	fd_new->z_vec[0] = -1.0;
	fd_new->z_vec[1] = 0.0;
	fd_new->z_vec[2] = 0.0;
	break;

     case VD_XNEG:
	fd_new->x_vec[0] = 0.0;			/*  0.0 */
	fd_new->x_vec[1] = costheta;
	fd_new->x_vec[2] = -1.0 * sintheta;
	fd_new->y_vec[0] = 0.0;
	fd_new->y_vec[1] = sintheta;
	fd_new->y_vec[2] = costheta;
	fd_new->z_vec[0] = 1.0;
	fd_new->z_vec[1] = 0.0;
	fd_new->z_vec[2] = 0.0;
	break;

     case VD_YPOS:
	fd_new->x_vec[0] = costheta;
	fd_new->x_vec[1] = 0.0;
	fd_new->x_vec[2] = -1.0 * sintheta;
	fd_new->y_vec[0] = sintheta;
	fd_new->y_vec[1] = 0.0;
	fd_new->y_vec[2] = costheta;
	fd_new->z_vec[0] = 0.0;
	fd_new->z_vec[1] = -1.0;
	fd_new->z_vec[2] = 0.0;
	break;

     case VD_YNEG:
	fd_new->x_vec[0] = -1.0 * costheta;
	fd_new->x_vec[1] = 0.0;
	fd_new->x_vec[2] = -1.0 * sintheta;
	fd_new->y_vec[0] = -1.0 *sintheta;
	fd_new->y_vec[1] = 0.0;
	fd_new->y_vec[2] = costheta;
	fd_new->z_vec[0] = 0.0;
	fd_new->z_vec[1] = 1.0;
	fd_new->z_vec[2] = 0.0;
	break;

     case VD_ZPOS:
	fd_new->x_vec[0] = -1.0 * costheta;
	fd_new->x_vec[1] = -1.0 * sintheta;
	fd_new->x_vec[2] = 0.0;
	fd_new->y_vec[0] = -1.0 * sintheta;
	fd_new->y_vec[1] = costheta;
	fd_new->y_vec[2] = 0.0;
	fd_new->z_vec[0] = 0.0;
	fd_new->z_vec[1] = 0.0;
	fd_new->z_vec[2] = -1.0;
	break;

     case VD_ZNEG:
	fd_new->x_vec[0] = -1.0 * costheta;
	fd_new->x_vec[1] = 1.0 * sintheta;
	fd_new->x_vec[2] = 0.0;
	fd_new->y_vec[0] = -1.0 * sintheta;
	fd_new->y_vec[1] = -1.0 * costheta;
	fd_new->y_vec[2] = 0.0;
	fd_new->z_vec[0] = 0.0;
	fd_new->z_vec[1] = 0.0;
	fd_new->z_vec[2] = 1.0;
	break;
  }

quit:
  return OM_S_SUCCESS;

}

method  get_range_from_objid ( long	*msg )
{
 long			sts;
 struct GRobj_env       *locObjs = NULL;
 IGRint			nbLocObjs;
 IGRint			ii, jj;
 IGRboolean		world = 1;
 GRrange		loc_range;
 IGRboolean		processed;

  *msg = MSSUCC ;


  sts =
  as$start_fence( set		= &me->event1.located_object[0].located_obj,
		  set_env	= &me->event1.located_object[0].module_info,
		  nb_obj	= &nbLocObjs,
		  p_obj_env	= &locObjs,
		  response	= me->response,
		  response_data = me->response_data );

  for( ii=0; ii<3; ii++) me->tmp_range[ii] = IGE_DESIGN_LIMITS_MAX;
  for( ii=3; ii<6; ii++) me->tmp_range[ii] = IGE_DESIGN_LIMITS_MIN;

  processed = FALSE;
  for( ii=0; ii<nbLocObjs; ii++ )
  {
	sts = om$send ( msg = message GRgraphics.GRgetrang (
					msg,
					&locObjs[ii].mod_env.md_env.matrix_type,
					locObjs[ii].mod_env.md_env.matrix,
					&world,
					loc_range ),
	targetid = locObjs[ii].obj_id.objid,
	targetos = locObjs[ii].obj_id.osnum,
	senderid = NULL_OBJID );
	if ( !(sts & *msg & 1) )  continue;

	processed = TRUE;

	for(jj=0; jj<3; jj++)
	 if(loc_range[jj] < me->tmp_range[jj]) me->tmp_range[jj]=loc_range[jj];

	for(jj=3; jj<6; jj++)
	 if(loc_range[jj] > me->tmp_range[jj]) me->tmp_range[jj]=loc_range[jj];
  }

  dp$erase_hilite ( msg = msg );


  if ( processed )	*msg  = MSSUCC;
  else			*msg  = MSFAIL;

  return OM_S_SUCCESS;
}

method  get_range_from_objname(long	*msg)
{
  *msg = MSSUCC;

  return OM_S_SUCCESS;
}

method  set_range( long	*msg )
{
long	sts;
int	ii;
char    *fm_ptr = NULL;
double  tmp[6];


  *msg = MSSUCC;

  for(ii=0; ii<6; ii++)	me->fd_new.vw_volume[ii] = me->tmp_range[ii];

  /* find center of the range */
  for(ii=0; ii<3; ii++)
    me->fd_new.origin[ii]=(me->fd_new.vw_volume[ii] +
				me->fd_new.vw_volume[ii+3])/2.0;

  for(ii=0; ii<3; ii++)
    VDdet_conv_int_ext ( me->fd_new.origin[ii], &tmp[ii], me->VDcur_os);

  fm_ptr = me->status_display_form_ptr;

  VDdet_set_VALUES3(fm_ptr,VD_DET_ORIGIN, tmp );

  for(ii=0; ii<6; ii++)
    VDdet_conv_int_ext ( me->fd_new.vw_volume[ii], &tmp[ii], me->VDcur_os);

  VDdet_set_VALUES3(fm_ptr,VD_DET_VOL_MIN, tmp );
  VDdet_set_VALUES3(fm_ptr,VD_DET_VOL_MAX, &tmp[3] );

  sts = _VD_SEND_MY( VDCmdDetail.disp_view_vol ( msg ));

#ifdef VD_CHANGE_ZDEPTHS
  sts = _VD_SEND_MY( VDCmdDetail.VDdet_set_zdepths( msg));
  for(ii=0; ii<3; ii++)
	me->fd_old.origin[ii] = me->fd_new.origin[ii];

#endif

  return OM_S_SUCCESS;

}

method  extend_range( long   *msg )
{
long	sts;
int	ii;
char    *fm_ptr = NULL;
double  tmp[6];


  *msg = MSSUCC;

  for(ii=0; ii<3; ii++)
    if( me->tmp_range[ii] < me->fd_new.vw_volume[ii] )
		me->fd_new.vw_volume[ii] = me->tmp_range[ii];

  for(ii=3; ii<6; ii++)
    if( me->tmp_range[ii] > me->fd_new.vw_volume[ii] )
		me->fd_new.vw_volume[ii] = me->tmp_range[ii];

  /* find center of the range */
  for(ii=0; ii<3; ii++)
    me->fd_new.origin[ii]=(me->fd_new.vw_volume[ii] +
					me->fd_new.vw_volume[ii+3])/2.0;

  for(ii=0; ii<3; ii++)
    VDdet_conv_int_ext ( me->fd_new.origin[ii], &tmp[ii], me->VDcur_os);

  fm_ptr = me->status_display_form_ptr;

  VDdet_set_VALUES3(fm_ptr,VD_DET_ORIGIN, tmp );

  for(ii=0; ii<6; ii++)
    VDdet_conv_int_ext ( me->fd_new.vw_volume[ii], &tmp[ii], me->VDcur_os);

  VDdet_set_VALUES3(fm_ptr,VD_DET_VOL_MIN, tmp );
  VDdet_set_VALUES3(fm_ptr,VD_DET_VOL_MAX, &tmp[3] );

  sts = _VD_SEND_MY( VDCmdDetail.disp_view_vol ( msg ));

#ifdef VD_CHANGE_ZDEPTHS
  sts = _VD_SEND_MY( VDCmdDetail.VDdet_set_zdepths( msg ));
  for(ii=0; ii<3; ii++)
	me->fd_old.origin[ii] = me->fd_new.origin[ii];
#endif

  return OM_S_SUCCESS;

}


method get_coord_of_pt ( long *msg; int flag )
{
long			sts;
struct IGRpolyline	pt;
double			coords[3], tmp;
struct GRmd_env		*mdEnv;
int			action = 1, ii;
enum  GRdpmode		dpmode;

	pt.points = coords;

	mdEnv = &me->event1.located_object[0].module_info;
	sts = om$send ( msg = message GRlinear.GRgetpolyline (
			 msg,
			 &mdEnv->md_env.matrix_type,
			 mdEnv->md_env.matrix,
			 &action,
			 &pt ),
		   targetid = me->event1.located_object[0].located_obj.objid,
		   targetos = me->event1.located_object[0].located_obj.osnum );

	VDS_ERR_RPT("GRlinear.GRgetpolyline", sts, *msg, VD_VERBOSE );

	if ( flag )
	  for(ii=0;ii<3;ii++)
	  {
	     if ( coords[ii] < me->tmp_range[ii] )
	     {
	        tmp = me->tmp_range[ii];
		me->tmp_range[ii] = coords[ii];
		me->tmp_range[ii+3] = tmp;
	     }
	     else
		me->tmp_range[ii+3] = coords[ii];
	  }
	else
	  for(ii=0;ii<3;ii++) me->tmp_range[ii] = coords[ii];


	dpmode = GRbdhe;
	sts = om$send ( msg = message GRgraphics.GRdisplay (
					msg,
					&me->ModuleInfo.md_env.matrix_type,	
					me->ModuleInfo.md_env.matrix,
					&dpmode,
					&me->ModuleInfo.md_id ),
	targetid = me->event1.located_object[0].located_obj.objid,
	targetos = me->event1.located_object[0].located_obj.osnum,
	senderid = NULL_OBJID );

   *msg = MSSUCC;
   return OM_S_SUCCESS;

}


method  erase_sts_disp( long *msg )
{
   FIf_erase ( me->status_display_form_ptr );
   me->form_requested = 0;
   me->VDdet_form_display = FALSE;
   *msg = MSSUCC;
   return OM_S_SUCCESS;
}

method  disp_sts_disp( long *msg )
{
   FIf_display ( me->status_display_form_ptr );
   me->form_requested = 1;
   me->VDdet_form_display = TRUE;
   *msg = MSSUCC;
   return OM_S_SUCCESS;
}

method disp_view_vol ( long   *msg )
{
 long		sts, ii;
 double		rng[6];
 char		axis_tgl[20], view[20], constArrFlg;
 char           viewchar= VD_NODIR ;
 char		*fm_ptr = NULL;

   SetProc( VDCmdDetail_disp_view_vol ); Begin

   fm_ptr = me->status_display_form_ptr;

   VDdet_get_VALUES3(fm_ptr,VD_DET_VOL_MIN,rng);
   VDdet_get_VALUES3(fm_ptr,VD_DET_VOL_MAX,&rng[3]);

   for(ii=0; ii<6; ii++)
	VDdet_conv_ext_int( rng[ii], &rng[ii], me->VDcur_os );

   VDdet_get_ALPHA( fm_ptr, VD_DET_AXIS_TOGGLE, axis_tgl );

   if ( !strcmp(axis_tgl, "Alternative") )
   {
     constArrFlg = 1;
     VDdet_get_ALPHA ( fm_ptr, VD_DET_VIEW_FLD, view );
     VDdet_get_VIEWCHAR( view, &viewchar );
   }
   else
   {
     viewchar = VD_NODIR;
     constArrFlg = 0;
   }

/* 
 * TR179601991
 * Bufferred erases 
*/
me->m_OldBoxId = me->tmpList[VD_Obj_boxId];
me->tmpList[VD_Obj_boxId].objid = NULL_OBJID;

me->m_OldArrId = me->tmpList[VD_Obj_arrId];
me->tmpList[VD_Obj_arrId].objid = NULL_OBJID;

me->m_OldCsId = me->tmpList[VD_Obj_csId];
me->tmpList[VD_Obj_csId].objid = NULL_OBJID;

me->m_UpdateBox = TRUE;
me->m_UpdateArr = TRUE;
me->m_UpdateCs  = TRUE;

   sts = VDdisp_clip_box (	msg, 
				&me->tmpList[VD_Obj_boxId],
				&me->tmpList[VD_Obj_csId],
				&me->tmpList[VD_Obj_arrId],
				constArrFlg,
				&me->ModuleInfo, rng, &rng[3], viewchar );
   VDS_ERR_RPT ( "VDdisp_clip_box", sts, *msg, VD_VERBOSE );

   *msg = MSSUCC;
   End ;
   return OM_S_SUCCESS;

}

method  VDdet_init_toggles ( long *msg )
{

  me->fd_new.toggle &= ~VD_DET_AXIS_FLAG;
  me->fd_new.toggle &= ~VD_DET_ALT_FLAG;

  me->fd_new.vol_toggle = VD_DET_EXTENDED;

  *msg = MSSUCC;
  return OM_S_SUCCESS;

}

method  VDdet_set_zdepths ( long  *msg )
{
long		sts, ii;
double		rng[6], origin[3], dpths[2];
char		axis_tgl[20], view[20];
char		viewchar = VD_NODIR ;
char		*fm_ptr = NULL;


   sts  = OM_S_SUCCESS;
   *msg = MSSUCC;

   fm_ptr = me->status_display_form_ptr;
   VDdet_get_ALPHA( fm_ptr, VD_DET_AXIS_TOGGLE, axis_tgl );

   if ( !strcmp(axis_tgl, "Alternative") )
   {
     VDdet_get_ALPHA ( fm_ptr, VD_DET_VIEW_FLD, view );
     VDdet_get_VIEWCHAR( view, &viewchar );
   }
   else	goto wrapup;

   VDdet_get_VALUES3(fm_ptr,VD_DET_VOL_MIN,rng);
   VDdet_get_VALUES3(fm_ptr,VD_DET_VOL_MAX,&rng[3]);

   for(ii=0; ii<6; ii++)
	VDdet_conv_ext_int( rng[ii], &rng[ii], me->VDcur_os );

   VDdet_get_VALUES3(fm_ptr, VD_DET_ORIGIN, origin);

   for(ii=0;ii<3;ii++)
	VDdet_conv_ext_int( origin[ii], &origin[ii], me->VDcur_os );

   /* do some checks */
   if ( viewchar == VD_XPOS || viewchar == VD_XNEG )
	if ( rng[0] == rng[3] ) goto wrapup;

   if ( viewchar == VD_YPOS || viewchar == VD_YNEG )
	if ( rng[1] == rng[4] ) goto wrapup;

   if ( viewchar == VD_ZPOS || viewchar == VD_ZNEG )
	if ( rng[2] == rng[5] ) goto wrapup;

   switch ( viewchar )
   {
     case VD_XPOS :
	dpths[0] = origin[0] - rng[3];
	dpths[1] = origin[0] - rng[0];
	break;

     case VD_XNEG :
	dpths[0] = rng[0] - origin[0];
	dpths[1] = rng[3] - origin[0];
	break;

     case VD_YPOS :
	dpths[0] = origin[1] - rng[4];
	dpths[1] = origin[1] - rng[1];
	break;

     case VD_YNEG :
	dpths[0] = rng[1] - origin[1];
	dpths[1] = rng[4] - origin[1];
	break;

     case VD_ZPOS :
	dpths[0] = origin[2] - rng[5];
	dpths[1] = origin[2] - rng[2];
	break;

     case VD_ZNEG :
	dpths[0] = rng[2] - origin[2];
	dpths[1] = rng[5] - origin[2];
	break;
   }

   me->fd_new.toggle |= VD_DET_ZDEPTH_FLAG;
   for(ii=0; ii<2; ii++)
	VDdet_conv_ext_int (dpths[ii],
			&me->fd_new.usr_z_depth[ii], me->VDcur_os);

   FIg_set_state ( fm_ptr, VD_DET_Z_DEPTH_TOGGLE, 1 );
   VDdet_set_VALUES2( fm_ptr, VD_DET_Z_DEPTH, dpths );
   VDdet_set_MODE_ON( fm_ptr, VD_DET_Z_DEPTH, 2 );

wrapup:
   return sts;
}

end implementation VDCmdDetail;
