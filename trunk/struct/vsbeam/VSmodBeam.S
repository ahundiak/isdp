/* $Id: VSmodBeam.S,v 1.1.1.1 2001/01/04 21:10:12 cvs Exp $  */
 
/***************************************************************************
 * I/STRUCT
 *
 * File:        struct/vsbeam/VSmodBeam.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSmodBeam.S,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:12  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1997/10/06  09:01:10  pinnacle
# Replaced: vsbeam/VSmodBeam.S for:  by svkadamb for struct
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *                      suresh          modification
 ***************************************************************************/
/*
	I/STRUCT
*/ 
class specification VSmodBeam(0:0) of VSbeam, VSmodFeature ;

#include "OMmacros.h"
#include "vs.h"
#include "vsbeamdef.h"
#include "vsbeam.h"

/*+c
	Class of a beam which has undergone modifications, ie. which is the
	RESULT of an OPERATION performed on another beam.
-c*/

override
	VSsetOrientation,
	VSgetOrientation,

/*+o
Message VSgetSupportSf

Abstract
	Finds the supports surface of a beam, i.e. the surface which is the
	input of the topmost beam in a beam hierarchy.
Arguments
	See message VSgetSupportSf of class VSbeam.
-o*/
	VSgetSupportSf,

/*+o
Message VSgetSupportAxis

Abstract
	Finds the supports axis of a beam, i.e. the curve which is the input
	of the topmost beam in a plate hierarchy.
Arguments
	See message VSgetSupportAxis of class VSbeam.
-o*/
	VSgetSupportAxis ,


/*+o
Message VSgetsolidbeam

Abstract
	Gets the solid beam

	See message VSgetSolidBeam of class VSbeam.
-o*/

	VSgetSolidBeam ;

from VSbeam   inherit	NDdrawing_copy_geom,
			ACgive_structure,
			ACgive_db_structure,
			ACcheckin_candidate,
			ACadd_to_list_1,
			VDget_prefix_name,
			VSgetMassProperties,
			VSdescribeOutput,
			VSshowOrientation,
			VScreateFrozenCopy,
			VStransNameToIPATH,
			VStransIPATHToName ;


end specification VSmodBeam ;
