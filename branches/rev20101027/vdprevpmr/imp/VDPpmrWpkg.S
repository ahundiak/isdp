/* $Id */

/* I/VDS
 *
 * File:        vdprevpmr/imp/VDPpmrWpkg.S
 *
 * Description: Class for storing PMR notes.
 *
 *
 * Dependencies:
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      09/95           MSM           Creation
 */
class specification VDPpmrWpkg (1:0) of VDPRoot;

/*+ca
 Class VDPpmrWpkg

 Superclass
	VDPRoot

   Abstract
	This class maintains the list of all the Wpkg that have been created
	in a PMR session.

   Design Reference

   Methods
	VDPinit			Public		Initialises the Object
	VDPcheckWorkPackage	Public		checks Work Packages as completed
	VDPgetWorkPkg		Public		Returns all the work packages.

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

#include "VDPdef.h"

instance VDPpmrWpkg
{
   /* List of all the objects that are enabled during a design session */
   variable struct VDPwrkPkg	workPackage[0];
   variable char		Notes[0];
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
   Public Message VDPcheckWorkPackage

   Abstract
	This method checks the work package as completed.

   Algorithm

   Arguments
   Type		Name		I/O	Description

   Notes/Remarks

   Status/return Code
	status == OM_S_SUCCESS
	status == OM_E_xxx
-me*/

message VDPcheckWorkPackage( IGRlong *msg; struct VDPwrkPkg WorkPkg);

/*+me
   Public Message VDPgetWorkPkg

   Abstract
	This method returns all the work packages

   Algorithm

   Arguments
   Type		Name		I/O	Description

   Notes/Remarks

   Status/return Code
	status == OM_S_SUCCESS
	status == OM_E_xxx
-me*/

message VDPgetWorkPkg( IGRlong *msg; IGRint *nbObjs; struct VDPwrkPkg1 **WorkPkgs);

end specification VDPpmrWpkg;
