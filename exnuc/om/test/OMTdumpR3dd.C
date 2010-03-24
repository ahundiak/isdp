#include <math.h>
#include "OMobjectcomm.h"
#include "OMDB.h"
#include "OMindex.h"
#include "OMrtreedef.h"



DB_dump_rtree(root_page_p, levels_p)

R_PAGE_3D_DBL *root_page_p;
int *levels_p;
  
{
R_PAGE_3D_DBL *cur_page_p, *child_page_p;
int i, j;
char *status;
OM_S_OBJID tobj;
OM_S_RIP rip;



cur_page_p = root_page_p;
status = (cur_page_p->Header.Page_type == R_LF_RT_PAGE ? "R_LF_RT_PAGE" :
         (cur_page_p->Header.Page_type == R_NL_RT_PAGE ? "R_NL_RT_PAGE" :
         (cur_page_p->Header.Page_type == R_LF_NR_PAGE ? "R_LF_NR_PAGE" :
         (cur_page_p->Header.Page_type == R_NL_NR_PAGE ? "R_NL_NR_PAGE" :
       	                                                    "other" ))));
tobj = REF( OM_S_OBJID, cur_page_p );
printf("Address ( objid ): \t%d\n", tobj );
printf("HEADER\n");
printf("page type: \t%s\n", status);
printf("rtree type:\t%d\n", cur_page_p->Header.Rtree_type);
printf("number entries:\t%u\n",cur_page_p->Header.Key_count);
printf("\nTABLE\n");

for (i = 0; i < cur_page_p->Header.Key_count; i += 5)
  {
  for (j = i; j < i + 5 && j < cur_page_p->Header.Key_count; j++) 
    {
    printf("entry:\t%u", j);
    if (j < i + 4)
      printf("\t");
    }
  printf("\n");
  for (j = i; j < i + 5 && j < cur_page_p->Header.Key_count; j++)
    {
    printf("xmin:%9.2f  ", cur_page_p->Key[j].xmin);
    if (j < i + 4) ;
    }
  printf("\n");
  for (j = i; j < i + 5 && j < cur_page_p->Header.Key_count; j++)
    {
    printf("ymin:%9.2f  ", cur_page_p->Key[j].ymin);
    if (j < i + 4) ;
    }
  printf("\n");
  for (j = i; j < i + 5 && j < cur_page_p->Header.Key_count; j++)
    {
    printf("zmin:%9.2f  ", cur_page_p->Key[j].zmin);
    if (j < i + 4) ;
    }
  printf("\n");
  for (j = i; j < i + 5 && j < cur_page_p->Header.Key_count; j++)
    {
    printf("xmax:%9.2f  ", cur_page_p->Key[j].xmax);
    if (j < i + 4) ;
    }
  printf("\n");
  for (j = i; j < i + 5 && j < cur_page_p->Header.Key_count; j++)
    {
    printf("ymax:%9.2f  ", cur_page_p->Key[j].ymax);
    if (j < i + 4) ;
    }
  printf("\n");
  for (j = i; j < i + 5 && j < cur_page_p->Header.Key_count; j++)
    {
    printf("zmax:%9.2f  ", cur_page_p->Key[j].zmax);
    if (j < i + 4) ;
    }
  printf("\n");
  for (j = i; j < i + 5 && j < cur_page_p->Header.Key_count; j++)
    {
    if ( NOT_R_LEAF(cur_page_p->Header.Page_type) )
      printf("page:\t%d", cur_page_p->Objid[j]);
    else
      printf("recptr:\t%d", cur_page_p->Objid[j]);
    if (j < i + 4) printf("\t");
    }
  printf("\n");
  printf("\n\n");
  }

if (*levels_p > 1)
  {
  j = *levels_p - 1;
  if ( NOT_R_LEAF(cur_page_p->Header.Page_type) )
    for (i = 0; i < cur_page_p->Header.Key_count; i++)
      {
      child_page_p = DEREF(char, cur_page_p->Objid[i], rip);
      DB_dump_rtree( child_page_p, &j );
      }
  }
}
