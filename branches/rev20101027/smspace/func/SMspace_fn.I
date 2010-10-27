/* $Id: SMspace_fn.I,v 1.1.1.1 2001/01/04 21:07:37 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smspace/func / SMspace_fn.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMspace_fn.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:37  cvs
 *	Initial import to CVS
 *	
# Revision 1.2  1998/10/14  15:41:36  pinnacle
# Replaced: smspace/func/SMspace_fn.I for:  by impd251 for vds
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.3  1998/04/10  14:45:16  pinnacle
# Replaced: smspace/func/SMspace_fn.I for:  by impd for vds
#
# Revision 1.2  1998/02/27  19:10:04  pinnacle
# Replaced: smspace/func/SMspace_fn.I for:  by impd for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.2  1996/04/29  09:14:08  pinnacle
# Replaced: smspace/func/SMspace_fn.I for:  by ksundar for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	10/14/98	HF		Fix for TR 179801486
 * -------------------------------------------------------------------*/

/*

     PL       22 NOV 1991  : Design date

ABSTRACT :

	Implements Functions used for the space management product.
	- 1/ 	SMexploration
	- 2/ 	SMIsIndexInArray
	- 3/ 	SMInitmark
	- 4/ 	SMTestEnd
	- 5/  	SMGraphDescr
	- 6/  	SMIsGraphExist
	- 7/  	SMFillNextInGraph
	- 8/  	SMFindPtInGraph
	- 11/  	SMGetLoopInGraph
	- 12/  	SMMarkExist
	- 13/  	SMGetNbCurves
	- 14/   SMGetNbIntPts
	- 15/ 	SMSortCvIntpts
	- 16/ 	SMorder_pt_on_cv
	- 17/	SMGetMaxSfLoop
	- 18/	SMCreatCompCv
	- 19/ 	SMSortSfIntCvs
	- 20/ 	SMGetNbSurfs
	- 21/ 	SMGetCommonIndex
	- 22/ 	SMGetOrderSfLoop
	- 23/ 	SMGetMaxSfVol
	- 24/ 	SMGetSfInLoop
	- 25/ 	SMCrtPartCvs
	- 26/	SMGetSfintpt
	- 27/	SMChgInters
	- 28/   SMFillSfGeom
	- 29/	SMFreeSfGeom
*/

class implementation Root;

#include <stdio.h>
#include <string.h>
#include <math.h>

#include "igrtypedef.h"
#include "igetypedef.h"
#include "ex.h"
#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "grerr.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "msdef.h"
#include "EMSssprops.h"
#include "EMSmsgdef.h"
#include "EMS.h"
#include "EMSopt.h"

#include "SMgraph.h"
#include "VDSutil_def.h"

#include "macro.h"

#include "AS_status.h"
#include "VDmem.h"

#include "bstypes.h"
#include "bserr.h"

/* include prototype */

#include "bstagsort.h"
#include "bstagsorti.h"
#include "bsalloccv.h"
#include "bsfreecv.h"
#include "bspartofcv.h"
#include "bsrev_cv.h"
#include "bstrpsfiter.h"
#include "bsmdstptcv.h"
#include "bsbx2.h"
#include "bsplptnorrg.h"
#include "bsmdistptsf.h"

#define   AS_DEBUG 	1
/* #define   DEBUG 	1 */

#define VD_DEBUG

#include "VDdebug.h"

from GRbcsubbc		import GRconstruct;
from GRgraphics		import GRdelete;
from GRvg       	import GRgetsize, GRgetgeom, GRdetplane, GRprojpt;
from EMSsubbs  		import EMpartolbasis,EMtangent_normal, EMget_props;
from GRcompcurve	import EMaddtocomp, EMmakecomp;
from ASnode		import ASreturn_go;

extern GRclassid	OPP_EMSplane_class_id, OPP_EMSsurface_class_id,
			OPP_GRcurve_class_id,OPP_EMScompsurf_class_id,
			OPP_EMSsubbs_class_id,OPP_EMSsfimpbnd_class_id,
			OPP_EMSproject_class_id,OPP_GRbcsubbc_class_id,
			OPP_EMSsfboolean_class_id, OPP_GRgrgrp_class_id,
			OPP_EMSsfstitch_class_id,OPP_GRcompcurve_class_id;

/*1 ====================== SMexploration =====================

	Given a graph, the function looks for a loop
	beginning at "depart" (recursive algorithm based on
	possible neighbours of the element).
	The function sets some marks on the elements that are taken,
	so that the other loops beginning at "depart" can be returned
	at the next call of the function.

	always return(1) .

*/

int	SMexploration(graphe,depart,SMinters,current_index,index_chemin,chemin,
		    nb_mark, mark)

struct gr_arc 	*graphe; 	/* (I/O) input graph (mark is modified) */
int 		depart; 	/* (I) depart index for the loop */
struct SMinters	*SMinters;	/* (I) def of intersection pts */
int 		current_index;  /* (I)  first elt to fill in chemin at
					index_chemin*/
int 		*index_chemin;  /* (I/O) I = first index to fill
					 O = nb of elt returned in chemin */
int 		*chemin;	/* (I/O) O = loop returned I = previous loop */
int		*nb_mark; 	/* (I/O) nb of mark (chemin already taken) */
struct mark	*mark;		/* (I) mark ((chemin already taken) */

/*.SMexploration */
{
  struct gr_arc 	*list;
  int		next_index, act_index;

  act_index = current_index;
  chemin[*index_chemin] = act_index;
  *index_chemin = *index_chemin + 1;
  list = &graphe[act_index];

  while( SMTestEnd(graphe, chemin, *index_chemin, (*list), SMinters ) == 0)
  {
    if(*index_chemin <= 0 ) break;

    if(list->next_taken < list->nb_next)
    {
      next_index = list->next[list->next_taken];
      list->next_taken ++;
    }
    else
    {
      *index_chemin = *index_chemin - 1;
      SMInitmark(&graphe[act_index]);
      if(*index_chemin <= 0) break;
      act_index = chemin[*index_chemin-1];
      list = &graphe[act_index];
      continue;
    }
    if( SMIsIndexInArray(graphe, next_index, chemin,
			 *index_chemin, mark, *nb_mark, SMinters ) == 0)
    {
      SMexploration(graphe,depart,SMinters,next_index,
		    index_chemin, chemin,  nb_mark, mark);
      break;
    }
  }

  return(1);
}

/*2 ====================== SMIsIndexInArray ======================

	The function detects if the given index can be put in
 	the array defining the loop:
		. The element must not already be in the array
		unless if it is the depart index (loop definition).
		. The element must not be taken if it creates with
		the previous element a combination already taken.
		(mark on arc to avoid duplicate loops)

	return(1) if the element cannot be taken.
	else return(0).
*/
int	SMIsIndexInArray(graphe, index,array,nb_array, mark, nb_mark, SMinters)
struct gr_arc 	*graphe; /* (I) input graph */
int 		index;   /* (I) index to be tested */
int		*array;  /* (I) array of index already taken */
int		nb_array;/* (I) nb_elt in array */
struct mark	*mark;   /* (I) array of mark on graph elt */
int		nb_mark; /* (I) nb_elt in mark array */
struct SMinters	*SMinters;	/* (I) def of intersection pts */

/*.SMIsIndexInArray*/
{
  int	i;

  if(nb_mark > 0 && nb_array > 0)
  {
    for(i=0;i<nb_mark;i++)
    {
      if(SMIsEqualPt(graphe[array[nb_array-1]].pt,mark[i].pt1,SMinters) &&
	 SMIsEqualPt(graphe[index].pt,mark[i].pt2,SMinters) &&
	 graphe[index].cv == mark[i].curve &&
	 graphe[index].part_nb == mark[i].part_nb) return(1);
      if(SMIsEqualPt(graphe[array[nb_array-1]].pt,mark[i].pt2,SMinters) &&
	 SMIsEqualPt(graphe[index].pt,mark[i].pt1,SMinters) &&
	 graphe[index].cv == mark[i].curve &&
	 graphe[index].part_nb == mark[i].part_nb) return(1);
    }
  }
  for(i=0;i<nb_array;i++)
  {
    if((SMIsEqualPt(graphe[index].pt,graphe[array[0]].pt, SMinters)	&&  nb_array > 1 && nb_array != 2) ||
       (SMIsEqualPt(graphe[array[0]].pt,graphe[index].pt,SMinters)	&& nb_array == 2 &&
	(graphe[array[1]].cv != graphe[index].cv || graphe[array[1]].part_nb != graphe[index].part_nb)))
      return(0);

    if(SMIsEqualPt(graphe[array[i]].pt,graphe[index].pt, SMinters))  return(1);
  }

  return(0);
}

/*3 ====================== SMInitmark ======================

	The function init the mark next_taken in the structure
	gr_arc (index of next element to explore).

	always return(1) .

*/
int	SMInitmark(gr_arc)
struct gr_arc *gr_arc; /* (I/O) struct to initialise */
/*.SMInitmark*/
{
  gr_arc->next_taken = 0;
  return(1);
}

/*4 ====================== SMTestEnd ======================

	The function tests if the loop is completed
	(depart == current but without going through the same
	curve as at the beginning).

	return(1) if it is the end.
	else return(0).

*/
int	SMTestEnd(graphe, array, nb_elt, current, SMinters)
struct gr_arc 	*graphe; /* (I) input graph */
int		*array;  /* (I) array of graph elt to test */
int		nb_elt;  /* (I) nb_elt in the array */
struct gr_arc 	current; /* (I) last pt of array (test if equal to depart*/
struct SMinters	*SMinters;/* (I) pts definition */
/*.SMTestEnd*/
{

  if(nb_elt < 1) return 1;

  if(SMIsEqualPt(graphe[array[0]].pt,current.pt, SMinters) &&     nb_elt > 1 && nb_elt != 3)
    return(1);

  if(nb_elt == 3 && SMIsEqualPt(graphe[array[0]].pt,current.pt, SMinters)
     && (graphe[array[1]].cv != current.cv ||
	 graphe[array[1]].part_nb != current.part_nb ) ) return(1);
  else return(0);
}

/*5 ====================== SMGraphDescr ======================

	The function fills the structure on graph elements
	with the info on the intersection pts on curves.
	graph is allocated by the function and must be
	deallocated by the user.
	The graph elements are all the possible couples
	(cv, intpt on cv).

	cv_index is the array of curve index in the SMcurve array
	(for bounded volume the SMcurve are the curves on a surface
	and the index in the SMcurve array is different than the index
	of the input curve) can be NULL if curves are input ones.

	return(1) if ok.
	else return(0).
*/

int	SMGraphDescr(nb_cv, curve, cv_index, SMinters,nb_elt_in_graph, graph)
int		nb_cv;   	  /* (I) nb curves input */
struct SMcurve	*curve;  	  /* (I) array of curves point (ordered )*/
int		*cv_index;	  /* (I) curve index */
struct SMinters	*SMinters;	  /* (I) def of intersection pts */
int		*nb_elt_in_graph; /* (O) nb_elt in graph*/
struct gr_arc 	**graph; 	  /* (O) output graph */
/*.SMGraphDescr*/
{
  int		i,k,l, gr_index, nb_index, next, pts_num, stat, part_nb,  nb_ptcv;
  int		*array, nb_array, before, after;
  int		*tmp_index;
  struct gr_arc	*tmp_graph;

  if(curve == NULL )
  {
    if (OM_Gf_verbose_warning) printf("ERROR Invalid Argument\n");
    return(0);
  }

  array = NULL;
  tmp_graph = NULL;
  if(graph != NULL) (*graph) = NULL;
  tmp_index = NULL;

  pts_num = 0;

  tmp_index = _MALLOC(nb_cv, int);
  if(tmp_index == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR bad allocation \n");
    goto wrapup;
  }

  if(cv_index == NULL)
    for(i=0;i<nb_cv;i++) tmp_index[i] = i;
  else
    for(i=0;i<nb_cv;i++) tmp_index[i] = cv_index[i];

  stat = SMGetNbIntPts(nb_cv, curve, tmp_index, &pts_num, NULL);
  if(stat != 1)
  {
    if (OM_Gf_verbose_warning) printf("ERROR SMGetNbIntPts\n");
    goto wrapup;
  }

  tmp_graph = _MALLOC((3*pts_num+1), struct gr_arc);
  if( tmp_graph == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR bad allocation \n");
    goto wrapup;
  }

  array = NULL;
  array = _MALLOC((3*pts_num+1), int);
  if(array == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR Bad dynamic allocation\n");
    goto wrapup;
  }
  for(i=0;i< (3*pts_num+1); i++)
  {
    SMInitmark(&tmp_graph[i]);
    tmp_graph[i].nb_next = 0;
    tmp_graph[i].part_nb = 0;
  }

  nb_index = 0;
  for(i=0;i< nb_cv; i++)
  {
    part_nb = 0;
    if(curve[tmp_index[i]].cv_geom->phy_closed == TRUE &&
       curve[tmp_index[i]].nb_intpt == 2) part_nb = 1;

    for(k=0;k<curve[tmp_index[i]].nb_intpt;k++)
    {
      if(!SMIsGraphExist(tmp_index[i],
			 curve[tmp_index[i]].pt_index[k],
			 part_nb,
			 tmp_graph,
			 nb_index,
			 &gr_index))
      {
	tmp_graph[nb_index].cv = tmp_index[i];
	tmp_graph[nb_index].pt = curve[tmp_index[i]].pt_index[k];
	tmp_graph[nb_index].nb_next = 0;
	tmp_graph[nb_index].part_nb = 0;
	if(part_nb == 1)
	{
	  tmp_graph[nb_index].part_nb = 1;
	  nb_index ++;
	  tmp_graph[nb_index].cv = tmp_index[i];
	  tmp_graph[nb_index].pt = curve[tmp_index[i]].pt_index[k];
	  tmp_graph[nb_index].nb_next = 0;
	  tmp_graph[nb_index].part_nb = 2;
	  nb_index ++;
	}
	else nb_index ++;

      }
    }
  }

  for(i=0;i< nb_cv; i++)
  {
    nb_ptcv = curve[tmp_index[i]].nb_intpt;
    if(nb_ptcv < 2) continue;
    part_nb = 0;
    if(curve[tmp_index[i]].cv_geom->phy_closed == TRUE &&
       nb_ptcv == 2) part_nb = 1;

    for(k=0;k<nb_ptcv;k++)
    {
      SMFindPtInGraph(tmp_graph, nb_index, curve[tmp_index[i]].pt_index[k],
		      SMinters, &nb_array, array);
      if(k == (nb_ptcv-1) && curve[tmp_index[i]].cv_geom->phy_closed == TRUE)
	after = curve[tmp_index[i]].pt_index[0];
      else if (k == (nb_ptcv-1))
	after = -1;
      else
	after = curve[tmp_index[i]].pt_index[k+1];
      if(k == 0 && curve[tmp_index[i]].cv_geom->phy_closed == TRUE)
	before = curve[tmp_index[i]].pt_index[nb_ptcv-1];
      else if(k == 0)
	before = -1;
      else
	before = curve[tmp_index[i]].pt_index[k-1];

      if(before == after) after = -1;

      for(l=0;l<nb_array;l++)
      {
	/*| fill with next */
	if(after != -1)
	{
	  SMIsGraphExist(tmp_index[i], after, part_nb,
			 tmp_graph,nb_index, &next);
	  if(next == -1)
	  {
	    if (OM_Gf_verbose_warning) printf("ERROR graphe not found\n");
	    goto wrapup;
	  }
	  SMFillNextInGraph(&tmp_graph[array[l]], next);
	}
	/*|fill with previous*/

	if(before != -1)
	{
	  SMIsGraphExist(tmp_index[i], before, part_nb,
			 tmp_graph, nb_index, &next);
	  if(next == -1)
	  {
	    if (OM_Gf_verbose_warning) printf("ERROR graphe not found\n");
	    goto wrapup;
	  }
	  SMFillNextInGraph(&tmp_graph[array[l]], next);
	}
      }
    }
    if(part_nb == 1)
    {
      /* do the same with the second part of the curve */
      part_nb = 2;
      for(k=0;k<nb_ptcv;k++)
      {
	SMFindPtInGraph(tmp_graph, nb_index, curve[tmp_index[i]].pt_index[k],
			SMinters, &nb_array, array);
	if(k == (nb_ptcv-1) && curve[tmp_index[i]].cv_geom->phy_closed == TRUE)
	  after = curve[tmp_index[i]].pt_index[0];
	else if (k == (nb_ptcv-1))
	  after = -1;
	else
	  after = curve[tmp_index[i]].pt_index[k+1];
	if(k == 0 && curve[tmp_index[i]].cv_geom->phy_closed == TRUE)
	  before = curve[tmp_index[i]].pt_index[nb_ptcv-1];
	else if(k == 0)
	  before = -1;
	else
	  before =   curve[tmp_index[i]].pt_index[k-1];

	if(before == after) after = -1;

	for(l=0;l<nb_array;l++)
	{
	  /*| fill with next */
	  if(after != -1)
	  {
	    SMIsGraphExist(tmp_index[i], after, part_nb,
			   tmp_graph,nb_index, &next);
	    if(next == -1)
	    {
	      if (OM_Gf_verbose_warning) printf("ERROR graphe not found\n");
	      goto wrapup;
	    }
	    SMFillNextInGraph(&tmp_graph[array[l]], next);
	  }
	  /*|fill with previous*/

	  if(before != -1)
	  {
	    SMIsGraphExist(tmp_index[i], before, part_nb,
			   tmp_graph, nb_index, &next);
	    if(next == -1)
	    {
	      if (OM_Gf_verbose_warning) printf("ERROR graphe not found\n");
	      goto wrapup;
	    }
	    SMFillNextInGraph(&tmp_graph[array[l]], next);
	  }
	}
      }

    }

  }

  if(nb_elt_in_graph != NULL) *nb_elt_in_graph = nb_index;
  if(graph != NULL && nb_index != 0)
  {
    (*graph) = NULL;
    (*graph) = _MALLOC(nb_index, struct gr_arc);
    if( (*graph) == NULL)
    {
      if (OM_Gf_verbose_warning) printf("ERROR bad allocation \n");
      goto wrapup;
    }
    for(i=0;i<nb_index;i++) (*graph)[i] = tmp_graph[i];
  }

  _FREE(tmp_index);
  _FREE(tmp_graph);
  _FREE(array);
  return(1);

wrapup:
  _FREE(tmp_index);
  if(graph != NULL && (*graph) != NULL)_FREE(*graph);
  _FREE(array);
  _FREE(tmp_graph);
  return(0);
}

/*6 ======================  SMIsGraphExist ======================

	The function determines if the couple (curve, pt, part_nb)
	defining an element of the graph, already exists in the list.
	If the element is found, the index of the graph element is
	returned in gr_index.

	return(1) if exist.
	else return(0).
*/

int	SMIsGraphExist(curve, pt, part_nb, graphe, nb_graphe, gr_index)
int		curve;    /* (I) input curve */
int		pt;       /* (I) input point */
int		part_nb;  /* (I) part_nb if closed_cv */
struct gr_arc 	*graphe;  /* (I) input graph */
int		nb_graphe;/* (I) nb elt in graph */
int		*gr_index;/* (O) index of graph elt if found */
/*.SMIsGraphExist*/
{
  int		i;

  if(gr_index != NULL) *gr_index = -1;

  for(i=0;i<nb_graphe;i++)
  {
    if(graphe[i].cv == curve && graphe[i].pt == pt
       && graphe[i].part_nb == part_nb )
    {
      if(gr_index != NULL) *gr_index = i;
      return(1);
    }
  }
  return(0);
}

/*7 ====================== SMFillNextInGraph  ======================

	The function adds in the structure defining the element
	of the graph, the given next index.

	always return(1).
*/

int SMFillNextInGraph(graphe, next)
struct gr_arc 	*graphe; /* (I/O) graph elt where next will be added */
int		next;    /* (I) next to add */
/*.SMFillNextInGraph*/
{
  graphe->next[graphe->nb_next] = next;
  graphe->nb_next = graphe->nb_next + 1;

  return(1);
}

/*8 ====================== SMFindPtInGraph  ======================

	The function searchs all the graph elements that have pt
	as a node.
	Array must be allocated by user (of nb_in_graph).

	return(1) if ok
	else 0.

*/

int	SMFindPtInGraph(graphe, nb_graphe, pt, SMinters, nb_array, array)
struct gr_arc 	*graphe;   /* (I) input graph */
int		nb_graphe; /* (I) nb elt in graph */
int		pt;        /* (I) point to find */
struct SMinters	*SMinters;	/* (I) def of intersection pts */
int		*nb_array; /* (O) nb elt returned in array */
int		*array;    /* (O) array of graph index returned (where pt) */
/*.SMFindPtInGraph*/
{
  int	i, nb_tmp;

  if(graphe == NULL || nb_graphe == 0 || SMinters == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR Invalid Argument\n");
    return(0);
  }
  if(nb_array != NULL) *nb_array = 0;

  nb_tmp = 0;
  for(i=0;i<nb_graphe;i++)
  {
    if(SMIsEqualPt(graphe[i].pt,pt, SMinters))
    {
      if(array != NULL) array[nb_tmp] = i;
      nb_tmp ++;
    }
  }
  if(nb_array != NULL) *nb_array = nb_tmp;

  return(1);
}

/*11 ====================== SMGetLoopInGraph  ======================

	Given a graph, this function returns all loops in it.
	A Loop is defined as a way to go from one point to this same
	point without going through the same point ( last point is the same
	as the first one ). The loops are defined as a list of graph index.

	ex of loop :

		loop_index	pt (graph[loop_index].pt)

		  2		0
		  5		2
		  6		3
		  7		1
		  8		0

	loops is allocated by the function (nb_loops)
	and must be deallocated by the user.

	return(1) if ok.
	else return(0).

*/

int	SMGetLoopInGraph(nb_elt_graph, graph, SMinters,nb_loops, loops)
int		nb_elt_graph;   /* (I) nb_elt in graph */
struct gr_arc	*graph;	        /* (I) input graph */
struct SMinters	*SMinters;	/* (I) def of intersection pts */
int		*nb_loops;      /* (O) nb_loop found in graph */
struct one_loop **loops;	/* (O) returned loops of graph */

/*.SMGetLoopInGraph*/
{
  int		i,k, depart, LoopAlloc, TmpLoop_nb, current_index,
		index_chemin, *chemin, **TmpLoop, *LoopElt_nb, nb_mark,
		 MarkAlloc, nb_tmp;
  struct gr_arc	*wrk_graph;
  IGRboolean	found;
  struct	mark	*mark, tmp_mark;

  TmpLoop_nb = 0;
  LoopAlloc = INCR_ALLOC;
  MarkAlloc = INCR_ALLOC;
  TmpLoop = NULL;
  mark = NULL;
  LoopElt_nb = NULL;
  nb_mark = 0;
  chemin = NULL;
  wrk_graph = NULL;

  if(graph == NULL || nb_elt_graph == 0)
  {
    if (OM_Gf_verbose_warning) printf("ERROR invalid arguments\n");
    return(0);
  }

  if(loops != NULL) (*loops) = NULL;

  chemin = (int *)malloc((nb_elt_graph +1 )* sizeof(int));
  if(chemin == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR Bad allocation of chemin \n");
    goto wrapup;
  }

  wrk_graph = (struct gr_arc *)malloc(nb_elt_graph *sizeof(struct gr_arc ));
  if(wrk_graph == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR Bad allocation of wrk_graph\n");
    goto wrapup;
  }

  for(k=0;k<nb_elt_graph;k++) wrk_graph[k] = graph[k];

  mark = (struct mark *)malloc(MarkAlloc*sizeof(struct mark ));
  if(mark == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR Bad allocation of mark\n");
    goto wrapup;
  }

  TmpLoop = (int **)malloc(LoopAlloc*sizeof(int *));
  if(TmpLoop == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR Bad allocation of tmploop\n");
    goto wrapup;
  }
  for(i=0;i<LoopAlloc;i++) TmpLoop[i] = NULL;

  LoopElt_nb = (int *)malloc(LoopAlloc*sizeof(int ));
  if(LoopElt_nb == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR Bad allocation loopelt\n");
    goto wrapup;
  }

  for(k=0;k< nb_elt_graph; k++)
  {
    for(i=0;i<nb_elt_graph;i=i+1) SMInitmark(&wrk_graph[i]);

    depart = k;
    found = FALSE;
    for(i=0;i<k;i=i+1)
    {
      if(wrk_graph[i].pt == wrk_graph[k].pt) { found = TRUE; break;}
    }
    if(found == TRUE) continue; /* point already explored */

    if(LoopAlloc <= TmpLoop_nb )
    {

      nb_tmp = LoopAlloc + INCR_ALLOC;

      LoopElt_nb = (int *)realloc(LoopElt_nb,
				  nb_tmp*sizeof(int ));
      if(LoopElt_nb == NULL)
      {
	if (OM_Gf_verbose_warning) printf("ERROR Bad reallocation\n");
	goto wrapup;
      }
      TmpLoop = (int **)realloc(TmpLoop,
				nb_tmp*sizeof(int *));
      if(TmpLoop == NULL)
      {
	if (OM_Gf_verbose_warning) printf("ERROR Bad reallocation\n");
	goto wrapup;
      }
      for(i=LoopAlloc;i<nb_tmp;i++) TmpLoop[i] = NULL;
      LoopAlloc = nb_tmp;

    }
    LoopElt_nb[TmpLoop_nb] = 0;
    current_index = depart;

    index_chemin = 0;

    SMexploration(	wrk_graph,
			depart,
			SMinters,
			current_index,
			&index_chemin,
			chemin,
			&nb_mark,
			mark);

    LoopElt_nb[TmpLoop_nb] = index_chemin;
    if(LoopElt_nb[TmpLoop_nb] > 1)
    {
      TmpLoop[TmpLoop_nb] = NULL;
      TmpLoop[TmpLoop_nb] = (int *) malloc(LoopElt_nb[TmpLoop_nb]*sizeof(int));
      if(TmpLoop[TmpLoop_nb] == NULL)
      {
	if (OM_Gf_verbose_warning) printf("ERROR Bad allocation LoopElt_nb[TmpLoop_nb]\n");
	goto wrapup;
      }

      for(i=0;i<LoopElt_nb[TmpLoop_nb];i++)
	TmpLoop[TmpLoop_nb][i] = chemin[i];
      TmpLoop_nb ++;
      tmp_mark.pt1 = wrk_graph[chemin[0]].pt;
      tmp_mark.pt2 = wrk_graph[chemin[1]].pt;
      tmp_mark.curve = wrk_graph[chemin[1]].cv;
      tmp_mark.part_nb = wrk_graph[chemin[1]].part_nb;

      if(MarkAlloc <= nb_mark)
      {
	nb_tmp = MarkAlloc + INCR_ALLOC;
	mark = (struct mark *)realloc(mark,
				      nb_tmp*sizeof(struct mark ));
	if(mark == NULL)
	{
	  if (OM_Gf_verbose_warning) printf("ERROR Bad allocation mark\n");
	  goto wrapup;
	}
	MarkAlloc = nb_tmp ;
      }
      if( ! SMMarkExist(&tmp_mark, nb_mark, mark))
      {
	mark[nb_mark].pt1 = wrk_graph[chemin[0]].pt;
	mark[nb_mark].pt2 = wrk_graph[chemin[1]].pt;
	mark[nb_mark].curve = wrk_graph[chemin[1]].cv;
	mark[nb_mark].part_nb = wrk_graph[chemin[1]].part_nb;
	nb_mark = nb_mark + 1;
      }
    }

    while(index_chemin > 1)
    {
      if(LoopAlloc <= TmpLoop_nb )
      {
	nb_tmp = LoopAlloc + INCR_ALLOC;

	LoopElt_nb = (int *)realloc(LoopElt_nb,
				    nb_tmp*sizeof(int ));
	if(LoopElt_nb == NULL)
	{
	  if (OM_Gf_verbose_warning) printf("ERROR Bad reallocation\n");
	  goto wrapup;
	}
	TmpLoop = (int **)realloc(TmpLoop,
				  nb_tmp*sizeof(int *));
	if(TmpLoop == NULL)
	{
	  if (OM_Gf_verbose_warning) printf("ERROR Bad reallocation\n");
	  goto wrapup;
	}
	for(i=LoopAlloc;i<nb_tmp;i++) TmpLoop[i] = NULL;
	LoopAlloc = nb_tmp;
      }
      index_chemin = index_chemin-2;

      current_index = chemin[index_chemin];
      SMexploration(	wrk_graph,
			depart,
			SMinters,
			current_index,
			&index_chemin,
			chemin,
			&nb_mark,
			mark);
      LoopElt_nb[TmpLoop_nb] = index_chemin;

      if(LoopElt_nb[TmpLoop_nb] > 1)
      {
	TmpLoop[TmpLoop_nb] = NULL;
	TmpLoop[TmpLoop_nb] = (int *) malloc(LoopElt_nb[TmpLoop_nb]*sizeof(int));
	if(TmpLoop[TmpLoop_nb] == NULL)
	{
	  if (OM_Gf_verbose_warning) printf("ERROR Bad allocation LoopElt_nb[TmpLoop_nb]\n");
	  goto wrapup;
	}

	for(i=0;i<LoopElt_nb[TmpLoop_nb];i++)
	  TmpLoop[TmpLoop_nb][i] = chemin[i];
	TmpLoop_nb ++;

	tmp_mark.pt1 = wrk_graph[chemin[0]].pt;
	tmp_mark.pt2 = wrk_graph[chemin[1]].pt;
	tmp_mark.curve = wrk_graph[chemin[1]].cv;
	tmp_mark.part_nb = wrk_graph[chemin[1]].part_nb;

	if(MarkAlloc <= nb_mark)
	{
	  nb_tmp = MarkAlloc + INCR_ALLOC;
	  mark = (struct mark *)realloc(mark,
					nb_tmp*sizeof(struct mark ));
	  if(mark == NULL)
	  {
	    if (OM_Gf_verbose_warning) printf("ERROR Bad allocation mark \n");
	    goto wrapup;
	  }
	  MarkAlloc = nb_tmp;
	}
	if( ! SMMarkExist(&tmp_mark, nb_mark, mark))
	{
	  mark[nb_mark].pt1 = wrk_graph[chemin[0]].pt;
	  mark[nb_mark].pt2 = wrk_graph[chemin[1]].pt;
	  mark[nb_mark].curve = wrk_graph[chemin[1]].cv;
	  mark[nb_mark].part_nb = wrk_graph[chemin[1]].part_nb;
	  nb_mark = nb_mark + 1;
	}
      }
    }
  }

  if(nb_loops != NULL) *nb_loops = TmpLoop_nb;

  if(loops != NULL && TmpLoop_nb > 0)
  {
    *loops = NULL;
    *loops = (struct one_loop *)malloc(TmpLoop_nb * sizeof(struct one_loop));
    if(*loops == NULL)
    {
      if (OM_Gf_verbose_warning) printf("ERROR Bad allocation loops\n");
      goto wrapup;
    }
    for(i=0;i<TmpLoop_nb;i++) (*loops)[i].edge = NULL;

    for(i=0;i<TmpLoop_nb;i++) 
    {

      (*loops)[i].nb_edge = LoopElt_nb[i];
      (*loops)[i].edge = (int *)malloc(LoopElt_nb[i]*sizeof(int));
      if((*loops)[i].edge == NULL)
      {
	if (OM_Gf_verbose_warning) printf("ERROR Bad allocation\n");
	goto wrapup;
      }

      for(k=0;k<LoopElt_nb[i];k++)
	(*loops)[i].edge[k] = TmpLoop[i][k];
    }
  }

  if(TmpLoop != NULL)
  {
    for(i=0;i<LoopAlloc;i++)
      _FREE(TmpLoop[i]);
    _FREE(TmpLoop);
  }
  _FREE(LoopElt_nb);
  _FREE(mark);
  _FREE(wrk_graph);
  _FREE(chemin);
  return(1);

wrapup:

  if(TmpLoop != NULL)
  {
    for(i=0;i<TmpLoop_nb;i++)
      _FREE(TmpLoop[i]);
    _FREE(TmpLoop);
  }
  _FREE(LoopElt_nb);
  _FREE(mark);
  _FREE(wrk_graph);
  _FREE(chemin);

  if(loops != NULL && (*loops) != NULL)
  {
    for(i=0;i<TmpLoop_nb;i++)
      _FREE((*loops)[i].edge);
    _FREE(*loops);

  }
  return(0);
}

/*12 ======================  SMMarkExist ======================

	Given an array of marks, return 1 if the input
	mark is in the array. ( else 0)

*/

int	SMMarkExist(mark, nb_array, array)
struct mark	*mark;    /* (I) mark to find in the array */
int		nb_array; /* (I) nb mark in array */
struct mark	*array;   /*(I) array of mark where search is made */

/*.SMMarkExist*/
{
  int		i;

  for(i=0;i<nb_array;i++)
  {
    if(array[i].pt1 == mark->pt1 && array[i].pt2 == mark->pt2 &&
       array[i].curve == mark->curve &&
       array[i].part_nb == mark->part_nb) return(1);
    if(array[i].pt1 == mark->pt2 && array[i].pt2 == mark->pt1 &&
       array[i].curve == mark->curve &&
       array[i].part_nb == mark->part_nb) return(1);
  }
  return(0);
}

/*13 ======================  SMGetNbCurves ======================

	given an array of graph elts (pt+cv) return the
	number of different curves in the array and optionnaly
	the array of curves index.
	(curves_index is allocated by the function and must be
	deallocated by the user).

*/

int	SMGetNbCurves(loop, slarc, nb_curves, curves_index)
struct one_loop *loop;		/* (I) loop index */
struct sl_arc	*slarc;		/* (I) sl_arc definition */
int		*nb_curves;	/* (O) nb different curves in graph_index */
int		**curves_index; /* (O) index of the different curves returned */

/*.SMGetNbCurves*/
{
  int		i,k, *tmp, nb_tmp;
  IGRboolean	found;

  if(loop == NULL || slarc == NULL )
  {
    if (OM_Gf_verbose_warning) printf("ERROR Invalid argument\n");
    return(0);
  }

  tmp = NULL;
  nb_tmp = 0;

  if(curves_index != NULL) *curves_index = NULL;

  tmp = (int *)malloc(loop->nb_edge * sizeof(int ));
  if(tmp == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR bad allocation\n");
    goto wrapup;
  }

  for(i=0;i<loop->nb_edge;i++)
  {
    found = FALSE;
    for(k=0;k<nb_tmp;k++)
      if(slarc[loop->edge[i]].index_cv == tmp[k])
      {found = TRUE;break;}
    if(found == FALSE)
    {
      tmp[nb_tmp] = slarc[loop->edge[i]].index_cv;
      nb_tmp ++;
    }
  }

  if(nb_curves != NULL) *nb_curves = nb_tmp;
  if(curves_index != NULL && nb_tmp >0)
  {
    *curves_index = NULL;
    *curves_index = (int *)malloc(nb_tmp*sizeof(int));
    if(*curves_index == NULL)
    {
      if (OM_Gf_verbose_warning) printf("ERROR bad allocation\n");
      goto wrapup;
    }
    for(i=0;i<nb_tmp;i++) (*curves_index)[i] = tmp[i];

  }

  _FREE(tmp);
  return (1);
wrapup:
  if(curves_index != NULL && (*curves_index) != NULL)
    _FREE(*curves_index);
  _FREE(tmp);
  return(0);
}

/*14 ======================  SMGetNbIntPts ======================

	given an array of curves intersection points return the
	total number of intersection pts (curves have common intpts)
	and optionnaly the array of pts index.
	(intpts is allocated by the function and must be
	deallocated by the user).

*/

int	SMGetNbIntPts(nb_curves, curves, cvindex, nb_intpts, intpts)
int		nb_curves;	/* (I) nb curves */
struct SMcurve	*curves;	/* (I) curves intersection pts */
int		*cvindex;	/* (I) index of SMcurve */
int		*nb_intpts;	/* (O) number of intersection pts */
int		**intpts;	/* (O) returned intersection pts */

/*.SMGetNbIntPts*/
{
  int		i,j,k, *tmp_pts, nb_alloc, nbpts;
  IGRboolean	found;

  if(curves == NULL || cvindex == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR, invalid argument\n");
    return(0);
  }

  nbpts = 0;
  tmp_pts = NULL;
  if(intpts != NULL) (*intpts) = NULL;

  nb_alloc = 0;
  for(i=0;i<nb_curves;i++) nb_alloc = nb_alloc + curves[cvindex[i]].nb_intpt;

  tmp_pts = (int *)malloc(nb_alloc*sizeof(int ));
  if(tmp_pts == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR, Bad allocation\n");
    goto wrapup;
  }

  nbpts = 0;
  for(i=0;i<nb_curves;i++) 
  {
    for(j=0;j<curves[cvindex[i]].nb_intpt;j++)
    {
      found = FALSE;
      for(k=0;k<nbpts;k++)
      {
	if(tmp_pts[k] == curves[cvindex[i]].pt_index[j])
	{found = TRUE; break;}
      }
      if(found == FALSE)
      {
	tmp_pts[nbpts] = curves[cvindex[i]].pt_index[j];
	nbpts ++;
      }
    }
  }

  if(nb_intpts != NULL) *nb_intpts = nbpts;
  if(intpts != NULL && nbpts > 0)
  {
    *intpts = NULL;
    *intpts = (int *)malloc(nbpts * sizeof(int));
    if( (*intpts) == NULL)
    {
      if (OM_Gf_verbose_warning) printf("ERROR bad allocation\n");
      goto wrapup;
    }
    for(i=0;i<nbpts;i++) (*intpts)[i] = tmp_pts[i];
  }

  _FREE(tmp_pts);
  return (1);

wrapup:
  _FREE(tmp_pts);
  if(intpts != NULL && (*intpts) != NULL)_FREE(*intpts);

  return (0);
}

/*15 ======================  SMSortCvIntpts ======================

	Given an array of intersection pts (and its definition)
	sort an array of curves ordered pts.

	ex: p1 = c1 X c2		c1 = p1, p2, p3
	    p2 = c3 X c1	=> 	c2 = p1, p3
	    p3 = c1 X c2		c3 = p2

	The pts on each curve will be in increasing order.
	cv_inters is allocated by the function and must be deallocated
	by the user.

*/

int	SMSortCvIntpts(nb_cv, nb_pts, pt_inters, cv_inters)
int		nb_cv;		/* (I) number of allocated curves */
int		nb_pts;		/* (I) nb pts definition */
struct SMinters	*pt_inters;	/* (I) def of intersection pts */
struct SMcurve	*cv_inters;	/* (O) returned  curves */

/*.SMSortCvIntpts*/
{
  int		i,j,k, stat;
  struct SMcurve	*curves;
  IGRboolean	err_flag, found;

  if(pt_inters == NULL || nb_pts == 0 || nb_cv == 0 || cv_inters == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR Invalid argument\n");
    return(0);
  }

  curves = NULL;
  err_flag = FALSE;

  for(i=0;i<nb_cv;i++)
  {
    cv_inters[i].nb_intpt = 0;
    cv_inters[i].pt_index = NULL;
  }

  curves = (struct SMcurve *)malloc(nb_cv * sizeof(struct SMcurve));
  if(curves == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR, bad allocation\n");
    err_flag = TRUE;
    goto wrapup;
  }
  for(i=0;i<nb_cv;i++) 
  {
    curves[i].nb_intpt = 0;
    curves[i].pt_index = NULL;
  }
  for(i=0;i<nb_cv;i++) 
  {
    curves[i].pt_index = (int *)malloc((nb_pts+1)*sizeof(int));
    if(curves[i].pt_index == NULL)
    {
      if (OM_Gf_verbose_warning) printf("ERROR, bad allocation\n");
      err_flag = TRUE;
      goto wrapup;
    }
  }

  for(i=0;i<nb_pts;i++)
  {
    for(k=0;k<nb_cv;k++)
    {if(pt_inters[i].cv1 == k ) break;}
    /* verif that this point is not already in list */
    found = FALSE;
    for(j=0;j<curves[k].nb_intpt;j++)
    {
      if(SMIsEqualPt(i, curves[k].pt_index[j], pt_inters)) 
      {
	found = TRUE;
	break;
      }
    }
    if(found == FALSE)
    {
      curves[k].pt_index[curves[k].nb_intpt] = i;
      curves[k].nb_intpt ++;
    }
    for(k=0;k<nb_cv;k++)
      if(pt_inters[i].cv2 == k ) break;
    found = FALSE;
    for(j=0;j<curves[k].nb_intpt;j++)
    {
      if(SMIsEqualPt(i, curves[k].pt_index[j], pt_inters)) 
      {
	found = TRUE;
	break;
      }
    }
    if(found == FALSE)
    {
      curves[k].pt_index[curves[k].nb_intpt] = i;
      curves[k].nb_intpt ++;
    }
  }

  for(k=0;k<nb_cv;k++)
  {
    if(curves[k].nb_intpt == 0) continue;
    stat = SMorder_pt_on_cv(k, curves[k].nb_intpt, curves[k].pt_index,
			    pt_inters);
    if(stat != 1)
    {
      if (OM_Gf_verbose_warning) printf("ERROR SMorder_pt_on_cv\n");
      err_flag = TRUE;
      goto wrapup;
    }
  }

  for(i=0;i<nb_cv;i++)
  {
    if(curves[i].nb_intpt == 0) continue;
    cv_inters[i].nb_intpt = curves[i].nb_intpt;
    cv_inters[i].pt_index = NULL;
    cv_inters[i].pt_index = (int *)malloc(cv_inters[i].nb_intpt*
					  sizeof(int));
    if( cv_inters[i].pt_index == NULL)
    {
      if (OM_Gf_verbose_warning) printf("ERROR, bad allocation\n");
      err_flag = TRUE;
      goto wrapup;
    }
    for(k=0;k<cv_inters[i].nb_intpt;k++)
      cv_inters[i].pt_index[k] = curves[i].pt_index[k];
  }

wrapup:
  if(curves != NULL)
  {
    for(i=0;i<nb_cv;i++)
      if(curves[i].pt_index != NULL)
	_FREE(curves[i].pt_index);
    _FREE(curves);
  }
  if(err_flag == TRUE)
  {
    if(cv_inters != NULL )
    {
      for(i=0;i<nb_cv;i++)
	if(cv_inters[i].pt_index != NULL)
	  _FREE(cv_inters[i].pt_index);
    }
    return(0);
  }
  else return(1);

}

/*16 ======================  SMorder_pt_on_cv ======================

	Given an array of point index lying on a same curve,
	the function returns the same array in the increasing order
	of their position on the curve.

*/

int	SMorder_pt_on_cv(curve, nb_pts, pts, pt_inters)
int		curve;		/* (I) curve index */
int		nb_pts;		/* (I) nb pts */
int		*pts;		/* (I/O) pts index to order*/
struct SMinters	*pt_inters;	/* (I) def of intersection pts (param on cv)*/

/*.SMorder_pt_on_cv*/
{
  int		i, *order, *index;
  IGRdouble	*values;
  BSrc		rc;

  if(pts == NULL || pt_inters == NULL || nb_pts == 0)
  {
    if (OM_Gf_verbose_warning) printf("ERROR invalid argument\n");
    return(0);
  }
  values = NULL;
  order = NULL;
  index = NULL;

  values = (IGRdouble *)malloc(nb_pts*sizeof(IGRdouble));
  if(values == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR bad allocation\n");
    goto wrapup;
  }
  order = (int *)malloc(nb_pts*sizeof(int));
  if(order == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR bad allocation\n");
    goto wrapup;
  }
  index = (int *)malloc(nb_pts*sizeof(int));
  if(index == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR bad allocation\n");
    goto wrapup;
  }

  for(i=0;i<nb_pts; i++)
  {
    if(pt_inters[pts[i]].cv1 == curve) values[i] = pt_inters[pts[i]].par1;
    else values[i] = pt_inters[pts[i]].par2;
  }

  (IGRboolean)BStagsort( &rc, &nb_pts, values, order);
  if(rc != BSSUCC)
  {
    if (OM_Gf_verbose_warning) printf("ERROR BStagsort\n");
    goto wrapup;
  }

  for(i=0;i<nb_pts; i++) index[i] = pts[order[i]];
  for(i=0;i<nb_pts; i++) pts[i] = index[i];

  _FREE(values);
  _FREE(order);
  _FREE(index);
  return(1);

wrapup:
  _FREE(values);
  _FREE(order);
  _FREE(index);
  return(0);

}

/*17 ======================  SMGetMaxSfLoop ======================

	Given an array of loops (sl_arc index), The function returns
	the index of the loop that contains the maximum number of
	different input objects (surfaces or curves)and the number of
	objects taken in that loop.
	loopindex is allocated by the function and must be deallocated
	by the user.

*/

int	SMGetMaxSfLoop(loop, sl_arc, SMsfinters, nb_surfs, nb_maxloop,loopindex)
struct loop_on_surf	*loop	;	/* (I) input loops (=sl_arc index) */
struct sl_arc		*sl_arc;	/* (I) sl_arc definition */
struct SMsfinters	*SMsfinters; 	/* (I) surf intersection def */
int			*nb_surfs;	/* (O) nb surfs in the loops*/
int			*nb_maxloop;	/* (O) nb of loop with the max nb of cv */
int			**loopindex; 	/* (O) index of the loops returned */

/*.SMGetMaxSfLoop*/
{
  int		total_nb, i, max, stat, *max_loop,
    nb_cv, *cvindex, nb_max, nbsf;

  if(loop == NULL || sl_arc == NULL )
  {
    if (OM_Gf_verbose_warning) printf("ERROR Invalid argument\n");
    return(0);
  }

  cvindex = NULL;
  max_loop = NULL;
  total_nb = 0;
  if(loopindex != NULL) (*loopindex) = NULL;

  for(i=0;i<loop->nb_loop;i++) total_nb = total_nb + loop->one_loop[i].nb_edge;

  max_loop = (int *)malloc((total_nb+1) *sizeof(int));
  if(max_loop == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR Bad allocation\n");
    goto wrapup;
  }

  max = -1;
  nb_max = 0;

  for(i=0;i<loop->nb_loop;i++)
  {
    cvindex = NULL;
    stat = SMGetNbCurves(&(loop->one_loop[i]), sl_arc,
			 &nb_cv, &cvindex);
    if(stat != 1)
    {
      if (OM_Gf_verbose_warning) printf("ERROR SMGetNbCurves\n");
      goto wrapup;
    }
    nbsf = 0;
    stat = SMGetNbSurfs(nb_cv, cvindex, SMsfinters,
			&nbsf, NULL);
    if(stat != 1)
    {
      if (OM_Gf_verbose_warning) printf("ERROR SMGetNbSurfs\n");
      goto wrapup;
    }
    if(max < nbsf) 
    {
      max = nbsf;
      nb_max = 0;
      max_loop[nb_max] = i;
      nb_max ++;
    }
    else if(max == nbsf)
    {
      max_loop[nb_max] = i;
      nb_max ++;
    }
    _FREE(cvindex);
  }

  if(nb_surfs != NULL) *nb_surfs = max;
  if(nb_maxloop != NULL) *nb_maxloop = nb_max;
  if(loopindex != NULL && nb_max >0) 
  {
    *loopindex = NULL;
    *loopindex = (int *)malloc(nb_max*sizeof(int));
    if(*loopindex == NULL)
    {
      if (OM_Gf_verbose_warning) printf("ERROR bad allocation\n");
      goto wrapup;
    }
    for(i=0;i<nb_max;i++) (*loopindex)[i] = max_loop[i];
  }

  _FREE(cvindex);
  _FREE(max_loop);
  return(1);
wrapup:

  _FREE(cvindex);
  if(loopindex != NULL && (*loopindex) != NULL)
    _FREE(*loopindex);
  _FREE(max_loop);
  return(0);
}

/*18 ======================  SMCreatCompCv ======================

        Given an array of curves, The function creates the composite
        curve and return its geometry if needed.

	comp_geom (if non NULL) is allocated by the function and must be
	deallocated by the user.

        return(1) if ok
        else return(0).

*/

int	SMCreatCompCv(nb_cv, curves, cst, comp_id, comp_geom)
int			nb_cv;		/* (I) nb curves */
struct GRlc_info	*curves;	/* (I) curves */
struct GRvg_construct   *cst;		/* (I) construction list */
struct	GRid		*comp_id;	/* (O) composite id created*/
struct IGRbsp_curve	**comp_geom;	/* (O) composite geom */

/*.SMCreatCompCv*/
{
  int			k, stat;
  IGRboolean		err_flag;
  IGRdouble		dist;
  long			size, msg, rotten_one, nput, nret;
  IGRdouble		coef, set_tol, basis_tol, cht_tol;

  if(nb_cv == 0 || curves == NULL || cst == NULL || comp_id == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR Invalid argument\n");
    return(0);
  }

  __enterFunction ( name = "SMCreatCompCv", argfmt = "nb_cv = %d",  args = `nb_cv` );

  err_flag = FALSE;

  if(comp_geom != NULL) *comp_geom = NULL;

  nput = sizeof(basis_tol);

  gr$get_basis_tolerance(	msg    = &msg,
				sizbuf = &nput,
				buffer = &basis_tol,
				nret   = &nret);

  if(!(msg&1))
  
  {
    if (OM_Gf_verbose_warning) printf("error gr$get_basis_tolerance\n");
    err_flag = TRUE;
    goto wrapup;
  }

  nput = sizeof(cht_tol);

  gr$get_chord_height_tolerance(msg    = &msg,
                         	sizbuf = &nput,
                         	buffer = &cht_tol,
                         	nret   = &nret);

  if(!(msg&1))
  {
    if (OM_Gf_verbose_warning) printf("error gr$get_chord_height_tolerance\n");
    err_flag = TRUE;
    goto wrapup;
  }
  set_tol = cht_tol;

  /* we must always keep cht = 1000 basis */

  /****
    set_tol = 1000*set_tol;

    nput = sizeof(set_tol);

    gr$put_chord_height_tolerance
    (msg    = &msg,
    sizbuf = &nput,
    buffer = &set_tol);

    if(!(msg&1))
    {
    if (OM_Gf_verbose_warning) printf("error gr$put_basis_tolerance\n");
    err_flag = TRUE;
    goto wrapup;
    }
    ****/

#ifdef	DEBUG
  printf("make composite curve with the %d curves\n",nb_cv);
  for(k=0;k<nb_cv;k++)
    printf("curve: %d, %d\n", curves[k].located_obj.objid, curves[k].located_obj.osnum);

  printf("set env_info to 21,2 ........\n");
  cst->env_info->md_id.objid = 21;

#endif

  if ( VDcomment )	// For DEBUGGING ; put in RTREE to make locatable
  {
    cst->env_info->md_id.objid = 21;
  }

  comp_id->osnum = cst->env_info->md_id.osnum;
  comp_id->objid = NULL_OBJID;
  rotten_one = 0;

  stat = om$construct(msg = message GRcompcurve.EMmakecomp( 	&msg,
								cst->env_info,
								nb_cv,
 								curves,
 								&rotten_one),
		      classid = OPP_GRcompcurve_class_id,
		      p_objid  = &comp_id->objid,
		      osnum  = comp_id->osnum );

  as$status(sts=stat);
  if (!(stat&msg&1))
  {
    if (OM_Gf_verbose_warning)
    {
      printf("GRcompcurve.EMmakecomp failed\n");
      if(msg == GRILLDEFINITION) printf("GRILLDEFINITION\n");
      if(msg == MSFAIL) printf("MSFAIL\n");
    }
    
    comp_id->objid = NULL_OBJID;
    err_flag = TRUE;
    goto wrapup;
  }

  if(comp_geom != NULL)
  {
    stat = om$send(msg = message GRvg.GRgetsize(&msg,
						&((cst->env_info)->md_env.matrix_type),
						(cst->env_info)->md_env.matrix,
						&size ),
		   senderid = NULL_OBJID,
	  	   targetid = comp_id->objid,
	  	   targetos = comp_id->osnum );

    as$status(sts = stat);
    if(!(stat & msg &1))
    {
      if (OM_Gf_verbose_warning) printf("ERROR GRvg.GRgetsize\n");
      err_flag = TRUE;
      goto wrapup;
    }

    (*comp_geom) = (struct IGRbsp_curve *) malloc(size);

    if(*comp_geom == NULL) 
    {
      if (OM_Gf_verbose_warning) printf("ERROR, Bad dynamic allocation \n");
      err_flag = TRUE;
      goto wrapup;
    }

    stat = om$send(msg = message GRvg.GRgetgeom(&msg,
						&((cst->env_info)->md_env.matrix_type),
						(cst->env_info)->md_env.matrix,
						(char *) (*comp_geom)),
		   senderid = NULL_OBJID,
		   targetid = comp_id->objid,
		   targetos = comp_id->osnum );
    as$status(sts = stat);
    if(!(stat & msg &1))
    {
      if (OM_Gf_verbose_warning) printf("ERROR GRvg.GRgetgeom\n");
      err_flag = TRUE;
      goto wrapup;
    }

    coef = 0.;
    for(k=0;k<3;k=k+1) 
    {
      dist = (*comp_geom)->poles[k] -(*comp_geom)->poles[3*((*comp_geom)->num_poles-1)+k];
      coef = coef + (IGRdouble)fabs(dist);
    }

    if (coef < basis_tol) (*comp_geom)->phy_closed = TRUE;
    else 	(*comp_geom)->phy_closed = FALSE;
  }

wrapup:

/*
    nput = sizeof(basis_tol);

    gr$put_basis_tolerance
    (msg    = &msg,
    sizbuf = &nput,
    buffer = &basis_tol);

    if(!(msg&1)) if (OM_Gf_verbose_warning) printf("error restore basis_tolerance\n");

    nput = sizeof(cht_tol);

    gr$put_chord_height_tolerance
    (msg    = &msg,
    sizbuf = &nput,
    buffer = &cht_tol);

    if(!(msg&1)) if (OM_Gf_verbose_warning) printf("error gr$put_chord_height_tolerance\n");
*/

  if(err_flag == TRUE) 
  {
    if(comp_geom != NULL && *comp_geom != NULL)
    {
      _FREE( *comp_geom);
    }
    if(om$is_objid_valid(osnum = comp_id->osnum,
			 objid = comp_id->objid) & 1)
    {
      stat = om$send(	msg = message GRgraphics.GRdelete(&msg,
							  cst->env_info),
			senderid = NULL_OBJID,
			targetid = comp_id->objid ,
			targetos = comp_id->osnum);
      comp_id->objid = NULL_OBJID;
      as$status(sts=stat);
    }

    __exit_error_Function ( name = "SMCreatCompCv" );

    return(0);
  }
  else
  {
    __exitFunction ( name = "SMCreatCompCv" );

    return(1);
  }
}

/*19 ======================  SMSortSfIntCvs ======================

	Given an array of intersection curves (and its definition)
	sort an array of surfaces consecutive cvs.

	SMsurf is allocated by the function and must be deallocated
	by the user.

        return(1) if ok
        else return(0).
*/

int	SMSortSfIntCvs(nb_cvinters, cvinters, nb_SMsurf, SMsurf)
int			nb_cvinters;	/* (I) nb curves definition */
struct SMsfinters	*cvinters;	/* (I) def of intersection curves */
int			*nb_SMsurf;	/* (O) number of surfaces */
struct SMsurf		**SMsurf;	/* (O) returned  surfaces */

/*.SMSortSfIntCvs*/
{
  int		i,k, num_sf, *sf_index;
  struct SMsurf	*surfs;
  IGRboolean	err_flag, found;

  sf_index = NULL;
  surfs = NULL;
  err_flag = FALSE;
  num_sf = 0;

  if(cvinters == NULL || nb_cvinters == 0)
  {
    if (OM_Gf_verbose_warning) printf("ERROR Invalid argument\n");
    return(0);
  }
  if(SMsurf != NULL) (*SMsurf) = NULL;

  sf_index = (int *)malloc(2*nb_cvinters * sizeof(int));
  if(sf_index == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR, bad allocation\n");
    err_flag = TRUE;
    goto wrapup;
  }

  for(i=0;i<nb_cvinters;i++)
  {
    found = FALSE;
    for(k=0;k<num_sf;k++)
      if(cvinters[i].sf1 == sf_index[k]) 
      {
	found = TRUE;
	break;
      }
    if(found == FALSE)
    {
      sf_index[num_sf] = cvinters[i].sf1;
      num_sf ++;
    }
    found = FALSE;
    for(k=0;k<num_sf;k++)
      if(cvinters[i].sf2 == sf_index[k]) {found = TRUE; break;}
    if(found == FALSE)
    {
      sf_index[num_sf] = cvinters[i].sf2;
      num_sf ++;
    }
  }

  if(num_sf == 0)
  {
    if(nb_SMsurf != NULL) *nb_SMsurf = num_sf;
    goto wrapup;
  }

  surfs = (struct SMsurf *)malloc(num_sf * sizeof(struct SMsurf));
  if(surfs == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR, bad allocation\n");
    err_flag = TRUE;
    goto wrapup;
  }
  for(i=0;i<num_sf;i++) 
  {
    surfs[i].nb_intcv = 0;
    surfs[i].cv_index = NULL;
  }
  for(i=0;i<num_sf;i++) 
  {
    surfs[i].cv_index = (int *)malloc(2*nb_cvinters*sizeof(int));
    if(surfs[i].cv_index == NULL)
    {
      if (OM_Gf_verbose_warning) printf("ERROR, bad allocation\n");
      err_flag = TRUE;
      goto wrapup;
    }
  }

  for(i=0;i<nb_cvinters;i++)
  {
    for(k=0;k<num_sf;k++)
      if(cvinters[i].sf1 == k ) break;
    surfs[k].cv_index[surfs[k].nb_intcv] = i;
    surfs[k].nb_intcv ++;

    for(k=0;k<num_sf;k++)
      if(cvinters[i].sf2 == k ) break;
    surfs[k].cv_index[surfs[k].nb_intcv] = i;
    surfs[k].nb_intcv ++;
  }

  if(nb_SMsurf != NULL) *nb_SMsurf = num_sf;
  if(SMsurf != NULL)
  {
    *SMsurf = NULL;
    *SMsurf = (struct SMsurf *)malloc(num_sf*sizeof(struct SMsurf));
    if( (*SMsurf) == NULL)
    {
      if (OM_Gf_verbose_warning) printf("ERROR, bad allocation\n");
      err_flag = TRUE;
      goto wrapup;
    }
    for(i=0;i<num_sf;i++) (*SMsurf)[i].cv_index = NULL;
    for(i=0;i<num_sf;i++)
    {
      (*SMsurf)[i].nb_intcv = surfs[i].nb_intcv;
      (*SMsurf)[i].cv_index = NULL;
      (*SMsurf)[i].cv_index = (int *)malloc(surfs[i].nb_intcv*
					    sizeof(int));
      if( (*SMsurf)[i].cv_index == NULL)
      {
	if (OM_Gf_verbose_warning) printf("ERROR, bad allocation\n");
	err_flag = TRUE;
	goto wrapup;
      }
      for(k=0;k<(*SMsurf)[i].nb_intcv;k++)
	(*SMsurf)[i].cv_index[k] = surfs[i].cv_index[k];
    }

  }

wrapup:
  if(surfs != NULL)
  {
    for(i=0;i<num_sf;i++)
      _FREE(surfs[i].cv_index);
    _FREE(surfs);
  }
  if(err_flag == TRUE)
  {
    if(SMsurf != NULL && (*SMsurf) != NULL)
    {
      for(i=0;i<num_sf;i++)
	_FREE((*SMsurf)[i].cv_index);
      _FREE(*SMsurf);
    }
    return(0);
  }
  else return(1);

}

/*20 ======================  SMGetNbSurfs ======================

        given an array of curve index (surfaces intersections or input curves),
        return the number of different surfaces that are intersected
        in the array and optionnaly the array of surface index.

        (surfs_index is allocated by the function and must be
        deallocated by the user).

        return(1) if ok
        else return(0).

*/
int	SMGetNbSurfs(nb_cv, curves, SMsfinters, nb_surfs, surfs_index)
int			nb_cv;		/* (I) nb curves */
int			*curves; 	/* (I) index of the input curves */
struct SMsfinters	*SMsfinters; 	/* (I) surf intersection def */
int			*nb_surfs;	/* (O) nb different surfs in graph_index */
int			**surfs_index; 	/* (O) index of the different surfs returned */

/*.SMGetNbSurfs*/
{
  int		i,k, *tmp, nb_tmp, index;
  IGRboolean	found;

  if(curves == NULL || nb_cv == 0 || SMsfinters == NULL )
  {
    if (OM_Gf_verbose_warning) printf("ERROR Invalid argument\n");
    return(0);
  }

  tmp = NULL;
  nb_tmp = 0;

  if(surfs_index != NULL) *surfs_index = NULL;

  tmp = (int *)malloc(2*nb_cv * sizeof(int ));
  if(tmp == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR bad allocation\n");
    goto wrapup;
  }

  for(i=0;i<nb_cv;i++)
  {

    if(SMsfinters[curves[i]].sf1 == -1) index = SMsfinters[curves[i]].sf2;
    else index = SMsfinters[curves[i]].sf1;

    found = FALSE;
    for(k=0;k<nb_tmp;k++)
      if(index == tmp[k])
      {found = TRUE;break;}
    if(found == FALSE)
    {
      tmp[nb_tmp] = index;
      nb_tmp ++;
      if(SMsfinters[curves[i]].sf1 == -1) continue;
    }
    index = SMsfinters[curves[i]].sf2;

    found = FALSE;
    for(k=0;k<nb_tmp;k++)
      if(index == tmp[k])
      {found = TRUE;break;}
    if(found == FALSE)
    {
      tmp[nb_tmp] = index;
      nb_tmp ++;
    }
  }

  if(nb_surfs != NULL) *nb_surfs = nb_tmp;
  if(surfs_index != NULL && nb_tmp >0)
  {
    *surfs_index = NULL;
    *surfs_index = (int *)malloc(nb_tmp*sizeof(int));
    if(*surfs_index == NULL)
    {
      if (OM_Gf_verbose_warning) printf("ERROR bad allocation\n");
      goto wrapup;
    }
    for(i=0;i<nb_tmp;i++) (*surfs_index)[i] = tmp[i];

  }

  _FREE(tmp);
  return (1);
wrapup:
  if(surfs_index != NULL && (*surfs_index) != NULL)
    _FREE(*surfs_index);
  _FREE(tmp);
  return(0);
}

/*21 ======================  SMGetCommonIndex ======================

	given n array of index return an array of the index that are
	common to all sets.
	common is allocated by the function and must be deallocated by
	the user.

        return(1) if ok
        else return(0).

*/

int	SMGetCommonIndex(nb_array, nb_elt, array, nb_common, common)
int			nb_array;	/* (I) nb array */
int			*nb_elt;	/* (I) nb elt in array */
int			**array; 	/* (I) input array of index */
int			*nb_common;	/* (O) nb different surfs in graph_index */
int			**common; 	/* (O) index of the different surfs returned */

/*.SMGetCommonIndex*/
{
  int		i,k,i1, k1, l, nb_tmp, *tmp, total_nb, index;
  IGRboolean	in_array, found, found1;

  if(nb_array == 0 || nb_elt == NULL || array == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR Invalid argument\n");
    return(0);
  }
  tmp = NULL;
  nb_tmp = 0;
  found1 = FALSE;
  index = 0;

  total_nb = 0;
  for(i=0;i<nb_array;i++) total_nb = total_nb + nb_elt[i];

  if(total_nb == 0)
  {
    if(nb_common != NULL) *nb_common = 0;
    return(1);
  }

  tmp = (int *) malloc(total_nb * sizeof(int));
  if(tmp == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR, bad allocation\n");
    goto wrapup;
  }

  for(i=0;i<nb_array;i++)
  {
    for(k=0;k<nb_elt[i];k++)
    {
      found = FALSE;
      for(i1=0;i != i1 && i1<nb_array;i1++)
      {
	found1 = FALSE;
	for(k1=0;k1<nb_elt[i1];k1++)
	{
	  if(array[i][k] == array[i1][k1]) 
	  {
	    index = array[i][k];
	    found1 = TRUE;
	    break;
	  }
	}
	if(found1 == FALSE) break;
      }
      found = found1;
      if(found == TRUE)
      {
	in_array = FALSE;
	for(l=0;l<nb_tmp;l++)
	  if(tmp[l] == index) {in_array = TRUE;break;}
	if(in_array == FALSE)
	{
	  tmp[nb_tmp] = index;
	  nb_tmp ++;
	}
      }
    }
  }

  if(nb_common != NULL) *nb_common = nb_tmp;
  if(common != NULL && nb_tmp != 0)
  {
    *common = (int *)malloc(nb_tmp*sizeof(int));
    if(*common == NULL)
    {
      if (OM_Gf_verbose_warning) printf("ERROR, Bad allocation\n");
      goto wrapup;
    }
    for(i=0;i<nb_tmp;i++) (*common)[i] = tmp[i];
  }

  _FREE(tmp);
  return(1);
wrapup:
  _FREE(tmp);
  if(common != NULL && *common != NULL)_FREE(*common);

  return(0);
}

/*22 ======================  SMGetOrderSfLoop ======================

	Find the loop (if it exists) that uses surfaces in their
	order of input. If it doesn't exist, index_loop = -1.

	The function only looks at the loops that correspond to the
	given array of index.

        return(1) if ok
        else return(0).

*/

int	SMGetOrderSfLoop(loop, nb_index, index, sl_arc, SMsfinters, index_loop)
struct loop_on_surf	*loop	;	/* (I) input loops (=sl_arc index) */
int			nb_index;       /* (I) nb of loop index */
int			*index;         /* (I) loop index */
struct sl_arc		*sl_arc;	/* (I) sl_arc definition */
struct SMsfinters	*SMsfinters; 	/* (I) surf intersection def */
int			*index_loop;    /* (O) ordered loop */
/*.SMGetOrderSfLoop*/
{
  int		i,j,k, stat, nb_sf, *sfindex, *order,
    previous, next, pos1, pos2;
  IGRboolean	found;
  BSrc		rc;

  if(loop == NULL || sl_arc == NULL || SMsfinters == NULL || nb_index == 0 ||
     index == NULL || index_loop == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR Invalid argument\n");
    return(0);
  }
  sfindex = NULL;
  order = NULL;

  *index_loop = -1;

  for(i=0;i<nb_index;i++)
  {
    found = TRUE;
    nb_sf = 0;

    stat = SMGetSfInLoop(&loop->one_loop[index[i]], sl_arc, SMsfinters,
			 &nb_sf, &sfindex);
    if(stat != 1)
    {
      if (OM_Gf_verbose_warning) printf("ERROR SMGetSfInLoop\n");
      goto wrapup;
    }
    if(nb_sf == 0) continue;

    order = (int *)malloc(nb_sf * sizeof(int));
    if(order == NULL)
    {
      if (OM_Gf_verbose_warning) printf("ERROR, Bad Allocation\n");
      goto wrapup;
    }
    (void)BStagsorti(&nb_sf, sfindex, order, &rc);
    if(rc != BSSUCC)
    {
      if (OM_Gf_verbose_warning) printf("ERROR BStagsorti\n");
      goto wrapup;
    }
    for(k=0;k<nb_sf;k++) order[k] = sfindex[order[k]];

    for(k=0;k<nb_sf;k++)
    {
      for(j=0;j<nb_sf;j++)
	if(order[j] == sfindex[k]) break;

      if(k==0)pos1 = sfindex[nb_sf-1];
      else pos1 = sfindex[k-1];

      if(k==nb_sf-1) pos2 = sfindex[0];
      else pos2 = sfindex[k+1];

      if(j==0) previous = order[nb_sf-1];
      else previous = order[j-1];

      if(j==nb_sf-1) next = order[0];
      else  next = order[j+1];

      if( !(previous == pos1 && next == pos2) &&
	  !(previous == pos2 && next == pos1) )
      {
	found = FALSE;
	break;
      }
    }

    if(found == TRUE) 
    {
      *index_loop = index[i];
      _FREE(sfindex);
      _FREE(order);
      break;
    }
    _FREE(sfindex);
    _FREE(order);
  }

  _FREE(sfindex);
  _FREE(order);
  return(1);

wrapup:
  _FREE(order);
  _FREE(sfindex);
  return(0);
}

/*23 ======================  SMGetMaxSfVol ======================

	given an array of volumes, return the index of the volumes
	that contain the maximum number of surfaces.

	maxvol is allocated by the function and must be deallocated
	by the user.

        return(1) if ok
        else return(0).
*/

int	SMGetMaxSfVol(nb_vol, vols, nb_maxvol, maxvol)
int			nb_vol	;/* (I) nb  input volumes */
struct one_solid	*vols;	/* (I)  input volumes*/
int			*nb_maxvol;/* (O) nb of vol with the max nb of sf */
int			**maxvol; /* (O) index of the vol returned */
/*.SMGetMaxSfVol*/
{
  int		total_nb, i,j,k, max, *max_index,
    *sfindex, nb_max, nbsf;
  IGRboolean	found;

  if(nb_vol == 0 || vols == NULL )
  {
    if (OM_Gf_verbose_warning) printf("ERROR Invalid argument\n");
    return(0);
  }

  max_index = NULL;
  sfindex = NULL;
  total_nb = 0;

  if(maxvol != NULL) *maxvol = NULL;

  if(nb_maxvol != NULL) *nb_maxvol = 0;

  max_index = (int *)malloc(nb_vol *sizeof(int));
  if(max_index == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR Bad allocation\n");
    goto wrapup;
  }

  for(i=0;i<nb_vol;i++) total_nb = total_nb + vols[i].nb_surf;

  sfindex = (int *)malloc(total_nb *sizeof(int));
  if(sfindex == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR Bad allocation\n");
    goto wrapup;
  }
  nbsf = 0;
  nb_max = 0;
  max = 0;
  for(i=0;i<nb_vol;i++)
  {
    nbsf = 0;
    for(k=0;k<vols[i].nb_surf;k++)
    {
      found = FALSE;
      for(j=0;j<nbsf;j++)
      {
	if(vols[i].surf_index[k] == vols[i].surf_index[j])
	{
	  found = TRUE;
	  break;
	}
      }
      if(found == FALSE)
      {
	sfindex[nbsf] = j;
	nbsf ++;
      }
    }
    if(max < nbsf) 
    {
      max = nbsf;
      nb_max = 0;
      max_index[nb_max] = i;
      nb_max ++;
    }
    else if(max == nbsf)
    {
      max_index[nb_max] = i;
      nb_max ++;
    }

  }
  if(nb_maxvol != NULL) *nb_maxvol = nb_max;
  if(maxvol != NULL && nb_max >0) 
  {
    *maxvol = NULL;
    *maxvol = (int *)malloc(nb_max*sizeof(int));
    if(*maxvol == NULL)
    {
      if (OM_Gf_verbose_warning) printf("ERROR bad allocation\n");
      goto wrapup;
    }
    for(i=0;i<nb_max;i++) (*maxvol)[i] = max_index[i];
  }

  _FREE(max_index);
  _FREE(sfindex);
  return(1);
wrapup:

  _FREE(max_index);
  _FREE(sfindex);
  if(maxvol != NULL && (*maxvol) != NULL)
    _FREE(*maxvol);
  return(0);

}

/*24 ======================  SMGetSfInLoop ======================

	Given a loop, return all the surfaces used (except the support = S0).
	The surfaces are returned in the order of the loop.

	sfindex is allocated by the function and must be deallocated by
	the user.

        return(1) if ok
        else return(0).

*/

int	SMGetSfInLoop(loop, sl_arc, SMsfinters, nb_sf, sfindex)
struct one_loop		*loop	;	/* (I) input loops (=sl_arc index) */
struct sl_arc		*sl_arc;	/* (I) sl_arc definition */
struct SMsfinters	*SMsfinters; 	/* (I) surf intersection def */
int			*nb_sf;    /* (O) nb of surfaces returned */
int			**sfindex;    /* (O) index of surfaces returned */
/*.SMGetSfInLoop*/
{
  int		i,j,k, *surf, nb_surf, cv_index;
  IGRboolean	found;

  if(loop == NULL || sl_arc == NULL || SMsfinters == NULL )
  {
    if (OM_Gf_verbose_warning) printf("ERROR Invalid argument\n");
    return(0);
  }
  surf = NULL;
  nb_surf = 0;

  if(sfindex != NULL) *sfindex = NULL;
  if(loop->nb_edge == 0)
  {
    if(nb_sf != NULL) *nb_sf = 0;
    return(1);
  }
  surf = (int *)malloc(loop->nb_edge * 2 * sizeof(int));
  if(surf == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR, Bad allocation\n");
    goto wrapup;
  }

  nb_surf = 0;
  for(i=0;i<loop->nb_edge;i++)
  {
    cv_index = sl_arc[loop->edge[i]].index_cv;
    if(SMsfinters[cv_index].sf1 != 0)
      surf[nb_surf] = SMsfinters[cv_index].sf1;
    else
      surf[nb_surf] = SMsfinters[cv_index].sf2;
    nb_surf ++;

  }

  i=0;
  while(i<nb_surf) 
  {
    found = FALSE;
    for(k=0;k<i;k++)
    {
      if(surf[k] == surf[i])
      {
	for(j=k;j<nb_surf-1;j++) surf[j] = surf[j+1];
	nb_surf --;
	found = TRUE;
	break;
      }
    }
    if(found == FALSE) i++;
  }

  if(nb_sf != NULL) *nb_sf = nb_surf;
  if(sfindex != NULL)
  {
    *sfindex = (int *) malloc(nb_surf*sizeof(int));
    if(*sfindex == NULL)
    {
      if (OM_Gf_verbose_warning) printf("ERROR, Bad allocation\n");
      goto wrapup;
    }
    for(i=0;i<nb_surf;i++) (*sfindex)[i] = surf[i];

  }

  _FREE(surf);
  return(1);

wrapup:
  _FREE(surf);
  if(sfindex != NULL && *sfindex != NULL)_FREE(*sfindex);

  return(0);
}

/*25 ======================  SMCrtPartCv ======================

        Given an array of curves, The function creates the part of
        the curves between the intersection pts.

	part_id and part_geom (if not NULL) are allocated by the function of
	loop->nb_edge and must be deallocated by the function.

	each part_geom is allocated by the function and must be
	deallocated by the user.

        return(1) if ok
        else return(0).

*/

int	SMCrtPartCv(nb_cv, bsp_cv, nb_inters,inters, loop,
	     slarc, cst, part_id, part_geom)
int			nb_cv;		/* (I) nb curves */
struct IGRbsp_curve	**bsp_cv;	/* (I) curves */
int			nb_inters;	/* (I) nb_intersection info */
struct SMinters		*inters;	/* (I) info on intersection */
struct one_loop		*loop;		/* (I) input loop */
struct sl_arc		*slarc;		/* (I) arc definition */
struct GRvg_construct   *cst;		/* (I) construction list */
struct GRlc_info	**part_id;	/* (O) (NULL) partofcv id created*/
struct IGRbsp_curve	***part_geom;	/* (O) (NULL) partofcv geom */

/*.SMCrtPartCv*/
{
  int			i,k, stat, index_pt1, rev, index_pt2, cv_index,
			nb_part, num_poles, part_nb, exact1, exact2;
  IGRboolean		err_flag;
  IGRdouble		par1, par2, d_par;
  BSrc			rc;
  long			msg;
  struct GRvg_construct   tmp_cst;
  struct IGRbsp_curve	*tmp_geom;

  if(bsp_cv == NULL || inters == NULL || loop == NULL || slarc == NULL ||
     cst == NULL || loop->nb_edge == 0)
  {
    if (OM_Gf_verbose_warning) printf("ERROR Invalid argument\n");
    return(0);
  }
  if(part_id == NULL && part_geom == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR Invalid argument\n");
    return(0);
  }
  tmp_geom = NULL;
  exact1 = exact2 = 0;

  nb_part = loop->nb_edge ;

  if(part_id != NULL)
  {
    *part_id = NULL;
    *part_id = (struct GRlc_info *)malloc(nb_part*sizeof(struct GRlc_info ));
    if(*part_id == NULL)
    {
      if (OM_Gf_verbose_warning) printf("ERROR Bad dynamic allocation ");
      err_flag = TRUE;
      goto wrapup;
    }
    for(i=0;i<nb_part;i++) 
    {
      (*part_id)[i].located_obj.objid = NULL_OBJID;
      (*part_id)[i].located_obj.osnum = cst->env_info->md_id.osnum;
      (*part_id)[i].module_info = (*cst->env_info);
    }
  }

  if(part_geom != NULL)
  {
    *part_geom = NULL;
    *part_geom = (struct IGRbsp_curve **)malloc(nb_part*sizeof(struct IGRbsp_curve * ));
    if(*part_geom == NULL)
    {
      if (OM_Gf_verbose_warning) printf("ERROR Bad dynamic allocation ");
      err_flag = TRUE;
      goto wrapup;
    }
    for(i=0;i<nb_part;i++) (*part_geom)[i] = NULL;
  }

  err_flag = FALSE;

  for(i=0;i<nb_part;i++)
  {
    index_pt1 = slarc[loop->edge[i]].index_pt1;
    index_pt2 = slarc[loop->edge[i]].index_pt2;
    cv_index  = slarc[loop->edge[i]].index_cv;
    part_nb   = slarc[loop->edge[i]].part_nb;

    par1 = par2 = -1;

    if( inters[index_pt1].cv1 == cv_index ) 
    {
      par1 = inters[index_pt1].par1;
      exact1 = index_pt1;
    }
    else if ( inters[index_pt1].cv2 == cv_index ) 
    {
      par1 = inters[index_pt1].par2;
      exact1 = index_pt1;
    }
    else
    {
      /* find the same pt that is on the curve */
      for(k=0;k<nb_inters;k++)
      {
	if(SMIsEqualPt(k, index_pt1, inters))
	{
	  if( inters[k].cv1 == cv_index )
	    par1 = inters[k].par1;
	  else if ( inters[k].cv2 == cv_index )
	    par1 = inters[k].par2;

	}
	exact1 = k;
	if(par1 != -1) break;
      }
    }
    if( inters[index_pt2].cv1 == cv_index )
    {
      par2 = inters[index_pt2].par1;
      exact2 = index_pt2;
    }
    else if ( inters[index_pt2].cv2 == cv_index ) 
    {
      par2 = inters[index_pt2].par2;
      exact2 = index_pt2;
    }
    else
    {
      /* find the same pt that is on the curve */
      for(k=0;k<nb_inters;k++)
      {
	if(SMIsEqualPt(k, index_pt2, inters))
	{
	  if( inters[k].cv1 == cv_index )
	    par2 = inters[k].par1;
	  else if ( inters[k].cv2 == cv_index )
	    par2 = inters[k].par2;

	}
	exact2 = k;
	if(par2 != -1) break;
      }
    }

    d_par = (par1 + par2)/2;
    if(part_nb == 1) d_par = 3*(par1 + par2)/2;
    if(d_par > 1) d_par = 1;

    if(cv_index >= nb_cv)
    {
      if (OM_Gf_verbose_warning) printf("ERROR, Bad curve index\n");
      err_flag = TRUE;
      goto wrapup;
    }
    num_poles = bsp_cv[cv_index]->num_poles +2*bsp_cv[cv_index]->order - 1;

    if(part_geom != NULL)
    {
      (void)BSalloccv(bsp_cv[cv_index]->order,
		      num_poles,
		      bsp_cv[cv_index]->rational,
		      bsp_cv[cv_index]->num_boundaries ,
		      &(*part_geom)[i],
		      &rc);
      if(rc != BSSUCC && rc!=BSNULL) 
      {
	if (OM_Gf_verbose_warning) printf("ERROR Bad dynamic allocation ");
	err_flag = TRUE;
	goto wrapup;
      }
#ifdef	DEBUG
      printf("partof cv[%d] between %lf, and %lf\n", cv_index, par1, par2);

#endif

      (IGRboolean)BSpartofcv(&rc, bsp_cv[cv_index], par1, d_par,
			     par2, (*part_geom)[i]);
      if(rc != BSSUCC)  
      {
	if (OM_Gf_verbose_warning) printf("ERROR, Bad extraction of the part of bsp_cv \n");
	err_flag = TRUE;
	goto wrapup;
      }

      /* CORRECTION 22 JUNE 1993 if nb_part =1 d_par > par2 need also
	 to reverse the curve */

      if(par1 > par2 || d_par > par2) rev = 1;
      else rev = 0;
      if(rev)
      {
	(IGRboolean)BSrev_cv(&rc, (*part_geom)[i]);
	if(rc != BSSUCC)
	{
	  if (OM_Gf_verbose_warning) printf("ERROR, cannot reverse the curve\n");
	  err_flag = TRUE;
	  goto wrapup;
	}
      }
      /* June 21 1992 PB modify the curve and is not good , try with modifying only
       *   the weight of the last poles that we need without weight *********
       *
       *		if((*part_geom)[i]->rational){
       *			for(k=0;k<(*part_geom)[i]->num_poles;k++){
       *				(*part_geom)[i]->poles[3*k] =
       *				   (*part_geom)[i]->poles[3*k]/(*part_geom)[i]->weights[k];
       *				(*part_geom)[i]->poles[3*k+1] =
       *				   (*part_geom)[i]->poles[3*k+1]/(*part_geom)[i]->weights[k];
       *				(*part_geom)[i]->poles[3*k+2] =
       *				   (*part_geom)[i]->poles[3*k+2]/(*part_geom)[i]->weights[k];
       *			}
       *			(*part_geom)[i]->rational = FALSE;
       *			if((*part_geom)[i]->weights){
       *				free((*part_geom)[i]->weights);
       *				(*part_geom)[i]->weights = NULL;
       *			}
       *		}
       *********/

      if((*part_geom)[i]->rational)
      {
	/* June 21 1992 */

	(*part_geom)[i]->weights[0] = 1;
	(*part_geom)[i]->weights[(*part_geom)[i]->num_poles -1 ] = 1;
      }

      for(k=0;k<3;k++)
      {
	(*part_geom)[i]->poles[k] = inters[exact1].pt[k];
	(*part_geom)[i]->poles[3*( (*part_geom)[i]->num_poles -1) + k] = inters[exact2].pt[k];
      }
    }
    else
    {
      (void)BSalloccv(bsp_cv[cv_index]->order,
		      num_poles,
		      bsp_cv[cv_index]->rational,
		      bsp_cv[cv_index]->num_boundaries ,
		      &tmp_geom,
		      &rc);
      if(rc != BSSUCC && rc!=BSNULL) 
      {
	if (OM_Gf_verbose_warning) printf("ERROR Bad dynamic allocation ");
	err_flag = TRUE;
	goto wrapup;
      }

#ifdef	DEBUG
      printf("partof cv[%d] between %lf, and %lf\n", cv_index, par1, par2);

#endif
      (IGRboolean)BSpartofcv(&rc, bsp_cv[cv_index], par1, d_par,
			     par2, tmp_geom);
      if(rc != BSSUCC)  
      {
	if (OM_Gf_verbose_warning) printf("ERROR, Bad extraction of the part of bsp_cv \n");
	err_flag = TRUE;
	goto wrapup;
      }

      /* CORRECTION 22 JUNE 1993 if nb_part =1 d_par > par2 need also to reverse the curve */

      if(par1 > par2 || d_par > par2) rev = 1;
      else rev = 0;
      if(rev)
      {
	(IGRboolean)BSrev_cv(&rc, tmp_geom);
	if(rc != BSSUCC)
	{
	  if (OM_Gf_verbose_warning) printf("ERROR, cannot reverse the curve\n");
	  err_flag = TRUE;
	  goto wrapup;
	}
      }

      /* June 21 1992 PB modify the curve and is not good , try with modifying only
       *   the weight of the last poles that we need without weight *********
       *
       *		if(tmp_geom->rational){
       *			for(k=0;k<tmp_geom->num_poles;k++){
       *				tmp_geom->poles[3*k] =
       *				   tmp_geom->poles[3*k]/tmp_geom->weights[k];
       *				tmp_geom->poles[3*k+1] =
       *				   tmp_geom->poles[3*k+1]/tmp_geom->weights[k];
       *				tmp_geom->poles[3*k+2] =
       *				   tmp_geom->poles[3*k+2]/tmp_geom->weights[k];
       *			}
       *			tmp_geom->rational = FALSE;
       *			if(tmp_geom->weights){
       *				free(tmp_geom->weights);
       *				tmp_geom->weights = NULL;
       *			}
       *		}
       *******/
      if(tmp_geom->rational)
      {
	/* June 21 1992 */

	tmp_geom->weights[0] = 1;
	tmp_geom->weights[tmp_geom->num_poles -1 ] = 1;
      }
      for(k=0;k<3;k++)
      {
	tmp_geom->poles[k] = inters[exact1].pt[k];
	tmp_geom->poles[3*(tmp_geom->num_poles -1 )+ k] = inters[exact2].pt[k];
      }
    }
    if( part_id != NULL)
    {
      tmp_cst = (*cst);

      if(part_geom != NULL)
	tmp_cst.geometry = (char *) (*part_geom)[i];
      else
	tmp_cst.geometry = (char *) tmp_geom;

      stat = om$construct(msg = message GRbcsubbc.GRconstruct
			  (&tmp_cst),
			  classid = OPP_GRbcsubbc_class_id,
			  p_objid  = &(*part_id)[i].located_obj.objid,
			  osnum  = (*part_id)[i].located_obj.osnum );

      as$status(sts=stat);
      if (!(stat&1))
      {
	if (OM_Gf_verbose_warning) printf("GRbcsubbs.GRconstruct failed\n");
	(*part_id)[i].located_obj.objid = NULL_OBJID;
	err_flag = TRUE;
	goto wrapup;
      }
    }
    if(tmp_geom != NULL)
    {
      (IGRboolean)BSfreecv(&rc, tmp_geom);
      tmp_geom= NULL;
    }
  }

wrapup:

  if(tmp_geom != NULL)
  {
    (IGRboolean)BSfreecv(&rc, tmp_geom);
    tmp_geom= NULL;
  }

  if(err_flag == TRUE) 
  {
    if(part_geom != NULL && (*part_geom != NULL))
    {
      for(i=0;i<nb_part;i++)
      {
	if((*part_geom)[i] != NULL)
	{
	  (IGRboolean)BSfreecv(&rc, (*part_geom)[i]);
	  (*part_geom)[i]= NULL;
	}
      }
      _FREE(*part_geom);
    }
    if(part_id != NULL && (*part_id) != NULL)
    {
      for(i=0;i<nb_part;i++)
      {
	if(om$is_objid_valid(osnum = (*part_id)[i].located_obj.osnum,
			     objid = (*part_id)[i].located_obj.objid) & 1)
	{
	  stat = om$send(	msg = message GRgraphics.GRdelete(&msg,
								  tmp_cst.env_info),
				senderid = NULL_OBJID,
				targetid = (*part_id)[i].located_obj.objid ,
				targetos = (*part_id)[i].located_obj.osnum);
	  as$status(sts=stat);
	  (*part_id)[i].located_obj.objid = NULL_OBJID;
	}
      }
      _FREE(*part_id);
    }
    return(0);
  }
  else return(1);

}

/*25 ======================  SMCrtPartCv1 ======================

        Given an array of curves, The function creates the part of
        the curves between the intersection pts.

	part_id and part_geom (if not NULL) are allocated by the function of
	loop->nb_edge and must be deallocated by the function.

	each part_geom is allocated by the function and must be
	deallocated by the user.

        return(1) if ok
        else return(0).

*/

int	SMCrtPartCv1(nb_cv, bsp_cv, nb_inters,inters, cst, part_id, part_geom)
int			nb_cv;		/* (I) nb curves */
struct IGRbsp_curve	**bsp_cv;	/* (I) curves */
int			nb_inters;	/* (I) nb_intersection info */
struct SMinters		*inters;	/* (I) info on intersection */
struct GRvg_construct   *cst;		/* (I) construction list */
struct GRlc_info	**part_id;	/* (O) (NULL) partofcv id created*/
struct IGRbsp_curve	***part_geom;	/* (O) (NULL) partofcv geom */

/*.SMCrtPartCv1*/
{
  int			i,k, l, stat, index_pt1, rev, index_pt2,  num_poles;
  IGRboolean		err_flag;
  IGRdouble		par1, par2, d_par;
  BSrc			rc;
  long			msg;
  struct GRvg_construct   tmp_cst;
  struct IGRbsp_curve	*tmp_geom;

  if(bsp_cv == NULL || inters == NULL || cst == NULL )
  {
    if (OM_Gf_verbose_warning) printf("ERROR Invalid argument\n");
    return(0);
  }
  if(part_id == NULL && part_geom == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR Invalid argument\n");
    return(0);
  }
  tmp_geom = NULL;
  index_pt1 = index_pt2 = 0;

  if(part_id != NULL)
  {
    *part_id = NULL;
    *part_id = (struct GRlc_info *)malloc(nb_cv*sizeof(struct GRlc_info ));
    if(*part_id == NULL)
    {
      if (OM_Gf_verbose_warning) printf("ERROR Bad dynamic allocation ");
      err_flag = TRUE;
      goto wrapup;
    }
    for(i=0;i<nb_cv;i++) 
    {
      (*part_id)[i].located_obj.objid = NULL_OBJID;
      (*part_id)[i].located_obj.osnum = cst->env_info->md_id.osnum;
      (*part_id)[i].module_info = (*cst->env_info);
    }
  }

  if(part_geom != NULL)
  {
    *part_geom = NULL;
    *part_geom = (struct IGRbsp_curve **)malloc(nb_cv*sizeof(struct IGRbsp_curve * ));
    if(*part_geom == NULL)
    {
      if (OM_Gf_verbose_warning) printf("ERROR Bad dynamic allocation ");
      err_flag = TRUE;
      goto wrapup;
    }
    for(i=0;i<nb_cv;i++) (*part_geom)[i] = NULL;
  }

  err_flag = FALSE;

  for(i=0;i<nb_cv;i++)
  {
    par1 = par2 = 0;
    for(k=0;k<nb_inters;k++)
      if(inters[k].cv1 == i || inters[k].cv2 == i)
      {
	index_pt1 = k;
	if(inters[k].cv1 == i) par1 = inters[index_pt1].par1;
	else par1 = inters[index_pt1].par2;
	break;
      }
    for(l=k+1;l<nb_inters;l++)
      if(inters[l].cv1 == i || inters[l].cv2 == i)
      {
	index_pt2 = l;
	if(inters[k].cv1 == i) par2 = inters[index_pt1].par1;
	else par2 = inters[index_pt1].par2;
	break;
      }

    d_par = (par1 + par2)/2;

    num_poles = bsp_cv[i]->num_poles +2*bsp_cv[i]->order - 1;

    if(part_geom != NULL)
    {
      (void)BSalloccv(bsp_cv[i]->order,
		      num_poles,
		      bsp_cv[i]->rational,
		      bsp_cv[i]->num_boundaries ,
		      &(*part_geom)[i],
		      &rc);
      if(rc != BSSUCC && rc!=BSNULL) 
      {
	if (OM_Gf_verbose_warning) printf("ERROR Bad dynamic allocation ");
	err_flag = TRUE;
	goto wrapup;
      }

      (IGRboolean)BSpartofcv(&rc, bsp_cv[i], par1, d_par,
			     par2, (*part_geom)[i]);
      if(rc != BSSUCC)  
      {
	if (OM_Gf_verbose_warning) printf("ERROR, Bad extraction of the part of bsp_cv \n");
	err_flag = TRUE;
	goto wrapup;
      }

      /* CORRECTION 22 JUNE 1993 if nb_part =1 d_par > par2 need also to reverse the curve */

      if(par1 > par2 || d_par > par2) rev = 1;
      else rev = 0;
      if(rev)
      {
	(IGRboolean)BSrev_cv(&rc, (*part_geom)[i]);
	if(rc != BSSUCC)
	{
	  if (OM_Gf_verbose_warning) printf("ERROR, cannot reverse the curve\n");
	  err_flag = TRUE;
	  goto wrapup;
	}
      }
      /* June 21 1992 PB modify the curve and is not good , try with modifying only
       *   the weight of the last poles that we need without weight *********
       *
       *		if((*part_geom)[i]->rational){
       *			for(k=0;k<(*part_geom)[i]->num_poles;k++){
       *				(*part_geom)[i]->poles[3*k] =
       *				   (*part_geom)[i]->poles[3*k]/(*part_geom)[i]->weights[k];
       *				(*part_geom)[i]->poles[3*k+1] =
       *				   (*part_geom)[i]->poles[3*k+1]/(*part_geom)[i]->weights[k];
       *				(*part_geom)[i]->poles[3*k+2] =
       *				   (*part_geom)[i]->poles[3*k+2]/(*part_geom)[i]->weights[k];
       *			}
       *			(*part_geom)[i]->rational = FALSE;
       *			if((*part_geom)[i]->weights){
       *				free((*part_geom)[i]->weights);
       *				(*part_geom)[i]->weights = NULL;
       *			}
       *		}
       ***********/
      if((*part_geom)[i]->rational)
      {
	/* June 21 1992 */

	(*part_geom)[i]->weights[0] = 1;
	(*part_geom)[i]->weights[(*part_geom)[i]->num_poles -1 ] = 1;
      }

      for(k=0;k<3;k++)
      {
	(*part_geom)[i]->poles[k] = inters[index_pt1].pt[k];
	(*part_geom)[i]->poles[3*( (*part_geom)[i]->num_poles -1) + k] = inters[index_pt2].pt[k];
      }
    }
    else
    {
      (void)BSalloccv(bsp_cv[i]->order,
		      num_poles,
		      bsp_cv[i]->rational,
		      bsp_cv[i]->num_boundaries ,
		      &tmp_geom,
		      &rc);
      if(rc != BSSUCC && rc!=BSNULL) 
      {
	if (OM_Gf_verbose_warning) printf("ERROR Bad dynamic allocation ");
	err_flag = TRUE;
	goto wrapup;
      }

      (IGRboolean)BSpartofcv(&rc, bsp_cv[i], par1, d_par,
			     par2, tmp_geom);
      if(rc != BSSUCC)  
      {
	if (OM_Gf_verbose_warning) printf("ERROR, Bad extraction of the part of bsp_cv \n");
	err_flag = TRUE;
	goto wrapup;
      }

      /* CORRECTION 22 JUNE 1993 if nb_part =1 d_par > par2 need also to reverse the curve */

      if(par1 > par2 || d_par > par2) rev = 1;
      else rev = 0;
      if(rev)
      {
	(IGRboolean)BSrev_cv(&rc, tmp_geom);
	if(rc != BSSUCC)
	{
	  if (OM_Gf_verbose_warning) printf("ERROR, cannot reverse the curve\n");
	  err_flag = TRUE;
	  goto wrapup;
	}
      }

      /* June 21 1992 PB modify the curve and is not good , try with modifying only
       *   the weight of the last poles that we need without weight *********
       *
       *		if(tmp_geom->rational){
       *			for(k=0;k<tmp_geom->num_poles;k++){
       *				tmp_geom->poles[3*k] =
       *				   tmp_geom->poles[3*k]/tmp_geom->weights[k];
       *				tmp_geom->poles[3*k+1] =
       *				   tmp_geom->poles[3*k+1]/tmp_geom->weights[k];
       *				tmp_geom->poles[3*k+2] =
       *				   tmp_geom->poles[3*k+2]/tmp_geom->weights[k];
       *			}
       *			tmp_geom->rational = FALSE;
       *			if(tmp_geom->weights){
       *				free(tmp_geom->weights);
       *				tmp_geom->weights = NULL;
       *			}
       *		}
       *********/
      if(tmp_geom->rational)
      {
	/* June 21 1992 */

	tmp_geom->weights[0] = 1;
	tmp_geom->weights[tmp_geom->num_poles -1 ] = 1;
      }

      for(k=0;k<3;k++)
      {
	tmp_geom->poles[k] = inters[index_pt1].pt[k];
	tmp_geom->poles[3*(tmp_geom->num_poles -1 )+ k] = inters[index_pt2].pt[k];
      }
    }
    if( part_id != NULL)
    {
      tmp_cst = (*cst);

      if(part_geom != NULL)
	tmp_cst.geometry = (char *) (*part_geom)[i];
      else
	tmp_cst.geometry = (char *) tmp_geom;

      stat = om$construct(msg = message GRbcsubbc.GRconstruct
			  (&tmp_cst),
			  classid = OPP_GRbcsubbc_class_id,
			  p_objid  = &(*part_id)[i].located_obj.objid,
			  osnum  = (*part_id)[i].located_obj.osnum );

      as$status(sts=stat);
      if (!(stat&1))
      {
	if (OM_Gf_verbose_warning) printf("GRbcsubbs.GRconstruct failed\n");
	(*part_id)[i].located_obj.objid = NULL_OBJID;
	err_flag = TRUE;
	goto wrapup;
      }
    }
    if(tmp_geom != NULL)
    {
      (IGRboolean)BSfreecv(&rc, tmp_geom);
      tmp_geom= NULL;
    }
  }

wrapup:

  if(tmp_geom != NULL)
  {
    (IGRboolean)BSfreecv(&rc, tmp_geom);
    tmp_geom= NULL;
  }

  if(err_flag == TRUE) 
  {
    if(part_geom != NULL && (*part_geom != NULL))
    {
      for(i=0;i<nb_cv;i++)
      {
	if((*part_geom)[i] != NULL)
	{
	  (IGRboolean)BSfreecv(&rc, (*part_geom)[i]);
	  (*part_geom)[i]= NULL;
	}
      }
      _FREE(*part_geom);
    }
    if(part_id != NULL && (*part_id) != NULL)
    {
      for(i=0;i<nb_cv;i++)
      {
	if(om$is_objid_valid(osnum = (*part_id)[i].located_obj.osnum,
			     objid = (*part_id)[i].located_obj.objid) & 1)
	{
	  stat = om$send(	msg = message GRgraphics.GRdelete(&msg,
								  tmp_cst.env_info),
				senderid = NULL_OBJID,
				targetid = (*part_id)[i].located_obj.objid ,
				targetos = (*part_id)[i].located_obj.osnum);
	  as$status(sts=stat);
	  (*part_id)[i].located_obj.objid = NULL_OBJID;
	}
      }
      _FREE(*part_id);
    }
    return(0);
  }
  else return(1);

}

/*26 ======================  SMGetSfintpt ======================

	Given the intersection points (intersection of 3 surfaces)
	Get the surfaces index and fill the structure SMExactInt.

	IntPts->sf.geom are allocated by the function and must be
	deallocated by the user.

        return(1) if ok
        else return(0).

*/

int	SMGetSfintpt(nb_inters, inters, cvinters, lc_obj, typesf, IntPts)
int			nb_inters;	/* (I) nb pts of intersection */
struct SMinters		*inters;	/* (I) info on pts intersection */
struct SMsfinters	*cvinters;	/* (I) def of intersection curves */
struct GRlc_info	*lc_obj;	/* (I) input surfaces */
int			*typesf;	/* (I) type of surfaces */
struct SMExactInt	*IntPts	;	/* (O) exact intersection pts */

/*.SMGetSfintpt*/
{
  int			i,k, l,stat, nb_cv,cvindex[2], nb_surf, *surf_index;
  long			msg;
  IGRboolean		isuccess, world, compute_new, cv_type, comp_type, err_flag;
  BSrc			rc;
  IGRdouble		partolbasis, knot_tol1, knot_tol2, knot_tol3;

  if(nb_inters == 0 || cvinters == NULL || inters == NULL || lc_obj == NULL || IntPts == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR Invalid argument\n");
    return(0);
  }

  __enterFunction ( name = "SMGetSfintpt", argfmt = "nb_inters = %d",  args = `nb_inters` );

  err_flag = FALSE;
  knot_tol1= knot_tol2=knot_tol3 = 0;

  for(k=0;k<nb_inters;k++)
    for(i=0;i<3;i++) IntPts[k].surf[i].geom = NULL;

  for(k=0;k<nb_inters;k++)
  {
    nb_cv=2;
    cvindex[0] = inters[k].cv1;
    cvindex[1] = inters[k].cv2;

    stat = SMGetNbSurfs(nb_cv, cvindex, cvinters, &nb_surf, &surf_index);
    if(!(stat & 1))
    {
      if (OM_Gf_verbose_warning) printf("ERROR SMGetNbSurfs\n");
      err_flag = TRUE;
      goto wrapup;
    }

    /* this function cannot be applied for curves limitating or
       for composite surface (cannot getgeom) */

    cv_type   = FALSE;
    comp_type = FALSE;
    for(i=0; i< nb_surf; i++)
    {
      if(typesf[surf_index[i]] == CURV   ) cv_type   = TRUE;
      if(typesf[surf_index[i]] == COMP_SF) comp_type = TRUE;
    }

    __printf ( "k = %d, nb_surf = %d, cv_type = %d, comp_type = %d", `k, nb_surf, cv_type, comp_type` );

    if(nb_surf != 3)
    {
//    if(cv_type == TRUE)	// HF: 02/26/98 Changed cv_type to comp_type ==>> Bounded Surface works better (always ?!?!?)
      if(comp_type == TRUE)
      {
	for(l=0;l<3;l++)
	  IntPts[k].point[l] = inters[k].pt[l];

	i = 0;
	while(i<nb_surf)
	{
	  IntPts[k].surf[i].index = surf_index[0];
	  IntPts[k].surf[i].typesf= typesf[surf_index[0]];
	  i++;
	}
	continue;
      }
      if (OM_Gf_verbose_warning) printf("ERROR , Intersection pt must be an intersection of 3 surfaces\n");
      err_flag = TRUE;
      goto wrapup;
    }

    if (cv_type == TRUE || comp_type == TRUE)
    {
      for(l=0;l<3;l++)
	IntPts[k].point[l] = inters[k].pt[l];
      for(i=0;i<nb_surf;i++)
      {
	IntPts[k].surf[i].index = surf_index[0];
	IntPts[k].surf[i].typesf= typesf[surf_index[0]];
      }

      continue;
    }

    for(i=0;i<3;i++)
    {
      stat = SMFillSfGeom(surf_index[0], lc_obj, typesf, &inters[k], &IntPts[k].surf[i]);
      if(!(stat & 1))
      {
	if (OM_Gf_verbose_warning) printf("ERROR SMFillSfGeom\n");
	err_flag = TRUE;
	goto wrapup;
      }
      world = TRUE;
      compute_new = FALSE;

      stat = om$send(msg = message EMSsubbs.EMpartolbasis(&msg,
							  &lc_obj[surf_index[i]].module_info.md_env.matrix_type,
							  lc_obj[surf_index[i]].module_info.md_env.matrix,
							  &world, compute_new,
							  &partolbasis),
		     senderid = NULL_OBJID,
		     targetid = lc_obj[surf_index[i]].located_obj.objid,
		     targetos = lc_obj[surf_index[i]].located_obj.osnum );
      as$status(sts = stat);
      if (!(stat&msg&1))
      {
	if (OM_Gf_verbose_warning) printf("ERROR EMSsubbs.EMpartolbasis\n");
	err_flag = TRUE;
	goto wrapup;
      }

      if      (i == 0) knot_tol1 = partolbasis;
      else if (i == 1) knot_tol2 = partolbasis;
      else             knot_tol3 = partolbasis;
    }
    (void)BStrpsfiter(
		      IntPts[k].surf[0].geom,
		      IntPts[k].surf[1].geom,
		      IntPts[k].surf[2].geom,
		      knot_tol1,
		      knot_tol2,
		      knot_tol3,
		      &IntPts[k].surf[0].u_par,
		      &IntPts[k].surf[0].v_par,
		      &IntPts[k].surf[1].u_par,
		      &IntPts[k].surf[1].v_par,
		      &IntPts[k].surf[2].u_par,
		      &IntPts[k].surf[2].v_par,
		      IntPts[k].point,
		      &isuccess,
		      &rc);
    if(rc != BSSUCC)
    {
      if (OM_Gf_verbose_warning) printf("ERROR BStrpsfiter\n");
      err_flag = TRUE;
      goto wrapup;
    }
  }

wrapup:

  _FREE(surf_index);

  if(err_flag == TRUE)
  {
    for(i=0;i<nb_inters;i++)
      for(k=0;k<3;k++) SMFreeSfGeom( &IntPts[i].surf[k]);

    __exit_error_Function ( name = "SMGetSfintpt" );
    return(0);
  }
  else
  {
    __exitFunction ( name = "SMGetSfintpt" );
    return (1);
  }
}

/*27 ======================  SMChgInters ======================

	Function that modifies the structure SMinters, with
	the exact intersection points.

        return(1) if ok
        else return(0).

*/

int	SMChgInters(nb_inters, inters, cvinters, IntPts)
int			nb_inters;	/* (I) nb pts of intersection */
struct SMinters		*inters;	/* (I/O) info on pts intersection */
struct SMsfinters	*cvinters;	/* (I) def of intersection curves */
struct SMExactInt	*IntPts	;	/* (I) exact intersection pts */

/*.SMChgInters*/
{
  int			i,k;
  struct IGRbsp_curve	*curve;
  IGRpoint		base;
  IGRdouble		dist;
  BSrc			rc;

  for(i=0;i<nb_inters;i++)
  {
    for(k=0;k<3;k++) inters[i].pt[k] = IntPts[i].point[k];
    curve = cvinters[inters[i].cv1].cv_geom;
    (void)BSmdstptcv(curve, IntPts[i].point, &inters[i].par1,
		     base, &dist, &rc);
    if(rc != BSSUCC)
    {
      if (OM_Gf_verbose_warning) printf("ERROR BSmdstptcv\n");
      goto wrapup;
    }
    curve = cvinters[inters[i].cv2].cv_geom;
    (void)BSmdstptcv(curve, IntPts[i].point, &inters[i].par2,
		     base, &dist, &rc);
    if(rc != BSSUCC)
    {
      if (OM_Gf_verbose_warning) printf("ERROR BSmdstptcv\n");
      goto wrapup;
    }
  }
  return(1);

wrapup:
  return(0);

}

/*28 ======================  SMFillSfGeom ======================

	Function that fills (and alloc for the geom) the structure SMIntOnSf.

        return(1) if ok
        else return(0).

*/

int	SMFillSfGeom(surf_index, lc_obj, typesf, inters, surf)
int			surf_index; /* (I) index of the surface */
struct GRlc_info	*lc_obj;    /* (I) input surfaces */
int			*typesf;    /* (I) type of surfaces */
struct SMinters		*inters;    /* (I) info on the intersection pt*/
struct SMIntOnSf	*surf;      /* (I/O) structure to fill */

/*.SMFillSfGeom*/
{
  int			l, stat;
  long			size, msg, nb_point;
  struct IGRplane		plane;
  IGRdouble		dist, pt[6], scale;
  IGRpoint		bx[2], base, min, max;
  IGRboolean		in_range, err_flag;
  BSrc			rc;

  err_flag = FALSE;

  surf->index = surf_index;
  surf->geom = NULL;
  surf->typesf = typesf[surf->index];

  if(surf->typesf == PLAN)
  {
    plane.point = &pt[0];
    plane.normal= &pt[3];

    stat = om$send (msg = message GRvg.GRdetplane(&msg,
						  &lc_obj[surf->index].module_info.md_env.matrix_type,
						   lc_obj[surf->index].module_info.md_env.matrix,
						  &plane),
		    senderid = NULL_OBJID,
		    targetid = lc_obj[surf->index].located_obj.objid,
		    targetos = lc_obj[surf->index].located_obj.osnum );

    as$status(sts = stat);
    if(!(stat & msg & 1))
    {
      if (OM_Gf_verbose_warning) printf("ERROR in GRvg.GRdetplane\n" );
      err_flag = TRUE;
      goto wrapup;
    }
    scale = 1.5;

    for(l=0;l<3;l++) bx[0][l] = inters->pt[l];
    for(l=0;l<3;l++) bx[1][l] = plane.point[l];
    nb_point = 2;

    (IGRboolean)BSbx2(&rc, &nb_point, bx, NULL, min, max);
    if(rc != BSSUCC)
    {
      if (OM_Gf_verbose_warning) printf("ERROR BSbxx2\n");
      err_flag = TRUE;
      goto wrapup;
    }
    // HF: 10/14/98 Fix for TR 179801486
    if ( fabs(max[0]-min[0]) < 1e-10 &&
	 fabs(max[1]-min[1]) < 1e-10 &&
	 fabs(max[2]-min[2]) < 1e-10)
    {
      max[0] += 10;
      max[1] += 10;
      max[2] += 10;
      min[0] -= 10;
      min[1] -= 10;
      min[2] -= 10;
    }
    
    surf->geom = (struct IGRbsp_surface *)malloc((unsigned)
						 (sizeof(struct IGRbsp_surface)));
    if(surf->geom == NULL)
    {
      if (OM_Gf_verbose_warning) printf("ERROR Bad allocation\n");
      err_flag = TRUE;
      goto wrapup;
    }

    surf->geom->weights = NULL;
    surf->geom->poles = NULL;
    surf->geom->u_knots = NULL;
    surf->geom->v_knots = NULL;

    surf->geom->poles = (IGRdouble *)malloc (4*sizeof(IGRpoint));
    if(surf->geom->poles == NULL)
    {
      if (OM_Gf_verbose_warning) printf("ERROR Bad allocation\n");
      err_flag = TRUE;
      goto wrapup;
    }
    surf->geom->u_knots = (IGRdouble *)malloc (4*sizeof(IGRdouble));
    if(surf->geom->u_knots == NULL)
    {
      if (OM_Gf_verbose_warning) printf("ERROR Bad allocation\n");
      err_flag = TRUE;
      goto wrapup;
    }
    surf->geom->v_knots = (IGRdouble *)malloc(4*sizeof(IGRdouble));

    if(surf->geom->v_knots == NULL)
    {
      if (OM_Gf_verbose_warning) printf("ERROR Bad allocation\n");
      err_flag = TRUE;
      goto wrapup;
    }
    __printf ( ">>>>> BSplptnorrg: min          = %lg, %lg, %lg", `min[0], min[1], min[2]` );
    __printf ( ">>>>> BSplptnorrg: max          = %lg, %lg, %lg", `max[0], max[1], max[2]` );
    __printf ( ">>>>> BSplptnorrg: plane.point  = %lg, %lg, %lg", `plane.point[0], plane.point[1], plane.point[2]` );
    __printf ( ">>>>> BSplptnorrg: plane.normal = %lg, %lg, %lg", `plane.normal[0], plane.normal[1], plane.normal[2]` );
    
    (void)BSplptnorrg(min, max, plane.point, plane.normal,
		      scale, &in_range, surf->geom, &rc);
    __printf ( "<<<<< BSplptnorrg: in_range     = %d, rc = %d", `in_range, rc` );

    if(rc != BSSUCC)
    {
      if (OM_Gf_verbose_warning) printf("ERROR BSplptnorrg\n");
      err_flag = TRUE;
      goto wrapup;
    }
  }
  else
  {
    stat = om$send(msg = message GRvg.GRgetsize(&msg,
						&lc_obj[surf->index].module_info.md_env.matrix_type,
						lc_obj[surf->index].module_info.md_env.matrix,
						&size),
		   senderid = NULL_OBJID,
		   targetid = lc_obj[surf->index].located_obj.objid,
		   targetos = lc_obj[surf->index].located_obj.osnum );
    as$status(sts = stat);
    if (!(stat&msg&1))
    {
      if (OM_Gf_verbose_warning) printf("ERROR GRvg.GRgetsize\n");
      err_flag = TRUE;
      goto wrapup;
    }

    surf->geom = (struct IGRbsp_surface *) malloc(size*sizeof (struct IGRbsp_surface));

    if(surf->geom == NULL)
    {
      if (OM_Gf_verbose_warning) printf("ERROR , Bad allocation\n");
      err_flag = TRUE;
      goto wrapup;
    }

    stat = om$send(msg = message GRvg.GRgetgeom(&msg,
						&lc_obj[surf->index].module_info.md_env.matrix_type,
						lc_obj[surf->index].module_info.md_env.matrix,
						(char *) surf->geom),
		   senderid = NULL_OBJID,
		   targetid = lc_obj[surf->index].located_obj.objid,
		   targetos = lc_obj[surf->index].located_obj.osnum );
    as$status(sts = stat);
    if (!(stat&msg&1))
    {
      if (OM_Gf_verbose_warning) printf("ERROR GRvg.GRgetgeom\n");
      err_flag = TRUE;
      goto wrapup;
    }

  }
  (IGRboolean) BSmdistptsf(&rc, surf->geom, inters->pt,
			   &surf->u_par, &surf->v_par, base, &dist);

  if(rc != BSSUCC)
  {
    if (OM_Gf_verbose_warning) printf("ERROR BSmdistptsf\n");
    err_flag = TRUE;
    goto wrapup;
  }

wrapup:
  if(err_flag == TRUE)
  {
    SMFreeSfGeom(surf);
    return(0);
  }
  else return(1);
}

/*29 ======================  SMFreeSfGeom ======================

	Function that free the structure SMIntOnSf.
        always return(1)

*/

int	SMFreeSfGeom(surf)
struct SMIntOnSf	*surf;     /* (I) structure to free */

/*.SMFreeSfGeom*/
{
  if(surf->geom != NULL)
  {
    if(surf->typesf == PLAN)
    {
      if(surf->geom->poles)
      {
	_FREE(surf->geom->poles);
	surf->geom->poles = NULL;
      }
      if(surf->geom->u_knots)
      {
	_FREE(surf->geom->u_knots);
	surf->geom->u_knots = NULL;
      }
      if(surf->geom->v_knots)
      {
	_FREE(surf->geom->v_knots);
	surf->geom->v_knots = NULL;
      }
    }
    _FREE(surf->geom);
    surf->geom = NULL;
  }

  return(1);

}

/*30 ======================  SMGetOrderSfLoop1 ======================

	Find the loop (if it exists) that uses surfaces in their
	order of input. If it doesn't exist, index_loop = -1.

	The function only looks at the loops that correspond to the
	given array of index.

        return(1) if ok
        else return(0).

*/

int	SMGetOrderSfLoop1(loop, nb_index, index, sl_arc, SMsfinters, index_loop)
struct loop_on_surf	*loop	;	/* (I) input loops (=sl_arc index) */
int			nb_index;       /* (I) nb of loop index */
int			*index;         /* (I) loop index */
struct sl_arc		*sl_arc;	/* (I) sl_arc definition */
struct SMsfinters	*SMsfinters; 	/* (I) surf intersection def */
int			*index_loop;    /* (O) ordered loop */
/*.SMGetOrderSfLoop1*/
{
  int		min, min_index, i,k, stat, nb_sf, *sfindex;
  IGRboolean	found;

  if( loop == NULL || sl_arc == NULL || SMsfinters == NULL || nb_index == 0 ||
      index == NULL || index_loop == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR Invalid argument\n");
    return(0);
  }
  sfindex = NULL;
  min_index = 0;

  *index_loop = -1;

  for(i=0;i<nb_index;i++)
  {
    found = TRUE;
    nb_sf = 0;

    stat = SMGetSfInLoop(&loop->one_loop[index[i]], sl_arc, SMsfinters,
			 &nb_sf, &sfindex);
    if(stat != 1)
    {
      if (OM_Gf_verbose_warning) printf("ERROR SMGetSfInLoop\n");
      goto wrapup;
    }
    if(nb_sf == 0) 
    {
      _FREE(sfindex);
      continue;
    }
    min=1e6;
    for(k=0;k<nb_sf;k++)
    {
      if(min > sfindex[k]) 
      {
	min = sfindex[k];
	min_index = k;
      }
    }
    for(k=0;k<nb_sf;k++)
    {
      if(k == min_index-1)continue;
      else if(k == nb_sf-1 && !(sfindex[k]+1 == sfindex[0]))
      {
	found = FALSE;
	break;
      }
      else if(!(sfindex[k]+1 == sfindex[k+1] ))
      {
	found = FALSE;
	break;
      }
    }

    if(found == TRUE) 
    {
      *index_loop = index[i];
      _FREE(sfindex);
      break;
    }
    _FREE(sfindex);
  }

  _FREE(sfindex);
  return(1);

wrapup:
  _FREE(sfindex);
  return(0);
}

end implementation Root;
