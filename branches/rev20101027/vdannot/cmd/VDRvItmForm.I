/* $Id: VDRvItmForm.I,v 1.1.1.1 2001/01/04 21:07:40 cvs Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vdannot/cmd/VDRvItmForm.I
 *
 * Description:
 *      Implementation file for VDCmdRvItem.
 *      Methods :
 *                      form_notification
 *
 * Dependencies:
 *
 * Revision History:
 *
 *      12/14/94        R. Manem        Creation for OPE enhancements
 *
 * -------------------------------------------------------------------*/


class implementation VDCmdRvItem;

#include <stdio.h>
#include <string.h>

#include "OMparameters.h"
#include "OMmacros.h"
#include "igrdef.h"
#include "igrmacros.h"
#include "msdef.h"
#include "msmacros.h"
#include "exdef.h"
#include "AS_status.h"

#include "grdpbmacros.h"
#include "grerr.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "VDSannot.h"
#include "FI.h"
#include "VDmsg.h"

#define VD_FP        me^^CEO.forms[0].form_ptr

/*
#define DEBUG
*/

/*+mo
 -------------------------------------------------------------------------
  Overridden Message
        form_notification from CEO

  Abstract
        Form notification routine for the CO

  Arguments
        int           form_label;     label of form which received user  input
        int           gadget_label;   gadget label  which received user  input
        double        value;          value of gadget ( or field row # )
        char          * form_ptr ;    ptr to I/Forms form which received input

 -------------------------------------------------------------------------
-mo*/


method form_notification( int 		form_label;
			  int 		gadget_label;
			  double 	value; 
			  char 		*form_ptr )
{
    IGRlong	msg;
    IGRint	i,size,
		rc, 
		sel, 
		len,
		pos;
    IGRchar	buffer[MAXROWSIZE];
    IGRint      keepCurTbl;
    IGRchar     tablename[80];
    IGRlong     status = OM_S_SUCCESS;

    FIfld_set_text( VD_FP, FI_MSG_FIELD, 0, 0, "", FALSE );

    switch ( gadget_label )
    {
        case  FI_CANCEL		:

            _put_response( resp = EX_FORM_FINISHED );

            break;

        case  VD_ITM_EXPR_FLD	:

            /* store the expression in instance date */

            FIfld_get_text( VD_FP, gadget_label, 0, 0, MAXROWSIZE, 
				(unsigned char *)buffer, &sel, &pos );

            /* first validate the regular expression */

            len = strlen( buffer );
            if( !(rc = ASmatchRE( buffer, NULL ) ) )
            {
                UI_status( "Invalid regular expression" );
                FIfld_set_text( VD_FP, FI_MSG_FIELD, 0, 0,
			(unsigned char *)"Invalid regular expression", FALSE );
            }

            if( !len || !rc )
            {
                FIfld_set_text( VD_FP, gadget_label, 0, 0, "*", FALSE );
                strcpy( me->itemRegExpr, "*" );
            }
            else
            {
                status = om$vla_set_dimension( varray	= me->itemRegExpr,
					       size	= len + 1 );
                as$status( action = GOTO_VALUE, value = quit );

                strcpy( me->itemRegExpr, buffer );
            }

		#ifdef DEBUG
    		printf("\nme->itemRegExpr = %s", me->itemRegExpr );
		#endif

            /* update list of item numbers */

            status = om$send( msg	= message VDCmdRvItem.VDupdateItemList
								( &msg ),
			      mode	= OM_e_wrt_message,
			      targetid	= my_id );

            as$status();

            /* update highlight */

            status = om$send( msg	= message VDCmdRvItem.VDupdateHighlight
								 ( &msg ),
			      mode	= OM_e_wrt_message,
			      targetid	= my_id );

            as$status();

            break;

        case  VD_HLT_OPT_BTN	:

            /* store new option in instance date */

            FIg_get_state( VD_FP, gadget_label, &me->highlightOpt );

            /* update state of Fit obj gadget, and corresponding instance */

            if( !me->highlightOpt )
            {
                FIg_erase(   VD_FP, VD_FIT_OBJ_LST );
                FIg_erase(   VD_FP, VD_ITM_FIT_FLD );
                FIg_erase(   VD_FP, VD_ITM_FIT_NME );
                FIg_erase(   VD_FP, VD_ITM_FIT_3DO );
                FIg_set_state( VD_FP, VD_FIT_OBJ_LST, FALSE );   
                me->fitObjOpt = FALSE;
            }
            else {
                FIg_display(  VD_FP, VD_FIT_OBJ_LST );
                FIg_display(  VD_FP, VD_ITM_FIT_FLD );
                FIg_display(  VD_FP, VD_ITM_FIT_NME );
                FIg_display(  VD_FP, VD_ITM_FIT_3DO );
                FIg_set_state( VD_FP, VD_ITM_FIT_3DO, me->fit3DObject);   
                FIfld_set_value( VD_FP, VD_ITM_FIT_FLD, 0, 0, me->fitRatio, 
                                    FALSE );
            }
             

            /* update highlight */

            status = om$send( msg	= message VDCmdRvItem.VDupdateHighlight
								( &msg ),
			      mode	= OM_e_wrt_message,
			      targetid	= my_id );

            as$status();

            break;

        case  VD_ITM_LIST_FLD	:
            FIfld_get_value( VD_FP, VD_ITM_FIT_FLD, 0, 0, &me->fitRatio,
                               &sel, &pos);

            /* update highlight only if necessary */

            if( me->highlightOpt )
            {
                status = om$send( msg		= message VDCmdRvItem.
							VDupdateHighlight(&msg),
			          mode		= OM_e_wrt_message,
			          targetid	= my_id );
                as$status();
            }

            break;

        case  VD_TBL_NAME_FLD	:

            /* ndowId.objid == NULL_OBJID */

            len = om$dimension_of( varray = me->curTblName );
            FIfld_get_text( VD_FP, gadget_label, 0, 0, len,
				(unsigned char *)me->curTblName, &sel, &pos );

            /* update me->curTblIndex */

            keepCurTbl = FALSE;

            for( i = 0 ; i < me->nbTables ; i++ )
                if( !strcmp( me->curTblName, me->tables[i].tblName ) )
                {
                    keepCurTbl = TRUE;
                    me->curTblIndex = i;
                    me->curTblInSet = TRUE;
                    __DBGpr_int(" curTblIndex ", me->curTblIndex);
                    __DBGpr_str(" curTblName ", me->curTblName);
                    break;
                }
            if( !keepCurTbl ) {

                size = om$dimension_of( varray  =  me->tableNoSet);

                for( i = 0 ; i < size ; i++ ) {

                  if( !strcmp( me->curTblName, me->tableNoSet[i].tblName )){
                    keepCurTbl = TRUE;
                    me->curTblIndex = i;
                    me->curTblInSet = FALSE;
                    break;
                  }
                }
             }
            if( !keepCurTbl ) {
                    me->curTblIndex = 0;
                    me->curTblInSet = FALSE;
            }
            

            /* update list of item numbers */

            status = om$send( msg	= message VDCmdRvItem.VDupdateItemList
								( &msg ),
			      mode	= OM_e_wrt_message,
			      targetid	= my_id );

            as$status();

            /* if highlight all option is set, then update highlight */

            if( !me->highlightOpt )
            {
                status = om$send( msg		= message VDCmdRvItem.
							VDupdateHighlight(&msg),
			          mode		= OM_e_wrt_message,
			          targetid	= my_id );
                as$status();
            }
            else
            {
                /* must erase the existing highlight */

                dp$erase_hilite( msg = &msg );
            }

            break;

        case  VD_ITM_FIT_3DO	:
                FIg_get_state( VD_FP, gadget_label, &me->fit3DObject);
            
                FIfld_get_value( VD_FP, VD_ITM_FIT_FLD, 0, 0, &me->fitRatio,
                               &sel, &pos);
        
                /* update highlight only if necessary */

                if( me->highlightOpt ) {
                status = om$send( msg           = message VDCmdRvItem.
                                                        VDupdateHighlight(&msg),
                                  mode          = OM_e_wrt_message,
                                  targetid      = my_id );
                as$status();
                }


            break;  

        case  VD_ITM_FIT_FLD	:
            FIfld_get_value( VD_FP, VD_ITM_FIT_FLD, 0, 0, &me->fitRatio,
                               &sel, &pos);
            break;  

        case  VD_FIT_OBJ_LST	:

            FIfld_get_value( VD_FP, VD_ITM_FIT_FLD, 0, 0, &me->fitRatio,
                               &sel, &pos);
            /* 
             * if highlight option is all nos, 
             *     clear the selection, and instance data
             *     break
             */

            if( !me->highlightOpt )
            {
                FIg_set_state( VD_FP, gadget_label, FALSE );
                me->fitObjOpt = FALSE;
                break;
            }
            else
            {
                /* otherwise update instance data */
            
                FIg_get_state( VD_FP, gadget_label, &me->fitObjOpt );
                FIfld_get_value( VD_FP, VD_ITM_FIT_FLD, 0, 0, &me->fitRatio, 
                                 &sel, &pos);

            }

            /* update highlight */

            status = om$send( msg	= message VDCmdRvItem.VDupdateHighlight
								( &msg ),
			      mode	= OM_e_wrt_message,
			      targetid	= my_id );

            as$status();

            break;
        
   	case  VD_ITM_BAL_TOG	:

            FIg_get_state( VD_FP, gadget_label, &me->ballonTog );

            keepCurTbl = FALSE;

            /* update name field */
            if( !me->ballonTog ) {  /* with ballon */

               me->curTblInSet = TRUE;

               for( i = 0 ; i < me->nbTables ; i++ ) {
                  if( !strcmp( me->curTblName, me->tables[i].tblName )){
                    keepCurTbl = TRUE;
                    me->curTblIndex = i;
                    break;
                  }
               }
               if( !keepCurTbl ) {
                 
                      strcpy( me->curTblName, "");

                      me->curTblIndex = 0;
               } 
               
               FIfld_set_text( VD_FP, VD_TBL_NAME_FLD, 0, 0,
                        (unsigned char *)me->curTblName, FALSE );

               /* update the associative list of table names */

               FIfld_set_list_num_rows( VD_FP, VD_TBL_NAME_FLD, 0, 
                                                    me->nbTables );

               for( i = 0 ; i < me->nbTables ; i++ )
                 VDfld_set_list_text( VD_FP, VD_TBL_NAME_FLD, i, 0,
                        (unsigned char *)me->tables[i].tblName, FALSE );
            }
            else {  /* without ballon */
               for( i = 0 ; i < me->nbTables ; i++ ) {

                  if( !strcmp( me->curTblName, me->tables[i].tblName )){
                    keepCurTbl = TRUE;
                    me->curTblIndex = i;
                    me->curTblInSet = TRUE;
                    break;
                  }
               }
               if( !keepCurTbl ) {

    		size = om$dimension_of( varray  =  me->tableNoSet);

                for( i = 0 ; i < size ; i++ ) {

                  if( !strcmp( me->curTblName, me->tableNoSet[i].tblName )){
                    keepCurTbl = TRUE;
                    me->curTblIndex = i;
                    me->curTblInSet = FALSE;
                    break;
                  }
                }
               }

               if( !keepCurTbl ) {

                      strcpy( me->curTblName, "");

                      me->curTblIndex = 0;

                      me->curTblInSet = FALSE;

               } /* if( !keepCurTbl ) */

               FIfld_set_text( VD_FP, VD_TBL_NAME_FLD, 0, 0,
                        (unsigned char *)me->curTblName, FALSE );


               /* update the associative list of table names */
    	       size = om$dimension_of( varray  = me->tableIdName); 

               FIfld_set_list_num_rows( VD_FP, VD_TBL_NAME_FLD, 0,
                                                    size);

               for( i = 0 ; i < size ; i++ ) {

                 tablename[0] = '\0';
        	 strcat( tablename, me->tableIdName[i].tbl_name);
                 strcat( tablename, "[");
                 strcat( tablename, me->tableIdName[i].deg_file.fname);
                 strcat( tablename, "]");

                 VDfld_set_list_text( VD_FP, VD_TBL_NAME_FLD, i, 0,
                                                 tablename, FALSE );
               } 

            }
 

            /* update list of item numbers */
            status = om$send( msg       = message VDCmdRvItem.VDupdateItemList
                                                                ( &msg ),
                              mode      = OM_e_wrt_message,
                              targetid  = my_id );
            as$status();

            /* update highlight */
            status = om$send( msg    = message VDCmdRvItem.VDupdateHighlight
                                                                ( &msg ),
                              mode      = OM_e_wrt_message,
                              targetid  = my_id );
            as$status();

            break;


    }

    goto quit;

quit :
    return OM_S_SUCCESS;
}

end implementation VDCmdRvItem;
