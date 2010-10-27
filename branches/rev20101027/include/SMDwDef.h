/* $Id: SMDwDef.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/include / SMDwDef.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMDwDef.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:30  cvs
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
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

#ifndef SMDwDef_include
#define SMDwDef_include


/*
 *   Include file defining structure and constants for the SMAN drawing
 *   extraction.
     History
     
     28 May 93		Raju		Added AttName in struct SMDwSymb
 */

struct SMDwSymb
{
 IGRint			options;
 IGRdouble		lens;		/* (Min) Length for ContLn */
 IGRdouble		MaxLens;	/* Max Length for ContLn   */
 IGRshort		TextJust;	/* Same as defined in gotextdef */
					/* CENTER_CENTER, ....		*/
 IGRchar		AttName[20];	/* Attribute whose value should appear on drawing
 					   as text */
 struct	GRsymbology 	symb;
}; 

/*
 *   Options: define the different combinations.
 */

#define SMDWCLUSR	0x00000001	/* Color user defined		*/
#define SMDWCLACT	0x00000002	/* Color active 		*/
#define SMDWCLOBJ	0x00000004	/* Color as object		*/

#define SMDWLVUSR	0x00000010	/* Level user defined		*/
#define SMDWLVACT	0x00000020	/* Level active			*/
#define SMDWLVOBJ	0x00000040	/* Level as object		*/

#define SMDWWTUSR	0x00000100	/* Weight user defined		*/
#define SMDWWTACT	0x00000200	/* Weight active		*/
#define SMDWWTOBJ	0x00000400	/* Weight as object		*/

#define SMDWSTUSR	0x00001000	/* Style user defined		*/
#define SMDWSTACT	0x00002000	/* Style active			*/
#define SMDWSTOBJ	0x00004000	/* Style as object		*/

#define SMDWCTLNUSR	0x00010000	/* length user defined		*/
#define SMDWCTLNMM	0x00020000	/* Mini & Maxi length defined	*/
#define SMDWCTLNAUTO	0x00040000	/* length auto computed		*/

#define SMDWTXUSR	0x00100000	/* TEXT justif user defined	*/
#define SMDWTXACT	0x00200000	/* TEXT justif active		*/

#define SMDWATTUSR	0x01000000	/* Name of Attrib. to be displayed
					   is defined by user		*/
#define SMDWATTOBJ	0x02000000	/* Display Comp. Name		*/

#define SMDWEXTFLR	0x10000000	/* Extract floor of compart.	*/
#define SMDWEXTCS	0x20000000	/* Extract cross-section	*/

/*
 * Name of the collection created to store the information
 */
#define SMDwCollName ":SMDrwParam"

/*
 * Number of maximum collection created for one object to extract
 */
#defime SMMAXCOLDW	10

/*
 * Number of maximum object created for a compart at extraction time
 */
#defime SMMAXOBJDW	5 

#define SMMAXCOLDIM 	50	/* SMMAXCOLDW * SMMAXOBJDW */

#endif

