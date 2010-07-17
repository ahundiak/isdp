
/* $Id: VCElCable.S,v 1.2 2002/05/08 15:48:23 anand Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vccable/VCElCable.S
 *
 * Description:
 *      Real class implementing electrical cables
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCElCable.S,v $
 *        Revision 1.2  2002/05/08 15:48:23  anand
 *        Files added/modified for sub-cable functionality.
 *
 *        Revision 1.1.1.1  2001/01/04 21:12:27  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:09:46  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.6  1997/04/29  13:04:34  pinnacle
# Replaced: vccable/VCElCable.S for:  by hverstee for cabling
#
# Revision 1.5  1997/03/06  22:41:56  pinnacle
# Replaced: vccable/VCElCable.S for:  by hverstee for cabling
#
# Revision 1.4  1997/01/16  14:33:48  pinnacle
# Replaced: vccable/VCElCable.S for:  by hverstee for cabling
#
# Revision 1.3  1996/09/25  22:04:00  pinnacle
# Replaced: vccable/VCElCable.S for:  by hverstee for cabling
#
# Revision 1.2  1996/09/25  15:59:24  pinnacle
# Replaced: vccable/VCElCable.S for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:51:16  pinnacle
# Created: vccable/VCElCable.S by hverstee for cabling
#
 *
 * History:
 *        05/29/96        hv        Initial
 *
 *************************************************************************/

class specification VCElCable (0:0) of VCCable;

instance VCElCable
{
};

override VCGetProduct;
override VCGetModel;
override VCSetTagNo;

override NDplace;
override NDdelete;
override GRdelete;

override VCCmpDef;

override VCCbInitCon;

/* Added by Anand for sub-cables */
override VCCSetCon_Data;

end specification VCElCable;
