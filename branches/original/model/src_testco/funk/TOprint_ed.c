
   #include <stdio.h>
   #include <string.h>
   #include "TOtopology.h"
   #include "TOstruct1.h"
   #include "TOproto_ta.h"

    int TOprint_ed(struct topology *topo)
    {
       int i;
       struct edge *hilfe;
       struct telist *tetemp;
       FILE *fp = NULL;

       if((fp = fopen("top_data","a"))== NULL)
       {
          printf("can't open print_ed \n");
          return(-10);
       }
       hilfe = topo->ed.ehead->next;
/*
       der kopfnachfolger zeigt auf den schwanz--> leere liste;
*/
       fprintf(fp,"\nprint edgestruktur ehead: %x  etail: %x\n\n",
               topo->ed.ehead,topo->ed.etail);
       fprintf(fp,"nr ed next status \n edid0 edid1 edid2 surface p1 p2 num_te\n\n");
       if(hilfe == topo->ed.etail)
          return(0);
/*
       marschiere bis der nachfolger auf den schwanz zeigt;
*/
       i = 0;
       while(hilfe != topo->ed.etail)
       {
          i = i + 1;
          fprintf(fp,"%10d %10x %10x %10d\n",i,hilfe,hilfe->next,hilfe->status);
          fprintf(fp," %10x %10x %10x %10x %10x %10x %10d\n",
                  hilfe->edid0,hilfe->edid1,hilfe->edid2,hilfe->sf,
                  hilfe->p1,hilfe->p2,hilfe->num_te);
          fprintf(fp,"%8.3f %8.3f %8.3f %8.3f %8.3f %8.3f\n",
                  hilfe->p1->x,hilfe->p1->y,hilfe->p1->z,
                  hilfe->p2->x,hilfe->p2->y,hilfe->p2->z); 
          tetemp = hilfe->elehead->next;
          while(tetemp != hilfe->eletail)
          {
             fprintf(fp,"%10x ", tetemp->ied);
             tetemp = tetemp->next;
          }
          fprintf(fp,"\n\n");
          hilfe = hilfe->next;
       }
       fprintf(fp,"es wurden %d edges ausgegeben\n\n",i);
       if(fp)
          fclose(fp);
       return(0);
    }
