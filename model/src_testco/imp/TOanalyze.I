/*
This file contains the analysis functions for the Topology Analysis project.
*/

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
#undef clock
#define ARC_DEGREE 180.0/3.1415926

time_t zeit;

/*
Name

   TOanalyze_top

Abstract

    text

Synopsis

int TOanalyze_top(struct topology *topo,
                 int *n_out_bdr,
                 struct elist **out_bdr_head,
                 struct elist **out_bdr_tail,
                 int *n_poi_con, struct telist **poi_con_head,
                                 struct telist **poi_con_tail,
                 int *n_nor_con, struct telist **nor_con_head,
                                 struct telist **nor_con_tail,
                 int *n_rad_con, struct telist **rad_con_head,
                                 struct telist **rad_con_tail,
                 int *n_ramific, struct telist **ramific_head,
                                 struct telist **ramific_tail,
                 int *n_poi_p_con, struct point    **p_con_head,
                                   struct point    **p_con_tail,
                 int *n_poi_n_con, struct point    **n_con_head,
                                   struct point    **n_con_tail,
                 int *n_poi_r_con, struct point    **r_con_head,
                                   struct point    **r_con_tail)

Description

    analyze topology and return pointer fields to structures
    containing elements, which violates some conditions.
    Flags in topo indicate, which fields are set.

    The caller has to free the fields with free

Return Value

    0

Notes

Index

Keywords

History

    15 Feb 94   B.Burkhardt     Creation
    15 Jun 94   B.Burkhardt     Add Message Output for worst case Analysis
*/
int TOanalyze_top(struct topology *topo,
                 int *n_out_bdr,
                 struct elist **out_bdr_head,
                 struct elist **out_bdr_tail,
                 int *n_poi_con, struct telist **poi_con_head,
                                 struct telist **poi_con_tail,
                 int *n_nor_con, struct telist **nor_con_head,
                                 struct telist **nor_con_tail,
                 int *n_rad_con, struct telist **rad_con_head,
                                 struct telist **rad_con_tail,
                 int *n_ramific, struct telist **ramific_head,
                                 struct telist **ramific_tail,
                 int *n_poi_p_con, struct point    **p_con_head,
                                   struct point    **p_con_tail,
                 int *n_poi_n_con, struct point    **n_con_head,
                                   struct point    **n_con_tail,
                 int *n_poi_r_con, struct point    **r_con_head,
                                   struct point    **r_con_tail)
{
   int sts = NULL;

#ifdef DBG
   printf("TOanalyze_top\n");
#endif
   ex$message(msgnumb = EMS_I_ClearStatusField,);
   ex$message(msgnumb = EMS_P_ClearPromptField,);
/*
   Initialize the worst_case values for Distance,
   Normal and Radius Violation
*/
   topo->pa.max_dist_viol = NULL;
   topo->pa.max_norm_viol = NULL;
   topo->pa.max_radi_viol = NULL;

   *n_out_bdr      = NULL; 
   *n_poi_con      = NULL;
   *n_nor_con      = NULL;
   *n_rad_con      = NULL;
   *n_ramific      = NULL;
   *out_bdr_head  = NULL;
   *out_bdr_tail  = NULL;
   *poi_con_head  = NULL;
   *poi_con_tail  = NULL;
   *nor_con_head  = NULL;
   *nor_con_tail  = NULL;
   *rad_con_head  = NULL;
   *rad_con_tail  = NULL;
   *ramific_head  = NULL;
   *ramific_tail  = NULL;
   *n_poi_p_con   = NULL;
   *p_con_head   = NULL;
   *p_con_tail   = NULL;
   *n_poi_n_con   = NULL;
   *n_con_head   = NULL;
   *n_con_tail   = NULL;
   *n_poi_r_con   = NULL;
   *r_con_head   = NULL;
   *r_con_tail   = NULL;


/* if outer boundary is required */
   if(topo->pa.option & TOPO_DO_OUTER_BOUNDARY)
   {
      ex$message(field = ERROR_FIELD,
                 msgnumb = EMS_E_PrOutB);/*Processing Outer Boundary*/

      sts = TOana_out_bdr(topo,n_out_bdr,out_bdr_head,out_bdr_tail);
      if(sts)
      {
#ifdef DBG
         printf("TOana_out_bdr failed\n");
#endif
         goto wrapup;
      }            
   }
/*
   if only analysis of point continuity is required
*/
   if((topo->pa.option & TOPO_DO_VIOLATED_CONTI)&&
      (!(topo->pa.option & TOPO_DO_VIOLATED_NORMA)))
   {
      ex$message(field = ERROR_FIELD,
                 msgnumb = EMS_E_PrDistV);/*Processing Distance Violation*/

      sts = TOana_dist(topo,n_poi_con,poi_con_head,poi_con_tail,
                            n_poi_p_con,p_con_head,p_con_tail);
      if(sts)
      {
#ifdef DBG
         printf("TOana_dist failed\n");
#endif
         ex$message(field = ERROR_FIELD,
                    msgnumb = EMS_E_DistFail);/* Analyze Distance failed*/
         goto wrapup;
      }            
   }            
/*
   if normal or radius continuity analysis is required
*/
   if(topo->pa.option & TOPO_DO_VIOLATED_NORMA ||
      topo->pa.option & TOPO_DO_VIOLATED_RADIU)
   {
      if(!(topo->pa.option & TOPO_DO_VIOLATED_RADIU))
      {
         ex$message(field = ERROR_FIELD,
                    msgnumb = EMS_E_PrDiNo);/*Processing Distance and Normal
                                             Violation*/
      }  
      else
      {
         ex$message(field = ERROR_FIELD,
                    msgnumb = EMS_E_PrDiNoRa);/*Processing Distance,Normal
                                             and Radius Violation*/
      }

      sts = TOana_nor(topo,
                      n_poi_con,poi_con_head,poi_con_tail,
                      n_nor_con,nor_con_head,nor_con_tail,
                      n_rad_con,rad_con_head,rad_con_tail,
                      n_poi_p_con,p_con_head,p_con_tail,
                      n_poi_n_con,n_con_head,n_con_tail,
                      n_poi_r_con,r_con_head,r_con_tail);
      if(sts)
      {
#ifdef DBG
         printf("TOana_nor failed\n");
#endif
         ex$message(field = ERROR_FIELD,
                    msgnumb = EMS_E_NoRaFail); /*Analyze Normal/Radius failed*/
         goto wrapup;
      } 
   } 
   sts = NULL;
wrapup:
   return(sts);
}

/*
Name

   TOana_out_bdr

Abstract

    text

Synopsis

   int TOana_out_bdr(struct topology *topo,
                     int *n_out_bdr,
                     struct elist **out_bdr_head,
                     struct elist **out_bdr_tail)

Description

    analyze th outer boundary curves and return a pointer field to
    an edge list;
    Flags in topo indicate, which fields are set.

    The caller has to free the fields with free

Return Value

    0

Notes

Index

Keywords

History

    28 Feb 94   B.Burkhardt     Creation
*/
int TOana_out_bdr(struct topology *topo,
                  int *n_out_bdr,
                  struct elist **out_bdr_head,
                  struct elist **out_bdr_tail)
{
   int    sts = NULL;
   short  num_ii = NULL;
   struct edge *etemp;
   struct edge *seid;
   struct elist *selhead;
   struct elist *seltail;

#ifdef DBG
   FILE *fp = NULL;
   printf("TOana_out_bdr\n");
   if((fp=fopen("top_data","a"))==NULL)
   {
      printf("can't open top_data in TOana_out_bdr\n");
      return(-1);
   } 
#endif
   *n_out_bdr      = NULL; 
   *out_bdr_head  = NULL;
   *out_bdr_tail  = NULL;

   etemp = topo->ed.ehead;
/*
   return  if list is empty
*/
   if(etemp->next == topo->ed.etail)
      return(0);
/* 
   Initialize an edge element list for the members of the outer boundary;
*/
   sts = TOinit_el(topo,&selhead,&seltail);
   if(sts)
   {
      goto wrapup;
   }
/*
   investigate all edges; find all free edges as members of the
   outer boundary
   search for all edges with an empty top edge list and
   which are not element of a super edge
*/
   while((etemp=etemp->next) != topo->ed.etail)
   {
/*
      if(etemp->status != 9 &&
         etemp->num_te == NULL && (etemp->status > NULL ||
                                   etemp->status == -2))
*/
      if((etemp->num_te != NULL && etemp->elehead->next != etemp->eletail && 
          etemp->elehead->next->ied->num_ele > 2 )||
         (etemp->status != 9 &&
         etemp->num_te == NULL && (etemp->status > NULL)))
      {
/*
         if super edge find basic elements recursively
*/
         /*if(etemp->status == 2 || etemp->status == -2) */
         if(etemp->status == 2 )
         {
            seid = etemp;
            sts = TOlist_se(topo,seltail,&num_ii,seid,etemp);
            if(sts)
               goto wrapup;
         }
/*
         edge not contains part edges
*/
      /* else if(etemp->status != 3 && etemp->ext->referenced_object.objid) */
         else if(etemp->status !=-2 &&
                 etemp->status != 3 && etemp->ext->referenced_object.objid)
         {
            sts = TOadd_el(topo,seltail,etemp);
            if(sts)
            {
               goto wrapup;
            }
            num_ii++;
         }
      }
   }
   if(!num_ii)
   {
#ifdef DBG
      printf("\nno stitchable edges\n");
#endif
   ex$message(field = ERROR_FIELD,
              msgnumb = EMS_E_NoOutB);/*No Outer Boundary Curves*/
   }
   else
   {
      struct elist * temp;
      temp = selhead;
/*
      parts of super edges may be members of topological edges
      remove them!
*/
      while(temp->next != seltail)
      {
         while(temp->next->ied->num_te != NULL &&
               temp->next->ied->elehead->next != temp->next->ied->eletail && 
               temp->next->ied->elehead->next->ied->num_ele == 2)
         {
            num_ii--;
            if(temp->next->next == seltail)
               break;
            temp->next = temp->next->next;
         }  
         temp = temp->next;
      } /* while(temp->next != seltail) */  
      if(seltail->next->ied->num_te)
      {
         seltail->next = seltail->next->next;
         num_ii--;
      }

      *n_out_bdr    = num_ii;
      *out_bdr_head = selhead;
      *out_bdr_tail = seltail;
   }
   ex$message(field = ERROR_FIELD,
              msgnumb = EMS_E_NrOutB,/*Number of Outer Boundary Curves */
              type = "%4d", var = num_ii);

   sts = NULL;
wrapup:
#ifdef DBG
   if(fp)
      fclose(fp);
#endif
   return(sts);
}

/*
Name

   TOana_dist

Abstract

    text

Synopsis

   int TOana_dist(struct topology *topo,
                  int *n_poi_con,
                  struct telist **poi_con_head,
                  struct telist **poi_con_tail,
                  int           *n_poi_p_con,
                  struct point  **p_con_head,
                  struct point  **p_con_tail);


Description

    analyze th outer boundary curves and return a pointer field to
    an edge list;
    Flags in topo indicate, which fields are set.

    The caller has to free the fields with free

Return Value

    0

Notes

Index

Keywords

History

    28 Feb 94   B.Burkhardt     Creation
*/
int TOana_dist(struct topology *topo,
               int *n_poi_con,
               struct telist **poi_con_head,
               struct telist **poi_con_tail,
               int             *n_poi_p_con,
               struct point    **p_con_head,
               struct point    **p_con_tail)
{
   int    sts = NULL;
   short  num_ii = NULL;
   short  sti_option = 2; /* investigate edge match with 'sample_size' points */
   struct top_edge *tetemp;
   struct edge *edge1;
   struct edge *edge2;
   struct telist *selhead;
   struct telist *seltail;
   double max_dist;

#ifdef DBG
   FILE *fp = NULL;
   printf("TOana_dist\n");
   if((fp=fopen("top_data","a"))==NULL)
   {
      printf("can't open top_data in TOana_out_bdr\n");
      return(-1);
   } 
#endif
   ex$message(msgnumb = EMS_I_ClearStatusField,);
   ex$message(msgnumb = EMS_P_ClearPromptField,);
   ex$message(field = ERROR_FIELD,
              msgnumb = EMS_E_PrDistV); /*Processing Distance Violation*/

   *n_poi_con     = NULL; 
   *poi_con_head  = NULL;
   *poi_con_tail  = NULL;
   *n_poi_p_con   = NULL;
   *p_con_head    = NULL;
   *p_con_tail    = NULL;

   tetemp = topo->te.tehead;
/*
   return  if list is empty
*/
   if(tetemp->next == topo->te.tetail)
   {
      ex$message(field = ERROR_FIELD,
                 msgnumb = EMS_E_NoToAna);
      topo->pa.form_state = FORM_STATE_AA;
      return(0);
   }
/* 
   Initialize a top edge element list for the violated top edges
*/
   sts = TOinit_tl(topo,&selhead,&seltail);
   if(sts)
   {
#ifdef DBG
      printf("TOinit_tl failed in TOana_dist\n");
#endif
      goto wrapup;
   }
/*
/* 
   Initialize a pointlist for the violated points
*/
   sts = TOinit_pt(topo,p_con_head,p_con_tail);
   if(sts)
   {
#ifdef DBG
      printf("TOinit_pt failed in TOana_dist\n");
#endif
      goto wrapup;
   }
/*
   over all topological edges
   in case of Ramifications Only top_edges with two members used
*/
   while((tetemp=tetemp->next) != topo->te.tetail)
   {
      if(tetemp->num_ele == 2)
      {
      edge1 = NULL;
      edge2 = NULL;
      if(tetemp->elehead->next != tetemp->eletail &&
        (tetemp->elehead->next->ied->status == 2 ||
         tetemp->elehead->next->ied->status ==-2))
         continue;
         edge1 = tetemp->elehead->next->ied;
      if(tetemp->elehead->next->next != tetemp->eletail &&
        (tetemp->elehead->next->next->ied->status == 2 ||
         tetemp->elehead->next->next->ied->status ==-2))
         continue;
         edge2 = tetemp->elehead->next->next->ied;
      if(edge1 ==NULL || edge2 == NULL)  
      {
         sts = -1;
         goto wrapup;
      }
      sts = TOstitch_ed(topo,sti_option,edge1,edge2,
                        n_poi_p_con, p_con_head,p_con_tail,
                        NULL, NULL, NULL, NULL, NULL, NULL);
      if(sts<NULL)
      {
#ifdef DBG
         printf("TOstitch_ed failed in TOana_dist\n");
#endif
         goto wrapup;
      }
      if(!sts)/* point continuity violated */
      {
         sts = TOadd_tl(topo,seltail,tetemp);
         if(sts)
         {
#ifdef DBG
            printf("TOadd_tl failed in TOana_dist\n");
#endif
            goto wrapup;
         }
         num_ii++;
      }
      }/*if(tetemp->num_ele == 2)*/
   }/*while((tetemp=tetemp->next) != topo->te.tetail)*/
   if(!num_ii)
   {
      ex$message(field = ERROR_FIELD,
                 msgnumb = EMS_E_NoViolDet); /*No Violations detected*/

   }
   else
   {
      *n_poi_con    = num_ii;
      *poi_con_head = selhead;
      *poi_con_tail = seltail;
      
      if(topo->pa.max_dist_viol<1.e-6)
         max_dist = 0.0; 
      else
         max_dist = topo->pa.max_dist_viol;
      ex$message(field = ERROR_FIELD,
                 msgnumb = EMS_E_MaxDist, /* Dist:.........*/
                 type = "%12.6f",
                 var = `max_dist`);
   }
   sts = NULL;
wrapup:
#ifdef DBG
   if(fp)
      fclose(fp);
#endif
   return(sts);
}

/*
Name

   TOana_nor

Abstract

    text

Synopsis

   int TOana_nor(struct topology *topo,
                 int *n_poi_con,
                 struct telist **poi_con_head,
                 struct telist **poi_con_tail,
                 int *n_nor_con,
                 struct telist **nor_con_head,
                 struct telist **nor_con_tail,
                 int *n_rad_con,
                 struct telist **rad_con_head,
                 struct telist **rad_con_tail,
                 int             *n_poi_p_con,
                 struct point    **p_con_head,
                 struct point    **p_con_tail,
                 int             *n_poi_n_con,
                 struct point    **n_con_head,
                 struct point    **n_con_tail,
                 int             *n_poi_r_con,
                 struct point    **r_con_head,
                 struct point    **r_con_tail)


Description

    The caller has to free the fields with free

Return Value

    0

Notes

Index

Keywords

History

    08 Apr 94   B.Burkhardt     Creation
*/

int TOana_nor(struct topology *topo,
              int *n_poi_con,
              struct telist **poi_con_head,
              struct telist **poi_con_tail,
              int *n_nor_con,
              struct telist **nor_con_head,
              struct telist **nor_con_tail,
              int *n_rad_con,
              struct telist **rad_con_head,
              struct telist **rad_con_tail,
              int          *n_poi_p_con,
              struct point **p_con_head,
              struct point **p_con_tail,
              int          *n_poi_n_con,
              struct point **n_con_head,
              struct point **n_con_tail,
              int          *n_poi_r_con,
              struct point **r_con_head,
              struct point **r_con_tail)

{
   int    sts   = NULL;
   int    state = NULL;
   short  num_ii = NULL;
   short  sti_option = 3; /* investigate edge match with 'sample_size' points */
   struct top_edge *tetemp;
   struct edge *edge1;
   struct edge *edge2;
   struct telist *selhead1;
   struct telist *seltail1;
   struct telist *selhead2;
   struct telist *seltail2;
   struct telist *selhead3;
   struct telist *seltail3;
   double max_dist, max_norm, max_radi;

#ifdef DBG
   FILE *fp = NULL;
   printf("TOana_nor\n");
   if((fp=fopen("top_data","a"))==NULL)
   {
      printf("can't open top_data in TOana_nor\n");
      return(-1);
   } 
#endif
   *n_poi_con     = NULL; 
   *poi_con_head  = NULL;
   *poi_con_tail  = NULL;
   *n_nor_con     = NULL; 
   *nor_con_head  = NULL;
   *nor_con_tail  = NULL;
   *n_rad_con     = NULL; 
   *rad_con_head  = NULL;
   *rad_con_tail  = NULL;
   *n_poi_p_con   = NULL;
   *p_con_head   = NULL;
   *p_con_tail   = NULL;
   *n_poi_n_con   = NULL;
   *n_con_head   = NULL;
   *n_con_tail   = NULL;
   *n_poi_r_con   = NULL;
   *r_con_head   = NULL;
   *r_con_tail   = NULL;



   tetemp = topo->te.tehead;
/*
   return  if list is empty
*/
   if(tetemp->next == topo->te.tetail)
   {
      ex$message(field = ERROR_FIELD,
                 msgnumb = EMS_E_NoToAna);
      return(0);
   }
/* 
   Initialize a top edge element list for the point violated top edges
*/
   sts = TOinit_tl(topo,&selhead1,&seltail1);
   if(sts)
   {
      goto wrapup;
   }
/*
   Initialize a pointlist for the violated points
*/
   sts = TOinit_pt(topo,p_con_head,p_con_tail);
   if(sts)
   {
#ifdef DBG
      printf("TOinit_pt failed in TOana_nor\n");
#endif
      goto wrapup;
   }
/* 
   Initialize a top edge element list for the normal violated top edges
*/
   if(topo->pa.option & TOPO_DO_VIOLATED_NORMA)
   {
      sti_option = 3;
      sts = TOinit_tl(topo,&selhead2,&seltail2);
      if(sts)
      {
         goto wrapup;
      }
/*
      Initialize a pointlist for the violated normals
*/
      sts = TOinit_pt(topo,n_con_head,n_con_tail);
      if(sts)
      {
#ifdef DBG
         printf("TOinit_pt failed in TOana_nor\n");
#endif
         goto wrapup;
      }
   }
/* 
   Initialize a top edge element list for the radius violated top edges
*/
   if(topo->pa.option & TOPO_DO_VIOLATED_RADIU)
   {
      sti_option = 4;
      sts = TOinit_tl(topo,&selhead3,&seltail3);
      if(sts)
      {
         goto wrapup;
      }
/*
      Initialize a pointlist for the violated radius
*/
      sts = TOinit_pt(topo,r_con_head,r_con_tail);
      if(sts)
      {
#ifdef DBG
         printf("TOinit_pt failed in TOana_nor\n");
#endif
         goto wrapup;
      }
   }
/*
   over all topological edges
*/
   while((tetemp=tetemp->next) != topo->te.tetail)
   {
/*
      only manifold geometry is investigated
      ramification are marked as Outer Boundary Curves
*/
      if(tetemp->num_ele==2)
      {
         edge1 = NULL;
         edge2 = NULL;
         if(tetemp->elehead->next != tetemp->eletail &&
           (tetemp->elehead->next->ied->status == 2 ||
            tetemp->elehead->next->ied->status ==-2))
            continue;
            edge1 = tetemp->elehead->next->ied;
         if(tetemp->elehead->next->next != tetemp->eletail &&
           (tetemp->elehead->next->next->ied->status == 2 ||
            tetemp->elehead->next->next->ied->status ==-2))
            continue;
            edge2 = tetemp->elehead->next->next->ied;
         if(edge1 ==NULL || edge2 == NULL)  
         {
            sts = -1;
            goto wrapup;
         }
         state = TOstitch_ed(topo,sti_option,edge1,edge2,
                             n_poi_p_con, p_con_head, p_con_tail,
                             n_poi_n_con, n_con_head, n_con_tail,
                             n_poi_r_con, r_con_head, r_con_tail);
         if(state<NULL)
         {
            goto wrapup;
         }
         if(!state)
         {/* no point continuity */
            sts = TOadd_tl(topo,seltail1,tetemp);
            if(sts)
            {
               goto wrapup;
            }
            (*n_poi_con)++;
         }
         else if((sti_option == 3 || sti_option == 4) && state < 2)
         { /* normal continuity required; not satisfied */
            sts = TOadd_tl(topo,seltail2,tetemp);
            if(sts)
            {
               goto wrapup;
            }
            (*n_nor_con)++;
         }
         else if(sti_option == 4 && state < 3)
         { /* radius continuity required; not satisfied */  
            sts = TOadd_tl(topo,seltail3,tetemp);
            if(sts)
            {
               goto wrapup;
            }
            (*n_rad_con)++;
         }
      }/* if(tetemp->num_ele==2) */
   }/* while((tetemp=tetemp->next) != topo->te.tetail) */
   num_ii = *n_rad_con + *n_nor_con + *n_poi_con;
   if(!num_ii)
   {
      ex$message(field = ERROR_FIELD,
                 msgnumb = EMS_E_NoViolDet); /*No Violations detected*/

   }
   else
   {
      *poi_con_head = selhead1;
      *poi_con_tail = seltail1;
      if(topo->pa.option & TOPO_DO_VIOLATED_NORMA)
      {  
         *nor_con_head = selhead2;
         *nor_con_tail = seltail2;
      } 

      if(topo->pa.option & TOPO_DO_VIOLATED_RADIU)
      {
         *rad_con_head = selhead3;
         *rad_con_tail = seltail3;
      } 
      if(topo->pa.max_dist_viol<-1.e-6)
         max_dist = 0.0;
      else
         max_dist = topo->pa.max_dist_viol;
      if(topo->pa.max_norm_viol<1.e-6)
         max_norm = 0.0;
      else
         max_norm = topo->pa.max_norm_viol*ARC_DEGREE;
      if(topo->pa.max_radi_viol<1.e-6)
         max_radi = 0.0;
      else
         max_radi = topo->pa.max_radi_viol;
      if(topo->pa.option & TOPO_DO_VIOLATED_RADIU)
      {
         ex$message(field = ERROR_FIELD,
                    msgnumb = EMS_E_MaxViol, /* Dist:...Norm:...Rad:...*/
                    type = "%12.6f %12.6f %12.6f",
                    var = `max_dist,max_norm,max_radi`);
      }
      else
      {
         ex$message(field = ERROR_FIELD,
                    msgnumb = EMS_E_MaxDiNo, /* Dist:...Norm:...*/
                    type = "%12.6f %12.6f",
                    var = `max_dist,max_norm`);
      }
   }
   sts = NULL;
wrapup:
#ifdef DBG
   if(fp)
      fclose(fp);
#endif
   return(sts);
}
end implementation Root;
