/* $Id: VDSppl_util.I,v 1.10 2001/11/14 23:33:31 jayadev Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdcppl / VDSppl_util.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSppl_util.I,v $
 *	Revision 1.10  2001/11/14 23:33:31  jayadev
 *	small range box fix for Boolean
 *	
 *	Revision 1.9  2001/09/05 21:50:30  jayadev
 *	*** empty log message ***
 *	
 *	Revision 1.8  2001/03/20 21:17:10  jayadev
 *	*** empty log message ***
 *	
 *	Revision 1.7  2001/03/14 00:35:21  jayadev
 *	cutting cylinder length reduced
 *	
 *	Revision 1.6  2001/02/23 16:04:11  jayadev
 *	changes for surface extension for pla_offext macro by Jean Luc
 *	
 *	Revision 1.5  2001/01/25 22:08:18  jayadev
 *	cylinder length factor put back to 1.5
 *	
 *	Revision 1.3  2001/01/19 20:58:40  jayadev
 *	changes in spacing with CVS version
 *	
# Revision 1.6  2000/11/27  16:34:56  pinnacle
# Replaced: vds/vdcppl/VDSppl_util.I for:  by jpulapar for Service Pack
#
# Revision 1.5  2000/10/24  16:25:54  pinnacle
# Replaced: vds/vdcppl/VDSppl_util.I for:  by jwfrosch for Service Pack
#
# Revision 1.4  2000/08/03  17:50:44  pinnacle
# Replaced: vds/vdcppl/VDSppl_util.I for:  by jwfrosch for Service Pack
#
# Revision 1.3  2000/07/17  18:56:52  pinnacle
# Replaced: vds/vdcppl/VDSppl_util.I for:  by jwfrosch for Service Pack
#
# Revision 1.2  2000/06/17  17:20:26  pinnacle
# Replaced: vds/vdcppl/VDSppl_util.I for:  by rchennup for Service Pack
#
# Revision 1.1  2000/04/20  20:57:18  pinnacle
# Created: vds/vdcppl/VDSppl_util.I by jwfrosch for Service Pack
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	10/30/97	ah		Assorted uninit warnings
 *
 *	01/09/98	HF		Forcing EMS's _Pathway_ code to be used in order to
 *					improve the IntTwoSrf functionality.
 *					EMS's "Intersect 2 Elements" command seems to be faster
 *					and to generate 'cleaner' results when intersecting 2
 *					surfaces.
 *
 *					Sometimes the input order of the surfaces is important,
 *					meaning the command either fails or works properly
 *					depending on which surface is selected 1st, although
 *					the BSsfsfint() function is successful in both situations.
 *
 *					Because of this peculiarity the IntTwoSrf() function has
 *					been modified and will call EMintersect_two_element() for
 *					a 2nd time with swapped inputs in case the 1st time fails.
 *					(Based on testing in relation with TR#179702403)
 *
 *       05/11/98       ah              TR179801038 EMintersect_two_elements sometimes returns errors
 *                                      even though some sort of intersection was made.  Happens on
 *                                      knuckled surfaces.
 *	 07/07/99	HF		Modified function IntTwoSrf().
 *                                      If (*NbInt > MAX_FEET(=100)), divide cht by 10 and try again.
 *       04/20/2000     HF              Temporary fix for TR 179901421 until definite MATH fix is available
 *                                      When MATH fix is ready, just cancel call to function VD_TR179901421
 *       06/17/00       Jayadev         retry without _Pathway_ if it fails
 *       07/17/2000	HF		Retracting fix of 06/17/00. It was causing regressions resulting
 *					in TR's 179901749 & 179901791
 *       11/27/00       Jayadev         EvalFromTo() uses EvalFromTo1()
 *                                      Project 8 rangebox points using BuildEightVerFromRange()
 *                                      pinnacle backup ppl_util.SAV before these changes
 *       02/23/01       Jayadev         surface extension in u & v directions by Jean Luc 
 *					uv_extent_surface_geom()
 * -------------------------------------------------------------------*/

/*

	File name :		VDSppl_util.I
	Revision date :		92/10/02
	Product :		I/VDS 2.1 - PPMmacro library

	Description :
		This file gathers functions which are shared by PPL macros.

	History :

	91/09/04	CH	Creation date
	92/02/06	JLL	Implement IntTwoSrf() function for int_2_elem
				and crv_pro_v macros.
	92/05/06	ALC	Implement extent_surface_geom() function for
				pla_offext macro.
	92/06/19	ALC	Re-compiled for Apogee
	92/06/22	LLC	Modify fct IntTwoSrf(); we call temporary
				LLCintersect_two_element() until EMS20
	92/10/02	ALC	Call now EMintersect_two_element() in 2.1
 */


class implementation Root;

#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "griodef.h"
#include "godef.h"
#include "go.h"
#include "ex.h"
#include "grio.h"
#include "dp.h"
#include "OMmacros.h"
#include "grmacros.h"
#include "parametric.h"
#include "AS_status.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bschangepar.h"
#include "msdef.h"
#include "emssfintdef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "growner.h"
#include "bsdta_rdusf.h"
#include "bssfincktm.h"
#include "bsarclnpars.h"
#include "bsdistptpt.h"

 
#include "VDmem.h"
#define	VD_DEBUG
//#define	DEBUG 1 
#include	<VDdebug.h>

from GRvg		import GRgetsize, GRgetgeom, GRpostabsg ;
from GRgraphics		import GRdisplay, GRcptform, GRdelete, GRgetrang,
			       GRptproject ;
from GRvg		import GRgeomprops, GRgenabsg ;
from GRowner		import GRget_number_components, GRget_components,
			       GRdrop      ;
from GRcurve		import GRendpts    ;
from GRbcsubbc		import EMleast_squares_fit_curvee ;
from NDnode		import ASreturn_go ;
from NDmacro		import ACconsume   ;
from NDnodein		import ACunconsume ;
from EMSproject		import EMplace_surface_of_projection ;
from EMSsubbs		import EMtangent_normal ;

extern char 		*malloc() ;
//extern			free()    ;
extern 			BSmkvec() ;
extern void		*memcpy()   ;
extern void 		BSallocsf() ;
extern IGRboolean	BSfreesf(), BSnorvec(), BSsf_copy() ;
extern double		fabs() ;
extern void 		BSprtbspsf();

extern OMuword		OPP_GRgrgrp_class_id;
extern OMuword		OPP_GRcompcurve_class_id;
extern OMuword		OPP_GR3dlinestr_class_id;
extern OMuword		OPP_EMSsurface_class_id, OPP_EMSsolid_class_id;
extern OMuword		OPP_GRcurve_class_id;
/*
	-------------------------------------------------------------------
 */

extern IGRboolean _pathway_orient, _pathway_trim;


/* ====================================================================== */


static IGRint extent_u_poles(old_surf_geom_ptr, extent, old_row, new_surf_geom_ptr)
  struct IGRbsp_surface 	*old_surf_geom_ptr ;  	/* I */
  IGRdouble			 extent  ; 		/* I */
  IGRlong			 old_row ;		/* I : row of old matrix of poles  */
  struct IGRbsp_surface 	*new_surf_geom_ptr ;   	/* O */
/*
  Description :
  if u_order > 2
	  Compute 2*(u_order-1) new poles for an u-isocurve of the
          surface, and update the geometry ‚for this isocurve by
          filling up a complete row in the new matrix of poles.
*/

{
  IGRint	i , j, iM3 ;
  IGRint	write_indice  ; /* initial indice to store new poles   */
  IGRint	incr_indice   ; /* index to new matrix of poles        */
  IGRint 	first, second ; /* poles indices from old geometry     */
  IGRint 	before, last  ; /* poles indices from old geometry */
  IGRdouble	w_first, w_second, w_before, w_last , u;
  IGRpoint	aux1_point, aux2_point ;
  IGRvector	ext_vector ;
  IGRshort	order ;
  BSrc		bsrc  ;

  /* Init some stuff to get rid of warnings */
  w_first = w_second = w_before = w_last = 0.0;

  /*
   * Set writing indice to fill up a row of poles in the new matrix
   */
  write_indice =  3 * (new_surf_geom_ptr->u_num_poles * (
                      (new_surf_geom_ptr->v_num_poles - old_surf_geom_ptr->v_num_poles) / 2 + old_row) );
  order = old_surf_geom_ptr->u_order ;

  /*
   *  Extent on the left side : order-1 new poles will be computed
   */
  first  = 3 * old_surf_geom_ptr->u_num_poles * old_row ; /* first  pole indice */
  second = first + 3 ;				    /* second pole indice */

  if (old_surf_geom_ptr->rational)
  {
    /* Divide the second old pole by its weight */
    w_first  = old_surf_geom_ptr->weights[first/3] ;
    w_second = old_surf_geom_ptr->weights[second/3] ;
    if ( (fabs(w_first) <= 0.0) || (fabs(w_second) <= 0.0) )
    {
#ifdef DEBUG
      printf("extent_u_poles() : weight should not be negative\n") ;
#endif
      return 0 ;
    }
    for(j=0;j<3;j++)
    {
      aux1_point[j] = old_surf_geom_ptr->poles[first+j]  / w_first ;
      aux2_point[j] = old_surf_geom_ptr->poles[second+j] / w_second ;
    }
  }
  else
  {
    for(j=0;j<3;j++)
    {
      aux1_point[j] = old_surf_geom_ptr->poles[first+j] ;
      aux2_point[j] = old_surf_geom_ptr->poles[second+j] ;
    }
  }

  BSmkvec(&bsrc, ext_vector, aux2_point, aux1_point) ;
  /* Note : ext_vector should be oriented to the outside left extension */
  if (bsrc != BSSUCC) return 0 ;

  BSnorvec(&bsrc, ext_vector) ;
  if (bsrc != BSSUCC) return 0 ;

  /*
   *  Compute and store new poles, and weights if rational
   */
  if( order > 2 )
  {
	  if (old_surf_geom_ptr->rational)
	  {
		for (i = 0 ; i < order - 1 ; i++)
		{
			/* Weights */
			iM3 = write_indice + 3*i;
			u = extent - extent * (IGRdouble)i / (IGRdouble)(order-1);

			for(j=0;j<3;j++)
			{
				new_surf_geom_ptr->poles[iM3+j] = old_surf_geom_ptr->poles[first+j] / w_first + u * ext_vector[j] ;
				new_surf_geom_ptr->poles[iM3+j]*= w_first;
			}

			new_surf_geom_ptr->weights[iM3/3] = w_first ;
		} 
	  }
	  else
	  {
		for (i = 0 ; i < order - 1 ; i++)
		{
			iM3 = write_indice + 3*i;
			u = extent - extent * (IGRdouble)i / (IGRdouble)(order-1);

			for(j=0;j<3;j++)
			{
				new_surf_geom_ptr->poles[iM3+j] = old_surf_geom_ptr->poles[first+j] + u * ext_vector[j];
			}
		}
	  }

	  incr_indice = write_indice + 3 * (order -1) ;
	  /*
	   *    Re-copy the previous list of poles and weights from old matrixes
       */

	  memcpy((char *) &new_surf_geom_ptr->poles[incr_indice], 	/* target */
			 (char *) &old_surf_geom_ptr->poles[first], 		/* source */
             (int) (old_surf_geom_ptr->u_num_poles * 3 * sizeof(IGRdouble))	) ;

	  if (old_surf_geom_ptr->rational)
	  {
			/* Weights */
			memcpy((char *) &new_surf_geom_ptr->weights[incr_indice/3],
					(char *) &old_surf_geom_ptr->weights[first/3],
					(int) (old_surf_geom_ptr->u_num_poles * sizeof(IGRdouble))) ;
	  }

	  incr_indice = incr_indice + 3 * old_surf_geom_ptr->u_num_poles ;

  }/* end case where order > 2  and the left side*/
  else
  {
#ifdef DEBUG
printf("extent_u_poles() left side for order == 2, write_indice = %d\n",write_indice) ;
#endif
	  iM3 = write_indice;

	  if (old_surf_geom_ptr->rational)
	  {
		for(j=0;j<3;j++)
		{
			new_surf_geom_ptr->poles[iM3+j] = old_surf_geom_ptr->poles[first+j] / w_first + extent*ext_vector[j];
			new_surf_geom_ptr->poles[iM3+j]*= w_first;
		}
		new_surf_geom_ptr->weights[iM3/3] = w_first ;
	  }
	  else
	  {
		for(j=0;j<3;j++)
		{
				new_surf_geom_ptr->poles[iM3] = old_surf_geom_ptr->poles[first+j] + extent * ext_vector[j];
		}
	  }

	  incr_indice = write_indice + 3;

	  /*
	   *    Re-copy the previous list of poles and weights from old matrixes
	   *	into the new_surf_geom_ptr
       */

	  memcpy((char *) &new_surf_geom_ptr->poles[incr_indice], 	/* target */
			 (char *) &old_surf_geom_ptr->poles[first+3], 		/* source */
             (int) ((old_surf_geom_ptr->u_num_poles-1) * 3 * sizeof(IGRdouble))	) ;

	  if (old_surf_geom_ptr->rational)
	  {
			/* Weights */
			memcpy((char *) &new_surf_geom_ptr->weights[incr_indice/3],
					(char *) &old_surf_geom_ptr->weights[(first+3)/3],
					(int) ((old_surf_geom_ptr->u_num_poles-1) * sizeof(IGRdouble))) ;
	  }

	  incr_indice = incr_indice + 3 * (old_surf_geom_ptr->u_num_poles-2) ;
#ifdef DEBUG

	printf("extent_u_poles() right side for order > 2, incr_indice = %d\n",incr_indice) ;
#endif
	
  } /* end case order == 2 and extend left side */ 

 
  /*
   *    Extent on the right side : order-1 new poles will be computed
   */

  last   = 3 * (old_surf_geom_ptr->u_num_poles * (old_row+1) -1) ;
  before = last - 3 ;

  if (old_surf_geom_ptr->rational)
  {
    /* Divide the penultimate old pole by its weight */
    w_before = old_surf_geom_ptr->weights[before/3] ;
    w_last   = old_surf_geom_ptr->weights[last/3]   ;

    for(j=0;j<3;j++)
    {
      aux1_point[j] = old_surf_geom_ptr->poles[before+j]   / w_before ;
      aux2_point[j] = old_surf_geom_ptr->poles[last+j]     / w_last ;
    }
  }
  else
  {
    for(j=0;j<3;j++)
    {
      aux1_point[j] = old_surf_geom_ptr->poles[before+j];
      aux2_point[j] = old_surf_geom_ptr->poles[last+j];
    }
  }

  BSmkvec(&bsrc, ext_vector, aux1_point, aux2_point) ;
  /* Note : ext_vector should be oriented to the outside right extension */
  if (bsrc != BSSUCC) return 0 ;

  BSnorvec(&bsrc, ext_vector) ;
  if (bsrc != BSSUCC) return 0 ;



  if ( order > 2 )
  {
	if (old_surf_geom_ptr->rational)
	{
		for (i = 0 ; i < order - 1 ; i++)
		{
			/* Weights */

			iM3 = incr_indice + 3 * i;
			u = (IGRdouble)(i+1) * extent / (IGRdouble)(order-1) ;

			for(j=0;j<3;j++)
			{
				new_surf_geom_ptr->poles[iM3+j] = old_surf_geom_ptr->poles[last+j] / w_last + u * ext_vector[j] ;
				new_surf_geom_ptr->poles[iM3+j]*= w_last;
			}
			new_surf_geom_ptr->weights[iM3/3] = w_last ;
		} /* for */
	}
	else
	{
		for (i = 0 ; i < order - 1 ; i++)
		{
			iM3 = incr_indice + 3 * i;
			u = (IGRdouble)(i+1) * extent / (IGRdouble)(order-1) ;

			for(j=0;j<3;j++)
			{
				new_surf_geom_ptr->poles[iM3+j] = old_surf_geom_ptr->poles[last+j] + u * ext_vector[j] ;
			}
		}
	}

	incr_indice = incr_indice + 3 * (order - 1) ; /* debug purpose */
  }/* end case order > 2 and extend right side */ 
  else
  {
	iM3 = incr_indice;

	if (old_surf_geom_ptr->rational)
	{
		
		for(j=0;j<3;j++)
		{
			new_surf_geom_ptr->poles[iM3+j] = old_surf_geom_ptr->poles[last+j] / w_last + extent * ext_vector[j] ;
			new_surf_geom_ptr->poles[iM3+j]*= w_last;
		}
		new_surf_geom_ptr->weights[iM3/3] = w_last ;
	}
	else
	{
		for(j=0;j<3;j++)
		{
			new_surf_geom_ptr->poles[iM3+j] = old_surf_geom_ptr->poles[last+j] + extent * ext_vector[j] ;
		}
	}
  }/* end case order == 2 and extend right side */ 



  return 1 ;	/* success */
} /* extent_u_poles() */

/* ====================================================================== */
/* ====================================================================== */

IGRint eval_extent_ratios(pSurfGeom, uvDir, lenExt, pLeftExt, pRightExt)
  struct IGRbsp_surface *pSurfGeom; /* I : The BS surface geometry*/
  IGRboolean			uvDir;		/* I : uvDir = true -> extent evaluated in the u direction */
  IGRdouble				lenExt;     /* I : the Euclidian length */
  IGRdouble				*pLeftExt; 	/* O : this can be the true extension or the parametric */
  IGRdouble				*pRightExt;	/* O : needed only for order == 2 */

/*
  Description :
  This function simply evaluate the 2 ratios in to apply a polynomial 
  extension when we have pSurfGeom->u_order or pSurfGeom->v_order == 2
*/
{
  IGRint i,j,k,iM3, iE3;
  IGRdouble leftVec[3], leftLen, rightVec[3], rightLen, *pLeftStart, *pLeftEnd, *pRightStart, *pRightEnd ;
  IGRdouble leftStartWeight,leftEndWeight, rightStartWeight, rightEndWeight;
  IGRdouble maxLeftLen,maxRightLen, zeroTol;


  IGRdouble aveLeftLen, aveRightLen;
  BSrc	rc;

#ifdef DEBUG
printf("eval_extent_ratio\n");
#endif

  BSEXTRACTPAR(&rc, BSTOLLENVEC, zeroTol );

  if( lenExt < zeroTol )
  {
	*pLeftExt = 0.0;
	*pRightExt = 0.0;
	goto wrapup;
  }
 
  leftLen = 1.0E+16;
  rightLen = 1.0E+16;
  *pLeftExt = 1.0E+16;
  *pRightExt = 1.0E+16;
  maxLeftLen = -1.0;
  maxRightLen = -1.0;
  aveLeftLen = 0.0;
  aveRightLen = 0.0;

  if( uvDir == TRUE )
  {
	if( pSurfGeom->u_order > 2 )
	{
		*pRightExt = lenExt;
		*pLeftExt = lenExt;
		goto wrapup;
	}
 
	iM3 = 3 * pSurfGeom->u_num_poles;
	iE3 = iM3 * pSurfGeom->v_num_poles;
	j = iM3 - 6;

    if( pSurfGeom->rational )
	{
		for( i=0; i<iE3; i+=iM3 )
		{
			pLeftStart = &pSurfGeom->poles[i];
			leftStartWeight = pSurfGeom->weights[i/3];
			pLeftEnd = &pSurfGeom->poles[i+3];
			leftEndWeight = pSurfGeom->weights[(i+3)/3];

			pRightStart = &pSurfGeom->poles[j];
			rightStartWeight = pSurfGeom->weights[j/3];
			pRightEnd = &pSurfGeom->poles[j+3];
			rightEndWeight = pSurfGeom->weights[(j+3)/3];

			for( k=0;k<3;k++ )
			{
				pLeftStart[k]  = pLeftStart[k]  / leftStartWeight;
				pLeftEnd[k]    = pLeftEnd[k]    / leftEndWeight;
				pRightStart[k] = pRightStart[k] / rightStartWeight;
				pRightEnd[k]   = pRightEnd[k]   / rightEndWeight;
			}
			leftLen = BSdistptpt( &rc, pLeftStart, pLeftEnd );
			if( leftLen < (*pLeftExt) ) *pLeftExt = leftLen;
			if( leftLen > maxLeftLen ) maxLeftLen = leftLen;
			rightLen = BSdistptpt( &rc, pRightStart, pRightEnd );
			if( rightLen < (*pRightExt) ) *pRightExt = rightLen;
			if( rightLen > maxRightLen ) maxRightLen = rightLen;
			aveLeftLen += leftLen;

			aveRightLen += rightLen;
			j+=iM3;
		}
	} /* end of rational case for uvDir == TRUE */
	else
	{
		for( i=0; i<iE3; i+=iM3 )
		{
			leftLen = BSdistptpt( &rc, &pSurfGeom->poles[i], &pSurfGeom->poles[i+3] );
			if( leftLen < (*pLeftExt) ) *pLeftExt = leftLen;
			if( leftLen > maxLeftLen ) maxLeftLen = leftLen;
			rightLen = BSdistptpt( &rc, &pSurfGeom->poles[j], &pSurfGeom->poles[j+3] );
			if( rightLen < (*pRightExt) ) *pRightExt = rightLen;
			if( rightLen > maxRightLen ) maxRightLen = rightLen;	
			aveLeftLen += leftLen;
			aveRightLen += rightLen;

			 
		
#ifdef DEBUG
printf("i = %d, j = %d, leftLen = %f, right = %f\n",i,j,leftLen,rightLen);
#endif
			j+=iM3; 
		}
	}/* end of non rational for  uvDir == TRUE */

	aveLeftLen = aveLeftLen /  pSurfGeom->v_num_poles;

	aveRightLen = aveRightLen / pSurfGeom->v_num_poles;
  }/* end if uvDir == TRUE */
  else
  {
	

#ifdef DEBUG
printf(" v direction\n");
#endif

 
	if( pSurfGeom->v_order > 2 )
	{
		*pRightExt = lenExt;
		*pLeftExt = lenExt;
		goto wrapup;
	}

	iM3 = 3 * pSurfGeom->u_num_poles * (pSurfGeom->v_num_poles - 2);
	iE3 = 3 * pSurfGeom->u_num_poles;


    if( pSurfGeom->rational )
	{
		for( i=0; i<iE3; i+=3 )
		{
			pLeftStart = &pSurfGeom->poles[i];
			leftStartWeight = pSurfGeom->weights[i/3];
			pLeftEnd = &pSurfGeom->poles[i+iE3];
			leftEndWeight = pSurfGeom->weights[(i+iE3)/3];

			j = i + iM3;
			pRightStart = &pSurfGeom->poles[j];
			rightStartWeight = pSurfGeom->weights[j/3];
			pRightEnd = &pSurfGeom->poles[j+iE3];
			rightEndWeight = pSurfGeom->weights[(j+iE3)/3];

			for( k=0;k<3;k++ )
			{
				pLeftStart[k]  = pLeftStart[k]  / leftStartWeight;
				pLeftEnd[k]    = pLeftEnd[k]    / leftEndWeight;
				pRightStart[k] = pRightStart[k] / rightStartWeight;
				pRightEnd[k]   = pRightEnd[k]   / rightEndWeight;
			}
			leftLen = BSdistptpt( &rc, pLeftStart, pLeftEnd );
			if( leftLen < (*pLeftExt) ) *pLeftExt = leftLen;
			if( leftLen > maxLeftLen ) maxLeftLen = leftLen;
			rightLen = BSdistptpt( &rc, pRightStart, pRightEnd );
			if( rightLen < (*pRightExt) ) *pRightExt = rightLen;
			if( rightLen > maxRightLen ) maxRightLen = rightLen;

			aveLeftLen += leftLen;
			aveRightLen += rightLen;
		}
	} /* end of rational case for uvDir == FALSE */
	else
	{
		for( i=0; i<iE3; i+=3 )
		{
			leftLen = BSdistptpt( &rc, &pSurfGeom->poles[i], &pSurfGeom->poles[i+iE3] );
			if( leftLen < (*pLeftExt) ) *pLeftExt = leftLen;
			if( leftLen > maxLeftLen ) maxLeftLen = leftLen;
			j = i + iM3;
			rightLen = BSdistptpt( &rc, &pSurfGeom->poles[j], &pSurfGeom->poles[j+iE3] );
			if( rightLen < (*pRightExt) ) *pRightExt = rightLen;
			if( rightLen > maxRightLen ) maxRightLen = rightLen;
			aveLeftLen += leftLen;
			aveRightLen += rightLen;	
		}
	}/* end of non rational for  uvDir == FALSE */

 
	aveLeftLen  = aveLeftLen / pSurfGeom->u_num_poles;
	aveRightLen = aveRightLen / pSurfGeom->u_num_poles;

  }/* end if uvDir == FAlSE */

 // BSEXTRACTPAR(&rc, BSTOLLENVEC, zeroTol);

    
#ifdef DEBUG
printf(" pleftExt = %f, prightExt = %f, lenExt = %f\n", *pLeftExt, *pRightExt,lenExt );
printf(" maxLeftLen = %f, maxpRightLen = %f\n", lenExt,maxLeftLen, maxRightLen);
#endif

/*
  if( *pLeftExt > zeroTol )  *pLeftExt  = lenExt / (*pLeftExt);
  else						 *pLeftExt  = lenExt / maxLeftLen;
  if( *pRightExt > zeroTol ) *pRightExt = lenExt / (*pRightExt);
  else						 *pRightExt = lenExt / maxRightLen;
*/
 
  *pLeftExt = lenExt / aveLeftLen;
  *pRightExt = lenExt / aveRightLen; 

wrapup:

#ifdef DEBUG
printf(" Values returned: pleftExt = %f, prightExt = %f\n", *pLeftExt, *pRightExt);
#endif
	
return(1);
}

/* ====================================================================== */
/* ====================================================================== */
IGRint poly_extent_u_poles(old_surf_geom_ptr, extent, right_extent, old_row, new_surf_geom_ptr)
  struct IGRbsp_surface 	*old_surf_geom_ptr ;/* I */
  IGRdouble					extent  ; 			/* I : this can be the true extension or the parametric */
  IGRdouble					right_extent  ;		/* I : needed only for order == 2 */
  IGRlong					old_row ;			/* I : row of old matrix of poles  */
  struct IGRbsp_surface 	*new_surf_geom_ptr ;/* O */
/*
  Description :
  if u_order > 2
	  Compute 2*(u_order-1) new poles for an u-isocurve of the
          surface, and update the geometry for this isocurve by
          filling up a complete row in the new matrix of poles.
  else 
	  just an extrapolation is applied and not noving the poles with a constant length because 
	  this will cause a deformation of the original surface.
	  In this case extent is the parametric extension for the left side and right_extent
	  is for the right side. 
*/

{
  IGRint	i , j, iM3 ;
  IGRint	write_indice  ; /* initial indice to store new poles   */
  IGRint	incr_indice   ; /* index to new matrix of poles        */
  IGRint 	first, second ; /* poles indices from old geometry     */
  IGRint 	before, last  ; /* poles indices from old geometry */
  IGRdouble	w_first, w_second, w_before, w_last , u;
  IGRpoint	aux1_point, aux2_point ;
  IGRvector	ext_vector ;
  IGRshort	order ;
  BSrc		bsrc  ;

  /* Init some stuff to get rid of warnings */
  w_first = w_second = w_before = w_last = 0.0;

  /*
   * Set writing indice to fill up a row of poles in the new matrix
   */
  write_indice =  3 * (new_surf_geom_ptr->u_num_poles * (
                      ((new_surf_geom_ptr->v_num_poles - old_surf_geom_ptr->v_num_poles) / 2) + old_row) );
  order = old_surf_geom_ptr->u_order ;

  /*
   *  Extent on the left side : order-1 new poles will be computed
   */
  first  = 3 * old_surf_geom_ptr->u_num_poles * old_row ; /* first  pole indice */
  second = first + 3 ;									  /* second pole indice */

  if (old_surf_geom_ptr->rational)
  {
    /* Divide the second old pole by its weight */
    w_first  = old_surf_geom_ptr->weights[first/3] ;
    w_second = old_surf_geom_ptr->weights[second/3] ;
    if ( (fabs(w_first) <= 0.0) || (fabs(w_second) <= 0.0) )
    {
      return 0 ;
    }
    for(j=0;j<3;j++)
    {
      aux1_point[j] = old_surf_geom_ptr->poles[first+j]  / w_first ;
      aux2_point[j] = old_surf_geom_ptr->poles[second+j] / w_second ;
    }
  }
  else
  {
    for(j=0;j<3;j++)
    {
      aux1_point[j] = old_surf_geom_ptr->poles[first+j] ;
      aux2_point[j] = old_surf_geom_ptr->poles[second+j] ;
    }
  }

  BSmkvec(&bsrc, ext_vector, aux2_point, aux1_point) ;
  /* Note : ext_vector should be oriented to the outside left extension */
  if (bsrc != BSSUCC) return 0 ;

#ifdef DEBUG
printf("ext_vector left = %f,%f,%f\n",ext_vector[0],ext_vector[1],ext_vector[2]);
#endif
  
   /*
   *  Compute and store new poles, and weights if rational
   */
  if( order > 2 )
  {
 
	  BSnorvec(&bsrc, ext_vector) ;
	  if (bsrc != BSSUCC) return 0 ;
 
	  if (old_surf_geom_ptr->rational)
	  {
		for (i = 0 ; i < order - 1 ; i++)
		{
			/* Weights */
			iM3 = write_indice + 3*i;
 			u = (1.0-(IGRdouble)i/(IGRdouble)(order-1)) * extent;
 
			//u = extent - extent * (IGRdouble)i / (IGRdouble)(order-1);

			for(j=0;j<3;j++)
			{
				new_surf_geom_ptr->poles[iM3+j] = old_surf_geom_ptr->poles[first+j] / w_first + u * ext_vector[j] ;
				new_surf_geom_ptr->poles[iM3+j]*= w_first;
			}

			new_surf_geom_ptr->weights[iM3/3] = w_first ;
		} 
	  }
	  else
	  {
		for (i = 0 ; i < order - 1 ; i++)
		{
			iM3 = write_indice + 3*i;
			u = extent - extent * (IGRdouble)i / (IGRdouble)(order-1);

			for(j=0;j<3;j++)
			{
				new_surf_geom_ptr->poles[iM3+j] = old_surf_geom_ptr->poles[first+j] + u * ext_vector[j];
			}
		}
	  }

	  incr_indice = write_indice + 3 * (order -1) ;
	  /*
	   *    Re-copy the previous list of poles and weights from old matrixes
       */

	  memcpy((char *) &new_surf_geom_ptr->poles[incr_indice], 	/* target */
			 (char *) &old_surf_geom_ptr->poles[first], 		/* source */
             (int) (old_surf_geom_ptr->u_num_poles * 3 * sizeof(IGRdouble))	) ;

	  if (old_surf_geom_ptr->rational)
	  {
			/* Weights */
			memcpy((char *) &new_surf_geom_ptr->weights[incr_indice/3],
					(char *) &old_surf_geom_ptr->weights[first/3],
					(int) (old_surf_geom_ptr->u_num_poles * sizeof(IGRdouble))) ;
	  }

	  incr_indice = incr_indice + 3 * old_surf_geom_ptr->u_num_poles ;

  }/* end case where order > 2  and the LEFT side*/
  else
  {

#ifdef DEBUG
printf("extent_u_poles() left side for order == 2, write_indice = %d\n",write_indice) ;
#endif

	  iM3 = write_indice;
	   
	  if (old_surf_geom_ptr->rational)
	  {
		for(j=0;j<3;j++)
		{
			new_surf_geom_ptr->poles[iM3+j] = old_surf_geom_ptr->poles[first+j] / w_first + extent*ext_vector[j];
			new_surf_geom_ptr->poles[iM3+j]*= w_first;
		}
		new_surf_geom_ptr->weights[iM3/3] = w_first ;
	  }
	  else
	  {
		for(j=0;j<3;j++)
		{
			new_surf_geom_ptr->poles[iM3+j] = old_surf_geom_ptr->poles[first+j] + extent * ext_vector[j];
		}
	  }

#ifdef DEBUG
printf("poly_extent_u_poles,order=2,left side, iM3 = %d, first = %d\n", iM3, first);
printf("old_surf_geom_ptr->poles[%d] = %f,%f,%f\n",(first/3), old_surf_geom_ptr->poles[first],
	   old_surf_geom_ptr->poles[first+1],old_surf_geom_ptr->poles[first+2]);
printf("new_surf_geom_ptr->poles[%d] = %f,%f,%f\n",(iM3/3), new_surf_geom_ptr->poles[iM3],
	   new_surf_geom_ptr->poles[iM3+1],new_surf_geom_ptr->poles[iM3+2]);
#endif
	  

	  /*
	   *    Re-copy the previous list of poles and weights from old matrixes
	   *	into the new_surf_geom_ptr
       */

	  
	
	  if( old_surf_geom_ptr->u_num_poles > 2 )
	  {
			
		 iM3 = write_indice + 3;

	 	 memcpy((char *) &new_surf_geom_ptr->poles[iM3], 	/* target */
			(char *) &old_surf_geom_ptr->poles[first+3], 		/* source */
                        (int) ((old_surf_geom_ptr->u_num_poles-2) * 3 * sizeof(IGRdouble))	) ;

	  	if (old_surf_geom_ptr->rational)
	  	{
			/* Weights */
			memcpy((char *) &new_surf_geom_ptr->weights[iM3/3],
					(char *) &old_surf_geom_ptr->weights[(first+3)/3],
					(int) ((old_surf_geom_ptr->u_num_poles-2) * sizeof(IGRdouble))) ;
	  	}

		iM3 += 3 * (old_surf_geom_ptr->u_num_poles-2);
	  }
	  else iM3 += 3;

	  

#ifdef DEBUG
	printf("extent_u_poles() right side for order = 2, incr_indice = %d\n",incr_indice) ;
#endif
	
  } /* end case order == 2 and extend LEFT side */ 

 
  /*
   *    Extent on the right side : order-1 new poles will be computed
   */

  last   = 3 * (old_surf_geom_ptr->u_num_poles * (old_row+1) -1 ) ;
  before = last - 3 ;

#ifdef DEBUG
	printf(" last = %d, before = %d\n",last,before);
#endif

  if (old_surf_geom_ptr->rational)
  {
    /* Divide the penultimate old pole by its weight */
    w_before = old_surf_geom_ptr->weights[before/3] ;
    w_last   = old_surf_geom_ptr->weights[last/3]   ;

    for(j=0;j<3;j++)
    {
      aux1_point[j] = old_surf_geom_ptr->poles[before+j]  / w_before ;
      aux2_point[j] = old_surf_geom_ptr->poles[last+j]    / w_last ;
    }
  }
  else
  {
    for(j=0;j<3;j++)
    {
      aux1_point[j] = old_surf_geom_ptr->poles[before+j];
      aux2_point[j] = old_surf_geom_ptr->poles[last+j];
    }
  }

  BSmkvec(&bsrc, ext_vector, aux1_point, aux2_point) ;
  /* Note : ext_vector should be oriented to the outside right extension */
  if (bsrc != BSSUCC) return 0 ;

#ifdef DEBUG
printf("ext_vector right = %f,%f,%f\n",ext_vector[0],ext_vector[1],ext_vector[2]);
#endif

  if ( order > 2 )
  {
	BSnorvec(&bsrc, ext_vector) ;
	if (bsrc != BSSUCC) return 0 ;
 
	if (old_surf_geom_ptr->rational)
	{
		for (i = 0 ; i < order - 1 ; i++)
		{
			/* Weights */

			iM3 = incr_indice + 3 * i;
			u = (IGRdouble)(i+1) * right_extent / (IGRdouble)(order-1) ;

			for(j=0;j<3;j++)
			{
				new_surf_geom_ptr->poles[iM3+j] = old_surf_geom_ptr->poles[last+j] / w_last + u * ext_vector[j] ;
				new_surf_geom_ptr->poles[iM3+j]*= w_last;
			}
			new_surf_geom_ptr->weights[iM3/3] = w_last ;
		} /* for */
	}
	else
	{
		for (i = 0 ; i < order - 1 ; i++)
		{
			iM3 = incr_indice + 3 * i;
			u = (IGRdouble)(i+1) * right_extent / (IGRdouble)(order-1) ;

			for(j=0;j<3;j++)
			{
				new_surf_geom_ptr->poles[iM3+j] = old_surf_geom_ptr->poles[last+j] + u * ext_vector[j] ;
			}
		}
	}

	incr_indice = incr_indice + 3 * (order - 1) ; /* debug purpose */
  }/* end case order > 2 and extend right side */ 
  else
  {

	if (old_surf_geom_ptr->rational)
	{
		
		for(j=0;j<3;j++)
		{
			new_surf_geom_ptr->poles[iM3+j] = old_surf_geom_ptr->poles[last+j] / w_last + 
							  right_extent * ext_vector[j] ;
			new_surf_geom_ptr->poles[iM3+j]*= w_last;
		}
		new_surf_geom_ptr->weights[iM3/3] = w_last ;
	}
	else
	{
		for(j=0;j<3;j++)
		{
			new_surf_geom_ptr->poles[iM3+j] = old_surf_geom_ptr->poles[last+j] + 
							  right_extent * ext_vector[j] ;
		}

#ifdef DEBUG
printf("poly_extent_u_poles,order=2,right side, iM3 = %d, last = %d\n", iM3, last);
printf("old_surf_geom_ptr->poles[%d] = %f,%f,%f\n",(last/3), old_surf_geom_ptr->poles[last],
	   old_surf_geom_ptr->poles[last+1],old_surf_geom_ptr->poles[last+2]);
printf("new_surf_geom_ptr->poles[%d] = %f,%f,%f\n",(iM3/3), new_surf_geom_ptr->poles[iM3],
	   new_surf_geom_ptr->poles[iM3+1],new_surf_geom_ptr->poles[iM3+2]);
#endif

	}
  }/* end case order == 2 and extend right side */ 


  return 1 ;	/* success */
} /* poly_extent_u_poles() */

/* ====================================================================== */
/* ====================================================================== */
IGRint poly_extent_v_poles(old_surf_geom_ptr, extent, right_extent, column, new_surf_geom_ptr)
  struct IGRbsp_surface 	*old_surf_geom_ptr ;	/* I */
  IGRdouble			extent  ;	 	/* I : extension value            */
  IGRdouble			right_extent  ;	 	/* I : extension value            */
  IGRlong			column  ; 		/* I */
  struct IGRbsp_surface 	*new_surf_geom_ptr ;	/* I / O */
/*
  Description :
	  Compute 2*(v_order-1) new poles for a v-isocurve of the
          surface, and add them to the new matrix of poles.
  Note :
	  This function works directly on the new matrix of poles,
          and should be called after the extension of the surface
          in the u direction has been done (see extent_u_poles()).
 */
{
  IGRshort	order ;
  IGRint	read_indice   ; /* where to read poles */
  IGRint	i, incr_indice, iM3, j   ;
  IGRint	first, second ; /* indices to extent in v direction */
  IGRint	before, last  ; /* indices to extent in v direction */
  IGRdouble	w_first, w_second, w_before, w_last, u ;
  IGRpoint	aux1_point, aux2_point ;
  IGRvector	ext_vector;
  BSrc		bsrc ;

  /* Init some stuff to get rid of warnings */
  w_first = w_second = w_before = w_last = 0.0;

  /*
   *    Set indice to read poles in the new matrix
   */

  read_indice = 3 * ( new_surf_geom_ptr->u_num_poles * (
                    ( new_surf_geom_ptr->v_num_poles - old_surf_geom_ptr->v_num_poles) / 2) );
  order = new_surf_geom_ptr->v_order ;

  /*
   *    Exten the left side : order-1 new poles will be computed
   */

  first  =  read_indice + 3 * column; 	 /* first pole indice of iso v  */
  second = first + 3 * new_surf_geom_ptr->u_num_poles ; /* second pole indice */

  if (old_surf_geom_ptr->rational)
  {
    /* Divide the second old pole by its weight */
    w_first  = new_surf_geom_ptr->weights[first/3] ;
    w_second = new_surf_geom_ptr->weights[second/3] ;

    if ( (fabs(w_first) <= 0.0) || (fabs(w_second) <= 0.0) )
    {
      return 0 ;
    }

    for(j=0;j<3;j++)
    {
      aux1_point[j] = new_surf_geom_ptr->poles[first+j]   / w_first ;
      aux2_point[j] = new_surf_geom_ptr->poles[second+j]  / w_second ;
    }
  }
  else
  {
    for(j=0;j<3;j++)
    {
      aux1_point[j] = new_surf_geom_ptr->poles[first+j] ;
      aux2_point[j] = new_surf_geom_ptr->poles[second+j] ;
    }
  }

  BSmkvec(&bsrc, ext_vector, aux2_point, aux1_point) ;
  /* Note : ext_vector should be oriented to the outside left extension */
  if (bsrc != BSSUCC) return 0 ;



  if( order > 2 )
  {
 
	BSnorvec(&bsrc, ext_vector) ;
	if (bsrc != BSSUCC) return 0 ;
 
	if (old_surf_geom_ptr->rational)
	{
		for (i = 0 ; i < order - 1 ; i++)
		{
			iM3 = 3 * (column + i * new_surf_geom_ptr->u_num_poles);
			u = extent -  extent * (IGRdouble)i  / (IGRdouble)(order-1) ;

			/* Weights */

			for(j=0;j<3;j++)
			{
				new_surf_geom_ptr->poles[iM3+j] = new_surf_geom_ptr->poles[first+j]  / w_first + u * ext_vector[j] ;
				new_surf_geom_ptr->poles[iM3+j]*= w_first;
			}
			new_surf_geom_ptr->weights[iM3/3] = w_first ;
		} /* for */
	}
	else
	{
		for (i = 0 ; i < order - 1 ; i++)
		{
			iM3 = 3 * (column + i * new_surf_geom_ptr->u_num_poles);
			u = ( extent -  extent * (IGRdouble)i  / (order-1) );

			for(j=0;j<3;j++)
			{
				new_surf_geom_ptr->poles[iM3+j] = new_surf_geom_ptr->poles[first+j] + u * ext_vector[j] ;
			}
		}
	}
  }/* end of the left side order > 2 */
  else
  {
	iM3 = 3 * column;

	if (old_surf_geom_ptr->rational)
	{
		for(j=0;j<3;j++)
		{
			new_surf_geom_ptr->poles[iM3+j] = new_surf_geom_ptr->poles[first+j]  / w_first + extent * ext_vector[j] ;
			new_surf_geom_ptr->poles[iM3+j]*= w_first;
		}
			new_surf_geom_ptr->weights[iM3/3] = w_first ;
	}
	else
	{
		for(j=0;j<3;j++)
		{
			new_surf_geom_ptr->poles[iM3+j] = new_surf_geom_ptr->poles[first+j] + extent * ext_vector[j] ;
		}
	}
  }/* end of the left side order == 2 */

  /*
   *    Extent on the right side : order-1 new poles will be computed
   */

  last   = read_indice + 3 * ((old_surf_geom_ptr->v_num_poles - 1) * new_surf_geom_ptr->u_num_poles + column ) ;
  before = last - 3 * new_surf_geom_ptr->u_num_poles ;

  if (old_surf_geom_ptr->rational)
  {
    /* Divide the penultimate old pole by its weight */
    w_before = new_surf_geom_ptr->weights[before/3] ;
    w_last   = new_surf_geom_ptr->weights[last/3]   ;

    for(j=0;j<3;j++)
    {
      aux1_point[j] = new_surf_geom_ptr->poles[before+j]  / w_before ;
      aux2_point[j] = new_surf_geom_ptr->poles[last+j]    / w_last ;
    }
  }
  else
  {
    for(j=0;j<3;j++)
    {
      aux1_point[j] = new_surf_geom_ptr->poles[before+j] ;
      aux2_point[j] = new_surf_geom_ptr->poles[last+j] ;
    }
  }

  BSmkvec(&bsrc, ext_vector, aux1_point, aux2_point) ;
  if (bsrc != BSSUCC) return 0 ;



  incr_indice = last + 3 * new_surf_geom_ptr->u_num_poles ;


  if( order > 2 )
  {
	  BSnorvec(&bsrc, ext_vector) ;
	  if (bsrc != BSSUCC) return 0 ;
 
	  if(old_surf_geom_ptr->rational)
	  {
		for (i = 0 ; i < order - 1 ; i++)
		{
		/* Weights */

			iM3 = incr_indice + 3*i*new_surf_geom_ptr->u_num_poles;
			u = (IGRdouble)(i+1) * right_extent / (IGRdouble) (order-1);

			for(j=0;j<3;j++)
			{
				new_surf_geom_ptr->poles[iM3+j] = new_surf_geom_ptr->poles[last+j] / w_last  + u * ext_vector[j] ;
				new_surf_geom_ptr->poles[iM3+j]*= w_last;
			}

			new_surf_geom_ptr->weights[iM3 / 3] = w_last ;

		} /* for */
	  }
	  else
	  {
		for (i = 0 ; i < order - 1 ; i++)
		{
			iM3 = incr_indice + 3*i*new_surf_geom_ptr->u_num_poles;
			u = (IGRdouble)(i+1) * right_extent / (IGRdouble) (order-1);

			for(j=0;j<3;j++)
			{
				new_surf_geom_ptr->poles[iM3+j] = new_surf_geom_ptr->poles[last+j] + u * ext_vector[j] ;
			}
		}
	  }
  }
  else
  {
	  u = right_extent;
	  if( old_surf_geom_ptr->v_num_poles == 2 ) u = right_extent / (1.0 + extent );

	  if(old_surf_geom_ptr->rational)
	  {

			for(j=0;j<3;j++)
			{
				new_surf_geom_ptr->poles[last+j] = new_surf_geom_ptr->poles[last+j] / w_last + u * ext_vector[j] ;
				new_surf_geom_ptr->poles[last+j]*= w_last;
			}

			new_surf_geom_ptr->weights[last/3] = w_last ;
	  }
	  else
	  {
		for(j=0;j<3;j++)
		{
			new_surf_geom_ptr->poles[last+j] = new_surf_geom_ptr->poles[last+j] + u * ext_vector[j] ;
		}
	  }
  }

  return 1 ;	/* success */
} /* poly_extent_v_poles() */
/* ====================================================================== */
/* ====================================================================== */
static IGRint extent_v_poles(old_surf_geom_ptr, extent, column, new_surf_geom_ptr)
  struct IGRbsp_surface 	*old_surf_geom_ptr ;	/* I */
  IGRdouble			extent  ;	 	/* I : extension value            */
  IGRlong			column  ; 		/* I */
  struct IGRbsp_surface 	*new_surf_geom_ptr ;	/* I / O */
/*
  Description :
	  Compute 2*(v_order-1) new poles for a v-isocurve of the
          surface, and add them to the new matrix of poles.
  Note :
	  This function works directly on the new matrix of poles,
          and should be called after the extension of the surface
          in the u direction has been done (see extent_u_poles()).
 */
{
  IGRshort	order ;
  IGRint	read_indice   ; /* where to read poles */
  IGRint	i, incr_indice, iM3, j   ;
  IGRint	first, second ; /* indices to extent in v direction */
  IGRint	before, last  ; /* indices to extent in v direction */
  IGRdouble	w_first, w_second, w_before, w_last, u ;
  IGRpoint	aux1_point, aux2_point ;
  IGRvector	ext_vector    ;
  BSrc		bsrc ;

  /* Init some stuff to get rid of warnings */
  w_first = w_second = w_before = w_last = 0.0;

  /*
   *    Set indice to read poles in the new matrix
   */

  read_indice = 3 * ( new_surf_geom_ptr->u_num_poles * (
                    ( new_surf_geom_ptr->v_num_poles - old_surf_geom_ptr->v_num_poles) / 2) );
  order = new_surf_geom_ptr->v_order ;

  /*
   *    Exten the left side : order-1 new poles will be computed
   */

  first  =  read_indice + 3 * column; 	 /* first pole indice of iso v  */
  second = first + 3 * new_surf_geom_ptr->u_num_poles ; /* second pole indice */

  if (old_surf_geom_ptr->rational)
  {
    /* Divide the second old pole by its weight */
    w_first  = new_surf_geom_ptr->weights[first/3] ;
    w_second = new_surf_geom_ptr->weights[second/3] ;

    if ( (fabs(w_first) <= 0.0) || (fabs(w_second) <= 0.0) )
    {
#ifdef DEBUG
      printf("extent_u_poles() : weight should not be null\n") ;
#endif
      return 0 ;
    }

    for(j=0;j<3;j++)
    {
      aux1_point[j] = new_surf_geom_ptr->poles[first+j]   / w_first ;
      aux2_point[j] = new_surf_geom_ptr->poles[second+j]  / w_second ;
    }
  }
  else
  {
    for(j=0;j<3;j++)
    {
      aux1_point[j] = new_surf_geom_ptr->poles[first+j] ;
      aux2_point[j] = new_surf_geom_ptr->poles[second+j] ;
    }
  }

  BSmkvec(&bsrc, ext_vector, aux2_point, aux1_point) ;
  /* Note : ext_vector should be oriented to the outside left extension */
  if (bsrc != BSSUCC) return 0 ;

  BSnorvec(&bsrc, ext_vector) ;
  if (bsrc != BSSUCC) return 0 ;

  if( order > 2 )
  {
	if (old_surf_geom_ptr->rational)
	{
		for (i = 0 ; i < order - 1 ; i++)
		{
			iM3 = 3 * (column + i * new_surf_geom_ptr->u_num_poles);
			u = extent -  extent * (IGRdouble)i  / (IGRdouble)(order-1) ;

			/* Weights */

			for(j=0;j<3;j++)
			{
				new_surf_geom_ptr->poles[iM3+j] = new_surf_geom_ptr->poles[first+j]  / w_first + u * ext_vector[j] ;
				new_surf_geom_ptr->poles[iM3+j]*= w_first;
			}
			new_surf_geom_ptr->weights[iM3/3] = w_first ;
		} /* for */
	}
	else
	{
		for (i = 0 ; i < order - 1 ; i++)
		{
			iM3 = 3 * (column + i * new_surf_geom_ptr->u_num_poles);
			u = ( extent -  extent * (IGRdouble)i  / (order-1) );

			for(j=0;j<3;j++)
			{
				new_surf_geom_ptr->poles[iM3+j] = new_surf_geom_ptr->poles[first+j] + u * ext_vector[j] ;
			}
		}
	}
  }/* end of the left side order > 2 */
  else
  {
	iM3 = 3 * column;

	if (old_surf_geom_ptr->rational)
	{
		for(j=0;j<3;j++)
		{
			new_surf_geom_ptr->poles[iM3+j] = new_surf_geom_ptr->poles[first+j]  / w_first + extent * ext_vector[j] ;
			new_surf_geom_ptr->poles[iM3+j]*= w_first;
		}
			new_surf_geom_ptr->weights[iM3/3] = w_first ;
	}
	else
	{
		for(j=0;j<3;j++)
		{
			new_surf_geom_ptr->poles[iM3+j] = new_surf_geom_ptr->poles[first+j] + extent * ext_vector[j] ;
		}
	}
  }/* end of the left side order == 2 */

  /*
   *    Extent on the right side : order-1 new poles will be computed
   */

  last   = read_indice + 3 * ((old_surf_geom_ptr->v_num_poles - 1) * new_surf_geom_ptr->u_num_poles + column ) ;
  before = last - 3 * new_surf_geom_ptr->u_num_poles ;

  if (old_surf_geom_ptr->rational)
  {
    /* Divide the penultimate old pole by its weight */
    w_before = new_surf_geom_ptr->weights[before/3] ;
    w_last   = new_surf_geom_ptr->weights[last/3]   ;

    for(j=0;j<3;j++)
    {
      aux1_point[j] = new_surf_geom_ptr->poles[before+j]  / w_before ;
      aux2_point[j] = new_surf_geom_ptr->poles[last+j]    / w_last ;
    }
  }
  else
  {
    for(j=0;j<3;j++)
    {
      aux1_point[j] = new_surf_geom_ptr->poles[before+j] ;
      aux2_point[j] = new_surf_geom_ptr->poles[last+j] ;
    }
  }

  BSmkvec(&bsrc, ext_vector, aux1_point, aux2_point) ;
  if (bsrc != BSSUCC) return 0 ;

  BSnorvec(&bsrc, ext_vector) ;
  if (bsrc != BSSUCC) return 0 ;

  incr_indice = last + 3 * new_surf_geom_ptr->u_num_poles ;


  if( order > 2 )
  {
	  if(old_surf_geom_ptr->rational)
	  {
		for (i = 0 ; i < order - 1 ; i++)
		{
		/* Weights */

			iM3 = incr_indice + 3*i*new_surf_geom_ptr->u_num_poles;
			u = (IGRdouble)(i+1) * extent / (IGRdouble) (order-1);

			for(j=0;j<3;j++)
			{
				new_surf_geom_ptr->poles[iM3+j] = new_surf_geom_ptr->poles[last+j] / w_last  + u * ext_vector[j] ;
				new_surf_geom_ptr->poles[iM3+j]*= w_last;
			}

			new_surf_geom_ptr->weights[iM3 / 3] = w_last ;

		} /* for */
	  }
	  else
	  {
		for (i = 0 ; i < order - 1 ; i++)
		{
			iM3 = incr_indice + 3*i*new_surf_geom_ptr->u_num_poles;
			u = (IGRdouble)(i+1) * extent / (IGRdouble) (order-1);

			for(j=0;j<3;j++)
			{
				new_surf_geom_ptr->poles[iM3+j] = new_surf_geom_ptr->poles[last+j] + u * ext_vector[j] ;
			}
		}
	  }
  }
  else
  {
	  if(old_surf_geom_ptr->rational)
	  {

			for(j=0;j<3;j++)
			{
				new_surf_geom_ptr->poles[last+j] = new_surf_geom_ptr->poles[last+j] / w_last + extent * ext_vector[j] ;
				new_surf_geom_ptr->poles[last+j]*= w_last;
			}

			new_surf_geom_ptr->weights[last/3] = w_last ;
	  }
	  else
	  {
		for(j=0;j<3;j++)
		{
			new_surf_geom_ptr->poles[last+j] = new_surf_geom_ptr->poles[last+j] + extent * ext_vector[j] ;
		}
	  }
  }


  return 1 ;	/* success */
} /* extent_v_poles() */

/* ====================================================================== */

static IGRint extent_knots(order, old_knots, old_num_knots, new_num_knots, new_knots)
  IGRshort	order ;			/* I */
  IGRdouble	*old_knots    ;	     	/* I */
  IGRlong	old_num_knots ;	     	/* I */
  IGRlong	new_num_knots ;	     	/* I */
  IGRdouble	*new_knots    ;	     	/* O */
/*
  Description :
	  Reparametrize the knots vector (example with order = 4) :
          [0, 0, 0, 0, 0.33, 0.33, 0.33, ... , 0.66, 0.66, 0.66, 1, 1, 1, 1]
          |-- u_new = 1/3 + u_old / 3
 */
{
  IGRint 		i ;
  
  if(  new_num_knots > old_num_knots  )
  {
	for (i = 0 ; i < order ; i = i+1)
	{
		new_knots[i] = 0.0 ;
	}

	for (i = 0 ; i < old_num_knots - 2 ; i = i+1)
	{
		new_knots[order + i] = ((IGRdouble) 1)/3 + old_knots[i+1]/3 ;
    /* start indice from 1 to old_num_knots - 2 for old knots ! */
	}

	for (i = 0 ; i < order ; i = i+1)
	{
		new_knots[order + (old_num_knots - 2) + i] = 1.0 ;
	}
  }
  else
  {
		memcpy((char *) &new_knots[0], (char *) &old_knots[0], (int) (old_num_knots * sizeof(IGRdouble))) ;
  }
return 1 ;
} /* extent_knots() */


/* ***************** VDconsume_and_display () *********************** */
/*  Copied from Ludo code
/*
/* */
VDconsume_and_display( as_sup, c_mod, d_mod, md_env )
  struct  GRid            as_sup;  /* Assoc object 			(I) */
  IGRshort                c_mod;   /* 1 => consume, else => unconsume 	(I) */
  IGRshort                d_mod;   /* 1 => display, else => undisplay	(I) */
  struct  GRmd_env        *md_env; /* mod env of as_sup			(I) */
/*.VDconsume_and_display*/
{
  IGRlong                 sts, msg;
  struct  GRid            go_sup;
  struct  GRmd_env        sup_env;
  enum    GRdpmode        pen;

  sts = om$send(  msg      = message NDnode.ASreturn_go( &go_sup,
                                                         &sup_env.md_env.matrix_type,
                                                          sup_env.md_env.matrix ),
                  senderid = NULL_OBJID,
                  targetid = as_sup.objid,
                  targetos = as_sup.osnum );
  as$status( sts = sts );

  if( c_mod )
  {
    if( d_mod )     pen = GRbd;
    else            pen = GRbehe;

    sts = om$send(  msg      = message GRgraphics.GRdisplay( &msg,
                                                             &sup_env.md_env.matrix_type,
                                                              sup_env.md_env.matrix,
                                                             &pen,
                                                             &md_env->md_id ),
                    senderid = NULL_OBJID,
                    targetid = go_sup.objid,
                    targetos = go_sup.osnum );
    as$status( sts = sts );

    sts = om$send( msg       = message NDmacro.ACconsume( &msg,
                                                          "",
                                                          0,
                                                          0,
                                                          md_env ),
                   senderid = NULL_OBJID,
                   targetid = as_sup.objid,
                   targetos = as_sup.osnum );
    as$status( sts = sts );
  }
  else
  {
    sts = om$send(  msg      = message NDnodein.ACunconsume ( &msg, "" ),
                    senderid = NULL_OBJID,
                    targetid = as_sup.objid,
                    targetos = as_sup.osnum );
    as$status( sts = sts );

    if( d_mod )     pen = GRbd;
    else            pen     = GRbehe;

    sts = om$send(  msg      = message GRgraphics.GRdisplay( &msg,
                                                             &sup_env.md_env.matrix_type,
                                                              sup_env.md_env.matrix,
                                                             &pen,
                                                             &md_env->md_id ),
                    senderid = NULL_OBJID,
                    targetid = go_sup.objid,
                    targetos = go_sup.osnum );
    as$status( sts = sts );
  }

  return  sts;
} /* VDconsume_and_display() */

/*
 *	===================================================================
 *		Functions needed by crv_pro_v.u and int_2_ele.u
 *		Written by Jean-Luc LOSCHUTZ
 *								(92/01/25)
 *	===================================================================
 */


/*
	-------------------------------------------------------------------
	BuildSrf() :
	----------
	Function used by the PPL macro crv_pro_v.u
									JLL
	-------------------------------------------------------------------
 */

BuildSrf( crv_info, FromTo, cst, PjSrfId, msg )

  struct GRlc_info		*crv_info;
  IGRdouble			*FromTo;
  struct  GRvg_construct	*cst;
  struct	GRid		*PjSrfId;
  IGRlong			*msg;

{

  IGRlong		stat		;
  IGRdouble		trans_mat[16]	;
  IGRboolean		pos_orient_flag	;
  GRobjid		travobj		;
  struct GRid		CopiedObj	;
  extern int		MAidmx()	;
  extern int		GRdisplay_object() ;

#ifdef DEBUG
  printf("Call to BuildSrf() function \n") ;
  __DBGpr_grid("crv_info =",&crv_info->located_obj);
#endif

  CopiedObj.objid = NULL_OBJID;

  MAidmx(msg,trans_mat);
  trans_mat[3]  = FromTo[0] - FromTo[3];
  trans_mat[7]  = FromTo[1] - FromTo[4];
  trans_mat[11] = FromTo[2] - FromTo[5];

  stat = om$send(msg	= message GRgraphics.GRcptform( msg,
                                                        &crv_info->module_info,
                                                        trans_mat,
                                                        cst->env_info,
                                                        &CopiedObj.objid ),
                 senderid = NULL_OBJID,
                 targetid = crv_info->located_obj.objid,
                 targetos = crv_info->located_obj.osnum ) ;
  as$status(sts = stat) ; if( !( *msg & stat & 1 ) ) return(MSFAIL) ;
  CopiedObj.osnum = cst->env_info->md_id.osnum;

#ifdef DEBUG
  gr$display_object( object_id = (struct GRid *) &CopiedObj,
                     mode      = GRhd	);
#endif

  PjSrfId->objid  = NULL_OBJID      ;
  PjSrfId->osnum  = CopiedObj.osnum ;
  pos_orient_flag = TRUE ;

  stat =
    om$construct( classname = "EMSproject",
                  osnum     = PjSrfId->osnum,
                  p_objid   = &PjSrfId->objid,
                  msg       = message EMSproject.EMplace_surface_of_projection( cst,
                                                                                &CopiedObj,
                                                                                cst->env_info,
                                                                                NULL,
                                                                                NULL,
                                                                                &FromTo[0],
                                                                                &FromTo[6],
                                                                                pos_orient_flag,
                                                                                &travobj) ) ;
  as$status(sts = stat) ;
  if ( !(stat & 1) ) return (MSFAIL) ;
  PjSrfId->objid = travobj;

#ifdef DEBUG
  __DBGpr_grid("PjSrfId =",PjSrfId);
  gr$display_object( object_id = (struct GRid *) PjSrfId,
                     mode      = GRbd	);
#endif

  stat = om$send( msg      = message GRgraphics.GRdelete(msg,cst->env_info),
                  senderid = NULL_OBJID,
                  targetid = CopiedObj.objid,
                  targetos = CopiedObj.osnum) ;
  as$status(sts = stat) ;

  *msg = MSSUCC;
  return(MSSUCC);

} /* BuildSrf() */

/*
	-------------------------------------------------------------------
	BuildCompCrv() :
	--------------
	Function used by the PPL macros crv_pro_v.u, and int_2_ele.u (from
	version including associative expressions).
	This function is called by the function IntTwoSrf(), if
	AppOption (approximation) has been set to TRUE in the list of its
	arguments.
									JLL
	-------------------------------------------------------------------
 */

BuildCompCrv( flag, CompIn, CompOut, str_cl, cst, surfs, suc )

  IGRboolean			flag;
  struct	GRid		*CompIn;
  struct	GRid		*CompOut;
  OMuword			str_cl;
  struct  GRvg_construct	*cst;
  struct GRlc_info        	surfs[];
  IGRlong			*suc;

{
  IGRlong		stat;
  IGRint		i;
  IGRint		num_components;
  struct	GRid	*compid, appcouid;
  OMuword		cou_cl;
  OM_S_CHANSELECT   	Channel1;
  OM_S_CHANSELECT   	Channel2;

#ifdef DEBUG
  printf("Call to BuildCompCrv() \n") ;
#endif

  Channel1.type       = OM_e_name;
  Channel1.u_sel.name = "to_components";

  Channel2.type       = OM_e_name;
  Channel2.u_sel.name = "to_owners";

  compid = NULL;

  if( flag == TRUE )
  {
#ifdef DEBUG
    __DBGpr_com("    it's compcurve");
#endif
    stat = om$send( msg = message GRowner.GRget_number_components( suc,
                                                                   &num_components ),
                    senderid = NULL_OBJID,
                    targetid = CompIn->objid,
                    targetos = CompIn->osnum );
    as$status(sts = stat) ;

    if( !(*suc&stat&1) )
    {
      printf(" error in GRget_number_components\n");
      goto wrapup;
    }

    compid = (struct GRid *) om$malloc( size = num_components * sizeof(struct GRid));
    if( compid == NULL )
    {
      printf(" error in om$malloc\n");
      goto wrapup;
    }

#ifdef DEBUG
    __DBGpr_com("enter GRowner.GRget_components");
#endif

    stat = om$send( msg = message GRowner.GRget_components( suc,
                                                            cst->env_info,
                                                            compid,
                                                            num_components,
                                                            &i,
                                                            (IGRint) 0,
                                                            OM_K_MAXINT ),
                    senderid = NULL_OBJID,
                    targetid = CompIn->objid,
                    targetos = CompIn->osnum );
    as$status(sts = stat) ;
    if( !(*suc&stat&1) )
    {
      printf(" error in GRget_components\n");
      goto wrapup;
    }

    for(i=0 ; i<num_components ; i=i+1)
    {
      om$get_classid( objid     = compid[i].objid,
                      osnum     = compid[i].osnum,
                      p_classid = &cou_cl) ;


      if( om$is_ancestry_valid( superclassid = str_cl,
                                subclassid   = cou_cl ) == OM_S_SUCCESS )
      {
#ifdef DEBUG
        __DBGpr_com("linestr in composite");
#endif

        stat = AppLinestr( &(compid[i]), &appcouid, cst, surfs, suc );
        if( *suc == MSSUCC )
        {
          stat = om$send( msg = message Root.disconnect( Channel1,
                                                         compid[i].objid,
                                                         compid[i].osnum,
                                                         Channel2),
                          senderid = NULL_OBJID,
                          targetid = CompIn->objid,
                          targetos = CompIn->osnum ) ;
          as$status(sts = stat) ;

          stat = om$send( msg = message Root.connect( Channel1, i,
                                                      appcouid.objid,
                                                      appcouid.osnum,
                                                      Channel2, OM_K_MAXINT),
                          senderid = NULL_OBJID,
                          targetid = CompIn->objid,
                          targetos = CompIn->osnum ) ;
          as$status(sts = stat) ;

          stat = om$send( msg      = message GRgraphics.GRdelete( suc,cst->env_info),
                          senderid = NULL_OBJID,
                          targetid = compid[i].objid,
                          targetos = compid[i].osnum ) ;
          as$status(sts = stat) ;
        }
      }
    }

    if( compid != NULL ) om$dealloc(ptr = compid);
    CompOut->objid = CompIn->objid;
    CompOut->osnum = CompIn->osnum;
    CompIn->objid  = NULL_OBJID;

    return(MSSUCC);
  }
  else
  {
#ifdef DEBUG
    __DBGpr_com("    it's GR3dlinestr");
#endif
    stat = AppLinestr( CompIn, CompOut, cst, surfs, suc );
    if ( !(stat&1) )
    {
      CompOut->objid = CompIn->objid;
      CompOut->osnum = CompIn->osnum;
      CompIn->objid  = NULL_OBJID;
    }
    return(MSSUCC);
  }

wrapup:

  if( compid != NULL ) om$dealloc(ptr = compid);
  CompOut->objid = CompIn->objid;
  CompOut->osnum = CompIn->osnum;
  CompIn->objid  = NULL_OBJID;

  return(MSFAIL);

} /* BuildCompCrv() */

/*
	-------------------------------------------------------------------
	AppLinestr() :
	------------
	This function is called by the function BuildCompCrv().
	Approximate a line-string by a B-spline.
									JLL
	-------------------------------------------------------------------
 */

AppLinestr( CompIn, CompOut, cst, surfs, suc )
  struct	GRid		*CompIn;
  struct	GRid		*CompOut;
  struct  GRvg_construct	*cst;
  struct GRlc_info       	 surfs[];
  IGRlong			*suc;

{

  IGRlong		stat;
  struct GRlc_info      lc_inf ;
  IGRdouble		average_error;
  IGRdouble		maximum_error;
  IGRdouble		maximum_segment[6], begend[6], endpts[6], uv[2];
  IGRdouble		dis_fact, TgtNor[27], proj_pt[3], derivates[6];
  IGRlong		order		;
  IGRboolean		periodic	;
  IGRlong      		number_of_points, num_seg, maximum_index ;
  struct GRparms	proj_parms[2]	;
  IGRint		i, k		;
  IGRint		numpM3;
  struct IGRbsp_curve	*cv;
  extern IGRboolean	BScrossp() 	;
  extern IGRdouble	BSdotp();

#ifdef DEBUG
  printf("Call to AppLinestr() \n") ;
  __DBGpr_com("---> AppLinestr");
  __DBGpr_grid("Surf1", &(surfs[0].located_obj) );
  __DBGpr_grid("Surf2", &(surfs[1].located_obj) );
#endif

  /* evaluate the tangency conditions */

  dis_fact = 1.0;

  stat = om$send( msg = message GRvg.GRgenabsg( suc,
                                                &cst->env_info->md_env.matrix_type,
                                                 cst->env_info->md_env.matrix,
                                                (IGRchar **) &cv ),
                  senderid = NULL_OBJID,
                  targetid = CompIn->objid,
                  targetos = CompIn->osnum) ;
  as$status(sts = stat) ;

  if ( !(*suc&stat&1) ) return(MSFAIL);

  numpM3 = 3 * (cv->num_poles-1);

  for(i=0;i<3;i=i+1)
  {
    endpts[i]      = cv->poles[i];
    derivates[i]   = cv->poles[i+3] - cv->poles[i];
    endpts[i+3]    = cv->poles[numpM3+i];
    derivates[i+3] = cv->poles[numpM3+i] - cv->poles[numpM3-3+i];
  }

  for(i=0;i<2;i=i+1)
  {
#ifdef DEBUG
    __DBGpr_com("---> enter GRgraphics.GRptproject");
#endif

    stat = om$send( msg = message GRgraphics.GRptproject( suc,
                                                          &cst->env_info->md_env.matrix_type,
                                                           cst->env_info->md_env.matrix,
                                                          &endpts[3*i],
                                                          proj_pt,
                                                          &proj_parms[0] ),
                    senderid = NULL_OBJID,
                    targetid = surfs[0].located_obj.objid,
                    targetos = surfs[0].located_obj.osnum) ;
    as$status(sts = stat) ;

#ifdef DEBUG
    __DBGpr_com("---> exit GRgraphics.GRptproject on surf 1");
    __DBGpr_grid("	leaf1 =", &(proj_parms[0].leaf_id) );
#endif

    if ( !(*suc & stat & 1) ) return(MSFAIL);

    uv[0] = proj_parms[0].u;
    uv[1] = proj_parms[0].v;

    stat = om$send( msg = message EMSsubbs.EMtangent_normal( suc,
                                                             cst->env_info,
                                                             uv,
                                                             dis_fact,
                                                             (IGRvector *)TgtNor),
                    senderid = NULL_OBJID,
                    targetid = proj_parms[0].leaf_id.objid,
                    targetos = proj_parms[0].leaf_id.osnum );
    as$status(sts = stat) ;

#ifdef DEBUG
    __DBGpr_com("---> exit EMSsubbs.EMtangent_normal on surf 1");
    __DBGpr_double("    uv = ", uv, 2,2 );
    __DBGpr_vec("    tgt u 1 =", TgtNor,3 );
    __DBGpr_vec("    tgt u 1 =", &TgtNor[3],3 );
    __DBGpr_vec("    nor 1 =", &TgtNor[6],3 );
#endif

    if ( !(*suc&stat&1) ) return(MSFAIL);

    stat = om$send( msg = message GRgraphics.GRptproject( suc,
                                                          &cst->env_info->md_env.matrix_type,
                                                           cst->env_info->md_env.matrix,
                                                          &endpts[3*i],
                                                           proj_pt,
                                                          &proj_parms[1] ),
                    senderid = NULL_OBJID,
                    targetid = surfs[1].located_obj.objid,
                    targetos = surfs[1].located_obj.osnum );
    as$status(sts = stat) ;

#ifdef DEBUG
    __DBGpr_com("---> exit GRgraphics.GRptproject on surf 1");
    __DBGpr_grid("	leaf2 =", &(proj_parms[1].leaf_id) );
#endif
    if ( !(*suc&stat&1) ) return(MSFAIL);

    uv[0] = proj_parms[1].u;
    uv[1] = proj_parms[1].v;

    stat = om$send( msg = message EMSsubbs.EMtangent_normal( suc,
                                                             cst->env_info,
                                                             uv,
                                                             dis_fact,
                                                             (IGRvector *)&TgtNor[9]),
                    senderid = NULL_OBJID,
                    targetid = proj_parms[1].leaf_id.objid,
                    targetos = proj_parms[1].leaf_id.osnum );
    as$status(sts = stat) ;

#ifdef DEBUG
    __DBGpr_com("---> exit EMSsubbs.EMtangent_normal on surf 2");
    __DBGpr_double("   uv = ", uv, 2,2 );
    __DBGpr_vec("   tgt u 2 =", &TgtNor[9],3 );
    __DBGpr_vec("   tgt 2 =", &TgtNor[12],3 );
    __DBGpr_vec("    nor 2 =", &TgtNor[15],3 );
#endif

    if ( !(*suc&stat&1) ) return(MSFAIL);

    BScrossp(suc,&TgtNor[6],&TgtNor[15],&begend[3*i]);

    if( BSdotp(suc,&derivates[3*i],&begend[3*i]) < 0.0 )
    {
      for( k=3*i; k<3*(i+1); k=k+1)
        begend[k] = -1.0 * begend[k];
    }
  }

#ifdef DEBUG */
  __DBGpr_double( " begend =", begend, 3, 6 );
#endif */

  lc_inf.located_obj.objid = CompIn->objid;
  lc_inf.located_obj.osnum = CompIn->osnum;
  lc_inf.module_info       = *cst->env_info;

  CompOut->objid           = NULL_OBJID;
  CompOut->osnum           = CompIn->osnum;

  order                    = 4;
  periodic                 = FALSE;
  number_of_points         = 0;
  num_seg                  = 0;

#ifdef DEBUG
  __DBGpr_grid("CompOut", CompOut );
  __DBGpr_com("---> GRsubbc.EMleast_squares_fit_curvee");
#endif

#if 0
  stat = ci$send( msg = message GRbcsubbc.EMleast_squares_fit_curvee( order,
                                                                      periodic,
                                                                      number_of_points,NULL,
                                                                      &lc_inf,
                                                                      begend,
                                                                      &begend[3],
                                                                      num_seg,
                                                                      NULL,
                                                                      &average_error,
                                                                      &maximum_error,
                                                                      &maximum_index,
                                                                      maximum_segment,
                                                                      cst ),
                  targetid = CompOut->objid,
                  targetos = CompOut->osnum);
#endif

#if 1
  stat = om$construct( classname = "GRbcsubbc",
                       osnum     = CompOut->osnum,
                       p_objid   = &CompOut->objid,
                       msg       = message GRbcsubbc.EMleast_squares_fit_curvee( order,
                                                                                 periodic,
                                                                                 number_of_points,
                                                                                 NULL,
                                                                                 &lc_inf,
                                                                                 (IGRvector *)begend,
                                                                                 (IGRvector *)&begend[3],
                                                                                 num_seg,
                                                                                 NULL,
                                                                                 &average_error,
                                                                                 &maximum_error,
                                                                                 &maximum_index,
                                                                                 (IGRpoint *) maximum_segment, cst ) ) ;
  as$status(sts = stat) ;
#endif

#ifdef DEBUG
  __DBGpr_grid("CompOut", CompOut );
  __DBGpr_com("---> exit GRsubbc.EMleast_squares_fit_curvee");
#endif

  if ( !(stat&1) ) return(MSFAIL);

  *suc = MSSUCC;
  return(MSSUCC);

} /* AppLinestr() */

/*
v	-------------------------------------------------------------------
	EvalFromTo() :
	------------
	This function is used by the macro crv_pro_v.u
									JLL
	-------------------------------------------------------------------
 */

EvalFromTo( srf_info, crv_info, p1, p2, FromTo, msg )

  struct GRlc_info 	*srf_info;
  struct GRlc_info	*crv_info;
  IGRdouble		*p1;
  IGRdouble		*p2;
  IGRdouble		*FromTo;
  IGRlong			*msg;

{

  IGRlong		stat;
  IGRdouble		rng[6];
  IGRboolean		world ;

  /* ---  this function :
     . get the range of the original curve to project and the surface.
     . Project this to range on to the line  of projection
       to define the length of the surface of projection
       we will have to build later.
     --- */

#ifdef DEBUG
  printf("Call to EvalFromTo() \n") ;
#endif

  world = 1 ; /* to apply env matrix */
  stat = om$send( msg = message GRgraphics.GRgetrang( msg,
                                                      &srf_info->module_info.md_env.matrix_type,
                                                       srf_info->module_info.md_env.matrix,
                                                      &world,
                                                      rng ),
                  senderid = NULL_OBJID,
                  targetid = srf_info->located_obj.objid,
                  targetos = srf_info->located_obj.osnum );
  as$status(sts = stat) ;

  if( !(*msg&stat&1) ) return(MSFAIL);
#ifdef DEBUG
  __DBGpr_grid("original srf_info ",&srf_info->located_obj);
  __DBGpr_double("range of surface =",rng,3,6);
#endif
 EvalFromTo1(rng, crv_info, p1, p2, FromTo, msg );
 if(!(*msg&1)) return(MSFAIL);

  *msg = MSSUCC;
  return(MSSUCC);

  // wrapup:	// Never used though it should have been

  // return(MSFAIL);
} /* EvalFromTo() */

/*
	-------------------------------------------------------------------
	ProjPtOntoLine() :
	----------------
	Called by EvalFromTo().
									JLL
	-------------------------------------------------------------------
 */

ProjPtOntoLine( p, q, point, u, ProjPt, rc )

  IGRdouble	*p;		/* line origin */
  IGRdouble	*q;		/* vector defining the direction */
  IGRdouble	*point; 	/* point to project */
  IGRdouble	*u;		/* paramter of projection */
  IGRdouble	*ProjPt;	/* the resulting projected point */
  IGRlong	*rc;		/* return code */

{

  IGRdouble		vdif[3]   ;
  IGRdouble		d	  ;
  IGRint		i	  ;
  extern IGRint		BSmkvec() ;
  extern IGRdouble	BSdotp()  ;

  BSmkvec(rc,vdif,p,point);
  if( *rc != BSSUCC ) return 1;

  d = BSdotp(rc,q,q);
  if( *rc != BSSUCC ) return 1;

  *u = BSdotp(rc,vdif,q);
  *u = *u / d;

  for(i=0;i<3;i=i+1)
    ProjPt[i] = p[i] + (*u) * q[i];

#ifdef DEBUG
  __DBGpr_double("parameter *u =",u,1,1);
  __DBGpr_vec("ProjPt =",ProjPt,3);
#endif

  *rc = MSSUCC;
  return(MSSUCC);
} /* ProjPtOntoLine() */

/*
	-------------------------------------------------------------------
 */

__DBGpr_vec(txt, val, idim )

  IGRchar  	*txt;
  IGRdouble	*val;
  IGRint		idim;

{
  IGRint	i;

  printf(txt);

  for(i=0;i<idim;i=i+1)
    printf(" %f,",val[i]);
  printf("\n");

  return 1;    // Get rid of warning message
}

/*
	-------------------------------------------------------------------
 */

__DBGpr_grid( txt, id )

  IGRchar	*txt;
  struct GRid	*id;

{
  printf(txt);
  printf(" objid = %d, %d \n",id->objid,id->osnum );
  return 1;
}

/*
	-------------------------------------------------------------------
 */

__DBGpr_double( txt, d, dim1, dim2 )

  IGRchar	*txt;
  IGRdouble	*d;
  IGRint	dim1;
  IGRint	dim2;

{
  IGRint i, j, k;

  for(i=0;i<dim2;i=i+dim1)
  {
    k = i + dim1;
    printf("      ");
    printf(txt);
    printf("[%d] = ",i);

    for(j=i;j<k;j=j+1)
      printf("%f,", d[j] );
    printf("\n");
  }
  return 1;
}

/*
	-------------------------------------------------------------------
 */

__DBGpr_int( txt, d, dim1, dim2 )

  IGRchar	*txt;
  IGRint	*d;
  IGRint	dim1;
  IGRint	dim2;

{
  IGRint i, j, k;

  for(i=0;i<dim2;i=i+dim1)
  {
    k = i + dim1;
    printf("      ");
    printf(txt);
    printf("[%d] = ",i);

    for(j=i;j<k;j=j+1)
      printf("%d,", d[j] );
    printf("\n");
  }
  return 1;
}

/*
	-------------------------------------------------------------------
 */

__DBGpr_com(txt)

  IGRchar  	*txt;
{
  printf(txt);
  printf("\n");
  return 1;
}

/*
	===================================================================
		End of functions needed by crv_pro_v.u and int_2_ele.u
	===================================================================
 */

/* ====================================================================== */


IGRint get_extsurf_geom(surf_ptr, surf_mod_env_ptr, extent, ext_surf_geom_ptrptr)
  struct GRid		 *surf_ptr  ;			/* I */
struct GRmd_env		 *surf_mod_env_ptr ;		/* I */
IGRdouble		  extent ;			/* I */
struct IGRbsp_surface 	**ext_surf_geom_ptrptr ;	/* O */
/*
  Description :
	  Given a located bspline surface and an extent value, this
          function returns the new geometry corresponding to a surface
          extended tangently at its boundary isocurves.
          A return code of 1 indicates a successful completion.
  Note :
	  The new surface geometry (*ext_surf_geom_ptrptr) is allocated
          by this function.
          After usage, *ext_surf_geom_ptrptr should be freed by BSfreesf().
*/
{
  struct IGRbsp_surface *surf_geom_ptr ; /* old geometry */
  IGRlong		size  ;
  IGRlong 		msg, sts ;
  IGRint		rc_func  ;
  IGRdouble		u_extent, v_extent;

  /*
   *    Get former bspline surface geometry
   */

  /*
   * Golly gee, what if GRgetsize fails
   * Add null here to prevent random freeing
   */
  surf_geom_ptr = NULL ;

  sts = om$send( msg = message GRvg.GRgetsize( &msg,
                                               &surf_mod_env_ptr->md_env.matrix_type,
                                                surf_mod_env_ptr->md_env.matrix,
                                               &size ),
                 senderid = NULL_OBJID,
                 targetid = surf_ptr->objid,
                 targetos = surf_ptr->osnum ) ; as$status(sts=sts) ;
  if( !(sts & msg & 1) )
  {
    rc_func = 0 ;
    goto wrapup ;
  }

  surf_geom_ptr = NULL ;
  surf_geom_ptr = (struct IGRbsp_surface *) malloc(size) ;
  if (surf_geom_ptr == NULL)
  {
    rc_func = 0 ;
    goto wrapup ;
  }

  sts = om$send( msg = message GRvg.GRgetgeom( &msg,
                                               &surf_mod_env_ptr->md_env.matrix_type,
                                                surf_mod_env_ptr->md_env.matrix,
                                               (IGRchar *) surf_geom_ptr),
                 senderid = NULL_OBJID,
                 targetid = surf_ptr->objid,
                 targetos = surf_ptr->osnum ) ; as$status(sts=sts) ;
  if( !(sts & msg & 1) )
  {
    rc_func = 0 ;
    goto wrapup;
  }

//  sts = extent_surface_geom( surf_geom_ptr,		  /* I */
//                             extent,				  /* I */
//                             ext_surf_geom_ptrptr );/* O */

  u_extent = extent;
  v_extent = extent;
	
#ifdef DEBUG
printf("u_extent = %f,v_extent = %f\n",u_extent,v_extent);
#endif

sts = uv_extent_surface_geom(surf_geom_ptr, u_extent, v_extent, ext_surf_geom_ptrptr);
  if (!(sts & 1))
  {
#ifdef DEBUG
    printf("uv_extent_surface_geom() failed\n") ;
#endif
    rc_func = 0 ; goto wrapup ;
  }

  rc_func = 1 ; /* success */

wrapup:	/* in all cases */

  if (surf_geom_ptr != NULL) free(surf_geom_ptr) ; /* malloc() used */

  return rc_func ;
} /* get_extsurf_geom() */

/* ====================================================================== */
/* ====================================================================== */

IGRint uv_extent_surface_geom(surf_geom_ptr, u_extent, v_extent, ext_surf_geom_ptrptr)
  struct IGRbsp_surface *surf_geom_ptr ;		/* I: The original surface */
  IGRdouble				u_extent ;				/* I: The extension in the u direction of the surface */
  IGRdouble				v_extent ;				/* I: The extension in the v direction of the surface */   
  struct IGRbsp_surface **ext_surf_geom_ptrptr ;/* O */
/*
  Description :
	  Given a bspline surface geometry and an extent value, this
          function returns the new geometry corresponding to a surface
          extended tangently at its boundary isocurves.
          A return code of 1 indicates a successful completion.
  Note :
	  The new surface geometry (*ext_surf_geom_ptrptr) is allocated
          by this function.
          After usage, *ext_surf_geom_ptrptr should be freed by BSfreesf().
 */
{
  IGRdouble		abs_u_extent, abs_v_extent, leftExt, rightExt, zeroTol ;
  struct IGRbsp_surface   *ext_surf_geom_ptr ; /* local notation */
  IGRshort		num_boundaries  ;
  IGRlong		new_u_num_poles, new_v_num_poles ;
  IGRlong		new_u_num_knots, new_v_num_knots ;
  IGRint		start_row, start_pos;
  IGRlong 		sts ;
  BSrc			bsrc ;

  IGRlong irow,icol;  // Make type match what extent function expects

#ifdef DEBUG
  printf("	---> Call to extent_surface_geom() \n") ;
  printf("	Initial surface : \n") ;
  printf("	u_order   is %d \n", surf_geom_ptr->u_order) ;
  printf("	v_order   is %d \n", surf_geom_ptr->v_order) ;
  printf("	u num poles is %d \n", surf_geom_ptr->u_num_poles) ;
  printf("	v num poles is %d \n", surf_geom_ptr->v_num_poles) ;
  
  printf("      u num knots is %d \n", surf_geom_ptr->u_num_knots);
  printf("      v num knots is %d \n", surf_geom_ptr->v_num_knots);
  printf("      u_extent = %f, v_extent = %f \n",u_extent,v_extent);
  printf("\n") ;
#endif


  BSEXTRACTPAR(&bsrc, BSTOLLENVEC, zeroTol);

  abs_u_extent = fabs(u_extent);
  abs_v_extent = fabs(v_extent);

  if ( (abs_u_extent < zeroTol) && (abs_v_extent < zeroTol) )
  {
    /*
      Just copy the surface
    */
    ext_surf_geom_ptr = NULL ; /* local */
    BSallocsf(	surf_geom_ptr->u_order,
                surf_geom_ptr->v_order,
                surf_geom_ptr->u_num_poles,
                surf_geom_ptr->v_num_poles,
                surf_geom_ptr->rational,
                surf_geom_ptr->num_boundaries, /* No boundaries    */
                &ext_surf_geom_ptr,	       /* ptr to local ptr */
                &bsrc	) ;
    if (bsrc != BSSUCC) return 0 ;

    BSsf_copy(&bsrc, surf_geom_ptr, ext_surf_geom_ptr) ;
    if (bsrc != BSSUCC)
      goto wrapup ;
    else
    {
      *ext_surf_geom_ptrptr = ext_surf_geom_ptr ;
      return 1 ; /* success */
    }
  } /* if */

  /*
    0) Allocate new surface geometry, and initialize it
  */

  if (surf_geom_ptr->u_phy_closed)
  {
    /* No extension in u direction */
    new_u_num_poles = surf_geom_ptr->u_num_poles ;
    new_u_num_knots = surf_geom_ptr->u_num_knots ;
  }
  else
  {
	  if( (surf_geom_ptr->u_order == 2) || (abs_u_extent < zeroTol) )
	  {
		new_u_num_poles = surf_geom_ptr->u_num_poles;
		new_u_num_knots = surf_geom_ptr->u_num_knots;
	  }
	  else
	  {
		new_u_num_poles = surf_geom_ptr->u_num_poles + 2 * (surf_geom_ptr->u_order - 1) ;
		new_u_num_knots = surf_geom_ptr->u_num_knots + 2 * (surf_geom_ptr->u_order - 1) ;
	  }
  }

  if (surf_geom_ptr->v_phy_closed)
  {
    /* No extension in v direction */
    new_v_num_poles = surf_geom_ptr->v_num_poles ;
    new_v_num_knots = surf_geom_ptr->v_num_knots ;
  }
  else
  {
	  if( (surf_geom_ptr->v_order == 2) || (abs_v_extent < zeroTol) )
	  {
		new_v_num_poles = surf_geom_ptr->v_num_poles;
		new_v_num_knots = surf_geom_ptr->v_num_knots;
	  }
	  else
	  {
		new_v_num_poles = surf_geom_ptr->v_num_poles + 2 * (surf_geom_ptr->v_order - 1) ;
		new_v_num_knots = surf_geom_ptr->v_num_knots + 2 * (surf_geom_ptr->v_order - 1) ;
	  }
  }

  num_boundaries  = 0 ;

  ext_surf_geom_ptr = NULL ; /* local */
  BSallocsf(	surf_geom_ptr->u_order,
		surf_geom_ptr->v_order,
		new_u_num_poles,
		new_v_num_poles,
		surf_geom_ptr->rational,
		num_boundaries,			/* No boundaries */
		&ext_surf_geom_ptr,		/* ptr to local ptr */
		&bsrc	) ;
  if (bsrc != BSSUCC)
  {
	#ifdef DEBUG
    printf("BSallocsf() failed \n") ;
	#endif
    goto wrapup ;
  }

  ext_surf_geom_ptr->u_order        = surf_geom_ptr->u_order ;
  ext_surf_geom_ptr->v_order        = surf_geom_ptr->v_order ;
  ext_surf_geom_ptr->u_periodic     = surf_geom_ptr->u_periodic ;
  ext_surf_geom_ptr->v_periodic     = surf_geom_ptr->v_periodic ;
  ext_surf_geom_ptr->u_non_uniform  = TRUE ;
  ext_surf_geom_ptr->v_non_uniform  = TRUE ;

  ext_surf_geom_ptr->u_num_poles    = new_u_num_poles ;
  ext_surf_geom_ptr->v_num_poles    = new_v_num_poles ;
  ext_surf_geom_ptr->u_num_knots    = new_u_num_knots ;
  ext_surf_geom_ptr->v_num_knots    = new_v_num_knots ;

  ext_surf_geom_ptr->rational       = surf_geom_ptr->rational ;
  ext_surf_geom_ptr->planar         = surf_geom_ptr->planar   ;
  ext_surf_geom_ptr->u_phy_closed   = surf_geom_ptr->u_phy_closed ;
  ext_surf_geom_ptr->v_phy_closed   = surf_geom_ptr->v_phy_closed ;
  ext_surf_geom_ptr->pos_orient     = surf_geom_ptr->pos_orient   ;
  ext_surf_geom_ptr->on_off         = surf_geom_ptr->on_off       ;
  ext_surf_geom_ptr->num_boundaries = 0  ;		/* no boundaries */
  ext_surf_geom_ptr->bdrys          = NULL ;

  /*
    Test
  */

#ifdef DEBUG
  printf("	Extended surface : \n") ;
  printf("	u_order   is %d \n", ext_surf_geom_ptr->u_order) ;
  printf("	v_order   is %d \n", ext_surf_geom_ptr->v_order) ;
  printf("	u num poles is %d \n", ext_surf_geom_ptr->u_num_poles) ;
  printf("	v num poles is %d \n", ext_surf_geom_ptr->v_num_poles);
  printf("  u num knots is %d \n", ext_surf_geom_ptr->u_num_knots);
  printf("  v num knots is %d \n", ext_surf_geom_ptr->v_num_knots) ;
#endif

  /*
    1) Extent surface geometry in the u directions
    (lines of the new matrix of poles)
  */
  
  start_row = (ext_surf_geom_ptr->v_num_poles - surf_geom_ptr->v_num_poles) / 2 ;
  start_pos = start_row * (ext_surf_geom_ptr->u_num_poles) ;

  if (ext_surf_geom_ptr->u_phy_closed)
  {

#ifdef DEBUG
    printf("Surface is u_phy_closed \n") ; /* no extension needed */
#endif

    /* Poles matrix : the starting position is (start_pos * 3) */
    memcpy((char *) &ext_surf_geom_ptr->poles[start_pos * 3], /* target */
           (char *) &surf_geom_ptr->poles[0],
           (int) surf_geom_ptr->u_num_poles * surf_geom_ptr->v_num_poles * 3 * sizeof(IGRdouble)) ;

    /* Vector u-knots */
    memcpy((char *) &ext_surf_geom_ptr->u_knots[0],	/* target */
           (char *) &surf_geom_ptr->u_knots[0],
           (int) surf_geom_ptr->u_num_knots * sizeof(IGRdouble)) ;

    /* Weights */
    if (ext_surf_geom_ptr->rational)
    {
      memcpy((char *) &ext_surf_geom_ptr->weights[start_pos],
             (char *) &surf_geom_ptr->weights[0],
             (int) surf_geom_ptr->u_num_poles * surf_geom_ptr->v_num_poles * sizeof(IGRdouble)) ;
    }
  } /* u_phy_closed */
  else
  {
    /* Extent both sides of u isocurve for each line of the poles matrix */

	if( abs_u_extent > zeroTol )
	{
		sts = eval_extent_ratios(surf_geom_ptr, TRUE, abs_u_extent, &leftExt, &rightExt);

		/* Recopy old poles, compute & store new poles in new matrix of poles */

		for (irow = 0 ;			/* row of old matrix of poles */
			 irow < surf_geom_ptr->v_num_poles ;   /* old v num poles */
			 irow++)
		{
		  sts = poly_extent_u_poles( surf_geom_ptr,      /* I */
				                     leftExt,rightExt,   /* I */
						             irow,               /* I */
									 ext_surf_geom_ptr );/* O */
		  if (!(sts & 1))
		  {
			goto wrapup ;
		  }
		} /* for */
	}
	else
	{
		
 		irow = surf_geom_ptr->u_num_poles * surf_geom_ptr->v_num_poles * sizeof(IGRdouble);
		memcpy((char *) &ext_surf_geom_ptr->poles[3*start_pos],
		       (char *) &surf_geom_ptr->poles[0],
		       (int) 3*irow );
		if( ext_surf_geom_ptr->rational )
		memcpy((char *) &ext_surf_geom_ptr->weights[start_pos],
		       (char *) &surf_geom_ptr->weights[0],
    		       (int) irow ); 	
	} 

	/* Update u-knots vector */
	sts = extent_knots(	ext_surf_geom_ptr->u_order,		/* I */
		                surf_geom_ptr->u_knots,			/* I */
			            surf_geom_ptr->u_num_knots,		/* I */
			            ext_surf_geom_ptr->u_num_knots,	/* I */
				        ext_surf_geom_ptr->u_knots);	/* O */

  } /* else : u direction */

  /*
    2) Extent surface geometry in the v directions
    (columns of the new matrix of poles)
  */

  if (ext_surf_geom_ptr->v_phy_closed)
  {

    /* No additional poles */

    /* Vector v-knots */
    memcpy((char *) &ext_surf_geom_ptr->v_knots[0],	/* target */
           (char *) &surf_geom_ptr->v_knots[0],		/* source */
           (int) surf_geom_ptr->v_num_knots * sizeof(IGRdouble)) ;

    /* No additional weights */
  } /* v_phy_closed */
  else
  {
    /* Extent both sides of v isocurve for each column of the poles matrix */

	if( abs_v_extent > zeroTol )
	{
		sts = eval_extent_ratios(surf_geom_ptr, FALSE, abs_v_extent, &leftExt, &rightExt);
		/* Compute & store new poles in new matrix of poles */
		for (icol = 0 ;		/* column of new matrix of poles */
			 icol < ext_surf_geom_ptr->u_num_poles ;
			 icol++)
		{
			sts = poly_extent_v_poles( surf_geom_ptr,
					                   leftExt, rightExt,
								       icol,                    /* I */
									   ext_surf_geom_ptr	    /* O */ ) ;
			if (!(sts & 1))
			{
				goto wrapup ;
			}
		}
	}

	/* Update v-knots vector */
	sts = extent_knots(	ext_surf_geom_ptr->v_order,		/* I */
		                surf_geom_ptr->v_knots,			/* I */
			            surf_geom_ptr->v_num_knots,		/* I */
						ext_surf_geom_ptr->v_num_knots,	/* I */
				        ext_surf_geom_ptr->v_knots );	/* O */
  } /* else : v direction */

  *ext_surf_geom_ptrptr = ext_surf_geom_ptr ; /* global */
  return 1 ;  /* success */

wrapup:	/* error */

  if (ext_surf_geom_ptr != NULL)
  {	/* BSallocsf() used */
    BSfreesf(&bsrc, ext_surf_geom_ptr) ;
    if (bsrc != BSSUCC) printf("BSfreesf() failed \n") ;
    *ext_surf_geom_ptrptr = NULL ;
  }

  *ext_surf_geom_ptrptr = NULL;
  return 0 ;

} /* uv_extent_surface_geom() */

/* ====================================================================== */
/* ====================================================================== */


/* ====================================================================== */

IGRint extent_surface_geom(surf_geom_ptr, extent, ext_surf_geom_ptrptr)
  struct IGRbsp_surface 	 *surf_geom_ptr ;		/* I */
  IGRdouble			  extent ;			/* I */
  struct IGRbsp_surface 	**ext_surf_geom_ptrptr ;	/* O */
/*
  Description :
	  Given a bspline surface geometry and an extent value, this
          function returns the new geometry corresponding to a surface
          extended tangently at its boundary isocurves.
          A return code of 1 indicates a successful completion.
  Note :
	  The new surface geometry (*ext_surf_geom_ptrptr) is allocated
          by this function.
          After usage, *ext_surf_geom_ptrptr should be freed by BSfreesf().
 */
{
  IGRdouble		abs_extent, leftExt, rightExt ;
  struct IGRbsp_surface   *ext_surf_geom_ptr ; /* local notation */
  IGRshort		num_boundaries  ;
  IGRlong		new_u_num_poles, new_v_num_poles ;
  IGRlong		new_u_num_knots, new_v_num_knots ;
  IGRint		start_row, start_pos;
  IGRlong 		sts ;
  BSrc			bsrc ;

  IGRlong irow,icol;  // Make type match what extent function expects

#ifdef DEBUG
  printf("	---> Call to extent_surface_geom() \n") ;
  printf("	Initial surface : \n") ;
  printf("	u_order   is %d \n", surf_geom_ptr->u_order) ;
  printf("	v_order   is %d \n", surf_geom_ptr->v_order) ;
  printf("	u num poles is %d \n", surf_geom_ptr->u_num_poles) ;
  printf("	v num poles is %d \n", surf_geom_ptr->v_num_poles) ;
  printf("\n") ;
#endif

  abs_extent = fabs(extent) ;
  if (abs_extent < 1.0E-6)
  {
    /*
      Just copy the surface
    */
    ext_surf_geom_ptr = NULL ; /* local */
    BSallocsf(	surf_geom_ptr->u_order,
                surf_geom_ptr->v_order,
                surf_geom_ptr->u_num_poles,
                surf_geom_ptr->v_num_poles,
                surf_geom_ptr->rational,
                surf_geom_ptr->num_boundaries, /* No boundaries    */
                &ext_surf_geom_ptr,	       /* ptr to local ptr */
                &bsrc	) ;
    if (bsrc != BSSUCC) return 0 ;

    BSsf_copy(&bsrc, surf_geom_ptr, ext_surf_geom_ptr) ;
    if (bsrc != BSSUCC)
      goto wrapup ;
    else
    {
      *ext_surf_geom_ptrptr = ext_surf_geom_ptr ;
      return 1 ; /* success */
    }
  } /* if */

  /*
    0) Allocate new surface geometry, and initialize it
  */

  if (surf_geom_ptr->u_phy_closed)
  {
    /* No extension in u direction */
    new_u_num_poles = surf_geom_ptr->u_num_poles ;
    new_u_num_knots = surf_geom_ptr->u_num_knots ;
  }
  else
  {
/* JLL beg 1 */
	  if( surf_geom_ptr->u_order == 2 )
	  {
		new_u_num_poles = surf_geom_ptr->u_num_poles;
		new_u_num_knots = surf_geom_ptr->u_num_knots;
	  }
	  else
	  {
		new_u_num_poles = surf_geom_ptr->u_num_poles + 2 * (surf_geom_ptr->u_order - 1) ;
		new_u_num_knots = surf_geom_ptr->u_num_knots + 2 * (surf_geom_ptr->u_order - 1) ;
	  }
/* JLL end 1 */
  }

  if (surf_geom_ptr->v_phy_closed)
  {
    /* No extension in v direction */
    new_v_num_poles = surf_geom_ptr->v_num_poles ;
    new_v_num_knots = surf_geom_ptr->v_num_knots ;
  }
  else
  {
/* JLL beg 2 */
	  if( surf_geom_ptr->v_order == 2 )
	  {
		new_v_num_poles = surf_geom_ptr->v_num_poles;
		new_v_num_knots = surf_geom_ptr->v_num_knots;
	  }
	  else
	  {
		new_v_num_poles = surf_geom_ptr->v_num_poles + 2 * (surf_geom_ptr->v_order - 1) ;
		new_v_num_knots = surf_geom_ptr->v_num_knots + 2 * (surf_geom_ptr->v_order - 1) ;
	  }
/* JLL end 2 */
  }

  num_boundaries  = 0 ;

  ext_surf_geom_ptr = NULL ; /* local */
  BSallocsf(	surf_geom_ptr->u_order,
		surf_geom_ptr->v_order,
		new_u_num_poles,
		new_v_num_poles,
		surf_geom_ptr->rational,
		num_boundaries,			/* No boundaries */
		&ext_surf_geom_ptr,		/* ptr to local ptr */
		&bsrc	) ;
  if (bsrc != BSSUCC)
  {
#ifdef DEBUG
    printf("BSallocsf() failed \n") ;
#endif
    goto wrapup ;
  }

  ext_surf_geom_ptr->u_order        = surf_geom_ptr->u_order ;
  ext_surf_geom_ptr->v_order        = surf_geom_ptr->v_order ;
  ext_surf_geom_ptr->u_periodic     = surf_geom_ptr->u_periodic ;
  ext_surf_geom_ptr->v_periodic     = surf_geom_ptr->v_periodic ;
  ext_surf_geom_ptr->u_non_uniform  = TRUE ;
  ext_surf_geom_ptr->v_non_uniform  = TRUE ;

  ext_surf_geom_ptr->u_num_poles    = new_u_num_poles ;
  ext_surf_geom_ptr->v_num_poles    = new_v_num_poles ;
  ext_surf_geom_ptr->u_num_knots    = new_u_num_knots ;
  ext_surf_geom_ptr->v_num_knots    = new_v_num_knots ;

  ext_surf_geom_ptr->rational       = surf_geom_ptr->rational ;
  ext_surf_geom_ptr->planar         = surf_geom_ptr->planar   ;
  ext_surf_geom_ptr->u_phy_closed   = surf_geom_ptr->u_phy_closed ;
  ext_surf_geom_ptr->v_phy_closed   = surf_geom_ptr->v_phy_closed ;
  ext_surf_geom_ptr->pos_orient     = surf_geom_ptr->pos_orient   ;
  ext_surf_geom_ptr->on_off         = surf_geom_ptr->on_off       ;
  ext_surf_geom_ptr->num_boundaries = 0  ;		/* no boundaries */
  ext_surf_geom_ptr->bdrys          = NULL ;

  /*
    Test
  */

#ifdef DEBUG
  printf("	Extended surface : \n") ;
  printf("	u_order   is %d \n", ext_surf_geom_ptr->u_order) ;
  printf("	v_order   is %d \n", ext_surf_geom_ptr->v_order) ;
  printf("	u num poles is %d \n", ext_surf_geom_ptr->u_num_poles) ;
  printf("	v num poles is %d \n", ext_surf_geom_ptr->v_num_poles) ;
#endif

  /*
    1) Extent surface geometry in the u directions
    (lines of the new matrix of poles)
  */
  
  start_row = (ext_surf_geom_ptr->v_num_poles - surf_geom_ptr->v_num_poles) / 2 ;
  start_pos = start_row * (ext_surf_geom_ptr->u_num_poles) ;

  if (ext_surf_geom_ptr->u_phy_closed)
  {
#ifdef DEBUG
    printf("Surface is u_phy_closed \n") ; /* no extension needed */
#endif

    /* Poles matrix : the starting position is (start_pos * 3) */
    memcpy((char *) &ext_surf_geom_ptr->poles[start_pos * 3], /* target */
           (char *) &surf_geom_ptr->poles[0],
           (int) surf_geom_ptr->u_num_poles * surf_geom_ptr->v_num_poles * 3 * sizeof(IGRdouble)) ;

    /* Vector u-knots */
    memcpy((char *) &ext_surf_geom_ptr->u_knots[0],	/* target */
           (char *) &surf_geom_ptr->u_knots[0],
           (int) surf_geom_ptr->u_num_knots * sizeof(IGRdouble)) ;

    /* Weights */
    if (ext_surf_geom_ptr->rational)
    {
      memcpy((char *) &ext_surf_geom_ptr->weights[start_pos],
             (char *) &surf_geom_ptr->weights[0],
             (int) surf_geom_ptr->u_num_poles * surf_geom_ptr->v_num_poles * sizeof(IGRdouble)) ;
    }
  } /* u_phy_closed */
  else
  {
    /* Extent both sides of u isocurve for each line of the poles matrix */
#ifdef DEBUG
    printf("Extent surface in the u directions \n") ;
#endif
    sts = eval_extent_ratios(surf_geom_ptr, TRUE, abs_extent, &leftExt, &rightExt);
    /* Recopy old poles, compute & store new poles in new matrix of poles */
    for (irow = 0 ;			/* row of old matrix of poles */
         irow < surf_geom_ptr->v_num_poles ;   /* old v num poles */
         irow++)
    {
      sts = poly_extent_u_poles( surf_geom_ptr,
                            leftExt,rightExt,
                            irow,                    /* I */
                            ext_surf_geom_ptr	     /* O */) ;
      if (!(sts & 1))
      {
        goto wrapup ;
      }
    } /* for */

    /* Update u-knots vector */
    sts = extent_knots(	ext_surf_geom_ptr->u_order,		/* I */
                        surf_geom_ptr->u_knots,			/* I */
                        surf_geom_ptr->u_num_knots,		/* I */
						ext_surf_geom_ptr->u_num_knots,	/* I */
                        ext_surf_geom_ptr->u_knots		/* O */
    ) ;
  } /* else : u direction */

  /*
    2) Extent surface geometry in the v directions
    (columns of the new matrix of poles)
  */

  if (ext_surf_geom_ptr->v_phy_closed)
  {
#ifdef DEBUG
    printf("Surface is v_phy_closed \n") ; /* no extension needed */
#endif

    /* No additional poles */

    /* Vector v-knots */
    memcpy((char *) &ext_surf_geom_ptr->v_knots[0],	/* target */
           (char *) &surf_geom_ptr->v_knots[0],		/* source */
           (int) surf_geom_ptr->v_num_knots * sizeof(IGRdouble)) ;

    /* No additional weights */
  } /* v_phy_closed */
  else
  {
    /* Extent both sides of v isocurve for each column of the poles matrix */

#ifdef DEBUG
    printf("Extent surface in the v directions \n") ;
#endif
    sts = eval_extent_ratios(surf_geom_ptr, FALSE, abs_extent, &leftExt, &rightExt);
    /* Compute & store new poles in new matrix of poles */
    for (icol = 0 ;		/* column of new matrix of poles */
         icol < ext_surf_geom_ptr->u_num_poles ;
         icol++)
    {
      sts = poly_extent_v_poles( surf_geom_ptr,
                            leftExt, rightExt,
                            icol,                    /* I */
                            ext_surf_geom_ptr	     /* O */ ) ;
      if (!(sts & 1))
      {
        goto wrapup ;
      }
    }

    /* Update v-knots vector */
    sts = extent_knots(	ext_surf_geom_ptr->v_order,		/* I */
                        surf_geom_ptr->v_knots,			/* I */
                        surf_geom_ptr->v_num_knots,		/* I */
						ext_surf_geom_ptr->v_num_knots,	/* I */
                        ext_surf_geom_ptr->v_knots		/* O */
    ) ;
  } /* else : v direction */

  *ext_surf_geom_ptrptr = ext_surf_geom_ptr ; /* global */
  return 1 ;  /* success */

wrapup:	/* error */

  if (ext_surf_geom_ptr != NULL)
  {	/* BSallocsf() used */
    BSfreesf(&bsrc, ext_surf_geom_ptr) ;
    if (bsrc != BSSUCC) printf("BSfreesf() failed \n") ;
    *ext_surf_geom_ptrptr = NULL ;
  }

  *ext_surf_geom_ptrptr = NULL;
  return 0 ;

} /* extent_surface_geom() */

/*
	===================================================================
		End of functions needed by pla_offext.u
	===================================================================
 */

int VD_TR179901421 ( msg, surfs )
  IGRlong		*msg;
  struct GRlc_info      *surfs;
{
  IGRlong                sts;
  int                    two_ruled = 0, Reparameter_Reduce;
  struct IGRbsp_surface *bsp0 = NULL, *bsp1 = NULL;

  __enterFunction ( name = "VD_TR179901421" , argfmt = "surfs[0] = [%d,%d], surfs[1] = [%d,%d]", args =
                    `surfs[0].located_obj.osnum, surfs[0].located_obj.objid, surfs[1].located_obj.osnum, surfs[1].located_obj.objid` ) ;

  sts = om$send( msg = message GRvg.GRgenabsg ( msg,
                                                &surfs[1].module_info.md_env.matrix_type,
                                                 surfs[1].module_info.md_env.matrix,
                                                (IGRchar **) &bsp1 ),
                 senderid = NULL_OBJID,
                 targetid = surfs[1].located_obj.objid,
                 targetos = surfs[1].located_obj.osnum);
  if ( ! ( 1 & sts & *msg ) )
    goto wrapup;

  sts = om$send( msg = message GRvg.GRgenabsg ( msg,
                                                &surfs[0].module_info.md_env.matrix_type,
                                                 surfs[0].module_info.md_env.matrix,
                                                (IGRchar **) &bsp0 ),
                 senderid = NULL_OBJID,
                 targetid = surfs[0].located_obj.objid,
                 targetos = surfs[0].located_obj.osnum);
  if ( ! ( 1 & sts & *msg ) )
    goto wrapup;

  // ONLY continue if both are ruled surfaces ...
  if ( bsp0->u_order * bsp0->v_order == 8 && bsp1->u_order * bsp1->v_order == 8 )
  {
    two_ruled = 1;
  }
  else
    goto wrapup;

  // VDReparameterizeSrf() alone causes the intersection curve to have a lot more poles then
  // VDReduce_dataSrf()
  // The best solution, which works in most cases, is : Reduce_data AND Reparameterize

  Reparameter_Reduce = 2;

  if ( Reparameter_Reduce == 0 )              // ONLY Reparameterize
  {
    sts = VDReparameterizeSrf ( msg, &surfs[0] );
    sts = VDReparameterizeSrf ( msg, &surfs[1] );
  }
  else if ( Reparameter_Reduce == 1 )         // ONLY Reduce_data
  {
    sts = VDReduce_dataSrf ( msg, &surfs[0] );
    sts = VDReduce_dataSrf ( msg, &surfs[1] );
  }
  else if ( Reparameter_Reduce == 2 )         // 1st Reduce_data AND Reparameterize
  {
    sts = VDReduce_dataSrf ( msg, &surfs[0] );
    sts = VDReduce_dataSrf ( msg, &surfs[1] );
    sts = VDReparameterizeSrf ( msg, &surfs[0] );
    sts = VDReparameterizeSrf ( msg, &surfs[1] );
  }

wrapup:

  __exitFunction ( name = "VD_TR179901421", argfmt = "two_ruled = %d, sts = %d, *msg = %d", args = `two_ruled, sts, *msg` );

  return two_ruled;
}

int VDReduce_dataSrf ( msg, surfs )
  IGRlong		*msg;
  struct GRlc_info      *surfs;
{
  IGRlong                sts;
  long                   bsRC ;

  IGRint                 tanl, tanr, tant, tanb, option ;
  IGRboolean             erropt ;
  IGRdouble              maxerr, avgerr, uvpar[2], auvpar[2] ;
  IGRpoint               pt, apt ;
  GRobjid                newobjid ;
  struct GRpost_info     post_info ;
  struct IGRbsp_surface *bsp0 = NULL, *red_geom0 = NULL;

  __enterFunction ( name = "VDReduce_dataSrf" , argfmt = "surfs[0] = [%d,%d]", args =
                    `surfs[0].located_obj.osnum, surfs[0].located_obj.objid` ) ;

  sts = om$send( msg = message GRvg.GRgenabsg ( msg,
                                                &surfs[0].module_info.md_env.matrix_type,
                                                 surfs[0].module_info.md_env.matrix,
                                                (IGRchar **) &bsp0 ),
                 senderid = NULL_OBJID,
                 targetid = surfs[0].located_obj.objid,
                 targetos = surfs[0].located_obj.osnum);
  if ( ! ( 1 & sts & *msg ) )
    goto wrapup;

  /*
   * Do data reduction.
   */
  tanl   = 1 ;
  tanr   = 1 ;
  tant   = 1 ;
  tanb   = 1 ;
  option = 2 ;	/* Data reduction in u and v direction */
  erropt = TRUE ;

  post_info.construct_flag = FALSE ;

  BSdta_rdusf( bsp0, option, tanl, tanr, tant, tanb, erropt,
               &maxerr, &avgerr, uvpar, pt, auvpar, apt, &red_geom0, &bsRC ) ;
  if( BSERROR( bsRC ) )
  {
    red_geom0 = NULL ;
    sts = MSFAIL;
    goto wrapup ;
  }

  sts = om$send( msg = message GRvg.GRpostabsg( msg,
                                               &surfs[0].module_info,
                                               &post_info,
                                                (IGRchar *) red_geom0,
                                               &newobjid ),
                 senderid = NULL_OBJID,
                 targetid = surfs[0].located_obj.objid,
                 targetos = surfs[0].located_obj.osnum);
  if( ! ( sts & *msg & 1 ) )
  {
    goto wrapup ;
  }

wrapup:

  __exitFunction ( name = "VDReduce_dataSrf", argfmt = "sts = %d, *msg = %d", args = `sts, *msg` );

  return sts;
}

int VDReparameterizeSrf( msg, surfs )
  IGRlong		*msg;
  struct GRlc_info      *surfs;
{
  IGRlong                sts, size0;
  long                   bsRC ;

  IGRint                 option = 2, u_num_poles, v_num_poles;
  GRobjid                newobjid ;
  struct GRpost_info     post_info ;
  struct IGRbsp_surface *bsp0 = NULL, *srf_ptr0 = NULL;

  __enterFunction ( name = "VDReparameterizeSrf" , argfmt = "surfs = [%d,%d]", args =
                    `surfs[0].located_obj.osnum, surfs[0].located_obj.objid` ) ;

  sts = om$send( msg = message GRvg.GRgenabsg ( msg,
                                                &surfs[0].module_info.md_env.matrix_type,
                                                 surfs[0].module_info.md_env.matrix,
                                                (IGRchar **) &bsp0 ),
                 senderid = NULL_OBJID,
                 targetid = surfs[0].located_obj.objid,
                 targetos = surfs[0].located_obj.osnum);
  if ( ! ( 1 & sts & *msg ) )
    goto wrapup;

  u_num_poles = (bsp0->u_num_poles - bsp0->u_order) * (bsp0->u_order - 1) + bsp0->u_order;
  v_num_poles = (bsp0->v_num_poles - bsp0->v_order) * (bsp0->v_order - 1) + bsp0->v_order;

  BSallocsf( bsp0->u_order,
             bsp0->v_order,
             u_num_poles,
             v_num_poles,
             bsp0->rational,
             bsp0->num_boundaries,
            &srf_ptr0,
            &bsRC ) ;
  __printf("BSallocsf(): bsRC = %d, srf_ptr0 = %#x, u_num_poles = %d, v_num_poles = %d", `bsRC, srf_ptr0, u_num_poles, v_num_poles` );
  if( BSERROR( bsRC ) )
  {
    sts = MSFAIL;
    goto wrapup ;
  }

  option = 2 ;

  // Increase knot multiplicity to (order - 1) in u and v direction
  BSsfincktm ( bsp0, option, srf_ptr0, &bsRC );
  if( BSERROR( bsRC ) )
  {
    sts = MSFAIL;
    goto wrapup ;
  }

  // Reparameterize knot vectors in u and v direction
  BSarclnpars ( &bsRC, option, srf_ptr0 );
  if( BSERROR( bsRC ) )
  {
    sts = MSFAIL;
    goto wrapup ;
  }

//    if ( VDcomment )
//    {
//      BSprtbspsf ( srf_ptr0 );
//    }

  sts = om$send( msg = message GRvg.GRpostabsg( msg,
                                               &surfs[0].module_info,
                                               &post_info,
                                                (IGRchar *) srf_ptr0,
                                               &newobjid ),
                 senderid = NULL_OBJID,
                 targetid = surfs[0].located_obj.objid,
                 targetos = surfs[0].located_obj.osnum);
  if( ! ( sts & *msg & 1 ) )
  {
    goto wrapup ;
  }

wrapup:

  if (srf_ptr0)
  {
    BSfreesf (&bsRC, srf_ptr0) ;
  }

  __exitFunction ( name = "VDReparameterizeSrf", argfmt = "sts = %d, *msg = %d", args = `sts, *msg` );

  return sts;
}

/*
	-------------------------------------------------------------------
	sts = IntTwoSrf() :
	-----------------
	Intersect two elements (general surfaces or curves).

	Function used by the PPL macros crv_pro_v.u, and int_2_ele.u (from
	version including associative expressions).
	This function calls the function BuildCompCrv() defined here.
									JLL
	-------------------------------------------------------------------
 */

int IntTwoSrf( TrimOption, AppOption, BaseSrf, PjSrf, cst, NbInt, IntSol, msg )

  IGRboolean		TrimOption ; /* I */ /* 0 if no trim          */
  IGRboolean		AppOption  ; /* I */ /* 0 if no approximation */
  struct GRlc_info 	*BaseSrf   ; /* I */ /* First surface  */
  struct GRlc_info	*PjSrf     ; /* I */ /* Second Surface */
  struct GRvg_construct	*cst       ; /* I */
  IGRint		*NbInt     ; /* O */ /* Number of intersection*/
  struct GRid		*IntSol    ; /* O */ /* Array of solutions    */
  IGRlong		*msg       ; /* O */

{
  unsigned short 	trimming_options ;
  struct GRid		*GRint, CompOut ;
  IGRint		num_inter ;
  IGRint		i ;
  IGRlong		stat ;
  OMuword		grgrp_cl, obj_cl, compcrv_cl, str_cl ;
  struct GRlc_info      surfs[2] ;
  extern int		EMintersect_two_element() ;
  extern int		GRdisplay_object() ;

  int                   TR179901421 = 0, two_ruled = 0;

  IGRboolean save_pathway_orient = _pathway_orient, save_pathway_trim = _pathway_trim, retryFlag = FALSE;

//    if ( VDcomment )
//    {
//      AppOption = TrimOption = _pathway_orient = _pathway_trim = save_pathway_orient = save_pathway_trim = 0;
//    }

  __enterFunction ( name = "IntTwoSrf", argfmt = "AppOption = %d, TrimOption = %d", args = `AppOption, TrimOption` );

#ifdef DEBUG
  printf("\nCall to IntTwoSrf() \n") ;
#endif

  GRint	= NULL;

  surfs[0] = BaseSrf[0];
  surfs[1] = PjSrf[0];

  __printf("surfs[0] = [%d,%d], surfs[1] = [%d,%d]",
           `surfs[0].located_obj.osnum, surfs[0].located_obj.objid, surfs[1].located_obj.osnum, surfs[1].located_obj.objid` ) ;

  if ( VDcomment )
  {
    char             dbnam[256];
    OMuword          obj0_cl, obj1_cl;
    struct GRobj_env obj0_id, obj1_id, crv_id;

    obj0_id.obj_id.osnum = surfs[0].located_obj.osnum;
    obj0_id.obj_id.objid = surfs[0].located_obj.objid;
    obj0_id.mod_env      = surfs[0].module_info;

    obj1_id.obj_id.osnum = surfs[1].located_obj.osnum;
    obj1_id.obj_id.objid = surfs[1].located_obj.objid;
    obj1_id.mod_env      = surfs[1].module_info;

    om$get_classid( objid     =  obj0_id.obj_id.objid,
                    osnum     =  obj0_id.obj_id.osnum,
                    p_classid = &obj0_cl);
    om$get_classid( objid     =  obj1_id.obj_id.objid,
                    osnum     =  obj1_id.obj_id.osnum,
                    p_classid = &obj1_cl);

    if( om$is_ancestry_valid( superclassid = OPP_EMSsurface_class_id,
                              subclassid   = obj0_cl ) == OM_S_SUCCESS )
    {
      if( om$is_ancestry_valid( superclassid = OPP_EMSsolid_class_id,
                                subclassid   = obj0_cl ) != OM_S_SUCCESS )
      {
        sprintf(dbnam,"surf0_%d.txt", obj0_id.obj_id.objid);
        VDdumpSurface ( &obj0_id, NULL, dbnam );
      }
    }
    else
    {
      sprintf(dbnam,"curv0_%d.txt", obj0_id.obj_id.objid);
      VDdumpCurve ( &obj0_id, NULL, dbnam );
    }

    if( om$is_ancestry_valid( superclassid = OPP_EMSsurface_class_id,
                              subclassid   = obj1_cl ) == OM_S_SUCCESS )
    {
      if( om$is_ancestry_valid( superclassid = OPP_EMSsolid_class_id,
                                subclassid   = obj1_cl ) != OM_S_SUCCESS )
      {
        sprintf(dbnam,"surf1_%d.txt", obj1_id.obj_id.objid);
        VDdumpSurface ( &obj1_id, NULL, dbnam );
      }
    }
    else
    {
      sprintf(dbnam,"curv1_%d.txt", obj1_id.obj_id.objid);
      VDdumpCurve ( &obj1_id, NULL, dbnam );
    }
  }

try_again:  // retry without _pathway_orient flag if this fails

  if( TrimOption == TRUE )
  {
    trimming_options = EMSINT_TRIM_HANDLESTOP |
                       EMSINT_TRIM_OUTPUT     |
                       EMSINT_TRIM_BDRYISAREA |
                       EMSINT_TRIM_COPLANAR   |
                       EMSINT_TRIM_PROCOVERLAP;

    if( ! retryFlag )
    {
      _pathway_orient = _pathway_trim = 1;	// HF: 01/09/98 Forcing EMS's _Pathway_ code to be used ?!?!??!?
    }
    else
    {
      _pathway_orient = save_pathway_orient;
      _pathway_trim = save_pathway_trim;
    }
  }
  else
    trimming_options = FALSE;

#ifdef DEBUG
  __DBGpr_grid("BaseSrf =",&BaseSrf->located_obj);
  __DBGpr_grid("PjSrf =",&PjSrf->located_obj);
#endif

  // HF: 04/19/2000 Kludge for TR 179901421
  // Performing a reduce_data on the two ruled_surfaces before intersecting seems to work better ...
  // Another option is, to reparameterize the two surfaces (but curve has a lot more poles) ...
  // The safest solution seems to be to do a reduce_data first and then reparameterize ...

  if ( TR179901421 )
  {
    two_ruled = VD_TR179901421 ( msg, surfs );
  }
  if ( two_ruled )
  {
    IGRlong   msg_loc, sts;
    IGRdouble tol, cht, cht_sav, bastol;

    BSEXTRACTPAR(&msg_loc, BSTOLLENVEC, bastol);
    BSEXTRACTPAR(&msg_loc, BSTOLCHRDHT, cht);

    cht_sav   = cht;
    cht      *= 1.0;    // Another KLUDGE would be to INCREASE tolerance cht by a factor of 2 (or 5) ...

    sts = BSchangepar(&msg_loc, BSTOLCHRDHT, cht);

    stat = EMintersect_two_element ( BaseSrf, PjSrf,
                                     trimming_options, cst,
                                     &num_inter, &GRint, msg);
    as$status(sts = stat) ;

    sts = BSchangepar(&msg_loc, BSTOLCHRDHT, cht_sav);
  }
  else
  {
    stat = EMintersect_two_element ( BaseSrf, PjSrf,
                                     trimming_options, cst,
                                     &num_inter, &GRint, msg);
    as$status(sts = stat);
  }

  // Ignore status if an intersection was made
  // TR179801038 - Get errors on "knuckled" surfaces
  if (num_inter > 0)
  {
    stat = OM_S_SUCCESS;
    *msg = MSSUCC;
  }

#ifdef DEBUG
  printf("num_inter is %d \n", num_inter) ;
#endif

  __printf("LINE = %d, stat = %d, *msg = %d, num_inter is %d", `__LINE__, stat, *msg, num_inter` ) ;

  if( num_inter == 0 || !(stat & *msg & 1) )
  {
    if( GRint != NULL ) free(GRint);

    stat = EMintersect_two_element ( PjSrf, BaseSrf,		// Swapped Surfaces
                                     trimming_options, cst,
                                     &num_inter, &GRint, msg) ;
    as$status(sts = stat) ;

    // Ignore status if an intersection was made
    // TR179801038
    if (num_inter > 0)
    {
      stat = OM_S_SUCCESS;
      *msg = MSSUCC;
    }

#ifdef DEBUG
    printf("num_inter is %d \n", num_inter) ;
#endif

    __printf("LINE = %d, stat = %d, *msg = %d, num_inter = %d", `__LINE__, stat, *msg, num_inter` ) ;
  }

  _pathway_orient = save_pathway_orient;	// Reset to saved value
  _pathway_trim   = save_pathway_trim;		// Reset to saved value

// HF: 07/17/2000 Retracting fix of 06/17/2000 (causing regressions)
//    if(( num_inter == 0 ) && (TrimOption) && (!retryFlag))
//    {
//      retryFlag = TRUE;
//      goto try_again ;
//    }
//    if(( num_inter == 0 ) && (!TrimOption))goto wrapup ;
//    if(( num_inter == 0 ) && (retryFlag))  goto wrapup ;

  if( num_inter == 0 ) goto wrapup ;
  if( !(stat & *msg & 1))
  {
#ifdef DEBUG
    printf("Error in EMintersect_two_element() \n") ;
#endif
    goto wrapup ;
  }

  *NbInt = num_inter;

#ifdef DEBUG
  for(i=0;i<num_inter;i=i+1)
  {
    __DBGpr_grid("GRint =",&GRint[i]);
    /*
      gr$display_object( object_id = (struct GRid *) &GRint[i]),
      mode      = GRbd	);
    */
  }
#endif

  /* --- check if the result is a graphics group --- */

  om$get_classid( classname = "GRgrgrp", p_classid = &grgrp_cl);

  om$get_classid( objid     = GRint[0].objid,
                  osnum     = GRint[0].osnum,
                  p_classid = &obj_cl	) ;

  __printf ("OPP_GRgrgrp_class_id = %d, grgrp_cl = %d, obj_cl = %d, *NbInt = %d", `OPP_GRgrgrp_class_id, grgrp_cl, obj_cl, *NbInt` );

  if( om$is_ancestry_valid( superclassid = grgrp_cl,
                            subclassid   = obj_cl ) == OM_S_SUCCESS )
  {
    stat = om$send( msg = message GRowner.GRget_number_components( msg,
                                                                   NbInt ),
                    senderid = NULL_OBJID,
                    targetid = GRint[0].objid,
                    targetos = GRint[0].osnum ) ;
    as$status(sts = stat) ;

    __printf("GRowner.GRget_number_components() : stat = %d, *msg = %d, *NbInt is %d", `stat, *msg, *NbInt` ) ;

    if( !(*msg & stat & 1) ) goto wrapup ;

#define MAX_FEET	100
    // HF: 07/07/99 If (*NbInt > MAX_FEET), divide cht by 10 and try again !!!

    if ( *NbInt > MAX_FEET )
    {
      int       NbInt_sav = *NbInt;
      IGRlong   msg_loc, sts;
      IGRdouble tol, cht, cht_sav, bastol;

      BSEXTRACTPAR(&msg_loc, BSTOLLENVEC, bastol);
      BSEXTRACTPAR(&msg_loc, BSTOLCHRDHT, cht);

      cht_sav   = cht;
      cht      /= 10.0;

      if( GRint != NULL ) free(GRint);

      sts = BSchangepar(&msg_loc, BSTOLCHRDHT, cht);

      stat = EMintersect_two_element(BaseSrf, PjSrf,
                                     trimming_options, cst,
                                     &num_inter, &GRint, msg) ;
      as$status(sts = stat) ;

      sts = BSchangepar(&msg_loc, BSTOLCHRDHT, cht_sav);

      // Ignore status if an intersection was made
      // TR179801038
      if (num_inter > 0)
      {
        stat = OM_S_SUCCESS;
        *msg = MSSUCC;
      }

      __printf("LINE = %d, stat = %d, *msg = %d, num_inter = %d, NbInt_sav = %d, bastol = %lg, cht_sav = %lg, cht = %lg",
               `__LINE__, stat, *msg, num_inter, NbInt_sav, bastol, cht_sav, cht` ) ;

      om$get_classid( objid     = GRint[0].objid,
                      osnum     = GRint[0].osnum,
                      p_classid = &obj_cl	) ;

      __printf ("OPP_GRgrgrp_class_id = %d, grgrp_cl = %d, obj_cl = %d, *NbInt = ", `OPP_GRgrgrp_class_id, grgrp_cl, obj_cl, *NbInt` );

      if( om$is_ancestry_valid( superclassid = grgrp_cl,
                                subclassid   = obj_cl ) == OM_S_SUCCESS )
      {
        stat = om$send( msg = message GRowner.GRget_number_components( msg, NbInt ),
                        senderid = NULL_OBJID,
                        targetid = GRint[0].objid,
                        targetos = GRint[0].osnum ) ;
        as$status(sts = stat) ;

        __printf("GRowner.GRget_number_components() : stat = %d, *msg = %d, *NbInt is %d", `stat, *msg, *NbInt` ) ;

        if( !(*msg & stat & 1) ) goto wrapup ;

        stat = om$send( msg = message GRowner.GRget_components( msg,
                                                                cst->env_info,
                                                                IntSol,
                                                                (*NbInt),
                                                                &i,
                                                                (IGRint) 0,
                                                                OM_K_MAXINT ),
                        senderid = NULL_OBJID,
                        targetid = GRint[0].objid,
                        targetos = GRint[0].osnum );
        as$status(sts = stat) ;

        __printf("GRowner.GRget_components() : stat = %d, *msg = %d", `stat, *msg` ) ;

        if( !(*msg & stat & 1) ) goto wrapup ;

        stat = om$send( msg = message GRowner.GRdrop( msg,
                                                      cst->env_info),
                        senderid = NULL_OBJID,
                        targetid = GRint[0].objid,
                        targetos = GRint[0].osnum );
        as$status(sts = stat) ;
        if( !(*msg&stat&1) ) goto wrapup;
      }
      else
      {
        *NbInt = num_inter;
        for(i=0;i < (*NbInt); i++)
          IntSol[i] = GRint[i];
      }
      goto STEP_OUT;
    }	////////////////////// HF: 07/07/99 If (*NbInt > MAX_FEET) //////////////////////

    stat = om$send( msg = message GRowner.GRget_components( msg,
                                                            cst->env_info,
                                                            IntSol,
                                                            (*NbInt),
                                                            &i,
                                                            (IGRint) 0,
                                                            OM_K_MAXINT ),
                    senderid = NULL_OBJID,
                    targetid = GRint[0].objid,
                    targetos = GRint[0].osnum );
    as$status(sts = stat) ;

    __printf("GRowner.GRget_components() : stat = %d, *msg = %d", `stat, *msg` ) ;

    if( !(*msg & stat & 1) ) goto wrapup ;

    stat = om$send( msg = message GRowner.GRdrop( msg,
                                                  cst->env_info),
                    senderid = NULL_OBJID,
                    targetid = GRint[0].objid,
                    targetos = GRint[0].osnum );
    as$status(sts = stat) ;
    if( !(*msg&stat&1) ) goto wrapup;
  }
  else
  {
    *NbInt = num_inter;
    for(i=0;i<(*NbInt);i=i+1) IntSol[i] = GRint[i];
  }

STEP_OUT:

#ifdef DEBUG
  for(i=0;i<(*NbInt);i=i+1)
  {
    __DBGpr_grid("IntSol =",&IntSol[i]);
  }
#endif

  if ( VDcomment )
  {
    char             dbnam[256];
    struct GRobj_env crv_id;

    for(i=0; i< *NbInt; i++)
    {
      __printf ("IntSol[%d] = [%d,%d]",`i, IntSol[i].osnum, IntSol[i].objid`);

      crv_id.obj_id  = IntSol[i];
      crv_id.mod_env = surfs[0].module_info;

      if ( i == 0 )
      {
        sprintf(dbnam,"crv0_%d_%d.txt", surfs[0].located_obj.objid, surfs[1].located_obj.objid);
        VDdumpCurve ( &crv_id, NULL, dbnam );
      }
      if ( i == 1 )
      {
        sprintf(dbnam,"crv1_%d_%d.txt", surfs[0].located_obj.objid, surfs[1].located_obj.objid);
        VDdumpCurve ( &crv_id, NULL, dbnam );
      }
    }
  }

  if( AppOption == TRUE )
  {
    om$get_classid( classname = "GRcompcurve", p_classid = &compcrv_cl);
    om$get_classid( classname = "GR3dlinestr", p_classid = &str_cl);

    __printf ("OPP_GRcompcurve_class_id = %d, compcrv_cl = %d", `OPP_GRcompcurve_class_id, compcrv_cl` );
    __printf ("OPP_GR3dlinestr_class_id = %d, str_cl     = %d", `OPP_GR3dlinestr_class_id, str_cl` );

    for(i=0; i < (*NbInt); i=i+1)
    {
      om$get_classid( objid     = IntSol[i].objid,
                      osnum     = IntSol[i].osnum,
                      p_classid = &obj_cl	) ;

      if( om$is_ancestry_valid( superclassid = compcrv_cl,
                                subclassid   = obj_cl ) == OM_S_SUCCESS )
      {
        BuildCompCrv ( TRUE, &IntSol[i], &CompOut, str_cl, cst, surfs, msg);
        IntSol[i] = CompOut;
      }
      else if(om$is_ancestry_valid( superclassid = str_cl,
                                    subclassid   = obj_cl ) == OM_S_SUCCESS )
      {
        BuildCompCrv ( FALSE, &IntSol[i], &CompOut, str_cl, cst, surfs, msg);
        IntSol[i] = CompOut;
      }
    }
  }

  if( GRint != NULL ) free(GRint);
  *msg = MSSUCC;

//    if ( VDcomment )
//    {
//      enum GRdpmode mode = GRbdhd;
//      IGRint        sts, i0;
//      struct IGRbsp_surface *bsp = NULL;
//
//      if ( *NbInt >= 100 && (( surfs[0].located_obj.objid == 490 && surfs[0].located_obj.osnum == 12 ) ||
//                                ( surfs[1].located_obj.objid == 490 && surfs[1].located_obj.osnum == 12 )))
//      {
//        fflush ( NULL );
//
//        for (i0=0; i0 < 2; i0++)
//        {
//          sts = om$send(  msg      = message GRgraphics.GRdisplay ( msg,
//                                                                    &surfs[i0].module_info.md_env.matrix_type,
//                                                                     surfs[i0].module_info.md_env.matrix,
//                                                                    &mode,
//                                                                    &surfs[i0].module_info.md_id ),
//                          senderid = NULL_OBJID,
//                          targetid = surfs[i0].located_obj.objid,
//                          targetos = surfs[i0].located_obj.osnum );
//        }
//
//        sts = om$send( msg = message GRvg.GRgenabsg ( msg,
//                                                      &surfs[0].module_info.md_env.matrix_type,
//                                                       surfs[0].module_info.md_env.matrix,
//                                                      (IGRchar **) &bsp ),
//                       senderid = NULL_OBJID,
//                       targetid = surfs[0].located_obj.objid,
//                       targetos = surfs[0].located_obj.osnum) ;
//        BSprtbspsf ( bsp );
//
//        sts = om$send( msg = message GRvg.GRgenabsg ( msg,
//                                                      &surfs[1].module_info.md_env.matrix_type,
//                                                       surfs[1].module_info.md_env.matrix,
//                                                      (IGRchar **) &bsp ),
//                       senderid = NULL_OBJID,
//                       targetid = surfs[1].located_obj.objid,
//                       targetos = surfs[1].located_obj.osnum) ;
//        BSprtbspsf ( bsp );
//      }
//    }

  __exitFunction ( name = "IntTwoSrf", argfmt = "*NbInt = %d, *msg = %d", args = `*NbInt, *msg` );

  return(MSSUCC);

wrapup:
  if( GRint != NULL )
    free(GRint);
  *NbInt = 0;
  *msg = MSFAIL;

  __exit_error_Function ( name = "IntTwoSrf", argfmt = "*msg = %d", args = `*msg` );

  return(MSFAIL);
} /* IntTwoSrf() */
/* This function is just a wrapper on top of EvalFromTo()
 * We can send the surface range of the neat parent instead of the
 * one with cutouts
 */
EvalFromTo1( srfRange, crv_info, p1, p2, FromTo, msg )

  IGRdouble 		*srfRange;
  struct GRlc_info	*crv_info;
  IGRdouble		*p1;
  IGRdouble		*p2;
  IGRdouble		*FromTo;
  IGRlong		*msg;

{

  IGRint		i, MaxInd, MinInd;
  IGRlong		stat;
  IGRdouble		rng[6], MaxVal, MinVal;
  IGRdouble		utab[16], p1p2[3], PtTab[48];
  IGRdouble             range[48];
  IGRboolean		world ;
  extern IGRint		BSmkvec() ;
  extern IGRdouble 	fabs()    ;

  /* ---  this function :
     . get the range of the original curve to project and the surface.
     . Project this to range on to the line  of projection
       to define the length of the surface of projection
       we will have to build later.
     --- */

#ifdef DEBUG
  printf("Call to EvalFromTo() \n") ;
#endif

  // Init to get rid of warnings
  MinInd = MaxInd = 0;

#ifdef DEBUG
  __DBGpr_double("range of surface =",srfRange,3,6);
#endif

  BSmkvec( msg, p1p2, p1, p2 );

  world = 1 ; /* to apply env matrix */
  stat = om$send( msg = message GRgraphics.GRgetrang( msg,
                                                      &crv_info->module_info.md_env.matrix_type,
                                                       crv_info->module_info.md_env.matrix,
                                                      &world,
                                                      rng ),
                  senderid = NULL_OBJID,
                  targetid = crv_info->located_obj.objid,
                  targetos = crv_info->located_obj.osnum );

  if( !(*msg&stat&1) ) return(MSFAIL) ;

#ifdef DEBUG
  __DBGpr_grid("original crv_info ",&crv_info->located_obj);
  __DBGpr_double("range of curve =",rng,3,6);
#endif

  BuildEightVerFromRange(srfRange,&range[0]);
  
  BuildEightVerFromRange(rng,&range[24]);

  for(i=0;i<48;i+=3)
  {
    
  ProjPtOntoLine( p1, p1p2, &range[i], &utab[i/3], &PtTab[i], msg );
  if( *msg != MSSUCC ) return(MSFAIL);
  }

#ifdef DEBUG
  __DBGpr_double("utab =",utab,4,16);
  __DBGpr_double("PtTab =",PtTab,3,48);
#endif

  /* --- find the min and max index of the min and max parameter --- */

  MaxVal = -1.0E31;
  MinVal =  1.0E31;

  for(i=0;i<16;i=i+1)
  {
    if( utab[i] < MinVal ){ MinVal = utab[i]; MinInd = 3*i;}
    if( utab[i] > MaxVal ){ MaxVal = utab[i]; MaxInd = 3*i;}
  }

#ifdef DEBUG
  __DBGpr_int("MinInd =",&MinInd,1,1);
  __DBGpr_double("MinVal =",&MinVal,1,1);
  __DBGpr_int("MaxInd =",&MaxInd,1,1);
  __DBGpr_double("MaxVal =",&MaxVal,1,1);
#endif

  MaxVal = 1.1 * (MaxVal - MinVal);
  if( fabs(MaxVal) < 0.01 ) MaxVal = 2.0;
  for(i=0;i<3;i=i+1)
  {
    FromTo[i]   = PtTab[MinInd +i] - MaxVal * p1p2[i];
    FromTo[3+i] = PtTab[MinInd +i];
    FromTo[6+i] = PtTab[MinInd +i] + MaxVal * p1p2[i];
  }

#ifdef DEBUG
  __DBGpr_double("FromTo =",FromTo,3,9);
#endif

  *msg = MSSUCC;
  return(MSSUCC);

  // wrapup:	// Never used though it should have been

  // return(MSFAIL);
} /* EvalFromTo1() */

IGRint BuildEightVerFromRange(IGRdouble *range, IGRdouble *rangeEight)
{
  IGRint retFlag = 0,i;
  IGRdouble vector[3];

  for(i=0; i<3; i++)
	vector[i] = range[i+3] - range[i];

  for(i=0; i<24; i+=3) {
	rangeEight[i]  =  range[0];
	rangeEight[i+1] = range[1];
	rangeEight[i+2] = range[2];
  }

  rangeEight[3] += vector[0];  // point 3 
  
  rangeEight[6] += vector[0];   // point 6
  rangeEight[8] += vector[2]; 
  
  rangeEight[11] += vector[2]; // point 9 

  rangeEight[13] += vector[1];  // point 12 
   
  rangeEight[15] += vector[0];  // point 15 
  rangeEight[16] += vector[1]; 
   
  rangeEight[18] += vector[0];  // point 18 
  rangeEight[19] += vector[1]; 
  rangeEight[20] += vector[2]; 
     
  rangeEight[22] += vector[1];  // point 21 
  rangeEight[23] += vector[2]; 



  retFlag = 1;
wrapup:
  return retFlag;
}
end implementation Root;
