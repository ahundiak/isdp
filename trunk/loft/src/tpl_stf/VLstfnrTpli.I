class implementation VLstfnrTpl;

#include	<string.h>
#include	"vlprototype.h"
#include	"AS_status.h"
#include	"nddef.h"
#include	"bserr.h"
#include	"bsparameters.h"
#include	"expression.h"
#include	"expmacros.h"
#include	"asmacros.h"
#include	"grmacros.h"
#include	"exmacros.h"
#include	"msmacros.h"
#include	"OMprimitives.h"
#include	"ACrg_collect.h"

#include	"bsxtractpar.h"

#include	"vssectiondef.h"
#include	"vsmiscmacros.h"
#include	"vsbeamdef.h"
#include	"parametric.h"

#include	"vlmsg.h"
#include	"vlglobals.h"
#include	"vlstifftpl.h"
#include	"vlmiscmacros.h"

from	ACdyn_col	import	ACset_list_attribute;
from	VSstfBeam	import	VSgetPlateSide;

extern	IGRdouble	pow();

extern	GRclassid	OPP_ACdyn_col_class_id;
extern	GRclassid	OPP_VSimgFeature_class_id;

/*	#define	TRACE	*/

/* ========================================================================== */
method ACconstruct_feet ( 		IGRlong		*msg;
			 		IGRint		cn_type;
			 		IGRint		count;
			 struct		GRid		list[];
			 struct		GRmd_env	*md_env;
					IGRint		*fcount;
			 struct		GRid		*feet_list )
{

		IGRint		i, nlin=0, nmac=0, nvtx=0;
		IGRint		flag[IDX_SC_SIZE];
		IGRlong		loc_msg , sts;

		IGRdouble	web_left;
		IGRdouble	tpl_height;
		IGRdouble	tpl_thickness;
		IGRdouble	ext1;
		IGRdouble	ext2;
		IGRint		tpl_code, linear=0;
		IGRchar		name[DI_PATH_MAX], *tagnam;
		IGRdouble	DistTol, ChtTol, BaseTol, RangTol;
	struct	GRobj_env	Stiff, WebFace, Bottom, *Qline, *Qmacr;
	struct	GRid		Bedge, Tedge, *text_id, *line_id, Oedge;
		IGRpoint	Xpt[4], *vertex, Ospt, Oept, pnt;
	struct	GRparms		parm;
		VLquLine	Query[IDX_SC_SIZE];
	struct	ACrg_coll	*attr;
		IGRdouble	max=pow(2.0,(IGRdouble)IDX_SC_SIZE), Xinv=1.0;
	struct	ret_struct	str;

#ifdef TRACE
printf("\t>>> Enter in VLstfnrTpli.ACconstruct_feet\n");
#endif

	/* Initialize */
	*fcount = MACRO_S_FFEET;
	for ( i=0; i<*fcount; i++) {
		feet_list[i].objid = NULL_OBJID;
		feet_list[i].osnum = md_env->md_id.osnum;
	}
	BSxtractpar ( msg, BSTOLBASIS, &BaseTol);
	BSxtractpar ( msg, BSTOLCHRDHT, &ChtTol);
	DistTol = 5 * ChtTol;
	RangTol = 5 * ChtTol;
	Qline   = NULL;
	Qmacr   = NULL;
	vertex  = NULL;
	tagnam  = NULL;
	line_id = NULL;
	text_id = NULL;
	VLqLineStfTpl (Query);
	Bedge.objid = Tedge.objid = NULL_OBJID;
	Bedge.osnum = Tedge.osnum = md_env->md_id.osnum;

	/* Get <web_left> values */
	sts = om$send ( msg      = message NDnode.NDgive_structure
                                        ( msg, &str, md_env),
                        targetid = list[IDX_ST_WLEF].objid,
                        targetos = list[IDX_ST_WLEF].osnum );
        as$status ( sts    = sts,
                    msg    = "NDnode.NDgive_structure(WLEF)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
        web_left = str.var.root_pm_st.value;
	if (web_left != VAL_TO_WEBR)	web_left = VAL_TO_WEBL;
	if (web_left == VAL_TO_WEBL) 	strcpy ( name, VS_K_nmWebL);
	else 				strcpy ( name, VS_K_nmWebR);

	/* Get <tpl_height> values */
	sts = om$send ( msg      = message NDnode.NDgive_structure
                                        ( msg, &str, md_env),
                        targetid = list[IDX_ST_THEI].objid,
                        targetos = list[IDX_ST_THEI].osnum );
        as$status ( sts    = sts,
                    msg    = "NDnode.NDgive_structure(THEI)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
        tpl_height = str.var.root_pm_st.value;

	/* Get <tpl_thickness> values */
	sts = om$send ( msg      = message NDnode.NDgive_structure
                                        ( msg, &str, md_env),
                        targetid = list[IDX_ST_TTHI].objid,
                        targetos = list[IDX_ST_TTHI].osnum );
        as$status ( sts    = sts,
                    msg    = "NDnode.NDgive_structure(TTHI)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
        tpl_thickness = str.var.root_pm_st.value;

	/* Get <extension1> values */
	sts = om$send ( msg      = message NDnode.NDgive_structure
                                        ( msg, &str, md_env),
                        targetid = list[IDX_ST_EXT1].objid,
                        targetos = list[IDX_ST_EXT1].osnum );
        as$status ( sts    = sts,
                    msg    = "NDnode.NDgive_structure(EXT1)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
        ext1 = str.var.root_pm_st.value;

	/* Get <extension2> values */
	sts = om$send ( msg      = message NDnode.NDgive_structure
                                        ( msg, &str, md_env),
                        targetid = list[IDX_ST_EXT2].objid,
                        targetos = list[IDX_ST_EXT2].osnum );
        as$status ( sts    = sts,
                    msg    = "NDnode.NDgive_structure(EXT2)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
        ext2 = str.var.root_pm_st.value;

	/* Get <tpl_code> values */
	sts = om$send ( msg      = message NDnode.NDgive_structure
                                        ( msg, &str, md_env),
                        targetid = list[IDX_ST_CODE].objid,
                        targetos = list[IDX_ST_CODE].osnum );
        as$status ( sts    = sts,
                    msg    = "NDnode.NDgive_structure(CODE)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	if 	(str.var.root_pm_st.value < 0)		tpl_code = 0;
	else if (str.var.root_pm_st.value >= max)	tpl_code = max - 1;
        else	tpl_code = (IGRint) str.var.root_pm_st.value;
	VLdecode ( tpl_code, IDX_SC_SIZE, flag);
	for ( i=0; i<IDX_SC_SIZE; i++)
		Query[i].query = (IGRboolean) flag[i];

	/* Create <tpl_thickness> (foot) expression */
	sts = exp$create ( exp_value = tpl_thickness,
                           p_exp_id  = &feet_list[IDX_SF_TTHI].objid,
                           osnum     = md_env->md_id.osnum,
                           p_osnum   = &feet_list[IDX_SF_TTHI].osnum);
        as$status ( sts    = sts,
                    msg    = "exp$create(TTHI))",
                    test   = (sts != EXP_S_SUCCESS),
                    action = GOTO_VALUE,
                    value  = wrapup );
#ifdef TRACE
printf( "feet_list[IDX_SF_TTHI] = (%d|%d)\n", 
	feet_list[IDX_SF_TTHI].osnum, feet_list[IDX_SF_TTHI].objid );
#endif

	/* Find the real stiffener object */
	sts = vl$return_foot ( msg     = msg,
			       objId   = &list[IDX_ST_STIF],
			       objEnv  = md_env,
			       footId  = &Stiff.obj_id,
			       footEnv = &Stiff.mod_env );
	if (!((*msg)&1&sts)) {	Stiff.obj_id  = list[IDX_ST_STIF];
				Stiff.mod_env = *md_env;	}

	sts = VLcheckLinearity( &Stiff, md_env, &linear );
        as$status ( sts    = sts,
                    msg    = "VLcheckLinear", 
                    test   = (!(sts & 0x00000001)),
                    action = GOTO_VALUE,
                    value  = wrapup );

	if( linear ) { 
               ex$message(     field           = ERROR_FIELD,
                               justification   = CENTER_JUS,
                               in_buff         = "Stiffener axis is linear: No Template created" ) ;
	       printf("\nStiffener axis is linear : No Template created" ) ;
 	       goto wrapup;	}

	/* Get the common edge */
	sts = VLgetCommonEdge ( &Stiff, name, VS_K_nmFlgInfE, &WebFace, NULL,
				md_env, &Bedge, msg );
        as$status ( sts    = sts,
                    msg    = "VLgetCommonEdge()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

/*
 *      If there is no common edge between VS_K_nmWebL and VS_K_nmFlgInfE
 *      (i.e. if it is not a "T" beam), I supposed it as a "I" beam.
 *      Compute the common edge between VS_K_nmWebL and VS_K_nmFlgInfILS
 *      or VS_K_nmWebR and VS_K_nmFlgInfIRS if the above function fails.
 */

        if( Bedge.objid == NULL_OBJID )
        {
           IGRchar face_name[40];
           if( !strcmp( name, VS_K_nmWebL ) )
                strcpy( face_name, VS_K_nmFlgInfILS );
           else
                strcpy( face_name, VS_K_nmFlgInfIRS );

           sts = om$send( msg = message NDmacro.ACtest_foot(
                                                msg,face_name  ),
                              senderid = NULL_OBJID,
                              targetid = Stiff.obj_id.objid,
                              targetos = Stiff.obj_id.osnum );

           if(!( sts & *msg & 1) )
           {
                if( !strcmp( name, VS_K_nmWebL ) )
                    strcpy( face_name, VS_K_nmFlgInfILF );
                else
                    strcpy( face_name, VS_K_nmFlgInfIRF );
           }


           sts = VLgetCommonEdge ( &Stiff, name, face_name, &WebFace,
                                    NULL, md_env, &Bedge, msg );

        }

        as$status ( sts    = sts,
                    msg    = "VLgetCommonEdge()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Change face environment */
	WebFace.mod_env = Stiff.mod_env;

	/* Construct Top edge of the template */
	sts = VLtopStfTpl ( &WebFace, &Bedge, tpl_height, web_left, md_env,
			    &Tedge, msg );
        as$status ( sts    = sts,
                    msg    = "VLtopStfTpl()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Get extremities points */
	sts = VLorderedEndpts ( &Bedge, &Tedge, md_env, Xpt, msg);
        as$status ( sts    = sts,
                    msg    = "VLorderedEndpts()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Extend bottom curve */
	sts = VLextendCurve( msg, &Bedge, md_env, BaseTol, DistTol,
			     ext1, ext2, NULL, NULL);
        as$status ( sts    = sts,
                    msg    = "VLextendCurve()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Extend top curve */
	sts = VLextendCurve( msg, &Tedge, md_env, BaseTol, DistTol,
			     ext1, ext2, NULL, NULL);
        as$status ( sts    = sts,
                    msg    = "VLextendCurve()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

{        struct  ret_struct      attrVal;
        char                    attrName[40];
	int             	suc,tmp=0;
        strcpy( attrName, VS_K_bmFlgThkAttr );

          sts = om$send( msg = message NDmacro.ACgive_structure (
                                                        &suc ,
                                                        &tmp,
                                                        attrName,
                                                        &attrVal,
                                                        &(Stiff.mod_env)),
                        senderid = NULL_OBJID,
                        targetid = Stiff.obj_id.objid,
                        targetos = Stiff.obj_id.osnum  );

          if(!(sts & 1 & suc))
	  {
            RangTol = 2.00;
	  }
          else
          {
	    RangTol = attrVal.var.root_pm_st.value * 2.0 + 2.0 ;
	  }

}

	/* Query for lines in the range of stiffener wide side */
	sts = VLqueryStfTpl ( &WebFace, &Stiff, Query, RangTol, md_env,
			      &nlin, &Qline, &nmac, &Qmacr, msg);
        as$status ( sts    = sts,
                    msg    = "VLqueryStfTpl()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Create ACrg_collect box */
	sts = VLcreateAttrStfTpl ( nlin, nmac, &attr, msg);
        as$status ( sts    = sts,
                    msg    = "VLcreateAttrStfTpl()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Query for available lines along Bedge */
	Bottom.obj_id  = Bedge;
	Bottom.mod_env = *md_env;
#ifdef TRACE
for (i=0;i<nlin;i++) {
printf( ">>> Qline %d = (%d|%d)\n",
	i, Qline[i].obj_id.osnum, Qline[i].obj_id.objid );
}
#endif

	/* Realloc memory for Qline if needed */
	if (nmac) {
		if (Qline) 
			Qline = (struct GRobj_env *) om$realloc (
				ptr  = (IGRchar *) Qline,
				size = (nlin+nmac)*sizeof(struct GRobj_env) );
		else	Qline = om$calloc ( num	      = nmac,
					    structure = struct GRobj_env );
	}

	sts = VLvertexStfTpl ( nlin, Qline, nmac, Qmacr, &Bottom, RangTol,
			       Xpt[0], Xpt[2], Query,
			       &attr, &nvtx, &vertex, &tagnam, msg);
        as$status ( sts    = sts,
                    msg    = "VLvertexStfTpl()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
#ifdef TRACE
for (i=0;i<nvtx;i++) {
printf( "<<< Qline %d = (%d|%d)\n",
	i, Qline[i].obj_id.osnum, Qline[i].obj_id.objid );
}
#endif

	if (!nvtx) {

		/* Because of some problem with gap WebSide & VSplates */

		/* Change of Web Side */
		if (web_left == VAL_TO_WEBL) 	strcpy ( name, VS_K_nmWebR);
		else 				strcpy ( name, VS_K_nmWebL);
#ifdef TRACE
printf( "nvtx = %d so have a look on <%s>\n", nvtx, name);
#endif
		/* Find other web side common edge */
		sts = VLgetCommonEdge ( &Stiff, name, VS_K_nmFlgInfE, &WebFace,
					NULL, md_env, &Oedge, msg );
        	as$status ( sts    = sts,
	                    msg    = "VLgetCommonEdge()",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );

/*
 *      If there is no common edge between VS_K_nmWebL and VS_K_nmFlgInfE
 *      (i.e. if it is not a "T" beam), I supposed it as a "I" beam.
 *      Compute the common edge between VS_K_nmWebL and VS_K_nmFlgInfILS
 *      or VS_K_nmWebR and VS_K_nmFlgInfIRS if the above function fails.
 */

        if( Oedge.objid == NULL_OBJID )
        {
           IGRchar face_name[40];
           if( !strcmp( name, VS_K_nmWebL ) )
                strcpy( face_name, VS_K_nmFlgInfILS );
           else
                strcpy( face_name, VS_K_nmFlgInfIRS );

           sts = om$send( msg = message NDmacro.ACtest_foot(
                                                msg,face_name  ),
                              senderid = NULL_OBJID,
                              targetid = Stiff.obj_id.objid,
                              targetos = Stiff.obj_id.osnum );

           if(!( sts & *msg & 1) )
           {
                if( !strcmp( name, VS_K_nmWebL ) )
                    strcpy( face_name, VS_K_nmFlgInfILF );
                else
                    strcpy( face_name, VS_K_nmFlgInfIRF );
           }


           sts = VLgetCommonEdge ( &Stiff, name, face_name, &WebFace,
                                    NULL, md_env, &Oedge, msg );


        }

        as$status ( sts    = sts,
                    msg    = "VLgetCommonEdge()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

		/* Find other bottom edge endpoints */
		sts = VLendpts ( msg, &Oedge, md_env, Ospt, Oept);
        	as$status ( sts    = sts,
	                    msg    = "VLendpts()",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );

		/* Extend bottom curve */
		sts = VLextendCurve ( msg, &Oedge, md_env, BaseTol, DistTol,
			       	      ext1, ext2, NULL, NULL);
        	as$status ( sts    = sts,
	                    msg    = "VLextendCurve()",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );

		/* Query for available lines along other Bedge */
		Bottom.obj_id  = Oedge;
		Bottom.mod_env = *md_env;
		sts = VLvertexStfTpl ( nlin, Qline, nmac, Qmacr, &Bottom,
				       RangTol, Ospt, Oept, Query, 
			       	       &attr, &nvtx, &vertex, &tagnam, msg);
        	as$status ( sts    = sts,
	                    msg    = "VLvertexStfTpl()",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );

		/* Delete other bottom edge */
		gr$delete_object ( msg          = msg,
				   md_env       = &Bottom.mod_env,
				   object_id	= &Bottom.obj_id,
				   display_flag = 0 );
		
		/* Project vertices on the good web side */
		for ( i=0; i<nvtx; i++) {
			dblcpy ( pnt, vertex[i], 3);
			sts = om$send ( msg = message GRgraphics.GRptproject (
						msg,
						&md_env->md_env.matrix_type,
						md_env->md_env.matrix,
						pnt, vertex[i], &parm ),
					senderid = NULL_OBJID,
					targetid = Bedge.objid,
					targetos = Bedge.osnum );
        		as$status ( sts    = sts,
		                    msg    = "GRgraphics.GRptproject",
		                    test   = (!(sts & 0x00000001 & (*msg))),
		                    action = GOTO_VALUE,
		                    value  = wrapup );
		}
	}

	sts = om$construct ( classid = OPP_ACdyn_col_class_id,
                             osnum   = feet_list[IDX_SF_ATTR].osnum,
                             p_objid = &feet_list[IDX_SF_ATTR].objid );

        sts = om$send ( msg = message ACdyn_col.ACset_list_attribute
                                        ( msg, IDX_SB_PVAR+nvtx, attr),
                        targetid = feet_list[IDX_SF_ATTR].objid,
                        targetos = feet_list[IDX_SF_ATTR].osnum );
        as$status ( sts    = sts,
                    msg    = "ACdyn_col.ACset_list_attribute",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Adjust feet number */
	(*fcount) += 2 * nvtx;

	/* Allocate memory for line segments array */
	line_id = om$calloc ( num       = 2 + nvtx,
			      structure = struct GRid );
	text_id = om$calloc ( num       = 2 + nvtx,
			      structure = struct GRid );

	/* Create text mark and line segments */
	if (vs$is_ancestry_valid ( object  = &Stiff.obj_id,
				   classid = OPP_VSimgFeature_class_id ) )
		Xinv = -1.0;
	sts = VLtextStfTpl ( &Bedge, &Tedge, Xpt, vertex, tagnam, nvtx, md_env,
			     Query, Qline, Xinv, text_id, line_id, msg );
        as$status ( sts    = sts,
                    msg    = "VLtextStfTpl()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
#ifdef TRACE
for ( i=0; i<nvtx; i++)
	printf ( "Elem %2d : text_id : (%d|%d)\tline_id : (%d|%d)\n",
		i, text_id[i].osnum, text_id[i].objid,
		line_id[i].osnum, line_id[i].objid );
#endif
	/* Set text mark and line segments in macro feet */
	feet_list[IDX_SF_SMRK] = text_id[0];
	feet_list[IDX_SF_EMRK] = text_id[1];
	feet_list[IDX_SF_SLIN] = line_id[0];
	feet_list[IDX_SF_ELIN] = line_id[1];
	for ( i=0; i<nvtx; i++)	{
		feet_list[MACRO_S_FFEET+2*i]   = line_id[2+i];
		feet_list[MACRO_S_FFEET+2*i+1] = text_id[2+i];
	}

	/* Compute arc lengths of Bedge */
	sts = VLdirectionStfTpl ( &Bedge, &Tedge, md_env, Xpt[0], Xpt[2],
				  nvtx, &line_id[2],
				  &feet_list[IDX_SF_AMRK],
				  &feet_list[IDX_SF_ALIN], msg);
        as$status ( sts    = sts,
                    msg    = "VLdirectionStfTpl()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Create contour (last created : delete Bedge & Tedge) */
	sts = VLcontourStfTpl ( &Bedge, &Tedge, md_env, BaseTol, DistTol,
				&feet_list[IDX_SF_CONT], msg );
        as$status ( sts    = sts,
                    msg    = "VLcontourStfTpl()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	Bedge.objid = Tedge.objid = NULL_OBJID;
	Bedge.osnum = Tedge.osnum = md_env->md_id.osnum;

#ifdef TRACE
printf( "feet_list[IDX_SF_CONT] = (%d|%d)\n", 
	feet_list[IDX_SF_CONT].osnum, feet_list[IDX_SF_CONT].objid );
#endif

wrapup:

#ifdef TRACE
printf("\n Status =  %d , msg = %d ",sts, *msg );
printf("\n the Number of feets  %d   ",*fcount);
for ( i=0; i< *fcount; i++)
printf( "feet_list[%d] = (%d|%d)\n",
         i,feet_list[i].osnum, feet_list[i].objid );
#endif

	if (!(sts & 0x00000001 & (*msg))) {

		if (Bedge.objid != NULL_OBJID)
			gr$delete_object ( msg          = &loc_msg,
			   		   md_env       = md_env,
			   		   object_id	= &Bedge,
			   		   display_flag = 0 );

		if (Tedge.objid != NULL_OBJID)
			gr$delete_object ( msg          = &loc_msg,
			   		   md_env       = md_env,
			   		   object_id	= &Tedge,
			   		   display_flag = 0 );

		for ( i=0; i<*fcount; i++) {
			if (feet_list[i].objid != NULL_OBJID)
				gr$delete_object ( msg          = &loc_msg,
				   		   md_env       = md_env,
				   		   object_id	= &feet_list[i],
				   		   display_flag = 0 );
		}
		*fcount = 0;
	}

	if (text_id) {	om$dealloc (ptr = text_id); text_id = NULL;	}
	if (line_id) {	om$dealloc (ptr = line_id); line_id = NULL;	}
	if (tagnam)  {	om$dealloc (ptr = tagnam);  tagnam  = NULL;	}
	if (vertex)  {	om$dealloc (ptr = vertex);  vertex  = NULL;	}
	if (Qmacr)   {	om$dealloc (ptr = Qmacr);   Qmacr   = NULL;	}
	if (Qline)   {	om$dealloc (ptr = Qline);   Qline   = NULL;	}

#ifdef TRACE
printf("\t<<< Exit from VLstfnrTpli.ACconstruct_feet\n");
#endif

	return(sts);
}

method VDgetObjDef( long *msg ; VDobjDef *myDef ) {

        long            sts ;   /* OM return code       */

        /*
         * name.
         */
        myDef->info             = VL_I_ObjStiffenerTemp;
        myDef->type             = 0 ;

        sts     = OM_S_SUCCESS ;
        *msg    = MSSUCC ;

        return sts ;
} /* method VDgetObjdDef */
/*----------------------------------------------------------------------------*/


end implementation VLstfnrTpl;
