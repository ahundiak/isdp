

/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/
/* relations.h - support code for relation specifications		*/
/*									*/
/* Object PreProcessor - opp						*/
/* Paul L. Hammond							*/
/* March 21, 1986							*/
/*									*/
/*vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv*/
#ifndef RELATIONS_INCLUDED
#define RELATIONS_INCLUDED

#include "identifier.h"

struct hook_definition
 {
  char	**class_list;  /* pointer to array */
  int	class_count;
  int	attributes;
  int	initial_count;
  int	incremental_count;
 };

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __
#define __(args) args
#endif
#else
#ifndef __
#define __(args) ()
#endif
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* relations.c */
void end_channel_def __((identifier_ptr chan, int attributes, identifier_ptr class_list, int initial_size, int size_incr, char *other));
#if 0
 identifier_ptr chan;	    /* channel type symbol */
 int attributes; 	    /* bit mask */
 identifier_ptr class_list; /* linked by "link" */
 int initial_size; /* number of slots to be initialy allocated on side */
 int size_incr;    /* number of slots to be added when side is expanded */
#endif

#if defined(__cplusplus)
}
#endif

#endif /* RELATIONS_INCLUDED */
/* End relations.h */
