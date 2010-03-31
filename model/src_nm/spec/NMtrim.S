/*

Abstract

  This class represents region modification on a surface/composite
  surface/solid by using suitable parametric data. The generation of the
  data is independent. It could be from an oriented curve or from oriented
  intersections between 2 surfaces.

History

	  SM	01-April-91	Genesis
*/

class specification NMtrim (1:0) of EMSsfboolean;

#include "emsdattyp.h"
#include "emsinter.h"
#include "emsbool.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "emssfintdef.h"
#include "emssfint.h"
#include "emsdef.h"
#include "EMSmsgdef.h"
#include "emserr.h"
#include "nmdef.h"
#include "nmchandef.h"

from EMSsfboolean inherit debug;

override
    EMintcopy, 
    EMdeactivate, 	/* Disconnect loops_in from their edges and then
			   send wrt parent. Since this node did not create
			   the edges, it should not delete them. This to
			   be done only in case of undo - delete.
			*/
    EMsavestatedelete,  /* As above */
    EMgetstatedesc,
    EMgetsolidclass,
    GRgetobjinfo,
    NDmove_to_root, 	/* send EMSdpr.EMundo to self */
    EMtranslate_id_key, 
    EMconstruct_associative;


message NMtrim_element(IGRlong *EMmsg; struct GRmd_env *env;
               IGRushort boolopt; struct GRid *int_src, *trim_elem;
	       IGRchar *status_str;
               GRobjid **display_ids; IGRint *display_count);


end specification NMtrim;
