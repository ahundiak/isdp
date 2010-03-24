

/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/
/* messbuf.h - handles allocation and naming of message buffers		*/
/*									*/
/* Object PreProcessor - opp						*/
/* Paul L. Hammond							*/
/* March 21, 1986							*/
/*									*/
/*vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv*/
#ifndef MESSBUF_INCLUDED
#define MESSBUF_INCLUDED

#include <stdio.h>
#include "identifier.h"

struct message_buffer_def
 {
  struct message_buffer_def *next, *nest, *user;
  identifier_ptr msg, class;
  int index;
  int major, minor;
  int has_args;
 };

/*
   generate_message_buffers and remove_message_buffers
   return the count of lines printed into the "fil".
*/

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

/* messbuf2.c */
int new_message_buffer __((int nested, identifier_ptr class, identifier_ptr msg, struct message_buffer_def *user));
int generate_message_buffers __((FILE *fil));
int remove_message_buffers __((FILE *fil));

#if defined(__cplusplus)
}
#endif

#endif /* MESSBUF_INCLUDED */
/* End messbuf.h */
