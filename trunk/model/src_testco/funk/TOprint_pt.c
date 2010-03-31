   #include <stdio.h>
   #include <string.h>
   #include "TOtopology.h"
   #include "TOstruct1.h"
   #include "TOproto_ta.h"

    int TOprint_pt(struct topology *topo)
    {
       int i;
       struct point *hilfe;
       FILE *fp = NULL;

       if((fp = fopen("top_data","a"))== NULL)
       {
          printf("can't open print_pt \n");
          return(-10);
       }
       hilfe = topo->pt.phead->next;
/*
       der kopfnachfolger zeigt auf den schwanz--> leere liste;
*/
       fprintf(fp,"\nprint pointstruktur phead: %x  ptail: %x\n",
               topo->pt.phead,topo->pt.ptail);
       fprintf(fp,"nr pnt next status edge top_pt\nx y z\n\n");
       if(hilfe == topo->pt.ptail)
          return(0);
/*
       marschiere bis der nachfolger auf den schwanz zeigt;
*/
       i = 0;
       while(hilfe != topo->pt.ptail)
       {
          i = i + 1;
          fprintf(fp,"%10d  %10x",i,hilfe);
          fprintf(fp,"%10x %10d %10x %10x\n %10.3f %10.3f %10.3f\n",
                 hilfe->next, hilfe->status,
                 hilfe->ed,hilfe->tp,
                 hilfe->x,hilfe->y,hilfe->z);
          hilfe = hilfe->next;
       }
       fprintf(fp," es wurden %d punkte ausgegeben \n\n",i);
       if(fp)
          fclose(fp);
       return(0);
    }
