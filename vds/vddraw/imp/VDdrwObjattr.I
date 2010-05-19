/* $Id: VDdrwObjattr.I,v 1.1.1.1 2001/01/04 21:08:38 cvs Exp $ */
/*---------------------------------------------------------------------------
/*  I/VDS
 *
 * File:        vddraw/imp/VDdrwObjattr.I
 *
 * Description:
 *
 *      This file implements the methods GRgetattr and GRputattr for the
 *	visualization objects.
 *
 * Dependencies:
 *      VDdrwObj.S
 *
 * Revision History
 *	$Log: VDdrwObjattr.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:38  cvs
 *	Initial import to CVS
 *	
# Revision 1.2  2000/02/27  14:39:06  pinnacle
# Replaced: vddraw/imp/VDdrwObjattr.I for:  by impd252 for vds
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1998/04/10  14:42:08  pinnacle
# Replaced: vddraw/imp/VDdrwObjattr.I for:  by azuurhou for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.4  1995/09/25  13:34:08  pinnacle
# Replaced: vddraw/imp/VDdrwObjattr.I for:  by azuurhou for vds.240
#
# Revision 1.3  1995/07/11  20:15:48  pinnacle
# Replaced: vddraw/imp/VDdrwObjattr.I for:  by azuurhou for vds.240
#
# Revision 1.1  1995/06/27  18:26:00  pinnacle
# Created: vddraw/imp/VDdrwObjattr.I by azuurhou for vds.240
#
 *
 * History:
 *	06/23/95	adz		creation date
 *	02/27/00	adz		Check for consumed parents (TR179900701)
 * -------------------------------------------------------------------------
 */

class implementation VDdrwObj;

#include <string.h>
#include "OMmacros.h"
#include "OMprimitives.h"
#include "exdef.h"
#include "exmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "asmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "vddrwattr.h"
#include "vds.h"
#include "VDmsg.h"

/*
 * Define the hardcoded limits of the buffer for processing the parent
 * information (macro/name/design).
 *
 * Buffer:  Macro Name xxxx\0  Object name \0   Design Name \0
 *  Index:  0                  16               57
 */

#define	VD_K_drwMacroMax	15
#define	VD_K_drwNameMax		40
#define	VD_K_drwDesignMax	15

#define	VD_K_drwNameIndex	16
#define	VD_K_drwDesignIndex	57

#define	VD_K_drwInfoMax		73

/*+mo
 -------------------------------------------------------------------------
  Public Message 
	GRputattr	from GRvg

  	Retrieve the attributes from the VDdrwObj object.

  Arguments
	IGRlong         *msg		O : Completion code.
	VDpartAttr	*attr		I : Attribute Structure.

  Status/Return Code

	OM_S_SUCCESS	if success;
	OM_E_ABORT	if fails
 -------------------------------------------------------------------------
-me*/

method GRputattr(	IGRlong			*msg;
			IGRchar			*attr ){

	IGRint			sts = OM_S_SUCCESS ;
	VDpartAttr		*part ;		/* Part Attributes	*/
	VDdrwObjInfo		*objInfo ;
	int			size ;
	GRname			locMacro, locName, locDesign ;

	SetProc( VDdrwObj_GRputattr ); Begin

	/*
	 * get info
	 */
	*msg	= MSSUCC;
	part	= (VDpartAttr *) attr ;

	switch(	part->Iwant ){

	case VD_I_drwInitialization :

		om$vla_set_dimension(	varray = me->info , 
					size = VD_K_drwInfoMax );
		me->info[0]		      = '\0' ;
		me->info[VD_K_drwNameIndex]   = '\0' ;
		me->info[VD_K_drwDesignIndex] = '\0' ;
		me->indx[0] = 0 ;
		me->indx[1] = 0 ;
		me->stsMask = 0 ;

		break ;

	/*
	 * Object Interaction types.
	 */
	case VD_I_drwParentObj :	/* Get the 2d/3d parent     */
	case VD_I_drwGeometObj :	/* VDdrwGm Object	    */
	case VD_I_drwParentCtx :	/* Parent Context object    */	
	case VD_I_drwAttribObj :	/* Get collector object     */

		__DBGpr_com(" No Object Interaction types " );
		break;

	/*
	 * Object Values types.
	 */
	case VD_I_drwMacroInfo :	/* Object + Graphical Macro */
	case VD_I_drwOccurInfo :	/* Occurence Object Name    */
	case VD_I_drwDesgnInfo :	/* Parent Design File       */
	case VD_I_drwAllObjInfo:	/* Macro/Occurence/Design   */

        	/*
		 * concatenate information into instance buffer.
		 */
		size = om$dimension_of(	varray	= me->info );

		locMacro[0]	= '\0' ;
		locName[0]	= '\0' ;
		locDesign[0]	= '\0' ;

		if( size == VD_K_drwInfoMax ){
		  /*
		   * Somebody has been working with the information.
		   * Get the old stuff and copy the new (if available).
		   */
		  strcpy( locMacro  , me->info		 );
		  strcpy( locName   , &me->info[VD_K_drwNameIndex] );
		  strcpy( locDesign , &me->info[VD_K_drwDesignIndex] );
		}

		if( part->Iwant == VD_I_drwMacroInfo )
			strncpy(locMacro,  part->aString, VD_K_drwMacroMax );
		if( part->Iwant == VD_I_drwOccurInfo )
			strncpy(locName,   part->aString, VD_K_drwNameMax );
		if( part->Iwant == VD_I_drwDesgnInfo )
			strncpy(locDesign, part->aString, VD_K_drwDesignMax );

		if( part->Iwant == VD_I_drwAllObjInfo ){

		  objInfo = (VDdrwObjInfo *) part->specific ;
		  if( objInfo->objMacro )
		    strncpy( locMacro,  objInfo->objMacro, VD_K_drwMacroMax );
		  if( objInfo->objName )
		    strncpy( locName,   objInfo->objName, VD_K_drwNameMax );
		  if( objInfo->objDesign )
		    strncpy( locDesign, objInfo->objDesign, VD_K_drwDesignMax );
		}
	
		/*
		 * Reconcatenate the information into the buffer.
		 */
		size = VD_K_drwInfoMax ;

		sts =
		om$vla_set_dimension(	varray  = me->info ,
					size    = size );

		strncpy( me->info, locMacro, VD_K_drwMacroMax );
		strncpy( &me->info[VD_K_drwNameIndex], locName,
							VD_K_drwNameMax );
		strncpy( &me->info[VD_K_drwDesignIndex], locDesign,
							VD_K_drwDesignMax );

		break;
	case VD_I_drwAttrbInfo :	/* Give objects attr        */

		break;

	/*
	 * Object State types.
	 */
        /*
         * Object state information.
         *
         *      Bit states                      0x.... ....
         *          (0)         /    (1)
         *
         *      Select          / Trans         0x.... ...1
         *      Active          / Detached      0x.... ..1.
         *      Locatable       / Non ...       0x.... .1..
         *      Model Object    / Implied Mat   0x.... 1...
         *
         *      Associative     / Non ...       0x1... ....
         *
         */

	case VD_I_drwGetStsMask :	/* Get bit mask of object   */

		__DBGpr_com(" No Object Interaction types " );

		break;

	case VD_I_drwSetStsMask :	/* Set bit mask of object   */
	case VD_I_drwAddStsMask :	/* operation mask |= mask   */

		if( part->Iwant == VD_I_drwSetStsMask )
			me->stsMask	= part->aType ;
		else
			me->stsMask	|= part->aType ; 

		if( part->aType & VD_B_drwNonAssociative ){
			
			IGRchar		mask, n_state ;

			mask	= me->state | ND_DEGRADED ;
			n_state	= ND_DEGRADED ;
			sts =
			_VD_SEND_MY( NDnodein.NDchg_state( mask, n_state ));
			__DBGpr_int(" New State ", me->state );
		}
		break;
	case VD_I_drwDelStsMask :	/* operation mask &= mask   */

		me->stsMask	&= ~part->aType ;
		break;

	case VD_I_drwChkStsMask :	/* Check of mask is valid   */
		__DBGpr_com(" No Object Interaction types " );
		break;

	case VD_I_drwSelectMask :

		/*
		 * Putting for the select set mask.
	 	 */
		me->indx[0]	= part->aType ;

		break ;

	default :

		__DBGpr_int(" UNknown Iwant ", part->Iwant );
		*msg = MSFAIL ;
		goto wrapup;
	}

	wrapup :
		End;
		return sts ;
}

/*+mo
 -------------------------------------------------------------------------
  Public Message 
	GRgetattr	from GRvg

  Abstract
  	Retrieve the attributes from the VDdrwObj object.

  Arguments
	IGRlong         *msg		O : Completion code.
	VDpartAttr	*attr		O : Attribute Structure.

  Status/Return Code

	OM_S_SUCCESS	if success;
	OM_E_ABORT	if fails
 -------------------------------------------------------------------------
-me*/

method GRgetattr(	IGRlong			*msg;
			IGRchar			*attr ){

	IGRint			sts = OM_S_SUCCESS ;	/* OMreturn code   */
	VDpartAttr		*part ;		/* Part Attributes	*/
	struct	GRid		lObjId ;
	struct	GRobj_env	chdObj ;
	VDdrwObjInfo		*objInfo ;
	IGRint			cnt;

	SetProc( VDdrwObj_GRgetattr ); Begin

	/*
	 * get info
	 */
	*msg	= MSSUCC;
	part	= (VDpartAttr *) attr ;

	switch(	part->Iwant ){

	/*
	 * GETATTR --- Object Interaction types.
	 */
	case VD_I_drwParentCtx :	/* Parent Context object    */	
	case VD_I_drwParentObj :	/* Get the 2d/3d parent     */

		part->obj._objid = NULL_OBJID ;
		sts =
		_VD_SEND_MY(	NDnode.NDget_objects(
						ND_ROOT, &part->obj._grid,
						1, NULL, 1, 1, &cnt ));
		if( (!(sts&1))||( part->obj._objid == NULL_OBJID )){
			*msg = MSFAIL ;
			goto wrapup ;
		}
		__DBGpr_obj(" Pretend Object ", part->obj._grid );

		if( part->Iwant == VD_I_drwParentCtx ){
			sts =
			VD_drw_GetCtxAndRefFromSrc( &part->obj._grid,
					&lObjId, (struct GRid *) NULL );
			part->obj._grid = lObjId ;
			__DBGpr_obj(" Context Obj ", part->obj._grid );
		}
		else{
			sts =
			_VD_SEND_OBJ(	part->obj._grid,
					NDmacro.ACreturn_foot(
						msg,
                                                "",
                                                &part->obj._grid,
                                                &part->obj._matrix_type,
                                                part->obj._matrix ));
			if( !(sts&*msg&1)){
				*msg = MSFAIL ;
				goto wrapup ;
			}
			part->obj._md_os = part->obj._osnum ;
			sts =
			ex$get_modid(	mod_osnum	= part->obj._md_os,
					mod_id		= &part->obj._md_id );

			__DBGpr_obj(" Dady1 Obj ", part->obj._grid );
			/*
			 * Check of object is consumed.
			 */
			VDatGetConsumingChild( &(part->obj), &chdObj );
			part->obj = chdObj ;
			__DBGpr_obj(" Dady2 Obj ", part->obj._grid );
		}

		break ;
	case VD_I_drwGeometObj :	/* VDdrwGm Object	    */

	        sts =
		_VD_SEND_MY(	NDmacro.ACreturn_foot(
						msg,
						"geom",
						&part->obj._grid,
                                                &part->obj._matrix_type,
                                                part->obj._matrix ));
		__CheckRC( sts, 1, "NDmacro.ACreturn_foot", wrapup );

		part->obj._md_os = part->obj._osnum ;
		sts =
		ex$get_modid(	mod_osnum	= part->obj._md_os,
				mod_id		= &part->obj._md_id );

		__DBGpr_obj(" Geom Obj ", part->obj._grid );

		break ;
	case VD_I_drwAttribObj :	/* Get collector object     */

		sts =
		_VD_SEND_MY(	NDnode.NDget_objects(
						ND_ROOT, &part->obj._grid,
						0, NULL, 0, 0, &cnt ));
		__CheckRC( sts, 1, "NDnode.NDget_objects", wrapup ) ;

		__DBGpr_obj(" Attr Obj ", part->obj._grid );

		break;

	/*
	 * GETATTR --- Object Values types.
	 */
	case VD_I_drwMacroInfo :	/* Object Macro Name        */

		strncpy( part->aString, me->info, VD_K_drwMacroMax );
		part->aInt = strlen( part->aString );
		__DBGpr_str(" Object Info ", part->aString );

		break;
	case VD_I_drwOccurInfo :	/* Occurence Object Name    */

		strncpy( part->aString, &me->info[VD_K_drwNameIndex],
			VD_K_drwNameMax );
		part->aInt = strlen( part->aString );
		__DBGpr_str(" Object Info ", part->aString );

		break;
	case VD_I_drwDesgnInfo :	/* Parent Design File       */

		strncpy( part->aString, &me->info[VD_K_drwDesignIndex],
					VD_K_drwDesignMax );
		part->aInt = strlen( part->aString );
		__DBGpr_str(" Object Info ", part->aString );

		break;

	case VD_I_drwAllObjInfo :	/* Macro/Occurence/Design   */
		objInfo = (VDdrwObjInfo *) part->specific ;
		if( objInfo->objMacro )
			strncpy( objInfo->objMacro,
				 me->info, VD_K_drwMacroMax );
		if( objInfo->objName )
			strncpy( objInfo->objName,  
				&me->info[VD_K_drwNameIndex],VD_K_drwNameMax );
		if( objInfo->objDesign )
			strncpy( objInfo->objDesign,
			   &me->info[VD_K_drwDesignIndex],VD_K_drwDesignMax );

		break;
	case VD_I_drwAttrbInfo :	/* Give objects attr        */

		break;

	/*
	 * GETATTR --- Object State types.
	 *
         * Object state information.
         *
         *      Bit states                      0x.... ....
         *          (0)         /    (1)
         *
         *      Select          / Trans         0x.... ...1
         *      Active          / Detached      0x.... ..1.
         *      Locatable       / Non ...       0x.... .1..
         *      Model Object    / Implied Mat   0x.... 1...
         *
         *      Associative     / Non ...       0x1... ....
         *
         */
	case VD_I_drwGetStsMask :	/* Get bit mask of object   */

		part->aType	= me->stsMask ;

		break ;
	case VD_I_drwSetStsMask :	/* Set bit mask of object   */
	case VD_I_drwAddStsMask :	/* operation mask |= mask   */
	case VD_I_drwDelStsMask :	/* operation mask &= mask   */

		__DBGpr_com(" No Object Interaction types " );

		break;
	case VD_I_drwChkStsMask :	/* Check of mask is valid   */

		*msg = me->stsMask & part->aType ;
		break ;

	case VD_I_drwSelectMask :

		/*
		 * Adding for the select set mask.
	 	 */
		part->aType	= me->indx[0] ;

		break ;

	default :

		__DBGpr_int(" Unknown Iwant ", part->Iwant );
		*msg = MSFAIL ;
		goto wrapup ;
	}

	wrapup :
		End;
		return sts;
} /* GRgetattr */

/*----------------------------------------------------------------------------*/

end implementation VDdrwObj;

