/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vdannot/func/VDgetItemNo.I
 *
 * Description:
 *	Implementation of function for the macro vd$getItemNoForObj
 *
 * Dependencies:
 *
 * Revision History:
 *
 * History:
 *      12/12/94	R. Manem	Creation
 *	12/13/94	R. Manem	Fixed bug in itemPfx reference :
 *					Check for itemPfx = NULL before
 *					checking and freeing *itemPfx
 *	12/29/94	R. Manem	Simplified getting source object
 *					by using GRfindcontext and
 *					as$make_source.
 *	06/15/95	tlb		MOdified for new VDitem, VDitemMgr
 *
 * -------------------------------------------------------------------*/

class implementation Root;

#include "igrtypedef.h"
#include "OMerrordef.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "gr.h"
#include "exmacros.h"
#include "asmacros.h"
#include "AS_status.h"
#include "asbox.h"
#include "bs.h"
#include "v_miscmacros.h"

#define VD_DEBUG

#include "VDdebug.h"

#define	TRUE	1
#define	FALSE	0

from VDitem		import	VDgetItemInfo;

extern GRclassid	OPP_VDitem_class_id,
			OPP_VDdrw2d_class_id,
			OPP_VDdrwSet_class_id,
			OPP_VDdrwTblRow_class_id,
			OPP_ACpretend_class_id,
			OPP_ACpretendin_class_id,
			OPP_NDnodein_class_id;

IGRlong VDgetItemNoForObj
(
  struct GRid		  obj,
  IGRchar		 *tblName,
  struct GRid		 *itemId,
  IGRchar		**itemNo,
  IGRboolean		 *found
)
{
  IGRint		 i, j, indx = 0;
  IGRchar		*curTblName = NULL;
  IGRlong		 msg = 1;
  struct GRid		 object,
			 srcObj,
			 ctxId;
  OMuword		 os;

  IGRlong		 status = OM_S_SUCCESS;

  int			 NbPrtnd   = 0, NbDrwSet   = 0, NbTblRow = 0;

  OM_S_CHANSELECT	 to_prtnd;
  struct GRid		*Prtnd	  = NULL,
			*TblRow	  = NULL,
			*DrwSet	  = NULL;

  __enterFunction ( name = "VDgetItemNoForObj" );

  /*
   * Prepare channel_selector
   */

  status = om$make_chanselect ( channame	= "GRnotify.notification",
				p_chanselect	= &to_prtnd );
  as$status( action = GOTO_VALUE, value = wrapup );

  *found = FALSE;

  if( itemId )
  {
    itemId->objid = NULL_OBJID;
  }

  __printf ( "Object = [%d,%d]", `obj.osnum, obj.objid` );

  /* get current osnum */

  status = ex$get_cur_mod( osnum    = &os );

  /* get the context object for as$make_source */

  if( obj.osnum == os )
  {
    ctxId = NULL_GRID;
  }
  else
  {
    status = GRfindcontext( &msg, NULL, NULL, &obj.osnum, &ctxId );

    if( !(status & 1) )
    {
      __prints ( "Context not found" );
      ctxId = NULL_GRID;
    }
  }

  __printf ( "ctxId = [%d,%d]", `ctxId.osnum, ctxId.objid` );

  status = as$make_source (	go_grid		= obj,
				context_grid	= ctxId,
				as_os		= obj.osnum,
				as_grid		= &srcObj );
  as$status();

  __printf ( "Source object [%d,%d] ==>> [%d,%d]", `obj.osnum, obj.objid, srcObj.osnum, srcObj.objid` );

  /* for each child, check if VDgetItemInfo works */

  /*
   * Get All NDnodein (ACpretendin & ASsourcein) objects from the notification channel
   * If NbPrtnd != 0, then we have to check each one for VDitem ...
   */

  if ( DMancestry_valid ( obj, OPP_VDdrw2d_class_id ) & 1 )
  {
    status = VDGetGridsFromChan_of_Class ( &msg, obj, &ND_father, -OPP_NDnodein_class_id, &NbPrtnd, &Prtnd );

    __printf ( ">>>>>>>>>> VDdrw2d : <%d> NDnodein on ND_father channel", NbPrtnd );
  }
  else if ( DMancestry_valid ( obj, OPP_ACpretend_class_id ) & 1 )
  {
    status = VDGetGridsFromChan_of_Class ( &msg, obj, &ND_children, OPP_VDdrwSet_class_id, &NbDrwSet, &DrwSet );

    __printf ( ">>>>>>>>>> ACpretend : <%d> VDdrwSet on ND_children channel", NbDrwSet );

    indx = 0;

    for( i = 0 ; i < NbDrwSet ; i++ )
    {
      NbTblRow = 0;

      status = VDGetGridsFromChan_of_Class ( &msg, DrwSet[i], &ND_children, OPP_VDdrwTblRow_class_id, &NbTblRow, &TblRow );

      NbPrtnd += NbTblRow;

      if ( Prtnd == NULL )
      {
	Prtnd = _MALLOC ( NbPrtnd, struct GRid );
      }
      else
      {
	Prtnd = _REALLOC ( Prtnd, NbPrtnd, struct GRid );
      }

      __printf ( ">>>>>>>>>> <%d> VDdrwTblRow on ND_children channel of DrwSet[%d] = [%d,%d]",
		`NbTblRow, i, DrwSet[i].osnum, DrwSet[i].objid` );

      for( j = 0 ; j < NbTblRow ; j++ )
      {
	obj = TblRow[j];
	status = as$make_source(go_grid		= obj,
				context_grid	= ctxId,
				as_os		= obj.osnum,
				as_grid		= &srcObj );
	as$status();

	Prtnd [indx++] = srcObj;

	__printf ( "TblRow[%d] = [%d,%d] ==>> Prtnd[%d] = [%d,%d]",
		`j, obj.osnum, obj.objid, indx-1, srcObj.osnum, srcObj.objid` );
      }
      _FREE ( TblRow );
    }
  }
  else
  {
    status = VDGetGridsFromChan_of_Class ( &msg, obj, &to_prtnd, -OPP_NDnodein_class_id, &NbPrtnd, &Prtnd );

    __printf ( ">>>>>>>>>> Else : <%d> NDnodein on notification channel", NbPrtnd );
  }

  __printf ( "status = %d, msg = %d, NbPrtnd = %d", `status, msg, NbPrtnd` );

  for( i = 0 ; i < MAX ( 1, NbPrtnd ) ; i++ )
  {
    if ( NbPrtnd )
    {
      __printf ( "Prtnd[%d] = [%d,%d]", `i, Prtnd[i].osnum, Prtnd[i].objid` );

      srcObj = Prtnd[i];
    }

    for( j = 0 ; j < OM_K_MAXINT ; j++ )
    {
      status = om$get_objid_at_index( objid	= srcObj.objid,
				      osnum	= srcObj.osnum,
				      index	= j,
				      p_chanselect = &ND_children,
				      objidaddr    = &object.objid,
				      osnumaddr    = &object.osnum);
      if( !(status & 1) )
      {
	break;
      }

      __printf ( ">>>>>Object[%d] = [%d,%d]", `j, object.osnum, object.objid` );

      if ( ! (DMancestry_valid( object, OPP_VDitem_class_id) & 1 ) ) continue;

      _FREE ( curTblName );

      status = om$send (   msg      = message VDitem.VDgetItemInfo( &msg,
								  itemNo,
								 &curTblName ),
			   senderid = NULL_OBJID,
			   targetid = object.objid,
			   targetos = object.osnum);
      if( (status & msg & 1) )
      {
	/* item object found */

	__printf ( "Item object found [%d,%d], itemNo = <%s>", `object.osnum, object.objid, *itemNo` );
	__printf ( "tblName = <%s>, curTblName = <%s>", `tblName, curTblName` );

	/* check if table name matches */

	if( !strcmp( tblName, curTblName ) )
	{
	  __prints ( "Item object found and table name matches");

	  if( itemId )
	  {
	    *itemId = object;
	  }

	  *found =  TRUE;

	  goto wrapup;
	}
	else
	{
	  _FREE ( *itemNo );
	}
      }
    }
  }

  status = OM_S_SUCCESS;

wrapup :

  _FREE ( Prtnd  );
  _FREE ( DrwSet  );
  _FREE ( curTblName );

  __exitFunction ( name = "VDgetItemNoForObj" );

  return status;
}

end implementation Root;
