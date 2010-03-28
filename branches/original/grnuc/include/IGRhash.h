#ifndef igrhash
/*
   H. BEQUET  05/27/1987 (revised : 06/01/87)                      IGRhash.h
   
   This include file contains the data definitions for the IGRhash class.
   This include file depends on the following files :
   
                          . IGRhashdef.h
*/

#define igrhash
                               
struct entry
       {
       	 IGRchar *key  /* the key                          */,
       	         *info /* the information                  */;
         IGRint  next  /* the overflow index               */;
       };

struct element
       {
       	 IGRchar *key      /* the key                          */,
       	         *info     /* the information                  */;
       };

#endif
