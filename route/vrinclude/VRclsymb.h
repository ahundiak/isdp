/* $Id: VRclsymb.h,v 1.1.1.1 2001/01/04 21:12:55 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrinclude / VRclsymb.h
 *
 * Description:
	Definitions for I/ROUTE Center Line Symbology ommacro for call.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRclsymb.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:55  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.1  1997/07/17  18:30:54  pinnacle
 * route 2.5
 *
 * Revision 1.1  1996/07/25  18:25:44  pinnacle
 * Creation of Route 241 project
 *
 * Revision 1.2  1996/01/17  23:40:08  pinnacle
 * Replaced: vrinclude/VRclsymb.h for:  by r240_int for route240
 *
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	01/15/96   tlb		Correct protoype declaration
 *
 *************************************************************************/
#include "go.h"

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

#define RETRIEVE	0
#define STORE		1

extern IGRint VRsymbology __((	IGRlong			*return_code, 
				IGRint			operation,
				struct	GRid		*symb_id,
				struct	GRsymbology	*symb));


#if defined(__cplusplus)
}
#endif
/***********************************

VR$symbology(
		return_code	pointer to IGRlong returns code for last 
				operation in call;
				
		operation	IGRchar defining type of operation. Normally
				only RETRIEVE used and this is the default.
				
		symb_id		point to struct GRid the entry for osnum will
				define the object space for the symbology.
				
		symb		pointer to struct GRsymbology which contains the
				space for the active VR symbology.
				
			)

*********************************/

#omdef VR$symbology(	return_code = NULL,
			operation   = RETRIEVE,
			symb_id	    = NULL,
			symb	    = NULL  )
			
VRsymbology( (  return_code ), 
	      ( operation ), 
	      ( symb_id ), 
	      ( symb )	   )
	      
#endomdef
