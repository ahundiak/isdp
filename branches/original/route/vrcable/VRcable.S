/* $Id: VRcable.S,v 1.1.1.1 2001/01/04 21:12:40 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrcable / VRcable.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRcable.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:40  cvs
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
# Revision 1.2  1996/01/16  20:05:32  pinnacle
# Replaced: vrcable/VRcable.S for:  by r240_int for route240
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *
 *************************************************************************/
/* 
/* Abstract :
/*	This graphics class defines a common set for methods, used
/*	to manipulate the VRcable object.
/*
/* Notes:
/*	None.
/*
/* History:
/*	
/*	ADZ 02/06/91 : Creation date.
/*	ADZ 11/27/91 : MOdification bend_table methods.
/* */

class specification VRcable (0:1) of GRlinestr,ACncpx;

instance VRcable
{
	IGRdouble	sect_radius;	/* access by expression */
	IGRdouble	bend_radius;	/* access by expression */
	variable IGRdouble bend_table[0];
};

override NDplace, GRgetobjinfo, GRlnproject, GRptproject;
override GRvtadjseg, GRdelvertex, GRinsvertex, GRmoveseg, GRmodify, GRxform;
override ACconstruct_feet, ACcontext_compute_feet;
/*\
MOTIVATION
    Specific behaviour for
	NDplace        	  : placement
	NDcompute_node 	  : recompute after a parent change
	GRgetobjinfo 	  : UI_status when locate
\*/


message VRCbGetProps(		IGRlong 	*msg; 
		   		struct GRmd_env	*md_env;
				IGRdouble	*sect_radius;
				IGRdouble	*bend_radius;
				IGRdouble	*cab_length );
/*\
Abstract: 
	This method returns the instance values of a VRcable object.

Arguments
     *msg		IGRlong		O: completion code.
     *md_env		struct GRmd_env	I: environment information.
     *sect_radius	IGRdouble	O: default section radius of cable.
     *bend_radius	IGRdouble	O: the sectionn radius of cable.
     *cab_length	IGRdouble	O: the cable length.

Return Values
     - MSSUCC if successful
     - MSFAIL (severe) if failure

Notes
    In case one of the instance values is not required, give NULL pointer as
    input parameter.

Example:
	sts = om$send(	msg = message VRcable.VRCbGetProps( 
					&msg, &md_env, NULL, NULL, &length ),
			targetid = cable.objid );
\*/


message VRCbDelBendRad(		IGRlong 	*msg;
				IGRint		index );
/*\
Abstract: 
	This method deletes the bend radius value at the index of the internal 
	bend table representation for an cable instance data. The bend table
	will be resized.

Arguments
     *msg		IGRlong		O: completion code
     index		IGRint		I: table index

Return Values
     - MSSUCC if successful
     - MSFAIL (severe) if failure

Notes
    If a failure occurs, the object's instance data will not be modified
\*/


message VRCbInsBendRad(		IGRlong 	*msg;
				IGRint		index );
/*\
Abstract: 
	This method inserts the default bend radius value (instance data) of a 
	cable at the index of the internal bend table representation for the
	cable instance data. The bend table will be resized.

Arguments
     *msg		IGRlong		O: completion code
     index		IGRint		I: table index

Return Values
     - MSSUCC if successful
     - MSFAIL (severe) if failure

Notes
    If a failure occurs, the object's instance data will not be modified
\*/


message VRCbChaBendRad(		IGRlong		*msg;
				struct GRmd_env *md_env;
				IGRboolean	global;
				IGRdouble	*rad;
				IGRdouble	*point;
				IGRdouble	*view );
/*\
Abstract 	
	This method determines with help of the z-view representation and an
	input data point the index of the bend_table. The rad value will be
	at the found index. The boolean global allows to modify the bend table
	individual or common for all the bend tables indexes.
	and an object.

Arguments
     *msg		IGRlong		O: completion code
     *md_env		struct GRmd_env	I: environment information
     global		IGRboolean	I: changement option (TRUE/FALSE)
     *rad		IGRdouble	I: bend radius value to insert
     *point		IGRdouble	I: (IGRpoint) data point near the vertex to modify
     *view		IGRdouble	I: (IGRpoint) the z-view of the current view.

Return Values
     - MSSUCC if successful
     - MSFAIL (severe) if failure

Notes
     global = TRUE	The total bend radius table will be updated with the
			given radius value (rad).
     global = FALSE	With help of the data point (point) and the view 
			representation of the window (view) the nearest vertex
			will be updated with the given radius valeu (rad).
    
\*/
			
end specification VRcable;
