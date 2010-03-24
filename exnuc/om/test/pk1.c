#include 	<errno.h>
#include	<stdio.h>
#include	<math.h>
#include	"pk.h"

extern double sqrt();

int	distrib[20][20] = { {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 } };

main()
{
 double	mdx=0.0;	/* x2 - x1 mean */
 double mdy=0.0;	/* y2 - y1 mean */
 double mdd=0.0;	/* diagonal length mean */
 double	sdx=0.0;	/* x2 - x1 summation */
 double sdy=0.0;	/* y2 - y1 summation */
 double sdd=0.0;	/* diagonal length summation */
 double vdx=0.0;	/* variant of x2 - x1 */
 double vdy=0.0;	/* variant of y2 - y1 */
 double vdd=0.0;	/* variant of diagonal length */
 double maxX=0.0;	/* maximum X value */
 double maxY=0.0;	/* maximum Y value */
 double minX=9999999999990.0;	/* minimum X value */
 double minY=9999999999990.0;	/* minimum Y value */
 double maxXC=0.0;	/* maximum X center value */
 double maxYC=0.0;	/* maximum Y center value */
 double minXC=9999999999990.0;	/* minimum X center value */
 double minYC=9999999999990.0;	/* minimum Y center value */
 double maxDX=0.0;	/* maximum DX value */
 double maxDY=0.0;	/* maximum DY value */
 double minDX=9999999999990.0;	/* minimum DX value */
 double minDY=9999999999990.0;	/* minimum DY value */
 double ssize=0.0;	/* object size summation */
 FILE	*fi, *fo1, *fo2;
 HEAD	h;	/* header record for pk1.out file */
 InObjRec ir;	/* input object record */
 OutObjRec or;	/* output object record */
 int	zz, numobjs=0;	/* N */
 int	sumBigs=0;	/* objects with xdist or ydist > 15% */
 double xrange;
 double yrange;

 /* create output files */
 /* open input file */
 if ( ! (fi = fopen ("/usr3/group/rtree.dat", "r")))
	return(errno);
 if ( ! (fo1 = fopen("pk1.out", "w")))
	return(errno);
 if ( ! (fo2 = fopen("pk1.stat", "w")))
	return(errno);

 /* 1st pass thru input file - get summations and means and maxs */
 /* while not end of file */
 while (1)
 {
   double  dx, dy;

   /* read record */
   zz = fscanf (fi, "%lf%lf%lf%lf%d", &ir.x1, &ir.y1, &ir.x2, &ir.y2, &ir.size);
   if( zz != 5)
   {
	printf("1st pass thru\n");
	break;	/* end of file */
   }
   /* calculate dx, dy, length of diag., and totals of each */
   numobjs++;
   if ( maxX < ir.x2 ) maxX = ir.x2;
   if ( maxY < ir.y2 ) maxY = ir.y2;
   if ( minX > ir.x1 ) minX = ir.x1;
   if ( minY > ir.y1 ) minY = ir.y1;
   dx = ir.x2 - ir.x1;
   sdx += dx;
   dy = ir.y2 - ir.y1;
   sdy += dy;
   if( dx < 0 ) dx *= -1;
   if( dy < 0 ) dy *= -1;
   if ( maxDX < dx ) maxDX = dx;
   if ( maxDY < dy ) maxDY = dy;
   if ( minDX > dx ) minDX = dx;
   if ( minDY > dy ) minDY = dy;
   sdd += sqrt( (dx * dx) + (dy * dy) );
   ssize += ir.size;

   /* calculate MAX and MIN X & Y Centers */

   if( (ir.x1 + ir.x2)/2 > maxXC ) maxXC = (ir.x1 + ir.x2)/2 ;
   if( (ir.y1 + ir.y2)/2 > maxYC ) maxYC = (ir.y1 + ir.y2)/2 ;
   if( (ir.x1 + ir.x2)/2 < minXC ) minXC = (ir.x1 + ir.x2)/2 ;
   if( (ir.y1 + ir.y2)/2 < minYC ) minYC = (ir.y1 + ir.y2)/2 ;

 }

 h.maxX = maxXC;
 h.maxY = maxYC;
 h.minX = minXC;
 h.minY = minYC;
 h.meanSize = ssize / numobjs;
 h.numObjs = numobjs;
 mdx = sdx / numobjs;
 mdy = sdy / numobjs;
 mdd = sdd / numobjs;
 xrange = maxX - minX;
 yrange = maxY - minY;

 /* print header to pk1.out file */
 if ((fwrite(&h,sizeof(HEAD),1,fo1)) != 1)
      return(errno);
 
 if( (fseek (fi,0,0)) != NULL )
	return(errno);

 /* 2nd pass thru input file - get variants and center points and output records */
 /* while not end of file */
 while (1)
 {
   double  dx, dy, dd;
   int	xdist, ydist;

   /* read record */
   zz = fscanf (fi, "%lf%lf%lf%lf%d", &ir.x1, &ir.y1, &ir.x2, &ir.y2, &ir.size);
   if( zz != 5)
   {
	printf("2nd pass thru\n");
	break;	/* end of file */
   }

   /* calculate center point and variants and output record */

   dx = ir.x2 - ir.x1;
   dy = ir.y2 - ir.y1;
   if( dx < 0 ) dx *= -1;
   if( dy < 0 ) dy *= -1;
   dd += sqrt( (dx * dx) + (dy * dy) );

   if ( dx - mdx >= 0 )
    vdx += dx - mdx;
   else
    vdx += mdx - dx;
   if ( dy - mdy >= 0 )
    vdy += dy - mdy;
   else
    vdy += mdy - dy;
   if ( dd - mdd >= 0 )
    vdd += dd - mdd;
   else
    vdd += mdd - dd;

   /* calculate dx/xrange % and note in 20:20 array of distribution */
   /* (also dy/yrange) */

   xdist = ((dx*100)/xrange)/5;
   if( (((int)dx*100)/(int)xrange) % 5 ) xdist++;
   ydist = ((dy*100)/yrange)/5;
   if( (((int)dy*100)/(int)yrange) % 5 ) ydist++;
   distrib[ydist][xdist]++;

   or.x1 = ir.x1;
   or.x2 = ir.x2;
   or.y1 = ir.y1;
   or.y2 = ir.y2;
   or.size = ir.size;
   if( xdist > 3 || ydist > 3 ) 
   { or.flag = 1; sumBigs++; }
   else or.flag = 0;
   or.xc = (or.x1 + or.x2)/2;
   or.yc = (or.y1 + or.y2)/2;
   if ((fwrite(&or,sizeof(OutObjRec),1,fo1)) != 1)
      return(errno);

 }

 /* output statistics to pk1.stat */
 fprintf(fo2, "X mean is %f\n", mdx);
 fprintf(fo2, "Y mean is %f\n", mdy);
 fprintf(fo2, "D mean is %f\n", mdd);
 fprintf(fo2, "X var is %f\n", vdx/numobjs);
 fprintf(fo2, "Y var is %f\n", vdy/numobjs);
 fprintf(fo2, "D var is %f\n", vdd/numobjs);
 fprintf(fo2, "X center max is %f\n", maxXC);
 fprintf(fo2, "Y center max is %f\n", maxYC);
 fprintf(fo2, "X center min is %f\n", minXC);
 fprintf(fo2, "Y center min is %f\n", minYC);
 fprintf(fo2, "X max is %f\n", maxX);
 fprintf(fo2, "Y max is %f\n", maxY);
 fprintf(fo2, "DX max is %f\n", maxDX);
 fprintf(fo2, "DY max is %f\n", maxDY);
 fprintf(fo2, "X min is %f\n", minX);
 fprintf(fo2, "Y min is %f\n", minY);
 fprintf(fo2, "DX min is %f\n", minDX);
 fprintf(fo2, "DY min is %f\n", minDY);
 fprintf(fo2, "Number of objects is %d\n", numobjs);
 fprintf(fo2, "Mean objects size is %f\n", h.meanSize);
 fprintf(fo2, "Total objects > 15%% distribution is %d\n", sumBigs);
 fprintf(fo2, "\n       0%%    5%%   10%%   15%%   20%%   25%%   30%%   35%%   40%%   45%%   50%%   55%%   60%%   65%%   70%%   75%%   80%%   85%%   90%%   95%%  \n");
 for(zz=0; zz<20; zz++)	/* row or ydist */
 {
  int	cc;
   fprintf(fo2, "\n%2d%%",zz*5);
  for(cc=0; cc<20; cc++)	/* column or xdist */
   fprintf(fo2, "%6d", distrib[zz][cc]);
 }

 fclose (fi);
 fclose (fo1);
 fclose (fo2);
 exit();
};
