/* UTI debug include file */

#include	<stdio.h>

extern FILE *UTIconsole;
extern int  UTIdebug;

#define _UTI_dbg(message, variable) \
    if ( UTIdebug ) \
     { \
       fprintf( UTIconsole, "UTIR : "); \
       fprintf( UTIconsole, (message), (variable)); \
       fprintf( UTIconsole, "\n"); \
     }
