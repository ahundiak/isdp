/* $Id: VDdispVVform.I,v 1.1.1.1 2001/01/04 21:09:32 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdvvol/func/VDdispVVform.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDdispVVform.I
 *
 * History:
 *	07/25/95    raju	creation date
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
#include	"griomacros.h"
#include	"grmacros.h"
#include	"msdef.h"
#include	"msmacros.h"
#include	"dp.h"
#include 	"FI.h"

#include	"vdmemmacros.h"
#include	"vderrmacros.h"
#include	"vdvvoldef.h"
#include	"vdvvolmacros.h"

#define	 VD_LIST_FLD  15

%safe
#include	"VX_FIproto.h"
static  int			num_vvol;
static  struct GRid		*vvol_id_list = NULL;
static  struct GRmd_env		*vvol_env_list = NULL;
static  char			**vvol_name_list = NULL,
				**vvol_desc_list  = NULL;
static  char			*selected_vol;
%endsafe

from   VDviewvol   import  VDvv_give_solid;
from   VDviewvol   import  VDvv_display_solid;
from   GRgraphics  import  GRdisplay;
from   NDnode	   import  ASreturn_go;


int   VDselVvol_form_notif();
int   VDform_events_loop();

/*
  Return status :
       user needs to free vvol_ids, vvol_env, vvol_names, vvol_desc
*/

long   VDget_filename_from_os(
  GRspacenum	os_num,
  char		filename[]
)
{
char	fullname[256];
int	len, ii;
long	sts;


     sts = om$os_number_to_name ( osnum  = os_num,
				  osname = fullname );
     if ( !(sts&1) ) goto error;

     len = strlen ( fullname );

     /* find first backslash from end */
     for( ii = len-1; ii >= 0; ii-- )
	if ( fullname[ii] == '/' )  break;
     strncpy( filename, &fullname[ii+1], 14 );
     filename[14] = '\0';

     return 1;

error:
     return 0;
}

long  VDdispVVform(
  long			*msg,		/* O */
  IGRboolean		single_multi_sel, /* I -  TRUE =  select only one vv.
					     FALSE = select more than one vv.
					  */
  int			*num_vvol_sel,  /* O - no. of vv's selected*/
  struct GRid		**vvol_ids,	/* O - list of ids of selected vv's.
						= NULL, if not needed	*/
  struct GRmd_env	**vvol_env,	/* O - list of envs of selected vv's.
						= NULL, if not needed	*/
  char			***vvol_names,	/* O - list of names of selected vv's.
						= NULL, if not needed	*/
  char			***vvol_desc	/* O - list of desc of selected vv's.
						= NULL, if not needed	*/
)
{
 long			sts;
 int			ii, jj;
 char			filename[15];
 Form			fp;

 sts = OM_S_SUCCESS;
 *msg = MSSUCC;

 sts = vd$get_vvol_list (   msg		=  msg,
			    num_vvol	=  &num_vvol,
			    vvol_ids	=  &vvol_id_list,
			    vvol_env	=  &vvol_env_list,
			    vvol_names  =  &vvol_name_list,
			    vvol_desc	=  &vvol_desc_list  );
 VDS_ERR_HNDLR( "vd$get_vvol_list", sts, *msg, VD_VERBOSE, wrapup );
 if ( num_vvol == 0 )
 {
    ex$message (  in_buff = "No view volumes defined",
		  field   = ERROR_FIELD,
		  justification = CENTER_JUS );
    sts = OM_W_ABORT;
    goto wrapup;
 }

 selected_vol = (char *) malloc( sizeof(char) * num_vvol );
 for ( ii =0; ii<num_vvol; ii++)  selected_vol[ii] = FALSE;

 sts = FIf_new( 0, "VDselVVol", VDselVvol_form_notif, &fp);

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

 FIfld_set_max_num_rows( fp, VD_LIST_FLD, num_vvol );
 FIfld_set_num_rows ( fp, VD_LIST_FLD, num_vvol );

 for(ii=0; ii<num_vvol; ii++)
 {
     FIfld_set_text ( fp, VD_LIST_FLD, ii, 0, vvol_name_list[ii], FALSE );
     FIfld_set_text ( fp, VD_LIST_FLD, ii, 1, vvol_desc_list[ii], FALSE );

     FIfld_set_select( fp, VD_LIST_FLD, ii, 0, FALSE );
     FIfld_set_select( fp, VD_LIST_FLD, ii, 1, FALSE );

     sts = VDget_filename_from_os (  vvol_id_list[ii].osnum,  filename );
     if ( !(1&sts) ) continue;
     FIfld_set_text ( fp, VD_LIST_FLD, ii, 2, filename, FALSE );
     FIfld_set_select( fp, VD_LIST_FLD, ii, 2, FALSE );
 }

 FIf_display ( fp );

 sts = VDform_events_loop ( fp );
 if ( sts != FI_SUCCESS ) 
 {
   *num_vvol_sel = 0;
   goto wrapup;
 }

 *num_vvol_sel = 0;
 for ( ii=0; ii<num_vvol; ii++)
    if ( selected_vol[ii] ) (*num_vvol_sel)++;

 if ( *num_vvol_sel )
 {
   /*
    *  allocate memory
    */

   if ( vvol_ids )
      *vvol_ids = (struct GRid *) malloc( sizeof(struct GRid) *(*num_vvol_sel));
   if ( vvol_env )
      *vvol_env = 
	(struct GRmd_env *) malloc ( sizeof(struct GRmd_env) * (*num_vvol_sel));
   if ( vvol_names )
   {
     sts = vd$malloc_str_list ( str_list  = vvol_names,
				num_str   = (*num_vvol_sel),
				str_size  = VD_MAX_VOL_NAME_LEN );

     if( !sts )
     {
	printf("%s[line:%d] : can not allocate memory\n", __FILE__, __LINE__);
	goto wrapup;
     }
   }
   if ( vvol_desc )
   {
     sts = vd$malloc_str_list ( str_list  = vvol_desc,
				num_str   = (*num_vvol_sel),
				str_size  = VD_MAX_VOL_DESC_LEN );
     if ( !sts )
     {
	printf("%s[line:%d] : can not allocate memory\n", __FILE__, __LINE__);
	goto wrapup;
     }
   }
   /* check if memory has been allocated */
   if ( (vvol_ids && !(*vvol_ids)) ||
	(vvol_env && !(*vvol_env)) ||
	(vvol_names && !(*vvol_names)) ||
	(vvol_desc && !(*vvol_desc))      )
   {
      *num_vvol_sel = 0;
      goto wrapup;
   }

   for ( ii=0, jj=0; ii<num_vvol; ii++)
   {
     if ( selected_vol[ii] )
     {
	if ( vvol_ids )  (*vvol_ids)[jj] = vvol_id_list[ii];
	if ( vvol_env )  (*vvol_env)[jj] = vvol_env_list[ii];
	if ( vvol_names ) strcpy( (*vvol_names)[jj], vvol_name_list[ii] );
	if ( vvol_desc ) strcpy( (*vvol_desc)[jj], vvol_desc_list[ii] );
	jj++;
     }
   } /* for ( ii=0, jj=0; ii<num_vvol; ii++) */
 } /* if ( *num_vvol_sel ) */

wrapup:
 if ( vvol_id_list ) { free (vvol_id_list ); vvol_id_list = NULL; }
 if ( vvol_env_list ) { free (vvol_env_list ); vvol_env_list = NULL; }
 if ( vvol_name_list ) 
 { 
   vd$free_str_list ( str_list = vvol_name_list,
		      num_str  = num_vvol );
   vvol_name_list = NULL;
 }
 if ( vvol_desc_list )
 { 
   vd$free_str_list ( str_list = vvol_desc_list,
		      num_str  = num_vvol );
   vvol_desc_list = NULL;
 }
 if ( selected_vol ) { free ( selected_vol); selected_vol = NULL; }
 num_vvol = 0;
 return sts;
}

int VDselVvol_form_notif (
  int           f_label,        /* i - The label of the form    */
  int           g_label,        /* i - The label of the gadget  */
  double        value,          /* i - The value of the gadget  */
  Form          fp              /* i - Form pointer             */
)
{
 int			ii,
 			sel_flag;
 long			msg, sts;
 struct GRid		solidId;


  FIg_set_text( fp, FI_MSG_FIELD, "" );

  switch ( g_label )
  {
    case VD_LIST_FLD:
	for ( ii=0; ii < num_vvol; ii++ )
	{
	  FIfld_get_select ( fp, VD_LIST_FLD, ii, 0, &sel_flag);
	  if ( sel_flag )
	  {
	    sts = om$send ( msg = message NDnode.ASreturn_go(
					&solidId,
					NULL,
					NULL ),
			    targetid = vvol_id_list[ii].objid,
			    targetos = vvol_id_list[ii].osnum,
			    senderid = NULL_OBJID );
	    VDS_ERR_CONTINUE("NDnode.ASreturn_go", sts, 1, VD_VERBOSE );

	    sts = gr$put_properties (	object_id = &solidId,
					action     = 1,
					properties_mask = GRIS_DISPLAYABLE );

	    ACset_disthruref();
	    sts = gr$display_object ( object_id = &solidId,
				      md_env    = &vvol_env_list[ii],
				      mode	= GRhd );
	    ACreset_disthruref();

	    sts = gr$put_properties (	object_id = &solidId,
					action     = 0,
					properties_mask = GRIS_DISPLAYABLE );
	  } /* if (sel_flag ) */
	  else
	  {
	    sts = om$send ( msg = message NDnode.ASreturn_go(
					&solidId,
					NULL,
					NULL ),
			    targetid = vvol_id_list[ii].objid,
			    targetos = vvol_id_list[ii].osnum,
			    senderid = NULL_OBJID );
	    VDS_ERR_CONTINUE("NDnode.ASreturn_go", sts, 1, VD_VERBOSE );

	    sts = gr$put_properties (	object_id = &solidId,
					action     = 1,
					properties_mask = GRIS_DISPLAYABLE );

	    ACset_disthruref();
	    sts = gr$display_object ( object_id = &solidId,
				      md_env    = &vvol_env_list[ii],
				      mode	= GRbdhe );
	    ACreset_disthruref();

	    sts = gr$put_properties (	object_id = &solidId,
					action     = 0,
					properties_mask = GRIS_DISPLAYABLE );
	  } /* else of if ( sel_flag ) */
	}   /* for ( ii=0; ii < num_vvol; ii++ ) */
	break;

     case FI_ACCEPT:
     case FI_CANCEL:
	for ( ii=0; ii < num_vvol; ii++ )
	{
	  FIfld_get_select ( fp, VD_LIST_FLD, ii, 0, &sel_flag);
	  if ( sel_flag )
	  {
	    if ( g_label == FI_ACCEPT ) selected_vol[ii] = TRUE;

	    sts = om$send ( msg = message NDnode.ASreturn_go(
					&solidId,
					NULL,
					NULL ),
			    targetid = vvol_id_list[ii].objid,
			    targetos = vvol_id_list[ii].osnum,
			    senderid = NULL_OBJID );
	    VDS_ERR_CONTINUE("NDnode.ASreturn_go", sts, 1, VD_VERBOSE );

	    sts = gr$put_properties (	object_id = &solidId,
					action     = 1,
					properties_mask = GRIS_DISPLAYABLE );
	    ACset_disthruref();
	    sts = gr$display_object ( object_id = &solidId,
				      md_env    = &vvol_env_list[ii],
				      mode	= GRbdhe );
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


int VDform_events_loop( Form fp )
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

