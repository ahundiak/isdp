/* $Id: VDRepSrfCmd.S,v 1.1.1.1 2001/01/04 21:08:53 cvs Exp $ */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdloft/cmd/VDRepSrfCmd.S
 *
 * Description:    Command to repair surfaces whose poles are too close
 *
 *                 This command looks at the surface in the u direction
 *                 and then in the v direction to see whether the poles
 *                 are closer than a CHT.  Should this be the case a new
 *                 surface is created with the offending poles spread
 *                 out beyond CHT.
 *
 *		   Removed messages VLSetLevel and InitInstance from Loft's
 *		   original spec file and added messages VDstoreResponse,
 *		   VDstoreLocate and VDstoreList.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDRepSrfCmd.S,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:53  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1998/02/03  21:54:46  pinnacle
# TR_179702387: converted file from Loft to VDS
#
 *
 * History:
 *  MM/DD/YY  AUTHOR  DESCRIPTION
 *  01/23/98  ejm     TR:179702387, converted file from Loft to VDS
 ***************************************************************************/

class specification VDRepSrfCmd (1:0) of VDS_LOCATE;


instance VDRepSrfCmd
{

/*c	Same as superclass + **/

  short	NewLevel ;

/*	Following for store methods, brought over from VLlocateCmd.S	*/

  IGRint		Response;	/* VDstoreResponse */
  struct GRid		VDwindow;	/* VDstoreLocate   */
  IGRpoint		AcceptPoint;	/* VDstoreLocate   */
  struct GRobj_env	Loc_env;	/* VDstoreLocate   */
  IGRulong		VStype;		/* VDstoreList     */
  IGRint		VLtype;		/* VDstoreList     */
  IGRint		Cnt1;		/* VDstoreList     */
  IGRint		Cnt2;		/* VDstoreList     */
  IGRint		Cnt3;		/* VDstoreList     */
  struct GRobj_env	*Lst1;		/* VDstoreList     */
  struct GRobj_env	*Lst2;		/* VDstoreList     */
  struct GRobj_env	*Lst3;		/* VDstoreList     */
  struct GRmd_env	Current;	/* VDstoreList     */

};


message RepairSurface ( struct GRobj_env * TheSurf );

message VDProcessSrfs ( IGRlong * ret );

message VDstoreResponse ( long * sts );

message VDstoreLocate ( long * sts );

message VDstoreList ( IGRlong * sts ; IGRint make_indx ; IGRint flag );

end specification VDRepSrfCmd;
