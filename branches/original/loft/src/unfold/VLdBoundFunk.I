/* $Id: VLdBoundFunk.I,v 1.2 2001/01/16 19:46:14 ramarao Exp $  */

/* --------------------------------------------------------------------
 * I/LOFT
 *
 * File:        loftdp/src/unfold/VLdBoundFunk.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLdBoundFunk.I,v $
 *      Revision 1.2  2001/01/16 19:46:14  ramarao
 *      *** empty log message ***
 *
# Revision 1.1  2000/04/19  17:46:24  pinnacle
# Created: loft/src/unfold/VLdBoundFunk.I by rchennup for Service Pack
#
# Revision 1.5  2000/03/24  18:47:02  pinnacle
# Replaced: src/unfold/VLdBoundFunk.I for:  by impd252 for loft
#
# Revision 1.4  2000/03/14  20:31:42  pinnacle
# Added code to Process Bevel macros.
#
# Revision 1.3  2000/02/25  20:28:06  pinnacle
# Used Art's function VLunwBevelGetGap.
#
# Revision 1.2  2000/02/25  17:17:10  pinnacle
# Removed the check for angle type while applying stock.
#
# Revision 1.1  1998/04/30  10:32:50  pinnacle
# LOFT 2.5.1
#
# Revision 1.1  1997/05/08  14:05:56  pinnacle
# Loft 250
#
# Revision 1.6  1997/02/23  22:50:34  pinnacle
# Replaced: src/unfold/VLdBoundFunk.I for:  by rchennup for loft
#
# Revision 1.4  1996/05/01  06:53:56  pinnacle
# Replaced: src/unfold/VLdBoundFunk.I for:  by rchennup for loft
#
# Revision 1.3  1996/01/31  09:04:10  pinnacle
# Replaced: src/unfold/VLdBoundFunk.I for:  by svkadamb for loft
#

 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      03/14/00	Rama Rao	Added code to Process Bevel macros
 * -------------------------------------------------------------------*/

/*f
	VLdBoundFunk.I contains all the basics functions to generate the
	2D edges of an unwraped surface based on his representation
	before unwraping.

JLL 17 jan 93 : extract from VLdevel.I
		add argument dim to function VLcre3dCvFromParams to
		be able to handle funny IGRbsp_curve structure even if it's
		uv space.

JLL 18 Jan 93 : add VLedgeMatch  retrieves all the 2D edges forming
		a genbs surface and then performs the edge matching between
		3D edge_att and the 3D representaion of the 2D edges.

JLL 19 Jan 93 : VLmatchEdgeWithAtt is the function that perform the
		edge matching.

JLL 10 mai 94 : add GRchglevel method in VLcreBoundWithOff() in the case
		of copy

JLL 16 May 94 : set objRet and lcCv to NULL_OBJID after malloc 
JLL 17 May 94 : delete VLcreOrd2Srf() in VLbuildUnwrapEdge and add comments
RR  25 Feb 00 : Removed the check for angle type while applying stock.
*/


class implementation VLabstract;



/*
# ifndef DEBUG
# define DEBUG 1
# endif
*/

/*
#define DEBUG1
*/

#include <stdio.h>
#include <math.h>
#include "vlprototype.h"

#include "OMprimindex.h"
#include "OMprimitives.h"
#include "OMminimum.h"
#include "OMerrordef.h"

#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdef.h"
#include "igrdp.h"
#include "godef.h"
#include "gr.h"
#include "growner.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "dp.h"
#include "bstypes.h"
#include "bserr.h"
#include "maerr.h"
#include "bs.h"
#include "bsparameters.h"
#include "EMSmsgdef.h"
#include "msdef.h"
#include "OMindex.h"
#include "OMmacros.h"
#include "EMSssprops.h"
#include "EMSdpb.h"
#include "EMSopt.h"
#include "grmacros.h"
#include "dpezmac.h"
#include "igr.h"
#include "griodef.h"
#include "go.h"
#include "ex.h"
#include "grio.h"
#include "nddef.h"
#include "asmacros.h"
#include "parametric.h"
#include "csdef.h"
#include "values.h"
#include "vsedgedef.h"
#include "vsedgemacros.h"
#include "vsgeommacros.h"
#include "vlunfold.h"
#include "vsjoint.h"
#include "vsmiscmacros.h"
#include "bsvalues.h"
#include "vledgeattr.h"
#include "ACrg_collect.h"
#include "ACattrib.h"

  
from	ASindexcv	import  ASget_uvwdef;
from	EMSboundary	import	EMcount_edges, EMget_edges;
from    EMSedge		import	EMgetbcgeom, EMget_bcxyz_geom;
from	EMSloopset      import	EMget_loops;
from   	GRcompcurve	import  EMmakecomp;
from	GRcurve		import  GRmidpoint;
from    GRcurve         import  GRendpts;
from	IGEgragad	import	DPinrot;
from	ACrg_collect	import	AClist_attribute, ACget_named_attribute;
from    ACcpx_defn	import	ACgive_name;

extern GRclassid	OPP_GR3dlinestr_class_id;
extern GRclassid	OPP_GRcompcurve_class_id;
extern GRclassid        OPP_EMSgenbs_class_id;
extern GRclassid        OPP_GRgencs_class_id;
extern GRclassid        OPP_GRbcsubbc_class_id;
extern GRclassid        OPP_GR3dcirarc_class_id;
extern GRclassid        OPP_GRcirarc_class_id;

extern 			BSchtptstsf();
extern 			BSchtptstso();
extern 			BSsfarrevn();
extern 			BSkts_f_fit();
extern 			BSkts_f_app();
extern 			BSrev_cv();
extern  IGRboolean	BSfreesf();
extern			GRdpb_get();
extern			GRdpb_put();
extern	IGRdouble	BSdistptpt();
extern	IGRboolean	BScrossp();
extern	IGRdouble	BSdotp();
extern	IGRdouble	BSlenvec();
extern  IGRboolean	BSnorvec();
extern  void		BSchtptstcv();
extern	void		BSalloccv(), BSallocsf();
extern	IGRboolean	BSfreecv(), BSfreesf();
extern  IGRchar		*memcpy();
extern  void		BSsfeval();
extern			GRdisplay_object();
extern	IGRdouble	cos(),fabs();
extern			ASmake_source_from_env();
extern IGRint 		MAinvmx();
extern IGRint 		MAmulmx();
extern IGRboolean	MAtypemx();
extern IGRint 		BSmdistptsf();
extern IGRint 		VLfindOrientation();
extern IGRint 		VLlongHorzOrTrans();
extern void		__DBGpr_double();
extern			SortAndBuildCrv();
extern long		VSdoCurvesOverlap();
extern void             FAevPtSfFaDr();

/*===========================================================================*/
  
IGRlong VLcreBoundaries (
 
struct 	mise_a_plat	*dev,		/*I the unwraped structure */
struct	GRvg_construct	*cst,		/*I construction list given */
        IGRboolean	DisOpt,		/*I TRUE if you want display */
	IGRboolean	*WantGraGrp,	/*I not use to day */
	IGRint		*NumObj,	/*O number of objects return */
struct  GRobj_env	**ObjRet 	/*O the objects created */
)

/*d This function evaluates the unwraped edge of a unwraped surface without
    taking into account the edge attributs that could be attached to
    the parent surface */

/*h october/92 JLL creation date */

/*c Beginning of function */
{

	IGRlong		suc, stat;
	IGRint 		i, j, k, ie;
	IGRdouble	*P;
struct 	IGRpolyline	lst;
struct  IGRbsp_curve	cv;
struct  GRlc_info	*LcCv;
	BSrc	  	rc;
struct	IGRbsp_surface  *sf;
	IGRint		NumBound, MaxPts;
struct  GRobj_env	*TmpRet;
	IGRlong		rotten_one ;
	IGRdouble	u, v;
	IGRushort	*props;
	IGRdouble	*pars;
  GRobjid		*LoopIds;
  IGRint		buf_size, NumLoops;
  struct	GRid    *EdgesId;
  OM_S_CHANSELECT 	chanloopset;
  IGRuint		nb_loopset;
  IGRlong		option;
  IGRint		depth;
  IGRint		NumEdges;
	IGRushort 	options;
  OM_S_OBJECT_LINKAGE	listLOOPSET;
  IGRint		size_buf;
  IGRdouble		SavedCht, Cht;


 #ifdef DEBUG
 printf("------------VLcreBoundaries------------\n");
 #endif

 LcCv       = NULL;
 sf         = NULL;
 lst.points = NULL;
 *ObjRet    = NULL;
 TmpRet	    = NULL;
 props      = NULL;
 cv.poles   = NULL;
 cv.knots   = NULL;
 cv.weights = NULL;
 cv.bdrys   = NULL;
 EdgesId    = NULL;
 LoopIds    = NULL;
 pars	    = NULL;

 NumBound = dev->surface->num_boundaries;

 if( dev->surface->num_boundaries == 0 ){

     /*c surface without boundaries -> generation of the */

	#ifdef DEBUG
	printf("Pas de loop\n");
	#endif
 
 	LcCv = (struct  GRlc_info *) 
        	om$malloc( size = 4 * sizeof( struct GRlc_info ) );
 	if( LcCv == NULL ){
		printf(" malloc GRlc_info : Failed\n");
		 goto wrapup;
	}

	for(i=0;i<4;i++) LcCv[i].module_info = *(cst->env_info);
 	MaxPts = 3 * dev->Nb_u;
	if( dev->Nb_u < dev->Nb_v ) MaxPts = 3 * dev->Nb_v;

 	lst.points = NULL;
 	lst.points = (IGRdouble *)om$malloc( 
					size = MaxPts * sizeof(IGRdouble) );
 	if( lst.points == NULL ){
		printf(" malloc lst.points : Failed\n");
		goto wrapup;
 	}

	cst->geometry	= (IGRchar *) &lst;

	/*c get the first iso in u */

     	memcpy ( (IGRchar *)lst.points,(IGRchar *)dev->M,
	         (IGRint) 3 * dev->Nb_u * sizeof(IGRdouble) );

        lst.num_points = dev->Nb_u;
	LcCv[0].located_obj.objid = NULL_OBJID;
	LcCv[0].located_obj.osnum = cst->env_info->md_id.osnum;
  	om$construct( classid = OPP_GR3dlinestr_class_id, 
	                    p_objid = &LcCv[0].located_obj.objid, 
         	            osnum   = LcCv[0].located_obj.osnum,
			    msg     = message GRgraphics.GRaltconstruct(cst) );

	/*c get the second iso in u */

     	memcpy ( (IGRchar *)lst.points,
	         (IGRchar *)&dev->M[3*dev->Nb_u*(dev->Nb_v-1)],
	         (IGRint) 3 * dev->Nb_u * sizeof(IGRdouble) );

	LcCv[2].located_obj.objid = NULL_OBJID;
	LcCv[2].located_obj.osnum = cst->env_info->md_id.osnum;
  	om$construct( classid = OPP_GR3dlinestr_class_id, 
	                    p_objid = &LcCv[2].located_obj.objid, 
         	            osnum   = LcCv[2].located_obj.osnum,
			    msg     = message GRgraphics.GRaltconstruct(cst) );

	/*c get the first iso in v */

	j = 0;
	lst.num_points = dev->Nb_v;

	for(i=0;i<3*dev->Nb_u*dev->Nb_v;i+=3*dev->Nb_u){
     		memcpy ( (IGRchar *)&lst.points[j],
	         	(IGRchar *)&dev->M[i],
	         	(IGRint) 3 * sizeof(IGRdouble) );
		j += 3;
	}
	
	LcCv[3].located_obj.objid = NULL_OBJID;
	LcCv[3].located_obj.osnum = cst->env_info->md_id.osnum;
  	om$construct( classid = OPP_GR3dlinestr_class_id, 
	                    p_objid = &LcCv[3].located_obj.objid, 
         	            osnum   = LcCv[3].located_obj.osnum,
			    msg     = message GRgraphics.GRaltconstruct(cst) );

	j = 0;
	k = 3 * (dev->Nb_u - 1);


	for(i=k;i<3*dev->Nb_u*dev->Nb_v;i+=3*dev->Nb_u){
     		memcpy ( (IGRchar *)&lst.points[j],
	         	(IGRchar *)&dev->M[i],
	         	(IGRint) 3 * sizeof(IGRdouble) );
		j += 3;
	}
	
	LcCv[1].located_obj.objid = NULL_OBJID;
	LcCv[1].located_obj.osnum = cst->env_info->md_id.osnum;
  	om$construct( classid = OPP_GR3dlinestr_class_id, 
	                    p_objid = &LcCv[1].located_obj.objid, 
         	            osnum   = LcCv[1].located_obj.osnum,
			    msg     = message GRgraphics.GRaltconstruct(cst) );


 	TmpRet = (struct  GRobj_env *)
        	om$malloc( size =  sizeof( struct GRobj_env ) );
 	if( TmpRet == NULL ){
		printf(" malloc TmpRet : Failed\n");
		 goto wrapup;
	}

	cst->geometry = NULL;
	TmpRet->obj_id.objid = NULL_OBJID;
	TmpRet->obj_id.osnum = cst->env_info->md_id.osnum;
	TmpRet->mod_env	     = *cst->env_info;
	stat = om$construct ( msg 	= message GRgraphics.GRconstruct
						( cst ),

				classid	= OPP_GRcompcurve_class_id,	
				p_objid	= &TmpRet->obj_id.objid,
 				osnum  	= TmpRet->obj_id.osnum );

	if ( !(stat&1)) {
		printf(" GRgraphics.GRconstruct for comp : Failed\n");
		goto deldel;
	}	

	stat = om$send( msg      = message GRcompcurve.EMmakecomp(  
							      &suc,
							      cst->env_info,
							      4,
	   						      LcCv,
							      &rotten_one  ),
			targetid = TmpRet->obj_id.objid,
			targetos = TmpRet->obj_id.osnum,
			senderid = NULL_OBJID );

	if (! (stat & suc & 1)) {

		  printf( "GRcompcurve.EMmakecomp : Failed\n");
		  /*
		   *	If comp curve construction fails, delete new
		   *	curves, and keep old input curves
		   */
deldel:
		  for(i=0 ; i<4; i++)
		  {
     			stat = om$send(msg      = message GRgraphics.GRdelete(
					&suc, cst->env_info ),
             		 targetid = LcCv[i].located_obj.objid,
			 targetos = LcCv[i].located_obj.osnum,
			 senderid = NULL_OBJID ) ;
 		  }
		  
		  goto wrapup;	    
	}

	*NumObj = 1;
	if( DisOpt == TRUE ){

 		gr$display_object ( object_id = (struct GRid *)&TmpRet->obj_id,
		     	    	    mode      = GRbd );
	}
	
	*ObjRet = TmpRet;

 }/*c end of natural edege case */

 else{


	#ifdef DEBUG
	printf("C' est une surface avec  loop\n");
	#endif


 	/*c creation of a facette surface to remap the edges */

	if( dev->devsrf == NULL ) {
	  VLcreOrd2Srf( dev->M, dev->Nb_u, dev->Nb_v, dev->Param_u, 
		         dev->Param_v, 0, cst, (IGRboolean)FALSE, 
		         NULL, &(dev->devsrf), &suc );
	  if( suc != MSSUCC ){
		  printf("Error in VLcreBoundaries\n");
		  printf("VLcreOrd2Srf Failed\n"); 
	  }
        }
	/*c ajout 1 find the loopset */


  	stat = OM_S_SUCCESS;


 	/*c We look for the EMSloopset , first check if have one */ 

	chanloopset.type		= OM_e_num;
	stat = om$get_channel_number ( channame  = "EMSsubbs.to_loopset",
				       p_channum = &chanloopset.u_sel.number );
	if ( ! (stat&1)) {
	  printf("Error in VLcreBoundaries \n");
	  printf("Error get_channel_number loopset\n"); 
	  goto wrapup;
	}

	/*c retrieve the loopset id */

	listLOOPSET.S_objid = NULL_OBJID;
	stat = om$get_channel_objects(    
				osnum	        = dev->surf_id.obj_id.osnum,
				objid	        = dev->surf_id.obj_id.objid,
				p_chanselect	= &chanloopset,
				size		= 1,
				count		= &nb_loopset,
				list		= &listLOOPSET );
	if ( ! (stat&1)) {
	  printf("Error in VLcreBoundaries \n");
	  printf("Error No loopset to this element : No a surface with bnd\n");
	  goto wrapup;
	}

	#ifdef DEBUG
	printf("nb_loopset=%d\n",nb_loopset);
	#endif
	
	/*c retrieve the number of loops */

	option  = EMS_OPT_ALL;
  	LoopIds = NULL;
  	props   = NULL;
	depth   = OM_K_MAXINT;
	buf_size = 0;

	stat = om$send ( msg = message EMSloopset.EMget_loops( 	&suc,
								option,
								&depth,
								&LoopIds,
								&props,
								&buf_size,
								&NumLoops ),
		    senderid = NULL_OBJID,
		    targetid = listLOOPSET.S_objid,
		    targetos = listLOOPSET.osnum );

	if ( !(stat&suc&1)) {
	  printf("Error in VLcreBoundaries \n");
	  printf("Error in EMSloopset.EMget_loops\n");
	  goto wrapup;
	}
	
	#ifdef DEBUG
	printf("NumLoops=%d\n",NumLoops);
	#endif 

	/*c malloc the number of composite curves that will be returned */

 	TmpRet = (struct  GRobj_env *)
        	om$malloc( size =  NumLoops * sizeof( struct GRobj_env ) );
 	if( TmpRet == NULL ){
	  	printf("Error in VLcreBoundaries \n");
		printf(" malloc TmpRet : Failed\n");
		goto wrapup;
	}




	/*c find the maximun number of edges in loops */

	j = 0;
	options = 0;

	stat = om$send ( msg = message EMSboundary.EMcount_edges(
							&suc, option, &j ),
	            senderid = NULL_OBJID,
		    targetid = listLOOPSET.S_objid,
		    targetos = listLOOPSET.osnum );
	if ( !(stat&suc&1)) {
	 	printf("Error in VLcreBoundaries \n");
	  	printf("Error in EMSboundary.EMcount_edges\n");
	  	goto wrapup;
	}


	#ifdef DEBUG
	printf(" num max edge from EMSboundary.EMcount_edges  = %d\n",j);
	#endif

	option = EMS_OPT_ALL;
	/* malloc the array to build the 2D edges */
 	LcCv = (struct  GRlc_info *) 
        	om$malloc( size = j * sizeof( struct GRlc_info ) );
 	if( LcCv == NULL ){
		printf(" malloc GRlc_info : Failed\n");
		 goto wrapup;
	}

	EdgesId = NULL;
	depth = 1;
	NumEdges = 0;
	buf_size = 0;

	for(i=0;i<NumLoops;i++){

		#ifdef DEBUG
		printf("enter EMget_edges = LoopIds[%d]=%d\n",i,LoopIds[i]);
		#endif

		stat = om$send ( msg = message EMSboundary.EMget_edges( 
						&suc,
						depth,
						option,
						&EdgesId,
						&buf_size,
						&NumEdges ),
			    senderid = NULL_OBJID,
		            targetid = LoopIds[i],
			    targetos = listLOOPSET.osnum  );

		if ( !(stat&suc&1)) {
	 		printf("Error in VLcreBoundaries \n");
	  		printf("Error in EMSboundary.EMget_edges\n");
	  		goto wrapup;
		}

		#ifdef DEBUG
		printf("NumEdges=%d\n",NumEdges);
		#endif

	   	for(ie=0;ie<NumEdges;ie++){
		    stat = om$send ( msg      = message EMSedge.EMgetbcgeom(
							&suc,
            						(IGRint) 0,
            						(IGRint) OM_K_MAXINT,
							(IGRboolean) FALSE,
							NULL,
			     				&cv,
				        		NULL,
							options ),
			 senderid = NULL_OBJID,
	   		 targetid = EdgesId[ie].objid,
	   		 targetos = EdgesId[ie].osnum );


		    if( !(stat&suc&1) ){
	  		printf("Error in VLcreBoundaries \n");
	  		printf("Error in EMSedge.EMgetbcgeom\n");
			goto wrapup;
		    }
		    

		    #ifdef DEBUG
		    	printf("EdgesId[%d] =%d,%d\n",EdgesId[ie].objid,
					              EdgesId[ie].osnum);
		    	printf("cv.num_poles = %d\n",cv.num_poles);
		    #endif


		    /*c evaluate the edge in the unwrap space */

		    #ifdef DEBUG
		    __DBGpr_bscv( "2d cv", &cv, &rc );		
		    #endif

		    if( cv.num_poles == 2 ){
			
			#ifdef DEBUG
			printf("case cv.num_poles == 2 \n");
			#endif

			if( fabs((cv.poles[0]-cv.poles[3]) ) < 1.0E-10 ){
				P = dev->Param_v;
		    	        MaxPts = dev->Nb_v;
			}
			else if(fabs((cv.poles[1]-cv.poles[4])) < 1.0E-10){
				P = dev->Param_u;
		    	        MaxPts = dev->Nb_u;
			   
			}
			else{
				if( dev->Nb_u > dev->Nb_v ){
					P = dev->Param_u;
					MaxPts = dev->Nb_u;
				}
				else{
					P = dev->Param_v;
		 			MaxPts = dev->Nb_v;
				}
			}

			if( lst.points ){ printf(" super dangereux \n"); 
					om$dealloc( ptr = lst.points ); }
 			lst.points = (IGRdouble *)
			om$malloc( size = 3*MaxPts*sizeof(IGRdouble));
 			if( lst.points == NULL ){
	  			printf("Error in VLcreBoundaries \n");
				printf(" malloc lst.points : Failed\n");
				goto wrapup;
 			}
				
			for(k=0;k<MaxPts;k++){
			  u = (1.0-P[k])*cv.poles[0] + P[k]*cv.poles[3];
			  v = (1.0-P[k])*cv.poles[1] + P[k]*cv.poles[4];
			  BSsfeval( dev->devsrf,u,v,0,&(lst.points[3*k]),&rc);
			}

			lst.num_points = MaxPts;

		    }
		    else{

			

			if( cv.order == 2 ){
			    
			    #ifdef DEBUG
			    printf("case cv.num_poles > 2 and cv.order == 2\n");
			    #endif

		    	    MaxPts = 3 * cv.num_poles;

			    if( lst.points ){ 
					printf(" super dangereux \n"); 
					om$dealloc( ptr = lst.points ); 
			    }

			    lst.points = NULL;
 			    lst.points = (IGRdouble *)
				    om$malloc( size = MaxPts*sizeof(IGRdouble));
 			    if( lst.points == NULL ){
	  			printf("Error in VLcreBoundaries \n");
				printf(" malloc lst.points : Failed\n");
				goto wrapup;
 			    }

			    for(k=0;k<MaxPts;k+=3)
				BSsfeval( dev->devsrf,cv.poles[k],cv.poles[k+1],
				          0,&(lst.points[k]),&rc);

			    lst.num_points = cv.num_poles;
			}
			else{

			    #ifdef DEBUG
			    printf("case cv.num_poles > 2 and cv.order > 2\n");
			    #endif

			    size_buf = sizeof(Cht);
     			    gr$get_chord_height_tolerance (
						msg 	= &rc,
						sizbuf	= &size_buf,
						buffer	= &SavedCht,
						nret	= &size_buf);

     			    Cht = SavedCht / 10000;
			    if( Cht < 0.0001 ) Cht = 0.0001;

			    #ifdef DEBUG
			    printf("cht=%f\n",Cht);
			    #endif

     			    gr$put_chord_height_tolerance (
						msg = &rc,
			 			sizbuf= &size_buf,
			 			buffer= &Cht );

			    if(pars){ om$dealloc( ptr = pars ); pars = NULL; }
			    BSchtptstcv(&cv,&lst.num_points,&(lst.points),
					&pars, &rc);

     			    gr$put_chord_height_tolerance (
						msg = &rc,
			 			sizbuf= &size_buf,
			 			buffer= &SavedCht );
	
			    MaxPts = 3 * lst.num_points;
	    
			    for(k=0;k<MaxPts;k+=3){
			       u = lst.points[k];
			       v = lst.points[k+1];
			       BSsfeval(dev->devsrf,u,v,0,&(lst.points[k]),&rc);
			    }

			    om$dealloc( ptr = pars );
			    pars = NULL; 
			}

		    }

		    /*c construct the linestring */

		    LcCv[ie].located_obj.objid = NULL_OBJID;
		    LcCv[ie].located_obj.osnum = cst->env_info->md_id.osnum;
		    LcCv[ie].module_info       = *(cst->env_info);

 		    cst->geometry	= (IGRchar *) &lst;

  		    stat=om$construct( classid = OPP_GR3dlinestr_class_id, 
	                    	      p_objid = &LcCv[ie].located_obj.objid, 
         	                      osnum   = LcCv[ie].located_obj.osnum,
		        msg     = message GRgraphics.GRaltconstruct(cst) );

		    if( !(stat&1) ){
	  		printf("Error in VLcreBoundaries \n");
	  		printf("Error in om$construct\n");
			goto wrapup;
		    }

 		    if( lst.points != NULL ){
				om$dealloc( ptr = lst.points );
				lst.points = NULL;
		    }

		    if( cv.poles ){ free( cv.poles ); cv.poles = NULL; }
		    if( cv.knots ){ free( cv.knots ); cv.knots = NULL; }
		    if( cv.weights ){ free( cv.weights ); cv.weights = NULL; }
		    if( cv.bdrys ){ free( cv.bdrys ); cv.bdrys   = NULL; }
			
	   	}/* end loop on ie */

		if( NumEdges > 1 ){

			cst->geometry = NULL;
			TmpRet[i].obj_id.objid = NULL_OBJID;
			TmpRet[i].obj_id.osnum = cst->env_info->md_id.osnum;
			TmpRet[i].mod_env      = *cst->env_info;

			stat = om$construct ( 
			       msg = message GRgraphics.GRconstruct(cst),
				 classid  = OPP_GRcompcurve_class_id,	
				 p_objid  = &TmpRet[i].obj_id.objid,
 				 osnum    = TmpRet[i].obj_id.osnum );

			if ( !(stat&1)) {
			printf(" GRgraphics.GRconstruct for comp : Failed\n");
			goto deldel1;
			}	

			stat = om$send( msg = message GRcompcurve.EMmakecomp(  
							      &suc,
							      cst->env_info,
							      (IGRlong)NumEdges,
	   						      LcCv,
							      &rotten_one  ),
				   targetid = TmpRet[i].obj_id.objid,
			           targetos = TmpRet[i].obj_id.osnum,
			           senderid = NULL_OBJID );

			if(!(stat&suc&1)) {
	  	     	    printf("Error in VLcreBoundaries \n");
		     	    printf( "EMmakecomp for loop=%d: Failed\n",i );
deldel1:
		     	    for(ie=0 ; ie<NumEdges; ie++){
     				stat = om$send(
					      msg = message GRgraphics.GRdelete(
							&suc, cst->env_info ),
             		 	targetid = LcCv[ie].located_obj.objid,
			 	targetos = LcCv[ie].located_obj.osnum,
			 	senderid = NULL_OBJID ) ;
 		            }
		            goto wrapup;
		     	}/* end if failed */

		}
		else{
			TmpRet[i].obj_id  = LcCv[0].located_obj;
			TmpRet[i].mod_env = *cst->env_info;
		}

		NumEdges = 0;
		buf_size = 0;

		if( EdgesId != NULL ){ 
			om$dealloc( ptr = EdgesId ); 
			EdgesId = NULL;
		}

		if( DisOpt == TRUE )
 		gr$display_object ( 
			object_id = (struct GRid *)&LcCv[i].located_obj,
		     	mode      = GRbd );


	}/* end loop on i */
       
	if( LoopIds != NULL ) om$dealloc( ptr = LoopIds );

	*NumObj = NumLoops;
	*ObjRet = TmpRet;

 
}/*c end if the surface has boundaries */


 cst->geometry = NULL;
 if( LcCv != NULL ) om$dealloc( ptr = LcCv );
 if( lst.points != NULL ){ om$dealloc( ptr = lst.points ); lst.points = NULL; }
 if( sf != NULL ) BSfreesf(&rc,sf);
 if( props != NULL ) om$dealloc( ptr = props );



 return MSSUCC;

wrapup:

	cst->geometry = NULL;
	if( LcCv != NULL ){ om$dealloc( ptr = LcCv ); LcCv = NULL; } 
	if( lst.points != NULL ){ om$dealloc( ptr=lst.points );lst.points=NULL;}
	if( TmpRet != NULL ){ om$dealloc( ptr = TmpRet ); TmpRet = NULL;}
	if( sf != NULL ){ BSfreesf(&rc,sf); sf = NULL; }
	if( props != NULL ){ om$dealloc( ptr = props ); props = NULL;}
	if( cv.poles ){ free( cv.poles ); cv.poles = NULL; }
	if( cv.knots ){	free( cv.knots ); cv.knots = NULL; }
	if( cv.weights ){ free( cv.weights ); cv.weights = NULL; }
	if( cv.bdrys ){	free( cv.bdrys ); cv.bdrys   = NULL; }

 	if( EdgesId != NULL ){ om$dealloc( ptr = EdgesId ); EdgesId = NULL; }
 	if( LoopIds != NULL ){ om$dealloc( ptr = LoopIds ); LoopIds= NULL; } 

	return MSFAIL;
}


/*========================================================================*/
IGRlong	VLmatchEdgeWithAtt (

	IGRshort	checkOpt,/*I  test according 2D space or 3D space */
				 /*   0 --> 2D else 3D */
struct 	mise_a_plat	*dev,	 /*I  from which we retrieve the surface ID */
	IGRint		numAtt,  /*I  number of nci_macros edge_att */
struct	GRid		*attIds, /*I  array of nci_macros edge_att */
	IGRint		numEdge, /*I  number of edges */
struct	EdgeMatch	*edgeIds, /*IO the structure containing edgeIds as
				      input and depending on SUCCESS or not
				      edgeIds->EdgeMac = attIds[i] or NULL */

	IGRlong		*suc     /*O  MSSUCC or MSFAIL	*/
)

/*d 	VLmatchEdgeWithAtt is the function that performs the real geometric
	edge matching. */

/*h 19 January  93 JLL creation date */

/*c Beginning of function */

{

struct 	IGRbsp_curve	**xyzCrvAtt, cv;
	IGRint		i, j;
	IGRlong		OmStat, msg;
	IGRint		loc_suc;
struct	GRid		AS_ELEM;
struct	GRobj_env	ELEM;

	IGRushort 	options;



/*c retrieve all the xyz edge curves attached as parents of each edge_att 
    nci_macro */

	#ifdef DEBUG
	printf("---------- VLmatchEdgeWithAtt -------------\n");
	#endif

	xyzCrvAtt  = NULL;
	cv.poles   = NULL;
	cv.weights = NULL;
	cv.knots   = NULL;
	cv.bdrys= NULL;

	xyzCrvAtt = (struct IGRbsp_curve **) 
		    om$malloc ( size = numAtt * sizeof(IGRchar *) );
        if( xyzCrvAtt == NULL ) { 
	  printf("Error in VLmatchEdgeWithAtt\n");
	  printf("Error in om$malloc of xyzCrvAtt\n");
	  goto wrapup;
	}

	for(i=0;i<numAtt;i++){

		xyzCrvAtt[i] = NULL;

  		OmStat = om$send( msg = message  ACcpx.ACfind_exp_temp_obj(
								 &loc_suc, 
							         1, 
							         &AS_ELEM ),
				  senderid = NULL_OBJID,
                    		  targetid = attIds[i].objid,
	            		  targetos = attIds[i].osnum );
  		if(!(OmStat&loc_suc&1) ){
	  		printf("Error in VLmatchEdgeWithAtt\n");
	  		printf("Error in ACfind_exp_temp_obj = %d\n",i);
			goto wrapup;
		}

  		OmStat = om$send( msg      = message NDmacro.ACreturn_foot(	
					&msg ,
					"",
					&ELEM.obj_id, 
					&ELEM.mod_env.md_env.matrix_type, 
					ELEM.mod_env.md_env.matrix ),
				  senderid = NULL_OBJID,
	   			  targetid = AS_ELEM.objid,
	   			  targetos = AS_ELEM.osnum );
  		if(!(OmStat&msg&1) ){
	  		printf("Error in VLmatchEdgeWithAtt\n");
	  		printf("Error in ACreturn_foot = %d\n",i);
			goto wrapup;
		}

   		ELEM.mod_env.md_id.osnum = ELEM.obj_id.osnum;
		xyzCrvAtt[i] = NULL;
		OmStat = VLgetGeometry( &ELEM, (IGRboolean) FALSE, NULL_OBJID, 
 			       		 (IGRchar **)&xyzCrvAtt[i], &msg );
                if(!(OmStat&msg&1)) {
	  		printf("Error in VLmatchEdgeWithAtt\n");
	  		printf("Error in VLgetGeometry = %d\n",i);
 			goto wrapup;
		}

	}


/*c loop on all the edge_att nci_macros to get the 3D graphic edge att and
    then performes the comparaison test.
    if no edge_att is found the  edgeIds->EdgeMac.objid is set to NULL else
    we store the edge_att GRid */ 

	options = 0;

    	if( checkOpt == 0 ){

	    for(i=0; i<numEdge; i++){

		   OmStat = om$send ( msg      = message EMSedge.EMgetbcgeom(
							&msg,
            						(IGRint) 0,
            						(IGRint) OM_K_MAXINT,
							(IGRboolean) FALSE,
							NULL,
			     				&cv,
				        		NULL,
							options ),
			 senderid = NULL_OBJID,
	   		 targetid = edgeIds[i].EdgeId.objid,
			 targetos = edgeIds[i].EdgeId.osnum );

		   if( !(OmStat&msg&1) ){
	  		printf("Error in VLmatchEdgeWithAtt\n");
	  		printf("Error in EMSedge.EMgetbcgeom = %d\n",i);
 			goto wrapup;
		   }


	    }

    	}/* end checkOpt == 0, for edges in uv space */

    	else{

	    for(i=0; i<numEdge; i++){

		/*d retrieve the xyz bspline edge */

		OmStat = om$send ( msg = message EMSedge.EMget_bcxyz_geom( 
					&msg,
					(struct GRmdenv_info *) NULL,
					(struct GRid *) NULL,
					(struct IGRbsp_surface *)dev->surface,
            				(IGRint) 0,
            				(IGRint) OM_K_MAXINT,
					(IGRboolean) FALSE,
					(struct EMSpartedinfo  *)NULL,
			     		&cv ),

			 senderid = NULL_OBJID,
	   		 targetid = edgeIds[i].EdgeId.objid,
			 targetos = edgeIds[i].EdgeId.osnum );

		 if( !(OmStat&msg&1) ){
	  		printf("Error in VLmatchEdgeWithAtt\n");
	  		printf("Error in EMSedge.EMget_bcxyz_geom = %d\n",i);
 			goto wrapup;
		 }

		
		    #ifdef DEBUG
		    __DBGpr_bscv( "2D cv", &cv, &msg );	
		    #endif

		/* check which 2D edge is matching with the curve attribut */

		for(j=0; j<numAtt; j++){
		   edgeIds[i].EdgeMac.objid = NULL_OBJID;
		   if( xyzCrvAtt[j] != NULL ){

		        #ifdef DEBUG
		    	__DBGpr_bscv( "xyz cv", xyzCrvAtt[j], &msg );	
			#endif

			if( VLcheck3DCrv( xyzCrvAtt[j], &cv ) == TRUE ){
				#ifdef DEBUG
				printf("edge att = %d coincide with %d\n",j,i);
				#endif
				edgeIds[i].EdgeMac = attIds[j];
				om$dealloc( ptr = xyzCrvAtt[j] );
				xyzCrvAtt[j] = NULL;
				break;
			}
		   }
		}

		if( cv.poles ){ free( cv.poles ); cv.poles = NULL; }
		if( cv.knots ){	free( cv.knots ); cv.knots = NULL; }
		if( cv.weights ){ free( cv.weights ); cv.weights = NULL; }
		if( cv.bdrys ){	free( cv.bdrys ); cv.bdrys   = NULL; }

	    }/*end loop i */



    	}/*end checkOpt # 0, we check the coincidence against 3D edges*/





	for(i=0;i<numAtt;i++){
		if( xyzCrvAtt[i] != NULL ) {
			om$dealloc( ptr = xyzCrvAtt[i] );
			xyzCrvAtt[i] = NULL;
		}
	}

	if( xyzCrvAtt != NULL ){
		om$dealloc( ptr = xyzCrvAtt );
		xyzCrvAtt = NULL;
	}

	*suc = MSSUCC;
	return(MSSUCC);



wrapup:

	if( cv.poles ){ free( cv.poles ); cv.poles = NULL; }
	if( cv.knots ){	free( cv.knots ); cv.knots = NULL; }
	if( cv.weights ){ free( cv.weights ); cv.weights = NULL; }
	if( cv.bdrys ){	free( cv.bdrys ); cv.bdrys   = NULL; }

	for(i=0;i<numAtt;i++){
		if( xyzCrvAtt[i] != NULL ) {
			om$dealloc( ptr = xyzCrvAtt[i] );
			xyzCrvAtt[i] = NULL;
		}
	}

	if( xyzCrvAtt != NULL ){
		om$dealloc( ptr = xyzCrvAtt );
		xyzCrvAtt = NULL;
	}

	*suc = MSFAIL;
	return(MSFAIL);

}


/*=========================================================================*/

IGRlong	VLedgeMatch( dev, NumLoops, LoopIndex, NumEdges, EdgeList, suc )

/*d  VLedgeMatch  retrieves all the 2D edges forming
     a genbs surface and then performs the edge matching between
     3D edge_att and the 3D representaion of the 2D edges. */

/*h 18 January 93 JLL creation date */

struct 	mise_a_plat	*dev;	    /*I from which we retrieve the surface ID */
	IGRint		*NumLoops;  /*O number of close loops */ 
	IGRint		**LoopIndex;/*O we store the nb of edges per loop */
	IGRint		*NumEdges;  /*O total number of edges */
struct  EdgeMatch	**EdgeList; /*O the edge list */
	IGRlong		*suc;       /*O MSSUCC, MSFAIL */

/*c Beginning of function */

{

  IGRlong		stat, retMsg;
  IGRint 		i, j, ie;

  GRobjid		*LoopIds;
  IGRint		buf_size;
  struct	GRid    *EdgesId;
  OM_S_CHANSELECT 	chanloopset;
  IGRuint		nb_loopset;
  IGRlong		option;
  IGRint		depth;
  IGRint		CurNumEdges;
  	IGRushort 	options;
  OM_S_OBJECT_LINKAGE	listLOOPSET;
  	IGRushort	*props;
  IGRint		*locLoopIndex;
  struct EdgeMatch	*locEdgeList;
  IGRint		numMacros;
  struct GRid		*macrosId;
  struct GRid	        GObj;
  struct GRmd_env       EnvGObj;
  struct GRobj_env	TravId;



	#ifdef DEBUG
	printf("--------------VLedgeMatch ------------\n");
	#endif

  	stat = OM_S_SUCCESS;
	locLoopIndex = NULL;
	locEdgeList  = NULL;
	LoopIds      = NULL;
	props	     = NULL;
	EdgesId	     = NULL;
	macrosId     = NULL;

 	/*c We look for the EMSloopset , first check if have one */ 

	chanloopset.type		= OM_e_num;
	stat = om$get_channel_number ( channame  = "EMSsubbs.to_loopset",
				       p_channum = &chanloopset.u_sel.number );
	if ( ! (stat&1)) {
	  printf("Error in VLedgeMatch \n");
	  printf("Error get_channel_number loopset\n"); 
	  goto wrapup;
	}


   GObj.objid = NULL_OBJID;

   stat = om$send( msg      = message NDnode.ASreturn_go( 
					&GObj,
					&EnvGObj.md_env.matrix_type,
    					EnvGObj.md_env.matrix ),
    		senderid = NULL_OBJID, 
   		targetid = dev->surf_id.obj_id.objid, 
   		targetos = dev->surf_id.obj_id.osnum );
 
  if( !( 1 & stat ) ){
	GObj.objid = dev->surf_id.obj_id.objid;
	GObj.osnum = dev->surf_id.obj_id.osnum;
  }

	/*c retrieve the loopset id */

	listLOOPSET.S_objid = NULL_OBJID;
	stat = om$get_channel_objects(    
				osnum	        = GObj.osnum,
				objid	        = GObj.objid,
				p_chanselect	= &chanloopset,
				size		= 1,
				count		= &nb_loopset,
				list		= &listLOOPSET );
	if ( ! (stat&1)) {
	  printf("Error in VLedgeMatch \n");
	  printf("Error No loopset to this element : No a surface with bnd\n");
	  goto wrapup;
	}

	#ifdef DEBUG
	printf("nb_loopset=%d\n",nb_loopset);
	#endif
	
	/*c retrieve the number of loops */

	option  = EMS_OPT_ALL;
  	LoopIds = NULL;
  	props   = NULL;
	depth   = OM_K_MAXINT;
	buf_size = 0;

	stat = om$send ( msg = message EMSloopset.EMget_loops( 	&retMsg,
								option,
								&depth,
								&LoopIds,
								&props,
								&buf_size,
								NumLoops ),
		    senderid = NULL_OBJID,
		    targetid = listLOOPSET.S_objid,
		    targetos = listLOOPSET.osnum );

	if ( !(stat&retMsg&1)) {
	  printf("Error in VLedgeMatch \n");
	  printf("Error in EMSloopset.EMget_loops\n");
	  goto wrapup;
	}
	
	#ifdef DEBUG
	printf("Total NumLoops=%d\n",(*NumLoops));
	#endif 

	/*c malloc the array containing the number of edges per loop */

 	locLoopIndex = (IGRint *) 
			om$malloc( size = (*NumLoops) * sizeof(IGRint) );
 	if( locLoopIndex == NULL ){
	  	printf("Error in VLedgeMatch \n");
		printf(" malloc locLoopIndex : Failed\n");
		goto wrapup;
	}




	/*c find the maximun number of edges in loops */

	j = 0;
	options = 0;

	stat = om$send ( msg = message EMSboundary.EMcount_edges(
							&retMsg, option, &j ),
	            senderid = NULL_OBJID,
		    targetid = listLOOPSET.S_objid,
		    targetos = listLOOPSET.osnum );
	if ( !(stat&retMsg&1)) {
	 	printf("Error in VLcreBoundaries \n");
	  	printf("Error in EMSboundary.EMcount_edges\n");
	  	goto wrapup;
	}


	#ifdef DEBUG
	printf(" num edges  = %d\n",j);
	#endif

	option = EMS_OPT_ALL;

	/* malloc the array to build the 2D edges match structure */

 	locEdgeList = (struct  EdgeMatch *) 
        om$malloc( size = j * (*NumLoops) * sizeof( struct  EdgeMatch ) );
 	if( locEdgeList == NULL ){
		printf(" malloc locEdgeList : Failed\n");
		goto wrapup;
	}

	EdgesId = NULL;
	depth = 1;
	CurNumEdges = 0;
	buf_size = 0;
	*NumEdges = 0;


	/*c here we store for each loop the number of edges in LoopsIndex.
	    edgesId are store sequentially in EdgeList. */
	

	
	for(i=0;i<(*NumLoops);i++){

		#ifdef DEBUG
		printf("enter EMget_edges = LoopIds[%d]=%d\n",i,LoopIds[i]);
		#endif

		CurNumEdges = 0;

		stat = om$send ( msg = message EMSboundary.EMget_edges( 
						&retMsg,
						depth,
						option,
						&EdgesId,
						&buf_size,
						&CurNumEdges ),
			    senderid = NULL_OBJID,
		            targetid = LoopIds[i],
			    targetos = listLOOPSET.osnum  );

		if ( !(stat&retMsg&1)) {
	 		printf("Error in VLedgeMatch \n");
	  		printf("Error in EMSboundary.EMget_edges\n");
	  		goto wrapup;
		}

		#ifdef DEBUG
		printf("CurNumEdges=%d\n",CurNumEdges);
		#endif

	   	for(ie=0;ie<CurNumEdges;ie++){

		    #ifdef DEBUG
		    	printf("EdgesId[%d] =%d,%d\n",ie, EdgesId[ie].objid,
					                  EdgesId[ie].osnum);
		    #endif

		    locEdgeList[*NumEdges].EdgeId = EdgesId[ie]; 
		    *NumEdges	+= 1;


		}

		locLoopIndex[i] = CurNumEdges;

		CurNumEdges = 0;
		buf_size = 0;
		if( EdgesId != NULL ){ 
			om$dealloc( ptr = EdgesId ); 
			EdgesId = NULL;
		}

	}


	*LoopIndex = locLoopIndex;
	*EdgeList  = locEdgeList;
	if( props != NULL )        om$dealloc( ptr = props );
 	if( EdgesId != NULL )	   om$dealloc( ptr = EdgesId ); 
 	if( LoopIds != NULL )      om$dealloc( ptr = LoopIds );


	/*d We retieve now all the nci_macros edge_attr attach to the surface */
        as$make_source(go_grid = dev->surf_id.obj_id,
                       mod_env = &dev->surf_id.mod_env,
                       as_grid = &TravId.obj_id);

	stat = VLgetChildrenMacro( TravId, "edge_att", 
				    &numMacros, &macrosId, &dev->res_id );
	if( stat != MSSUCC ){
	 	printf("Error in VLedgeMatch \n");
	  	printf("VLgetChildrenMacro Failed\n");
		goto wrapup;
	}

        if( numMacros == 0 )
        {
            stat = VLgetChildrenMacro( TravId, "VSedge3Datt",
                                   &numMacros, &macrosId, &dev->res_id );
            if( stat != MSSUCC ){
                 printf("Error in VLedgeMatch \n");
                 printf("VLgetChildrenMacro Failed\n");
            }
        }

	#ifdef DEBUG
	printf("numMacros edge_att = %d\n",numMacros);	
	#endif

	if( numMacros == 0 ){
		for(ie=0;ie<(*NumEdges);ie++)
			locEdgeList[ie].EdgeMac.objid = NULL_OBJID;
	}
	else{
		/*d edge_att exist so we perform matching between 
		    3D and 2D edges */

		   VLmatchEdgeWithAtt( 1, dev, numMacros, macrosId, 
					(*NumEdges), locEdgeList, &retMsg );
		   if( retMsg != MSSUCC ) goto wrapup;
	}

	if( macrosId != NULL ) om$dealloc( ptr = macrosId );

	*suc = MSSUCC;
	return(MSSUCC);


wrapup:
	*suc = MSFAIL;
	*NumEdges  = 0;
	*NumLoops = 0;
	if( locLoopIndex != NULL ) om$dealloc( ptr = locLoopIndex );
	if( locEdgeList != NULL)   om$dealloc( ptr = locEdgeList );
	if( props != NULL )        om$dealloc( ptr = props );
 	if( EdgesId != NULL )	   om$dealloc( ptr = EdgesId ); 
 	if( LoopIds != NULL )      om$dealloc( ptr = LoopIds );
	if( macrosId != NULL ) 	   om$dealloc( ptr = macrosId );
	*LoopIndex = NULL;
	*EdgeList  = NULL;

	return(MSFAIL);
}	
/*=========================================================================*/

IGRint VLcheck3DCrv( xyzCvAtt, crv )

/*d this function checks if two object are coinciendent */

/*h 22 january 93  JLL cretaion date */

struct	IGRbsp_curve	*xyzCvAtt;
struct	IGRbsp_curve	*crv;

/*c Beginning of function */
 
{
IGRint		j,i, strtIndex, endIndex;
IGRdouble	tol;
IGRlong		suc;
	IGRdouble	activCht, cht;
	IGRint		size_buf;



  /*c get the active cht */

  size_buf = sizeof(cht);
  gr$get_chord_height_tolerance ( 	msg 	= &suc,
				  	sizbuf	= &size_buf,
					buffer	= &activCht,
					nret	= &size_buf	);
  tol  = 2.* activCht;
/*
	if( xyzCvAtt->num_poles != crv->num_poles ){
		#ifdef DEBUG
		printf("VLcheck3DCrv: xyzCvAtt->num_poles # crv->num_poles\n");
		#endif
		return(FALSE);
	}
*/
	
	for(i=0;i<3;i++)
	if( fabs( (xyzCvAtt->poles[i]-crv->poles[i]) ) > tol ){
		#ifdef DEBUG
		printf("VLcheck3DCrv: start poles #\n");
		__DBGpr_double("xyzCvAtt",&xyzCvAtt->poles[0],3,3);
		__DBGpr_double("crv",&crv->poles[0],3,3);
		#endif
		return(FALSE);
	} 
/*
	strtIndex = 3 * (xyzCvAtt->num_poles / 2);
	if( strtIndex > 0 ){
		endIndex = strtIndex + 3;
		for(i=strtIndex;i<endIndex;i++)
		if(fabs((xyzCvAtt->poles[i]-crv->poles[i]))>tol){
		    #ifdef DEBUG
		    printf("VLcheck3DCrv: midle poles #\n");
		    __DBGpr_double("xyzCvAtt",&xyzCvAtt->poles[strtIndex],3,3);
		    __DBGpr_double("crv",&crv->poles[strtIndex],3,3);
		    #endif
		    return(FALSE);
		} 
	}
*/

	strtIndex = 3 * (xyzCvAtt->num_poles-1);
	endIndex = strtIndex + 3;
        j = 3*(crv->num_poles-1);
	for(i=strtIndex;i<endIndex;i++,j++)
	if(fabs( (xyzCvAtt->poles[i]- crv->poles[j]) ) > tol){
		    #ifdef DEBUG
		    printf("VLcheck3DCrv: end poles #\n");
		    __DBGpr_double("xyzCvAtt",&xyzCvAtt->poles[strtIndex],3,3);
		    __DBGpr_double("crv",&crv->poles[strtIndex],3,3);
		    #endif
		    return(FALSE);
	}
		
        return(TRUE);
	
}
/*==========================================================================*/

IGRlong VLisOffNeeded( /*EdgeList*/OfVal, fromIndex, toIndex, OuiNon )
/*d this small function just defines if for a given edge list that 
    represents a loop, it is necessary or not to perform an offset curve. */

/*struct  EdgeMatch	*EdgeList;*/	/*I the entire list of object */
double			*OfVal;
IGRint			fromIndex;	/*I the from index to start to search */
IGRint			toIndex;	/*I the ind search index */
IGRint			*OuiNon;	/*O TRUE if offset needed or FALSE */


/*c beginning of code */

{
	IGRint	i, numEdge;

	numEdge = toIndex - fromIndex;

	if( numEdge == 0 ){
		*OuiNon = FALSE;
		 printf("Error numEdge = 0 in VLisOffNeeded\n");
		 return(MSFAIL);
	}

	*OuiNon = TRUE;

	for(i=fromIndex;i<toIndex;i++){
		//if( EdgeList[i].EdgeMac.objid != NULL_OBJID )return(MSSUCC); 
                if (OfVal[i] >= 0.00001 || OfVal[i] <= -0.00001) return(MSSUCC);
	}

	*OuiNon = FALSE;
	return(MSSUCC);

}
/*==========================================================================*/
IGRlong VLbuildUnwrapEdge( dev, uvEdgeId, activCht, cht, cst, 
			    UnwrapEdgeId, suc )

/*d this fucntion evaluates the 2D unwraped edge according his uv 
    representation in the uv space. the idea his to say that between the
    the 3D surface and the 2D unwraped surface the space is no modifyed.
    This for sure an approximation that looks valid in pratical case */

/*h 25 January 93 JLL creation date */

struct 	mise_a_plat	*dev;		/*I dev structure to use the 3D surface
					    and its 2D unwraped evaluation */
struct	GRid		*uvEdgeId;	/*I the edge in uv space */
	IGRdouble	activCht;	/*I the 3d active cht use as a backup */
	IGRdouble	cht;		/*  cht that you want to apply to
					    perfom the stroking */
struct	GRvg_construct	*cst;		/*I construction list */
struct	GRobj_env	*UnwrapEdgeId;  /*O the 2D unwraped edge */
	IGRlong		*suc;		/*O MSSUCC or MSFAIL */

/*c Beginning of function */

{

	 IGRlong	OmStat;
struct 	 IGRpolyline	lst;
struct   IGRbsp_curve	cv;
	 IGRushort 	options;
	 IGRdouble	*P;
	 IGRint		MaxPts;
	 IGRdouble	*pars, u, v;
	 IGRint		k,jj;
  	 IGRint		size_buf;
         double         ptDr[3],vecDr[6];
static   int            bound_count=0; /* used in the case of ARC_LENGTH 
                                          tesselation option. this the 
                                          number of the edge of the plate */

	#ifdef DEBUG
	printf("------------------ VLbuildUnwrapEdge --------------\n");
	#endif

        if (bound_count == 4) bound_count = 0;

	options = 0;
 	cv.poles   = NULL;
 	cv.knots   = NULL;
 	cv.weights = NULL;
 	cv.bdrys = NULL;
	UnwrapEdgeId->obj_id.objid = NULL_OBJID;
	pars       = NULL;
	lst.points = NULL;

	#ifdef DEBUG
	printf("cht = %f, activCht = %f\n", cht, activCht);
	#endif

	/*c retrieve the uv space definition of the edge  */

	OmStat = om$send ( msg      = message EMSedge.EMgetbcgeom(
							suc,
            						(IGRint) 0,
            						(IGRint) OM_K_MAXINT,
							(IGRboolean) FALSE,
							NULL,
			     				&cv,
				        		NULL,
							options ),
		 senderid = NULL_OBJID,
		 targetid = uvEdgeId->objid,
		 targetos = uvEdgeId->osnum );

	if( !(OmStat&1) ){
	  	printf("Error in VLbuildUnwrapEdge \n");
	  	printf("EMSedge.EMgetbcgeom Failed\n");
		goto wrapup;
	}

	#ifdef DEBUG 
	    printf(" num_poles = %d, order=%d\n",cv.num_poles, cv.order);
	    __DBGpr_bscv( "2d cv", &cv, suc ); 

	#endif 



	if( cv.num_poles == 2 ){

          if (dev->tesselation_option == ARC_LENGTH) {
           /* by construction, we computed dev->Param_u and dev->Nb_u
              on this two edges */
            if (bound_count == 0 || bound_count == 2) {
              P = dev->Param_u;
              MaxPts = dev->Nb_u;
            }
            else {
           /* by construction, we computed dev->Param_v and dev->Nb_v
              on this two edges */
              P = dev->Param_v;
              MaxPts = dev->Nb_v;
            }

            lst.points = NULL;
            lst.points = (IGRdouble *)
            om$malloc( size = 3*MaxPts*sizeof(IGRdouble));
            if( lst.points == NULL ){
                    printf("Error in VLbuildUnwrapEdge \n");
                    goto wrapup;
            }

              for(k=0;k<MaxPts;k++){
                u = (1.0-P[k])*cv.poles[0] + P[k]*cv.poles[3];
                v = (1.0-P[k])*cv.poles[1] + P[k]*cv.poles[4];
                BSsfevaln(dev->surface,u,v,1,&jj,ptDr,vecDr,suc);
                FAevPtSfFaDr((IGRshort) 3,dev->P,dev->devsrf,
                            dev->def, ptDr, vecDr, u,v,
                            &(lst.points[3*k]),suc);
             }
 	     lst.num_points = MaxPts;
          }
          else {
		
		/*c check if it an iso curve in u or in v */
		/*c if true then MaxPts, the number of points to evaluate
		    along the iso will be equal to the number of points
		    for the tessalation 
		    else the MaxPts will be set to the sup between the number
		    in u and v.  */

		if( fabs((cv.poles[0]-cv.poles[3]) ) < 1.0E-10 ){

			#ifdef DEBUG
			printf("constant in u\n");
			#endif

                          P = dev->Param_v;
                          MaxPts = dev->Nb_v;

			lst.points = NULL;
 			lst.points = (IGRdouble *)
			om$malloc( size = 3*MaxPts*sizeof(IGRdouble));
 			if( lst.points == NULL ){
	  			printf("Error in VLbuildUnwrapEdge \n");
				printf(" malloc 1 lst.points : Failed\n");
				goto wrapup;
 			}
				
			  for(k=0;k<MaxPts;k++){
			    u = (1.0-P[k])*cv.poles[0] + P[k]*cv.poles[3];
			    v = (1.0-P[k])*cv.poles[1] + P[k]*cv.poles[4];
			    BSsfeval( dev->devsrf,u,v,0,&(lst.points[3*k]),suc);
			  }
		}
		else if(fabs((cv.poles[1]-cv.poles[4])) < 1.0E-10){

			#ifdef DEBUG
			printf("constant in v\n");
			#endif

                          P = dev->Param_u;
                          MaxPts = dev->Nb_u;

			lst.points = NULL;
 			lst.points = (IGRdouble *)
			om$malloc( size = 3*MaxPts*sizeof(IGRdouble));
 			if( lst.points == NULL ){
	  			printf("Error in VLbuildUnwrapEdge \n");
				printf(" malloc 2 lst.points : Failed\n");
				goto wrapup;
 			}

			  for(k=0;k<MaxPts;k++){
			    u = (1.0-P[k])*cv.poles[0] + P[k]*cv.poles[3];
			    v = (1.0-P[k])*cv.poles[1] + P[k]*cv.poles[4];
			    BSsfeval( dev->devsrf,u,v,0,&(lst.points[3*k]),suc);
                          }

		}
		else{

			/*c we got a lineseg in the uv space that is not
			    parallel to the axis. We should have done a
			    stroking according the 3D cht to get the real
			    uv list. Because no approximation in the uv
			    space, this case appears just if the surface is
			    a plane */
		
			MaxPts = 6;
			lst.points = NULL;
 			lst.points = (IGRdouble *)
			om$malloc( size = MaxPts*sizeof(IGRdouble));
 			if( lst.points == NULL ){
	  			printf("Error in VLbuildUnwrapEdge \n");
				printf(" malloc 3 lst.points : Failed\n");
				goto wrapup;
 			}

			  for(k=0;k<MaxPts;k+=3){
			    BSsfeval( dev->devsrf,cv.poles[k], cv.poles[k+1],
				      0,&(lst.points[k]),suc);
                          }
			
			MaxPts = 2;
		}
                lst.num_points = MaxPts;
          }

	}/* we got a BSedge with just two poles */

	else{

		if( cv.order == 2 ){
		    MaxPts = 3 * cv.num_poles;
		    lst.points = NULL;
 		    lst.points = (IGRdouble *)
				  om$malloc( size = MaxPts*sizeof(IGRdouble));
 		    if( lst.points == NULL ){
	  		printf("Error in VLbuildUnwrapEdge \n");
			printf(" malloc 4 lst.points : Failed\n");
			goto wrapup;
 		    }

                    if (dev->tesselation_option == PARAMETRIC){
		      for(k=0;k<MaxPts;k+=3) {
			 BSsfeval( dev->devsrf,cv.poles[k],cv.poles[k+1],
				          0,&(lst.points[k]),suc);
                      }
                    }
		    else{
		      for(k=0;k<MaxPts;k+=3) {
                         BSsfevaln(dev->surface,cv.poles[k],cv.poles[k+1],1,
                                   &jj,ptDr,vecDr,suc);
                         FAevPtSfFaDr((IGRshort) 3,dev->P,dev->devsrf,dev->def,
                                      ptDr, vecDr, cv.poles[k],cv.poles[k+1],
                                      &(lst.points[k]),suc);
                      }
                    }

		    lst.num_points = cv.num_poles;


		} /* the BSedge is a linestring with more than 2 poles */

		else{

			size_buf = sizeof(IGRdouble);

     			gr$put_chord_height_tolerance (
						msg = suc,
			 			sizbuf= &size_buf,
			 			buffer= &cht );

			#ifdef DEBUG
			printf("Enter BSchtptstcv\n");
			#endif

			BSchtptstcv(&cv,&lst.num_points,&(lst.points),
					&pars, suc);
			
			#ifdef DEBUG
			printf("Exit BSc lst.num_points = %d\n",lst.num_points);
			#endif

     			gr$put_chord_height_tolerance (
						msg = suc,
			 			sizbuf= &size_buf,
			 			buffer= &activCht );
	
			MaxPts = 3 * lst.num_points;

                        if (dev->tesselation_option == PARAMETRIC){
			  for(k=0;k<MaxPts;k+=3){
			       u = lst.points[k];
			       v = lst.points[k+1];
			       BSsfeval(dev->devsrf,u,v,0,&(lst.points[k]),suc);
                          }
			}
		        else{
			  for(k=0;k<MaxPts;k+=3){
			       u = lst.points[k];
			       v = lst.points[k+1];
   			       BSsfevaln(dev->surface,u,v,1,&jj,ptDr,vecDr,suc);
                               FAevPtSfFaDr((IGRshort) 3,dev->P,dev->devsrf,
                                            dev->def, ptDr, vecDr, u,v,
                                            &(lst.points[k]),suc);
                          }
			}

			om$dealloc( ptr = pars );
			pars = NULL; 

		}/* the order of this BSedge is > 2 */

	}/* we got a BSedge with more than two poles */


	/*c construct the linestring */

	UnwrapEdgeId->obj_id.objid = NULL_OBJID;
	UnwrapEdgeId->obj_id.osnum = cst->env_info->md_id.osnum;
     	memcpy ( (IGRchar *)&UnwrapEdgeId->mod_env,(IGRchar *)cst->env_info,
	         (IGRint) sizeof( struct GRmd_env) );

 	cst->geometry	= (IGRchar *) &lst;

  	OmStat=om$construct( classid = OPP_GR3dlinestr_class_id, 
	                     p_objid = &UnwrapEdgeId->obj_id.objid, 
         	             osnum   = UnwrapEdgeId->obj_id.osnum,
		             msg     = message GRgraphics.GRaltconstruct(cst) );
	if( !(OmStat&1) ){
	  	printf("Error in VLbuildUnwrapEdge \n");
	  	printf(" om$construct Failed\n");
		goto wrapup;
	}
        if (dev->tesselation_option == ARC_LENGTH) bound_count++;

	if(pars){ om$dealloc( ptr = pars ); pars = NULL; }
	if(lst.points){ om$dealloc( ptr = lst.points ); lst.points = NULL;}
	if( cv.poles ){ free( cv.poles ); cv.poles = NULL; }
	if( cv.knots ){	free( cv.knots ); cv.knots = NULL; }
	if( cv.weights ){ free( cv.weights ); cv.weights = NULL; }
	if( cv.bdrys ){	free( cv.bdrys ); cv.bdrys   = NULL; }

 	cst->geometry	= NULL;
	*suc = MSSUCC;
	return(MSSUCC);


wrapup:
 	cst->geometry	= NULL;
	if( cv.poles ){ free( cv.poles ); cv.poles = NULL; }
	if( cv.knots ){	free( cv.knots ); cv.knots = NULL; }
	if( cv.weights ){ free( cv.weights ); cv.weights = NULL; }
	if( cv.bdrys ){	free( cv.bdrys ); cv.bdrys   = NULL; }

	if(pars){ om$dealloc( ptr = pars ); pars = NULL; }
	if(lst.points){ om$dealloc( ptr = lst.points ); lst.points = NULL;}
	*suc = MSFAIL;
	return(MSFAIL);

}
/*===========================================================================*/

IGRlong  VLretMaxOfVal (NumEdges,EdgeList, mod_env, MaxOfVal, suc)
int			NumEdges;
struct  EdgeMatch	*EdgeList;
struct  GRmd_env        *mod_env;
IGRdouble		*MaxOfVal;
IGRlong			*suc;
{
IGRlong			sts;
IGRint			loc_msg;
IGRint			i;
struct ret_struct	expr;
double			fbs;

  *suc = MSFAIL;
  if (EdgeList == NULL || MaxOfVal == NULL) goto quit;
  *MaxOfVal = 0;
  for (i=0;i<NumEdges;i++) {
   // we want the "R" type only 
    if (EdgeList[i].EdgeMac.objid == NULL_OBJID) continue;
    sts = om$send( msg = message ACcpx.ACfind_exp_temp_struct(
                                                &loc_msg,
                                                2,
                                                (struct ret_struct *) &expr,
                                                mod_env),
            senderid = NULL_OBJID,
            targetid = EdgeList[i].EdgeMac.objid,
            targetos = EdgeList[i].EdgeMac.osnum );

    if( !(sts&loc_msg&1) ) goto quit;
    if (expr.var.text_st.text_string[0] != 'R') continue;

    sts = om$send( msg = message ACcpx.ACfind_exp_temp_struct( 
						&loc_msg,
						3,
						(struct ret_struct *) &expr,
						mod_env),
            senderid = NULL_OBJID,
            targetid = EdgeList[i].EdgeMac.objid,
            targetos = EdgeList[i].EdgeMac.osnum );

    if( !(sts&loc_msg&1) ) goto quit;
    if (expr.var.root_pm_st.value > 0) continue;
    fbs = fabs(expr.var.root_pm_st.value);
    if (*MaxOfVal < fbs) *MaxOfVal = fbs;
  }
  
  *suc = MSSUCC;
quit :
   return *suc;
}

IGRlong  VLretOfVal( EdgeMac, OfVal, suc )

/*d just a small function to retrieve the offset value attached to one edge */

/*h 25 january 93 JLL creation date */

struct	GRid		*EdgeMac;	/*I edge_att macro id */
	IGRdouble	*OfVal;		/*O the offset return */
	IGRlong		*suc;		/*I MSSUCC or MSFAIL */


/*c beginning of code */
{


	IGRlong		OmStat;
struct GRid		box, defId;
       int		num;
       double		gap;
       char		*macDef;
struct ACrg_coll	list_att[ATT_NB_ATT];

  if( EdgeMac->objid == NULL_OBJID ){
	*OfVal = 0.0;
  	*suc = MSSUCC;
  	return(MSSUCC);
  }

  OmStat = om$send(  msg      = message ACcpx.find_macro( &defId ),
		     senderid = NULL_OBJID,
                     targetid = EdgeMac->objid,
                     targetos = EdgeMac->osnum  );
  if( !(OmStat&&1) ) goto wrapup;

  OmStat = om$send(  msg      = message ACcpx_defn.ACgive_name( &macDef ),
                     senderid = NULL_OBJID,
                     targetid = defId.objid,
                     targetos = defId.osnum  );
  if( !(OmStat&&1) )  goto wrapup;

  if( !strcmp( macDef, "Bevel"     ) ||
      !strcmp( macDef, "EJ_Bevel"  ) ||
      !strcmp( macDef, "VA_Bevel"  ) ||
      !strcmp( macDef, "Fab_Stock" ) )
  {
	struct ACrg_coll attrib;

	strcpy( attrib.name, "stock_value" );
     	// find the box
	OmStat = om$send( msg     = message  ACcpx.ACfind_exp_temp_obj(
                                                         (IGRint *)suc,
                                                         0,
                                                         &box ),
                    senderid = NULL_OBJID,
                    targetid = EdgeMac->objid,
                    targetos = EdgeMac->osnum );
  	if(!(OmStat&(*suc)&1) ) goto wrapup;

  	OmStat = om$send(msg = message ACrg_collect.ACget_named_attribute
                                        ( suc, &attrib ) ,
                       senderid = NULL_OBJID,
                       targetid = box.objid,
                       targetos = box.osnum);
  	if(!(OmStat&(*suc)&1) ) goto wrapup;

        *OfVal = attrib.desc.value.att_exp;
        *suc = MSSUCC;
        return(MSSUCC);
  }

  gap = 0.0;

    // find the box
  OmStat = om$send( msg     = message  ACcpx.ACfind_exp_temp_obj(
          					         (IGRint *)suc,
                                                         ATT_T_IDX_BOX,
                                                         &box ),
                    senderid = NULL_OBJID,
                    targetid = EdgeMac->objid,
                    targetos = EdgeMac->osnum );
  if(!(OmStat&(*suc)&1) ) goto wrapup;

  OmStat = om$send(msg = message ACrg_collect.AClist_attribute
                                        (suc,ATT_NB_ATT,list_att,&num),
                       senderid = NULL_OBJID,
                       targetid = box.objid,
                       targetos = box.osnum);
  if(!(OmStat&(*suc)&1) ) goto wrapup;

  if (num < ATT_IDX_ALLOWANCE) goto wrapup;

/*
  if (strcmp(list_att[ATT_IDX_TYPE_ANGLE].desc.value.att_txt,DEFAULT_ANGLE)) {
	*OfVal = 0.0;
        *suc = MSSUCC;
        return(MSSUCC);
  }
*/

  *OfVal  = list_att[ATT_IDX_ALLOWANCE].desc.value.att_exp;
  if( VLunwBevelGetGap( EdgeMac, NULL, NULL, &gap ) )
  {
	*OfVal -= 0.5*gap;
	//*OfVal -= 0.5*list_att[ATT_IDX_V].desc.value.att_exp;
  }
  *suc = MSSUCC;
  return(MSSUCC);
  

wrapup:
	*OfVal = 0.0;
	*suc = MSFAIL;
	return(MSFAIL);
}



/*==========================================================================*/

IGRlong VLdropCompCrv( CompId, numComp, ListIds, index, suc )

/*d this function find the components of a composite curve and places it 
    in the ListIds array starting at the index value. Index is then updated. */
 
/*h 25 January 1993 JLL cration date */

struct	GRobj_env	*CompId;	/*I composite curve ID */
IGRint			numComp;	/*I if you know it then give it
					    else put 0 */
struct	GRid		*ListIds;	/*O the component list, this is
					    the responsability of the caller
					    to malloc */
IGRint			*index;		/*IO current index where to store,
					     then value updated */
IGRlong			*suc;		/*O MSSUCC MSFAIL */


/*c beginning of code */

{

IGRint	locNumComp;
IGRint	numRet;
IGRlong	OmStat;

if( numComp == 1 ){
	ListIds[*index] = CompId->obj_id;
	*index = *index + 1;
	*suc = MSSUCC;
	return(MSSUCC);
}
else{
	if( numComp == 0 ){
		OmStat = om$send( msg = message GRowner.GRget_number_components(
					suc,
			     		&locNumComp ),

	           	 senderid = NULL_OBJID,
	  	 	 targetid = CompId->obj_id.objid,
	  	 	 targetos = CompId->obj_id.osnum );
	}
	else locNumComp = numComp;

	OmStat = om$send( msg = message GRowner.GRget_components( 
					suc,
					&(CompId->mod_env),
					&ListIds[*index],
					locNumComp,
					&numRet,
			     		(IGRint) 0,
					OM_K_MAXINT ),

	        	 senderid = NULL_OBJID,
	  	 	 targetid = CompId->obj_id.objid,
	  	 	 targetos = CompId->obj_id.osnum );
	if( !(OmStat&(*suc)&1) ){
		printf("Error in VLdropCompCrv\n");
		printf("GRowner.GRget_components: Failde\n");
		goto wrapup;
	}


	*index = *index + locNumComp;

	OmStat = om$send( msg = message GRowner.GRdrop( 
					suc,
					&(CompId->mod_env) ),

	              	 senderid = NULL_OBJID,
	  	 	 targetid = CompId->obj_id.objid,
	  	 	 targetos = CompId->obj_id.osnum );
	if( !(OmStat&(*suc)&1) ){
		printf("Error in VLdropCompCrv\n");
		printf("GRowner.GRdrop: Failde\n");
		goto wrapup;
	}

	*suc = MSSUCC;
}

return(MSSUCC);

wrapup:
	*suc = MSFAIL;
	return(MSFAIL);

}

IGRlong VLtest_angle (
             struct IGRbsp_curve	*cv1,
             struct IGRbsp_curve	*cv2,
             IGRdouble			angle
                   )
{
IGRdouble *int_pts,*par1,*par2,*end_pts,*over0,*over1;
IGRdouble   pr,evl1[10],evl2[10];
int nb_int;
long n_over;
BSrc	  rc;

  int_pts = par1 = par2 = end_pts = over0 = over1 = NULL;
  BScvcv_int(&rc,cv1,cv2,&nb_int,&int_pts,&par1,&par2,
       &n_over,&end_pts,&over0,&over1);
  if (par1 != NULL && par2 != NULL && int_pts != NULL) {
    BScveval(cv1,par1[0],1,evl2,&rc);
    if (rc != BSSUCC) { printf( "Error in BScveval(1) ...\n");
		        return -1;	}
    BScveval(cv2,par2[0],1,evl1,&rc);
    if (rc != BSSUCC) { printf( "Error in BScveval(2) ...\n");
		        return -1;	}
   // free memory
    if (int_pts) {om$dealloc(ptr= int_pts ); int_pts = NULL;}
    if (par1) {om$dealloc(ptr= par1 ); par1 = NULL;}
    if (par2) {om$dealloc(ptr= par2 ); par2 = NULL;}
    if (end_pts) {om$dealloc(ptr= end_pts ); end_pts = NULL;}
    if (over0) {om$dealloc(ptr= over0 ); over0 = NULL;}
    if (over1) {om$dealloc(ptr= over1 ); over1 = NULL;}

    BSnorvec(&rc,&evl1[3]);
    BSnorvec(&rc,&evl2[3]);
    pr = BSdotp(&rc,&evl1[3],&evl2[3]);
    if (fabs(pr) < angle) return 0;
    return 1;
  }
  else {
#ifdef DEBUG
printf("DDDDISJOINT\n");
#endif
      if (int_pts) {om$dealloc(ptr= int_pts ); int_pts = NULL;}
      if (par1) {om$dealloc(ptr= par1 ); par1 = NULL;}
      if (par2) {om$dealloc(ptr= par2 ); par2 = NULL;}
      if (end_pts) {om$dealloc(ptr= end_pts ); end_pts = NULL;}
      if (over0) {om$dealloc(ptr= over0 ); over0 = NULL;}
      if (over1) {om$dealloc(ptr= over1 ); over1 = NULL;}
      return 0;
  }
}

/*==========================================================================*/

IGRlong VLcreBoundWithOff (

struct 	mise_a_plat	*dev,	    /*I structure containing the informations */
struct	GRvg_construct	*cst,	    /*I construction list */
        IGRboolean	DisOpt,	    /*I display needed or not */
	IGRint		*NumObj,    /*O number of loop objects return */
struct  GRobj_env	**ObjRet,   /*O loop objects return */
	IGRint		**LoopIndex,/*O gives the nb of edges in each loop */
	IGRint		*NumEdges,  /*O total number of edges */
struct  EdgeMatch	**EdgeList, /*O the edge list  containing the unwraped
					edge ID and the edge_attribut macro
					matching with */
        int		*surf_type, /*O : type of the surface (Port,
                                          Starboard or Middle). */
struct  GRid		*line,      /*O : will contain the two unwrapping 
                                           edges corresponding to the plate's
                                           closest edges to the Middle, Front 
                                           or Down of the boat */
	int             *nb_old_crvs,
	struct  GRid    **old_crvs,
	IGRlong		*suc        /*O MSSUCC, MSFAIL */
)	

/*d  This function evaluates the unwraped edge of a unwraped surface 
    taking into account the edge attributs that could be attached to
    the parent surface.  */

/*h 3 January 93 JLL creation date */
/*h 16 May    94 JLL set objRet and lcCv to NULL_OBJID after malloc */



/*c Beginning of function */
{

  	IGRint		i, j, k, ie;
  	IGRlong		OmStat;
struct	IGRbsp_curve	cv;
struct  GRobj_env	*LcCv;

struct	GRobj_env	StrID;
	IGRdouble	activCht, cht;
	IGRint		size_buf;
	IGRdouble	*OfVal;
	IGRint		OuiNon;

struct  GRid 		edgeC,edgeF,edgeD; /* closest edges to the Middle,
                                              Front and Down of the boat */
struct  GRid 		lineC,lineF,lineD; /* unwrapping edges corresponding to
                                              the closest edges to the Middle,
                                              Front and Down of the boat */
        int 		orient;            /* Horizontal, transversal or
                                              longitudinal */
struct  GRid		*CmpLst;
        IGRint		ii,NumCmp;
        IGRint		ii0,ii1,ii2;
        IGRint		iiC,iiF,iiD;
struct IGRbsp_curve	**edgeCv,**CmpCv; 

IGRshort		TypeOfCurve;
struct	GRid		*ConCrvs;
IGRint			NumConCrvs;
IGRdouble		info[4];
IGRboolean		bool,bool0;
   


  #ifdef DEBUG
   printf("------------------------ VLcreBoundWithOff --------------------\n");
  #endif

  ConCrvs    = NULL;
  *ObjRet    = NULL;
  *LoopIndex = NULL;
  *EdgeList  = NULL;
  CmpLst     = NULL;
  CmpCv      = NULL;
  edgeCv     = NULL;
  cv.poles   = NULL;
  cv.weights = NULL;
  cv.knots   = NULL;
  LcCv       = NULL;
  OfVal	     = NULL;
  iiF = iiC = iiD = 0;
  ii0 = ii1 = ii2 = 0;
  NumConCrvs = 0;
  bool = FALSE;
  bool0 = FALSE;


  VLedgeMatch( dev, NumObj, LoopIndex, NumEdges, EdgeList, suc );
  if( *suc != MSSUCC ){
  	printf("Error in VLcreBoundWithOff\n");
  	printf("VLedgeMatch Failed\n");
	goto wrapup;
  }
  #ifdef DEBUG
  printf("return VLedgeMatch NumObj=%d,NumEdges%d\n",(*NumObj),(*NumEdges));
  #endif
  /*c malloc the array to return the unwraped composite curve */

  (*ObjRet) = (struct  GRobj_env *)
	  om$malloc( size = (*NumObj) * sizeof(struct GRobj_env) );
  if( *ObjRet == NULL ){
  	printf("Error in VLcreBoundWithOff\n");
	printf(" om$malloc ObjRet : Failed\n");
	goto wrapup;
  }

  for(i=0;i<(*NumObj);i++) (*ObjRet)[i].obj_id.objid = NULL_OBJID;

  /*c malloc the GRlc_info structure to build composite curve */
  /*c set the object ID to NULL_OBJID */

  LcCv = (struct  GRobj_env *)
	  om$malloc( size = (*NumEdges) * sizeof(struct GRobj_env) );
  if( LcCv == NULL ){
  	printf("Error in VLcreBoundWithOff\n");
	printf(" om$malloc LcCv : Failed\n");
	goto wrapup;
  }

  for(i=0;i<(*NumEdges);i++) LcCv[i].obj_id.objid = NULL_OBJID;


  /*c get the active cht */

  size_buf = sizeof(cht);
  gr$get_chord_height_tolerance ( 	msg 	= suc,
				  	sizbuf	= &size_buf,
					buffer	= &activCht,
					nret	= &size_buf	);
  cht = activCht / 10000;
  if( cht < 0.0001 ) cht = 0.0001;

  if (!VLlongHorzOrTrans(&dev->surf_id,&orient)) {
    printf("Error in VLcreBoundWithOff\n");
    goto wrapup;
  }

  if((*suc = VLfindOrientation(&dev->surf_id,&edgeC,&edgeF,
                                 &edgeD,surf_type))!= MSSUCC){
    printf("Error in VLcreBoundWithOff\n");
    printf("VLfindOrientation : Failed\n");
    goto wrapup;
  }

  ie = 0;

  for(i=0; i<(*NumObj); i++ ){
	
	for(j=0; j<(*LoopIndex)[i]; j++){
//#ifdef BBB
          if (dev->developpable == 1){


		/*c the surface is planar then we just copy the edges and
		    set the active level */

		#ifdef DEBUG
		printf("surface is planar\n");
		#endif

		OmStat = vs$get_graphic_edge( msg    = suc,
                                             edId   = &((*EdgeList)[ie].EdgeId),
                                             edEnv  = &(dev->surf_id.mod_env),
                                             copy   = TRUE,
                                             copyEnv= cst->env_info,
                                             grEdge = &(StrID.obj_id)) ;
                if( !( OmStat & 1 & *suc) ) {
    		    printf("Error in VLcreBoundWithOff\n");
                    printf( "vs$get_graphic_edge Failed\n" ) ;
                }

                StrID.mod_env = *(cst->env_info);

		OmStat = om$send( msg = message GRvg.GRchglevel( 
						suc,
						(IGRshort *) &(cst->level) ),
                                senderid = NULL_OBJID,
                                targetid = StrID.obj_id.objid,
	                        targetos = StrID.obj_id.osnum ) ;
        	if (!(OmStat&(*suc)&1)) {
    		    	printf("Error in VLcreBoundWithOff\n");
          		printf("GRchglevel Failed\n");
        	}
          }/* end case if the surface is planar */

          else {
//#endif

		/*c the surface is not planar */
  		/*c for each 3D edge build the corresponding unwraped edge */

		#ifdef DEBUG
		  printf("enter VLbuildUnwrapEdge\n");
		  printf("EdgeList[%d]=%d,%d\n",ie,(*EdgeList)[ie].EdgeId.objid,
			(*EdgeList)[ie].EdgeId.osnum);
		#endif

		VLbuildUnwrapEdge( dev, &(*EdgeList)[ie].EdgeId, activCht, 
				    cht, cst, &StrID, suc );
		if( *suc != MSSUCC ){
  			printf("Error in VLcreBoundWithOff\n");
			printf(" VLbuildUnwrapEdge : Failed\n");
			goto deldel;

		}
          }

          if (i==0 & line != NULL) { /* Find the unwrapped edges 
                                        corresponding to edgeC, edgeF
                                        et edgeD */
       
           	if (edgeC.objid == (*EdgeList)[ie].EdgeId.objid &&
               	edgeC.osnum == (*EdgeList)[ie].EdgeId.osnum) {
             	lineC = StrID.obj_id; 
             	iiC = ie;
          	}

          	if (edgeF.objid == (*EdgeList)[ie].EdgeId.objid &&
               		edgeF.osnum == (*EdgeList)[ie].EdgeId.osnum) {
             		lineF = StrID.obj_id;
             		iiF = ie;
          	}

           	if (edgeD.objid == (*EdgeList)[ie].EdgeId.objid &&
               		edgeD.osnum == (*EdgeList)[ie].EdgeId.osnum) {
             		lineD = StrID.obj_id;
             		iiD = ie;
           	}
          }

	  LcCv[j].obj_id = StrID.obj_id;
	  (*EdgeList)[ie].EdgeId = StrID.obj_id;

     	  memcpy ( (IGRchar *)&LcCv[j].mod_env,
	  	   (IGRchar *)cst->env_info, 
		   (IGRint)sizeof( struct GRmd_env) );

	  ie += 1;

	}/* we built the unwrap edge j of the each edges i */




	/*c construct a composite curve if the loop contains more than
	    one edge */

	#ifdef DEBUG

           printf("(*LoopIndex)[%d]=%d, ie=%d\n",i,(*LoopIndex)[i], ie);
	   for(j=0; j<(*LoopIndex)[i];j++)
	   printf("LcCv[%d] = %d,%d\n",j, LcCv[j].obj_id.objid,
		  LcCv[j].obj_id.osnum);
        #endif

	if( (*LoopIndex)[i] > 1 ){

		cst->geometry = NULL;
		(*ObjRet)[i].obj_id.objid = NULL_OBJID;
		(*ObjRet)[i].obj_id.osnum = cst->env_info->md_id.osnum;

		TypeOfCurve = 3;
		SortAndBuildCrv( LcCv, (*LoopIndex)[i], TypeOfCurve, cst, 
		     		 &ConCrvs, &NumConCrvs, suc );

		if( NumConCrvs == 0 ) {
	  		printf("Error in VLcreBoundWithOff\n");
		     	printf( "SortAndBuildCrv Failed for loop=%d: \n",i );
			(*ObjRet)[i].obj_id.objid = NULL_OBJID;
			goto deldel;
		}
		else if( NumConCrvs == 1 ){
			if( ConCrvs[0].objid == NULL_OBJID ){
	  		   printf("Error in VLcreBoundWithOff\n");
		     	   printf( "SortAndBuildCrv Failed for loop=%d: \n",i );
			   goto deldel;
			}

			(*ObjRet)[i].obj_id = ConCrvs[0];
			(*ObjRet)[i].mod_env = *(cst->env_info); 

		}
		else{
			printf("NumConCrvs = %d\n",NumConCrvs);
			(*ObjRet)[i].obj_id.objid = NULL_OBJID;
			goto deldel;
		}

	}
	else{
		(*ObjRet)[i].obj_id  = LcCv[0].obj_id;
		(*ObjRet)[i].mod_env = *(cst->env_info);
	}

	if( DisOpt == TRUE )
 	gr$display_object ( object_id = (struct GRid *)&(*ObjRet)[i].obj_id,
		     	    mode      = GRbd );


  }/* end of loop i */

 if (line != NULL) {
	switch (orient) {

      		case VL_HORZ : // horizontal
        	   if (*surf_type == VL_MIDDEL) {//if the surface cut shipaxis
                                               // we just need the closest edge
                                               // to the front.
          			line[0].objid = NULL_OBJID;
          			line[1] = lineF;
          			line[2] = lineC;// it will be needed for
                                                // several choices by
                                               // the function VLget_mac_names.
          			ii0 = -1;
          			ii1 = iiF;
          			ii2 = iiC;
        		}
        		else {
        			line[2] = line[0] = lineC;
          			line[1] = lineF;
          			ii0 = ii2 = iiC;
          			ii1 = iiF;
        		}
        		break;

      		case VL_TRANS : // transversal
        	     if (*surf_type == VL_MIDDEL) {//if the surface cut shipaxis
                                               // we just need the closest edge
                                               // to the DOWN.
          			line[0].objid = NULL_OBJID;
          			line[1] = lineD;
          			line[2] = lineC;// it will be needed for
                                                // several choices by
                                               // the function VLget_mac_names.
          			ii0 = -1;
          			ii1 = iiD;
          			ii2 = iiC;
        		}
        		else {
          			line[2] = line[0] = lineC;
          			line[1] = lineD;
          			ii0 = ii2 = iiC;
          			ii1 = iiD;
        		}
        		break;

       		case VL_LONG : // longitudinal
         		line[0] = lineF;
         		line[1] = lineD;
          		ii2 = ii0 = iiF;
          		ii1 = iiD;
       			break;

       		default : goto deldel; 
    	}

	#ifdef DEBUG1
	printf("LES LINES=%d %d %d %d %d %d\n", line[0].objid,line[0].osnum,
						line[1].objid,line[1].osnum,
						line[2].objid,line[2].osnum);
	fflush(stdout);
	#endif
  }
  

  /*c retrieve the offset values strored in the edge_att */

  OfVal = (IGRdouble *)
	  om$malloc( size = (*NumEdges) * sizeof(IGRdouble) );
  if( OfVal == NULL ){
  	printf("Error in VLcreBoundWithOff\n");
	printf(" malloc OfVal : Failed\n");
	goto deldel;
  }

  for(i=0;i<(*NumEdges);i++){
	if( (*EdgeList)[i].EdgeMac.objid != NULL_OBJID ){
  		VLretOfVal( &((*EdgeList)[i].EdgeMac),
			     &(OfVal[i]), suc );
  		if( (*suc) != MSSUCC ){
  			printf("Error in VLcreBoundWithOff\n");
	     		printf( "VLretOfVal Failed for loop=%d: \n",i );
			goto deldel;
		}
	}
	else OfVal[i] = 0.0;
  }

  #ifdef DEBUG
  __DBGpr_double("OfVal",OfVal,1,(*NumEdges));
  #endif



  /*c apply the offset values on each loop if needed */

  j  = 0;
  ie = 0;
  for(i=0; i<(*NumObj); i++ ){
	
	ie += (*LoopIndex)[i];

	VLisOffNeeded( /*&((*EdgeList)[0])*/OfVal, j, ie, &OuiNon );

	#ifdef DEBUG
	printf("exit VLisOffNeeded j = %d, ie = %d, OuiNon = %d\n", 
		j,ie,OuiNon);
	#endif

	if( OuiNon == TRUE ){
          bool = TRUE;

          if (i==0) {
		VLoffset_Cv( &(*ObjRet)[i], cst, (IGRboolean)TRUE, 
		   (IGRdouble *)NULL, (*LoopIndex)[i], &(OfVal[j]), 
		   info, (IGRboolean)FALSE, &StrID, nb_old_crvs, old_crvs, suc);
                bool0 = TRUE;
          }
          else
		VLoffset_Cv( &(*ObjRet)[i], cst, (IGRboolean)FALSE, 
		   (IGRdouble *)NULL, (*LoopIndex)[i], &(OfVal[j]), 
                   NULL, (IGRboolean)FALSE, &StrID, nb_old_crvs, old_crvs, suc);

 		if( (*suc) != MSSUCC ){
	  		printf("Error in VLcreBoundWithOff\n");
			printf( "VLoffset_Cv Failed for loop=%d: \n",i );
			goto deldel;
		} 

		(*ObjRet)[i] = StrID;
	}

	j = ie;

  }

  if (bool == TRUE) {
  j=0;
  for(i=0; i<(*NumObj); i++ ){
     if ((*LoopIndex)[i] > 1) {
        OmStat = om$send( msg      = message GRowner.GRget_number_components(
                                                                suc,
                                                                &NumCmp ),
                          senderid = NULL_OBJID,
                          targetid = (*ObjRet)[i].obj_id.objid,
                          targetos = (*ObjRet)[i].obj_id.osnum );
        if (!(OmStat&(*suc)&1)) {
                printf("Error in VLcreBoundWithOff\n");
                printf( "GRget_number_components\n");
                goto deldel;
        }
     }
     else NumCmp = 1;
        
        if (j < NumCmp) j = NumCmp;
   }

   CmpLst = (struct  GRid *)
                  om$malloc( size =  j * sizeof( struct GRid ) );
   if( CmpLst == NULL ){
           printf("Error in VLcreBoundWithOff\n");
           printf("malloc CmpLst : Failed\n");
           goto deldel;
   }
   CmpCv = (struct  IGRbsp_curve **)
                  om$malloc( size =  j * sizeof( struct IGRbsp_curve *) );
   if( CmpCv == NULL ){
           printf("Error in VLcreBoundWithOff\n");
           printf("malloc CmpCv : Failed\n");
           goto deldel;
   }
   edgeCv = (struct  IGRbsp_curve **)
                  om$malloc( size =  j * sizeof( struct IGRbsp_curve *) );
   if( edgeCv == NULL ){
           printf("Error in VLcreBoundWithOff\n");
           printf("malloc edgeCv : Failed\n");
           goto deldel;
   }
   for (k=0;k<j;k++) edgeCv[k] = CmpCv[k] = NULL;

  k = 0;
  for(i=0; i<(*NumObj); i++ ){
    if (i==0) {
      OmStat = VLreparameter_off_curve(&(*ObjRet)[i],(*LoopIndex)[i], 
                                       &((*EdgeList)[k]), &OfVal[k],info,
                                       CmpLst,CmpCv,edgeCv,cst,TRUE);
      if (bool0) {
           for (ii=0; ii<(*LoopIndex)[0];ii++)
     	   om$send( msg = message GRgraphics.GRdelete(suc,cst->env_info),
             	     targetid = LcCv[ii].obj_id.objid,
		     targetos = LcCv[ii].obj_id.osnum,
		     senderid = NULL_OBJID ) ;
   
      }
    }
    else {
      OmStat = VLreparameter_off_curve(&(*ObjRet)[i],(*LoopIndex)[i], 
                                       &((*EdgeList)[k]), &OfVal[k],NULL,
                                       CmpLst,CmpCv,edgeCv,cst,FALSE);
      }
    if (!(OmStat&1)) goto deldel;
    k += (*LoopIndex)[i];
  }

  if (line != NULL) {
    if (ii0 >= 0) line[0] = (*EdgeList)[ii0].EdgeId;
    line[1] = (*EdgeList)[ii1].EdgeId;
    line[2] = (*EdgeList)[ii2].EdgeId;
  }
  }

   	#ifdef DEBUG1
		printf("LES OFFSET LINES :\n");
		if (ii0 >=0) 
  			printf("0 et 1 et 2 = %d %d %d %d %d %d\n",
				line[0].objid,line[0].osnum,
				line[1].objid,line[1].osnum,
				line[2].objid,line[2].osnum);
		else
			printf("1 et 2 = %d %d %d %d\n",
				line[1].objid,line[1].osnum,
				line[2].objid,line[2].osnum);
		fflush(stdout);
	#endif

 cst->geometry = NULL;

 if( OfVal )	   { om$dealloc( ptr = OfVal );        OfVal        = NULL; }
 if( CmpLst ) 	   { om$dealloc( ptr = CmpLst );       CmpLst       = NULL; }
 if( CmpCv ) 	   { om$dealloc( ptr = CmpCv );        CmpCv        = NULL; }
 if( edgeCv ) 	   { om$dealloc( ptr = edgeCv );       edgeCv       = NULL; }
 if( LcCv )        { om$dealloc( ptr = LcCv ); 	       LcCv         = NULL; }
 if( ConCrvs )     { om$dealloc( ptr = ConCrvs );      ConCrvs      = NULL; }

 #ifdef DEBUG
 printf(" exit VLcreBoundWithOff with SUCCESS\n");
 #endif

 *suc = MSSUCC;
 return(MSSUCC);


deldel:

	/*c delete the composite curve which could have been already evaluated*/
	for( k=0; k<(*NumObj); k++ ){
	if( (*ObjRet)[k].obj_id.objid != NULL_OBJID )
     	OmStat = om$send( msg = message GRgraphics.GRdelete(suc,cst->env_info),
             	     targetid = (*ObjRet)[k].obj_id.objid,
		     targetos = (*ObjRet)[k].obj_id.osnum,
		     senderid = NULL_OBJID ) ;
	}

	/*c delete the edge components of the current loop which failed */
	for( k=0; k<(*NumEdges); k++ ){
	if( LcCv[k].obj_id.objid != NULL_OBJID )
     	OmStat = om$send( msg = message GRgraphics.GRdelete(suc,cst->env_info),
             	     targetid = LcCv[k].obj_id.objid,
		     targetos = LcCv[k].obj_id.osnum,
		     senderid = NULL_OBJID ) ;
	}

wrapup:

 if( OfVal )	   { om$dealloc( ptr = OfVal );        OfVal        = NULL; }
 if( CmpLst ) 	   { om$dealloc( ptr = CmpLst );       CmpLst       = NULL; }
 if( CmpCv ) 	   { om$dealloc( ptr = CmpCv );       CmpCv       = NULL; }
 if( edgeCv ) 	   { om$dealloc( ptr = edgeCv );       edgeCv       = NULL; }
 if( LcCv )        { om$dealloc( ptr = LcCv ); 	       LcCv         = NULL; }
 if( (*ObjRet) )   { om$dealloc( ptr = (*ObjRet) );    (*ObjRet)    = NULL; }
 if( (*LoopIndex) ){ om$dealloc( ptr = (*LoopIndex) ); (*LoopIndex) = NULL; }
 if( (*EdgeList) ) { om$dealloc( ptr = (*EdgeList) );  (*EdgeList)  = NULL; }
 if( ConCrvs )     { om$dealloc( ptr = ConCrvs );      ConCrvs      = NULL; }


 *NumEdges = 0;
 *NumObj   = 0;

 #ifdef DEBUG
 printf(" exit VLcreBoundWithOff with FAILURE\n");
 #endif

 *suc	   = MSFAIL;
 return(MSFAIL);

}

/*==========================================================================*/

end implementation VLabstract;
