#include <stdio.h>

/*---ConvDouble------------------------------------------------------------*/

int ConvDouble( double *d, int n )

   {
   union
      {
      char   c[8];
      double   d;
      } x, y;

   if( d == NULL )
      {
      return(0);
      }

   while( n )
      {
      x.d = *d;

      y.c[0] = x.c[7];
      y.c[1] = x.c[6];
      y.c[2] = x.c[5];
      y.c[3] = x.c[4];
      y.c[4] = x.c[3];
      y.c[5] = x.c[2];
      y.c[6] = x.c[1];
      y.c[7] = x.c[0];

      *d = y.d;

      d++;
      n--;
      }

   return(1);
   }

/*---ConvShort-------------------------------------------------------------*/

int ConvShort( short *s, int n )

   {
   union
      {
      char   c[2];
      short   s;
      } x, y;

   if( s == NULL )
      {
      return(0);
      }

   while( n )
      {
      x.s = *s;

      y.c[0] = x.c[1];
      y.c[1] = x.c[0];

      *s = y.s;

      s++;
      n--;
      }
   return(1);
   }

/*---ConvInt---------------------------------------------------------------*/

int ConvInt( int *i, int n )

   {
   union
      {
      char   c[4];
      int   i;
      } x, y;

   if( i == NULL )
      {
      return(0);
      }

   while( n )
      {
      x.i = *i;

      y.c[0] = x.c[3];
      y.c[1] = x.c[2];
      y.c[2] = x.c[1];
      y.c[3] = x.c[0];

      *i = y.i;

      i++;
      n--;
      }

   return(1);
   }


