#include <stdio.h>
#include "igrtypedef.h"
#include "igr.h"
#include "gotextdef.h"
#include "hsdef.h"
#include "HStl_window.h"
#include "HPglobal.h"
#include "dump.h"

void WriteDouble( FILE *ofp, double dd )
   {
   union
      {
      double d;
      long   l[2];
      } d;

   d.d = dd;
   fprintf( ofp, "%10.6lf : %d %d\n", d.d, d.l[0], d.l[1] );
   }

void WriteDouble2( FILE *ofp, double *dd )
   {
   union
      {
      double d;
      long   l[2];
      } d[2];

   d[0].d = dd[0];
   d[1].d = dd[1];
   fprintf( ofp, "%10.6lf %10.6lf : %d %d %d %d\n", 
      d[0].d, d[1].d, 
      d[0].l[0], d[0].l[1], d[1].l[0], d[1].l[1] );
   }

void WriteDouble3( FILE *ofp, double *dd )
   {
   union
      {
      double d;
      long   l[2];
      } d[3];

   d[0].d = dd[0];
   d[1].d = dd[1];
   d[2].d = dd[2];

   fprintf( ofp, "%7.4lf %7.4lf %7.4lf : %d %d %d %d %d %d\n", 
      d[0].d, d[1].d, d[2].d, 
      d[0].l[0], d[0].l[1], d[1].l[0], d[1].l[1], d[2].l[0], d[2].l[1] );
   }

void WriteDouble4( FILE *ofp, double *dd )
   {
   union
      {
      double d;
      long   l[2];
      } d[4];

   d[0].d = dd[0];
   d[1].d = dd[1];
   d[2].d = dd[2];
   d[3].d = dd[3];

   fprintf( ofp, "%9.4lf %9.4lf %9.4lf %9.4lf: %d %d %d %d %d %d %d %d\n", 
      d[0].d, d[1].d, d[2].d, d[3].d, 
      d[0].l[0], d[0].l[1], d[1].l[0], d[1].l[1], 
      d[2].l[0], d[2].l[1], d[3].l[0], d[3].l[1] );
   }
