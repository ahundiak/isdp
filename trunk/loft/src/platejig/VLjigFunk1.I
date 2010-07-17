/*f <VLjigFunk.I> contains a set of functions used to compute general operations
    in the plate_jigs construction workflow. */

class implementation VLabstract;

#include        <stdio.h>
#include        "vlprototype.h"
#include        "OMerrordef.h"
#include        "OMindex.h"
#include        "AS_status.h"
#include        "grmacros.h"
#include        "grdpbdef.h"
#include        "grdpbmacros.h"
#include        "grdpb.h"
#include        "gotextdef.h"
#include        "maerr.h"
#include        "bs.h"
#include        "bsparameters.h"
#include        "bsconic.h"
#include        "msdef.h"
#include        "EMSmsgdef.h"
#include        "EMSssprops.h"
#include        "EMSdpb.h"
#include        "dpezmac.h"
#include        "asmacros.h"
#include        "DIdef.h"
#include        "math.h"
#include        "cotxmacros.h"
#include        "ACattrib.h"
#include        "fontdef.h"
#include        "fontmacros.h"
#include        "grmessage.h"
#include        "vsplatedef.h"
#include        "vsmiscmacros.h"
#include        "vltablejig.h"
#include        "vlmiscmacros.h"

#include	"bsarc3pts.h"
#include	"bscrossp.h"
#include	"bscv_sf_int.h"
#include	"bsdotp.h"
#include	"bslenvec.h"
#include	"bsnorvec.h"
#include	"bspardelcv.h"
#include	"bspl_cv_int.h"
#include	"bsprepsphr.h"
#include	"bsprptoncv.h"
#include	"bsrev_cv.h"
#include	"bssfeval.h"

/*	#define	TRACE	*/

extern	IGRdouble	fabs();
extern	IGRchar		*strrchr();

extern	void		BuildCrv(), OrderCrv();

extern	GRclassid	OPP_ACrg_collect_class_id;
extern	GRclassid	OPP_GRbcsubbc_class_id;

from	ACrg_collect    import  ACget_named_attribute, AClist_attribute,
				ACset_list_attribute;
from	GRlinear	import	GRgetpolyline;

/* ========================================================================== */

/* ========================================================================== */
IGRlong VLplateContours ( msg, nplt, Plate, Env, Contour)

/*d This function find the contours of an array of STRUCT plates, which are the
    border of the <base> surface supporting the VSplate. The Contour array must
    be allocated and deallocated by user. */

/*h 20/01/1993 : creation by Marc FOURNIER (ISDC). */

		IGRlong		*msg;		/*O Completion code	      */
		IGRint		nplt;		/*I Number of Struct plates   */
	struct	GRobj_env	Plate[];	/*I Array of Struct plates    */
	struct	GRmd_env	*Env;		/*I Module info		      */
	struct	GRid		Contour[];	/*O Array of plate contours   */

{
/* Beginning of function */

		IGRint		sts=OM_S_SUCCESS;
	struct	GRobj_env	Surf;
	struct	GRid		frozen;
		IGRint		i;

	for ( i=0; i<nplt; i++) {

		/* Copy VSplate to create a frozen one */
		frozen.objid = NULL_OBJID;
		frozen.osnum = Env->md_id.osnum;
		sts = gr$copy_object ( msg		= msg,
				       object_id	= &Plate[i].obj_id,
				       md_env		= &Plate[i].mod_env,
				       new_env		= Env,
				       new_id		= &frozen,
				       display_flag	= 0 );
		as$status ( sts    = sts,
                            msg    = "gr$copy_object()",
                            test   = (!(sts & 0x00000001 & (*msg))),
                            action = GOTO_VALUE,
                            value  = wrapup );

		/* Extract <offset> support surface */
		sts = VLextractVSplateSurface ( msg,
				                &frozen,
				                Env,
						VS_K_plTopSfPath,
				                &Surf.obj_id,
				                &Surf.mod_env,
				                NULL );
		as$status ( sts    = sts,
                            msg    = "VLextractVSplateSurface()",
                            test   = (!(sts & 0x00000001 & (*msg))),
                            action = GOTO_VALUE,
                            value  = wrapup );

		/* Construct <base> contour */
		Contour[i].objid = NULL_OBJID;
		Contour[i].osnum = Env->md_id.osnum;
		sts = VSdrwMakeSfContourCompCurve ( msg,
						    &Surf.obj_id,
						    &Surf.mod_env,
						    Env,
					      	    &Contour[i] );
		if (!((*msg)&1&sts))
printf( "VSplate:(%d|%d)  Support:(%d|%d)  Surface:(%d|%d)  Contour:(%d|%d)\n",
	Plate[i].obj_id.osnum, Plate[i].obj_id.objid,
	frozen.osnum, frozen.objid, Surf.obj_id.osnum, Surf.obj_id.objid,
	Contour[i].osnum, Contour[i].objid);
		as$status ( sts    = sts,
                	    msg    = "VSdrwMakeSfContourCompCurve()",
                	    test   = (!(sts & 0x00000001 & (*msg))),
                	    action = GOTO_VALUE,
                	    value  = wrapup );

		/* Delete copied surface */
		sts = gr$delete_object ( msg		= msg,
					 md_env		= Env,
					 object_id	= &frozen );
		as$status ( sts    = sts,
                	    msg    = "gr$delete_object()",
                	    test   = (!(sts & 0x00000001 & (*msg))),
                	    action = GOTO_VALUE,
                	    value  = wrapup );

		/* Redisplay source surface */
		sts = gr$display_object ( object_id = &Plate[i].obj_id,
					  md_env    = &Plate[i].mod_env,
					  mode      = GRbd );
		as$status ( sts    = sts,
                    	    msg    = "gr$display_object()",
                    	    test   = (!(sts & 0x00000001)),
                    	    action = GOTO_VALUE,
                    	    value  = wrapup );
	}

wrapup:
	return (sts);

/* End of function */
}
/* ========================================================================== */

/* ========================================================================== */
IGRlong VLplaneIndex ( msg, num, plane, index)

/*d This function find the frame system indexation. The returned buffer must be
    deallocated by the program calling VLplaneIndex(). */

/*h 25/01/1993 : creation by Marc FOURNIER (ISDC). */

		IGRlong		*msg;		/*O Completion code	      */
		IGRint		num;		/*I Number of selected planes */
	struct	GRobj_env	plane[];	/*I Selected planes	      */
		IGRchar		***index;	/*O Array of index	      */

{
/* Beginning of function */

		IGRint		sts=OM_S_SUCCESS;
		IGRchar		name[DI_PATH_MAX];
		IGRint		i;
		IGRint		sidx, cidx, eidx;

	/* Allocate memory for indexes' buffer (IGRchar) */
	*index = NULL;
	*index = om$calloc ( num = num, structure = IGRchar *);
        if (*index == NULL) { printf( "Unable to allocate <%d> bytes\n",
                                      num * sizeof(IGRchar *));
                              goto wrapup; }
 	for ( i=0; i<num; i++)
		(*index)[i] = om$calloc (num = DI_PATH_MAX,structure = IGRchar);

	if (num == 1) {
		strcpy ( (*index)[0], "1/1");
		sts  = OM_S_SUCCESS;
		*msg = MSSUCC;
		goto wrapup;
	}

	/* Retrieve the names of the input planes */
	for ( i=0; i<num; i++) {
		sts = om$send ( msg      = message GRvg.GRgetname ( msg, name),
                  	     	senderid = NULL_OBJID,
                  	     	targetid = plane[i].obj_id.objid,
                  	     	targetos = plane[i].obj_id.osnum );
		as$status ( sts    = sts,
                	    msg    = "GRvg.GRgetname",
                	    test   = (!(sts & 0x00000001 & (*msg))),
                	    action = GOTO_VALUE,
                	    value  = wrapup );
		strcpy ( (*index)[i], &(strrchr(name,':'))[2] );
	}

	/* Construct the output index for each input plane */
	sscanf ( (*index)[0],     "%d", &sidx);
	sscanf ( (*index)[num-1], "%d", &eidx);
	for ( i=0; i<num; i++) {
		sscanf (  (*index)[i], "%d", &cidx);
		if      (sidx <= eidx) 	cidx = cidx - sidx + 1;
		else if (eidx <  sidx)	cidx = sidx - cidx + 1;
		sprintf ( (*index)[i], "%d/%d", cidx, num);
	}

wrapup:
	return (sts);

/* End of function */
}
/* ========================================================================== */

/* ========================================================================== */
IGRlong VLcreateJigText ( title, Rpt1, Rpt2, nvtx, Vertex, Env, Sline,
			  radius, Attr, text_num, text_id, loc_mat, msg)

/*d This function constructs the texts associated with a template_jig. */

/*h 23/03/1993 : creation by Marc FOURNIER (ISDC). */

		IGRchar		title[];	/*I Template_jig title	      */
		IGRdouble	Rpt1[];		/*I Template_jig Rplane pnt 1 */
		IGRdouble	Rpt2[];		/*I Template_jig Rplane pnt 2 */
		IGRint		nvtx;		/*I Number of vertices	      */
		IGRdouble	Vertex[];	/*I Array of vertices	      */
	struct	GRmd_env	*Env;		/*I Module info		      */
	struct	GRid		*Sline;		/*I Template_jig Sline	      */
		IGRdouble	radius;		/*I Hole radius value	      */
	struct	ACrg_coll	Attr[];		/*I Rigid collection	      */
		IGRint		*text_num;	/*O Number of texts to build  */
	struct	GRid		**text_id;	/*O Array of texts ID	      */
		IGRdouble	loc_mat[];	/*O Local matrix	      */
		IGRlong		*msg;		/*O Completion code	      */

{
/* Beginning of function */

		IGRlong		sts=OM_S_SUCCESS;
	struct	GRdpb_text_symb	text_symb;
		IGRint		size;
		IGRlong		ret;
		IGRchar		txt[DI_PATH_MAX];
		IGRint		len;
		IGRpoint	cnt;
		IGRvector	xvec, yvec, zvec;
		IGRint		i, j;
		BSrc		rc;
		IGRpoint	spt, ept;
		IGRdouble	buffer[9];
	struct	IGRpolyline	poly;
		IGRint		action;

		IGRint		E, L, R, W, C, idx;
		IGRpoint	pnt;
		IGRvector	Sxv, Szv;
		IGRdouble	Xs, Zs, Xa, Za;

	/* Initialize */
	E = (IGRint) Attr[IDX_RG_P_E_NUM].desc.value.att_exp;
	R = (IGRint) Attr[IDX_RG_P_R_NUM].desc.value.att_exp;
	L = (IGRint) Attr[IDX_RG_P_L_NUM].desc.value.att_exp;
	W = (IGRint) Attr[IDX_RG_P_W_NUM].desc.value.att_exp;
	C = (IGRint) Attr[IDX_RG_P_C_NUM].desc.value.att_exp;
	*text_num = 2 + nvtx + C;
	*text_id  = NULL;
	idx       = IDX_RG_P_VALUE + 2 * (E + R + L);

	/* Allocate memory */
	*text_id = om$calloc ( num = *text_num, structure = struct GRid);
        if (*text_id == NULL) { printf( "Unable to allocate <%d> bytes\n",
                                        *text_num * sizeof(struct GRid));
                                goto wrapup; }

	/* Retrieve text symbology */
	size = sizeof(struct GRdpb_text_symb);
        gr$get_text_symb ( msg    = msg,
                           sizbuf = &size,
                           buffer = &text_symb,
                           nret   = &ret );

	sts = VLvector ( msg, Rpt1, Rpt2, 1.0, 1.0, TRUE, xvec);
	as$status ( sts    = sts,
                    msg    = "VLvector()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	sts = VLvector ( msg, Rpt1, Vertex, 1.0, 1.0, TRUE, yvec);
	as$status ( sts    = sts,
                    msg    = "VLvector()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

        BScrossp ( &rc, xvec, yvec, zvec);
        if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
        BSnorvec ( &rc, zvec);
        if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
        BScrossp ( &rc, zvec, xvec, yvec);
        if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
        BSnorvec ( &rc, yvec);
        if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }

        /* Create the local rotation matrix */
        for ( i=0; i<3; i++) {
                loc_mat[4*i+0] = xvec[i];
                loc_mat[4*i+1] = yvec[i];
                loc_mat[4*i+2] = zvec[i];
                loc_mat[4*i+3] = Rpt1[i];
                loc_mat[12+i]  = 0.0;
        }
        loc_mat[15] = 1.0;

        /* Create the title */
        txt[0] = '\0';
        title[80] = '\0';
        sprintf ( txt, "%s", title);
        len = strlen(txt);
        for ( i=0; i<3; i++) cnt[i] = Rpt1[i]
                                    + 0.05 * (Rpt2[i]   - Rpt1[i])
                                    + 0.05 * (Vertex[i] - Rpt1[i]);
        text_symb.Active_just = LEFT_BOTTOM;
	(*text_id)[0].objid = NULL_OBJID;
	(*text_id)[0].osnum = Env->md_id.osnum;
        sts = co$place_text ( msg               = msg,
                              text_string       = txt,
                              text_length       = &len,
                              lbs_matrix        = loc_mat,
                              origin            = cnt,
                              TextSymb          = &text_symb,
                              mode              = GRbe,
                              flags             = 1,
                              buffer            = &(*text_id)[0] );
	as$status ( sts    = sts,
                    msg    = "co$place_text()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Create the LK text on the S line */
	action = 1;
	poly.points = &buffer[0];

	sts = om$send ( msg      = message GRlinear.GRgetpolyline (
                                        msg,
                                        &Env->md_env.matrix_type,
                                        Env->md_env.matrix,
                                        &action,
                                        &poly ),
                        senderid = NULL_OBJID,
                        targetid = Sline->objid,
                        targetos = Sline->osnum);
	as$status ( sts    = sts,
                    msg    = "GRlinear.GRgetpolyline",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
        dblcpy ( spt, &(poly.points[0]), 3);
        dblcpy ( ept, &(poly.points[3]), 3);

	sts = VLvector ( msg, ept, spt, 1.0, 1.0, TRUE,  Sxv);
	as$status ( sts    = sts,
                    msg    = "VLvector()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

        BScrossp ( &rc, Sxv, zvec, Szv);
        if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
        BSnorvec ( &rc, Szv);
        if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }

	txt[0] = '\0';
        sprintf ( txt, "%s", "L K");
        len = strlen(txt);
        for ( i=0; i<3; i++)    cnt[i] = (spt[i] + ept[i]) / 2.0;
        text_symb.Active_just = CENTER_CENTER;
	(*text_id)[1].objid = NULL_OBJID;
	(*text_id)[1].osnum = Env->md_id.osnum;
	sts = co$place_text ( msg         = msg,
                              text_string = txt,
                              text_length = &len,
                              lbs_matrix  = loc_mat,
                              origin      = cnt,
                              TextSymb    = &text_symb,
                              mode        = GRbe,
                              flags       = 1,
                              buffer      = &(*text_id)[1] );
	as$status ( sts    = sts,
                    msg    = "co$place_text()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Create the vertices $ sign */
	text_symb.Active_just = CENTER_CAP;
	for ( i=0; i<nvtx; i++) {
		txt[0] = '\0';
        	sprintf ( txt, "%s", "$");
        	len = strlen(txt);

		sts = VLvector ( msg, ept, &Vertex[3*i], 1.0, 1.0, TRUE, pnt);
		as$status ( sts    = sts,
                    	    msg    = "VLvector()",
                    	    test   = (!(sts & 0x00000001 & (*msg))),
                    	    action = GOTO_VALUE,
                    	    value  = wrapup );
		Xs = BSdotp( &rc, pnt, Sxv);
		Zs = BSdotp( &rc, pnt, Szv);

		for ( j=0; j<W;  j++) {
			Xa = Attr[idx+  j].desc.value.att_exp;
			Za = Attr[idx+W+j].desc.value.att_exp;
			if (  (fabs (Xs-Xa) <= 1.0e-5)
			   && (fabs (Zs-Za) <= 1.0e-5) ) {
				sprintf ( txt, "%s%c%cZ%d",
					  txt, ESC, LINEFEED, C+j+1 );
       				len = strlen(txt);
				j = W;
			}
		}

        	for ( j=0; j<3; j++)    cnt[j] = Vertex[3*i+j] - radius*yvec[j];
		(*text_id)[i+2].objid = NULL_OBJID;
		(*text_id)[i+2].osnum = Env->md_id.osnum;
		sts = co$place_text ( msg         = msg,
				      text_string = txt,
				      text_length = &len,
				      lbs_matrix  = loc_mat,
				      origin      = cnt,
				      TextSymb    = &text_symb,
				      mode        = GRbe,
				      flags       = 1,
				      buffer      = &(*text_id)[i+2] );
		as$status ( sts    = sts,
                	    msg    = "co$place_text()",
                	    test   = (!(sts & 0x00000001 & (*msg))),
                	    action = GOTO_VALUE,
                	    value  = wrapup );
	}

	/* Create the lines | sign */
	text_symb.Active_just = CENTER_CAP;
	idx += 2*W;
	for ( i=0; i<C; i++) {
		Xa = Attr[idx+  i].desc.value.att_exp;
		Za = Attr[idx+C+i].desc.value.att_exp;
        	for ( j=0; j<3; j++)
			cnt[j] = ept[j] + (Xa * Sxv[j]) - (Za * Szv[j]);
/*
printf( "Xa = %g\tSxv : [%g,%g,%g]\n", Xa, Sxv[0], Sxv[1], Sxv[2]);
printf( "Za = %g\tSzv : [%g,%g,%g]\n", Za, Szv[0], Szv[1], Szv[2]);
printf( "ept : [%g,%g,%g] --> cnt %d : [%g,%g,%g]\n",
	ept[0], ept[1], ept[2], i, cnt[0], cnt[1], cnt[2] );
*/
		txt[0] = '\0';
		sprintf ( txt, "|%c%cZ%d", ESC, LINEFEED, i+1);
       		len = strlen(txt);
		(*text_id)[i+2+nvtx].objid = NULL_OBJID;
		(*text_id)[i+2+nvtx].osnum = Env->md_id.osnum;
		sts = co$place_text ( msg         = msg,
				      text_string = txt,
				      text_length = &len,
				      lbs_matrix  = loc_mat,
				      origin      = cnt,
				      TextSymb    = &text_symb,
				      mode        = GRbe,
				      flags       = 1,
				      buffer      = &(*text_id)[i+2+nvtx] );
		as$status ( sts    = sts,
                	    msg    = "co$place_text()",
                	    test   = (!(sts & 0x00000001 & (*msg))),
                	    action = GOTO_VALUE,
                	    value  = wrapup );
	}

wrapup:
	return (sts);

/* End of function */
}
/* ========================================================================== */

/* ========================================================================== */
IGRlong VLextractVertices ( msg, ncrv, Curve, Inv, nvtx, Vertex)

/*d This function extracts the vertices of a bunch of ordered curves that are
    the components of composite curve. The vertices's array must be freed by
    the calling program. */

/*h 26/03/1993 : creation by Marc FOURNIER (ISDC). */

		IGRlong		*msg;		/*O Completion code	      */
		IGRint		ncrv;		/*I Number of curves	      */
	struct	GRobj_env	Curve[];	/*I Array of curves	      */
		IGRshort	Inv[];		/*I Curve inversion flag      */
		IGRint		*nvtx;		/*O Number of vertices	      */
		IGRdouble	**Vertex;	/*O Array of vertices	      */

{
/* Beginning of function */

		IGRlong		sts=OM_S_SUCCESS;
		IGRint		i, j;
		IGRpoint	spt, ept;

	/* Initialize */
	*nvtx   = ncrv + 1;
	*Vertex = NULL;
	if (ncrv < 1) {
		printf( "VLextractVertices() : no curves given !\n");
		*msg = MSFAIL;
		goto wrapup;
	}

	/* Allocate memory */
	*Vertex = om$calloc ( num = *nvtx * 3, structure = IGRdouble);
        if (*Vertex == NULL) { printf( "Unable to allocate <%d> bytes\n",
                                       *nvtx * 3 * sizeof(IGRdouble));
                               goto wrapup; }

	/* First step */
	sts = VLendpts ( msg, &Curve[0].obj_id, &Curve[0].mod_env, spt, ept);
	as$status ( sts    = sts,
                    msg    = "VLendpts()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	if (Inv[0] == 1) {	dblcpy ( &(*Vertex)[0], spt, 3);
				dblcpy ( &(*Vertex)[3], ept, 3);	}
	else { 			dblcpy ( &(*Vertex)[0], ept, 3);
				dblcpy ( &(*Vertex)[3], spt, 3);	}

	for ( i=1; i<ncrv; i++) {
		sts = VLendpts ( msg, &Curve[i].obj_id, &Curve[i].mod_env,
				  spt, ept);
		as$status ( sts    = sts,
                	    msg    = "VLendpts()",
                	    test   = (!(sts & 0x00000001 & (*msg))),
                	    action = GOTO_VALUE,
                	    value  = wrapup );

		/* Compute vertices */
		if (Inv[i] == 1) {
			for ( j=0; j<3; j++) 	(*Vertex)[3*i+j] =
						((*Vertex)[3*i+j]+spt[j]) / 2.0;
			dblcpy ( &(*Vertex)[3*i+3], ept, 3);
		}
		else {
			for ( j=0; j<3; j++) 	(*Vertex)[3*i+j] =
						((*Vertex)[3*i+j]+ept[j]) / 2.0;
			dblcpy ( &(*Vertex)[3*i+3], spt, 3);
		}
	}

wrapup:
	return (sts);

/* End of function */
}
/* ========================================================================== */

/* ========================================================================== */
IGRlong VLcreateScallops ( msg, nvtx, Vertex, Env, r, cst, c, d, b,
			   Scalloped, Unscallop  )

/*d This function constructs the scallops associated with the vertices. The
    input argument Curve is modified. */

/*h 31/03/1993 : creation by Marc FOURNIER (ISDC). */

		IGRlong		*msg;		/*O  Completion code	      */
		IGRint		nvtx;		/*I  Number of vertices	      */
		IGRdouble	Vertex[];	/*I  Array of vertices	      */
	struct	GRmd_env	*Env;		/*I  Module info	      */
		IGRdouble	r;		/*I  Scallops' radius	      */
	struct  GRvg_construct  *cst;   	/*I  Construction list        */
		IGRpoint	c;		/*I  Appx center of final obj */
		IGRdouble	d;		/*I  Distance tolerance	      */
		IGRdouble	b;		/*I  Basic tolerance	      */
	struct	GRid		*Scalloped;	/*IO Top cv with    scallops  */
	struct	GRid		*Unscallop;	/*O  Top cv without scallops  */

{
/* Beginning of function */

		IGRint		sts=OM_S_SUCCESS;
	struct	GRid		Copy;
		IGRint		i, j;
		IGRlong		size;
	struct	IGRbsp_surface	sphere;
		IGRdouble	*buffer;
		IGRint		po, wt, uk, vk;
	struct	IGRbsp_curve	*curve, cv1, cv2, cv3;
		BSrc		rc;
		IGRdouble	*inter, *pts, *t_par, *u_par, *v_par;
		IGRint		nint, num;
		IGRdouble	par1, par2, par3;
		IGRboolean	on_curve;
		IGRint		nseg;
	struct	GRobj_env	*Icv, *Ocv;
		IGRshort	*inv;
		IGRboolean	adj, clo;
	struct	GRlc_info	*entries;
		IGRpoint	spt, Spt, Ept;
		IGRvector	vec;
		IGRlong		l_msg;
		IGRboolean	reverse=FALSE, success=FALSE;
	struct	GRpost_info	post_info;

	/* Initialize */
	nseg = nvtx + 1;
	buffer  = NULL;
	curve   = NULL;
	inter   = NULL;
	pts     = NULL;
	t_par   = NULL;
	u_par   = NULL;
	v_par   = NULL;
	Icv     = NULL;
	Ocv     = NULL;
	inv     = NULL;
	entries = NULL;
	Spt[0] = Ept[0] = 0.0;
	if (nvtx <= 0)	goto wrapup;

	/* Save input curve */
	Copy.objid = NULL_OBJID;
	Copy.osnum = Env->md_id.osnum;
	sts = gr$copy_object ( msg		= msg,
			       object_id	= Scalloped,
			       md_env		= Env,
			       new_env		= Env,
			       new_id		= &Copy,
			       display_flag	= 0 );
	as$status ( sts    = sts,
                    msg    = "gr$copy_object()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Copy input curve in unscalloped curve */
	Unscallop->objid = NULL_OBJID;
	Unscallop->osnum = Env->md_id.osnum;
	sts = gr$copy_object ( msg		= msg,
			       object_id	= Scalloped,
			       md_env		= Env,
			       new_env		= Env,
			       new_id		= Unscallop,
			       display_flag	= 0 );
	as$status ( sts    = sts,
                    msg    = "gr$copy_object()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

#ifdef TRACE
	/* Extract endpoints */
	sts = VLendpts ( msg, &Copy, Env, Spt, Ept);
	as$status ( sts    = sts,
                    msg    = "VLendpts()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

printf( "Curve [%d|%d] enpoints : (%g,%g,%g) & (%g,%g,%g)\n",
	Copy.osnum, Copy.objid, Spt[0],Spt[1],Spt[2], Ept[0],Ept[1],Ept[2]);
#endif

	/* Extract IGRbsp_curve from input curve */
	sts = om$send ( msg      = message GRvg.GRgetsize (
						msg,
						&Env->md_env.matrix_type,
						Env->md_env.matrix,
						&size ),
			senderid = NULL_OBJID,
			targetid = Copy.objid,
			targetos = Copy.osnum );
	as$status ( sts    = sts,
                    msg    = "GRvg.GRgetsize",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	curve = (struct IGRbsp_curve *) om$calloc (size = size);
	if (curve == NULL) { printf( "Unable to allocate %d bytes\n", size);
                	     goto wrapup; }
	sts = om$send ( msg      = message GRvg.GRgetgeom (
						msg,
						&Env->md_env.matrix_type,
						Env->md_env.matrix,
						(IGRchar *) curve ),
			senderid = NULL_OBJID,
			targetid = Copy.objid,
			targetos = Copy.osnum );
	as$status ( sts    = sts,
                    msg    = "GRvg.GRgetgeom",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Determine if vertices are in reverse order */
	if (nvtx >= 2) {
		on_curve = FALSE;
		par1     = -1.0;
		BSprptoncv ( &rc, curve, &Vertex[0], &par1, &on_curve);
        	if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
		if (on_curve == FALSE) {
			printf( "1st Vertex [%lf|%lf|%lf] not on curve\n",
				Vertex[0], Vertex[1], Vertex[2]);
			*msg = MSFAIL; goto wrapup; }

		on_curve = FALSE;
		par2     = -1.0;
		BSprptoncv ( &rc, curve, &Vertex[3], &par2, &on_curve);
        	if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
		if (on_curve == FALSE) {
			printf( "2nd Vertex [%lf|%lf|%lf] not on curve\n",
				Vertex[3], Vertex[4], Vertex[5]);
			*msg = MSFAIL; goto wrapup; }

		if (par2 < par1)	reverse = TRUE;
	}
#ifdef TRACE
printf( "par1=%lf\tpar2=%lf\treverse=%d\n", par1, par2, reverse);
#endif
	if (reverse == TRUE) {
		if (BSrev_cv ( &rc, curve) == FALSE) { *msg = MSFAIL;
						       goto wrapup; }
	}
	
	/* Allocate memory for intersection points' array */
	inter = om$calloc ( num = 2 * 3 * nvtx, structure = IGRdouble);
        if (inter == NULL) { printf( "Unable to allocate <%d> bytes\n",
                                     2 * 3 * nvtx * sizeof(IGRdouble));
                             goto wrapup; }

	/* Allocate memory for sphere IGRbsp_surface */
	po = 0;
	wt = po + (BSCIRCLE_NUM_POLES_MAX * 5 * 3);
	uk = wt + (BSCIRCLE_NUM_POLES_MAX * 5 * 1);
	vk = uk + (5 + BSCIRCLE_ORDER);
	size = (vk + BSCIRCLE_NUM_KNOTS_MAX) * sizeof(IGRdouble);
	buffer = (IGRdouble *) om$calloc (size = size);
	if (buffer == NULL) { printf( "Unable to allocate <%d> bytes", size);
                	      goto wrapup; }
	sphere.poles    = &buffer[po];
	sphere.weights  = &buffer[wt];
	sphere.u_knots  = &buffer[uk];
	sphere.v_knots  = &buffer[vk];

#ifdef TRACE
printf( "\n");
	for ( i=0; i<nvtx; i++) {
		on_curve = FALSE;
		par2     = -1.0;
		BSprptoncv ( &rc, curve, &Vertex[3*i], &par2, &on_curve);
        	if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
		if (on_curve == FALSE) {
			printf( "Vertex [%lf|%lf|%lf] not on curve\n",
				Vertex[3*i], Vertex[3*i+1], Vertex[3*i+2]);
			*msg = MSFAIL; continue;
		}
		else 	printf( "Vertex\t[%lf|%lf|%lf]\thave param=%lf\n",
				Vertex[3*i], Vertex[3*i+1], Vertex[3*i+2],par2);
	}
printf( "\n");
#endif

	/* Construct intersection between curve & vertices' sphere */
	for ( i=0; i<nvtx; i++) {
		/* Construct proximity sphere */
		BSprepsphr ( &rc, &Vertex[3*i], &r, &sphere);
        	if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }

		/* Intersect sphere & curve */
		BScv_sf_int ( &rc, curve, &sphere,
			      &nint, &pts, &t_par, &u_par, &v_par);
        	if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
		dblcpy ( &inter[6*i+0], &pts[0], 3);
		dblcpy ( &inter[6*i+3], &pts[3], 3);
		
		/* Free memory */
		if (pts)    { om$dealloc (ptr = pts);    pts    = NULL; }
		if (t_par)  { om$dealloc (ptr = t_par);  t_par  = NULL; }
		if (u_par)  { om$dealloc (ptr = u_par);  u_par  = NULL; }
		if (v_par)  { om$dealloc (ptr = v_par);  v_par  = NULL; }
	}
	if (buffer) { om$dealloc (ptr = buffer); buffer = NULL; }

#ifdef TRACE
printf( "\n");
	for ( i=0; i<nvtx; i++) {

		on_curve = FALSE;
		par1     = -1.0;
		BSprptoncv ( &rc, curve, &inter[6*i], &par1, &on_curve);
        	if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
		if (on_curve == FALSE) {
			printf( "Inter1 [%lf|%lf|%lf] not on curve\n",
				inter[6*i], inter[6*i+1], inter[6*i+2]);
			*msg = MSFAIL; continue;
		}
		else 	printf( "Left Inter\t[%lf|%lf|%lf]\thave param=%lf\n",
				inter[6*i], inter[6*i+1], inter[6*i+2], par1);

		on_curve = FALSE;
		par3     = -1.0;
		BSprptoncv ( &rc, curve, &inter[6*i+3], &par3, &on_curve);
        	if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
		if (on_curve == FALSE) {
			printf( "Inter3 [%lf|%lf|%lf] not on curve\n",
				inter[6*i+3], inter[6*i+4], inter[6*i+5]);
			*msg = MSFAIL; continue;
		}
		else 	printf( "Right Inter\t[%lf|%lf|%lf]\thave param=%lf\n",
				inter[6*i+3], inter[6*i+4], inter[6*i+5], par3);
	}
printf( "\n");
#endif

	/* Allocate memory for two IGRbsp_curve */
	po = 0;
	wt = po + 3 * curve->num_poles;
	uk = wt + curve->num_poles;
	vk = uk + curve->num_knots;
	size = 2 * vk * sizeof(IGRdouble);
	buffer = (IGRdouble *) om$calloc (size = size);
	if (buffer == NULL) { printf( "Unable to allocate <%d> bytes", size);
                	      goto wrapup; }
	cv1.poles   = &buffer[po];	cv2.poles   = &buffer[vk + po];
	cv1.weights = &buffer[wt];	cv2.weights = &buffer[vk + wt];
	cv1.knots   = &buffer[uk];	cv2.knots   = &buffer[vk + uk];

	/* Allocate memory for segments & arcs (GRobj_env) */
	Icv = om$calloc ( num = nvtx + nseg, structure = struct GRobj_env);
        if (Icv == NULL) { printf( "Unable to allocate <%d> bytes\n",
                                   (nvtx + nseg) * sizeof(struct GRobj_env));
                           goto wrapup; }
	for ( i=0; i<nvtx+nseg; i++) { Icv[i].obj_id.objid = NULL_OBJID;
				       Icv[i].obj_id.osnum = Env->md_id.osnum;
				       Icv[i].mod_env      = *Env; }

	Ocv = om$calloc ( num = nvtx + nseg, structure = struct GRobj_env);
        if (Ocv == NULL) { printf( "Unable to allocate <%d> bytes\n",
                                   (nvtx + nseg) * sizeof(struct GRobj_env));
                           goto wrapup; }

	inv = om$calloc ( num = nvtx + nseg, structure = IGRshort);
        if (inv == NULL) { printf( "Unable to allocate <%d> bytes\n",
                                   (nvtx + nseg) * sizeof(IGRshort));
                           goto wrapup; }

	entries = om$calloc ( num = nvtx + nseg, structure = struct GRlc_info);
        if (entries == NULL) { printf( "Unable to allocate <%d> bytes\n",
                                       (nvtx+nseg) * sizeof(struct GRlc_info));
                               goto wrapup; }

	/* Create segments by partial delete */
	Icv[0].obj_id = Copy;
	for ( i=0; i<nvtx; i++) {

#ifdef TRACE
/*
printf( "\n\tCURVE for Vertex %d\n", i);
for (j=0;j<curve->num_poles;j++) {
	printf( "Pole\t%d\t[%g|%g|%g]", i,
		curve->poles[3*j], curve->poles[3*j+1], curve->poles[3*j+2] );
	if (curve->rational) printf( "\t[%g]", curve->weights[j]);
	printf( "\n");
}
*/
#endif

		/* Retrieve parameters of the left point */
		on_curve = FALSE;
		par1     = -1.0;
		BSprptoncv ( &rc, curve, &inter[6*i],  &par1, &on_curve);
        	if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
		if (on_curve == FALSE) {
#ifdef TRACE
			printf( "\tPoint 1 : [%lf|%lf|%lf] not on curve\n",
				inter[6*i], inter[6*i+1], inter[6*i+2]);
#endif
			*msg = MSFAIL; goto wrapup; }

		/* Retrieve parameters of the center point */
		on_curve = FALSE;
		par2     = -1.0;
		BSprptoncv ( &rc, curve, &Vertex[3*i], &par2, &on_curve);
        	if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
		if (on_curve == FALSE) {
#ifdef TRACE
                        printf( "\tPoint 2 : [%lf|%lf|%lf] not on curve\n",
                                Vertex[3*i], Vertex[3*i+1], Vertex[3*i+2]);
#endif
                        *msg = MSFAIL; goto wrapup; }

		/* Retrieve parameters of the right point */
		on_curve = FALSE;
		par3     = -1.0;
		BSprptoncv ( &rc, curve, &inter[6*i+3],  &par3, &on_curve);
        	if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
		if (on_curve == FALSE) {
#ifdef TRACE
			printf( "\tPoint 3 : [%lf|%lf|%lf] not on curve\n",
				inter[6*i+3], inter[6*i+4], inter[6*i+5]);
#endif
			*msg = MSFAIL; goto wrapup; }

#ifdef TRACE
		if (*msg != MSFAIL) printf( "Parameters are : (%g,%g,%g)\n",
					    par1, par2, par3);
#endif

		/* Partial delete operation */
		BSpardelcv ( curve, par1, par2, par3, &num, &cv1, &cv2, &rc);
        	if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }

		/* Delete old cv1 3D B-spline curve */
		sts = gr$delete_object ( msg       = msg,
				         md_env    = &Icv[i].mod_env,
				         object_id = &Icv[i].obj_id );
		as$status ( sts    = sts,
                	    msg    = "gr$delete_object()",
                	    test   = (!(sts & 0x00000001 & (*msg))),
                	    action = GOTO_VALUE,
                	    value  = wrapup );

		/* Create 3D B-spline curve from cv1 */
		cst->geometry = (IGRchar *) &cv1;
		Icv[i].obj_id.objid = NULL_OBJID;
		sts = om$construct ( classid = OPP_GRbcsubbc_class_id,
                             	     osnum   = Icv[i].obj_id.osnum,
                             	     p_objid = &Icv[i].obj_id.objid,
                             	     msg     = message GRgraphics.GRconstruct
								(cst) );
		as$status ( sts    = sts,
                	    msg    = "om$construct(GRgraphics.GRconstruct)",
                	    test   = (!(sts & 0x00000001 & (*(cst->msg)))),
                	    action = GOTO_VALUE,
                	    value  = wrapup );

		/* Create 3D B-spline curve from cv2 */
		cst->geometry = (IGRchar *) &cv2;
		Icv[i+1].obj_id.objid = NULL_OBJID;
		sts = om$construct ( classid = OPP_GRbcsubbc_class_id,
                             	     osnum   = Icv[i+1].obj_id.osnum,
                             	     p_objid = &Icv[i+1].obj_id.objid,
                             	     msg     = message GRgraphics.GRconstruct
								(cst) );
		as$status ( sts    = sts,
                	    msg    = "om$construct(GRgraphics.GRconstruct)",
                	    test   = (!(sts & 0x00000001 & (*(cst->msg)))),
                	    action = GOTO_VALUE,
                	    value  = wrapup );
		*curve = cv2;
	}
	if (buffer) { om$dealloc (ptr = buffer); buffer = NULL; }

	/* Allocate memory for one IGRbsp_curve */
	po = 0;
	wt = po + 3 * 7;
	uk = wt + 1 * 7;
	vk = uk + 10;
	size = vk * sizeof(IGRdouble);
	buffer = (IGRdouble *) om$calloc (size = size);
	if (buffer == NULL) { printf( "Unable to allocate %d bytes\n", size);
                	      goto wrapup; }
	cv3.rational= TRUE;
	cv3.poles   = &buffer[po];
	cv3.weights = &buffer[wt];
	cv3.knots   = &buffer[uk];
	
	/* Construct arcs */
	cst->geometry = (IGRchar *) &cv3;
	for ( i=0; i<nvtx; i++) {

		/* Contruct arc track point */
		for ( j=0; j<3; j++) vec[j] = c[j] - Vertex[3*i+j];
        	BSnorvec ( &rc, vec);
        	if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
		for ( j=0; j<3; j++) spt[j] = Vertex[3*i+j] + (r * vec[j]);

		BSarc3pts ( &rc, &inter[6*i], &spt[0], &inter[6*i+3], &cv3);
        	if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }

		/* Create 3D B-spline curve from cv3 */
		Icv[i+nseg].obj_id.osnum = Env->md_id.osnum;
		Icv[i+nseg].obj_id.objid = NULL_OBJID;
		sts = om$construct ( classid = OPP_GRbcsubbc_class_id,
                             	     osnum   = Icv[i+nseg].obj_id.osnum,
                             	     p_objid = &Icv[i+nseg].obj_id.objid,
                             	     msg     = message GRgraphics.GRconstruct
								(cst) );
		as$status ( sts    = sts,
                	    msg    = "om$construct(GRgraphics.GRconstruct)",
                	    test   = (!(sts & 0x00000001 & (*(cst->msg)))),
                	    action = GOTO_VALUE,
                	    value  = wrapup );
	}

	/* Order segments & arcs */
	OrderCrv ( Icv, (nseg+nvtx), d, b, Ocv, inv, &adj, &clo, msg);
        if (*msg != BSSUCC) { printf( "Error in OrderCrv() : %d\n", *msg);
                	      *msg = MSFAIL; goto wrapup; }

	/* Build composite curve */
	for ( i=0; i<nseg+nvtx; i++) {
		entries[i].module_info = Ocv[i].mod_env;
		entries[i].located_obj = Ocv[i].obj_id;
	}
	BuildCrv ( 2, Ocv, nseg+nvtx, inv, adj, clo, entries, cst, &Copy, msg);
        if (*msg != BSSUCC) { printf( "Error in BuildCrv() : %d\n", *msg);
                	      *msg = MSFAIL; goto wrapup; }
        else *msg = MSSUCC;

	/* Put computed scalloped curve in the output argument */
	sts = gr$delete_object ( msg       = msg,
				 md_env    = Env,
				 object_id = Scalloped );
	as$status ( sts    = sts,
                    msg    = "gr$delete_object()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	*Scalloped = Copy;
	success    = TRUE;
	
wrapup:

	if (reverse == TRUE) {
		sts = om$send ( msg      = message GRvg.GRgetsize (
						&l_msg,
						&Env->md_env.matrix_type,
						Env->md_env.matrix,
						&size ),
				senderid = NULL_OBJID,
				targetid = Unscallop->objid,
				targetos = Unscallop->osnum );
		as$status ( sts    = sts,
                	    msg    = "GRvg.GRgetsize",
                	    test   = (!(sts & 0x00000001 & (l_msg))),
                	    action = GOTO_VALUE,
                	    value  = wrapup );

		if (curve)  { om$dealloc (ptr = curve);  curve  = NULL; }
		curve = (struct IGRbsp_curve *) om$calloc (size = size);
		if (curve == NULL) { printf( "Unable to allocate %d bytes\n",
				     size);
                	     	     goto quit; }

		sts = om$send ( msg      = message GRvg.GRgetgeom (
						&l_msg,
						&Env->md_env.matrix_type,
						Env->md_env.matrix,
						(IGRchar *) curve ),
				senderid = NULL_OBJID,
				targetid = Unscallop->objid,
				targetos = Unscallop->osnum );
		as$status ( sts    = sts,
                	    msg    = "GRvg.GRgetgeom",
                	    test   = (!(sts & 0x00000001 & (l_msg))),
                	    action = GOTO_VALUE,
                	    value  = wrapup );

		if (BSrev_cv ( &rc, curve) == FALSE) 	goto quit;

		post_info.construct_flag = FALSE;
		sts = om$send ( msg      = message GRvg.GRpostabsg (
						&l_msg,
						Env,
						&post_info,
						(IGRchar *) curve,
						&(Unscallop->objid) ),
				senderid = NULL_OBJID,
				targetid = Unscallop->objid,
				targetos = Unscallop->osnum );
		as$status ( sts    = sts,
                	    msg    = "GRvg.GRpostabsg",
                	    test   = (!(sts & 0x00000001 & (l_msg))),
                	    action = GOTO_VALUE,
                	    value  = wrapup );
		if (success == FALSE) {
			sts = om$send ( msg      = message GRvg.GRgetsize (
						&l_msg,
						&Env->md_env.matrix_type,
						Env->md_env.matrix,
						&size ),
					senderid = NULL_OBJID,
					targetid = Scalloped->objid,
					targetos = Scalloped->osnum );
			as$status ( sts    = sts,
                		    msg    = "GRvg.GRgetsize",
                		    test   = (!(sts & 0x00000001 & (l_msg))),
                		    action = GOTO_VALUE,
                		    value  = wrapup );

			if (curve) { om$dealloc (ptr = curve);  curve  = NULL; }
			curve = (struct IGRbsp_curve *) om$calloc (size = size);
			if (curve == NULL) {
				printf( "Unable to allocate %d bytes\n", size);
                	     	goto quit; }

			sts = om$send ( msg      = message GRvg.GRgetgeom (
						&l_msg,
						&Env->md_env.matrix_type,
						Env->md_env.matrix,
						(IGRchar *) curve ),
					senderid = NULL_OBJID,
					targetid = Scalloped->objid,
					targetos = Scalloped->osnum );
			as$status ( sts    = sts,
                		    msg    = "GRvg.GRgetgeom",
                		    test   = (!(sts & 0x00000001 & (l_msg))),
                		    action = GOTO_VALUE,
                		    value  = wrapup );

			if (BSrev_cv ( &rc, curve) == FALSE) 	goto quit;

			post_info.construct_flag = FALSE;
			sts = om$send ( msg      = message GRvg.GRpostabsg (
							&l_msg,
							Env,
							&post_info,
							(IGRchar *) curve,
							&(Scalloped->objid) ),
					senderid = NULL_OBJID,
					targetid = Scalloped->objid,
					targetos = Scalloped->osnum );
			as$status ( sts    = sts,
                		    msg    = "GRvg.GRpostabsg",
                		    test   = (!(sts & 0x00000001 & (l_msg))),
                		    action = GOTO_VALUE,
                		    value  = wrapup );
		}
        }

#ifdef TRACE
/*
printf( "\n\tOUTPUT CURVE\n");
for (i=0;i<curve->num_poles;i++) {
	printf( "Pole\t%d\t[%g|%g|%g]", i,
		curve->poles[3*i], curve->poles[3*i+1], curve->poles[3*i+2] );
	if (curve->rational) printf( "\t[%g]", curve->weights[i]);
	printf( "\n");
}
*/
#endif

quit:
	for ( i=0; i<nseg+nvtx; i++) {

		if (Icv) {
			if (Icv[i].obj_id.objid != NULL_OBJID)
				gr$delete_object ( msg	     = &l_msg,
				   	   	   md_env    = &Icv[i].mod_env,
				   	   	   object_id = &Icv[i].obj_id );
		}
		if (Ocv) {
			if (Ocv[i].obj_id.objid != NULL_OBJID)
				gr$delete_object ( msg	     = &l_msg,
				   	   	   md_env    = &Ocv[i].mod_env,
				   	   	   object_id = &Ocv[i].obj_id );
		}
	}
/* printf( "om$dealloc(entries)\n"); */
	if (entries){ om$dealloc (ptr = entries);entries= NULL; }
/* printf( "om$dealloc(inv)\n"); */
	if (inv)    { om$dealloc (ptr = inv);    inv    = NULL; }
/* printf( "om$dealloc(Ocv)\n"); */
	if (Ocv)    { om$dealloc (ptr = Ocv);    Ocv    = NULL; }
/* printf( "om$dealloc(Icv)\n"); */
	if (Icv)    { om$dealloc (ptr = Icv);    Icv    = NULL; }
/* printf( "om$dealloc(inter)\n"); */
	if (inter)  { om$dealloc (ptr = inter);  inter  = NULL; }
/* printf( "om$dealloc(pts)\n"); */
	if (pts)    { om$dealloc (ptr = pts);    pts    = NULL; }
/* printf( "om$dealloc(t_par)\n"); */
	if (t_par)  { om$dealloc (ptr = t_par);  t_par  = NULL; }
/* printf( "om$dealloc(u_par)\n"); */
	if (u_par)  { om$dealloc (ptr = u_par);  u_par  = NULL; }
/* printf( "om$dealloc(v_par)\n"); */
	if (v_par)  { om$dealloc (ptr = v_par);  v_par  = NULL; }
/* printf( "om$dealloc(buffer)\n"); */
	if (buffer) { om$dealloc (ptr = buffer); buffer = NULL; }
/* printf( "om$dealloc(curve)\n"); */
	if (curve)  { om$dealloc (ptr = curve);  curve  = NULL; }

	return (sts);

/* End of function */
}
/* ========================================================================== */

/* ========================================================================== */
IGRlong VLcreateJigBox ( msg, LK, TP, Env, nvtx, Vertex, ncln, Clines,
			 offset, index, Xpln, Box, Attr)

/*d This function creates an attribute box filled with XZ values of specific
    points of the template_jig. */

/*h 19/04/1993 : creation by Marc FOURNIER (ISDC). */

		IGRlong		*msg;		/*O Completion code       */
	struct	GRid		*LK;		/*I LK line object	  */
	struct	GRid		*TP;		/*I Top line object	  */
	struct	GRmd_env	*Env;		/*I Target module info	  */
		IGRint		nvtx;		/*I Number of vertices	  */
		IGRdouble	Vertex[];	/*I Array of vertices	  */
		IGRint		ncln;		/*I Number of char lines  */
		IGRdouble	Clines[];	/*I Array of char points  */
		IGRdouble	offset;		/*I Offset value	  */
		IGRchar		index[];	/*I Index template_jig	  */
		IGRdouble	Xpln[];		/*I Normal to construct   */
	struct	GRid		*Box;		/*O Attributes box object */
	struct	ACrg_coll	**Attr;		/*O Rigid collection	  */

{
/* Beginning of function */

		IGRint		sts=OM_S_SUCCESS;
		IGRpoint	Spt, Ept;
		IGRpoint	spt, ept;
		IGRvector	LKdir, LKort;
		IGRint		i, j;
		BSrc		rc;
		IGRvector	curr;
		IGRdouble	X1, Z1, X2, Z2, X, Z;
		IGRint		ndiv1, ndiv2;
		IGRvector	odir1, odir2;
		IGRlong		size;
	struct	IGRbsp_curve	*cv;
		IGRint		num_attr;
		IGRint		idx;
		IGRint		n_int, ns;
		IGRdouble	*pts, *u, *a, *b;

	/* Initialize */
	cv	 = NULL;
	*Attr    = NULL;
	pts	 = NULL;
	u	 = NULL;
	a	 = NULL;
	b	 = NULL;


	/* Extract extended & punched curve extremities */
	sts = VLendpts ( msg, TP, Env, Spt, Ept);
	as$status ( sts    = sts,
                    msg    = "VLendpts()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Build director vector of the LK line */
	sts = VLendpts ( msg, LK, Env, spt, ept);
	as$status ( sts    = sts,
                    msg    = "VLendpts()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	sts = VLvector ( msg, ept, spt, 1.0, 1.0, TRUE, LKdir);
	as$status ( sts    = sts,
                    msg    = "VLvector()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	BScrossp ( &rc, LKdir, Xpln, LKort);
        if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
	BSnorvec ( &rc, LKort);
        if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }

	/* Evaluate extremity 1 */
	sts = VLvector ( msg, ept, Spt, 1.0, 1.0, FALSE,  curr);
	as$status ( sts    = sts,
                    msg    = "VLvector()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	X1 = BSdotp ( &rc, LKdir, curr);
        if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }

	sts = VLvector ( msg, LKdir, curr, X1, 1.0, FALSE,  curr);
	as$status ( sts    = sts,
                    msg    = "VLvector()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	Z1 = BSdotp ( &rc, LKort, curr);
        if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
	ndiv1 = fabs(Z1) / offset;

	/* Construct direction 1 vector */
	ndiv1++;
	dblcpy ( odir1, curr, 3);
	BSnorvec ( &rc, odir1);
        if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }

	/* Evaluate extremity 2 */
	sts = VLvector ( msg, ept, Ept, 1.0, 1.0, FALSE,  curr);
	as$status ( sts    = sts,
                    msg    = "VLvector()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	X2 = BSdotp ( &rc, LKdir, curr);
        if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }

	sts = VLvector ( msg, LKdir, curr, X2, 1.0, FALSE,  curr);
	as$status ( sts    = sts,
                    msg    = "VLvector()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	Z2 = BSdotp ( &rc, LKort, curr);
        if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
	ndiv2 = fabs(Z2) / offset;

	/* Construct direction 2 vector */
	dblcpy ( odir2, curr, 3);
	BSnorvec ( &rc, odir2);
        if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }

	/* Extract IGRbsp_curve for TOP line */
	sts = om$send ( msg      = message GRvg.GRgetsize (
                                                msg,
                                                &Env->md_env.matrix_type,
                                                Env->md_env.matrix,
                                                &size ),
			senderid = NULL_OBJID,
                        targetid = TP->objid,
                        targetos = TP->osnum );
	as$status ( sts    = sts,
                    msg    = "GRvg.GRgetsize",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
        cv = (struct IGRbsp_curve *) om$calloc (size = size);
        if (cv == NULL) { printf( "Unable to allocate <%d> bytes\n", size);
                          goto wrapup; }
        sts = om$send ( msg      = message GRvg.GRgetgeom (
                                                msg,
                                                &Env->md_env.matrix_type,
                                                Env->md_env.matrix,
                                                (IGRchar *) cv ),
			senderid = NULL_OBJID,
                        targetid = TP->objid,
                        targetos = TP->osnum );
	as$status ( sts    = sts,
                    msg    = "GRvg.GRgetgeom",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Allocate memory for rigid collection */
	num_attr = 10 + 2 * (ndiv1 + ndiv2 + (nvtx - 2) + ncln);
	*Attr = om$calloc ( num = num_attr, structure = struct ACrg_coll);
	if (*Attr == NULL) {	printf( "Unable to allocate <%d> bytes\n",
			                num_attr * sizeof(struct ACrg_coll));
				goto wrapup; }

	/* Give name to the elements of the rigid collection */
	strcpy ( (*Attr)[IDX_RG_P_INDEX].name, NAM_RG_P_INDEX);
	strcpy ( (*Attr)[IDX_RG_P_E_NUM].name, NAM_RG_P_E_NUM);
	strcpy ( (*Attr)[IDX_RG_P_R_NUM].name, NAM_RG_P_R_NUM);
	strcpy ( (*Attr)[IDX_RG_P_L_NUM].name, NAM_RG_P_L_NUM);
	strcpy ( (*Attr)[IDX_RG_P_W_NUM].name, NAM_RG_P_W_NUM);
	strcpy ( (*Attr)[IDX_RG_P_C_NUM].name, NAM_RG_P_C_NUM);
idx = IDX_RG_P_VALUE;
	for ( i=0; i<2; i++)
		sprintf( (*Attr)[idx+i].name, "%s%d", NAM_RG_P_E_XPT, i);
idx += 2;
	for ( i=0; i<2; i++)
		sprintf( (*Attr)[idx+i].name, "%s%d", NAM_RG_P_E_ZPT, i);
idx += 2;
	for ( i=0; i<ndiv1; i++) {
		sprintf( (*Attr)[idx+i].name, "%s%d", NAM_RG_P_R_XPT, i);
		sprintf( (*Attr)[idx+ndiv1+i].name, "%s%d", NAM_RG_P_R_ZPT, i);
	}
idx += 2*ndiv1;
	for ( i=0; i<ndiv2; i++) {
		sprintf( (*Attr)[idx+i].name, "%s%d", NAM_RG_P_L_XPT, i);
		sprintf( (*Attr)[idx+ndiv2+i].name, "%s%d", NAM_RG_P_L_ZPT, i);
	}
idx += 2*ndiv2;
	for ( i=0; i<nvtx-2; i++) {
		sprintf( (*Attr)[idx     +i].name, "%s%d", NAM_RG_P_W_XPT, i);
		sprintf( (*Attr)[idx+nvtx-2+i].name,
			 "%s%d", NAM_RG_P_W_ZPT, i);
	}
idx += 2*(nvtx-2);
	for ( i=0; i<ncln; i++) {
		sprintf( (*Attr)[idx     +i].name, "%s%d", NAM_RG_P_C_XPT, i);
		sprintf( (*Attr)[idx+ncln+i].name,
			 "%s%d", NAM_RG_P_C_ZPT, i);
	}

	/* Give type to the elements of the rigid collection */
	(*Attr)[IDX_RG_P_INDEX].desc.type = AC_ATTRIB_TEXT;
	for ( i=IDX_RG_P_E_NUM; i<num_attr; i++)
		(*Attr)[i].desc.type = AC_ATTRIB_DOUBLE;

	/* Give value to some elements of the rigid collection */
	strcpy ( (*Attr)[IDX_RG_P_INDEX].desc.value.att_txt, index);
	(*Attr)[IDX_RG_P_E_NUM].desc.value.att_exp = 2;
	(*Attr)[IDX_RG_P_R_NUM].desc.value.att_exp = ndiv1;
	(*Attr)[IDX_RG_P_L_NUM].desc.value.att_exp = ndiv2;
	(*Attr)[IDX_RG_P_W_NUM].desc.value.att_exp = nvtx-2;
	(*Attr)[IDX_RG_P_C_NUM].desc.value.att_exp = ncln;
	(*Attr)[IDX_RG_P_VALUE+0].desc.value.att_exp = Z1;
	(*Attr)[IDX_RG_P_VALUE+1].desc.value.att_exp = Z2;
	(*Attr)[IDX_RG_P_VALUE+2].desc.value.att_exp = X1;
	(*Attr)[IDX_RG_P_VALUE+3].desc.value.att_exp = X2;

	/* Allocate memory for BSpl_cv_int() structures */
	pts = om$calloc ( num = 3 * cv->num_poles, structure = IGRdouble);
	if (pts == NULL) {	printf( "Unable to allocate <%d> bytes\n",
			                3 * cv->num_poles * sizeof(IGRdouble));
				goto wrapup; }

	u = om$calloc ( num = cv->num_poles, structure = IGRdouble);
	if (u == NULL) {	printf( "Unable to allocate <%d> bytes\n",
			                cv->num_poles * sizeof(IGRdouble));
				goto wrapup; }

	a = om$calloc ( num = cv->num_poles, structure = IGRdouble);
	if (a == NULL) {	printf( "Unable to allocate <%d> bytes\n",
			                cv->num_poles * sizeof(IGRdouble));
				goto wrapup; }

	b = om$calloc ( num = cv->num_poles, structure = IGRdouble);
	if (b == NULL) {	printf( "Unable to allocate <%d> bytes\n",
			                cv->num_poles * sizeof(IGRdouble));
				goto wrapup; }

	/* Evaluate division points (1) */
idx = IDX_RG_P_VALUE + 4;
	for ( i=0; i<ndiv1; i++) {
		for ( j=0; j<3; j++)
			curr[j] = ept[j] + (i * offset * odir1[j]);
		BSpl_cv_int ( &rc, cv, curr, odir1, &n_int, pts, u, &ns, a, b);
		if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
		for ( j=0; j<3; j++)    curr[j] = pts[j] - ept[j];
		X = BSdotp( &rc, LKdir, curr);
		(*Attr)[idx+i].desc.value.att_exp = X;
		if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
		for ( j=0; j<3; j++)    curr[j] -= X * LKdir[j];
		Z = BSdotp ( &rc, LKort, curr);
		(*Attr)[idx+ndiv1+i].desc.value.att_exp = Z;
		if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
	}
	(*Attr)[idx+ndiv1].desc.value.att_exp = 0.0;

	/* Evaluate division points (2) */
idx += 2*ndiv1;
	for ( i=0; i<ndiv2; i++) {
		for ( j=0; j<3; j++)
			curr[j] = ept[j] + ((i+1) * offset * odir2[j]);
		BSpl_cv_int ( &rc, cv, curr, odir2, &n_int, pts, u, &ns, a, b);
		if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
		for ( j=0; j<3; j++)    curr[j] = pts[j] - ept[j];
		X = BSdotp( &rc, LKdir, curr);
		(*Attr)[idx+i].desc.value.att_exp = X;
		if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
		for ( j=0; j<3; j++)    curr[j] -= X * LKdir[j];
		Z = BSdotp ( &rc, LKort, curr);
		(*Attr)[idx+ndiv2+i].desc.value.att_exp = Z;
		if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
	}

	/* Evaluate weld points */
idx += 2*ndiv2;
	for ( i=0; i<nvtx-2; i++) {
		sts = VLvector ( msg, ept, &Vertex[3*i+3], 1.0, 1.0, FALSE,
				  curr);
		as$status ( sts    = sts,
                    	    msg    = "VLvector()",
                    	    test   = (!(sts & 0x00000001 & (*msg))),
                    	    action = GOTO_VALUE,
                    	    value  = wrapup );
		X = BSdotp ( &rc, LKdir, curr);
		(*Attr)[idx+i].desc.value.att_exp = X;
		if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
		sts = VLvector ( msg, LKdir, curr, X, 1.0, FALSE, curr);
		as$status ( sts    = sts,
                    	    msg    = "VLvector()",
                    	    test   = (!(sts & 0x00000001 & (*msg))),
                    	    action = GOTO_VALUE,
                    	    value  = wrapup );
		Z = BSdotp ( &rc, LKort, curr);
		(*Attr)[idx+nvtx-2+i].desc.value.att_exp = Z;
		if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
	}

	/* Evaluate characteristic points */
idx += 2*(nvtx-2);
	for ( i=0; i<ncln; i++) {
		sts = VLvector ( msg, ept, &Clines[3*i], 1.0, 1.0, FALSE,
				  curr);
		as$status ( sts    = sts,
                    	    msg    = "VLvector()",
                    	    test   = (!(sts & 0x00000001 & (*msg))),
                    	    action = GOTO_VALUE,
                    	    value  = wrapup );
		X = BSdotp ( &rc, LKdir, curr);
		(*Attr)[idx+i].desc.value.att_exp = X;
		if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
		sts = VLvector ( msg, LKdir, curr, X, 1.0, FALSE, curr);
		as$status ( sts    = sts,
                    	    msg    = "VLvector()",
                    	    test   = (!(sts & 0x00000001 & (*msg))),
                    	    action = GOTO_VALUE,
                    	    value  = wrapup );
		Z = BSdotp ( &rc, LKort, curr);
		(*Attr)[idx+ncln+i].desc.value.att_exp = Z;
		if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
	}

/*
printf("\n");

idx = IDX_RG_P_VALUE + 4;
for ( i=0; i<ndiv1; i++)
printf( "\t%s=%g\t%s=%g\n",
	(*Attr)[idx+i].name, (*Attr)[idx+i].desc.value.att_exp,
	(*Attr)[idx+ndiv1+i].name, (*Attr)[idx+ndiv1+i].desc.value.att_exp);

idx += 2*ndiv1;
for ( i=0; i<ndiv2; i++)
printf( "\t%s=%g\t%s=%g\n",
	(*Attr)[idx+i].name, (*Attr)[idx+i].desc.value.att_exp,
	(*Attr)[idx+ndiv2+i].name, (*Attr)[idx+ndiv2+i].desc.value.att_exp);

idx += 2*ndiv2;
for ( i=0; i<nvtx-2; i++)
printf( "\t%s=%g\t%s=%g\n",
	(*Attr)[idx+i].name, (*Attr)[idx+i].desc.value.att_exp,
	(*Attr)[idx+nvtx-2+i].name, (*Attr)[idx+nvtx-2+i].desc.value.att_exp);

idx += 2*(nvtx-2);
for ( i=0; i<ncln; i++)
printf( "\t%s=%g\t%s=%g\n",
	(*Attr)[idx+i].name, (*Attr)[idx+i].desc.value.att_exp,
	(*Attr)[idx+cln+i].name, (*Attr)[idx+cln+i].desc.value.att_exp);

printf( "\n");
for ( i=1; i<num_attr; i++)
	printf( "ATTR %2d : <%s>\t%g\n",
		i, (*Attr)[i].name, (*Attr)[i].desc.value.att_exp);
*/
	
	/* Construct attributes box object */
	Box->osnum = Env->md_id.osnum;
	Box->objid = NULL_OBJID;
        sts = om$construct ( classid = OPP_ACrg_collect_class_id,
                             osnum   = Box->osnum,
                             p_objid = &Box->objid );
	as$status ( sts    = sts,
                    msg    = "om$construct()",
                    test   = (!(sts & 0x00000001)),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Fill constructed attributes box */
	sts = om$send ( msg	 = message ACrg_collect.ACset_list_attribute
						 ( msg, num_attr, (*Attr)),
			senderid = NULL_OBJID,
			targetid = Box->objid,
			targetos = Box->osnum );
	as$status ( sts    = sts,
                    msg    = "ACrg_collect.ACset_list_attribute",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

wrapup:
	if (b)        { om$dealloc(ptr = b);        b        = NULL; }
	if (a)        { om$dealloc(ptr = a);        a        = NULL; }
	if (u)        { om$dealloc(ptr = u);        u        = NULL; }
	if (pts)      { om$dealloc(ptr = pts);      pts      = NULL; }
	if (cv)       { om$dealloc(ptr = cv);       cv       = NULL; }
	return (sts);

/* End of function */
}
/* ========================================================================== */

/* ========================================================================== */
IGRlong VLextractRgColls ( msg, comp, ncomp, attr)

/*d This function extracts attributes from a plate_jigs' manager and fills an
    ACrg_coll array with them. */

/*h 20/04/1993 : creation by Marc FOURNIER (ISDC). */

		IGRlong		*msg;		/*O Completion code       */
	struct	GRid		comp[];		/*I components array      */
		IGRint		ncomp;		/*I Number of components  */
	struct	ACrg_coll	***attr;	/*O Attributes array	  */

{
/* Beginning of function */

		IGRint		sts=OM_S_SUCCESS;
		IGRint		nattr, i;
	struct	GRid		foot;

	/* Initialize */
	*attr	= NULL;

	/* Allocate memory for feet */
	*attr = om$calloc ( num = ncomp, structure = struct ACrg_coll *);
        if (*attr == NULL) { printf( "Unable to allocate <%d> bytes\n",
				     ncomp * sizeof(struct ACrg_coll *));
			     goto wrapup; }

	for ( i=0; i<ncomp; i++) {
		/* Retrieve the foot NAM_PO_RESU of each <VLjigObj> */
		sts = vl$return_foot ( msg     = msg,
				       name    = NAM_PO_RESU,
	                               objId   = &comp[i],
	                               footId  = &foot );
		as$status ( sts    = sts,
                	    msg    = "vl$return_foot(RESU)",
                	    test   = (!(sts & 0x00000001 & (*msg))),
                	    action = GOTO_VALUE,
                	    value  = wrapup );

		/* Evaluate the size of attributes' array */
		sts = om$send ( msg      = message ACrg_collect.AClist_attribute
						( msg, 0, NULL, &nattr),
				senderid = NULL_OBJID,
				targetid = foot.objid,
				targetos = foot.osnum);
		as$status ( sts    = sts,
                	    msg    = "ACrg_collect.AClist_attribute",
                	    test   = (!(sts & 0x00000001 & (*msg))),
                	    action = GOTO_VALUE,
                	    value  = wrapup );

		/* Allocate memory for each attributes' array */
		(*attr)[i] = om$calloc ( num 	   = nattr,
					 structure = struct ACrg_coll );
        	if ((*attr)[i] == NULL) {
			printf( "Unable to allocate <%d> bytes\n",
                                 nattr * sizeof(struct ACrg_coll));
                        goto wrapup;
		}

		/* Load the attributes' array */
		sts = om$send ( msg      = message ACrg_collect.AClist_attribute
						( msg,
						  nattr,
						  (*attr)[i],
						  NULL),
				senderid = NULL_OBJID,
				targetid = foot.objid,
				targetos = foot.osnum);
		as$status ( sts    = sts,
                	    msg    = "ACrg_collect.AClist_attribute",
                	    test   = (!(sts & 0x00000001 & (*msg))),
                	    action = GOTO_VALUE,
                	    value  = wrapup );
	}
	
wrapup:
	return (sts);

/* End of function */
}
/* ========================================================================== */

/* ========================================================================== */
IGRlong dblrnd (dbl)

/*d This function approximate a double to the closest integer */

/*h 22/04/1993 : creation by Marc FOURNIER (ISDC). */

	IGRdouble	dbl;	/*I double value	*/

{
/* Beginning of function */

	IGRlong		rnd;

	rnd = (IGRlong)dbl;
	dbl = dbl - (IGRdouble)rnd;
	if (dbl > 0.5)	rnd++;

	return (rnd);

/* End of function */
}
/* ========================================================================== */

/* ========================================================================== */
IGRlong VLbuildJigRow ( msg, num, attr, row,
			   r_max, l_max, w_max, c_max, len, txt)

/*d This function creates the rows of the jig table. row = -1 creates the title
    and row = 0,1,2, ... creates the current line. */

/*h 22/04/1993 : creation by Marc FOURNIER (ISDC). */

		IGRlong		*msg;		/*O Completion code           */
		IGRint		num;		/*I Number of current lines   */
	struct	ACrg_coll	*attr[];	/*I Attributes array	      */
		IGRint		row;		/*I Order of current line     */
		IGRint		r_max;		/*I Maximum of right data     */
		IGRint		l_max;		/*I Maximum of left data      */
		IGRint		w_max;		/*I Maximum of weld data      */
		IGRint		c_max;		/*I Maximum of charac data    */
		IGRint		len;		/*I Maximum length for text   */
		IGRchar		txt[];		/*O Resulting text	      */

{
/* Beginning of function */

		IGRint		sts=OM_S_SUCCESS, idx=0, i;
		IGRint		val, r_cur, l_cur, w_cur, c_cur;
		IGRchar		text[20];

	/* Initialize */
	txt[0] = text[0] = '\0';
	r_cur = l_cur = w_cur = c_cur = 0;

	/* Verify */
	if (row >= num) {
		printf( "Cannot build %dth line, only %d components ...\n",
			row, num );
		*msg = MSFAIL;
		goto wrapup;
	}

	if (row == -1) {
		/* First line of table (title) */
		strcpy ( text, "|");
		VLfillText ( msg, txt, len, &idx, 6, text);
		for ( i=0; i<2; i++) {
			sprintf ( text, "  L%d", i+1);
			VLfillText ( msg, txt, len, &idx, 6, text); }

		for ( i=0; i<2; i++) {
			sprintf ( text, "  X%d", i+1);
			VLfillText ( msg, txt, len, &idx, 6, text); }

		for ( i=0; i<r_max-1; i++) {
			if (i < 26) 
				sprintf ( text, " %c", 'A'+i);
			else if (i < 52)
				sprintf ( text, " %c%c", 'A'+i-26, 'A'+i-26);
			else	text[0] = '\0';
			VLfillText ( msg, txt, len, &idx, 4, text); }

		if ((r_max-1) < 26) 
			sprintf ( text, " %c*", 'A'+r_max-1);
		else if ((r_max-1) < 52)
			sprintf ( text, " %c%c*",
				  'A'+r_max-1-26, 'A'+r_max-1-26);
		else	text[0] = '\0';
		VLfillText ( msg, txt, len, &idx, 4, text);

		for ( i=r_max; i<r_max+l_max; i++) {
			if (i < 26) 
				sprintf ( text, " %c", 'A'+i);
			else if (i < 52)
				sprintf ( text, " %c%c", 'A'+i-26, 'A'+i-26);
			else	text[0] = '\0';
			VLfillText ( msg, txt, len, &idx, 4, text); }

		for ( i=0; i<w_max+c_max; i++) {
			sprintf ( text, " Z%d", i+1);
			VLfillText ( msg, txt, len, &idx, 4, text); }
	}
	else {
		/* Build current row */
		if (strlen(attr[row][IDX_RG_P_INDEX].desc.value.att_txt) < 5)
			sprintf ( text, "| %s",
			  	  attr[row][IDX_RG_P_INDEX].desc.value.att_txt);
		else 	sprintf ( text, "|%s",
			  	  attr[row][IDX_RG_P_INDEX].desc.value.att_txt);

		VLfillText ( msg, txt, len, &idx, 6, text);

		val = IDX_RG_P_VALUE;
		for ( i=0; i<2; i++) {
			sprintf ( text, "%6d",
dblrnd (fabs (attr[row][val+i].desc.value.att_exp) ) );
			VLfillText ( msg, txt, len, &idx, 6, text);
		}

		val += 2;
		for ( i=0; i<2; i++) {
			sprintf ( text, "%6d",
dblrnd (fabs (attr[row][val+i].desc.value.att_exp) ) );
			VLfillText ( msg, txt, len, &idx, 6, text);
		}

		/* Retrieve sizes for current row */
		r_cur = (IGRint)attr[row][IDX_RG_P_R_NUM].desc.value.att_exp;
		l_cur = (IGRint)attr[row][IDX_RG_P_L_NUM].desc.value.att_exp;
		w_cur = (IGRint)attr[row][IDX_RG_P_W_NUM].desc.value.att_exp;
		c_cur = (IGRint)attr[row][IDX_RG_P_C_NUM].desc.value.att_exp;

		val += 2;
		for ( i=r_max-1; i>=r_cur; i--)
			VLfillText ( msg, txt, len, &idx, 4, " -- ");
		for ( i=r_cur-1; i>=0; i--) {
			sprintf ( text, "%4d",
dblrnd (fabs (attr[row][val+i].desc.value.att_exp) ) );
			VLfillText ( msg, txt, len, &idx, 4, text);
		}

		val += 2*r_cur;
		for ( i=0; i<l_cur; i++) {
			sprintf ( text, "%4d",
dblrnd (fabs (attr[row][val+i].desc.value.att_exp) ) );
			VLfillText ( msg, txt, len, &idx, 4, text);
		}
		for ( i=l_cur; i<l_max; i++)
			VLfillText ( msg, txt, len, &idx, 4, " -- ");

		val += 2*l_cur + c_cur;
		for ( i=0; i<c_cur; i++) {
			sprintf ( text, "%4d",
dblrnd (fabs (attr[row][val+i].desc.value.att_exp) ) );
			VLfillText ( msg, txt, len, &idx, 4, text);
		}
		for ( i=c_cur; i<c_max; i++)
			VLfillText ( msg, txt, len, &idx, 4, " -- ");

		val += 2*c_max - c_cur + w_cur;
		for ( i=0; i<w_cur; i++) {
			sprintf ( text, "%4d",
dblrnd (fabs (attr[row][val+i].desc.value.att_exp) ) );
			VLfillText ( msg, txt, len, &idx, 4, text);
		}
		for ( i=w_cur; i<w_max; i++)
			VLfillText ( msg, txt, len, &idx, 4, " -- ");
	}

	/* Suppress last | character */
	txt[strlen(txt)-1] = '\0';

wrapup:
	return (sts);

/* End of function */
}
/* ========================================================================== */

/* ========================================================================== */
IGRlong VLbuildJigTable ( msg, num, attr, Env, loc_mat,
			  r_max, l_max, w_max, c_max, text_id)

/*d This function creates the jig table from a ACrg_coll array. */

/*h 20/04/1993 : creation by Marc FOURNIER (ISDC). */

		IGRlong		*msg;		/*O Completion code        */
		IGRint		num;		/*I Number of components   */
	struct	ACrg_coll	*attr[];	/*I Attributes array	   */
	struct	GRmd_env	*Env;		/*I Target module info	   */
		IGRdouble	loc_mat[];	/*I Coordinate system mat  */
		IGRint		*r_max;		/*O Right side max number  */
		IGRint		*l_max;		/*O Left side max number   */
		IGRint		*w_max;		/*O Weld points max number */
		IGRint		*c_max;		/*O char lines max number  */
	struct	GRid		*text_id;	/*O Graphic group object   */

{
/* Beginning of function */

		IGRint		sts=OM_S_SUCCESS;
		IGRint		i, len, idx=0;
		IGRchar		*table;
		IGRchar		text[20], *row;
		IGRshort	ft_pos;
		IGRint		size;
		IGRlong		nret;
	struct	GRdpb_text_symb	txt_symb;
		IGRpoint	cnt;

	/* Initialize */
	text_id->objid = NULL_OBJID;
	text_id->osnum = Env->md_id.osnum;
	table = NULL;
	row   = NULL;
	text[0] = '\0';

	/* Retrieve max values */
	for ( i=0; i<num; i++) {
		if ((IGRint)attr[i][IDX_RG_P_R_NUM].desc.value.att_exp > *r_max)
		*r_max = (IGRint)attr[i][IDX_RG_P_R_NUM].desc.value.att_exp;
		if ((IGRint)attr[i][IDX_RG_P_L_NUM].desc.value.att_exp > *l_max)
		*l_max = (IGRint)attr[i][IDX_RG_P_L_NUM].desc.value.att_exp;
		if ((IGRint)attr[i][IDX_RG_P_W_NUM].desc.value.att_exp > *w_max)
		*w_max = (IGRint)attr[i][IDX_RG_P_W_NUM].desc.value.att_exp;
		if ((IGRint)attr[i][IDX_RG_P_C_NUM].desc.value.att_exp > *c_max)
		*c_max = (IGRint)attr[i][IDX_RG_P_C_NUM].desc.value.att_exp;
	}

	/* Allocate memory for the table */

/* 	len = 10 + ((4 + *r_max + *l_max + *w_max + *c_max) * 5); */

	len = 10 + ((6 + *r_max + *l_max + *w_max + *c_max) * 6);
	row = om$calloc ( num = len, structure = IGRchar);
        if (row == NULL)	{ printf( "Unable to allocate <%d> bytes\n",
                                  len * sizeof(IGRchar));
                              	  goto wrapup; } 	row[0] = '\0';

	table = om$calloc ( num = len*(1+num), structure = IGRchar);
        if (table == NULL)	{ printf( "Unable to allocate <%d> bytes\n",
                                  len*(1+num) * sizeof(IGRchar));
                              	  goto wrapup; } 	table[0] = '\0';

	/* Build the title and lines of the table */
	for ( i=-1; i<num; i++) {
		sts = VLbuildJigRow ( msg, num, attr, i,
					 *r_max, *l_max, *w_max, *c_max,
				         len, row);
		as$status ( sts    = sts,
                	    msg    = "VLbuildJigRow()",
                	    test   = (!(sts & 0x00000001 & (*msg))),
                	    action = GOTO_VALUE,
                	    value  = wrapup );
/*
printf("ROW %2d : <%s>\n", i, row);
*/

		VLfillText ( msg, table, len*(1+num), &idx, strlen(row), row);
		sprintf ( table, "%s%c%c", table, ESC, LINEFEED);
		idx += 2;
        }

	/* Get font 101 */
	font$retrieve ( msg		= msg,
			font		= "101",
			local_font_name = "101",
			font_position	= &ft_pos );
	if( (*msg != GR_E_FtLdd) && (*msg != MSSUCC) ) {
		printf( "Font 101 cant be loaded ...\n");
		goto wrapup;
	}

	/* Get active text symbology */
	size = sizeof (struct GRdpb_text_symb);
	gr$get_text_symb ( msg	  = msg,
			   sizbuf = &size,
			   buffer = &txt_symb,
			   nret	  = &nret );
	txt_symb.Active_font	 = ft_pos;
	txt_symb.Active_linespac = 1.5275;
	txt_symb.Active_just	 = LEFT_BOTTOM;

	/* Place table text */
	len = strlen (table);
	table[len-2] = '\0';
	len = strlen (table);
	cnt[0] = loc_mat[3];
	cnt[1] = loc_mat[7];
	cnt[2] = loc_mat[11];
	sts = co$place_text ( msg		= msg,
			      text_string	= table,
			      text_length	= &len,
			      lbs_matrix	= loc_mat,
			      origin		= cnt,
			      TextSymb		= &txt_symb,
			      mode		= GRbe,
			      flags		= 1,
			      buffer		= text_id );
	as$status ( sts    = sts,
                    msg    = "co$place_text()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	
wrapup:
	if (table)	{ om$dealloc (ptr = table);	table = NULL;	}
	return (sts);

/* End of function */
}
/* ========================================================================== */

/* ========================================================================== */
IGRlong VLprocessCheckList ( CheckList, RngPlane, NumPlane, MaxPlane, Name)

/*d This function process the check list */

/*h 06/05/1993 : creation by Marc FOURNIER (ISDC). */

		IGRint		CheckList[];
		IGRint		RngPlane;
		IGRint		*NumPlane;
		IGRint		*MaxPlane;
		IGRchar		Name[];
{
/* Beginning of function */

		IGRint		sts=OM_S_SUCCESS;
		IGRint		i, sidx=-1, eidx=-1;
		IGRchar		work[20];

	/* Initialize */
	(*NumPlane) = (*MaxPlane) = (IGRint) 0;

	/* Evaluate NumPlane & MaxPlane */
	for ( i=0; i<RngPlane; i++) {
		(*NumPlane) += CheckList[i];
		if ( (CheckList[i] == 1) && (sidx == -1) )	sidx = i;
		if (CheckList[i] == 1)				eidx = i;
	}
	(*MaxPlane) = eidx - sidx + 1;
	if ( (sidx == -1) || (eidx == -1) )	sts = MSFAIL;

	for ( i=0; i<30; i++) {
		work[0] = '\0';
		if (CheckList[i] == 1) sprintf( work, "%d/%d", i+1, *NumPlane);
		strcpy( &Name[10*i], work);
	}

	return (sts);

/* End of function */
}
/* ========================================================================== */

/* ========================================================================== */
IGRlong VLextractCharpoints ( msg, Topcont, Env, ncln, Cln, ncpt, Cpt)

/*d This function intersects characteristic lines with the top part of the
    plate_jig contour. */

/*h 12/05/1993 : creation by Marc FOURNIER (ISDC). */

		IGRlong		*msg;		/*O Completion code           */
	struct	GRid		*Topcont;	/*I Top part of the contour   */
	struct	GRmd_env	*Env;		/*I Current module info	      */
		IGRint		ncln;		/*I Number of char lines      */
	struct	GRid		Cln[];	/*I Characteristic lines      */
		IGRint		*ncpt;		/*O Number of char points     */
		IGRdouble	Cpt[];	/*O Characteristic points     */

{
/* Beginning of function */

		IGRint		sts=OM_S_SUCCESS;
		IGRint		i;
	struct	GRid		Line, Point;
		IGRshort	typ;
		IGRmatrix	mat;
	struct	GRmd_env	env;
	struct	ret_struct	str;

	/* Initialize */
	*ncpt = 0;

	for ( i=0; i<ncln; i++) {

		/* Get graphic object */
		Line.objid = Point.objid = NULL_OBJID;
		Line.osnum = Point.osnum = Env->md_id.osnum;
		sts = om$send ( msg      = message NDnode.ASreturn_go
						( &Line, &typ, mat),
				senderid = NULL_OBJID,
				targetid = Cln[i].objid,
				targetos = Cln[i].osnum );
		as$status ( sts    = sts,
                	    msg    = "NDnode.ASreturn_go",
                	    test   = (!(sts & 0x00000001)),
                	    action = GOTO_VALUE,
                	    value  = wrapup );

		/* Intersect graphic object with top contour */
		env        	       = *Env;
		env.md_id.osnum        = Line.osnum;
		env.md_env.matrix_type = typ;
		dblcpy ( env.md_env.matrix, mat, 16);
		sts = VLcreatePtInter( msg, Topcont, Env, &Line, &env,
					  &Point, Env);
		if ( ((*msg)&1&sts) && (Point.objid != NULL_OBJID) ) {

			/* Find coordinate of the intersection point */
			as$make_source ( go_grid = Point,
					 mod_env = Env,
					 as_grid = &Point );
			sts = om$send (
				msg	= message NDnode.NDgive_structure
						( msg, &str, Env),
				senderid = NULL_OBJID,
				targetid = Point.objid,
				targetos = Point.osnum );
			if (!((*msg)&1&sts)) {
				gr$delete_object ( msg       = msg,
						   md_env    = Env,
						   object_id = &Point );
			}
			else {  dblcpy( &Cpt[*ncpt*3], str.var.point_st.pt, 3);
				(*ncpt)++; }
			as$status ( sts    = sts,
                    		    msg    = "NDnode.NDgive_structure",
                    		    test   = (!(sts & 0x00000001 & (*msg))),
                    		    action = GOTO_VALUE,
                    		    value  = wrapup );
		}
		gr$delete_object ( msg = msg, md_env = Env, object_id = &Point);
	}

wrapup:
	return (sts);

/* End of function */
}
/* ========================================================================== */

/* ========================================================================== */
IGRlong VLtagTemplateJig ( msg, tj_id, tj_env, r_max, l_max, attr, feet)

/*d This function tags a representative template_jig with annotations */

/*h 04/06/1993 : creation by Marc FOURNIER (ISDC). */

		IGRlong		*msg;	 /*O Completion code                  */
	struct	GRid		*tj_id;	 /*I Representative template_jig ID   */
	struct	GRmd_env	*tj_env; /*I Representative template_jig ENV  */
		IGRint		r_max;	 /*I Maximum number (right side)      */
		IGRint		l_max;	 /*I Maximum number (left side)       */
	struct  ACrg_coll       attr[];	 /*I Representative rigid collection  */
	struct	GRid		feet[];	 /*O Resulting tag text array	      */

{
/* Beginning of function */

		IGRint		sts=OM_S_SUCCESS, i, j, k, idx, len, count, num;
	struct	GRobj_env	lk_line, contour;
		IGRpoint	spt, ept, cnt, Spt, Ept;
		IGRvector	Xvec, Yvec, Zvec, Xref, Yref, Zref;
		IGRmatrix	txt_mat;
		BSrc		rc;
	struct  GRdpb_text_symb txt_symb;
                IGRint          siz;
                IGRlong         ret;
		IGRdouble	Yval;
		IGRchar		txt[DI_PATH_MAX];
	struct	GRid		*comp, at_id;
		IGRint		r_cur, l_cur;
	struct	ACrg_coll	tmp;
		IGRdouble	delta;

	/* Initialize */
	comp = NULL;
	Xref[1] = Xref[2] = Yref[0] = Yref[2] = Zref[0] = Zref[1] = 0.0;
	Xref[0] = Yref[1] = Zref[2] = 1.0;

	/* Retrieve contour & transformation matrix */
	sts = vl$return_foot ( msg     = msg,
			       name    = NAM_PO_CONT,
                               objId   = tj_id,
			       objEnv  = tj_env,
                               footId  = &contour.obj_id,
			       footEnv = &contour.mod_env );
	as$status ( sts    = sts,
                    msg    = "vl$return_foot(CONT)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
#ifdef TRACE
printf( "Template (%d|%d) : <%s> is (%d|%d)\n", tj_id->osnum, tj_id->objid,
	NAM_PO_CONT, contour.obj_id.osnum, contour.obj_id.objid);
#endif

	/* Extract contour components number */
	sts = om$send ( msg      = message GRowner.GRget_number_components 
						( msg, &count),
			senderid = NULL_OBJID,
			targetid = contour.obj_id.objid,
			targetos = contour.obj_id.osnum );
	as$status ( sts    = sts,
                    msg    = "GRowner.GRget_number_components",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
#ifdef TRACE
printf( "Contour (%d|%d) have %d components\n", 
	contour.obj_id.osnum, contour.obj_id.objid, count);
#endif

	/* Allocate memory for components */
	comp = om$calloc ( num = count, structure = struct GRid);
	if (comp == NULL) { 	printf( "Unable to allocate <%d> bytes\n",
					count * sizeof(struct GRid) );
				goto wrapup; }

	/* Extract contour components */
        sts = om$send ( msg      = message GRowner.GRget_components (
                                                msg,
                                                &contour.mod_env,
                                                comp,
                                                count,
                                                &num,
                                                0,
                                                OM_K_MAXINT ),
                        senderid = NULL_OBJID,
			targetid = contour.obj_id.objid,
			targetos = contour.obj_id.osnum );
	as$status ( sts    = sts,
                    msg    = "GRowner.GRget_components",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	if (num != count) {
                printf( "Expect %d components, %d are returned\n", count, num);
                *msg = MSFAIL;
                goto wrapup;
        }
#ifdef TRACE
for ( i=0; i<count; i++)
	printf( "Component %d : (%d|%d)\n", i,  comp[i].osnum, comp[i].objid);
#endif

	/* Extract endpoints of the penultimate component */
	sts = VLendpts ( msg, &comp[count-2], &contour.mod_env, Spt, Ept);
	as$status ( sts    = sts,
                    msg    = "VLendpts()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
#ifdef TRACE
printf( "penultimate component : (%g,%g,%g)\t--> (%g,%g,%g)\n",
	Spt[0], Spt[1], Spt[2], Ept[0], Ept[1], Ept[2] );
#endif

	/* Retrieve LK line & transformation matrix */
	sts = vl$return_foot ( msg     = msg,
			       name    = NAM_PO_KLIN,
                               objId   = tj_id,
			       objEnv  = tj_env,
                               footId  = &lk_line.obj_id,
			       footEnv = &lk_line.mod_env );
	as$status ( sts    = sts,
                    msg    = "vl$return_foot(KLIN)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Extract endpoints of the LK line */
	sts = VLendpts ( msg, &lk_line.obj_id, &lk_line.mod_env, spt, ept);
	as$status ( sts    = sts,
                    msg    = "VLendpts()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
#ifdef TRACE
printf( "LK line : (%g,%g,%g)\t--> (%g,%g,%g)\n",
	spt[0], spt[1], spt[2], ept[0], ept[1], ept[2] );
#endif

	/* Construct text matrix & LK coordinate system */
       	for ( i=0; i<3; i++) {	Yvec[i] = Spt[i] - Ept[i];
				Zvec[i] = spt[i] - ept[i]; }

        BSnorvec ( &rc, Yvec);
        if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
	if (BSdotp ( &rc, Yref, Yvec) < 0.0)
		for ( i=0; i<3; i++)	Yvec[i] *= -1.0;
        if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }

        BSnorvec ( &rc, Zvec);
        if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
	if (BSdotp ( &rc, Zref, Zvec) < 0.0)
		for ( i=0; i<3; i++)	Zvec[i] *= -1.0;
        if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }

        BScrossp ( &rc, Yvec, Zvec, Xvec);
        if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
        BSnorvec ( &rc, Xvec);
        if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
	if (Xvec[0] == 0)	dblcpy ( Xvec, Xref, 3);

        BScrossp ( &rc, Xvec, Yvec, Zvec);
        if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }

#ifdef TRACE
printf( "Xvec : [%g,%g,%g]\n", Xvec[0], Xvec[1], Xvec[2]);
printf( "Yvec : [%g,%g,%g]\n", Yvec[0], Yvec[1], Yvec[2]);
printf( "Zvec : [%g,%g,%g]\n", Zvec[0], Zvec[1], Zvec[2]);
#endif

        for ( i=0; i<3; i++) {
                txt_mat[4*i+0] = Yvec[i];
                txt_mat[4*i+1] = Zvec[i];
                txt_mat[4*i+2] = Xvec[i];
                txt_mat[4*i+3] = 0.0;
                txt_mat[12+i]  = 0.0;
	}
        txt_mat[15] = 1.0;

	/* Retrieve active symbology */
	siz = sizeof (struct GRdpb_text_symb);
        gr$get_text_symb ( msg    = msg,
                           sizbuf = &siz,
                           buffer = &txt_symb,
                           nret   = &ret );
	txt_symb.Active_just = CENTER_CAP;

	/* Retrieve attributes */
	r_cur = (IGRint)attr[IDX_RG_P_R_NUM].desc.value.att_exp;
	l_cur = (IGRint)attr[IDX_RG_P_L_NUM].desc.value.att_exp;
	idx   = IDX_RG_P_VALUE
              + 2 * (IGRint)attr[IDX_RG_P_E_NUM].desc.value.att_exp;

	sts = vl$return_foot ( msg     = msg,
			       name    = NAM_PO_RESU,
                               objId   = tj_id,
                               footId  = &at_id );
	as$status ( sts    = sts,
                    msg    = "vl$return_foot(RESU)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	sprintf ( tmp.name, "%s0", NAM_RG_P_L_ZPT);
        sts = om$send ( msg = message ACrg_collect.ACget_named_attribute
						( msg, &tmp),
			senderid = NULL_OBJID,
                        targetid = at_id.objid,
                        targetos = at_id.osnum );
	as$status ( sts    = sts,
                    msg    = "ACrg_collect.ACget_named_attribute",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	delta = tmp.desc.value.att_exp;

	/* Place text on right side */
	for ( i=0; i<r_max; i++) {
		if (i >= r_cur) {
			Yval = attr[idx+r_cur+r_cur-1].desc.value.att_exp;
			Yval -= (i - r_cur + 1) * delta;
		}
		else	Yval = attr[idx+r_cur+i].desc.value.att_exp;

		for ( j=0; j<3; j++) cnt[j] = ept[j] + Yval * Yvec[j];
		k = r_max-i-1;
		txt[0] = '\0';
		if (k<26)       sprintf ( txt, "|%c%c%c",
                                          ESC, LINEFEED, 'A'+k);
                else if (k<52)  sprintf ( txt, "|%c%c%c%c",
                                          ESC, LINEFEED, 'A'+k-26, 'A'+k-26);
                else            strcpy  ( txt, "|");

		len = strlen (txt);
                sts = co$place_text ( msg         = msg,
                                      text_string = txt,
                                      text_length = &len,
                                      lbs_matrix  = txt_mat,
                                      origin      = cnt,
                                      TextSymb    = &txt_symb,
                                      mode        = GRbe,
                                      buffer      = &feet[k] );
		as$status ( sts    = sts,
                	    msg    = "co$place_text()",
                	    test   = (!(sts & 0x00000001 & (*msg))),
                	    action = GOTO_VALUE,
                	    value  = wrapup );
	}

	/* Place text on left side */
	idx += 2 * r_cur;
	for ( i=0; i<l_max; i++) {
		if (i >= l_cur) {
			Yval = attr[idx+l_cur+l_cur-1].desc.value.att_exp;
			Yval += (i - l_cur + 1) * delta;
		}
		else	Yval = attr[idx+l_cur+i].desc.value.att_exp;

		for ( j=0; j<3; j++) cnt[j] = ept[j] + Yval * Yvec[j];
		k = r_max+i;
		txt[0] = '\0';
		if (k<26)       sprintf ( txt, "|%c%c%c",
                                          ESC, LINEFEED, 'A'+k);
                else if (k<52)  sprintf ( txt, "|%c%c%c%c",
                                          ESC, LINEFEED, 'A'+k-26, 'A'+k-26);
                else            strcpy  ( txt, "|");

		len = strlen (txt);
                sts = co$place_text ( msg         = msg,
                                      text_string = txt,
                                      text_length = &len,
                                      lbs_matrix  = txt_mat,
                                      origin      = cnt,
                                      TextSymb    = &txt_symb,
                                      mode        = GRbe,
                                      buffer      = &feet[k] );
		as$status ( sts    = sts,
                	    msg    = "co$place_text()",
                	    test   = (!(sts & 0x00000001 & (*msg))),
                	    action = GOTO_VALUE,
                	    value  = wrapup );
	}

wrapup:
	if (comp)	{ om$dealloc (ptr = comp);	comp = NULL; }
	return (sts);

/* End of function */
}
/* ========================================================================== */

end implementation VLabstract;
