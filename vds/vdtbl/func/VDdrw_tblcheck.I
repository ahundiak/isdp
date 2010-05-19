/* $Id: VDdrw_tblcheck.I,v 1.1 2001/02/19 20:23:48 ylong Exp $  */

/* I/VDS
 * -------------------------------------------------------------------------
 *
 * File:        vdmisc//VDdrw_tblcheck.I
 *
 * Description:
 *         API routines for table.
 *		VDdrw_CheckTblValid
 *
 * Dependencies:
 *
 * History:
 *      10/18/00        Ming            Created
 *
 * -------------------------------------------------------------------------
 */

class implementation Root;

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>

#include "igrtypedef.h"
#include "OMerrordef.h"
#include "OMtypes.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMmacros.h"

#include "EMSmsgdef.h"
#include "EMSutlmacros.h"
#include "exmacros.h"
#include "macro.h"
#include "ndmacros.h"
#include "nddef.h"
#include "batch.h"
#include "grdpbmacros.h"
#include "grdpbdef.h"
#include "asmacros.h"
#include "asbox.h"
#include "FI.h"
#include "dpmacros.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"
#include "v_slc.h"

#include "VDdrwlo.h"
#include "VDdrwlo_pr.h"
#include "VDtblCmdDef.h"

#include "ACattrib.h"
#include "ACrg_collect.h"

#include "vddrwattr.h"
#include "vdparmacros.h"
#include "VDcompmacros.h"
#include "VDCmdDef.h"
#include "VDattrexp.h"
#include "VDdrwtbl.h"
#include "VDsa.h"
#include "v_drwprocess.h"

from VDdrwTbl		import VDgetTableParts,
			       VDgetTotalNbOfRows;
from VDdrwTblHdr	import VDgetRowInfo,
			       VDrowNoToGRid;
from GRgraphics		import GRdisplay,
			       GRgetname,
			       GRdelete;

extern GRclassid 	OPP_GRowner_class_id;
extern GRclassid 	OPP_GR3dlineseg_class_id;
extern GRclassid 	OPP_GR3dtext_class_id;
extern GRclassid 	OPP_GRclhdr_class_id;


/*+fe
 -------------------------------------------------------------------------
  Function VDdrw_CheckTblValid

  Abstract
        Function retrieves all objects from the existing table

  Arguments

        IGRlong          *msg           O       return code
	struct GRobj_env *tblId		I	table ID
        IGRint		 *is_good       O	flag which shows the table 
						is good or not.

  Returns
        OM_S_SUCCESS    = if success
        OM_E_ABORT      = if error
 ------------------------------------------------------------------------- -fe*/
IGRlong VDdrw_CheckTblValid( IGRlong	      *msg,
			     struct GRobj_env *tblId,
			     IGRint	      *is_good ) 
{
    IGRint		 i, j;
    IGRlong		 status;
    IGRint		 ind = 0,
			 nbRows = 0,
			 cnt,
			 nbHdrRows,
			 nbHdrs,
			 startRowNo;
    struct GRid		 *hdrId;
    struct VDdrw_rowInfo *rowIds;
    OM_S_CHANSELECT      compChan;
    OM_S_OBJECT_LINKAGE  *compObj = NULL;
    struct GRid		 ownerID, componentID;


    SetProc( VDdrw_CheckTblValid ); Begin

    *msg      = MSSUCC;
    status    = 0;
    hdrId     = NULL;
    rowIds    = NULL;
    *is_good  = 1;

    if( tblId == NULL ) goto wrapup;

    status =
    ems$make_chanselect(        chan_label      = GRcmpowner_to_components,
                                chan_selector   = &compChan );
    __CheckRC( status, 1, "make_chanselect", wrapup );

    /*
    ** get number of table parts(headers)
    */
    nbHdrs = 0;
    status =
    om$send( msg      = message VDdrwTbl.VDgetTableParts(msg,
                                                         &nbHdrs,
                                                         NULL),
	     senderid = NULL_OBJID,
             targetid = tblId->obj_id.objid,
             targetos = tblId->obj_id.osnum );

    if( !(status&*msg&1) || (nbHdrs <= 0) ) goto wrapup;

    hdrId = _MALLOC( nbHdrs, struct GRid );
    if( hdrId == NULL ) goto wrapup;

    status =
    om$send( msg      = message VDdrwTbl.VDgetTableParts(msg,
                                                         &nbHdrs,
                                                         hdrId),
             senderid = NULL_OBJID,
    	     targetid = tblId->obj_id.objid,        
             targetos = tblId->obj_id.osnum );

    if( !(status&*msg&1) ) goto wrapup;

    /*
    ** Retrive total No. of rows in the table
    */
    status =
    om$send( msg      = message VDdrwTbl.VDgetTotalNbOfRows(msg,&nbRows),
             senderid = NULL_OBJID,
             targetid = tblId->obj_id.objid,
             targetos = tblId->obj_id.osnum );
    if( !(status&*msg&1) ) goto wrapup;

    if( nbRows > 0 )
    {
      /*
      ** allocate memory for rows
      */
      rowIds = _MALLOC( nbRows, struct VDdrw_rowInfo );
      if( !rowIds ) goto wrapup;
    }
    else
    {
      status = OM_S_SUCCESS;
      goto wrapup;
    }

    /* 
    ** Retrieve all table rows.
    */
    ind = 0;
    for( i = 0 ; i < nbHdrs ; i++ )
    {
      status =
      om$send( msg      = message VDdrwTblHdr.VDgetRowInfo(msg,
                                                           &nbHdrRows,
                                                           &startRowNo),
	       senderid = NULL_OBJID,
               targetid = hdrId[i].objid,
               targetos = hdrId[i].osnum );
      if( !(status&*msg&1) ) goto wrapup;

      for( j = startRowNo ; j < startRowNo+nbHdrRows ; j++ )
      {
        status =
        om$send( msg      = message VDdrwTblHdr.VDrowNoToGRid(
							msg,
                                                        j,
                                                        &rowIds[ind].rowId),
                 senderid = NULL_OBJID,
                 targetid = hdrId[i].objid,
                 targetos = hdrId[i].osnum );
        if( !(status&*msg&1) ) goto wrapup;

        ind++;
      }
    }

    nbRows = ind;

    for( i = 0 ; i < nbRows ; i++ )
    {
      status =
      om$get_channel_count( osnum           = rowIds[i].rowId.osnum,
                            objid           = rowIds[i].rowId.objid,
                            p_chanselect    = &compChan,
                            count           = (OMuint *)&cnt );
      __CheckRC( status, 1, "get_channel_objects", wrapup );

      if( cnt > 0 )
      {
        compObj = _MALLOC( cnt, OM_S_OBJECT_LINKAGE );
        if( !compObj ) goto wrapup;
      }

      status =
      om$get_channel_objects( osnum           = rowIds[i].rowId.osnum,
                              objid           = rowIds[i].rowId.objid,
                              p_chanselect    = &compChan,
                              size            = 1,
                              list            = compObj,
                              count           = (OMuint *)&cnt );
      __CheckRC( status, 1, "get_channel_objects", wrapup );

      ownerID.objid = compObj[0].S_objid;
      ownerID.osnum = compObj[0].osnum;

      if( !(vd_$is_ancestry_valid(object  = &ownerID,
                                  classid = OPP_GRowner_class_id)) )
      {
        *is_good = 0;
        goto wrapup;
      }

      _FREE( compObj );
      compObj = NULL;
      cnt = 0;

      status =
      om$get_channel_count( osnum           = ownerID.osnum,
                            objid           = ownerID.objid,
                            p_chanselect    = &compChan,
                            count           = (OMuint *)&cnt );
      __CheckRC( status, 1, "get_channel_objects", wrapup );

      if( cnt > 0 )
      {
        compObj = _MALLOC( cnt, OM_S_OBJECT_LINKAGE );
        if( !compObj ) goto wrapup;
      }

      status =
      om$get_channel_objects( osnum           = ownerID.osnum,
                              objid           = ownerID.objid,
                              p_chanselect    = &compChan,
                              size            = cnt,
                              list            = compObj,
                              count           = (OMuint *)&cnt );
      __CheckRC( status, 1, "get_channel_objects", wrapup );
 
      for( j = 0 ; j < cnt ; j++ )
      {
        componentID.objid = compObj[j].S_objid;
        componentID.osnum = compObj[j].osnum;
        if( !(vd_$is_ancestry_valid(object  = &componentID,
                                    classid = OPP_GR3dlineseg_class_id)) &&
            !(vd_$is_ancestry_valid(object  = &componentID,
                                    classid = OPP_GR3dtext_class_id)) && 
	    !(vd_$is_ancestry_valid(object  = &componentID,
                                    classid = OPP_GRclhdr_class_id)) )
        {
          *is_good = 0;
          goto wrapup;
        }
      }

      _FREE( compObj );
      compObj = NULL;
      cnt = 0;
    }

    status = OM_S_SUCCESS;
    *msg   = OM_S_SUCCESS;


wrapup:
    _FREE( hdrId );
    _FREE( rowIds );
    _FREE( compObj );

    End
    return status;
} /* VDdrw_CheckTblValid */

/*+fe
 -------------------------------------------------------------------------
  Function VDdrw_displayForm

  Abstract
        Function displays good and bad tables

  Arguments

        IGRlong          *msg           O       return code
   	Form		 form           I       form pointer.
        IGRint		 goodCnt	I       count of good tables
	struct GRobj_env *goodTbl	I	good table list.
        IGRint		 badCnt		I       count of corrupted tables
	struct GRobj_env *badTbl	I	bad table list.

  Returns
        OM_S_SUCCESS    = if success
        OM_E_ABORT      = if error
 ------------------------------------------------------------------------- -fe*/
IGRlong VDdrw_displayForm( IGRlong	    *msg,
			   Form		    form,
			   IGRint	    goodCnt,
			   struct GRobj_env *goodTbl,
			   IGRint	    badCnt,
			   struct GRobj_env *badTbl )
{
    IGRint		 i;
    IGRlong		 status;
    IGRchar              pathname[DI_PATH_MAX];
    IGRint		 nbRow, Selflag, tmp;


    SetProc( VDdrw_displayForm ); Begin

    *msg      = MSSUCC;
    status    = 0;
    nbRow     = 0;
    Selflag   = FALSE;

    if( !form ) goto wrapup;

    FIf_display( form );

    if( goodTbl != NULL & goodCnt > 0 )
    {
      for( i = 0 ; i < goodCnt ; i++ )
      {
	pathname[0] = '\0';
        status =
 	om$send( msg      = message GRgraphics.GRgetname(msg,
							 pathname),
		 senderid = NULL_OBJID,
                 targetid = goodTbl[i].obj_id.objid,
                 targetos = goodTbl[i].obj_id.osnum );

 	FIfld_set_text( form,
			VD_DRW_CHECK_TABLE,
			nbRow,
			1,
			pathname,
			Selflag );

        FIfld_set_value( form,
                         VD_DRW_CHECK_TABLE,
                         nbRow,
                         2,
                         (double)goodTbl[i].obj_id.objid,
                         Selflag );

	nbRow++;
      }
    }

    if( badTbl != NULL & badCnt > 0 )
    {
      for( i = 0 ; i < badCnt ; i++ )
      {
        pathname[0] = '\0';
        status =
        om$send( msg      = message GRgraphics.GRgetname(msg,
                                                         pathname),
                 senderid = NULL_OBJID,
                 targetid = badTbl[i].obj_id.objid,
                 targetos = badTbl[i].obj_id.osnum );

        FIfld_set_text( form,
                        VD_DRW_CHECK_TABLE,
                        nbRow,
                        0,
                        "*",
                        Selflag );

        FIfld_set_text( form,
                        VD_DRW_CHECK_TABLE,
                        nbRow,
                        1,
                        pathname,
                        Selflag );

        FIfld_set_value( form,
                         VD_DRW_CHECK_TABLE,
                         nbRow,
                         2,
                         (double)badTbl[i].obj_id.objid,
                         Selflag );

        nbRow++;
      }
    }



wrapup:

    End
    return status;
} /* VDdrw_displayForm */

/*+fe
 -------------------------------------------------------------------------
  Function VDdrw_removeBadTbl

  Abstract
        Function removes all bad tables

  Arguments

        IGRlong          *msg           O       return code
 	IGRint		 badCnt		I       No. of bad tables.
	struct GRobj_env *badTbl	I	list of bad tables

  Returns
        OM_S_SUCCESS    = if success
        OM_E_ABORT      = if error
 ------------------------------------------------------------------------- -fe*/
IGRlong VDdrw_removeBadTbl( IGRlong	      *msg,
			     IGRint	      badCnt,
			     struct GRobj_env *badTbl ) 
{
    IGRint		 i;
    IGRlong		 status;
    struct GRmd_env      loc_env;
    enum GRdpmode        dpmode;


    SetProc( VDdrw_CheckTblValid ); Begin

    *msg      = MSSUCC;
    status    = 0;

    if( badTbl == NULL || badCnt <= 0 ) goto wrapup;

    loc_env = badTbl[0].mod_env;

    /*
    ** Remove all the bad tables 
    */
    for( i = 0 ; i < badCnt ; i++ )
    {
      dpmode = GRbe;
      status =
      om$send( msg      = message GRgraphics.GRdisplay(
						msg,
                                                &loc_env.md_env.matrix_type,
						loc_env.md_env.matrix,
						&dpmode,
						&loc_env.md_id),
	       senderid = NULL_OBJID,
               targetid = badTbl[i].obj_id.objid,
               targetos = badTbl[i].obj_id.osnum );
      if( !(status&*msg&1) ) goto wrapup;

      status =
      om$send( msg      = message GRgraphics.GRdelete(msg,
                                                      &loc_env),
	       senderid = NULL_OBJID,
               targetid = badTbl[i].obj_id.objid,
               targetos = badTbl[i].obj_id.osnum );
      if( !(status&*msg&1) ) goto wrapup;
    }

    status = OM_S_SUCCESS;
    *msg   = OM_S_SUCCESS;


wrapup:

    End
    return status;
} /* VDdrw_removeBadTbl */

/*+fe
 -------------------------------------------------------------------------
  Function VDdrw_hiliteTable

  Abstract
        Function highlight the selected table

  Arguments

        IGRlong          *msg           O       return code
        Form		 form		I       form pointer

  Returns
        OM_S_SUCCESS    = if success
        OM_E_ABORT      = if error
 ------------------------------------------------------------------------- -fe*/
IGRlong VDdrw_hiliteTable( IGRlong	*msg,
			   Form	      	form ) 
{
    IGRlong		 status;
    struct GRmd_env      loc_env;
    enum GRdpmode        dpmode;
    IGRint 		 row, sel, position;
    IGRdouble		 value;
    struct GRobj_env     object;
    IGRint		 size = sizeof( struct GRmd_env );


    SetProc( VDdrw_hiliteTable ); Begin

    *msg      = MSSUCC;
    status    = 0;
    row = position = -1;

    if( form == NULL ) goto wrapup;

    dp$erase_hilite( msg = msg );

    FIfld_get_active_row( form, VD_DRW_CHECK_TABLE, &row, &position );

    /*
    ** get current module environment
    */
    status = gr$get_module_env( msg     = msg,
                                sizbuf  = &size,
                                buffer  = &loc_env );

    if( row >= 0 )
    {
      FIfld_get_value( form,
		       VD_DRW_CHECK_TABLE,
		       row,
		       2,
		       &value,
		       &sel,
		       &position );

      object.obj_id.objid = (int)value;
      object.obj_id.osnum = loc_env.md_id.osnum;
      object.mod_env      = loc_env;
    }

    vd_$bulk_display( dpmode = GRhdo, objenvs = &object );

    status = OM_S_SUCCESS;
    *msg   = OM_S_SUCCESS;


wrapup:

    End
    return status;
} /* VDdrw_hiliteTable */

end implementation Root;
