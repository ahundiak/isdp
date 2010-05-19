/* $Id: SinglePlane.I,v 1.1.1.1 2001/01/04 21:07:34 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	smframe/api/SinglePlane.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SinglePlane.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:34  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1998/03/27  19:14:30  pinnacle
# CR_179800868: Replaced smframeapi.h with smAPImacros.h
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.2  1996/02/21  14:45:40  pinnacle
# Replaced: smframe/api/SinglePlane.I for:  by v240_int for vds.240
#
# Revision 1.1  1996/02/20  20:33:46  pinnacle
# Created: ./smframe/api/SinglePlane.I by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *      03/27/98   ejm          CR_179800868: Replaced smframeapi.h with
 *                              smAPImacros.h (to eliminate duplicate
 *                              prototypes).
 *
 ***************************************************************************/

class implementation Root;

#include        <stdio.h>
#include        <string.h>
#include        "igetypedef.h"
#include        "igrtypedef.h"
#include        "OMminimum.h"
#include        "OMerrordef.h"
#include        "igrdef.h"
#include        "igr.h"
#include        "exdef.h"
#include        "ex.h"
#include        "igrdp.h"
#include        "gr.h"
#include        "growner.h"
#include        "godef.h"
#include        "go.h"
#include        "griodef.h"
#include        "grio.h"
#include        "grdpbdef.h"
#include        "grdpbmacros.h"
#include        "msdef.h"
#include        "msmacros.h"
#include        "exmacros.h"
#include        "AS_status.h"
#include        "ACrg_collect.h"
#include        "nddef.h"
#include        "ndmacros.h"
#include        "asbox.h"
#include        "asmacros.h"
#include        "expression.h"
#include        "expmacros.h"
#include        "macro.h"
#include        "dp.h"
#include        "grmacros.h"
#include        "parametric.h"

#include        "DIdef.h"
#include        "DItypedef.h"
#include        "DIglob.h"
#include        "DIprims.h"

#include        "vdsmacros.h"
#include        "SMframe.h"

#include        "smframedef.h"
#include        "smAPImacros.h"

/* External SMAN functions used by SMcreate_single_plane() */
extern	IGRboolean	SMfr_convert_unit_int();

/* External SMAN classes used by SMcreate_single_plane() */
extern	GRclassid	OPP_SMInfPlane_class_id;

/* Imported messages used by SMcreate_single_plane() */
from	ACncpx		import	ACmplace;
from	GRvg		import	GRputname;

/* Imported messages used by SMmodify_single_plane() */
from	GRvg		import	GRchgname, GRgetname;
from	NDnode		import	NDget_objects,
				NDchange_connect,
				NDgive_structure,
				NDs_compute_node;

/* ***** */

IGRboolean CSPinitCst (	struct	GRvg_construct	*cst	) {

IGRint			sts;
IGRlong			msg, siz, ret;
struct	GRmd_env	Env;
IGRshort		Level;
struct	IGRdisplay	Dis;

	/* Get active environment */
	siz=sizeof(struct GRmd_env);
	sts = gr$get_module_env ( msg	 = &msg,
				  sizbuf = &siz,
				  buffer = &Env,
				  nret   = &ret );
	as$status ( sts    = sts,
                    msg    = "gr$get_module_env()",
                    test   = (!(sts & 0x00000001 & msg)),
                    action = RET_VALUE,
                    value  = FALSE );

	/* Get active display */
	siz=sizeof(struct IGRdisplay);
	gr$get_active_display ( msg    = &msg,
				sizbuf = &siz,
				buffer = &Dis,
				nret   = &ret );
	as$status ( sts    = sts,
                    msg    = "gr$get_active_display()",
                    test   = (!(sts & 0x00000001 & msg)),
                    action = RET_VALUE,
                    value  = FALSE );

	/* Get active level */
	siz=sizeof(IGRshort);
	gr$get_active_level ( msg    = &msg,
			      sizbuf = &siz,
			      buffer = &Level,
			      nret   = &ret );
	as$status ( sts    = sts,
                    msg    = "gr$get_active_level()",
                    test   = (!(sts & 0x00000001 & msg)),
                    action = RET_VALUE,
                    value  = FALSE );

	/* Initialize construction list */
	cst->msg	= &msg;
	cst->env_info	= &Env;
	cst->display	= &Dis;
	cst->geometry	= NULL;
	cst->newflag	= FALSE;
	cst->level	= Level;
	cst->properties	= GRIS_LOCATABLE | GRIS_DISPLAYABLE;
	cst->class_attr	= NULL;
	cst->name	= NULL;

	return TRUE;
}

/* ***** */

IGRboolean CSPconvert (		IGRdouble	*value,
				IGRchar		*unit	) {

	IGRdouble	convert;
	
	if (SMfr_convert_unit_int ( *value, unit, &convert ) ) {
		*value = convert;
		return TRUE;
	}
	else	return FALSE;
}

/* ***** */

IGRboolean CSPnewName	(	IGRchar		*nam	)	{

	IGRint	sts;
	DIchar	*wrk;
	DIobjid	obj;

	/* Search already existing named object in local EMS directory */
	obj = NULL_OBJID;
	sts = di$translate ( objname = nam, p_objid = &obj );
	if ( (sts != DIR_S_SUCCESS) || (obj == NULL_OBJID) )	return TRUE;
	else {	/* Search the last underscore character */
		wrk = (DIchar *) strrchr ( nam, '_' );
		if (wrk == NULL) {
			strcat ( nam, "_" );
			return (CSPnewName ( nam ) );
		}
		else {	IGRint	i;
			wrk++;

			for ( i=0; i<10000; i++ ) {
				sprintf ( wrk, "%d", i );
				obj = NULL_OBJID;
				sts = di$translate ( objname = nam,
						     p_objid = &obj );
				if (  (sts != DIR_S_SUCCESS)
				   || (obj == NULL_OBJID) )	return TRUE;
			}
			return FALSE;
		}
	}
}

/* ***** */

IGRlong	SMcreate_single_plane (	IGRlong			*msg,
				struct	GRid		*csId,
				struct	GRmd_env	*csEnv,
				IGRint			axis,
				IGRdouble		distance,
				IGRchar			*distUnit,
				IGRint			planeSize,
				IGRdouble		*planeValue,
				IGRchar			*name,
				IGRchar			*label,
				IGRint			orientation,
				IGRint			wJustif,
				IGRint			hJustif,
				struct	GRid		*singlePlaneId	) {

	IGRlong		sts=OM_S_SUCCESS, siz=sizeof(struct GRmd_env), ret;
struct	GRmd_env	Env;
	IGRchar		axe[2], just[3], Label[DI_PATH_MAX], Name[DI_PATH_MAX];
	IGRdouble	size;
struct	GRid		Root[7];

	/* Initialize */
	*msg = MSFAIL;
	singlePlaneId->objid = Root[0].objid = NULL_OBJID;
	if (!name) {
		printf( "SMcreate_single_plane() : a name must be given !\n" );
		goto wrapup;
	}
	else	strcpy ( Name, name );

	/* Get active environment */
	sts = gr$get_module_env ( msg	 = msg,
				  sizbuf = &siz,
				  buffer = &Env,
				  nret   = &ret );
	as$status ( sts    = sts,
                    msg    = "gr$get_module_env()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	*msg = MSFAIL;

	/* Set active osnum in objects */
	singlePlaneId->osnum = Root[0].osnum = Env.md_id.osnum;

	/* Increment name */
	if (! CSPnewName (Name) )	goto wrapup;

	/* Root 0 : coordinate system object */
	sts = as$make_source ( go_grid = *csId,
			       mod_env = csEnv,
			       as_os   = Env.md_id.osnum,
			       as_grid = &Root[0] );
	as$status ( sts    = sts,
                    msg    = "as$make_source(cs)",
                    test   = (!(sts & 0x00000001)),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Evaluate axis */
	switch (axis) {
                case SM_FA_Xaxis:	axe[0] = 'x';	break;
                case SM_FA_Yaxis:	axe[0] = 'y';	break;
                case SM_FA_Zaxis:	axe[0] = 'z';	break;
                default :
			printf ( "SMcreate_single_plane : unknown axis <%d>\n",
                                axis );
                        goto wrapup;
        }
	axe[1] = '\0';

	/* Root 1 : axis expression */
	sts = exp$create ( exp_syntax = axe,
			   p_exp_id   = &Root[1].objid,
			   osnum      = Env.md_id.osnum,
			   p_osnum    = &Root[1].osnum,
			   type_rq    = EXP_TEXT );
	as$status ( sts    = sts,
                    msg    = "exp$create(axis)",
                    test   = (!(sts & 0x00000001)),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Root 2 : distance expression */
	if (! CSPconvert ( &distance, distUnit ) )	goto wrapup;
	sts = exp$create ( exp_value  = distance,
			   p_exp_id   = &Root[2].objid,
			   osnum      = Env.md_id.osnum,
			   p_osnum    = &Root[2].osnum );
	as$status ( sts    = sts,
                    msg    = "exp$create(distance)",
                    test   = (!(sts & 0x00000001)),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Evaluate plane size */
	if (! CFSplnSize ( &size, planeSize, planeValue, distUnit ) )
		goto wrapup;

	/* Root 3 : size expression */
	sts = exp$create ( exp_value  = size,
			   p_exp_id   = &Root[3].objid,
			   osnum      = Env.md_id.osnum,
			   p_osnum    = &Root[3].osnum );
	as$status ( sts    = sts,
                    msg    = "exp$create(size)",
                    test   = (!(sts & 0x00000001)),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Root 4 : label expression */
	if ( (!label) ||  (! strcmp ( label, "$0" ) ) )
		strcpy ( Label, Name );
	else	strcpy ( Label, label);
	sts = exp$create ( exp_syntax = Label,
			   p_exp_id   = &Root[4].objid,
			   osnum      = Env.md_id.osnum,
			   p_osnum    = &Root[4].osnum,
			   type_rq    = EXP_TEXT );
	as$status ( sts    = sts,
                    msg    = "exp$create(label)",
                    test   = (!(sts & 0x00000001)),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Root 5 : orientation expression */
	sts = exp$create ( exp_value  = (IGRdouble) orientation,
			   p_exp_id   = &Root[5].objid,
			   osnum      = Env.md_id.osnum,
			   p_osnum    = &Root[5].osnum );
	as$status ( sts    = sts,
                    msg    = "exp$create(orientation)",
                    test   = (!(sts & 0x00000001)),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Evaluate justification */
	if (! CFSjustif ( &just[0], wJustif ) )	goto wrapup;
	if (! CFSjustif ( &just[1], hJustif ) )	goto wrapup;
	just[2] = '\0';

	/* Root 6 : justification expression */
	sts = exp$create ( exp_syntax = just,
			   p_exp_id   = &Root[6].objid,
			   osnum      = Env.md_id.osnum,
			   p_osnum    = &Root[6].osnum,
			   type_rq    = EXP_TEXT );
	as$status ( sts    = sts,
                    msg    = "exp$create(justification)",
                    test   = (!(sts & 0x00000001)),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Construct single plane */
	sts = om$construct ( classid = OPP_SMInfPlane_class_id,
			     osnum   = Env.md_id.osnum,
			     p_objid = &singlePlaneId->objid );
	as$status ( sts    = sts,
                    msg    = "om$construct(SMInfPlane)",
                    test   = (!(sts & 0x00000001)),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Place single plane */
	sts = om$send ( msg = message ACncpx.ACmplace ( (IGRint *) msg,
							ACcant_place_sym,
							0, "SMInfPlane",
			  				7, Root, &Env ),
			senderid = NULL_OBJID,
			targetid = singlePlaneId->objid,
			targetos = singlePlaneId->osnum );
	as$status ( sts    = sts,
                    msg    = "ACncpx.ACmplace",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
			    
	/* Name single plane */
	sts = om$send ( msg = message GRvg.GRputname ( msg, Name ),
			senderid = NULL_OBJID,
			targetid = singlePlaneId->objid,
			targetos = singlePlaneId->osnum );
	as$status ( sts    = sts,
                    msg    = "GRvg.GRputname",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

wrapup:
	return (sts);
}

/* ***** */

IGRlong	SMmodify_single_plane (	IGRlong			*msg,
				struct	GRid		*singlePlaneId,
				struct	GRid		*csId,
				struct	GRmd_env	*csEnv,
				IGRint			*axis,
				IGRdouble		*distance,
				IGRchar			*distUnit,
				IGRint			*planeSize,
				IGRdouble		*planeValue,
				IGRchar			*name,
				IGRchar			*label,
				IGRint			*orientation,
				IGRint			*wJustif,
				IGRint			*hJustif )	{

	IGRlong		sts=OM_S_SUCCESS, siz=sizeof(struct GRmd_env), ret;
	IGRint		i, cnt=0, cn_type=ND_COMP;
struct	GRid		newCs, Root[7];
struct	GRmd_env	Env;
	IGRchar		axe[2], exp[DI_PATH_MAX];
	IGRchar		Name[DI_PATH_MAX], Label[DI_PATH_MAX];
	IGRdouble	size;
struct	ret_struct	str;

	/* Initialize */
	*msg = MSFAIL;
	if (singlePlaneId->objid == NULL_OBJID)	goto wrapup;
	for ( i=0; i<7; i++ )	Root[i].objid = NULL_OBJID;

	/* Retrieve roots */
	sts = om$send ( msg = message NDnode.NDget_objects
                                ( ND_ROOT, Root, 7, NULL, 0, 6, &cnt ),
                        senderid = NULL_OBJID,
                        targetid = singlePlaneId->objid,
                        targetos = singlePlaneId->osnum );
        as$status ( sts    = sts,
                    msg    = "NDnode.NDget_objects",
                    test   = ((sts != OM_S_SUCCESS) || (cnt != 7)),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Get active environment */
	sts = gr$get_module_env ( msg	 = msg,
				  sizbuf = &siz,
				  buffer = &Env,
				  nret   = &ret );
	as$status ( sts    = sts,
                    msg    = "gr$get_module_env()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	*msg = MSFAIL;

	/* New coordinate system */
	if ( (csId) && (csEnv) ) {

		/* Make source of new coordinate system */
		newCs.objid = NULL_OBJID;
		newCs.osnum = Env.md_id.osnum;
		sts = as$make_source ( go_grid = *csId,
				       mod_env = csEnv,
				       as_os   = Env.md_id.osnum,
				       as_grid = &newCs );
		as$status ( sts    = sts,
	                    msg    = "as$make_source(cs)",
	                    test   = (!(sts & 0x00000001)),
                    	    action = GOTO_VALUE,
                    	    value  = wrapup );

		/* Change connection */
		sts = om$send ( msg = message NDnode.NDchange_connect
						( 1, &Root[0], &newCs ),
	                        senderid = NULL_OBJID,
	      	                targetid = singlePlaneId->objid,
	                        targetos = singlePlaneId->osnum );
	        as$status ( sts    = sts,
	                    msg    = "NDnode.NDchange_connect",
	                    test   = (sts != OM_S_SUCCESS),
	                    action = GOTO_VALUE,
	                    value  = wrapup );

		/* Put it in the batch */
		sts = nd$wait_batch ( type	 = GR_GEOM_POSTED,
				      nb_obj	 = 1,
				      l_object	 = singlePlaneId,
				      l_obj_info = &cn_type );
	        as$status ( sts    = sts,
	                    msg    = "nd$wait_batch()",
	                    test   = (sts != OM_S_SUCCESS),
	                    action = GOTO_VALUE,
	                    value  = wrapup );
	}

	/* Evaluate new axis */
	if (axis) {
		switch (*axis) {
                	case SM_FA_Xaxis:       axe[0] = 'x';   break;
                	case SM_FA_Yaxis:       axe[0] = 'y';   break;
                	case SM_FA_Zaxis:       axe[0] = 'z';   break;
                	default :
printf ( "SMmodify_single_plane : unknown axis <%d>\n", *axis );
                        	goto wrapup;
        	}
        	axe[1] = '\0';
		sts = exp$modify ( exp_id     = Root[1].objid,
				   osnum      = Root[1].osnum,
				   exp_syntax = axe );
		as$status ( sts    = sts,
	                    msg    = "exp$modify(axis)",
	                    test   = (!(sts & 0x00000001)),
                    	    action = GOTO_VALUE,
                    	    value  = wrapup );
	}

	/* Evaluate new distance */
	if (distance) {
		if (! CSPconvert ( distance, distUnit ) )	goto wrapup;
		sprintf ( exp, "%f", *distance );
		sts = exp$modify ( exp_id     = Root[2].objid,
				   osnum      = Root[2].osnum,
				   exp_syntax = exp );
		as$status ( sts    = sts,
	                    msg    = "exp$modify(distance)",
	                    test   = (!(sts & 0x00000001)),
                    	    action = GOTO_VALUE,
                    	    value  = wrapup );
	}

	/* Evaluate new plane size */
	if (planeSize) {
		if ( CFSplnSize ( &size, *planeSize, planeValue, distUnit ) ) {
			sprintf ( exp, "%f", size );
			sts = exp$modify ( exp_id     = Root[3].objid,
					   osnum      = Root[3].osnum,
					   exp_syntax = exp );
			as$status ( sts    = sts,
		                    msg    = "exp$modify(size)",
		                    test   = (!(sts & 0x00000001)),
	                    	    action = GOTO_VALUE,
	                    	    value  = wrapup );
		}
	}

	/* Work on name */
	Name[0] = '\0';
	if (name) 
		strcpy ( Name, name );
	else {	sts = om$send ( msg = message GRvg.GRgetname ( msg, Name ),
				senderid = NULL_OBJID,
				targetid = singlePlaneId->objid,
				targetos = singlePlaneId->osnum );
	        as$status ( sts    = sts,
	                    msg    = "GRvg.GRgetname(single plane)",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );
		di$split ( pathname = Name, name = Name );
	}

	/* Evaluate new label */
	if (label) {
		if ( (label[0] == '\0') || (! strcmp ( label, "$0" )) )
			strcpy ( Label, Name );
		else	strcpy ( Label, label );
		sts = exp$modify ( exp_id     = Root[4].objid,
				   osnum      = Root[4].osnum,
				   exp_syntax = Label );
		as$status ( sts    = sts,
	                    msg    = "exp$modify(label)",
	                    test   = (!(sts & 0x00000001)),
	                    action = GOTO_VALUE,
		            value  = wrapup );
	}

	/* Evaluate new orientation */
	if (orientation) {
		sprintf ( exp, "%d", *orientation );
		sts = exp$modify ( exp_id     = Root[5].objid,
				   osnum      = Root[5].osnum,
				   exp_syntax = exp );
		as$status ( sts    = sts,
	                    msg    = "exp$modify(orientation)",
	                    test   = (!(sts & 0x00000001)),
                    	    action = GOTO_VALUE,
                    	    value  = wrapup );
	}

	/* Evaluate new justifications */
	sts = om$send ( msg = message NDnode.NDgive_structure
					( msg, &str, &Env ),
			senderid = NULL_OBJID,
			targetid = Root[6].objid,
			targetos = Root[6].osnum );
	as$status ( sts    = sts,
                    msg    = "NDnode.NDgive_structure",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	strcpy ( exp, str.var.text_st.text_string );
	if (wJustif) {
		if (! CFSjustif ( &exp[0], *wJustif ) ) goto wrapup;
	}
	if (hJustif) {
		if (! CFSjustif ( &exp[1], *hJustif ) ) goto wrapup;
	}
	if ( (wJustif) || (hJustif) ) {
		exp[2] = '\0';
		sts = exp$modify ( exp_id     = Root[6].objid,
				   osnum      = Root[6].osnum,
				   exp_syntax = exp );
		as$status ( sts    = sts,
	                    msg    = "exp$modify(justification)",
	                    test   = (!(sts & 0x00000001)),
                    	    action = GOTO_VALUE,
                    	    value  = wrapup );
	}

	/* Change name */
	if (name)  {
		if (! strcmp ( Name, name ) ) {
			sts = om$send ( msg = message GRvg.GRchgname
						( msg, &Env, Name ),
					senderid = NULL_OBJID,
					targetid = singlePlaneId->objid,
					targetos = singlePlaneId->osnum );
		        as$status ( sts    = sts,
		                    msg    = "GRvg.GRchgname(single plane)",
		                    test   = (!(sts & 0x00000001 & (*msg))),
		                    action = GOTO_VALUE,
		                    value  = wrapup );
		}
	}

	/* Display off single plane */
	gr$display_object ( object_id = singlePlaneId,
			    md_env = &Env, mode = GRbe );

	/* Recompute the single plane */
	sts = om$send ( msg = message NDnode.NDs_compute_node
					( msg, 0, &Env ),
			senderid = NULL_OBJID,
			targetid = singlePlaneId->objid,
			targetos = singlePlaneId->osnum );
        as$status ( sts    = sts,
                    msg    = "NDnode.NDs_compute_node(single plane)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Execute batch */
	sts = nd$exec_batch ();
        as$status ( sts    = sts,
                    msg    = "nd$exec_batch()",
                    test   = (sts != OM_S_SUCCESS),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Display on single plane */
	gr$display_object ( object_id = singlePlaneId,
			    md_env = &Env, mode = GRbd );

wrapup:
	return (sts);
}

/* ***** */

end implementation Root;
