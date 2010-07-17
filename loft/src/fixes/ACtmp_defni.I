/*
  ACcpx_defni.I
  robert patience
  21_jul_86
*/
class implementation ACtmp_defn;

#include "ctype.h"
#include "ASmacroi.h"
#include "macro.h"
#include "OMmacros.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "exdef.h"
#include "acdef.h"
#include "acmacros.h"

#define AS_DEBUG

from IGRdir import translate;
from OMObjSpace import pass;

extern GRclassid OPP_ACtmp_defn_class_id;

struct ACsymbol_struct
       { struct GRid symb_def ,  /* symbolic definition                       */
                     real_def ;  /* real definition                           */
	 int    used;            /* number of time the symb definition is used*/
       } ;

ACload_symbol(osid,osnum)
OM_S_OBJID osid;
GRspacenum osnum;
/*.ACload_symbol*/
{
// int status;
//  OM_S_CLASSLIST clist;
 struct GRid real_grid;
extern	struct ACsymbol_struct *ACsymbol_def;

	// FIX BUG LLC 4 Nov : replace pass method by a loop on object space.
	//			because pass can break before end of Obj Space
/*
  clist.w_count=1;
  clist.w_flags=OM_CLST_subclass;
  clist.p_classes=&OPP_ACtmp_defn_class_id;

  status = om$send(msg = message OMObjSpace.pass(&clist,OM_e_wrt_object,
                              message ACtmp_defn.ACreturn_real_def
					(&real_grid,(IGRchar *)ACsymbol_def)),
		   senderid = NULL_OBJID,
		   targetid = osid,
		   targetos = osnum);

  as$status();
*/
  ACalloc_symbol();

// Start FIX
	{
	struct	GRid	OBJ;
	GRclassid	cid;

	OBJ.osnum	= osnum;
	for( OBJ.objid = 0; OBJ.objid<OM_GA_OSDs[OBJ.osnum]->CurSpaceMapSize; 
								OBJ.objid ++){

		om$get_classid(		osnum	  = OBJ.osnum, 
					objid	  = OBJ.objid, 
					p_classid = &cid );

		if( om$is_ancestry_valid(
				subclassid	= cid,
				superclassid	= OPP_ACtmp_defn_class_id ))

      			om$send( msg	  = message ACtmp_defn.ACreturn_real_def
					(&real_grid,(IGRchar *)ACsymbol_def),
				 targetid = OBJ.objid,
				 targetos = OBJ.osnum,
				 senderid = NULL_OBJID );
	}
	}// end block
// End Fix

  return(OM_S_SUCCESS);
 }


end implementation ACtmp_defn;
