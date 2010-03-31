/* ###################   APOGEE COMPILED   ################## */
class implementation ECtpanaly;

#include <stdio.h>                      /* FILE         */
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "igrtypedef.h"
#include "TOdsl.h"
#include "TOtopology.h"
#include "TOstruct1.h"
#include "TOproto_ta.h"
#include "TOproto_ds.h"
#include "bserr.h"
#include "bstypes.h"
#include "bsparameters.h"
#include "bsarclen.h"
/*
Name

    TOpartedge.I

Abstract

    text

Synopsis

sts=TOpartedge(struct topology *topo;
               struct edge **ed;
               IGRint ovlap_type[2][4];
               IGRdouble bsovlap[2][4]);

   topo             - main data structure of topology
   ed               - pointer of the edges in the topological
                      data structures
   ovlap_type[2][4] - overlap at start,middle or end
   bsovlap[2][4])   - parameters of the overlap interval

Description

  This function performs the splitting of edges in the data
  structures of the topology feature

Return Value

  sts=0         - if the "stitching" is successful, i.e. there is at
		  at least one overlap, which is successfully stitched.

  sts=-1        - if the "stitching" is unsuccessful. This would imply
		  that either there was no overlap, or that the overlap
  		  did not survive the validation test (gap in the 
		  overlap).

Notes

Index

Keywords

History

B.Burkhardt 29-Mar-94 Created 
B.Burkhardt 10-Sep-94 Corrections for multiple splitted edges
*/

int TOpartedge(struct topology *topo,
               struct edge **ed,
               IGRint ovlap_type[2][4],
               IGRdouble bsovlap[2][4])

{
   short	   edg_ix;
   double	   valdiff[2];
   double       tmp_begin;
   double       tmp_end;
   int             ii = NULL;
   int             sts = NULL;
   int             num_cand;
   double          para[2][2];
   struct point    *end_pts[2][2];
   struct edge     *new_ed[2];
   struct edge     *te_cand[5];
   struct top_edge *new_te;
   struct elist    *elhead;
   struct elist    *eltail;
   
   for(edg_ix=0;edg_ix<2;edg_ix++)
      valdiff[edg_ix] = bsovlap[edg_ix][1] - bsovlap[edg_ix][0];
   num_cand = NULL;
   for(edg_ix=0;edg_ix<2;edg_ix++)
   {
      if((ovlap_type[edg_ix][0] == EMS_O_begin &&
          ovlap_type[edg_ix][1] == EMS_O_begin) ||
         (ovlap_type[edg_ix][0] == EMS_O_end &&
          ovlap_type[edg_ix][1] == EMS_O_end))
      {
         sts = NULL;
         goto wrapup;
      }   
   }   
   for(edg_ix=0;edg_ix<2;edg_ix++)
   {
      tmp_begin = EMS_O_begin;
      tmp_end   = EMS_O_end;
      new_ed[0] = NULL;
      new_ed[1] = NULL;
/*
      if part edge transform overlap paramters
*/
      if (ed[edg_ix]->status == 4)
      {
         tmp_begin = ed[edg_ix]->ext->bound[0].param;
         tmp_end   = ed[edg_ix]->ext->bound[1].param;
         if((valdiff[edg_ix]>NULL && (bsovlap[edg_ix][0]>=tmp_end ||
                                      bsovlap[edg_ix][1]<=tmp_begin))||
            (valdiff[edg_ix]<NULL && (bsovlap[edg_ix][1]>=tmp_end ||
                                      bsovlap[edg_ix][0]<=tmp_begin)))
         {
            sts = NULL;
            goto wrapup;
         }
               
      } /* if (ed[edg_ix]->status == 4) */

      if (ovlap_type[edg_ix][0] == EMS_O_middle &&
          ovlap_type[edg_ix][1] == EMS_O_middle)
      {
         if (valdiff[edg_ix] > 0) 
         {
            end_pts[0][0] = ed[edg_ix]->p1;
            end_pts[0][1] = (valdiff[1-edg_ix]>NULL) ?
                           ed[1-edg_ix]->p2:ed[1-edg_ix]->p1; 
            end_pts[1][0] = end_pts[0][1];
            end_pts[1][1] = ed[edg_ix]->p2;

            para[0][0] = tmp_begin;
            para[0][1] = bsovlap[edg_ix][1];
            para[1][0] = bsovlap[edg_ix][1];
            para[1][1] = tmp_end;
            sts = TOadd_pe(topo,ed[edg_ix],para,end_pts, new_ed);
            if(sts)
            {
               return(-1);
            }
/*
            the first interval is singular TOadd_pe didn't create
            edges, use the original edge for top edge
*/
            if(!new_ed[0])
            {
               new_ed[0] = ed[edg_ix];
            } 
            end_pts[0][0] = (valdiff[1-edg_ix]>NULL) ?
                            ed[1-edg_ix]->p1:ed[1-edg_ix]->p2; 
            end_pts[0][1] = (valdiff[1-edg_ix]>NULL) ?
                            ed[1-edg_ix]->p2:ed[1-edg_ix]->p1; 
            end_pts[1][0] = ed[edg_ix]->p1;
            end_pts[1][1] = end_pts[0][0];

            para[0][0] = bsovlap[edg_ix][0];
            para[0][1] = bsovlap[edg_ix][1];
            para[1][0] = tmp_begin;
            para[1][1] = bsovlap[edg_ix][0]; 
            sts = TOadd_pe(topo,new_ed[0],para,end_pts, new_ed);
            if(sts)
            {
               return(-1);
            }
         }
         else
         {
            end_pts[0][0] = (valdiff[1-edg_ix]>NULL) ?
                            ed[1-edg_ix]->p1:ed[1-edg_ix]->p2; 
            end_pts[0][1] = ed[edg_ix]->p1;
            end_pts[1][0] = ed[edg_ix]->p2;
            end_pts[1][1] = end_pts[0][0];

            para[0][0] = bsovlap[edg_ix][1];
            para[0][1] = tmp_end;
            para[1][0] = tmp_begin;
            para[1][1] = bsovlap[edg_ix][1];
            sts = TOadd_pe(topo,ed[edg_ix],para,end_pts, new_ed);
            if(sts)
            {
               return(-1);
            }
/*
            the first interval is singular TOadd_pe didn't create
            edges, use the original edge for top edge
*/
            if(!new_ed[0])
            {
               new_ed[0] = ed[edg_ix];
            } 
            end_pts[0][0] = (valdiff[1-edg_ix]>NULL) ?
                            ed[1-edg_ix]->p1:ed[1-edg_ix]->p2; 
            end_pts[0][1] = (valdiff[1-edg_ix]>NULL) ?
                            ed[1-edg_ix]->p2:ed[1-edg_ix]->p1; 
            end_pts[1][0] = end_pts[0][1];
            end_pts[1][1] = ed[edg_ix]->p1;

            para[0][0] = bsovlap[edg_ix][1];
            para[0][1] = bsovlap[edg_ix][0];
            para[1][0] = bsovlap[edg_ix][0];
            para[1][1] = tmp_end;
            sts = TOadd_pe(topo,new_ed[0],para,end_pts, new_ed);
            if(sts)
            {
               return(-1);
            }
         }
      }
      else if(ovlap_type[edg_ix][0] == EMS_O_middle &&
              (ovlap_type[edg_ix][1] == EMS_O_begin ||
               ovlap_type[edg_ix][1] == EMS_O_end))
      {
         if (valdiff[edg_ix] > 0) 
         {
            end_pts[0][0] = (valdiff[1-edg_ix]>NULL) ?
                            ed[1-edg_ix]->p1 : ed[1-edg_ix]->p2;
            end_pts[0][1] = ed[edg_ix]->p2;
            end_pts[1][0] = ed[edg_ix]->p1;
            end_pts[1][1] = end_pts[0][0];

            para[0][0] = bsovlap[edg_ix][0];
            para[0][1] = bsovlap[edg_ix][1];
            para[1][0] = tmp_begin; 
            para[1][1] = bsovlap[edg_ix][0];
         }
         else
         {
            end_pts[0][0] = (valdiff[1-edg_ix]>NULL) ?
                            ed[1-edg_ix]->p1 : ed[1-edg_ix]->p2;
            end_pts[0][1] = ed[edg_ix]->p1;
            end_pts[1][0] = ed[edg_ix]->p2;
            end_pts[1][1] = end_pts[0][0];
                               
            para[0][0] = bsovlap[edg_ix][1];
            para[0][1] = bsovlap[edg_ix][0];
            para[1][0] = bsovlap[edg_ix][0];
            para[1][1] = tmp_end; 
         }
         sts = TOadd_pe(topo,ed[edg_ix],para,end_pts, new_ed);
         if(sts)
         {
            return(-1);
         }
      }
      else if((ovlap_type[edg_ix][0] == EMS_O_begin ||
               ovlap_type[edg_ix][0] == EMS_O_end) &&
               ovlap_type[edg_ix][1] == EMS_O_middle)
      {
         if (valdiff[edg_ix] > 0) 
         {
            end_pts[0][0] = ed[edg_ix]->p1;
            end_pts[0][1] = (valdiff[1-edg_ix]>NULL) ?
                            ed[1-edg_ix]->p2 : ed[1-edg_ix]->p1;
            end_pts[1][0] = end_pts[0][1];
            end_pts[1][1] = ed[edg_ix]->p2;

            para[0][0] = bsovlap[edg_ix][0];
            para[0][1] = bsovlap[edg_ix][1]; 
            para[1][0] = bsovlap[edg_ix][1];
            para[1][1] = tmp_end;
         }
         else
         {
            end_pts[0][0] = ed[edg_ix]->p2;
            end_pts[0][1] = (valdiff[1-edg_ix]>NULL) ?
                            ed[1-edg_ix]->p2 : ed[1-edg_ix]->p1;
            end_pts[1][0] = end_pts[0][1];
            end_pts[1][1] = ed[edg_ix]->p1;

            para[0][0] = bsovlap[edg_ix][1];
            para[0][1] = bsovlap[edg_ix][0]; 
            para[1][0] = tmp_begin;
            para[1][1] = bsovlap[edg_ix][1];
         }
         sts = TOadd_pe(topo,ed[edg_ix],para,end_pts, new_ed);
         if(sts)
         {
            return(-1);
         }
      }               
      else /* only overlap_type 0 or 1 */
      {
         ed[edg_ix]->num_te = 1;
         te_cand[num_cand++] = ed[edg_ix];
      }
      if(new_ed[0])
      {
         te_cand[num_cand++] = new_ed[0];
      }
   } /* for(edg_ix=0;edg_ix<2;edg_ix++) */  
   if(num_cand>1)
   {
      for(ii=0;ii<num_cand;ii++)
         te_cand[ii]->num_te = 1;

      sts = TOadd_te(topo,1,num_cand,&elhead,&eltail);
      if(sts)
      { 
         return(-1);
      }  
      new_te = topo->te.tetail->next;
      for(ii=0;ii<num_cand;ii++)
      {
         sts = TOadd_el(topo,eltail,te_cand[ii]);
         if(sts)
         { 
            return(-1);
         }  
         sts = TOadd_tl(topo,te_cand[ii]->eletail,new_te);
         if(sts)
         { 
            return(-1);
         }  
      } /* for num_cand */    
   } /* if(num_cand>1) */    
   sts = NULL;
wrapup:
   return(sts);
}
/*
Name
	TOadd_pe

Abstract
	add one edge to the linked list
	
Synopsis
	
    sts = TOadd_pe(topo,ed0,para,end_pts,new_ed)

    struct topology *topo;
    struct edge     *ed0;
    double          para[2][2];
    double          *end_pts[2][2];
    struct edge     **new_ed;


Description
 
	Input:
    	case 		state of the edge generation state is status = 1
    	*ed0 		pointer to an edge or super edge 

	Output:

    	**new_ed	list header for topological edges

Return Values

	sts

Notes

Index

Keywords

History
	B. Burkhardt	03/17/94	Creation date.
*/
		
int TOadd_pe(struct topology *topo,
             struct edge     *ed0,
             double          para[2][2],
             struct point    *end_pts[2][2],
             struct edge     **new_ed)
 
{
   
   int              i =NULL;
   int              jj =NULL;
   int              sts =NULL;
   double           point[3];
   struct point     *pp[2];
   struct top_point *tpp;
   struct edge      *edid0;
   struct telist    *tlh;
   struct telist    *tlt;
   struct Ext_data_edge  *edid =NULL;

   for(i=0;i<2;i++)
      new_ed[i] = NULL;
/* 
   don't create new edges if one part is singular
*/
   if(para[0][1]-para[0][0]<0.01 && para[0][1]-para[0][0] > -0.01)
   {
      BSrc rc;
      IGRdouble start,ende,dir,arc;
      IGRboolean status;
      start = (para[0][0] < para[0][1]) ? para[0][0] : para[0][1];
      ende  = (para[0][0] < para[0][1]) ? para[0][1] : para[0][0];
      dir   = para[0][0] + 0.5*(para[0][1]-para[0][0]);
      BSarclen(&rc,&status,ed0->edid0->ext->edge,&start,&ende,&dir,&arc);
      if(rc != BSSUCC)
      {
         sts = -1;
         goto wrapup;
      }
      if(arc < topo->pa.topology_tolerance)
      {
         new_ed[1] = ed0;
         goto wrapup;
      }
   }
   if(para[1][1]-para[1][0]<0.01 && para[1][1]-para[1][0] > -0.01)
   {
      BSrc rc;
      IGRdouble start, ende, dir, arc;
      IGRboolean status;
      start = (para[1][0] < para[1][1]) ? para[1][0] : para[1][1];
      ende  = (para[1][0] < para[1][1]) ? para[1][1] : para[1][0];
      dir   = para[1][0] + 0.5*(para[1][1]-para[1][0]);
      BSarclen(&rc,&status,ed0->edid0->ext->edge,&start,&ende,&dir,&arc);
      if(rc != BSSUCC)
      {
         sts = -1;
         goto wrapup;
      }
      if(arc < topo->pa.topology_tolerance)
      {
         new_ed[0] = ed0;
         goto wrapup;
      }
   }
   edid0 = ed0->edid0;
   for(i=0;i<2;i++)
   {
      edid = (struct Ext_data_edge *)TOnew_memory(topo,
                                                 sizeof(struct Ext_data_edge));
      if(edid == NULL){ sts=-1; goto wrapup;}
      edid->referenced_object.osnum =
            edid0->ext->referenced_object.osnum;
      edid->referenced_object.objid = 
            edid0->ext->referenced_object.objid;
      edid->edge                    = NULL;
      edid->displayed_object.osnum  = NULL;
      edid->displayed_object.objid  = NULL;
      edid->bound[0].param          = para[i][NULL];
      edid->bound[0].span_inx       = NULL;
      edid->bound[1].param          = para[i][1];
      edid->bound[1].span_inx       = NULL;
      sts = TOadd_ed(topo,edid,4,edid0,NULL,NULL,
                     edid0->sf,NULL,NULL,NULL,&tlh,&tlt);
      if(sts)
      {
         goto wrapup;
      }
      new_ed[i] = topo->ed.etail->next;
      for(jj=0;jj<2;jj++)
      {
         tpp      = end_pts[i][jj]->tp;
         point[0] = end_pts[i][jj]->x; 
         point[1] = end_pts[i][jj]->y; 
         point[2] = end_pts[i][jj]->z; 
         sts = TOadd_pt(topo,1,point,new_ed[i],tpp);
         if(sts)
         {
            goto wrapup;
         }
         pp[jj]  = topo->pt.ptail->next;
         sts     = TOadd_pl(topo,tpp->eletail,pp[jj]);
         if(sts)
         {
            goto wrapup;
         }
      } /* for jj */
      new_ed[i]->p1 = pp[0];
      new_ed[i]->p2 = pp[1];
   } /* for i */
   ed0->status = 3;
   ed0->edid1 = new_ed[0];
   ed0->edid2 = new_ed[1];
   sts = NULL;
wrapup:
   return(sts);
}
end implementation ECtpanaly;

