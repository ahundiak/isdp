/* $Id $  */

/*************************************************************************
 * I/LOFT
 *
 * File:        src/unwext/VLunwDevFunk.I
 *
 * Description: Contains all the set of functions used gererate and
 *		unwrap the facettes.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log $
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *      06/05/00   JLL		File Creation 
 *************************************************************************/

class implementation VLabstract;

#include <math.h>
#include "bserr.h"
#include "bsdotp.h"
#include "bsnorvec.h"
#include "bscrossp.h"
#include "grmacros.h"
#include "vsmiscmacros.h"
#include "vlstructure.h"

extern GRclassid	OPP_GR3dlinestr_class_id;

/*==========================================================================*/
/*==========================================================================*/
/* date: 5/20/00															*/
/* VLmaplatTriaNew : Unwrap a triangle										*/
/* rend MSSUCC si ok , MSFAIL sinon											*/
/* The fundamental difference in term of code between VLmaplatTria and      */
/* VLmaplatTriaNew we pass different arguments								*/
/****************************************************************************/

IGRlong VLmaplatTriaNew( pP, pM, pN, Nb_u, i, j, i0, j0, i1, j1 )
IGRdouble	*pP;	/* I pointer to the array of 3D factes */
IGRdouble	*pM;	/* I/O pointer to the unwraped facets */
IGRdouble	*pN;	/* I pointer to the normal */
IGRint		Nb_u;	/* I number of points in the u direction */
IGRint		i;	/* I indice sur param_u du point a calculer */
IGRint		j;      /* I indice sur param_v du point a calculer */
IGRint		i0; 	/* I indice sur param_u du point de ref1 */
IGRint		j0;	/* I indice sur param_v du point de ref1 */ 
IGRint		i1; 	/* I indice sur param_u du point de ref2 */ 
IGRint		j1;	/* I indice sur param_v du point de ref2 */
{
BSrc            rc;
IGRint          k, ijM3, i0j0M3, i1j1M3;
IGRdouble 	x, y, *P, *P1, *P0, *M, I[3], J[3], K[3], I0[3], J0[3], K0[3];
IGRvector	vect;

  #ifdef DEBUG
      struct	GRid	triaId;
     VLdrawTria( pP, Nb_u, i, j, i0, j0, i1, j1, 1, &triaId  );
  #endif


  /* Construction de IJK */

  /* Test if the point PIJ is coincident with P0 */
  ijM3   = 3*(i+Nb_u*j);
  i0j0M3 = 3*(i0+Nb_u*j0);
  i1j1M3 = 3*(i1+Nb_u*j1);

  P0= &(pP[i0j0M3]);
  M = &(pP[ijM3]);

  x = 0.0;
  for(k=0;k<3;k++)
  {
      y = M[k] - P0[k];
      x += y*y;
  }

  if( x < 1.0e-6 )
  {
      M  = &(pM[ijM3]);
      P0 = &(pM[i0j0M3]);
      for(k=0;k<3;k++) M[k] = P0[k];
      return MSSUCC;
  }

  /* Test if the point PIJ is coincident with P1 */
  P1= &(pP[i1j1M3]);

  x = 0.0;
  for(k=0;k<3;k++)
  {
      y = M[k] - P1[k];
      x += y*y;
  }

  if( x<1.0e-6)
  {
      M  = &(pM[ijM3]);
      P1 = &(pM[i1j1M3]);
      for(k=0;k<3;k++) M[k] = P1[k];
      return MSSUCC;
  }

  /* I = Pi0j0Pi1j1 */
  for(k=0;k<3;k++) I[k] = P1[k] - P0[k];
  BSnorvec(&rc,I);
  if (rc!=BSSUCC) 
  {
      printf(" VLmaplatTriaNew : BSnorvec 1 Fail\n");
      return MSFAIL;
  }

  /*c J = Pi0j0Pij */
  P1 = &(pP[ijM3]);
  for( k = 0; k < 3; k++ ) vect[k] = P1[k] - P0[k];

  BScrossp( &rc, I, vect,K );
  BSnorvec( &rc, K );
  if( rc != BSSUCC ) 
  {
      printf(" VLmaplatTriaNew : BSnorvec 2 Fail\n");
      return MSFAIL;
  }

  P1= &( pN[ijM3] );
  if( BSdotp( &rc, K, P1 ) < 0.0 )
  {
      K[0] = -K[0];
      K[1] = -K[1];
      K[2] = -K[2];
  }

  BScrossp(&rc,K,I,J);
  x = BSdotp(&rc,vect,I);
  y = BSdotp(&rc,vect,J);

  /* Construction de ijk */
  P1 = &(pM[i1j1M3]);
  P0 = &(pM[i0j0M3]);

  for(k=0;k<3;k++) I0[k] = P1[k] - P0[k];
  BSnorvec(&rc,I0);
  if (rc!=BSSUCC) 
  {
      printf(" VLmaplatTriaNew : BSnorvec 3 Fail\n");
      return MSFAIL;
  }

  K0[0] = 0;
  K0[1] = 0;
  K0[2] = 1;
  BScrossp(&rc,K0,I0,J0);
  if ( rc!=BSSUCC )
  {
      printf(" VLmaplatTriaNew : BScrossp 4 Fail\n");
      return MSFAIL;
  }

  M = &(pM[ijM3]);
  for(k=0;k<3;k++) M[k] = P0[k] + x*I0[k] + y*J0[k];

  #ifdef DEBUG
     VLdrawTria( pM, Nb_u, i, j, i0, j0, i1, j1, 1, &triaId  );
  #endif

  return MSSUCC;   

}

/* Newest version of VLmaplatRec : Just unwrap a facet
   The function has been modified to be more robust
   This function unwrap one corner of a facet thus this is equivalent to
   unwrap a triangle.If the first triangle is degenerated because in fact
   the facet is degenerated in a triangle, then we use the 2 other possible
   case to evaluate this point and make an average or not */

IGRlong VLmaplatRecNew ( pP, pM, pN, Nb_u, i, j, i0, j0, 
			 i1, j1, i2, j2, average )
IGRdouble	*pP;	/* I pointer to the array of 3D factes */
IGRdouble	*pM;	/* I/O pointer to the unwraped facets */
IGRdouble	*pN;	/* I pointer to the normals */
IGRint		Nb_u;	/* I number of points in the u direction */
IGRint		i;	/* I indice sur param_u du point a calculer */
IGRint		j;      /* I indice sur param_v du point a calculer */ 
IGRint		i0; 	/* I indice sur param_u du point de ref1 */
IGRint		j0;	/* I indice sur param_v du point de ref1 */
IGRint		i1; 	/* I indice sur param_u du point de ref2 */
IGRint		j1;	/* I indice sur param_v du point de ref2 */ 
IGRint		i2; 	/* I indice sur param_u du point de ref3 */
IGRint		j2;	/* I indice sur param_v du point de ref3 */
IGRint	average;	/* I option to evaluate P(ij) as an average, 
			   average = 1 else anything */
{
IGRint          Index;
IGRlong		ret, ret1;
IGRdouble 	x0, y0, deno;

  #ifdef DEBUG
    struct GRid    rectId;
    VLdrawRec( pP, Nb_u, i, j, i0, j0, i1, j1, i2, j2, 1, &rectId  );
  #endif

  deno = x0 = y0 = 0.0;
  Index = VLindex( Nb_u, i, j, 0 );

  if( average == 1)
  {
     ret = VLmaplatTriaNew ( pP, pM, pN, Nb_u, i, j, i1, j1, i2, j2 );
     if (ret!=MSSUCC) 
     {
	printf("Warning, Error in VLMaplatRecNew() \n");
 	printf("Average case, maplat__triangle 1 : FAIL\n");
     }
     else
     {
	x0 += pM[Index];
	y0 += pM[Index+1];
	deno = deno + 1.0;
     }

     ret = VLmaplatTriaNew ( pP, pM, pN, Nb_u, i, j, i0, j0, i1, j1 );
     if (ret!=MSSUCC) 
     {
	printf("Warning, Error in VLMaplatRecNew() \n");
 	printf("Average case, maplat__triangle 2 : FAIL\n");
     }
     else
     {
	x0 += pM[Index];
	y0 += pM[Index+1];
	deno = deno + 1.0;
     }

     ret = VLmaplatTriaNew ( pP, pM, pN, Nb_u, i, j, i0, j0, i2, j2 );
     if (ret!=MSSUCC)
     {
	printf("Warning,Error in VLMaplatRecNew() \n");
 	printf("Average case, maplat__triangle 3 : FAIL\n");
     }
     else
     {
	x0 = x0 + pM[Index];
	y0 = y0 + pM[Index+1];
	deno = deno + 1.0;
     }

     if( deno > 0.0 )
     {
	pM[Index]	= x0 / deno;
	pM[Index+1] = y0 / deno;
     }
     else
     {
	printf("Severe Error in VLMaplatRecNew() 0 \n");
	return MSFAIL;
     }
 }/* End of P(ij) computed as an average */
 else
 {
     ret = VLmaplatTriaNew ( pP, pM, pN, Nb_u, i, j, i1, j1, i2, j2 );
     if (ret==MSSUCC) return MSSUCC;
     else
     {
	printf("Warning, Error in VLMaplatRecNew() \n");
 	printf("maplat__triangle 1 : FAIL, Recovery Process \n");
    
	ret1 = VLmaplatTriaNew ( pP, pM, pN, Nb_u, i, j, i0, j0, i1, j1 );
	if (ret1!=MSSUCC) 
	{
	    printf("Warning, Error in VLMaplatRecNew() \n");
 	    printf("maplat__triangle 2 : FAIL, Recovery Process \n");
	}
	else
        {
	    x0 += pM[Index];
	    y0 += pM[Index+1];
	    deno = deno + 1.0;
	}

	ret1 = VLmaplatTriaNew ( pP, pM, pN, Nb_u, i, j, i0, j0, i2, j2 );
	if (ret1!=MSSUCC)
	{
	    printf("Warning,Error in VLMaplatRecNew() \n");
 	    printf("maplat__triangle 3 : FAIL, Recovery Process Impossible \n");
	}
	else
        {
	    x0 = x0 + pM[Index];
	    y0 = y0 + pM[Index+1];
	    deno = deno + 1.0;
	}

	if( deno > 0.0 )
	{
	    pM[Index]	= x0 / deno;
	    pM[Index+1] = y0 / deno;
	}
	else
	{
	    printf("Severe Error in VLMaplatRecNew() 1 \n");
	    return MSFAIL;
	}
    }
 }/* end of the NON average case */

 #ifdef DEBUG
    VLdrawRec( pM, Nb_u, i, j, i0, j0, i1, j1, i2, j2, 1, &rectId  );
 #endif

 return MSSUCC;
}

/* VLmaplatQuadNew : mise a plat de 2 bandes d'un quadran */
IGRlong VLmaplatQuadNew( dev, i0, j0, I, J ,IsResInM)
struct 	mise_a_plat	*dev;
IGRint			i0;	  /* I indice sur param_u du point de depart */
IGRint			j0;       /* I indice sur param_v du point de depart */ 
IGRint			I;	  /* I indice sur param_u du point cible */
IGRint			J;	  /* I indice sur param_v du point cible */ 
IGRboolean		IsResInM; /* I	IsresInM = True implies that results 
		are stored in dev->M else results are stored in dev->fg */
{
IGRlong			ret;
IGRint			i, j, det_i, inc_u, inc0_u, det_j, inc_v, inc0_v ;
IGRdouble		*pP, *pM, *pN;

  if( IsResInM == TRUE ) 	pM = dev->M;
  else			   	pM = dev->fg;

  pP = dev->P;
  pN = dev->norm;

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

  while( (i!=I)&&(j!=J) )
  {
     ret = VLmaplatRecNew( pP, pM, pN, dev->Nb_u, 
		  i+inc0_u, j+inc0_v, i, j, i+inc0_u, j, i, j+inc0_v, 0);
     if( ret !=MSSUCC)
     {
 	printf("VLmaplatRec : FAIL \n");
	return MSFAIL;
     }
     i = i+inc_u;
     j = j+inc_v;
  }

  inc_u = inc0_u;
  inc_v = inc0_v;
  if ( abs(det_i) < abs(det_j) ) inc_v=0; else inc_u=0;
  i = i0+inc_u;
  j = j0+inc_v;

  while( (i!=I)&&(j!=J) )
  {
     ret = VLmaplatRecNew( pP, pM, pN, dev->Nb_u, 
		  i+inc0_u, j+inc0_v, i, j, i+inc0_u, j, i, j+inc0_v, 0);
     if( ret != MSSUCC)
     {
 	printf("VLmaplatRec : FAIL \n");
	return MSFAIL;
     }
     i = i + inc_u;
     j = j + inc_v;
  }

  i = i0 + inc0_u;
  j = j0 + inc0_v;

  ret = VLmaplatQuadNew(dev, i, j, I, J, IsResInM );
  if( ret != MSSUCC )
  {
      printf("VLmaplatQuadNew : FAIL \n");
      return MSFAIL;
  }

  return MSSUCC;
}

/* VLevalDmNew : To get the development process started in VLmaplatNDevelNew()
   we must find a first facet tha is non degenerated. this function is just
   an helper function, that for 2 given points, return the length and MSFAIL
   the length is equal to 0 else MSSUCC and the length */
 
IGRlong VLevalDmNew( P, Nb_u, i1, j1, ij2, option, vect, dm )
IGRdouble	*P;	/*I: the matrix of points */
IGRint		Nb_u;	/*I: number of colums */
IGRint		i1;	/*I: index in u of the first point */
IGRint		j1;	/*I: index in v of the */
IGRint      	ij2;    /*I: the index in u or in v depending to option */
IGRint		option; /*I: option to evaluate dm at u or v constant, 
			     option = 1 -> u constant */
IGRdouble	*vect;  /*O: the vector vect = P2 - Pi1j1 */
IGRdouble	*dm;	/*O: the lentgh of vect if MSSUCC, else *dm=0 */
{
IGRint 		k;
IGRdouble	*P1, *P2,x;

  if( option )
  {
      P1 = P + VLindex (Nb_u, i1, j1, 0 );
      P2 = P + VLindex (Nb_u, i1, ij2, 0 );
  }
  else
  {
      P1 = P + VLindex (Nb_u, i1,  j1, 0 );
      P2 = P + VLindex (Nb_u, ij2, j1, 0 );
  }

  *dm = 0.0;

  for( k=0;k<3;k++ )
  {
      x   = P2[k] - P1[k];
      *dm = *dm + x*x;
      vect[k] = x;
  }

  if( (*dm > 0.0 ) )
  {
      *dm = sqrt(*dm);
      return MSSUCC;
  }
  else
  {
      *dm = 0.0;
      return MSFAIL;
  }
}

IGRlong VLfindMidVertex( dev, dmHorOrVer, IsResInM, dem_u, dem_v )
struct	mise_a_plat	*dev;
IGRboolean		dmHorOrVer;
IGRboolean		IsResInM;
IGRint			*dem_u;
IGRint			*dem_v;
{
IGRint		Nb_u, i, j, ib, jb, orgU, orgV;
IGRdouble	*pP, *pM, *pTemp, vect[3], dm;

  if( dmHorOrVer )
  {
      /* The horizontal case is not implemented yet */
      return MSFAIL;
  }
  else
  {
      orgU = dev->Nb_u/2 - 1;
      orgV = dev->Nb_v/2 - 1;

      Nb_u = dev->Nb_u;
      ib = Nb_u -1;
      jb = dev->Nb_v -1;
      pP = dev->P;

      for( j=orgV;j<jb;j++ )
      {
	for( i=orgU;i<ib;i++)
	  if( VLevalDmNew(pP, Nb_u, i, j, j+1, 1, &vect[0], &dm) == MSSUCC) 
          {
	     *dem_u = i;
	     *dem_v = j;
	     goto itsok;
	  }
      }

      if( (orgV-1) >= 0 )
      {
	for( j=orgV-1;j>=0;j-- )
	{
	     for( i=orgU;i<ib;i++)
		if( VLevalDmNew(pP, Nb_u, i, j, j+1, 1, &vect[0], &dm) == MSSUCC) 
	 	{	
		    *dem_u = i;
		    *dem_v = j;
		    goto itsok;
		}
	}
      }

      if( ((orgV-1) >= 0) && ((orgU-1) >= 0) )
      {
	for( j=orgV-1;j>=0;j-- )
	{
	    for( i=orgU-1;i>=0;i--)
	      if( VLevalDmNew(pP, Nb_u, i, j, j+1, 1, &vect[0], &dm) == MSSUCC)
              {       
                 *dem_u = i;
                 *dem_v = j;
                 goto itsok;
	      }
	}
      }

      if( (orgU-1) >= 0 )
      {
	for( j=orgV;j>jb;j++ )
	{
	    for( i=orgU-1;i>=0;i--)
	      if( VLevalDmNew(pP, Nb_u, i, j, j+1, 1, &vect[0], &dm) == MSSUCC) 
	      {       
		*dem_u = i;
	        *dem_v = j;
		goto itsok;
	      }
	}
      }

      printf("Error in VLfindMidVertex() \n");
      printf("FAILED to evaluate dm\n");
      return MSFAIL;

itsok:
      if( IsResInM == TRUE ) 	pTemp = dev->M;
      else 			pTemp = dev->fg;

      pM = pTemp + VLindex(dev->Nb_u,(*dem_u),(*dem_v),0);
      pM[0] = 0.0;
      pM[1] = 0.0;
      pM[2] = 0.0;

      pM = pTemp + VLindex(dev->Nb_u,(*dem_u),(*dem_v+1),0);
      pM[0] = 0.0;
      pM[1] = -dm;
      pM[2] = 0.0;
  }
  return MSSUCC;
}

/* VLmaplat0: Unfold the network with the original method */
IGRlong VLmaplat0 (dev, dem_u, dem_v, IsResInM)
struct	mise_a_plat	*dev;
IGRint			dem_u;
IGRint			dem_v;
IGRboolean		IsResInM; /*I	IsresInM = True implies that results 
		are stored in dev->M else results are stored in dev->fg */
{
IGRint 		i;
IGRlong 	ret;
IGRdouble 	*pP, *pM, *pN;

  if( IsResInM == TRUE ) 	pM = dev->M;
  else			  	pM = dev->fg;

  pP = dev->P;
  pN = dev->norm;

 /* bande centrale horizontale */
 for(i=dem_u+1;i<dev->Nb_u;i++)
 {
    ret = VLmaplatTriaNew( pP, pM, pN, dev->Nb_u, i, dem_v, i-1, 
			   dem_v, i-1 ,dem_v+1);
    if (ret!=MSSUCC) 
    {
	printf("Error in VLmaplat0() \n");
 	printf("maplat__triangle 1: i = %d, FAIL \n",i);
	return MSFAIL;
    }
      
    ret = VLmaplatTriaNew( pP, pM, pN, dev->Nb_u, i, dem_v+1, i-1, 
			   dem_v+1, i-1, dem_v );
    if (ret!=MSSUCC) 
    {
	printf("Error in VLmaplat0() \n");
 	printf("maplat__triangle 2: i = %d, FAIL \n",i);
	return MSFAIL;
    }

    #ifdef DEBUG2
       trace_ligne_plat( dev, i, dem_v+0, i-1, dem_v+0 );
       trace_ligne_plat( dev, i, dem_v+1, i-1, dem_v+1 );
       trace_ligne_plat( dev, i, dem_v+0, i,   dem_v+1);
    #endif
 }

 for( i = dem_u-1; i >= 0; i -= 1 )
 {
     ret = VLmaplatTriaNew( pP, pM, pN, dev->Nb_u, i, dem_v, i+1, dem_v+1, 
			    i+1, dem_v);
     if (ret!=MSSUCC) 
     {
	printf("Error in VLmaplat0() \n");
 	printf("maplat__triangle 3: i = %d, FAIL \n",i);
	return MSFAIL;
     }
       
     ret = VLmaplatTriaNew( pP, pM, pN, dev->Nb_u, i, dem_v+1, i+1, dem_v, 
			    i+1, dem_v+1);
     if (ret!=MSSUCC) 
     {
	printf("Error in VLmaplat0() \n");
 	printf("maplat__triangle 4: i = %d, FAIL \n",i);
	return MSFAIL;
     }

     #ifdef DEBUG2
	trace_ligne_plat(dev,i,dem_v,i+1,dem_v);
	trace_ligne_plat(dev,i,dem_v+1,i+1,dem_v+1);
	trace_ligne_plat(dev,i,dem_v+0,i,dem_v+1);
     #endif
 }

 /* bande centrale verticale */
 for( i = dem_v+2; i < dev->Nb_v; i++ )
 {
     ret = VLmaplatTriaNew( pP, pM, pN, dev->Nb_u, dem_u, i, dem_u, i-1, 
			    dem_u+1, i-1);
     if (ret!=MSSUCC) 
     {
	printf("Error in VLmaplat0() \n");
 	printf("maplat__triangle 5: i = %d, FAIL \n",i);
	return MSFAIL;
     }
       
     ret = VLmaplatTriaNew( pP, pM, pN, dev->Nb_u, dem_u+1, i, dem_u, 
			    i-1, dem_u+1, i-1 );
     if (ret!=MSSUCC) 
     {
	printf("Error in VLmaplat0() \n");
 	printf("maplat__triangle 6: i = %d, FAIL \n",i);
	return MSFAIL;
     }

     #ifdef DEBUG2
	trace_ligne_plat(dev,dem_u,i-1,dem_u,i);
	trace_ligne_plat(dev,dem_u+1,i-1,dem_u+1,i);
	trace_ligne_plat(dev,dem_u,i,dem_u+1,i);
     #endif
 }

 for(i=dem_v-1;i>=0;i-=1)
 {
     ret = VLmaplatTriaNew( pP, pM, pN, dev->Nb_u, dem_u, i, dem_u, i+1, 
			    dem_u+1, i+1 );
     if (ret!=MSSUCC) 
     {
	printf("Error in VLmaplat0() \n");
 	printf("maplat__triangle 7: i = %d, FAIL \n",i);
	return MSFAIL;
     }

     ret = VLmaplatTriaNew( pP, pM, pN, dev->Nb_u, dem_u+1, i,dem_u, i+1, 
			    dem_u+1, i+1 );
     if (ret!=MSSUCC) 
     {
	printf("Error in VLmaplat0() \n");
 	printf("maplat__triangle 8: i = %d, FAIL \n",i);
	return MSFAIL;
     }

     #ifdef DEBUG2
	trace_ligne_plat(dev,dem_u,i+1,dem_u,i);
	trace_ligne_plat(dev,dem_u+1,i+1,dem_u+1,i);
	trace_ligne_plat(dev,dem_u,i,dem_u+1,i);
     #endif
 }

 if( (dev->Nb_u>2) && (dev->Nb_v>2) )
 {
     ret = VLmaplatQuadNew( dev, dem_u, dem_v, 0, 0, IsResInM );
     if (ret!=MSSUCC) 
     {
	printf("Error in VLmaplat0() \n");
 	printf("VLmaplatQuadNew 1 : FAIL \n");
	return MSFAIL;
     }

     ret = VLmaplatQuadNew( dev, dem_u, dem_v+1, 0, dev->Nb_v-1, IsResInM );
     if( ret != MSSUCC ) 
     {
	printf("Error in VLmaplat0() \n");
 	printf("VLmaplatQuadNew 2 : FAIL \n");
	return MSFAIL;
     }	

     ret = VLmaplatQuadNew( dev,dem_u+1,dem_v+1,dev->Nb_u-1,dev->Nb_v-1,IsResInM);
     if (ret!=MSSUCC) 
     {
	printf("Error in VLmaplat0() \n");
 	printf("VLmaplatQuadNew 3 : FAIL \n");
	return MSFAIL;
     }	

     ret = VLmaplatQuadNew( dev, dem_u+1, dem_v, dev->Nb_u-1, 0, IsResInM );
     if( ret != MSSUCC ) 
     {
	printf("Error in VLmaplat0() \n");
 	printf("VLmaplatQuadNew 4 : FAIL \n");
	return MSFAIL;
     }	
 }

 return MSSUCC;
}

/* VLmaplat1: Unfold the network starting from the center and row by row */
IGRlong VLmaplat1 ( dev, dem_u ,dem_v, IsResInM, average )
struct	mise_a_plat	*dev;
IGRint			dem_u;
IGRint			dem_v;
IGRboolean		IsResInM; /*I	IsresInM = True implies that results 
					are stored in dev->M else results are 
					stored in dev->fg */
IGRboolean		average;  /*I   average = TRUE then we average point 
					computed with VLmaplatRecNew(),
					else we don't */	 
{
IGRint		i, j, dem_uCur, dem_vCur;
IGRlong		ret;
IGRdouble	*pP, *pM, *pN;

  if( IsResInM == TRUE ) 	pM = dev->M;
  else			 	pM = dev->fg;

  pP = dev->P;
  pN = dev->norm;

  /* unwrap the "right half" of the first row */

  dem_vCur = dem_v + 1;
  dem_uCur = dem_u + 1;

  for( i = dem_u+1; i < dev->Nb_u; i++ )
  {
     ret = VLmaplatTriaNew( pP, pM, pN, dev->Nb_u, i, dem_vCur, i-1, dem_vCur, 
			    i-1, dem_v);
     if( ret != MSSUCC ) 
     {
	printf("Error in VLmaplat1() \n");
 	printf("maplat__triangle 0: i = %d, FAIL \n",i);
	return MSFAIL;
     }

     ret = VLmaplatRecNew( pP, pM, pN, dev->Nb_u, i, dem_v, i-1, dem_vCur,
			   i, dem_vCur, i-1, dem_v, average);
     if( ret != MSSUCC )
     {
	printf("Error in VLmaplat1() \n");
 	printf("VLmaplatRec 0: FAIL \n");
	return MSFAIL;
     }
  }

  /* unwrap the "left half" of the first row */
  for( i = dem_u-1; i >= 0; i -= 1 )
  {
     ret = VLmaplatTriaNew( pP, pM, pN, dev->Nb_u, i, dem_vCur, i+1, dem_vCur, 
			    i+1, dem_v);
     if( ret != MSSUCC ) 
     {
	printf("Error in VLmaplat1() \n");
 	printf("maplat__triangle 1: i = %d, FAIL \n",i);
	return MSFAIL;
     }

     ret = VLmaplatRecNew( pP, pM, pN, dev->Nb_u, i, dem_v, i+1, dem_vCur,
			   i, dem_vCur, i+1, dem_v, average );
     if( ret != MSSUCC )
     {
	printf("Error in VLmaplat1() \n");
 	printf("VLmaplatRec 1: FAIL \n");
	return MSFAIL;
     }
  }

  /* unwrap the part above the first row */
  for( j = dem_v-1; j >= 0; j -= 1 )
  {
     dem_vCur = j+1;

     ret = VLmaplatTriaNew( pP, pM, pN, dev->Nb_u, dem_u, j, dem_u, dem_vCur, 
			    dem_uCur, dem_vCur);
     if( ret != MSSUCC ) 
     {
	printf("Error in VLmaplat1() \n");
 	printf("maplat__triangle 2: j = %d, FAIL \n",j);
	return MSFAIL;
     }

     for( i = dem_u+1; i < dev->Nb_u; i++ )
     {
 	ret = VLmaplatRecNew( pP, pM, pN, dev->Nb_u, i, j, i-1, dem_vCur,
			      i, dem_vCur, i-1, j, average);
 	if( ret != MSSUCC )
        {
	    printf("Error in VLmaplat1() \n");
 	    printf("VLmaplatRec 2: FAIL \n");
	    return MSFAIL;
        }
     }

     for( i = dem_u-1; i >= 0; i -= 1 )
     {
	ret = VLmaplatRecNew( pP, pM, pN, dev->Nb_u, i, j, i+1, dem_vCur,
			      i, dem_vCur, i+1, j, average );
 	if( ret != MSSUCC )
        {
	    printf("Error in VLmaplat1() \n");
 	    printf("VLmaplatRec 3: FAIL \n");
	    return MSFAIL;
        }
     }
  }

  /* unwrap the part below the first row */
  for( j = dem_v+2; j < dev->Nb_v; j++ )
  {
     dem_vCur = j - 1;

     ret = VLmaplatTriaNew( pP, pM, pN, dev->Nb_u, dem_u, j, dem_u, 
			    j-1, dem_u+1, j-1 );
     if( ret != MSSUCC ) 
     {
	printf("Error in VLmaplat1() \n");
 	printf("maplat__triangle 3: i = %d, FAIL \n",i);
	return MSFAIL;
     }

     for( i = dem_u+1; i < dev->Nb_u; i++ )
     {
 	ret = VLmaplatRecNew( pP, pM, pN, dev->Nb_u, i, j, i-1, dem_vCur,
			      i, dem_vCur, i-1, j, average);
 	if( ret != MSSUCC )
	{
	   printf("Error in VLmaplat1() \n");
 	   printf("VLmaplatRec 2: FAIL \n");
	   return MSFAIL;
	}
     }

     for( i = dem_u-1; i >= 0; i -= 1 )
     {
         ret = VLmaplatRecNew( pP, pM, pN, dev->Nb_u, i, j, i+1, dem_vCur,
			       i, dem_vCur, i+1, j, average );
         if( ret != MSSUCC )
         {
	    printf("Error in VLmaplat1() \n");
 	    printf("VLmaplatRec 3: FAIL \n");
	    return MSFAIL;
         }
     }
  }

  return MSSUCC;
}

/* VLmaplatNDevelNew : calcul de mise a plat de surface non developable
   alloue l'espace nescessaire au resultat */
IGRlong VLmaplatNDevelNew(dev, option)
struct mise_a_plat	*dev;
IGRint			option;
{
BSrc            rc;
IGRint		dem_u, Nb_u, dem_v, i, index;
IGRlong		ret;
IGRdouble	dm, *pP,*pM;
IGRvector	vect;
IGRboolean	dmHorOrVer, IsResInM, averageVert;

  dev->M = (IGRdouble *) malloc (dev->Nb_u*dev->Nb_v*3*sizeof(IGRdouble));
  if (dev->M==NULL) 
  {
    printf("VLmaplatDevel  : alloc of dev->M : FAIL \n");
    return MSFAIL;
  }

  if( dev->developpable == 1 ) return MSSUCC;

  switch( option )
  {
     default:
     case 0: 
     {
	/* unwrapping using the original way */
	/* find an approximated facet in the middle of the network of points */

	dmHorOrVer = FALSE; IsResInM = TRUE;

	ret = VLfindMidVertex( dev, dmHorOrVer, IsResInM, &dem_u, &dem_v );
	if( !(ret&1) )
        {
	   printf("case 0: Error in VLmaplatNDevelNew() \n");
	   printf("VLfindMidVertex FAILED\n");
	   goto wrapup;
	}

	ret = VLmaplat0(dev,dem_u,dem_v,IsResInM);
	if( !(ret&1) )
  	{
	   printf("case 0: Error in VLmaplatNDevelNew() \n");
	   printf("VLmaplat0 FAILED\n");
	   goto wrapup;
	}
		
	break;
     }

     case 1: 
     {
	/* unwrapping at in the u direction */
	dmHorOrVer = FALSE; IsResInM = TRUE; averageVert = TRUE;

	ret = VLfindMidVertex( dev, dmHorOrVer, IsResInM, &dem_u, &dem_v );
	if( !(ret&1) )
	{
	    printf("case 1:Error in VLmaplatNDevelNew() \n");
	    printf("VLfindMidVertex FAILED\n");
	    goto wrapup;
	}
	ret = VLmaplat1( dev, dem_u, dem_v, IsResInM, averageVert );
	if( !(ret&1) )
	{
	    printf("case 1:Error in VLmaplatNDevelNew() \n");
	    printf("VLmaplat1 FAILED\n");
	    goto wrapup;
	}
		
	break;
     }

     case 2: 
     {
	/* unwrapping as an average of VLmaplat0 and VLmaplat1 */
	/* First unwrap with VLmaplat0 */

	dmHorOrVer = FALSE; IsResInM = TRUE; averageVert = TRUE;

	ret = VLfindMidVertex( dev, dmHorOrVer, IsResInM, &dem_u, &dem_v );
	if( !(ret&1) )
	{
	   printf("case 2:Error in VLmaplatNDevelNew() \n");
	   printf("VLfindMidVertex 2 FAILED\n");
	   goto wrapup;
	}

	ret = VLmaplat0( dev, dem_u, dem_v, IsResInM );
	if( !(ret&1) )
	{
	   printf("case 2:Error in VLmaplatNDevelNew() \n");
	   printf("VLmaplat0 FAILED\n");
	   goto wrapup;
	}

	/* Now make the second unwrap with maplat1 and store the result in fg */
	dev->fg = (IGRdouble *) malloc( dev->Nb_u*dev->Nb_v*3*
					sizeof(IGRdouble) );
	if( dev->M == NULL ) 
	{
	   printf("VLmaplatDevel  : alloc of dev->fg : FAIL \n");
	   return MSFAIL;
        }

	/* Here we just set the 2 first vertices in dev->fg */
	index = VLindex( dev->Nb_u, dem_u, dem_v, 0 );
	pP = dev->fg + index;
	pM = dev->M + index;
	pP[0] = pM[0];
	pP[1] = pM[1];
	pP[2] = pM[2];
	index = VLindex(dev->Nb_u,dem_u,(dem_v+1),0);
	pP = dev->fg + index;
	pM = dev->M + index;
	pP[0] = pM[0];
	pP[1] = pM[1];
	pP[2] = pM[2];

	IsResInM = FALSE;
	ret = VLmaplat1( dev, dem_u, dem_v, IsResInM, averageVert );
	if( !(ret&1) )
	{
	    printf("case 2:Error in VLmaplatNDevelNew() \n");
	    printf("VLmaplat1 FAILED\n");
	    goto wrapup;
	}

	/* Average the 2 and put the result in dev->M */
	index = 3 * dev->Nb_u * dev->Nb_v;
	for(i=0;i<index;i++) dev->M[i] = (dev->M[i] + dev->fg[i]) * 0.5;

	break;
     }

     case 3:
     {
        BSunwrap( dev->surface, dev->Nb_u, dev->Nb_v, dev->Param_u, 
		  dev->Param_v, dev->epaisseur * dev->fib_ratio, dev->M, &rc );
	if( rc != BSSUCC ) return MSFAIL;
        break;
     }
  }

  #ifdef DEBUG2
	trace_ligne_plat(dev,dem_u,dem_v,dem_u,dem_v+1);
  #endif 

  ret = VLcreUnfoldSrfStr( dev );
  if (ret != MSSUCC) 
  {
     printf("Error in VLmaplatNDevelNew() \n");
     printf("VLcreUnfoldSrfStr() FAILED \n");
     return MSFAIL;
  }
  return MSSUCC;

wrapup:
 return MSFAIL;   
}		

end implementation VLabstract;
