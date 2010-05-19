/* $Id: PlaceGen.I,v 1.1.1.1 2001/01/04 21:08:42 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdequip/api/PlaceGen.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: PlaceGen.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:42  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/10/29  17:24:12  pinnacle
# Place Equipment API
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	10/19/96	i-paris		created
 *
 ***************************************************************************/

class implementation Root;

#include	<stdio.h>
#include	<string.h>
#include	"igetypedef.h"
#include	"igrtypedef.h"
#include	"OMminimum.h"
#include	"OMerrordef.h"
#include	"igrdef.h"
#include	"igr.h"
#include	"exdef.h"
#include	"ex.h"
#include	"igrdp.h"
#include	"gr.h"
#include	"growner.h"
#include	"godef.h"
#include	"go.h"
#include	"griodef.h"
#include	"grio.h"
#include	"AS_status.h"
#include	"asmacros.h"
#include	"grmacros.h"
#include	"macro.h"
#include	"acrepdef.h"
#include	"acrepmacros.h"
#include	"grdpbdef.h"
#include	"grdpbmacros.h"
#include	"nd.h"
#include	"nddef.h"
#include	"ndmacros.h"
#include	"msmacros.h"
#include	"parametric.h"
#include	"acdef.h"
#include	"acmacros.h"
#include	"ACattrib.h"
#include	"ACrg_collect.h"
#include	"PDUerror.h"
#include	"ACdb_info.h"
#include	"expression.h"
#include	"expmacros.h"
#include	"csdef.h"
#include	"grcoordsys.h"

#include	"DIdef.h"
#include	"DItypedef.h"
#include	"DIglob.h"
#include	"DIprims.h"

#include	"bserr.h"
#include	"bsnorvec.h"

#include	"COmdef.h"
#include	"VDSutil.h"
#include	"VDScheckdef.h"
#include	"VDSpathdef.h"
#include	"VDSudp_mac.h"
#include	"v_miscmacros.h"
#include	"vdbmacros.h"
#include	"vdattmacros.h"

/*
#include	"VDapi.h"
*/

#include	"vdAPIequips.h"
#include	"vdmacprotos.h"

from	GRgraphics	import	GRconstruct, GRgetname;
from    GRvg            import  GRputname;

extern	GRclassid	OPP_GRgencs_class_id;

/* ************************************************************************** */
IGRlong	VDbuildCSvectors (	IGRlong		*msg,
				IGRdouble	*X,
				IGRdouble	*Y,
				IGRint		Wname,
				IGRdouble	*x,
				IGRdouble	*y,
				IGRdouble	*z	)
{
	IGRlong		sts=OM_S_SUCCESS;
	IGRint		i;
	BSrc		rc;

	/* Initialize */
	x[0] = x[1] = x[2] = 0.0;
	y[0] = y[1] = y[2] = 0.0;
	z[0] = z[1] = z[2] = 0.0;
	
	/* Set message to error */
	*msg = MSFAIL;

	/* Normalize vector */
	if	(X != NULL) {
		for ( i=0; i<3; i++ )	x[i] = X[i];
		if (!BSnorvec ( &rc, x ) )	goto wrapup;
	}
	else if (Y != NULL) {
		for ( i=0; i<3; i++ )	y[i] = Y[i];
		if (!BSnorvec ( &rc, y ) )	goto wrapup;
	}
	else {	if	(Wname == VD_WIN_TOP_NAM) {
			x[0] = 1.0;
			y[1] = 1.0;
		}
		else if	(Wname == VD_WIN_BOT_NAM) {
			x[0] = -1.0;
			y[1] = 1.0;
		}
		else if	(Wname == VD_WIN_RIG_NAM) {
			x[2] = 1.0;
			y[0] = 1.0;
		}
		else if	(Wname == VD_WIN_LEF_NAM) {
			x[0] = 1.0;
			y[2] = 1.0;
		}
		else	goto wrapup;
	}

	/* Create Z vector */
	if (!BScrossp ( &rc, x, y, z ) )	goto wrapup;
	
	/* Set message to success */
	*msg = MSSUCC;

wrapup:
	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VDcreateCS (		IGRlong		*msg,
				IGRdouble	*Cpnt,
				IGRdouble	*Xvec,
				IGRdouble	*Yvec,
				IGRint		Wname,
				IGRdouble	*matrix,
				IGRchar		*name,
			struct	GRobj_env	*CS	)
{
	IGRlong		sts=OM_S_SUCCESS;
	IGRint		i, siz=sizeof(struct GRmd_env), ret;
struct	GRobj_env	CoorSys;
struct	GRsymbology	sym;
struct	GRvg_construct	cst;
struct	IGRlbsys	lbs;
struct	GRcs_construct	arg;
	IGRdouble	x[3], y[3], z[3];

        /* Get current environment */
        sts = gr$get_module_env ( msg    = msg,
                                  sizbuf = &siz,
                                  buffer = &CoorSys.mod_env,
                                  nret   = &ret );
        as$status ( sts    = sts,
                    msg    = "gr$get_module_env()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Get active symbology */
	ASget_active_symb ( &sym.level, &sym.display_attr );

	/* Initialize */
	lbs.diag_pt1[0] = lbs.diag_pt1[1] = lbs.diag_pt1[2] = 0.0;
	lbs.diag_pt2[0] = lbs.diag_pt2[1] = lbs.diag_pt2[2] = 0.0;
	arg.desc	= NULL;
	arg.flag	= CS_CONNECT_TO_MGR | CS_NO_MAKE_ACTIVE;

	/* Fill construction list */
	vd_$fill_cnst_list ( Cnst_list	= cst,
			     Env_info	= &CoorSys.mod_env,
			     Level	= sym.level,
			     Display	= &sym.display_attr,
			     Geometry	= &lbs,
			     Class_attr	= &arg,
			     Name	= name );

	/* Set msg to error */
	CoorSys.obj_id.objid = NULL_OBJID;
	CoorSys.obj_id.osnum = CoorSys.mod_env.md_id.osnum;
	*msg = MSFAIL;

	/* Check input arguments */
	if ( (Cpnt == NULL) && (matrix == NULL) )	goto wrapup;
	if (  (Wname != VD_WIN_NOT_NAM)
	   && (Wname != VD_WIN_TOP_NAM)
	   && (Wname != VD_WIN_BOT_NAM)
	   && (Wname != VD_WIN_RIG_NAM)
	   && (Wname != VD_WIN_LEF_NAM) )	Wname = VD_WIN_NOT_NAM;
	if (  ( (Xvec == NULL) && (Wname  == VD_WIN_NOT_NAM) )
	   && ( (Xvec == NULL) && (matrix == NULL) ) )	goto wrapup;
	if (  ( (Yvec == NULL) && (Wname  == VD_WIN_NOT_NAM) )
	   && ( (Yvec == NULL) && (matrix == NULL) ) )	goto wrapup;

	/* Fill matrix */
	if (matrix != NULL) {
		for ( i=0; i<16; i++ )	lbs.matrix[i] = matrix[i];
	}
	else {	lbs.matrix[12] = lbs.matrix[13] = lbs.matrix[14] = 0.0;
		lbs.matrix[15]					 = 1.0;

		/* Center point */
		if (Cpnt != NULL) {
			lbs.matrix[3]  = Cpnt[0];
			lbs.matrix[7]  = Cpnt[1];
			lbs.matrix[11] = Cpnt[2];
		}
		else	goto wrapup;

		/* Get vectors */
		sts = VDbuildCSvectors ( msg, Xvec, Yvec, Wname, x, y, z );
	        as$status ( sts    = sts,
	                    msg    = "VDbuildCSvectors()",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );

		/* Set vectors */
		for ( i=0; i<3; i++ ) {
			lbs.matrix[4*i+0] = x[i];
			lbs.matrix[4*i+1] = y[i];
			lbs.matrix[4*i+2] = z[i];
		}
	}

	/* Construct coordinate system */
	sts = om$construct ( classid = OPP_GRgencs_class_id,
			     osnum   = CoorSys.obj_id.osnum,
			     p_objid = &CoorSys.obj_id.objid );
        as$status ( sts    = sts,
                    msg    = "om$construct(GRgencs)",
                    test   = (!(sts & 0x00000001)),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Build coordinate system */
	sts = om$send ( msg = message GRgraphics.GRconstruct (&cst),
			senderid = NULL_OBJID,
			targetid = CoorSys.obj_id.objid,
			targetos = CoorSys.obj_id.osnum );
        as$status ( sts    = sts,
                    msg    = "GRgraphics.GRconstruct",
                    test   = (!(sts & 0x00000001 & (*(cst.msg)))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Display coordinate system */
	sts = gr$display_object ( object_id = &CoorSys.obj_id,
				  md_env    = &CoorSys.mod_env );
        as$status ( sts    = sts,
                    msg    = "gr$display_object()",
                    test   = (!(sts & 0x00000001)),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Set msg to success */
	if (CS)	*CS = CoorSys;
	*msg = MSSUCC;

wrapup:
	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VDincrementalName (		IGRlong		*msg,
				struct	GRid		*obj,
					IGRchar		*dir,
					IGRchar		*rot	)
{
	IGRlong		sts=OM_S_SUCCESS;
	IGRint		i;
	IGRchar		Dir[DI_PATH_MAX], Ful[DI_PATH_MAX];
struct	GRid		bidon;

	/* Check no naming */
	*msg = MSSUCC;
	if ( (rot == NULL) || (rot[0] == '\0') )	goto wrapup;

	/* Check directory */
	if 	(dir == NULL)	di$pwd ( dirname = Dir );
	else if (dir[0] != ':') {
		di$pwd ( dirname = Dir );
		sprintf ( Dir, "%s:%s", Dir, dir );
	}
	else {	di$give_pathname ( osnum = obj->osnum, pathname = Dir );
		sprintf ( Dir, "%s%s", Dir, dir );
	}

	/* Find unexisting absolute name */
	for ( i=0; i<1000; i++ ) {
		sprintf ( Ful, "%s:%s_%03d", Dir, rot, i );
		sts = di$translate ( objname = Ful,
                                     p_objid = &bidon.objid,
                                     p_osnum = &bidon.osnum );
		if (sts != DIR_S_SUCCESS)       break;
	}

	/* Name object */
	if (i < 1000) {
		sts = om$send ( msg = message GRvg.GRputname ( msg, Ful ),
				senderid = NULL_OBJID,
				targetid = obj->objid,
				targetos = obj->osnum );
		as$status ( sts	   = sts,
			    msg	   = "GRvg.GRputname",
			    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );
	}
	else	*msg = MSFAIL;

wrapup:
	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong VDplaceMacroOrEquip (           IGRlong         *msg,
					IGRchar		*MacLib,
					IGRchar		*MacDef,
					IGRchar		*CatName,
					IGRchar		*PartNum,
					IGRchar		*RevName,
                                        IGRint          TplNum,
                                struct  VDcollector     TplCol[],
                                        IGRint          DynNum,
                                struct  VDcollector	*DynCol,
				enum	ACm_poss_hdr	Htyp,
                                        IGRint          rep,
                                        IGRint          lay,
                                        IGRint          col,
                                        IGRint          wgt,
                                        IGRint          stl,
                                        IGRint          One,
                                        IGRint          All,
                                        IGRchar         *DirPath,
                                        IGRchar         *RootName,
					IGRint		prop,
                                struct  GRid            *OccId )
{
        IGRlong         sts, siz=sizeof(struct GRmd_env), ret;
struct  GRobj_env       Occ;
struct	VDdescriptor	Desc;

        /* Get current environment */
        sts = gr$get_module_env ( msg    = msg,
                                  sizbuf = &siz,
                                  buffer = &Occ.mod_env,
                                  nret   = &ret );
        as$status ( sts    = sts,
                    msg    = "gr$get_module_env()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Initialize descriptor */
	Desc.MacLib[0]		= '\0';
	Desc.MacNam[0]		= '\0';
	Desc.MacDef.objid	= NULL_OBJID;
	Desc.MacDef.osnum	= Occ.mod_env.md_id.osnum;
	Desc.HdrTyp		= HDR_CONS;
	Desc.MacTyp		= mac_exp;
	Desc.HdrSym		= 0;
	Desc.prop		= 0;
	Desc.StaBox.objid	= NULL_OBJID;
	Desc.StaBox.osnum	= Occ.mod_env.md_id.osnum;
	Desc.DbInfo.quantity	= 0;
	Desc.DbInfo.serial_no	= 0;
	Desc.DbInfo.catalog[0]	= '\0';
	Desc.DbInfo.part_num[0]	= '\0';
	Desc.DbInfo.revision[0]	= '\0';
	Desc.DbInfo.usage[0]	= '\0';

	if ( (CatName == NULL) && (PartNum == NULL) && (RevName == NULL) ) {

		/* Get macro description */
        	sts = VDgetMacroDescription ( msg, MacLib, MacDef,
                                      	      Occ.mod_env.md_id.osnum, Htyp,
					      &Desc );
        	as$status ( sts    = sts,
	                    msg    = "VDgetMacroDescription()",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );
	}
	else {	/* Get equip description */
        	sts = VDgetEquipDescription ( msg, CatName, PartNum, RevName,
                                      	      Occ.mod_env.md_id.osnum, Htyp,
					      &Desc );
        	as$status ( sts    = sts,
	                    msg    = "VDgetEquipDescription()",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );
	}

        /* Initialize */
        Occ.obj_id.objid = NULL_OBJID;
        Occ.obj_id.osnum = Occ.mod_env.md_id.osnum;
        Desc.HdrSym |= lay;
        if (col)        Desc.HdrSym |= col;
        if (wgt)        Desc.HdrSym |= wgt;
        if (stl)        Desc.HdrSym |= stl;
        if (One)        Desc.HdrSym |= One;
        if (All)        Desc.HdrSym |= All;

        /* Switch between macro and equipment cases */
        if      (DynCol == NULL) {

                /* Macro case */
                sts = VDplaceMacro ( msg, TplNum, TplCol, &Desc,
				     DirPath, RootName, prop, &Occ );
                as$status ( sts    = sts,
                            msg    = "VDplaceMacro()",
                            test   = (!(sts & 0x00000001 & (*msg))),
                            action = GOTO_VALUE,
                            value  = wrapup );
        }
        else {	/* Equipment case */
                sts = VDplaceEquip ( msg, TplNum, TplCol, DynNum, DynCol, &Desc,
				     rep, DirPath, RootName, prop, &Occ );
                as$status ( sts    = sts,
                            msg    = "VDplaceEquip()",
                            test   = (!(sts & 0x00000001 & (*msg))),
                            action = GOTO_VALUE,
                            value  = wrapup );
        }

wrapup:
        if (OccId)        *OccId = Occ.obj_id;
        return (sts);
}
/* ************************************************************************** */

end implementation Root;
