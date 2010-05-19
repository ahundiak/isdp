/* $Id: VDPCmdEnab.S,v 1.1.1.1 2001/01/04 21:08:58 cvs Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdpenable/cmd/VDPCmdEnab.S
 *
 * Description:
 *	Command for PME enabling items
 *
 * History:
 *
 *	10/12/95	MSM	Creation
 *    Jan 09 1998	SSR	TR # 179702659
 * ---------------------------------------------------------------------*/

class specification VDPCmdEnab (1:0) of VDS_LOCATE;

/*+cmd
/* -----------------------------------------------------------------------

   Command Object Class VDPCmdEnab

   Superclass
	VDS_lOCATE

   Abstract
	This command object lets the PME enabling of Items in a VDS design 
	session.

   Methods

	my_init			Public		Initialises.

	VDPLocateObjects	Public		Locates all eligible Objects.

      VDPEnableItems	Public		PME Enables all selected items.

	VDPLocate1Obj	Public		Locates only one eligible object

-----------------------------------------------------------------------------
-cmd*/

/*+v
 ---------------------------------------------------------------------------
 Abstract

 Notes/Remarks

*/

instance VDPCmdEnab
{

};

/*

-v*/

/*+me
 ---------------------------------------------------------------------------
  Public Message VDPLocateObjects

  Abstract
        This method stores all the located objects

  Arguments
        IGRlong         *sts            O       Return code

  Status
      status == OM_S_SUCCESS

  Return Code
        *sts = VD_SUCCESS
               VD_ERROR ( if error )

 ---------------------------------------------------------------------------
-me*/

message VDPLocateObjects ( long * sts );


/*+me
 ---------------------------------------------------------------------------
  Public Message VDPLocate1Obj

  Abstract
        This method locates one object at a time.

  Arguments
        IGRlong         *sts            O       Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS
 ---------------------------------------------------------------------------
-me*/
message VDPLocate1Obj( long   *sts );

/*+me
 ---------------------------------------------------------------------------
  Public Message VDPEnableItems

  Abstract
        This method PME enables all the eligible items

  Arguments
        IGRlong         *sts            O       Return code

  Status
      status == OM_S_SUCCESS

  Return Code
        *sts = VD_SUCCESS
               VD_ERROR ( if error )

 ---------------------------------------------------------------------------
-me*/

message VDPEnableItems ( long *sts );


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

end specification VDPCmdEnab;
