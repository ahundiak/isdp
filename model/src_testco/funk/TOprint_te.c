
#include <stdio.h>
#include <string.h>
#include "TOstruct1.h"
#include "TOtopology.h"
#include "TOproto_ta.h"

int TOprint_te(struct topology *topo)
{
   int i;
   struct elist   *tehilfe;
   struct top_edge *tetemp;
   FILE *fp = NULL;

   if((fp = fopen("top_data","a"))== NULL)
   {
      printf("can't open fp in TOprint_te \n");
      return(-1);
   }
   tetemp = topo->te.tehead->next;
/*
   der kopfnachfolger zeigt auf den schwanz--> leere liste;
*/
   fprintf(fp,"\nprint topedgestruktur tehaid: %x tetail: %x \n\n",
           topo->te.tehead,topo->te.tetail);
   fprintf(fp,"nr *te next status num_ele\nadressen aller edges\nfuer jede edge: \nied->edid0\n\n");

   if(tetemp == topo->te.tetail)
      return(0);
/*
   marschiere bis der nachfolger auf den schwanz zeigt;
*/
   i = 0;
   while(tetemp != topo->te.tetail)
   {
      i = i + 1;
      fprintf(fp,"%10d %10x ",i,tetemp);
      fprintf(fp,"%10x %10d %10d\n",tetemp->next,
             tetemp->status,tetemp->num_ele);
      tehilfe = tetemp->elehead->next;
      while(tehilfe != tetemp->eletail)
      {
         fprintf(fp,"%10x ", tehilfe->ied);
         tehilfe = tehilfe->next;
      }  
      fprintf(fp,"\n");
      tehilfe = tetemp->elehead->next;
      if(tehilfe != tetemp->eletail)
      {
         fprintf(fp,"te = %f %f %f %f %f %f\n",
         tehilfe->ied->p1->x,tehilfe->ied->p1->y,tehilfe->ied->p1->z,
         tehilfe->ied->p2->x,tehilfe->ied->p2->y,tehilfe->ied->p2->z);
       }
       fprintf(fp,"\n");
       tetemp = tetemp->next;
    }
    fprintf(fp,"es wurden %d topedges ausgegeben\n\n",i);
    if(fp)
       fclose(fp);
    return(0);
}
