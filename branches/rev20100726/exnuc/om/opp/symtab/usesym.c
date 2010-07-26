#include "symtab.h"

static symbol_table_ptr known_classes;

void init ()
 {

  known_classes = new_symbol_table (17, 0);

 } /* init */

struct known_class
 {
  struct symbol s;
  struct opp_class_def *class;
 };

static struct known_class *new_known_class (p)
 struct opp_class_def *p;
 {
  struct known_class *kc = malloc (sizeof (*kc) + strlen (p->name) +1);

  kc->s.name = strcpy (kc+1, p->name);
  kc->class = p;

  return kc;
 }; /* new_known_class */

/* A function such as this could be used a filter for the real get_class */
int lookup_class (class, p_class)
 char *class;
 struct opp_class_def **p_class;
 {
  int stat = 0;
  struct known_class *p; 
 
  if (p = lookup_symbol (known_classes, class))
   *p_class = p->class;
  else
   {
    stat = discos_get_class (class, 0, p_class);
    enter_symbol (known_classes, new_known_class (*p_class));
   }
  return stat;
 } /* lookup_class */
