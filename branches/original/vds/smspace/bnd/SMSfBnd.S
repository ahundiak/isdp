/* $Id: SMSfBnd.S,v 1.1.1.1 2001/01/04 21:07:37 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smspace/bnd / SMSfBnd.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMSfBnd.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:37  cvs
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

/* ------------------------------------------------------------------------
   SMSfBnd.S
   Pascale Lacroix
   July 1992

   ABSTRACT:
	This class implement a surface bounded by several other surfaces 
	or curves.
       
	Parents of the macro:

	- An ACrg_collect witch contains :
	    offset     : offset regards as the support
            infinite   : integer that store the info for each surface 
			 (or curve) to specify if
			 plane must be taken as infinite or not (bit = 1 for
			 infinite, else 0).

	- The support surface on which is constructed the bounded surface.
	- The limitating objects.

---------------------------------------------------------------------------- */

class specification SMSfBnd (0:1) of SMAttMgr, VDSroot;

override ACmplace_from_def;

override GRgetobjinfo; 

override ACconstruct_feet; 
 

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


message SMcreate(IGRlong *msg; IGRchar *name; IGRdouble offset; IGRint ordered;
		IGRint rev_sup; struct GRid *track_id; IGRint nb_surf; 
		struct GRid *surfs; unsigned int infinite);
/* ABSTRACT :
     Fill all the parameters of the macro and place it 

  ARGUMENTS :
      msg     : completion code (MSSUCC or MSFAIL)
      name    : the name of the bounded surface
      offset  : offset of support
      ordered : 1 if ordered input surface 
      rev_sup : 1 if bounded must have the reverse orientation of the support
      track_id: track point (NULL_OBJID if not)
      nb_surf : number of parent surfaces (or curves)
      surfs   : The parent surfaces or curves
      infinite: Info on each surface
*/

message SMModify(IGRlong *msg; IGRchar *name; IGRdouble offset; IGRint ordered;
		IGRint rev_sup; struct GRid *track_id;IGRint nb_surf; 
		struct GRid *surfs; unsigned int infinite);
/* ABSTRACT :
     Fill all the parameters of and existing macro and redisplay it 

  ARGUMENTS :
      msg     : completion code (MSSUCC or MSFAIL)
      name    : the name of the bounded surface
      offset  : offset of support
      ordered : 1 if ordered input surface 
      rev_sup : 1 if bounded must have the reverse orientation of the support
      track_id: track point (NULL_OBJID if not)
      nb_surf : number of parent surfaces (or curves)
      surfs   : The parent surfaces or curves
      infinite: Info on each surface
*/

message SMGetParameters(IGRlong *msg;IGRchar *name;IGRdouble *offset; 
		IGRint *ordered;IGRint *rev; IGRint *track;IGRint *nb_surf; 
		struct GRid **surfs; unsigned int *infinite);
/* ABSTRACT :
     Get all the parameters of and existing macro.
     A null pointer for a parameter means not return this parameter
     surfs (if non NULL) is allocated by the method and must be deallocated 
     by the user (If the method fails surfs is deallocated in the method).

  ARGUMENTS :
      msg     : completion code (MSSUCC or MSFAIL)
      name    : the name of the bounded surface
      offset  : offset of support
      ordered : 1 if ordered input surface 
      rev     : 1 if bounded must have the reverse orientation of the support
      track   : 1 if track point exist
      nb_surf : number of parent surfaces (or curves) (track point included)
      surfs   : The parent surfaces or curves (track point included)
      infinite: Info on each surface
*/


end specification SMSfBnd;


