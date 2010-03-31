/* EMtrace.h */
/* Definitions required for EMtrace.I EMtraceo.I EMscanhorse.c */

# ifndef EMtrace_include
# define EMtrace_include 1

  struct ptr_end_struct
   {
     IGRdouble    start_end[6]; /* Starting end info of the sub-string
                                   [0-2] is the start point. [3-5] is the
                                   normalized tangent vector in the direction
                                   of the curve. ie |pole2 - pole1| normalized
                                */

     IGRdouble    stop_end[6];  /* Stopping end info of the sub-string
                                   [0-2] is the stop point. [3-5] is the
                                   normalized tangent vector in the REVERSE
                                   direction of the curve. ie
                                   |pole (n-1) - pole (n) | normalized
                                */
                                
     IGRshort     next_entity;  /* link to the next record */

     IGRshort     string;       /* string number of the connected string */

     IGRboolean   flow_reversed;/* parametrization info */

     IGRchar      *original_node; /* ptr to original node. could be in any
                                     form. Post processor should decipher
                                     this */

     IGRlong      original_index; /* index of the original node, if sent
                                     as an array rather than linked list */
   };

# endif
