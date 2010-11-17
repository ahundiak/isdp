/* $Id: VDtblLoc.I,v 1.4.2.1 2002/08/05 16:17:07 ylong Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd / VDtblLoc.I
 *
 * Description:
 *      Implementation of the following methods for VDCmdCrTbl :
 *              store_cs
 *              store_and_process_table
 *              process_locate
 *              process_rowno
 *
 * Dependencies:
 *
 * History:
 *
 *      04/14/95        R. Manem        Creation
 *      07/14/95        R. Manem        Process located components
 *      07/21/95        R. Manem        Filter dangles from located objects
 *      08/15/95        R. Manem        Avoid validation of category for
 *					located objects
 * 	12/15/97	vini		CR-179526497
 *	07/30/99	Ming		tr179900784
 *	06/05/02	ylong		CR6391
 *	08/05/02	ylong		TR6614, delete GRgrset/GRsvset
 * -------------------------------------------------------------------*/


class implementation VDCmdCrTbl;
/*
#define vdsDEBUG
#define vdserrDEBUG

*/

#include <stdio.h>
#include <lcmacros.h>
#include <math.h>
#include "string.h"

#include "OMmacros.h"
#include "OMprimitives.h"
#include "exproto.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "go.h"
#include "macro.h"
#include "nddef.h"

#include "VDdrwlo.h"
#include "VDdrwlo_pr.h"
#include "VDdrwtbl.h"
#include "VDtblCmdDef.h"
#include "vdsetmacros.h"		/* for vd$filter_objects */

#include "VDCmdDef.h"
#include "FI.h"
#include "FEI.h"

#include "coparamac.h"

#include "igetypedef.h"
#include "igrtypedef.h"
#include "grdpbdef.h"

#include "igrdef.h"
#include "igrmacros.h"

#include "dpmacros.h"
#include "grdpbmacros.h"

#include "grmacros.h"

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



#include "VDtblCmdDef.h"

//extern GRclassid  OPP_VDdrwTblRow_class_id;

from VDdrwTbl		import	VDgetTableParts, 
				VDgetTotalNbOfRows,
				VDgetAdsTblName,
				VDgetTableLayoutName;

from VDdrwTblHdr	import	VDgetRowInfo,
				VDrowNoToGRid;
from VDdrwTblRow	import	VDgetRowNumber,
				VDisRowLinedOut;
from GRgraphics		import	GRgetname;
from GRgrset		import	GSdissolve;

/*+me
 ---------------------------------------------------------------------------
  Public Message store_cs

  Abstract
        This method stores the located coordinate system.

  Arguments
        IGRlong         *sts            O       Return code

  Notes/Remarks

  Status Code
      status == OM_S_SUCCESS

  Return Code
      *sts =    VD_SUCCESS
                VD_ERROR ( no memory )
 ---------------------------------------------------------------------------
-me*/

method  store_cs ( long * sts )
{

    IGRint              traceFlag;

    SetProc( VDCmdCrTbl.store_cs ); Begin

    *sts = VD_SUCCESS;
    traceFlag = 0;   
    if(traceFlag) printf(">>> vds/vdtbl/cmd/VDtblLoc.I: method store_cs\n");

    if( me->nbCs >= om$dimension_of( varray = me->cs ) )
    {
	__DBGpr_com( "Invalid number of cs and vla size" );
	UI_status( "Error encountered : command terminated" );
	goto wrapup;
    }

    me->cs[me->nbCs].obj_id = me->event1.located_object[0].located_obj ;
    me->cs[me->nbCs].mod_env = me->event1.located_object[0].module_info ;

    __DBGpr_obj( "Located Cs Id ",  me->cs[me->nbCs].obj_id );

    me->nbCs++;

wrapup :
    if(traceFlag) printf("<<< vds/vdtbl/cmd/VDtblLoc.I: method store_cs[%d]\n",
                         OM_S_SUCCESS);
    End
    return OM_S_SUCCESS;
}

/*+me
 ---------------------------------------------------------------------------
  Public Message store_and_process_table

  Abstract
        This method stores the located table.
        It also gets the list of table headers and stores them
	in the instance data.  Copies of the headers are made.  

  Arguments
        IGRlong         *sts            O       Return code

  Notes/Remarks

  Status Code
      status == OM_S_SUCCESS

  Return Code
      *sts =    VD_SUCCESS
                VD_ERROR (no memory )
 ---------------------------------------------------------------------------
-me*/

method store_and_process_table( long * sts )
{
    IGRint		i, 
			nbRows = 0,
			nbParts;
    IGRlong		msg,
			status = OM_S_SUCCESS;
    struct VDdrwlo_tab	tblRec;
    IGRint              traceFlag;

    SetProc( VDCmdCrTbl.store_and_process_table ); Begin

    *sts = VD_SUCCESS;
    traceFlag = 0;   
    if(traceFlag) printf(">>> vds/vdtbl/cmd/VDtblLoc.I: method store_and_process_table\n");

//    me->tblObj.obj_id = me->event1.located_object[0].located_obj ;
    me->tblObj.mod_env = me->event1.located_object[0].module_info ;

    __DBGpr_obj( "table object", me->tblObj.obj_id );

    /* validate table for  "Create Table" */

    if( me->mytype == CREATE_TABLE )
    {
    	status =
    	_VD_SEND_OBJ( me->tblObj.obj_id, VDdrwTbl.VDgetTotalNbOfRows( &msg, 
								  &nbRows ) );
    	CheckRC( status, msg );

    	if( nbRows )
	{
	    *sts = VD_RESTART_CMD;
	    UI_status( "Invalid table selected" );
	    goto wrapup;
	}
    }

    /* CR6391, let lined out rows editable */

    if( me->mytype == MODIFY_TABLE )
    {
	VDtblSetAttrForLnOutRows( &me->tblObj.obj_id );
    }

    /* get the table layout name */

    status =
    _VD_SEND_OBJ( me->tblObj.obj_id, VDdrwTbl.VDgetTableLayoutName(	
						&msg,
						me->tblLayoutName ) );
    __CheckRC( status, msg, "VDdrwTbl.VDgetTableLayoutName", wrapup );

    __DBGpr_str( "table layout name", me->tblLayoutName );

    /* get the att driven symbol table name */

    status =
    _VD_SEND_OBJ( me->tblObj.obj_id, VDdrwTbl.VDgetAdsTblName(	
						&msg,
						me->adsTblName ) );
    __CheckRC( status, msg, "VDdrwTbl.VDgetTableLayoutName", wrapup );

    __DBGpr_str( "Attribute driven symbol table name", me->adsTblName );

    /* get the table record */

    status = VD_drwlo_gtab( &msg, me->tblLayoutName, &tblRec );
    __CheckRC( status, msg, "VD_drwlo_gtab", wrapup );

    /* store the type of the table */

    strcpy( me->tblTypeName, tblRec.Tabtyp );
    __DBGpr_str( "table type name", me->tblTypeName );

    /* Modified by Ming for tr179900784 */
    if( !strcmp( me->tblTypeName, VD_DRW_BOM_TYPE_NAME ) ||
	strstr( me->tblTypeName, VD_DRW_BOMX_TYPE_NAME ) )
        me->tblType = VD_DRW_TBLTYPE_BOM;
    else
        me->tblType = VD_DRW_TBLTYPE_GEN;

    /* 
     * retrieve the list of headers 
     */

    /* get number of table parts(headers) */

    status =
    _VD_SEND_OBJ( me->tblObj.obj_id, VDdrwTbl.VDgetTableParts( 	&msg,
								&nbParts,
								NULL ) );
    __CheckRC( status, msg, "VDdrwTbl.VDgetTableParts", wrapup );

    __DBGpr_int( "Number of table parts", nbParts );

    /* allocate memory for the headers */

    status = om$vla_set_dimension(	varray	= me->hdrIds,
					size	= nbParts );
    CheckRC( status, 1 );

    if( !(status & 1) )
    {
	*sts = VD_ERROR;
	UI_status( "Error encountered : command terminated" );
	goto wrapup;
    }

    /* get the list of table headers */

    status =
    _VD_SEND_OBJ( me->tblObj.obj_id, VDdrwTbl.VDgetTableParts( 	&msg,
								&nbParts,
								me->hdrIds ) );
    __CheckRC( status, msg, "VDdrwTbl.VDgetTableParts", wrapup );

    __DBGpr_objlist( "List of header ids", nbParts, me->hdrIds );

    /* allocate memory for the copy of the headers */

    status = om$vla_set_dimension(	varray	= me->cpyHdrs,
					size	= nbParts );
    CheckRC( status, 1 );

    if( !(status & 1) )
    {
	*sts = VD_ERROR;
	UI_status( "Error encountered : command terminated" );
	goto wrapup;
    }

    /* make a copy */

    for( i = 0 ; i < nbParts ; i++ )
    {
	/* 
         * osnum is the current os : table, header and rows all must be
         * in the active design file 
         * locate filter to handle it : must be able to modify the object 
         * located.
         */

        me->cpyHdrs[i].osnum = me->hdrIds[i].osnum;

        status =
        om$construct_and_copy(	objid	= me->hdrIds[i].objid,
				obj_osnum= me->hdrIds[i].osnum,
				osnum	= me->hdrIds[i].osnum,
				p_objid	= &me->cpyHdrs[i].objid );
        CheckRC( status, 1 );
    }

    __DBGpr_objlist( "List of header copies ", nbParts, me->cpyHdrs );

wrapup :

    if( !(status & msg & 1) )
    {
	*sts = VD_ERROR;
	UI_status( "Error encountered : command terminated" );
    }
    if(traceFlag) printf("<<< vds/vdtbl/cmd/VDtblLoc.I: method store_and_process_table[%d]\n",
                         OM_S_SUCCESS);
    End
    return OM_S_SUCCESS;
}



method VDgettherow ( long * sts )
{
  int             status = OM_S_SUCCESS;
  

struct GRobj_env        *rowObjs = NULL;
IGRint                  NbRowObjs;
IGRint                  vincount;
IGRshort                isLinedOut;

GRclassid               classid;
struct GRevent          obj_event;

    OMuint              count;
    IGRchar             pathname[DI_PATH_MAX];
    GRname              tblName;
    struct GRid         tblId;
    OM_S_CHANSELECT     hdrChan, ownerChan;
    OM_S_OBJECT_LINKAGE hdrObj;
    IGRint              nbRows;
    IGRint              nbParts;
    IGRint              nbHdrRows;
    IGRint              startRowNo;
    IGRint              i, ind,j;
    struct GRid         *hdrIds = NULL;
    struct VDhdrRowinfo *hdrRow = NULL;
    IGRint              traceFlag;

     SetProc(  VDCmdCrTbl.VDgettherow ); Begin

     *sts = VD_SUCCESS ;
     traceFlag = 0;  
     if(traceFlag) printf(">>> vds/vdtbl/cmd/VDtblLoc.I: method VDgettherow\n");

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

	obj_event = me->event1;

    status = om$get_classid(
        osnum     = obj_event.located_object[0].located_obj.osnum,
        objid     = obj_event.located_object[0].located_obj.objid,
        p_classid = &classid );

      if (om$is_ancestry_valid (
               subclassid   = classid,
               superclassid = OPP_VDdrwTblRow_class_id)
                                 != OM_S_SUCCESS)
        {
	me->tblObj.obj_id = me->event1.located_object[0].located_obj ;
	*sts = VD_ERROR; 
	goto wrapup;
	}
	else  *sts = OM_S_SUCCESS;

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
     vincount = 0;

     if ( NbRowObjs ) {
        /* increase the list of me->VDlocRows */
        for( i=0 ; i<NbRowObjs ; i++ ){
          /* add in list.  */
          if( rowObjs[i].obj_id.objid != NULL_OBJID ){
             /* increment of list. */
             status =
             om$vla_set_dimension(  varray =  me->VDlocRows,
                                    size   =  vincount +1 );
             me->VDlocRows[vincount]  = rowObjs[i];
             vincount ++;
          }
        }
     } /* if ( NbRowObjs ) */

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

	me->tblObj.obj_id = tblId;

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
                           size    = nbRows);

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

                    ind++;
      }
    } /* for i */

wrapup:
    if(traceFlag) printf("<<< vds/vdtbl/cmd/VDtblLoc.I: method VDgettherow[%d]\n",
                         OM_S_SUCCESS);
   End
  return OM_S_SUCCESS;
}


/*+me
 ---------------------------------------------------------------------------
  Public Message process_locate

  Abstract
        This method processes the located set of objects for BOM.

  Arguments
        IGRlong         *sts            O       Return code

  Notes/Remarks

  Status Code
      status == OM_S_SUCCESS

  Return Code
      *sts =    VD_SUCCESS
                VD_ERROR (no memory)
		VD_RESTART_CMD (no objects located)
 ---------------------------------------------------------------------------
-me*/

method  process_locate ( long * sts )
{
    IGRint		i,
			event_size,
			nbOldObjs = 0,
			nbObjs = 0;
    IGRlong		msg = 1,
			status = OM_S_SUCCESS;

#ifdef REMOVED

    IGRint		obj_generic;
    IGRchar		*locateType = NULL;

#endif

    struct GRid		setId;
    struct GRmd_env	setEnv;
    struct GRobj_env	*listObjs = NULL,
			*tmpLObjs = NULL;

    SetProc( VDCmdCrTbl.process_locate ); Begin
    *sts = VD_SUCCESS;

    nbOldObjs = om$dimension_of( varray = me->locObjs );
    __DBGpr_int( "Initial number of located objecst ", nbOldObjs );

    /* make graphic set, if necessary */

    event_size = sizeof( struct GRevent );

    VD_MakeGRsetOfObject(	&msg,
				&me->ModuleInfo,
				&me->event1.located_object[0].located_obj,
				&me->event1.located_object[0].module_info,
				&setId,
				&setEnv,
				0 );
    __DBGpr_int("VD_MakeGRsetOfObject_msg", msg);

    /* eliminate dangles, header, row, check for ownership of located objects */

    status =
    vd$filter_objects(	msg	= &msg,
			setId	= &setId );

    __DBGpr_int("Vvd$filter_objects_msg", msg);

#ifdef REMOVED

    /* set up the eligible classes, in locateType */

    obj_generic = macro_generic;
    status = VDdrw_getLocateTypeForBOM( &locateType );
    __CheckRC( status, 1, "VDdrw_getLocateTypeForBOM", wrapup );

    __DBGpr_str( "Locate type", locateType );

#endif

    /* get the list of located objects */

    ACset_disthruref();

    status =
    as$start_fence(	set		= &setId,
			set_env		= &setEnv,
			nb_obj		= &nbObjs,
			p_obj_env	= &listObjs,
			response	= me->response,
			response_data	= me->response_data );
			
#ifdef REMOVED
			response_data	= me->response_data,
			type_generic	= obj_generic,
			macro_name	= locateType );
#endif

    __DBGpr_int( "No of objects located", nbObjs );

    __CheckRC( status, 1, "as$start_fence", wrapup );

    ACreset_disthruref();

    if( !nbObjs )
    {
        *sts = VD_RESTART_CMD;
	goto wrapup;
    }

    /* copy objects to temp buffer */

    tmpLObjs = _MALLOC( nbObjs, struct GRobj_env );
    if( !tmpLObjs )
    {
	*sts = VD_ERROR;
	UI_status( "Error in dynamic allocation : command terminated" );
	goto wrapup;
    }

    __DBGpr_int("Original nbObjs", nbObjs);
    for( i = 0 ; i < nbObjs ; i++ )
    {
	tmpLObjs[i] = listObjs[i];
	__DBGpr_obj("Original listObjs", listObjs[i].obj_id);
    }

    /* filter out the objects : replace drawing objects with their parents */

    VDdrw_filterListOfObjects( &msg, &nbObjs, &tmpLObjs );
    __DBGpr_int("VDdrw_filterListOfObjects_msg", msg);
    __DBGpr_int("nbObjs after filter", nbObjs);

    if( !nbObjs && me->mytype == CREATE_TABLE )
    {
        *sts = VD_RESTART_CMD;
	goto wrapup;
    }

    if( me->mytype == CREATE_TABLE )
    {
	status = om$vla_set_dimension(	varray	= me->locObjs,
					size	= nbObjs );
	__CheckRC( status, 1, "om$vla_set_dimension", wrapup );

	for( i = 0 ; i < nbObjs ; i++ )
	    me->locObjs[i] = tmpLObjs[i];
    }
    else if( me->mytype == MODIFY_TABLE )
    {
	for( i = 0 ; i < nbObjs ; i++ )
	{
	    status =
	    _VD_SEND_MY( VDS_LOCATE.addLocatedObject(	&msg,
							&tmpLObjs[i].obj_id,
							&tmpLObjs[i].mod_env,
							OM_K_MAXINT ) );
	    __CheckRC( status, msg, "VDS_LOCATE.addLocatedObject", wrapup );
	}
    }

    /* total number of objects */

    nbObjs = om$dimension_of( varray	= me->locObjs );

    /* number of newly located objects */

    me->nbNewLocObjs = nbObjs - nbOldObjs;
    __DBGpr_int( "Number of newly located objects", me->nbNewLocObjs );

#ifdef vdsDEBUG
    printf("\n\tFinal list of objects\n");
    for( i = 0 ; i < nbObjs ; i++ )
        printf("\t\tObj # %d = [%d, %d]\n", i, 	me->locObjs[i].obj_id.objid,
						me->locObjs[i].obj_id.osnum );
#endif

wrapup :
    if( setId.objid != NULL_OBJID ) /* TR6614 */
    {
        om$send ( msg      = message GRgrset.GSdissolve(&msg),
                  targetid = setId.objid,
                  targetos = setId.osnum);
    }

    if( !(status & msg & 1) )
    {
	*sts = VD_ERROR;
	UI_status( "Error encountered : command terminated" );
	__DBGpr_com("Error encountered : command terminated\n");
    }
    ASend_fence();
    _FREE( tmpLObjs );

#ifdef REMOVED
    _FREE( locateType );
#endif
    End
    return OM_S_SUCCESS;
}

/*+me
 ---------------------------------------------------------------------------
  Public Message process_rowno

  Abstract
        This method stores the located row number and updates the
        form.

  Arguments
        long         *sts            O       Return code

  Notes/Remarks

  Status/Return Code
      sts == VD_SUCCESS

 ---------------------------------------------------------------------------
-me*/

method  process_rowno( long *sts )
{
    IGRint		rowNo;
    IGRchar		buf[20];
    struct GRid		rowId;
    IGRlong		msg,
			status = OM_S_SUCCESS;
    IGRint              traceFlag;


    SetProc( VDCmdCrTbl.process_rowno ); Begin

    *sts = VD_SUCCESS;
    traceFlag = 0;   
if(traceFlag) printf(">>> vds/vdtbl/cmd/VDtblLoc.I: method  process_rowno\n");

    rowId = me->event1.located_object[0].located_obj ;
    __DBGpr_obj( "Row id", rowId );

    /* get the row number */

    status =
    _VD_SEND_OBJ( rowId, VDdrwTblRow.VDgetRowNumber( &msg, &rowNo ) );
    __CheckRC( status, msg, "VDdrwTblRow.VDgetRowNumber", wrapup );

    __DBGpr_int( "Row number of located row", rowNo );

    sprintf( buf, "%d", rowNo );
    __DBGpr_str( "Row number string", buf );

    /* update number on the form */

    FIg_set_text( VD_FP, VD_TBL_SPL_LOC_ROW_TXT, buf );
						
wrapup :
    if(traceFlag) printf("<<< vds/vdtbl/cmd/VDtblLoc.I: method  process_rowno[%d]\n",
                         OM_S_SUCCESS);
    End
    return OM_S_SUCCESS;
}

end implementation VDCmdCrTbl;
