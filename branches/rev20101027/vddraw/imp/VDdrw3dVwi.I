/* $Id: VDdrw3dVwi.I,v 1.1.1.1 2001/01/04 21:08:38 cvs Exp $ */
/*---------------------------------------------------------------------------
/*  I/VDS
 *
 * File:        vddraw/imp/VDdrw3dVwi.I
 *
 * Description:
 *
 *      This file implements the methods for the View Volume control object,
 *	which concatenates all 3d visualization objects.
 *
 * Dependencies:
 *      VDdrw3dVw.S
 *
 * History:
 *      06/06/94        adz		Creation date.
 *
 * -------------------------------------------------------------------------
 */

class implementation VDdrw3dVw;

/*
%safe
#include <math.h>
%endsafe
*/

#include <math.h>
#include "OMmacros.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include <stdio.h>
#include <string.h>
#include "msdef.h"
#include "refdef.h"
#include "madef.h"

#include "acdef.h"
#include "acmacros.h"
#include "asbox.h"
#include "dp.h"
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

#include "vds.h"
#include "VDSutil_def.h" 
#include "vdbatdrw.h"
#include "vdbatdrwmac.h"
#include "vddrwattr.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "VDmsg.h"
#include "SMmsg.h"
#include "v_dbgmacros.h"
#include "vdsetmacros.h"
#include "vdsmacros.h"


/*+mo
 -------------------------------------------------------------------------

  Overridden Message
       GRgetobjinfo from GRgraphics

  Abstract

	Reports information about the object. 
	It has been overriden to display the type of the main surface when it
	is located (status field).

  Arguments

      IGRlong		*msg             O   	completion code
      struct GRobj_info	*info            O	structure for information about
                                 		the object

  Status/Return Code
     OM_S_SUCCESS	if success;
     OM_E_ABORT		if fails

 -------------------------------------------------------------------------
-mo*/

method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
	/*
	 * layout:	Occurence Name - Design File.
	 */
	SetProc( VDdrw3dVw_GRgetobjinfo ); Begin

	sprintf( info->type, "3d View-Volume -%s-%s ",
			&me->info[0], &me->info[me->indx[1]] );

	*msg = MSSUCC;
	End ;
	return(OM_S_SUCCESS);
}

/*+mo
 -------------------------------------------------------------------------

  Overridden Message
       GRdelete from GRgraphics

  Abstract

	Delete the model set object and all the linked section objects.
	This will automatically delete all the volume cut members.

  Arguments

      IGRlong		*msg             O   	completion code
      struct GRmd_env	*md_env          I	structure for environment

  Status/Return Code
     OM_S_SUCCESS	if success;
     OM_E_ABORT		if fails



 -------------------------------------------------------------------------
-mo*/

method GRdelete(IGRlong *rc ; struct GRmd_env *md_env)
{
	/*
	 * If any VDdrw3d objects are connected to this
	 * object, recompute them.
	 */
	IGRint			sts = OM_S_SUCCESS ;
	OM_S_CHANSELECT		*to_drw ;

	SetProc( VDdrw3dVw_GRdelete ); Begin

	*rc = MSSUCC ;

	/*
	 * find the list of all the VDdrw3d object which are
	 * connect to this Volume Control object.
	 */
        sts =
        VDdrw_GetToDrwChannel( VD_O_drw3d, &to_drw );
        __CheckRC( sts, 1, "VDdrw_GetToDrwChannel", wrapup );

        sts =
	_VD_SEND_CHAN(	*to_drw, GRgraphics.GRdelete( rc, md_env ));
	__CheckRC( sts, *rc, "GRgraphics.GRdelete", wrapup );

	wrapup :

		sts =
		_VD_SEND_MY( VDdrw3dVw.VDdeleteIfEmpty( rc, md_env ));
		__CheckRC( sts, *rc, "VDdrw3dVw.VDdeleteIfEmpty", wrapup );
	
		End ;
		return	sts ;
}

/*----------------------------------------------------------------------------*/

method VDgetObjDef( long *msg ; VDobjDef *myDef ) {

	long		sts ;	/* OM return code	*/

	/*
	 * name.
	 */
	SetProc( VDdrw3dVw_VDgetObjDef ); Begin

	*msg	= MSSUCC ;

	myDef->info		= VD_I_ObjDrw3dVw ;
	myDef->type		= VD_O_drw3dVw ;

	sts	= OM_S_SUCCESS ;

	End ;
	return sts ;

} /* VDgetObjDef */

/*+mo
 -------------------------------------------------------------------------
  Public Message 
	ACconstruct_feet from NDnode

  Description:
 
      This file implements the ACconstruct_feet for the drawing object.
 
  Dependencies:
       VDdrw3dVw

  History:
	12/21/94	adz	creation date 
	07/18/95	adz	generate flexisble input list.
 
  -------------------------------------------------------------------------
 */

/* ******************* MSG ACconstruct_feet () ************************	*/

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
	 */

	IGRint			sts = OM_S_SUCCESS ,
				i, size;
	IGRlong			parProps ;
	IGRshort		action = 0 ,
				props  = GRIS_DISPLAYABLE | GRIS_LOCATABLE ;
	GRname			objName,
				objDesc,
				modFile;
	struct	GRobj_env	parObj,
				lstObj,
				volObj;

	SetProc( VDdrw3dVw_ACconstruct_feet ); Begin

	*msg = MSFAIL;
	i = 0;

#ifdef	vdsDEBUG
	for( i=0 ; i<count; i++ )	VD_ShowObj( & list[i] );
#endif

	/*
	 * Find the connected parent object. This can be of the class:
	 *
	 *	GRdrawview 	drawing-view
	 *	VDmdlview	model-view object.
	 *	VDviewvol	view-volume object.
	 *	EMSsolid	general solid object.
	 */
	lstObj._objid	= NULL_OBJID ;
	sts =
	_VD_SEND_OBJ(	list[1],
			NDnode.ASreturn_go(	&lstObj._grid,
						&lstObj._matrix_type,
						lstObj._matrix ));
	__CheckRC( sts, 1, "NDnode.ASreturn_go", wrapup );


	/*
	 * get owner object "VDmdlview". The Assource object can be 
	 * connected the to graphical component of the model-view.
	 */
	parObj = lstObj ;
	ASget_as_owner(	&lstObj._grid, &parObj._grid );
	if( parObj._objid == NULL_OBJID ) parObj = lstObj ;

	parObj._md_os = parObj._osnum ;
	sts = ex$get_modid(mod_osnum = parObj._md_os, mod_id = &parObj._md_id );

#ifdef	vdsDEBUG
	VD_ShowObj( &lstObj._grid );
	VD_ShowObj( &parObj._grid );
#endif

	/*
	 * get parent object information.
	 */
	sts =
	VDbat_GiveObjectInfo(	msg,
				&parObj._grid,
				&parProps,
				modFile,
				objName,
				objDesc );
	if( !( sts & *msg & 1 )){
		strcpy( objName, "Unknown" ); strcpy( objDesc, "Unknown" );
	}

	/*
	 * Get the solid object.
	 */
	sts =
	vd$drw_solids_from_data(	msg		= msg,
					dv_sol		= &parObj,
					props		= parProps,
					offset		= me->vol_offset,
					offset_sol	= &volObj );

	if( !(sts&*msg&1) )
        {
	  volObj.obj_id.osnum = OM_Gw_current_OS;
	  volObj.obj_id.objid = NULL_OBJID;
	  volObj.mod_env = *md_env;
          sts = 
          om$send( msg      = message GRgraphics.GRcopy(msg,
                                                        &parObj.mod_env,
                                                        md_env,
                                                        &volObj.obj_id.objid),
                   targetid = parObj.obj_id.objid,
                   targetos = parObj.obj_id.osnum );

        }
	__DBGpr_obj( "volObj", volObj.obj_id );

	/*
	 * Set Level for the solid.
	 */
	feet_list[0] = volObj._grid ;
	
	sts =
	_VD_SEND_OBJ( feet_list[0], GRvg.GRchglevel( msg, &me->level_3d ));
	__CheckRC( sts, *msg, "GRvg.GRchglevel", wrapup );

	/*
	 * initialize predefined attributes :
	 *		- model-view name,
	 *		- model-view description,
	 *		- design file name,
	 */
	
	modFile[0] = '\0';

	VD_drw_GetDesignName(   parObj._md_os, modFile, &parObj.mod_env );

	__DBGpr_str( "objName", objName );
	__DBGpr_str( "objDesc", objDesc );
	__DBGpr_str( "modFile", modFile );

        /*
         * concatenate information into instance buffer.
         */
        me->indx[0]     = strlen( objName ) + 1 ;
        me->indx[1]     = strlen( objDesc ) + 1 + me->indx[0] ;
        size            = strlen( modFile ) + 1 + me->indx[1] ;

        sts = om$vla_set_dimension( varray = me->info, size = size );

        strcpy( &me->info[0],           objName );
        strcpy( &me->info[me->indx[0]], objDesc );
        strcpy( &me->info[me->indx[1]], modFile );

	__DBGpr_obj( " Feet [0] ", feet_list[0] );

	/*
	 * set the display mode for the object to non-locate and 
	 * non-display.
	 */
	sts =
	_VD_SEND_MY( GRgraphics.GRchgprops( msg, &action, &props ));
	__CheckRC( sts, *msg, "GRgraphics.GRchgprops", wrapup );

	*fcount = 1 ;
#ifdef	vdsDEBUG
	for( i=0 ; i<*fcount; i++ )	VD_ShowObj( & feet_list[i] );
#endif

	*msg = MSSUCC;
	End ;
	return	OM_S_SUCCESS;
 
wrapup:
	*msg = MSFAIL;
	End ;
	return OM_W_ABORT;
}

/*+mo
 -------------------------------------------------------------------------
  Public Message 
	NDupdate from NDnode

  Description:
 
      This file implements the NDupdate for the object after modification.
 
  Dependencies:
	VDdrw3dVw

  History:
 
  -------------------------------------------------------------------------
 */


method	NDupdate(		IGRint		*msg;
				IGRint		cn_type; 
				IGRint		count;
				struct GRid	*parents;
				IGRint		*parent_state ;
				struct GRid	*context ;
				struct GRid	*new_objid ;
				struct GRmd_env	*md_env )
{
	IGRint		sts = OM_S_SUCCESS ;
	IGRlong		lmsg ;
	
	SetProc( VDdrw3dVw_NDupdate ); Begin

	*msg = MSSUCC ;

	sts =
	_VD_SEND_WRT_M( my_id, ACncpx.NDupdate(	msg,
						cn_type,
						count,
						parents,
						parent_state,
						context,
						new_objid,
						md_env ));
	__CheckRC( sts, *msg, "ACncpx.NDupdate", wrapup ) ;

	/*
	 * Check for obejcts to recompute.
	 */
        cn_type = ND_COMP;

	if( me->compute ){

		sts =
		_VD_SEND_MY(	VDSroot.VDcompute( &lmsg, &cn_type ));
		__CheckRC( sts, lmsg, "VDSroot.VDcompute", wrapup ) ;
	}

	wrapup :

		End ;
		return sts ;
}


/*+mo
 -------------------------------------------------------------------------
  Public Message 
	VDcompute from VDSroot

  Description:
 
      This file implements the VDcompute call for all VDdrw3d objects.
 
  Dependencies:
	VDdrw3dVw

  History:
 
  -------------------------------------------------------------------------
 */

method	VDcompute(	long		*msg;
			int		*type )
{
	/*
	 * find the list of all the VDdrw3d object which are
	 * connect to this Volume Control object.
	 */
	IGRint			sts = OM_S_SUCCESS ,
				oType = VD_O_drw3dObj,
				count,
				i ;
	struct	GRid		myGRid,
				*grids = NULL ;

	SetProc( VDdrw3dVw_VDcompute ); Begin

	myGRid.objid	= my_id ;
	myGRid.osnum	= OM_Gw_current_OS ;

        sts =
        VDdrw_GetChannelObjects( msg, &myGRid, NULL, oType, &count,&grids,NULL);
        __CheckRC( sts, *msg, "VDdrw_GetChannelObjects", wrapup );

	__DBGpr_int(" Object Found ", count );

	for( i=0 ; i<count ; i++ ){

		sts =
		om$send(msg = message VDSroot.VDcompute( msg, type),
			targetid = grids[i].objid,
			targetos = grids[i].osnum,
			senderid = grids[i].objid );	
	}

	wrapup :

		_FREE( grids );
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

	/*
	 * Put the properties to no proptect:
	 *	- Does not create source,
	 *	- Does not verify the number (variable number of templates) 
	 *	- Does not verify the template types
	 */

	IGRint		sts = OM_S_SUCCESS ;

	SetProc( VDdrw3dVw_ACmplace_from_def ); Begin

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
		End ;
		return	sts;
}

/*me+
 -------------------------------------------------------------------------
  Public Message
        GRputattr	from GRvg

  Abstract
        Set the instance info for section object.

  Arguments
        OUT     long            *msg            Completion code.
	IN	VDpartAttr	*attr		Information.

  Note

 -------------------------------------------------------------------------
-mo*/

method	GRputattr(	IGRlong         *msg ;
                        IGRchar		*attr ){

	IGRint			sts = OM_S_SUCCESS,
				lenInfo ;
	VDpartAttr		*part;

	SetProc( VDdrw3dVw_Grputattr ); Begin

	*msg	= MSSUCC ;
	part	= (VDpartAttr *) attr ;

	switch(	part->Iwant ) {

	case	VD_I_drwInitialization	:

		me->compute	= FALSE ;
		me->vol_offset	= 0.0 ;
		me->level_3d	= 1 ;
		strcpy(	me->visual_3d, "" );

		break ;
        case    VD_I_drwInternalName    :

                lenInfo = 1 + strlen( part->aString );
                om$vla_set_dimension( varray = me->name, size = lenInfo );
                strcpy( me->name, part->aString );
                __DBGpr_str(" name  ", me->name  );

		break ;
	case	VD_I_drwCompute	:

		me->compute	= part->aInt ;

		break ;
	case	VD_I_drwOffset	:

		me->vol_offset	= part->aValue ;

		break ;
	case	VD_I_drwLevel	:

		me->level_3d	= part->aType ;

		break ;
	case	VD_I_drwVisual	:

                lenInfo = 1 + strlen( part->aString );
		sts =
                om$vla_set_dimension( varray = me->visual_3d, size = lenInfo+1);
                strcpy( me->visual_3d, part->aString );
                __DBGpr_str(" visual_3d  ", me->visual_3d  );

		break ;
	default :

		__DBGpr_int(" Unknown Type ", part->Iwant );
		goto wrapup ;
	}

	wrapup:
		End ;
		return OM_S_SUCCESS ;
}

/*me+
 -------------------------------------------------------------------------
  Public Message
        GRgetattr

  Abstract
        Get the instance info of object.

  Arguments
        OUT     long            *msg            Completion code.
	OUT	VDpartAttr	*attr		Information.

  Note

 -------------------------------------------------------------------------
-mo*/

method GRgetattr(	IGRlong         *msg ;
			IGRchar		*attr ){

	VDpartAttr		*part ;

	SetProc( VDdrw3dVw_VDgetInfo ); Begin

	*msg	= MSSUCC ;
	part	= (VDpartAttr *) attr ;

	switch(	part->Iwant ) {

	case	VD_I_drwInitialization	:

		__DBGpr_com(" Invalid Option " );
		*msg = OM_E_INVARG ;

		break ;
        case    VD_I_drwInternalName    :

                strcpy( part->aString, me->name );
                __DBGpr_str( " Info ", part->aString );

                break ;
	case	VD_I_drwCompute	:

		part->aInt	= me->compute ;

		break ;
	case	VD_I_drwOffset	:

		part->aValue	= me->vol_offset ;

		break ;
	case	VD_I_drwLevel	:

		part->aType	= me->level_3d ;

		break ;
	case	VD_I_drwVisual	:

		strcpy( part->aString, me->visual_3d );

		break ;
	default :

		__DBGpr_int(" Unknown Type ", part->Iwant );
	}

	End ;
	return OM_S_SUCCESS ;
}

/*+mo
 -------------------------------------------------------------------------
  Private Message 
	VDdeleteIfEmpty 

  Description:
	Delete the object itself under certain conditions.
 
  Dependencies:
	VDdrw3dVw

  History:
  -------------------------------------------------------------------------
 */

method	VDdeleteIfEmpty(	IGRlong			*msg;
				struct	GRmd_env	*md_env ){

	long		        sts = OM_S_SUCCESS ;
	OMuint			cnt = 0 ;
	IGRint			action = 0 ;
	OM_S_CHANSELECT		*to_drw;

	SetProc( VDdrw3dVw_VDdeleteIfEmpty ); Begin

	*msg = MSSUCC;

	sts = VDdrw_GetToDrwChannel( VD_O_drw3d, &to_drw );
	__CheckRC( sts, 1, "VDdrw_GetToDrwChannel", wrapup );

	sts =
	om$get_channel_count(	objid		= my_id,
				p_chanselect	= to_drw,
				count		= &cnt );
	__CheckRC( sts, 1, "om$get_channel_count", wrapup );

        __DBGpr_int( "count ", cnt );

	if( ! cnt ){

		struct	GRid	myGRid ;

		myGRid.objid	= my_id ;
		myGRid.osnum	= OM_Gw_current_OS ;
		/*
		 * check if object exist in VDbatData object -> remove it.
		 */
		sts =
		VDbat_UpdateControlData( msg, md_env, &myGRid, action );
		CheckRC( sts, *msg );
	
		sts =
		_VD_SEND_WRT_M(	my_id, ASnode.GRdelete( msg, md_env ));
		__CheckRC( sts, *msg, "ASnode.GRdelete", wrapup );
	}
	
	wrapup:
		End ;
		return sts ;
}

/*
  -------------------------------------------------------------------------
 */

end implementation VDdrw3dVw;
 
