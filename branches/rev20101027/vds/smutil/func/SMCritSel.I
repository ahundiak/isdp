/* $Id: SMCritSel.I,v 1.1.1.1 2001/01/04 21:07:39 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smutil/func / SMCritSel.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMCritSel.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:39  cvs
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

class implementation Root;

#include "OMmacros.h"
#include "OMindex.h"
#include "madef.h"
#include "godef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "msdef.h"
#include "exmacros.h"

#include "SMdef.h"
#include "ACattrib.h"
#include "ACrg_collect.h"

#include "SMdef.h"
#include "SMmacros.h"

#include "AS_status.h"


from OMObjSpace import pass;
from SMmgr	import SMGetList, SMClearTag;

/*---------------------------------------------------------------------------*/
/* 
/* SMCritSel:
/*
/* Given a type, a sub_type and a criteria, its returns either the list of 
/* found objects or tags them.
/*
/*---------------------------------------------------------------------------*/

SMCritSel(
IGRlong		  *msg,	     /* O : Completion code			  */
IGRshort	   options,  /* I : SM_CLEAR_TAG, SM_NEW_LIST		  */
IGRshort	   state,    /* I : Selected state (SM_NEW, .... 	  */
IGRshort	   type,     /* I : Type of the object (see SMdef.h).	  */
IGRshort	   sub_type, /* I : Sub-type of the object (see SMdef.h). */
IGRint		   nb_crit,  /* I : Number of criteria.			  */
struct ACrg_coll  *crit,     /* I : Criteria list.			  */
struct SMObjList  *list,     /* O : Found object list.			  */
IGRboolean	   tag       /* I : TRUE if it tags the objects		  */
)
{
 IGRlong		status;
 IGRint			i;
 OM_S_CLASSLIST         clist;
 extern GRclassid       OPP_SMmgr_class_id;
 OMuword                classes;
 struct GRid		mod_id;

 *msg = MSFAIL;

 if(tag != TRUE && list == NULL) return OM_W_ABORT;
   
 classes         = OPP_SMmgr_class_id;
 clist.w_count   = 1;
 clist.w_flags   = OM_CLST_subclass;
 clist.p_classes = &classes;
 ex$get_cur_mod( id = &mod_id.objid, osnum = &mod_id.osnum );

 /* !!! recuperer tous les osnums si reference file 	*/
 /* Now extraction only for the current os 		*/

 if(options & SM_CLEAR_TAG && options & SM_REF_FILE)
  {
   /* Tag option not used with reference file attachement */
   return OM_S_SUCCESS;
  }

 if(options & SM_CLEAR_TAG)
  {
   status = om$send( msg = message OMObjSpace.pass(&clist,OM_e_wrt_object,
                         message SMmgr.SMClearTag()),
                         senderid = NULL_OBJID,
                         targetid = OM_GO_current_OS_objid,
                         targetos = mod_id.osnum);
   as$status(action = RET_STATUS);
  }


 if(!(options & SM_ADD_LIST))
  {
   if(list)
    {
     list->nb_objects = 0;
     list->nb_alloc   = 0;
    }
  }

 *msg = MSSUCC;
 status = om$send( msg = message OMObjSpace.pass(&clist,OM_e_wrt_object,
                         message SMmgr.SMGetList(msg, state, options, type,
			 	sub_type, nb_crit, crit, list, tag)),
                         senderid = NULL_OBJID,
                         targetid = OM_GO_current_OS_objid,
                         targetos = mod_id.osnum);
 as$status(action = RET_STATUS);
 if(*msg == MSFAIL) return OM_W_ABORT;
  

 if(options & SM_REF_FILE)
  {
   GRspacenum	ref_os[100];
   IGRint	nb_ref;
   OM_S_OBJID 	md_id;
  
   nb_ref = 0;
   status = VDfind_ref_files(ref_os, 100, &nb_ref);

   for(i=0;i<nb_ref;i++)
    {
     if(ref_os[i] == mod_id.osnum) continue;

     om$osnum_to_oso_objid(osnum = ref_os[i],p_objid = &md_id);
     *msg = MSSUCC;
     status = om$send( msg = message OMObjSpace.pass(&clist,OM_e_wrt_object,
                         message SMmgr.SMGetList(msg, state, options, type,
			 	sub_type, nb_crit, crit, list, tag)),
                         senderid = NULL_OBJID,
                         targetid = md_id,
		         targetos = ref_os[i]);

     as$status(action = RET_STATUS);
     if(*msg == MSFAIL)return OM_W_ABORT;
   }
 }
 return OM_S_SUCCESS;
}

end implementation Root;


