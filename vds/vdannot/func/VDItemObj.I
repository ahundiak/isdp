/* $Id: VDItemObj.I,v 1.3 2001/09/14 16:57:26 ahundiak Exp $  */

/* I/VDS
 * -------------------------------------------------------------------------
 *
 * File:	vdannot/func/VDItemObj.I
 *
 * Description:		VDGetGridsFromChan_of_Class
 *			VDGetRowIdsItemNums_TblIdsTblNms_FromObjId
 *			VDGetRowIdItemNum_FromObjId_TableId
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDItemObj.I,v $
 *	Revision 1.3  2001/09/14 16:57:26  ahundiak
 *	*** empty log message ***
 *	
 *	Revision 1.2  2001/07/28 20:03:00  ad
 *	*** empty log message ***
 *	
 *	Revision 1.1.1.1  2001/01/04 21:07:40  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1998/04/16  00:00:18  pinnacle
# Replaced: vdannot/func/VDItemObj.I for:  by mdong for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.9  1996/04/10  18:21:38  pinnacle
# Replaced: vdannot/func/VDItemObj.I for:  by jwfrosch for vds.240
#
# Revision 1.8  1995/09/22  20:01:26  pinnacle
# Replaced: vdannot/func/VDItemObj.I for:  by jwfrosch for vds.240
#
# Revision 1.7  1995/09/06  21:04:06  pinnacle
# Replaced: vdannot/func/VD[AIsg]*.I for:  by jwfrosch for vds.240
#
# Revision 1.6  1995/08/30  13:39:54  pinnacle
# Replaced: vdannot/func/VD[AlpsI]*.I for:  by jwfrosch for vds.240
#
# Revision 1.5  1995/08/29  21:25:42  pinnacle
# Replaced: vdannot/func/VD[ApTgsI]*.I for:  by jwfrosch for vds.240
#
# Revision 1.4  1995/08/23  18:00:02  pinnacle
# Replaced: vdannot/func/VD*I for:  by jwfrosch for vds.240
#
# Revision 1.3  1995/08/18  23:04:08  pinnacle
# Replaced: vdannot/func/*.I for:  by jwfrosch for vds.240
#
# Revision 1.2  1995/07/25  22:44:32  pinnacle
# Replaced: vdannot/func/VDItemObj.I for:  by jwfrosch for vds.240
#
# Revision 1.1  1995/07/13  14:00:38  pinnacle
# Created: vdannot/func/VDItemObj.I by jwfrosch for vds.240
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *
 *	06/16/95     HF		Creation
 *
 *	04/10/96     HF		TR 179601220
 *      04/14/98     Ming       TR179800949. Add function 
 *                                           VDGetVDdrw2dObject_FrmModelObj()
 *      07/28/01     adz	TR5467
 *
 * -------------------------------------------------------------------------
 */

class implementation Root;

/*
#define vdsDEBUG
#define vdserrDEBUG
*/

#include <stdio.h>
#include <string.h>

#include "igrtypedef.h"
#include "igetypedef.h"
#include "OMerrordef.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "ex.h"
#include "gr.h"
#include "growner.h"
#include "exmacros.h"
#include "asmacros.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#include "vdandef.h"
#include "vdanmacros.h"
#include "asbox.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "VDdrwlo.h"
#include "VDdrwtbl.h"

#include "AS_status.h"

#define VD_DEBUG

#include "VDdebug.h"

extern GRclassid	OPP_VDdrwSet_class_id,
			OPP_VDdrwTbl_class_id,
			OPP_VDdrwTblHdr_class_id,
			OPP_VDdrw3d_class_id,
			OPP_VDdrw2d_class_id,
			OPP_VDdrwTblRow_class_id,
			OPP_ACpretendin_class_id,
			OPP_ACpretend_class_id,
			OPP_NDnodein_class_id,
			OPP_VDatBase_class_id,
			OPP_VDct1Base_class_id;

from	VDdrwTblRow	import	VDgetItemNumber;
from	NDmacro		import	ACreturn_foot;

/*+fe
 -------------------------------------------------------------------------
  Function VDGetGridsFromChan_of_Class

  Macro Name
	None

  Abstract
	Function to retrieve the number of objects from a channel

  Arguments

	IGRlong		 *msg		O	return code
	struct GRid	  ModelId	I	Id of the owner object
	OM_S_CHANSELECT	 *my_chansel	I	channel to retrieve onjects from
	short		  classid	I	classid to look for :
						classid > 0 : exact match
						classid = 0 : all objects on channel
						classid < 0 : all subclassed objects
	int		 *NbFound	O	# objects found on channel
	struct GRid	**FoundId	O	List of objects found on channel
						HAS TO BE FREED BY CALLING FUNCTION !!!
  Notes/Remarks

  Returns
	OM_S_SUCCESS	= if success
	OM_E_ABORT	= if error
 -------------------------------------------------------------------------
-fe*/

int VDGetGridsFromChan_of_Class
(
  IGRlong		 *msg,
  struct GRid		  ModelId,
  OM_S_CHANSELECT	 *my_chansel,
  short			  classid,
  int			 *NbFound,
  struct GRid		**FoundId
)
{
  int			 i0, j0, status = OM_S_SUCCESS;
  short			 valid_class = 0;
  OMuint		 cnt = 0;
  GRclassid		 clid;
  OM_S_OBJECT_LINKAGE	*lobj = NULL;

  __enterFunction ( name = "VDGetGridsFromChan_of_Class" );

  *msg     = MSSUCC;
  *NbFound = 0;
  *FoundId = NULL;
  /*
   * Find the number of objects on the channel
   */

  status = om$get_channel_count(osnum		= ModelId.osnum,
				objid		= ModelId.objid,
				p_chanselect	= my_chansel,
				count		= &cnt );
//  as$status ();
  if ( status != OM_S_SUCCESS ) { __print_goto ( "wrapup" ); goto wrapup; }

  if ( cnt > 0 )
  {
    lobj = _MALLOC ( cnt, OM_S_OBJECT_LINKAGE );

    if ( lobj == NULL ) { __print_goto ( "wrapup" ); goto wrapup; }

    if ( lobj )
    {
      status = om$get_channel_objects(
				osnum		= ModelId.osnum,
				objid		= ModelId.objid,
				p_chanselect	= my_chansel,
				size		= cnt,
				list		= lobj,
				count		= &cnt );
      as$status ();

      if ( ! status ) { __print_goto ( "wrapup" ); goto wrapup; }

      for ( i0 = 0; i0 < cnt; i0++ )
      {
	struct GRid	child_id;

	child_id.objid = lobj[i0].S_objid;
	child_id.osnum = lobj[i0].osnum;

	if ( classid < 0 )
	{
	  valid_class = DMancestry_valid ( child_id, - classid );
	}
	else if ( classid > 0 )
	{
	  om$get_classid (objid		= child_id.objid,
			osnum		= child_id.osnum,
			p_classid	= &clid );
	}

	if ( classid == 0 )
	{
	  if ( (*FoundId) == NULL ) { (*FoundId) = _MALLOC ( cnt, struct GRid ); }

	  if ( (*FoundId) == NULL ) { __print_goto ( "wrapup" ); goto wrapup; }

	  *NbFound = cnt;
	  for ( j0 = 0; j0 < cnt; j0++ )
	  {
	    (*FoundId)[j0].objid = lobj[j0].S_objid;
	    (*FoundId)[j0].osnum = lobj[j0].osnum;
	  }

	  break;
	}
	else if ( (valid_class & 1) || clid == classid )
	{
	  if ( (*FoundId) == NULL ) { (*FoundId) = _MALLOC ( (*NbFound) + 1, struct GRid ); }
	  else { (*FoundId) = _REALLOC ( (*FoundId), (*NbFound) + 1, struct GRid ); }

	  if ( (*FoundId) == NULL ) { __print_goto ( "wrapup" ); goto wrapup; }

	  (*FoundId)[*NbFound].objid = child_id.objid;
	  (*FoundId)[*NbFound].osnum = child_id.osnum;

	  (*NbFound)++;
	}
      }
    }
  }

  __printf ( "sts= %d, *msg= %d, Id= [%d,%d], NbPrtnd= %d", `status, *msg, ModelId.osnum, ModelId.objid, *NbFound` );
  __exitFunction ( name = "VDGetGridsFromChan_of_Class" );

  _FREE ( lobj );

  return status;

wrapup :

  _FREE ( lobj );
  _FREE ( *FoundId );

  status   = OM_E_ABORT;
  *msg     = MSFAIL;
  *NbFound = 0;

  __exit_error_Function ( name = "VDGetGridsFromChan_of_Class" );

  return status;
}

/*+fe
 -------------------------------------------------------------------------
  Function VDGetRowIdsItemNums_TblIdsTblNms_FromObjId

  Macro Name
	None

  Abstract
	Function to retrieve the RowIds+ItemNumbers and TableIds+TableNames
	for an object (p.e. VDequipment)

  Arguments

	IGRlong		  *msg		O	return code
	int		  *NbFound	O	Flag indicating found
						(should be 0 or > 0)
	int		  *NbUnCnctd	O	Flag indicating not yet connected rows
						(should be <= NbFound)
	struct GRid	   ModelId	I	Id of the Model object

				FOLLOWING ARGUMENTS HAVE TO BE FREED BY CALLING FUNCTION !!!

	int		 **UnCnctdFlag	O	Array of flags indicating Free(1) or Connected(0)
	struct GRid	 **RowId	O	Ids of the Row objects
	struct GRid	 **TblId	O	Ids of the Table objects

	char		***ItemNum	O	ItemNumbers
	char		***TblNam	O	TableNames
	char		***PthNam	O	PathNames

  Notes/Remarks

  Returns
	OM_S_SUCCESS	= if success
	OM_E_ABORT	= if error
 -------------------------------------------------------------------------
-fe*/

int VDGetRowIdsItemNums_TblIdsTblNms_FromObjId
(
  IGRlong		  *msg,
  int			  *NbFound,
  int			  *NbUnCnctd,
  int			 **UnCnctdFlag,
  struct GRid		   ModelId,
  struct GRid		 **RowId,
  struct GRid		 **TblId,
  char			***ItemNum,
  char			***TblNam,
  char			***PthNam
)
{
  IGRboolean		 item_found, VDComp_class = TRUE;
  IGRlong		 loc1_msg = 0;
  int			 i0, j0, status = OM_S_SUCCESS, indx = 0, have_pretends = 0;
  int			 TotNbDrwSet= 0,
			 NbDrwSet = 0,
			 NbTblRow = 0,
			 NbTblHdr = 0,
			 NbTables = 0,
			 NbPrTree = 0,
			 NbPrtnd  = 0,
			 NbPrtnd1 = 0;
  IGRint		 itemsz   = 0;
  IGRchar		 item_num [40];
  char			 table_nm [DI_PATH_MAX],
			 pathname [DI_PATH_MAX],
			 filename [DI_PATH_MAX], *cptr, *ItmNm = NULL;

  OM_S_CHANSELECT	 to_child, to_tblHdr, to_owner, to_prtnd;
  struct GRid		 item_id,
			*TotDrwSet= NULL,
			*DrwSet   = NULL,
			*TblRow   = NULL,
			*TblHdr   = NULL,
			*Tables   = NULL,
			*PrTree   = NULL,
			*Prtnd	  = NULL,
			*Prtnd1	  = NULL;

  struct GRid		srcObj[2],
			ctxId  = NULL_GRID;
  OMuword		os = 0;
  GRclassid		classid;

  __enterFunction ( name = "VDGetRowIdsItemNums_TblIdsTblNms_FromObjId" );

   *msg		= MSSUCC;
   *NbFound	= 0;
   *NbUnCnctd	= 0;
   srcObj[0]	= NULL_GRID;
   srcObj[1]	= NULL_GRID;

  /*
   * Prepare channel_selectors
   */

  status = om$make_chanselect ( channame	= "NDchildren.children",
				p_chanselect	= &to_child );
  as$status( action = GOTO_VALUE, value = wrapup );

  status = om$make_chanselect ( channame	= "VDdrwTblRow.to_tblHdr",
				p_chanselect	= &to_tblHdr );
  as$status( action = GOTO_VALUE, value = wrapup );

  status = om$make_chanselect ( channame	= "GRconnector.to_owners",
				p_chanselect	= &to_owner );
  as$status( action = GOTO_VALUE, value = wrapup );

  status = om$make_chanselect ( channame	= "GRnotify.notification",
				p_chanselect	= &to_prtnd );
  as$status( action = GOTO_VALUE, value = wrapup );

  /*
   * Get current osnum
   */
  status = ex$get_cur_mod ( osnum    = &os );
  __printf ( ">>>>> CurrentOS = [%d]",`os` );

  /*
   * Special case to handle VRCorrection/VRComponent objects properly
   */

  VDComp_class = TRUE;
  status =
  om$get_classid (	classname = "VRComponent",
			p_classid = &classid );
  if ( ! ( status & 1 ) ) VDComp_class = FALSE;

  loc1_msg = ( VDComp_class && DMancestry_valid ( ModelId, classid ) );

  if ( loc1_msg & OM_S_SUCCESS )
  {
    /*
     * Get the context object for as$make_source
     */
    if( ModelId.osnum == os )
    {
      ctxId = NULL_GRID;
    }
    else
    {
      status = GRfindcontext( msg, NULL, NULL, &ModelId.osnum, &ctxId );
      if( !(status & 1) )
      {
	__prints ( "Context not found" );
	ctxId = NULL_GRID;
      }
    }

    __printf ( "ctxId = [%d,%d]", `ctxId.osnum, ctxId.objid` );
    status = as$make_source (	go_grid		= ModelId,
				context_grid	= ctxId,
				as_os		= ModelId.osnum,
				as_grid		= &srcObj[0] );
    as$status();

//    __printf ( ">>>>> ModelId = [%d,%d] ==>>  srcObj[0] = [%d,%d]",
//		` ModelId.osnum, ModelId.objid, srcObj[0].osnum, srcObj[0].objid` );
//
//    if ( srcObj[0].objid != NULL_OBJID && srcObj[0].objid != ModelId.objid
//    && DMancestry_valid ( srcObj[0], OPP_ACpretend_class_id ) & 1 )
    {
      /*
       * Replace ModelId (VRComponent) by srcObj[0] (ACpretendin)
       */

      __printf ( ">>>>> VRComponent == >> ACpretendin: ModelId = [%d,%d] ==>>  srcObj[0] = [%d,%d]",
		` ModelId.osnum, ModelId.objid, srcObj[0].osnum, srcObj[0].objid` );

      have_pretends++;
    }

    status = as$make_source (	go_grid	= ModelId,
				as_os	= ModelId.osnum,
				as_grid	= &srcObj[1] );
    as$status();

    if ( srcObj[0].objid != srcObj[1].objid )
    {
//    __printf ( ">>>>> ModelId = [%d,%d] ==>>  srcObj[1] = [%d,%d]",
//		` ModelId.osnum, ModelId.objid, srcObj[1].osnum, srcObj[1].objid` );
//
//    if ( srcObj[1].objid != NULL_OBJID && srcObj[1].objid != ModelId.objid
//      && DMancestry_valid ( srcObj[1], OPP_ACpretend_class_id ) & 1 )
//    {}
      /*
       * Replace ModelId (VRComponent) by srcObj[1] (ACpretendin)
       */

      __printf ( ">>>>> VRComponent == >> ACpretendin: ModelId = [%d,%d] ==>>  srcObj[1] = [%d,%d]",
		` ModelId.osnum, ModelId.objid, srcObj[1].osnum, srcObj[1].objid` );

      have_pretends++;
    }


    if ( have_pretends )
    {
      NbPrtnd = have_pretends;

      Prtnd = _MALLOC ( NbPrtnd, struct GRid );

      if ( Prtnd )
      {
	memcpy ( Prtnd, srcObj, have_pretends * sizeof ( struct GRid ) );
      }
    }
  }

  /*
   * Get All ACpretendin/ASsourcein (subclasses of NDnodein) objects from the notification channel
   * If NbPrtnd != 0, then we have to find the VDdrwSet here also !!!
   */

  __printf ( ">>>>> Has Pretends = [%d]",`have_pretends` );

  if ( have_pretends == FALSE )
  {
//    status = VDGetGridsFromChan_of_Class ( msg, ModelId, &to_prtnd, OPP_ACpretendin_class_id, &NbPrtnd, &Prtnd );
    __prints ( "GetGrids: -OPP_NDnodein_class_id " );
    status = VDGetGridsFromChan_of_Class ( msg, ModelId, &to_prtnd, -OPP_NDnodein_class_id, &NbPrtnd, &Prtnd );
  }

  for ( i0 = 0; i0 < NbPrtnd; i0++)
  {
    __prints ( "GetGrids: OPP_VDdrwSet_class_id " );
    status = VDGetGridsFromChan_of_Class ( msg, Prtnd[i0], &to_child, OPP_VDdrwSet_class_id, &NbDrwSet, &DrwSet );

    if ( NbDrwSet > 0 )
    {
      if ( TotDrwSet == 0 ) { TotDrwSet =  _MALLOC ( (TotNbDrwSet+NbDrwSet), struct GRid ); }
      else { 		      TotDrwSet = _REALLOC ( TotDrwSet, (TotNbDrwSet+NbDrwSet), struct GRid ); }
      if ( TotDrwSet == 0 ) { __print_goto ( "quit" ); goto quit; }

      memcpy ( &TotDrwSet[TotNbDrwSet], DrwSet, sizeof (struct GRid) * NbDrwSet );

      TotNbDrwSet += NbDrwSet;
      _FREE ( DrwSet );
    }
    __printf ("%d VDdrwSet connected to this ACpretendin [%d,%d]", `NbDrwSet, Prtnd[i0].osnum, Prtnd[i0].objid` );

  }

  /*
   * Get All VDdrwSet objects from the children channel
   * If NbDrwSet == 0, and also TotNbDrwSet == 0 then there is no need to look further
   */

  if ( have_pretends == FALSE )
  {
    __prints ( "GetGrids: OPP_VDdrwSet_class_id " );
    status = VDGetGridsFromChan_of_Class ( msg, ModelId, &to_child, OPP_VDdrwSet_class_id, &NbDrwSet, &DrwSet );
  }
  else
  {
    NbDrwSet = 0;
  }

  if ( NbDrwSet == 0 && TotNbDrwSet == 0 )
  {

    /*
     * The Row may have been constructed with usage of Tree object.
     * Model -(to_notify)- VDxxBase -(to_notify)- ASsource -(child)- Set(s).
     * Model -(to_notify)- VDxxBase -(child)- Set(s).
     */

    __prints ( "GetGrids: OPP_VDatBase_class_id " );
    status = VDGetGridsFromChan_of_Class ( msg, ModelId, &to_prtnd, OPP_VDatBase_class_id, &NbPrTree, &PrTree );

    if( !NbPrTree ){
      __prints ( "GetGrids: OPP_VDct1Base_class_id " );
      status = VDGetGridsFromChan_of_Class ( msg, ModelId, &to_prtnd, OPP_VDct1Base_class_id, &NbPrTree, &PrTree );
    }

    if( NbPrTree ){

      /*
       * Check if there is a Make_source (ASsource | ACpretend connected) -> Always to notify channel !!
       */

      NbPrtnd = 0 ;
      _FREE( Prtnd );

      for ( i0 = 0; i0 < NbPrTree; i0++ ){

        __prints ( "GetGrids: -OPP_NDnodein_class_id " );
        status = VDGetGridsFromChan_of_Class ( msg, PrTree[i0], &to_prtnd, -OPP_NDnodein_class_id, &NbPrtnd1, &Prtnd1 );

        if( NbPrtnd1 > 0 ){
          if ( Prtnd == 0 ) { Prtnd =  _MALLOC (        (NbPrtnd+NbPrtnd1), struct GRid ); }
          else { 	      Prtnd = _REALLOC ( Prtnd, (NbPrtnd+NbPrtnd1), struct GRid ); }
          if ( Prtnd == 0 ) { __print_goto ( "quit" ); goto quit; }

          memcpy ( &Prtnd[NbPrtnd], Prtnd1, sizeof (struct GRid) * NbPrtnd1 );

          NbPrtnd += NbPrtnd1;
          _FREE ( Prtnd1 );
        }
      }

      __printf ("%d Source (1) connected ", NbPrtnd );

      if( ! NbPrtnd ){

	/*
	 * This can be the case where the tree and the table are in the same file. 
	 */
	Prtnd = _MALLOC ((NbPrTree), struct GRid );
	memcpy ( &Prtnd[NbPrtnd], PrTree, sizeof (struct GRid) * NbPrTree );
	NbPrtnd += NbPrTree ;

      }

      __printf ("%d Source (2) connected ", NbPrtnd );

      if( NbPrtnd ){

        _FREE( DrwSet );

        for ( i0 = 0; i0 < NbPrtnd; i0++)
        {
          __prints ( "GetGrids: OPP_VDdrwSet_class_id " );
          status = VDGetGridsFromChan_of_Class ( msg, Prtnd[i0], &to_child, OPP_VDdrwSet_class_id, &NbDrwSet, &DrwSet );

          if ( NbDrwSet > 0 )
          {
            if ( TotDrwSet == 0 ) { TotDrwSet =  _MALLOC (            (TotNbDrwSet+NbDrwSet), struct GRid ); }
            else { 		    TotDrwSet = _REALLOC ( TotDrwSet, (TotNbDrwSet+NbDrwSet), struct GRid ); }
            if ( TotDrwSet == 0 ) { __print_goto ( "quit" ); goto quit; }

            memcpy ( &TotDrwSet[TotNbDrwSet], DrwSet, sizeof (struct GRid) * NbDrwSet );

            TotNbDrwSet += NbDrwSet;
            _FREE ( DrwSet );
          }
          __printf ("%d VDdrwSet connected to this ACpretendin [%d,%d]", `NbDrwSet, Prtnd[i0].osnum, Prtnd[i0].objid` );
        }
	/*
	 * Adjust the NbDrwSet & TotNbDrwSet for down stream processing.
	 */
	NbDrwSet    = 0 ;
      }
    }

    if( NbDrwSet == 0 && TotNbDrwSet == 0 ){ __print_goto ( "quit" ); goto quit; }
  }



  /*
   * We find all possible VDdrwSet objects..
   * ============================================================
   */

  if ( NbDrwSet > 0 )
  {
    if ( TotNbDrwSet > 0 )
    {
      DrwSet = _REALLOC ( DrwSet, (TotNbDrwSet+NbDrwSet), struct GRid );

      memcpy ( &DrwSet[NbDrwSet], TotDrwSet, sizeof (struct GRid) * TotNbDrwSet );

      NbDrwSet += TotNbDrwSet;
      _FREE ( TotDrwSet );
    }
  }
  else
  {
    if ( TotNbDrwSet > 0 )
    {
      DrwSet = TotDrwSet;
      NbDrwSet = TotNbDrwSet;
    }
  }

  for ( i0 = 0; i0 < NbDrwSet; i0++)
  {
    __printf ("ModelId [%d,%d] connected to VDdrwSet[%d] =  [%d,%d]",
		`ModelId.osnum, ModelId.objid, i0, DrwSet[i0].osnum, DrwSet[i0].objid` );
  }

  *NbFound = NbDrwSet;

  if ( (*ItemNum) == NULL ) { (*ItemNum) = _CALLOC ( NbDrwSet, char * ); }
  if ( (*ItemNum) == NULL ) { __print_goto ( "wrapup" ); goto wrapup; }

  if ( (*TblNam) == NULL ) { (*TblNam) = _CALLOC ( NbDrwSet, char * ); }
  if ( (*TblNam) == NULL ) { __print_goto ( "wrapup" ); goto wrapup; }

  if ( (*PthNam) == NULL ) { (*PthNam) = _CALLOC ( NbDrwSet, char * ); }
  if ( (*PthNam) == NULL ) { __print_goto ( "wrapup" ); goto wrapup; }

  for ( i0 = 0; i0 < NbDrwSet; i0++)
  {
    (*ItemNum)[i0] = NULL;
    (*TblNam) [i0] = NULL;
    (*PthNam) [i0] = NULL;
    table_nm  [0]  = '\0';
    pathname  [0]  = '\0';

    /*
     * Get All VDdrwTblRow objects from the children channel of VDdrwSet: SHOULD BE 1
     */

    __prints ( "GetGrids: OPP_VDdrwTblRow_class_id " );
    status = VDGetGridsFromChan_of_Class ( msg, DrwSet[i0], &to_child, OPP_VDdrwTblRow_class_id, &NbTblRow, &TblRow );

    if ( NbTblRow == 0 )
    {
      printf ("ERROR: No VDdrwTblRow connected to this VDdrwSet [%d,%d]\n", DrwSet[i0].osnum, DrwSet[i0].objid );
      __print_goto ( "quit" );
      goto wrapup;
    }
    else if ( NbTblRow > 1 )
    {
      printf ("ERROR: More then one (%d) VDdrwTblRow connected to this VDdrwSet [%d,%d]\n",
			NbTblRow, DrwSet[i0].osnum, DrwSet[i0].objid );
      __print_goto ( "quit" );
      goto wrapup;
    }

    /*
     * Get All VDdrwTblHdr objects from the to_tblHdr channel of VDdrwTblRow: SHOULD BE 1
     */

    __prints ( "GetGrids: OPP_VDdrwTblHdr_class_id " );
    status = VDGetGridsFromChan_of_Class ( msg, TblRow[0], &to_tblHdr, OPP_VDdrwTblHdr_class_id, &NbTblHdr, &TblHdr );

    if ( NbTblHdr == 0 )
    {
      printf ("ERROR: No VDdrwTblHdr connected to this VDdrwTblRow [%d,%d]\n", TblRow[0].osnum, TblRow[0].objid );
      __print_goto ( "quit" );
      goto wrapup;
    }
    else if ( NbTblHdr > 1 )
    {
      printf ("ERROR: More then one (%d) VDdrwTblHdr connected to this VDdrwTblRow [%d,%d]\n",
			NbTblHdr, TblRow[0].osnum, TblRow[0].objid );
      __print_goto ( "quit" );
      goto wrapup;
    }

    item_num [0] = '\0';

    status = om$send (	msg	 = message VDdrwTblRow.VDgetItemNumber ( msg, &itemsz, item_num ),
			senderid = NULL_OBJID,
			targetid = TblRow[0].objid,
			targetos = TblRow[0].osnum );
    as$status();

    /*
     * (Re)Allocate memory for RowId & ItemNum
     */

    if ( (*RowId) == NULL ) { 	(*RowId) = _MALLOC (           (indx + 1), struct GRid ); }
    else { 			(*RowId) = _REALLOC( (*RowId), (indx + 1), struct GRid ); }

    if ( (*RowId) == NULL ) { __print_goto ( "wrapup" ); goto wrapup; }

    ( *RowId ) [indx] = TblRow[0];

    (*ItemNum) [indx] = _CALLOC ( strlen (item_num) + 1, char );

    if ( (*ItemNum)[indx] == NULL ) { __print_goto ( "wrapup" ); goto wrapup; }

    strcpy ( ( *ItemNum ) [indx] , item_num );

    /*
     * (Re)Allocate memory for UnCnctdFlag
     */

    if ( (*UnCnctdFlag) == NULL ) { (*UnCnctdFlag) = _CALLOC ( (indx + 1), int ); }
    else { (*UnCnctdFlag) = _REALLOC ( (*UnCnctdFlag), (indx + 1), int ); }

    if ( (*UnCnctdFlag) == NULL ) { __print_goto ( "wrapup" ); goto wrapup; }

    /*
     * Get All VDdrwTbl objects from the to_owners channel of VDdrwTblHdr: SHOULD BE 1
     */

    __prints ( "GetGrids: OPP_VDdrwTbl_class_id " );
    status = VDGetGridsFromChan_of_Class ( msg, TblHdr[0], &to_owner, OPP_VDdrwTbl_class_id, &NbTables, &Tables );

    if ( NbTables == 0 )
    {
      printf ("ERROR: No VDdrwTbl connected to this VDdrwTblHdr [%d,%d]\n", TblHdr[0].osnum, TblHdr[0].objid );
      __print_goto ( "quit" );
      goto wrapup;
    }
    else if ( NbTables > 1 )
    {
      printf ("ERROR: More then one (%d) VDdrwTbl connected to this VDdrwTblHdr [%d,%d]\n",
			NbTables, TblHdr[0].osnum, TblHdr[0].objid );
      __print_goto ( "quit" );
      goto wrapup;
    }

    /*
     * (Re)Allocate memory for TblId
     */

    __printf (  ">>>>>>>>>> *TblId = %#x, TblId[%d] = %#x", `*TblId, indx, TblId[indx]` );

    if ( (*TblId) == NULL )
    {
      (*TblId) = _MALLOC ( (indx + 1), struct GRid );
    }
    else
    {
      (*TblId) = _REALLOC ( (*TblId), (indx + 1), struct GRid );
    }

    __printf (  "<<<<<<<<<< *TblId = %#x, TblId[%d] = %#x", `*TblId, indx, TblId[indx]` );

    if ( (*TblId) == NULL ) { __print_goto ( "wrapup" ); goto wrapup; }

    ( *TblId ) [indx] = Tables[0];

    __printf (  "(*TblId)[%d] = [%d,%d] Tables = [%d,%d]",
	`indx, (*TblId)[indx].osnum, (*TblId)[indx].objid, Tables[0].osnum, Tables[0].objid` );

    status = di$untranslate (	objname = table_nm,
				objid	= Tables[0].objid,
				osnum	= Tables[0].osnum);
    if ( status != DIR_S_SUCCESS )
    {
	di$report_error ( sts = status );
    }
    __printf (  "table_nm = <%s>", `table_nm` );

    di$give_pathname ( osnum = Tables[0].osnum, pathname = pathname );
    di$split (  pathname = pathname, name = filename);

    /*
     * Remove 1st & last ':'
     */
    strcpy ( table_nm, &table_nm[1] );			// Skip first  ':'
    table_nm [ strlen(table_nm) ] = '\0';		// Remove last ':'

    /*
     * tablename starts at last ':' and is appended with [<filename>]
     */
    cptr = strrchr ( table_nm, ':' );			// Last  ':'
    sprintf ( table_nm, "%s[%s]", ++cptr, filename );
    strcat  ( pathname, ":usr:drw_tables" );

    __printf ( "table_nm = <%s>, pathname = <%s>, filename = <%s>", `table_nm, pathname, filename` );

    if ( have_pretends == FALSE )
    {
      status = vd$getItemNoForObj (	obj	= ModelId,
					tblName	= table_nm,
					itemId	= &item_id,
					itemNo	= &ItmNm,
					found	= &item_found );
    }
    else
    {
      for ( j0 = 0; j0 < NbPrtnd; j0++)
      {
	status = vd$getItemNoForObj (	obj	= Prtnd[j0],
					tblName	= table_nm,
					itemId	= &item_id,
					itemNo	= &ItmNm,
					found	= &item_found );

	if ( item_found == FALSE )
	{
	  _FREE ( ItmNm );
	}
	else
	{
	  break;
	}
      }
    }

    if ( item_found == FALSE )
    {
      (*NbUnCnctd)++;
      (*UnCnctdFlag)[i0] = 1;
    }
    else
    {
      (*UnCnctdFlag)[i0] = 0;
    }

    _FREE ( ItmNm );

    (*TblNam)[indx] = _CALLOC ( strlen (table_nm) + 1, char );

    if ( (*TblNam)[indx] == NULL )
    {
      __print_goto ( "wrapup" );
      goto wrapup;
    }

    (*PthNam)[indx] = _CALLOC ( strlen (pathname) + 1, char );

    if ( (*PthNam)[indx] == NULL )
    {
      __print_goto ( "wrapup" );
      goto wrapup;
    }

    strcpy ( ( *TblNam ) [indx] , table_nm );
    strcpy ( ( *PthNam ) [indx] , pathname );

    indx++;

    _FREE ( TblRow );
    _FREE ( TblHdr );
    _FREE ( Tables );
  }

quit:

  _FREE ( DrwSet );
  _FREE ( TblRow );
  _FREE ( TblHdr );
  _FREE ( Tables );
  _FREE ( Prtnd  );
  _FREE ( Prtnd1  );
  _FREE ( PrTree  );

  __printf ( "Found %d Row's connected", *NbFound );

  __exitFunction ( name = "VDGetRowIdsItemNums_TblIdsTblNms_FromObjId" );

  return status;

wrapup :

  status   = OM_E_ABORT;
  *msg     = MSFAIL;
  *NbFound = 0;

  _FREE ( DrwSet );
  _FREE ( TblRow );
  _FREE ( TblHdr );
  _FREE ( Tables );
  _FREE ( Prtnd  );
  _FREE ( Prtnd1 );
  _FREE ( PrTree );

  _FREE ( *RowId );
  _FREE ( *TblId );
  _FREE ( *UnCnctdFlag );

  for ( i0=0; i0 < NbDrwSet; i0++ )
  {
    _FREE ( (*ItemNum)[i0] );
    _FREE ( (*TblNam )[i0]);
    _FREE ( (*PthNam )[i0]);
  }

  _FREE ( *ItemNum );
  _FREE ( *TblNam );
  _FREE ( *PthNam );

  __printf ( "Found %d Row's connected", *NbFound );

  __exit_error_Function ( name = "VDGetRowIdsItemNums_TblIdsTblNms_FromObjId" );

  return status;
}

/*+fe
 -------------------------------------------------------------------------
  Function VDGetRowIdItemNum_FromObjId_TableId

  Macro Name
	None

  Abstract
	Function to retrieve the RowId+ItemNumber from and ModelId & TableIds
	for an object (p.e. VDequipment)

  Arguments

	IGRlong		  *msg		O	return code
	int		  *NbFound	O	Flag indicating found
						(should be 0 or > 0)
	struct GRid	   ModelId	I	Id of the owner object
	struct GRid	   TableId	I	Id of the Table to search object

	struct GRid	  *RowId	O	Id of the Row object
	char		   ItemNum[]	O	ItemNumber

  Notes/Remarks

  Returns
	OM_S_SUCCESS	= if success
	OM_E_ABORT	= if error
 -------------------------------------------------------------------------
-fe*/

int VDGetRowIdItemNum_FromObjId_TableId
(
  IGRlong		  *msg,
  int			  *NbFound,
  struct GRid		   ModelId,
  struct GRid		   TableId,
  struct GRid		  *TblRowId,
  char			  *ItemNumber
)
{
  int			 i0, indx = 0,status = OM_S_SUCCESS, success_found = FALSE;
  IGRlong		  loc1_msg = 0;
  struct GRobj_env	  ModRefId;
  struct GRid		 *RowId	  = NULL;
  struct GRid		 *TblId	  = NULL;
  char			**ItemNum = NULL;
  char			**TblNam  = NULL;
  char			**PthNam  = NULL;
  int			  NbUnCnctd    = 0;
  int			 *UnCnctdFlag  = NULL;

  __enterFunction ( name = "VDGetRowIdItemNum_FromObjId_TableId" );

  *msg		= MSSUCC;
  *NbFound	= 0;
  ItemNumber[0] = '\0';
  TblRowId->objid	 = NULL_OBJID;
  ModRefId.obj_id.objid  = NULL_OBJID;

  loc1_msg = DMancestry_valid ( ModelId, OPP_ACpretendin_class_id );

  if ( loc1_msg & OM_S_SUCCESS )
  {
    status =
    om$send (	msg	 = message NDmacro.ACreturn_foot(
					 msg,
					 "",
					&ModRefId.obj_id,
					&ModRefId.mod_env.md_env.matrix_type,
					 ModRefId.mod_env.md_env.matrix ),
		senderid = NULL_OBJID,
		targetid = ModelId.objid,
		targetos = ModelId.osnum );
    as$status();

    __printf ( "status = %d, *msg = %d, ModRefId = [%d,%d]", `status, *msg, ModRefId.obj_id.osnum, ModRefId.obj_id.objid` );

    status = VDGetRowIdsItemNums_TblIdsTblNms_FromObjId
		( msg, NbFound, &NbUnCnctd, &UnCnctdFlag, ModRefId.obj_id, &RowId, &TblId, &ItemNum, &TblNam, &PthNam );
  }
  else
  {
    status = VDGetRowIdsItemNums_TblIdsTblNms_FromObjId
		( msg, NbFound, &NbUnCnctd, &UnCnctdFlag, ModelId, &RowId, &TblId, &ItemNum, &TblNam, &PthNam );
  }

  __printf ( "ModelId[%d,%d] is connected to %d Tables (%d unconnected)", `ModelId.osnum, ModelId.objid, *NbFound, NbUnCnctd` );

  indx = *NbFound;
  for ( i0=0; i0 < indx; i0++ )
  {
    __printf (  "RowId[%d] = [%d,%d] TblId = [%d,%d] UnCnctdFlag [%d] ItemNum = <%s>",
		`i0, RowId[i0].osnum, RowId[i0].objid, TblId[i0].osnum, TblId[i0].objid, UnCnctdFlag [i0], ItemNum[i0]` );

    if ( TblId[i0].osnum == TableId.osnum && TblId[i0].objid == TableId.objid )
    {
      *TblRowId = RowId[i0];
      strcpy ( ItemNumber, ItemNum[i0] );
      success_found = TRUE;
      break;
    }
  }
  *NbFound = success_found;

  __exitFunction ( name = "VDGetRowIdItemNum_FromObjId_TableId" );

  _FREE ( RowId );
  _FREE ( TblId );
  _FREE ( UnCnctdFlag );

  for ( i0=0; i0 < indx; i0++ )
  {
    _FREE ( (ItemNum)[i0]);
    _FREE ( (TblNam )[i0]);
    _FREE ( (PthNam )[i0]);
  }

  _FREE ( ItemNum );
  _FREE ( TblNam );
  _FREE ( PthNam );

  return status;
}

/*+fe
 -------------------------------------------------------------------------
  Function VDGetVDdrw2dObject_FrmModelObj

  Macro Name
        None

  Abstract
        Function to retrieve all the VDdrw2d objects from a given 
        model object.

  Arguments

        IGRlong           *msg          O       return code
        int               *TotNbDrw2d   O       Flag indicating found
                                                (should be 0 or > 0)
        struct GRid       ModelId       I       Id of the Model object

Note:    FOLLOWING ARGUMENT HAS TO BE FREED BY CALLING FUNCTION !!!

        struct GRobj_env  **TotDrw2d    O       List of VDdrw2d objects 

  Notes/Remarks

  Returns
        OM_S_SUCCESS    = if success
        OM_E_ABORT      = if error
 -------------------------------------------------------------------------
-fe*/

int VDGetVDdrw2dObject_FrmModelObj
(
  IGRlong                 *msg,
  int                     *TotNbDrw2d,
  struct GRid             ModelId,
  struct GRobj_env        **TotDrw2d
)
{
  IGRboolean             VDComp_class = TRUE;
  IGRlong                loc1_msg = 0;
  int                    i0, j0, k0,
                         have_pretends = 0,
                         status = OM_S_SUCCESS;
  int                    TotNbDrw3d= 0,
                         NbDrw3d = 0,
                         NbDrw2d = 0,
                         NbPrtnd  = 0;
  OM_S_CHANSELECT        to_child, to_prtnd;
  struct GRid            *TotDrw3d= NULL,
                         *Drw3d   = NULL,
                         *Drw2d   = NULL,
                         modObj,
                         *Prtnd    = NULL;
  struct GRid            srcObj[2],
                         ownId = NULL_GRID,
                         ctxId = NULL_GRID;
  struct GRmd_env        modEnv;
  OMuword                os = 0;
  GRclassid              classid;


  SetProc( VDGetVDdrw2dObject_FrmModelObj ); Begin

  *msg         = MSSUCC;
  srcObj[0]    = NULL_GRID;
  srcObj[1]    = NULL_GRID;
  *TotDrw2d    = NULL;
  *TotNbDrw2d  = 0;

  /*
  ** Retrieve the owner object ID
  */
  __DBGpr_obj( "ModelId", ModelId );
  ASget_as_owner( &ModelId, &ownId );
  if(  ownId.objid == NULL_OBJID ) goto wrapup;
  ModelId = ownId;
  __DBGpr_obj( "ModelId", ModelId );

  /*
  ** Prepare channel_selectors
  */

  status = om$make_chanselect( channame        = "NDchildren.children",
                               p_chanselect    = &to_child );
  __CheckRC( status, 1, "om$make_chanselect", wrapup );

  status = om$make_chanselect( channame        = "GRnotify.notification",
                               p_chanselect    = &to_prtnd );
  __CheckRC( status, 1, "om$make_chanselect", wrapup );

  /*
  ** Special case to handle VRCorrection/VRComponent objects properly
  */

  VDComp_class = TRUE;
  status = om$get_classid( classname = "VRComponent",
                           p_classid = &classid );
  if( !(status&1) ) VDComp_class = FALSE;

  loc1_msg = ( VDComp_class && DMancestry_valid(ModelId, classid) );

  if( loc1_msg&OM_S_SUCCESS )
  {
    /*
    ** Get current osnum
    */

    status = ex$get_cur_mod( osnum = &os );

    /*
    ** Get the context object for as$make_source
    */

    if( ModelId.osnum == os )
    {
      ctxId = NULL_GRID;
    }
    else
    {
      status = GRfindcontext( msg, NULL, NULL, &ModelId.osnum, &ctxId );

      if( !(status&1) )
      {
        __DBGpr_com( "Context not found" );
        ctxId = NULL_GRID;
      }
    }

    __DBGpr_obj( "ctxId", ctxId );

    status = as$make_source( go_grid         = ModelId,
                             context_grid    = ctxId,
                             as_os           = ModelId.osnum,
                             as_grid         = &srcObj[0] );
    
    if( status&1 )
    {
      /*
      ** Replace ModelId (VRComponent) by srcObj[0] (ACpretendin)
      */
      __DBGpr_obj( "srcObj[0]", srcObj[0] );

      have_pretends++;
    }

    status = as$make_source( go_grid = ModelId,
                             as_os   = ModelId.osnum,
                             as_grid = &srcObj[1] );

    if( (status&1) && (srcObj[0].objid != srcObj[1].objid) )
    {
      /*
      ** Replace ModelId (VRComponent) by srcObj[1] (ACpretendin)
      */
      __DBGpr_obj( "srcObj[1]", srcObj[1] );

      have_pretends++;
    }

    if( have_pretends )
    {
      NbPrtnd = have_pretends;

      Prtnd = _MALLOC( NbPrtnd, struct GRid );

      if( Prtnd )
      {
        memcpy( Prtnd, srcObj, have_pretends * sizeof ( struct GRid ) );
      }
    }
  }

  if( have_pretends == FALSE )
  {
    __prints ( "GetGrids: OPP_ACpretendin_class_id " );
    status = VDGetGridsFromChan_of_Class( msg, 
                                          ModelId, 
                                          &to_prtnd,
                                          OPP_ACpretendin_class_id,
                                          &NbPrtnd, 
                                          &Prtnd );
    __CheckRC( status, 1, "VDGetGridsFromChan_of_Class", wrapup );

    __DBGpr_int( "No. of ACpretendin", NbPrtnd );
  }
  __DBGpr_int( "NbPrtnd", NbPrtnd );

  for( i0 = 0; i0 < NbPrtnd; i0++)
  {
    __prints ( "GetGrids: OPP_VDdrw3d_class_id " );
    status = VDGetGridsFromChan_of_Class( msg, 
                                          Prtnd[i0],
                                          &to_child,
                                          OPP_VDdrw3d_class_id,
                                          &NbDrw3d,
                                          &Drw3d );
    __CheckRC( status, 1, "VDGetGridsFromChan_of_Class", wrapup );
    __DBGpr_int( "NbDrw3d", NbDrw3d );

    if( NbDrw3d > 0 )
    {
      if( TotDrw3d == NULL )
      {
        TotDrw3d = _MALLOC( (TotNbDrw3d+NbDrw3d), struct GRid );
      }
      else
      {
        TotDrw3d = _REALLOC( TotDrw3d, (TotNbDrw3d+NbDrw3d), struct GRid );
      }

      if( TotDrw3d == 0 )
      {
        goto wrapup;
      }

      memcpy( &TotDrw3d[TotNbDrw3d], Drw3d, sizeof(struct GRid)*NbDrw3d );

      TotNbDrw3d += NbDrw3d;

      NbDrw3d = 0;
      _FREE( Drw3d );

    }
  }
  _FREE( Prtnd );
  Prtnd   = NULL;
  NbPrtnd = 0;

  for( j0 = 0; j0 < TotNbDrw3d; j0++)
  {
    __prints ( "GetGrids: OPP_ACpretendin_class_id " );
    status = VDGetGridsFromChan_of_Class( msg,
                                          TotDrw3d[j0],
                                          &to_prtnd,
                                          OPP_ACpretendin_class_id,
                                          &NbPrtnd,
                                          &Prtnd );
    __CheckRC( status, 1, "VDGetGridsFromChan_of_Class", wrapup );
    __DBGpr_int( "NbPrtnd", NbPrtnd );
 
    for( i0 = 0; i0 < NbPrtnd; i0++)
    {
      __prints ( "GetGrids: OPP_VDdrw2d_class_id " );
      status = VDGetGridsFromChan_of_Class( msg, 
                                            Prtnd[i0],
                                            &to_child,
                                            OPP_VDdrw2d_class_id,
                                            &NbDrw2d,
                                            &Drw2d );
      __CheckRC( status, 1, "VDGetGridsFromChan_of_Class", wrapup );
      __DBGpr_int( "NbDrw2d", NbDrw2d );

      if( NbDrw2d > 0 )
      {
        if( *TotDrw2d == NULL )
        {
          *TotDrw2d = _MALLOC( (*TotNbDrw2d+NbDrw2d), struct GRobj_env );
        }
        else
        {
          *TotDrw2d = _REALLOC( *TotDrw2d, 
				(*TotNbDrw2d+NbDrw2d), 
				struct GRobj_env );
        }

        if( *TotDrw2d == NULL )
        {
          goto wrapup;
        }
      }
 
      for( k0 = 0; k0 < NbDrw2d; k0++)
      {
        status =
        om$send( msg = message NDmacro.ACreturn_foot(
					    msg,
                                            "",
                                            &modObj,
                                            &modEnv.md_env.matrix_type,
                                            modEnv.md_env.matrix),
                 senderid = NULL_OBJID,
                 targetid = Drw2d[k0].objid,
                 targetos = Drw2d[k0].osnum ) ;
        __CheckRC( status, *msg, "NDmacro.ACreturn_foot", wrapup );
       
        modEnv._MD_OS = modObj.osnum;
        status = ex$get_modid( mod_osnum = modEnv._MD_OS,
                               mod_id    = &modEnv._MD_ID );
        
        (*TotDrw2d)[*TotNbDrw2d].mod_env = modEnv;
        (*TotDrw2d)[*TotNbDrw2d].obj_id  = modObj;
        *TotNbDrw2d += 1;
      }
      NbDrw2d = 0;
      _FREE( Drw2d );
      Drw2d = NULL;
    }
    NbPrtnd = 0;
    _FREE( Prtnd );
    Prtnd   = NULL;
  }
 

  _FREE ( Drw3d );
  _FREE ( Drw2d );
  _FREE ( TotDrw3d );
  _FREE ( Prtnd );

  End
  return status;

wrapup :

  status      = OM_E_ABORT;
  *msg        = MSFAIL;
  *TotNbDrw2d = 0;

  _FREE ( Drw3d );
  _FREE ( Drw2d );
  _FREE ( TotDrw3d );
  _FREE ( Prtnd );

  End
  return status;
}

end implementation Root;
