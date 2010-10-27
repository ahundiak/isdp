/* $Id: VDPCmdRvPmr.S,v 1.1.1.1 2001/01/04 21:09:03 cvs Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdprevpmr/cmd/VDPCmdRvPmr.S
 *
 * Description:
 *	Command for displaying PME items to which Notes have been attached.
 *
 * History:
 *
 *	10/12/95	MSM	Creation
 *
 * ---------------------------------------------------------------------*/

class specification VDPCmdRvPmr (1:0) of VDS_LOCATE;


#include "VDPdef.h"

/*+cmd
/* -----------------------------------------------------------------------

   Command Object Class VDPCmdRvPmr

   Superclass
	VDS_lOCATE

   Abstract
	This command object shows all the Objects to which notes have been 
	attached in a PMR session.

   Methods

	my_init			Public		Initialises.

	VDPSelectItems		Public		Selects Items.

-----------------------------------------------------------------------------
-cmd*/

/*+v
 ---------------------------------------------------------------------------
 Abstract

 Notes/Remarks

*/

instance VDPCmdRvPmr
{
    struct GRid			window_id;
};

/*

-v*/

/*+me
 ---------------------------------------------------------------------------
  Public Message my_init

  Abstract
        This method initializes instance data

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
 ---------------------------------------------------------------------------
  Public Message get_window

  Abstract
        This method gets the window id and stores it in the instance data

  Arguments
        IGRlong         *sts            O       Return code

  Status
      status == OM_S_SUCCESS

  Return Code
        *sts = VD_SUCCESS

 ---------------------------------------------------------------------------
-me*/

message get_window( long *sts );

override form_notification;

end specification VDPCmdRvPmr;
