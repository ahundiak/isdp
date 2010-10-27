/* $Id: SMglob.S,v 1.1.1.1 2001/01/04 21:07:35 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smglob/imp / SMglob.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMglob.S,v $
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

/* ------------------------------------------------------------------------
   SMglob.S
   Jean Jasinczuk
   June 1992

   ABSTRACT:
	This class implement global data 
	The global data is a macro whose parents are
	 -an ACrg_collect which contains all the data parameters
          (create by this class)
	 -a ship cs
         -a frame system
	 -a hull 
---------------------------------------------------------------------------- */
class specification SMglob (0:1) of SMAttMgr, VDSroot ;

#include "SMglob.h"

override SMWhoAreYou;

override SMFillSfFile;


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

message SMcreate(IGRlong *msg; struct GRid *cs;
                 struct GRid *frm; struct GRmd_env *frm_env;
		 struct GRid *hull; struct ACrg_coll *ACrg);
/* ABSTRACT :
     Fill all the parameters and connect the SMglob
     The cs and hull are graphic objects
     It also put it state as SM_ACT and SM_NEW
     All parameters are needed.
  ARGUMENTS :
      msg      O : completion code (MSSUCC or MSFAIL)
      cs       I : Cs
      frm      I : Frame system 
      frm_env  I : Env of frame system	
      hull     I : Hull to connect with the global	
      ACrg     I : ACrg_collection containing all attributes
*/

message SMModify(IGRlong *msg; struct GRid *cs;
		 struct GRid *frm;struct GRmd_env *frm_env;
		 struct GRid *hull; struct ACrg_coll *ACrg);	
/* ABSTRACT :
    Modify all  parameters of the SMglob
    It also put it state as SM_ACT and SM_MOD 
  ARGUMENTS :
      msg      O : completion code (MSSUCC or MSFAIL)
      cs       I : Cs
      frm      I : Frame system
      frm_env  I : Env of frame system
      hull     I : Hull to connect with the global	
      ACrg     I : ACrg_collection containing all attributes
*/


message SMGetConnected(IGRlong *msg;struct GRid *cs;
	               struct GRid *frm;struct GRmd_env *frm_env;
                       struct GRid *hull);
/* ABSTRACT :
     Get all the connected objects to SMglob
     Give NULL pointer if not interested with parameter       	 
     Return NULL_OBJID for each parameter not connected
     It return the graphic object bind to the parent	

  ARGUMENTS :
      msg       O : completion code (MSSUCC or MSFAIL)
      cs        O : Cs
      frm       I : Frame system 
      frm_env   I : Env of frame system
      hull      O : The hull connected 
*/


override ACmplace_from_def,ACconstruct_feet;

end specification SMglob;





