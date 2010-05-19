/* $Id: VDCmdEdTbRw.sl,v 1.4 2001/05/07 23:42:04 ylong Exp $  */
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd/VDCmdEdTbRw.sl
 *
 * Description:
 *      COmmand object for "Edit Table Row"
 *      Slic file to produce spec file, state table and command table entry
 *      Implementation files are separate
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDCmdEdTbRw.sl,v $
 *      Revision 1.4  2001/05/07 23:42:04  ylong
 *      *** empty log message ***
 *
 *      Revision 1.3  2001/05/02 20:46:44  ylong
 *      *** empty log message ***
 *
 *      Revision 1.2  2001/02/15 15:40:29  ramarao
 *      Don't empty the collectors.
 *
 *      Revision 1.1.1.1  2001/01/04 21:09:26  cvs
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
# Revision 1.18  1996/04/25  15:58:46  pinnacle
# Replaced: vdtbl/cmd/VDCmdEdTbRw.sl for:  by yzhu for vds.240
#
# Revision 1.17  1995/10/13  18:26:46  pinnacle
# Replaced: vdtbl/cmd/VDCmdEdTbRw.sl for:  by yzhu for vds.240
#
# Revision 1.16  1995/10/12  21:14:00  pinnacle
# Replaced: vdtbl/cmd/VDCmdEdTbRw.sl for:  by yzhu for vds.240
#
# Revision 1.15  1995/09/07  17:03:30  pinnacle
# Replaced: vdtbl/cmd/VDCmdEdTbRw.sl for:  by yzhu for vds.240
#
# Revision 1.14  1995/08/23  19:36:02  pinnacle
# Replaced: vdtbl/cmd/VDCmdEdTbRw.sl for:  by yzhu for vds.240
#
# Revision 1.13  1995/08/09  21:10:40  pinnacle
# Replaced: vdtbl/cmd/VDCmdEdTbRw.sl for:  by yzhu for vds.240
#
# Revision 1.10  1995/08/03  22:26:30  pinnacle
# Replaced: vdtbl/cmd/VDCmdEdTbRw.sl for:  by yzhu for vds.240
#
#
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      06/01/95        Y.Zhu           Creation
 *	05/02/01	ylong		CR5119, TR5164
 * -------------------------------------------------------------------*/


/****************************************************************************
 *                      CLASS SPECIFICATION
 ****************************************************************************/

class           VDCmdEdTbRw
super_class     VDS_LOCATE
command_table   "vds.cmd"
product_name    "$VDS_PATH"
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
#include  "grdpbdef.h"
#include  "igrdef.h"
#include  "dpdef.h"
#include  "dpmacros.h"
#include  "grdpbmacros.h"
#include  "FI.h"
#include  "VDdrwlo.h"
#include  "VDdrwtbl.h"
#include  "VDtblCmdDef.h"
#include  "nddef.h"

/* Below is information for creating the spec file */

instance
{

      /* locate Row */
      variable struct GRobj_env      VDlocRows[0];   /* selected rows */

      /* table info */
      variable struct VDdrwlo_data   datRecs[0];    /* replaceble date record */
      variable struct VDdrwlo_apifix fixDataTextRecs[0];/* fixed text date rec*/

      variable IGRint                colWidth[0];    /* form column width     */
      variable IGRint                oriColWidth[0]; /* table column width    */
      variable struct VDrowDataList  newRowData[0];  /* new row data          */
                                     

      /* form info */
      IGRint                         maxLinesPerRow; /* max line num per row  */
      IGRint                         nbRows;         /* total row number      */
      IGRint                         selRowInd;      /* select row number     */
      variable struct VDdrw_rowInfo  tblRows[0];     /* table row info        */
      variable struct GRobj_env      locObjs[0];     /* object env            */

      IGRint			     nbTotalCol;     /* adjust total Cols no  */

      IGRint			     nbvisCols;      /*num of visiable cols   */
      IGRint                         rep_label;      /* Form return status    */
      IGRint                         preStartColInd; /* vis col info          */
      IGRint                         preVisColNum;   /* vis col info          */
      IGRint                         newStartColInd; /* vis col info          */
      IGRint                         newVisColNum;   /* vis col info          */
      IGRint                         nbShiftCol;     /* shift col num         */
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

#include "DItypedef.h"
#include "DIdef.h"
#include "DIprims.h"
#include "ndmacros.h"

#include "go.h"

#include "VDdrwlo.h"
#include "VDdrwlo_pr.h"
#include "VDdrwtbl.h"
#include "VDtblCmdDef.h"

#include "VDCmdDef.h"
#include "FI.h"
#include "FEI.h"
#include "AS_status.h"

/* #define  DEBUG */
%safe
  static int x_pos = -1,y_pos = -1;
%endsafe


from GRgraphics   import GRgetname;
from VDdrwTblRow  import GRgetobjinfo;
from VDdrwTbl     import VDgetTotalNbOfRows;
from VDdrwTbl     import VDgetTableParts;
from VDdrwTbl     import VDgetTableLayoutName;
from VDdrwTblHdr  import VDgetRowInfo;
from VDdrwTblHdr  import VDrowNoToGRid;
from VDdrwTblRow  import VDgetParentObjectList;
from VDdrwTblRow  import VDgetCurrentRowValues;
from VDdrwTblRow  import VDisRowLinedOut;
from VDSroot      import VDcompute;
from ACrg_collect import ACset_list_attribute;
from ACrg_collect import ACrem_attribute;
from VDdrwTblRow  import ACfind_temp_obj;
from VDdrwTblRow  import VDgetQtyExpr;
from VDdrwTblRow  import VDgetItemNumber, VDputItemNumber;
from GRgraphics   import GRdisplay;
from NDmacro      import ACreturn_foot;

/*-------------*/
/* action area */    
/*-------------*/
action form_notification extern

action VDsetRowDataStr(IGRlong  *sts;
                       IGRint   selRowInd)     extern

action VDupdVisCols(  IGRlong   *sts;
                      IGRint    *preStartColInd;
                      IGRint    *preVisColNum;
                      IGRint    *newStartColInd;
                      IGRint    *newVisColNum)  extern

action VDgetVisColsInfo(      IGRlong  *sts;
                              IGRint    preStartColInd;
                              IGRint    preVisColNum;
                              IGRint    *newStartColInd;
                              IGRint    *newVisColNum;
                              IGRint    nbShiftCol;
                              IGRint    direct)      extern

action VDmodNewValStr(       IGRlong  *sts;
                             IGRint    preStartColInd;
                             IGRint    preVisColNum) extern

action VDupdatHighlight(       IGRlong *sts; 
                               IGRint  selRowInd)    extern

/*+me
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  Message  VDlocateRow 

  Abstract
        This method locate row of table for edit table.

  Arguments
        IGRlong         *sts            O       Return code

  Notes/Remarks

  Status Code
      status == OM_S_SUCCESS

  Return Code
      *sts =    VD_SUCCESS
                VD_ERROR(no objects located)
                VD_ETR_LINE_OUT (line out row)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-me*/
action VDlocateRow 
{
struct GRobj_env        *rowObjs = NULL;
IGRint                  NbRowObjs;
IGRint                  i;
IGRint                  count;
IGRshort                isLinedOut;

     SetProc(  VDCmdEdTbRw.VDlocateRow ); Begin

     *sts = VD_SUCCESS ;
     /*
      * using as$start_fence to locate row object
      */
     status =
     as$start_fence( set    = &me->event1.located_object[0].located_obj,
                     set_env = &me->event1.located_object[0].module_info,
                     nb_obj        = &NbRowObjs,
                     p_obj_env     = &rowObjs,
                     response      = me->response,
                     response_data = me->response_data );
    __DBGpr_int( "No of objects located", NbRowObjs );

     if( !(status & 1) ) {
        *sts = VD_ERROR;
        goto wrapup;
     }

     /* check if the row is line out */
     status =
     _VD_SEND_OBJ( rowObjs[0].obj_id, VDdrwTblRow.VDisRowLinedOut(sts,
                                              &isLinedOut ));

     if(!(status&*sts&1)) {
       *sts = VD_ERROR;  
       goto wrapup;
     }
 
     if( isLinedOut == 1) {
       *sts = VD_ETR_LINE_OUT;  
       goto wrapup;
     }
     status =
     om$vla_set_dimension(  varray =  me->VDlocRows,
                            size   =  0);
     count = 0;

     if ( NbRowObjs ) {
        /* increase the list of me->VDlocRows */
        for( i=0 ; i<NbRowObjs ; i++ ){
          /* add in list.  */
          if( rowObjs[i].obj_id.objid != NULL_OBJID ){
             /* increment of list. */
             status =
             om$vla_set_dimension(  varray =  me->VDlocRows,
                                    size   =  count +1 );
             me->VDlocRows[count]  = rowObjs[i];
             count ++;
          }
        }
     } /* if ( NbRowObjs ) */

wrapup:
     ASend_fence();
     End
     goto quit;
} /* VDlocateRow */
/*+me
 ---------------------------------------------------------------------------

  Message VDgetRowInfo

  Abstract
        This method get row info from opdates  row id

  Arguments
        IGRlong         *sts            O       Return code

  Statuse
      status == OM_S_SUCCESS      
  Return Code
      *sts =    VD_SUCCESS
                VD_ERROR(error)
 ---------------------------------------------------------------------------
-me*/
action VDgetRowInfo
{
    OMuint              count;
    IGRchar             pathname[DI_PATH_MAX];
    GRname              tblName;
    struct GRid         tblId;
    OM_S_CHANSELECT     hdrChan, ownerChan;
    OM_S_OBJECT_LINKAGE hdrObj;
    IGRint              nbRows;
    IGRint              nbParts;
    struct VDdrwlo_tab  tblRec;
    IGRint              nbHdrRows;
    IGRint              startRowNo;
    IGRint              i, ind,j, nbTxt,k; 
    IGRdouble           height;
    IGRshort            nbFixRecs, nbDatRecs, nbObjs;
    struct GRobj_env    *locObjs = NULL;
    IGRint              nbCols = 0;
    struct VDdrw_colInfo *colRecs = NULL;
    struct VDdrwlo_qtyExp   qty;
    struct GRid         *hdrIds = NULL;
    struct VDhdrRowinfo *hdrRow = NULL; 
    IGRchar             tblLayoutName[VD_ETR_TEXT_SIZE]; 
    struct VDdrwlo_apifix *fixRecs = NULL;

 
    SetProc(  VDgetRowInfo); Begin

    *sts = VD_SUCCESS; 

    /* select the channels */
    status =
    om$make_chanselect( channame        = "VDdrwTblRow.to_tblHdr",
                        p_chanselect    = &hdrChan );
    CheckRC( status, 1 );
 
    if( !(status & 1) ) {
         *sts = VD_ERROR;
         goto wrapup;
    } 
 

    status =
    om$make_chanselect( channame        = "GRconnector.to_owners",
                        p_chanselect    = &ownerChan );
    CheckRC( status, 1 );
 
    if( !(status & 1) ) {
         *sts = VD_ERROR;
         goto wrapup;
    } 

    /* 
     * from selected row to get the header object 
    */

    status =
    om$get_channel_objects(     objid         = me->VDlocRows[0].obj_id.objid, 
    				osnum         = me->VDlocRows[0].obj_id.osnum, 
                                p_chanselect   = &hdrChan,
                                size           = 1,
                                list           = &hdrObj,
                                count          = &count );
    CheckRC( status, 1 );

    if( !(status & 1) ) {
         *sts = VD_ERROR;
         goto wrapup;
    }


    /* get the VDdrwTbl object */
    status =
    om$get_objid_at_index(      osnum           = hdrObj.osnum,
                                objid           = hdrObj.S_objid,
                                p_chanselect    = &ownerChan,
                                index           = 0,
                                objidaddr       = &tblId.objid,
                                osnumaddr       = &tblId.osnum );

    CheckRC( status, 1 );

    if( !(status & 1) ) {
         *sts = VD_ERROR;
         goto wrapup;
    }
    __DBGpr_obj( "Table id", tblId );


    /* get table name */

    status =  
    _VD_SEND_OBJ( tblId, GRgraphics.GRgetname(  sts,
                                                pathname ) );
    CheckRC( status, *sts );

    if( !(status & *sts & 1) ) {
         *sts = VD_ERROR;
         goto wrapup;
    }

    __CheckRC( status, *sts, "GRgraphics.GRgetname", wrapup );

    /* strip off the directory name */
    status = di$split(  pathname        = pathname,
                        name            = tblName );

    CheckRC( status, *sts );
    __DBGpr_str( "\n\ttblName", tblName );
    

    /* get total number of rows */ 
    status =
    _VD_SEND_OBJ(tblId, VDdrwTbl.VDgetTotalNbOfRows( sts, &nbRows ) );
    CheckRC( status, *sts );

    if( !(status & *sts & 1) ) {
         *sts = VD_ERROR;
         goto wrapup;
    }

    if( !nbRows )
    {
            UI_status( "Empty table selected" );
            *sts = VD_ERROR;
            goto wrapup;
    }
    me->nbRows = nbRows;

    /*
     * retrieve the list of headers
     */

    /* get number of table parts(headers) */
    status =
    _VD_SEND_OBJ( tblId, VDdrwTbl.VDgetTableParts(  sts,
                                                    &nbParts,
                                                    NULL ) );
    CheckRC( status, *sts );

    if( !(status & *sts & 1) ) {
         *sts = VD_ERROR;
         goto wrapup;
    }

    __DBGpr_int( "Number of table parts", nbParts );

 
    /* allocate memory for the headers */
    hdrIds = _MALLOC( nbParts, struct  GRid );

    if( !hdrIds ) {
        UI_status( "Error encountered : command terminated" );
        *sts = VD_ERROR;
        goto wrapup;
    }

    /* get the list of table headers */

    status =
    _VD_SEND_OBJ( tblId, VDdrwTbl.VDgetTableParts(  sts,
                                                    &nbParts,
                                                    hdrIds ) );

    CheckRC( status, *sts );

    if( !(status & *sts & 1) ) {
         *sts = VD_ERROR;
         goto wrapup;
    }
    __DBGpr_objlist( "List of header ids", nbParts, hdrIds );

    /* 
     * get row info for each header and initialize them into the hdrRow 
     * get the list of rowIds and initialize them into the me->tblRows 
     */
    hdrRow =  _MALLOC( nbParts ,  struct VDhdrRowinfo );
    if( !hdrRow ) {
        UI_status( "Error encountered : command terminated" );
        *sts = VD_ERROR;
        goto wrapup;
    }

    status =
    om$vla_set_dimension(  varray  = me->tblRows,
                           size    = 0 );

    status =
    om$vla_set_dimension(  varray  = me->tblRows,
                           size    = me->nbRows);

    CheckRC( status, 1 );

    if( !(status & 1) )
    {
        UI_status( "Error encountered : command terminated" );
        *sts = VD_ERROR;
        goto wrapup;
    }

    status =
    om$vla_set_dimension(  varray  = me->locObjs,
                           size    = 0 );

    ind = 0;
    for( i = 0 ; i < nbParts ; i++ ) {
       /* get hdr row info  */
       status =
       _VD_SEND_OBJ( hdrIds[i], VDdrwTblHdr.VDgetRowInfo(  sts,
                                                           &nbHdrRows,
                                                           &startRowNo ) );
       CheckRC( status, *sts );

       if( !(status & *sts & 1) ) {
                             continue;
       }

       __DBGpr_int( "i", i );
       __DBGpr_int( "\tNumber of rows in header", nbHdrRows );
       __DBGpr_int( "\tStart row number", startRowNo );

       hdrRow[i].nbHdrRows = nbHdrRows;
       hdrRow[i].startRowNo = startRowNo;
       hdrRow[i].hdrIds = hdrIds[i];

       /* 
        * for each row, get the rowId, startIndex, qty and the number of 
        * model objects 
        */
       for( j = startRowNo ; j < (startRowNo + nbHdrRows) ; j++ ) {
            status =
            _VD_SEND_OBJ( hdrIds[i], VDdrwTblHdr.VDrowNoToGRid(
                                                sts,
                                                j,
                                                &me->tblRows[ind].rowId ) );
	    CheckRC( status, *sts );

 	    if( !(status & *sts & 1) ) {
    	    	*sts = VD_ERROR;
       	    	goto wrapup;
    	    }

            __DBGpr_obj( "Row id ", me->tblRows[ind].rowId );

            me->tblRows[ind].nbObjs = 0;
            status =
            _VD_SEND_OBJ( me->tblRows[ind].rowId, 
                          VDdrwTblRow.VDgetParentObjectList( sts,
                                                       &me->tblRows[ind].nbObjs,
                                                       NULL ) );
            CheckRC( status, *sts );
 	    if( !(status & *sts & 1) ) {
    	    	*sts = VD_ERROR;
       	    	goto wrapup;
    	    }
            __DBGpr_int( "No of parent set objects ", me->tblRows[ind].nbObjs );

            /*   get me->locObjs   */ 
            if( me->tblRows[ind].nbObjs == 0) {
                ind++;
                continue;
            }
            locObjs = NULL;
            locObjs = _MALLOC( me->tblRows[ind].nbObjs, struct GRobj_env); 
            status =
            _VD_SEND_OBJ( me->tblRows[ind].rowId, 
                          VDdrwTblRow.VDgetParentObjectList( sts,
                                                       &me->tblRows[ind].nbObjs,
                                                       locObjs ) );
            CheckRC( status, *sts );
 	    if( !(status & *sts & 1) ) {
    	    	*sts = VD_ERROR;
       	    	goto wrapup;
    	    }

            nbObjs = om$dimension_of( varray = me->locObjs ); 
            status =
            om$vla_set_dimension(  varray  = me->locObjs,
                                   size    = nbObjs + me->tblRows[ind].nbObjs);

            CheckRC( status, 1 );

            if( !(status & 1) )
            {
              UI_status( "Error encountered : command terminated" );
    	      *sts = VD_ERROR;
              goto wrapup;
            }
            for( k = nbObjs; k < nbObjs + me->tblRows[ind].nbObjs; k++) {
               me->locObjs[k] = locObjs[k - nbObjs];
            }

		#ifdef DEBUG
            	for( k = nbObjs; k < nbObjs+ me->tblRows[ind].nbObjs; k++) 
    		printf( "\n\t me->locObjs[%d].obj_id = [%d, %d]\n", 
                  k, me->locObjs[k].obj_id.objid, me->locObjs[k].obj_id.osnum);
		#endif

            _FREE(locObjs);
            locObjs = NULL; 

		#ifdef DEBUG
    		printf( "\n\t tblRows[%d].nbObjs = %d\n", ind, 
                                         me->tblRows[ind].nbObjs);
    		printf( "\n\t tblRows[%d].startIndex = %d\n", 
                               ind, me->tblRows[ind].startIndex);
		#endif
            ind++;
      }
    } /* for i */

	#ifdef DEBUG
    		printf( "\n\t ind = %d\n", ind);
	#endif

    /* get selected row number in the table */
    for( i = 0 ; i < me->nbRows ; i++ ) {
       if ( me->tblRows[i].rowId.objid == me->VDlocRows[0].obj_id.objid && 
            me->tblRows[i].rowId.osnum == me->VDlocRows[0].obj_id.osnum ) {
         	me->selRowInd = i;
         	break;
       }
    }

    /* initialize the row entries */
    /*
     *  must get me->tblRows[i].qty: sofar I hardcode  me->tblRows[i].qty
     * and waiting for message for get me->tblRows[i].qty from row id
     */

     status =
     _VD_SEND_OBJ( me->tblRows[0].rowId, VDdrwTblRow.VDgetQtyExpr( sts,
                                              &qty ) );

     CheckRC( status, *sts );

     if( !(status & *sts & 1) ) {
                *sts = VD_ERROR;
                goto wrapup;
     }

    me->tblRows[0].startIndex = 0;
    me->tblRows[0].flag = VD_DRW_ROW_OLD;
    me->tblRows[0].qty = qty;

    for( i = 1 ; i < me->nbRows ; i++ )
    {
       status =
       _VD_SEND_OBJ( me->tblRows[i].rowId, VDdrwTblRow.VDgetQtyExpr( sts,
                                              &qty ) );
       CheckRC( status, *sts );

       if( !(status & *sts & 1) ) {
              *sts = VD_ERROR;
                goto wrapup;
        }

        me->tblRows[i].startIndex = me->tblRows[i-1].startIndex +
                                        me->tblRows[i-1].nbObjs;
        me->tblRows[i].flag = VD_DRW_ROW_OLD;
        me->tblRows[i].qty = qty;
    }

    /* 
     * get the table layout name 
     */

    status =
    _VD_SEND_OBJ( tblId, VDdrwTbl.VDgetTableLayoutName(
                                                sts,
                                                tblLayoutName ) );
    CheckRC( status, *sts );

    if( !(status & *sts & 1) ) {
                *sts = VD_ERROR;
                goto wrapup;
    }

    __DBGpr_str( "table layout name", tblLayoutName );


    /* get the table record */

    status = VD_drwlo_gtab( sts, tblLayoutName, &tblRec );
    CheckRC( status, *sts );

    if( !(status & *sts & 1) ) {
                *sts = VD_ERROR;
                goto wrapup;
    }

    /* 
     * get the list of fixed and repalceable components of table 
     * based on table layout name and stores the information in the 
     * instance data
     */   

           /* get the list of data(repalceable) components */
    status = VD_drwlo_gdata(    sts,
                                tblLayoutName,
                                VD_DRWLO_EN_DATA,
                                0, 0,
                                0, NULL,
                                &height,
                                &nbDatRecs,
                                NULL );
            CheckRC( status, *sts );

            if( !(status & *sts & 1) ) {
                *sts = VD_ERROR;
                goto wrapup;
            }

    __DBGpr_int( "Number of data records", nbDatRecs );


    status = om$vla_set_dimension(      varray  = me->datRecs,
                                        size    = (IGRint)nbDatRecs );

    CheckRC( status, 1 );

    if( !(status & 1) )
    {
        UI_status( "Error encountered : command terminated" );
        *sts = VD_ERROR;
        goto wrapup;
    }

    status = VD_drwlo_gdata(    sts,
                                tblLayoutName,
                                VD_DRWLO_EN_DATA,
                                0, 0,
                                0, NULL,
                                &height,
                                &nbDatRecs,
                                me->datRecs );
            CheckRC( status, *sts );

            if( !(status & *sts & 1) ) {
                *sts = VD_ERROR;
                goto wrapup;
            }

               /* get the list of fixed components on data row*/

    status = VD_drwlo_gfix(     sts,
                                tblLayoutName,
                                VD_DRWLO_EN_DATA,
                                0, 0,
                                0, NULL,
                                &height,
                                &nbFixRecs,
                                NULL );

            CheckRC( status, *sts );

            if( !(status & *sts & 1) ) {
                *sts = VD_ERROR;
                goto wrapup;
            }

    __DBGpr_int( "Number of fixed records", nbFixRecs );

    fixRecs = NULL; 
    fixRecs =  _MALLOC(nbFixRecs, struct VDdrwlo_apifix);

    CheckRC( status, 1);
    if( !(status & 1) )
    {
        UI_status( "Error encountered : command terminated" );
        *sts = VD_ERROR;
        goto wrapup;
    }

    status = VD_drwlo_gfix(     sts,
                                tblLayoutName,
                                VD_DRWLO_EN_DATA,
                                0, 0,
                                0, NULL,
                                &height,
                                &nbFixRecs,
                                fixRecs );
            CheckRC( status, *sts );

            if( !(status & *sts & 1) ) {
                *sts = VD_ERROR;
                goto wrapup;
            }

             /* retain only the fixed text components on data */


    status = om$vla_set_dimension(      varray  = me->fixDataTextRecs,
                                        size    = (IGRint)nbFixRecs );

    nbTxt = 0;
    for( i = 0 ; i < nbFixRecs ; i++ ) {
        if( fixRecs[i].rectyp == VD_DRWLO_EN_TEXT )
            me->fixDataTextRecs[nbTxt++] = fixRecs[i];
    }
    __DBGpr_int( "Number of fixed text components", nbTxt );

               /* resize the vla */

    status = om$vla_set_dimension(      varray  = me->fixDataTextRecs,
                                        size    = nbTxt );
 
    /*
     * get title column record
     * get me->nbTotalCol and me->maxLinesPerRow 
     */
    nbFixRecs = om$dimension_of( varray = me->fixDataTextRecs );
    nbDatRecs = om$dimension_of( varray = me->datRecs );

    status =
    VDdrw_getColumnList(        sts,
                                nbFixRecs, nbDatRecs,
                                me->fixDataTextRecs, me->datRecs,
                                &nbCols, &me->maxLinesPerRow,
                                &colRecs );
            CheckRC( status, *sts );

            if( !(status & *sts & 1) ) {
                *sts = VD_ERROR;
                goto wrapup;
            }


    /* get total column list */

    me->nbTotalCol = nbCols;

    /*
     * get column width array, when column width over
     * VD_ETR_colWidthMax char, cut it as VD_ETR_colWidthMax char, 
     * (maximum show 3 * columns(14 chars) which is calculated from form width)
     * this width is used for setting row width in the form.
     */


     status =
     om$vla_set_dimension(  varray =  me->colWidth,
                            size   =  me->nbTotalCol);

     status =
     om$vla_set_dimension(  varray =  me->oriColWidth,
                            size   =  me->nbTotalCol);

     for( i = 0 ; i < me->nbTotalCol; i++ ) {
        me->colWidth[i] = colRecs[i].nbChars;
        me->oriColWidth[i] = colRecs[i].nbChars;
        if ( me->colWidth[i] > VD_ETR_colWidthMax) 
                      me->colWidth[i] = VD_ETR_colWidthMax;
     }

wrapup :
    for( i = 0 ; i < nbCols ; i++ )
        _FREE( colRecs[i].colTitles );
    _FREE( colRecs );
    _FREE(locObjs);
    _FREE(hdrIds); 
    _FREE(hdrRow); 
    _FREE(fixRecs); 
    End
    goto quit;
} /* VDgetRowInfo */
/*+me
 ---------------------------------------------------------------------------

  Message VDinitFrm1

  Abstract
        This method is used to set from row 

  Arguments
        IGRlong         *sts            O       Return code

  Statuse
      status == OM_S_SUCCESS
  Return Code
      *sts =    VD_SUCCESS
                VD_ERROR(error)
 ---------------------------------------------------------------------------
-me*/
action VDinitFrm1
{
IGRint  direct, i, startIndex;
IGRlong  loc_msg;
enum    GRdpmode        dpmode;
struct  GRmd_env        ModEnvObj; 

    SetProc( VDinitFrm1); Begin
    *sts = VD_SUCCESS;

    dpmode = GRhd;
    FIfld_set_num_rows(VD_FP, VD_ETR_VIS_NEW_ROW, me->maxLinesPerRow);
    FIfld_set_max_num_rows( VD_FP, VD_ETR_VIS_NEW_ROW, me->maxLinesPerRow);
    __DBGpr_int( "me->maxLinesPerRow", me->maxLinesPerRow );

     /* set row data struct */
    status =
    om$send(msg = message VDCmdEdTbRw.VDsetRowDataStr(
                                 sts, me->selRowInd),
                  targetid = my_id );

    CheckRC( status, *sts );

    if( !(status & *sts & 1) ) {
                *sts = VD_ERROR;
                goto wrapup;
    }

    /* set visiable info */
    me->preStartColInd = 0;
    me->preVisColNum =0;
    me->newStartColInd = 0;
    me->newVisColNum = 0;
    me->nbShiftCol = 0;

    direct = 1;
    status = 
    om$send(msg = message VDCmdEdTbRw.VDgetVisColsInfo(
                              sts,
                              me->preStartColInd,
                              me->preVisColNum,
                              &me->newStartColInd,
                              &me->newVisColNum,
			      me->nbShiftCol,
                              direct),
                targetid = my_id );
    CheckRC( status, *sts );

    if( !(status & *sts & 1) ) {
                *sts = VD_ERROR;
                goto wrapup;
    }

    /* update columns in view area*/
    me->nbShiftCol = VD_ETR_defaultShiftCol;

    status =
    om$send(msg = message VDCmdEdTbRw.VDupdVisCols(
                              sts,
                              &me->preStartColInd,
                              &me->preVisColNum,
                              &me->newStartColInd,
                              &me->newVisColNum),
                targetid = my_id );
    CheckRC( status, *sts );

    if( !(status & *sts & 1) ) {
                *sts = VD_ERROR;
                goto wrapup;
    }
  
    /* display objects assoiated with the row */

    startIndex =  me->tblRows[me->selRowInd].startIndex;
    for ( i = 0; i < me->tblRows[me->selRowInd].nbObjs; i++ ) {


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
    goto quit;

} /*  VDinitFrm1 */
/*+me
 ---------------------------------------------------------------------------

  Message VDupdateRow

  Abstract
        This method is used to update row

  Arguments
        IGRlong         *sts            O       Return code

  Statuse
      status == OM_S_SUCCESS
  Return Code
      *sts =    VD_SUCCESS
                VD_ERROR(error)
 ---------------------------------------------------------------------------
-me*/
action VDupdateRow
{
IGRint                      j, i0, j0,
                            col, row, len,
                            nbFixRecs, nbDatRecs;
IGRchar                     buf[4049],
                            buf1[128],
                            *datValue = NULL,
                            fieldMsg[80],
                            attName[80];
struct GRid                 collId;
IGRint                      type, size;
IGRint                      itemFlag = FALSE;
    
    SetProc( VDupdateRow ); Begin
    *sts = VD_SUCCESS;

    /* number of fixed and variable records */
    nbFixRecs = om$dimension_of( varray = me->fixDataTextRecs );
    nbDatRecs = om$dimension_of( varray = me->datRecs );

    __DBGpr_int( "Number of fixed text records", nbFixRecs );
    __DBGpr_int( "Number of data records", nbDatRecs );

    /*
     * for selected row
     *     empty collector contents
     *     for each field in row  (fixed and variable texts)
     *          get the default value
     *          get the value from the form
     *          if different, store in the rg_collector
     */

     /* get the collector id */

     status =
     _VD_SEND_OBJ( me->tblRows[me->selRowInd].rowId, 
                                               VDdrwTblRow.ACfind_temp_obj(
                                                                (int *)sts,
                                                                "coll",
                                                                &collId ) );
     CheckRC( status, *sts );
     if( !(status & *sts & 1) ) {
                *sts = VD_ERROR;
                goto wrapup;
     }

     __DBGpr_obj( "Collector id", collId );

     /* empty collector
     status =
     _VD_SEND_OBJ( collId, ACrg_collect.ACset_list_attribute(sts,
                                                                0,
                                                                NULL ) );
     CheckRC( status, *sts );
     */

     size = om$dimension_of( varray =  me->newRowData) ;
     __DBGpr_int( " size of me->newRowData", size );


     /* loop through fixed texts */
     for( j = 0 ; j < nbFixRecs ; j++ ) {

       col = me->fixDataTextRecs[j].VD.tx.colno;
       row = me->fixDataTextRecs[j].VD.tx.lineno;

       __DBGpr_int( " fixDataTextRecs Col number ", col );
       __DBGpr_int( " fixDataTextRecs Line number ", row );

       for ( i0 = 0; i0< size; i0++ ) { /* loop through all me->newRowData */

         if( row == (me->newRowData[i0].lineNos ) && 
                col == me->newRowData[i0].colNos ) {

            /* get text from me->newRowData */
            buf[0] = '\0';
            strcpy(buf, me->newRowData[i0].values);

            /* if over length, skip it */
            len = strlen(buf);
            fieldMsg[0] = '\0';

            if( len > me->oriColWidth[col-1]) {

                buf[me->oriColWidth[col-1]] = '\0';
                me->newRowData[i0].values[0] = '\0';
                strcpy(me->newRowData[i0].values,buf);

                sprintf( fieldMsg,
                "Truncated Table Column %d: length can not over %d ", col,
                          me->oriColWidth[col-1]);

                FIfld_set_text( VD_FP, FI_MSG_FIELD, 0, 0, 
                 "Truncated Fixed Text Field", FALSE );
                UI_status( fieldMsg );

            }

            /* compare with default value */

            if( strcmp( buf, me->fixDataTextRecs[j].VD.tx.Text ) )
            {
                /* add to collector */

                sprintf( attName, "%d %d", col, 
                         me->fixDataTextRecs[j].VD.tx.lineno );
                __DBGpr_str( "Name of attribute", attName );
                __DBGpr_str( "Value of attribute", buf );

                status = VDputAttInColl( sts, collId, attName, buf );
                CheckRC( status, *sts );
            }
           break;
          } /* for if */
        } /* for i0 */
     } /* for j */

     /* loop through variable texts */
     for( j = 0 ; j < nbDatRecs ; j++ ) {

       /* skip OVERFLOW lines */

       if( me->datRecs[j].rectyp == VD_DRWLO_EN_OVERFLOW )
                continue;

       col = me->datRecs[j].colno;
       row = me->datRecs[j].lineno;

       __DBGpr_int( "through datRecs Col number ", col  );
       __DBGpr_int( "through datRecs Row number ", row  );
 
       for ( i0 = 0; i0< size; i0++ ) { /* loop through all me->newRowData */
  
         if( row == (me->newRowData[i0].lineNos ) && 
              	          col == me->newRowData[i0].colNos ) {

            /* get text from me->newRowData */
            buf[0] = '\0';
            strcpy(buf,  me->newRowData[i0].values);

            /* handle item number separately*/
            itemFlag = FALSE;
            if( me->datRecs[j].rectyp == VD_DRWLO_EN_ITEMNO )
            {
                __DBGpr_str( "Item number", buf );
                
                /* check item unique */ 

                for (j0 = 0; j0 < me->nbRows; j0++ ) {

                  __DBGpr_obj( "Row Id", me->tblRows[j0].rowId );

                  /* get item number */

                  buf1[0] = '\0';
                  len = 0;  

                  status =
                  _VD_SEND_OBJ( me->tblRows[j0].rowId, 
                                VDdrwTblRow.VDgetItemNumber( sts,
                                                             &len,
                                                             buf1) );
                  CheckRC( status, *sts );

                  if( !(status&*sts&1)) continue;

                  buf1[len] = '\0';
                  __DBGpr_str( "Item number value", buf1 );

/*  tr 179601694  if( !strcmp(buf,buf1) && ( j0 != me->selRowInd ) && !buf1 ) 
 */
                
                  __DBGpr_int( "strlen(buf) =", strlen(buf) );
                  if( !strcmp(buf,buf1) && ( j0 != me->selRowInd ) && 
                       strlen(buf) ) {

                      itemFlag = TRUE; /* = true, not update the item */

                      break;

                  } 
                }
 
                __DBGpr_int( "itemFlag", itemFlag );
                /* set the item number in the row object */

                if( !itemFlag ) { 
                
                  status =
                  _VD_SEND_OBJ( me->tblRows[me->selRowInd].rowId, 
                              VDdrwTblRow.VDputItemNumber( sts, buf ) );

                  CheckRC( status, *sts );

                }
                else {
                    /* can not modify item num due to duplification */
			UI_status(" Item Number is not unique !"); 
                        FIfld_set_text( VD_FP, FI_MSG_FIELD, 0, 0, 
                        "Item Number is not unique!", FALSE ); 
                }

                break;
        
            } /* for if */

            /* get default value */ 

            _FREE( datValue );
            datValue = NULL;
          
            status = VDdrw_getFldValue( sts,
                                        me->tblRows[me->selRowInd].nbObjs,
                            &me->locObjs[me->tblRows[me->selRowInd].startIndex],
                                        me->datRecs[j], 
                                        me->tblRows[me->selRowInd].qty,
					&me->tblRows[me->selRowInd].rowId,
                                        &datValue );
            CheckRC( status, *sts );

            __DBGpr_str( "Buffer value", buf );

            if( datValue )
                __DBGpr_str( "Default value", datValue );
    
            attName[0] = '\0';
            sprintf( attName, "%d %d", col, me->datRecs[j].lineno );

            /* compare the two */

            if( (!datValue && strlen(buf) ) ||
                        ( datValue && strcmp( buf, datValue ) ) )
            {
                /* add to collector */
                __DBGpr_com( "add to collector" );

                __DBGpr_str( "Name of attribute", attName );
                __DBGpr_str( "Value of attribute", buf );

                status = VDputAttInColl( sts, collId, attName, buf );
                CheckRC( status, *sts);

            }
	    else if( datValue && !strcmp( buf, datValue ) )
	    {	/* This block is added for CR5119 and TR5164 */
		IGRchar		subName[40];
		subName[0]	= '\0';

		status =
		_VD_SEND_OBJ (	collId,
				ACrg_collect.ACrem_attribute( sts, attName ));
		CheckRC( status, *sts );
		if( (status&*sts&1) ) {
		   for( j0 = 0; j0 < 100; j0++ )
		   {
		      sprintf(subName, "%s(%d)", attName, j0);
		      status =
		      _VD_SEND_OBJ (  collId,
                                ACrg_collect.ACrem_attribute( sts, subName ));
		      if( !(status&*sts&1) ) break;
		   }
		}
		*sts = MSSUCC;
		status = OM_S_SUCCESS;
	    }

            break;
          } /* for if */
        } /* for I0*/
     } /* for j */

     /* recomputer the row  */    

     type = ND_COMP;

     status =
     _VD_SEND_OBJ( me->tblRows[me->selRowInd].rowId, 
                      VDSroot.VDcompute( sts,&type));   
     CheckRC( status, *sts );

     
     /* update columns in view area*/
     status =
     om$send( msg = message VDCmdEdTbRw.VDupdVisCols(
                              sts,
                              &me->preStartColInd,
                              &me->preVisColNum,
                              &me->newStartColInd,
                              &me->newVisColNum),
                     mode     = OM_e_wrt_message,
                     targetid = my_id );
     CheckRC( status, *sts );


     /* do recompute right now */

     nd$exec_batch();

     /* highlight the selected row again */

     status =
     om$send( msg = message VDCmdEdTbRw.VDupdatHighlight(
                                                              sts,
                                                              me->selRowInd),
                          mode     = OM_e_wrt_message,
                          targetid = my_id );

     CheckRC( status, *sts );

     
wrapup:
     _FREE( datValue );
     End
     goto quit;

} /* VDupdateRow */
/*+me
 ---------------------------------------------------------------------------

  Message VDbackToInitFrm

  Abstract
        This method sets back the form to initial states: just keep row
        number column.

  Arguments
        IGRlong         *sts            O       Return code

  Status/Return Code
      status == OM_S_SUCCESS     

 ---------------------------------------------------------------------------
-me*/

action VDbackToInitFrm
{
    IGRint              i, nbVisCols;
    IGRint              xlo, ylo, xhi, yhi;


    SetProc( VDCmdEdTbRw.VDbackToInitFrm); Begin
    *sts = MSSUCC;
    status = OM_S_SUCCESS;

   /* delete previous columns */
    for(i = 0; i < (me->preVisColNum); i++) {
      FImcf_get_num_vis_cols( VD_FP, VD_ETR_VIS_TIT_ROW, &nbVisCols);
      nbVisCols --;
      FImcf_delete_col( VD_FP, VD_ETR_VIS_TIT_ROW, (me->preVisColNum) - i );
      FImcf_delete_col( VD_FP, VD_ETR_VIS_ORI_ROW, (me->preVisColNum) - i );
      FImcf_delete_col( VD_FP, VD_ETR_VIS_NEW_ROW, (me->preVisColNum) - i );
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

      /* refresh the form */

      FIf_get_size( VD_FP, &xhi, &yhi );
      FIg_get_location( VD_FP, VD_ETR_VIS_ORI_ROW, &xlo, &ylo );
      FIf_paint_area( VD_FP, xlo, ylo, xhi, yhi );
      FIg_get_location( VD_FP, VD_ETR_VIS_NEW_ROW, &xlo, &ylo );
      FIf_paint_area( VD_FP, xlo, ylo, xhi, yhi );

      /* set field row num */
      FIfld_set_max_num_rows( VD_FP, VD_ETR_VIS_TIT_ROW, 0);
      FIfld_set_max_num_rows( VD_FP, VD_ETR_VIS_ORI_ROW, 0);
      FIfld_set_max_num_rows( VD_FP, VD_ETR_VIS_NEW_ROW, 0);


      /* fill in row num field as empty */
      FIfld_set_text( VD_FP, VD_ETR_VIS_ORI_ROW, 0, 0, "", FALSE );
      FIfld_set_text( VD_FP, VD_ETR_VIS_NEW_ROW, 0, 0, "", FALSE );

      /* set row info as init state values */ 
      me->preStartColInd = 0;
      me->preVisColNum =0;
      me->newStartColInd = 0;
      me->newVisColNum = 0;
      me->nbShiftCol = 0;

    End
    goto quit;

} /* VDbackToInitFrm */

/*----------------------------------------------------------------------------*
 * action return_form: 
 * status field in CEO_LOCATE is to get return value of the
 * routine form_notification; sts is used in state table
 *----------------------------------------------------------------------------*/
action VDreturnForm
{
#ifdef DEBUG
        printf("return_form\n");
#endif
        *sts = me->rep_label;
        status = OM_S_SUCCESS;
        goto quit;
} /* VDreturnForm */
/*-----------------------------------------------------------------
 methed  for free instance
------------------------------------------------------------------*/
action free_instance
{
IGRint num0,i;

    *sts = MSSUCC;
    dp$erase_hilite (msg = sts); 
    num0 = om$dimension_of( varray = me->newRowData );

    for(i = 0; i < num0; i++) {
       _FREE(me->newRowData[i].values);
    }

    status = OM_S_SUCCESS;
    goto quit;
}

/*-----------------------------------------------------------------
 methed  for save form location
------------------------------------------------------------------*/
action  VDsave_form_pos
{
        FIf_get_location(me->forms[0].form_ptr,&x_pos,&y_pos);

        status = OM_S_SUCCESS ;
        *sts = MSSUCC;
        goto quit ;
}
/*-----------------------------------------------------------------
 methed  for get form location
------------------------------------------------------------------*/
action  VDset_form_pos
{
        if(x_pos != -1 && y_pos != -1)
                FIf_set_location ( me->forms[0].form_ptr, x_pos, y_pos );

        status = OM_S_SUCCESS ;
        *sts = MSSUCC;
        goto quit ;
}
/*+me
 ---------------------------------------------------------------------------
  Message VDis_table_uptodate

  Abstract
        This method checks if the table rows are up-to-date w.r.t the
        model objects.

  Arguments
        IGRlong         *sts            O       Return code

  Notes/Remarks

  Status/Return Code
      *sts =    VD_SUCCESS if up-to-date
                VD_ERROR if tbl rows need recomputing
 ---------------------------------------------------------------------------
-me*/

action  VDis_table_uptodate 
{
    IGRint              upToDate;
    IGRlong             msg;

    SetProc( VDCmdEdTbRw.VDis_table_uptodate ); Begin

    *sts = VD_SUCCESS;

    /* check  dependencies */

    status = VDdrw_checkDependency( &msg, &upToDate );

    __DBGpr_int( "FIle uptodate", upToDate );

    if( !upToDate )
    {
            UI_status( "Need to update dependencies using Update Drawing");
            *sts = VD_ERROR;
            goto wrapup;
    }

wrapup :
    End
    goto quit;
}

