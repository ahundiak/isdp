
/* $Id: VCstructs2.h,v 1.1.1.1 2001/01/04 21:12:35 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcinclude/VCstructs2.h
 *
 * Description:
 *
 *      Structures defined for VC cabling system
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCstructs2.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:12:35  cvs
 *      Initial import to CVS
 *
 * Revision 1.2  1999/01/19  17:13:00  pinnacle
 * Replaced: vcinclude/VCstructs2.h for: CR179701619 by aharihar for route
 *
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.1  1998/02/18  20:13:52  pinnacle
 * Created: vcinclude/VCstructs2.h by kddinov for route
 *
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *	Feb/98		KDD	VCJumpConn, VCJumpData, VCOffset.
 *
 *	19 Jan 1999	Anand	Modified VCJumpConn, VCJumpData.
 *
 * Note: When expanding those structures, ALWAYS add new members at the end.
 *************************************************************************/

#ifndef VCstructs2_include
#define VCstructs2_include

/*-------------------------------------------------------------------------
* Structure to define the map: 
* pin position pair (Module, Position), to JumperId number. 
* There can be many pairs corresponding to same JumperId,
* as well as many Jumpers connecting the same pair. 
*
* JumperId connects to VCJumpData.
* (Mod, Pos) connects to the terminal position. 
*------------------------------------------------------------------------*/  
struct VCJumpConn 
{
	IGRshort	JumperId;
	IGRchar		Mod[VC_MAX_MOD_ID];
	IGRchar		Pos[VC_MAX_POS_ID];
};


/*-------------------------------------------------------------------------
* Structure to store information specific to a particular Jumper.
*
* JumperId connects it with VCJumpConn.
* jump_code connects to VCT_JUMP DB table. 
*------------------------------------------------------------------------*/
struct VCJumpData 
{
	IGRshort	JumperId;
	IGRchar		jump_code[VC_MAX_CCODE];
	IGRchar		no_mto_flag;
	IGRchar		cnt_vs_max;
	IGRint		NumTermPins;
	IGRchar		remarks[80];

	IGRchar		*Extend;
};


/*-------------------------------------------------------------------------
* Structure to store the map:
* connect point index number, to offset.
*
* In cables the index corresponds to the vertex number. 
*------------------------------------------------------------------------*/
struct VCOffset 
{
	IGRshort	Index;
	IGRvector	Offset;
};
	


#endif

