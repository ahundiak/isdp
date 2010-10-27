/*f
	VLdFemFunk.I contains all the set of functions used gererate and
	unwrap the facettes.


JLL 17 jan 93 : functions move from VLdevel.I to manage better the soft
JLL 5  May 94 : add function VLcreUnfoldSrfStr().
JLL 6  May 94 : in VLmaplatNDevel() call VLcreUnfoldSrfStr() to create
		dev->devsrf.
*/

class implementation VLabstract;


/*
# ifndef DEBUG
# define DEBUG 1
# endif
*/



#include <stdio.h>
#include "vlstructure.h"
#include "OMprimindex.h"
#include "OMprimitives.h"
#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMindex.h"
#include "OMmacros.h"
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
#include "bserr.h"
#include "maerr.h"
#include "bs.h"
#include "bsparameters.h"
#include "EMSmsgdef.h"
#include "msdef.h"
#include "madef.h"
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
#include "parametric.h"


#include "bschtptstsf.h"
#include "bschtptstso.h"
#include "bssfarrevn.h"
#include "bsfreesf.h"
#include "bsdistptpt.h"
#include "bscrossp.h"
#include "bsdotp.h"
#include "bslenvec.h"
#include "bsnorvec.h"
#include "bsfreecv.h"
#include "bsalloccv.h"
#include "bsallocsf.h"
#include "bssfeval.h"

#include "bstst_plan.h"
#include "mainvmx.h"
#include "mamulmx.h"
#include "matypemx.h"
#include "maoptsxfo.h"
#include "marptsxfo.h"


extern			GRdpb_get();
extern			GRdpb_put();
extern  IGRint		abs();
extern  IGRchar		*memcpy();
extern  IGRdouble	sqrt();
extern	IGRdouble	fabs();
extern			GRdisplay_object();




  

extern GRclassid	OPP_GR3dlinestr_class_id;





/******************************************************************************/
/* VLdrawRec : this function is used for debug only, to create the 	      */
/* unwraped rectangle							      */
/******************************************************************************/
IGRlong VLdrawRec( pts, numU, i0, j0, i1, j1, i2, j2, i3, j3, creOpt, rectId )

	IGRdouble	*pts;	/*I array containing all the points */
	IGRint		numU;   /*I because i0,j0 are the repectively the
				    the colum and row index, I need the
				    the number of components in a row to
				    define the index in the array.*/
	IGRint		i0,j0;  
	IGRint		i1,j1;  
	IGRint		i2,j2;
	IGRint		i3,j3;
	IGRint		creOpt; /*I     creOpt = 0, create and not display 
					creOpt = 1, create and display 
					creOpt = 2, create display delete */
struct	GRid		*rectId;

{
IGRlong			sts, loc_msg;
struct	GRvg_construct	cnst;
struct	IGRpolyline	lstr_geom;
	IGRdouble	tab[15];
	IGRint		i, j;


	lstr_geom.points = &tab[0];
	
	VLinitCnst( &cnst );
	rectId->objid	= NULL_OBJID;
	rectId->osnum	= cnst.env_info->md_id.osnum;
	
	sts = om$construct(	classid	= OPP_GR3dlinestr_class_id,
				osnum	= rectId->osnum,
				p_objid	= &rectId->objid );
	if( sts & 1 ){

		lstr_geom.num_points	= 4;
		j = 3 * ( i0 + ( j0 * numU ) );
		for(i=0;i<3;i++){ 
			tab[i] = pts[j+i];
			tab[12+i] = tab[i];
		}

		j = 3 * ( i1 + ( j1 * numU ) );
		for(i=0;i<3;i++) tab[3+i] = pts[j+i];
		
		j = 3 * ( i2 + ( j2 * numU ) );
		for(i=0;i<3;i++) tab[6+i] = pts[j+i];

		j = 3 * ( i3 + ( j3 * numU ) );
		for(i=0;i<3;i++) tab[9+i] = pts[j+i];


		cnst.geometry	= (IGRchar *) &lstr_geom;

		sts = om$send(	msg	 = message GRgraphics.GRaltconstruct
						( &cnst ),
				senderid = NULL_OBJID,
				targetid = rectId->objid,
				targetos = rectId->osnum );
	}

	if( ! (sts&1)){

		sts = om$send(	msg	 = message GRgraphics.GRdelete
						( &loc_msg, cnst.env_info ),
				senderid = NULL_OBJID,
				targetid = rectId->objid,
				targetos = rectId->osnum );
		rectId->objid = NULL_OBJID;
		loc_msg	= MSFAIL;
		goto wrapup;
	}

	if( creOpt == 0 ){

		/*c just create without display */

		loc_msg = MSSUCC;
	}
	else if( creOpt == 1){

		/*c create end display the tria */

		gr$display_object ( object_id = &rectId,
                	    	    md_env    = cnst.env_info,
		     	    	    mode      = GRbd );

		loc_msg = MSSUCC;
	}
	else{

		/*c display and delete the graphic object */

		gr$display_object ( object_id = &rectId,
                	    	    md_env    = cnst.env_info,
		     	    	    mode      = GRbd );

		sts = om$send(	msg	 = message GRgraphics.GRdelete
						( &loc_msg, cnst.env_info ),
				senderid = NULL_OBJID,
				targetid = rectId->objid,
				targetos = rectId->osnum );

		rectId->objid = NULL_OBJID;

		loc_msg = MSSUCC;
	}

wrapup:
	if( loc_msg != MSSUCC ) printf("error display rec\n");	
return	loc_msg;

}

/*===========================================================================*/

IGRlong VLinitDev (dev)
/*d just a small function to set all the pointers of the struct mise_a_plat
    to null. */
/*h 23/october/92 JLL: creation date
    7/juillet/93  JLL: set to NULL dev->ind array */


struct mise_a_plat	*dev; /*IO */
{
 	dev->surface	  = NULL;
 	dev->Param_u	  = NULL;
 	dev->Param_v	  = NULL;
 	dev->P		  = NULL;
 	dev->M		  = NULL;
 	dev->norm	  = NULL;
 	dev->def	  = NULL;
 	dev->fg		  = NULL;
	dev->devsrf	  = NULL;
 	dev->bdrys_a_plat = NULL;

	dev->edgeUVGeom	  = NULL;
	dev->edgeAt	  = NULL;
	dev->ind	  = NULL;
        dev->uvSrfId.objid = NULL_OBJID;
        dev->tesselation_option = 0;
        dev->AllWaterLines = 0;
        dev->WantedLinesCode = 31;
        dev->side_of_plate = 2;

 	return MSSUCC;
}

/*===========================================================================*/

IGRlong VLfreeDev (dev)

/*d just a small function to free all the pointers of the struct mise_a_plat
    and set to null. */
/*h 23/october/92 JLL: creation date 
    7/juillet/93  JLL: add free of dev->ind array */


struct mise_a_plat	*dev; /*I the struct used to unwrap */

{
IGRint	i;
BSrc	rc;

 if( dev->surface ){
        if( dev->surface->bdrys ){
		om$dealloc( ptr = dev->surface->bdrys );
		dev->surface->bdrys = NULL;
	}
	om$dealloc( ptr = dev->surface ); 
	dev->surface = NULL;
 }

 if (dev->Param_u)   {free(dev->Param_u);        dev->Param_u = NULL;}
 if (dev->Param_v)   {free(dev->Param_v);        dev->Param_v = NULL;}
 if (dev->P)	     {free(dev->P); 	         dev->P	      = NULL;}
 if (dev->M)	     {free(dev->M);	         dev->M       = NULL;}
 if (dev->norm)	     {free(dev->norm);	         dev->norm    = NULL;}
 if (dev->def)	     {free(dev->def);	         dev->def     = NULL;}
 if (dev->devsrf)    {BSfreesf(&rc,dev->devsrf); dev->devsrf  = NULL;}
 if (dev->fg)	     {free(dev->fg);	         dev->fg      = NULL;}

 if( dev->edgeUVGeom )	free( dev->edgeUVGeom );
 if( dev->edgeAt )	free( dev->edgeAt );

 if((dev->bdrys_a_plat)&&(dev->bdrys_a_plat->num_boundaries!=0)) {
	for (i=0;i<dev->bdrys_a_plat->num_boundaries;i=i+1)
		free((dev->bdrys_a_plat->bndries[i]).points);
	free(dev->bdrys_a_plat);
	dev->bdrys_a_plat	= NULL;
 }

 if( dev->ind )      {free(dev->ind);	         dev->ind      = NULL;}

 return MSSUCC;

}	

/*===========================================================================*/

IGRint VLindex( dev, u, v, corg )
struct 	mise_a_plat	*dev;
	IGRint 		u;
	IGRint 		v;
	IGRint 		corg;

{ return ( 3 * (u+(v*dev->Nb_u))+corg ); }

/*===========================================================================*/
IGRlong VLcreUnfoldSrfStr( devel ) 

struct mise_a_plat	*devel; /*I the structure containing everything */

{


	IGRlong		rc;
struct	IGRbsp_surface 	*sfPtr;



if( devel->devsrf != NULL ){
	printf("Error in VLcreUnfoldSrfStr\n");	
	printf("devel->ressrf already exists\n");
	return MSSUCC;
}

if( devel->developpable == 1 ){
	
	/*
	 *	the surface is flat so we just need to copy and apply
	 *      a transformation matrix to devel->surface
	 */


	if( devel->surface == NULL ){
	   printf("Error in VLcreUnfoldSrfStr()\n");
	   printf("devel->surface does'nt exist\n");
	   goto wrapup;
	}

	sfPtr = devel->surface;

	/*
	 *	malloc the devel->ressrf structure and copy devel->surface
	 */


	BSallocsf ( 	(IGRshort)sfPtr->u_order, 
			(IGRshort)sfPtr->v_order,
	     		(IGRlong)sfPtr->u_num_poles, 
			(IGRlong)sfPtr->v_num_poles,
	     		(IGRboolean ) sfPtr->rational, 
			(IGRshort)sfPtr->num_boundaries, 
			&devel->devsrf, &rc);
 	if (rc != BSSUCC) {
	   printf("Error in VLcreUnfoldSrfStr()\n");
	   printf("BSallocsf on <struct IGRbsp_surface *> returns %d\n", rc);
	   goto wrapup; 
 	}

	BSsf_copy( &rc, sfPtr, devel->devsrf );
 	if (rc != BSSUCC) {
	   printf("Error in VLcreUnfoldSrfStr()\n");
	   printf("Error in BSsf_copy()\n");
	   goto wrapup; 
 	}

	return MSSUCC;
}
else{


	if( (devel->Nb_u < 2) || (devel->Nb_v < 2) ){
	   printf("Error in VLcreUnfoldSrfStr()\n");
	   printf("devel->Nb_u = %d, devel->Nb_u = %d\n");
	   printf("these values should be set to 2 in this particular case\n");
	   goto wrapup;
	}

	if( devel->M == NULL ){
	   printf("Error in VLcreUnfoldSrfStr()\n");
	   printf("the unfold has not been already perform devel->M == NULL\n");
	   goto wrapup;
	}

	if( devel->Param_u == NULL ){
	   printf("Error in VLcreUnfoldSrfStr()\n");
	   printf("Knots in u do not exist devel->Param_u == NULL\n");
	   goto wrapup;
	}

	if( devel->Param_v == NULL ){
	   printf("Error in VLcreUnfoldSrfStr()\n");
	   printf("Knots in v do not exist devel->Param_v == NULL\n");
	   goto wrapup;
	}


	 VLcreOrd2Srf( 	devel->M, 
			devel->Nb_u, devel->Nb_v, 
		       	devel->Param_u, devel->Param_v, 
			0, NULL, (IGRboolean) TRUE, 
			NULL, &devel->devsrf,&rc); 

	if( rc != MSSUCC ){
	   printf("Error in VLcreUnfoldSrfStr()\n");
	   printf("Error in VLcreOrd2Srf()\n");
	   goto wrapup;
	}

	return MSSUCC;

}


wrapup:
	if( devel->devsrf != NULL ) BSfreesf(&rc,devel->devsrf);
	devel->devsrf = NULL;
	return  MSFAIL;
}


/*===========================================================================*/
IGRlong VLcreUnfoldSrfStrOrig( devel ) 

struct mise_a_plat	*devel; /*I the structure containing everything */

{

IGRint		i, j, k, i3, j3;
IGRint		dem_u;
IGRint		dem_v;
IGRdouble 	*Ptr0, *Ptr1, *Ptr2, P0[3], P1[3], P2[3], vx[3], vy[3], vz[3];
IGRdouble	fromMat[16], toMat[16], tmpMat[16], trsMat[16];
IGRshort	four;
IGRshort	trsMatType;
IGRlong		stat, rc;
struct	IGRbsp_surface *sfPtr;
IGRlong		numElem;


if( devel->devsrf != NULL ){
	printf("devel->ressrf already exists\n");
	return MSSUCC;
}

if( devel->developpable == 1 ){
	
	/*
	 *	the surface is flat so we just need to copy and apply
	 *      a transformation matrix to devel->surface
	 */


	if( devel->surface == NULL ){
	   printf("Error in VLcreUnfoldSrfStr()\n");
	   printf("devel->surface does'nt exist\n");
	   goto wrapup;
	}

	sfPtr = devel->surface;

	dem_u = (sfPtr->u_num_poles) / 2 - 1;
	dem_v = (sfPtr->v_num_poles) / 2 - 1;
	k     = dem_u +  dem_v * sfPtr->u_num_poles;
	Ptr0  = sfPtr->poles + 3 * k;
	Ptr1  = Ptr0 + 3 * sfPtr->u_num_poles;
	Ptr2  = Ptr0 + 3;

	/*
	 * build the from matrix
	 */

	if( sfPtr->rational ){

		i3    = k + sfPtr->u_num_poles;
		j3    = k + 1;

		for(i=0;i<3;i++){
		  P0[i] = Ptr0[i] / sfPtr->weights[k];
		  P1[i] = Ptr1[i] / sfPtr->weights[i3];
		  P2[i] = Ptr2[i] / sfPtr->weights[j3];
		  vx[i] = P2[i] - P0[i];
		  vy[i] = P1[i] - P0[i];
		}

	}
	else{
		for(i=0;i<3;i++){
		  P0[i] = Ptr0[i];
		  vx[i] = Ptr2[i] - Ptr0[i];
		  vy[i] = Ptr1[i] - Ptr0[i];
		}

		/*
		printf("PO=%f,%f,%f\n",P0[0],P0[1],P0[2]); 
		printf("Ptr1=%f,%f,%f\n",Ptr1[0],Ptr1[1],Ptr1[2]); 
		printf("Ptr2=%f,%f,%f\n",Ptr2[0],Ptr2[1],Ptr2[2]); 
		*/
	}

	BSnorvec(&rc,vy);
	BScrossp(&rc,vx,vy,vz);
	BSnorvec(&rc,vz);
	BScrossp(&rc,vy,vz,vx);
	BSnorvec(&rc,vx);

	for ( i=0; i<3; i++) {
		j = 4 * i;
		fromMat[j]   = vx[i];
		fromMat[j+1] = vy[i];
		fromMat[j+2] = vz[i];
		fromMat[j+3] = P0[i];
	}

	fromMat[12] = 0.0; fromMat[13] = 0.0; 
	fromMat[14] = 0.0; fromMat[15] = 1.0;

	/*
	 *	build the toMatrix
	 */

	toMat[0]  =-1.0; toMat[1]  = 0.0; toMat[2]  = 0.0; toMat[3]  = 0.0;
	toMat[4]  = 0.0; toMat[5]  =-1.0; toMat[6]  = 0.0; toMat[7]  = 0.0;
	toMat[8]  = 0.0; toMat[9]  = 0.0; toMat[10] =-1.0; toMat[11] = 0.0;
	toMat[12] = 0.0; toMat[13] = 0.0; toMat[14] = 0.0; toMat[15] = 1.0;

	/*
	 *	from these two matrix build the rotation matrix
	 */

	four = 4;

  	MAinvmx ( &rc, &four, fromMat, tmpMat);
  	MAmulmx ( &rc, &four, &four, &four, toMat, tmpMat, trsMat);
	MAtypemx( &rc, trsMat, &trsMatType);


	/*
	 *	malloc the devel->ressrf structure and copy devel->surface
	 */


	BSallocsf ( 	(IGRshort)sfPtr->u_order, 
			(IGRshort)sfPtr->v_order,
	     		(IGRlong)sfPtr->u_num_poles, 
			(IGRlong)sfPtr->v_num_poles,
	     		(IGRboolean ) sfPtr->rational, 
			(IGRshort)sfPtr->num_boundaries, 
			&devel->devsrf, &rc);
 	if (rc != BSSUCC) {
	   printf("Error in VLcreUnfoldSrfStr()\n");
	   printf("BSallocsf on <struct IGRbsp_surface *> returns %d\n", rc);
	   goto wrapup; 
 	}

	BSsf_copy( &rc, sfPtr, devel->devsrf );
 	if (rc != BSSUCC) {
	   printf("Error in VLcreUnfoldSrfStr()\n");
	   printf("Error in BSsf_copy()\n");
	   goto wrapup; 
 	}

	/*
	 *	apply the transformation matrix
	 */

	if ( trsMatType != MAIDMX)
	{
		printf("not MAIDMX\n");
	  	numElem = sfPtr->u_num_poles * sfPtr->v_num_poles;

	  	if (! sfPtr->rational )
	  	{
	    		stat = MAoptsxform( &rc, &numElem, &trsMatType, trsMat,
			       	  	      sfPtr->poles,
					      devel->devsrf->poles);
	  	}
	  	else
	  	{
	    		stat = MArptsxform( &rc, &numElem, &sfPtr->rational, 
					      sfPtr->weights, trsMat, 
					      sfPtr->poles, 
					      devel->devsrf->poles );
	  	}

	  	if (! (1 & stat))
	  	{
	   		printf("Error in VLcreUnfoldSrfStr()\n");
			printf("Error MAoptsxform or MArptsxform\n");
			goto wrapup;
	  	}
	}
	else 		printf("MAIDMX\n");


	/*
	 *	set values in the structure that will be used later
	 */	

	return MSSUCC;
}
else{


	if( (devel->Nb_u < 2) || (devel->Nb_v < 2) ){
	   printf("Error in VLcreUnfoldSrfStr()\n");
	   printf("devel->Nb_u = %d, devel->Nb_u = %d\n");
	   printf("these values should be set to 2 in this particular case\n");
	   goto wrapup;
	}

	if( devel->M == NULL ){
	   printf("Error in VLcreUnfoldSrfStr()\n");
	   printf("the unfold has not been already perform devel->M == NULL\n");
	   goto wrapup;
	}

	if( devel->Param_u == NULL ){
	   printf("Error in VLcreUnfoldSrfStr()\n");
	   printf("Knots in u do not exist devel->Param_u == NULL\n");
	   goto wrapup;
	}

	if( devel->Param_v == NULL ){
	   printf("Error in VLcreUnfoldSrfStr()\n");
	   printf("Knots in v do not exist devel->Param_v == NULL\n");
	   goto wrapup;
	}


	 VLcreOrd2Srf( 	devel->M, 
			devel->Nb_u, devel->Nb_v, 
		       	devel->Param_u, devel->Param_v, 
			0, NULL, (IGRboolean) TRUE, 
			NULL, &devel->devsrf,&stat); 

	if( stat != MSSUCC ){
	   printf("Error in VLcreUnfoldSrfStr()\n");
	   printf("Error in VLcreOrd2Srf()\n");
	   goto wrapup;
	}

	return MSSUCC;

}


wrapup:
	if( devel->devsrf != NULL ) BSfreesf(&rc,devel->devsrf);
	devel->devsrf = NULL;
	return  MSFAIL;
}

/*==========================================================================*/
/* VLmaplatTria : mise a plat d'un triangle				    */
/* rend MSSUCC si ok , MSFAIL sinon   					    */
/*==========================================================================*/

IGRlong VLmaplatTria ( dev, i, j, i0, j0, i1, j1 )

struct 	mise_a_plat	*dev;
	IGRint		i;	/* I indice sur param_u du point a calculer */
	IGRint		j;      /* I indice sur param_v du point a calculer */
	IGRint		i0; 	/* I indice sur param_u du point de ref1 */
	IGRint		j0;	/* I indice sur param_v du point de ref1 */ 
	IGRint		i1; 	/* I indice sur param_u du point de ref2 */ 
	IGRint		j1;	/* I indice sur param_v du point de ref2 */ 

{

IGRdouble	I[3],J[3],K[3]; 	/*repere de l'element 3D */
IGRdouble	I0[3],J0[3],K0[3]; 	/*repere de l'element a plat */
IGRdouble 	*P,*P1,*P0,*M;
IGRdouble	x,y;
IGRvector	vect;
BSrc		rc;
IGRint		k;

 #ifdef DEBUG
 struct	GRid	triaId;
 VLdrawTria( dev->P, dev->Nb_u, i, j, i0, j0, i1, j1, 1, &triaId  );
 #endif

 /*c  Construction de IJK */
 P = dev->P;
 P1= &(P[3*(i1+dev->Nb_u*j1)]);
 P0= &(P[3*(i0+dev->Nb_u*j0)]);

 /*c I = Pi0j0Pi1j1 */
 for(k=0;k<3;k++) I[k] = P1[k] - P0[k];
 BSnorvec(&rc,I);
 if (rc!=BSSUCC) {
	printf(" VLmaplatTria : BSnorvec I Fail\n");
	return MSFAIL;
 }

 /*c J= Pi0j0Pij */
 P1= &(P[3*(i+dev->Nb_u*j)]);
 for(k=0;k<3;k++) vect[k] = P1[k] - P0[k];


 BScrossp(&rc,I,vect,K);
 BSnorvec(&rc,K);
 if (rc!=BSSUCC) {
	printf(" VLmaplatTria : BSnorvec I Fail\n");
	return MSFAIL;
 }

 P1= &(dev->norm[3*(i+dev->Nb_u*j)]);
 if( BSdotp(&rc,K,P1) < 0.0 ){
		K[0]=-K[0];
		K[1]=-K[1];
		K[2]=-K[2];
 }

 BScrossp(&rc,K,I,J);
 x = BSdotp(&rc,vect,I);
 y = BSdotp(&rc,vect,J);

	
 /*c  Construction de ijk */

 P = dev->M;
 P1= &(P[3*(i1+dev->Nb_u*j1)]);
 P0= &(P[3*(i0+dev->Nb_u*j0)]);
 for(k=0;k<3;k++) I0[k] = P1[k] - P0[k];
 BSnorvec(&rc,I0);
 if (rc!=BSSUCC) {
	printf(" VLmaplatTria : BSnorvec I Fail\n");
	return MSFAIL;
 }

 K0[0] =0;
 K0[1] =0;
 K0[2] =1;
 BScrossp(&rc,K0,I0,J0);

 M= &(P[3*(i+dev->Nb_u*j)]);

 for(k=0;k<3;k++) M[k] = P0[k] + x*I0[k] + y*J0[k];

 #ifdef DEBUG
 VLdrawTria( dev->M, dev->Nb_u, i, j, i0, j0, i1, j1, 1, &triaId  );
 #endif

 return MSSUCC;   
}

/******************************************************************************/
/* maplsat_rectangle : mise a plat d'un rectangle			      */
/* rend MSSUCC si ok , MSFAIL sinon   					      */
/******************************************************************************/
IGRlong VLmaplatRec ( dev, i, j, i0, j0, i1, j1, i2, j2 )
struct 	mise_a_plat	*dev;
	IGRint		i;	/* I indice sur param_u du point a calculer */
	IGRint		j;      /* I indice sur param_v du point a calculer */ 
	IGRint		i0; 	/* I indice sur param_u du point de ref1 */
	IGRint		j0;	/* I indice sur param_v du point de ref1 */
	IGRint		i1; 	/* I indice sur param_u du point de ref2 */
	IGRint		j1;	/* I indice sur param_v du point de ref2 */ 
	IGRint		i2; 	/* I indice sur param_u du point de ref3 */
	IGRint		j2;	/* I indice sur param_v du point de ref3 */

 
{

IGRlong		ret;
IGRint		Index;
IGRdouble 	x0, y0, *M;
struct	GRid	rectId;

 #ifdef DEBUG
 VLdrawRec( dev->P, dev->Nb_u, i, j, i0, j0, i1, j1, i2, j2, 1, &rectId  );
 #endif

 M = dev->M;
 ret = VLmaplatTria( dev, i, j, i0, j0, i1, j1 );
 if (ret!=MSSUCC) {
 	printf("maplat__triangle 1: FAIL \n");
	return MSFAIL;}

 Index = VLindex( dev, i, j, 0 );
 x0 = M[Index];
 y0 = M[Index+1];

 ret = VLmaplatTria( dev, i, j, i0, j0, i2, j2 );
 if (ret!=MSSUCC) {
 	printf("maplat__triangle 2 : FAIL \n");
	return MSFAIL;}

 M[Index]  = (M[Index]+x0) / 2.0;
 M[Index+1]= (M[Index+1]+y0) /2.0;

/* #ifdef DEBUG */
 VLdrawRec( dev->M, dev->Nb_u, i, j, i0, j0, i1, j1, i2, j2, 1, &rectId  );
/* #endif*/


 return MSSUCC;

}

/******************************************************************************/
/* maplsat_rectangle : mise a plat d'un rectangle			      */
/* rend MSSUCC si ok , MSFAIL sinon   					      */
/******************************************************************************/
IGRlong VLnewMaplatRec ( dev, i, j, i0, j0, i1, j1, i2, j2 )
struct 	mise_a_plat	*dev;
	IGRint		i;	/* I indice sur param_u du point a calculer */
	IGRint		j;      /* I indice sur param_v du point a calculer */ 
	IGRint		i0; 	/* I indice sur param_u du point de ref1 */
	IGRint		j0;	/* I indice sur param_v du point de ref1 */
	IGRint		i1; 	/* I indice sur param_u du point de ref2 */
	IGRint		j1;	/* I indice sur param_v du point de ref2 */ 
	IGRint		i2; 	/* I indice sur param_u du point de ref3 */
	IGRint		j2;	/* I indice sur param_v du point de ref3 */

 
{

IGRlong		ret;

 #ifdef DEBUG
 struct	GRid	rectId;
 VLdrawRec( dev->P, dev->Nb_u, i, j, i0, j0, i1, j1, i2, j2, 1, &rectId  );
 #endif

/*

IGRint		Index;
IGRdouble 	x0, y0, *M;

 M = dev->M;
 ret = VLmaplatTria( dev, i, j, i0, j0, i1, j1 );
 if (ret!=MSSUCC) {
 	printf("maplat__triangle 1: FAIL \n");
	return MSFAIL;}

 Index = VLindex( dev, i, j, 0 );
 x0 = M[Index];
 y0 = M[Index+1];

 ret = VLmaplatTria( dev, i, j, i0, j0, i2, j2 );
 if (ret!=MSSUCC) {
 	printf("maplat__triangle 2 : FAIL \n");
	return MSFAIL;}

 M[Index]  = (M[Index]+x0) / 2.0;
 M[Index+1]= (M[Index+1]+y0) /2.0;

*/

  /* to supprim warning message during compiling because i0 and j0 
     are not used in this function */
  i0 = i0;
  j0 = j0; 

 ret = VLmaplatTria( dev, i, j, i1, j1, i2, j2 );
 if (ret!=MSSUCC) {
 	printf("maplat__triangle 2 : FAIL \n");
	return MSFAIL;}


#ifdef DEBUG
 VLdrawRec( dev->M, dev->Nb_u, i, j, i0, j0, i1, j1, i2, j2, 1, &rectId  );
#endif


 return MSSUCC;

}

/******************************************************************************/
/* VLmaplatQuad : mise a plat de 2 bandes d'un quadran		      	      */
/* rend MSSUCC si ok , MSFAIL sinon   					      */
/******************************************************************************/
IGRlong VLmaplatQuad ( dev, i0, j0, I, J )
struct 	mise_a_plat	*dev;
	IGRint		i0;	/* I indice sur param_u du point de depart */
	IGRint		j0;     /* I indice sur param_v du point de depart */ 
	IGRint		I;	/* I indice sur param_u du point cible */
	IGRint		J;      /* I indice sur param_v du point cible */ 
{

IGRint			det_i,inc_u,inc0_u,i;
IGRint			det_j,inc_v,inc0_v,j;
IGRlong			ret;


 det_i = I-i0;
 det_j = J-j0;

 if ( det_i*det_j == 0 ) return MSSUCC;

 inc0_u = det_i / abs(det_i);
 inc0_v = det_j / abs(det_j);
 i= i0;
 j= j0;

 inc_u = inc0_u;
 inc_v = inc0_v;
 if ( abs(det_i) >= abs(det_j) ) inc_v = 0; else inc_u = 0;

 while( (i!=I)&&(j!=J) ){
	ret = VLnewMaplatRec(dev,i+inc0_u,j+inc0_v,i,j,i+inc0_u,j,i,j+inc0_v);
  	if( ret !=MSSUCC){
 		printf("VLmaplatRec : FAIL \n");
		return MSFAIL;}
	i=i+inc_u;
	j=j+inc_v;
 }

 inc_u = inc0_u;
 inc_v = inc0_v;
 if ( abs(det_i) < abs(det_j) ) inc_v=0; else inc_u=0;
 i= i0+inc_u;
 j= j0+inc_v;

 while( (i!=I)&&(j!=J) ){
  	ret = VLnewMaplatRec(dev,i+inc0_u,j+inc0_v,i,j,i+inc0_u,j,i,j+inc0_v);
	if( ret != MSSUCC){
 		printf("VLmaplatRec : FAIL \n");
		return MSFAIL;}
	i=i+inc_u;
	j=j+inc_v;
 }

 i= i0+inc0_u;
 j= j0+inc0_v;

 ret = VLmaplatQuad(dev,i,j,I,J);
 if( ret != MSSUCC ){
 	printf("VLmaplatQuad : FAIL \n");
	return MSFAIL;}


 return MSSUCC;

}

/******************************************************************************/
/* VLmaplatDevel : calcul de mise a plat de surface developable		      */
/* alloue l'espace nescessaire au resultat				      */
/* rend MSSUCC si ok , MSFAIL sinon   					      */
/******************************************************************************/
IGRlong VLmaplatDevel (dev)
struct mise_a_plat	*dev;

{
IGRint		dem_param;
IGRint		i;
IGRlong		ret;
IGRdouble	dm;
IGRdouble 	*P,*P1,*P2,*M;
IGRvector	vect;
BSrc		rc;

 dev->M = (IGRdouble *) malloc (dev->Nb_u*dev->Nb_v*3*sizeof(IGRdouble));
 if (dev->M==NULL) {printf("VLmaplatDevel  : malloc for dev->M : FAIL \n");
	return MSFAIL;}

 dem_param = dev->Nb_u / 2;
 #ifdef DEBUG
 	printf(" 1/2 param = %d \n",dem_param);
 #endif 

 P = dev->P;
 P1= &(P[3*dem_param]);
 P2= &(P[3*(dem_param+dev->Nb_u)]);
 for(i=0;i<3;i++) vect[i] = P2[i] - P1[i];
 dm = BSlenvec(&rc,vect) / 2.0;

 M = dev->M +3*dem_param;
 M[0] = 0;
 M[1] = -dm;
 M[2] = 0;
 M = dev->M +3*(dem_param+dev->Nb_u);
 M[0] = 0;
 M[1] = dm;
 M[2] = 0;

 #ifdef DEBUG2
	trace_ligne_plat(dev,dem_param,0,dem_param,1);
 #endif 

 for(i=dem_param+1;i<dev->Nb_u;i++){

	ret = VLmaplatTria(dev,i,0,i-1,0,i-1,1);
 	if (ret!=MSSUCC) {
 		printf("maplat__triangle : FAIL \n");
		return MSFAIL;}

	ret = VLmaplatTria(dev,i,1,i-1,1,i-1,0);
 	if (ret!=MSSUCC) {
 		printf("maplat__triangle : FAIL \n");
		return MSFAIL;}

	#ifdef DEBUG2
		trace_ligne_plat(dev,i,0,i-1,0);
		trace_ligne_plat(dev,i,1,i-1,1);
		trace_ligne_plat(dev,i,0,i,1);
	#endif
 }

 for(i=dem_param-1;i>=0;i-=1){

	ret = VLmaplatTria(dev,i,0,i+1,1,i+1,0);
 	if (ret!=MSSUCC) {
 		printf("maplat__triangle : FAIL \n");
		return MSFAIL;}

	ret = VLmaplatTria(dev,i,1,i+1,0,i+1,1);
 	if (ret!=MSSUCC) {
 		printf("maplat__triangle : FAIL \n");
		return MSFAIL;}

	#ifdef DEBUG2
		trace_ligne_plat(dev,i,0,i+1,0);
		trace_ligne_plat(dev,i,1,i+1,1);
		trace_ligne_plat(dev,i,0,i,1);
	#endif
 }

 return MSSUCC;
   
}

/******************************************************************************/
/* VLmaplatNDevel : calcul de mise a plat de surface non developable  	      */
/* alloue l'espace nescessaire au resultat				      */
/* rend MSSUCC si ok , MSFAIL sinon   					      */
/******************************************************************************/
IGRlong VLmaplatNDevel (dev)
struct mise_a_plat	*dev;
{

IGRint		dem_u;
IGRint		dem_v;
IGRint		i;
IGRlong		ret;
IGRdouble	dm;
IGRdouble 	*P,*P1,*P2,*M;
IGRvector	vect;
BSrc		rc;


 dev->M = (IGRdouble *) malloc (dev->Nb_u*dev->Nb_v*3*sizeof(IGRdouble));
 if (dev->M==NULL) {printf("VLmaplatDevel  : alloc point : FAIL \n");
	return MSFAIL;}

 if( dev->developpable == 1 ) return MSSUCC;

 dem_u = dev->Nb_u/2 - 1;
 dem_v = dev->Nb_v/2 - 1;
 
 #ifdef DEBUG
 	printf(" 1/2 param u = %d \n",dem_u);
 	printf(" 1/2 param v = %d \n",dem_v);
 #endif 

 P = dev->P;
 P1= P + VLindex(dev,dem_u,dem_v,0);
 P2= P + VLindex(dev,dem_u,dem_v+1,0);
 for(i=0;i<3;i++) vect[i] = P2[i] - P1[i];
/* dm = BSlenvec(&rc,vect) / 2.0; */
 dm = BSlenvec(&rc,vect);

 M = dev->M + VLindex(dev,dem_u,dem_v,0);
 M[0] = 0.0;
/* M[1] = -dm;*/
 M[1] = 0.0;
 M[2] = 0.0;
 M = dev->M + VLindex(dev,dem_u,dem_v+1,0);
 M[0] = 0.0;
 M[1] = -dm;
 M[2] = 0.0;

 #ifdef DEBUG2
	trace_ligne_plat(dev,dem_u,dem_v,dem_u,dem_v+1);
 #endif 

 /* bande centrale horizontale */

 for(i=dem_u+1;i<dev->Nb_u;i++){

	ret = VLmaplatTria(dev,i,dem_v,i-1,dem_v,i-1,dem_v+1);
 	if (ret!=MSSUCC) {
 		printf("maplat__triangle : FAIL \n");
		return MSFAIL;}

	ret = VLmaplatTria(dev,i,dem_v+1,i-1,dem_v+1,i-1,dem_v);
 	if (ret!=MSSUCC) {
 		printf("maplat__triangle : FAIL \n");
		return MSFAIL;}

	#ifdef DEBUG2
		trace_ligne_plat(dev,i,dem_v+0,i-1,dem_v+0);
		trace_ligne_plat(dev,i,dem_v+1,i-1,dem_v+1);
		trace_ligne_plat(dev,i,dem_v+0,i,dem_v+1);
	#endif
 }

 for(i=dem_u-1;i>=0;i-=1){

	ret = VLmaplatTria(dev,i,dem_v,i+1,dem_v+1,i+1,dem_v);
 	if (ret!=MSSUCC) {
 		printf("maplat__triangle : FAIL \n");
		return MSFAIL;}

	ret = VLmaplatTria(dev,i,dem_v+1,i+1,dem_v,i+1,dem_v+1);
 	if (ret!=MSSUCC) {
 		printf("maplat__triangle : FAIL \n");
		return MSFAIL;}

	#ifdef DEBUG2
		trace_ligne_plat(dev,i,dem_v,i+1,dem_v);
		trace_ligne_plat(dev,i,dem_v+1,i+1,dem_v+1);
		trace_ligne_plat(dev,i,dem_v+0,i,dem_v+1);
	#endif
 }

 /* bande centrale verticale */

 for(i=dem_v+2;i<dev->Nb_v;i++){

	ret = VLmaplatTria(dev,dem_u,i,dem_u,i-1,dem_u+1,i-1);
 	if (ret!=MSSUCC) {
 		printf("maplat__triangle : FAIL \n");
		return MSFAIL;}

	ret = VLmaplatTria(dev,dem_u+1,i,dem_u,i-1,dem_u+1,i-1);
 	if (ret!=MSSUCC) {
 		printf("maplat__triangle : FAIL \n");
		return MSFAIL;}

	#ifdef DEBUG2
		trace_ligne_plat(dev,dem_u,i-1,dem_u,i);
		trace_ligne_plat(dev,dem_u+1,i-1,dem_u+1,i);
		trace_ligne_plat(dev,dem_u,i,dem_u+1,i);
	#endif
 }

 for(i=dem_v-1;i>=0;i-=1){

	ret = VLmaplatTria(dev,dem_u,i,dem_u,i+1,dem_u+1,i+1);
 	if (ret!=MSSUCC) {
 		printf("maplat__triangle : FAIL \n");
		return MSFAIL;}

	ret = VLmaplatTria(dev,dem_u+1,i,dem_u,i+1,dem_u+1,i+1);
 	if (ret!=MSSUCC) {
 		printf("maplat__triangle : FAIL \n");
		return MSFAIL;}

	#ifdef DEBUG2
		trace_ligne_plat(dev,dem_u,i+1,dem_u,i);
		trace_ligne_plat(dev,dem_u+1,i+1,dem_u+1,i);
		trace_ligne_plat(dev,dem_u,i,dem_u+1,i);
	#endif
 }

 if ((dev->Nb_u>2)&&(dev->Nb_v>2)){

	ret = VLmaplatQuad(dev,dem_u,dem_v,0,0);
 	if (ret!=MSSUCC) {
 		printf("VLmaplatQuad 1 : FAIL \n");
		return MSFAIL;}

	ret = VLmaplatQuad(dev,dem_u,dem_v+1,0,dev->Nb_v-1);
 	if (ret!=MSSUCC) {
 		printf("VLmaplatQuad 1 : FAIL \n");
		return MSFAIL;}	

	ret = VLmaplatQuad(dev,dem_u+1,dem_v+1,dev->Nb_u-1,dev->Nb_v-1);
 	if (ret!=MSSUCC) {
 		printf("VLmaplatQuad 2 : FAIL \n");
		return MSFAIL;}	

	ret = VLmaplatQuad(dev,dem_u+1,dem_v,dev->Nb_u-1,0);
 	if (ret!=MSSUCC) {
 		printf("VLmaplatQuad 4 : FAIL \n");
		return MSFAIL;}	
 }

/*
 IGRint i3;
 IGRdouble dx, dy;
 M =dev->M ;
 dx = M[0];
 dy = M[1];
 i3 = 3 * dev->Nb_u*dev->Nb_v;

 for(i=0;i<i3;i+=3){ 
	M[i]	-= dx;
	M[i]	 = M[i]	 - dx;
xx	M[i+1]	 = M[i+1] - dy;
	M[i+1]   = -M[i+1] + dy;
 }

*/

ret = VLcreUnfoldSrfStr( dev );
if (ret != MSSUCC) {
	printf("Error in VLmaplatNDevel() \n");
	printf("VLcreUnfoldSrfStr() FAILED \n");
	return MSFAIL;
}

 return MSSUCC;   

}

/******************************************************************************/
/* VLdrawTria : this function is used for debug only, to create the 	      */
/* unwraped tria							      */
/******************************************************************************/
IGRlong VLdrawTria( pts, numU, i0, j0, i1, j1, i2, j2, creOpt, triaId  )

	IGRdouble	*pts;	/*I array containing all the points */
	IGRint		numU;   /*I because i0,j0 are the repectively the
				    the colum and row index, I need the
				    the number of components in a row to
				    define the index in the array.*/
	IGRint		i0,j0;  
	IGRint		i1,j1;  
	IGRint		i2,j2;
	IGRint		creOpt; /*I     creOpt = 0, create and not display 
					creOpt = 1, create and display 
					creOpt = 2, create display delete */
struct	GRid		*triaId;

{
IGRlong			sts, loc_msg;
struct	GRvg_construct	cnst;
struct	IGRpolyline	lstr_geom;
	IGRdouble	tab[12];
	IGRint		i, j;


	lstr_geom.points = &tab[0];
	
	VLinitCnst( &cnst );
	triaId->objid	= NULL_OBJID;
	triaId->osnum	= cnst.env_info->md_id.osnum;
	
	sts = om$construct(	classid	= OPP_GR3dlinestr_class_id,
				osnum	= triaId->osnum,
				p_objid	= &triaId->objid );
	if( sts & 1 ){

		lstr_geom.num_points	= 4;
		j = 3 * ( i0 + ( j0 * numU ) );
		for(i=0;i<3;i++){ 
			tab[i] = pts[j+i];
			tab[9+i] = tab[i];
		}

		j = 3 * ( i1 + ( j1 * numU ) );
		for(i=0;i<3;i++) tab[3+i] = pts[j+i];
		
		j = 3 * ( i2 + ( j2 * numU ) );
		for(i=0;i<3;i++) tab[6+i] = pts[j+i];

		cnst.geometry	= (IGRchar *) &lstr_geom;

		sts = om$send(	msg	 = message GRgraphics.GRaltconstruct
						( &cnst ),
				senderid = NULL_OBJID,
				targetid = triaId->objid,
				targetos = triaId->osnum );
	}

	if( ! (sts&1)){

		sts = om$send(	msg	 = message GRgraphics.GRdelete
						( &loc_msg, cnst.env_info ),
				senderid = NULL_OBJID,
				targetid = triaId->objid,
				targetos = triaId->osnum );
		triaId->objid = NULL_OBJID;
		loc_msg	= MSFAIL;
		goto wrapup;
	}

	if( creOpt == 0 ){

		/*c just create without display */

		loc_msg = MSSUCC;
	}
	else if( creOpt == 1){

		/*c create end display the tria */

		gr$display_object ( object_id = &triaId,
                	    	    md_env    = cnst.env_info,
		     	    	    mode      = GRbd );

		loc_msg = MSSUCC;
	}
	else{

		/*c display and delete the graphic object */

		gr$display_object ( object_id = &triaId,
                	    	    md_env    = cnst.env_info,
		     	    	    mode      = GRbd );

		sts = om$send(	msg	 = message GRgraphics.GRdelete
						( &loc_msg, cnst.env_info ),
				senderid = NULL_OBJID,
				targetid = triaId->objid,
				targetos = triaId->osnum );

		triaId->objid = NULL_OBJID;

		loc_msg = MSSUCC;
	}

wrapup:
	if( loc_msg != MSSUCC ) printf("error display tria\n");	
return	loc_msg;

}

end implementation VLabstract;
