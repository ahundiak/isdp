#ifndef REassoc_h
#define REassoc_h 1

/*
  This include file contains the recomputation information and type 
  definition for all the instantiable classes under EMSassoc.

  EMS_ASfunction                    255  

History:
 PP: 11/4/91 : Trying to make some sense of the info spread out in 
               different include files.
*/

/*
 * If the type is 255 then a function name and optionally recomputation
 * information is stored in EMSassoc vla.
 */

#define EMS_ASfunction 255
/*
 * The following functions are supported.
 * EFmirror_copy
 * EFamrge_curves 
 * EFacvbool
 */

/*
 * If the type is 254 then the non-associative solid is attached to a
 * a coordinate system.
 */

#define EMS_ASattached_to_cs 254

/*
 * If the type is 253 then the macro type is pattern feature. 
 * 
 */

#define EMS_ASpattern_macro 253

#endif
