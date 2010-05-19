/* $Id: VDdrw3di.I,v 1.3 2001/10/05 16:19:22 ramarao Exp $ */
/*---------------------------------------------------------------------------
/*  I/VDS
 *
 * File:        vddraw/imp/VDdrw3di.I
 *
 * Description:
 *
 *      This file implements the methods for the 3d-model visualizaton object.
 *
 * Dependencies:
 *      VDdrw3d.S
 *
 * Revision History
 *	$Log: VDdrw3di.I,v $
 *	Revision 1.3  2001/10/05 16:19:22  ramarao
 *	Fixed TR# 5496.
 *	
 *	Revision 1.2  2001/01/19 21:11:28  ramarao
 *	Merged from SP.
 *	
# Revision 1.3  2000/11/03  21:31:22  pinnacle
# Replaced: vds/vddraw/imp/VDdrw3di.I for:  by jpulapar for Service Pack
#
# Revision 1.2  2000/11/03  15:19:40  pinnacle
# Replaced: vds/vddraw/imp/VDdrw3di.I for:  by jpulapar for Service Pack
#
# Revision 1.1  2000/11/01  21:27:28  pinnacle
# Created: vds/vddraw/imp/VDdrw3di.I by jpulapar for Service Pack
#
# Revision 1.2  2000/02/27  14:16:34  pinnacle
# Replaced: vddraw/imp/VDdrw3di.I for:  by impd252 for vds
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/11/21  08:14:18  pinnacle
# Replaced: vddraw/imp/VDdrw3di.I for:  by ksundar for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.7  1995/09/05  14:35:32  pinnacle
# Replaced: ./vddraw/imp/VDdrw3di.I for:  by azuurhou for vds.240
#
# Revision 1.6  1995/08/17  22:51:24  pinnacle
# Replaced: vddraw/imp/VDdrw3di.I for:  by azuurhou for vds.240
#
# Revision 1.5  1995/08/07  20:21:32  pinnacle
# Replaced: vddraw/imp/VDdrw3di.I for:  by azuurhou for vds.240
#
# Revision 1.4  1995/07/26  16:51:50  pinnacle
# Replaced: vddraw/imp/VDdrw3di.I for:  by azuurhou for vds.240
#
# Revision 1.2  1995/06/27  21:02:44  pinnacle
# Replaced: vddraw/imp/VDdrw3di.I for:  by azuurhou for vds.240
#
 *
 * History:
 *	06/16/95	adz		creation date
 *	07/02/95	adz		add cn_type to ACconstruct_feet.
 *      02/27/00	adz		As Tr179900701 - check for active child.
 *      11/01/00        Jayadev         range reduction - VDdrw3dReduceRange 
 * -------------------------------------------------------------------------
 */

class implementation VDdrw3d;

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

#include "acdef.h"
#include "acmacros.h"
#include "asbox.h"
#include "AS_debug.h"
#include "grerr.h"
#include "grgsdef.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "bserr.h"
#include "bsparameters.h"
#include "exmacros.h"

#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "asmacros.h"
#include "nddef.h"
#include "ndmacros.h"

#include "ACattrib.h"
#include "ACrg_collect.h"

#include "AS_status.h"

#include "grerr.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "EMSmsgdef.h"

#include "vds.h"
#include "VDSutil_def.h" 
#include "vd_ve.h"
#include "v_edgedef.h"
#include "v_edgemacros.h"
#include "v_miscmacros.h"
#include "v_geommacros.h"
#include "v_datamacros.h"
#include "v_drwmacros.h"
#include "v_dbgmacros.h"
#include "VDmsg.h"
#include "SMmsg.h"
#include "vddrwattr.h"
#include "vdsmacros.h"

/*
#define vdsDEBUG 1
#define vdserrDEBUG 1
#include "v_dbgmacros.h"
*/
extern	GRclassid	OPP_Gexp_class_id,
			OPP_VDdrwGm_class_id,
			OPP_VDdrw3d_class_id,
			OPP_Gtext_exp_class_id,
			OPP_EMSsubbs_class_id;
from	expression	import	modify;
from	ACcpx_defn	import	ACgive_name;
from    EMSsubbs   	import EMreduce_range;
/*----------------------------------------------------------------------------*/

method VDgetObjDef(	long			*msg ;
			VDobjDef		*myDef ) {

	long		sts ;	/* OM return code	*/

	/*
	 * name.
	 */
	SetProc( VDdrw3d_VDgetObjDef ); Begin

	myDef->info		= VD_I_ObjDrw3d ;
	myDef->type		= VD_O_drw3dObj ;

	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	End
	return sts ;

} /* VDgetObjDef */

/*+mo
 -------------------------------------------------------------------------
  Public Message 
	ACconstruct_feet from NDnode

  Description:
      This file implements the ACconstruct_feet for the drawing object.
 
  Dependencies:
       VDdrw3d

  History:
 
	12/21/94	adz	creation date 
	03/28/95	adz	object data reduction.
 
  -------------------------------------------------------------------------
 */

method	ACconstruct_feet(	IGRlong		*msg;
				IGRint		cn_type; 
				IGRint		count;
				struct GRid	list[];
				struct GRmd_env *md_env;
				IGRint		*fcount;
				struct GRid	*feet_list )
{

	/*
	 * Root list:
	 *	- Dynamic collection (description, location, comp_flag, ...).
	 * 	- Parent object.
	 *	- VDdrw3dVw object (private channel).
	 */

	IGRint			sts = OM_S_SUCCESS,
				i,
				msCount ;
	IGRlong			inConn = OM_K_MAXINT ;
	struct GRid		gmId,		/* geometry feet	*/
				macDef,		/* macro definition	*/
				myGRid,		/* ikke			*/
				*msList ;
	IGRshort		action = 1 ,
				VwLevel,
				props  = GRIS_DISPLAYABLE | GRIS_LOCATABLE ;
	GRname			mdlASCII,
				gmMacro;	/* macro feet	 */
	struct	GRobj_env	vwObj, 		/* VDdrw3dVw object */
				parObj,		/* Graphical parent object */
				chdObj,		/* Check for consumed child */
				volObj;		/* intersect object */
	struct	GRsymbology	elmSymb ;
	VD_drwOutputData	*output = NULL ;
	struct	GRvg_construct	resCst;
	VDpartAttr		attr ;
	struct VDve_elem_buf	buf ;

	SetProc( VDdrw3d_ACconstruct_feet ); Begin 

	*msg	= MSFAIL;
	msList	= NULL ;
	msCount	= 0 ;

	buf.obj_info_p	= NULL ;
	buf.count	= 0 ;
	buf.buf_siz	= 0 ;

	/*
	 * init drawing object.
	 */
	myGRid.objid = my_id;
	myGRid.osnum = OM_Gw_current_OS;

	gmId.objid = NULL_OBJID ;
	gmId.osnum = OM_Gw_current_OS;

#ifdef	vdsDEBUG
	for( i=0 ; i<count ; i++ )	VD_ShowObj( list +i );
#endif
	/*
	 * find the VDdrw3dVw object.
	 */
	sts =
    	VDdrw_GetChannelOwner(  msg, &myGRid, VD_O_drw3d, &vwObj._grid );
	__CheckRC( sts, *msg, "VDdrw_GetChannelOwner", wrapup );

	vwObj._md_os = vwObj._osnum;
	vwObj._md_id = NULL_OBJID;

	/*
	 * Get the default support file name display level.
	 */
	attr.Iwant = VD_I_drwLevel ;
	sts =
	_VD_SEND_OBJ( vwObj._grid, GRvg.GRgetattr( msg, (char *)&attr ));
	 __CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup );

	VwLevel = attr.aType ;
	__DBGpr_int( "VwLevel ", VwLevel );

	attr.Iwant = VD_I_drwVisual ;
	sts =
	_VD_SEND_OBJ( vwObj._grid, GRvg.GRgetattr( msg, (char *)&attr ));
	__CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup );

	strcpy( mdlASCII, attr.aString );
	__DBGpr_str(" mdlASCII ", mdlASCII );

	/*
	 * We can have three way of creation the VDdrw3d feet objects.
	 *	1. Intersection with solid & respect to the support file.
	 *	2. Intersection with solid.
	 *	3. Copy the parent objects geometry.
	 */

	if( cn_type != VD_P_drw_PREPROCESS ){

	    /*
	     * find the parent object. It can be the associative parent,
	     * or it internal VDdrwGm components.
	     */

	    if( cn_type == VD_P_drw_FEETPROCESS ){

		__DBGpr_com(" cn_type == VD_P_drw_FEETPROCESS " );
		sts =
		_VD_SEND_MY(	NDmacro.ACreturn_foot(	msg, "geom",
							&parObj._grid,
							&parObj._matrix_type,
							parObj._matrix ));

	    }
	    else{
		__DBGpr_com(" cn_type == VD_P_drw_INTERACTIVE " );
		sts =
		_VD_SEND_OBJ(	list[1],
				NDmacro.ACreturn_foot(	msg,
							"",
							&parObj._grid,
							&parObj._matrix_type,
							parObj._matrix ));
	    }
	    __CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup );

	    parObj._md_os = parObj._osnum;
	    parObj._md_id = NULL_OBJID;
		sts =
		ex$get_modid( mod_osnum = parObj._md_os, mod_id = &parObj._md_id );

		VDatGetConsumingChild ( &parObj, &chdObj );
		parObj = chdObj ;
	    /*
	     * find the volumes of the VDdrw3dVw object.
	     */
	    volObj._objid	= NULL_OBJID ;
	    sts =
	    _VD_SEND_OBJ(	vwObj._grid,
	  			NDmacro.ACreturn_foot(	msg,
							"vol",
							&volObj._grid,
							&volObj._matrix_type,
							volObj._matrix ));
	    __CheckRC( sts, 1, "NDnode.ASreturn_go", wrapup );

	    volObj._md_os = volObj._osnum ;
            sts =
	    ex$get_modid(	mod_osnum = volObj._md_os,
				mod_id	  = &volObj._md_id );

	    if( strlen( mdlASCII ) == 0 ){
		/*
		 * Forget the parser and process directly.
		 */
		goto no_parser ;
	    }

	    /*
	     * the section cut process keywords are added inside this
	     * function.
	     */
	    sts = 
	    vd_$drwExecSection(	msg	= msg,
				elmId	= &parObj._grid,
				elmEnv	= &parObj.mod_env,
				drwEnv	= &volObj.mod_env,
				selList	= &volObj._grid,
				selCount= 1,
				filename= mdlASCII,
				output	= &output );
	    if( sts & *msg & 1 ){

	      VD_drwOutputData	*p	= output ;
	      while( p ) { msCount += p->set.count ; p = p->next ; }

	      if( msCount ) {

	        msList = _MALLOC( msCount, struct GRid );
	        if( msList ){
	          msCount = 0 ;
	          p = output ;

	          while( p ) {
	            int	i ;
	            int	max = p->set.count ;
	            struct GRid *l = p->set.list ;

	            for( i = 0 ; i < max ; i++ ) { msList[msCount++] = l[i] ; }
	            p = p->next ;
	          }
	        } /* if msList */
	      }
	      VD_drwFreeOutputData( &output ) ;
	    }

	    if( ! msList ){

no_parser :
	      /*
	       * Set the default symbology before calculation.
	       */
	      sts =
	      _VD_SEND_OBJ( parObj._grid, GRvg.GRgetsymb( msg, &elmSymb ));
	      __CheckRC( sts, *msg, "GRvg.GRgetsymb", wrapup );

	      elmSymb.level = VwLevel ;

	      __DBGpr_int(" mdlLevel ", elmSymb.level );

	      /*
	       * We didn't find a support file. We will create a intersection
	       * based on modelView object and 3D model object.
	       */
	      vd_$fill_cnst_list(
	        	Msg		= msg,
	        	Env_info	= md_env,
	        	Level		= elmSymb.level,
	        	Display		= &elmSymb.display_attr,
	        	Cnst_list	= resCst );

	      sts =
	      vd_$get_volume_intersect(	msg		= msg,
					optrCount	= 1,
					optrList	= &parObj,
					operand		= &volObj,
					resCst		= &resCst,
					resCount	= &msCount,
					result		= &msList );

	      __CheckRC( sts, *msg, "make_boolean_intersect", wrapup );

	    } /* if ! msList */
	
	} /* If INTERACTIVE */
	else{

	    __DBGpr_com(" cn_type == VD_P_drw_PREPROCESSING " );

	    UI_status(" Copy geometry ");

	    /*
	     * Copy the geometry of the parent object in feet.
	     */
	    sts =
	    _VD_SEND_OBJ(	list[1],
				NDmacro.ACreturn_foot(	msg,
							"",
							&parObj._grid,
							&parObj._matrix_type,
							parObj._matrix ));
	    __CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup );
	    parObj._md_os = parObj._osnum ;
	    
        sts =
	    ex$get_modid( mod_osnum = parObj._md_os, mod_id = &parObj._md_id );

		VDatGetConsumingChild ( &parObj, &chdObj );
		parObj = chdObj ;

	    sts =
	    vd_$select_obj_comps(	msg	= msg,
					option	= VD_K_gm_SdSfWf,
					count   = 1,
					grIds	= &parObj._grid,
					theEnv	= &parObj.mod_env,
					elmList = &buf );
	    __CheckRC( sts, *msg, "vd_$select_obj_comps", wrapup );

	    __DBGpr_int(" Number of Comps ", buf.count );

	    /*
	     * Get the symbology of the objects.
	     */
	    sts =
	    _VD_SEND_OBJ( parObj._grid, GRvg.GRgetsymb( msg, &elmSymb ));
	    __CheckRC( sts, *msg, "GRvg.GRgetsymb", wrapup );

	    elmSymb.level = VwLevel ;
	    __DBGpr_int( "mdlLevel ", elmSymb.level );

	    /*
	     * Copy the information to the msList and msCount.
	     */
	    msCount	= buf.count ;
	    msList	= _MALLOC( msCount, struct GRid );
	    if( msList ){
		for( i=0 ; i<msCount ; i++ ){
			msList[i].objid = NULL_OBJID ;
			sts =
			vd_$grCopy(	msg	= msg,
					frEnv	= & buf.obj_info_p[i].mod_env,
					frObj	= & buf.obj_info_p[i]._grid,
					toEnv	= md_env,
					toObj	= msList +i,
					symb	= &elmSymb );
		}
	    }
	    _FREE( buf.obj_info_p );
	    buf.obj_info_p = NULL ;
	}

	/*
	 * store the resulted geometry in the macro object.
	 */
	__DBGpr_int("ACconstruct_feet: Components ", msCount );

	/*
	 * If we do not have any graphical elements to connect, we
	 * will distroy the objects.
	 */
	if( ! msCount ) goto wrapup ;

        sts = VDdrwUpdateAttrCollector( msg, &myGRid, &parObj, mdlASCII );
        __CheckRC( sts, *msg, "VDdrwUpdateAttrCollector", wrapup );

	sts =
	VD_drwGeomGiveMacroBySize( msg, msCount, gmMacro );
	__CheckRC( sts, *msg, "VD_drwGeomGiveMacroBySize", wrapup );

	/*
	 * Delete the previous macro and regenerate a new one.
	 */
	macDef.objid = NULL_OBJID ;
	__DBGpr_str("Macro Type ", gmMacro );

#if 0 /* commented during the fix for the TR:179702015 by sundar */
	sts =
	_VD_SEND_MY( NDmacro.ACreturn_foot( msg, "geom",&gmId,NULL,NULL ));

	/*
	 * Delete the VDdrwGeom object.
	 */
	if( sts&*msg&1 ){

            sts =
            _VD_SEND_OBJN(	gmId,
				GRconnector.GRdisconn(	msg, &myGRid ));
	    __CheckRC( sts, *msg, "GRconnector.GRdisconn", wrapup );

	    sts =
	    _VD_SEND_OBJ(	gmId,
				GRgraphics.GRdelete(	msg, md_env ));
	    __CheckRC( sts, *msg, "GRgraphics.GRdelete", wrapup );
	    *msg = MSFAIL ;
	    gmId.objid = NULL_OBJID ;
	} 

	if( ! (sts&*msg&1) ){
#endif

 	    /*
	     * find the macro definition for the first occurence.
	     */
	    if( macDef.objid == NULL_OBJID ){
		sts =
		ac$find_macro_defn(
				action           = ACfind_load,
				macro_name       = gmMacro,
				p_macro_defn_id  = &macDef );

		if( ! ( sts&1 ) || macDef.objid == NULL_OBJID ){
			goto wrapup ;
		}
	    }

	    /*
	     * load the macro definition.
	     */
	    gmId.osnum = md_env->md_id.osnum;
	    sts =
	    om$construct(	classid	= OPP_VDdrwGm_class_id,
				osnum   = gmId.osnum,
				p_objid = &gmId.objid,
				msg	= message ACcpx.ACload_macro(macDef));

	    sts =
	    _VD_SEND_OBJ( gmId, NDnode.NDmove_to_root(msg, &gmId, md_env));
	    CheckRC( sts, *msg );
	// }

	/*
	 * connect the object.
	 */

	__DBGpr_obj(" VDdrwGm Objects ", gmId );
	__DBGpr_int(" Connect Count  ", msCount );

	for( i=0 ; i<msCount ; i++ ) {

		__DBGpr_obj(" Connect Object ", msList[i] );
                sts = om$send(msg = message EMSsubbs.EMreduce_range(msg,
                                            md_env, &msList[i].objid, 0),
                       targetid = msList[i].objid,
                       targetos = msList[i].osnum);
		if(!(sts&*msg&1)) 
		{
		  //printf("\n EMSsubbs.EMreduce_range failed \n");
		} 

		sts =
		_VD_SEND_OBJN(	msList[i],
				GRconnector.GRrigidconn(msg, &gmId, &inConn ));
		__CheckRC( sts, *msg, "GRconnector.GRrigidconn", wrapup );
	}

	/*
	 * connect the graphical feet.
	 */
	*fcount = 1 ;
	feet_list[0] = gmId ;

        sts =
        _VD_SEND_MY(  GRgraphics.GRchgprops( msg, &action, &props ));
        __CheckRC( sts, *msg, "GRgraphics.GRchgprops", wrapup );

	*msg = MSSUCC ;
	sts  = OM_S_SUCCESS ;

	wrapup:
		if( !( sts & *msg & 1 )){
			if(( msList ) && ( msCount )){
				vd_$bulk_delete(count	= msCount,
						grids	= msList,
						theEnv	= md_env );
			}
		}

		_FREE( msList );
		_FREE( buf.obj_info_p );

		End ;
		return sts ;
}

/*+mo
 -------------------------------------------------------------------------
  Overridden Message
        ACmplace_from_def from ACncpx

  Abstract

	Place an occurence of the macro in the design file.

  Arguments
      int 		*suc       	O 	0 FAILED 1 SUCCESS
      int		prop            I 	see macro.h
      char		rep             I 	navsea representation
      char 		*macro_name	I 	the macro to place
      int 		numb_obj	I 	the number of real template
      struct GRid 	*uplist     	I 	the list of templates
      struct GRid 	*def_occ    	I 	transfer context has to be 
						performed from this default 
						occurence
      struct GRmd_env	*mod_env	I	module env

  Status/Return Code
     OM_S_SUCCESS	if success;
     OM_E_ABORT		if fails

 -------------------------------------------------------------------------
-mo*/
method ACmplace_from_def(	int		*rc,
						prop;
				char		rep;
				char		*macro_name;
				int		num_temp;
				struct GRid	*temp_list;
				struct GRid	*def_occ;
				struct GRmd_env *md_env ){

IGRint		sts = OM_S_SUCCESS ;

	/*
	 * Put the properties to no proptect:
	 *	- Does not create source,
	 *	- Does not verify the number (variable number of templates) 
	 *	- Does not verify the template types
	 */
	SetProc( VDdrw3d_ACmplace_from_def ); Begin

	prop = prop | AChdr_noprotect | ACcant_place_sym;

	sts =
	_VD_SEND_WRT_M( my_id, ACncpx.ACmplace_from_def(rc,
							prop,
							rep, 
							macro_name,
							num_temp,
							temp_list,
							def_occ,
							md_env ));
	__CheckRC( sts, *rc, "ACncpx.ACmplace_from_def", wrapup ) ;

wrapup:
	End
	return sts ;
}

/*+mo
 -------------------------------------------------------------------------
  Overridden Message
        NDctl_parent_type from NDnode

  Abstract

	Find the matching string in the occurence macro of the section
	object and the input locate. 

  Arguments
      int 		*msg       	O 	0 FAILED 1 SUCCESS
      int		type            I 	macro type
      char		*info           I 	macro matching string 

  Status/Return Code
     OM_S_SUCCESS	if success;

 -------------------------------------------------------------------------
-mo*/
method NDctl_parent_type(	long		*msg;
				int		type ;
				char		*info ){

GRname			macName;
IGRchar			*mPtr ;

	SetProc( VDdrw3d_NDctl_parent_type ); Begin

	*msg = MSFAIL ;

	/* 
	 * Is a macro required 
	 */
	if( !( type & macro_generic )) return OM_S_SUCCESS;

	/*
	 * Do we have to control its type
	 */
	if(	info == NULL ||
	      ( info[0] == '*' && info[1] == '\0') ||
		info[0] == '\0'){

		*msg = MSSUCC;
		return OM_S_SUCCESS;
	}

	/*
	 * Find the macro of the section object.
 	 */
	strcpy( macName, me->info );

	mPtr = NULL ; mPtr = strchr( macName, '[' ); if( mPtr ) *mPtr = '\0';

	if( ASmatchRE( info, macName )) *msg = MSSUCC;
	else 				*msg = MSFAIL;
 
	End
	return OM_S_SUCCESS;
}

/*+mo
 -------------------------------------------------------------------------
  Overridden Message
        NDget_parent_type from NDnode

  Abstract

	Find the matching string in the occurence macro of the section
	object and the input locate. 

  Arguments
      int 		*msg       	O 	0 FAILED 1 SUCCESS
      int		type            I 	macro type
      char		*info           I 	macro matching string 

  Status/Return Code
     OM_S_SUCCESS	if success;

 -------------------------------------------------------------------------
-mo*/

method NDget_parent_type(	long		*msg;
				int		*type;
				char		*info ){

GRname			macName ;
IGRchar			*mPtr ;

	SetProc( VDdrw3d_NDget_parent_type ); Begin 

	*msg = MSFAIL;
	/*
	 * Find the macro of the section object.
 	 */
	strcpy( macName, &me->info[0] );
	mPtr = NULL ; mPtr = strchr( macName, '[' ); if( mPtr ) *mPtr = '\0';

	if( strlen( macName ) == 0 )	goto wrapup ;
		
	/*
	 * Fill in the return structure.
	 */
	strncpy( info, macName, macro_MAX_CHAR);
	*type = macro_generic;

	info[macro_MAX_CHAR-1] = '\0';

	*msg = MSSUCC;

wrapup:
	End
	return OM_S_SUCCESS;
}

/* This function is interfaced with COz_reduce.u */
IGRint VDdrw3dReduceRange(struct GRid *objects,
			struct GRmd_env *md_env,
			int numObjs)
{
  IGRint retFlag = 0,ncomp;
  IGRlong msg,sts;
  IGRlong  inConn = OM_K_MAXINT ;
  struct GRid gmId,*comps,newObj;
  int ii,jj;
  IGRchar buffer[1024];
  
  if((!objects) || (numObjs ==0)) goto wrapup;
  

  for(ii = 0; ii<numObjs; ii++)
    {
      
      gmId.objid = NULL_OBJID;
      gmId.osnum = 2;
      
      _FREE(comps);
      ncomp = 0;

      sprintf(buffer,"Processing object[%d]\n",ii);
      UI_status(buffer);      
      sts = om$send(msg= message GRgraphics.GRremwrng(&msg,md_env),
		    senderid = NULL_OBJID,
		    targetos = objects[ii].osnum,
		    targetid = objects[ii].objid);
      if(!(sts&msg&1)) continue;
      
      sts = om$send(msg = message NDmacro.ACreturn_foot(
							&msg, "geom",&gmId,NULL,NULL ),
		    senderid = NULL_OBJID,
		    targetid = objects[ii].objid,
		    targetos = objects[ii].osnum);
      if(!(sts&msg&1)) goto add_back;
      
      sts =
	vd_$get_components(  msg             = &msg,
			     grobjId         = &gmId,
			     grobjEnv        = md_env,
			     number          = &ncomp,
			     components      = &comps );
      if(!(sts&msg&1))  goto add_back;
      if(ncomp == 0)  goto add_back;
      
      for(jj=0; jj<ncomp; jj++)
	{
	  newObj.osnum = md_env->md_id.osnum;
	  if (EFisAncestryValid(&msg, comps[jj].objid, comps[jj].osnum,
				OPP_EMSsubbs_class_id, FALSE))
	    {
	      sts = om$send(msg = message EMSsubbs.EMreduce_range(&msg,
								  md_env, &newObj.objid, 0),
			    senderid = NULL_OBJID,
			    targetid = comps[jj].objid,
			    targetos = comps[jj].osnum);
	  if(!(sts&msg&1))
	    {
	      //printf("\n EMSsubbs.EMreduce_range failed \n");
	    }
	  /*	  
		  sts =
		  _VD_SEND_OBJN(  newObj,
		  GRconnector.GRrigidconn(&msg, &gmId, &inConn ));
	  __CheckRC( sts, msg, "GRconnector.GRrigidconn", wrapup );
	  */
	    }
	}
    add_back:
      sts = om$send(msg= message GRgraphics.GRaddwrng(&msg,md_env),
		    senderid = NULL_OBJID,
		    targetos = objects[ii].osnum,
		    targetid = objects[ii].objid);
      if(!(sts&msg&1)) continue;      
    }
  retFlag = 1;
 wrapup:
  _FREE(comps);
  return retFlag;
}
/* This function deletes the non locatable and non displayable VDdrw3d objects
* from the supplied list ; this is interfaced with ppl COz_deldrw3d.u
*/
IGRint VDdrw3dDelete(struct GRid *drwObjs,
		     struct GRmd_env *mdEnv,
		     int count)
{
  IGRint retFlag = 0,ii;
  IGRlong sts,msg;
  struct GRid *delList = NULL;
  IGRint badCount = 0;
  IGRshort props;
  IGRchar buffer[1024];
  
  if((!drwObjs) || (count == 0)) goto wrapup;
  delList = _MALLOC(count,struct GRid);
  if(!delList) goto wrapup;
  
  for(ii=0; ii<count; ii++) 
    {
      sts = om$send(msg = message GRgraphics.GRgetprops(&msg,&props), 
		    senderid = NULL_OBJID,
		    targetid = drwObjs[ii].objid,
		    targetos = drwObjs[ii].osnum);
      if(!(sts&msg&1)) continue; 
      
      if(!(props & GRIS_DISPLAYABLE)) 
	{
	  delList[badCount].objid = drwObjs[ii].objid;
	  delList[badCount].osnum = drwObjs[ii].osnum;
	  badCount++; 
	}
    } 
  __DBGpr_int("badCount ",badCount);
  if((delList != NULL) &&( badCount != 0 )){
    __DBGpr_objlist("delList",badCount,delList);
    sprintf(buffer,"%d non_locatable/displayable VDdrw3d Objects Found",badCount);
    UI_status(buffer);
    sleep(1);
    __DBGpr_int("badCount ",badCount);
    vd_$bulk_delete(count	= badCount,
		    grids	= delList,
		    theEnv	= mdEnv );
  }
  retFlag = 1;
 wrapup:
  _FREE(delList);
  return retFlag;
} 
/*
  -------------------------------------------------------------------------
*/
end implementation VDdrw3d;

