/* $Id: VDEdTbRwFrm.I,v 1.3 2001/05/07 23:42:46 ylong Exp $  */
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdannot/cmd/VDEdTbRwFrm.I
 *
 * Description:
 *      this file includes method: form_notification
 *
 * Dependencies:
 *
 * Revision History:
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      06/01/95        Y.Zhu           Creation
 *	05/02/01	ylong		CR5119 
 * -------------------------------------------------------------------*/
class implementation VDCmdEdTbRw;
#include <stdio.h>
#include <string.h>
#include <memory.h>
#include <malloc.h>
#include <string.h>
#include <stdlib.h>

#include "OMmacros.h"
#include "OMparameters.h"
#include "OMprimitives.h"
#include "grdpbdef.h"
#include "igrdef.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "grdpbmacros.h"
#include "AS_status.h"                  /* define as$status                */

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "FI.h"

#include "VDtblCmdDef.h"
/* #define DEBUG */

from  VDdrwTblRow    import VDgetCurrentRowValues;
from  VDdrwTblRow    import VDisRowLinedOut;
from  GRcontext      import GRgetinstance;
from  GRgraphics     import GRdisplay;
from  NDmacro        import ACreturn_foot;

#define	MAXCOLUMNS	200
%safe
static	IGRint	colSelected[MAXCOLUMNS];
%endsafe

/*+mo
******************************************************************************

Method:

    form_notification

Description:

    This method supports the edit table row form.

Arguments
        int           form_label;     label of form which received user  input
        int           gadget_label;   gadget label  which received user  input
        double        value;          value of gadget ( or field row # )
        Form          form_ptr ;      ptr to I/Forms form which received input

Override:

    from CEO form_notification

******************************************************************************
-mo*/
method form_notification ( int    form_label;
                           int    gadget_label;
                           double value;
                           Form   form_ptr )
{
IGRint          status = OM_S_SUCCESS;
IGRlong         sts, msg;
IGRint          sel_flag = FALSE, direct, sel, pos, row, col;
IGRint          rowInd, rvtAll = 0;
IGRshort        isLinedOut;
IGRdouble       nbShiftCol;
IGRint		maxLen = 4096;
IGRchar		buf[4096], msgStr[80];
IGRint		nbDatRecs = 0, nbNewDatRecs = 0, objIndex, i, j;

#ifdef DEBUG
        printf("form_notification\n");
#endif
       switch (gadget_label){
	case FI_CANCEL:
			#ifdef DEBUG
            			printf(" FI_CANCEL \n");
			#endif
            dp$erase_hilite (msg = &sts);
	    me->rep_label = VD_ETR_FORM_CANCEL;
            _put_response( resp = EX_FORM_FINISHED );
            break;

       	case FI_EXECUTE:
			#ifdef DEBUG
            			printf(" FI_EXECUTE \n");
			#endif
            FIfld_set_text( form_ptr, FI_MSG_FIELD, 0, 0, 
                              "", sel_flag);

            status =
            om$send( msg = message VDCmdEdTbRw.VDmodNewValStr( 
                             &sts,
                             me->preStartColInd,
                             me->preVisColNum),
                     mode     = OM_e_wrt_message,
                     targetid = my_id );
            as$status( action = RET_STATUS );

	    me->rep_label = VD_ETR_FORM_EXECUTE;
            _put_response (resp = VD_ETR_FORM_INFO);
            break;

       	case FI_ACCEPT:
			#ifdef DEBUG
            			printf(" FI_ACCEPT \n");
			#endif

            status =
            om$send( msg = message VDCmdEdTbRw.VDmodNewValStr(
                             &sts,
                             me->preStartColInd,
                             me->preVisColNum),
                     mode     = OM_e_wrt_message,
                     targetid = my_id );
            as$status( action = RET_STATUS );

	    me->rep_label = VD_ETR_FORM_ACCEPT;
            _put_response (resp = VD_ETR_FORM_INFO);
            break;

        case VD_ETR_PREV_ROW:
             FIfld_set_text( form_ptr, FI_MSG_FIELD, 0, 0, 
                              "", sel_flag);

             /* check if the row is line out */
             rowInd = me->selRowInd;
             isLinedOut = 1;
             while(rowInd > 0) {
                   rowInd = rowInd - 1;
                   status =
                   _VD_SEND_OBJ(  me->tblRows[rowInd].rowId,
                               VDdrwTblRow.VDisRowLinedOut(&sts,
                                              &isLinedOut ));
                   if(isLinedOut != 1) {
                        me->selRowInd = rowInd + 1;
                        break;
                   }
             }
             if (me->nbShiftCol == 0)  me->nbShiftCol = 1;

             if(me->selRowInd > 0 && isLinedOut == FALSE) {
                 me->selRowInd = me->selRowInd - 1;

                 /* high light previous row */
                 status =
                 om$send( msg = message VDCmdEdTbRw.VDupdatHighlight( 
                                                              &sts, 
                                                              me->selRowInd),
                          mode     = OM_e_wrt_message,
                          targetid = my_id );
                 as$status( action = RET_STATUS );

                 /* set row data struct */ 
                 status =
                 om$send( msg = message VDCmdEdTbRw.VDsetRowDataStr( 
                                                              &sts, 
                                                              me->selRowInd),
                     mode     = OM_e_wrt_message,
                     targetid = my_id );
                 as$status( action = RET_STATUS );
    
    		 /* update columns in view area*/
  
                 status =
                 om$send( msg = message VDCmdEdTbRw.VDupdVisCols(
                              &sts,
                              &me->preStartColInd,
                              &me->preVisColNum,
                              &me->newStartColInd,
                              &me->newVisColNum),
                     mode     = OM_e_wrt_message,
                     targetid = my_id );
                 as$status( action = RET_STATUS );
             }    
             else {
              FIfld_set_text( form_ptr, FI_MSG_FIELD, 0, 0, 
                              "No previous row", sel_flag);
             }
	     me->rep_label = VD_ETR_FORM_PREVROW;
             _put_response (resp = VD_ETR_FORM_INFO);
             break;

        case VD_ETR_NEXT_ROW:
             FIfld_set_text( form_ptr, FI_MSG_FIELD, 0, 0, 
                              "", sel_flag);

             /* check if the row is line out */
             rowInd = me->selRowInd;
             isLinedOut = 1;
             while(rowInd < me->nbRows - 1) {
                   rowInd = rowInd + 1;
                   status =
                   _VD_SEND_OBJ(  me->tblRows[rowInd].rowId,
                               VDdrwTblRow.VDisRowLinedOut(&sts,
                                              &isLinedOut ));
                   if(isLinedOut != 1) {
                        me->selRowInd = rowInd - 1;
                        break;
                   }
             }

             if (me->nbShiftCol == 0)  me->nbShiftCol = 1;
             if(me->selRowInd < me->nbRows - 1 && isLinedOut == FALSE) {
                 me->selRowInd = me->selRowInd + 1;

                 /* high light next row */
                 status =
                 om$send( msg = message VDCmdEdTbRw.VDupdatHighlight(
                                                              &sts,
                                                              me->selRowInd),
                          mode     = OM_e_wrt_message,
                          targetid = my_id );
                 as$status( action = RET_STATUS );

                 /* set row data struct */
                 status =
                 om$send( msg = message VDCmdEdTbRw.VDsetRowDataStr(
                                                              &sts,
                                                              me->selRowInd),
                     mode     = OM_e_wrt_message,
                     targetid = my_id );
                 as$status( action = RET_STATUS );

                 /* update columns in view area*/

                 status =
                 om$send( msg = message VDCmdEdTbRw.VDupdVisCols(
                              &sts,
                              &me->preStartColInd,
                              &me->preVisColNum,
                              &me->newStartColInd,
                              &me->newVisColNum),
                          mode     = OM_e_wrt_message,
                          targetid = my_id );
	        as$status( action = RET_STATUS );
             }
             else {
              FIfld_set_text( form_ptr, FI_MSG_FIELD, 0, 0,
                              "No next row", sel_flag);
             }
	     me->rep_label = VD_ETR_FORM_NEXTROW;
             _put_response (resp = VD_ETR_FORM_INFO);
             break;


	case VD_ETR_SCRL_LIF_BTN: 
             FIfld_set_text( form_ptr, FI_MSG_FIELD, 0, 0, 
                              "", sel_flag);

            /* modify new row struct */

            status =
            om$send( msg = message VDCmdEdTbRw.VDmodNewValStr(
                             &sts,
                             me->preStartColInd,
                             me->preVisColNum),
                     mode     = OM_e_wrt_message,
                     targetid = my_id );
            as$status( action = RET_STATUS );

	    /* get col info */
    	    direct = 0;
           
            FIfld_get_value( VD_FP, VD_ETR_SHIF_COL_NUM, 0, 0, 
                             &nbShiftCol, &sel, &pos );
            me->nbShiftCol = (int) nbShiftCol;

            if( me->preStartColInd - me->nbShiftCol < 0)  {
                me->nbShiftCol = me->preStartColInd;
                __DBGpr_int( "me->nbShiftCol",  me->nbShiftCol );
                me->rep_label = VD_ETR_SCRL_LIF_BTN;
                _put_response (resp = VD_ETR_FORM_INFO);
                if(!me->nbShiftCol) { 
                   me->nbShiftCol = 1;
                   FIfld_set_value( VD_FP, VD_ETR_SHIF_COL_NUM, 0, 0, 
                             (double)me->nbShiftCol, FALSE);
                   FIfld_set_text( form_ptr, FI_MSG_FIELD, 0, 0, 
                     "Can not shift to left", sel_flag);
                   break;
                }
            }

            status =
            om$send(msg = message VDCmdEdTbRw.VDgetVisColsInfo(
                              &sts,
                              me->preStartColInd,
                              me->preVisColNum,
                              &me->newStartColInd,
                              &me->newVisColNum,
                              me->nbShiftCol,
                              direct),
                 mode     = OM_e_wrt_message,
                targetid = my_id );
            as$status( action = RET_STATUS );

            /* update columns in view area*/
            status =
            om$send(msg = message VDCmdEdTbRw.VDupdVisCols(
                              &sts,
                              &me->preStartColInd,
                              &me->preVisColNum,
                              &me->newStartColInd,
                              &me->newVisColNum),
                 mode     = OM_e_wrt_message,
                targetid = my_id );
            as$status( action = RET_STATUS );

	    for( i = 1; i <= me->newVisColNum; i++ ) 
	    {
		sel = colSelected[i+me->newStartColInd];
                FIfld_set_select( form_ptr, VD_ETR_VIS_TIT_ROW, 0, i, sel );
	    }

            me->rep_label = VD_ETR_SCRL_LIF_BTN;
            _put_response (resp = VD_ETR_FORM_INFO);
            break;

	case VD_ETR_SCRL_RIG_BTN:
                        #ifdef DEBUG
                                printf(" VD_ETR_SCRL_RIG_BTN \n");
                        #endif
             FIfld_set_text( form_ptr, FI_MSG_FIELD, 0, 0, "", sel_flag);

            /* modify new row struct */
            status =
            om$send( msg = message VDCmdEdTbRw.VDmodNewValStr(
                             &sts,
                             me->preStartColInd,
                             me->preVisColNum),
                     mode     = OM_e_wrt_message,
                     targetid = my_id );
            as$status( action = RET_STATUS );

            /* get col info */
            direct = 1;
            FIfld_get_value( VD_FP, VD_ETR_SHIF_COL_NUM, 0, 0, 
                             &nbShiftCol, &sel, &pos );
            me->nbShiftCol = (int) nbShiftCol;

            if( me->preStartColInd + me->nbShiftCol > 
                                  me->nbTotalCol - 1)  {
                me->nbShiftCol = me->nbTotalCol - 1 - me->preStartColInd;
                __DBGpr_int( "me->nbShiftCol",  me->nbShiftCol );
                me->rep_label = VD_ETR_SCRL_RIG_BTN;
                _put_response (resp = VD_ETR_FORM_INFO);
                if( !me->nbShiftCol) { 
                   me->nbShiftCol = 1;
                   FIfld_set_value( VD_FP, VD_ETR_SHIF_COL_NUM, 0, 0, 
                             (double)me->nbShiftCol, FALSE);
                   FIfld_set_text( form_ptr, FI_MSG_FIELD, 0, 0, 
                    "Can not shift to right", sel_flag);
                   break;
                }
            }

            status =
            om$send(msg = message VDCmdEdTbRw.VDgetVisColsInfo(
                              &sts,
                              me->preStartColInd,
                              me->preVisColNum,
                              &me->newStartColInd,
                              &me->newVisColNum,
                              me->nbShiftCol,
                              direct),
                    mode = OM_e_wrt_message,
                    targetid = my_id );
            as$status( action = RET_STATUS );

            /* update columns in view area */
            status =
            om$send(msg = message VDCmdEdTbRw.VDupdVisCols(
                              &sts,
                              &me->preStartColInd,
                              &me->preVisColNum,
                              &me->newStartColInd,
                              &me->newVisColNum),
                    mode = OM_e_wrt_message,
                    targetid = my_id );
            as$status( action = RET_STATUS );

	    for( i = 1; i <= me->newVisColNum; i++ ) 
	    {
		sel = colSelected[i+me->newStartColInd];
                FIfld_set_select( form_ptr, VD_ETR_VIS_TIT_ROW, 0, i, sel );
	    }

            me->rep_label = VD_ETR_SCRL_RIG_BTN;
            _put_response (resp = VD_ETR_FORM_INFO);
            break;

	case VD_ETR_RVT_ROW_TGL:	/* added for CR5119, by ylong */
	    for( i = 0; i < me->newVisColNum; i++ ) 
	    {
                FImcf_set_select( form_ptr, VD_ETR_VIS_TIT_ROW, 0, FALSE );
	    }

	    for( i = 0; i < MAXCOLUMNS; i++) 
	    {
		colSelected[i] = FALSE;
	    }
            break;

	case VD_ETR_VIS_TIT_ROW:	/* added for CR5119, by ylong */
            FIfld_set_text( form_ptr, FI_MSG_FIELD, 0, 0, "", sel_flag);
	    FIg_get_state( form_ptr, VD_ETR_RVT_ROW_TGL, &rvtAll ); 
	    FImcf_get_active_col(form_ptr, VD_ETR_VIS_TIT_ROW, &col, &pos);
	    FIfld_get_active_row(form_ptr, VD_ETR_VIS_TIT_ROW, &row, &pos);
	    FIfld_get_select(form_ptr, VD_ETR_VIS_TIT_ROW, row, col, &sel);
	    if( !rvtAll ) 
	    {
		msgStr[0] = '\0';
		if( me->datRecs[me->newStartColInd + col-1].rectyp == 
			VD_DRWLO_EN_USERDEFINED)
		{
		   strcpy(msgStr, "The field is User Defined");
		   sel = FALSE;
		}
		else if(me->datRecs[me->newStartColInd + col-1].rectyp ==
				VD_DRWLO_EN_ITEMNO )
		{
		   strcpy(msgStr, "The field is Item Number");
		   sel = FALSE;
		}
		FIfld_set_text( form_ptr, FI_MSG_FIELD, 0, 0, msgStr, sel_flag);
		FIfld_set_select(form_ptr, VD_ETR_VIS_TIT_ROW, row, col, sel);
		colSelected[me->newStartColInd + col] = sel;
	    }
	    else 
	    {
                FImcf_set_select( form_ptr, VD_ETR_VIS_TIT_ROW, 0, sel );
		for( i = 0; i < me->nbTotalCol; i++) 
		{
		   colSelected[me->datRecs[i].colno] = sel;
		}
	    }
            me->rep_label = VD_ETR_VIS_TIT_ROW;
            _put_response (resp = VD_ETR_FORM_INFO);
            break;

		
	case VD_ETR_RVT_ROW_BTN:	/* added for CR5119, by ylong */
	    nbDatRecs = om$dimension_of( varray = me->datRecs );
	    nbNewDatRecs = om$dimension_of( varray =  me->newRowData) ;
	    objIndex = me->tblRows[me->selRowInd].startIndex ;

	    for( i = 0; i < nbDatRecs; i++) 
	    {
		if( !colSelected[me->datRecs[i].colno] ) continue;
		for( j = 0; j < nbNewDatRecs; j++ ) 
		{
		   if( me->newRowData[j].colNos == me->datRecs[i].colno &&
		       me->datRecs[i].rectyp != VD_DRWLO_EN_USERDEFINED ) 
		   {
			_FREE( me->newRowData[j].values );
			status = VDdrw_getFldValue( &msg,
                                    me->tblRows[me->selRowInd].nbObjs,
                                    &me->locObjs[objIndex],
                                    me->datRecs[i],
                                    me->tblRows[me->selRowInd].qty,
                                    &me->tblRows[me->selRowInd].rowId,
                                    &me->newRowData[j].values );
		   }
		}
	    }

	    /* update columns in view area*/
	    status =
	    om$send (	msg	 = message VDCmdEdTbRw.VDupdVisCols(
							&msg,
							&me->preStartColInd,
							&me->preVisColNum,
							&me->newStartColInd,
							&me->newVisColNum),
			mode     = OM_e_wrt_message,
			targetid = my_id );
	    as$status( action = RET_STATUS );

            FImcf_set_select( form_ptr, VD_ETR_VIS_TIT_ROW, 0, FALSE );

	    for( i = 0; i < MAXCOLUMNS; i++) 
	    {
		colSelected[i] = 0;
	    }

            me->rep_label = VD_ETR_RVT_ROW_BTN;
            _put_response (resp = VD_ETR_FORM_INFO);
            break;

        default:
                break;

      } /* switch */ 
quit:
  return status;

} /* form_notification */
/*+me
 ---------------------------------------------------------------------------

  Message VDupdVisCols

  Abstract
        This method updates columns in view area according to view starting
        column index and visiable column number. 

  Arguments
        IGRlong         *sts            O       Return code
        IGRint          preStartColInd  I       previous starting Col index 
                                                which is visiable
        IGRint          preVisColNum    I       previous visable Col number  
        IGRint          newStartColInd  I       new starting Col index 
                                                which is visiable
        IGRint          newVisColNum    I       new visable Col number  

  Status/Return Code
      status == OM_S_SUCCESS

 ---------------------------------------------------------------------------
-me*/
method VDupdVisCols(  	    IGRlong         *msg;
                            IGRint          *preStartColInd;
                            IGRint          *preVisColNum;
                            IGRint          *newStartColInd;
                            IGRint          *newVisColNum)
{
    IGRint              i, attr_mask,j, nbVisCols;
    char                rowno[10];
    IGRlong             status = OM_S_SUCCESS;
    IGRint              xlo, ylo, xhi, yhi; 
    IGRint              nbFixRecs, nbDatRecs, nbCols;
    struct VDdrw_colInfo   *colRecs = NULL;
    IGRint              objIndex, i0, line, col;
    IGRchar             *fldVal = NULL;
    IGRint              size,  nbrow = 0;

  SetProc( VDCmdEdTbRw.VDupdVisCols); Begin
  *msg = MSSUCC;
 
  if( (*preVisColNum) != (*newVisColNum) || 
                          (*preStartColInd) != (*newStartColInd) ) {

  /* delete previous columns */

  for(i = 0; i < (*preVisColNum); i++) { 

      FImcf_get_num_vis_cols( VD_FP, VD_ETR_VIS_TIT_ROW, &nbVisCols);
      nbVisCols --;

      FImcf_delete_col( VD_FP, VD_ETR_VIS_TIT_ROW, (*preVisColNum) - i );
      FImcf_delete_col( VD_FP, VD_ETR_VIS_ORI_ROW, (*preVisColNum) - i );
      FImcf_delete_col( VD_FP, VD_ETR_VIS_NEW_ROW, (*preVisColNum) - i );

      FImcf_set_num_vis_cols( VD_FP, VD_ETR_VIS_TIT_ROW, nbVisCols);
      FImcf_set_num_vis_cols( VD_FP, VD_ETR_VIS_ORI_ROW, nbVisCols);
      FImcf_set_num_vis_cols( VD_FP, VD_ETR_VIS_NEW_ROW, nbVisCols);

      FIg_activate( VD_FP, VD_ETR_VIS_TIT_ROW );
      FIg_activate( VD_FP, VD_ETR_VIS_ORI_ROW );
      FIg_activate( VD_FP, VD_ETR_VIS_NEW_ROW );

      FIg_display( VD_FP, VD_ETR_VIS_TIT_ROW );
      FIg_display( VD_FP, VD_ETR_VIS_ORI_ROW );
      FIg_display( VD_FP, VD_ETR_VIS_NEW_ROW );
   }
    
   /* 
    * insert new columns 
    */

   for ( i = 0; i < (*newVisColNum); i ++ ) {  

       /* column title */
       FImcf_insert_col( VD_FP, VD_ETR_VIS_TIT_ROW, i + 1, 
                    me->colWidth[i+(*newStartColInd)], FI_MULTI_SELECT, FI_ALPHA );
       FIg_activate( VD_FP, VD_ETR_VIS_TIT_ROW );
       FIfld_set_num_vis_chars( VD_FP, VD_ETR_VIS_TIT_ROW, i + 1,
                         me->colWidth[i+(*newStartColInd)] );
       FIfld_get_attr( VD_FP, VD_ETR_VIS_TIT_ROW, i+1, &attr_mask );
       attr_mask = attr_mask | FI_DISPLAY_HSCROLL;
       FIfld_set_attr( VD_FP,  VD_ETR_VIS_TIT_ROW, i+1,  attr_mask );
    
       /* Original column */
       FImcf_insert_col( VD_FP, VD_ETR_VIS_ORI_ROW, i + 1,
		me->colWidth[i+(*newStartColInd)], FI_REVIEW, FI_ALPHA );
       FIg_activate( VD_FP, VD_ETR_VIS_ORI_ROW );
       FIfld_set_num_vis_chars( VD_FP, VD_ETR_VIS_ORI_ROW, i + 1,
                         me->colWidth[i+(*newStartColInd)] );
       FIfld_get_attr( VD_FP, VD_ETR_VIS_ORI_ROW, i+1, &attr_mask );
       attr_mask = attr_mask | FI_HORT_SCROLL | FI_DISPLAY_HSCROLL; 
       FIfld_set_attr( VD_FP,  VD_ETR_VIS_ORI_ROW, i+1, attr_mask );

       /* New column */
       FImcf_insert_col( VD_FP, VD_ETR_VIS_NEW_ROW, i + 1,
			me->colWidth[i+(*newStartColInd)], FI_INSERT, FI_ALPHA );
       FIg_activate( VD_FP, VD_ETR_VIS_NEW_ROW );
       FIfld_set_num_vis_chars( VD_FP, VD_ETR_VIS_NEW_ROW, i + 1,
                         me->colWidth[i+(*newStartColInd)] );
       FIfld_get_attr( VD_FP, VD_ETR_VIS_NEW_ROW, i+1, &attr_mask );
       attr_mask = attr_mask | FI_HORT_SCROLL | FI_DISPLAY_HSCROLL
                             | FI_NOTIFY_BY_LINE;
       FIfld_set_attr( VD_FP,  VD_ETR_VIS_NEW_ROW, i+1, attr_mask );

     
       /* 
        * update the number of visible columns 
        */
       FImcf_get_num_vis_cols( VD_FP, VD_ETR_VIS_TIT_ROW, &nbVisCols);
       nbVisCols++;

       FImcf_set_num_vis_cols( VD_FP, VD_ETR_VIS_TIT_ROW, nbVisCols);
       FImcf_set_num_vis_cols( VD_FP, VD_ETR_VIS_ORI_ROW, nbVisCols);
       FImcf_set_num_vis_cols( VD_FP, VD_ETR_VIS_NEW_ROW, nbVisCols);

       /* activate the gadgets and display them */

       FIg_activate( VD_FP, VD_ETR_VIS_TIT_ROW );
       FIg_activate( VD_FP, VD_ETR_VIS_ORI_ROW );
       FIg_activate( VD_FP, VD_ETR_VIS_NEW_ROW );

       FIg_display( VD_FP, VD_ETR_VIS_TIT_ROW );
       FIg_display( VD_FP, VD_ETR_VIS_ORI_ROW );
       FIg_display( VD_FP, VD_ETR_VIS_NEW_ROW );
    }
  } /* if */

    /* refresh the form */

    FIf_get_size( VD_FP, &xhi, &yhi );
    FIg_get_location( VD_FP, VD_ETR_VIS_ORI_ROW, &xlo, &ylo );
    FIf_paint_area( VD_FP, xlo, ylo, xhi, yhi );
    FIg_get_location( VD_FP, VD_ETR_VIS_NEW_ROW, &xlo, &ylo );
    FIf_paint_area( VD_FP, xlo, ylo, xhi, yhi );

/*    FIfld_set_num_rows(VD_FP, VD_ETR_VIS_NEW_ROW, me->maxLinesPerRow); */
    FIfld_set_max_num_rows( VD_FP, VD_ETR_VIS_NEW_ROW, me->maxLinesPerRow);
    __DBGpr_int( "me->maxLinesPerRow", me->maxLinesPerRow );
    __DBGpr_int( "*newVisColNum", *newVisColNum );

    /*  
     * initialize the all rows to empty string  
     */

    for( i = 0 ; i < (*newVisColNum); i++ ) {
        for( j = 0 ; j < me->maxLinesPerRow ; j++ ){
            FIfld_set_text( VD_FP, VD_ETR_VIS_TIT_ROW, j, i + 1, "", FALSE );
            FIfld_set_text( VD_FP, VD_ETR_VIS_ORI_ROW, j, i + 1, "", FALSE );
            FIfld_set_text( VD_FP, VD_ETR_VIS_NEW_ROW, j, i + 1, "", FALSE );
        } 
    } 

    /*
     * get title column record
     */
    nbFixRecs = om$dimension_of( varray = me->fixDataTextRecs );
    nbDatRecs = om$dimension_of( varray = me->datRecs );

    status =
    VDdrw_getColumnList(        msg,
                                nbFixRecs, nbDatRecs,
                                me->fixDataTextRecs, me->datRecs,
                                &nbCols, &me->maxLinesPerRow,
                                &colRecs );

    __CheckRC( status, *msg, "VDdrw_getColumnList", wrapup );
  

    /* fill title field */
    __DBGpr_com( "     *** fill in title field***   " );

    for( i = 0 ; i < (*newVisColNum); i++ ) {
        j = 0;
        FIfld_set_text(VD_FP, VD_ETR_VIS_TIT_ROW, 0, i+1,
                    colRecs[i+(*newStartColInd)].colTitles[0], FALSE );

		#ifdef DEBUG
            		printf("\n\ti = %d, j = %d, title = %s\n", i, j,
                        colRecs[i+(*newStartColInd)].colTitles[0]);
		#endif
    }

    /* fill in Original field */
    __DBGpr_com( "     *** fill in Original field***   " );

    objIndex = me->tblRows[me->selRowInd].startIndex ;
    FIfld_get_num_rows( VD_FP, VD_ETR_VIS_ORI_ROW, &nbrow ); 

    for( i = 0 ; i < (*newVisColNum); i++ ) {

      __DBGpr_com( "***scan the list of data records***" );

      for( i0 = 0 ; i0 < nbDatRecs ; i0++ ) 
      {
          col =  me->datRecs[i0].colno - 1;
          line = me->datRecs[i0].lineno;

          if( col != i+(*newStartColInd) )   continue;
 
          __DBGpr_int( "Column number", col + 1  );
          __DBGpr_int( "line number", line  );

          _FREE( fldVal );
          fldVal = NULL;

          status = VDdrw_getFldValue( msg,
                                    me->tblRows[me->selRowInd].nbObjs,
                                    &me->locObjs[objIndex],
                                    me->datRecs[i0],
                                    me->tblRows[me->selRowInd].qty,
                                    &me->tblRows[me->selRowInd].rowId,
                                    &fldVal );
          CheckRC( status, *msg );

          __DBGpr_str( "Variable Field Value ", fldVal );

          FIfld_set_text(VD_FP, VD_ETR_VIS_ORI_ROW, line - 1, i+1,
                    fldVal, FALSE );
        } /* for */

        __DBGpr_com( "***scan the list of fiexd records***" );
    
        for( i0 = 0 ; i0 < nbFixRecs ; i0++ ) {

          col =  me->fixDataTextRecs[i0].VD.tx.colno - 1;
          line = me->fixDataTextRecs[i0].VD.tx.lineno;
       
          if( col != i+(*newStartColInd) )   continue;

          __DBGpr_int( "Column number", col + 1  );
          __DBGpr_int( "line number", line );

          __DBGpr_str( "Fixed Field Value ", 
                        me->fixDataTextRecs[i0].VD.tx.Text );

          FIfld_set_text(VD_FP, VD_ETR_VIS_ORI_ROW, line - 1, i+1,
                    me->fixDataTextRecs[i0].VD.tx.Text, FALSE );

        } /* for i0 */

    } /* for i */

    /* fill in New field */
    __DBGpr_com( "     *** fill in New field ***   " );

    size = om$dimension_of( varray = me->newRowData);

    for( i = 0 ; i < (*newVisColNum); i++ ) {
        for( j = 0 ; j < size ; j++ ) {

            col = me->newRowData[j].colNos;
            line = me->newRowData[j].lineNos;

            if ( (col - 1) != i+(*newStartColInd) ) continue;

            FIfld_set_text(VD_FP, VD_ETR_VIS_NEW_ROW, line - 1, i+1,
                    me->newRowData[j].values, FALSE );

            __DBGpr_int( "Column number", col  );
            __DBGpr_int( "line number", line );
            __DBGpr_str( "me->newRowData[j].values",
                          me->newRowData[j].values);
        }
    }

    /* fill in row num field */ 
    rowno[0] = '\0';
    sprintf(rowno, "%d", me->selRowInd + 1);

    FIfld_set_text( VD_FP, VD_ETR_VIS_TIT_ROW, 0, 0, "R.No", FALSE );
    FIfld_set_text( VD_FP, VD_ETR_VIS_ORI_ROW, 0, 0, rowno, FALSE );
    FIfld_set_text( VD_FP, VD_ETR_VIS_NEW_ROW, 0, 0, rowno, FALSE );

    /* fill in shift col number filed */
    FIfld_set_value( VD_FP, VD_ETR_SHIF_COL_NUM, 0, 0, 
          (double)me->nbShiftCol, FALSE );

    /* renew start point */
    (*preStartColInd) = (*newStartColInd);
    (*preVisColNum)   = (*newVisColNum);

wrapup:
    for( i = 0 ; i < nbCols ; i++ )
        _FREE( colRecs[i].colTitles );
    _FREE( colRecs );
    _FREE( fldVal );

    End
    return status;
} /* VDupdVisCols */
/*+me
 ---------------------------------------------------------------------------

  Message VDsetRowDataStr

  Abstract
        This method updates columns in view area according to view starting
        column index and visiable column number.

  Arguments
        IGRlong         *sts            O       Return code
        IGRint          selRowInd       I       selected row index

  Status/Return Code
      status == OM_S_SUCCESS if success

 ---------------------------------------------------------------------------
-me*/
method VDsetRowDataStr( IGRlong  *sts;
                        IGRint   selRowInd)
{
IGRlong                         status = OM_S_SUCCESS;
IGRint                          i, size,len;
IGRint                          nbValues,
                                *lineNos = NULL,
                                *colNos = NULL;
IGRchar                         **values = NULL;

    SetProc( VDCmdEdTbRw.VDsetRowDataStr); Begin
    *sts = MSSUCC;
     
 
    /* set current structure  current values*/
    status =
    _VD_SEND_OBJ( me->tblRows[me->selRowInd].rowId,
                             VDdrwTblRow.VDgetCurrentRowValues(
                                                                sts,
                                                                &nbValues,
                                                                &lineNos,
                                                                &colNos,
                                                                &values ) );

    __CheckRC( status, *sts, "VDdrwTblRow.VDgetCurrentRowValues", wrapup );
    __DBGpr_int( "# of values in VDgetCurrentRowValues", nbValues );

	#ifdef DEBUG
          for( j = 0 ; j < nbValues ; j++ )
           printf( "\t\t\t(%d, %d) = %s\n", lineNos[j], colNos[j], values[j] );
	#endif

 
   /* free previous memery allocation */
    size = om$dimension_of( varray =  me->newRowData) ;
    __DBGpr_int( "previous size of me->newRowData", size );

    for( i = 0; i < size; i++) {
          _FREE(me->newRowData[i].values);
          me->newRowData[i].values = NULL;
    }

    /*
     * allocate  me->newRowData
     */

    status =
    om$vla_set_dimension(  varray =  me->newRowData,
                           size   =  nbValues);

    if( !(status&1) ) {
        goto wrapup;
    }

    for( i = 0 ; i < nbValues ; i++ ) {
        me->newRowData[i].lineNos = 0;
        me->newRowData[i].colNos = 0;
        me->newRowData[i].values = NULL;
    }

    /* colNos: start from 1; lineNos: start from one */

    for( i = 0 ; i < nbValues ; i++ ) {

        me->newRowData[i].colNos =  colNos[i] ;

        me->newRowData[i].lineNos =  lineNos[i] ;

        len = strlen (values[i]) + 1;

        me->newRowData[i].values=
                (IGRchar *)malloc(sizeof(IGRchar) *  (len));
    
        strcpy( me->newRowData[i].values, values[i]); 

         __DBGpr_int( "Column number", me->newRowData[i].colNos  );
         __DBGpr_int( "line number", me->newRowData[i].lineNos );
         __DBGpr_str( "me->newRowData[i].values", me->newRowData[i].values);

     } /* for */
  
wrapup :
     _FREE( lineNos );
     _FREE( colNos );
     _LOOPFREE( values, nbValues );

     End
     return status;

} /*VDsetRowDataStr*/
/*+me
 ---------------------------------------------------------------------------

  Message VDgetVisColsInfo

  Abstract
        This method get visiable column info

  Arguments
        IGRlong         *sts            O       Return code
        IGRint          preStartColInd  I       previous starting Col index
                                                which is visiable
        IGRint          preVisColNum    I       previous visable Col number
        IGRint          *newStartColInd o       new starting Col index
                                                which is visiable
        IGRint          *newVisColNum   o       new visable Col number
        IGRint          direct          I       direction of scroll
                                                rigth = 1(default)
                                                left  = 0
        IGRint          nbShiftCol      I       shift number

  Status/Return Code
      status == OM_S_SUCCESS

 ---------------------------------------------------------------------------
-me*/
method VDgetVisColsInfo( IGRlong  *sts;
                              IGRint    preStartColInd;
                              IGRint    preVisColNum;
                              IGRint    *newStartColInd;
                              IGRint    *newVisColNum;
                              IGRint    nbShiftCol;
                              IGRint    direct)  
{
IGRlong     msg; 
IGRint      totalnbChar,ii,i;
IGRint      status = OM_S_SUCCESS;


    SetProc( VDCmdEdTbRw.VDgetVisColsInfo); Begin
    msg = MSSUCC;
 
      if (direct == 1 && (preStartColInd + nbShiftCol) < (me->nbTotalCol)) 
      { (*newStartColInd) = preStartColInd + nbShiftCol; 
        totalnbChar = 0;
        i = (*newStartColInd);
        if( i > me->nbTotalCol - 1 || i < 0) {
              printf(" Out of column range\n");
              goto wrapup;
        }
        ii = 0;
        while( i < me->nbTotalCol ) {
         totalnbChar = totalnbChar + me->colWidth[i];
         if( totalnbChar > VD_ETR_viewWidthMax ) break;
         i = i + 1;
         ii = ii + 1;
        }
       (*newVisColNum) = ii;    
      } 
    if (direct == 0 && (preStartColInd - nbShiftCol ) >= 0) {
        totalnbChar = 0;
        i = (preStartColInd  - nbShiftCol);
        if( i > me->nbTotalCol - 1 || i < 0) {
              printf(" Out of column range\n");
              goto wrapup;
        }
        ii = 0;
        while( i < me->nbTotalCol ) {
         totalnbChar = totalnbChar + me->colWidth[i];
         if( totalnbChar > VD_ETR_viewWidthMax ) break;
         i = i + 1;  
         ii = ii + 1;
        }
       (*newVisColNum) = ii;   
       (*newStartColInd) = preStartColInd - nbShiftCol;
      }
#ifdef DEBUG
       printf(" (*newVisColNum) = %d, totalnbChar = %d\n", (*newVisColNum),
                totalnbChar);
#endif

wrapup :
    End
    return status;
} /* VDgetVisColsInfo */
/*+me
 ---------------------------------------------------------------------------

  Message VDmodNewValStr

  Abstract
        This method get visiable column info

  Arguments
        IGRlong         *sts            O       Return code
        IGRint          preStartColInd  I       start col num
        IGRint          preVisColNum    I       total col num in the form now 

  Status/Return Code
      status == OM_S_SUCCESS      for succesful
      status == OM_E_ABORT        for unsuccesful

 ---------------------------------------------------------------------------
-me*/
method VDmodNewValStr( IGRlong  *sts;
                       IGRint    preStartColInd;
                       IGRint    preVisColNum)
{
IGRint     status = OM_S_SUCCESS;
IGRint     i,j,k,  maxLen = 4096, sel, pos,  
           size, len, found, col, line, len1;
IGRchar    buf[4096];

    SetProc( VDCmdEdTbRw.VDmodNewValStr); Begin
    *sts = MSSUCC;

    __DBGpr_int( "preStartColInd", preStartColInd);
    __DBGpr_int( "preVisColNum", preVisColNum );
    __DBGpr_int( "me->nbTotalCol", me->nbTotalCol );
    __DBGpr_int( "me->nbShiftCol", me->nbShiftCol );

    /*
     * recompute me->newRowData 
     */

    for( i = 0; i < preVisColNum; i++) {       
        for( j = 0 ; j <  me->maxLinesPerRow; j++ ) {
            __DBGpr_int( "j", j );
            __DBGpr_int( "i", i );
            
            /* ge text from form */

            buf[0] = '\0';
            FIfld_get_text( VD_FP, VD_ETR_VIS_NEW_ROW, j, i+1, maxLen,
                                (unsigned char *)buf, &sel, &pos );

	    __DBGpr_str( "Buffer value", buf );

            len = strlen(buf);

	    __DBGpr_int( "Buffer len", len );

            found = FALSE;
    
            size = om$dimension_of( varray =  me->newRowData) ;
            __DBGpr_int( "size ", size );

            for( k = 0; k < size; k++) {

              col = me->newRowData[k].colNos;

              line = me->newRowData[k].lineNos;

              if( (preStartColInd + i != col - 1 ) || (j != line - 1 )) 
                     continue;

              len1 = strlen(me->newRowData[k].values);

	      __DBGpr_int( "value len", len1 );
               
	      if(len <= len1) { /* no malloc */
                    me->newRowData[k].values[0] = '\0';
                    strcpy( me->newRowData[k].values, buf); 
	            __DBGpr_com( "No malloc");
              } 
	      else{
                    if( !me->newRowData[k].values ) {
		      me->newRowData[k].values=
			(IGRchar *) malloc( sizeof( IGRchar ) * (len + 1) );
               		if( !me->newRowData[k].values ) {
                              status = OM_E_ABORT; 
                              goto wrapup;
               		}
	                __DBGpr_com( "Malloc");
                    }
                    else { 
		      me->newRowData[k].values=
			(IGRchar *) realloc( me->newRowData[k].values, 
                                     sizeof( IGRchar ) * (len + 1) );
               		if( !me->newRowData[k].values ) {
                              status = OM_E_ABORT; 
                              goto wrapup;
               		}
	                __DBGpr_com( "Realloc");
                    } 
                    me->newRowData[k].values[0] = '\0';
                    strcpy( me->newRowData[k].values, buf); 
	       
	       }		
	       __DBGpr_int( "Column No", me->newRowData[k].colNos );
	       __DBGpr_int( "Line  No",  me->newRowData[k].lineNos );
               __DBGpr_str( " me->newRowData[k].values",  
                                   me->newRowData[k].values );
               found = TRUE;    
               break; 

            } /* for k */

            if( !found ) {

	       __DBGpr_com( " allocate  memory for new me->newRowData" );

               /*
                * allocate  memory for new me->newRowData
                */
               size = om$dimension_of( varray =  me->newRowData) ;
               status =
               om$vla_set_dimension(  varray =  me->newRowData,
                                      size   =  size + 1);

               if( !(status&1) ) {
                              status = OM_E_ABORT; 
                              goto wrapup;
               }
              
               me->newRowData[size].lineNos = j + 1;
               me->newRowData[size].colNos = preStartColInd + i + 1;

               me->newRowData[size].values = NULL;
	       me->newRowData[size].values=
           	 (IGRchar *) malloc( sizeof( IGRchar ) * (len + 1) );

               if( !me->newRowData[k].values ) {
                              status = OM_E_ABORT; 
                              goto wrapup;
               }
               me->newRowData[size].values[0] = '\0';
               strcpy( me->newRowData[size].values, buf); 

	       __DBGpr_int( "Column No", me->newRowData[k].colNos );
	       __DBGpr_int( "Line  No",  me->newRowData[k].lineNos );
               __DBGpr_str( " me->newRowData[k].values",  
                                   me->newRowData[k].values );
            } /* if */
        } /* for j */
    } /* for i */ 

wrapup:
    End
    return status;

}/* VDmodNewValStr */
/*+me
 ---------------------------------------------------------------------------

  Message VDupdatHighlight

  Abstract
        This method update highlight for selected row

  Arguments
        IGRlong         *sts            O       Return code
        IGRint          selRowInd       I       selected row index

  Status/Return Code
      status == OM_S_SUCCESS      for succesful
      status == OM_E_ABORT        for unsuccesful

 ---------------------------------------------------------------------------
-me*/
method VDupdatHighlight( IGRlong *sts;
                                IGRint selRowInd)
{ 
IGRlong          	status;
long            	bytes, received, loc_msg;
int             	suc,
                	count,
                	i;
struct  GRid    	rfmgr,
                	ctxId;
struct  GRmd_env 	ModEnvItems, ModEnvObj;
enum    GRdpmode 	dpmode;
OM_S_CHANSELECT 	rfmgrTOctx;     /* Ref. file mgr -> context     */
OMuword         	TmpOsnum;
short           	flag;
IGRint                  startIndex;

    SetProc( VDCmdEdTbRw.VDupdatHighlight); Begin
    *sts = MSSUCC;
    status = OM_S_SUCCESS;

    dpmode = GRhd;

    dp$erase_hilite( msg = sts );

    /*
     * get current module environment
     */
    bytes = sizeof( struct GRmd_env );
    status = gr$get_module_env(   msg     = &suc,
                                  sizbuf  = &bytes,
                                  buffer  = &ModEnvItems,
                                  nret    = &received );

    if( ModEnvItems.md_id.osnum !=  me->tblRows[selRowInd].rowId.osnum ){
      /*
       * Get module environment of the given OS
       */
      status = om$make_chanselect(
                             channame        = "Super_rfmgr.to_context",
                             p_chanselect    = &rfmgrTOctx ) ;
      if( !( status & 1 ) ) goto wrapup ;

      /*
       * Get the context Super.
       */
      status = GRgetctxsuper( sts, &rfmgr ) ;
      if( !( status & 1 & *sts ) ) goto wrapup ;

      status = om$get_channel_count(osnum           = rfmgr.osnum,
                                    objid           = rfmgr.objid,
                                    p_chanselect    = &rfmgrTOctx,
                                    count           = (OMuint *) &count ) ;
      if( !( status & 1 ) ) goto wrapup ;
      __DBGpr_int( " count ", count );

      /*
       * Loop on contexts.
       */
      for( i = 0 ; i < count ; i++ )
      {
           status = om$send(
                   msg     = message GRcontext.GRgetinstance(
                                              sts,
                                              &ModEnvItems.md_env.matrix_type,
                                              ModEnvItems.md_env.matrix,
                                              &TmpOsnum,
                                              &flag,
                                              &ctxId ),
                  senderid        = rfmgr.objid,
                  targetos        = rfmgr.osnum,
                  p_chanselect    = &rfmgrTOctx,
                  to              = i,
                  from            = i ) ;

           if( !( 1 & status & *sts ) ) continue ;
           if ( TmpOsnum == me->tblRows[selRowInd].rowId.osnum ) break;

      }

      if ( i >= count ) {  
         printf( "Display table row in OS : can not find OS [%d] \n", 
                  me->tblRows[selRowInd].rowId.osnum );
         status = OM_E_ABORT;
         goto wrapup;
      }
   }
   ModEnvItems.md_id.osnum = me->tblRows[selRowInd].rowId.osnum;
   ModEnvItems.md_id.objid = NULL_OBJID;

   status =
   om$send(msg = message GRgraphics.GRdisplay(&loc_msg,
                                           &ModEnvItems.md_env.matrix_type,
                                           ModEnvItems.md_env.matrix,
                                           &dpmode,
                                           &ModEnvItems.md_id),
              targetid = me->tblRows[selRowInd].rowId.objid,
              targetos = me->tblRows[selRowInd].rowId.osnum,
              senderid = NULL_OBJID );
    as$status();

    /* display objects assoiated with the row */

    startIndex =  me->tblRows[selRowInd].startIndex;
          
    __DBGpr_int(" startIndex ", me->tblRows[selRowInd].startIndex);
    for ( i = 0; i < me->tblRows[selRowInd].nbObjs; i++ ) {

          __DBGpr_int(" i ", i);
          __DBGpr_mat(" matrix ", 
             me->locObjs[i + startIndex].mod_env.md_env.matrix);
          __DBGpr_int(" matrix type ", 
             me->locObjs[i + startIndex].mod_env.md_env.matrix_type);
          __DBGpr_obj(" objec id ", me->locObjs[i + startIndex].obj_id);

          status =
          _VD_SEND_OBJN(   me->locObjs[i + startIndex].obj_id,
                           NDmacro.ACreturn_foot(
                                        &loc_msg,
                                        "",
                                        &me->locObjs[i + startIndex].obj_id,
                                        &ModEnvObj.md_env.matrix_type,
                                        ModEnvObj.md_env.matrix ));
          if( !(status&loc_msg&1) ) continue ;
          __DBGpr_mat(" matrix", ModEnvObj.md_env.matrix);

          ModEnvObj.md_id.osnum = me->locObjs[i + startIndex].obj_id.osnum;
          ModEnvObj.md_id.objid = NULL_OBJID;
          
          status =
          om$send(msg = message GRgraphics.GRdisplay(&loc_msg,
                                           &ModEnvObj.md_env.matrix_type,
                                            ModEnvObj.md_env.matrix,
                                           &dpmode,
                                           &ModEnvObj.md_id),
              targetid = me->locObjs[i + startIndex].obj_id.objid,
              targetos = me->locObjs[i + startIndex].obj_id.osnum,
              senderid = NULL_OBJID );
          as$status();
    }

wrapup:
   End
   return status;

}/* VDupdatHighlight */
end implementation VDCmdEdTbRw;
