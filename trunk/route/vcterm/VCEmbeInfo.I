/* $Id: VCEmbeInfo.I,v 1.1.1.1 2001/01/04 21:12:38 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vcterm / VCEmbeInfo.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VCEmbeInfo.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:38  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1998/02/24  22:41:24  pinnacle
# Created: vcterm/VCEmbeInfo.I by kddinov for route
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	Feb-98		KDD	creation
 *
 *************************************************************************/
class implementation VCEmbed;

#include  "vds.h"
#include  "VDmsg.h"

method VDgetObjDef(     long *msg ;
                        VDobjDef *myDef )
{

        myDef->info             = VD_I_ObjVCEmbed ;
        myDef->type             = 0 ;

        *msg    = MSSUCC ;

        return (OM_S_SUCCESS)  ;
}

end implementation VCEmbed;
