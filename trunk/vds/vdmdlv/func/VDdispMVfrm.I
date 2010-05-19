/* $Id: VDdispMVfrm.I,v 1.1.1.1 2001/01/04 21:08:56 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdmdlv/func/VDdispMVfrm.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDdispMVfrm.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:56  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.7  1996/03/22  06:23:18  pinnacle
# Replaced: vdmdlv/func/VDdispMVfrm.I for:  by msbraju for vds.240
#
# Revision 1.6  1995/09/25  22:55:34  pinnacle
# Replaced: vdmdlv/func/VDdispMVfrm.I for:  by sundar for vds.240
#
# Revision 1.5  1995/09/13  16:02:20  pinnacle
# Replaced: vdmdlv/func/VDdispMVfrm.I for:  by azuurhou for vds.240
#
# Revision 1.4  1995/08/24  16:12:42  pinnacle
# Replaced: vdmdlv/func/VDdispMVfrm.I for:  by tlbriggs for vds.240
#
# Revision 1.3  1995/08/23  23:39:18  pinnacle
# Replaced: vdmdlv/func/*.I for:  by tlbriggs for vds.240
#
# Revision 1.2  1995/08/02  11:11:00  pinnacle
# Replaced: vdmdlv/func/VDdispMVfrm.I for:  by msbraju for vds.240
#
# Revision 1.1  1995/07/25  20:59:20  pinnacle
# Created: vdmdlv/func/VDdispMVfrm.I by azuurhou for vds.240
#
 *
 * History:
 *	07/25/95    raju	creation date
 *    	08/23/95    tlb		Modified to use _MALLOC, _FREE
 *    	08/24/95    tlb		Add VdMem.h include
 ***************************************************************************/

class implementation Root;

#include 	<stdio.h>
#include	"exdef.h"

#include	"OMminimum.h"
#include	"igetypedef.h"
#include	"igrtypedef.h"
#include	"igr.h"
#include	"griodef.h"
#include	"godef.h"
#include	"gr.h"
#include	"igrdp.h"
#include	"go.h"
#include	"ex.h"
#include	"grio.h"
#include	"exmacros.h"
#include	"DItypedef.h"
#include	"DIdef.h"
#include	"DIglob.h"
#include	"DIprims.h"
#include	"griomacros.h"
#include	"grmacros.h"
#include	"msdef.h"
#include	"msmacros.h"
#include	"dp.h"
#include 	"FI.h"
#define	 VD_LIST_FLD  15

#include	"vdmemmacros.h"
#include	"vderrmacros.h"
#include	"vdmdlvwdef.h"    /* for VD_MAX_MV_NAME_LEN, DESC_LEN */
#include 	"VDmem.h"

%safe
#include	"VX_FIproto.h"
static  int			num_mv;
static  struct GRid		*mv_id_list = NULL;
static  struct GRmd_env		*mv_env_list = NULL;
static  char			**mv_name_list = NULL,
				**mv_desc_list  = NULL;
static  char			*selected_mv;
%endsafe

int   VDselMV_form_notif();
int   VDform_events_loop2();

from  VDmdlview  import  VDmv_display_solid;
from  NDnode	 import  ASreturn_go;


/*
Internal Function : VDdispMVform

  When this function is called, a form showing all defined model views appear.
User can select one or more model views. This function returns the list
of selected model views.

Memory:
 This function allocates memory for mv_ids, mv_envs, mv_names and
mv_desc.

 It should be freed by the calling routine.
 _FREE ( mv_ids );
 _FREE ( mv_envs );
 if ( mv_names ) VDfree_str_list ( mv_names, num_mv_sel );
 if ( mv_desc ) VDfree_str_list ( mv_desc, num_mv_sel );
*/

long  VDdispMVform(
  long			*msg,		/* O - return status */
  IGRboolean		single_multi_sel, /* I -  TRUE =  select only one mv.
					     FALSE = select more than one mv.
					  */
  int			*num_mv_sel,	/* O - no. of mvs selected	*/
  struct GRid		**mv_ids,	/* O - list of ids of selected mvs.
						= NULL, if not needed	*/
  struct GRmd_env	**mv_envs,	/* O - list of envs of selected mvs.
						= NULL, if not needed	*/
  char			***mv_names,	/* O - list of names of selected mvs.
						= NULL, if not needed	*/
  char			***mv_desc	/* O - list of desc of selected mvs.
						= NULL, if not needed	*/
)
{
 long			sts;
 int			ii, jj;
 char			filename[15];
 Form			fp;

 *num_mv_sel = 0;

 sts = VDgetMVlist ( msg, &num_mv,  &mv_id_list, &mv_env_list,
			&mv_name_list, &mv_desc_list  );
 VDS_ERR_HNDLR( "VDgetMVlist", sts, *msg, VD_VERBOSE, wrapup );
 if ( num_mv == 0 )
 {
    ex$message (  in_buff = "No model views defined",
		  field   = ERROR_FIELD,
		  justification = CENTER_JUS );
    sts = OM_W_ABORT;
    goto wrapup;
 }

  selected_mv = _MALLOC( num_mv, char );
  _CheckMem (selected_mv, sts, *msg, wrapup);

 for ( ii =0; ii<num_mv; ii++)  selected_mv[ii] = FALSE;

 sts = FIf_new( 0, "VDselMV", VDselMV_form_notif, &fp);

#ifdef VDS_DBG
 FIf_cvrt_to_perm_win(fp);
#endif

 if (sts != FI_SUCCESS)
 {
   fprintf (stderr, "FIf_new failed: sts = %d\n",sts);
   goto wrapup;
 }

 if ( single_multi_sel )
 {
    FIfld_set_mode( fp, VD_LIST_FLD, 0, FI_SINGLE_SELECT );
    FIfld_set_mode( fp, VD_LIST_FLD, 1, FI_SINGLE_SELECT );
    FIfld_set_mode( fp, VD_LIST_FLD, 2, FI_SINGLE_SELECT );
 }
 else
 {
    FIfld_set_mode( fp, VD_LIST_FLD, 0, FI_MULTI_SELECT );
    FIfld_set_mode( fp, VD_LIST_FLD, 1, FI_MULTI_SELECT );
    FIfld_set_mode( fp, VD_LIST_FLD, 2, FI_MULTI_SELECT );
 }

 FIfld_set_max_num_rows( fp, VD_LIST_FLD, num_mv );
 FIfld_set_num_rows ( fp, VD_LIST_FLD, num_mv );

 for(ii=0; ii<num_mv; ii++)
 {
     FIfld_set_text ( fp, VD_LIST_FLD, ii, 0, mv_name_list[ii], FALSE );
     FIfld_set_text ( fp, VD_LIST_FLD, ii, 1, mv_desc_list[ii], FALSE );

     FIfld_set_select( fp, VD_LIST_FLD, ii, 0, FALSE );
     FIfld_set_select( fp, VD_LIST_FLD, ii, 1, FALSE );

     sts = VDget_filename_from_os (  mv_id_list[ii].osnum,  filename );
     if ( !(1&sts) ) continue;
     FIfld_set_text ( fp, VD_LIST_FLD, ii, 2, filename, FALSE );
     FIfld_set_select( fp, VD_LIST_FLD, ii, 2, FALSE );
 }

 FIf_display ( fp );

 sts = VDform_events_loop2 ( fp );
 if ( sts != FI_SUCCESS ) 
 {
   *num_mv_sel = 0;
   goto wrapup;
 }

 *num_mv_sel = 0;
 for ( ii=0; ii<num_mv; ii++)
    if ( selected_mv[ii] ) (*num_mv_sel)++;

 if ( *num_mv_sel )
 {
   /*
    *  allocate memory
    */

   if ( mv_ids ) {
      	*mv_ids = _MALLOC( (*num_mv_sel), struct GRid);
  	_CheckMem (*mv_ids, sts, *msg, wrapup);
	}

   if ( mv_envs ) {
      	*mv_envs = _MALLOC( (*num_mv_sel), struct GRmd_env);
      	_CheckMem (*mv_envs, sts, *msg, wrapup);
	}

   if ( mv_names )
   {
     sts = vd$malloc_str_list ( str_list = mv_names,
				num_str  = (*num_mv_sel),
				str_size = VD_MAX_MV_NAME_LEN );
     if( !sts )
     {
	printf("%s[line:%d] : can not allocate memory\n", __FILE__, __LINE__);
	goto wrapup;
     }
   }
   if ( mv_desc )
   {
     sts = vd$malloc_str_list ( str_list = mv_desc,
				num_str  = (*num_mv_sel),
				str_size = VD_MAX_MV_DESC_LEN );
     if( !sts )
     {
	printf("%s[line:%d] : can not allocate memory\n", __FILE__, __LINE__);
	goto wrapup;
     }
   }

   for ( ii=0, jj=0; ii<num_mv; ii++)
   {
     if ( selected_mv[ii] )
     {
        if ( mv_ids )  (*mv_ids)[jj] = mv_id_list[ii];
	if ( mv_envs ) (*mv_envs)[jj] = mv_env_list[ii];
	if ( mv_names ) strcpy( (*mv_names)[jj], mv_name_list[ii] );
	if ( mv_desc ) strcpy( (*mv_desc)[jj], mv_desc_list[ii] );
	jj++;
     }
   } /* for ( ii=0, jj=0; ii<num_mv; ii++) */
 } /* if ( *num_mv_sel ) */

wrapup:
 _FREE (mv_id_list ); 
 _FREE (mv_env_list ); 
 if ( mv_name_list )
 {
    vd$free_str_list (	str_list = mv_name_list,
			num_str  = num_mv );
    mv_name_list = NULL;
 }
 if ( mv_desc_list )
 {
    vd$free_str_list (	str_list = mv_desc_list,
			num_str  = num_mv );
    mv_desc_list = NULL;
 }
 _FREE ( selected_mv); 
 num_mv = 0;
 return sts;
}

int VDselMV_form_notif
 (
  int           f_label,        /* i - The label of the form    */
  int           g_label,        /* i - The label of the gadget  */
  double        value,          /* i - The value of the gadget  */
  Form          fp              /* i - Form pointer             */
)
{
 int			ii,
 			sel_flag;
 long			sts, msg;
 struct GRid		solidId;


  


  FIg_set_text( fp, FI_MSG_FIELD, "" );

  switch ( g_label )
  {

    case VD_LIST_FLD:
	for ( ii=0; ii < num_mv; ii++ )
	{
	  FIfld_get_select ( fp, VD_LIST_FLD, ii, 0, &sel_flag);
	  if ( sel_flag )
	  {
	    sts = om$send ( msg = message NDnode.ASreturn_go(
					&solidId,
					NULL,
					NULL ),
			    targetid = mv_id_list[ii].objid,
			    targetos = mv_id_list[ii].osnum,
			    senderid = NULL_OBJID );
	    VDS_ERR_CONTINUE("NDnode.ASreturn_go", sts, 1, VD_VERBOSE );

	    sts = gr$put_properties (	object_id = &solidId,
					action     = 1,
					properties_mask = GRIS_DISPLAYABLE );

	    ACset_disthruref();
	    sts = gr$display_object ( object_id = &solidId,
				      md_env    = &mv_env_list[ii],
				      mode	= GRhd );
	    ACreset_disthruref();

	    sts = gr$put_properties (	object_id = &solidId,
					action     = 0,
					properties_mask = GRIS_DISPLAYABLE );
	  } /* if (sel_flag ) */
	  else
	  {
	    sts = om$send ( msg = message NDnode.ASreturn_go (
					&solidId,
					NULL,
					NULL ),
			    targetid = mv_id_list[ii].objid,
			    targetos = mv_id_list[ii].osnum,
			    senderid = NULL_OBJID );
	    VDS_ERR_CONTINUE("NDnode.ASreturn_go", sts, 1, VD_VERBOSE );

	    sts = gr$put_properties (	object_id = &solidId,
					action     = 1,
					properties_mask = GRIS_DISPLAYABLE );

	    ACset_disthruref();
	    sts = gr$display_object ( object_id = &solidId,
				      md_env    = &mv_env_list[ii],
				      mode	= GRbdhe );
	    ACreset_disthruref();

	    sts = gr$put_properties (	object_id = &solidId,
					action     = 0,
					properties_mask = GRIS_DISPLAYABLE );
	  } /* else of if ( sel_flag ) */
	}   /* for ( ii=0; ii < num_mv; ii++ ) */
	break;

     case FI_CANCEL:
     case FI_ACCEPT:
	for ( ii=0; ii < num_mv; ii++ )
	{
	  FIfld_get_select ( fp, VD_LIST_FLD, ii, 0, &sel_flag);
	  if ( sel_flag )
	  {
	    if ( g_label == FI_ACCEPT ) selected_mv[ii] = TRUE;
	    sts = om$send ( msg = message NDnode.ASreturn_go(
					&solidId,
					NULL,
					NULL ),
			    targetid = mv_id_list[ii].objid,
			    targetos = mv_id_list[ii].osnum,
			    senderid = NULL_OBJID );
	    VDS_ERR_CONTINUE("NDnode.ASreturn_go", sts, 1, VD_VERBOSE );

	    sts = gr$put_properties (	object_id = &solidId,
					action     = 1,
					properties_mask = GRIS_DISPLAYABLE );

	    ACset_disthruref();
	    sts = gr$display_object ( object_id = &solidId,
				      md_env    = &mv_env_list[ii],
				      mode	= GRhd );
	    ACreset_disthruref();

	    sts = gr$put_properties (	object_id = &solidId,
					action     = 0,
					properties_mask = GRIS_DISPLAYABLE );
	  }
	}
	{ int   rsp = EX_FORM_FINISHED;
	  ex$putque(msg = &msg, response = &rsp);
	}
	break;

  }

  /*
   * The following statement is only to make compiler not to say
   * that f_label and value are not referenced
   * This can be the last statement in case of any changes 
   */
  if ( f_label || value ) ;

  return OM_S_SUCCESS;

}


int VDform_events_loop2( Form fp )
{
int		status, response;
IGRlong		ret, done=0;
IGRchar		response_data[256];
struct GRevent	event;

	do {

		done = 1;

		status = co$getevent (
			msg             = &ret,
			event_mask      = ( GRm_BACK_UP | GRm_FORM_FINISHED ),
			event           = &event,
			response        = &response,
			response_data   = response_data);

		if ( response == CMD_STRING || response == STRING ||
		     response == EX_OBJID ) {
			ex$message( field = ERROR_FIELD,
				    in_buff = "Input Ignored");
			done = 0;
		}

	/* While not trying to stack a command or enter a string */
	} while ( !done );

	/* Undisplay form and free the memory it allocated */
	FIf_delete (fp);

	/* kill command event detected? */
	if ( response ==  TERMINATE ) {

	/* Place the kill command event back on the queue */
		ex$putque(
			msg = &ret,
			response	= &response,
			buffer		= response_data);
	}

	if ( event.response != EX_FORM_FINISHED ) return( event.response );
		
/*
		This code would replace the event code above on non-GRnuc apps

		Wait_for_next ( FI_EVENT_MASK, &event );
		if( !FI_process_event(event) ) FI_clear_event(event);
*/
	return(FI_SUCCESS);
}

end implementation Root;

