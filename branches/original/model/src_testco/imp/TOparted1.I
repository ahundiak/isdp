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
/*
Name

    TOpartedge1.I

Abstract

    text

Synopsis

sts=TOpartedge1(struct topology *topo;
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
*/

int TOpartedge1(struct topology *topo,
                struct edge **ed,
                IGRint ovlap_type[2][4],
                IGRdouble bsovlap[2][4])

{
   IGRshort	   edg_ix;
   IGRdouble	   valdiff[2];
   IGRdouble       tmp_begin;
   IGRdouble       tmp_end;
   int             sts = NULL;
   int             num_cand;
   double          para[2][2];
   struct point    *end_pts[2][2];
   struct edge     *new_ed[2];
   struct edge     *te_cand[2][5];
   
   for(edg_ix=0;edg_ix<2;edg_ix++)
   {
      valdiff[edg_ix] = bsovlap[edg_ix][1] - bsovlap[edg_ix][0];
   }
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
      num_cand  = NULL;
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
         if((valdiff[edg_ix]>NULL && (bsovlap[edg_ix][0]>tmp_end ||
                                      bsovlap[edg_ix][1]<tmp_begin))||
            (valdiff[edg_ix]<NULL && (bsovlap[edg_ix][1]>tmp_end ||
                                      bsovlap[edg_ix][0]<tmp_begin)))
         {
            sts = NULL;
            goto wrapup;
         }
               

      } /* if (ed[edg_ix]->status == 4) */

      if (ovlap_type[edg_ix][1] == EMS_O_adjacent ||
          ovlap_type[edg_ix][2] == EMS_O_adjacent)
      {
         end_pts[0][0] = ed[edg_ix]->p1;
         end_pts[0][1] = (valdiff[1-edg_ix]>NULL) ?
                         ed[1-edg_ix]->p2:ed[1-edg_ix]->p1; 
         end_pts[1][0] = end_pts[0][1];
         end_pts[1][1] = ed[edg_ix]->p2;

         para[0][0] = tmp_begin;
         para[0][1] = bsovlap[edg_ix][1];
         para[1][0] = bsovlap[edg_ix][2];
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
         if(new_ed[0])
         {
            new_ed[0]->num_te = 1;
            te_cand[edg_ix][num_cand++] = new_ed[0];
         } 
         if(new_ed[1])
         {
            new_ed[1]->num_te = 1;
            te_cand[edg_ix][num_cand++] = new_ed[1];
         } 
      }
      else /* if (ovlap_type[edg_ix][1] == EMS_O_adjacent ||...*/
      {
         if (valdiff[edg_ix] > 0) 
         {
            end_pts[0][0] = ed[edg_ix]->p1;
            end_pts[0][1] = (valdiff[1-edg_ix]>NULL) ?
                            ed[1-edg_ix]->p2:ed[1-edg_ix]->p1; 
            end_pts[1][0] = end_pts[0][1];
            end_pts[1][1] = ed[edg_ix]->p2;

            para[0][0] = tmp_begin;
            para[0][1] = bsovlap[edg_ix][2];
            para[1][0] = bsovlap[edg_ix][2];
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
            if(new_ed[1])
            {
               new_ed[1]->num_te = 1;
               te_cand[edg_ix][num_cand++] = new_ed[1];
            }
            end_pts[0][0] = ed[edg_ix]->p1;
            end_pts[0][1] = (valdiff[1-edg_ix]>NULL) ?
                            ed[1-edg_ix]->p1:ed[1-edg_ix]->p2; 
            end_pts[1][0] = end_pts[0][1];
            end_pts[1][1] = (valdiff[1-edg_ix]>NULL) ?
                            ed[1-edg_ix]->p2:ed[1-edg_ix]->p1; 

            para[0][0] = tmp_begin;
            para[0][1] = bsovlap[edg_ix][1];
            para[1][0] = bsovlap[edg_ix][1];
            para[1][1] = bsovlap[edg_ix][2]; 
            sts = TOadd_pe(topo,new_ed[0],para,end_pts, new_ed);
            if(sts)
            {
               return(-1);
            }
            if(new_ed[0])
            {
               new_ed[0]->num_te = 1;
               te_cand[edg_ix][num_cand++] = new_ed[0];
            }
         }
         else
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
            if(new_ed[1])
            {
               new_ed[1]->num_te = 1;
               te_cand[edg_ix][num_cand++] = new_ed[1];
            }
            end_pts[0][0] = (valdiff[1-edg_ix]>NULL) ?
                            ed[1-edg_ix]->p1:ed[1-edg_ix]->p2; 
            end_pts[0][1] = (valdiff[1-edg_ix]>NULL) ?
                            ed[1-edg_ix]->p2:ed[1-edg_ix]->p1; 
            end_pts[1][0] = end_pts[0][1];
            end_pts[1][1] = ed[edg_ix]->p1;

            para[0][0] = tmp_begin;
            para[0][1] = bsovlap[edg_ix][2];
            para[1][0] = bsovlap[edg_ix][2];
            para[1][1] = bsovlap[edg_ix][1];
            sts = TOadd_pe(topo,new_ed[0],para,end_pts, new_ed);
            if(sts)
            {
               return(-1);
            }
            if(new_ed[0])
            {
               new_ed[0]->num_te = 1;
               te_cand[edg_ix][num_cand++] = new_ed[0];
            }
         }
      } /* if (ovlap_type[edg_ix][1] == EMS_O_adjacent ||...*/
   } /* for(edg_ix=0;edg_ix<2;edg_ix++) */
#ifdef NOT_USED
   if(num_cand>1)
   {
      int             ii = NULL;
      struct top_edge *new_te;
      struct elist    *elhead;
      struct elist    *eltail;
      for(edg_ix=0;edg_ix<2;edg_ix++)
      {
      for(ii=0;ii<num_cand;ii++)
         te_cand[edg_ix][ii]->num_te = 1;

      sts = TOadd_te(topo,1,num_cand,&elhead,&eltail);
      if(sts)
      { 
         return(-1);
      }  
      new_te = topo->te.tetail->next;
      for(ii=0;ii<2;ii++)
      {
         jj = 
         sts = TOadd_el(topo,eltail,te_cand[ii][);
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
      } /*  */    
   } /* if(num_cand>1) */    
#endif
   sts = NULL;
wrapup:
   return(sts);
}
end implementation ECtpanaly;

