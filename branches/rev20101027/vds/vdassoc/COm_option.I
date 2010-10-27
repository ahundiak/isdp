/* $Id: COm_option.I,v 1.1.1.1 2001/01/04 21:07:41 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdassoc/COm_option.I
 *
 * Description:
 *		Correction in function.
 *
 * Dependencies:
 8		GRNUCSRC/assoc/nmacro_co/COm_option.I
 *
 * Revision History:
 *	$Log: COm_option.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:41  cvs
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
# Revision 1.1  1995/11/07  14:35:36  pinnacle
# Created: vdassoc/COm_option.I by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	11/06/95	adz		creation date
 *
 ***************************************************************************/

class implementation COm_place;

#include "nddef.h"
#include "OMmacros.h"
#include "coparadef.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "AS_status.h"
#include "exmacros.h"
#include "macro.h"
#include "msmacros.h"
#include "ASmessages.h"
#include "expmacros.h"
#include "ASmessages.h"
#include "madef.h"
#include "ACattrib.h"
#include "asbox.h"
#include "ACcondit.h"
#include "grerr.h"
#include "acmacros.h"


#define AS_DEBUG

from GRvg    import GRchglevel,GRchgcolor,GRchgweight,GRchgstyle,GRgetsymb;
from NDmacro import ACgive_structure,ACreturn_foot,ACcopy_to_Groot;
from GR3dpoint import GRaltconstruct;
from ACdiowner import ACcreate,ACadd_component,ACadd_attribute_by_type,
		      ACadd_component_with_name;
from NDnode  import NDgive_structure, ASreturn_go, NDchg_state;
from ACmacro_defn       import ACgive_upscan,ACcreate_default;
from ACcond_def         import ACgive_condit_desc, ACfind_rep;
from    ACrg_collect    import  ACset_list_attribute;
from    ACrg_collect    import  AClist_attribute;
from    ACdiowner       import  ACrem_attribute;
from    ACdiowner       import  ACmod_attribute;
from GRvg import GRgetname;

char *strrchr();

extern GRclassid OPP_ACcond_def_class_id, OPP_ASsource_class_id,
		 OPP_ACncpx_class_id,OPP_ACheader_class_id;

COm_get_condit_def_hdr(msg, macro_id, def_hdr, num_temp, temp_list, md_env)
IGRlong			*msg;
struct GRid		*macro_id, *def_hdr;
IGRint			num_temp;
struct GRid		*temp_list;
struct GRmd_env 	*md_env;
{
 IGRint		active_index;
 IGRlong	status = OM_S_SUCCESS;
 struct GRid 		sym, rep_id, def_id, def_occ;

 if( num_temp == 0 || temp_list == NULL ){ return (OM_E_ABORT); }

 rep_id.objid = NULL_OBJID;
 status = om$send(msg = message ACcond_def.ACfind_rep(msg, 
				                      num_temp,
						      sym, 
                                                      temp_list,
                                                      &rep_id,
						      &active_index,
				                      md_env),
	           senderid = NULL_OBJID,
                   targetid = macro_id->objid,
	           targetos = macro_id->osnum);
 as$status(action = RET_STATUS);

 if ( rep_id.objid != NULL_OBJID ) 
 {
     COm_get_option_grid(&rep_id,&def_id,(char *) NULL);

     def_occ.objid = NULL_OBJID;

     if(def_id.objid != NULL_OBJID)
     {
            status = om$send(msg = message NDmacro.ACreturn_foot(msg,
                                			        "~~occurence",
								&def_occ,
								NULL,
								NULL),
		             senderid = NULL_OBJID,
                             targetid = def_id.objid,
                             targetos = def_id.osnum);
            as$status(action = RET_STATUS);

	    if ( def_occ.objid != NULL_OBJID ) {
		def_hdr->objid = def_occ.objid;
		def_hdr->osnum = def_occ.osnum;
	    }
       }
  }
  return(1);
}

end implementation COm_place;
