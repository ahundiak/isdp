
/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/
/* oppface.h - opp interface for discos					*/
/*									*/
/* Paul L. Hammond							*/
/* December 10, 1986							*/
/*vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv*/
#ifndef oppface_included
#define oppface_included

#include "class.h"

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

/* oppface.c */
void exit_opp __((void));
void init_opp __((char *cpp_flags[]));

int opp_process_impl_file __((char *file_name, struct opp_class_def **pp_class));
/* "p_class" is an output parameter which will point to a classdef */

int lookup_class __((char *class, struct opp_class_def **p_class));
int opp_get_class __((char *class, int outgen, struct opp_class_def **p_class));
/*
 name - 		name of spec file 
 outgen -  if true, generate output file
 p_class -  output - pointer to class def
*/

#if defined(__cplusplus)
}
#endif

#endif
