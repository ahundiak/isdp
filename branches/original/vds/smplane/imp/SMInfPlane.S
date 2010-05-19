/* $Id: SMInfPlane.S,v 1.1.1.1 2001/01/04 21:07:36 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smplane/imp / SMInfPlane.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMInfPlane.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:36  cvs
 *	Initial import to CVS
 *	
# Revision 1.2  1999/02/12  19:16:24  pinnacle
# Replaced: smplane/imp/SMInfPlane.S for:  by mdong for vds
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
/*---------------------------------------------------------------------------
/*
/*  ABSTRACT
/*  This class defined an individual frame object
/*  ADZ - 01 Feb 1994 :	Override GRadd_to_display_list for display.
/*---------------------------------------------------------------------------*/
class specification SMInfPlane (0:1) of EMSplane, VDSroot ;

override EMSplane;

override GRgetobjinfo;  /* Override to obtain "Frame Name" */

override GRgenabsg;    /* Pass message to the foot plane */

override GRgetgeom;   /* Ask plane is geometry */

override GRadd_to_display_list;	/* Avoid setting in display list */

override  NDgive_structure; 

override ASreturn_go; 

override GRdetplane;

override GRgetsize;

override ACconstruct_feet;

override EMget_props;

override GRgetrang;

override NDdrawing_copy_geom;  


/*+mo
  Overriden Message
	VDgetObjDef from VDSroot

  Abstract
        Returns the definition of an object: name of templates and feet, etc.
  Arguments
        OUT     long            *msg            Completion code.
        IN      VDobjDef        *objDef         Object definition.
  Note
        The fields of `objDef' point to static buffers and therefore should
        not be freed.
-mo*/

override VDgetObjDef;

message SMgive_rel_position(IGRlong *msg;IGRdouble *frame_pos);
/* ABSTRACT:
   Give the position of the infinite plane relative to is axis
   and his coordinate syst
 ARGUMENTS:
   msg        [O] Completion code   MSSUCC or MSFAIL
   frame_pos  [O] Position of frame 
*/

message SMGetSFrameList( IGRlong *msg; struct SMObjList *list );
/*
** Find all single frame objects.
** ARGUMENTS:
** msg   [O] Completion code   MSSUCC or MSFAIL
** list  [O] Single frame object lists
*/
  

			     
end specification SMInfPlane;



