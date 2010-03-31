/*
Name

    TOgen_engine

Abstract

    This is the function that generates the topological data structures
    using the input lists generated in TOgen_input.

Synopsis

    TOgen_engine(topo)

    struct topology *topo;          generell topology structure

Description

Return Value
    sts = 0	if successful;
         -1	if processing failed;
Notes

History

    23 Feb 94   B.Burkhardt    	Creation
*/
#include <stdio.h>
#include <string.h>
#include <time.h>
#undef clock
#include "TOstruct1.h"
#include "TOtopology.h"
#include "TOproto_ta.h"

int TOgen_engine( struct topology *topo)

{
   int sts = NULL;
#ifdef DBG
   FILE *fp;
   if((fp=fopen("match","w"))==NULL)
   {
      printf("can't open match in TOgen_engine\n");
      return(-1);
   }
   printf("TOgen_engine\n");
#endif

/*
   Find all connections between those edges which are connected atleast
   at one endpoint;
*/

   sts = TObasic_log(topo);
   if(sts)
   {
      goto wrapup;
   }

/*
   all unsatisfyed edges will be investigated for splitting
*/
   sts = TOsplit_ed(topo);
   if(sts)
   {
      goto wrapup;
   }
/*
   all unconnected edges will be investigated for connections
   where no common end point exists;
*/
   sts =TOinv_fre_ed(topo);
   if(sts)
   {
      goto wrapup;
   }
#ifdef TEST_RAMIF
   investigation for ramification curves
   sts =TOinv_ramif(topo);
   if(sts)
   {
      goto wrapup;
   }
#endif
#ifdef TEST_ENGINE
   sts = TOprint_sf(topo);
   if(sts) goto wrapup;
   sts = TOprint_ed(topo);
   if(sts) goto wrapup;
   sts = TOprint_pt(topo);
   if(sts) goto wrapup;
   sts = TOprint_tp(topo);
   if(sts) goto wrapup;
   sts = TOprint_te(topo);
   if(sts) goto wrapup;
#endif
   sts = NULL;
wrapup:
   return(sts);
}
