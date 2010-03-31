
    #include <stdio.h>
    #include <string.h>
   #include "TOtopology.h"
   #include "TOstruct1.h"
   #include "TOproto_ta.h"

    int TOprint_sf(struct topology *topo)
    {
       int i;
       struct surface *hilfe;
       struct elist *eltemp;
       FILE *fp = NULL;

       if((fp = fopen("top_data","a"))== NULL)
       {
          printf("can't open print_sf \n");
          return(-10);
       }
       hilfe = topo->sf.sfhead->next;
/*
       der kopfnachfolger zeigt auf den schwanz--> leere liste;
*/
       fprintf(fp,"\nprint flaechenstruktur sfhead: %x sftail: %x\n\n",
               topo->sf.sfhead, topo->sf.sftail);
       fprintf(fp,"nr *sf next sfid num_ed\n*ed....\n\n");
       if(hilfe == topo->sf.sftail)
          return(0);
/*
       marschiere bis der nachfolger auf den schwanz zeigt;
*/
       i = 0;
       while(hilfe != topo->sf.sftail)
       {
          i = i + 1;
          fprintf(fp,"%10d %10x ",i,hilfe);
          fprintf(fp,"%10x %10d\n",
                  hilfe->next, hilfe->num_ed);
               
          eltemp = hilfe->elehead->next;
          while(eltemp != hilfe->eletail)
          {
             fprintf(fp,"%10x", eltemp->ied);
             eltemp = eltemp->next;
          }
          fprintf(fp,"\n\n");
          hilfe = hilfe->next;
       }
       fprintf(fp," es wurden %d flaechen ausgegeben\n",i);
       if(fp)
          fclose(fp);
       return(0);
    }
