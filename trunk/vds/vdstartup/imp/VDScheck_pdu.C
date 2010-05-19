/* $Id: VDScheck_pdu.C,v 1.1.1.1 2001/01/04 21:09:23 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vdstartup/imp / VDScheck_pdu.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDScheck_pdu.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:23  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*****************************************************************************
 VDScheck_pdu - Check if PDU product exists on workstation
 This function reads /usr/ip32/product_data in order to locate PDU product

 Output: (global int) VD_PDU_present = 1 if PDU located
		      VD_PDU_present = 0 if PDU not located

 Returns 1 if OK
         0 if error

 AdZ:	Function rewritten.
*******************************************************************************/
#include <stdio.h>


int	VD_PDU_present;

int VDScheck_pdu()
{
char	product_path[256];

   VD_PDU_present = 0;

   /* Check if PDU is downloaded to workstation */
   if( get_modtype_data( "Pdu", NULL, NULL, NULL, NULL, product_path ) == 0 )
   {
        /*
         * product not avaiable on system.
         */
        return 0 ;
   }

   VD_PDU_present = 1;
   return 1;
}
