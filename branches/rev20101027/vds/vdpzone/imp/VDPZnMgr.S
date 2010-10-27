/* $Id */

/* I/VDS
 *
 * File:        vdpzone/imp/VDPZnMgr.S
 *
 * Description: Class for a zone definition.
 *		This class can consist of either model views, or 2-D surfaces or
 *		1-d lines or 0-d points.
 *
 *
 * Dependencies:
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      12/95            MSM            Creation
 */

class specification VDPZnMgr (1:0) of GRcmpowner;

/*+ca
 Class VDPZnMgr

 Superclass
	VDPRoot

   Abstract
	This class defines the zones created in a VDS session.

   Methods

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
#include "VDPzone.h"

instance VDPZnMgr
{
  /* variable struct GRid	ZoneObjs[0]; */
};

/*+me
    Public Message VDPinit

    Abstract
	Initialisation message sent after creation

    Arguments
    Type	name		I/O	Description

    IGRlong	msg		O	return message

-me*/

message VDPinit( IGRlong *msg );

/*+me
    Public Message VDPgetZoneList

    Abstract
	This method returns all the Zones created in the current file

    Arguments

    Notes/Remarks

    Status/return Code
	status == OM_S_SUCCESS
	status == OM_E_xxxx
-me*/

message VDPgetZoneList( IGRlong *msg; IGRint *nbZones; struct VDPzone **zoneObjs );

/*+me
    Public Message VDPqueryZoneList

    Abstract
	This message queries the Database for all the Zones.	

    Arguments

    Notes/Remarks

    Status/return Code
	status == OM_S_SUCCESS
	status == OM_E_xxxx
-me*/

message VDPqueryZoneList( IGRlong *msg );

end specification VDPZnMgr;
