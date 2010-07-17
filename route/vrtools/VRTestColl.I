/* $Id: VRTestColl.I,v 1.2 2002/04/10 20:44:52 louis Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:        vrtools / VRTestColl.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VRTestColl.I,v $
 *      Revision 1.2  2002/04/10 20:44:52  louis
 *      TR5649-Standardize tolerance
 *
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *      04/08/02   law          TR5649-standardize tolerance with VRGetTol
 *************************************************************************/
class implementation Root;

#include <math.h>
#include "OMminimum.h"
#include "OMerrordef.h"
#include "msdef.h"
#include "nddef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "VRutildef.h"
#include "VRattr_def.h"
#include "VRMath.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "AS_status.h"

#define AS_DEBUG

from	ACrg_collect	import	AClist_attribute;

/********************************************************************************************/
/*
/*	This function test if two collection are identical 
/*
/**/

VRTestColl( p_msg, p_FirstCollectionId, p_SecondCollectionId, Result )

IGRlong				*p_msg;              	/* return code            	*/
struct		GRid		*p_FirstCollectionId;	/* given collection GRid 	*/
struct		GRid		*p_SecondCollectionId;	/* output collection GRid 	*/
IGRboolean			*Result;

/*.VRTestColl*/
{
  IGRint			FstNb, SecNb, NbAttr, i, j;
  IGRlong			status=OM_S_SUCCESS, retcode=MSSUCC;
  struct	ACrg_coll	p_FstList[VR_MAX_ATTR], p_SecList[VR_MAX_ATTR];
  IGRboolean			p_Result[VR_MAX_ATTR];

  *p_msg    = MSSUCC;
  *Result   = TRUE;

  if( !p_FirstCollectionId || !p_SecondCollectionId )  return OM_E_INVARG;

  /*" FirstCollectionId  = %d %d \n", p_FirstCollectionId->objid, p_FirstCollectionId->osnum*/ 
  /*" SecondCollectionId = %d %d \n", p_SecondCollectionId->objid, p_SecondCollectionId->osnum*/
 
  /*| ----- List the two collection to have their attributes  ----- */
  status = om$send( msg      = message ACrg_collect.AClist_attribute
                               		( &retcode, VR_MAX_ATTR, p_FstList, &FstNb ),
                    senderid = NULL_OBJID,
                    targetid = p_FirstCollectionId->objid,
                    targetos = p_FirstCollectionId->osnum );
  as$status();

  status = om$send( msg      = message ACrg_collect.AClist_attribute
                               		( &retcode, VR_MAX_ATTR, p_SecList, &SecNb ),
                    senderid = NULL_OBJID,
                    targetid = p_SecondCollectionId->objid,
                    targetos = p_SecondCollectionId->osnum );
  as$status(  );
  /*" FstNb = %d SecNb = %d \n",FstNb, SecNb*/

  /*| ----- If their number of attributes are different they are not identical ----- */
  if ( FstNb != SecNb )
  {
	/*| Collections are different */
	*Result = FALSE;
	return OM_S_SUCCESS;
  }
  else NbAttr = FstNb;

  for ( i=0; i<NbAttr; i++ )
  {
	p_Result[i] = FALSE;
	for ( j=0; j<NbAttr; j++ )
	{
		if( ( !strcmp( p_FstList[i].name, p_SecList[i].name )) &&
		    ( p_FstList[i].desc.type == p_SecList[i].desc.type) )
		{
			if (( p_FstList[i].desc.type == AC_ATTRIB_DOUBLE ) &&
			    /*BILLA  Double value comparison problem */
			    (fabs( p_FstList[i].desc.value.att_exp - p_SecList[i].desc.value.att_exp ) < VRGetTol(VR_DEFAULT_TOL) ) )
				p_Result[i] = TRUE;

			if (( p_FstList[i].desc.type == AC_ATTRIB_TEXT ) &&
			    ( !strcmp( p_FstList[i].desc.value.att_txt, p_SecList[i].desc.value.att_txt )))
				p_Result[i] = TRUE;
		       
		}
	}
  }

  for ( i=0; i<NbAttr; i++ )
  {
	if (  p_Result[i] == FALSE )	*Result = FALSE;
  }

  /*"Result = %d \n",*Result*/

  return OM_S_SUCCESS;
}

end implementation Root;
