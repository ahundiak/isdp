
/* $Id: VCElTerm.S,v 1.1.1.1 2001/01/04 21:12:38 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcterm/VCElTerm.S
 *
 * Description:
 *      Real class implementing electrical terminals
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCElTerm.S,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:38  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/11/30  16:10:00  pinnacle
# Replaced: vcterm/VCElTerm.S for:  by r250_int for route
#
# Revision 1.6  1997/11/26  18:45:44  pinnacle
# Replaced: vcterm/VCElTerm.S for:  by apazhani for cabling
#
# Revision 1.5  1997/03/12  22:07:20  pinnacle
# Replaced: vcterm/VCElTerm.S for:  by hverstee for cabling
#
# Revision 1.4  1997/01/20  21:17:46  pinnacle
# Replaced: vcterm/VCElTerm.S for:  by hverstee for cabling
#
# Revision 1.3  1996/09/25  22:00:02  pinnacle
# Replaced: vcterm/VCElTerm.S for:  by hverstee for cabling
#
# Revision 1.2  1996/09/25  15:54:24  pinnacle
# Replaced: vcterm/VCElTerm.S for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:25:42  pinnacle
# Created: vcterm/VCElTerm.S by hverstee for cabling
#
 *
 * History:
 *        05/29/96        hv        Initial
 *        11/25/97        Alwin     Overridden method NDmove_to_root
 *
 *************************************************************************/

class specification VCElTerm (0:0) of VCTerm;

instance VCElTerm 
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

end specification VCElTerm;

