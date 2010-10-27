/* $Id: VDdrwObjover.I,v 1.1.1.1 2001/01/04 21:08:38 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vddraw/imp/VDdrwObjover.I
 *
 * Description:
 *
 * Dependencies:
 *	VDdrwObj.S
 *
 * Revision History:
 *	$Log: VDdrwObjover.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:38  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1998/03/24  14:44:42  pinnacle
# Replaced: vddraw/imp/VDdrwObjover.I for:  by v250_int for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.4  1996/06/22  13:41:06  pinnacle
# Replaced: vddraw/imp/VDdrwObjover.I for:  by azuurhou for vds.240
#
# Revision 1.3  1995/07/11  20:15:20  pinnacle
# Replaced: vddraw/imp/VDdrwObjover.I for:  by azuurhou for vds.240
#
# Revision 1.2  1995/06/27  21:03:14  pinnacle
# Replaced: vddraw/imp/VDdrwObjover.I for:  by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	23/06/95	adz		creation date
 *	24/03/98	adz		ACgive_structure with VDSroot.
 *
 * -------------------------------------------------------------------*/

class implementation VDdrwObj;

%safe
#include <math.h>
%endsafe

#include <stdio.h>
#include <string.h>
#include "OMmacros.h"
#include "OMprimitives.h"
#include "msdef.h"
#include "refdef.h"
#include "madef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "exmacros.h"
#include "grerr.h"

#include "asbox.h"
#include "grgsdef.h"
#include "nddef.h"
#include "ndmacros.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "ACrg_collect.h"
#include "AS_status.h"
#include "AS_debug.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "vddrwattr.h"
#include "vds.h"
#include "VDmsg.h"

method GRxform(	IGRlong			*msg;
		struct GRmd_env		*obj_dsenv; 
		IGRshort		*matrix_type;
		IGRmatrix		matrix;
		GRobjid			*newobjid )
{
	int		sts = OM_S_SUCCESS ;

	SetProc( VDdrwObj_GRxform ); Begin

	/*
	 *  xform on to graph channel
	 */

	*msg = MSSUCC ;

	sts =
	_VD_SEND_CHAN(	AC_mto_graf_chns,
			GRvg.GRxform(	msg, obj_dsenv, matrix_type,
					matrix, newobjid ));
	__CheckRC( sts, *msg, "GRvg.GRxform", wrapup ) ;

	__DBGpr_com(" Call NDnode.NDchange_node "); 

	sts =
	_VD_SEND_MY( NDnode.NDchange_node( obj_dsenv ));
	__CheckRC( sts, 1, "NDnode.NDchange_node", wrapup ) ;

wrapup:
	End
	return OM_S_SUCCESS;
}

/*+mo
 -------------------------------------------------------------------------

  Overridden Message
        ACgive_structure from NDmacro

  Abstract
        This method gives attribute value of name.

 -------------------------------------------------------------------------
-mo*/

method ACgive_structure(	int			*suc,
							*direct_index;
				char			*footname;
				struct ret_struct	*ptr_rst;
				struct GRmd_env		*md_env )
{
	IGRint			sts = OM_S_SUCCESS ;

	/*
	 * find the structure from current object and if not found
	 * form it parents object.
	 */

	IGRlong			msg ;
	struct	GRid		ftObj ;
	IGRshort		mtxTyp ;
	IGRmatrix		mtx ;

	SetProc( VDdrwObj_ACgive_structure ); Begin

	__DBGpr_str(" Name ", footname );

	sts =
	_VD_SEND_MY( NDmacro.ACreturn_foot( &msg,"attr",&ftObj,&mtxTyp, mtx ));
	if( sts&1 && msg&1 ){

		sts =
		_VD_SEND_OBJ(	ftObj,
				NDmacro.ACgive_structure( 
						suc, direct_index,
						footname, ptr_rst, md_env ));
		if( sts & *suc & 1 ) goto wrapup ;
	}

	sts =
	_VD_SEND_WRT_M( my_id,
			VDSroot.ACgive_structure(suc,
						direct_index,
						footname,
						ptr_rst,
						md_env ));
	if( !( sts & *suc & 1 )){

		/*
		 * find information from parent object.
		 */
		struct	GRid		parObj ;
		struct	GRobj_env	ModObj;
		IGRint			cnt ;
		IGRlong			msg;

		__DBGpr_com(" VDdrwObj_Get_Parent ");

		parObj.objid = NULL_OBJID ;
		sts =
		_VD_SEND_MY( NDnode.NDget_objects( ND_ROOT, &parObj,
						1, NULL, 1, 1, &cnt ));
		if( (!( sts&1 ))||( parObj.objid == NULL_OBJID )){
			sts = MSSUCC ;
			goto wrapup ;
		}

		sts =
		_VD_SEND_OBJN(	parObj, 
				NDmacro.ACreturn_foot(
						&msg,
						"",
						&ModObj._grid,
						&ModObj._matrix_type,
						ModObj._matrix ) );
		if( !( sts&msg&1 )){
			sts = MSSUCC ;
			goto wrapup ;
		}

		ModObj._md_os = ModObj._osnum;

		sts =
		ex$get_modid(mod_osnum = ModObj._md_os,
                	     mod_id    = &ModObj._md_id );

		sts =
		_VD_SEND_OBJN(	ModObj._grid,
				NDmacro.ACgive_structure(suc,
							direct_index,
							footname,
							ptr_rst,
							&ModObj.mod_env ));
	}

	wrapup :
		End;
		return sts;
}

/*+mo
 -------------------------------------------------------------------------

  Overridden Message
        ACfind_temp_obj from NDmacro

  Abstract
        This method gives template object value.

 -------------------------------------------------------------------------
-mo*/


method ACfind_temp_obj(		int			*suc;
				char			*name;
				struct GRid		*temp_obj )
{
	IGRint			sts;

	/*
	 * redirect to parents
	 */
	SetProc( VDdrwObj_ACfind_temp_obj ); Begin

	__DBGpr_str(" Name ", name );

	sts =
	_VD_SEND_WRT_M( my_id,
			ACncpx.ACfind_temp_obj( suc, name, temp_obj ));

	if( !( sts & *suc & 1 )){

		/*
		 * find information from parent object.
		 */
		struct	GRid		parObj ;
		struct	GRobj_env	ModObj;
		IGRint			cnt ;
		IGRlong			msg;

		__DBGpr_com(" VDdrwObj_Get_Parent ");

		parObj.objid = NULL_OBJID ;
		sts =
		_VD_SEND_MY( NDnode.NDget_objects( ND_ROOT, &parObj,
						1, NULL, 1, 1, &cnt ));
		if( (!( sts&1 ))||( parObj.objid == NULL_OBJID )){
			sts = MSSUCC ;
			goto wrapup ;
		}

		sts =
		_VD_SEND_OBJN(	parObj,
				NDmacro.ACreturn_foot(
						&msg,
						"",
						&ModObj._grid,
						&ModObj._matrix_type,
						ModObj._matrix ) );
		if( !( sts&msg&1 )){
			sts = MSSUCC ;
			goto wrapup ;
		}

		ModObj._md_os = ModObj._osnum;

		sts =
		ex$get_modid(mod_osnum = ModObj._md_os,
                	     mod_id    = &ModObj._md_id );

		sts =
		_VD_SEND_OBJN(	ModObj._grid,
				ACcpx.ACfind_temp_obj( suc, name, temp_obj ));
	}

	wrapup:
		End ;
		return sts ;
}

end implementation VDdrwObj;
