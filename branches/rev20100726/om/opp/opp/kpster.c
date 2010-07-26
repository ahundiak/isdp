#include "../opp/kptype.h"
#include <cpp.h>
#include "../opp/kpster.h"
#include "ptoken.h" /* for struct pnode_token */


void pster_dump_item(tt)
struct pnode *tt;
 {
  struct harry_item *h;
  struct pnode_token *ta;

  h = harry;
  while (h->name)
   {
    if (h->val == tt->typ)
     {
      if (tt->typ > harry_edge)
       {
        int i=0;
        printf ("%d NODE: %s\n",tt,h->name);
        while ((int)(tt->l[i]) != -1)
         {
          printf (" l%d: %d\n",i,tt->l[i]);
          i++;
         }
       }
      else
       {
        ta = (struct pnode_token *)tt;
        printf ("%d TOKEN: %s\n",tt,h->name);
        printf (" value: %s\n\n",ta->constr);
       }
      break;
     }
    h++;
   }
 }


void pster_dump_ptree(tt)
struct pnode *tt;
 {
  pster_dump_item(tt);
  if (tt->typ > harry_edge)
   {
    int i=0;
    while ((int)(tt->l[i]) != -1)
     {
      if (tt->l[i]) pster_dump_ptree(tt->l[i]);
      i++;
     }
   }
 }
