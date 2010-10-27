/* $Id: VDCmditblni.I,v 1.1.1.1 2001/01/04 21:07:40 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdannot/cmd / VDCmditblni.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmditblni.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:40  cvs
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
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

class implementation VDCmditbln;

#include "AS_status.h"
#include "VDmsg.h"
#include "coparadef.h"
#include "coparamac.h"

from DMroot import replace_text;
from NDnode import NDconnect;
from NDmacro import ACreturn_foot;
from GRgraphics import GRdisplay;
from expression import modify;
from VDitbln import VDset_item_number;

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */ 
/*				Global Variables
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */ 

%safe 
int	VDcurrent_item_number = 1;/* Item Number placed LAST ;	*/

int	VDauto_increment = 1;	/* Set by toggle in FORM	      */
					/* If TRUE, current_item_number is    */
					/* incremented after placement of Item*/

int	VDquantity = 1; 
%endsafe

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */ 
extern GRclassid OPP_ACncpx_class_id;
extern GRclassid OPP_ACpretendin_class_id;
extern GRclassid OPP_VDitbln_class_id;

method init_type()
{
IGRint		status = OM_S_SUCCESS;
long		numberOfBytes,
		BytesReceived,
		msg;
IGRint		*ItemNbs,
		nbItems,
		listSize,
		i1,
		maxItemNb;
struct GRmd_env ModEnvItems;


  ItemNbs = NULL;

  status =
  om$send(msg = message VDCmdAnnot.init_type(),
	  targetid = my_id,
	  mode = OM_e_wrt_message);
  as$status(action = RET_STATUS);

  me->an_classid = OPP_VDitbln_class_id;
  me->msgnumb   = VD_M_PlItNm;
  me->loc_key   = VD_P_IdElIt;

  status =
  om$send(msg = message COdim.create_form(0,"VDPlItem", &me->form),
	  targetid = my_id);
  as$status(action = RET_STATUS);

  /*
   *  get the item no.s in the current OS. Get the maximum item no. of the
   *  exisiting item no.s .  Set the current item number to max. item no. + 1.
   */

   numberOfBytes = sizeof ModEnvItems ;
   gr$get_module_env(	msg     = &msg,
			sizbuf  = &numberOfBytes,
			buffer  = &ModEnvItems,
			nret    = &BytesReceived ) ;


   listSize = 0;
   do
   {
	listSize += 100;

	if ( listSize == 100 ) 
		ItemNbs = ( IGRint * ) malloc ( sizeof (IGRint) * listSize );
	else
		ItemNbs = ( IGRint * ) realloc ( ItemNbs,
						 sizeof ( IGRint ) * listSize);

	status =
	     VDgetItemsInOs (	ModEnvItems.md_id.osnum,
				listSize,
				ItemNbs,
				NULL,
				&nbItems );
    }  while ( listSize <= nbItems );

    maxItemNb = 0;
    for ( i1=0; i1<nbItems; i1++ )
	if ( maxItemNb < ItemNbs[i1] )  maxItemNb = ItemNbs[i1];

    if( ItemNbs ) free ( ItemNbs );

#ifdef  DEBUG
    printf( " VDCmditbln.init_type : maxItemNb = [%d]\n" , maxItemNb );
#endif

    VDcurrent_item_number = maxItemNb + 1;

  return status;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */ 

method process_bln_form(
	IGRboolean display;
	IGRint label;
	IGRdouble value;
	Form form)
{
IGRint		status = OM_S_SUCCESS,
		sts;
IGRdouble	dbl_dum;
struct DMsenv_param par_senv;
long		numberOfBytes,
		BytesReceived,
		msg;
IGRint		*ItemNbs,
		nbItems,
		listSize,
		i1;
struct GRmd_env ModEnvItems;
char		msg_buff[81];
GRobjid		*ItemIds;

	ItemNbs = NULL;
	ItemIds = NULL;

        dm$get_dim_param(type = DM_SENV_PARAM, p_data = &par_senv);
	status = OM_S_SUCCESS;

	FIg_set_text ( form, FI_MSG_FIELD, "" );
	dp$erase_hilite ( msg = &msg );

	if (!display)
	{
	 /* Get info from displayed form */
	 switch(label)
	  {
	   /* special icons for place item number */
	    case GAD_AUTO_INC:

		sts = FIg_get_state(form, GAD_AUTO_INC, &VDauto_increment);
		if(sts != FI_SUCCESS) VDauto_increment = 1;
		break;

	    case GAD_IT_NMBR:

		sts = FIg_get_value(form, GAD_IT_NMBR, &dbl_dum);
		if(sts != FI_SUCCESS) return(OM_E_ABORT);
		VDcurrent_item_number = dbl_dum;

		/*
		 *  get the item no.s in the current OS. Get the maximum
		 *  item no. of the exisiting item no.s .
		 *  Set the current item number to max. item no. + 1.
   		 */

		numberOfBytes = sizeof ModEnvItems ;
		gr$get_module_env(	msg     = &msg,
					sizbuf  = &numberOfBytes,
					buffer  = &ModEnvItems,
					nret    = &BytesReceived ) ;


   		listSize = 0;
   		do
   		{
		  listSize += 100;

		  if ( listSize == 100 ) 
		  {
		    ItemNbs = ( IGRint * ) malloc ( sizeof (IGRint) * listSize);
		    ItemIds = ( GRobjid * )
				malloc ( sizeof (GRobjid) * listSize);
		  }
		  else
		  {
		    ItemNbs = ( IGRint * ) realloc ( ItemNbs,
						 sizeof ( IGRint ) * listSize);
		    ItemIds = ( GRobjid * ) realloc ( ItemIds,
						 sizeof ( GRobjid ) * listSize);
		  }
		  status =
			VDgetItemsInOs ( ModEnvItems.md_id.osnum,
					 listSize,
					 ItemNbs,
					 ItemIds,
					 &nbItems );
    		}  while ( listSize <= nbItems );

		for ( i1=0 ; i1<nbItems; i1++ )
		   if ( VDcurrent_item_number == ItemNbs[i1] )
		   {
			FIg_display ( form, FI_MSG_FIELD );
			ex$message ( msgnumb = VD_W_ItemNbExst, buff =msg_buff);
			FIg_set_text ( form, FI_MSG_FIELD, msg_buff );
			status =  VDdisplayItemsInOs (	&msg,
							ModEnvItems.md_id.osnum,
							1,
							&ItemIds[i1] );
			
			break;
		   }

		if( ItemNbs ) free ( ItemNbs );
		if( ItemIds ) free ( ItemIds );

		if(me->an_grid.objid != NULL_OBJID)
		{
		   IGRchar item_string[80];
		   int rc;
		   sprintf(item_string,"%d",VDcurrent_item_number);
       		   status = om$send( msg = message DMroot.replace_text(
                                        &rc,
                                        DIM_TEXT,
                                        (struct GRid *) NULL,
                                        &me->dyn_env,
                                        strlen(item_string),
                                        (IGRuchar *)item_string),
                   targetid = me->an_grid.objid,
                   targetos = me->an_grid.osnum);

                   status =
                   om$send(msg = message VDitbln.VDset_item_number(
							VDcurrent_item_number),
                           targetid = me->an_grid.objid,
                           targetos = me->an_grid.osnum);
                   as$status( action = RET_STATUS );
		}
		break;

	    case GAD_IT_QUAN:

		sts = FIg_get_value(form, GAD_IT_QUAN, &dbl_dum);
		if(sts == FI_SUCCESS) VDquantity = dbl_dum;
		break;


	    default :
	        /*
                 * Regular processing for the place text with balloon form
		 */
		status =
                om$send(msg = message COanplace.process_bln_form
				   	     (display,label,value,form),
			targetid = my_id,
			mode = OM_e_wrt_message);
		as$status( action = RET_STATUS );
	    }
					
	}
	else
	{
	  /*
	   * Initialize field of form to display on the screen
	   * 	- special item number placement
	   *    - general form for place text with balloon
	   */


	   FIg_set_state(form, GAD_AUTO_INC, VDauto_increment);
	   FIg_set_value(form,GAD_IT_NMBR,(double)VDcurrent_item_number);
	   FIg_set_value(form,GAD_IT_QUAN,(double)VDquantity);

	   status =
           om$send(msg = message COanplace.process_bln_form
					       (display,label,value,form),
		  targetid = my_id,
		  mode = OM_e_wrt_message);
	   as$status( action = RET_STATUS );

	}

	return(status);
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */ 
method LC_selection(IGRint *msg; struct GRlc_info *lc_info)
{
IGRint		status = OM_S_SUCCESS,
		i,
		count;
struct GRid	*obj;

  *msg = OM_S_SUCCESS;
  status = OM_S_SUCCESS;

  if( me->state == WAIT_MAC ){

    count = 0;
    as$start_fence(	set		= &lc_info->located_obj,
			nb_obj		= &count,
			p_obj		= &obj,
			response	= NULL,
			response_data	= NULL );

    for( i=0; i<count; i++ ){
      *msg = DMancestry_valid(obj[i], OPP_ACncpx_class_id);
      if(*msg == OM_S_SUCCESS) break;
    }
    ASend_fence();
  }
  else{ 
    status =
    om$send(msg = message VDCmdAnnot.LC_selection(msg,lc_info),
	    targetid = my_id,
	    mode = OM_e_wrt_message);
    as$status( action = RET_STATUS );
  }

  return status ;
}

method place_dimension()
{
IGRint		status = OM_S_SUCCESS,
		rc,
		i,
		count,
		item_used,
		item_quantity;
IGRlong		loc_msg,
		loc1_msg;
IGRchar		item_string[80];
struct GRid	*obj,
		null_grid,
		item_id,
		foot;
enum GRdpmode	dpmode = GRhd;

  /*
   * call the main place_dimension method first and then connect the
   * macros to the item number.
   */
  status =
  om$send(msg = message COanplace.place_dimension(),
	  targetid = my_id,
	  mode = OM_e_wrt_message);
  as$status(action = RET_STATUS);

  if( me->an_grid.objid == NULL_OBJID ) return OM_S_SUCCESS;

  /*
   * connect all macros to the place item
   */ 
  count = 0;
  as$start_fence(	set		= &me->hdr_set.obj_id,
			nb_obj		= &count,
			p_obj		= &obj,
			make_source	= TRUE,
			response	= NULL,
			response_data	= NULL );

  item_used = 0;
  for( i=0; i<count; i++ ){
    loc_msg = DMancestry_valid( obj[i], OPP_ACncpx_class_id);
    loc1_msg = DMancestry_valid(obj[i], OPP_ACpretendin_class_id);

    if( (loc_msg & OM_S_SUCCESS ) || (loc1_msg & OM_S_SUCCESS) ){
      status =
      VDget_drawing_item_info_opt(	obj+i,
					&item_id,
					item_string,
					&item_quantity,
					&me->md_env);
      if(status&1){

	char mess[80];
	status =
        om$send(msg = message GRgraphics.GRdisplay
					(&loc_msg,
					 &me->md_env.md_env.matrix_type,
				         me->md_env.md_env.matrix,&dpmode,
					 &me->md_env.md_id),
		targetid = obj[i].objid,
		targetos = obj[i].osnum);

	status =
	om$send(msg = message GRgraphics.GRdisplay
					(&loc_msg,
					 &me->md_env.md_env.matrix_type,
				         me->md_env.md_env.matrix,&dpmode,
					 &me->md_env.md_id),
		targetid = item_id.objid,
		targetos = item_id.osnum);

	sprintf( mess,
		"Highlighted element already has item number %s",
		item_string);
	UI_status(mess);
      }
      else{
	char st_quantity[80];

	item_used = 1;

        status =
	om$send(msg = message NDmacro.ACreturn_foot
                                  (&loc_msg,"quantity",&foot,NULL,NULL),
		targetid = obj[i].objid,
		targetos = obj[i].osnum);
	if( status&loc_msg&1 ){
    	  if( VDquantity > 0 ) sprintf(st_quantity,"%d",VDquantity);
    	  else st_quantity[0] = '\0';
    	  if(status&loc_msg&1){
       	    status =
	    om$send(msg = message expression.modify(NULL,st_quantity,
                                                (short *) &loc_msg),
                    targetid = foot.objid,
                    targetos = foot.osnum);
	  }
	}

	status=
	om$send(msg = message NDnode.NDconnect(1,obj+i,null_grid,ND_NEW),
		targetid = me->an_grid.objid,
		targetos = me->an_grid.osnum);
	as$status(action = RET_STATUS);
      }
    }
  }

  ASend_fence();

  /*
   * put the item number as the dimensional text
   */

  if( item_used ){

    sprintf( item_string, "%d", VDcurrent_item_number );
    status =
    om$send(msg = message DMroot.replace_text(
                                        &rc,
                                        DIM_TEXT,
                                        (struct GRid *) NULL,
                                        &me->dyn_env,
                                        strlen(item_string),
                                        (IGRuchar *)item_string),
            targetid = me->an_grid.objid,
            targetos = me->an_grid.osnum);

    status =
    om$send( msg = message VDitbln.VDset_item_number (VDcurrent_item_number),
             targetid = me->an_grid.objid,
             targetos = me->an_grid.osnum);
		
  }
  else{
    status =
    om$send(msg = message VDCmdAnnot.delete_dimension (),
            targetid = my_id);

    me->an_grid.objid = NULL_OBJID;
  }

  return status;
}

method display_dimension(int ele; int type)
{
IGRint		status = OM_S_SUCCESS;

  status =
  om$send(msg = message VDCmdAnnot.display_dimension(ele,type),
	  targetid = my_id,
	  mode = OM_e_wrt_message);
  if( type & ADDWRNG  && VDauto_increment ){
    VDcurrent_item_number++;
    if( me->form_display )
      FIg_set_value(me->form,GAD_IT_NMBR, (double) VDcurrent_item_number);
  }

  return status;
}

end implementation VDCmditbln;
