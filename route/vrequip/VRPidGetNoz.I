/* $Id: VRPidGetNoz.I,v 1.2 2001/02/20 01:13:43 build Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	route/vrequip / VRPidGetNoz.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VRPidGetNoz.I,v $
 *      Revision 1.2  2001/02/20 01:13:43  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.1.1.1  2001/01/04 21:12:51  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/10/20  15:33:00  pinnacle
# Replaced: vrequip/VRPidGetNoz.I for:  by kddinov for route
#
# Revision 1.3  1997/09/17  20:42:44  pinnacle
# Replaced: vrequip/VRPidGetNoz.I for:  by kddinov for route
#
# Revision 1.2  1997/09/12  23:26:32  pinnacle
# Replaced: vrequip/VRPidGetNoz.I for:  by kddinov for route
#
# Revision 1.1  1997/09/11  17:19:02  pinnacle
# Created: vrequip/VRPidGetNoz.I by kddinov for route
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	Sept 97		kdd	VRPidEqp_GetNozzles
 *
 *************************************************************************/
class implementation Root;
 
/*
#define vdsDEBUG        1
*/
 
 
#include <stdio.h>
 
#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMprimitives.h"
#include "msdef.h"
#include "nddef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "VRutildef.h"
#include "VRattr_def.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "AS_status.h"
#include "vrdbgmacros.h"
#include "VDmem.h"

#include "VRutildef.h"
#include "VRchannel.h"

from NDnode	import 	ASreturn_go;
from NDmacro	import 	ACreturn_foot;
from ACcpx	import 	find_macro;
from ACcpx_defn	import 	ACgive_feet_desc;


/*******************************************************************************
* KDD Aug 1997
*  Gets VRNozHold feet and corresponding VRNozzle children of Pid Equipment.
*     One to one correspondence between VRNozHold components & VRNozz children.
*     consult with VREquipOver.I: VRPlaceNozzleFeet
*-------------------------------------------------------------------------------
*
* I: EquipId	struct GRid	- Pid Equipment object ID.
*
* O: NumFeet	*int		- number of feet found,
*
* O: Feet[]     *(struct myfeet)- list of feet description. VRNozHold only.  
*				  I allocate memory, the caller must free it. 
*
* O: NumChild	*int		- number of children.
*
* O: Child[]  	*(struct GRid)	- list of children ACpretend IDs. 
*				  The actual VRNozzle are children of ACpretend.
*				  I allocate memory, the caller must free it. 
*
* I: md_env     *(struct GRmd_env) - Module environment as returned from locate.
*-------------------------------------------------------------------------------
*
* RETURN status:
*
* 1     - OK
* even  - problems
*******************************************************************************/

int VRPidEqp_GetNozzles( 	   struct GRid		EquipId,
				   int			*p_NumFeet,
				   struct myfeet	**Feet,
				   int			*p_NumChild,
				   struct GRid		**Child,
				   struct GRmd_env      *md_env)
{
   struct GRid		GraphicsId, MacDefId, FootId,
			*ACpretend = NULL,
			*VRNozzle  = NULL,
			*p_Child   = NULL;

   struct myfeet	*FeetDesc = NULL,
			*p_Feet   = NULL;

   char			ClassName[64]={""};

   IGRlong		sts = 1, retcode;

   int			i, j, count, 
			NumFeet = 0, NumChild = 0, NumVRNozzle = 0,
			NumACpretend = 0; 

SetProc(VRPidEqp_GetNozzles); Begin

   GraphicsId.objid = NULL_OBJID;
   MacDefId.objid   = NULL_OBJID;
   FootId.objid     = NULL_OBJID;

/*-------------------------
# Initialize 
-------------------------*/
   if ( EquipId.objid == NULL_OBJID ) { goto wrapup; } 

__DBGpr_obj("Equipment ID                ", EquipId); 

/*-------------------------
#  Get feet
-------------------------*/
   sts = om$send( msg     = message NDnode.ASreturn_go( &GraphicsId, NULL,NULL),
		 senderid = NULL_OBJID,
                 targetid = EquipId.objid,
		 targetos = EquipId.osnum);
   as$status(sts = sts, action = GOTO_VALUE, value = wrapup);
 
    sts = om$send(  msg   = message ACcpx.find_macro (&MacDefId),
		 senderid = NULL_OBJID,
                 targetid = GraphicsId.objid,
                 targetos = GraphicsId.osnum);
    as$status(sts = sts, action = GOTO_VALUE, value = wrapup);
 
 
    sts = om$send( msg      = message ACcpx_defn. ACgive_feet_desc
                                        ( &count, &FeetDesc ),
		   senderid = NULL_OBJID,
                   targetid = MacDefId.objid,
                   targetos = MacDefId.osnum );
    if ( !(sts&1) ) count = 0; 
 
    NumFeet = 0;
    for (i=0; i < count; i++ ) {
        sts = om$send ( msg = message NDmacro.ACreturn_foot
                               (&retcode, FeetDesc[i].name, &FootId,NULL, NULL),
		   senderid = NULL_OBJID,
                   targetid = GraphicsId.objid,
                   targetos = GraphicsId.osnum);
	as$status(sts = sts);
        if ( !(sts & 1) || !(retcode & 1) ) continue;
 
        om$get_classname( objid           = FootId.objid,
                          osnum           = FootId.osnum,
                          classname       = ClassName);

        if ( !strcmp( ClassName, "VRNozHold") ) {
	      if ( NumFeet == 0 ) p_Feet = _MALLOC( 1, struct myfeet); 
	      else          p_Feet = _REALLOC(p_Feet, NumFeet+1, struct myfeet);

              p_Feet [ NumFeet ] = FeetDesc[i];
__DBGpr_str("Feet VRNozHold               ", p_Feet [ NumFeet ].name); 
	      NumFeet++; 
        }
    }
 
/*-------------------------
#  Get children ancestry of VRNozzle. 
-------------------------*/
    sts = vr$get_channel_objects(  objid            = EquipId.objid,
                                   osnum            = EquipId.osnum,
                                   chan_name        = "children",
                                   filter_class     = "ACpretend,ACpretendin",
                                   operation        = VR_INCLUDE,
                                   count            = &NumACpretend,
                                   object_list      = &ACpretend);

    if ( !(sts & 1) ) NumACpretend = 0; 

    NumChild = 0; 

    for ( i = 0; i < NumACpretend; i++) {
        if ( VRNozzle ) { _FREE( VRNozzle ) ; VRNozzle = NULL;}
	NumVRNozzle = 0;

	sts = vr$get_channel_objects( objid          = ACpretend[i].objid,
				      osnum	     = ACpretend[i].osnum,
                                      chan_name      = "children",
                                      ancestry_class = "VRNozzle",
                                      operation      = VR_INCLUDE,
                                      count          = &NumVRNozzle,
                                      object_list    = &VRNozzle);

	if ( !(sts & 1) || (NumVRNozzle <= 0) ) continue; 

        if ( NumChild == 0 ) p_Child = _MALLOC( 1, struct GRid);
        else            p_Child = _REALLOC( p_Child, NumChild + 1, struct GRid);

	p_Child [ NumChild ] = ACpretend [ i ] ; 
__DBGpr_obj("Child VRNozzle               ", p_Child [ NumChild ] ); 
	NumChild++;
    }

/*-------------------------
#  Wrapup
-------------------------*/
wrapup:

/* NOTE (KDD Sept, 1997): 
*  ACcpx_defn. ACgive_feet_desc doesn't allocate memory, instead returns 
*  pointer to the actual memory location for the feet description. 
*  This is a violation of the Data Encapsulation Principle.
*   if ( FeetDesc ) { _FREE ( FeetDesc ) ; FeetDesc = NULL; } 
*/

   if ( ACpretend) { _FREE ( ACpretend) ; ACpretend= NULL; } 
   if ( VRNozzle ) { _FREE ( VRNozzle ) ; VRNozzle = NULL; } 

   if ( p_NumChild ) *p_NumChild = NumChild;
   if ( p_NumFeet  ) *p_NumFeet  = NumFeet;

   if ( Child ) *Child = p_Child;
   else         { _FREE ( p_Child); p_Child = NULL;} 

   if ( Feet  ) *Feet  = p_Feet;
   else         { _FREE ( p_Feet); p_Feet = NULL;} 

End;
sts = 1;
return ( sts); 
}




end implementation Root;

