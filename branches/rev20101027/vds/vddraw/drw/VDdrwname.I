/* $Id: VDdrwname.I,v 1.2 2001/02/20 23:43:29 ad Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:	vddraw/drw / VDdrwname.I
 *
 * Description:
 *	functions to retreive macro type andm names
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDdrwname.I,v $
 *	Revision 1.2  2001/02/20 23:43:29  ad
 *	*** empty log message ***
 *	
 *	Revision 1.1.1.1  2001/01/04 21:08:37  cvs
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
# Revision 1.7  1995/09/29  20:21:56  pinnacle
# Replaced: vddraw/drw/VDdrwname.I for:  by azuurhou for vds.240
#
# Revision 1.5  1995/09/28  12:50:04  pinnacle
# Replaced: ./vddraw/drw/VDdrwname.I for:  by azuurhou for vds.240
#
# Revision 1.4  1995/08/17  22:52:50  pinnacle
# Replaced: vddraw/drw/VDdrwname.I for:  by azuurhou for vds.240
#
# Revision 1.2  1995/06/27  18:30:58  pinnacle
# Replaced: vddraw/drw/VDdrwname.I for:  by azuurhou for vds.240
#
# Revision 1.1  1995/05/11  19:08:16  pinnacle
# Created: vddraw/drw/VDdrwname.I by tlbriggs r#
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	5/10/95    tlb		Created
 *	6/23/95	   adz		Changed calls for VDdrw3d object.
 *	9/27/95	   adz	   	Change the VD_drwGetACcpxInfo for Name.
 *	9/29/95	   adz	        Protect the GRxxType objects for VDdrw3d.
 *	2/20/01	   adz		Add option to control the VRNozzle objects
 *
 *************************************************************************/

class implementation VDSroot ;

#include <string.h>
#include <stdio.h>
#include <ctype.h>
#include "msdef.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "gotextdef.h"
#include "fontdef.h"
#include "font.h"
#include "EMSmsgdef.h"
#include "v_slcdef.h"
#include "v_slc.h"
#include "v_drwdef.h"
#include "v_drwapi.h"
#include "vddrwattr.h"
#include "VDdrwgrammar.h"
#include "v_globalmsg.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"

/*
 * Includes for function prototypes.
 */
#include "v_drwproto.h"

extern OMuword		OPP_ACconst_class_id ;
extern OMuword		OPP_ACcpx_class_id ;
extern OMuword		OPP_VDSroot_class_id ;
extern OMuword		OPP_GRclhdr_class_id ;
extern OMuword		OPP_GRsmhdr_class_id ;
extern OMuword		OPP_VDdrw3d_class_id ;

extern char		DIR_G_car_dir ;

from ACcpx_defn		import 	ACgive_name ;

/*----------------------------------------------------------------------------*/

int VD_drwGetGRhdrInfo(	struct GRid	*elmId,		/* element id */
			char		*name,		/* name returned */
			int 		Macro1_Name0	/* macro or name  */
			)
{
	long			rc, sts = OM_S_SUCCESS ;
	struct GRobj_info	info;
	char			*ptr;
	
	*name = '\0';

        if( vd_$is_ancestry_valid(      object  = elmId,
                                        classid = OPP_VDdrw3d_class_id )){

	  VD_drwGetSectInfo( elmId, name, TRUE );
          if (!strcmp( name, "Cell") || !strcmp( name, "Symbol") ){
		
	    if( Macro1_Name0 ){
		__DBGpr_str("VDdrw3d Macro", name );
		return TRUE ;
	    }

	    *name = '\0';
	    VD_drwGetSectInfo( elmId, name, Macro1_Name0 );
	  }
	}

	/* 
	 * Get info <type>:<name> 
	 */
	info.type[0] = '\0';
	sts = 
	_VD_SEND_OBJN( *elmId, GRgraphics.GRgetobjinfo (&rc, &info ));
	__CheckRC( sts, rc, "GRgetobjinfo", wrapup );

	if( Macro1_Name0 ){
		ptr = strchr (info.type, ':');
		if (ptr) *ptr = '\0';
		strcpy (name, info.type);
	}
	else {
		ptr = strchr (info.type, ':');
		ptr = (ptr == NULL) ? info.type :  ++ptr;
		strcpy (name, ptr);
	}

	__DBGpr_str("GR name", name );

	return TRUE;

	wrapup:

#ifdef	vdsDEBUG
		VD_ShowObj( elmId );
#endif
		return FALSE;
}
/*----------------------------------------------------------------------------*/

int VD_drwGetSectInfo(	struct GRid	*elmId,		/* element id */
			char		*name,		/* name returned */
			int 		Macro1_Name0	/* macro or name */
			)
{
	long			msg ;
	long			sts = OM_S_SUCCESS ;
	char			*mPtr ;
	VDpartAttr		attr ;

	name[0] = '\0';
	attr.Iwant = Macro1_Name0 ? VD_I_drwMacroInfo : VD_I_drwOccurInfo ;

	/*
	 * Since it's a section object, get the instance field.
	 */
	sts = _VD_SEND_OBJN( *elmId, GRvg.GRgetattr( &msg, (char *) &attr ));
	__CheckRC( sts, msg, "GRvg.GRgetattr", none );

	strcpy( name, attr.aString );

	/* remove extra stuff */
        mPtr = NULL ;
        mPtr = strchr( name, '[' );
        if( mPtr ) *mPtr = '\0';

	__DBGpr_str ("volume cut name", name);

	return TRUE;
none:

#ifdef	vdsDEBUG
	VD_ShowObj( elmId );
#endif
	return FALSE;
}

/*----------------------------------------------------------------------------*/

int VD_drwGetACcpxInfo(	struct GRid	*elmId,	/* element id */
			char	*name,		/* name returned */
			int 	Macro1_Name0	/* macro = TRUE, name = FALSE */
			)
{
	long			sts;
	long			msg ;
	int			rc ;
	struct GRid		macroDef ;
	char			*macName ;
	
	name[0] = '\0';

	if( Macro1_Name0 ){
	  /*
	   * Get the macro definition name.
	   */
	  sts = 
	  _VD_SEND_OBJN( (*elmId), ACcpx.find_macro( &macroDef ));
	  __CheckRC( sts, 1, "ACcpx.find_macro", wrapup ) ;

	  sts = 
	  _VD_SEND_OBJN( macroDef, ACcpx_defn.ACgive_name( &macName ));
	  __CheckRC( sts, 1, " ACcpx_defn.ACgive_name", wrapup ) ;

	  /* 
 	   * Mirrored copy macro case
	   */
	  if ( strcmp ( macName, "cpymir" ) == 0 ) {
		int			Index = -1;
		struct ret_struct	retStr;

		sts = 
		_VD_SEND_OBJN(	(*elmId),
				NDmacro.ACgive_structure(
						   &rc,
						   &Index,
						   "miror_obj",
						   &retStr,
						   NULL ));
		__CheckRC( sts, rc, "NDmacro.ACgive_structure", wrapup );

		strcpy( name, retStr.var.text_st.text_string);
		}
	  else 
		strcpy( name, macName ) ;

	  /*
	   * Check for special handling for the nozzle objects. The nozzle macro
	   * definition is identical to the 'hvav', 'rway' and 'piping' components.
	   * To avoid this object, we are changing the definition by user request 
	   * only. Macro1_Name0 > TRUE thn check for Nozzle.
	   */
	  if( Macro1_Name0 > 1 ){

		OMuword ObjClassId;

        	om$get_classid(	objid = elmId->objid,
                        	osnum = elmId->osnum,
                        	p_classid = &ObjClassId );

		if( om$is_ancestry_valid(
				subclassid	= ObjClassId,
				superclassname	= "VRNozzle" ) == OM_S_SUCCESS ){

			strcpy( name, "ISDP_nozzle");
		}
	  }

	  __DBGpr_str ("ACcpx name", name);

	  return TRUE;

	}
	else{
	  /*
	   * Get the macro basename.
	   */

	  GRname	objName ;
	  
	  *objName	= '\0' ;

          sts =
          _VD_SEND_OBJN(  (*elmId), GRvg.GRgetname( &msg, objName));
          if(( sts & msg & 1 ) && ( objName[0] != '\0' )){

		char    *pName ;

                if( pName = strrchr( objName, DIR_G_car_dir )) pName ++ ;
		else	pName = objName ;

		strcpy( name, pName );
	  }
          else{
		VD_drwGetGRhdrInfo( elmId, objName, FALSE );
	  }

	  return TRUE ;
	}

	wrapup:

#ifdef	vdsDEBUG
		VD_ShowObj( elmId );
#endif
		return FALSE;
}

end implementation VDSroot;
