/* $Id: VDDeItmPrFrm.I,v 1.1.1.1 2001/01/04 21:07:40 cvs Exp $  */
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdannot/cmd/VDDeItmPrFrm.I
 *
 * Description:
 *      this file includes method: form_notification
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDDeItmPrFrm.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:40  cvs
 *      Initial import to CVS
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
# Revision 1.9  1996/05/06  22:53:38  pinnacle
# Replaced: vdannot/cmd/VDDeItmPrFrm.I for:  by yzhu for vds.240
#
# Revision 1.8  1996/02/05  11:54:52  pinnacle
# Replaced: vdannot/cmd/VDDeItmPrFrm.I for:  by rgade for vds.240
#
# Revision 1.7  1995/11/30  19:46:52  pinnacle
# Replaced: vdannot/cmd/VDDeItmPrFrm.I for:  by yzhu for vds.240
#
# Revision 1.6  1995/10/02  21:33:04  pinnacle
# Replaced: vdannot/cmd/VDDeItmPrFrm.I for:  by yzhu for vds.240
#
# Revision 1.5  1995/10/02  21:12:34  pinnacle
# Replaced: vdannot/cmd/VDDeItmPrFrm.I for:  by yzhu for vds.240
#
# Revision 1.4  1995/08/24  03:11:40  pinnacle
# Replaced: vdannot/cmd/VDDeItmPrFrm.I for:  by yzhu for vds.240
#
# Revision 1.3  1995/07/26  15:48:10  pinnacle
# Replaced: vdannot/cmd/VDDeItmPrFrm.I for:  by yzhu for vds.240
#
# Revision 1.2  1995/07/14  14:05:32  pinnacle
# Replaced: vdannot/cmd/VDDeItmPrFrm.I for:  by yzhu for vds.240
#
# Revision 1.1  1995/07/13  18:24:12  pinnacle
# Created: vdannot/cmd/VDDeItmPrFrm.I by yzhu for vds.240
#
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      07/10/95        Y.Zhu           Creation
 *
 * -------------------------------------------------------------------*/
class implementation VDCmdDeItPr;
#include <stdio.h>
#include <string.h>
#include <memory.h>
#include <malloc.h>
#include <ctype.h>
#include <stdlib.h>

#include "OMminimum.h"
#include "OMmacros.h"
#include "OMparameters.h"
#include "OMprimitives.h"
#include "grdpbdef.h"
#include "igrdef.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "grdpbmacros.h"
#include "AS_status.h"                  /* define as$status                */
#include "FI.h"

#include "VDSannot.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"
#include "vdmemmacros.h"

/* #define DEBUG */ 

from VDquery import VDgive_query, VDgetPfxInfo, VDdelPfxInfo; 
/****************************************************************************
 Function indexcmp 
  a sort function for prefix index comparison on ascending 
*****************************************************************************/
int  indexcmp( struct VDitmQryPfxInfo *elm1,
             struct VDitmQryPfxInfo *elm2 )
{
     if( elm1->pfx_index<elm2->pfx_index )
          return(-1);
     else 
          return(1);
}
/*****************************************************************************
 method form_notification

Description:

    This method supports the define item prefix.

Arguments
        int           form_label;     label of form which received user  input
        int           gadget_label;   gadget label  which received user  input
        double        value;          value of gadget ( or field row # )
        Form          form_ptr ;      ptr to I/Forms form which received input

Override:

    from CEO form_notification

******************************************************************************/
method form_notification ( int    form_label;
                           int    gadget_label;
                           double value;
                           Form   form_ptr )
{
IGRint          status = OM_S_SUCCESS;
IGRlong         sts;  
IGRlong         sel_flag=FALSE;  
IGRint          lflag, num_rows,sel,pos,len, num_rows1;
IGRchar         buf[80], tmps[100];
IGRchar         *ptr;

#ifdef DEBUG
        printf("form_notification\n");
#endif
       switch (gadget_label){
	case FI_CANCEL:
			#ifdef DEBUG
            			printf(" FI_CANCEL \n");
			#endif
            dp$erase_hilite (msg = &sts);
	    me->rep_label = VD_DIPD_FORM_CANCEL;
            _put_response( resp = EX_FORM_FINISHED );
            break;

       	case FI_EXECUTE:
			#ifdef DEBUG
            			printf(" FI_EXECUTE \n");
			#endif
            FIfld_set_text( form_ptr, FI_MSG_FIELD, 0, 0, 
                              "", sel_flag);

	    me->rep_label = VD_DIPD_FORM_EXECUTE;
            _put_response (resp = VD_DIPD_FORM_INFO);
            break;

       	case FI_ACCEPT:
			#ifdef DEBUG
            			printf(" FI_ACCEPT \n");
			#endif

	    me->rep_label = VD_DIPD_FORM_ACCEPT;
            _put_response (resp = VD_DIPD_FORM_INFO);
            break;

        case VD_DIPD_DEL_ROW:
			#ifdef DEBUG
            			printf(" VD_DIPD_DEL_ROW\n");
			#endif
             FIfld_set_text( form_ptr, FI_MSG_FIELD, 0, 0, "", sel_flag);
    	     FIfld_get_num_rows ( VD_FP, VD_DIPD_SEL_FLD, &num_rows);
             
             /* call VDitmPreRowChg */
             lflag = VDDELSELE;
             status =
             om$send(msg = message VDCmdDeItPr.VDitmPreRowChg(&sts,
                                                              lflag),
                     targetid = my_id );
             if( status&sts&1) {
    	        FIfld_set_num_rows ( VD_FP, VD_DIPD_SEL_FLD, num_rows - 1);
    	        FIfld_set_max_num_rows ( VD_FP, VD_DIPD_SEL_FLD, num_rows - 1);
             }
	     me->rep_label = VD_DIPD_FORM_DELROW;
             _put_response (resp = VD_DIPD_FORM_INFO);
             break;

        case VD_DIPD_INS_ROW:
			#ifdef DEBUG
            			printf(" VD_DIPD_INS_ROW \n");
			#endif
             FIfld_set_text( form_ptr, FI_MSG_FIELD, 0, 0, "", sel_flag);
    	     status =
             om$send(msg = message VDCmdDeItPr.VDinsItmPreRow(&sts),
                  targetid = my_id );

	     me->rep_label = VD_DIPD_FORM_INSROW;
             _put_response (resp = VD_DIPD_FORM_INFO);
             break;


	case VD_DIPD_ARROW_U: 
                        #ifdef DEBUG
                                printf(" VD_DIPD_ARROW_U\n");
                        #endif
             FIfld_set_text( form_ptr, FI_MSG_FIELD, 0, 0, "", sel_flag);
             FIfld_get_active_row(form_ptr, VD_DIPD_SEL_FLD, &num_rows,&pos);
             FIfld_get_num_rows ( VD_FP, VD_DIPD_SEL_FLD, &num_rows1);


             /* call VDitmPreRowChg */
             lflag = VDCHGPREV;
             status =
             om$send(msg = message VDCmdDeItPr.VDitmPreRowChg(&sts,
                                                              lflag),
                     targetid = my_id );
             if(num_rows) { 
              FIfld_set_select(form_ptr,VD_DIPD_SEL_FLD,num_rows,0,FALSE); 
              FIfld_set_select(form_ptr,VD_DIPD_SEL_FLD,num_rows,2,FALSE); 
              FIfld_set_select(form_ptr,VD_DIPD_SEL_FLD,num_rows,3,FALSE); 
              FIfld_set_select(form_ptr,VD_DIPD_SEL_FLD,num_rows - 1,0,TRUE); 
              FIfld_set_select(form_ptr,VD_DIPD_SEL_FLD,num_rows - 1,2,TRUE); 
              FIfld_set_select(form_ptr,VD_DIPD_SEL_FLD,num_rows - 1,3,TRUE); 
              FIfld_set_active_row(form_ptr,VD_DIPD_SEL_FLD, num_rows - 1,pos);
             }
             me->rep_label = VD_DIPD_ARROW_U;
             _put_response (resp = VD_DIPD_FORM_INFO);
             break;

        case VD_DIPD_ARROW_D:
                        #ifdef DEBUG
                                printf(" VD_DIPD_ARROW_D\n");
                        #endif
             FIfld_set_text( form_ptr, FI_MSG_FIELD, 0, 0, "", sel_flag);
             FIfld_get_active_row(form_ptr, VD_DIPD_SEL_FLD, &num_rows,&pos);
             FIfld_get_num_rows ( VD_FP, VD_DIPD_SEL_FLD, &num_rows1);

             /* call VDitmPreRowChg */
             lflag = VDCHGNEXT;
             status =
             om$send(msg = message VDCmdDeItPr.VDitmPreRowChg(&sts,
                                                              lflag),
                     targetid = my_id );

             if(num_rows < num_rows1 - 1) { 
              FIfld_set_select(form_ptr,VD_DIPD_SEL_FLD,num_rows,0,FALSE); 
              FIfld_set_select(form_ptr,VD_DIPD_SEL_FLD,num_rows,2,FALSE); 
              FIfld_set_select(form_ptr,VD_DIPD_SEL_FLD,num_rows,3,FALSE); 
              FIfld_set_select(form_ptr,VD_DIPD_SEL_FLD,num_rows + 1,0,TRUE) ; 
              FIfld_set_select(form_ptr,VD_DIPD_SEL_FLD,num_rows + 1,2,TRUE) ; 
              FIfld_set_select(form_ptr,VD_DIPD_SEL_FLD,num_rows + 1,3,TRUE) ; 
              FIfld_set_active_row(form_ptr, VD_DIPD_SEL_FLD, num_rows + 1,pos);
             }
 
             me->rep_label = VD_DIPD_ARROW_D;
             _put_response (resp = VD_DIPD_FORM_INFO);
             break;

        case VD_DIPD_SEL_FLD:
                        #ifdef DEBUG
                                printf(" VD_DIPD_SEL_FLD\n");
                        #endif
             /* set number of rows */
             FIfld_set_text (form_ptr, 10, 0, 0, "", FALSE ); 

             buf[0] = '\0';
             FIfld_get_active_row(form_ptr, VD_DIPD_SEL_FLD, &num_rows,&pos);
             FIfld_get_text( form_ptr, VD_DIPD_SEL_FLD, num_rows, 1,
                             VD_DIPD_MAX_QRY_NAME_LEN, buf, &sel, &pos);

             ptr = buf;
             while(isspace(*ptr)) ptr++;
             FIfld_set_text (form_ptr, VD_DIPD_SEL_FLD,num_rows, 1,
                                       ptr, FALSE ); 


             tmps[0] = '\0';
             if( buf != NULL ) {
                  len = strlen(buf);
                  if (isspace(buf[len - 1])) {
                     sprintf( tmps,"Row %d:  the prefix has ending blanks '%s'",
                                   num_rows + 1, ptr);
                     FIfld_set_text (form_ptr, 10, 0, 0, tmps, FALSE ); 
                  }
             } 

             /* get state */
             break;

        default:
             break;

      } /* switch */ 
quit:
  return status;

} /* form_notification */
/*+me
 ---------------------------------------------------------------------------

  Private Message VDitmPreRowChg


  Abstract
        This method changed a prefix definition row. It incldues: delete,
        exchage with previos line or next line.

  Arguments
        IGRlong         *msg            O       Return code
        IGRint          lflag           I       =VDCHGPREV, 
                                                 change with previos line
                                                =VDDELSELE,  
                                                 delete selected line
                                                =VDCHGNEXT,  
                                                 chnage with next line
  Status/Return Code
      status == OM_S_SUCCESS

 ---------------------------------------------------------------------------
-me*/
method VDitmPreRowChg(  IGRlong         *msg;
                        IGRint          lflag)
{
IGRlong 		status = OM_S_SUCCESS;
struct VDitmQryPfxInfo 	tmp1, tmp2;
IGRint  		i, num_qry,selflag, selRow,sel, num_rows1, pos;

                #ifdef DEBUG
                        printf(" VDCmdDeItmPre.VDitmPreRowChg\n");
                #endif

    SetProc( VDCmdDeItmPre.VDitmPreRowChg); Begin
    *msg = MSSUCC;


    /* red  me->tmpqry from form */
    FIfld_get_num_rows ( VD_FP, VD_DIPD_SEL_FLD, &num_rows1);

    __DBGpr_int( " No of row in form", num_rows1);

    num_qry  = om$dimension_of( varray = me->tmpqry );
    __DBGpr_int( " No of me->tmpqry",  num_qry);

    if( !num_qry || ( num_rows1 > num_qry ) ) {
         FIfld_set_text (VD_FP, 10, 0, 0,"Can not make any row chnage", FALSE );
         status = OM_E_ABORT;
         goto wrapup;
    }

    for(i = 0; i < num_rows1; i++) {
                me->tmpqry[i].pfx_index = i + 1;
                me->tmpqry[i].pfx_name[0] = '\0';
                FIfld_get_text( VD_FP, VD_DIPD_SEL_FLD, i, 1,
                        VD_DIPD_MAX_QRY_NAME_LEN,
                        me->tmpqry[i].pfx_name, &sel, &pos);
                me->tmpqry[i].qry_name[0] = '\0';
                FIfld_get_text( VD_FP, VD_DIPD_SEL_FLD, i, 2,
                        VD_DIPD_MAX_QRY_NAME_LEN,
                        me->tmpqry[i].qry_name, &sel, &pos);
                me->tmpqry[i].qry_def[0] = '\0';
                FIfld_get_text( VD_FP, VD_DIPD_SEL_FLD, i, 3,
                        VD_DIPD_MAX_QRY_DEF_LEN,
                        me->tmpqry[i].qry_def, &sel, &pos);
    }


    /* check if a row is selected */
    selRow = 0;
    selflag = FALSE;
    for( i = 0; i < num_qry; i++) {
            FIfld_get_select (VD_FP, VD_DIPD_SEL_FLD, i, 0, &sel);
            if (sel) {
                selRow = i;
                selflag = TRUE;
                break;
            }
    }
    /* if no row was selected, give warning message */
    if( !selflag) {
         FIfld_set_text ( VD_FP, 10, 0, 0,"No row is selected", FALSE );
         status = OM_E_ABORT;
         goto wrapup;
    }
    else
         FIfld_set_text ( VD_FP, 10, 0, 0,"", FALSE );
 
    /* make a copy of previous tmpqry */
    status =
    om$vla_set_dimension(  varray =  me->tmpqryc,
                           size   =  0);
    status =
    om$vla_set_dimension(  varray =  me->tmpqryc,
                           size   =   num_qry);

    __CheckRC( status, 1, "om$vla_set_dimension", wrapup );

    for( i = 0; i < num_qry; i++ ) {
       me->tmpqryc[i] = me->tmpqry[i];
    }

    /* change row */
    switch( lflag) {
      case  VDCHGPREV:
            /* see if it is first row */
            if(selRow == 0) {
               FIfld_set_text(VD_FP,10, 0, 0,"Can not move up futher",FALSE );
               status = OM_E_ABORT; 
               goto wrapup;
            } 
            /* set tmp1 = previous row, tmp2 =  selected row  */ 
            tmp1 = me->tmpqry[selRow-1];
            tmp2 = me->tmpqry[selRow];

            /* change relative rows in tmpqry */
            me->tmpqry[selRow-1] = tmp2;
                me->tmpqry[selRow-1].pfx_index = tmp1.pfx_index;
            me->tmpqry[selRow] = tmp1;
                me->tmpqry[selRow].pfx_index = tmp2.pfx_index;

            /* redisplay form */
            for(i= selRow-1; i<=selRow; i++) {
              FIfld_set_value ( VD_FP, VD_DIPD_SEL_FLD, i, 0,
                          (double)me->tmpqry[i].pfx_index, FALSE );
              FIfld_set_text ( VD_FP, VD_DIPD_SEL_FLD, i, 1,
                          me->tmpqry[i].pfx_name, FALSE );
              FIfld_set_text ( VD_FP, VD_DIPD_SEL_FLD, i, 2,
                          me->tmpqry[i].qry_name, FALSE );
              FIfld_set_text ( VD_FP, VD_DIPD_SEL_FLD, i, 3,
                          me->tmpqry[i].qry_def, FALSE );
            }

            break; 
      case  VDDELSELE:
            /* reorder tmpqry */
            status =
            om$vla_set_dimension(  varray =  me->tmpqry,
                           size   =  0);
            status =
            om$vla_set_dimension(  varray =  me->tmpqry,
                           size   =   num_qry - 1);
            __CheckRC( status, 1, "om$vla_set_dimension", wrapup );
            
            if(!(num_qry - 1) ) {
                /* no entry left */
                i = num_qry-1;
                FIfld_set_text ( VD_FP, VD_DIPD_SEL_FLD, i, 0,
                          "", FALSE );
                FIfld_set_text ( VD_FP, VD_DIPD_SEL_FLD, i, 1,
                          "", FALSE );
                FIfld_set_text ( VD_FP, VD_DIPD_SEL_FLD, i, 2,
                          "", FALSE );
                FIfld_set_text ( VD_FP, VD_DIPD_SEL_FLD, i, 3,
                          "", FALSE );
                break;
            }
            for(i = 0; i<selRow; i++) {
               me->tmpqry[i] = me->tmpqryc[i];
            }
            for(i = selRow; i<num_qry-1; i++) {
               me->tmpqry[i] = me->tmpqryc[i+1];
               me->tmpqry[i].pfx_index = me->tmpqryc[i+1].pfx_index - 1;
            }

            /* delete query from collector */
/* Commented for TR#179600261 -Ravi */
#if 0
            status  = om$send ( msg = message  VDquery.VDdelPfxInfo( msg),
                                   targetid = me->tmpqryc[selRow].qry_id.objid,
                                   targetos = me->tmpqryc[selRow].qry_id.osnum,
                                   senderid = NULL_OBJID );

            as$status(); 
#endif

            /* redisplay form */
            for(i= selRow; i< num_qry-1; i++) {
              FIfld_set_value ( VD_FP, VD_DIPD_SEL_FLD, i, 0,
                          (double)me->tmpqry[i].pfx_index, FALSE );
              FIfld_set_text ( VD_FP, VD_DIPD_SEL_FLD, i, 1,
                          me->tmpqry[i].pfx_name, FALSE );
              FIfld_set_text ( VD_FP, VD_DIPD_SEL_FLD, i, 2,
                          me->tmpqry[i].qry_name, FALSE );
              FIfld_set_text ( VD_FP, VD_DIPD_SEL_FLD, i, 3,
                          me->tmpqry[i].qry_def, FALSE );
            }
            /* for last row */
              i = num_qry-1;
              FIfld_set_text ( VD_FP, VD_DIPD_SEL_FLD, i, 0,
                          "", FALSE );
              FIfld_set_text ( VD_FP, VD_DIPD_SEL_FLD, i, 1,
                          "", FALSE );
              FIfld_set_text ( VD_FP, VD_DIPD_SEL_FLD, i, 2,
                          "", FALSE );
              FIfld_set_text ( VD_FP, VD_DIPD_SEL_FLD, i, 3,
                          "", FALSE );
 
             FIfld_set_num_rows ( VD_FP, VD_DIPD_SEL_FLD, num_qry-1);
            break; 
      case  VDCHGNEXT:
            /* see if it is first row */
            if(selRow == num_qry -1) {
               FIfld_set_text(VD_FP,10, 0, 0,"Can not move down futher",FALSE );
               status = OM_E_ABORT;
               goto wrapup;
            }
            /* set tmp1 = selected row, tmp2 =  next row  */
            tmp1 = me->tmpqry[selRow];
            tmp2 = me->tmpqry[selRow+1];

            /* change relative rows in tmpqry */
            me->tmpqry[selRow] = tmp2;
                me->tmpqry[selRow].pfx_index = tmp1.pfx_index;
            me->tmpqry[selRow+1] = tmp1;
                me->tmpqry[selRow+1].pfx_index = tmp2.pfx_index;

            /* redisplay form */
            for(i= selRow; i<=selRow+1; i++) {
              FIfld_set_value ( VD_FP, VD_DIPD_SEL_FLD, i, 0,
                          (double)me->tmpqry[i].pfx_index, FALSE );
              FIfld_set_text ( VD_FP, VD_DIPD_SEL_FLD, i, 1,
                          me->tmpqry[i].pfx_name, FALSE );
              FIfld_set_text ( VD_FP, VD_DIPD_SEL_FLD, i, 2,
                          me->tmpqry[i].qry_name, FALSE );
              FIfld_set_text ( VD_FP, VD_DIPD_SEL_FLD, i, 3,
                          me->tmpqry[i].qry_def, FALSE );
            }

            break; 
      default:
            break;
    } /* switch */
wrapup:
    End
    return status;
} /* VDitmPreRowChg */


/*+me
 ---------------------------------------------------------------------------

  Public Message VDinsItmPreRow

  Abstract
        This method insert a prefix definition row. First, it check if a row
        is selected. If not, give warning info. If yes, it pop up "select query"
        form. It displays selected query on prefix definition form.

  Arguments
        IGRlong         *msg            O       Return code

  Status/Return Code
      status == OM_S_SUCCESS

 ---------------------------------------------------------------------------
-me*/
method VDinsItmPreRow(  IGRlong         *msg)
{
IGRlong 	status = OM_S_SUCCESS;
IGRint          i, selRow, num_row,j, num; 
IGRint          sel, pos, num_qry;
struct GRid     *qry_ids = NULL;
struct GRmd_env *qry_envs = NULL; 
IGRchar         **qry_names = NULL;
IGRchar         **qry_def = NULL;
IGRchar         **qry_desc = NULL;
IGRchar         *select = NULL,
                *where = NULL,
                *comment = NULL ;
IGRint          pfxflag;
IGRint          selflag;
IGRint          num_qry_sel;
struct GRid     outQryId;         
struct GRmd_env outQryenv;    
IGRchar         outQryName[80];           
GRspacenum      curOS;           

 
		#ifdef DEBUG
       			printf(" VDCmdDeItmPre.VDinsItmPreRow\n");
		#endif

    SetProc( VDCmdDeItmPre.VDinsItmPreRow); Begin
    *msg = MSSUCC;
    /* get current module */
    status =
    ex$get_cur_mod( osnum   = &curOS);
    __CheckRC( status, 1, "ex$get_cur_mod", wrapup );


    num_qry  = om$dimension_of( varray = me->tmpqry ); 

    /* check if a row is selected */
    selRow = 0;
    selflag = FALSE;
    FIfld_get_num_rows ( VD_FP, VD_DIPD_SEL_FLD, &num_row);
    for( i = 0; i < num_row; i++) {
            FIfld_get_select (VD_FP, VD_DIPD_SEL_FLD, i, 0, &sel);
            if (sel) {
                selRow = i;
                selflag = TRUE;
                break;
            }
    }
    /* if no row was selected, give warning message */
    if( !selflag ) {
                selRow = num_row;
    }

    /* if selRow large than num_qry:set it equal to larget row */
    if( selRow > num_qry - 1) {
          selRow = num_qry - 1;
    }  

    /* set select row:  */   
    FIfld_set_select (VD_FP, VD_DIPD_SEL_FLD, selRow, 1, TRUE);

    /* 
     * pop up "select query" form 
     */
    pfxflag = 0;
    qry_ids = NULL;
    qry_envs = NULL;
    qry_names = NULL;
    qry_desc = NULL;
    qry_def = NULL;
    num_qry_sel = 0;
    status =
    VDdispQryPfxForm(msg,
                     &num_qry_sel,
                     &qry_ids,
                     &qry_envs,
                     &qry_names,
                     &qry_desc,
                     pfxflag);
    if( !(status&*msg&1) || !num_qry_sel) {
         FIfld_set_text ( VD_FP, 10, 0, 0,
             "No query is selected or query list is empty", FALSE );
         goto wrapup;
    } 
    /* 
     * check selected query:
     * check it with all query names in the design file.     
     * if name duplication, make new query with name oldname_1, oldname_2 
     * all of those is done in VDcopyQry
     */
     
    for ( i = 0; i < num_qry_sel; i ++ ){
      if( qry_ids[i].osnum != curOS ) {
      status = 
      VDcopyQry(msg, qry_names[i], qry_ids[i], &outQryId, 
                                 &outQryenv, outQryName);
         if( status&*msg&1) {
          qry_names[i][0] = '\0';
          strcpy( qry_names[i], outQryName);
          qry_ids[i] = outQryId;
          qry_envs[i] = outQryenv;
         }   
      }
      if( qry_ids[i].osnum == curOS ) { 
         /* check name with that in tmpqry in order to avoid duplication */
         for(j = 0; j < num_qry; j++ ) {
            if( !strcmp(qry_names[i], me->tmpqry[j].qry_name)) {
               FIfld_set_text ( VD_FP, 10, 0, 0,
                                "Can not duplicate query name", FALSE );
               status = OM_E_ABORT;
               goto wrapup;
            }
         }
      }
    }

    /* get relative query definition */ 
    if ( !VDmalloc_str_list ( &qry_def, num_qry_sel, VD_DIPD_MAX_QRY_DEF_LEN ) )
                {
                        if ( num_qry_sel )
                            printf(" no memory allocated \n");

                        /* 5/6/96 */
                        status = OM_E_ABORT;

                        goto wrapup;  
                }
    
    for (i = 0; i< num_qry_sel; i++ ) {
    qry_def[i][0] = '\0';
    status =
    om$send(msg = message VDquery.VDgive_query(
                                                    msg,
                                                    &select,
                                                    &where,
                                                    &comment ),
                                        targetid = qry_ids[i].objid,
                                        targetos = qry_ids[i].osnum,
                                        senderid = NULL_OBJID );
    	if( status & *msg & 1 ){
          strcat(qry_def[i], select);
          strcat(qry_def[i], where);
    	}
    	_FREE( select );
    	_FREE( where );
    	_FREE( comment );
   	where = NULL;
    	select = NULL;
        comment = NULL;
   }

   /* set max row number */
    num = num_qry + num_qry_sel;
    FIfld_set_num_rows ( VD_FP, VD_DIPD_SEL_FLD, num);
    FIfld_set_max_num_rows ( VD_FP, VD_DIPD_SEL_FLD, num);


   /* make a copy of previous tmpqry */
    status =
    om$vla_set_dimension(  varray =  me->tmpqryc,
                           size   =  0);
    status =
    om$vla_set_dimension(  varray =  me->tmpqryc,
                           size   =   num_qry);

    __CheckRC( status, 1, "om$vla_set_dimension", wrapup );

    for( i = 0; i < num_qry; i++ ) {
       me->tmpqryc[i] = me->tmpqry[i];
    }
 
   /*
    * put instance query_pfx and new selected query into a tmp data
    */
    status =
    om$vla_set_dimension(  varray =  me->tmpqry,
                           size   =  0);
    status =
    om$vla_set_dimension(  varray =  me->tmpqry,
                           size   =  num_qry_sel + num_qry);

    __CheckRC( status, 1, "om$vla_set_dimension", wrapup );

     if( num_qry ) { /* there previous prefix def */
         /* rows: 0 - (selRow) */ 
       for(i = 0; i <= selRow; i++) {
        me->tmpqry[i].pfx_index = i+1;
        me->tmpqry[i].pfx_name[0] = '\0';
        FIfld_get_text( VD_FP, VD_DIPD_SEL_FLD, i, 1,VD_DIPD_MAX_QRY_NAME_LEN,
                        me->tmpqry[i].pfx_name, &sel, &pos);
        me->tmpqry[i].qry_name[0] = '\0';
        strcpy(me->tmpqry[i].qry_name, me->tmpqryc[i].qry_name );
        me->tmpqry[i].qry_def[0] = '\0';
        strcpy(me->tmpqry[i].qry_def, me->tmpqryc[i].qry_def );
        me->tmpqry[i].qry_desc[0] = '\0';
        strcpy(me->tmpqry[i].qry_desc, me->tmpqryc[i].qry_desc );
        me->tmpqry[i].qry_id = me->tmpqryc[i].qry_id;
        me->tmpqry[i].qry_env =me->tmpqryc[i].qry_env;
       }
       /* rows: selRow - (selRow+num_qry_sel-1) for new inserting rwos */
       for(i = selRow+1; i <= (selRow+num_qry_sel); i++) {
          me->tmpqry[i].pfx_index = i+1;
          me->tmpqry[i].pfx_name[0] = '\0';
          strcpy(me->tmpqry[i].pfx_name, "");
          me->tmpqry[i].qry_name[0] = '\0';
          strcpy(me->tmpqry[i].qry_name, qry_names[i - selRow-1] );
          me->tmpqry[i].qry_def[0] = '\0';
          strcpy(me->tmpqry[i].qry_def, qry_def[i - selRow-1] );
          me->tmpqry[i].qry_desc[0] = '\0';
          strcpy(me->tmpqry[i].qry_desc, qry_desc[i - selRow-1] );
          me->tmpqry[i].qry_id = qry_ids[i - selRow-1]; 
          me->tmpqry[i].qry_env = qry_envs[i - selRow-1]; 
       }
       /* rows: (selRow+num_qry_sel) - (num_qry_sel+num_qry-1) */
       for(i = (selRow+num_qry_sel+1); i < num_qry_sel+num_qry; i++) {
        me->tmpqry[i].pfx_index = i + 1;
        me->tmpqry[i].pfx_name[0] = '\0';
        FIfld_get_text( VD_FP, VD_DIPD_SEL_FLD, i-num_qry_sel, 1,
                        VD_DIPD_MAX_QRY_NAME_LEN,
                        me->tmpqry[i].pfx_name, &sel, &pos);
        me->tmpqry[i].qry_name[0] = '\0';
        strcpy(me->tmpqry[i].qry_name, me->tmpqryc[i-num_qry_sel].qry_name );
        me->tmpqry[i].qry_def[0] = '\0';
        strcpy(me->tmpqry[i].qry_def, me->tmpqryc[i-num_qry_sel].qry_def );
        me->tmpqry[i].qry_desc[0] = '\0';
        strcpy(me->tmpqry[i].qry_desc, me->tmpqryc[i-num_qry_sel].qry_desc );
        me->tmpqry[i].qry_id = me->tmpqryc[i-num_qry_sel].qry_id;
        me->tmpqry[i].qry_env =me->tmpqryc[i-num_qry_sel].qry_env;
       }
     }
     else { /* no previous entry */
       for(i = 0; i < (num_qry+num_qry_sel); i++) {
          me->tmpqry[i].pfx_index = i+1;
          me->tmpqry[i].pfx_name[0] = '\0';
          strcpy(me->tmpqry[i].pfx_name, "");
          me->tmpqry[i].qry_name[0] = '\0';
          strcpy(me->tmpqry[i].qry_name, qry_names[i] );
          me->tmpqry[i].qry_def[0] = '\0';
          strcpy(me->tmpqry[i].qry_def, qry_def[i] );
          me->tmpqry[i].qry_desc[0] = '\0';
          strcpy(me->tmpqry[i].qry_desc, qry_desc[i] );
          me->tmpqry[i].qry_id = qry_ids[i];
          me->tmpqry[i].qry_env = qry_envs[i];

       } 
     }
     /*
      * display tmpqry in form
      */
     for( i = 0; i < num_qry_sel+num_qry; i++ ) {
         FIfld_set_value ( VD_FP, VD_DIPD_SEL_FLD, i, 0,
                          (double)me->tmpqry[i].pfx_index, FALSE );
         FIfld_set_text ( VD_FP, VD_DIPD_SEL_FLD, i, 1,
                          me->tmpqry[i].pfx_name, FALSE );
         FIfld_set_text ( VD_FP, VD_DIPD_SEL_FLD, i, 2,
                          me->tmpqry[i].qry_name, FALSE );
         FIfld_set_text ( VD_FP, VD_DIPD_SEL_FLD, i, 3,
                          me->tmpqry[i].qry_def, FALSE );
     } 
      
wrapup:
 
    _FREE ( qry_ids );
    _FREE ( qry_envs );
    if ( qry_names ) VDfree_str_list ( qry_names, num_qry_sel );
    if ( qry_desc ) VDfree_str_list ( qry_desc, num_qry_sel );

    /* 5/6/96 
        if ( qry_names ) VDfree_str_list ( qry_names, num_qry_sel );
    	if ( qry_desc ) VDfree_str_list ( qry_desc, num_qry_sel );
    	if ( qry_def ) VDfree_str_list ( qry_def, num_qry_sel );
    */

    	VDfree_str_list ( qry_names, num_qry_sel );
    	VDfree_str_list ( qry_desc, num_qry_sel );
	VDfree_str_list ( qry_def, num_qry_sel );
    End

    return status;
} /* VDinsItmPreRow */

/*+me
 ---------------------------------------------------------------------------

  Private Message VDinitPfxFrm

  Abstract
        This method is used to initiate the "define item prefix definition"
        form 

  Arguments
        IGRlong         *msg            O       Return code

  Status/Return Code
      status == OM_S_SUCCESS            if success

 ---------------------------------------------------------------------------
-me*/
method VDinitPfxFrm( )
{
IGRlong                 status = OM_S_SUCCESS;
int                     num_qry_with_pfx, ii,i;
IGRlong                 msg;

                #ifdef DEBUG
                        printf(" VDCmdDeItPr.VDinitPfxFrm\n");
                #endif

    SetProc( VDCmdDeItPr.VDinitPfxFrm); Begin
    msg = MSSUCC;

    /* get query and prefix list */
    status =
    om$send(msg = message VDCmdDeItPr.VDgetQryPfxList(&msg),
                  targetid = my_id );
    if( !(status&msg&1)) { 
        FIfld_set_text ( VD_FP, 10, 0, 0," Query list is empty", FALSE );
        goto wrapup;
    }

    /* set queries with prefix into form */ 
        num_qry_with_pfx  = om$dimension_of( varray = me->query_pfx ); 
        FIfld_set_num_rows ( VD_FP, VD_DIPD_SEL_FLD, num_qry_with_pfx);
        FIfld_set_max_num_rows ( VD_FP, VD_DIPD_SEL_FLD, num_qry_with_pfx);

        for(ii=0; ii<num_qry_with_pfx; ii++) {
         /* set query name and description */

         FIfld_set_value ( VD_FP, VD_DIPD_SEL_FLD, ii, 0,  
                          (double)me->query_pfx[ii].pfx_index, FALSE );
         FIfld_set_text ( VD_FP, VD_DIPD_SEL_FLD, ii, 1,  
                          me->query_pfx[ii].pfx_name, FALSE );
         FIfld_set_text ( VD_FP, VD_DIPD_SEL_FLD, ii, 2,  
                          me->query_pfx[ii].qry_name, FALSE );
         FIfld_set_text ( VD_FP, VD_DIPD_SEL_FLD, ii, 3,  
                          me->query_pfx[ii].qry_def, FALSE );
        }

    /*
     * set instance tmpqry
     */
    status =
    om$vla_set_dimension(  varray =  me->tmpqry,
                           size   =  0);
    status =
    om$vla_set_dimension(  varray =  me->tmpqry,
                           size   =  num_qry_with_pfx);

    __CheckRC( status, 1, "om$vla_set_dimension", wrapup );
    for (i = 0; i< num_qry_with_pfx; i++) {
        me->tmpqry[i] = me->query_pfx[i];
    }

    /* set tmpqry */
wrapup:
    End
    return status;
} /* VDinitPfxFrm */


/*+me
 ---------------------------------------------------------------------------

  Public Message VDgetQryPfxList

  Abstract
        This method is used to get query list with prefix from query collector
        (only in design file) 

  Arguments
        IGRlong         *msg            O       Return code

  Status/Return Code
      status == OM_S_SUCCESS       if success

 ---------------------------------------------------------------------------
-me*/
method VDgetQryPfxList(  IGRlong         *msg)
{
IGRlong                 status = OM_S_SUCCESS;
IGRint                  num_qry,i,ii;
struct GRid             *qry_id_list = NULL;
struct GRmd_env         *qry_env_list = NULL;
IGRchar                 **qry_name_list = NULL,
                        **qry_desc_list  = NULL;
IGRint                  num_qry_with_pfx;
IGRchar                 *select = NULL,
                        *where = NULL,
                        *comment = NULL ;
IGRchar                 pfxName[80];
IGRint                  pfxIndex;
GRspacenum              curOS;

		#ifdef DEBUG
       			printf(" VDCmdDeItPr.VDgetQryPfxList\n");
		#endif

    SetProc( VDCmdDeItPr.VDgetQryPfxList); Begin
    *msg = MSSUCC;

    /* get all queries */ 
    status = VDget_qry_list ( msg, &num_qry,  &qry_id_list, &qry_env_list,
                           &qry_name_list, &qry_desc_list  );
    __CheckRC( status, *msg, "VDget_qry_list", wrapup );

    if ( num_qry == 0 ) {
       ex$message (  in_buff = "No queries defined",
                  field   = ERROR_FIELD,
                  justification = CENTER_JUS );
       *msg = OM_E_ABORT;
       goto wrapup;
    }

    /* 
     * set instance query 
     */
    status =
    om$vla_set_dimension(  varray =  me->query,
                           size   =  num_qry);

    __CheckRC( status, 1, "om$vla_set_dimension", wrapup );

    for (i = 0; i < num_qry; i++) {
        me->query[i].qry_id =  qry_id_list[i];
        me->query[i].qry_env = qry_env_list[i];
        me->query[i].qry_name[0] = '\0';
        strcpy( me->query[i].qry_name, qry_name_list[i]);
        me->query[i].qry_desc[0] = '\0';
        strcpy( me->query[i].qry_desc, qry_desc_list[i]);
        me->query[i].mod_flag = 0;

        /* get query definition */
        me->query[i].qry_def[0] = '\0';
        status =
        om$send(msg = message VDquery.VDgive_query(
                                                    msg,
                                                    &select,
                                                    &where,
                                                    &comment ),
                                        targetid = me->query[i].qry_id.objid,
                                        targetos = me->query[i].qry_id.osnum,
                                        senderid = NULL_OBJID );
        if( status & *msg & 1 ){
           strcat(me->query[i].qry_def, select); 
           strcat(me->query[i].qry_def, where); 
        }
        _FREE( select );
        _FREE( where );
        _FREE( comment );
        where = NULL;
        select = NULL;
        comment = NULL;

        /* assign them later */
        me->query[i].pfx_index = -1;
        me->query[i].pfx_name[0] = '\0';
    } 

    /* get current module */
    status =
    ex$get_cur_mod(  osnum   = &curOS);
    __CheckRC( status, 1, "ex$get_cur_mod", wrapup );

    /*
     * get query list with the prefix and in design file
     */
    ii = 0;
    for (i = 0; i < num_qry; i ++ ) {
           /* read pfxIndex and pfxName from collector */
           pfxIndex = -1;
           pfxName[0] = '\0';
           status =
           om$send(msg = message VDquery.VDgetPfxInfo( msg,
                                                       &pfxIndex,
                                                       pfxName),
                                        targetid = qry_id_list[i].objid,
                                        targetos = qry_id_list[i].osnum,
                                        senderid = NULL_OBJID );
           if( (status & *msg & 1) && qry_id_list[i].osnum == curOS ){
              ii = ii + 1 ;
           }
   }
   num_qry_with_pfx  = ii;
   /*
    * allocate instance query_pfx(queries with prefix only in design file)
    */
   status =
   om$vla_set_dimension(  varray =  me->query_pfx,
                          size   =  num_qry_with_pfx);
   __CheckRC( status, 1, "om$vla_set_dimension", wrapup );

   /*
    * make query list with prefix
    */
   ii = 0;
   if ( num_qry_with_pfx ) {
      for (i = 0; i < num_qry; i ++ ) {
           /* read pfxIndex and pfxName from collector */
           pfxIndex = -1;
           pfxName[0] = '\0';
           status =
           om$send(msg = message VDquery.VDgetPfxInfo( msg,
                                                       &pfxIndex,
                                                       pfxName),
                                        targetid = qry_id_list[i].objid,
                                        targetos = qry_id_list[i].osnum,
                                        senderid = NULL_OBJID );
           if( (status & *msg & 1) && qry_id_list[i].osnum == curOS ){
             me->query_pfx[ii].qry_id =  qry_id_list[i];
             me->query_pfx[ii].qry_env = qry_env_list[i];
             me->query_pfx[ii].qry_name[0] = '\0';
             strcpy( me->query_pfx[ii].qry_name, qry_name_list[i]);
             me->query_pfx[ii].qry_desc[0] = '\0';
             strcpy( me->query_pfx[ii].qry_desc, qry_desc_list[i]);
             me->query_pfx[ii].mod_flag = 0;

             me->query_pfx[ii].qry_def[0] = '\0';
             strcat(me->query_pfx[ii].qry_def, me->query[i].qry_def); 

             me->query_pfx[ii].pfx_name[0] = '\0';
             strcat( me->query_pfx[ii].pfx_name, pfxName);
             me->query_pfx[ii].pfx_index = pfxIndex;

             strcat(me->query[i].pfx_name, pfxName);
             me->query[i].pfx_index = pfxIndex;

             ii = ii + 1 ;
           } /* if */
      } /* for */

      /*
       * sort me->query_pfx
       */
      qsort( me->query_pfx, num_qry_with_pfx, sizeof(struct VDitmQryPfxInfo),
                      (int (*)())indexcmp );

   } /* if ( num_qry_with_pfx ) */

   if( num_qry_with_pfx ) {
       status = OM_S_SUCCESS;
       *msg = MSSUCC;
   } 
wrapup:

    _FREE (qry_id_list ); 
           qry_id_list = NULL; 

    _FREE (qry_env_list); 
           qry_env_list = NULL; 

    if ( qry_name_list ) {
         vd$free_str_list (  str_list = qry_name_list,
                             num_str  = num_qry );
         qry_name_list = NULL;
    }
    if ( qry_desc_list ) {
         vd$free_str_list (  str_list = qry_desc_list,
                             num_str  = num_qry );
         qry_desc_list = NULL;
    }

    End
    return status;
} /* VDgetQryPfxList */


end implementation VDCmdDeItPr;
