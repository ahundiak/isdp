/* $Id: VRHComp.S,v 1.1.1.1 2001/01/04 21:13:05 cvs Exp $  */

/***************************************************************************
 * I/ROUTE
 *
 * File:	vrprdcmp/VRHComp.S
 *
 * Description:
 *
 * Dependencies:
 *		SUBCLASS OF:    VRComponent, VRHvac
 *
 * Revision History:
 *	$Log: VRHComp.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:05  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.4  1995/12/17  18:06:12  pinnacle
# Replaced: ./vrprdcmp/VRHComp.S for:  by azuurhou for route240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	01/22/91	adz		creation date
 *
 ***************************************************************************/

class specification VRHComp (0:1) of VRComponent, VRHvac;

  instance VRHComp
  {
  };

/*--------------------------------------------------------------------------*/
override GRvg;		/* reject GRvg instances */

override ACgive_structure;

override VDgetObjDef;
override VRGetDefName;
override VRGetCatBehavior;

/*D    METHOD NAME   -  VRWriteAnalRes                        		*/
/*D                                                                     */
/*D    Abstract:                                                        */
/*D     This method writes the Analysis Info to the given file          */
/*D                                                                     */
/*D    Parameters:                                                      */
/*D                                                                     */
/*D    Name		I/O	Description                             */
/*D    ----		---     -----------                             */
/*D    *msg		I/O	Error indicator/message                	*/
/*D    cAnalType	I	Analysis Type( possible types defined in*/
/*D				VRdef.h					*/
/*D    pFile		I	File to write into			*/
/*D    nCptNum		I	Cpt Num at which the results are 	*/
/*D				requested				*/

message VRWriteAnalRes(	IGRlong			*msg;
			IGRchar			cAnalType;
			FILE			*pFile;
			IGRshort		nCptNum );

end specification VRHComp;
