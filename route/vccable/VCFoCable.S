
/* $Id: VCFoCable.S,v 1.2 2002/05/08 15:48:23 anand Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vccable/VCFoCable.S
 *
 * Description:
 *      Real class implementing fiberoptic cables
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCFoCable.S,v $
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
# Revision 1.6  1997/04/29  13:04:50  pinnacle
# Replaced: vccable/VCFoCable.S for:  by hverstee for cabling
#
# Revision 1.5  1997/03/06  22:42:12  pinnacle
# Replaced: vccable/VCFoCable.S for:  by hverstee for cabling
#
# Revision 1.4  1997/01/16  14:34:02  pinnacle
# Replaced: vccable/VCFoCable.S for:  by hverstee for cabling
#
# Revision 1.3  1996/09/25  22:04:22  pinnacle
# Replaced: vccable/VCFoCable.S for:  by hverstee for cabling
#
# Revision 1.2  1996/09/25  15:59:08  pinnacle
# Replaced: vccable/VCFoCable.S for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:52:16  pinnacle
# Created: vccable/VCFoCable.S by hverstee for cabling
#
 *
 * History:
 *        05/29/96        hv        Initial
 *
 *************************************************************************/

class specification VCFoCable (0:0) of VCCable;

instance VCFoCable
{
   variable struct VCFo_Conn     FO_con_splc[0];
};

override VCGetProduct;
override VCGetModel;
override VCSetTagNo;

override NDplace;
override NDdelete;
override GRdelete;

override VCCmpDef;

override VCCbInitCon;

/*   store/retrieve assigned connector/splice   */

message VCFo_PutConn  ( IGRlong         *msg;
                        IGRshort         nCpt;
                        IGRshort         nIdx;
                 struct VCpos           *IdStr;
                        IGRchar         *Conn;
                        IGRshort         CType);

message VCFo_GetConn  ( IGRlong         *msg;
                        IGRshort         nCpt;
                        IGRshort         nIdx;
                 struct VCpos           *IdStr;
                        IGRchar         *Conn;
                        IGRshort        *CType);

/* Added by Anand for sub-cables */
override VCCSetCon_Data;

end specification VCFoCable;

