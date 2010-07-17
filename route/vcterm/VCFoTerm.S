
/* $Id: VCFoTerm.S,v 1.1.1.1 2001/01/04 21:12:38 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcterm/VCFoTerm.S
 *
 * Description:
 *      Real class implementing fiberoptic terminals
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCFoTerm.S,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:38  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/11/30  16:10:04  pinnacle
# Replaced: vcterm/VCFoTerm.S for:  by r250_int for route
#
# Revision 1.6  1997/11/26  18:48:26  pinnacle
# Replaced: vcterm/VCFoTerm.S for:  by apazhani for cabling
#
# Revision 1.5  1997/03/12  22:07:36  pinnacle
# Replaced: vcterm/VCFoTerm.S for:  by hverstee for cabling
#
# Revision 1.4  1997/01/20  21:17:30  pinnacle
# Replaced: vcterm/VCFoTerm.S for:  by hverstee for cabling
#
# Revision 1.3  1996/09/25  22:00:20  pinnacle
# Replaced: vcterm/VCFoTerm.S for:  by hverstee for cabling
#
# Revision 1.2  1996/09/25  15:54:38  pinnacle
# Replaced: vcterm/VCFoTerm.S for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:26:14  pinnacle
# Created: vcterm/VCFoTerm.S by hverstee for cabling
#
 *
 * History:
 *        05/29/96        hv        Initial
 *        11/25/97        Alwin     Overriding the NDmove_to_root
 *
 *************************************************************************/

class specification VCFoTerm (0:0) of VCTerm;

instance VCFoTerm 
{
};

override VCGetProduct;
override VCGetModel;
override VCSetTagNo;
override VCCmpDef;

override NDplace;
override NDdelete;
override GRdelete;
override NDmove_to_root;

end specification VCFoTerm;

