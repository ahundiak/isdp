/* $Id: vlPplatejig.h,v 1.1.1.1 2001/01/04 21:11:13 cvs Exp $  */

/*************************************************************************
 * I/LOFT
 *
 * File:	include/prototypes / vlPplatejig.h
 *
 * Description:	prototypes of src/platejig functions.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vlPplatejig.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:11:13  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:32:50  pinnacle
 * LOFT 2.5.1
 *
 * Revision 1.1  1997/05/08  14:05:56  pinnacle
 * Loft 250
 *
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *      04/11/97   mf           header creation.
 *************************************************************************/
#if defined(__STDC__) || defined(__cplusplus)
#ifndef __
#define __(args) args
#endif
#else
#ifndef __
#define __(args) ()
#endif
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* VLjigFunk1.I */
IGRlong VLplateContours __((IGRlong *msg, IGRint nplt, struct GRobj_env Plate[], struct GRmd_env *Env, struct GRid Contour[]));
IGRlong VLplaneIndex __((IGRlong *msg, IGRint num, struct GRobj_env plane[], IGRchar ***index));
IGRlong VLcreateJigText __((IGRchar title[], IGRdouble Rpt1[], IGRdouble Rpt2[], IGRint nvtx, IGRdouble Vertex[], struct GRmd_env *Env, struct GRid *Sline, IGRdouble radius, struct ACrg_coll Attr[], IGRint *text_num, struct GRid **text_id, IGRdouble loc_mat[], IGRlong *msg));
IGRlong VLextractVertices __((IGRlong *msg, IGRint ncrv, struct GRobj_env Curve[], IGRshort Inv[], IGRint *nvtx, IGRdouble **Vertex));
IGRlong VLcreateScallops __((IGRlong *msg, IGRint nvtx, IGRdouble Vertex[], struct GRmd_env *Env, IGRdouble r, struct GRvg_construct *cst, IGRpoint c, IGRdouble d, IGRdouble b, struct GRid *Scalloped, struct GRid *Unscallop));
IGRlong VLcreateJigBox __((IGRlong *msg, struct GRid *LK, struct GRid *TP, struct GRmd_env *Env, IGRint nvtx, IGRdouble Vertex[], IGRint ncln, IGRdouble Clines[], IGRdouble offset, IGRchar index[], IGRdouble Xpln[], struct GRid *Box, struct ACrg_coll **Attr));
IGRlong VLextractRgColls __((IGRlong *msg, struct GRid comp[], IGRint ncomp, struct ACrg_coll ***attr));
IGRlong dblrnd __((IGRdouble dbl));
IGRlong VLbuildJigRow __((IGRlong *msg, IGRint num, struct ACrg_coll *attr[], IGRint row, IGRint r_max, IGRint l_max, IGRint w_max, IGRint c_max, IGRint len, IGRchar txt[]));
IGRlong VLbuildJigTable __((IGRlong *msg, IGRint num, struct ACrg_coll *attr[], struct GRmd_env *Env, IGRdouble loc_mat[], IGRint *r_max, IGRint *l_max, IGRint *w_max, IGRint *c_max, struct GRid *text_id));
IGRlong VLprocessCheckList __((IGRint CheckList[], IGRint RngPlane, IGRint *NumPlane, IGRint *MaxPlane, IGRchar Name[]));
IGRlong VLextractCharpoints __((IGRlong *msg, struct GRid *Topcont, struct GRmd_env *Env, IGRint ncln, struct GRid Cln[], IGRint *ncpt, IGRdouble Cpt[]));
IGRlong VLtagTemplateJig __((IGRlong *msg, struct GRid *tj_id, struct GRmd_env *tj_env, IGRint r_max, IGRint l_max, struct ACrg_coll attr[], struct GRid feet[]));

/* VLjigFunk2.I */
IGRlong VLupdateId __((IGRlong *msg, struct GRid *NewId, struct GRmd_env *NewEnv, IGRint idx, struct GRmd_env *Env, struct GRid *Obj));
IGRlong VLtwoEdgesInDirection __((IGRlong *msg, struct GRmd_env *Env, IGRint nplt, struct GRobj_env Plate[], IGRdouble Axis[], struct GRobj_env *Nedge, struct GRobj_env *Fedge));
IGRlong VLorderEndpointInDirection __((IGRlong *msg, struct GRobj_env *Edg, IGRdouble Axis[], IGRpoint *Pnt, IGRdouble *Dst));
IGRlong VLfindPpPoint __((IGRlong *msg, struct GRobj_env *Fplane, struct GRmd_env *Env, IGRint nplt, struct GRobj_env Plate[], IGRdouble Axis[], IGRdouble Middle, IGRdouble Space, struct GRid *PP_id, IGRdouble Ppnt[], IGRint *Pnum));
IGRlong VLsetPlateJigMgrAttr __((IGRlong *msg, IGRdouble value[], struct GRid *Attr));
IGRlong VLgetPlateJigMgrAttr __((IGRlong *msg, IGRdouble value[], struct GRid *Attr));
IGRlong VLsetPlateJigObjAttr __((IGRlong *msg, IGRdouble value[], struct GRid *Attr));
IGRlong VLgetPlateJigObjAttr __((IGRlong *msg, IGRdouble value[], struct GRid *Attr));
IGRlong VLbuildJigFixPlane __((IGRlong *msg, struct GRid *Klin, IGRdouble Ppnt[], IGRdouble Bpln[], IGRint typ, IGRdouble mid, IGRint ord, IGRdouble spa, struct GRmd_env *Env, struct GRid *Plan));

/* VLjigTblCmdi.I */

/* VLpltJigCmdi.I */

#if defined(__cplusplus)
}
#endif

