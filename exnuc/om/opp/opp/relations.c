
/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/
/* relations.c - support code for relation specifications		*/
/*									*/
/* Object PreProcessor - opp						*/
/* Paul L. Hammond							*/
/* October 1985								*/
/*									*/
/* Global Functions:							*/
/*	end_channel_def - */
/*									*/
/*vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv*/

#include <stdio.h>
#include <string.h>
#include "relations.h"
#include "opp.h"
#include "oppmalloc.h"
#include "oppydefs.h"

void end_channel_def (chan, attributes, class_list,
		      initial_size, size_incr, other)
 identifier_ptr chan;	    /* channel type symbol */
 int attributes; 	    /* bit mask */
 identifier_ptr class_list; /* linked by "link" */
 int initial_size; /* number of slots to be initialy allocated on side */
 int size_incr;    /* number of slots to be added when side is expanded */
 char *other;	   /* channel on other end of restricted channel */
 {
  register struct hook_definition *h;
  int class_count = 0;

  {
   register identifier_ptr s;
   for (class_count=0, s = class_list; s; s=s->link) ++class_count;
  }
  
  h = (struct hook_definition *) 
      malloc (sizeof (struct hook_definition) + class_count*sizeof(identifier_ptr));

  h->attributes = attributes;
  h->initial_count = initial_size;
  h->incremental_count = size_incr;
  h->class_count = class_count;

  if (attributes & CHAN_ATT_RES) /* restricted channel */
   {
    register int clen = strlen (class_list->s.s.name);
    register char *p  = malloc (clen + strlen(other) + 2 + sizeof (char *));

    h->class_list = (char **)p;
    p += sizeof (char *);
    *h->class_list = strcpy (p, class_list->s.s.name);
    p += clen;
    *p = '.';
    strcpy (p+1, other);
   }
  else if (class_count)
   {
    register identifier_ptr s;
    register identifier_ptr *cl_list;

    h->class_list = (char **) (h + 1);
    cl_list = (identifier_ptr *)h->class_list;

    for (s=class_list; s;)
     {
      register identifier_ptr next_s = s->link;
      *cl_list = (identifier_ptr)strcpy (malloc (strlen (s->s.s.name) + 1), s->s.s.name);
#ifdef DEBUG
      fprintf (stderr, " class name is %s : %s\n", s->s.s.name, *cl_list);
#endif
      ++cl_list;
      s->link = 0;
      s->flags &= ~F_IDENTIFIER_MARKED;
      s = next_s;
     }
   }
  else h->class_list = NULL;

  /* Now we must connect this to the chan symbol record */
  chan->field_link = (identifier_ptr) h;

 } /* end_channel_def */

