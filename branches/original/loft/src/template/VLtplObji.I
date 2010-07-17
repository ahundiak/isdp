class implementation VLtplObj;

#include        <math.h>
#include	"vlprototype.h"
#include	"AS_status.h"
#include	"nddef.h"
#include	"bsparameters.h"
#include	"bstypes.h"
#include	"bserr.h"
#include	"expression.h"
#include	"expmacros.h"
#include	"asmacros.h"
#include	"grmacros.h"

#include        "vsplate.h"
#include	"vsplatedef.h"

#include	"bscrossp.h"
#include	"bsdotp.h"
#include	"bsnorvec.h"
#include	"bsxtractpar.h"

#include	"mainvmx.h"
#include	"mamulmx.h"
#include	"matypemx.h"

#include 	"vlmsg.h"
#include	"vltemplate.h"
#include	"vlcntrline.h"
#include	"vlmiscmacros.h"
#include	"vlplatejig.h"

from	GRcurve		import	GRrevparm;
from	GRgencs		import	GRgetmatrix;

extern	IGRchar		*strrchr();
extern	IGRint		dblcpy();

/*	#define	TRACE		*/
/*	#define	TRACE_MATRIX	*/
/*	#define	TRACE_MEMORY	*/

/* ========================================================================== */
method ACconstruct_feet ( 		IGRlong		*msg;
			 		IGRint		cn_type;
			 		IGRint		count;
			 struct		GRid		list[];
			 struct		GRmd_env	*md_env;
					IGRint		*fcount;
			 struct		GRid		*feet_list	)
{

		IGRlong		sts, loc_msg;
	struct	GRvg_construct	cst;
		VLpltTplArg	arg;
		IGRdouble	Bpln[6];
                IGRdouble       Axis[3], angle_value=0.0, x_rng=0.0, y_rng=0.0;
		IGRchar		side[DI_PATH_MAX], name[DI_PATH_MAX], Ename[10];
		IGRint		i, idx=0, Xform=0;
	struct	GRobj_env	Support, Kline;
		IGRdouble	Ppln[6], Tpln[6];
		IGRdouble	BaseTol, ChtTol, DistTol;
	struct	GRid		Wpt1_id, Wpt2_id, text_id[6], cs_id;
		IGRmatrix	TXTmat, CSYmat, SCAmat, PRJmat;
		IGRmatrix	RNGmat, INVmat, CURmat;
		IGRshort	four=4, type, one=1;
		IGRpoint	Rpt1, Rpt2;
		GRrange		range;
		IGRdouble	Rng[4], rng[8];
	struct  GRobj_env       VSplate;
		IGRboolean	world=TRUE;
	struct	IGRplane	refplane;
		IGRpoint	point, spt, ept;
		IGRvector	normal, Vector, Cross;
	struct	GRid		plane_id, pl_id, SavExtInter, Line, Text;
	struct	IGRbsp_surface	*sf;
		BSrc		rc;
		IGRchar		LeanDirection[3];

#ifdef TRACE
printf("\t\t>>> Enter in VLtplObj.ACconstruct_feet\n");
#endif

	/* Initialize */
	BSxtractpar ( msg, BSTOLBASIS, &BaseTol);
        BSxtractpar ( msg, BSTOLCHRDHT, &ChtTol);
        DistTol = 5 * ChtTol;
	refplane.point  = point;
	refplane.normal = normal;
	Kline.obj_id.objid = plane_id.objid  = NULL_OBJID;
	Kline.obj_id.osnum = plane_id.osnum  = md_env->md_id.osnum;
	VLinitCnst (&cst);
	cst.env_info = md_env;
	*fcount = MACRO_TO_FEET + MACRO_TM_VFEET;
	for ( i=0; i<*fcount; i++)  {
  		feet_list[i].objid = NULL_OBJID;
		feet_list[i].osnum = md_env->md_id.osnum;
	}
	sf = NULL;
	arg.upr = arg.vpr = -1.0;

	/* Retrieve templates data */
	sts = VLtplObj_ret_attr ( &list[IDX_TO_ATTR], &arg, msg);
	as$status ( sts    = sts,
		    msg    = "VLtplObj_ret_attr()",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );
	Bpln[0] = arg.cnt[0];
	Bpln[1] = arg.cnt[1];
	Bpln[2] = arg.cnt[2];
	Bpln[3] = arg.nrm[0];
	Bpln[4] = arg.nrm[1];
	Bpln[5] = arg.nrm[2];
	
	/* Construct REAL DISTANCE foot */
	sts = exp$create ( exp_value = arg.dst,
			   p_exp_id  = &feet_list[IDX_TO_REAL].objid,
			   osnum     = md_env->md_id.osnum,
			   p_osnum   = &feet_list[IDX_TO_REAL].osnum );
	as$status ( sts    = sts,
		    msg    = "exp$create(REAL)",
		    test   = (sts != EXP_S_SUCCESS),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Evaluate axis vector */
        Axis[0] = Axis[1] = Axis[2] = 0.0;
        switch (arg.axe) {
                case IDX_AX1:   Axis[0] = 1.0;
                                break;
                case IDX_AX2:   Axis[1] = 1.0;
                                break;
                case IDX_AX3:   Axis[2] = 1.0;
                                break;
                default:        printf( "No Ship axis retrieved\n");
        }

	/* Retrieve plate support surface */
	sts = vl$return_foot ( msg     = msg,
                               objId   = &list[IDX_TO_PLAT],
                               objEnv  = md_env,
                               footId  = &VSplate.obj_id,
                               footEnv = &VSplate.mod_env );
        as$status ( sts    = sts,
                    msg    = "vl$return_foot(VSplate)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Retrieve geometric line of VLctlLine */
	sts = vl$return_foot ( msg     = msg,
			       name    = NAM_CL_CV,
                               objId   = &list[IDX_TO_CTRL],
                               objEnv  = md_env,
                               footId  = &Kline.obj_id,
                               footEnv = &Kline.mod_env );
	as$status ( sts    = sts,
		    msg    = "vl$return_foot(Kline)",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Correct normal inversion */
	if (arg.inv != INVNORM_OF)	arg.inv = INVNORM_ON;
	if (arg.inv == INVNORM_ON)	strcpy ( side, VS_K_plTopSfPath);
	else				strcpy ( side, VS_K_plBotSfPath);
#ifdef TRACE
printf( "arg.inv = %d : side : <%s>\n", arg.inv, side);
#endif

	if (arg.sta == VAL_TO_SPI)
	       	sts = VLextractVSplateSurface ( msg,
	                                        &VSplate.obj_id,
	                                        &VSplate.mod_env,
	                                        side,
	                                        &Support.obj_id,
	                                        &Support.mod_env,
						NULL);
	else
	       	sts = VLextractVSplateSurface ( msg,
	                                        &VSplate.obj_id,
	                                        &VSplate.mod_env,
	                                        side,
	                                        &Support.obj_id,
	                                        &Support.mod_env,
						&sf);
	as$status ( sts    = sts,
		    msg    = "VLextractVSplateSurface()",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );
#ifdef TRACE
printf( "VLextractVSplateSurface (%s) returns (%d|%d) in (%d|%d)\n",
        side, Support.obj_id.objid, Support.obj_id.osnum,
        Support.mod_env.md_id.objid, Support.mod_env.md_id.osnum );
#endif

	if (arg.sta == VAL_TO_MID) {

		/* Create intersection between VS base surface & plane */
#ifdef TRACE
printf( "VLcreateInter : between (%d|%d) and (%d|%d)\n",
        list[IDX_TO_PLAT].osnum, list[IDX_TO_PLAT].objid,
        list[IDX_TO_PLAN].osnum, list[IDX_TO_PLAN].objid);
#endif
		sts = VLcreateInter ( msg, &Support.obj_id, &Support.mod_env, 1,
				      &list[IDX_TO_PLAN], md_env, 0,
				      &feet_list[IDX_TO_CONT], md_env );
		if (!(sts & 0x00000001 & (*msg))) {
			sts     = OM_S_SUCCESS;
			*msg    = ND_COMP_SUCC;
			*fcount = 0;
			goto wrapup;
		}

#ifdef TRACE
om$get_classname ( osnum     = feet_list[IDX_TO_CONT].osnum,
		   objid     = feet_list[IDX_TO_CONT].objid,
		   classname = name );
printf( "VLcreateInter is (%d|%d) : <%s>\n", 
	feet_list[IDX_TO_CONT].osnum, feet_list[IDX_TO_CONT].objid, name);
#endif
	}

	else if (arg.sta == VAL_TO_EXT) {

		/* Extract normal from reference plane */
        	sts = om$send ( msg = message NDnode.ASreturn_go
						( &pl_id, &type, CURmat ),
                        	targetid = list[IDX_TO_PLAN].objid,
                        	targetos = list[IDX_TO_PLAN].osnum);
        	as$status ( sts    = sts,
                    	    msg    = "NDnode.ASreturn_go(PLAN)",
                    	    test   = (!(sts & 0x00000001)),
                    	    action = GOTO_VALUE,
                    	    value  = wrapup );
#ifdef TRACE
printf( "NDnode.ASreturn_go (%d|%d) --> (%d|%d)\n",
	list[IDX_TO_PLAN].osnum, list[IDX_TO_PLAN].objid,
	pl_id.osnum, pl_id.objid );
#endif
		sts = om$send ( msg = message GRvg.GRdetplane
					( msg, &type, CURmat, &refplane ),
                        	targetid = pl_id.objid,
                        	targetos = pl_id.osnum );
        	as$status ( sts    = sts,
                    	    msg    = "GRvg.GRdetplane(PLAN)",
                    	    test   = (!(sts & 0x00000001 & (*msg))),
                    	    action = GOTO_VALUE,
                    	    value  = wrapup );
#ifdef TRACE
printf( "EXT Reference Plane : [%g,%g,%g] & [%g,%g,%g]\n",
	refplane.point[0], refplane.point[1], refplane.point[2],
	refplane.normal[0], refplane.normal[1], refplane.normal[2] );
#endif
		/* Extract surface edge and build extremity plane */
		sts = VLextractSurfaceEdge ( msg, &Support, arg.upr, arg.vpr,
					     refplane.normal, md_env, &cst,
					     &feet_list[IDX_TO_CONT],
					     &plane_id, Ename );
        	as$status ( sts    = sts,
                    	    msg    = "VLextractSurfaceEdge()",
                    	    test   = (!(sts & 0x00000001 & (*msg))),
                    	    action = GOTO_VALUE,
                    	    value  = wrapup );
#ifdef TRACE
printf( "Extremity section plane is (%d|%d) called <%s>\n",
	plane_id.osnum, plane_id.objid, Ename);
#endif
	}

	else if (arg.sta == VAL_TO_SPI) {

		/* Copy LK line as begining of contour */
		sts = gr$copy_object ( msg	    = msg,
				       object_id    = &Kline.obj_id,
				       md_env	    = &Kline.mod_env,
				       new_env      = md_env,
				       new_id       = &feet_list[IDX_TO_CONT],
				       display_flag = 0 );
               	as$status ( sts    = sts,
                            msg    = "gr$copy_object()",
                            test   = (!(sts & 0x00000001 & (*msg))),
                            action = GOTO_VALUE,
                            value  = wrapup );

		/* Extract plane of the LK line */
		sts = VLdetplane ( msg, &feet_list[IDX_TO_CONT], md_env,
                               	   &Bpln[3], Axis, &refplane);
        	as$status ( sts    = sts,
                    	    msg    = "VLdetplane()",
                    	    test   = (!(sts & 0x00000001 & (*msg))),
                    	    action = GOTO_VALUE,
                    	    value  = wrapup );
#ifdef TRACE
printf( "SPI Reference Plane : [%g,%g,%g] & [%g,%g,%g]\n",
	refplane.point[0], refplane.point[1], refplane.point[2],
	refplane.normal[0], refplane.normal[1], refplane.normal[2] );
#endif

		/* Create LK plane */
		sts = VLcreatePlane ( refplane.point, refplane.normal, md_env,
				      &cst, &plane_id, msg);
        	as$status ( sts    = sts,
                    	    msg    = "VLcreatePlane()",
                    	    test   = (!(sts & 0x00000001 & (*msg))),
                    	    action = GOTO_VALUE,
                    	    value  = wrapup );

		/* Rename LK plane */
		sts = VLchangeTemporaryName ( md_env, &plane_id, "spine", msg);
                as$status ( sts    = sts,
                            msg    = "VLchangeTemporaryName",
                            test   = (!(sts & 0x00000001 & (*msg))) );
	}

	/* Orient template to be */
	sts = VLendpts ( msg, &feet_list[IDX_TO_CONT], md_env, spt, ept);
       	as$status ( sts    = sts,
                    msg    = "VLendpts()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	for ( i=0; i<3; i++)	Vector[i] = ept[i] - spt[i];
	BSnorvec ( &rc, Vector);
       	if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }

	if (arg.sta == VAL_TO_SPI)	dblcpy ( Cross, Axis, 3);
	else if (  ( (arg.sta == VAL_TO_MID) && (Axis[0] == 1.0) )
	        || ( (arg.sta == VAL_TO_EXT) && (Axis[0] == 1.0) ) )
		BScrossp ( &rc, &Bpln[3], Axis, Cross);
	else 	BScrossp ( &rc, Axis, &Bpln[3], Cross);
#ifdef TRACE
printf( "Axis:[%g,%g,%g] Cross:[%g,%g,%g] Vector:[%g,%g,%g]\n",
	Axis[0], Axis[1], Axis[2],
	Cross[0], Cross[1], Cross[2],
	Vector[0], Vector[1], Vector[2] );
#endif
	if (BSdotp ( &rc, Cross, Vector) > 0) {
		sts = om$send ( msg = message GRcurve.GRrevparm ( msg, md_env),
				targetid= feet_list[IDX_TO_CONT].objid,
				targetos= feet_list[IDX_TO_CONT].osnum);
		as$status ( sts    = sts,
			    msg    = "GRcurve.GRrevparm",
			    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );
#ifdef TRACE
printf( "\tCurve reversed before VLextendCurve()\n");
#endif
	}

	/* Extend intersection */
	sts = VLextendCurve( msg, &feet_list[IDX_TO_CONT], md_env, BaseTol,
			     DistTol, arg.xt1, arg.xt2, &Wpt1_id, &Wpt2_id);
	as$status ( sts    = sts,
		    msg    = "VLextendCurve()",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	if ( (arg.sta != VAL_TO_SPI) && (!arg.ful) ) {
		/* Save extended intersection */
		sts = gr$copy_object ( msg	    = msg,
				       object_id    = &feet_list[IDX_TO_CONT],
				       md_env	    = md_env,
				       new_env      = md_env,
				       new_id       = &SavExtInter,
				       display_flag = 0 );
	}

	/* Project average normal on section plane */
#ifdef TRACE
printf( "arg.sta = %d, plane_id = (%d|%d)\n", arg.sta,
	plane_id.osnum, plane_id.objid );
#endif
	if      (arg.sta == VAL_TO_MID)
		sts = VLcomputePlanes ( Bpln, &list[IDX_TO_PLAN], arg.dst,
					md_env, Ppln, Tpln, msg);
	else if ((arg.sta == VAL_TO_EXT) || (arg.sta == VAL_TO_SPI))
		sts = VLcomputePlanes ( Bpln, &plane_id, arg.dst,
					md_env, Ppln, Tpln, msg);
	as$status ( sts    = sts,
		    msg    = "VLcomputePlanes()",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );
#ifdef TRACE
printf( "P plane : [%g,%g,%g]\t& [%g,%g,%g]\n",
	Ppln[0], Ppln[1], Ppln[2], Ppln[3], Ppln[4], Ppln[5] );
printf( "T plane : [%g,%g,%g]\t& [%g,%g,%g]\n",
	Tpln[0], Tpln[1], Tpln[2], Tpln[3], Tpln[4], Tpln[5] );
#endif

	/* Create template's contour */
	sts = VLcreateContour ( msg, &feet_list[IDX_TO_CONT], md_env,
				Tpln, &cst, DistTol, BaseTol, Rpt1, Rpt2 );
	as$status ( sts    = sts,
		    msg    = "VLcreateContour()",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Retrieve template name */
	name[0] = '\0';
	if      (arg.sta == VAL_TO_MID)
		VLcreateName ( msg, 1, &list[IDX_TO_PLAT], &list[IDX_TO_PLAN],
			       md_env, MACRO_TO_NAME, name);
	else if ((arg.sta == VAL_TO_EXT) || (arg.sta == VAL_TO_SPI))
		VLcreateName ( msg, 1, &list[IDX_TO_PLAT], &plane_id,
			       md_env, MACRO_TO_NAME, name);
#ifdef TRACE
printf( "Template name will be : <%s>\n", name);
#endif

	/* Construct REFERENCE PLANE foot */
	sts = exp$create ( exp_syntax = name,
			   p_exp_id   = &feet_list[IDX_TO_REFP].objid,
			   osnum      = md_env->md_id.osnum,
			   p_osnum    = &feet_list[IDX_TO_REFP].osnum,
			   type_rq    = EXP_TEXT);
	as$status ( sts    = sts,
		    msg    = "exp$create(REFP)",
		    test   = (sts != EXP_S_SUCCESS),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Create control points */
	feet_list[IDX_TO_LINE].objid = NULL_OBJID;
	feet_list[IDX_TO_LINE].osnum = md_env->md_id.osnum;
	angle_value = -1.0;
	LeanDirection[0] = '\0';
	if      (arg.sta == VAL_TO_MID)
		sts = VLcreateSline ( &feet_list[IDX_TO_CONT],
				      Tpln,
				      &Kline.obj_id,
				      &list[IDX_TO_PLAN],
				      &Bpln[3],
				      md_env,
				      Axis,
				      arg.mid,
				      arg.siz,
				      sf,
				      &feet_list[IDX_TO_LINE],
				      &angle_value,
				      LeanDirection,
				      msg);
	else if (arg.sta == VAL_TO_EXT)
		sts = VLcreateSline ( &feet_list[IDX_TO_CONT],
				      Tpln,
				      &Kline.obj_id,
				      &plane_id,
				      &Bpln[3],
				      md_env,
				      Axis,
				      arg.mid,
				      arg.siz,
				      sf,
				      &feet_list[IDX_TO_LINE],
				      &angle_value,
				      LeanDirection,
				      msg);
	as$status ( sts    = sts,
		    msg    = "VLcreateSline()",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	if ( (arg.sta == VAL_TO_MID) || (arg.sta == VAL_TO_EXT) ) {

		/* Copy LP LINE foot */
		sts = gr$copy_object ( msg	    = msg,
				       object_id    = &feet_list[IDX_TO_LINE],
				       md_env	    = md_env,
				       new_env      = md_env,
				       new_id       = &feet_list[IDX_TO_LP3D],
				       display_flag = 0 );
		as$status ( sts    = sts,
			    msg    = "gr$copy_object(IDX_TO_LP3D)",
			    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );

		/* Construct LEAN DIRECTION foot */
		sts = exp$create ( exp_syntax = LeanDirection,
			           p_exp_id   = &feet_list[IDX_TO_LEAN].objid,
			           osnum      = md_env->md_id.osnum,
			           p_osnum    = &feet_list[IDX_TO_LEAN].osnum,
			           type_rq    = EXP_TEXT);
		as$status ( sts    = sts,
			    msg    = "exp$create(LEAN)",
			    test   = (sts != EXP_S_SUCCESS),
			    action = GOTO_VALUE,
			    value  = wrapup );
	}

	/* Create the text, feet of the macro */
	sts = VLcreateTplText ( name, angle_value, Rpt1, Rpt2,
				arg.siz, arg.inv, arg.sta,
        	   		&feet_list[IDX_TO_LINE],
        	   		&feet_list[IDX_TO_AMARK],
        	   		&feet_list[IDX_TO_LINE1],
        	   		&feet_list[IDX_TO_LINE2],
				&Wpt1_id, &Wpt2_id,
				md_env, &cst, text_id, TXTmat, msg );
	as$status ( sts    = sts,
	  	    msg    = "VLcreateTplText()",
	    	    test   = (!(sts & 0x00000001 & (*msg))),
	    	    action = GOTO_VALUE,
	    	    value  = wrapup );

	/* Copy the created text in the GRid list of feet */
	feet_list[IDX_TO_NAME]	= text_id[0];
	feet_list[IDX_TO_ATEXT]	= text_id[1];
	feet_list[IDX_TO_WELD1]	= text_id[2];
	feet_list[IDX_TO_WELD2]	= text_id[3];
	feet_list[IDX_TO_ANGL]	= text_id[4];
	feet_list[IDX_TO_TEXT]	= text_id[5];

	if (arg.sta == VAL_TO_SPI) {

		idx = MACRO_TO_SPINE;

		for ( i=MACRO_TO_TEMP; i<count; i++) {

			/* Extract info from rib-template */
			sts = vl$return_foot ( msg     = msg,
					       name    = NAM_TO_LP3D,
		                               objId   = &list[i],
		                               footId  = &Line );
		        as$status ( sts    = sts,
		                    msg    = "vl$return_foot(LP3D)",
		                    test   = (!(sts & 0x00000001 & (*msg))),
		                    action = GOTO_VALUE,
		                    value  = wrapup );

			sts = vl$return_foot ( msg     = msg,
					       name    = NAM_TO_REFP,
		                               objId   = &list[i],
		                               footId  = &Text );
		        as$status ( sts    = sts,
		                    msg    = "vl$return_foot(REFP)",
		                    test   = (!(sts & 0x00000001 & (*msg))),
		                    action = GOTO_VALUE,
		                    value  = wrapup );

			/* Create mark and text */
			sts = VLtplSpiMarkText ( msg, &Line, &Text,
						 md_env, &cst, arg.siz,
						 &feet_list[IDX_TO_CONT],
					         &feet_list[idx],
						 &feet_list[idx+1] );
			as$status ( sts    = sts,
		    		    msg    = "VLtplSpiMarkText()",
		    		    test   = (!(sts & 0x00000001 & (*msg))),
		    		    action = GOTO_VALUE,
		    		    value  = wrapup );
			idx+=2;
		}
	}

	else { 	/* ROLL LINES */
		struct GRid             res_id, *macrosId=NULL;
		struct	GRobj_env	VLrolLine, VSplateSrc;
			IGRint		lNumber, i, nb_roll=0;
			IGRpoint	*lTraces;

		idx = MACRO_TO_FEET;

		lTraces = NULL;

		/* Get the VLrolLine object from VSPlate template */
		VLrolLine.obj_id.objid = NULL_OBJID;
		VLrolLine.mod_env = VSplate.mod_env;
		VLrolLine.obj_id.osnum = VLrolLine.mod_env.md_id.osnum;

        	as$make_source(go_grid = VSplate.obj_id,
                       	       mod_env = &VSplate.mod_env,
                       	       as_grid = &VSplateSrc.obj_id);

		sts = VLgetChildrenMacro( VSplateSrc, "RolLn",
				&nb_roll, &macrosId, &res_id );
		if( nb_roll ) 	VLrolLine.obj_id = macrosId[0] ;
		else		VLrolLine.obj_id.objid = NULL_OBJID;
		if( macrosId ) 
		{ 
		    om$dealloc( ptr = macrosId ); 
		    macrosId = NULL;
		}

		/* Get traces of the VLrolLine geometry */
		sts = VLgetRollLineTraces ( msg,
					    &VLrolLine,
					    &list[IDX_TO_PLAN],
					    md_env,
					    &lNumber,
					    &lTraces );
	        as$status ( sts    = sts,
		            msg    = "VLgetRollLineTraces()",
		            test   = (!(sts & 0x00000001 & (*msg))),
		            action = GOTO_VALUE,
		    	    value  = NoTraces );

		/* Add traces as text object in feet list */
		for ( i=0; i<lNumber; i++ ) {

			sts = VLsetRollLineTraces ( msg,
						    lTraces[i],
						    arg.siz,
						    TXTmat,
						    md_env,
						    &cst,
						    &feet_list[idx],
						    &feet_list[idx+1] );
	        	as$status ( sts    = sts,
			            msg    = "VLgetRollLineTraces()",
			            test   = (!(sts & 0x00000001 & (*msg))),
			            action = GOTO_VALUE,
			    	    value  = wrapup );
#ifdef TRACE
printf ( "ROLL LINE : feet_list[%d] is [%d|%d]\n",
	idx, feet_list[idx].objid, feet_list[idx].osnum );
#endif
			idx+=2;
		}

NoTraces:
		/* Free traces buffer */
		if (lTraces) {
			om$dealloc (ptr = lTraces);
			lTraces = NULL;
		}
	}

	/* Adjust feet number */
	*fcount = idx;

       	/* Delete weld point 1 */
       	sts = om$send ( msg = message GRgraphics.GRdelete (msg,md_env),
                       	targetid = Wpt1_id.objid,
                       	targetos = Wpt1_id.osnum);
	as$status ( sts    = sts,
	    	    msg    = "GRgraphics.GRdelete",
	    	    test   = (!(sts & 0x00000001 & (*msg))),
	    	    action = GOTO_VALUE,
	    	    value  = wrapup );
	
	/* Delete weld point 2 */
	sts = om$send ( msg = message GRgraphics.GRdelete (msg,md_env),
                       	targetid = Wpt2_id.objid,
                       	targetos = Wpt2_id.osnum);
	as$status ( sts    = sts,
		    msg    = "GRgraphics.GRdelete",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	if (arg.prj == PROJECT_ON) {

		/* Retrieve target cs matrix */
        	sts = om$send ( msg = message NDnode.ASreturn_go
						( &cs_id, NULL, NULL),
                        	targetid = list[IDX_TO_CSYS].objid,
                        	targetos = list[IDX_TO_CSYS].osnum);
		as$status ( sts    = sts,
		    	    msg    = "NDnode.ASreturn_go",
		    	    action = GOTO_VALUE,
		    	    value  = wrapup );

        	sts = om$send ( msg = message GRgencs.GRgetmatrix (msg,CSYmat),
                        	targetid = cs_id.objid,
                        	targetos = cs_id.osnum);
		as$status ( sts    = sts,
		    	    msg    = "GRgencs.GRgetmatrix",
		    	    test   = (!(sts & 0x00000001 & (*msg))),
		    	    action = GOTO_VALUE,
		    	    value  = wrapup );

#ifdef TRACE_MATRIX
printf( "\n\tCoordinate System Matrix (before correction)\n");
printf( "\t[%g,%g,%g,%g]\n\t[%g,%g,%g,%g]\n\t[%g,%g,%g,%g]\n\t[%g,%g,%g,%g]\n",
        CSYmat[0],  CSYmat[1],  CSYmat[2],  CSYmat[3],
	CSYmat[4],  CSYmat[5],  CSYmat[6],  CSYmat[7],
        CSYmat[8],  CSYmat[9],  CSYmat[10], CSYmat[11],
	CSYmat[12], CSYmat[13], CSYmat[14], CSYmat[15] );
#endif
		/* Save cs matrix for further range computation */
		dblcpy ( RNGmat, CSYmat, 16);
#ifdef TRACE_MATRIX
printf( "\n\tText Matrix\n");
printf( "\t[%g,%g,%g,%g]\n\t[%g,%g,%g,%g]\n\t[%g,%g,%g,%g]\n\t[%g,%g,%g,%g]\n",
        TXTmat[0],  TXTmat[1],  TXTmat[2],  TXTmat[3],
	TXTmat[4],  TXTmat[5],  TXTmat[6],  TXTmat[7],
        TXTmat[8],  TXTmat[9],  TXTmat[10], TXTmat[11],
	TXTmat[12], TXTmat[13], TXTmat[14], TXTmat[15] );
#endif

		/* Compute projection matrix */
		MAinvmx  ( msg, &four, TXTmat, INVmat);

		for ( i=0; i<16; i++) 	SCAmat[i] = 0.0;
		SCAmat[0] = SCAmat[5] = SCAmat[10] = arg.sca;
		SCAmat[15] = 1.0;

		MAmulmx  ( msg, &four, &four, &four, SCAmat, INVmat, CURmat);
		MAmulmx  ( msg, &four, &four, &four, CSYmat, CURmat, PRJmat);
		MAtypemx ( msg, PRJmat, &type);
#ifdef TRACE_MATRIX
printf( "\n\tProjection Matrix\n");
printf( "\t[%g,%g,%g,%g]\n\t[%g,%g,%g,%g]\n\t[%g,%g,%g,%g]\n\t[%g,%g,%g,%g]\n",
        PRJmat[0],  PRJmat[1],  PRJmat[2],  PRJmat[3],
	PRJmat[4],  PRJmat[5],  PRJmat[6],  PRJmat[7],
        PRJmat[8],  PRJmat[9],  PRJmat[10], PRJmat[11],
	PRJmat[12], PRJmat[13], PRJmat[14], PRJmat[15] );
#endif

		/* Apply transformation to feet */
		Xform = *fcount;

		for ( i=0; i<Xform; i++) {
			if (feet_list[i].objid != NULL_OBJID) {
				sts = om$send ( msg = message GRgraphics.GRxform
							( msg,
							  md_env,
							  &type,
							  PRJmat,
							  &feet_list[i].objid ),
                        			targetid = feet_list[i].objid,
                        			targetos = feet_list[i].osnum);
				as$status ( sts    = sts,
		    	    	    	    msg    = "GRgraphics.GRxform",
		    	    	    	    test   = (!(sts&0x00000001&(*msg))),
		    	    	    	    action = GOTO_VALUE,
		    	    	    	    value  = wrapup );
			}
		}
	}
	else	{	dblcpy ( RNGmat, TXTmat, 16);	}

	MAtypemx ( msg, RNGmat, &type);
#ifdef TRACE_MATRIX
printf( "\n\tWorld Matrix\n");
printf( "\t[%g,%g,%g,%g]\n\t[%g,%g,%g,%g]\n\t[%g,%g,%g,%g]\n\t[%g,%g,%g,%g]\n",
        RNGmat[0],  RNGmat[1],  RNGmat[2],  RNGmat[3],
	RNGmat[4],  RNGmat[5],  RNGmat[6],  RNGmat[7],
        RNGmat[8],  RNGmat[9],  RNGmat[10], RNGmat[11],
	RNGmat[12], RNGmat[13], RNGmat[14], RNGmat[15] );
#endif
	  
	/* Get contour range */
	sts = om$send ( msg = message GRgraphics.GRgetrang
				( msg, &type, RNGmat, &world, range ),
                       	targetid = feet_list[IDX_TO_CONT].objid,
                       	targetos = feet_list[IDX_TO_CONT].osnum);
	as$status ( sts    = sts,
	    	    msg    = "GRgraphics.GRgetrang",
	    	    test   = (!(sts & 0x00000001 & (*msg))),
	    	    action = GOTO_VALUE,
	    	    value  = wrapup );
#ifdef TRACE_MATRIX
printf( "Range(%d|%d) :\n\t(%g|%g|%g)\t--> (%g|%g|%g)\n",
	feet_list[IDX_TO_CONT].objid, feet_list[IDX_TO_CONT].osnum,
	range[0], range[1], range[2], range[3], range[4], range[5]);
#endif
	MAinvmx  ( msg, &four, RNGmat, INVmat);
	dblcpy ( &Rng[0], &range[0], 3);	Rng[3] = 1.0;
	MAmulmx  ( msg, &four, &four, &one, INVmat, &Rng[0], &rng[0]);
	dblcpy ( &Rng[0], &range[3], 3);	Rng[3] = 1.0;
	MAmulmx  ( msg, &four, &four, &one, INVmat, &Rng[0], &rng[4]);
#ifdef TRACE_MATRIX
printf( "\t(%g|%g|%g|%g)\t--> (%g|%g|%g|%g)\n",
	rng[0], rng[1], rng[2], rng[3], rng[4], rng[5], rng[6], rng[7]);
printf( "rng[4]=%g, rng[0]=%g, rng[4]-rng[0]=%g, |rng[4]-rng[0]|=%g\n",
	rng[4], rng[0], rng[4]-rng[0], fabs(rng[4] - rng[0]) );
#endif
	x_rng = fabs(rng[4] - rng[0]);
	y_rng = sqrt ( (rng[5] - rng[1]) * (rng[5] - rng[1])
		     + (rng[6] - rng[2]) * (rng[6] - rng[2]) );

	/* Create X range foot */
	sts = exp$create ( exp_value = 1.05 * x_rng,
			   p_exp_id  = &feet_list[IDX_TO_XRNG].objid,
			   osnum     = md_env->md_id.osnum,
			   p_osnum   = &feet_list[IDX_TO_XRNG].osnum );
	as$status ( sts    = sts,
		    msg    = "exp$create(XRNG)",
		    test   = (sts != EXP_S_SUCCESS),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Create Y range foot */
	sts = exp$create ( exp_value = 1.05 * y_rng,
			   p_exp_id  = &feet_list[IDX_TO_YRNG].objid,
			   osnum     = md_env->md_id.osnum,
			   p_osnum   = &feet_list[IDX_TO_YRNG].osnum );
	as$status ( sts    = sts,
		    msg    = "exp$create(YRNG)",
		    test   = (sts != EXP_S_SUCCESS),
		    action = GOTO_VALUE,
		    value  = wrapup );

wrapup:

       	if (sf) {
#ifdef TRACE_MEMORY
printf( "om$dealloc (ptr = sf)\n");
#endif
		om$dealloc (ptr = sf);
		sf = NULL;
	}

       	if (plane_id.objid != NULL_OBJID)
		gr$delete_object ( msg       = &loc_msg,
			   	   md_env    = md_env,
			   	   object_id = &plane_id );
#ifdef TRACE
printf ("\n");
for ( i=0; i<count; i++) {
	om$get_classname ( osnum     = list[i].osnum,
		   	   objid     = list[i].objid,
	   		   classname = name );
        printf( "VLtplObj : template %2d is (%d|%d)\t<%s>\n",
                i, list[i].osnum, list[i].objid, name );
}
printf ("\n");
for ( i=0; i<*fcount; i++) {
	om$get_classname ( osnum     = feet_list[i].osnum,
		   	   objid     = feet_list[i].objid,
	   		   classname = name );
        printf( "\tVLtplObj : foot %2d is (%d|%d)\t<%s>\n",
                i, feet_list[i].osnum, feet_list[i].objid, name );
}

printf ("\n");
printf("\t\t<<< Exit from VLtplObj.ACconstruct_feet\n");
#endif

	return (sts);
}

method VDgetObjDef( long *msg ; VDobjDef *myDef ) {

        long            sts ;   /* OM return code       */

        /*
         * name.
         */
        myDef->info             = VL_I_Obj2DTemplate;
        myDef->type             = 0 ;

        sts     = OM_S_SUCCESS ;
        *msg    = MSSUCC ;

        return sts ;
} /* method VDgetObjdDef */
/*----------------------------------------------------------------------------*/


end implementation VLtplObj;
