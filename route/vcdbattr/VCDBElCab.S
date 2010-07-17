
/* $Id: VCDBElCab.S,v 1.1.1.1 2001/01/04 21:12:31 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/CABLE
 *
 * File:        vcdbattr/VCDBElCab.S
 *
 * Description:
 *
 * Specification file for cabling DB cache
 *   Electrical cable specifications
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCDBElCab.S,v $
 *      Revision 1.1.1.1  2001/01/04 21:12:31  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:25:18  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.3  1997/08/15  12:52:26  pinnacle
# Replaced: vcdbattr/VCDBElCab.S for:  by hverstee for cabling
#
# Revision 1.2  1997/07/14  21:42:52  pinnacle
# Replaced: vcdbattr/VCDBElCab.S for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  20:49:44  pinnacle
# Created: vcdbattr/VCDBElCab.S by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      05/31/96          HV            New
 *
 * -------------------------------------------------------------------*/

class specification VCDBElCab (0:0) of VCDBcable;

instance  VCDBElCab
{
  IGRshort        nDEFlead;      /*   default lead-data index    */

  variable struct VCdbelcond     ElCon[0];
};

override  VCGetPos;
override  VCGpAnum;
override  VCDB_fill;

end specification VCDBElCab;

