
/*
 * printer print root will print a source with connection to referential
 * or not
 */


#ifndef asdef_include
#define asdef_include

/* to print source with connection to coordinate system or not */

#define AS_PR_WITHOUT_REF  0
#define AS_PR_WITH_REF     1



/*
   using matrix, the matrix is stored in line (general case) 
   or in colomn 
*/

#define AS_IN_LINE    1   /* matrix is in line */
#define AS_IN_COL     2   /* matrix is in colomn */

#define AS_VECTOR     4   /* vector projection */
#define AS_POINT      8   /* point projection  */


#endif

