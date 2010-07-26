/*

 constant used by the ACmacros for messages and om  macro 

*/

#ifndef acdef_include
#define acdef_include

/*
  constant used by ac$construct_path and ac$construct_wd
*/

#define AC_INQ 0x01        /* inquire about path or wd 			      */
#define AC_SET 0x02        /* set the path or wd 			      */

/*
  constant used by ac$construct_path only 
*/

#define AC_ADD_PATH 0x04   /* add a file name to the path 		      */
#define AC_REM_PATH 0x08   /* remove a file name from the path 		      */

#endif
