
/* $Id: VCECmisc.I,v 1.1.1.1 2001/01/04 21:12:38 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcterm / VCECmisc.I
 *
 * Description:
 *   This file contains miscellaneous methods for an electrical 
 *   crossfile connector
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCECmisc.I,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:38  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  05:23:34  pinnacle
# Integ into Route 02040304
#
# Revision 1.1  1997/03/12  16:34:24  pinnacle
# Created: vcterm/VCECmisc.I by hverstee for cabling
#
 *
 * History:
 *        05/29/96        hv         Initial
 *
 *************************************************************************/

class implementation VCECbConn;


method VCGetProduct (IGRint   *Prodno;
                     IGRchar  *ProdNam)
{
   if (Prodno) *Prodno = VC_PROD_ELEC;

   if (ProdNam) strcpy (ProdNam, "EL");

   return (OM_S_SUCCESS);
}

end implementation VCECbConn;

