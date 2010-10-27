/* $Id: VDfunc.I,v 1.1.1.1 2001/01/04 21:08:52 cvs Exp $ */
 
/* # -------------------------------------------------------------------
# I/VDS
#
# File:		vds/vdio/VDfunc.I
#
# Description:
#
# Dependencies:
#
# Revision History:
#       $Log: VDfunc.I,v $
#       Revision 1.1.1.1  2001/01/04 21:08:52  cvs
#       Initial import to CVS
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.3  1997/12/09  20:34:00  pinnacle
# Replaced: vdio/VDfunc.I for:  by impd for vds
#
# Revision 1.2  1997/10/27  16:38:06  pinnacle
# Replaced: vdio/VDfunc.I for:  by v250_int for vds
#
# Revision 1.1  1997/10/27  16:29:28  pinnacle
# Created: vdio/VDfunc.I by jwfrosch for vds
#
#
# History:
#       MM/DD/YY        AUTHOR          DESCRIPTION
#       05/30/97        Sundar          Creation Date
#
# ------------------------------------------------------------------- */

class implementation Root;

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <stdlib.h>

#include "OMprimitives.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "dpmacros.h"

#include "godef.h"
#include "nddef.h"
#include "ndmacros.h"

#include "exmacros.h"
#include "ACrg_collect.h"
#include "ACattrib.h"
#include "VDSutil.h"
#include "v_dbgmacros.h"
#include "AS_status.h"
#include "VDmem.h"
#include "SMCompForm.h"
#include "SMdef.h"

#include "madef.h"
#include "maidmx.h"
#include "csmacros.h"

#define  AS_DEBUG
#define VD_K_ACT_SUCCESS 0x001
#define VD_K_RESTART_CMD 0x002

from	ACrg_collect	import	ACadd_list_attribute;
from	ACrg_collect	import	ACset_list_attribute;
from	VDequipment	import	ACgive_db_structure;
from 	ACcpx		import  ACfind_temp_obj;
from    ACrg_collect    import  ACchg_prop_mgr;
from    ACrg_collect    import  ACget_prop_mgr;

extern OMuword  OPP_VDequipment_class_id;

long VDobjInActiveSpace( long *msg, int *count, struct GRid **loc_obj, OMuword  class);

/*--------------------------------------------------------------------------*/

long VDobjInActiveSpace( 	long *msg, 
				int *count, 
				struct GRid **list, 
				OMuword class )
{
	OMuword 	objClassid,	/* Class of `curObj'		*/
			actOs ; 	/* OS number of active file	*/
	struct GRid	curObj;
	int		i,		/* Loop index			*/
			cnt,		/* Count of children		*/
			maxObjs ;	/* Max. of objs in Object Space */
					/* or in given list of parts.	*/
	long		sts = OM_S_SUCCESS ;

	cnt = 0;
	
	ex$get_cur_mod( osnum = &actOs ) ;
	maxObjs = OM_GA_OSDs[actOs]->CurSpaceMapSize ;
	curObj.osnum = actOs ;
		
	*list = _MALLOC ( maxObjs, struct GRid );

	for( i = 0 ; i < maxObjs ; i++ ) {

		curObj.objid = i ;

		sts = om$get_classid(	objid		= curObj.objid,
					osnum		= curObj.osnum,
					p_classid	= &objClassid ) ;
		if( !( sts & 1 ) ) {
			/*
			 * Not an object id.
			 */
			__DBGpr_obj( "OBJECT " , curObj );
			continue ;
		}
		sts = om$is_ancestry_valid(
				superclassid	= class,
				subclassid	= objClassid ) ;
		if( sts != OM_S_SUCCESS ) {
			/*
			 * Not a VSfeature. But check if it is a reference file
			 */
			continue ;
		} else {
			(*list)[cnt] = curObj;
			cnt++;
		}
	}

	if( cnt) *count = cnt;
	
	return( sts & *msg & 1 );
}

long VDget_active_cs ( long *msg, struct GRobj_env *csGrid )
{
  int             status = OM_S_SUCCESS;
 
 
        long            sts;
        BSrc            bsrc ;
        struct GRid     curMod ;
 
        /*
         * Retrieve current OS.
         */
        ex$get_cur_mod( id      = &curMod.objid,
                        osnum   = &curMod.osnum ) ;
 
        /*"Current OS : %d\n", curMod.osnum*/
 
        csGrid->obj_id.osnum = curMod.osnum ;
 
        /*
         * Retrieve active coordinate system.
         */
        sts = cs$get_active_info( msg   = msg,
                                  osnum = csGrid->obj_id.osnum,
                                  objid = &csGrid->obj_id.objid ) ;
 
        as$status( sts = sts,  action = GOTO_VALUE, value = wrapup ) ;
        as$status( sts = *msg, action = GOTO_VALUE, value = wrapup ) ;
 
        csGrid->mod_env.md_id = curMod ;
        csGrid->mod_env.md_env.matrix_type = MAIDMX ;
        MAidmx( &bsrc, csGrid->mod_env.md_env.matrix ) ;
 
        wrapup :
                *msg = ( sts & *msg & 1 ) ? VD_K_ACT_SUCCESS :
                                            VD_K_RESTART_CMD ;
 
quit:
  return OM_S_SUCCESS;
}
end implementation Root;
