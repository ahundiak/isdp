
class implementation Root;

%safe
#include <math.h>
%endsafe

#include "EMS.h"
#include "ems_m_inc.h"
#include "EMSmsgdef.h"            /* EMS_I_NotFound */
#include "EC_M.h"            /* Command strings */
#include "EC_P.h"      /* Prompt strings */
#include "EC_I.h"      /* Informational strings */
#include "EC_F.h"      /* Fatal strings */
#include "FI.h"
#include "EMSdpb.h"
#include "emsdef.h"
#include "emserr.h"
#include "REsfsolid.h"
#include "emsmass.h"

from EMScompsurf import EMcap_comp;
from EMSsfsolid import EMcap_thyself;

extern OMuword OPP_EMSgencompsf_class_id;

/*

Name
  EFSkinSolid

Abstract
 This function is an argument to ems$associative_element_by_function. 
 It is responsible for the creation and recomputation of the skinning 
 solid. 
Synopsis
 OUT:	IGRlong *EMmsg; if (1&*EMmsg) then successful else failed. 
 IN:	IGRuint options; not used.
 IN:	GRobjid old_objid; not used.
 IN:	GRobjid new_objid; objid of the newly created object.
 IN:	IGRint num_parents; number of parents.
 IN:	IGRchar *parent_info; information about parents. 
 IN:	IGRchar *recomp_info; information used to perform the recomputation
 IN:	struct GRvg_construct *construct_list; environment information
 OUT:	GRobjid *mod_new_id; same as new_objid if a change class did not occur, 
 			     else is whatever the id of the new class object is.
Description
 Create a composite surface using the same function used to create
 the skinning surface (EFSkinSurface, file EFCrtSkinSrf.I ), then cap it.
Return Value
 IGRlong
Notes

Index

Keywords
 solid,skinning,place,recompute
 
History
  06/22/93 : Carlos M. Diaz : created

 */
IGRint EFSkinSolid (EMmsg, options, old_objid, new_objid,num_parents,
parent_info, recomp_info, construct_list, mod_new_id)

IGRlong *EMmsg;
IGRuint options;
GRobjid old_objid;
GRobjid new_objid;
IGRint num_parents;
IGRchar *parent_info;
IGRchar *recomp_info;
struct GRvg_construct *construct_list;
GRobjid *mod_new_id;
{
 IGRlong sts, msg_loc = NULL;
 GRobjid surf_id = 0;
 
 sts = om$construct(classid = OPP_EMSgencompsf_class_id,
                            p_objid = &surf_id,
                            osnum = construct_list->env_info->md_id.osnum);
 if (!(1&sts)){
  EFprintcode(0,sts);
#ifdef DEBUG
  printf ("in line %d of file %s\n", __LINE__, __FILE__);
#endif
  EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_Fail, wrapup);
  }
 
 sts = EFSkinSurface (&msg_loc, options, old_objid, surf_id, num_parents,
 		parent_info, recomp_info, construct_list, &surf_id);

 if (!(1&sts&msg_loc)){
  EFprintcode(0,sts);
#ifdef DEBUG
  printf ("in line %d of file %s\n", __LINE__, __FILE__);
#endif
  EMerr_hndlr(!(1&sts&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
  }
 		
 sts = om$send ( msg = message EMSsfsolid.EMcap_thyself (&msg_loc,
                                          construct_list, 
                                          &surf_id),
	            senderid = NULL,
                    targetid = new_objid,
                    targetos = construct_list->env_info->md_id.osnum);
 if (!(1&sts&msg_loc)){
  EFprintcode(0,sts);
#ifdef DEBUG
  printf ("in line %d of file %s\n", __LINE__, __FILE__);
#endif
  EMerr_hndlr(!(1&sts&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
  }
 
 *mod_new_id = new_objid; 
#ifdef DEBUG
 printf("EFSkinSolid successful\n");
#endif
wrapup:
 return sts;
}

end implementation Root;
