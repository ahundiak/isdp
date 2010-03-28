#ifndef igrhashdef
/*
   H. BEQUET  05/27/1987 (revised : 06/01/87)                   IGRhashdef.h
   
   This include file contains the constant definitions for the IGRhash class.
   This include file depends on the following files :
   
                          . igetypedef.h
                          . igrtypedef.h
*/

#define igrhashdef


#define NIL -1 /* NIL pointer */

#define KEY_MAX_LENGTH  160  /* the maximum length for a key     */
#define INFO_MAX_LENGTH 160  /* the maximum length for a key     */
#define ALLOC_SIZE       5   /* every memory allocation reserves
                                ALLOC_SIZE entries               */
#define LINEAR_LIMIT     3   /* when more than LINEAR_LIMIT
                                elements are strored, the hash
                                coding orginization is used      */
#endif
