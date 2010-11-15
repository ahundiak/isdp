/* Do not alter this SPC information: $Revision: 1.1.54.1 $ */
/* The following was created using /usr/include/search.h from CLIX */

#ifndef  _HSEARCH_H
#define  _HSEARCH_H

/* HSEARCH(3C) */
typedef struct entry { char *key, *data; } ENTRY;
typedef enum { FIND, ENTER } ACTION;

/* TSEARCH(3C) */
typedef enum { preorder, postorder, endorder, leaf } VISIT;

#endif   /* _HSEARCH_H  */
