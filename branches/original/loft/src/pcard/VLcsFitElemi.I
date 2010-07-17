class implementation VLcsFitElem;

#include "bstypes.h"
#include "bsdotp.h"
#include "csdef.h"
#include "grcoordsys.h"

from	GRgencs		import GRinitialize;

extern	GRclassid	OPP_GRgencs_class_id;

method ACconstruct_feet( IGRlong *msg; IGRint cn_type;
			 IGRint count; struct GRid list [];
			 struct GRmd_env *md_env;
			 int *fcount; struct GRid  *feet_list )
{
long			sts, loc_msg;
struct	ret_struct	st_ref, st_pt;
BSrc			bs_rc;
double			v1[4], v2[4], v3[4];
short			four	= 4;
short			one	= 1;
double			invMat[16];
double			xLen, yLen;
int			i;
IGRboolean		word = 1;
short			rg_type;
double			rg_mat[16];
GRrange			range;
double			xElm, yElm;
struct	GRid		CsId;
struct	GRvg_construct	cst;
struct	IGRlbsys	lbsy;
struct	GRcs_construct	args;

	// get cs geom
	sts = om$send(	msg	 = message NDnode.NDgive_structure(
					msg,
					&st_ref,
					md_env ),
			targetid = list[0].objid,
			targetos = list[0].osnum );
	if( ! (sts & *msg & 1)){ *msg = MSFAIL; goto wrapup; }

	// get point
	sts = om$send(	msg	 = message NDnode.NDgive_structure(
					msg,
					&st_pt,
					md_env ),
			targetid = list[1].objid,
			targetos = list[1].osnum );
	if( ! (sts & *msg & 1)){ *msg = MSFAIL; goto wrapup; }

	// change the CS of the point
	MAinvmx(&loc_msg, &four, st_ref.var.ref_st.t, invMat);
	for(i=0; i<3; i++)
		v2[i] = st_pt.var.point_st.pt[i];
	v2[3] = 1.;

	MAmulmx(&loc_msg, &four, &four, &one, invMat, v2 , v3);

	// compute x length
	for(i=0; i<3; i++)
		v1[i] = st_ref.var.ref_st.t[(i*4)];
	xLen = BSdotp( &bs_rc, v1, v3 );
//	printf(" xLen : %f\n", xLen );

	// compute y length
	for(i=0; i<3; i++)
		v1[i] = st_ref.var.ref_st.t[(i*4)+1];
	yLen = BSdotp( &bs_rc, v1, v3 );
//	printf(" yLen : %f\n", yLen );

	// get range of the stiffener
	rg_type = MAIDMX;
	MAidmx( &loc_msg, rg_mat );
	sts = om$send(	msg	 = message GRgraphics.GRgetrang(
					&loc_msg,
					&rg_type, rg_mat, &word,
					range ),
			targetid = list[2].objid,
			targetos = list[2].osnum );

	// define scale factor
	xElm = range[3] - range[0];
	yElm = range[4] - range[1];

	// create a cs with new value

	VLinitCnst( &cst );
	cst.env_info	= md_env;
//	cst.properties	&= ~(GRIS_DISPLAYABLE | GRIS_LOCATABLE);
//	cst.properties |= GRNOT_IN_RTREE;

	dblcpy ( lbsy.matrix, st_ref.var.ref_st.t, 16);
	lbsy.diag_pt1[0] = lbsy.diag_pt1[1] = lbsy.diag_pt1[2] = 0.0;
        lbsy.diag_pt2[0] = lbsy.diag_pt2[1] = lbsy.diag_pt2[2] = 0.0;
	args.desc      = NULL;
	args.flag      = CS_CONNECT_TO_MGR | CS_NO_MAKE_ACTIVE;
	cst.class_attr = (IGRchar *) &args;
	cst.geometry   = (IGRchar *) &lbsy;

	// affect scale factor
	lbsy.matrix[0] *= xLen / xElm;
	lbsy.matrix[5] *= yLen / yElm;

	/*c Construct coordinate system */
	CsId.osnum	= OM_Gw_current_OS;
	CsId.objid	= NULL_OBJID;
	sts = om$construct ( classid = OPP_GRgencs_class_id,
                             osnum   = CsId.osnum,
                             p_objid = &CsId.objid,
                             msg     = message GRgraphics.GRconstruct(&cst));

	if( ! (sts&1)){ *msg = MSFAIL; goto wrapup; }
//	printf(" CsId : %d/%d\n", CsId.objid, CsId.osnum );

	*fcount	= 1;
	feet_list[0] = CsId;
	*msg	= MSSUCC;

wrapup :


return	OM_S_SUCCESS;
}

end implementation VLcsFitElem;


