
/* $Id: VCDBFoTerm.S,v 1.1.1.1 2001/01/04 21:12:32 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/CABLE
 *
 * File:        vcdbattr/VCDBFoTerm.S
 *
 * Description:
 *
 * Specification file for cabling DB cache
 *   fiberoptical terminal specifications
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCDBFoTerm.S,v $
 *      Revision 1.1.1.1  2001/01/04 21:12:32  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:25:18  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.3  1997/08/15  12:51:46  pinnacle
# Replaced: vcdbattr/VCDBFoTerm.S for:  by hverstee for cabling
#
# Revision 1.2  1997/07/14  21:43:24  pinnacle
# Replaced: vcdbattr/VCDBFoTerm.S for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  20:51:22  pinnacle
# Created: vcdbattr/VCDBFoTerm.S by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      05/31/96          HV            New
 *
 * -------------------------------------------------------------------*/

class specification VCDBFoTerm (0:0) of VCDBterm;

instance  VCDBFoTerm
{
  IGRshort        nDEFpin;       /*  default pin_data index   */

  variable struct VCdbfopin      Pin[0];
};

override  VCGetPos;
override  VCGpAnum;

override  VCDB_fill;

end specification VCDBFoTerm;

