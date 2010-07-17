
/* $Id: VCDBFoCab.S,v 1.1.1.1 2001/01/04 21:12:32 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/CABLE
 *
 * File:        vcdbattr/VCDBFoCab.S
 *
 * Description:
 *
 * Specification file for cabling DB cache
 *   Fiberoptic cable specifications
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCDBFoCab.S,v $
 *      Revision 1.1.1.1  2001/01/04 21:12:32  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:25:18  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.3  1997/08/15  12:52:00  pinnacle
# Replaced: vcdbattr/VCDBFoCab.S for:  by hverstee for cabling
#
# Revision 1.2  1997/07/14  21:43:14  pinnacle
# Replaced: vcdbattr/VCDBFoCab.S for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  20:50:50  pinnacle
# Created: vcdbattr/VCDBFoCab.S by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      05/31/96          HV            New
 *
 * -------------------------------------------------------------------*/

class specification VCDBFoCab (0:0) of VCDBcable;

instance  VCDBFoCab
{
  IGRshort        nDEFlead;      /*  default fiber-data index   */

  variable struct VCdbfocond     FoCon[0];
};

override  VCGetPos;
override  VCGpAnum;
override  VCDB_fill;

end specification VCDBFoCab;

