/* $Id: smframedef.h,v 1.1.1.1 2001/01/04 21:07:31 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	include/smframedef.h
 *
 * Description:
 *		API support constants for smAPImacros.h.
 *
 * Dependencies:
 *		Definition values for sm$create_frame_system(),
 *		sm$create_single_plane(), sm$modify_frame_system() and
 *		sm$modify_single_plane().
 *
 * Revision History:
 *	$Log: smframedef.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:31  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.1  1996/02/20  20:33:16  pinnacle
 * Created: ./include/smframedef.h by azuurhou for vds.240
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			i-paris		creation date
 ***************************************************************************/

#ifndef	smframedef_include
#define	smframedef_include

/* FRAME DISPLAY or SECTION DEFINITION */
#define	SM_FD_Number		0	/*	Number			*/
#define	SM_FD_Distance		1	/*	Distance		*/

/* FRAME AXIS */
#define	SM_FA_Xaxis		0	/*	axis is X		*/
#define	SM_FA_Yaxis		1	/*	axis is Y		*/
#define	SM_FA_Zaxis		2	/*	axis is Z		*/

/* FRAME ORIENTATION */
#define	SM_FO_Parallel		0	/*	parallel		*/
#define	SM_FO_Reversed		1	/*	reversed		*/

/* PLANE SIZE (REGULAR and REINFORCED) */
#define	SM_FS_Small		0	/*	Small plane size	*/
#define	SM_FS_Regular		1	/*	Regular plane size	*/
#define	SM_FS_Large		2	/*	Large plane size	*/
#define	SM_FS_Ems		3	/*	Ems plane size		*/

/* PLANE WIDTH JUSTIFICATION */
#define	SM_FJ_Width_Left	0	/*	left			*/
#define	SM_FJ_Width_Center	1	/*	center			*/
#define	SM_FJ_Width_Right	2	/*	right			*/

/* PLANE HEIGHT JUSTIFICATION */
#define	SM_FJ_Height_Bottom	0	/*	bottom			*/
#define	SM_FJ_Height_Center	1	/*	center			*/
#define	SM_FJ_Height_Top	2	/*	top			*/

#endif
