
/*************************************************************************
 * I/LOFT
 *
 * File:        src/tools/VLtoolsFunk.I
 *
 * Description: Miscellaneous Boundary functions.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLtoolsFunk.I,v $
 *      Revision 1.7  2002/06/17 13:42:50  ramarao
 *      Removed the MODEL version check.
 *
 *      Revision 1.6  2001/07/02 18:18:50  ramarao
 *      Fixed TR# 5402.
 *
 *      Revision 1.5  2001/05/18 22:18:52  ramarao
 *      Fixed TR# 5225.
 *
 *      Revision 1.4  2001/03/13 16:42:01  ramarao
 *      Fixed TR# 4818.
 *
 *      Revision 1.3  2001/02/20 01:06:39  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.2  2001/01/16 19:44:20  ramarao
 *      *** empty log message ***
 *
# Revision 1.12  2000/12/06  19:39:22  pinnacle
# Replaced: loft/src/tools/VLtoolsFunk.I for:  by rchennup for Service Pack
#
# Revision 1.11  2000/11/20  14:52:52  pinnacle
# Replaced: loft/src/tools/VLtoolsFunk.I for:  by rchennup for Service Pack
#
# Revision 1.10  2000/10/16  14:32:38  pinnacle
# Replaced: loft/src/tools/VLtoolsFunk.I for:  by rchennup for Service Pack
#
# Revision 1.9  2000/08/31  20:07:32  pinnacle
# Replaced: loft/src/tools/VLtoolsFunk.I for:  by rchennup for Service Pack
#
# Revision 1.6  2000/07/12  15:47:48  pinnacle
# Replaced: loft/src/tools/VLtoolsFunk.I for:  by rchennup for Service Pack
#
# Revision 1.5  2000/07/11  22:02:30  pinnacle
# Replaced: loft/src/tools/VLtoolsFunk.I for:  by rchennup for Service Pack
#
# Revision 1.1  2000/05/14  20:57:12  pinnacle
# Created: loft/src/tools/VLtoolsFunk.I by rchennup for Service Pack
#
# Revision 1.6  2000/04/03  17:29:36  pinnacle
# Replaced: src/tools/VLtoolsFunk.I for:  by impd252 for loft
#
# Revision 1.5  2000/03/02  20:03:56  pinnacle
# Now default rightSide in VLoffCrv() is FALSE;
#
# Revision 1.4  2000/02/24  20:15:48  pinnacle
# Implemented VLcheckNotchOnCompCrv().
#
# Revision 1.3  1999/12/30  12:39:04  pinnacle
# Replaced VLtoolsFunk.I for unwrapTR by jpulapar for loft
#
# Revision 1.2  1999/05/18  20:45:46  pinnacle
# (No comment)
#
# Revision 1.1  1998/04/30  10:32:50  pinnacle
# LOFT 2.5.1
#
# Revision 1.2  1998/04/14  13:55:46  pinnacle
# Replaced: src/tools/VLtoolsFunk.I for:  by smpathak for loft
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *      4/14/98   Sandeep Pathak     Header Creation
 *      4/14/98   Sandeep Pathak     File Modification
 *	2/24/00   Rama Rao	     Implemented VLcheckNotchOnCompCrv().
 *************************************************************************/

class implementation VLabstract;

#include <stdio.h>
#include <math.h>
#include "vlprototype.h"
#include "OMerrordef.h"
#include "godef.h"
#include "bserr.h"
#include "bsvalues.h"
#include "maerr.h"
#include "bs.h"
#include "bsparameters.h"
#include "bsicmpcvoff.h"
#include "EMSmsgdef.h"
#include "msdef.h"
#include "OMindex.h"
#include "OMmacros.h"
#include "EMSssprops.h"
#include "EMSdpb.h"
#include "grmacros.h"
#include "dpezmac.h"
#include "parametric.h"
#include "nddef.h"
#include "graph.h"
#include "asmacros.h"
#include "ndmacros.h"
#include "AS_status.h"
#include "igr.h"
#include "grdpbmacros.h"
#include "vsjoint.h"
#include "vlquerydef.h"
#include "bsmdstptcv.h"
#include "bsdotp.h"
#include "bsorthovec.h"
#include "bscrossp.h"
#include "bsxtractpar.h"
#include "bschgdeppar.h"
#include "bsdistptpt.h"
#include "vsgeommacros.h"
#include "VDmem.h"
#include "vldbgmacros.h"

#define vdsDEBUG 	1
#define vdserrDEBUG 	1

/********************* DEBUG after includes please 	**************
# ifndef DEBUG
# define DEBUG 1
# endif
*********************** end DEBUG		*********************/
static IGRint           nb_old_crvs;
static struct GRid      *old_crvs;

from	EMSsubbs	import  EMproject_curve_onto_surface;
from    EMSsubbs        import  EMproject_curve_along_surface_normals;
from    GRcurve		import  EMcvoffset;
from    ACcpx_defn	import  ACgive_name;
from    GRcurve		import  GRendpts, GRtotlength, GRptextend;
from    ACpretend	import  ACfind_parent;
from    GRlinear	import	GRgetpolyline;

extern GRclassid	OPP_ASindexcv_class_id;
extern GRclassid	OPP_GRcompcurve_class_id;
extern GRclassid	OPP_GR3dpoint_class_id;

extern IGRint		GRabsg_del_by_objid();
extern			GRdisplay_object();
extern 			ASmake_source_from_env();
extern IGRchar		*memcpy();
extern			ASget_as_owner();
extern double		fabs();
extern int              VLgetMacrosAtStep();
extern void             qsort();
extern char 		EX_version[];
extern char 		EX_date[];
extern 			EX_get_version ();

/*===========================================================================*
   Project a curve on a surface along a vector.
 *===========================================================================*/
IGRlong VLcurveOnSfByVec (

struct	GRobj_env	*BaseSurf,    /*I surf on which BaseCrv is projected */
struct  GRobj_env	*BaseCrv,     /*I curve to be projected */
	IGRdouble	*normal,      /*I vector of projection */
struct 	GRvg_construct	*cst,	      /*I construction list */
	IGRboolean	CrvIsProj,    /*I the curve is already lying the*/
				      /*  surface then we just build the*/
				      /*  assoc object*/
	IGRboolean	WantStat,     /*I status wanted when projecting */
	IGRboolean	TrimReq,      /*I Is projection limited to boundaries */
	IGRboolean	display,      /*I TRUE if display wanted */
struct  GRsymbology     *symbology,   /*I To overide the active symbology */
	IGRlong		*NumProjCrvs, /*O the number of resulting curves */
struct  GRid		*feet,	      /*O the resulting curves */
	IGRlong		*msg	      /*O return code MSSUCC or MSFAIL */
                          )
{
IGRlong		sts;
IGRint		i=0;
IGRshort	props;
IGRchar		state_ex, state_ed;
struct  GRlc_info       LocBaseSurf, LocBaseCrv;
OM_S_OBJID              *projectedCurveP;
struct  GRsymbology     symb;

  *msg = MSFAIL;
  projectedCurveP = NULL;
  *NumProjCrvs = 0;

  if( CrvIsProj == FALSE ){
    LocBaseSurf.located_obj = BaseSurf->obj_id;
    LocBaseSurf.module_info = BaseSurf->mod_env;
    LocBaseCrv.located_obj = BaseCrv->obj_id;
    LocBaseCrv.module_info = BaseCrv->mod_env;
    sts = om$send ( msg = message EMSsubbs.EMproject_curve_onto_surface(
                                                &LocBaseCrv,
                                                &LocBaseSurf,
                                                cst,
                                                normal,
                                                WantStat,
                                                TrimReq,
                                                NumProjCrvs,
                                                &projectedCurveP,
                                                msg ),
                    senderid = NULL_OBJID,
                    targetid = BaseSurf->obj_id.objid,
                    targetos = BaseSurf->obj_id.osnum );

  if( !(sts & (*msg) & 1) ){

        sts = om$send(msg=message
                                 EMSsubbs.EMproject_curve_along_surface_normals(
                                                &LocBaseCrv,
                                                &LocBaseSurf,
                                                cst,
                                                WantStat,
                                                TrimReq,
                                                NumProjCrvs,
                                                &projectedCurveP,
                                                msg ),
                    senderid = NULL_OBJID,
                    targetid = BaseSurf->obj_id.objid,
                    targetos = BaseSurf->obj_id.osnum );

  if( !(sts & (*msg) & 1) || (*NumProjCrvs) == 0  )
  {
    printf("ERROR in VLcurveOnSfByVec,EMproject_curve_along_surface_normals\n");
    printf("sts=%d msg=%d\n",sts,*msg);
    om$report_error(sts = sts);
    goto quit;
   }


  }

    sts = om$send(msg = message GRgraphics.GRgetprops(msg,&props),
 		          senderid = NULL_OBJID,
		          targetid = projectedCurveP[0],
      		          targetos = cst->env_info->md_id.osnum);
    if(!(sts&1) || props&GR_RIGID_RELATIONSHIP) goto quit;
  
    feet->objid = projectedCurveP[0];
    feet->osnum = cst->env_info->md_id.osnum;
  
    state_ex = ND_DONT_MVRT|ND_DEL_NO_CH; 
    state_ed = ND_DONT_MVRT;
  
    sts = om$send(	msg	 = message NDnode.NDchg_state 
				 		  ( state_ed, state_ed ),
		          senderid = NULL_OBJID,
		          targetid = feet->objid,
		          targetos = feet->osnum );
  
    if( symbology != NULL )
       sts = om$send( msg      = message GRvg.GRputsymb(msg,symbology),
		         senderid = NULL_OBJID,
                         targetid = feet->objid,
                         targetos = feet->osnum);
  
  
    if( display == TRUE ){
		       gr$display_object ( 
		       object_id = (struct GRid *)feet,
		       mode      = GRbd );
	  }
  
    }
  else{
   sts = om$send(msg = message GRgraphics.GRgetprops(msg,&props),
	         senderid = NULL_OBJID,
	         targetid = BaseCrv->obj_id.objid,
      	         targetos = BaseCrv->obj_id.osnum);
  
   if(!(sts&1) || props&GR_RIGID_RELATIONSHIP) goto quit;
  
   feet->objid = BaseCrv->obj_id.objid;
   feet->osnum = BaseCrv->obj_id.osnum;
  
   state_ex = ND_DONT_MVRT|ND_DEL_NO_CH; 
   state_ed = ND_DONT_MVRT;
  
   sts = om$send(	msg	 = message NDnode.NDchg_state 
				 		  ( state_ed, state_ed ),
		  senderid = NULL_OBJID,
         	  targetid = feet->objid,
		  targetos = feet->osnum );
  
   if( symbology != NULL )
   sts = om$send( msg      = message GRvg.GRputsymb(msg,symbology),
		         senderid = NULL_OBJID,
                         targetid = feet->objid,
                         targetos = feet->osnum);
    else {
      short act_level;

      gr$get_active_level( msg    = msg,
                       sizbuf = &i,
                       buffer = &act_level ) ;
      sts = om$send( msg   = message GRvg.GRgetsymb( msg,&symb),
                         senderid = NULL_OBJID,
                         targetid = BaseSurf->obj_id.objid,
                         targetos = BaseSurf->obj_id.osnum);
       symb.level = act_level;
       sts = om$send( msg      = message GRvg.GRputsymb(msg,&symb),
		         senderid = NULL_OBJID,
                         targetid = feet->objid,
                         targetos = feet->osnum);
    }
  
  
   if( display == TRUE ){
  
	       gr$display_object ( 
	       object_id = (struct GRid *)feet,
	       mode      = GRbd );
   }
  }
  *msg = MSSUCC;
  *NumProjCrvs = 1;
quit:
    gr$display_object ( object_id = (struct GRid *)feet,
			mode      = GRbehe );

  return 1;
}

/* ********************** VLreparameter_off_curve ********************* */
/*  Given an offseted composite curve (offcv obtained by EMcvoffset) and 
    the liste of edges of the original composite curve (before offset 
    edgeList), this function looks if the number of components in offcv 
    is greater than the number of edges of the original composite curve. 
    If so, it merges components added by the method EMcvoffset with the
    offset of the original components to obtain the same number of 
    components in both offcv and edgeListe.  
/* ******************************************************************** */
long VLreparameter_off_curve (

	struct GRobj_env	*offcv,  /*IO: input : Offseted composite curve 
						output: the new offseted 
							composite curve after
							eleminating edges 
							added by EMcvoffset 
							method*/
	IGRint			nbEdge,  /*I: number of components in the
                                              original composite curve */
	struct  EdgeMatch	*edgeList,/*IO : input : list of components 
                                                         in the original 
							 composite curve 
						 ouput : new list of edges */ 
	IGRdouble		*ofval,   /*I : offset values used to obtain
                                                offcv */
	IGRdouble		*info,    /*IO: information about on which
						side we will or we have
   						offst(ed).*/
	struct GRid		*CmpLst,  /*I : a pointer allocated by the
 						caller to the number of
						components of offcv,this
						to do a minimum of malloc */
	struct IGRbsp_curve	**edgeCv, /*I : a pointer allocated by the
 						caller to the number of
						components of offcv, this
                                                to do a minimum of malloc  */
	struct IGRbsp_curve	**CmpCv,  /*I : a pointer allocated by the
 						caller to the number of
						components of offcv, this
                                                to do a minimum of malloc */
	struct	GRvg_construct	*cst,	    /*I construction list */
        IGRboolean	        InOut 
                              )
{
long 			sts,loc_msg,msg;
int			NumCmp,NumRetObj;
int			i,j;
struct GRobj_env 	tmp,StrID;
VSoverlapInfo           ovlInfo;
struct IGRbsp_curve	*cvv;
IGRshort		TypeOfCurve;
struct	GRid		*ConCrvs;
IGRint			NumConCrvs;
struct GRobj_env	two_edges[2],*objList = NULL;


  msg = MSFAIL;
  if (nbEdge <= 0) goto quit;
  ConCrvs = NULL;
  NumConCrvs = 0;
  if (nbEdge > 1) {
    sts = om$send( msg      = message GRowner.GRget_number_components(
                                                              &loc_msg,
                                                              &NumCmp ),
                        senderid = NULL_OBJID,
                        targetid = offcv->obj_id.objid,
                        targetos = offcv->obj_id.osnum );
    if (!(sts&loc_msg&1)) goto quit;
        
    sts = om$send( msg = message GRowner.GRget_components(
                                     &loc_msg,
                                     cst->env_info,
                                     CmpLst,
                                     NumCmp,
                                     &NumRetObj,
                                     (IGRint) 0,
                                     OM_K_MAXINT ),
                      senderid = NULL_OBJID,
                      targetid = offcv->obj_id.objid,
                      targetos = offcv->obj_id.osnum );
    if (!(sts&loc_msg&1)) goto quit;
  }
  else {
    NumRetObj = 1;
    CmpLst[0] = offcv->obj_id;
  }

  if (nbEdge < NumRetObj) {  // EMcvOffset has added objects in offcv.
    for (i=0;i<NumRetObj;i++)
    {
      StrID.obj_id = CmpLst[i];
      StrID.mod_env = *(cst->env_info);
      sts = VLgetGeometry( &StrID, (IGRboolean)FALSE,
                           NULL_OBJID, (IGRchar **)&CmpCv[i], &loc_msg );
      if (!(sts&loc_msg&1)) goto quit;
    }
 
    /* in the following loop, we will offset each original curve and look
       if it matches with an component of offcv. The components of offcv
       which don't match are those added by EMcvoffset */

    for (i=0;i<nbEdge;i++)
    {
      if (ofval[i] >= 0.00001 || ofval[i] <= -0.00001) {
      tmp.obj_id  = edgeList[i].EdgeId;
      tmp.mod_env = *(cst->env_info); 
      sts = VLoffset_Cv( &tmp, cst, InOut, 
	   	         (IGRdouble *)NULL, 1, &(ofval[i]), info, 
                         (IGRboolean)FALSE, &StrID, NULL, NULL, &loc_msg);
      if (!(sts&loc_msg&1)) goto quit;
      }
      else {
        StrID.obj_id = edgeList[i].EdgeId;
        StrID.mod_env = *(cst->env_info);
      }

      sts = om$send(msg = message GRvg.GRgenabsg(&loc_msg,
                                        &(StrID.mod_env.md_env.matrix_type),
                                        StrID.mod_env.md_env.matrix,
                                        (IGRchar **)&cvv),
                  senderid = NULL_OBJID,
                  targetid = StrID.obj_id.objid,
                  targetos = StrID.obj_id.osnum );
      if (!(sts&loc_msg&1)) goto quit;
    
      for (j=0;j<NumRetObj;j++)
      {
        if (CmpLst[j].objid == NULL_OBJID) continue;
                      // test matching between CmpCv[j] and cvv
        sts = VSdoCurvesOverlap(&loc_msg,CmpCv[j],cvv,&ovlInfo);
        if (!(sts&loc_msg&1)) goto quit;
        if (
            ovlInfo.code == VS_K_TOTAL_MATCH || 
            ovlInfo.code == VS_K_1_COVERS_0  ||
            ovlInfo.code == VS_K_0_COVERS_1 
           )
        {
     	  sts = om$send( msg = message GRgraphics.GRdelete(&loc_msg,
                                                         cst->env_info),
             	     targetid = edgeList[i].EdgeId.objid,
		     targetos = edgeList[i].EdgeId.osnum,
		     senderid = NULL_OBJID ) ;
     	  sts = om$send( msg = message GRgraphics.GRdelete(&loc_msg,
                                                         cst->env_info),
             	     targetid = StrID.obj_id.objid,
		     targetos = StrID.obj_id.osnum,
		     senderid = NULL_OBJID ) ;

          edgeList[i].EdgeId = CmpLst[j];
          CmpLst[j].objid = NULL_OBJID;
          edgeCv[i] = CmpCv[j];
          break;
        }
      }
    }
    /* now, we will merge the founded added curves in offcv with other
       curves with has matched */
    for (i=0;i<NumRetObj;i++)
    {
      if (CmpLst[i].objid == NULL_OBJID) continue;
      for (j=0;j<nbEdge;j++)
      {
        if (edgeCv[j] != NULL)  {
               /* test angle between this two curves to know if
                  we will merge it. */
          sts = VLtest_angle(edgeCv[j],CmpCv[i],(cos(M_PI/18.0)));
          if (sts == -1) goto quit;
          if (sts == 1) {
            two_edges[0].obj_id = edgeList[j].EdgeId;
            two_edges[1].obj_id = CmpLst[i];
            two_edges[0].mod_env = *(cst->env_info);
            two_edges[1].mod_env = *(cst->env_info);
	    TypeOfCurve = 1;
               // merge the two curves
	    SortAndBuildCrv( two_edges, 2, TypeOfCurve, cst, 
	     		     &ConCrvs, &NumConCrvs, &loc_msg );
	    if( NumConCrvs == 0 ) {
	     	printf( "SortAndBuildCrv Failed\n");
		goto quit;
	    }
	    else if( NumConCrvs == 1 ){
		if( ConCrvs[0].objid == NULL_OBJID ){
	     	   printf( "SortAndBuildCrv Failed\n");
		   goto quit;
		}
		edgeList[j].EdgeId = ConCrvs[0];
                if (ConCrvs) {
                  om$dealloc( ptr = ConCrvs );ConCrvs = NULL; NumConCrvs=0;
                }
	    }
	    else{
		goto quit;
	    }
            break;
          }
        }
        else goto quit;
      }
      if (j==nbEdge) {
        goto quit;
      }
    }

    if( NumRetObj > 1 ){  // make a composite curve
        objList = (struct GRobj_env *) malloc(nbEdge*sizeof(struct GRobj_env));
        for (i=0;i<nbEdge;i++) {
          objList[i].obj_id = edgeList[i].EdgeId;
          objList[i].mod_env = *(cst->env_info);
        }
        sts = om$send( msg = message GRowner.GRdrop(
                                   &loc_msg,
                                   cst->env_info),
                         senderid = NULL_OBJID,
                         targetid = offcv->obj_id.objid,
                         targetos = offcv->obj_id.osnum );
        if( !(sts&loc_msg&1) ){
                printf("GRowner.GRdrop: Failde\n");
                goto quit;
        }
     	sts = om$send( msg = message GRgraphics.GRdelete(&loc_msg,
                                                           cst->env_info),
                         senderid = NULL_OBJID,
                         targetid = offcv->obj_id.objid,
                         targetos = offcv->obj_id.osnum );
	cst->geometry = NULL;
	offcv->obj_id.objid = NULL_OBJID;
	offcv->obj_id.osnum = cst->env_info->md_id.osnum;
	TypeOfCurve = 3;
	SortAndBuildCrv( objList, nbEdge, TypeOfCurve, cst, 
	     		 &ConCrvs, &NumConCrvs, &loc_msg );
 
	if( NumConCrvs == 0 ) {
	     	printf( "SortAndBuildCrv Failed\n");
		goto quit;
	}
	else if( NumConCrvs == 1 ){
		if( ConCrvs[0].objid == NULL_OBJID ){
	     	   printf( "SortAndBuildCrv Failed\n");
		   goto quit;
		}
		offcv->obj_id = ConCrvs[0];
		offcv->mod_env = *(cst->env_info); 
                if (ConCrvs) {
                  om$dealloc( ptr = ConCrvs );ConCrvs = NULL; NumConCrvs=0;
                }
	}
	else{
		goto quit;
	}
     }
  }
  else {
    for (j=0;j<NumRetObj; j++) 
      edgeList[j].EdgeId  = CmpLst[j];
  }
  msg = MSSUCC;
quit :
  if (objList) {free(objList);objList = NULL;}
  if (ConCrvs) {
    om$dealloc( ptr = ConCrvs );ConCrvs = NULL; NumConCrvs=0;
  }
  for (i=0;i<NumRetObj;i++)
  {
    om$dealloc( ptr = CmpCv[i] ); CmpCv[i] = NULL;
  }
  return msg;
}
struct  PntWork {
        IGRboolean              Idx;
        IGRdouble               Dist;
};

IGRint VLsortEWByDist ( a, b)

                struct  PntWork       *a, *b;

{
        return ((a->Dist == b->Dist) ? 0: (a->Dist < b->Dist)  ? -1 : 1);
}

IGRlong VLgetRightsideFromCompCrv(
IGRlong			*msg,	    /* O: Return Code */
struct  GRobj_env       CrvToOf,    /* I: Composite curve to offset */
struct	IGRbsp_curve	*FirstCrv,  /* I: First Compnent curve */
IGRdouble		*normal,    /* I: Plane Normal */
struct  GRvg_construct  *cst,       /* I: construction list */
IGRboolean		*rightSide  /* O: right_side ( TRUE or FALSE ) */ )
{
   BSrc   		rc;
   IGRint		i, j, action=1, nb_inter=0, pt1_ind=0, pt2_ind=0;
   IGRlong 		sts = OM_S_SUCCESS, loc_sts, loc_msg;
   IGRdouble		ptDev[6], crossp[3], second_pt[3], maxDist=0.0, 
			*pntInt=NULL, *OrdPts=NULL, matVec[3], dotp;
   struct GRid 		infLine, *pntsId=NULL;
   struct GRlc_info	curve1Info, curve2Info;
   struct IGRpolyline	point;
   struct  PntWork      *PW=NULL;

   SetProc( VLgetRightsideFromCompCrv ); Begin

   __DBGpr_obj("Curve to find Right Side ", CrvToOf.obj_id );
   // Evaluate the point and derivative of the curve at 0.5
   BScveval( FirstCrv, 0.5, 1, ptDev, &rc );
   __DBGpr_vec("First Point: Point at 0.5 parameter ", &ptDev[0] );
   __DBGpr_vec("Derivative at 0.5 parameter ", &ptDev[3] );
   __DBGpr_vec("Plane Normal ", normal );

   // Evaluate the cross product of the above derivative and plane normal
   BScrossp( &rc, &ptDev[3], normal, crossp );
   __DBGpr_vec("Cross Product of derivative and normal ", crossp );

   // Detemine the second point to create infinite line */
   for( i=0; i<3; ++i )  second_pt[i] = ptDev[i] + crossp[i] * 100;
   __DBGpr_vec("Second Point: 100 units length ", second_pt );

   // Construct an infinite line segment
   VSmake_infinite_line( msg, ptDev, second_pt, cst, &infLine ) ;
   __DBGpr_obj("Infinite Line Created between first and second pts ", infLine );

   // Intersect the infinite line with the composite curve.
   curve1Info.located_obj   = CrvToOf.obj_id ;
   curve1Info.module_info   = CrvToOf.mod_env ;
   curve2Info.located_obj   = infLine;
   curve2Info.module_info   = *(cst->env_info);

   sts = EMintersect_two_element( &curve1Info,
                                  &curve2Info,
                                  TRUE,
                                  cst,
                                  &nb_inter,
                                  &pntsId,
                                  msg ) ;
   __DBGpr_int("Number od intersection points ", nb_inter );
   if( nb_inter < 1 ) {
        if( *msg == EMS_E_NoDynamicMemory ) {
                   sts = OM_E_NODYNMEM ;
        } else {
                   *msg = EMS_W_NoSolution ;
                   sts = OM_W_ABORT ;
        }
        goto wrapup ;
   }

   // Allocate memory for resulting points
   pntInt = (IGRdouble *)om$malloc( size =  (3*nb_inter) * sizeof(IGRdouble));
   OrdPts = (IGRdouble *)om$malloc( size =  (3*nb_inter) * sizeof(IGRdouble));

   // For each intersection point evaluate the coordinates
   for( i=0; i<nb_inter; ++i )
   {
       point.points    = &pntInt[3*i];
       point.num_points= 1 ;
       sts = om$send( msg      = message GRlinear.GRgetpolyline(
                                             msg,
                                             &cst->env_info->md_env.matrix_type,
                                             cst->env_info->md_env.matrix,
                                             &action,
                                             &point ),
                 senderid = pntsId[i].objid,
                 targetid = pntsId[i].objid,
                 targetos = pntsId[i].osnum ) ;
       if( !(sts&1&(*msg)) ) goto wrapup;
	__DBGpr_vec("Intersection Point ", &pntInt[3*i] );
   }

   // From the list, evaluate the most distant points
   maxDist = 0.0;
   for( i=0; i<nb_inter; ++i )
   {
       for( j=i+1; j<nb_inter; ++j )
       {
	   IGRdouble	dist;
	   dist = BSdistptpt( &rc, &pntInt[3*i], &pntInt[3*j] );
	   if( dist > maxDist )
	   {
	       maxDist = dist;
	       pt1_ind = i;
	       pt2_ind = j;
	   }
        }
   }
   __DBGpr_vec("Most Distant First Point ", &pntInt[3*pt1_ind] );
   __DBGpr_vec("Most Distant Second Point ", &pntInt[3*pt2_ind] );

   /* Allocate and fill PntWork structure */
   PW = om$calloc ( num = nb_inter, structure = struct PntWork );

   j = 0;

   // Store the indices and distances for each point from the lowest point
   for( i=0; i<nb_inter; ++i )
   {
	PW[j].Idx = i;
	PW[j++].Dist = BSdistptpt( &rc, &pntInt[3*pt1_ind], &pntInt[3*i] );
   }

   // Sort the points in an order based on the above distances
   qsort ( PW, nb_inter, sizeof(struct PntWork), (int (*)())VLsortEWByDist);

   // Store the ordered points in another array in proper sequence
   for( i=0; i<nb_inter; ++i )
   {
	for( j=0; j<3; ++j )  OrdPts[3*i+j] = pntInt[3*(PW[i].Idx)+j];
	__DBGpr_vec("Ordered Point ", &OrdPts[3*i] );
   }

   // Check the closest point
   for( i=0; i<nb_inter; ++i )
   {
      if (
      	((OrdPts[3*i+0] - ptDev[0] <= 0.0001) && (OrdPts[3*i+0] - ptDev[0] >= -0.0001)) &&
      	((OrdPts[3*i+1] - ptDev[1] <= 0.0001) && (OrdPts[3*i+1] - ptDev[1] >= -0.0001)) &&
      	((OrdPts[3*i+2] - ptDev[2] <= 0.0001) && (OrdPts[3*i+2] - ptDev[2] >= -0.0001))
      ) break;
   }
   __DBGpr_int("Closest Point Index ", i );
   __DBGpr_vec("Closest Point ", &OrdPts[3*i] );

   if( i%2 )
   {
      /* If the index is odd, material direction vector is
	 from Odd to the PREVIOUS Even index */
      for(j=0;j<3;j++) matVec[j] = OrdPts[3*(i-1)+j] - ptDev[j];
      __DBGpr_com("Index is Even ");
   }
   else
   {
      /* If the index is even, material direction vector is 
	 from Even to the NEXT Odd index. */
      for(j=0;j<3;j++) matVec[j] = OrdPts[3*(i+1)+j] - ptDev[j];
      __DBGpr_com("Index is Odd ");
   }

   __DBGpr_vec("Material Direction Vector ", matVec );
   dotp = BSdotp( &rc, crossp, matVec );
   __DBGpr_dbl("Cross Product of matVec and crossp ", dotp );

   if( dotp < 0 )  *rightSide = FALSE;
   else		   *rightSide = TRUE;

   __DBGpr_int("Right Side ", *rightSide );
   __DBGpr_com("VLgetRightsideFromCompCrv Success");
   
wrapup:
   if( !(sts&1&(*msg)) )  __DBGpr_com("VLgetRightsideFromCompCrv Failed");
   // Delete the infinite line segment  
   loc_sts = om$send( msg = message GRgraphics.GRdelete( &loc_msg,
                                                     cst->env_info),
		 senderid = NULL_OBJID,
                 targetid = infLine.objid,
                 targetos = infLine.osnum  );

   // Delete all the intersection point objects.
   for( i=0; i<nb_inter; ++i )
   {
        loc_sts = om$send( msg = message GRgraphics.GRdelete( &loc_msg,
                                                          cst->env_info),
                 senderid = NULL_OBJID,
                 targetid = pntsId[i].objid,
                 targetos = pntsId[i].osnum  );
   }

   // Free the memory for all arrays
   if( pntInt ) { om$dealloc( ptr = pntInt );  pntInt  = NULL;}
   if( OrdPts ) { om$dealloc( ptr = OrdPts );  OrdPts  = NULL;}
   if( pntsId ) { om$dealloc( ptr = pntsId );  pntsId  = NULL;}
   if( PW     ) { om$dealloc( ptr = PW     );  PW      = NULL;}
   End
   return sts;
}

static IGRlong VLfindCrvsToMerge( IGRlong		*msg,
				  IGRint		NumCmp,
				  struct GRid		*CmpLst,
				  struct GRmd_env	*CmpEnv,
				  struct GRid		*line1,
				  struct GRid		*line2,
				  struct GRid		*notch,
				  struct GRvg_construct *cst,
				  struct GRid		*out_crv1,
				  struct GRid		*out_crv2	 )
{
BSrc			rc;
IGRlong			sts;
IGRint			i;
IGRdouble		offset;
IGRpoint		spt, ept, COG, pt1, pt2;
IGRvector		vec1, vec2, direction;
struct GRid		lineToOff;

   SetProc( VLfindCrvsToMerge ); Begin

   COG[0] = COG[1] = COG[2] = 0.0;

   for (i=0;i<NumCmp;i++)
   {
      sts = VLendpts( msg, &CmpLst[i], CmpEnv, spt, ept );
      COG[0] += spt[0] + ept[0];
      COG[1] += spt[1] + ept[1];
      COG[2] += spt[2] + ept[2];
   }
   COG[0] = COG[0]/(double)(2*NumCmp);  
   COG[1] = COG[1]/(double)(2*NumCmp);  
   COG[2] = COG[2]/(double)(2*NumCmp);

   __DBGpr_vec("COG ", COG );

   sts = VLendpts( msg, notch, CmpEnv, pt1, pt2 );
   __CheckRC( sts, *msg, "VLendpts", wrapup );
   __DBGpr_vec("Notch Start Point ", pt1 );
   __DBGpr_vec("Notch End Point ", pt2 );

   offset = BSdistptpt( &rc, pt1, pt2 );

   VLvector( msg, pt1, pt2, 1.0, 1.0, TRUE, vec1 );
   VLvector( msg, pt1, COG, 1.0, 1.0, TRUE, vec2 );

   __DBGpr_vec("Vector1 ", vec1 );
   __DBGpr_vec("Vector2 ", vec2 );

   if( BSdotp( &rc, vec1, vec2 ) < 0.0 )
   {
	__DBGpr_com("Offsetting First Line" );
	lineToOff = *line1;
	dblcpy( direction, vec1, 3 ); 
	*out_crv1 = *line2;
   }
   else
   {
	__DBGpr_com("Offsetting Second Line" );
	lineToOff = *line2;
	for( i=0; i<3; ++i )  direction[i] = -1 * vec1[i] ;
	*out_crv1 = *line1;
   } 

   sts = vs$offsetCurveAlongDirectionVector( msg	= msg,
					     cvId	= &lineToOff,
					     cvEnv	= CmpEnv,
					     offset	= offset,
					     direction	= direction,
					     cst	= cst,
					     offCvId 	= out_crv2 );

wrapup:
   End
   return sts;
}

IGRlong VLcheckNotchOnCompCrv( 	IGRlong			*msg,
				IGRint		   	NumCmp,
				struct GRid	   	*CmpLst,
				struct GRmd_env		*CmpEnv,
				IGRdouble	   	**offDist,	
				IGRboolean	   	*haveNotch,
				struct GRvg_construct   *cst,
			    	struct GRobj_env   	*newCmpCv )		
{
BSrc			rc;
IGRlong 		sts, rotten_one;
IGRint  		i, j, k, ind, prev_ind, next_ind, temp_int, 
			NumConCrvs=0;
IGRdouble		length, bas_tol, mdist, par, *loc_offDist=NULL;
IGRshort		*Orie=NULL;
IGRboolean  		adj, clo;
IGRchar			name[40];
IGRpoint		pt[2], base, new_end;
OM_S_CHANSELECT         to_comps;
struct IGRbsp_curve	*crv_geom=NULL;
struct GRlc_info   	entLC[2];
struct GRid		*ConCrvs=NULL, *CrvObj=NULL, compid;
struct GRobj_env	inp_edges[2], out_edges[2], MergeCrv, *inp_list=NULL,
			*out_list=NULL;

    SetProc( VLcheckNotchOnCompCrv ); Begin

    if( NumCmp<2 || !CmpLst || !CmpEnv || !offDist ) return OM_E_INVARG;

    sts  = MSSUCC;
    *msg = MSSUCC;

    inp_edges[1].obj_id.objid = NULL_OBJID;

    if( haveNotch ) *haveNotch = FALSE;

    __DBGpr_int( "Input Curves ", NumCmp );
    __DBGpr_objlist( "Input Curves ", NumCmp, CmpLst );

    for(i=0; i<NumCmp; i++)
    {
	if( (i-1)<0 ) 		prev_ind = NumCmp - 1;
	else			prev_ind = i-1;	

	if( (i+1)==NumCmp )	next_ind = 0;
	else			next_ind = i+1;

	length = 0.0;

	__DBGpr_int( "Checking ", i );
        sts = om$send(msg= message GRcurve.GRtotlength(
                                        msg,
                                        &cst->env_info->md_env.matrix_type,
                                        cst->env_info->md_env.matrix,
                                        &length ),
                        senderid = NULL_OBJID,
                        targetid = CmpLst[i].objid,
                        targetos = CmpLst[i].osnum );
	__CheckRC( sts, *msg, "Getting Length of Curve", wrapup ) ;
     
	__DBGpr_dbl( "Length ", length );
	__DBGpr_dbl( "Previous Curve's Offset Value ", (*offDist)[prev_ind] );
	__DBGpr_dbl( "Next Curve's Offset Value ", (*offDist)[next_ind] );

	if( ( length > 0.1 ) &&
	    ( length < (((*offDist)[prev_ind]+(*offDist)[next_ind])/2.0) ) && 
		(( (*offDist)[i] > 0.001 ) ||
	    ( (*offDist)[prev_ind] > 0.001 && (*offDist)[next_ind] > 0.001 )))
	{
	   __DBGpr_com( "This is a Notch");
	   break;
	}
	else
	{
	   __DBGpr_com( "This is NOT a Notch");
	} 
    }

    if( i == NumCmp )
    {
	__DBGpr_com( "There is NO Notch in the Composite Curve");
	if( haveNotch ) *haveNotch = FALSE;
	goto wrapup;
    }
 
    if( haveNotch ) *haveNotch = TRUE; 
    if( !newCmpCv ) goto wrapup;

    Orie  = _MALLOC( NumCmp, IGRshort );

    MergeCrv.mod_env  = *(cst->env_info);
    newCmpCv->mod_env = *(cst->env_info);
    __DBGpr_int( "Trying to remove the notch ", i ); 

    sts = VLfindCrvsToMerge( msg, NumCmp, CmpLst, CmpEnv, &CmpLst[prev_ind],
		&CmpLst[next_ind], &CmpLst[i], cst, &inp_edges[0].obj_id,
		&inp_edges[1].obj_id );

    inp_edges[0].mod_env = *CmpEnv;
    inp_edges[1].mod_env = *CmpEnv;

    BSxtractpar ( &rc, BSTOLBASIS, &bas_tol);

    __DBGpr_com( "Calling OrderCrv"); 
    sts = OrderCrv( inp_edges, 2, 0.001, bas_tol,
	            out_edges, Orie, &adj, &clo, msg );
    if ((*msg) == BSSUCC)   *msg = MSSUCC;
    else                    *msg = MSFAIL;
    if( !(sts&1&(*msg) ) )
    {
	*haveNotch = FALSE;
	goto wrapup;
    }

    __DBGpr_com( "Calling BuildCrv");
    sts = BuildCrv( 0, out_edges, 2, Orie, adj, clo, entLC, 
		    cst, &MergeCrv.obj_id, msg );
    if ((*msg) == BSSUCC)   *msg = MSSUCC;
    else                    *msg = MSFAIL;
    if( !(sts&1&(*msg) ))
    {
        *haveNotch = FALSE;
        goto wrapup;
    }
    __DBGpr_obj( "Output Curve ", MergeCrv.obj_id );

    VLendpts( msg, &MergeCrv.obj_id, cst->env_info, pt[0], pt[1] );

    for( k=0; k<2; ++k )
    {
       _FREE( crv_geom );
       if( k==0 )
       {
          temp_int = prev_ind - 1 ;
          if( temp_int < 0 ) temp_int = NumCmp-1 ;
       }
       else
       {
	  temp_int = next_ind + 1 ;
	  if( temp_int > NumCmp-1 ) temp_int = 0 ;
       }
       __DBGpr_obj("Checking For Extension ", CmpLst[temp_int] );
       sts = vs$get_geometry (  msg	= msg,
			        grobjId	= &CmpLst[temp_int],
			        grobjEnv= CmpEnv,
			        geometry= &crv_geom );
       for( j=0; j<2; ++j )
       {
          BSmdstptcv( crv_geom, pt[j], &par, base, &mdist, &rc );
	  __DBGpr_dbl( "Minimum Distance ", mdist );

          if( mdist > 0.5 && mdist < 10.0 )
          {
doit_again:
	      __DBGpr_int("Extending the Curve", temp_int );
	      sts = om$send(msg = message GRcurve.GRptextend(
				msg, cst->env_info, base,  pt[j], new_end ),
                      senderid = NULL_OBJID,
                      targetid = CmpLst[temp_int].objid,
                      targetos = CmpLst[temp_int].osnum );
    	      if( !(sts&1&(*msg) ) )
    	      {
        	*haveNotch = FALSE;
        	goto wrapup;
    	      }

	      sts = om$send(msg = message GRcurve.GRptextend(
				msg, cst->env_info, pt[j], new_end, base ),
			senderid = NULL_OBJID,
                        targetid = MergeCrv.obj_id.objid,
			targetos = MergeCrv.obj_id.osnum );
              if( !(sts&1&(*msg) ) )
              {
                *haveNotch = FALSE;
                goto wrapup;
              }

              if( ( BSdistptpt( &rc, pt[j], new_end ) - bas_tol ) > 1e-6 )
              {
                __DBGpr_com("Need to extend again" );
                VLendpts( msg, &MergeCrv.obj_id, cst->env_info, pt[0], pt[1] );
                dblcpy( base, new_end,3 );
                goto doit_again;
              }
          }
       }
    }

    temp_int = 0;
    CrvObj      = _MALLOC( NumCmp-2, struct GRid );
    loc_offDist = _MALLOC( NumCmp,   IGRdouble	      );
    for( ind=0; ind<NumCmp; ++ind )   loc_offDist[ind] = (*offDist)[ind];

    for( ind=0; ind<NumCmp; ++ind )
    {
	if( ind == prev_ind || ind == next_ind ) continue;
	if( ind == i )
	{
	   IGRdouble	off_apply=0.0;

	   if( ( loc_offDist[prev_ind] > loc_offDist[i] ) &&
	       ( loc_offDist[prev_ind] > loc_offDist[next_ind] ) )
	   		off_apply = loc_offDist[prev_ind];
	   else if( ( loc_offDist[i] > loc_offDist[prev_ind] ) &&
		    ( loc_offDist[i] > loc_offDist[next_ind] ) )
			off_apply = loc_offDist[i];
	   else		off_apply = loc_offDist[next_ind];

	   CrvObj[temp_int] = MergeCrv.obj_id;
	   __DBGpr_obj( "NewCurve in the List ", MergeCrv.obj_id );
	   (*offDist)[temp_int] = off_apply ;
	}
	else
	{
           sts = om$send(msg = message GRgraphics.GRcopy(
                                        msg, CmpEnv, cst->env_info,
                                        &CrvObj[temp_int].objid ),
                                senderid = NULL_OBJID,
                                targetid = CmpLst[ind].objid,
                                targetos = CmpLst[ind].osnum );
	   __CheckRC( sts, *msg, "GRgraphics.GRcopy", wrapup ) ;
           CrvObj[temp_int].osnum  = cst->env_info->md_id.osnum;
	   __DBGpr_obj( "New List ", CrvObj[temp_int] );
	   (*offDist)[temp_int] = loc_offDist[ind];
	}
	temp_int++;
    }

    inp_list      = _MALLOC( temp_int, struct GRobj_env );
    out_list      = _MALLOC( temp_int, struct GRobj_env );

    for( ind=0; ind<temp_int; ++ind )
    {
       inp_list[ind].obj_id   = CrvObj[ind];
       inp_list[ind].mod_env  = *(cst->env_info);
    }

    sts = OrderCrv( inp_list, temp_int, 0.01, bas_tol,
                    out_list, Orie, &adj, &clo, msg );
    if ((*msg) == BSSUCC)   *msg = MSSUCC;
    else                    *msg = MSFAIL;
    if( !(sts&1&(*msg) ) )
    {
        *haveNotch = FALSE;
        goto wrapup;
    }

    to_comps.type = OM_e_name;
    to_comps.u_sel.name = "GRcmpowner.to_components";

    for( i=0; i<temp_int; ++i )
    {
       for( j=0; j<temp_int; ++j )
       {
          if(   out_list[i].obj_id.objid == CrvObj[j].objid  &&
                out_list[i].obj_id.osnum == CrvObj[j].osnum  )      break;
       }
       if( j == temp_int ) goto wrapup;
       loc_offDist[i] = (*offDist)[j];
    }

    for( i=0; i<temp_int; ++i )    
    {
	(*offDist)[i] = loc_offDist[i] ;
	CrvObj[i] = out_list[i].obj_id ;
    }

    newCmpCv->obj_id.osnum =  cst->env_info->md_id.osnum;

    __DBGpr_int( "Calling vs$makeCompCurve", temp_int );
    sts = vs$makeCompCurve(  msg        = msg,
                             cvList     = CrvObj,
                             cvCount    = temp_int,
                             cvEnv      = cst->env_info,
                             compEnv    = cst->env_info,
                             compCv     = &newCmpCv->obj_id );
    if( !(sts&1&(*msg) ) )
    {
        *haveNotch = FALSE;
        goto wrapup;
    }
    __DBGpr_obj( "Final Composite Curve ", newCmpCv->obj_id );

wrapup:
    if( inp_edges[1].obj_id.objid != NULL_OBJID )
    {
      om$send(  msg = message GRgraphics.GRdelete
                                             ( msg, cst->env_info ),
                               senderid = NULL_OBJID,
                               targetid = inp_edges[1].obj_id.objid,
                               targetos = inp_edges[1].obj_id.osnum);
    }
    _FREE( CrvObj      );
    _FREE( ConCrvs     );
    _FREE( loc_offDist );
    _FREE( crv_geom    );
    _FREE( inp_list    );
    _FREE( out_list    );
    _FREE( Orie        );
    End
    return sts;
}


/*===========================================================================*
  This function was introduced to permit nagtif offset. So if the offset
  negative, it inverses the direction of offset. 
 *===========================================================================*/
IGRlong VLoffset_Cv (   
      struct  GRobj_env       *CrvToOf, /*I: curve to offset */
      struct  GRvg_construct  *cst,     /*I: construction list */
      IGRboolean      InOutSide,        /*I: TRUE : inverse direction
                                             FALSE: don't inverse direction */
      IGRdouble       *normal,          /*I: surface normal or NULL */
      IGRint          NumOf,            /*I: number of offset values */
      IGRdouble       *OfVal,           /*I: offset values */
      IGRdouble       *info,            /*I: supplement info : if info== NULL
                                              we compute a point else we
                                              take the point contained in
                                              info */
      IGRboolean      display,          /*I: TRUE :display curve 
					     FALSE: don't display it */
      struct  GRobj_env       *OfCrv,   /*I: offseted curve */
      IGRint          *NumOldCrvs,
      struct GRid     **OldCrvs,
      IGRlong         *suc )
{
double             *OfVal1, *OfVal2;
struct GRobj_env   obj_tmp;
int                i,positive=0,negative=0;


  *suc = MSFAIL;
  OfVal1 = NULL;
  OfVal2 = NULL;
  nb_old_crvs = 0;
  old_crvs = NULL;
  OfCrv->obj_id.objid = NULL_OBJID;

  if( NumOf < 1 ){
    printf("Error VLoffset_Cv\n");
    printf("NumOf should be >= 1\n");
    goto quit;
  }
  
  OfVal1 = (double *) om$malloc( size =  NumOf * sizeof( double));
  if( OfVal1 == NULL ){
    printf("Error VLoffset_Cv\n");
    printf("malloc OfVal1 : Failed\n");
    goto quit;
  }

  OfVal2 = (double *) om$malloc( size =  NumOf * sizeof( double));
  if( OfVal2 == NULL ){
    printf("Error VLoffset_Cv\n");
    printf("malloc OfVal2 : Failed\n");
    goto quit;
  }

  for (i=0; i<NumOf; i++)
  {
    if (OfVal[i] >= 0) {
      OfVal1[i] = OfVal[i];
      OfVal2[i] = 0;
      positive = 1;
    }
    else {
     if (OfVal[i] <  0) {
       OfVal2[i] = -OfVal[i];
       OfVal1[i] = 0;
       negative = 1;
     }/*
     else {
       OfVal2[i] = 0;
       OfVal1[i] = 0;
     }*/
    }
  }

 if (positive) {
    VLoffCrv(CrvToOf,cst,(IGRboolean)InOutSide,normal,
              NumOf,OfVal1,info,display,OfCrv,suc);
    if (!(*suc&1)) goto quit;

    if (negative) {
      if (InOutSide == FALSE) InOutSide = TRUE;
      else InOutSide = FALSE;
      obj_tmp = *OfCrv;
      VLoffCrv(&obj_tmp,cst,(IGRboolean)InOutSide,normal,
                NumOf,OfVal2,info,display,OfCrv,suc);

      om$send(  msg = message GRgraphics.GRdelete
                                             (suc, cst->env_info ),
                               senderid = NULL_OBJID,
                               targetid = obj_tmp.obj_id.objid,
                               targetos = obj_tmp.obj_id.osnum);
      if (!(*suc&1)) goto quit;

    }
  }

  else {
    if (negative) {
      if (InOutSide == FALSE) InOutSide = TRUE;
        else InOutSide = FALSE;
      VLoffCrv(CrvToOf,cst,(IGRboolean)InOutSide,normal,
                NumOf,OfVal2,info,display,OfCrv,suc);
      if (!(*suc&1)) goto quit;
    }
    else *OfCrv = *CrvToOf;
  }

  if( nb_old_crvs && NumOldCrvs && OldCrvs )
  {
     if( *OldCrvs )
     {
	 *OldCrvs = (struct  GRid *)om$realloc( ptr = (IGRchar *) *OldCrvs,
		 size =  ((*NumOldCrvs)+nb_old_crvs)* sizeof( struct GRid ) );
     }
     else
     {
         *OldCrvs = (struct  GRid *)
                    om$malloc( size = nb_old_crvs * sizeof( struct GRid ) );
     }
     if( *OldCrvs == NULL ){
                printf("Error in VLoffCrv\n");
                printf("Error in  malloc TmpRet : Failed\n");
                goto quit;
        }
     for( i=0; i<nb_old_crvs; ++i ) (*OldCrvs)[(*NumOldCrvs)+i] = old_crvs[i];
     *NumOldCrvs += nb_old_crvs;
  }

  *suc = MSSUCC;
  quit :
  if (OfVal1) {free(OfVal1); OfVal1 = NULL;}
  if (OfVal2) {free(OfVal2); OfVal2 = NULL;}
  return *suc;
}

/*===========================================================================*
 This function create an offset curve from a given curve.
 *===========================================================================*/
IGRlong VLoffCrv (
        struct	GRobj_env	*CrvToOf,/*I: curve to offset */
	struct	GRvg_construct	*cst,    /*I: construction list */
	IGRboolean	InOutSide,       /*I: TRUE : inverse direction
                                              FALSE: don't inverse direction */
	IGRdouble	*normal,         /*I: surface normal */
	IGRint		NumOf,           /*I: number of offset values */
	IGRdouble	*OfVal,          /*I: offset values */
        IGRdouble       *info,           /*I: supplement info : if info== NULL
                                              we compute a point else we
                                              take the point contained in 
                                              info */
	IGRboolean	display,         /*I: TRUE : display curve
                                              FALSE: don't display it */
	struct	GRobj_env	*OfCrv,  /*I: offseted curve */
	IGRlong		*suc )          

{


IGRlong			OM_stat;
OMuword			CrvToOf_cl;
struct	GRid		*CmpLst;
IGRint			NumCmp;
IGRint			NumRetObj;
struct	IGRplane	plane;
IGRdouble		bid[6];
IGRdouble		*offDist;
IGRint			*offCode;
IGRboolean		rightSide, uniform, fillet, removeLoops;
IGRint			i, i3,j;
struct	IGRbsp_curve	*cv;
IGRdouble		COG[3], pacou, ptdev[6],errcou, crossp[3], dotp;
struct IGResbc		esbc ;
IGRchar			*saveClassAttr, save_version[120], save_date[120];
BSrc			rc;
IGRdouble		savedtol;
IGRpoint	        norm1,stpt,enpt;
struct GRobj_env 	newCmpCv, CrvToOffset;
IGRboolean      	haveNotch;

#define EPS 0.00001
#define ZERO 0.001


/*c beginning of code */
/*c retrieve the class id of the comp_curve */

CmpLst   = NULL;
offDist  = NULL;
offCode  = NULL;
cv       = NULL;
saveClassAttr = NULL;
OfCrv->obj_id.objid = NULL_OBJID;
rightSide = FALSE;

/*
 * Need to save EX_version and EX_date, because they contain the version/date of
 * the currently active PRODUCT, and execution of EX_get_version() will 
 * overwrite them with the version/date of the Model executable...
 */
strcpy(save_version, EX_version);
strcpy(save_date, EX_date);

// Get version/date of the Model executable...
EX_get_version ();

// Open correct load_order file for NEW MODEL executable ...

//if( !strcmp(EX_version, "I/MODEL 03.04.00.11" ) ) fillet = 2;
//else    					  fillet = FALSE;

fillet = 2;

OM_stat = om$get_classid(  	osnum	  = CrvToOf->obj_id.osnum,
				objid	  = CrvToOf->obj_id.objid,
				p_classid = &CrvToOf_cl 	);
if( !(OM_stat&1) ){
	// printf("Error in VLoffCrv\n");
	// printf("Error in om$get_classid\n");
	goto wrapup;
}


if( om$is_ancestry_valid( superclassid	= OPP_GRcompcurve_class_id,
			  subclassid	= CrvToOf_cl ) == OM_S_SUCCESS ){

	/*c it's a composite curve beginning of traitement */
	/*c retrieve the number of components defining the composite */



	OM_stat = om$send( msg = message GRowner.GRget_number_components( 
					suc,
			     		&NumCmp ),
                      senderid = NULL_OBJID,
	  	      targetid = CrvToOf->obj_id.objid,
	  	      targetos = CrvToOf->obj_id.osnum );

	#ifdef DEBUG
	printf(" Composite curve, NumCmp = %d\n",NumCmp);
	#endif

	if( !(*suc&OM_stat&1) ){
		printf("Error in VLoffCrv\n");
		printf("Error message GRowner.GRget_number_components\n");
		goto wrapup;
	}

	if( NumCmp != NumOf ){
		printf("Error in VLoffCrv\n");
		printf("Error NumCmp # NumOf\n");
		goto wrapup;
	}

	/*c retrieve the attributes attached */


	OM_stat = om$send(msg	= message GRvg.GRgetattr( suc, (char *) &esbc ),
		       senderid = NULL_OBJID,
	  	       targetid = CrvToOf->obj_id.objid,
	  	       targetos = CrvToOf->obj_id.osnum );
	saveClassAttr	= cst->class_attr ;

	/* malloc the list to retrieve all the components */
	
 	CmpLst = (struct  GRid *) 
		  om$malloc( size =  NumCmp * sizeof( struct GRid ) );
 	if( CmpLst == NULL ){
		printf("Error in VLoffCrv\n");
		printf("Error in  malloc TmpRet : Failed\n");
		goto wrapup;
	}

	if( old_crvs ) free( old_crvs );
        old_crvs = NULL;
        old_crvs = (struct  GRid *)
                    om$malloc( size =  NumCmp * sizeof( struct GRid ) );
        if( old_crvs == NULL ){
                printf("Error in VLoffCrv\n");
                printf("Error in  malloc TmpRet : Failed\n");
                goto wrapup;
        }

	OM_stat = om$send( msg = message GRowner.GRget_components( 
					suc,
					&CrvToOf->mod_env,
					CmpLst,
					NumCmp,
					&NumRetObj,
			     		(IGRint) 0,
					OM_K_MAXINT ),
                 	 senderid = NULL_OBJID,
	  	 	 targetid = CrvToOf->obj_id.objid,
	  	 	 targetos = CrvToOf->obj_id.osnum );

 	if( !(*suc&OM_stat&1) ){
		printf("Error in VLoffCrv\n");
		printf("Error in  GRowner.GRget_components\n");
		goto wrapup;
	}

	/*c retrieve the plane of the curve */

	plane.point  = (IGRdouble *)&bid[0];
	plane.normal = (IGRdouble *)&bid[3];

	bid[3] = bid[4] = bid[5] = 0. ;
	OM_stat = om$send( msg = message GRvg.GRdetplane( 
					suc,
					&CrvToOf->mod_env.md_env.matrix_type,
					CrvToOf->mod_env.md_env.matrix,
					&plane ),

                 	 senderid = NULL_OBJID,
	  	 	 targetid = CrvToOf->obj_id.objid,
	  	 	 targetos = CrvToOf->obj_id.osnum );

	if ( fabs( bid[3] ) > 0. || fabs( bid[4] ) > 0. || fabs( bid[5] ) > 0.)
	{

		/*c malloc the offset dist and the type of offset */

 		offDist = (IGRdouble *) 
			  om$malloc( size =  NumCmp * sizeof( IGRdouble ) );
 		if( offDist == NULL ){
			printf("Error in VLoffCrv\n");
			printf("Error in  malloc offDist : Failed\n");
			goto wrapup;
		}

 		offCode = (IGRint *) 
			  om$malloc( size =  NumCmp * sizeof( IGRint ) );
 		if( offCode == NULL ){
			printf("Error in VLoffCrv\n");
			printf("Error in  malloc offCode : Failed\n");
			goto wrapup;
		}

		/*c evaluate the side of the compcurve */
		/*c for that I compute the approximate COG of the curve */
		/*c then I check the side according to */
 
		COG[0] = 0.0;
		COG[1] = 0.0;
		COG[2] = 0.0;

		/*c here to be sure we should test if this point belongs
		    the contour */

		#ifdef DEBUG
			printf("COG = %f,%f,%f\n",COG[0],COG[1],COG[2]);
		#endif

                 for (i=0;i<NumCmp;i++)
                 {
                   OM_stat = om$send( msg = message GRcurve.GRendpts(
                                           suc,
                                           &CrvToOf->mod_env.md_env.matrix_type,
                                           CrvToOf->mod_env.md_env.matrix,
                                           stpt,        enpt),
                 	 senderid = NULL_OBJID,
	  	 	 targetid = CmpLst[i].objid,
	  	 	 targetos = CmpLst[i].osnum );
                    if (!(OM_stat&(*suc)&1)) goto wrapup;
                    COG[0] += stpt[0] + enpt[0]; 
                    COG[1] += stpt[1] + enpt[1]; 
                    COG[2] += stpt[2] + enpt[2]; 
                  }
	          COG[0] = COG[0]/(double)(2*NumCmp);	
	          COG[1] = COG[1]/(double)(2*NumCmp);	
	          COG[2] = COG[2]/(double)(2*NumCmp);	
                  if (info != NULL) {
                    info[0] = COG[0];
                    info[1] = COG[1];
                    info[2] = COG[2];
                  }
            	OM_stat = om$send(msg = message GRvg.GRgenabsg(
					suc,
					&CrvToOf->mod_env.md_env.matrix_type,
					CrvToOf->mod_env.md_env.matrix,
                       			(IGRchar **)&cv ),
	                     senderid = NULL_OBJID,
	  	 	     targetid = CmpLst[0].objid,
			     targetos = CmpLst[0].osnum );

		VLgetRightsideFromCompCrv( suc, *CrvToOf, cv,
						 &bid[3], cst, &rightSide );

		if( InOutSide == TRUE ){
			if( rightSide == FALSE ) rightSide = TRUE;
			else rightSide = FALSE;
                }
		
		for(i=0;i<NumCmp;i++){
			offCode[i] = BSCONSTOFF;
			offDist[i] = OfVal[i];
                     /* because of a bug in the BS used in EMcvoffset
                        offDist should not contain zeros */
                        if (offDist[i]<EPS && offDist[i]>-EPS)
                          offDist[i] = 0.0;
		        else
			{
        		   om$send(msg = message GRgraphics.GRcopy(
                                                suc,
                                                &CrvToOf->mod_env,
                                                cst->env_info,
                                                &old_crvs[nb_old_crvs].objid ),
                                senderid = NULL_OBJID,
                                targetid = CmpLst[i].objid,
                                targetos = CmpLst[i].osnum );
			   old_crvs[nb_old_crvs].osnum = 
						cst->env_info->md_id.osnum;
			   ++nb_old_crvs;
			}
		}	

		OM_stat = VLcheckNotchOnCompCrv( suc, NumCmp, CmpLst, 
					&CrvToOf->mod_env, &offDist, 
					&haveNotch, cst, &newCmpCv );	 
		if( haveNotch ) 
		{
		   __DBGpr_obj( "New Composite Curve", newCmpCv.obj_id );
		   CrvToOffset = newCmpCv;
		}
		else CrvToOffset = *CrvToOf ;

		cst->class_attr = (char *) &esbc ;
		uniform = FALSE;

		removeLoops = TRUE;
                if (info) info[3] = 0;
        	OM_stat = om$send(msg = message GRcurve.EMcvoffset(
					suc,
                         		&cst->env_info->md_env.matrix_type,
                         		cst->env_info->md_env.matrix,
                   			cst,
                   			offDist, 
					plane.normal, 
                   			rightSide,
                   			uniform, 
                   			offCode,
                   			fillet, 
                   			removeLoops, 
					&OfCrv->obj_id,
                   			NULL, NULL, NULL),
	                     senderid = NULL_OBJID,
	  	 	     targetid = CrvToOffset.obj_id.objid,
	  	 	     targetos = CrvToOffset.obj_id.osnum );
		if (!((*suc)&OM_stat&1) || OfCrv->obj_id.objid == NULL_OBJID ){
                  if (info) info[3] = 1;
                  BSxtractpar ( &rc, BSTOLBASIS, &savedtol); 
                  BSchgdeppar(0.000001,&rc);
        	  OM_stat = om$send(msg = message GRcurve.EMcvoffset(
					suc,
                         		&cst->env_info->md_env.matrix_type,
                         		cst->env_info->md_env.matrix,
                   			cst,
                   			offDist, 
					plane.normal, 
                   			rightSide,
                   			uniform, 
                   			offCode,
                   			fillet, 
                   			removeLoops, 
					&OfCrv->obj_id,
                   			NULL, NULL, NULL),
	                     senderid = NULL_OBJID,
	  	 	     targetid = CrvToOffset.obj_id.objid,
	  	 	     targetos = CrvToOffset.obj_id.osnum );
                  BSchgdeppar(savedtol,&rc);
		  if (!((*suc)&OM_stat&1)){
			printf("Error in VLoffCrv\n");
			printf("EMcvoffset 1 Failed\n");
                        goto wrapup;
                  }
		}

                if( OfCrv->obj_id.objid == NULL_OBJID )
                {
                   printf("Error in VLoffCrv\n");
                   printf("EMcvoffset 1 Failed\n");
                   goto wrapup;
                }

		cst->class_attr = saveClassAttr ;
/*
                OM_stat = om$send( msg = message GRowner.GRdrop(
                                   suc,
                                   cst->env_info),
                         senderid = NULL_OBJID,
                         targetid = CrvToOf->obj_id.objid,
                         targetos = CrvToOf->obj_id.osnum );
                if( !(OM_stat&(*suc)&1) ){
                        printf("GRowner.GRdrop: Failde\n");
                        goto wrapup;
                }
*/
                OM_stat = om$send(  msg = message GRgraphics.GRdelete
                                                       (suc, cst->env_info ),
			senderid = NULL_OBJID,
		        targetid = CrvToOf->obj_id.objid,
      		        targetos = CrvToOf->obj_id.osnum);
		if( haveNotch )
		{
		   OM_stat = om$send(  msg = message GRgraphics.GRdelete
					(suc, cst->env_info ),
			senderid = NULL_OBJID,
			targetid = CrvToOffset.obj_id.objid,
			targetos = CrvToOffset.obj_id.osnum);
		}
	}
 	else if ( !(*suc&OM_stat&1) ){
		printf("Error in VLoffCrv\n");
		printf("Error in  GRvg.GRdetplane\n");
		goto wrapup;
	}
	else printf( "Big problem??\n\n" );
	
	

}/* end of traitement if CrvToOf is a GRcompcurve */

else{
	/*c retrieve the plane of the curve */
	plane.point  = (IGRdouble *)&bid[0];
	plane.normal = (IGRdouble *)&bid[3];

	OM_stat = om$send( msg = message GRvg.GRdetplane( 
					suc,
					&CrvToOf->mod_env.md_env.matrix_type,
					CrvToOf->mod_env.md_env.matrix,
					&plane ),

                 	 senderid = NULL_OBJID,
	  	 	 targetid = CrvToOf->obj_id.objid,
	  	 	 targetos = CrvToOf->obj_id.osnum );

 	if( !(*suc&OM_stat&1) ){
		if( normal ) for(i=0;i<3;i++) plane.normal[i] = normal[i];
		else{
                  if ( *suc == MASDGENRAT){  // if curve is a line segment

                    OM_stat = om$send( msg = message GRcurve.GRendpts(
                                           suc,
                                           &CrvToOf->mod_env.md_env.matrix_type,
                                           CrvToOf->mod_env.md_env.matrix,
                                           stpt,        enpt),
                 	 senderid = NULL_OBJID,
	  	 	 targetid = CrvToOf->obj_id.objid,
	  	 	 targetos = CrvToOf->obj_id.osnum );
                    if (!(OM_stat&(*suc)&1)) goto wrapup;

                    stpt[0] = enpt[0] - stpt[0];
                    stpt[1] = enpt[1] - stpt[1];
                    stpt[2] = enpt[2] - stpt[2];
                    BSorthovec( &rc, stpt, norm1 ) ;
		    BScrossp( &rc, stpt, norm1, plane.normal ); 
                    if (rc != BSSUCC) goto wrapup;
                  }
                  else {
			printf("Error in VLoffCrv\n");
			printf("Error in  GRvg.GRdetplane\n");
			goto wrapup;
		   }
                 }
	}
		/*c malloc the offset dist and the type of offset */
		NumCmp = 1;
		nb_old_crvs = 0;

 		offDist = (IGRdouble *) 
			  om$malloc( size =  NumCmp * sizeof( IGRdouble ) );
 		if( offDist == NULL ){
			printf("Error in VLoffCrv\n");
			printf("Error in  malloc offDist : Failed\n");
			goto wrapup;
		}

 		offCode = (IGRint *) 
			  om$malloc( size =  NumCmp * sizeof( IGRint ) );
 		if( offCode == NULL ){
			printf("Error in VLoffCrv\n");
			printf("Error in  malloc offCode : Failed\n");
			goto wrapup;
		}

		/*c evaluate the side of the compcurve */
		/*c for that I compute the approximate COG of the curve */
		/*c then I check the side according to */
 
            	OM_stat = om$send(msg = message GRvg.GRgenabsg(
					suc,
					&CrvToOf->mod_env.md_env.matrix_type,
					CrvToOf->mod_env.md_env.matrix,
                       			(IGRchar **)&cv ),
                             senderid = NULL_OBJID,
	  	 	     targetid = CrvToOf->obj_id.objid,
	  	 	     targetos = CrvToOf->obj_id.osnum );


		#ifdef DEBUG
		__DBGpr_bscv( "cv",cv,suc );
		#endif
                if (info == NULL) {
		  i3 = 3 * cv->num_poles;
		  COG[0] = 0.0;
		  COG[1] = 0.0;
		  COG[2] = 0.0;

                  if (!cv->rational) {
                    for(i=0;i<i3;i+=3){
                            COG[0] = COG[0] + cv->poles[i];
                            COG[1] = COG[1] + cv->poles[i+1];
                            COG[2] = COG[2] + cv->poles[i+2];
                    }
                  }
                  else {
		    for (j=0,i=0;i<i3;i+=3,j++){
                            COG[0] = COG[0] + cv->poles[i]/cv->weights[j];
                            COG[1] = COG[1] + cv->poles[i+1]/cv->weights[j];
                            COG[2] = COG[2] + cv->poles[i+2]/cv->weights[j];
		    }
                  }
                  COG[0] = COG[0]/(double) cv->num_poles;
                  COG[1] = COG[1]/(double) cv->num_poles;
                  COG[2] = COG[2]/(double) cv->num_poles;

		  for(i=0;i<3;i++) COG[i] = 0.99 * cv->poles[i] +
				             0.01 * COG[i];
                }
                else {
                  COG[0] = info[0];
                  COG[1] = info[1];
                  COG[2] = info[2];
            	  BScveval( cv, 0.5, 0, ptdev, suc);
		  for(i=0;i<3;i++) COG[i] = 0.99 * ptdev[i] + 0.01 * COG[i];
                }

   		BSmdstptcv( cv, COG, &pacou, ptdev, &errcou, suc );

            	BScveval( cv, pacou, 1, ptdev, suc);

		for(i=0;i<3;i++) COG[i] = COG[i] - ptdev[i];

		BScrossp( suc, &ptdev[3], plane.normal, crossp ); 
		dotp = BSdotp(suc,crossp,COG);

                if (dotp < savedtol && dotp > -savedtol) {
		  BScrossp( suc, &ptdev[3], norm1, crossp ); 
		  dotp = BSdotp(suc,crossp,COG);
                  plane.normal[0] = norm1[0];
                  plane.normal[1] = norm1[1];
                  plane.normal[2] = norm1[2];
                }
		if( dotp < 0 )  rightSide = FALSE;
		else		rightSide = TRUE;
		if( InOutSide == TRUE ){
			if( rightSide == FALSE ) rightSide = TRUE;
			else			 rightSide = FALSE;
		}
		
		for(i=0;i<NumCmp;i++){
			offCode[i] = BSCONSTOFF;
			offDist[i] = OfVal[i];
		}	

		cst->class_attr = (char *) &esbc ;
		uniform = TRUE;

		removeLoops = TRUE;
                if (info) {
                  if (info[3]) {
                    BSxtractpar ( &rc, BSTOLBASIS, &savedtol); 
                    BSchgdeppar(300*savedtol,&rc);
                  }
                }
        	OM_stat = om$send(msg = message GRcurve.EMcvoffset(
					suc,
                         		&cst->env_info->md_env.matrix_type,
                         		cst->env_info->md_env.matrix,
                   			cst,
                   			offDist, 
					plane.normal, 
                   			rightSide,
                   			uniform, 
                   			offCode,
                   			fillet, 
                   			removeLoops, 
					&OfCrv->obj_id,
                   			NULL, NULL, NULL),
	                     senderid = NULL_OBJID,
	  	 	     targetid = CrvToOf->obj_id.objid,
	  	 	     targetos = CrvToOf->obj_id.osnum );
                if (info) {
                  if (info[3]) {
                    BSchgdeppar(savedtol,&rc);
                  }
                }

		if(!((*suc)&OM_stat&1)){
			printf("Error in VLoffCrv\n");
			printf("EMcvoffset 2 Failed\n");
                        goto wrapup;
                }
                if( old_crvs ) free( old_crvs );
                nb_old_crvs = 0;
                old_crvs = NULL;
                old_crvs = (struct  GRid *)
                    om$malloc( size =  NumCmp * sizeof( struct GRid ) );
                if( old_crvs == NULL ){
                        printf("Error in VLoffCrv\n");
                        printf("Error in  malloc TmpRet : Failed\n");
                        goto wrapup;
                }

                om$send(msg = message GRgraphics.GRcopy(
                                                suc,
                                                &CrvToOf->mod_env,
                                                cst->env_info,
                                                &old_crvs[nb_old_crvs].objid ),
                           senderid = NULL_OBJID,
                           targetid = CrvToOf->obj_id.objid,
                           targetos = CrvToOf->obj_id.osnum );
                 old_crvs[nb_old_crvs].osnum = cst->env_info->md_id.osnum;
                 ++nb_old_crvs;

		 cst->class_attr = saveClassAttr ;
}/* end of traitement if CrvToOf is NOT a GRcompcurve */



if( display == TRUE ) gr$display_object ( object_id = &OfCrv->obj_id,
	               	                  mode      = GRbd );


*suc = MSSUCC;
if( CmpLst ) { om$dealloc( ptr = CmpLst );  CmpLst  = NULL;}
if( offDist ){ om$dealloc( ptr = offDist ); offDist = NULL;}
if( offCode ){ om$dealloc( ptr = offCode ); offCode = NULL;}
return(MSSUCC);
 
wrapup:
  	for( i=0; i<nb_old_crvs; ++i )
	{
	  if( old_crvs[i].objid != NULL_OBJID )
	  {
	      om$send(  msg = message GRgraphics.GRdelete
                                                (suc, cst->env_info ),
                        senderid = NULL_OBJID,
                        targetid = old_crvs[i].objid,
                        targetos = old_crvs[i].osnum);
	  }
        }
	*suc = MSFAIL;
	OfCrv->obj_id.objid = NULL_OBJID;
	if( CmpLst ) { om$dealloc( ptr = CmpLst );  CmpLst  = NULL;}
	if( offDist ){ om$dealloc( ptr = offDist ); offDist = NULL;}
	if( offCode ){ om$dealloc( ptr = offCode ); offCode = NULL;}
	return(MSFAIL);
}

/*=========================================================================*
d This function retrieve all children of a given ClassName and MacName 
    connected to an AS source object. 

 *=========================================================================*/

IGRlong VLgetChildrenMacro( parentId, childMacName, 
			     numMacros,  macrosId, realParent )

struct  GRobj_env parentId;		/*I As source object              */
	IGRchar	  *childMacName;	/*I macro name to find            */
	IGRint	  *numMacros;		/*O number of macro found         */
struct  GRid	  **macrosId;		/*O Grid list allocated by caller */
struct	GRid	  *realParent;

{

IGRint		      i , numObjects; 
IGRlong		      msg,sts;
struct GRid 	      *macBuf;
struct GRobj_env      *list_obj,Owner;
OMuword		      pretendin_cl, parentId_cl;

 msg = MSFAIL;
 macBuf = NULL;
 list_obj = NULL;
 *numMacros = 0;
 numObjects = 0;
 realParent->objid = NULL_OBJID;

  om$get_classid ( classname = "ACpretendin", p_classid = &pretendin_cl);
  om$get_classid ( osnum     = parentId.obj_id.osnum,
		   objid     = parentId.obj_id.objid,
		   p_classid = &parentId_cl ) ;
/***********
   	sts = om$send( msg      = message NDnode.ASreturn_go( 
					&GObj, 
					&EnvGObj.md_env.matrix_type,
    					EnvGObj.md_env.matrix ),
   		       senderid = NULL_OBJID, 
   		       targetid = parentId.obj_id.objid, 
   		       targetos = parentId.obj_id.osnum );
 
  	if( !( 1 & sts ) ){
		printf("Error in getChildMacro\n");
		goto wrapup;
  	}
	ASget_mac_owner(&GObj,&Owner.obj_id,&i);
*********/

   	sts = om$send( msg      = message ACpretend.ACfind_parent(
                                          &(Owner.obj_id),
                                          &(Owner.mod_env.md_env.matrix_type),
                                          Owner.mod_env.md_env.matrix
                                                                 ),
	        senderid        = NULL_OBJID,
		targetid 	= parentId.obj_id.objid,
		targetos 	= parentId.obj_id.osnum);

 #ifdef DEBUG
 printf("realParent = %d,%d\n",realParent->objid,realParent->osnum );
 #endif

   VLbrowseFctInTree( &Owner, VL_Q_TOP_SOURCE, NULL,
                     VL_Q_DOWN_DIRECT,
                     VLgetMacrosAtStep,
                     &numObjects, &list_obj );

  VLfilterDef(numObjects,list_obj,&numObjects,childMacName);
  if (numObjects == 0) { msg = MSSUCC; goto wrapup;}

  macBuf = (struct GRid *) malloc(numObjects*sizeof(struct GRid));
  if (macBuf == NULL) {
    printf("Problems at malloc memory\n");
    goto wrapup;
  }
    
  for (i=0;i<numObjects;i++)
  {
    macBuf[i] = list_obj[i].obj_id;
    (*numMacros)++;
  }
 
  *macrosId = macBuf;
  msg = MSSUCC;

wrapup:
	if( list_obj != NULL ) om$dealloc( ptr = list_obj );
	return(msg);

}
end implementation VLabstract;
