/* ###################   ANSI COMPILED     ################## */
#include "igrtypedef.h"

/*
 *  This is a function that MUST ALWAY RETURN TRUE!!!!!!!!!
 *
 *  Rational:  MDS is built on selected .o's from MODEL.  This function
 *  is implemented as a stub in MDS that ALWAYS RETURS FALSE.  This is
 *  how we get around conditional compiles when building MDS - discisions
 *  are made at runtime about whether code should be associative or not
 *  in a particular application.  Sure it's a kludge, be more elligant
 *  than most ... Shelley Heard 03/02/92.
 */
IGRboolean EMshould_be_associative()
{
   return 1;
}
