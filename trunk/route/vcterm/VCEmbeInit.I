
/* $Id: VCEmbeInit.I,v 1.1.1.1 2001/01/04 21:12:38 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vcterm / VCEmbeInit.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VCEmbeInit.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:38  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1998/02/18  20:12:28  pinnacle
# Created: vcterm/VCEmbeInit.I by kddinov for route
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *
 *************************************************************************/

class implementation VCEmbed;

method VCInitInstance (IGRlong *msg)
{
  IGRlong 	status;

  status = om$vla_set_dimension( varray = me->JumpConn,
                                 size   = 0 );

  me->JumpConnType = 0; 				/* unknown data type */


  status = om$vla_set_dimension( varray = me->JumpData,
                                 size   = 0 );
 
  me->JumpDataType = 0;                                 /* unknown data type */


return ( OM_S_SUCCESS ); 
}


end implementation VCEmbed;
