/* $Id: VDPCmdShEn.S,v 1.1.1.1 2001/01/04 21:08:58 cvs Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdpenable/cmd/VDPCmdShEn.S
 *
 * Description:
 *	Command for PME enabling items
 *
 * History:
 *
 *	10/12/95	MSM	Creation
 *
 * ---------------------------------------------------------------------*/

class specification VDPCmdShEn (1:0) of VDS_LOCATE;

/*+cmd
/* -----------------------------------------------------------------------

   Command Object Class VDPCmdShEn

   Superclass
	VDS_lOCATE

   Abstract
	This command object lets the PME enabling of Items in a VDS design 
	session.

   Methods

	my_init			Public		Initialises.

	VDPSelectItems		Public		Selects Items.

        VDPHighlightItems	Public		Highlights PME Enabled Items.

-----------------------------------------------------------------------------
-cmd*/

/*+v
 ---------------------------------------------------------------------------
 Abstract

 Notes/Remarks

*/

instance VDPCmdShEn
{
    struct GRid		window_id;
};

/*

-v*/

/*+me
 ---------------------------------------------------------------------------
  Public Message VDPSelectItems

  Abstract
        This method sselects all the PME enabled Items

  Arguments
        IGRlong         *sts            O       Return code

  Status
      status == OM_S_SUCCESS

  Return Code
        *sts = VD_SUCCESS
               VD_ERROR ( if error )

 ---------------------------------------------------------------------------
-me*/

message VDPSelectItems ( long * sts );

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

end specification VDPCmdShEn;
