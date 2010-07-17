/* $Id: VLunwFeat.S,v 1.1.1.1 2001/01/04 21:11:43 cvs Exp $  */

/*************************************************************************
 * I/LOFT
 *
 * File:        src/unwext/VLunwFeat.S
 *
 * Description: Specification file for Feature Object.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLunwFeat.S,v $
 *      Revision 1.1.1.1  2001/01/04 21:11:43  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:32:50  pinnacle
# LOFT 2.5.1
#
# Revision 1.1  1997/10/28  15:29:04  pinnacle
# Created: src/unwext/VLunwFeat.S by rchennup for loft
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *      10/28/97   Rama Rao     File Creation
 *************************************************************************/

class specification VLunwFeat (0:0) of VDdrwObj;

instance VLunwFeat
{
        channel { ( many_to_one ) VLunwObj.to_feat ; }   to_obj ;
};

override        ACmplace_from_def,
		ACconstruct_feet ;

override        VDgetObjDef;
override        GRdelete;

message VLgetUnw_obj(   IGRlong         *msg;
                        struct   GRid   *unw_obj );

end specification VLunwFeat;
