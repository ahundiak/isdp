
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:42:01 $
$Locker:  $
*/


#include <stdio.h>

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdp.h"

#include "dpstruct.h"

#include "bs.h"

#include "vedef.h"
#include "ve.h"

/* prototype files */
#include "VEpr_utilfnc.h"

/*---- VEfind_curve_range -------------------------------------------------*/

void VEfind_curve_range( curve, range )

	struct IGRbsp_curve *curve;
	IGRdouble           range[6];

/*
NAME
	VEfind_curve_range

DESCRIPTION
	Determine the range of a curve

PARAMETERS
	curve (IN) - the curve whose range is to be calculated
	range (OUT) - the range of the curve

GLOBALS USED
	none

HISTORY
	01/29/87    S.P. Rogers
	   Creation Date
*/

	{
	register IGRdouble  *poles, *weights;
	IGRint              i;
	IGRdouble           xmin, xmax, ymin, ymax, zmin, zmax;
	IGRdouble           xpole, ypole, zpole;

	poles   = curve->poles;
	weights = curve->weights;
	
	if ( curve->rational )
	   {
	   /* curve is rational ==> unweight poles */
	   xmin = xmax = *poles++ / *weights;
	   ymin = ymax = *poles++ / *weights;
	   zmin = zmax = *poles++ / *weights;
	   
	   weights++;
	   
	   for ( i = 1; i < curve->num_poles; i++ )
	      {
	      xpole = *poles++ / *weights;
	      ypole = *poles++ / *weights;
	      zpole = *poles++ / *weights;

	      weights++;
	      
	      if ( xpole < xmin )
	         xmin = xpole;
	      else if ( xpole > xmax )
	         xmax = xpole;

	      if ( ypole < ymin )
	         ymin = ypole;
	      else if ( ypole > ymax )
	         ymax = ypole;

	      if ( zpole < zmin )
	         zmin = zpole;
	      else if ( zpole > zmax )
	         zmax = zpole;
	      }

	   }  /* end: curve is rational */
	else
	   {
	   /* curve is not rational */
	   xmin = xmax = *poles++;
	   ymin = ymax = *poles++;
	   zmin = zmax = *poles++;

	   for ( i = 1; i < curve->num_poles; i++ )
	      {
	      xpole = *poles++;
	      ypole = *poles++;
	      zpole = *poles++;

	      if ( xpole < xmin )
	         xmin = xpole;
	      else if ( xpole > xmax )
	         xmax = xpole;

	      if ( ypole < ymin )
	         ymin = ypole;
	      else if ( ypole > ymax )
	         ymax = ypole;

	      if ( zpole < zmin )
	         zmin = zpole;
	      else if ( zpole > zmax )
	         zmax = zpole;
	      }

	   }  /* end: curve is not rational */

	range[XMIN] = xmin;
	range[YMIN] = ymin;
	range[ZMIN] = zmin;
	range[XMAX] = xmax;
	range[YMAX] = ymax;
	range[ZMAX] = zmax;

	}  /* VEfind_curve_range */


/*---- VEupdate_element_range ------------------------------------------*/

void VEupdate_element_range( struct VEelement_header *element,
			     IGRboolean              was_clipped,
			     IGRboolean              missing_link )

/*
NAME
	VEupdate_element_range

DESCRIPTION
	Reset an element's range by using the combined ranges of 
	its edges and possibly the clipping volume.

PARAMETERS
	element (IN) - the element whose range is to be updated
	was_clipped (IN) - TRUE, if some edges of the element were clipped
	missing_link (IN) - TRUE, if some of the corresponding shared edges
	                    for the element were missing
	
GLOBALS USED
	none

HISTORY
	08/11/87   S.A. Rapa
	   Creation Date
*/

	{
	IGRint               i;
	IGRdouble	     new_range[6];
	IGRdouble            *elem_range;
	IGRdouble            *edge_range;
	struct VEedge_header *this_edge;
	struct VEplane       *clip_planes;

	elem_range = element->range;

	if ( element->edges )
	   {
	   edge_range = element->edges->range;
	   this_edge = element->edges->next;

	   /* find the range box of the edges */
	   for ( i = 0; i < 6; i++ )
	      new_range[i] = edge_range[i];

	   while ( this_edge )
	      {
	      edge_range = this_edge->range;
	      if ( new_range[XMIN] > edge_range[XMIN] )
	         new_range[XMIN] = edge_range[XMIN];

	      if ( new_range[YMIN] > edge_range[YMIN] )
	         new_range[YMIN] = edge_range[YMIN];

	      if ( new_range[ZMIN] > edge_range[ZMIN] )
	         new_range[ZMIN] = edge_range[ZMIN];

	      if ( new_range[XMAX] < edge_range[XMAX] )
	         new_range[XMAX] = edge_range[XMAX];

	      if ( new_range[YMAX] < edge_range[YMAX] )
	         new_range[YMAX] = edge_range[YMAX];

	      if ( new_range[ZMAX] < edge_range[ZMAX] )
	         new_range[ZMAX] = edge_range[ZMAX];

	      this_edge = this_edge->next;
	      }

	   if ( was_clipped || missing_link )
	      {
	      /* the element had at least one edge clipped OR a real       */
	      /* edge corresponding to a dummy edge on this element        */
	      /* was not found (i.e., the real edge was clipped out)       */
	      /* => if the element's range extened outside of its clipping */
	      /* volume, only adjust it to the edges of the clipping       */
	      /* volume.                                                   */
	      clip_planes = element->env->clip_planes;
	      if ( elem_range[XMIN] < clip_planes[XMIN].point[0] )
	         elem_range[XMIN] = clip_planes[XMIN].point[0];
	      else if ( new_range[XMIN] > elem_range[XMIN] )
	         elem_range[XMIN] = new_range[XMIN];

	      if ( elem_range[YMIN] < clip_planes[YMIN].point[1] )
	         elem_range[YMIN] = clip_planes[YMIN].point[1];
	      else if ( new_range[YMIN] > elem_range[YMIN] )
	         elem_range[YMIN] = new_range[YMIN];

	      if ( elem_range[ZMIN] < clip_planes[ZMIN].point[2] )
	         elem_range[ZMIN] = clip_planes[ZMIN].point[2];
	      else if ( new_range[ZMIN] > elem_range[ZMIN] )
	         elem_range[ZMIN] = new_range[ZMIN];

	      if ( elem_range[XMAX] > clip_planes[XMAX].point[0] )
	         elem_range[XMAX] = clip_planes[XMAX].point[0];
	      else if ( new_range[XMAX] < elem_range[XMAX] )
	         elem_range[XMAX] = new_range[XMAX];

	      if ( elem_range[YMAX] > clip_planes[YMAX].point[1] )
	         elem_range[YMAX] = clip_planes[YMAX].point[1];
	      else if ( new_range[YMAX] < elem_range[YMAX] )
	         elem_range[YMAX] = new_range[YMAX];

	      if ( elem_range[ZMAX] > clip_planes[ZMAX].point[2] )
	         elem_range[ZMAX] = clip_planes[ZMAX].point[2];
	      else if ( new_range[ZMAX] < elem_range[ZMAX] )
	         elem_range[ZMAX] = new_range[ZMAX];

	      }  /* end: if */
	   else
	      {
	      /* update the range of the element with the range of its edges */
	      if ( new_range[XMIN] > elem_range[XMIN] )
	         elem_range[XMIN] = new_range[XMIN];

	      if ( new_range[YMIN] > elem_range[YMIN] )
	         elem_range[YMIN] = new_range[YMIN];

	      if ( new_range[ZMIN] > elem_range[ZMIN] )
	         elem_range[ZMIN] = new_range[ZMIN];

	      if ( new_range[XMAX] < elem_range[XMAX] )
	         elem_range[XMAX] = new_range[XMAX];

	      if ( new_range[YMAX] < elem_range[YMAX] )
	         elem_range[YMAX] = new_range[YMAX];

	      if ( new_range[ZMAX] < elem_range[ZMAX] )
	         elem_range[ZMAX] = new_range[ZMAX];
	      }

	   }  /* end: if ( element->edges ) */
	else
	   {
	   /* the element has no edges => force its range to be the    */
	   /* range of its clipping volume if it extends outside of it */
	   clip_planes = element->env->clip_planes;
	   if ( elem_range[XMIN] < clip_planes[XMIN].point[0] )
	      elem_range[XMIN] = clip_planes[XMIN].point[0];

	   if ( elem_range[YMIN] < clip_planes[YMIN].point[1] )
	      elem_range[YMIN] = clip_planes[YMIN].point[1];

	   if ( elem_range[ZMIN] < clip_planes[ZMIN].point[2] )
	      elem_range[ZMIN] = clip_planes[ZMIN].point[2];

	   if ( elem_range[XMAX] > clip_planes[XMAX].point[0] )
	      elem_range[XMAX] = clip_planes[XMAX].point[0];

	   if ( elem_range[YMAX] > clip_planes[YMAX].point[1] )
	      elem_range[YMAX] = clip_planes[YMAX].point[1];

	   if ( elem_range[ZMAX] > clip_planes[ZMAX].point[2] )
	      elem_range[ZMAX] = clip_planes[ZMAX].point[2];

	   }

	}  /* VEupdate_element_range */
