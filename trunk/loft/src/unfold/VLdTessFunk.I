/* $Id: VLdTessFunk.I,v 1.6 2001/10/24 23:17:49 ramarao Exp $  */

/***************************************************************************
 * I/LOFT
 *
 * File:	src/unfold/VLdTessFunk.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VLdTessFunk.I,v $
 *	Revision 1.6  2001/10/24 23:17:49  ramarao
 *	Fixed TR# 5686.
 *	
 *	Revision 1.5  2001/09/07 17:07:21  ramarao
 *	Fixed TR# 5578.
 *	
 *	Revision 1.4  2001/07/27 14:05:47  ramarao
 *	Fixed TR# 5432.
 *	
 *	Revision 1.3  2001/06/25 17:43:18  ramarao
 *	Fixed an unwrap algorithm problem.
 *	
 *	Revision 1.2  2001/01/16 19:46:17  ramarao
 *	*** empty log message ***
 *	
# Revision 1.3  2000/09/13  19:57:56  pinnacle
# Replaced: loft/src/unfold/VLdTessFunk.I for:  by rchennup for Service Pack
#
# Revision 1.1  2000/04/24  20:12:46  pinnacle
# Created: loft/src/unfold/VLdTessFunk.I by rchennup for Service Pack
#
# Revision 1.7  2000/03/23  20:47:44  pinnacle
# Replaced: src/unfold/VLdTessFunk.I for:  by impd252 for loft
#
# Revision 1.6  2000/03/22  15:56:40  pinnacle
# Replaced: src/unfold/VLdTessFunk.I for:  by impd252 for loft
#
# Revision 1.5  1999/10/26  18:30:16  pinnacle
# ah
#
# Revision 1.2  1998/07/15  15:43:16  pinnacle
# Replaced: src/unfold/VLdTessFunk.I for:  by smpathak for loft
#
# Revision 1.1  1998/04/30  10:32:50  pinnacle
# LOFT 2.5.1
#
# Revision 1.4  1998/04/26  16:54:08  pinnacle
# Replaced: src/unfold/VLdTessFunk.I for:  by impd for loft
#
# Revision 1.3  1998/04/23  21:08:02  pinnacle
# Replaced: src/unfold/VLdTessFunk.I for:  by azuurhou for loft
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	04/23/98	adz		Changes VLtessOpt1 routine
 *	04/26/98	adz		Romove checking for 4 parents.
 *	07/15/98	Sandeep		Modiffication for TR#179801177
 *					checking for plate with 3 or 4 edges.
 *      04/09/99        ah              Rama Rao SP08 Fixes
 *      07/23/99        ah              Quick hack for bsmdistptsf problem
 *	04/24/00	Rama Rao	Modified VLtessOpt1 function.
 ***************************************************************************/

class implementation VLabstract;

#include <stdio.h>
#include <math.h>
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
#include "msmacros.h"
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
#include "VDtypedef.h"
#include "VDefp.h"
#include "VDgeom.h"
#include "parametric.h"
#include "vsmiscmacros.h"
#include "vsedgedef.h"
#include "vsedgemacros.h"

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
#include "bsarclen.h"
#include "bsrev_cv.h"
#include "bssf3o4cvs.h"
#include "bstst_plan.h"
#include "bsunwght_p.h"
#include "bswght_p.h"

#include "mainvmx.h"
#include "mamulmx.h"
#include "matypemx.h"
#include "maoptsxfo.h"
#include "marptsxfo.h"
#include "vlunfold.h"
#include "msdef.h"
#include "vlmsg.h"

extern			GRdpb_get();
extern			GRdpb_put();
extern  IGRchar		*memcpy();
extern			GRdisplay_object();
extern  void		FAsetRng();
extern  void            BSsfevaln();
extern  IGRboolean      BSequalspcs();


from EMSsubbs import EMisoparcvs;
from GRcurve import GRendpts;
from GRcurve import GRptseqspace;

extern GRclassid        OPP_GR3dlinestr_class_id;
extern GRclassid        OPP_EMSgenbs_class_id;

/******************************************************************************/

IGRlong VLadd_parameters (dev,cst,bool,length,extension)

/*d This function is called by VLalloc_mesh (dev) to refine the number
    of points to be evaluated in oder to get a regular set of points.
*/

struct mise_a_plat	*dev;
struct  GRvg_construct  *cst;
int			bool;
double			*length;
int			*extension;

{

	IGRlong		ii,loc_msg,sts,msg;
	IGRdouble	uv[2];
	IGRint		nb;
	IGRboolean	stat;
struct IGRbsp_curve	*iso_bsp=NULL;
	GRobjid		*objid = NULL;
	IGRdouble	dbl1,dbl2,dbl3;
	IGRint		i,j,k,DNM1,*N;
	IGRdouble	average,**pars;
	IGRdouble	len1,len2;
	BSrc		bsrc;

  /*c
   * Set variables depending the direction of the refinement of the tessalation
   */

  msg = MSFAIL;
  uv[0] = 0;
  uv[1] = 1;

  if (bool) {
    N = &(dev->Nb_v);
    pars = &(dev->Param_v);
  }
  else {
    N = &(dev->Nb_u);
    pars = &(dev->Param_u);
  }

  DNM1 = *N - 1;

  /*c
   * create 2 iso curves in the direction given by the variable bool
   * bool = TRUE -> u direction, else -> v direction
   *
   */

  sts = om$send (msg = message EMSsubbs.EMisoparcvs  (
                                   &loc_msg,
                                   &(dev->surf_id.mod_env.md_env.matrix_type),
                                   dev->surf_id.mod_env.md_env.matrix,
                                   cst,
                                   FALSE,
                                   2,
                                   uv,
                                   bool,
                                   &ii,
                                   &objid),
        senderid  = NULL_OBJID,
        targetid  = dev->surf_id.obj_id.objid,
        targetos  = dev->surf_id.obj_id.osnum );
  if (!(sts&loc_msg&1)) {
  	printf("Error in VLadd_parameters\n");
  	printf("EMisoparcvs FAILED\n" ) ;
  	goto wrapup;
  }

  /*c
   * we strat the evaluation for the first isocurve
   *
   */

  sts = om$send(msg = message GRvg.GRgenabsg(&loc_msg,
                                        &(cst->env_info->md_env.matrix_type),
                                        cst->env_info->md_env.matrix,
                                        (IGRchar **)&iso_bsp),
                  senderid = NULL_OBJID,
                  targetid = objid[0],
                  targetos = cst->env_info->md_id.osnum );
  if (!(sts&loc_msg&1)) {
  	printf("Error in VLadd_parameters\n");
  	printf("GRgenabsg 1 FAILED\n") ;
  	goto wrapup;
  }

  /*c
   * with an equally space parametrisation, we evaluate the girth length
   * and we also evaluate the cumulate to later get the average length.
   * then we evaluate an average length.
   *
   */

  average = 0;
  for (i=0;i<DNM1;i++) 
  {
    dbl1 = (IGRdouble) i / DNM1;
    dbl2 = (IGRdouble) (i+1) / DNM1;
    dbl3 = (IGRdouble) (2*i+1) / (2*DNM1);
    BSarclen(&bsrc,&stat,iso_bsp,&dbl1, &dbl2,&dbl3,&length[i]);
    if (bsrc != BSSUCC) {
  	printf("Error in VLadd_parameters\n");
  	printf("BSarclen 1 FAILED\n") ;
  	goto wrapup;
    }
    average += length[i];
  }
  average = average / DNM1;

  /*c
   * At this stage we got the girth length between all the equally parametric
   * spaced points. Here we evaluate the number of point to insert for each 
   * interval.
   */

  for (i=0;i<DNM1;i++)
  {
    if (length[i]>average) {
      nb = length[i]/average;
      if (nb >= 2) extension[i] = nb-1;
    }
  }

  /*c
   * We repeat the same process for the second iso curve, with a small trick
   * at the end
   */ 
   
  sts = om$send(msg = message GRvg.GRgenabsg(&loc_msg,
                                        &(cst->env_info->md_env.matrix_type),
                                        cst->env_info->md_env.matrix,
                                        (IGRchar **)&iso_bsp),
                  senderid = NULL_OBJID,
                  targetid = objid[1],
                  targetos = cst->env_info->md_id.osnum );
  if (!(sts&loc_msg&1)) {
  	printf("Error in VLadd_parameters\n");
  	printf("GRgenabsg 2 FAILED\n") ;
  	goto wrapup;
  }

  average = 0;

  for (i=0;i<DNM1;i++) 
  {
    dbl1 = (IGRdouble) i / DNM1;
    dbl2 = (IGRdouble) (i+1) / DNM1;
    dbl3 = (IGRdouble) (2*i+1) / (2*DNM1);
    BSarclen(&bsrc,&stat,iso_bsp,&dbl1, &dbl2,&dbl3,&length[i]);
    if (bsrc != BSSUCC) {
  	printf("Error in VLadd_parameters\n");
  	printf("BSarclen 2 FAILED\n") ;
  	goto wrapup;
    }
    average += length[i];
  }
  average = (IGRdouble) average/DNM1;

  /*c
   * Because we have already evaluate insertion with the first iso,
   * for a given interval we have to compare nb with extension[i].
   */
  
  for (i=0;i<DNM1;i++)
  {
    if (length[i]>average) {
      nb = length[i]/average;
      nb--;
      if (nb > extension[i])  extension[i] = nb;
    }
  }

  /*c
   * here you may feal, I am done, the writter of this function added an extra 
   * refinement that is quite costly and may not be very usefull.
   * For a given interval he is evaluating the girth length of the remaining
   * piece when the insertion is done. He also evaluates the girth length of
   * first piece for the next interval. 
   * If these lentghs are over the ratio 2 then extra insertion are added
   * into extension[i] or extension[i+1].
   * This process starts with the second curve just to avoid one call to
   * GRgenabs() and we have already the geometry of objid[1].
   * The process is then repeated with objid[0]. Because in this area,
   * no function have been added to avoid duplication of code, 
   * everytime somebody changes some something in this code he needs to 
   * undertsand that he may have to do it in 2 areas !!!!.
   *
   *      l<----------- interval i ----------->l<-----------interval (i+1)--
   *      l                                    l
   *    i/DNM1                           (i+1)/DNM1
   *      l                                    l
   *      l			   l<-- len1-->l<---- len2---->l 
   *  ....+............j...........j...........+...............k............
   *                              /     /      l       \       l
   *                             /     /      / \       \       \
   *           	  	        /     /  dbl2    \	 \       dbl2
   *                           / dbl3             \       dbl3
   *                      dbl1                     dbl1
   */ 


  
  for (i=0;i<DNM1-1;i++)
  {
    if (extension[i]) {

      dbl1 = (IGRdouble) i/DNM1 +
             ((IGRdouble) extension[i]/(IGRdouble) (extension[i]+1))*
                                              ((IGRdouble)1/(IGRdouble)DNM1);
      dbl2 = (IGRdouble) (i+1) / DNM1;
      dbl3 = (IGRdouble) (dbl1+dbl2) * 0.5;
      BSarclen(&bsrc,&stat,iso_bsp,&dbl1, &dbl2,&dbl3,&len1);
      if (bsrc != BSSUCC) {
  		printf("Error in VLadd_parameters\n");
  		printf("BSarclen 3 FAILED\n") ;
  		goto wrapup;
      }
    }
    else   len1 = length[i];
    
    if (extension[i+1]) {
 
      dbl1 = (IGRdouble) (i+1)/DNM1;
      dbl2 =  dbl1 + ((IGRdouble)1/(IGRdouble)(extension[i+1]+1))*
                                              ((IGRdouble)1/(IGRdouble)DNM1);
      dbl3 = (IGRdouble) (dbl1+dbl2)/2.;
      BSarclen(&bsrc,&stat,iso_bsp,&dbl1, &dbl2,&dbl3,&len2);
      if (bsrc != BSSUCC) {
  		printf("Error in VLadd_parameters\n");
  		printf("BSarclen 4 FAILED\n") ;
  		goto wrapup;
      }
    }
    else len2 = length[i+1];

    /*c
     * We test if the girth length of the last inserted span of (i) interval
     * is close to the girth length of the first inserted span
     * of the (i+1) interval. If the ratio is <= 2 then no extra point will be
     * inserted, else it will be added into either into extension[i] or
     * extension[i+1].
     */
  
//    dbl1 = len1/len2;

/* START - JLL- Add and replace the previous piece of code
                The same piece of code is added bellow     */ 

     if( (len1 <= 0.1) || (len2 <= 0.1) ) dbl1 = 0;
     else{
         dbl1 = len1 / len2;
	if (dbl1 >= 2.) extension[i] += (int) dbl1 - 1;
     	else {
       	     dbl1 = len2 / len1;
	     if (dbl1 >= 2.) extension[i+1] += (int) dbl1 - 1;
        }
     } 

/* END */

  } /*c end of the loop on the DNM1-1 intervals */



  /*c
   * Retieve again the firsy isocurve and apply the same punishement
   * After GRgenbas the piece of code is repeated.
   */

  sts = om$send(msg = message GRvg.GRgenabsg(&loc_msg,
                                        &(cst->env_info->md_env.matrix_type),
                                        cst->env_info->md_env.matrix,
                                        (IGRchar **)&iso_bsp),
                  senderid = NULL_OBJID,
                  targetid = objid[0],
                  targetos = cst->env_info->md_id.osnum );
  if (!(sts&loc_msg&1)) {
  	printf("Error in VLadd_parameters\n");
  	printf("GRgenabsg 3 FAILED\n") ;
	goto wrapup;
  }


  for (i=0;i<DNM1-1;i++)
  {
    if (extension[i]) {

      dbl1 = (IGRdouble) i/DNM1 +
             ((IGRdouble) extension[i]/(IGRdouble) (extension[i]+1))*
                                              ((IGRdouble)1/(IGRdouble)DNM1);
      dbl2 = (IGRdouble) (i+1)/DNM1;
      dbl3 = (IGRdouble) (dbl1+dbl2)/2.;

      BSarclen(&bsrc,&stat,iso_bsp,&dbl1, &dbl2,&dbl3,&len1);
      if (bsrc != BSSUCC) {
  	printf("Error in VLadd_parameters\n");
  	printf("BSarclen 5 FAILED\n") ;
        goto wrapup;
      }
    }
    else 
      len1 = length[i];
    
    if (extension[i+1]) {

      dbl1 = (IGRdouble) (i+1)/DNM1;
      dbl2 =  dbl1 + ((IGRdouble)1/(IGRdouble)(extension[i+1]+1))*
                                              ((IGRdouble)1/(IGRdouble)DNM1);
      dbl3 = (IGRdouble) (dbl1+dbl2)/2.;
      BSarclen(&bsrc,&stat,iso_bsp,&dbl1, &dbl2,&dbl3,&len2);
      if (bsrc != BSSUCC) {
  	printf("Error in VLadd_parameters\n");
  	printf("BSarclen 6 FAILED\n") ;
        goto wrapup;
      }
    }
    else len2 = length[i+1];

/* START - JLL- Add and replace the previous piece of code */ 

    if( (len1 <= 0.1) || (len2 <= 0.1) ) dbl1 = 0;
    else{
         dbl1 = len1 / len2;
	if (dbl1 >= 2.) extension[i] += (int) dbl1 - 1;
     	else {
       	     dbl1 = len2 / len1;
	     if (dbl1 >= 2.) extension[i+1] += (int) dbl1 - 1;
        }
    } 

/* END */ 
  
  }/*c end of the loop on i */


  for (nb=0,i=0;i<DNM1;i++) 
     nb += extension[i];

  /*d
   * Now we have the good number of points, then malloc and fill 
   * the pars array. 
   */
 
  *pars = (IGRdouble *) malloc ((nb+ *N)*sizeof(IGRdouble));
  if( *pars == NULL ) {
  	printf("Error in VLadd_parameters\n");
  	printf("malloc Param FAILED\n") ;
 	goto wrapup; 
  }

  for (i=0,k=0;k< *N;k++,i++)
  {
    (*pars)[i] = (IGRdouble) k / DNM1;
    if (extension[k]) {
      for (j=1;j<=extension[k];j++)
      {
        (*pars)[i+j]=(*pars)[i]+((IGRdouble)j/(IGRdouble)(extension[k]+1))*
                                              ((IGRdouble)1/(IGRdouble)DNM1);
      }      
      i += j-1;
    } 
  } 
  *N += nb;

  msg = MSSUCC;

wrapup :

  if (objid) {
    om$send( msg = message  GRgraphics.GRdelete( &sts,cst->env_info),
                    senderid = NULL_OBJID,
                    targetid = objid[0],
                    targetos = cst->env_info->md_id.osnum);
    om$send( msg = message  GRgraphics.GRdelete( &sts,cst->env_info),
                    senderid = NULL_OBJID,
                    targetid = objid[1],
                    targetos = cst->env_info->md_id.osnum);
    free(objid); 
    objid = NULL;
  }

  return msg;
}
/******************************************************************************/

IGRlong VLalloc_mesh (dev)

/*d based on a first evaluation of the number of points in u and v,
    this function call VLadd_parameters() to add points such that the
    quad remains relatively constant in term of length.

    In order to refine the the tessalation, we extract the 2 iso curves 
    in u at the parameter v = 0 and 1.
    Then we introduce if necessary extra points in this direction.
    The insertion work is done by the VLadd_paramters() function.
    The same process is repeated in in the v direction for the iso u =0 and 1. 
    VLalloc_mesh() produces the matrix of u,v parameters and 
    then avarage normal is evaluated at each u,v parameter.

*/

struct mise_a_plat	*dev; /*I the structure containing everything */
{

int			nb,i;
long			sts,msg;
struct  GRvg_construct  cst;
double			*length;
int			*extension;

  msg=MSFAIL;
  length = NULL;
  extension = NULL;

  /* JLL 03/15/00 st_modif1
	add this code to avoid a lot of unnecessary computations
	when the surface is of order 2X2.
	In this case, just malloc and copy the knots vector in u and v
	*/
	if( (dev->surface->u_order == 2) && (dev->surface->v_order == 2) )
	{
                dev->Nb_u = dev->surface->u_num_poles;
                dev->Nb_v = dev->surface->v_num_poles;

		i = (dev->Nb_u)*sizeof(double);
		dev->Param_u = (double *) malloc((i));
		if (dev->Param_u == NULL) {
			printf("Error in VLalloc_mesh\n");
       		printf("malloc dev->Param_u FAILED\n");
       		goto wrapup;
		}
		memcpy((IGRchar *) dev->Param_u,(IGRchar *)&dev->surface->u_knots[1],
       (IGRint) (i));

		i = (dev->Nb_v)*sizeof(double);		
		dev->Param_v = (double *) malloc((i));
		if (dev->Param_v == NULL) {
			printf("Error in VLalloc_mesh\n");
       		printf("malloc dev->Param_v FAILED\n");
       		goto wrapup;
		}
		memcpy((IGRchar *) dev->Param_v,(IGRchar *)&dev->surface->v_knots[1],
       (IGRint) (i));
	   
		msg = MSSUCC;
		return MSSUCC;	   		
	}



/* JLL 03/15/00 ed_modif1 */

  VLinitCnst(&cst);


  /*c
   * length and extension are 2 arrays that will be used in both directions
   * to insert the necessary number of points.
   * length will store the girth lenth of each interval.
   * extension will store the number of points to be inserted for each
   * interval. This insertion will still be done using linear parametric 
   * spacing between existing parameters.
   * In order to use these temporary arrays in both u and v directions, they are
   * dimensioned to max(dev->Nb_u,dev->NB_v)
   *
   */

  nb = dev->Nb_u;
  if (nb < dev->Nb_v) nb = dev->Nb_v; 

  length = (IGRdouble *) malloc (nb*sizeof(IGRdouble));
  if (length == NULL){
  	printf("Error in VLalloc_mesh\n");
  	printf("malloc for length FAILED\n" ) ;
  	goto wrapup;
  }
  
  extension = (IGRint *) malloc (nb*sizeof(IGRint));
  if (extension == NULL){
 	printf("Error in VLalloc_mesh\n");
  	printf("malloc for extension FAILED\n" ) ;
  	goto wrapup;
  }

  /*c
   *  Process in the u direction
   */

  for (i=0;i< nb; i++) extension[i] = 0;
  sts = VLadd_parameters (dev,&cst,TRUE, length,extension);
  if (!(sts&1)){
 	printf("Error in VLalloc_mesh\n");
  	printf("VLadd_parameters for TRUE case FAILED\n" ) ;
  	goto wrapup;
  }

  /*c
   *  Process in the v direction
   */

  for (i=0;i< nb; i++) extension[i] = 0;
  sts = VLadd_parameters (dev,&cst,FALSE,length,extension);
  if (!(sts&1)){
 	printf("Error in VLalloc_mesh\n");
  	printf("VLadd_parameters for FALSE case FAILED\n" ) ;
  	goto wrapup;
  }

  /*c
   *  Now I got all my points inserted, dev->Nb_u and dev->Nb_v have been
   *  modified by VLadd_paramters, I can malloc my array of points.
   *  Why do I malloc here only dev->P and not also dev->M, dev->N ?
   */

/* JLL 02/28/00 modif1  make the malloc in the calling function */
/*
  This malloc is done in VLtessOpt(0)

  dev->P = (IGRdouble *) 
                  malloc ( dev->Nb_u * dev->Nb_v * 3 * sizeof(IGRdouble));
  if( dev->P == NULL ) {
 	printf("Error in VLalloc_mesh\n");
  	printf("malloc for dev->P FAILED\n" ) ;
  	goto wrapup;
  }
*/
/* JLL 02/28/00 end modif1*/

  msg=MSSUCC;
wrapup :
  if (length) {free(length); length = NULL;}
  if (extension) {free(extension); extension = NULL;}
 return msg;
}

/******************************************************************************/

IGRlong	VLtessOpt0( dev )

/*d This function evaluates the points and normals at the offset value,
    using the four sides of a plate.
    This tessalation technique will be mainly used for the ruled surfaces or
    surface of projections.
    
*/

/*h 18/April/95		JLL: creation date */


struct mise_a_plat	*dev; /*I the structure containing everything */


{

	IGRint		i, j, i3, k, k3;
	IGRdouble	UAveLen, VAveLen, UAve, VAve, ratio;
	IGRlong		locMsg, retMsg, pole_count;
	BSrc		rc;
	IGRdouble	*P;

	UI_status(" Processing Natural Mesh " );

#define MINPTS 60

retMsg = MSFAIL;

/* JLL 03/11/00 st_modif1
	if the u_order = 2 then dev->nb_u = u_num_poles
	if the v_order = 2 then dev->nb_v = v_num_poles
	 
*/
        /*c we evaluate an average length in u and in v to define
            a ratio between u and v such that the length of the
            resulting quad will be close in u and v */

        /*c evaluation of the average length in u */

        pole_count = dev->surface->u_num_poles * dev->surface->v_num_poles;

        if( dev->surface->rational )
        {
            BSunwght_p( &rc, dev->surface->poles, dev->surface->weights,
                        &pole_count, dev->surface->poles );
        }

        UAveLen = 0.0;
        j = 3 * dev->surface->u_num_poles;
        i3 = j * dev->surface->v_num_poles;
        k3 = 0;

        for( i=0; i<i3; i+=j )
        {
                k3 += j;
                for( k=(i+3);k<k3;k+=3)
                        UAveLen += BSdistptpt(&rc,&dev->surface->poles[k],
                                         &dev->surface->poles[(k-3)] );
        }

        UAve = UAveLen / ( (dev->surface->u_num_poles-1) *
                            dev->surface->v_num_poles );

        /* evaluation of the average length in the v direction */

        VAveLen = 0.0;
        i3 = i3 - 3 * dev->surface->u_num_poles;
        for( i=0; i<i3; i+=3 )
                VAveLen += BSdistptpt(&rc,&dev->surface->poles[i],
                                         &dev->surface->poles[i+j] );

        VAve = VAveLen / ( dev->surface->u_num_poles *
                                  (dev->surface->v_num_poles -1 ));

        #ifdef DEBUG
                printf("UAveLen = %f,UAve = %f, VAveLen = %f,VAve = %f\n",
                        UAveLen,UAve,VAveLen,VAve);
        #endif

        if( dev->surface->rational )
        {
            BSwght_p( &rc, dev->surface->poles, dev->surface->weights,
                      &pole_count, dev->surface->poles );
        }

if( dev->surface->u_num_poles == 2 )
{
    dev->Nb_u = 2;
    if( dev->surface->v_num_poles > 2 )
    {
        if( UAve > VAve ){
              dev->Nb_v = 1+VAveLen / (VAve * dev->surface->u_num_poles);
        }
        else{
              i = (IGRint)(VAve / UAve);
              dev->Nb_v = 1+VAveLen / (UAve * dev->surface->u_num_poles);
        }

        if( (dev->Nb_u <= dev->Nb_v) && (dev->surface->v_order > 2) ){
                ratio = (double) (dev->Nb_u) / (double) (dev->Nb_v);
                if( ratio > 0.1 ){
                        i = MINPTS / dev->Nb_u + 1;
                        dev->Nb_v = i * dev->Nb_v;
                }
        }
    }
    else  dev->Nb_v = 2;
}
else if( dev->surface->v_num_poles == 2 ){
    dev->Nb_v = 2;

    if( dev->surface->u_num_poles > 2 )
    {
        if( UAve > VAve ){
              dev->Nb_u = 1+UAveLen / (VAve * dev->surface->v_num_poles);
        }
        else{
              i = (IGRint)(VAve / UAve);
              dev->Nb_u = 1+UAveLen / (UAve * dev->surface->v_num_poles);
        }

        if( (dev->Nb_u > dev->Nb_v) && (dev->surface->u_order > 2) ){
                ratio = (double) (dev->Nb_v) / (double) (dev->Nb_u);
                if( ratio > 0.1 ){
                        i = MINPTS / dev->Nb_v + 1;
                        dev->Nb_u = i * dev->Nb_u;
                }
        }
    }
    else   dev->Nb_u = 2;
}
/* JLL 03/11/00 end_modif1 */

else{
	if( UAve > VAve ){
	      dev->Nb_u = 1+UAveLen / (VAve * dev->surface->v_num_poles);
	      dev->Nb_v = 1+VAveLen / (VAve * dev->surface->u_num_poles);
	}
	else{
	      i = (IGRint)(VAve / UAve);
	      dev->Nb_u = 1+UAveLen / (UAve * dev->surface->v_num_poles);
	      dev->Nb_v = 1+VAveLen / (UAve * dev->surface->u_num_poles);
	}

        if( dev->Nb_u <= dev->Nb_v ){
                ratio = (double) (dev->Nb_u) / (double) (dev->Nb_v);
                if( ratio > 0.1 ){
                        i = MINPTS / dev->Nb_u + 1;
                        dev->Nb_u = i * dev->Nb_u;
                        dev->Nb_v = i * dev->Nb_v;
                }
        }
        else{
                ratio = (double) (dev->Nb_v) / (double) (dev->Nb_u);
                if( ratio > 0.1 ){
                        i = MINPTS / dev->Nb_v + 1;
                        dev->Nb_u = i * dev->Nb_u;
                        dev->Nb_v = i * dev->Nb_v;
                }
        }
}
	
#ifdef DEBUG	
printf("dev->Nb_u = %d,dev->Nb_v = %d\n",dev->Nb_u, dev->Nb_v);
#endif

/* JLL 02/28/00 modif1 */

	locMsg = VLalloc_mesh(dev);
	if (!(locMsg&1)) goto wrapup;

dev->P = (IGRdouble *) malloc ( dev->Nb_u * dev->Nb_v * 3 * sizeof(IGRdouble));
if( dev->P == NULL ) {
 	printf("Error in VLtessOpt0\n");
  	printf("malloc for dev->P FAILED\n" ) ;
  	goto wrapup;
}
/*JLL 02/28/00 end modif1 */

dev->norm = (IGRdouble *) malloc (dev->Nb_u*dev->Nb_v*3*sizeof(IGRdouble));
if ( dev->norm == NULL) {
 	printf("Error in VLtessOpt0\n");
  	printf("malloc for dev->norm FAILED\n" ) ;
  	goto wrapup;
}

dev->M = (IGRdouble *) malloc( dev->Nb_u*dev->Nb_v*3*sizeof(IGRdouble));
if( dev->M == NULL){
	printf("Error in VLtessOpt0\n");
	printf("malloc for dev->M FAILED\n");
}

if( (dev->surface->u_order == 2) && (dev->surface->v_order == 2) ){
	memcpy((IGRchar *) dev->P,(IGRchar *) dev->surface->poles,
       		(IGRint) (dev->Nb_u*dev->Nb_v*3*sizeof(IGRdouble)));

	P = dev->M;	
}
else
	P = dev->P;


BSsfarrevn(     &rc,
                dev->surface,
                dev->Nb_u,
                dev->Param_u,
                dev->Nb_v,
                dev->Param_v,
                P,
                dev->norm );
if (rc!=BSSUCC) {
        goto wrapup;}


retMsg = MSSUCC;
wrapup:

	return retMsg;
}

/******************************************************************************/
IGRlong	VLtessOpt1( dev, MeshTol )

/*d This function evaluates the points and normals at the offset value,
    using the four sides of a plate.
    This new approach is mainely used for shell plates.
*/

/*h 18/April/95		JLL: creation date */ 
/*h 22/April/98		JLL: modification for surfaces 5 edges */


struct mise_a_plat	*dev;   /*I the structure containing everything */


IGRdouble		MeshTol;/*I approximate length in the case of opt = 1.
				    if The approximate length is <= 0 then
				    the function will evaluate the appropriated
				    length.
				*/

{
	IGRint			i, j, nb_pt;
	IGRlong			locSts, locMsg, retMsg, numPoles;
struct  IGRbsp_curve     	**workEdge, **realCvs;
struct 	IGRbsp_curve    	*cv, **fit_cv;
	IGRint			count = 0 ,
				numRealCvs = 0 ;
	struct GRid		*list, grEdge;
	struct  GRvg_construct  cst;
	IGRdouble		pt1[3], tmp[6],	
				prec ;
struct  IGRbsp_surface   	*srf2d;
	IGRboolean		intCusps;		


#define MINPTS 60

	UI_status(" Processing Boundaries Mesh " );

/*
 * Initialisation
 */

retMsg     = MSFAIL;
intCusps   = TRUE;
list 	   = NULL;
srf2d 	   = NULL;
workEdge   = NULL;
fit_cv     = NULL;
realCvs    = NULL;

VLinitCnst(&cst);

locSts = vs$get_surface_edges( msg         = &locMsg,
                               sfId        = &dev->surf_id.obj_id,
                               sfEnv       = &dev->surf_id.mod_env,
                               edgeType    = VS_K_CONTOUR_EDGES,
                               edCount     = &count,
                               edList      = &list ) ;

if( !( locSts & 1 & locMsg ) ) {
    	printf("Error in VLtessOpt1\n");
    	printf("vs$get_surface_edges FAILED\n" ) ;
    	goto wrapup;
}

if( count < 3 ){
	#ifdef DEBUG
	printf("Error in VLtessOpt1 count = %d\n",count);
	#endif
//        retMsg = GREATER_MAX_EDGE_ALLOWED;
      	goto wrapup;
}

/*
 * Malloc the array of bsp_curve
 */

fit_cv = ( struct IGRbsp_curve ** )
	 om$malloc( size = count * sizeof(struct IGRbsp_curve *));
if( fit_cv == NULL ){
	printf("Error in VLtessOpt1\n");
      	printf("om$malloc for fit_cv FAILED\n");
	goto wrapup;
}

for (i=0; i<count; i++) fit_cv[i] = NULL;

/*
 * Retrieve the geometry of the edges and apply a fitting if the returned
 * edge is a Linestring or an order 2 bsp_curve
 */ 


for (i=0; i<count; i++)
{
	cv = NULL;
  	locSts = vs$get_graphic_edge(  	msg     = &locMsg,
        	                       	edId    = &list[i],
                               		edEnv   = &dev->surf_id.mod_env,
                               		copy    = FALSE,
                               		copyEnv = NULL,
                               		grEdge  = &grEdge) ;
  	if( !( locSts & 1 & locMsg ) ) {
    		printf("Error in VLtessOpt1\n");
      		printf("vs$get_graphic_edge FAILED\n" ) ;
      		goto wrapup;
    	}

    	locSts = om$send(msg = message GRvg.GRgenabsg(
				&locMsg,
                                &dev->surf_id.mod_env.md_env.matrix_type,
                                dev->surf_id.mod_env.md_env.matrix,
                                (IGRchar **)&cv),
                  senderid = NULL_OBJID,
                  targetid = grEdge.objid,
                  targetos = grEdge.osnum );

  	if( !( locSts & 1 & locMsg ) ) {
    		printf("Error in VLtessOpt1\n");
      		printf("GRgenabsg FAILED\n" ) ;
      		goto wrapup;
    	}


    	if ( (cv->order == 2) && ( cv->num_poles > 2 ) ) {

     		 BSalloccv( (IGRshort) 4,
               		    (IGRlong ) cv->num_poles + 3,
               		    (IGRshort) 0,
               		    (IGRshort) 0,
               		    &fit_cv[i],
               		    &locMsg );

    		if( locMsg != BSSUCC ){
    			printf("Error in VLtessOpt1\n");
      			printf("BSalloccv 1 FAILED i = %d\n",i);
			goto wrapup;
    		}

      		BSdirfitcv( (long) cv->num_poles,(IGRpoint *) cv->poles,
			    (IGRshort) 4, 0, 0, FALSE, NULL, NULL,
			    fit_cv[i],&locMsg);
        	if (locMsg != BSSUCC) {
    			printf("Error in VLtessOpt1\n");
        		printf("BSdirfitcv FAILED i = %d\n",i);
        		goto wrapup;
      		}
                 
    	}
    	else {

      		BSalloccv( (IGRshort) cv->order,
               		   (IGRlong ) cv->num_poles,
               		   (IGRshort) cv->rational,
               		   (IGRshort) cv->num_boundaries,
               		   &fit_cv[i],
               		   &locMsg );

    		if( locMsg != BSSUCC ){
    			printf("Error in VLtessOpt1\n");
    		 	printf("BSalloccv 2 FAILED i = %d\n",i);
			goto wrapup;
    		}

      		BScv_copy(&locMsg,cv,fit_cv[i]);
      		if (locMsg != BSSUCC) {
    			printf("Error in VLtessOpt1\n");
        		printf("BScv_copy FAILED i = %d\n",i);
        		goto wrapup;
      		}

    	}


}/* end of the loop on the count edges */

/*
 * Check if the edges are degenerated. After this call we are looking for
 * 3 or 4 distinct curves otherwise we exit.
 */

/*c retrieve the cht and multiply by 2 */

/* BSEXTRACTPAR( &locMsg, BSTOLCHRDHT, prec ); */
prec = 0.01;

BSsidecntrs( count, fit_cv, intCusps, prec, &numRealCvs, &realCvs, &locMsg );
if( locMsg != BSSUCC ){
	printf("Error in VLtessOpt1\n");
	printf("Error in BSsidecntrs\n");
	goto wrapup;
}

/*
 * Increament of one
 */
numRealCvs++;


  if( (numRealCvs != 4) ){
    if( (numRealCvs != 3) ){
	printf("Error in VLtessOpt1\n");
    	printf("Invalid Number of edges  = %d\n",numRealCvs);
        goto wrapup;

    } 
  } 



/*
 * Now we got 3 or 4 curves, we then evaluate an approximated 
 * the length of it.
 */


for (i=0; i<numRealCvs; i++)
{
    	tmp[i] = 0.0;
    	nb_pt = 3 * (realCvs[i]->num_poles - 1);
    	for ( j=0; j<nb_pt; j=j+3)
	tmp[i] += BSdistptpt( &locMsg, &realCvs[i]->poles[j], 
		  &realCvs[i]->poles[j+3] );
}


/*
 *	evaluate the number of steps in u and v
 */

if( !(MeshTol > 0.0) ){

	/*
	 * the MeshTol is not given so we evaluate it
	 */

	MeshTol = tmp[0];
	j = 0;
	
	for(i=1;i<numRealCvs;i++){
		 if( tmp[i] > MeshTol ){
			j = i;
			MeshTol = tmp[i];
		 }
	}
	
	MeshTol = tmp[j] / MINPTS;
	
}

if( numRealCvs == 4 ){

	if( (realCvs[0]->num_poles == 2) && (realCvs[2]->num_poles == 2) )
		dev->Nb_u = 2;
	else if (tmp[0] > tmp[2]){
		dev->Nb_u = tmp[0] / MeshTol;
		if( dev->Nb_u < 2 ) dev->Nb_u = MINPTS;
	}
	else{
		dev->Nb_u = tmp[2] / MeshTol;
		if( dev->Nb_u < 2 ) dev->Nb_u = MINPTS;

	}

	if( (realCvs[1]->num_poles == 2) && (realCvs[3]->num_poles == 2) )
		dev->Nb_v = 2;
	else if (tmp[1] > tmp[3]){
		dev->Nb_v = tmp[1] / MeshTol;
		if( dev->Nb_v < 2 ) dev->Nb_v = MINPTS;
	}
	else{
		dev->Nb_v = tmp[3] / MeshTol;
		if( dev->Nb_v < 2 ) dev->Nb_v = MINPTS;

	}

}
else{

	if( realCvs[0]->num_poles == 2 )	dev->Nb_u = 2;
	else{
		dev->Nb_u = tmp[0] / MeshTol;
		if( dev->Nb_u < 2 ) dev->Nb_u = MINPTS;
	}

	if( (realCvs[1]->num_poles == 2) && (realCvs[2]->num_poles == 2) )
		dev->Nb_v = 2;
	else if (tmp[1] > tmp[2]){
		dev->Nb_v = tmp[1] / MeshTol;
		if( dev->Nb_v < 2 ) dev->Nb_v = MINPTS;
	}
	else{
		dev->Nb_v = tmp[2] / MeshTol;
		if( dev->Nb_v < 2 ) dev->Nb_v = MINPTS;

	}

}

/*
 *  we build now a four sided Coons patch using points with arc length
 *  spacing.
 */

/*c malloc the "u and v curves" */

workEdge = ( struct IGRbsp_curve ** )
	 om$malloc( size = numRealCvs * sizeof(struct IGRbsp_curve *));
if( workEdge == NULL ){
	printf("Error in VLtessOpt1\n");
      	printf("om$malloc for workEdge FAILED\n");
	goto wrapup;
}
for(i=0;i<numRealCvs;i++) { workEdge[i] = NULL; }


for(i=0;i<numRealCvs;i++) {

        if( numRealCvs == 4 ){
		if( (i==0) || (i==2) ) numPoles = dev->Nb_u;
		else		       numPoles = dev->Nb_v;
	}
	else{
		if( (i==0) ) numPoles = dev->Nb_u;
		else	     numPoles = dev->Nb_v;
	}
	
    	BSalloccv( (IGRshort) 2,
        	   (IGRlong ) numPoles,
               	   (IGRshort) 0,
                   (IGRshort) 0,
                   &workEdge[i],
                   &locMsg );

      	if (locMsg != BSSUCC) {
    		printf("Error in VLtessOpt1\n");
        	printf("BSalloccv FAILED for workEdge[%d]\n",i);
        	goto wrapup;
      	}
}

/*c evaluate the equaly spaced points along the Physical edges */

for (i=0; i< numRealCvs; i++) {

        if( numRealCvs == 4 ){
		if( (i==0) || (i==2) ) nb_pt = dev->Nb_u;
		else		       nb_pt = dev->Nb_v;
	}
	else{
		if( (i==0) ) nb_pt = dev->Nb_u;
		else	     nb_pt = dev->Nb_v;
	}

    	nb_pt--;

        if (nb_pt < 2) {
          workEdge[i]->knots[1] = 0;
          workEdge[i]->knots[2] = 1;
          workEdge[i]->poles[0] = realCvs[i]->poles[0];
          workEdge[i]->poles[1] = realCvs[i]->poles[1];
          workEdge[i]->poles[2] = realCvs[i]->poles[2];
          workEdge[i]->poles[3] = realCvs[i]->poles[3];
          workEdge[i]->poles[4] = realCvs[i]->poles[4];
          workEdge[i]->poles[5] = realCvs[i]->poles[5];
        }
        else {
    	  BSequalspcs(&locMsg,realCvs[i],NULL,&nb_pt,&(workEdge[i]->knots[1]),
                  workEdge[i]->poles);
    	  if (locMsg != BSSUCC){
    		  printf("Error in VLtessOpt1\n");
        	  printf("BSequalspcs FAILED for workEdge[%d]\n",i);
        	  goto wrapup;
	  }
        }

    	nb_pt++;
  
     	workEdge[i]->order          = (IGRshort) 2;
     	workEdge[i]->periodic       = FALSE;
     	workEdge[i]->non_uniform    = FALSE;
     	workEdge[i]->num_poles      = (IGRlong) nb_pt;
     	workEdge[i]->num_knots      = (IGRlong) nb_pt + 2;
     	workEdge[i]->rational       = FALSE;
     	workEdge[i]->planar         = FALSE;
     	workEdge[i]->phy_closed     = FALSE;
     	workEdge[i]->num_boundaries = 0;

     	workEdge[i]->knots[0]       = 0.0;
     	workEdge[i]->knots[1]       = 0.0;
     	workEdge[i]->knots[nb_pt]   = 1.0;
     	workEdge[i]->knots[nb_pt+1] = 1.0;
}

dev->Param_u = (double *) malloc((dev->Nb_u)*sizeof(double));
if (dev->Param_u == NULL) {
	printf("Error in VLtessOpt1\n");
       	printf("malloc dev->Param_u FAILED\n");
       	goto wrapup;
}


dev->Param_v = (double *) malloc((dev->Nb_v)*sizeof(double));
if (dev->Param_v == NULL) {
	printf("Error in VLtessOpt1\n");
       	printf("malloc dev->Param_v FAILED\n");
       	goto wrapup;
}

/*c set the knots vector in u and v */

tmp[0] = dev->Nb_u - 1; 
for (i=0;i<dev->Nb_u;i++)
{
    	tmp[1] = i/tmp[0];
    	workEdge[0]->knots[i+1] = tmp[1];
    	dev->Param_u[i]         = tmp[1];
}

workEdge[0]->knots[0] = 0;
workEdge[1]->knots[0] = 0;
workEdge[2]->knots[0] = 0;
workEdge[0]->knots[dev->Nb_u+1] = 1;


if( numRealCvs == 4 ){
	j = 3;

	for (i=0;i<dev->Nb_u;i++)
	workEdge[2]->knots[i+1] = workEdge[0]->knots[i+1];

	workEdge[3]->knots[0] = 0; 
	workEdge[1]->knots[dev->Nb_v+1] = 1;
	workEdge[2]->knots[dev->Nb_u+1] = 1;
	workEdge[3]->knots[dev->Nb_v+1] = 1;
}
else{
	j = 2;
	workEdge[1]->knots[dev->Nb_v+1] = 1;
	workEdge[2]->knots[dev->Nb_v+1] = 1;
}

tmp[0] = dev->Nb_v - 1; 
for (i=0;i<dev->Nb_v;i++)
{
    	tmp[1] = i/tmp[0];
    	workEdge[1]->knots[i+1] = tmp[1];
    	workEdge[j]->knots[i+1] = tmp[1];
    	dev->Param_v[i]         = tmp[1];
}


/*c inverse curves to avoid orientation problems in the resulting unwrap.
    I think I should add a test to know if I must inverse curves or not.
    I am waiting for a TR with orientation problem to know which
    test I must add 
 */

BSrev_cv(&locMsg,workEdge[0]);
if (locMsg != BSSUCC ) goto wrapup;
/*
BSrev_cv(&locMsg,workEdge[1]);
if (locMsg != BSSUCC ) goto wrapup;
BSrev_cv(&locMsg,workEdge[2]);
if (locMsg != BSSUCC ) goto wrapup;
BSrev_cv(&locMsg,workEdge[3]);
if (locMsg != BSSUCC ) goto wrapup;
*/

/*c evaluate the coons patch */

if( numRealCvs == 4 )
	BSsf3o4cvs( workEdge[0], workEdge[1], workEdge[2], workEdge[3],
               	    &srf2d, &locMsg );
else
	BSsf3o4cvs( workEdge[0], workEdge[1], workEdge[2], NULL,
               	    &srf2d, &locMsg );

if( locMsg != BSSUCC ){
	printf("Error in VLtessOpt1\n");
       	printf("BSsf3o4cvs FAILED\n");
       	goto wrapup;
}

/*c project the poles onto the surface */

nb_pt = 3 * srf2d->u_num_poles * srf2d->v_num_poles;

for (i=0; i<nb_pt; i+=3)
{
       	pt1[0] = srf2d->poles[i];
       	pt1[1] = srf2d->poles[i+1];
       	pt1[2] = srf2d->poles[i+2];

       	BSmdistptsf(    &locMsg,
                        dev->surface,
                        pt1,
                        &srf2d->poles[i],
                        &srf2d->poles[i+1],
                        tmp,
                        &tmp[5] );

      	if (locMsg != BSSUCC) {
	  //printf("Error in VLtessOpt1\n");
	  //printf("BSmdistptsf FAILED\n");

		pt1[0] += .001;
		BSmdistptsf(&locMsg,
			    dev->surface,
			    pt1,
			    &srf2d->poles[i],
			    &srf2d->poles[i+1],
			    tmp,
			    &tmp[5] );

		if (locMsg != BSSUCC) {
		  printf("Error in VLtessOpt1\n");
		  printf("BSmdistptsf FAILED for %f,%f,%f\n",pt1[0],pt1[1],pt1[2]);
		  goto wrapup;
		}
      	}
      	srf2d->poles[i+2] = 0.0;
}

/*c construct the surface in the uv space */

cst.geometry = (IGRchar *) srf2d;

dev->uvSrfId.objid = NULL_OBJID;
dev->uvSrfId.osnum = cst.env_info->md_id.osnum; 

locSts =  om$construct( classid = OPP_EMSgenbs_class_id,
                        p_objid = &dev->uvSrfId.objid,
                        osnum   = dev->uvSrfId.osnum,
                        msg     = message GRgraphics.GRconstruct(&cst) );

if (!(locSts&1)) goto wrapup;

/*c malloc space and set the range, contour of the quad in the u,v space */

dev->def = (IGRdouble *) malloc ( (
                            	    dev->Nb_u*dev->Nb_v*3 +
                            	    4*(dev->Nb_u-1)*(dev->Nb_v-1) +
                            	    3*(2*(dev->Nb_u-1 + dev->Nb_v-1)+1) +
			            2*(dev->Nb_u + dev->Nb_v) -1
                                   )*sizeof(IGRdouble)
                                 );
if (dev->def == NULL) {
	printf("Error in VLtessOpt1\n");
       	printf("malloc dev->def FAILED\n");
       	goto wrapup;
}

memcpy((IGRchar *) dev->def,(IGRchar *) srf2d->poles,
       (IGRint) (dev->Nb_u*dev->Nb_v*3*sizeof(IGRdouble)));

FAsetRng((IGRshort) 3,dev->def,dev->Nb_u,dev->Nb_v,&locMsg);
if (locMsg != BSSUCC) {
	printf("Error in VLtessOpt1\n");
	printf("FAsetRng FAILED\n");
	goto wrapup;
}

/*c evaluate at every (u,v) the points and the normals */

dev->P = (IGRdouble *) malloc(dev->Nb_u*dev->Nb_v*3*sizeof(IGRdouble));
if (dev->P == NULL) {
        printf("Error in VLtessOpt1\n");
	printf("malloc dev->P FAILED\n");
	goto wrapup;
}

dev->norm = (IGRdouble *) malloc(dev->Nb_u*dev->Nb_v*3*sizeof(IGRdouble));
if (dev->norm == NULL) {
        printf("Error in VLtessOpt1\n");
	printf("malloc dev->norm FAILED\n");
	goto wrapup;
}

nb_pt = 3 * srf2d->u_num_poles * srf2d->v_num_poles;
for(i=0;i<nb_pt;i+=3){
     	tmp[0] = srf2d->poles[i];
     	tmp[1] = srf2d->poles[i+1];
     	BSsfevaln(dev->surface, tmp[0],tmp[1],1,&j,&(dev->P[i]),
        	  &(dev->norm[i]),&locMsg);
     	if( locMsg != BSSUCC ){
        	printf("Error in VLtessOpt1\n");
		printf("BSsfevaln FAILED at point = %d \n",i);
		if( i == 0 ) goto wrapup;
		else{
			dev->norm[i]   = dev->norm[i-3]; 
			dev->norm[i+1] = dev->norm[i-2];
			dev->norm[i+2] = dev->norm[i-1];
		}
	}
} 


retMsg = MSSUCC;

wrapup:

	if( workEdge ){
 	  for (i=0;i<numRealCvs;i++){
   	   if (workEdge[i]){ BSfreecv(&locMsg,workEdge[i]); workEdge[i]=NULL; }
	  }
	  om$dealloc(ptr=workEdge); workEdge = NULL;
 	}
        if( realCvs ){
 	  for (i=0;i<numRealCvs;i++){
   	   if (realCvs[i]) { BSfreecv(&locMsg,realCvs[i]);  realCvs[i]=NULL; }
	  }
	  om$dealloc(ptr=realCvs); realCvs = NULL;
 	}
	if( fit_cv ){
 	  for (i=0;i<count;i++){
   	   if (fit_cv[i])  { BSfreecv(&locMsg,fit_cv[i]);     fit_cv[i]=NULL; }
	  }
	  om$dealloc(ptr=fit_cv); fit_cv = NULL;
	  
 	}
	
   	if (list)     { om$dealloc(ptr=list);       list  = NULL; }
   	if (srf2d)    { BSfreesf(&locMsg,srf2d);    srf2d = NULL; }

	return retMsg;
}

#if 0

IGRlong	VLtessOpt1( dev, MeshTol )

/*d This function evaluates the points and normals at the offset value,
    using the four sides of a plate.
    This new approach is mainely used for shell plates.
*/

/*h 18/April/95		JLL: creation date */ 
/*h 22/April/98		JLL: modification for surfaces 5 edges */


struct mise_a_plat	*dev;   /*I the structure containing everything */


IGRdouble		MeshTol;/*I approximate length in the case of opt = 1.
				    if The approximate length is <= 0 then
				    the function will evaluate the appropriated
				    length.
				*/

{
	IGRint			i, j, nb_pt, edgeCnt=0;
	IGRlong			locSts, locMsg, retMsg, numPoles;
struct  IGRbsp_curve     	**workEdge, **realCvs, **realEdgeGeom;
struct 	IGRbsp_curve    	*edgeGeom[VDEFP_NEAT_EDGES_MAX], *curveGeom;
	IGRint			count = 0 , numRealEdges = 0,
				numRealCvs = 0 ;
	struct GRid		*list, grEdge;
	struct  GRvg_construct  cst;
	IGRdouble		pt1[3], tmp[6],	tol,
				prec ;
struct  IGRbsp_surface   	*srf2d;
	IGRboolean		intCusps;		


#define MINPTS 60

	UI_status(" Processing Boundaries Mesh " );

/*
 * Initialisation
 */

retMsg     = MSFAIL;
intCusps   = TRUE;
list 	   = NULL;
srf2d 	   = NULL;
workEdge   = NULL;
realCvs    = NULL;
realEdgeGeom = NULL;

VLinitCnst(&cst);

   vdgeom$GetTolerance(cht = &tol);

   locSts = VDefpGetSurfaceEdgeBsps( &dev->surf_id, VDEFP_NEAT_EDGES_MAX,
                        tol, &edgeCnt, edgeGeom );
   if( edgeCnt == 3 || edgeCnt == 4 )
   {
	numRealEdges = edgeCnt ;
	goto skip_bsfunc;
   }

   /*
    * Check if the edges are degenerated. After this call we are looking for
    * 3 or 4 distinct curves otherwise we exit.
    */
   BSsidecntrs( edgeCnt, edgeGeom, intCusps, prec, &numRealEdges, 
	        &realEdgeGeom, &locMsg ) ;
   if( locMsg != BSSUCC ){
        printf("Error in VLtessOpt1\n");
        printf("Error in BSsidecntrs\n");
        goto wrapup;
   }

   /*
    * Increament of one
    */
   numRealEdges++;
   if( (numRealEdges != 4) ){
    if( (numRealEdges != 3) ){
        printf("Error in VLtessOpt1\n");
        printf("Invalid Number of edges  = %d\n",numRealEdges);
        goto wrapup;

    }
   }

skip_bsfunc:
/*
 * Malloc the array of bsp_curve
 */

realCvs = ( struct IGRbsp_curve ** )
         om$malloc( size = numRealEdges * sizeof(struct IGRbsp_curve *));
if( realCvs == NULL ){
        printf("Error in VLtessOpt1\n");
        printf("om$malloc for realCvs FAILED\n");
        goto wrapup;
}

for (i=0; i<numRealEdges; i++) realCvs[i] = NULL;
numRealCvs = numRealEdges;

/*
 * Retrieve the geometry of the edges and apply a fitting if the returned
 * edge is a Linestring or an order 2 bsp_curve
 */ 


for (i=0; i<numRealEdges; i++)
{
    if( realEdgeGeom ) 	curveGeom = realEdgeGeom[i] ;
    else		curveGeom = edgeGeom[i] ;
    	if ( (curveGeom->order == 2) && ( curveGeom->num_poles > 2 ) ) {

     		 BSalloccv( (IGRshort) 4,
               		    (IGRlong ) curveGeom->num_poles + 3,
               		    (IGRshort) 0,
               		    (IGRshort) 0,
               		    &realCvs[i],
               		    &locMsg );

    		if( locMsg != BSSUCC ){
    			printf("Error in VLtessOpt1\n");
      			printf("BSalloccv 1 FAILED i = %d\n",i);
			goto wrapup;
    		}

      		BSdirfitcv( (long) curveGeom->num_poles,
			    (IGRpoint *) curveGeom->poles,
			    (IGRshort) 4, 0, 0, FALSE, NULL, NULL,
			    realCvs[i],&locMsg);
        	if (locMsg != BSSUCC) {
    			printf("Error in VLtessOpt1\n");
        		printf("BSdirfitcv FAILED i = %d\n",i);
        		goto wrapup;
      		}
                 
    	}
    	else {

      		BSalloccv( (IGRshort) curveGeom->order,
               		   (IGRlong ) curveGeom->num_poles,
               		   (IGRshort) curveGeom->rational,
               		   (IGRshort) curveGeom->num_boundaries,
               		   &realCvs[i],
               		   &locMsg );

    		if( locMsg != BSSUCC ){
    			printf("Error in VLtessOpt1\n");
    		 	printf("BSalloccv 2 FAILED i = %d\n",i);
			goto wrapup;
    		}

      		BScv_copy(&locMsg, curveGeom,realCvs[i]);
      		if (locMsg != BSSUCC) {
    			printf("Error in VLtessOpt1\n");
        		printf("BScv_copy FAILED i = %d\n",i);
        		goto wrapup;
      		}

    	}


}/* end of the loop on the count edges */

/*
 * Now we got 3 or 4 curves, we then evaluate an approximated 
 * the length of it.
 */
for (i=0; i<numRealCvs; i++)
{
    	tmp[i] = 0.0;
    	nb_pt = 3 * (realCvs[i]->num_poles - 1);
    	for ( j=0; j<nb_pt; j=j+3)
	tmp[i] += BSdistptpt( &locMsg, &realCvs[i]->poles[j], 
		  &realCvs[i]->poles[j+3] );
}


/*
 *	evaluate the number of steps in u and v
 */

if( !(MeshTol > 0.0) ){

	/*
	 * the MeshTol is not given so we evaluate it
	 */

	MeshTol = tmp[0];
	j = 0;
	
	for(i=1;i<numRealCvs;i++){
		 if( tmp[i] > MeshTol ){
			j = i;
			MeshTol = tmp[i];
		 }
	}
	
	MeshTol = tmp[j] / MINPTS;
	
}

if( numRealCvs == 4 ){

	if( (realCvs[0]->num_poles == 2) && (realCvs[2]->num_poles == 2) )
		dev->Nb_u = 2;
	else if (tmp[0] > tmp[2]){
		dev->Nb_u = tmp[0] / MeshTol;
		if( dev->Nb_u < 2 ) dev->Nb_u = MINPTS;
	}
	else{
		dev->Nb_u = tmp[2] / MeshTol;
		if( dev->Nb_u < 2 ) dev->Nb_u = MINPTS;

	}

	if( (realCvs[1]->num_poles == 2) && (realCvs[3]->num_poles == 2) )
		dev->Nb_v = 2;
	else if (tmp[1] > tmp[3]){
		dev->Nb_v = tmp[1] / MeshTol;
		if( dev->Nb_v < 2 ) dev->Nb_v = MINPTS;
	}
	else{
		dev->Nb_v = tmp[3] / MeshTol;
		if( dev->Nb_v < 2 ) dev->Nb_v = MINPTS;

	}

}
else{

	if( realCvs[0]->num_poles == 2 )	dev->Nb_u = 2;
	else{
		dev->Nb_u = tmp[0] / MeshTol;
		if( dev->Nb_u < 2 ) dev->Nb_u = MINPTS;
	}

	if( (realCvs[1]->num_poles == 2) && (realCvs[2]->num_poles == 2) )
		dev->Nb_v = 2;
	else if (tmp[1] > tmp[2]){
		dev->Nb_v = tmp[1] / MeshTol;
		if( dev->Nb_v < 2 ) dev->Nb_v = MINPTS;
	}
	else{
		dev->Nb_v = tmp[2] / MeshTol;
		if( dev->Nb_v < 2 ) dev->Nb_v = MINPTS;

	}

}

/*
 *  we build now a four sided Coons patch using points with arc length
 *  spacing.
 */

/*c malloc the "u and v curves" */

workEdge = ( struct IGRbsp_curve ** )
	 om$malloc( size = numRealCvs * sizeof(struct IGRbsp_curve *));
if( workEdge == NULL ){
	printf("Error in VLtessOpt1\n");
      	printf("om$malloc for workEdge FAILED\n");
	goto wrapup;
}
for(i=0;i<numRealCvs;i++) { workEdge[i] = NULL; }


for(i=0;i<numRealCvs;i++) {

        if( numRealCvs == 4 ){
		if( (i==0) || (i==2) ) numPoles = dev->Nb_u;
		else		       numPoles = dev->Nb_v;
	}
	else{
		if( (i==0) ) numPoles = dev->Nb_u;
		else	     numPoles = dev->Nb_v;
	}
	
    	BSalloccv( (IGRshort) 2,
        	   (IGRlong ) numPoles,
               	   (IGRshort) 0,
                   (IGRshort) 0,
                   &workEdge[i],
                   &locMsg );

      	if (locMsg != BSSUCC) {
    		printf("Error in VLtessOpt1\n");
        	printf("BSalloccv FAILED for workEdge[%d]\n",i);
        	goto wrapup;
      	}
}

/*c evaluate the equaly spaced points along the Physical edges */

for (i=0; i< numRealCvs; i++) {

        if( numRealCvs == 4 ){
		if( (i==0) || (i==2) ) nb_pt = dev->Nb_u;
		else		       nb_pt = dev->Nb_v;
	}
	else{
		if( (i==0) ) nb_pt = dev->Nb_u;
		else	     nb_pt = dev->Nb_v;
	}

    	nb_pt--;

        if (nb_pt < 2) {
          workEdge[i]->knots[1] = 0;
          workEdge[i]->knots[2] = 1;
          workEdge[i]->poles[0] = realCvs[i]->poles[0];
          workEdge[i]->poles[1] = realCvs[i]->poles[1];
          workEdge[i]->poles[2] = realCvs[i]->poles[2];
          workEdge[i]->poles[3] = realCvs[i]->poles[3];
          workEdge[i]->poles[4] = realCvs[i]->poles[4];
          workEdge[i]->poles[5] = realCvs[i]->poles[5];
        }
        else {
    	  BSequalspcs(&locMsg,realCvs[i],NULL,&nb_pt,&(workEdge[i]->knots[1]),
                  workEdge[i]->poles);
    	  if (locMsg != BSSUCC){
    		  printf("Error in VLtessOpt1\n");
        	  printf("BSequalspcs FAILED for workEdge[%d]\n",i);
        	  goto wrapup;
	  }
        }

    	nb_pt++;
  
     	workEdge[i]->order          = (IGRshort) 2;
     	workEdge[i]->periodic       = FALSE;
     	workEdge[i]->non_uniform    = FALSE;
     	workEdge[i]->num_poles      = (IGRlong) nb_pt;
     	workEdge[i]->num_knots      = (IGRlong) nb_pt + 2;
     	workEdge[i]->rational       = FALSE;
     	workEdge[i]->planar         = FALSE;
     	workEdge[i]->phy_closed     = FALSE;
     	workEdge[i]->num_boundaries = 0;

     	workEdge[i]->knots[0]       = 0.0;
     	workEdge[i]->knots[1]       = 0.0;
     	workEdge[i]->knots[nb_pt]   = 1.0;
     	workEdge[i]->knots[nb_pt+1] = 1.0;
}

dev->Param_u = (double *) malloc((dev->Nb_u)*sizeof(double));
if (dev->Param_u == NULL) {
	printf("Error in VLtessOpt1\n");
       	printf("malloc dev->Param_u FAILED\n");
       	goto wrapup;
}


dev->Param_v = (double *) malloc((dev->Nb_v)*sizeof(double));
if (dev->Param_v == NULL) {
	printf("Error in VLtessOpt1\n");
       	printf("malloc dev->Param_v FAILED\n");
       	goto wrapup;
}

/*c set the knots vector in u and v */

tmp[0] = dev->Nb_u - 1; 
for (i=0;i<dev->Nb_u;i++)
{
    	tmp[1] = i/tmp[0];
    	workEdge[0]->knots[i+1] = tmp[1];
    	dev->Param_u[i]         = tmp[1];
}

workEdge[0]->knots[0] = 0;
workEdge[1]->knots[0] = 0;
workEdge[2]->knots[0] = 0;
workEdge[0]->knots[dev->Nb_u+1] = 1;


if( numRealCvs == 4 ){
	j = 3;

	for (i=0;i<dev->Nb_u;i++)
	workEdge[2]->knots[i+1] = workEdge[0]->knots[i+1];

	workEdge[3]->knots[0] = 0; 
	workEdge[1]->knots[dev->Nb_v+1] = 1;
	workEdge[2]->knots[dev->Nb_u+1] = 1;
	workEdge[3]->knots[dev->Nb_v+1] = 1;
}
else{
	j = 2;
	workEdge[1]->knots[dev->Nb_v+1] = 1;
	workEdge[2]->knots[dev->Nb_v+1] = 1;
}

tmp[0] = dev->Nb_v - 1; 
for (i=0;i<dev->Nb_v;i++)
{
    	tmp[1] = i/tmp[0];
    	workEdge[1]->knots[i+1] = tmp[1];
    	workEdge[j]->knots[i+1] = tmp[1];
    	dev->Param_v[i]         = tmp[1];
}


/*c inverse curves to avoid orientation problems in the resulting unwrap.
    I think I should add a test to know if I must inverse curves or not.
    I am waiting for a TR with orientation problem to know which
    test I must add 
 */

BSrev_cv(&locMsg,workEdge[0]);
if (locMsg != BSSUCC ) goto wrapup;
/*
BSrev_cv(&locMsg,workEdge[1]);
if (locMsg != BSSUCC ) goto wrapup;
BSrev_cv(&locMsg,workEdge[2]);
if (locMsg != BSSUCC ) goto wrapup;
BSrev_cv(&locMsg,workEdge[3]);
if (locMsg != BSSUCC ) goto wrapup;
*/

/*c evaluate the coons patch */

if( numRealCvs == 4 )
	BSsf3o4cvs( workEdge[0], workEdge[1], workEdge[2], workEdge[3],
               	    &srf2d, &locMsg );
else
	BSsf3o4cvs( workEdge[0], workEdge[1], workEdge[2], NULL,
               	    &srf2d, &locMsg );

if( locMsg != BSSUCC ){
	printf("Error in VLtessOpt1\n");
       	printf("BSsf3o4cvs FAILED\n");
       	goto wrapup;
}

/*c project the poles onto the surface */

nb_pt = 3 * srf2d->u_num_poles * srf2d->v_num_poles;

for (i=0; i<nb_pt; i+=3)
{
       	pt1[0] = srf2d->poles[i];
       	pt1[1] = srf2d->poles[i+1];
       	pt1[2] = srf2d->poles[i+2];

       	BSmdistptsf(    &locMsg,
                        dev->surface,
                        pt1,
                        &srf2d->poles[i],
                        &srf2d->poles[i+1],
                        tmp,
                        &tmp[5] );

      	if (locMsg != BSSUCC) {
	  //printf("Error in VLtessOpt1\n");
	  //printf("BSmdistptsf FAILED\n");

		pt1[0] += .001;
		BSmdistptsf(&locMsg,
			    dev->surface,
			    pt1,
			    &srf2d->poles[i],
			    &srf2d->poles[i+1],
			    tmp,
			    &tmp[5] );

		if (locMsg != BSSUCC) {
		  printf("Error in VLtessOpt1\n");
		  printf("BSmdistptsf FAILED for %f,%f,%f\n",pt1[0],pt1[1],pt1[2]);
		  goto wrapup;
		}
      	}
      	srf2d->poles[i+2] = 0.0;
}

/*c construct the surface in the uv space */

cst.geometry = (IGRchar *) srf2d;

dev->uvSrfId.objid = NULL_OBJID;
dev->uvSrfId.osnum = cst.env_info->md_id.osnum; 

locSts =  om$construct( classid = OPP_EMSgenbs_class_id,
                        p_objid = &dev->uvSrfId.objid,
                        osnum   = dev->uvSrfId.osnum,
                        msg     = message GRgraphics.GRconstruct(&cst) );

if (!(locSts&1)) goto wrapup;

/*c malloc space and set the range, contour of the quad in the u,v space */

dev->def = (IGRdouble *) malloc ( (
                            	    dev->Nb_u*dev->Nb_v*3 +
                            	    4*(dev->Nb_u-1)*(dev->Nb_v-1) +
                            	    3*(2*(dev->Nb_u-1 + dev->Nb_v-1)+1) +
			            2*(dev->Nb_u + dev->Nb_v) -1
                                   )*sizeof(IGRdouble)
                                 );
if (dev->def == NULL) {
	printf("Error in VLtessOpt1\n");
       	printf("malloc dev->def FAILED\n");
       	goto wrapup;
}

memcpy((IGRchar *) dev->def,(IGRchar *) srf2d->poles,
       (IGRint) (dev->Nb_u*dev->Nb_v*3*sizeof(IGRdouble)));

FAsetRng((IGRshort) 3,dev->def,dev->Nb_u,dev->Nb_v,&locMsg);
if (locMsg != BSSUCC) {
	printf("Error in VLtessOpt1\n");
	printf("FAsetRng FAILED\n");
	goto wrapup;
}

/*c evaluate at every (u,v) the points and the normals */

dev->P = (IGRdouble *) malloc(dev->Nb_u*dev->Nb_v*3*sizeof(IGRdouble));
if (dev->P == NULL) {
        printf("Error in VLtessOpt1\n");
	printf("malloc dev->P FAILED\n");
	goto wrapup;
}

dev->norm = (IGRdouble *) malloc(dev->Nb_u*dev->Nb_v*3*sizeof(IGRdouble));
if (dev->norm == NULL) {
        printf("Error in VLtessOpt1\n");
	printf("malloc dev->norm FAILED\n");
	goto wrapup;
}

nb_pt = 3 * srf2d->u_num_poles * srf2d->v_num_poles;
for(i=0;i<nb_pt;i+=3){
     	tmp[0] = srf2d->poles[i];
     	tmp[1] = srf2d->poles[i+1];
     	BSsfevaln(dev->surface, tmp[0],tmp[1],1,&j,&(dev->P[i]),
        	  &(dev->norm[i]),&locMsg);
     	if( locMsg != BSSUCC ){
        	printf("Error in VLtessOpt1\n");
		printf("BSsfevaln FAILED at point = %d \n",i);
		if( i == 0 ) goto wrapup;
		else{
			dev->norm[i]   = dev->norm[i-3]; 
			dev->norm[i+1] = dev->norm[i-2];
			dev->norm[i+2] = dev->norm[i-1];
		}
	}
} 


retMsg = MSSUCC;

wrapup:

	if( workEdge ){
 	  for (i=0;i<numRealCvs;i++){
   	   if (workEdge[i]){ BSfreecv(&locMsg,workEdge[i]); workEdge[i]=NULL; }
	  }
	  om$dealloc(ptr=workEdge); workEdge = NULL;
 	}
        if( realEdgeGeom ){
 	  for (i=0;i<numRealEdges;i++){
   	   if (realEdgeGeom[i]) 
	   { BSfreecv(&locMsg,realEdgeGeom[i]);  realEdgeGeom[i]=NULL; }
	  }
	  om$dealloc(ptr=realEdgeGeom); realEdgeGeom = NULL;
 	}
	if( realCvs ){
 	  for (i=0;i<numRealCvs;i++){
   	   if (realCvs[i])  { BSfreecv(&locMsg,realCvs[i]); realCvs[i]=NULL; }
	  }
	  om$dealloc(ptr=realCvs); realCvs = NULL;
	  
 	}
	for( i=0; i<edgeCnt; ++i ) _FREE( edgeGeom[i] );
	
   	if (list)     { om$dealloc(ptr=list);       list  = NULL; }
   	if (srf2d)    { BSfreesf(&locMsg,srf2d);    srf2d = NULL; }

	return retMsg;
}

#endif

/******************************************************************************/

IGRlong	VLgetPtsNorms( dev, opt, MeshTol )

/*d This function evaluates the points and normals at the offset value
    calling different methodes of tessalation.
*/
    
/*h 23/October/92	JLL: creation date 
    7/July/93        	JLL: add malloc of dev->ind array 
    5/May/94		JLL: create the structre dev->devsrf if the
		             original surface is planar 
    18/April/95         JLL: due to the new tessalation this function
			     is rewritten
*/

struct mise_a_plat	*dev; /*I the structure containing everything */

IGRshort		opt;    /*I opt = 0 ---> iso parametric distribution
				    of the tessalation.
				    opt = 1 ---> tessalation using the four
				    sides of a plate. This new approach is
				    mainely used for shell plates
				*/

IGRdouble		MeshTol;/*I approximate length in the case of opt = 1.
				    if The approximate length is <= 0 then
				    the function will evaluate the appropriated
				    length.
				*/

{
	IGRint			i, i3, j;
	IGRlong			retMsg,msg, locRc;
struct	IGRbsp_surface 		*sfPtr;
	IGRdouble		ep;
	IGRint			nbPts;
	IGRdouble		nvec[3];
       

/*
 * Test if the surface is planar, then we just need to copy the original
 */

retMsg = MSFAIL;

dev->developpable = 0;

sfPtr = dev->surface;

BStst_plan( ( sfPtr->u_num_poles * sfPtr->v_num_poles ),
	    sfPtr->poles,
	    sfPtr->weights,
	    &dev->developpable,
	    nvec,
	    &locRc );
if( locRc != BSSUCC ){
	printf("Error in VLgetPtsNorms()\n");
	printf("Error BStst_plan rc = %d\n",locRc);
	goto wrapup;
}

if( dev->developpable == TRUE ){
	#ifdef DEBUG
	printf( " surface is developpable \n");
	#endif

	/* 
	JLL 02/23/00 we don't need to perform any tessalation. 
	Here we need to be careful because a planar BSpline surface is not becessary an order 2X2 surface, 
	it can be just any BSpline surface where all the poles are in a same plan.
	The plan is representing itself the facet and no neutral fiber definition is needed.
	*/

	dev->developpable = 1;
	msg = VLcreUnfoldSrfStr( dev );
	if( !(msg&1) ){
		printf("Error in VLgetPtsNorms()\n");
		printf("VLcreUnfoldSrfStr FAILED\n");
	 	goto wrapup;
	}
}

switch( opt )
{

case 0: {
		msg = VLtessOpt0(dev);
		if( !(msg&1) ){
			printf("Error in VLgetPtsNorms()\n");
			printf("VLtessOpt0 FAILED\n");
	 		goto wrapup;
		}
		
		break;
	}

case 1: {
		msg = VLtessOpt1(dev,MeshTol);
		if( !(msg&1) ){
                        if (msg == GREATER_MAX_EDGE_ALLOWED) {
                          ex$message(msgnumb = VL_E_GreaterEdgeAllow);
                          dev->tesselation_option = PARAMETRIC;
                          msg = VLtessOpt0(dev);
                          if( !(msg&1) ) {
                            printf("Error in VLgetPtsNorms()\n");
                            printf("VLtessOpt0 FAILED\n");
                            goto wrapup;
                          }
                        }
                        else {
			printf("Error in VLgetPtsNorms()\n");
			printf("VLtessOpt1 FAILED\n");
	 		goto wrapup;
                        }
		}

		break;
	}

default: goto wrapup;


}/*c end switch to evaluate the points and parameters in the surface */


/*
 * evaluate the true position of the points depending of the thickness and
 * ratio
 */



ep = dev->epaisseur * dev->fib_ratio;

nbPts = 3 * dev->Nb_u * dev->Nb_v;

if( fabs(ep) > 1.0E-6 ) {

 	for (i=0;i<nbPts;i+=3) {
		i3 = i + 3;
		for(j=i;j<i3;j++) dev->P[j] += ep * dev->norm[j];  
	}
}

retMsg = MSSUCC;

wrapup:
	return retMsg;
}

end implementation VLabstract;

