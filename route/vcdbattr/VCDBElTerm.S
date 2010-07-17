
/* $Id: VCDBElTerm.S,v 1.1.1.1 2001/01/04 21:12:31 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/CABLE
 *
 * File:        vcdbattr/VCDBElTerm.S
 *
 * Description:
 *
 * Specification file for cabling DB cache
 *   Electrical terminal specifications
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCDBElTerm.S,v $
 *      Revision 1.1.1.1  2001/01/04 21:12:31  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:25:18  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.3  1997/08/15  12:52:14  pinnacle
# Replaced: vcdbattr/VCDBElTerm.S for:  by hverstee for cabling
#
# Revision 1.2  1997/07/14  21:43:02  pinnacle
# Replaced: vcdbattr/VCDBElTerm.S for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  20:50:16  pinnacle
# Created: vcdbattr/VCDBElTerm.S by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      05/31/96          HV            New
 *
 * -------------------------------------------------------------------*/

class specification VCDBElTerm (0:0) of VCDBterm;

instance  VCDBElTerm
{
  IGRshort        nDEFpin;       /*  default pin-data index   */

  variable struct VCdbelpin      Pin[0];
};

override  VCGetPos;
override  VCGpAnum;

override  VCDB_fill;

end specification VCDBElTerm;

