/*f <VLspineFunk.I> manage specific fuunctions for spine-templates */

class implementation VLabstract;

#include        <stdio.h>
#include        "vlprototype.h"
#include        "OMerrordef.h"
#include        "OMindex.h"
#include        "AS_status.h"
#include        "godef.h"
#include        "grmacros.h"
#include        "grdpbdef.h"
#include        "grdpbmacros.h"
#include        "grdpb.h"
#include        "gotextdef.h"
#include        "maerr.h"
#include        "bs.h"
#include        "bsparameters.h"
#include        "msdef.h"
#include        "asmacros.h"
#include        "DIdef.h"
#include        "bsvalues.h"
#include        "math.h"
#include        "cotxmacros.h"
#include        "msmacros.h"
#include        "vlplatejig.h"
#include        "vlmsg.h"

#include        "bscrossp.h"
#include        "bsnorvec.h"

from	GRlinear	import	GRgetpolyline;

/* ========================================================================== */
IGRlong	VLgetPolyline (		IGRlong		*msg,		/* O	*/
			struct	GRid		*Line,		/* I	*/
			struct	GRmd_env	*Env,		/* I	*/
			struct	IGRpolyline	*Poly	)	/* O	*/
{
		IGRint		sts=OM_S_SUCCESS, action=0;

	/* Initialize */
	Poly->num_points = 0;
	Poly->points     = NULL;

	/* Get polyline vertice number */
	sts = om$send ( msg = message GRlinear.GRgetpolyline (
						msg,
						&Env->md_env.matrix_type,
						Env->md_env.matrix,
						&action,
						Poly ),
			senderid = NULL_OBJID,
			targetid = Line->objid,
			targetos = Line->osnum );
	as$status ( sts    = sts,
                    msg    = "GRlinear.GRgetpolyline",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Get linestring vertice array */
	Poly->points = om$calloc ( num       = 3 * Poly->num_points,
				   structure = IGRdouble );
	action = 1;
	sts = om$send ( msg = message GRlinear.GRgetpolyline (
						msg,
						&Env->md_env.matrix_type,
						Env->md_env.matrix,
						&action,
						Poly ),
			senderid = NULL_OBJID,
			targetid = Line->objid,
			targetos = Line->osnum );
	as$status ( sts    = sts,
                    msg    = "GRlinear.GRgetpolyline",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

wrapup :
	return (sts);
}
/* ========================================================================== */

/* ========================================================================== */
IGRlong	VLtplSpiMarkText (		IGRlong		*msg,		/* O  */
				struct	GRid		*Line,		/* I  */
				struct	GRid		*Name,		/* I  */
				struct	GRmd_env	*Env,		/* I  */
				struct	GRvg_construct	*Cst,		/* I  */
					IGRdouble	Size,		/* I  */
				struct	GRid		*Cont,		/* I  */
				struct	GRid		*Mark,		/* O  */
				struct	GRid		*Text	)	/* O  */
{
		IGRint		sts=OM_S_SUCCESS, i, len;
	struct	IGRpolyline	poly;
		IGRchar		name[DI_PATH_MAX];
		IGRpoint	cnt, ept, spt, Ept, Spt;
	struct	ret_struct	str;
		BSrc		rc;
		IGRvector	xvec, yvec, zvec;
		IGRmatrix	mat;
	struct  GRdpb_text_symb text_symb;
                IGRint          size=sizeof(struct GRdpb_text_symb);
                IGRlong         ret;
	struct	GRid		component[4];

	/* Initialize */
	*msg = MSSUCC;
	Mark->objid = Text->objid = NULL_OBJID;
	Mark->osnum = Text->osnum = Env->md_id.osnum;

	/* Get text */
	sts = om$send ( msg = message NDnode.NDgive_structure ( msg, &str, Env),
                        senderid = NULL_OBJID,
                        targetid = Name->objid,
                        targetos = Name->osnum );
        as$status ( sts    = sts,
                    msg    = "NDmacro.NDgive_structure",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
        strcpy ( name, str.var.text_st.text_string );

	/* Get linestring */
	sts = VLgetPolyline ( msg, Line, Env, &poly);
	as$status ( sts    = sts,
                    msg    = "VLgetPolyline()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	if (poly.num_points < 2)	goto wrapup;
	else {				dblcpy ( spt, &poly.points[0], 3);
					dblcpy ( ept, &poly.points[3], 3);
	}

	/* Create line segment with the two first points */
	sts = VLcreateLineSeg ( spt, ept, Env, Cst, Mark, msg );
	as$status ( sts    = sts,
		    msg    = "VLcreateLineSeg()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	
	/* Text point */
	for ( i=0; i<3; i++)	cnt[i] = (spt[i] + ept[i]) / 2.0;

	/* Get contour components */
	sts = om$send ( msg = message GRowner.GRget_components
                                ( msg, Env, component, 4, &i, 0, 4 ),
                        senderid = NULL_OBJID,
                        targetid = Cont->objid,
                        targetos = Cont->osnum );
        as$status ( sts    = sts,
                    msg    = "GRowner.GRget_components",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Retrieve endpoints of third segment of contour */
        sts = VLendpts ( msg, &component[2], Env, Spt, Ept);
        as$status ( sts    = sts,
                    msg    = "VLendpts()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Retrieve text symbology */
        gr$get_text_symb ( msg    = msg,
                           sizbuf = &size,
                           buffer = &text_symb,
                           nret   = &ret );
	if (Size > 0.0)	{	text_symb.Active_width  = Size;
				text_symb.Active_height = Size;	}
	else if (text_symb.Active_width > text_symb.Active_height)
				Size = text_symb.Active_width;
	else			Size = text_symb.Active_height;			

	/* Text matrix */
	for ( i=0; i<3; i++) {
		xvec[i] = ept[i] - spt[i];
		yvec[i] = Ept[i] - Spt[i];
	}
	BSnorvec ( &rc, xvec);
	if (rc != BSSUCC) {     printf( "Error in BSnorvec()\n");
                                *msg = MSFAIL; goto wrapup;     }
	BSnorvec ( &rc, yvec);
	if (rc != BSSUCC) {     printf( "Error in BSnorvec()\n");
                                *msg = MSFAIL; goto wrapup;     }
	BScrossp ( &rc, xvec, yvec, zvec);
        if (rc != BSSUCC) {     printf( "Error in BScrossp()\n");
                                *msg = MSFAIL; goto wrapup;     }
        BSnorvec ( &rc, zvec);
        if (rc != BSSUCC) {     printf( "Error in BSnorvec()\n");
                                *msg = MSFAIL; goto wrapup;     }
        BScrossp ( &rc, zvec, xvec, yvec);
        if (rc != BSSUCC) {     printf( "Error in BScrossp()\n");
                                *msg = MSFAIL; goto wrapup;     }
        BSnorvec ( &rc, yvec);
        if (rc != BSSUCC) {     printf( "Error in BSnorvec()\n");
                                *msg = MSFAIL; goto wrapup;     }

        for ( i=0; i<3; i++) {  mat[4*i+0] = xvec[i];
                                mat[4*i+1] = yvec[i];
                                mat[4*i+2] = zvec[i];
                                mat[4*i+3] = cnt[i];
                                mat[12+i]  = 0.0;	}
        mat[15] = 1.0;

        /* Define text parameters */
        Text->objid = NULL_OBJID;
        Text->osnum = Env->md_id.osnum;
        len = strlen (name);
        text_symb.Active_just = CENTER_TOP;

        /* Place text */
        sts = co$place_text ( msg         = msg,
                              text_string = name,
                              text_length = &len,
                              lbs_matrix  = mat,
                              origin      = cnt,
                              TextSymb    = &text_symb,
                              mode        = GRbe,
                              flags       = 1,
                              buffer      = Text );
        as$status ( sts    = sts,
                    msg    = "co$place_text()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

wrapup :
	if (poly.points) {	om$dealloc (ptr = poly.points);
				poly.points = NULL;	}
	return (sts);
}
/* ========================================================================== */

end implementation VLabstract;
