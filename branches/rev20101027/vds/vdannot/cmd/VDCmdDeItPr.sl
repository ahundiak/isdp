/* $Id: VDCmdDeItPr.sl,v 1.1.1.1 2001/01/04 21:07:40 cvs Exp $  */
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdannot/cmd/VDCmdDeItPr.sl
 *
 * Description:
 *      Command object for "Define Item Prefix Definitions"
 *      Slic file to produce spec file VDCmdDeItPr.S and 
 *                           implementation file VDCmdDeItPri.I
 *      VDDeItmPre.t file for command table and 
 *      VDDeItmPrFrm..I for form implementation 
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDCmdDeItPr.sl,v $
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
# Revision 1.3  1995/08/10  20:30:36  pinnacle
# Replaced: vdannot/cmd/VDCmdDeItPr.sl for:  by yzhu for vds.240
#
# Revision 1.2  1995/07/26  15:47:28  pinnacle
# Replaced: vdannot/cmd/VDCmdDeItPr.sl for:  by yzhu for vds.240
#
# Revision 1.1  1995/07/13  18:23:08  pinnacle
# Created: vdannot/cmd/VDCmdDeItPr.sl by yzhu for vds.240
#
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      07/10/95        Y.Zhu           Creation
 *
 * -------------------------------------------------------------------*/


/****************************************************************************
 *                      CLASS SPECIFICATION
 ****************************************************************************/

class           VDCmdDeItPr
super_class     VDS_LOCATE
command_table   "vds.cmd"
product_name    "$VDS"
options         "SItc"
start_state     terminate


/****************************************************************************
 *                      SPECIFICATION AREA
 ****************************************************************************/
specification

#include  "OMminimum.h"
#include  "OMprimitives.h"
#include  "igetypedef.h"
#include  "igrtypedef.h"
#include  "FI.h"
#include  "VDSannot.h"
#include  "nddef.h"

/* Below is information for creating the spec file */

instance
{
      /* form info */
      IGRint                         rep_label;      /* Form return status */

      /* query info */ 
      variable struct VDitmQryPfxInfo  query[0];     /* all query list     */ 
      variable struct VDitmQryPfxInfo  query_pfx[0]; 
                                            /* query with ordering pfx     */ 
      variable struct VDitmQryPfxInfo  tmpqry[0]; 
      variable struct VDitmQryPfxInfo  tmpqryc[0]; 
                                            /* temp query  */ 
}

/****************************************************************************/
/*      IMPLEMENTATION AREA                                             *****/
/****************************************************************************/
implementation
#include <stdio.h>

#include "OMparameters.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "igrdef.h"
#include "igrmacros.h"
#include "msdef.h"
#include "exdef.h"
#include "coparamac.h"                  /* as$start_fence */
#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"
#include "go.h"
#include "FI.h"
#include "FEI.h"
#include "AS_status.h"
#include "VDSannot.h"
#include "VDCmdDef.h"                  /* VD_ERROR  */


/* #define  DEBUG */

from GRgraphics   import GRgetname;
from VDquery      import VDsetPfxInfo, VDdelPfxInfo;

/*-------------*/
/* action area */    
/*-------------*/
action form_notification extern

action VDitmPreRowChg(IGRlong  *sts;
                      IGRint   lflag)          extern

action VDinsItmPreRow(IGRlong  *sts)          extern

action VDinitPfxFrm( )         extern

action VDgetQryPfxList(IGRlong  *sts)         extern


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  Public Message  VDsetItmPreDef 

  Abstract
        This method is used to set item prefix definition into query
        collector.  

  Arguments
        IGRlong         *sts            O       Return code

  Notes/Remarks

  Status Code
      status == OM_S_SUCCESS

  Return Code
      *sts =    VD_SUCCESS
                VD_ERROR (no memory)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
action VDsetItmPreDef 
{
IGRint    i, num_qry,len,sel, pos, num_qryi_with_pfx;
IGRlong   msg;
IGRchar   pfxname[VD_DIPD_MAX_QRY_NAME_LEN];
IGRchar   errmsg[50];

#ifdef DEBUG
    printf("  VDCmdDeItPr.VDsetItmPreDef \n");
#endif
     SetProc(  VDCmdDeItPr.VDsetItmPreDef ); Begin
     *sts = VD_SUCCESS;

     num_qry  = om$dimension_of( varray = me->tmpqry );
     /* read and check the prefix name in tmpqry */
     for(i = 0; i<num_qry; i++) {
        me->tmpqry[i].pfx_name[0] = '\0';
        FIfld_get_text( VD_FP, VD_DIPD_SEL_FLD, i, 1,VD_DIPD_MAX_QRY_NAME_LEN,
                        pfxname, &sel, &pos);
        /* get red out front space */
        while(pfxname[0] == ' '&& (&pfxname[1] != NULL)){
                strcpy(pfxname, &pfxname[1]);
        }
     
        /* if prefix name is empty, return error */ 
        if(pfxname[0] =='\0') {
                errmsg[0] = '\0';
                sprintf(errmsg, "Row %d: prefix not defined",i+1);
                FIfld_set_text ( VD_FP, 10, 0, 0, errmsg, FALSE );
                *sts = VD_ERROR;
                goto wrapup;
        }
   
        /* 
        * check if the last char is digit. If yes, return error. case "V1 "
        * should be right.
        */
        len = strlen(pfxname);
        if( isdigit(pfxname[len-1])) {
                errmsg[0] = '\0';
                sprintf(errmsg, "Row %d: prefix cannot end in a digit",i+1);
                FIfld_set_text ( VD_FP, 10, 0, 0, errmsg, FALSE );
                *sts = VD_ERROR;
                goto wrapup;
        }
        /* copy pfxname into tmpqry */
        me->tmpqry[i].pfx_name[0] = '\0';
        strcpy(me->tmpqry[i].pfx_name, pfxname);
     } /* for i */ 
     /*
      * delete aLL previous prefix in query_pfx
      * because "delete row"  need delete some previou prefix
      */

     num_qryi_with_pfx  = om$dimension_of( varray = me->query_pfx );
     for(i = 0; i< num_qryi_with_pfx; i++) {
         status  = om$send ( msg = message  VDquery.VDdelPfxInfo( &msg),
                                   targetid = me->query_pfx[i].qry_id.objid,
                                   targetos = me->query_pfx[i].qry_id.osnum,
                                   senderid = NULL_OBJID );
         as$status(); 
      }

     /* 
      * put prefix info into query collector 
      */
     for (i = 0; i< num_qry; i++) {
             status  = om$send ( msg = message  VDquery.VDsetPfxInfo( &msg,
                                                 &me->tmpqry[i].pfx_index,
                                                 me->tmpqry[i].pfx_name),
                                        targetid = me->tmpqry[i].qry_id.objid,
                                        targetos = me->tmpqry[i].qry_id.osnum,
                                        senderid = NULL_OBJID );
             as$status(); 
             if( !(status&msg&1)) {
                errmsg[0] = '\0';
                sprintf(errmsg, "Can not set prefix for query: %s",
                                 me->tmpqry[i].qry_name);
                FIfld_set_text ( VD_FP, 10, 0, 0, errmsg, FALSE );
             } 
     }
 
     /* renew me->tmpqry, me->query_pfx */ 
        status  
        = om$send ( msg = message  VDCmdDeItPr.VDinitPfxFrm( ),
         					targetid = my_id );
        as$status();
  
wrapup:
     End
     goto quit;
} /* VDsetItmPreDef */
/*----------------------------------------------------------------------------
 * aceion renurn_form: 
 * status field in CEO_LOCATE is to get return value of the
 * routine form_notification; sts is used in state table
 *----------------------------------------------------------------------------*/
action VDItmPreReturnFrm
{
#ifdef DEBUG
        printf("return_form\n");
#endif
        *sts = me->rep_label;
        status = OM_S_SUCCESS;
        goto quit;
} /* VDItmPreReturnFrm */
