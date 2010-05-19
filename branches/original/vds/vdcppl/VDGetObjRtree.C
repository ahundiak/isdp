/* $Id: VDGetObjRtree.C,v 1.1 2001/09/19 15:49:51 hans Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdcppl / VDGetObjRtree.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDGetObjRtree.C,v $
 *	Revision 1.1  2001/09/19 15:49:51  hans
 *	Tool to fix TR# MP5556
 *	
 *
 * History:
 *	MM/DD/YYYY	AUTHOR		DESCRIPTION
 *      09/19/2001      HF              Creation Date
 *                                      Tool to fix TR# MP5556
 * -------------------------------------------------------------------*/

#include <stdio.h>
#include <values.h>

#include <OMminimum.h>
#include <OMerrordef.h>
#include <OMtypes.h>
#include <OMindex.h>
#include <OMlimits.h>
#include <OMspecify.h>
#include <OMrelation.h>
#include <OMextern.h>
#include <OMprimindex.h>
#include <OMprimitives.h>

#include "cieveryone.h"
#include "VDmem.h"

#define	VD_DEBUG
#include	<VDdebug.h>

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * This function retrieves objects of ClassId (or all, if ClassId==0),
 * from the Rtree, that are within the specified range...
 *
 * pp_ObjArray is _MALLOC'ed and MUST be _FREE'd by the calling function !!!
 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

int VDGetObjectsFromRtree ( GRclassid ClassId, struct OM_sd_objarray ** pp_ObjArray, GRrange extend )
{
  DB_3D_DBL_BOX         Fence;

  char                  classname[256];
  IGRint                ret, ret_bis, i, size = 0, Size = 0, ObjCount = 0;
  IGRlong               sts;
  GRclassid             ObjClassId;
  OM_S_CHANSELECT       chan;
  OM_S_MESSAGE          p_msg;
  OM_S_KEY_DESC         rtree_key_test;
  OM_S_OBJID           *arr;

  struct GRid           ModuleGrid;

  struct arglist
  {
    struct OM_sd_objarray       *Array;
    OM_S_KEY_DESC               *rtree_key;
    IGRchar                      null0;
    IGRint                       null1;
    IGRint                      *ret;
  } my_arglist;

  __enterFunction ( name = "VDGetObjectsFromRtree", argfmt = "ClassId = %d", args = `ClassId` );

  GRfindmod (&ModuleGrid);

  Fence.xmin = extend[0];
  Fence.ymin = extend[1];
  Fence.zmin = extend[2];
  Fence.xmax = extend[3];
  Fence.ymax = extend[4];
  Fence.zmax = extend[5];

  sts = om$make_chanselect (channame     = "module.primary",
                            p_chanselect = &chan);
  if(sts! = OM_S_SUCCESS)
  {
    om$report_error(sts = sts);
    goto wrapup;
  }

  size = sizeof( my_arglist );
  Size = sizeof( OM_S_OBJARRAY );

  *pp_ObjArray = _MALLOC( Size, OM_S_OBJARRAY );
  if( *pp_ObjArray == 0 )
  {
    sts = OM_E_NODYNMEM;
    goto wrapup;
  }

  __printf ( "Size = %d, size = %d", `Size, size` );

  (*pp_ObjArray)->size       = Size;
  (*pp_ObjArray)->count      = 0;
  (*pp_ObjArray)->tree_type  = KEY_3D_DBL;
  rtree_key_test.type        = KEY_3D_DBL;
  rtree_key_test.key.p_3ddbl = (DB_3D_DBL_BOX *)&Fence;

  sts = om$make_message (classname  = "OMrtree",
                         methodname = "translate",
                         size       = size,
                         p_arglist  = &my_arglist,
                         p_msg      = &p_msg);

  my_arglist.Array     = (struct OM_sd_objarray *) (*pp_ObjArray);
  my_arglist.rtree_key = &rtree_key_test;
  my_arglist.null0     = 0;
  my_arglist.null1     = 0;
  my_arglist.ret       = &ret_bis;

  if(sts! = OM_S_SUCCESS)
  {
    om$report_error(sts = sts);
    goto wrapup;
  }

//    printf ( "p_msg.select.DefClassid = %d\n",p_msg.select.DefClassid );
//    printf ( "p_msg.select.ReqClassid = %d\n",p_msg.select.ReqClassid );
//    printf ( "p_msg.select.FuncIndex  = %d\n",p_msg.select.FuncIndex );
//    printf ( "p_msg.size = %d\n",p_msg.size);

  sts = om$send (msg          = &p_msg,
                 senderid     = ModuleGrid.objid,
                 targetos     = ModuleGrid.osnum,
                 p_chanselect = &chan);

  if(sts! = OM_S_SUCCESS)
  {
    om$report_error(sts = sts);
    goto wrapup;
  }

  Size = (sizeof(OM_S_OBJID) * (*pp_ObjArray)->count) + sizeof(OM_S_OBJARRAY);
  _FREE (*pp_ObjArray);

  *pp_ObjArray = _MALLOC( Size, OM_S_OBJARRAY );
  if( *pp_ObjArray == 0 )
  {
    sts = OM_E_NODYNMEM;
    goto wrapup;
  }

  (*pp_ObjArray)->size       = Size;
  (*pp_ObjArray)->count      = 0;
  (*pp_ObjArray)->tree_type  = KEY_3D_DBL;

  my_arglist.Array     = (struct OM_sd_objarray *) (*pp_ObjArray);
  my_arglist.rtree_key = &rtree_key_test;
  my_arglist.null0     = 0;
  my_arglist.null1     = 0;
  my_arglist.ret       = &ret_bis;

  sts = om$send (msg          = &p_msg,
                 senderid     = ModuleGrid.objid,
                 targetos     = ModuleGrid.osnum,
                 p_chanselect = &chan);

  if(sts! = OM_S_SUCCESS)
  {
    om$report_error(sts = sts);
    goto wrapup;
  }

  ObjCount = 0;

  arr = (*pp_ObjArray)->array;

  for(i=0; i < (*pp_ObjArray)->count; i++)
  {
    om$get_classid (objid       = arr[i],
                    osnum       = ModuleGrid.osnum,
                    p_classid   = &ObjClassId);

    om$get_classname (objid     = arr[i],
                      osnum     = ModuleGrid.osnum,
                      classname = classname);

    if (ClassId == 0)
    {
      arr[ObjCount] = arr[i];

      __printf ( "arr[%i] = %6d, ClassId = %4d, classname = <%s>",
                 `i, arr[ObjCount], ObjClassId, classname`);
      ObjCount++;
    }
    else
    {
      if (om$is_ancestry_valid (subclassid   = ObjClassId,
                                superclassid = ClassId) == OM_S_SUCCESS)
      {
        arr[ObjCount] = arr[i];

        __printf ( "arr[%i] = %6d, ClassId = %4d, classname = <%s>",
                   `i, arr[ObjCount], ObjClassId, classname`);
        ObjCount++;
      }
    }
  }
  (*pp_ObjArray)->count = ObjCount;

wrapup:

  __exitFunction ( name = "VDGetObjectsFromRtree", argfmt = "sts = %d, ClassId = %d, ObjCount = %d",
                   args = `sts, ClassId, ObjCount` );

  return (sts);
}
