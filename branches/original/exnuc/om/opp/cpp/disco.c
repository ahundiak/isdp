#include <symtab.h>
#include "cpp.h"
#include "omdef.h"
#include "mallocdbg.h"

char *dump_macro (mac)
struct define_symbol *mac;
 {
  char so[4000];
  char *s;
  int size;
  
  s = &(so[0]);
  *s = 0;
  strcat (s,"#define ");
  strcat (s,mac->symb.name);
  s += strlen(s);
  if (mac->parametric)
   {
    int i;
    struct cpp_token *t;
    strcat (s,"(");
    for (i=0,t = mac->parameters; i<mac->no_of_pars; i++,t = t->flink)
     {
      if (i > 0) strcat (s,",");
      strcat (s,t->constr);
      s += strlen(s);
     }
    strcat (s,")");
   }
   {
    struct cpp_token *t;
    t = mac->define_tokens;
    while (t)
     {
      strcat (s," ");
      strcat (s,t->constr);
      t = t->flink;
      s += strlen(s);
     }
   }
  s += strlen (s);
  size = (int)s - (int)(&so[0]) + 1;
  s = (char *)malloc(size);
  strcpy (s,so);
  return (s);
 }


char *dump_omdef (omac)
struct om_macro *omac;
 {
  char so[4000];
  char *s;
  int size;
  
  s = &(so[0]);
  *s = 0;
  strcat (s,"#omdef ");
  strcat (s,omac->symb.name);
  s += strlen (s);
  if (omac->parametric)
   {
    struct para_symbol *ps;
    int l = -1;
    strcat (s,"(");
    ps = omac->para_link;
    while (ps)
     {
      if (l != -1)
       {
        if (l == ps->para_id)
         strcat (s," ^ ");
        else
         strcat (s," , ");
       }
      l = ps->para_id;
      strcat (s,ps->symb.name);
      if (ps->has_default)
       {
        struct cpp_token *ds;
        ds = ps->defaults;
        strcat (s,"= ");
        while (ds)
         {
          strcat (s,ds->constr);
          strcat (s," ");
          ds = ds->flink;
          s += strlen (s);
         }
       }
      ps = ps->next;
     }
    strcat (s,")\n");
    s += strlen (s);
   }
   {
    struct cpp_token *ds;
    ds = omac->def_link;
    strcat (s," ");
    while (ds)
     {
      strcat (s,ds->constr);
      strcat (s," ");
      ds = ds->flink;
      s += strlen (s);
     }
   }
  s += strlen (s);
  size = (int)s - (int)(&so[0]) + 1;
  s = (char *)malloc(size);
  strcpy (s,so);
  return (s);
 }
