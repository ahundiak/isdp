/* $Id: SMVolBnd.S,v 1.1.1.1 2001/01/04 21:07:37 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smspace/bnd / SMVolBnd.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMVolBnd.S,v $
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
   SMVolBnd.S
   Pascale Lacroix
   July 1992

   ABSTRACT:
	This class implement a volume constructed on surfaces. 
       
	Parents of the macro:

	- An ACrg_collect witch contains :
	    name       : name of the volume.
            infinite   : integer that store the info for each surface 
			 (or curve) to specify if
			 plane must be taken as infinite or not (bit = 1 for
			 infinite, else 0).

	- The limitating surfaces.

---------------------------------------------------------------------------- */

class specification SMVolBnd (0:1) of SMAttMgr, VDSroot;

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

message SMcreate(IGRlong *msg; IGRchar *name; IGRint ordered; IGRint nb_surf; 
		struct GRid *track_id; struct GRid *surfs; unsigned int infinite);
/* ABSTRACT :
     Fill all the parameters of the macro and place it 

  ARGUMENTS :
      msg     : completion code (MSSUCC or MSFAIL)
      name    : the name of the volume
      ordered : 1 if ordered input surface 
      nb_surf : number of parent surfaces 
      track_id: track point (NULL_OBJID if not)
      surfs   : The parent surfaces 
      infinite: Info on each surface
*/

message SMModify(IGRlong *msg; IGRchar *name; IGRint ordered; IGRint nb_surf; 
		struct GRid *track_id;struct GRid *surfs; unsigned int infinite);
/* ABSTRACT :
     Fill all the parameters of and existing macro and redisplay it 

  ARGUMENTS :
      msg     : completion code (MSSUCC or MSFAIL)
      name    : the name of the volume
      ordered : 1 if ordered input surface 
      nb_surf : number of parent surfaces 
      track_id: track point (NULL_OBJID if not)
      surfs   : The parent surfaces 
      infinite: Info on each surface
*/

message SMGetParameters(IGRlong *msg;IGRchar *name;
		IGRint *ordered; IGRint *track; IGRint *nb_surf; 
		struct GRid **surfs; unsigned int *infinite);
/* ABSTRACT :
     Get all the parameters of and existing macro.
     A null pointer for a parameter means not return this parameter
     surfs (if non NULL) is allocated by the method and must be deallocated 
     by the user (If the method fails surfs is deallocated in the method).

  ARGUMENTS :
      msg     : completion code (MSSUCC or MSFAIL)
      name    : the name of the volume
      ordered : 1 if ordered input surface 
      track   : 1 if track point exist
      nb_surf : number of parent surfaces 
      surfs   : The parent surfaces
      infinite: Info on each surface
*/


end specification SMVolBnd;


