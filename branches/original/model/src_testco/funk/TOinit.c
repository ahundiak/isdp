/*
Name

    TOinit

Abstract

    text

Synopsis

    int TOinit( struct topology *topo)

Description

    Initialize contents of structure topo

Return Value

    0

Notes

Index

Keywords

History

    21 Feb 94   B.Burkhardt     Creation
*/

#include <stdio.h>
#include "TOtopology.h"
#include "TOstruct1.h"
#include "TOproto_ta.h"
#include "TOnumbers.h"

int TOinit( struct topology *topo)
{
   int sts;
#ifdef DBG
   printf("TOinit\n");
#endif

   topo->sf.sfhead = NULL;
   topo->sf.sftail = NULL;
   topo->sf.num_sf = NULL;

   topo->ed.ehead = NULL;
   topo->ed.etail = NULL;
   topo->ed.num_ed = NULL;

   topo->pt.phead = NULL;
   topo->pt.ptail = NULL;
   topo->pt.num_pt = NULL;

   topo->tp.tphead = NULL;
   topo->tp.tptail = NULL;
   topo->tp.num_tp = NULL;

   topo->te.tehead = NULL;
   topo->te.tetail = NULL;
   topo->te.num_te = NULL;

   topo->mo.mohead = NULL;
   topo->mo.motail = NULL;

/*
   initialization of the generell topological data structure
   and the input data structures
*/
   sts = TOinit_mo(topo);
   if(sts)
      return(-1);
   sts = TOinit_input(topo);
   if(sts)
      return(-1);

   sts = TOinit_topo(topo);
   if(sts)
      return(-1);

   return 0;
}
