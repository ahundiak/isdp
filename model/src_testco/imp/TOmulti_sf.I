class implementation Root;

# include <alloca.h>
# include "igrtypedef.h"
# include "igetypedef.h"
# include "igr.h"
# include "igrdp.h"
# include "gr.h"
# include "go.h"
# include "ex.h"
# include "grdpbdef.h"
# include "grdpbmacros.h"
# include "dp.h"
# include "griodef.h"
# include "grio.h"
# include "lcdef.h"
# include "lc.h"
# include "EMSasnuc.h"
# include "EMSasmacros.h"
# include "EMSasnucdef.h"
# include "madef.h"
# include "godef.h"
# include "EMSmsgdef.h"
# include "OMerrordef.h"
# include "emserr.h"
# include "emsdef.h"
# include "emsmacros.h"
# include "msmacros.h"
# include "EMSopt.h"
# include "EMSprop.h"
# include "EMS.h"
# include "EMSbnddef.h"
# include "EMSbnd.h"
# include "EMSlmdef.h"
#include "EMSasopts.h"
#include "EC_P.h"
#include "EC_S.h"
#include "EC_I.h"
#include "EC_E.h"
#include "EC_M.h"
#include "GRtypedef.h"
#include "EMSascmacros.h"
# include <stdio.h>
# include "ECmsg.h"
# include "ECmsg.h"
# include "TOdsl.h"
# include "TOstruct1.h"
# include "TOtopology.h"
# include "TOproto_ta.h"
#include "TOproto_ds.h"
# include <time.h>
#include "bserr.h"
#include "bstypes.h"
#include "bsparameters.h"
#include "bsarclen.h"
#include "bssfeval.h"
#include "bsmdistptsf.h"
#undef clock
#define ARC_DEGREE 180.0/3.1415926

time_t zeit;

/*
Name

   TOmulti_surfaces

Abstract

    surfaces with identical edges will be marked as multi defined surfaces
    in a second step surfaces with two edges with a length < a given
    tolerance will be marked as small surfaces

Synopsis

int TOmulti_surfaces(struct topology *topo,
                     int *n_out_bdr,
                     struct elist **out_bdr_head,
                     struct elist **out_bdr_tail)

topo           - main structure for topological data
n_out_bdr      - number of boundaries of marked surfaces for display
out_bdr_head   - list header for boundaries to display
out_bdr_tail   - list tail for boundaries to display

Description

    Finds all identical Surfaces in a topological set of
    surfaces and returns their edges in a linked list

    The caller has to free the fields with free

Return Value

    0

Notes

Index

Keywords

History

    20 Jul 94   B.Burkhardt     Prototype
*/
int TOmulti_surfaces(struct topology *topo,
                     int *n_out_bdr,
                     struct elist **out_bdr_head,
                     struct elist **out_bdr_tail)
{
   int sts = NULL;
   int ok = NULL;
   int ok0= NULL;
   int okflag = NULL;
   struct surface *sftemp;
   struct surface *sfid;
   struct elist *eltemp;
   struct elist *eltemp0;
   struct elist *eltemp1;
   struct elist *eltemp2;
   struct elist *eltemp3;
   struct edge *etemp;
   struct elist *selhead;
   struct elist *seltail;
   IGRdouble    start;
   IGRdouble    ende;
   IGRdouble    dir;
   IGRdouble    arc;
   IGRboolean   status;
   IGRpoint     xyz_point[1], sf_point;
   struct IGRbsp_curve edge;
   BSrc         rc;
   int       n_small = NULL;

#ifdef DBG
   FILE *fp = NULL;
   printf("TOmulti_surfaces\n");
#endif
   ex$message(msgnumb = EMS_I_ClearStatusField,);
   ex$message(msgnumb = EMS_P_ClearPromptField,);

   ex$message(field = ERROR_FIELD,
              msgnumb = EMS_E_PrMuSu);/*Processing Multi Defined Surf*/

   *n_out_bdr     = NULL; 
   *out_bdr_head  = NULL;
   *out_bdr_tail  = NULL;

   sftemp = topo->sf.sfhead;
   /* return  if list is empty */
   if(sftemp->next == topo->sf.sftail)
      return(0);
   /* Initialize an edge element list for the members of the outer boundary; */
   sts = TOinit_el(topo,&selhead,&seltail);
   if(sts)
   {
      goto wrapup;
   }
   /* investigate all surfaces in the list */
   while((sftemp=sftemp->next) != topo->sf.sftail)
   {
      /* surface is not investigated */ 
      if(sftemp->num_ed > NULL)
      {
         eltemp0 = sftemp->elehead;/* header of the edge list of the surface */
         ok0 = 1;
         if(sftemp->num_ed == 1)ok0 = NULL;
         /*over all surf edges until the first non degenerated is found*/ 
         while((eltemp0=eltemp0->next) != sftemp->eletail)
         {
            if(eltemp0->ied->status == 9)/* status =9 ==> degenerated edge*/
               ok0++;
            else
               goto start_compare;
         }
start_compare:
         eltemp = eltemp0;
         ok = ok0;
         /*eltemp->ied->elehead => list header of the top edges
           (sf->ed->te_head) of the current edge eltemp->ied
           if the edge is part of a top edge */
         if(eltemp->ied->elehead->next != eltemp->ied->eletail)
         {
            etemp  = eltemp->ied;
            eltemp2 = etemp->elehead->next->ied->elehead;
            eltemp3 = etemp->elehead->next->ied->eletail;
            /*if there are edge elements in the top edge which are not
              investigated and no double surface found, do
              sfid =sf->ed->te->ed->sf
            while(ok < sftemp->num_ed && 
                  ((eltemp2=eltemp2->next) != eltemp3)) */
            while((eltemp2=eltemp2->next) != eltemp3)
            {
               ok = ok0;
               sfid  = eltemp2->ied->sf;
               if(sfid == sftemp || sfid->num_ed < NULL || 
                  sftemp->num_ed != sfid->num_ed)
                  continue;
               if(sftemp->num_ed == 1 && sfid->num_ed == 1)
                  eltemp = sftemp->elehead;
               else  
                  eltemp = eltemp0;
               okflag = 1; /* set to start interrogation */ 
               /* go over all edges of the surface, but only 
                  when the former step was successful and look if
                  they are belonging to the same surface*/
               while(okflag && (eltemp=eltemp->next)!= sftemp->eletail)
               {
                  etemp = eltemp->ied;
                  okflag = NULL;
                  /* edge dosn't belong to a top edge, or the list
                     of top edges is empty and it is not degenerated
                     then go to the next surface */
                  if((etemp->num_te == NULL || 
                      etemp->elehead->next == etemp->eletail)&&
                     etemp->status != 9)
                     goto next_surface;
                  if(etemp->status == 9)
                  {
                     okflag = 1;
                     ok++;
                     continue;
                  }
                  /* eltemp1 = sf->ed->te->ed_head*/
                  eltemp1 = etemp->elehead->next->ied->elehead;
                  /*over all edges of the current top edge*/
                  while((eltemp1 = eltemp1->next) != 
                                   etemp->elehead->next->ied->eletail)
                  {
                     okflag = NULL;
                     if(eltemp1->ied->sf == sfid)
                     {
                        okflag = 1;
                        ok++;
                        break;
                     }
                  }/*while((eltemp1 = eltemp1->next) != 
                                      etemp->elehead->next->ied->eletail)*/
               }/* while((eltemp=eltemp->next)!= sftemp->eletail) */
            } 
            if(ok == sftemp->num_ed)
            {
               BSsfeval(sftemp->ext->surf, 0.5, 0.5, 0, xyz_point, &rc);
               if(rc != BSSUCC)
               {
                  sts = -1;
                  goto wrapup;
               }
               BSmdistptsf(&rc, sfid->ext->surf, xyz_point[0], &start,&ende,
                           sf_point, &dir );
               if(rc != BSSUCC)
               {
                  sts = -1;
#ifdef DBG
                  printf("BSmdistptsf failed\n");
#endif
                  goto wrapup;
               }
#ifdef DBG
               printf(" u= %f v= %f dist = %f \n",start,ende,dir);
#endif
               if(dir<0.5*topo->pa.diagnosis_distance_tolerance)
               {
                  (*n_out_bdr)++;
                  eltemp = sftemp->elehead;
                  while((eltemp = eltemp->next) != sftemp->eletail)
                  {
                     sts = TOadd_el(topo,seltail,eltemp->ied);
                     if(sts)
                     {
                        goto wrapup;
                     }
                  }
               }/* if(dist<0.5*topo->pa.diagnosis_distance_tolerance) */
            }/* if(ok== sftemp->num_ed) */
         }/* if(eltemp->ied->elehead->next != eltemp->ied->eletail) */
      }/* if(sftemp->num_ed>NULL ) */
next_surface:
      /*sftemp->num_ed = -sftemp->num_ed;*/
      *n_out_bdr=*n_out_bdr;
   }/* while((sftemp=sftemp->next) != topo->sf.sftail) */
   if(!(*n_out_bdr))
   {
      ex$message(field = ERROR_FIELD,
                 msgnumb = EMS_E_NoMuSu);/*No Multi Defined Surfaces*/
   }
   else
   { 
      sftemp = topo->sf.sfhead;
      while((sftemp=sftemp->next) != topo->sf.sftail)
      {
         if(sftemp->num_ed < NULL)
            sftemp->num_ed = -sftemp->num_ed;

         *out_bdr_head= selhead;
         *out_bdr_tail= seltail;
      }
      ex$message(field = ERROR_FIELD,
                 msgnumb = EMS_E_NrMuSu,
                          /*Number of Multiple Defined Surfaces */
                          type = "%4d", var = *n_out_bdr);

   }
/*  now look for small elements; that means surfaces with atleast one edge
    completely in one top point
*/  
   ex$message(field = ERROR_FIELD,
              msgnumb = EMS_E_PrSmSu);/*Processing Small Surf*/
   etemp = topo->ed.ehead;
   while((etemp = etemp->next) != topo->ed.etail)
   {
      if((etemp->status == 1 || etemp->status == -1 ||
          etemp->status == 3 || etemp->status == -3)&&
         (etemp->sf->num_ed > NULL && etemp->p1->tp == etemp->p2->tp))
      {
         start = 0.0;
         ende  = 1.0;
         dir   = 0.5;
         edge = *(etemp->edid0->ext->edge);
         BSarclen(&rc,&status,&edge,&start,&ende,&dir,&arc);
         if(rc != BSSUCC)
         {
            sts = 1;
            goto wrapup;
         }
         if(arc < topo->pa.topology_tolerance)
         {
            eltemp = etemp->sf->elehead;
            while((eltemp=eltemp->next) != etemp->sf->eletail)
            {
               if(eltemp->ied == etemp)
                  continue;
               edge = *(eltemp->ied->edid0->ext->edge);
               BSarclen(&rc,&status,&edge,&start,&ende,&dir,&arc);
               if(rc != BSSUCC)
               {
                  sts = 1;
                  goto wrapup;
               }
               if(arc < topo->pa.topology_tolerance)
               {
                  n_small++;
                  etemp->sf->num_ed = -etemp->sf->num_ed;
                  eltemp1 = etemp->sf->elehead;
                  while((eltemp1 = eltemp1->next) != etemp->sf->eletail)
                  {
                     sts = TOadd_el(topo,seltail,eltemp1->ied);
                     if(sts)
                     {
                        goto wrapup;
                     }
                  }
                  break;
               }/* if(arc < topo->pa.topology_tolerance) */
            } /* while((eltemp=eltemp->next) != etemp->sf->eletail) */
         }/* if(arc < topo->pa.topology_tolerance) */
      }/* if(etemp->sf->num_ed > NULL && etemp->p1->tp == etemp->p2->tp) */
   }/*  while((etemp = etemp->next) != topo->ed.etail) */
   if(!n_small)
   {
      ex$message(field = ERROR_FIELD,
                 msgnumb = EMS_E_NoSmSu);/*No Small Surfaces*/
   }
   else
   { 
      sftemp = topo->sf.sfhead;
      while((sftemp=sftemp->next) != topo->sf.sftail)
      {
         if(sftemp->num_ed < NULL)
            sftemp->num_ed = -sftemp->num_ed;

         *out_bdr_head= selhead;
         *out_bdr_tail= seltail;
         *n_out_bdr   = (*n_out_bdr) + n_small;
      } /* while((sftemp=sftemp->next) != topo->sf.sftail) */
      ex$message(field = ERROR_FIELD,
                 msgnumb = EMS_E_NrSmSu,
                          /*Number of Small Surfaces */
                          type = "%4d", var = n_small);

   }/*  if(!n_small) */
   sts = NULL;
wrapup:

   return(sts);
}
end implementation Root;
