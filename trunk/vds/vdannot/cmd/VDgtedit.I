/* $Id: VDgtedit.I,v 1.1.1.1 2001/01/04 21:07:40 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdannot/cmd / VDgtedit.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDgtedit.I,v $
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
# Revision 1.2  1996/05/09  22:37:30  pinnacle
# Replaced: vdannot/cmd/VDgtedit.I for:  by yzhu for vds.240
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
 *      05/07/96        yzhu            change all VDtxbox to VDfrmtxt
 * -------------------------------------------------------------------*/

/*

Revision :  rmn

     modified execute method :
          - updating of instance data (item number) of VDitbln object
          - disabling editing of associative text with leader          
*/

class implementation COgtedit;

#include "igr.h"
#include "igrdp.h"
#include "dpstruct.h"
#include "dpdef.h"
#include "dimfont.h"
#include "fontmacros.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"

#define AS_DEBUG     1 
#define UPDT_TEXT     0x0000
#define ck_status(a)     {if( a != FI_SUCCESS) return(OM_E_ABORT);}

from DMframe import get_profile_type;
from DMframe import set_tol_mode;
from VDitbln import VDset_item_number;

method execute(int *response; char *response_data; int pos)
{
     IGRint status, status1;
     IGRlong long_rc;
     IGRint mod_batch, msgkey;
     IGRint updt_flag = 0;
     Form active_form;
     IGRshort current_index;
     char classname[OM_K_MAXCLASS_LEN];
     int i, number, valid, text_length;

     while (TRUE)
     {
          switch (me->state)
          {
               /*********************/
               case STATE_P_LOC_DIM:
               /*********************/

               me->gt_grid.objid = NULL_OBJID;

               status =
               om$send(msg = message COdim.locate_parent(
                                   response,
                                   response_data,
                                   &me->dim_event,
                                   TRUE,
                                   DM_P_LocFrEd,
                                   DM_P_AccElt,
                                   DM_P_LocFrEd),
                    targetid = my_id);
               dm$status(action = RET_STATUS);

               if (me->locate_rc == LC_OBJ_LOCATED)
               {
                    me->state = STATE_P_POS_TEXT;
                    me->gt_grid = 
                    me->dim_event.located_object[0].located_obj;


               /* if class is subclassed from VDfrmtxt or VDtxbox,
                  return after displaying msg 
               */

                    status = om$get_classname( osnum     = me->gt_grid.osnum,
                                               objid     = me->gt_grid.objid,
                                               classname = classname );
                    dm$status();

                    status = status1 = 0;

                    status = om$is_ancestry_valid( subclassname = classname,
                                              superclassname = "VDfrmtxt" );

                    status1 = om$is_ancestry_valid( subclassname = classname,
                                              superclassname = "VDtxbox" );

                    if( status == OM_S_SUCCESS || status1 == OM_S_SUCCESS)
                    {
                         UI_status( "Cannot edit associative text" );
                         me->state = STATE_P_LOC_DIM;
					break;
                    }

                    status=
                    om$send(msg = message COgtedit.load_data(),
                         targetid = my_id);
                    dm$status(action = RET_STATUS);

                    /*"dim type = %d\n", me->dim_type*/

                    if(me->dim_type == FEATURE_CONTROL_FRAME)
                    {
                         status =
                         om$send(msg = message DMframe.get_profile_type(
                                        &me->tol_sym),
                              targetid = me->gt_grid.objid,
                              targetos = me->gt_grid.osnum);
                         dm$status(action = RET_STATUS);
                              
                         /*" get_profile type:%d\n", me->tol_sym*/
                    }

                    if ((me->dim_type == FEATURE_CONTROL_FRAME)
                    ||  (me->dim_type == WELD)
                    ||  (me->dim_type == SURF))
                    {
                         status =
                         om$send(msg = message COgtedit.display_form(),
                              targetid = my_id);
                         dm$status(action = RET_STATUS);
                    }

                    if ((me->dim_type != TEXT_WITH_BALLOON)
                    &&  (me->dim_type != WELD)
                    &&  (me->dim_type != SURF))
                    {
                         status =
                         om$send(msg = message COgtedit.get_char_under(&me->dim_event),
                              targetid = my_id);
                         dm$status(action = RET_STATUS);
                    }
               }
               break;
               /*********************/
               case STATE_P_POS_TEXT:
               /*********************/
               dp$erase_hilite(msg = &long_rc);

               status =
               dm$get_dim_param(
                    type = DM_MISC_PARAM,
                    p_data = (char *) &me->dyn_info.info.par_misc);
               dm$status(action = RET_STATUS);

               if ((me->dim_type != WELD)
               &&  (me->dim_type != SURF)
               &&  (me->dim_type != TEXT_WITH_BALLOON))
               {
                    status =
                    om$send(msg =message COgtedit.position_cursor(),
                              targetid = my_id);
                    dm$status(action = RET_STATUS);
               }

               if ((me->dim_type == WELD)
               ||  (me->dim_type == SURF))
               {
                    me->mask1 &= ~GRm_STRING;
                    me->mask2 &= ~GRm_STRING;
                    msgkey = DM_P_ChgFormDataM;
               }
               else
               {
                    me->mask1 |= GRm_STRING;
                    me->mask2 |= GRm_STRING;
                    msgkey = DM_P_EnSbTx;
               }

               status =
               om$send(msg = message COdim.getevent(
                                   msgkey,
                                   response,
                                   response_data,
                                   &me->event1),
                    targetid = my_id);
               dm$status(action = RET_STATUS);

               if ((*response == EX_CHAR) || (*response == EX_STRING))
               {
                    /*^
                                        int i;
                         printf(" response:%d\n",*response);
                         for( i = 0; i<me->nbytes;i++)
                         printf("byte[%d]:%d\n",i,response_data[i]);
                    */

                    if ((me->dim_type != TEXT_WITH_BALLOON)
                    &&  (me->dim_type != WELD)
                    &&  (me->dim_type != SURF))
                    {
                         /*|- Make annot text*/

                         DMmake_annot_text(me->dyn_info.info.text_string,
                                &me->dyn_info.info.text_length,
                                &me->dyn_info.info.text_buff_size,
                                &me->dyn_info.info.text_st.estx,
                                AN_NORMAL,
                                response_data,
                                me->nbytes,
                                &me->dyn_info.info.gtattr,
                                me->dual_mode,
                                me->dim_type,
                                (IGRshort)me->dyn_info.info.par_misc.sixteen_bit_font,
                                &current_index,
                                &updt_flag,
                                3); /* bln_limit */

                         if(updt_flag == UPDT_TEXT)
                         {
                              updt_flag = 0;
                              break;
                         }
                          if( updt_flag & SET_SINGLE_MODE)
                         {
                              /*| set single mode */
                              status=
                              om$send(msg = message DMframe.set_tol_mode(DUAL_MODE_OFF),
                                        targetid = me->gt_grid.objid,
                                        targetos = me->gt_grid.osnum);
                              dm$status(action = RET_STATUS);
                              me->dual_mode = DUAL_MODE_OFF;
                              status = FIg_enable(me->form,TOL_SYMB_DUAL_LINE);
                              if(status != FI_SUCCESS)
                                   printf("FIg_enable fails:%d\n",status);
                         }
                         else if( updt_flag & SET_DUAL_MODE)
                         {
                              /*| set dual mode */
                              status=
                              om$send(msg = message DMframe.set_tol_mode(DUAL_MODE_ON),
                                        targetid = me->gt_grid.objid,
                                        targetos = me->gt_grid.osnum);
                              dm$status(action = RET_STATUS);
                              me->dual_mode = DUAL_MODE_ON;
                              status = FIg_disable(me->form,TOL_SYMB_DUAL_LINE);
                              if(status != FI_SUCCESS)
                                   printf("FIg_enable fails:%d\n",status);     

                              if((me->dyn_info.info.text_length + 2) < me->dyn_info.info.text_buff_size)
                              {
                                   int length;
                                   length = me->dyn_info.info.text_length;
                                   me->dyn_info.info.text_string[length++] = 27;
                                   me->dyn_info.info.text_string[length++] = 'E';
                                    me->dyn_info.info.text_length  = length;
                                   DMupdt_disp_chars(me->dyn_info.info.text_string,
                                               &me->dyn_info.info.text_length,
                                               &me->dyn_info.info.gtattr,
                                               me->dual_mode,
                                               FEATURE_CONTROL_FRAME);
                              }
                         }
                    }

                    mod_batch = ND_IMMEDIATE;
                    status =
                    DMmod_graph_batch_cp(GET_MODE | SET_MODE, NULL, NULL, &mod_batch);
                    dm$status(action = RET_STATUS);
                    
                    if (me->dim_type == TEXT_WITH_BALLOON)
                    {

				/* 
				 * check for classname : if VDitbln, validate string and 
				 * update item number
				 */

                    status = om$is_ancestry_valid( subclassname = classname,
                                              superclassname = "VDitbln" );
				if( status == OM_S_SUCCESS )
				{

               	/* validate text string : only integers are acceptible */

                         text_length = me->nbytes - 1;

					valid = 1;
                         if( response_data[0] == '\0' )
                         {
						UI_status( "Invalid entry" );
						valid = 0;
                         }

                         for(i = 0 ; i < text_length ; i++ )
                              if( !isdigit( response_data[i] ) )
                              {
                                   UI_status( "Invalid item number" );
                                   valid = 0;
                              }
					if( valid == 0)
					{
						me->state = STATE_P_POS_TEXT;
						break;
					}

                         number = atoi( response_data );

                    /*
                     * update the item number of the balloon object
                     */

                         status = om$send( msg = message 
                                           VDitbln.VDset_item_number( number ),
                                           targetid = me->gt_grid.objid ,
                                           targetos = me->gt_grid.osnum );
                         dm$status( action = RET_STATUS );
				}

                         status =
                         om$send(msg = message COgtedit.update_balloon(
                                        me->nbytes - 1,
                                        response_data),
                              targetid = my_id);
                         dm$status();
                    }
                    else if ((me->dim_type != WELD) && (me->dim_type != SURF))
                    {
                         status =
                         om$send( msg = message COgtedit.update_feature(),
                              targetid = my_id);
                         dm$status(action = RET_STATUS);
                    }

                    updt_flag = 0;
                    status =
                    DMmod_graph_batch_cp(GET_MODE | SET_MODE, NULL, NULL, &mod_batch);
                    dm$status(action = RET_STATUS);
               }
               else if(*response == DATA)
               {
                    status =
                    om$send(msg = message COgtedit.get_char_under(&me->event1),
                         targetid = my_id);
                    dm$status(action = RET_STATUS);
               }
               else if( *response == RESET)
               {
                    if (me->form_display)
                    {
                         if (me->dim_type == WELD)
                              active_form = me->weldform;
                         else if (me->dim_type == SURF)
                              active_form = me->surfform;
                         else     active_form = me->form;

                         status = FIf_erase(active_form);
                         ck_status(status);
                         me->form_display = FALSE;
                    }

                    status = dp$erase_hilite(msg= &long_rc);
                    me->state = STATE_P_LOC_DIM;
                    me->gt_grid.objid = NULL_OBJID;
               }
               break;

               /******/
               default:
               /******/

               printf("COgtedit: Unknown state %d\n", me->state);
               *response = TERMINATE;
               return(OM_S_SUCCESS);
          }

          switch (*response)
          {
               case DATA:
               case RESET:
               case D_RESET:
               case MOVE_ON:
               case EX_CHAR:
               case EX_STRING:
               break;

               case STATUS_DISP:
               break;

               case TERMINATE:

               if (me->gt_grid.objid != NULL_OBJID)
               {
                    status =
                    om$send(msg = message COgtedit.display_dimension(GRbd),
                         targetid = my_id);
                    dm$status(action = RET_STATUS);

                    nd$exec_batch();
               }

               default:
               return(OM_S_SUCCESS);
          }
     }
}
end implementation COgtedit;

