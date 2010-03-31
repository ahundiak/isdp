
/*
Name

    TObasic_log

Abstract

    finds all relations between surface edges which are
    connected atleast in one common point

Synopsis

    int TObasic_log(topo)

    struct topology 	*topo;	generell data structure for topology

Description


Return Value

    sts = 0		if operation successful

Notes

Index

Keywords

History

    22 Feb 94   B.Burkhardt     Creation
    20 May 94   B.Burkhardt     Inintialize adress pointer ipt
*/

#include <stdio.h>
#include <string.h>
#include <time.h>
#undef clock
#include "TOstruct1.h"
#include "TOtopology.h"
#include "TOproto_ta.h"


int TObasic_log(struct topology *topo)
{
   
   int sts = NULL;
   short num    = NULL;
   short num_se = NULL;
   struct point     **ipt = NULL;

#ifdef DBG
   FILE  *fp;
   int stt = NULL;
   time_t zeits;
   extern time_t zeit;
   if((fp = fopen("tmp","a"))== NULL)
   {
      printf("can't open fp in TObasic_log \n");
      return(-1);
   }
#endif

/*
   ipt is a vector with the list addresses of the points.
   It is used for qsort.
*/
   num    = topo->pt.num_pt;
   ipt    = (struct point **)malloc(num*sizeof(struct point *));
   if(ipt == NULL)
   {
      sts = -1;
      goto wrapup;
   }  
   sts    = TOpt_vector(topo,ipt);
   if(sts)
   {
      goto wrapup;
   }
#ifdef DBG
   fprintf(fp,"cpu nach pt_vector= %10.5f s \n",(double)clock()/1000000);
   stt    = time(&zeits);
   fprintf(fp,"time = %d sec.\n",(zeits-zeit));
#endif

/*
   sort points and find topological points
*/
   sts = TOsort_pt(topo, ipt);
   if(sts)
   {
      goto wrapup;
   }

#ifdef DBG
   fprintf(fp,"\npunktkatalog fertig \n");
   fprintf(fp,"cpu nach TOsort_pt= %10.5f s \n",(double)clock()/1000000);
   stt = time(&zeits);
   fprintf(fp,"time = %d sec.\n",(zeits-zeit));
   fprintf(fp,"anzahl der topologischen punkte   : %10d\n\n",
            topo->tp.num_tp);
#endif

/*
   use topological points to find all common edges
   with two identical endpoints
*/
   sts = TOsort_ed(topo);
   if(sts)
   {
      goto wrapup;
   }

#ifdef DBG
   fprintf(fp,"\nedgekatalog fertig \n");
   fprintf(fp,"cpu nach TOsort_ed= %10.5f s \n",(double)clock()/1000000);
   stt = time(&zeits);
   fprintf(fp,"time = %d sec.\n",(zeits-zeit));
   fprintf(fp,"\nanzahl der top_edges: %d \n\n",
           topo->te.num_te);
#endif

/*
   find all common edges; create super_edges and find relations
   between super_edge and surface edge
   zusammenfassung der flaechen an den gemeinsamen kanten
*/

   sts = TOsort_sf(topo, &num_se);
   if(sts)
   {
      goto wrapup;
   }

#ifdef DBG

   fprintf(fp,"\nflaechenrekursion fertig \n");
   fprintf(fp,"cpu nach TOsort_sf= %10.5f s \n",(double)clock()/1000000);
   stt = time(&zeits);
   fprintf(fp,"time = %d sec.\n",(zeits-zeit));
   fprintf(fp,"\nanzahl der flaechen   : %d \n",
              topo->sf.num_sf);
   fprintf(fp,"anzahl der     points   : %d \n",
              topo->pt.num_pt);
   fprintf(fp,"anzahl der top_points   : %d \n",
              topo->tp.num_tp);
   fprintf(fp,"anzahl der edges        : %d \n",
              topo->ed.num_ed);
   fprintf(fp,"anzahl der top_edges    : %d \n",
              topo->te.num_te);
   fprintf(fp,"anzahl der super_edges  : %d \n\n",num_se);
#endif

#ifdef TEST_BASIC
   sts = TOprint_sf(topo);
   if(sts)goto wrapup;
   sts = TOprint_ed(topo);
   if(sts)goto wrapup;
   sts = TOprint_pt(topo);
   if(sts)goto wrapup;
   sts = TOprint_tp(topo);
   if(sts)goto wrapup;
   sts = TOprint_te(topo);
   if(sts)goto wrapup;
#endif
   sts = NULL;
wrapup:
   if(ipt != NULL)
      free(ipt);
#ifdef DBG
   if(fp)
      fclose(fp);
#endif
   return(sts);
}
