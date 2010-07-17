
/* $Id: VCFCmisc.I,v 1.1.1.1 2001/01/04 21:12:38 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcterm / VCFCmisc.I
 *
 * Description:
 *   This file contains miscellaneous methods for a fiberoptic
 *   crossfile connector
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCFCmisc.I,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:38  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  05:23:34  pinnacle
# Integ into Route 02040304
#
# Revision 1.1  1997/03/12  16:34:06  pinnacle
# Created: vcterm/VCFCmisc.I by hverstee for cabling
#
 *
 * History:
 *        05/29/96        hv         Initial
 *
 *************************************************************************/

class implementation VCFCbConn;


method VCGetProduct (IGRint   *Prodno;
                     IGRchar  *ProdNam)
{
   if (Prodno) *Prodno = VC_PROD_FO;

   if (ProdNam) strcpy (ProdNam, "Fo");

   return (OM_S_SUCCESS);
}

end implementation VCFCbConn;

