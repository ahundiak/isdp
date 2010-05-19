/* $Id: VDPCmdCmpRl.S,v 1.1.1.1 2001/01/04 21:09:05 cvs Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdpzone/cmd/VDPCmdCmpRl.S
 *
 * Description:
 *	Command for posting compartment memberships.
 *
 * History:
 *
 *	10/12/95	MSM	Creation
 *
 * ---------------------------------------------------------------------*/

class specification VDPCmdCmpRl (1:0) of VDS_LOCATE;

/*+cmd
/* -----------------------------------------------------------------------

   Command Object Class VDPCmdCmpRl

   Superclass
	VDS_lOCATE

   Abstract
	This command object lets the PME enabling of Items in a VDS design 
	session.

   Methods

	my_init			Public		Initialises.

	locate_comp		Public		locates compartments.

        post_comp_reln		Public		posts the compartment relns.

-----------------------------------------------------------------------------
-cmd*/

/*+v
 ---------------------------------------------------------------------------
 Abstract

 Notes/Remarks

*/

instance VDPCmdCmpRl
{
    struct GRid		comp_id;

    /* Id of the located compartment */

};

/*

-v*/

/*+me
 ---------------------------------------------------------------------------
  Public Message locate_comp

  Abstract
        This method locates the compartment.

  Arguments
        IGRlong         *sts            O       Return code

  Status
      status == OM_S_SUCCESS

  Return Code
        *sts = VD_SUCCESS
               VD_ERROR ( if error )

 ---------------------------------------------------------------------------
-me*/

message locate_comp ( long * sts );

/*+me
 ---------------------------------------------------------------------------
  Public Message post_comp_reln

  Abstract
        This method posts the relationship between the compartments and the
	items contained in them.

  Arguments
        IGRlong         *sts            O       Return code

  Status
      status == OM_S_SUCCESS

  Return Code
        *sts = VD_SUCCESS
               VD_ERROR ( if error )

 ---------------------------------------------------------------------------
-me*/

message post_comp_reln ( long *sts );

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
               VD_ERROR ( if error )

 ---------------------------------------------------------------------------
-me*/

message my_init ( long *sts );

end specification VDPCmdCmpRl;
