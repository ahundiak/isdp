/* $Id: VLbalancei.I,v 1.1.1.1 2001/01/04 21:11:33 cvs Exp $  */

/*************************************************************************
 * I/LOFT
 *
 * File:	VLinteg/src/pin_jig / VLbalancei.I
 *
 * Description:	Methods of VLbalance class.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VLbalancei.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:11:33  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:32:50  pinnacle
# LOFT 2.5.1
#
# Revision 1.2  1997/11/28  09:07:24  pinnacle
# Replaced: src/pin_jig/VLbalancei.I for:  by rchennup for loft
#
# Revision 1.1  1997/05/08  14:05:56  pinnacle
# Loft 250
#
# Revision 1.6  1997/04/09  14:40:26  pinnacle
# Replaced: src/pin_jig/VLbalancei.I for: file header + vl$externalContour()file header + vl$externalContour() by mfournie for loft
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	04/09/97   mf		file header + vl$externalContour()
 *************************************************************************/
class implementation VLbalance;

#include	<string.h>
#include	"vlprototype.h"
#include	"AS_status.h"
#include	"nddef.h"
#include	"grmacros.h"
#include	"bsparameters.h"
#include	"bstypes.h"
#include	"bserr.h"
#include	"bsvalues.h"
#include	"DIdef.h"
#include	"expression.h"
#include	"vsplatedef.h"
#include	"vsmiscmacros.h"
#include	"ACattrib.h"
#include	"ACrg_collect.h"
#include	"ACdyn_col.h"
#include	"expression.h"
#include	"expmacros.h"

#include	"bsxtractpar.h"
#include	"mainvmx.h"
#include	"mamulmx.h"
#include	"matypemx.h"

#include	"vlplatejig.h"
#include	"vlfloor.h"
#include	"vlmsg.h"
#include	"vlmiscmacros.h"
#include	"vlquerydef.h"
#include	"vlcontmacros.h"

from	ACdyn_col	import	ACset_list_attribute;
from	GRgencs		import	GRgetmatrix;
from	expression	import	NDgive_value;

extern	GRclassid	OPP_ACdyn_col_class_id;
extern	GRclassid	OPP_EMSsubbs_class_id;
extern	GRclassid	OPP_GR3dlineseg_class_id;
extern	GRclassid	OPP_GRgencs_class_id;
extern	GRclassid	OPP_VLseaLine_class_id;
extern	GRclassid	OPP_VSplate_class_id;
extern	GRclassid	OPP_VSfrzPlate_class_id;
extern	GRclassid	OPP_VSimgFeature_class_id;
extern	GRclassid	OPP_VLmrkLine_class_id;
extern	GRclassid	OPP_text_exp_class_id;

extern	struct	GRid	NULL_GRID;

extern	IGRlong		EFproject_any_curve_on_planen();

/* ========================================================================== */
method ACconstruct_feet ( 		IGRlong		*msg;
			 		IGRint		cn_type;
			 		IGRint		count;
			 struct		GRid		list[];
			 struct		GRmd_env	*md_env;
					IGRint		*fcount;
			 struct		GRid		*feet_list )
{

		IGRint		sts=MSFAIL, i, j, number=0;
		IGRint		nobj=0, ncont=0, nplt=0, nmrk=0;
		IGRint		inv_norm, jig_type, option[2], nchd=0;
	struct	GRobj_env	*Temp, *Copy, *Surf, *Cont, *List, *Chld;
		IGRlong		size=sizeof(struct GRobj_env);
		IGRdouble	value, grd_dist, Angle[3];
		IGRboolean	img_flag=FALSE;
		IGRmatrix	PrjMat, TotMat, GrdMat, BalMat;
		IGRchar		name[ATTR_NAME];
	struct	GRvg_construct	cst;
		IGRdouble	bTol, cTol, dTol;
		IGRshort	four=4;
	struct	IGRplane	Nrm, Grd;
		IGRpoint	Pnt;
		IGRvector	Vec;
	struct	GRobj_env	Cntr;
		GRclassid	clid;
	struct	ACrg_coll	*attr;
		IGRchar		side[DI_PATH_MAX];
	struct	GRid		OldDef;
		IGRboolean	newDF, balCS;
	struct	GRobj_env	GrdCsys, BalCsys; 
		BSrc		rc;

	/* Initialize : step 1 */
	attr    = NULL;
	Temp    = NULL;
	Copy    = NULL;
	Surf    = NULL;
	Cont	= NULL;
	List	= NULL;
	Chld	= NULL;

	/* Detect old macro definition of VLbalance */
	sts = vl$return_foot ( msg     = msg,
			       objId   = &list[IDX_BT_BCS],
			       objEnv  = md_env,
			       footId  = &OldDef );
	as$status ( sts	   = sts,
    		    msg	   = "vl$return_foot(BCS)",
    		    test   = (!(sts & 0x00000001 & (*msg))),
    		    action = GOTO_VALUE,
    		    value  = wrapup );
	if	( vs$is_ancestry_valid ( object  = &OldDef,
					 classid = OPP_GRgencs_class_id ) ) {
		balCS = TRUE;
		newDF = TRUE;
	}
	else if ( vs$is_ancestry_valid ( object  = &OldDef,
					 classid = OPP_text_exp_class_id ) ) {
		balCS = FALSE;
		newDF = TRUE;
	}
	else {	balCS = FALSE;
		newDF = FALSE;	}

	/* Convert old macro definition of VLbalance to new one (if needed) */
	if (newDF == FALSE) {

		/* Convert : add a text expression in templates' list */
		sts = om$send ( msg = message VLbalance.convert ( msg ),
				targetid = my_id );
		as$status ( sts	   = sts,
    			    msg	   = " VLbalance.convert",
    			    test   = (!(sts & 0x00000001 & (*msg))),
    			    action = GOTO_VALUE,
    			    value  = wrapup );

		/* Get modified templates' list and count */
		sts = om$send ( msg = message NDnode.NDget_objects (
					ND_ROOT,
					list,
					MACRO_B_FTEMP + MACRO_B_VTEMP,
					(struct GRid **) NULL,
					0,
					OM_K_MAXINT,
					&count ),
				targetid = my_id );
		as$status ( sts	   = sts,
			    msg	   = "NDnode.NDget_objects",
			    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );
	}

	/* Initialize : step 2 */
	nobj    = count - MACRO_B_FTEMP;
	*fcount =  MACRO_B_FFEET + 2 * nobj ;
	for ( i=0; i<*fcount; i++) {
		feet_list[i].objid = NULL_OBJID;
		feet_list[i].osnum = md_env->md_id.osnum;
	}
	VLinitCnst (&cst);
	cst.env_info = md_env;
	BSxtractpar ( msg, BSTOLBASIS,  &bTol);
        BSxtractpar ( msg, BSTOLCHRDHT, &cTol);
        dTol = 5 * cTol;
	Cntr.obj_id.objid = NULL_OBJID;
	Cntr.obj_id.osnum = md_env->md_id.osnum;
	Grd.point  = Pnt;
	Grd.normal = Vec;
	Nrm.point  = Pnt;
	Nrm.normal = Vec;

	/* Apply existence rule #1 */
	if (nobj <= 0)	goto wrapup;

	/* Allocate memory for Temp array */
	Temp = (struct GRobj_env *) om$malloc (size = nobj * size);
        if (!Temp) {	printf( "Cannot %d bytes ...\n", nobj * size );
                	goto wrapup;	}

	/* Retrieve input graphic objects */
	for ( i=0; i<nobj; i++) {
		sts = vl$return_foot ( msg     = msg,
				       objId   = &list[MACRO_B_FTEMP+i],
				       objEnv  = md_env,
				       footId  = &Temp[i].obj_id,
				       footEnv = &Temp[i].mod_env );
		as$status ( sts	   = sts,
	    		    msg	   = "vl$return_foot",
	    		    test   = (!(sts & 0x00000001 & (*msg))),
	    		    action = GOTO_VALUE,
	    		    value  = wrapup );
	}

	sts = om$send ( msg = message expression.NDgive_value (&value),
			targetid = list[IDX_BT_QYO].objid,
			targetos = list[IDX_BT_QYO].osnum );
	as$status ( sts	   = sts,
		    msg	   = "expression.NDgive_value(QYO)",
		    test   = (!(sts & 0x00000001)),
		    action = GOTO_VALUE,
		    value  = wrapup );
	VLdecode ( (IGRint) value, 2, option);

	/* Retrieve mark on VLplates (if any) */
	if (option[1]) {
	for ( i=0; i<nobj; i++) {
		if (vs$is_ancestry_valid(object  = &Temp[i].obj_id,
                                         classid = OPP_VSplate_class_id)) {

			/* Free children buffer */
			nchd = 0;
			if (Chld) {	om$dealloc (ptr = Chld); Chld = NULL; }

			/* Browse get macros in Struct contruction tree */
			sts = VLbrowseFctInTree (
					&Temp[i],
					VL_Q_TOP_SOURCE,
					NULL,
					VL_Q_DOWN_DIRECT | VL_Q_DOWN_AFTER,
					VLgetMacrosAtStep,
					&nchd,
					&Chld );
			as$status ( sts	   = sts,
		    		    msg	   = "VLbrowseFctInTree()",
		    		    test   = (!(sts & 0x00000001)),
		    		    action = GOTO_VALUE,
		    		    value  = wrapup );
			if (!nchd)	continue;

			/* Filter macros that are marks */
			VLfilterClass ( nchd, Chld, &nchd,
					OPP_VLmrkLine_class_id );
			if (!nchd)	continue;

			/* Allocate memory to store marks (if needed) */
			nmrk += nchd;
			Temp = (struct GRobj_env *) om$realloc (
						ptr  = (IGRchar *) Temp,
						size = (nobj+nmrk) * size );
        		if (!Temp) {
				printf( "Cannot %d bytes ...\n",
					(nobj+nmrk) * size );
                		goto wrapup;
			}

			/* Store marks in templates array */
			for ( j=0; j<nchd; j++) {
				Temp[nobj+nmrk-nchd+j] = Chld[j];
#ifdef TRACE
printf( "Plate %2d\tChild %2d : (%d|%d)\n", i, j, 
	Chld[j].obj_id.osnum, Chld[j].obj_id.objid );
#endif
			}
		}
	}
	nobj += nmrk;
	}

	/* Allocate memory for Copy array */
	Copy = (struct GRobj_env *) om$malloc (size = nobj * size);
        if (!Copy) {	printf( "Cannot %d bytes ...\n", nobj * size );
                	goto wrapup;	}

	/* Allocate memory for Surf array */
	Surf = (struct GRobj_env *) om$malloc (size = nobj * size);
        if (!Surf) {	printf( "Cannot %d bytes ...\n", nobj * size );
                	goto wrapup;	}

	/* Allocate memory for Cont array */
	Cont = (struct GRobj_env *) om$malloc (size = nobj * size);
        if (!Cont) {	printf( "Cannot %d bytes ...\n", nobj * size );
                	goto wrapup;	}

	/* Allocate memory for struct ACrg_coll */
	attr = om$calloc ( num 	     = nobj * IDX_BB_MAX,
			   structure = struct ACrg_coll );
        if (!attr) {	printf( "Cannot %d bytes ...\n",
				nobj * IDX_BB_MAX * sizeof (struct ACrg_coll) );
                	goto wrapup;	}

	sts = om$send ( msg = message expression.NDgive_value (&value),
			targetid = list[IDX_BT_REV].objid,
			targetos = list[IDX_BT_REV].osnum );
	as$status ( sts	   = sts,
		    msg	   = "expression.NDgive_value(REV)",
		    test   = (!(sts & 0x00000001)),
		    action = GOTO_VALUE,
		    value  = wrapup );
	inv_norm = (IGRint) value;
	if (inv_norm != INVNORM_OF)     inv_norm = INVNORM_ON;
        if (inv_norm == INVNORM_OF)     strcpy ( side, VS_K_plTopSfPath);
        else                            strcpy ( side, VS_K_plBotSfPath);

	/* Generate struct ACrg_coll */
	for ( i=0; i<nobj; i++) {
		sprintf ( attr[IDX_BB_MAX*i+IDX_BB_IDX].name, "%s%d",
			  NAM_BB_IDX, i );
		sprintf ( attr[IDX_BB_MAX*i+IDX_BB_NAM].name, "%s%d",
			  NAM_BB_NAM, i );
		sprintf ( attr[IDX_BB_MAX*i+IDX_BB_BSM].name, "%s%d",
			  NAM_BB_BSM, i );
		sprintf ( attr[IDX_BB_MAX*i+IDX_BB_TSM].name, "%s%d",
			  NAM_BB_TSM, i );

		attr[IDX_BB_MAX*i+IDX_BB_IDX].desc.type = AC_ATTRIB_DOUBLE;
		attr[IDX_BB_MAX*i+IDX_BB_NAM].desc.type = AC_ATTRIB_TEXT;
		attr[IDX_BB_MAX*i+IDX_BB_BSM].desc.type = AC_ATTRIB_TEXT;
		attr[IDX_BB_MAX*i+IDX_BB_TSM].desc.type = AC_ATTRIB_TEXT;
	}

	/* Copy input graphic objects */
	for ( i=0; i<nobj; i++) {
		Copy[i].mod_env = *md_env;
		sts = gr$copy_object ( msg 	    = msg,
				       object_id    = &Temp[i].obj_id,
				       md_env	    = &Temp[i].mod_env,
				       new_env      = &Copy[i].mod_env,
				       new_id	    = &Copy[i].obj_id,
				       display_flag=0 );
		as$status ( sts	   = sts,
	    		    msg	   = "gr$copy_object",
	    		    test   = (!(sts & 0x00000001 & (*msg))),
	    		    action = GOTO_VALUE,
	    		    value  = wrapup );

		if (vs$is_ancestry_valid(object  = &Copy[i].obj_id,
                                         classid = OPP_VSfrzPlate_class_id)) {
                        VLextractVSplateSurface( msg,
                                                 &Copy[i].obj_id,
                                                 &Copy[i].mod_env,
                                                 side,
                                                 &Surf[i].obj_id,
                                                 &Surf[i].mod_env,
                                                 NULL);
			as$status ( sts	   = sts,
		    		    msg	   = "VLextractVSplateSurface()",
		    		    test   = (!(sts & 0x00000001 & (*msg))),
		    		    action = GOTO_VALUE,
		    		    value  = wrapup );

			attr[IDX_BB_MAX*i+IDX_BB_IDX].desc.value.att_exp = i;
			name[0] = '\0';
			sts = om$send ( msg = message GRgraphics.GRgetname 
							( msg, name),
					senderid = NULL_OBJID,
					targetid = Temp[i].obj_id.objid,
					targetos = Temp[i].obj_id.osnum );
			if ((!(sts & 0x00000001 & (*msg))) || (name[0] == '\0'))
strcpy(attr[IDX_BB_MAX*i+IDX_BB_NAM].desc.value.att_txt, "Unamed" );
                	else
strcpy(attr[IDX_BB_MAX*i+IDX_BB_NAM].desc.value.att_txt, &strrchr(name,':')[1]);

			if (option[0]) {
				sts = VLquery1 ( msg, &(Temp[i]), md_env,
					  	 OPP_VLseaLine_class_id,
						 VLcheckBorderLine,
						 &number, &List);
				as$status ( sts	   = sts,
		    		    	    msg	   = "VLquery1()",
		    		    	    test   = (!(sts&0x00000001&(*msg))),
		    		    	    action = GOTO_VALUE,
		    		    	    value  = wrapup );

				sts = VLsortPlateSeams ( &Temp[i], side,
							 number, &List, msg);
				as$status ( sts	   = sts,
		    		    	    msg	   = "VLsortPlateSeams()",
		    		    	    test   = (!(sts&0x00000001&(*msg))),
		    		    	    action = GOTO_VALUE,
		    		    	    value  = wrapup );

//				if (number != 2)
// printf( "VLquery1(VLcheckGenLine) returns only %d answers\n", number);
			}
			else	number = 0;

			if	(number < 1) {
sprintf ( attr[IDX_BB_MAX*i+IDX_BB_BSM].desc.value.att_txt, "S%d", nplt+1);
sprintf ( attr[IDX_BB_MAX*i+IDX_BB_TSM].desc.value.att_txt, "S%d", nplt+2);
			}
			else if (number < 2) {
				name[0] = '\0';
				sts = om$send (
					msg = message GRgraphics.GRgetname
							( msg, name),
					senderid = NULL_OBJID,
					targetid = List[0].obj_id.objid,
					targetos = List[0].obj_id.osnum );
if ((!(sts & 0x00000001 & (*msg))) || (name[0] == '\0'))
	sprintf ( attr[IDX_BB_MAX*i+IDX_BB_BSM].desc.value.att_txt,
		  "S%d", nplt+1);
else	sprintf ( attr[IDX_BB_MAX*i+IDX_BB_BSM].desc.value.att_txt,
		  "%s", &(strrchr(name,':'))[1] );

sprintf ( attr[IDX_BB_MAX*i+IDX_BB_TSM].desc.value.att_txt,
	  "S%d", nplt+2 );
			}
			else {
				name[0] = '\0';
				sts = om$send (
					msg = message GRgraphics.GRgetname
							( msg, name),
					senderid = NULL_OBJID,
					targetid = List[0].obj_id.objid,
					targetos = List[0].obj_id.osnum );
if ((!(sts & 0x00000001 & (*msg))) || (name[0] == '\0'))
	sprintf ( attr[IDX_BB_MAX*i+IDX_BB_BSM].desc.value.att_txt,
		  "S%d", nplt+1);
else	sprintf ( attr[IDX_BB_MAX*i+IDX_BB_BSM].desc.value.att_txt,
		  "%s", &(strrchr(name,':'))[1] );

				name[0] = '\0';
				sts = om$send (
					msg = message GRgraphics.GRgetname
							( msg, name),
					senderid = NULL_OBJID,
					targetid = List[1].obj_id.objid,
					targetos = List[1].obj_id.osnum );
if ((!(sts & 0x00000001 & (*msg))) || (name[0] == '\0'))
	sprintf ( attr[IDX_BB_MAX*i+IDX_BB_TSM].desc.value.att_txt,
		  "S%d", nplt+2);
else	sprintf ( attr[IDX_BB_MAX*i+IDX_BB_TSM].desc.value.att_txt,
		  "%s", &(strrchr(name,':'))[1] );
			}

			if (List) { om$dealloc (ptr = List); List = NULL; }
			nplt++;
		}
		else 	Surf[i] = Copy[i];
	}

	/* Contruct ATTR foot */
	sts = om$construct ( classid = OPP_ACdyn_col_class_id,
                             osnum   = feet_list[IDX_BF_ATTR].osnum,
                             p_objid = &feet_list[IDX_BF_ATTR].objid );

	sts = om$send ( msg = message ACdyn_col.ACset_list_attribute
                                                ( msg, IDX_BB_MAX * nplt, attr),
                           targetid = feet_list[IDX_BF_ATTR].objid,
                           targetos = feet_list[IDX_BF_ATTR].osnum );
        as$status ( sts    = sts,
                    msg    = "ACdyn_col.ACset_list_attribute",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Check an existing surface in the "Surf" list */
	for ( i=0; i<nobj; i++) {
		if (vs$is_ancestry_valid ( object  = &Surf[i].obj_id,
                                           classid = OPP_EMSsubbs_class_id) ) {
                        *msg = VL_S_SUCCESS;
                        break;
                }
	}
	if (*msg != VL_S_SUCCESS)	goto wrapup;

	/* Retrieve fix templates */
	sts = om$send ( msg = message expression.NDgive_value (&value),
			targetid = list[IDX_BT_GRD].objid,
			targetos = list[IDX_BT_GRD].osnum );
	as$status ( sts	   = sts,
		    msg	   = "expression.NDgive_value(GRD)",
		    test   = (!(sts & 0x00000001)),
		    action = GOTO_VALUE,
		    value  = wrapup );
	grd_dist = value;

	sts = vl$return_foot ( msg     = msg,
			       objId   = &list[IDX_BT_GCS],
			       objEnv  = md_env,
			       footId  = &GrdCsys.obj_id,
			       footEnv = &GrdCsys.mod_env );
	as$status ( sts	   = sts,
    		    msg	   = "vl$return_foot(GCS)",
    		    test   = (!(sts & 0x00000001 & (*msg))),
    		    action = GOTO_VALUE,
    		    value  = wrapup );

	if (balCS == FALSE)	BalCsys = GrdCsys;
	else {	sts = vl$return_foot ( msg     = msg,
				       objId   = &list[IDX_BT_BCS],
				       objEnv  = md_env,
				       footId  = &BalCsys.obj_id,
				       footEnv = &BalCsys.mod_env );
		as$status ( sts	   = sts,
    			    msg	   = "vl$return_foot(BCS)",
    			    test   = (!(sts & 0x00000001 & (*msg))),
    			    action = GOTO_VALUE,
    			    value  = wrapup );
	}

	sts = om$send ( msg = message expression.NDgive_value (&value),
			targetid = list[IDX_BT_TYP].objid,
			targetos = list[IDX_BT_TYP].osnum );
	as$status ( sts	   = sts,
		    msg	   = "expression.NDgive_value(TYP)",
		    test   = (!(sts & 0x00000001)),
		    action = GOTO_VALUE,
		    value  = wrapup );
	jig_type = (IGRint) value;

	/* Apply existence rule #2 */
	if ( (jig_type != IDX_J1) && (jig_type != IDX_J2) ) {
		printf( "Unavailable jig type %d\n", jig_type);
		*msg = MSFAIL; goto wrapup; }

	/* Evaluate img_flag (TRUE if 1st plate is an image) */
	for ( i=0; i<nobj; i++) {
		if (vs$is_ancestry_valid(object  = &Temp[i].obj_id,
                                       	 classid = OPP_VSplate_class_id)) {
			img_flag = FALSE;
			break;
			}
		if (vs$is_ancestry_valid(object  = &Temp[i].obj_id,
                                       	 classid = OPP_VSimgFeature_class_id)) {
			img_flag = TRUE;
			break;
		}
	}

	/* Because image planar symetry don't respect antisymetry of
	   vector cross product, we need to invert normal for images */
	if (img_flag) {	if (inv_norm == INVNORM_ON)	inv_norm = INVNORM_OF;
			else				inv_norm = INVNORM_ON; }

	/* Evaluate the average normal */
	sts = VLevalAvNor ( Surf, nobj-nmrk, Nrm.point, Nrm.normal, msg);
	as$status ( sts	   = sts,
		    msg	   = "VLevalAvNor()",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Evaluate the 3D | balance rotation */
	sts = VLevalFromMat ( Copy, nobj-nmrk, side, grd_dist, jig_type,
			      &Nrm, md_env, PrjMat, msg );
	as$status ( sts	   = sts,
		    msg	   = "VLevalFromMat()",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Retrieve ground CS matrix */
	sts = om$send ( msg = message GRgencs.GRgetmatrix ( msg, GrdMat),
			targetid = GrdCsys.obj_id.objid,
			targetos = GrdCsys.obj_id.osnum );
	as$status ( sts	   = sts,
		    msg	   = "GRgencs.GRgetmatrix(GRD)",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Retrieve balance CS matrix */
	sts = om$send ( msg = message GRgencs.GRgetmatrix ( msg, BalMat),
			targetid = BalCsys.obj_id.objid,
			targetos = BalCsys.obj_id.osnum );
	as$status ( sts	   = sts,
		    msg	   = "GRgencs.GRgetmatrix(BAL)",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Add BalCsys rotation to balancement (if needed) */
	if (balCS == TRUE) {

		if (  (!MAmulmx ( &rc, &four, &four, &four,
				  BalMat, PrjMat, TotMat ))
		   || (rc != MSSUCC) ) {
			printf( "Error in MAmulmx()\n" );
			*msg = MSFAIL;
			goto wrapup;
		}
	}
	else {	for ( i=0; i<16; i++ )	TotMat[i] = PrjMat[i];	}

	/* Evaluate the transformation Euler angles */
	sts = VLdirectorCosine ( TotMat, Angle);
	as$status ( sts	   = sts,
		    msg	   = "VLdirectorCosine()",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Print Euler angles in Unix window
	printf( "Xangle=%4.2f DEG, Yangle=%4.2f DEG, Zangle=%4.2f DEG\n",
		Angle[0]*180.0/M_PI, Angle[1]*180.0/M_PI, Angle[2]*180.0/M_PI);
        */

	/* Create the X angle feet */
	sts = exp$create ( exp_value = Angle[0],
			   p_exp_id  = &feet_list[IDX_BF_XANG].objid,
			   osnum     = md_env->md_id.osnum,
			   p_osnum   = &feet_list[IDX_BF_XANG].osnum);
	as$status ( sts	   = sts,
		    msg	   = "exp$create(XANG))",
		    test   = (sts != EXP_S_SUCCESS),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Create the Y angle feet */
	sts = exp$create ( exp_value = Angle[1],
			   p_exp_id  = &feet_list[IDX_BF_YANG].objid,
			   osnum     = md_env->md_id.osnum,
			   p_osnum   = &feet_list[IDX_BF_YANG].osnum);
	as$status ( sts	   = sts,
		    msg	   = "exp$create(YANG))",
		    test   = (sts != EXP_S_SUCCESS),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Create the Z angle feet */
	sts = exp$create ( exp_value = Angle[2],
			   p_exp_id  = &feet_list[IDX_BF_ZANG].objid,
			   osnum     = md_env->md_id.osnum,
			   p_osnum   = &feet_list[IDX_BF_ZANG].osnum);
	as$status ( sts	   = sts,
		    msg	   = "exp$create(ZANG))",
		    test   = (sts != EXP_S_SUCCESS),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Apply evaluated balancement to copies in BalCsys */
	sts = VLappFromMat ( Copy, nobj, &BalCsys, &cst, PrjMat, FALSE, FALSE,
			     NULL, msg);
	as$status ( sts	   = sts,
		    msg	   = "VLappFromMat()",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Set transformation results in feet */
	for ( i=0; i<nobj; i++)	{ 
		if (vs$is_ancestry_valid(object  = &Copy[i].obj_id,
                                         classid = OPP_VSfrzPlate_class_id)) {
			Cont[ncont] = Copy[i];
			ncont++;
		}
		feet_list[MACRO_B_FFEET+i] = Copy[i].obj_id;
	}
	*fcount =  MACRO_B_FFEET + nobj + ncont;

	/* Create the number of plates feet */
	sts = exp$create ( exp_value = (IGRdouble) ncont,
			   p_exp_id  = &feet_list[IDX_BF_NPLT].objid,
			   osnum     = md_env->md_id.osnum,
			   p_osnum   = &feet_list[IDX_BF_NPLT].osnum);
	as$status ( sts	   = sts,
		    msg	   = "exp$create(NPLT))",
		    test   = (sts != EXP_S_SUCCESS),
		    action = GOTO_VALUE,
		    value  = wrapup );

	Grd.point[0] = GrdMat[3];
	Grd.point[1] = GrdMat[7];
	Grd.point[2] = GrdMat[11];

	Grd.normal[0] = GrdMat[2];
	Grd.normal[1] = GrdMat[6];
	Grd.normal[2] = GrdMat[10];

	/* Construct global contour of VSplates */
	sts = vl$externalContour ( msg	= msg,
				   num	= ncont,
				   Plat	= Cont,
				   side	= side,
				   Env	= md_env,
	//			   Four	= TRUE,
				   Cont	= &Cntr );
	as$status ( sts	   = sts,
		    msg	   = "vl$externalContour()()",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Project contour on ground plane */
	sts = EFproject_any_curve_on_planen ( msg,
					      &cst,
					      &Cntr,
					      md_env,
					      &Grd,
					      Grd.normal,
					      &feet_list[IDX_BF_CONT],
					      &clid );
	as$status ( sts	   = sts,
		    msg	   = "EFproject_any_curve_on_planen()",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Delete contour */
	if (Cntr.obj_id.objid != NULL_OBJID) {
		gr$delete_object ( msg       = msg,
			           md_env    = &Cntr.mod_env,
			           object_id = &Cntr.obj_id);
		Cntr.obj_id.objid = NULL_OBJID;	}

	/* Construct individual contour of VSplates */
	for ( j=0; j<ncont; j++) {

		/* Construct contour of each VSplate */
		sts = vl$externalContour ( msg	= msg,
					   num	= 1,
					   Plat	= &Cont[j],
					   side	= side,
					   Env	= md_env,
					   Cont	= &Cntr );
		as$status ( sts	   = sts,
			    msg	   = "vl$externalContour()()",
			    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );

		/* Project contour on ground plane */
		sts = EFproject_any_curve_on_planen ( msg,
					      	      &cst,
					      	      &Cntr.obj_id,
					      	      md_env,
					      	      &Grd,
					      	      Grd.normal,
&feet_list[MACRO_B_FFEET+nobj+j],
					      	      &clid );
		as$status ( sts	   = sts,
		    	    msg	   = "EFproject_any_curve_on_planen()",
		    	    test   = (!(sts & 0x00000001 & (*msg))),
		    	    action = GOTO_VALUE,
		    	    value  = wrapup );

		/* Delete contour */
		if (Cntr.obj_id.objid != NULL_OBJID) {
			gr$delete_object ( msg       = msg,
					   md_env    = &Cntr.mod_env,
					   object_id = &Cntr.obj_id);
			Cntr.obj_id.objid = NULL_OBJID;	}
	}

wrapup:
	if (Cntr.obj_id.objid != NULL_OBJID) {
		gr$delete_object ( msg       = msg,
				   md_env    = &Cntr.mod_env,
				   object_id = &Cntr.obj_id);
		Cntr.obj_id.objid = NULL_OBJID;
	}
	if (attr) {	om$dealloc (ptr = attr);	attr = NULL;	}
	if (List) {	om$dealloc (ptr = List);	List = NULL;	}
	if (Cont) {	om$dealloc (ptr = Cont);	Cont = NULL;	}
	if (Surf) {	om$dealloc (ptr = Surf);	Surf = NULL;	}
	if (Copy) {	om$dealloc (ptr = Copy);	Copy = NULL;	}
	if (Temp) {	om$dealloc (ptr = Temp);	Temp = NULL;	}
	if (Chld) {	om$dealloc (ptr = Chld);	Chld = NULL;	}
	return(sts);
}
/* ========================================================================== */

/* ========================================================================== */
method VDgetObjDef( long *msg ; VDobjDef *myDef ) {

        long            sts ;   /* OM return code       */

        /*
         * name.
         */
        myDef->info             = VL_I_ObjBalance;
        myDef->type             = 0 ;

        sts     = OM_S_SUCCESS ;
        *msg    = MSSUCC ;

        return sts ;
} /* method VDgetObjdDef */
/* ========================================================================== */

/* ========================================================================== */
method convert	( IGRlong	*msg ) {

	IGRlong		sts=OM_S_SUCCESS;
	IGRint		count=0;
struct	GRid		list[MACRO_B_FTEMP + MACRO_B_VTEMP], text;

	/* Get VLbalance occurence's templates */
	sts = om$send ( msg = message NDnode.NDget_objects (
					ND_ROOT,
					list,
					MACRO_B_FTEMP + MACRO_B_VTEMP,
					(struct GRid **) NULL,
					0,
					OM_K_MAXINT,
					&count ),
			targetid = my_id );
	as$status ( sts	   = sts,
		    msg	   = "NDnode.NDget_objects",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Set message to error */
	*msg = MSFAIL;

	/* Disconnect templates that will be moved */
	sts = om$send ( msg = message NDnode.NDdisconnect
			( count - IDX_BT_BCS, &list[IDX_BT_BCS] ),
			targetid = my_id );
	as$status ( sts	   = sts,
		    msg	   = "NDnode.NDdisconnect",
		    test   = (!(sts & 0x00000001)),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Create expression for balance coordinate system */
        sts = exp$create ( exp_syntax = "bal_cs",
                           p_exp_id   = &text.objid,
                           osnum      = list[IDX_BT_GRD].osnum,
                           p_osnum    = &text.osnum,
                           type_rq    = EXP_TEXT );
        if (sts != EXP_S_SUCCESS)    goto wrapup;

	/* Connect text expression */
	sts = om$send ( msg = message NDnode.NDconnect
				( 1, &text, NULL_GRID, ND_ADD ),
			targetid = my_id );
	as$status ( sts	   = sts,
		    msg	   = "NDnode.NDconnect",
		    test   = (!(sts & 0x00000001)),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Reconnect templates that will be moved */
	sts = om$send ( msg = message NDnode.NDconnect (
					count - IDX_BT_BCS,
					&list[IDX_BT_BCS],
					NULL_GRID,
					ND_ADD ),
			targetid = my_id );
	as$status ( sts	   = sts,
		    msg	   = "NDnode.NDconnect",
		    test   = (!(sts & 0x00000001)),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Set message to success */
	*msg = MSSUCC;

wrapup:
	return (sts);
}
/* ========================================================================== */


end implementation VLbalance;
