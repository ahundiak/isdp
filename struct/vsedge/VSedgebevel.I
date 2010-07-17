/* **************************************************************************
 * I/STRUCT
 *
 * File:        struct/vsedge/VSedgebevel.I
 *
 * Description:
 *      These routines return two intersecting curves to be input into cutting
 *      machines for the purpose of beveling. The curves are the result of 
 *	intersecting a plate's top and bottom surfaces with a curved surface.
 *      
 *      In many situations it is necessary to bevel a plate edge to match the
 *      shape of a bounding surface, for example, where a deck or bulkhead
 *	intersects the curved hull surface.
 *
 *	Sample call to obtain object ids of curves:
 *      status = VSgetBevelCurves(me->edge_attr.obj_id,
 *                                me->edge_attr.mod_env,
 *                                &basecrvId,
 *                                &offsetcrvId );
 *
 * Dependencies:
 *      Form, struct/config/english/forms/VSedgeAttr.frm, is used, in 
 *	conjunction with the command, Place Edge Attributes, to define a base 
 *	plate for the edge attribute macro, and the command, Modify Edge
 *	Attribute, to add one or more plates (curved surfaces) that the base
 *	plate will intersect.
 *
 *	Edge attribute macro was defined to have three hardcoded parents in
 *	this order:
 *		1. surf		plate:base
 *		2. edge_3d	other type
 *		3. box		const.
 *
 * Notes:
 *	1."ref" is a term taken from added plates as listed under "Modify Macro"
 *	2.vs$makeCompCurve was initially used to get a composite curve but it
 *	  didn't work because it had too much of a strict tolerance value.
 *	3.If one plate, bevel curves = GRbcsubbc,
 *	  if more than one plate, bevel curves = GRcompcurve with 2 GRbcsubbc's
 *	4.Tentative snap points won't return a composite curve.
 *
 * Revision History:
 *
 * History:
 *      MM/DD/YY        AUTHOR  DESCRIPTION
 *      10/07/97        ejm     CR179700200: Need ability to place a contin-
 *                              uously changing bevel on plate edge.
 *				Created this file.
 *      01/02/98        ejm     CR179702285: Intersection of plates defaulted
 *				to plate:base surface of reference plate. Now,
 *				bevel curves are placed on surface closest to
 *				center point of plate with edge attr macro.
 *				Added function, VSdetSrfToInt.
 ************************************************************************** */

class implementation Root;

#include <stdio.h>		/* stdout used in fflush of SetProc          */
#include "OMminimum.h"		/* Includes OMtypes.h (OM_K_MAXINT),         */
				/* externs NULL_OBJID (=-1)                  */
#include "OMprimitives.h"       /* omdef om$send                             */
#include "OMerrordef.h"		/* OM error definitions by symbol	     */
#include "igetypedef.h"		/* GR typedefs				     */
#include "igrtypedef.h"		/* IGR types                                 */
#include "gr.h"			/* struct GRid                               */
#include "igr.h"		/* struct IGRbsp_curve                       */
#include "asmacros.h"		/* as$make_source                            */
#include "msdef.h"		/* MSSUCC, MSFAIL                            */
#include "nddef.h"		/* ND_ROOT                                   */
#include "grmacros.h"		/* gr$copy_object                            */
#include "grdpbdef.h"		/* maps gr_get to proper value with defines  */
#include "grdpbmacros.h"	/* gr$get_module_env, requires grdpbdef.h    */
#include "vsgeommacros.h"	/* vs$get_geometry                           */
#include "vsplatedef.h"		/* VS_K_plTopSfPathABS                       */
#include "vsstfnrdef.h"		/* VS_K_stOnTopOfPlate                       */
#include "vsmiscmacros.h"	/* vs$bulk_delete                            */
#include "vsgeommacros.h"	/* vs$makeCompCurve                          */
#include "vsdbgmacros.h"	/* SetProc, __DBGpr macros                   */
#include "bstypes.h"		/* BSrc					     */
#include "bserr.h"  		/* BSSUCC 				     */
#include "bsdistptpt.h"		/* Calculate distance between two points     */
#include "bssfarrev0.h"		/* Calculate four end points of a surface    */
#include "bssfeval.h"		/* Calculate center point of plate           */
#include "bsmdistptsf.h"	/* Calculate minimum distance from pt to srf */
#include "macros.h"		/* min					     */
#include "macro.h"		/* AChdr_noprotect(don't try to make source) */
#include "vdAPImacros.h"	/* vd_$return_foot                           */
#include "VDsupMac.h"		/* VDSUP_MAC_MAX_NUM_TEMP, VDSUP_I_COL       */
#include "VDmem.h"		/* _CALLOC, _FREE                            */
#include "vsstrngproto.h"	/* VSmemdup				     */


/* Display center point (debug) */
#include "igrdef.h"		/* needed by dpmacros.h			     */
#include "dpdef.h" 		/* needed by dpmacros.h			     */
#include "dpstruct.h"		/* struct DPele_header			     */
#include "dpmacros.h"		/* dp$display				     */


#define  VS_K_plEdgePath   "plate:$"  /* Used in NDmacro.ACreturn_foot       */

from  NDnode       import  NDget_objects, NDchg_state;
from  NDmacro      import  ACreturn_foot;
from  ACpretend    import  ACfind_parent;
from  VSstfBeam    import  VSgetPlateSide;
from  VDsupGen     import  VDsupSetTempList, VDsupSetType;
from  ACncpx       import  ACmplace;
from  ci_macro     import  init;

extern    struct   GRid   NULL_GRID;
extern    OMuword  OPP_ACrg_collect_class_id ;
extern    OMuword  OPP_nci_macro_class_id ;



/* Find the plate edges which can be used as trim lines for the bevel curve.  */
/* Plate end points are matched against the edge attribute macros edge to     */
/* identify which two edges are connected to the macro's edge. Each end point */
/* is compared to the macro's edges end points using a distance calculation.  */
/* A distance of nearly zero or zero indicates the two points match.          */

long VSfindPlateEdge( char   footname[],         /* I: foot to look at        */
                      struct GRid plateId,       /* I: id of plate            */
                      struct GRmd_env edgeEnv,   /* I: foot environment       */
                      struct IGRpointset  ptset, /* I: macro's edge_3d endpts */
                      struct GRid *trimId )      /* O: id of plate edge       */
{
  
  long		sts, msg;
  int		i, j, match;
  BSrc		rc;
  IGRdouble	uv[2];
  IGRdouble	endpts[12];
  IGRdouble	distval;
  IGRpoint	endpt, setpt;
  struct GRid	footId;
  struct IGRbsp_surface	*srfBsp=NULL;


  SetProc( VSfindPlateEdge ); Begin


  __DBGpr_str("footname:", footname);

  *trimId=NULL_GRID;

  sts = om$send( msg = message NDmacro.ACreturn_foot(
                                                  &msg,
                                                  footname,
                                                  &footId,
                                                  NULL,
                                                  NULL ),
	    senderid = NULL_OBJID,
            targetid = plateId.objid,
            targetos = plateId.osnum ) ;

  __CheckRC( sts, msg, "NDmacro.ACreturn_foot", wrapup ) ;

  __DBGpr_obj("NDmacro footId:", footId );

    /* Grab Geometry */
    sts = vs$get_geometry(
      msg      = &msg,
      grobjId  = &footId,
      grobjEnv = &edgeEnv,
      geometry = &srfBsp
    );
    __CheckRC(sts,msg,"get_geometry",wrapup);

  uv[0] = 0.0;
  uv[1] = 1.0;

  /* Obtain end points of surface B-spline */
  BSsfarrev0( &rc, srfBsp, 2, uv, 2, uv, endpts );
 
  if( rc != BSSUCC ){
    printf( "BSsfarrev0 error,  FILE %s LINE %d: \n", __FILE__, __LINE__ );
    sts = MSFAIL;  /* BSSUCC = 0 */
    goto wrapup;
  }

/*
#ifdef vsDEBUG
  printf("\n  end points for %s\n\n", footname);
  for(i=0; i<12; i++)
    printf("  points[%d] = %f\n", i, endpts[i]);

  printf("\n  ptset points for edge_3d\n\n");
  for(i=0; i<6; i++)
    printf("  points[%d] = %f\n", i, ptset.points[i]);
#endif
*/

  /* Check this plate edge's end points to see if one matches an edge_3d    */
  /* end point. If so, this edge connects with edge_3d, and can be used as  */
  /* a trim line.                                                           */

  match = 0;
  for(i=0; i<2; i++)
  {
    for(j=0; j<4; j++)
    {
      setpt[0]=ptset.points[3*i];   endpt[0]=endpts[3*j]; 
      setpt[1]=ptset.points[3*i+1]; endpt[1]=endpts[3*j+1]; 
      setpt[2]=ptset.points[3*i+2]; endpt[2]=endpts[3*j+2]; 
      
      distval = BSdistptpt( &rc, setpt, endpt );
      if( rc != BSSUCC ){
        printf( "BSdistptpt error,  FILE %s LINE %d: \n", __FILE__, __LINE__ );
        sts = MSFAIL;  /* BSSUCC = 0 */
        goto wrapup;
      }

/*    __DBGpr_dbl("distance value", distval); */

      if( distval < .05 ) match++;

    } /* j */
  } /* i */

  if( match == 1 ){
    __DBGpr_str("Trim Id:", footname );
    *trimId = footId;
  }


  if( srfBsp )   free( srfBsp);
  /* srfBsp = NULL; */

wrapup:

  End

  return sts;

} /* VSfindPlateEdge */



/* VSplaceCompCurve is an API for creating a composite curve. This code was   */
/* written because a call to vs$makeCompCurve (GRcompcurve.EMmakecomp) had a  */
/* restrictive tolerance and would corrupt the first objid in it's cvList if  */
/* the tolerance was violated.                                                */

/* I: cvList,   Id's of curves to make composite                              */
/* I: cvCount,  count of curves to make composite                             */
/* O: compcvId, Id of composite curve of two or more b-spline curves          */

IGRlong VSplaceCompCurve( struct GRid cvList[], int cvCount, struct GRid *cpcompcvId ) 
{
  IGRlong	sts, msg;
  IGRlong	NumberOfBytes, BytesReceived;
  IGRint	l_suc;
  int		i;

  struct GRid	asId;       /* Source Id */
  struct GRid	cvId[10];   /* Source Ids used by ci_macro.init */
  struct GRid	compId=NULL_GRID;
  struct GRid	compcvId=NULL_GRID;

  struct GRmd_env md_env;



  SetProc(VSplaceCompCurve); Begin



  sts = 1;

  /* Get module environment */

  NumberOfBytes = sizeof(md_env);

  gr$get_module_env(
                msg    = &msg,
                sizbuf = &NumberOfBytes,
                buffer = &md_env,
                nret   = &BytesReceived);

  if( !(msg&1) ){
    printf("\n   gr$get_module_env error\n\n");
    goto quit;
  }

  /* If feet of one macro (edge attribute macro) are to become parents of     */
  /*   another macro (support, or bevel, curve), they need to be "sourced"    */

  for( i=0; i<cvCount; i++)
  {
    as$make_source( go_grid = cvList[i],
		    mod_env = &md_env,
		    as_os   = md_env.md_id.osnum,
		    as_grid = &asId );

    cvId[i] = asId;
  }

  __DBGpr_objlist("curve source id's", cvCount, cvId );

  /* Make the composite curve object */
  compId.osnum = md_env.md_id.osnum;

  sts = om$construct(
    classid = OPP_nci_macro_class_id,
    osnum   =  compId.osnum,
    p_objid = &compId.objid
  );
  if (!(sts&1)) {
    printf("Composite curve object was not created\n");
    goto quit;
  }

  sts = om$send(
    msg  = message ci_macro.init(
      &l_suc,
       0,           /* prop      */
       "crv_comp",  /* cpx name  */
       cvCount,
       cvId,
       NULL,        /* internals */
      &md_env
    ),
    senderid = NULL_OBJID,
    targetid = compId.objid,
    targetos = compId.osnum
  );

  if (!(sts&l_suc&1)) {
    printf("Composite curve macro not placed\n\n");
    if(!(sts&1))  om$report_error( sts = sts );
    goto quit;
  }

  /* footname, "rescrv", from vds/cimacros/wireframe/macros/crv_comp.u        */
  sts = om$send( msg = message NDmacro.ACreturn_foot(
                                                  &msg,
                                                  "rescrv",
                                                  &compcvId,
                                                  NULL,
                                                  NULL ),
	    senderid = NULL_OBJID,
            targetid = compId.objid,
            targetos = compId.osnum ) ;

  __DBGpr_obj("compcvId", compcvId );
  __CheckRC( sts, msg, "NDmacro.ACreturn_foot_compcv", quit ) ;

  /* Copy composite curve id so it won't be deleted when the composite curve  */
  /* macro is deleted.                                                        */

  sts = gr$copy_object ( msg          = &msg,
                         object_id    = &compcvId,
                         md_env       = &md_env,
                         new_env      = &md_env,
                         new_id       = cpcompcvId,
                         display_flag = 0 );

  __DBGpr_obj("cpcompcvId", *cpcompcvId );
  __CheckRC ( sts, msg, "gr$copy_object", quit ) ;



quit:

  if (compId.objid != NULL_OBJID) 
    vs$bulk_delete(theEnv = &md_env, grids = &compId);


  End

  return( sts );

} /* VSplaceCompCurve */



/* VSplaceSuppCurve is an API for creating a support curve. The code was      */
/* obtained from the VDCsupGen class.  In this case, the support curve is a   */
/* "bevel curve".                                                             */

/* I: tempId[4], Id's of support curve parents                                */
/* O: bevelId,   Id of bevel curve (of a plate's base or offset surface)      */

long VSplaceSuppCurve( struct GRid tempId[4], struct GRid *bevelId ) 
{
  IGRlong	sts, msg;
  IGRlong	NumberOfBytes, BytesReceived;
  IGRint	l_suc;

  struct GRid	colId;
  struct GRid	asId;   /* Source Id */
  struct GRid	supId=NULL_GRID;

  struct GRid	tempListId[VDSUP_MAC_MAX_NUM_TEMP];
  IGRlong	tempNum;

  struct GRid	*tl;    /* Template List, allocated below */

  struct GRmd_env md_env;



  SetProc(VSplaceSuppCurve); Begin


  tl = NULL;

  /* Get module environment */

  NumberOfBytes = sizeof(md_env);

  gr$get_module_env(
                msg    = &msg,
                sizbuf = &NumberOfBytes,
                buffer = &md_env,
                nret   = &BytesReceived);

  if( !(msg&1) ){
    printf("\n   gr$get_module_env error\n\n");
    goto quit;
  }

  /* If feet of one macro (edge attribute macro) are to become parents of     */
  /*   another macro (support, or bevel, curve), they need to be "sourced"    */

  as$make_source( go_grid = tempId[0],
		  mod_env = &md_env,
		  as_os   = md_env.md_id.osnum,
		  as_grid = &asId );

  tempId[0] = asId;

  as$make_source( go_grid = tempId[1],
		  mod_env = &md_env,
		  as_os   = md_env.md_id.osnum,
		  as_grid = &asId );

  tempId[1] = asId;

  as$make_source( go_grid = tempId[2],
		  mod_env = &md_env,
		  as_os   = md_env.md_id.osnum,
		  as_grid = &asId );

  tempId[2] = asId;

  as$make_source( go_grid = tempId[3],
		  mod_env = &md_env,
		  as_os   = md_env.md_id.osnum,
		  as_grid = &asId );

  tempId[3] = asId;

  tl = _CALLOC(VDSUP_I_MAX, struct GRid);

  tl[VDSUP_I_SURF]  = tempId[0];  /* plate id, "surface object                */
  tl[VDSUP_I_REF1]  = tempId[1];  /* plate surface id, "base object"          */
  tl[VDSUP_I_TRIM1] = tempId[2];  /* trim1 object, defines one end of sup crv */
  tl[VDSUP_I_TRIM2] = tempId[3];  /* trim2 object, defines other end of curve */

  __DBGpr_obj("tl SURF", tl[VDSUP_I_SURF] );
  __DBGpr_obj("tl REF1", tl[VDSUP_I_REF1] );
  __DBGpr_obj("tl TRIM1", tl[VDSUP_I_TRIM1] );
  __DBGpr_obj("tl TRIM2", tl[VDSUP_I_TRIM2] );

  /* Construct Collection Object */
  colId.osnum = md_env.md_id.osnum;
  sts = om$construct(
    classid = OPP_ACrg_collect_class_id,
    osnum   =  colId.osnum,
    p_objid = &colId.objid
  );

  /* Delete children, if any */
  om$send(
    msg = message NDnode.NDchg_state(ND_DEL_NO_CH, ND_DEL_NO_CH ),
    senderid = NULL_OBJID,
    targetid = colId.objid,
    targetos = colId.osnum
  );

  as$make_source( go_grid = colId,
		  mod_env = &md_env,
		  as_os   = md_env.md_id.osnum,
		  as_grid = &asId );

  colId = asId;

  tl[VDSUP_I_COL] = colId;

  /* Make the support object */
  supId.osnum = md_env.md_id.osnum;

  sts = om$construct(
    classid = OPP_VDsupGen_class_id,
    osnum   =  supId.osnum,
    p_objid = &supId.objid
  );
  if (!(sts&1)) {
    printf("Basic supOff object was not created\n");
    goto quit;
  }

  *bevelId = supId;

  __DBGpr_obj("bevelId", *bevelId);

  /* Set type of support curve to place */
  sts = om$send(
    msg = message VDsupGen.VDsupSetType(VDSUP_MAC_TYPE_CRV),
    senderid = NULL_OBJID,
    targetid = supId.objid,
    targetos = supId.osnum
  );

  /* Generate template List */
  sts = om$send(
    msg = message VDsupGen.VDsupSetTempList( tl,VDSUP_I_MAX,NULL,&tempNum,
                                             tempListId ),
    senderid = NULL_OBJID,
    targetid = supId.objid,
    targetos = supId.osnum
  );

  __DBGpr_objlist("tempListId", tempNum, tempListId);

  sts = om$send(
    msg  = message ACncpx.ACmplace(
      &l_suc,
       AChdr_noprotect, 0,
       VDSUP_MAC_NAME,
       tempNum,
       tempListId,
      &md_env
    ),
    senderid = NULL_OBJID,
    targetid = supId.objid,
    targetos = supId.osnum
  );

  if (!(sts&l_suc&1)) {
    printf("Macro not placed\n\n");
    if(!(sts&1))  om$report_error( sts = sts );
    vs$bulk_delete(theEnv = &md_env, grids = &supId);
    goto quit;
  }


quit:

  _FREE(tl);

  End

  return OM_S_SUCCESS;

} /* VSplaceSuppCurve */


/* Debug function */
void VSverifyObject( struct GRid *object ) 
{
  int		sts;
  IGRchar	classname[OM_K_MAXCLASS_LEN];


  SetProc(VSverifyObject); Begin 


  sts = om$get_classname( objid = object->objid,
			  osnum = object->osnum,
			  classname = classname );

  if( !(sts&1) ) printf("\n   ERROR: om$get_classname\n");

  else printf("\n   Object %d  classname is %s\n", object->objid, classname);


  End
}


/* This routine determines the closest surface of a reference plate to the    */
/* center of the edge attribute macro's base plate surface for the purpose of */
/* intersection.  Display of the center point has been commented out.	      */

long VSdetSrfToInt( basePlsurfId, refPlate, edgeEnv, srfToIntId )
struct GRid	basePlsurfId;/* I: plate base surface			      */
struct GRid	refPlate;    /* I: reference plate to intersect		      */
struct GRmd_env edgeEnv;     /* I: foot environment			      */
struct GRid    *srfToIntId;  /* O: id of surface on ref plate to intersect    */
{
  int		i;		/* for loop counter */
  long		sts = MSSUCC, 
		msg = MSSUCC;
  BSrc		rc  = 0;	/* BSSUCC */
  char		*surfName=NULL; /* top and bottom surface names of a plate    */
  IGRdouble	upar, vpar;     /* B-spline u,v parameters                    */
  IGRdouble	dist, mdist[2]; /* distance returned from BSmdistptsf         */
  IGRpoint	base, ctrpt;   	/* center point of plate           */
  struct GRid   surfId[2];	/* temporary surface storage       */
  struct GRid   refPlsurfId;	/* surface of reference plate      */
  struct IGRbsp_surface	*srfBsp=NULL;     /* B-spline surface geometry */
  struct IGRbsp_surface	*basesrfBsp=NULL; /* B-spline surface geometry */


/*  For displaying center point of base plate * 
  struct DPele_header   ele_header;
  struct IGRpointset    pnt;
  struct IGRdisplay     active_display;
  IGRlong               NumberOfBytes;
  IGRlong               BytesReceived;
*/




  SetProc(VSdetSrfToInt);  Begin


  *srfToIntId = NULL_GRID;

  /* Get geometry of plate's base surface */
  sts = vs$get_geometry(
    msg      = &msg,
    grobjId  = &basePlsurfId,
    grobjEnv = &edgeEnv,
    geometry = &basesrfBsp
  );
  __CheckRC(sts,msg,"get_geometry_1",wrapup);

  /* Get center point of plate surface */
  BSsfeval(basesrfBsp,0.5,0.5,0,&ctrpt,&rc);
  if( rc != BSSUCC ){
    printf( "BSsfeval error,  FILE %s LINE %d: \n", __FILE__, __LINE__ );
    sts = MSFAIL;  /* BSSUCC = 0 */
    goto wrapup;
  }

  __DBGpr_vec("center point", ctrpt);


  /* Display center point of base plate * 


  pnt.num_points = 1;
  pnt.points = ctrpt;

  NumberOfBytes = sizeof( struct IGRdisplay );

  gr$get_active_display( msg = &msg,
                         sizbuf = &NumberOfBytes,
                         buffer = &active_display,
                         nret = &BytesReceived );
  active_display.weight = 2;

  dp$build_dis_buffer( buffer      = &ele_header,
                       type        =  IGRPS,
                       display_att = &active_display,
                       geometry    = (struct IGRpointset *) &pnt  );

  sts = dp$display(msg = &msg,
                 osnum = edgeEnv.md_id.osnum,
                buffer = &ele_header);
*/



  surfName = VS_K_plBotSfPath;  /* Bottom side of reference plate */

  /* Loop twice do get distances to both sides of reference plate */
  for( i=0; i<2; i++ )
  {
    sts = om$send( msg = message NDmacro.ACreturn_foot(
                                                  &msg,
                                                  surfName,
                                                  &refPlsurfId,
                                                  NULL,
                                                  NULL ),
	      senderid = NULL_OBJID,
              targetid = refPlate.objid,
              targetos = refPlate.osnum ) ;

    __DBGpr_obj("refPlsurfId", refPlsurfId );
    __CheckRC( sts, msg, "NDmacro.ACreturn_foot", wrapup ) ;

    surfId[i] = refPlsurfId;

    /* Get geometry of shell plate's surface */
    sts = vs$get_geometry(
      msg      = &msg,
      grobjId  = &refPlsurfId,
      grobjEnv = &edgeEnv,
      geometry = &srfBsp
    );
    __CheckRC(sts,msg,"get_geometry_2",wrapup);

    BSmdistptsf(&rc,srfBsp,ctrpt,&upar,&vpar,base,&dist);
    if( rc != BSSUCC ){
      printf( "BSmdistptsf error,  FILE %s LINE %d: \n", __FILE__, __LINE__ );
      sts = MSFAIL;  /* BSSUCC = 0 */
      goto wrapup;
    }
    mdist[i] = dist;

    surfName = VS_K_plTopSfPath;     /* Top side of reference plate */

  } /* for */

  dist = 0.0;
  /* Obtain minimum distance, set surface to intersect accordingly */
  dist = min(mdist[0], mdist[1]);
  if( dist == mdist[0] )
    *srfToIntId = surfId[0];
  else
    *srfToIntId = surfId[1];

  __DBGpr_dbl("minimum distance", dist);

wrapup:

  End

  return sts;

} /* DetSrfToInt */



/* VSgetBevelCurves calls all other functions in this file. baseGraphicId and */
/* offsetGraphicId are the result of the code in this file: they represent    */
/* the two curves needed to bevel a plate against other plates.               */

long VSgetBevelCurves( edgeId, edgeEnv, baseGraphicId, offsetGraphicId )
struct GRid	edgeId;	           /* I: edge macro id   */
struct GRmd_env edgeEnv;           /* I: edge macro env  */
struct GRid	*baseGraphicId;    /* O: base plate bottom bevel curve id */
struct GRid	*offsetGraphicId;  /* O: base plate top bevel curve id    */
{
  int		parentCnt=0, trimcnt=0, pltcnt=0, nPlate=0;
  long		sts = MSSUCC, msg = MSSUCC;
  char		*surfName=NULL;
  char		footname[21];
  IGRshort	matx_type;
  IGRdouble	matx[16];
  struct GRid   *parentList=NULL;
  struct GRid   *buffer=NULL;
  struct GRid   basePlateId;
  struct GRid	basePlsurfId;
  struct GRid	offsetPlsurfId;
  struct GRid	refPlsurfId;
  struct GRid	macroEdgeId;
  struct GRid	trimId;
  struct GRid	trimLines[2];
  struct GRid	inputIds[4];
  struct GRid	offcvList[10];
  struct GRid	bascvList[10];
  struct GRid	baseBevelId;    /* base plate bottom support macro id */
  struct GRid	offsetBevelId;  /* base plate top support macro id    */
  struct GRid	cpyoffFoot;
  struct GRid	cpybaseFoot;

  struct GRobj_env	offFoot;
  struct GRobj_env	baseFoot;

  struct IGRpointset	ptsetm;

  struct IGRbsp_curve   *crvBsp  = NULL;



  SetProc( VSgetBevelCurves ); Begin


  /* Get plate parents of edge attribute macro */
  sts = om$send ( msg =  message NDnode.NDget_objects(
                                 ND_IN_BUF | ND_ROOT,
                                 (struct GRid *)NULL,
                                 0,
                                 &buffer,
                                 0,
                                 OM_K_MAXINT,
                                 &parentCnt ),
	    senderid  = NULL_OBJID,
            targetid  = edgeId.objid,
            targetos  = edgeId.osnum);

  if (!(sts&1)) {
    goto wrapup;
  }

  parentList = (struct GRid *) VSmemdup( buffer,
                                         parentCnt * sizeof( struct GRid ) ) ;
  _CheckMem( parentList, sts, msg, wrapup );

  __DBGpr_int("number of parents of edge attribute macro", parentCnt);
  __DBGpr_objlist("parents", parentCnt, parentList);
  __DBGpr_com("\n");

  /* The edge attribute macro is attached to the base surface of the plate, */
  /* not to the plate itself! So, the first parent defined in the macro is  */
  /* an ACpretend object; we need the plate object, specifically, and it is */
  /* a parent of the ACpretend object. To find it, we call ACfind_parent.   */

  sts = om$send(  msg = message ACpretend.ACfind_parent
                                (&basePlateId,&matx_type,matx),
             senderid = NULL_OBJID,
             targetid = parentList->objid,
             targetos = parentList->osnum);

  __DBGpr_obj("basePlateId", basePlateId );
  
  /* Get plate's base and offset sides (bottom and top) */

  surfName = VS_K_plTopSfPath;
  __DBGpr_str("TopSf surfName", surfName );

  sts = om$send( msg = message NDmacro.ACreturn_foot(
                                                  &msg,
                                                  surfName,
                                                  &basePlsurfId,
                                                  NULL,
                                                  NULL ),
	    senderid = NULL_OBJID,
            targetid = basePlateId.objid,
            targetos = basePlateId.osnum ) ;

  __DBGpr_obj("basePlsurfId", basePlsurfId );
  __CheckRC( sts, msg, "NDmacro.ACreturn_foot_1", wrapup ) ;


  surfName = VS_K_plBotSfPath;
  __DBGpr_str("BotSf surfName", surfName );

  sts = om$send( msg = message NDmacro.ACreturn_foot(
                                                  &msg,
                                                  surfName,
                                                  &offsetPlsurfId,
                                                  NULL,
                                                  NULL ),
	    senderid = NULL_OBJID,
            targetid = basePlateId.objid,
            targetos = basePlateId.osnum ) ;

  __CheckRC( sts, msg, "NDmacro.ACreturn_foot_2", wrapup ) ;

  __DBGpr_obj("offsetPlsurfId", offsetPlsurfId );

  /* Get plate's edges (on each side of projected edge) to use to trim    */
  /* the bevel curves.                                                    */
  /* Will get geometry of base side of plate edges and compare end points */
  /* to determine which edges to use as trim curves.                      */

  sts = om$send( msg = message NDmacro.ACreturn_foot(
                                                  &msg,
                                                  "edge_3d",
                                                  &macroEdgeId,
                                                  NULL,
                                                  NULL ),
	    senderid = NULL_OBJID,
            targetid = edgeId.objid,
            targetos = edgeId.osnum ) ;

  __CheckRC( sts, msg, "NDmacro.ACreturn_foot_3", wrapup ) ;

  __DBGpr_obj("macroEdgeId", macroEdgeId );


    /* Grab Geometry */
    sts = vs$get_geometry(
      msg      = &msg,
      grobjId  = &macroEdgeId,
      grobjEnv = &edgeEnv,
      geometry = &crvBsp
    );
    __CheckRC(sts,msg,"get_geometry",wrapup);

  ptsetm.num_points = 2;
  ptsetm.points = (IGRdouble *) malloc( ptsetm.num_points * 3 * (sizeof(IGRdouble)) );

  ptsetm.points[0] = crvBsp->poles[0];
  ptsetm.points[1] = crvBsp->poles[1];
  ptsetm.points[2] = crvBsp->poles[2];
  ptsetm.points[3] = crvBsp->poles[crvBsp->num_poles*3-3];
  ptsetm.points[4] = crvBsp->poles[crvBsp->num_poles*3-2];
  ptsetm.points[5] = crvBsp->poles[crvBsp->num_poles*3-1];
  
/*
  printf("\n  end points for edge_3d\n\n");
  for(i=0; i<6; i++)
    printf("  points[%d] = %f\n", i, ptsetm.points[i]);
*/

  strcpy( footname, "plate:$1");

  sts = VSfindPlateEdge( footname, basePlateId, edgeEnv, ptsetm, &trimId  );

  if( !(sts&1) ){
    printf( "VSfindPlateEdge error,  FILE %s LINE %d: \n", __FILE__, __LINE__ );
    goto wrapup;
  }

  if( trimId.objid != NULL_OBJID ){
    trimLines[trimcnt] = trimId;
    trimcnt++;
  }


  strcpy( footname, "plate:$2");

  sts = VSfindPlateEdge( footname, basePlateId, edgeEnv, ptsetm, &trimId  );

  if( !(sts&1) ){
    printf( "VSfindPlateEdge error,  FILE %s LINE %d: \n", __FILE__, __LINE__ );
    goto wrapup;
  }

  if( trimId.objid != NULL_OBJID ){
    trimLines[trimcnt] = trimId;
    trimcnt++;
  }

  strcpy( footname, "plate:$3");

  sts = VSfindPlateEdge( footname, basePlateId, edgeEnv, ptsetm, &trimId  );

  if( !(sts&1) ){
    printf( "VSfindPlateEdge error,  FILE %s LINE %d: \n", __FILE__, __LINE__ );
    goto wrapup;
  }

  if( trimId.objid != NULL_OBJID ){
    trimLines[trimcnt] = trimId;
    trimcnt++;
  }

  strcpy( footname, "plate:$4");

  sts = VSfindPlateEdge( footname, basePlateId, edgeEnv, ptsetm, &trimId  );

  if( !(sts&1) ){
    printf( "VSfindPlateEdge error,  FILE %s LINE %d: \n", __FILE__, __LINE__ );
    goto wrapup;
  }

  if( trimId.objid != NULL_OBJID ){
    trimLines[trimcnt] = trimId;
    trimcnt++;
  }

  /* Subtract macro's three hardcoded parents; remaining number are the      */
  /* number of plates to intersect for bevel curves.                         */

  pltcnt = parentCnt - 3;

  for(nPlate=0; nPlate < pltcnt; nPlate++)
  {
    /* Get closest reference plate surface to intersect */
    sts = VSdetSrfToInt( basePlsurfId, parentList[nPlate+3], edgeEnv, 
                         &refPlsurfId );
    if( !(sts&1) ){
      printf( "VSdetSrfToInt error,  FILE %s LINE %d: \n", __FILE__, __LINE__ );
      goto wrapup;
    }

    /* Inputs to support curve API call */

    inputIds[0] = refPlsurfId;    /* Surface upon which bevel curves fall */
    inputIds[1] = offsetPlsurfId; /* Base object                          */
    inputIds[2] = trimLines[0];   /* Trim1 object                         */
    inputIds[3] = trimLines[1];   /* Trim2 object                         */

    __DBGpr_objlist("Inputs to VSplaceSuppCurve for offsetBevelId", 4, inputIds );

    sts = VSplaceSuppCurve( inputIds, &offsetBevelId );  /* returns macro id */

    __DBGpr_obj("Offset Bevel Support Id:", offsetBevelId );

    /* At this point, we've obtained support curve macro Ids, but, the objec- */
    /* tive is to return graphic ids of curves (lines). So, we need to get    */
    /* the graphic feet of the support macro Ids.                             */

    /* Get graphics foot */
    sts = vd_$return_foot ( msg     = &msg,
                            name    = "foot_00",
                            objId   = &offsetBevelId,
                            objEnv  = &edgeEnv,
                            footId  = &offFoot.obj_id,
                            footEnv = &offFoot.mod_env );
    __CheckRC ( sts, msg, "vd_$return_foot_1", wrapup ) ;

    __DBGpr_obj("Offset Foot Graphic Id:", offFoot.obj_id );


    /* The foot (GRbcsubbc) of owner (VDsupGen) macro is a "rigid" relation- */
    /* ship, therefore, the foot must be copied first before   the support   */
    /* curve macro graphic, no longer necessary, can be deleted - deletion   */
    /* also includes it's feet.						     */

    sts = gr$copy_object ( msg          = &msg,
                           object_id    = &offFoot.obj_id,
                           md_env       = &offFoot.mod_env,
                           new_env      = &edgeEnv,
                           new_id       = &cpyoffFoot,
                           display_flag = 0 );
    __CheckRC ( sts, msg, "gr$copy_object_1", wrapup ) ;

    __DBGpr_obj("Copy Offset Foot Id", cpyoffFoot );

    *offsetGraphicId = cpyoffFoot;      /* If only one plate to intersect   */ 
					/* If more, ignore, build cvList    */

    /* Delete support macro id */
    if (offsetBevelId.objid != NULL_OBJID) {
            gr$delete_object ( msg          = &msg,
                               object_id    = &offsetBevelId,
                               md_env       = &edgeEnv,
                               display_flag = 0 );
    }

    /* List plates if more than one, for input to VSplaceCompCurve */

    if( pltcnt > 1 ) offcvList[nPlate] = cpyoffFoot; 




    inputIds[1] = basePlsurfId;    /* Base object               */

    sts = VSplaceSuppCurve( inputIds, &baseBevelId );

    __DBGpr_obj("Base Bevel Support Id:", baseBevelId );

    sts = vd_$return_foot ( msg     = &msg,
                            name    = "foot_00",
                            objId   = &baseBevelId,
                            objEnv  = &edgeEnv,
                            footId  = &baseFoot.obj_id,
                            footEnv = &baseFoot.mod_env );
    __CheckRC ( sts, msg, "vd_$return_foot_2", wrapup ) ;

    __DBGpr_obj("Base Foot Graphic Id:", baseFoot.obj_id );


    sts = gr$copy_object ( msg          = &msg,
                           object_id    = &baseFoot.obj_id,
                           md_env       = &baseFoot.mod_env,
                           new_env      = &edgeEnv,
                           new_id       = &cpybaseFoot,
                           display_flag = 0 );
    __CheckRC ( sts, msg, "gr$copy_object_2", wrapup ) ;

    __DBGpr_obj("Copy Base Foot Id", cpybaseFoot );

    *baseGraphicId = cpybaseFoot;

    if( pltcnt > 1 ) bascvList[nPlate] = cpybaseFoot;

    /* Delete support macro id */
    if (baseBevelId.objid != NULL_OBJID) {
            gr$delete_object ( msg          = &msg,
                               object_id    = &baseBevelId,
                               md_env       = &edgeEnv,
                               display_flag = 0 );
    }

  } /* for nPlate */



  /* If more than one bevel curve for base and offset, connect them together */

  if( pltcnt > 1 ) 
  {
    __DBGpr_objlist("offcvList input for VSplaceCompCurve", pltcnt, offcvList);


    sts = VSplaceCompCurve( offcvList, pltcnt, offsetGraphicId);

    if( !(sts&1) )
      __CheckRC( sts, 1, "VSplaceCompCurve_1", wrapup ) ;

    __DBGpr_obj("offsetGraphicId", *offsetGraphicId);



    __DBGpr_objlist("bascvList input for makeCompCurve", pltcnt, bascvList);

    sts = VSplaceCompCurve( bascvList, pltcnt, baseGraphicId);

    if( !(sts&msg&1) )
      __CheckRC( sts, msg, "VSplaceCompCurve_2", wrapup ) ;

    __DBGpr_obj("baseGraphicId", *baseGraphicId);

  }

wrapup:

  End

  if( parentList ){
    free( parentList );
    parentList = NULL;
  }

  if( ptsetm.points ){   
    free( ptsetm.points );
    ptsetm.points = NULL;
  }

  if( crvBsp ){   
    free( crvBsp );
    crvBsp = NULL;
  }
 
  if( !(sts&msg&1) ) sts = MSFAIL;

  return sts;

} /* VSgetBevelCurves */



end implementation Root;

