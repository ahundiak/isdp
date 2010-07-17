/* $Id: VRGetAttrib.I,v 1.2 2001/02/20 01:17:47 build Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrtools / VRGetAttrib.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRGetAttrib.I,v $
 *	Revision 1.2  2001/02/20 01:17:47  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.1.1.1  2001/01/04 21:13:11  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/09/08  00:28:26  pinnacle
# Created: vrtools/VRGetAttrib.I by kddinov for route
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *
 *************************************************************************/
class implementation Root;

#include <stdio.h>
 
#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMprimitives.h"
#include "msdef.h"
#include "nddef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "AS_status.h"
#include "ACrg_collect.h"

#include "vrdbgmacros.h"

from	ACrg_collect	import	ACget_named_attribute;

/*******************************************************************************
*  Gets Attribute List from Collection Object of Collection List.
*
*-------------------------------------------------------------------------------
*  Attribute       :I   *(struct ACrg_coll) - Pointer to the Collection to load.
*                                       The caller must provide space.
*
*  NumAttrToModify :I  int               - Number of Attributes to get.
*
*  CollectionId    :I  *(struct GRid)   - Pointer to Collection Object
*
*  CollectionList  :I  *(struct ACrg_coll) - Pointer to source Collection List.
*
*  NumAttrInCollList :I  int               - Number of Attributes in CollList.
*******************************************************************************/
int VRGetAttribute(     Attribute,
                        NumAttrToModify,
                        CollectionId,
                        CollectionList,
                        NumAttrInCollList)
 
struct ACrg_coll        *Attribute;
int                     NumAttrToModify;
struct GRid             *CollectionId;
struct ACrg_coll        *CollectionList;
int                     NumAttrInCollList;

{
  int           sts, i, j ;
  long		retcode; 

  if ( (CollectionId == NULL) && (CollectionList == NULL) ) 
			{ sts = 0; goto wrapup; } 

  sts = 1; 

/*-------------------
*  Load from Collection Object 
---------------------*/
  if ( CollectionId != NULL ) {
     for ( i = 0; i < NumAttrToModify; i= i+ 1) {
         sts = om$send( msg   = message ACrg_collect.ACget_named_attribute
                                               ( &retcode, &Attribute[i] ),
		     senderid = NULL_OBJID,
                     targetid = CollectionId->objid,
                     targetos = CollectionId->osnum );
     }
     goto wrapup;
  }      

/*----------------
*  Load from Collection List 
------------------*/
  for ( i = 0; i < NumAttrToModify  ; i= i+ 1) 
  for ( j = 0; j < NumAttrInCollList; j = j + 1 ) {
        if ( !strcmp( Attribute [ i ].name, CollectionList [ j ].name) ) {
                Attribute [ i ] = CollectionList [ j ] ;
                break;
        }
  }

wrapup:
return sts;
}

end implementation Root;
