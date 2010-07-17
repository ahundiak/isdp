class implementation VLjigTbl;

#include	"vlprototype.h"
#include	"AS_status.h"
#include        "bsparameters.h"
#include        "bstypes.h"
#include        "grmacros.h"
#include	"vltablejig.h"
#include	"vlmiscmacros.h"

from    GRgencs         import  GRgetmatrix;

/* ========================================================================== */
method ACconstruct_feet ( 		IGRlong		*msg;
			 		IGRint		cn_type;
			 		IGRint		count;
			 struct		GRid		list[];
			 struct		GRmd_env	*md_env;
					IGRint		*fcount;
			 struct		GRid		*feet_list )
{

		IGRlong		sts;
	struct	GRid		csy_id, mgr_id, *Klu;
	struct	GRobj_env	*Obj;
		IGRmatrix	mat;
	struct	ACrg_coll	**attr;
		IGRint		i, ncomp, icomp=-1;
		IGRint		r_max, l_max, w_max, c_max;
		IGRchar		name[DI_PATH_MAX];

	/* Initialize */
	Obj     = NULL;
	Klu     = NULL;
	attr	= NULL;
	*fcount = MACRO_T_FFEET;
	r_max = l_max = w_max = c_max = 0;

	/* Retrieve coordinate_system */
	sts = vl$return_foot ( msg     = msg,
                               objId   = &list[IDX_T_CSYS],
                               footId  = &csy_id );
	as$status ( sts    = sts,
		    msg    = "vl$return_foot(CSYS)",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Retrieve platejig_manager */
	sts = vl$return_foot ( msg     = msg,
                               objId   = &list[IDX_T_PJIG],
                               footId  = &mgr_id );
	as$status ( sts    = sts,
		    msg    = "vl$return_foot(PJIG)",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Retrieve coordinate_system's matrix */
        sts = om$send ( msg = message GRgencs.GRgetmatrix ( msg, mat),
                        targetid = csy_id.objid,
                        targetos = csy_id.osnum );
	as$status ( sts    = sts,
		    msg    = "GRgencs.GRgetmatrix",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Retrieve platejig objects */
	sts = om$send ( msg = message GRowner.GRget_number_components
						( msg, &ncomp),
                        targetid = mgr_id.objid,
                        targetos = mgr_id.osnum );
	as$status ( sts    = sts,
		    msg    = "GRowner.GRget_number_components",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	ncomp-= MACRO_PM_FFEET;
        Obj = om$calloc ( num = ncomp, structure = struct GRobj_env );
        Klu = om$calloc ( num = ncomp, structure = struct GRid );

        for ( i=0; i<ncomp; i++) {
                name[0] = '\0';
                sprintf ( name, "%s%d", NAM_PM_VARF, i+1);
		sts = vl$return_foot ( msg     = msg,
				       name    = name,
	                               objId   = &mgr_id,
				       objEnv  = md_env,
	                               footId  = &Obj[i].obj_id,
				       footEnv = &Obj[i].mod_env );
                as$status ( sts    = sts,
			    msg    = "vl$return_foot(VARF)",
		    	    test   = (!(sts & 0x00000001 & (*msg))),
                            action = GOTO_VALUE,
                            value  = wrapup );
		Klu[i] = Obj[i].obj_id;
        }
	

	/* Retrieve attributes' array from plate_jig */
	sts = VLextractRgColls ( msg, Klu, ncomp, &attr);
	as$status ( sts    = sts,
		    msg    = "VLextractRgColls()",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Build jig table from attributes */
        sts = VLbuildJigTable ( msg, ncomp, attr, md_env, mat,
				&r_max, &l_max, &w_max, &c_max,
				&feet_list[IDX_T_TABLE]);
	as$status ( sts    = sts,
		    msg    = "VLbuildJigTable()",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );
	*fcount += r_max + l_max;
	for ( i=MACRO_T_FFEET; i<*fcount; i++) {
		feet_list[i].objid = NULL_OBJID;
		feet_list[i].osnum = md_env->md_id.osnum;
	}

	/* Select support template_jig */
	for ( i=0; i<ncomp; i++) {
	if (  ((IGRint)attr[i][IDX_RG_P_R_NUM].desc.value.att_exp == r_max)
	   && ((IGRint)attr[i][IDX_RG_P_L_NUM].desc.value.att_exp == l_max)
	   && ((IGRint)attr[i][IDX_RG_P_W_NUM].desc.value.att_exp == w_max)
	   && ((IGRint)attr[i][IDX_RG_P_C_NUM].desc.value.att_exp == c_max) )
		{ icomp = i; i = ncomp; }
	}
	if (icomp == -1)	icomp = ncomp - 1;

	sts = VLtagTemplateJig ( msg, &Obj[icomp].obj_id, &Obj[icomp].mod_env,
				 r_max, l_max, attr[icomp],
				 &feet_list[MACRO_T_FFEET]);
	as$status ( sts    = sts,
	    	    msg    = "VLtagTemplateJig()",
	    	    test   = (!(sts & 0x00000001 & (*msg))),
	    	    action = GOTO_VALUE,
	    	    value  = wrapup );

wrapup:
	if (Obj)	{ om$dealloc (ptr = Obj);	Obj = NULL; }
	if (attr)	{ om$dealloc (ptr = attr);	attr = NULL; }
	return(sts);
}

end implementation VLjigTbl;
