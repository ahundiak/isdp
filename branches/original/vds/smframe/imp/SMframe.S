/* $Id: SMframe.S,v 1.1.1.1 2001/01/04 21:07:35 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smframe/imp / SMframe.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMframe.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:35  cvs
 *	Initial import to CVS
 *	
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
/*  ADZ 01 Feb 1994 : Override GRadd_to_display_list for display
/*---------------------------------------------------------------------------*/

class specification SMframe (0:1) of EMSplane, nci_macro;

#include "vds.h"

override EMSplane;

override GRgetobjinfo;  /* Override to obtain "Frame Name" */

override GRgenabsg;    /* Pass message to the foot plane */

override GRgetname;   /* To return name asking frame system */

override GRadd_to_display_list; /* To avoid setting in display list */

override NDgive_structure; 

override ASreturn_go; 

override GRdetplane;

override GRcopy;

override NDcopy;

override NDconnect;

override GRgetsize;

override GRgetgeom;

override EMget_props;

override GRgetrang;

override DIgive_output;

/*+me
  Public Message SMgetObjDef
	Defined also in VDSroot

  Abstract
        Returns the definition of an object: name of templates and feet, etc.
  Arguments
        OUT     long            *msg            Completion code.
        IN      VDobjDef        *objDef         Object definition.
  Note
        The fields of `objDef' point to static buffers and therefore should
        not be freed.
-me*/

message SMgetObjDef(	long		*msg ;
			VDobjDef	*objDef );

message SMfind_frame_num(IGRlong *msg; IGRint *fr_number);
/*
   ABSTRACT:
    Give the number of the frame 
   ARGUMENTS:
     msg        [O] Completion code   MSSUCC or MSFAIL
     fr_num     [O] Frame number 
*/

message SMfind_frm_syst(IGRlong *msg;struct GRid *fr_syst);
/*
   ABSTRACT:
     Find the connected  frame systen 
    ARGUMENTS:
     msg        [O] Completion code   MSSUCC or MSFAIL
     fr_syst    [O] Connected frame system 
*/

message SMgive_rel_position(IGRlong *msg;IGRdouble *frame_pos);
/* ABSTRACT:
   Give the position of the frame relative to the axis
   of the frame syst
 ARGUMENTS:
   msg        [O] Completion code   MSSUCC or MSFAIL
   frame_pos  [O] Position of frame 
*/
  

		
	
end specification SMframe;



