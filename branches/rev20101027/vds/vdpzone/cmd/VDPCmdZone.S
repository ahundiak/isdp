/* I/VDS
 *
 * File : vdpzone/cmd/VDPCmdZone.S
 *
 * Description : Command class to manage zones in PME
 *
 * Dependencies :
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      12/19/95         MSM             Creation
 */

class specification VDPCmdZone (1:0) of VDS_LOCATE;

#include        <stdio.h>
#include        "OMminimum.h"
#include        "FI.h"

#include        "VDPDatFrmDf.h"
#include 	"VDPdef.h"
#include 	"VDPzone.h"

/*+cmd
  Command Object  Class VDPCmdZone

  Super Class:
        VDS_LOCATE

  Abstract
        Class to manage Zone Command.

  Methods
        my_init     Public                  initialises the command.

  Overridden Methods

        form_notification       Notification routine for VDPZone & VDPZone1


-cmd*/   /* command class */

instance VDPCmdZone
{
    variable struct VDPzone	zones[0];
    int				nbPlacedZones;
    variable struct VDPPlCtxTST	CtxTST[0];
    variable struct VDPNameDesc ZoneNameDesc[0];
    struct VDPzone		activeZone;

    struct GRid         	window_id;
    struct GRobj_env		gr_objenv;
};


/*+me
------------------------------------------------------------------------------
  Public Message my_init

  Abstract
        This method initializes the command's instance data and the form.

  Arguments
        IGRlong         *sts            O       Return code

  Status
      status == OM_S_SUCCESS

  Return Code
        *sts = VD_SUCCESS

 ---------------------------------------------------------------------------
-me*/
message my_init ( long *sts );

/*+me
------------------------------------------------------------------------------
  Public Message update

  Abstract
        This method updates the main form and the commands instance data.

  Arguments
        IGRlong         *sts            O       Return code

  Status
      status == OM_S_SUCCESS

  Return Code
        *sts = VD_SUCCESS

 ---------------------------------------------------------------------------
-me*/
message update ( long *sts );

/*+me
------------------------------------------------------------------------------
  Public Message VDPSelectZones

  Abstract
        This method queries the directory subsystem for all the zones and 
	fills the instance data.

  Arguments
        IGRlong         *sts            O       Return code

  Status
      status == OM_S_SUCCESS
		VD_ERROR  if error.

  Return Code
        *sts = VD_SUCCESS

 ---------------------------------------------------------------------------
-me*/

message VDPSelectZones ( long *sts );

/*+me
 -----------------------------------------------------------------------------
  Public Message VDPqueryClass

  Abstract

  This message queries the names and descriptions given the classname

  Status/Return Code

     status == OM_S_SUCCESS     if success;
     status == OM_E_ABORT       if error;
 -----------------------------------------------------------------------------
-me*/
message VDPqueryClass(  IGRlong *msg;
			IGRchar *ZoneClass );

/*+me
 -----------------------------------------------------------------------------
  Public Message store_solid

  Abstract

  This message stores the objid of solid located in the commands instance data.

  Status/Return Code

     status = OM_S_SUCCESS	if success;
     status = OM_E_ABORT	if error;
 -----------------------------------------------------------------------------
-me*/
message store_solid ( long	*sts );

override form_notification;

end specification VDPCmdZone;

