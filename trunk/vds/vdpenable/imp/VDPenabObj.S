/* $Id */

/* I/VDS
 *
 * File:        vdpenable/imp/VDPenabObj.S
 *
 * Description: Class for storing PME enabled VDS objects 
 *
 *
 * Dependencies:
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      09/95           MSM           Creation
 */
class specification VDPenabObj (1:0) of VDPRoot;

/*+ca
 Class VDPenabObj

 Superclass
	VDPRoot

   Abstract
	This class maintains the list of all the objects that have 
	been PME enabled. An object of this class is saved with the design
	file.

   Design Reference

   Methods
	VDPinit		Public		Initialises the Object

   Notes/Remarks

-ca*/

#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "OMtypes.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "growner.h"
#include "gr.h"
#include "msdef.h"

instance VDPenabObj
{
   /* List of all the objects that are enabled during a design session */
   variable GRobjid	enabObj[0];
};

/*+me
   Public Message VDPinit

   Abstract
	Initialisation message sent to the object upon creation.

   Algorithm

   Arguments
   Type		Name		I/O	Description

   Notes/Remarks

   Status/return Code
	status == OM_S_SUCCESS
	status == OM_E_xxx
-me*/

message VDPinit( IGRlong *msg );

/*+me
   Public Message VDPEnableObject

   Abstract
	This method adds to the list a PME enabled VDS object.

   Algorithm

   Arguments
   Type		Name		I/O	Description

   Notes/Remarks

   Status/return Code
	status == OM_S_SUCCESS
	status == OM_E_xxx
-me*/

message VDPEnableObject( IGRlong *msg; GRobjid VDSobjid);

/*+me
   Public Message VDPDisableObject( IGRlong *msg; GRobjid VDSobjid );

   Abstract
	This method disables a VDS object and deletes the entry from the List.

   Algorithm

   Arguments
   Type		Name		I/O	Description

   Notes/Remarks

   Status/return Code
	status == OM_S_SUCCESS
	status == OM_E_xxx
-me*/

message VDPDisableObject (IGRlong *msg; GRobjid VDSobjid );

/*+me
   Public Message VDPIsObjEnabled( IGRlong *msg, GRobjid VDSobjid );

   Abstract
	This method verifies if there is an entry in the List.

   Algorithm

   Arguments
   Type		Name		I/O	Description

   Notes/Remarks

   Status/return Code
	status == OM_S_SUCCESS
	status == OM_E_xxx
-me*/

message VDPIsObjEnabled ( IGRlong *msg; GRobjid VDSobjid; IGRboolean *Flag);

/*+me
   Public Message VDPgetPMenabledList

   Abstract
	This method returns the PME Enabled Item list.

   Algorithm

   Arguments
   Type		Name		I/O	Description

   Notes/Remarks

   Status/return Code
	status == OM_S_SUCCESS
	status == OM_E_xxx
-me*/

message VDPgetPMenabledList( IGRlong *msg; IGRint *nbObjs; struct GRobj_env **listObjs);

end specification VDPenabObj;
