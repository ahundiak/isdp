
#include <stdio.h>
#include <string.h>
#include "TOstruct1.h"
#include "TOtopology.h"
#include "TOproto_ta.h"

int TOprint_tp(struct topology *topo)
{
   int i;
   struct plist *tphilfe;
   struct top_point *hilfe;
   FILE *fp = NULL;

   if((fp = fopen("top_data","a"))== NULL)
   {
      printf("can't open fp in TOprint_tp \n");
      return(-1);
   }
   hilfe = topo->tp.tphead->next;
/*
   der kopfnachfolger zeigt auf den schwanz--> leere liste;
*/
   fprintf(fp,"\nprint top_tpstruktur tphead: %x tptail: %x \n",
           topo->tp.tphead,topo->tp.tptail);
   fprintf(fp,"nr *tp next status num_ele\nadressen aller points\nx y z\n\n");

   if(hilfe == topo->tp.tptail)
   return(0);
/*
   marschiere bis der nachfolger auf den schwanz zeigt;
*/
   i = 0;
   while(hilfe != topo->tp.tptail)
   {
      i = i + 1;
      fprintf(fp,"%10d %10x ",i,hilfe);
      fprintf(fp,"%10x %10d %10d\n",hilfe->next,
              hilfe->status,hilfe->num_ele);

/*
      tphilfe = hilfe->elehead->next;
      while(tphilfe != hilfe->eletail)
      {
         fprintf(fp,"%10x ",tphilfe->ipt);
         tphilfe = tphilfe->next;
      }
      fprintf(fp,"\n");
*/
      tphilfe = hilfe->elehead->next;
      if(tphilfe != hilfe->eletail)
      {
         fprintf(fp,"%10.3f %10.3f %10.3f\n",
                 tphilfe->ipt->x,tphilfe->ipt->y,tphilfe->ipt->z);
      }
      hilfe = hilfe->next;
   }
   fprintf(fp,"es wurden %d top_pts ausgegeben\n",i);
   if(fp)
      fclose(fp);
   return(0);
}
