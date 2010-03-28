/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME GR2objminline
 
     Abstract: This routine finds the closest minimum distance line
	      of two objects to a given point.

-----
%SC%

      GR2objminline(msg,obj1,env1,parms1,obj2,env2,parms2,loc_global,app_flag,
		    pl_pt,view,point,line)

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     obj1	  GRid		 first object and space information
     env1	  GRmdenv_info	 first object environment information
     parms1	  GRparms	 first object geometrical parameters
     obj2	  GRid		 second object and space information
     env2	  GRmdenv_info	 second object environment information
     loc_global	  IGRboolean     local or global flag - if TRUE, find
				 the line wrt located segment if a
				 curve is linear
     parms2	  GRparms	 second object geometrical parameters
     app_flag	  IGRboolean	 apparent min line flag TRUE - return
				 apparent minimum line 
     pl_pt	  IGRpoint	 point in plane of apparent line
     view	  IGRvector	 vector normal to plane of apparent line
     point	  IGRpoint	 point identifying desired line
     
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     msg	  IGRlong	 return code:
					MSSUCC - successful     
					MAEINFSOLUTION - infinite 
				 solution case.
					MSFAIL - an error occured
					MSINARG - invalid object
				 type for this operation

     line	  IGRline	 minimum distance line
     
     VALUE (boolean) = {TRUE,FALSE}
                        TRUE - line found
                        FALSE- no line found

-----
%MD%

     MODULES INVOKED:
	     GRget2objgeom
	     MA2pttobc
	     MAptln2dis
	     BSmdistcvcv
	     BSmdistcvsf
	     BSmdistsfsf

-----
%NB%

     NOTES:
	    The flag loc_global indicates whether the line to be found
	   is on the located segment if the (curve) geometry is linear.
            
-----

%CH%
     CHANGE HISTORY:

	RDH     05/12/86 : Design date.
	
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------
 This routine calls a math routine to find the minimum distance
line(s) and returns the one closest to the input pointl

----*/
/*EH*/

#include "grimport.h"
#include "igrtypedef.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "madef.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "msdef.h"
#include "bserr.h"

extern    IGRboolean    GRget2objgeom();
extern    IGRboolean    MAptln2dis();
extern    IGRboolean    MA2pttobc();

IGRboolean GR2objminline(msg,obj1,env1,parms1,obj2,env2,parms2,loc_global,
			 app_flag,pl_pt,view,point,line)


	   IGRlong             *msg;	/* return code			     */
	   struct GRid         *obj1;	/* first object and space number     */
	   struct GRmdenv_info *env1;   /* first object environment info     */
	   struct GRparms      *parms1; /* first object geometrical paras    */
	   struct GRid         *obj2;	/* second object and space info      */
	   struct GRmdenv_info *env2;   /* second object environment info    */
	   struct GRparms      *parms2; /* second object geometrical parms   */
	   IGRboolean	       *loc_global;/* local line flag for linear cases*/
	   IGRboolean	       *app_flag;/* flag for apparent line	     */
	   IGRpoint		pl_pt;	/* point in plane of apparent line   */
  	   IGRvector		view;	/* vector normal to plane of app line*/
	   IGRpoint	        point;	/* point identifying desired line    */
	   struct IGRline      *line;	/* minimum distance line	     */

{
  struct IGRbsp_curve *bc1,*bc2;	/* abstract geom pointers	     */
  struct IGRbsp_surface *bs1,*bs2;	/* abstract geom pointers	     */
  struct IGRplane pl;			/* plane of apparent line	     */
  struct IGRline ln;			/* degenerate line		     */
  struct IGRbsp_curve bc_ln1,bc_ln2;	/* B-spline lines		     */
  struct GRprops props1,props2;		/* geometric properties		     */

  IGRmatrix tmat;			/* plane projection matrix	     */

  IGRpoint *pt1, *pt2;			/* min dist points		     */

  IGRchar *ptr1,*ptr2;			/* abstract geom pointers	     */

  IGRdouble buf1[200],buf2[200];	/* default buffers for geometries    */
					/* doubles to force quadword algnmt  */

  IGRdouble poles1[12],knots1[6];	/* storage for ex_ln1		     */
  IGRdouble poles2[12],knots2[6];	/* storage for ex_ln2		     */
  IGRdouble dist, min_dist;		/* distances    		     */
  IGRdouble *par1, *par2;		/* u pars of min dist points	     */
  IGRdouble t;				/* t parameter			     */

  IGRlong s1,s2;			/* sizes of default buffers	     */
  IGRlong segnum;			/* segment number		     */
  IGRlong mess;				/* return code			     */
  IGRlong bsmsg;			/* return code			     */
  IGRlong i, j;				/* indexex			     */

  IGRint num;				/* number of returned lines	     */

  IGRboolean ex1,ex2;			/* extended geometry flags	     */


  *msg = MSSUCC;

  par1 = 0;
  par2 = 0;
  pt1 = 0;
  pt2 = 0;

  bc1 = 0;
  bc2 = 0;
  bs1 = 0;
  bs2 = 0;
  
  s1 = 1600;				/* sizes of bufs in bytes	     */
  s2 = 1600;

  ex1 = ex2 = FALSE;

  if( GRget2objgeom(msg,obj1,env1,&ex1,obj2,env2,&ex2,buf1,buf2,&s1,&s2,&ptr1,
		    &ptr2,&props1,&props2) )
    {
      if( props1.type == GRCURVE )
      {
	bc1 = (struct IGRbsp_curve *)ptr1;
      }
      else
      {
	bs1 = (struct IGRbsp_surface *)ptr1;
      }

      if( props2.type == GRCURVE )
      {
	bc2 = (struct IGRbsp_curve *)ptr2;
      }
      else
      {
	bs2 = (struct IGRbsp_surface *)ptr2;
      }

      if( *loc_global  &&  props1.type == GRCURVE  &&  props1.subtype == GRLN )
	{
	  bc_ln1.poles = poles1;
	  bc_ln1.knots = knots1;

	  if( props1.is_segmented )
	    {
	      MAutoparms(msg, bc1, &parms1->u, &segnum, &t);

	      MA2pttobc(msg, &bc1->poles[(segnum - 1) * 3], 
			&bc1->poles[segnum * 3], &bc_ln1);
	    }
	  else
	    {
	      MA2pttobc(msg, &bc1->poles[0],
			&bc1->poles[(bc1->num_poles - 1) * 3], &bc_ln1);
	    }
	  bc1 = &bc_ln1;
	}

      if( *loc_global  &&  props2.type == GRCURVE  &&  props2.subtype == GRLN )
	{
	  bc_ln2.poles = poles2;
	  bc_ln2.knots = knots2;

	  if( props2.is_segmented )
	    {
	      MAutoparms(msg, bc2, &parms2->u, &segnum, &t);

	      MA2pttobc(msg, &bc2->poles[(segnum - 1) * 3], 
			&bc2->poles[segnum * 3], &bc_ln2);
	    }
	  else
	    {
	      MA2pttobc(msg, &bc2->poles[0],
			&bc2->poles[(bc2->num_poles - 1) * 3], &bc_ln2);
	    }
	  bc2 = &bc_ln2;
	}

      if( *app_flag )
      {
	pl.point = pl_pt;
	pl.normal = view;

	MAplpromx(&mess,&pl,tmat);

	if( bc1 )
	{
	  MArptsxform(&mess,&bc1->num_poles,&bc1->rational,bc1->weights,tmat,
		      bc1->poles,bc1->poles);
	}
	else
	{
	  num = bs1->u_num_poles * bs1->v_num_poles;

	  MArptsxform(&mess,&num,&bs1->rational,bs1->weights,tmat,bs1->poles,
		      bs1->poles);
	}

	if( bc2 )
	{
	  MArptsxform(&mess,&bc2->num_poles,&bc2->rational,bc2->weights,tmat,
		      bc2->poles,bc2->poles);
	}
	else
	{
	  num = bs2->u_num_poles * bs2->v_num_poles;

	  MArptsxform(&mess,&num,&bs2->rational,bs2->weights,tmat,bs2->poles,
		      bs2->poles);
	}
      }

      if( props1.type == GRCURVE  &&  props2.type == GRCURVE )
      {
        BSmdistcvcv(bc1, bc2, &num, &par1, &par2, &pt1, &pt2, &dist, &bsmsg);
      }
      else
      {
	bsmsg = BSFAIL;
#ifndef IDRAW
	if( props1.type == GRCURVE  &&  props2.type == GRSURFACE )
  	{
	  BSmdistcvsf(bc1,bs2,&num,&par1,&par2,&pt1,&pt2,&dist,&bsmsg);
	}
	else
	{
	  if( props1.type == GRSURFACE  &&  props2.type == GRCURVE )
	  {
	    BSmdistcvsf(bc2,bs1,&num,&par1,&par2,&pt1,&pt2,&dist,&bsmsg);
	  }
	  else
	  {
	    if( props1.type == GRSURFACE  &&  props2.type == GRSURFACE )
	    {
	      BSmdistsfsf(bs1,bs2,&num,&par1,&par2,&pt1,&pt2,&dist,&bsmsg);
	    }
	    else
	    {
	      *msg = MSINARG;
	    }
	  }
	}
#endif  /* IDRAW */
      }

      if( bsmsg == BSSUCC  &&  ( 1 & *msg ) )
	{
	  ln.point1 = pt1[0];
	  ln.point2 = pt2[0];

	  j = 0;

	  MAptln2dis(msg, point, &ln, &min_dist);

	  for(i = 1; i < num; ++i)
	     {
	       ln.point1 = pt1[i];
	       ln.point2 = pt2[i];

	       MAptln2dis(msg, point, &ln, &dist);

	       if( dist < min_dist)
		 {
		   min_dist = dist;

		   j = i;
		 }
	     }

	  line->point1[0] = pt1[j][0];
	  line->point1[1] = pt1[j][1];
	  line->point1[2] = pt1[j][2];

	  line->point2[0] = pt2[j][0];
	  line->point2[1] = pt2[j][1];
	  line->point2[2] = pt2[j][2];
	}
      else
	{
	  if( bsmsg == BSINARG )
	    {
	      *msg = MAEINFSOLUTION;
	    }
	  else
	    {
	      *msg = MSFAIL;
	    }
	}
    }
  
  if( ptr2  &&  ptr2 != (char *)buf2 )		/* dealloc allocated storage */
  {
    om$dealloc(ptr =  ptr2 );
  }
  if( ptr1  &&  ptr1 != (char *)buf1 )
  {
    om$dealloc(ptr =  ptr1);
  }
  if( par1 )
  {
    om$dealloc(ptr =  par1);
  }
  if( par2 )
  {
    om$dealloc(ptr =  par2);
  }
  if( pt1 )
  {
    om$dealloc(ptr =  pt1);
  }
  if( pt2 )
  {
    om$dealloc(ptr =  pt2);
  }

  return( *msg == MSSUCC );

}/* This has been an R.D.H. production!!! */


