/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME GR2objangbis
 
     Abstract: This routine finds the angle bisector of two intersecting
	      curve objects.

-----
%SC%

     VALUE =  GR2objangbis(msg,obj1,env1,parms1,pt1,obj2,env2,parms2,pt2,
			   ext_flag,dis,pt3,bc_ln)

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     obj1	  GRid		 first object and space number
     env1	  GRmdenv_info	 first object environment information
     parms1	  GRparms	 geometric parameters for object 1
     pt1	  IGRpoint	 direction point on object one
     obj2	  GRid		 second object and space number
     env2	  GRmdenv_info	 second object environment information
     parms2	  GRparms	 geometric parameters for object 2
     pt2	  IGRpoint	 direction point on object 2
     ext_flag	  IGRshort	 flag for extend :0 -> distance extend
						 :1 -> project pt3 and
				 		       extend
     dis	  IGRdouble	 distance to extend line if ext_flag =0
     pt3	  IGRpoint	 point to project onto line to find
				 endpoint of bisector if ext_flag=1
     
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     msg	  IGRlong	 return code:
					MSSUCC - successful     
					MAINFSOLUTION - infinite 
				 solution case.
					MANOSOLUTION  - no intersection
				 point found.
					MSFAIL - an error occured
					MSINARG - invalid direction 
				 point

     bc_ln	  IGRbsp_curve	 angle bisector
     
     VALUE (boolean) = {TRUE,FALSE}
                        TRUE - angle bisector found
                        FALSE- angle bisector not found

-----
%MD%

     MODULES INVOKED:
		GRget2objgeom
		GR2bcisectutil
		GO2bcclisect
-----
%NB%

     NOTES:
	   In the case that the two objects have more than one 
	 intersection, the point, pt1, on the first object will
	 be used to identify which intersection is to be used.

	   If either direction point is at the intersection 
	 of the curves, this routine will fail since it will
	 not be able to determine which of the four possible
	 angles between the curves to bisect.            
-----

%CH%
     CHANGE HISTORY:
	
	RDH     05/12/86 : Design date.
        scw     06/23/92 : Added static ANSI C prototypes
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------
 This routine will find the intersection of the two objects which
is closest to the point on the first object. Then the tangent 
vectors of each curve at the intersection point are found and the
points on the two objects are used to orient two lines emananting
from the intersection point. These lines are then sent to MAangbis
to find a bisecting line of unit length. Finally, this line is
scaled by dis or pt3 is projected onto the line to find the endpoint
of the desired angle bisector.

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
extern    IGRboolean    GR2bcisectutil();
extern    IGRboolean    GO2bcclisect();

/*
 *  ANSI static prototype
 */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif
#if defined(__cplusplus)
extern "C" {
#endif

static IGRboolean GRfindbis __((IGRlong *msg, struct IGRbsp_curve *bc1, 
                                struct IGRbsp_curve *bc2, IGRdouble *u1, 
                                IGRdouble *u2, IGRpoint pt1, IGRpoint pt2, 
                                IGRpoint ipoint, IGRshort *ext_flag, 
                                IGRdouble *dis, IGRpoint pt3, 
                                struct IGRbsp_curve *bc_ln));

#if defined(__cplusplus)
}
#endif
#undef __



IGRboolean GR2objangbis(msg,obj1,env1,parms1,pt1,obj2,env2,parms2,pt2,
			ext_flag,dis,pt3,bc_ln)

	   IGRlong             *msg;	/* return code			     */
	   struct GRid         *obj1;	/* first object and space number     */
	   struct GRmdenv_info *env1;   /* first object environment info     */
	   struct GRparms      *parms1; /* first object geometrical paras    */
	   IGRpoint		pt1;	/* point on first object	     */
	   struct GRid         *obj2;	/* second object and space info      */
	   struct GRmdenv_info *env2;   /* second object environment info    */
	   struct GRparms      *parms2; /* second object geometrical parms   */
	   IGRpoint		pt2;	/* point on second object	     */
	   IGRshort	       *ext_flag;/* flag for type of extension	     */
	   IGRdouble	       *dis;	/* desired length of angle bisector  */
	   IGRpoint		pt3;	/* point to project to det endpoint  */
	   struct IGRbsp_curve *bc_ln;	/* angle bisector		     */

{
  struct IGRbsp_curve *bc1,*bc2;	/* abstract geom pointers	     */
  struct IGRbsp_curve bc_ln1,bc_ln2;	/* B-spline lines		     */
  struct IGRline ln;			/* degenerate line		     */
  struct GRprops props1,props2;		/* geometric properties	             */
  struct IGRline line1,line2;
  struct IGRline *lines[2];
  
  IGRchar *ptr1,*ptr2;			/* abstract geom pointers	     */
  IGRchar buf1[1300],buf2[1300];	/* default buffers for geometries    */

  IGRpoint  ipoint;			/* intersection point	 	     */
  IGRpoint  points[2];
  
  IGRdouble poles1[12],knots1[6];	/* for bc_ln1			     */
  IGRdouble poles2[12],knots2[6];	/* for bc_ln2			     */
  IGRdouble tol;			/* tolerance for intersection	     */
  IGRdouble u1,u2;			/* u parameters of intersection point*/
  IGRdouble dist;

  IGRint  bsrc;
  IGRlong s1,s2;			/* geometry buffer sizes	     */

  IGRboolean ex1,ex2;			/* extended geometry flags	     */


  *msg = MSSUCC;

  s1 = 1300;
  s2 = 1300;

  ex1 = ex2 = TRUE;

  if( GRget2objgeom(msg,obj1,env1,&ex1,obj2,env2,&ex2,buf1,buf2,&s1,&s2,&ptr1,
		    &ptr2,&props1,&props2) )
  {
    bc1 = (struct IGRbsp_curve *)ptr1;
    bc2 = (struct IGRbsp_curve *)ptr2;

    bc_ln1.poles = poles1;
    bc_ln1.knots = knots1;

    bc_ln2.poles = poles2;
    bc_ln2.knots = knots2;

    if( GR2bcisectutil(msg,&bc1,&bc2,parms1,parms2,&props1,&props2,&bc_ln1,
		       &bc_ln2) )
    {
      if( props1.type == GRCURVE && props1.subtype == GRLN && parms1->polygon_inx != 4 &&
	  props2.type == GRCURVE && props2.subtype == GRLN && parms2->polygon_inx != 4 )
      {
	line1.point1 = poles1;
	line1.point2 = &poles1[3];
	    
	line2.point1 = poles2;
	line2.point2 = &poles2[3];
	    
	lines[0] = &line1;
	lines[1] = &line2;
	    
	BSint2lns(lines,points,&dist,&bsrc);
	    
	if( bsrc == BSSUCC )
	{
	  ipoint[0] = points[0][0];
	  ipoint[1] = points[0][1];
	  ipoint[2] = points[0][2];
	  
	  u1 = u2 = 0.5;
	}
	else
	{
	  *msg = MSFAIL;
	}
      }
      else
      {
        ln.point1 = pt1;
        ln.point2 = pt1;

        bc_ln1.planar = FALSE;
        bc_ln2.planar = FALSE;

        tol = 0.01;

        GO2bcclisect(msg,bc1,bc2,&ln,&tol,ipoint,&u1,&u2);
      }

      if( 1 & *msg )
      {
        GRfindbis(msg,bc1,bc2,&u1,&u2,pt1,pt2,ipoint,ext_flag,dis,pt3,bc_ln);
      }
    }
  }
  
  if( ptr2  &&  ptr2 != buf2 )			/* dealloc allocated storage */
  {
    om$dealloc(ptr = ptr2 );
  }
  if( ptr1  &&  ptr1 != buf1 )
  {
    om$dealloc(ptr = ptr1 );
  }

  return( 1 & *msg );

}/* This has been an R.D.H. production!!! */



static IGRboolean GRfindbis(msg,bc1,bc2,u1,u2,pt1,pt2,ipoint,ext_flag,dis,
			    pt3,bc_ln)

       IGRlong             *msg;		/* return code		     */
       struct IGRbsp_curve *bc1;		/* first curve		     */
       struct IGRbsp_curve *bc2;		/* second curve		     */
       IGRdouble	   *u1;			/* u parameter ipoint bc1    */
       IGRdouble	   *u2;			/* u parmaeter ipoint bc2    */
       IGRpoint		    pt1;		/* point on bc1		     */
       IGRpoint		    pt2;		/* point on bc2		     */
       IGRpoint		    ipoint;		/* intersecion point 	     */
       IGRshort		   *ext_flag;		/* type of extension flag    */
       IGRdouble	   *dis;		/* distance to extend	     */
       IGRpoint		    pt3;		/* point to extend to	     */
       struct IGRbsp_curve *bc_ln;		/* angle bisector	     */

{
  struct IGRline ln;				/* unit angle bisector	     */

  IGRpoint p0,p1;				/* points for ln	     */

  IGRvector t1,t2;				/* tangent vectors	     */
  IGRvector v1,v2;				/* direction vectors	     */
  IGRvector v3;					/* temp vector		     */

  IGRdouble dot;				/* dot product		     */
  IGRdouble tpar;				/* t parameter		     */

  IGRlong mess;					/* return code		     */

extern    IGRboolean    MAbcu1derivative();
extern    IGRboolean    MAsubvc();
extern    IGRboolean    MAunitvc();
extern    IGRboolean    MAaddvc();


  *msg = MSSUCC;

  if( MAbcu1derivative(&mess,bc1,u1,t1) && MAbcu1derivative(&mess,bc2,u2,t2) )
    {
      MAsubvc(&mess,pt1,ipoint,v1);
      MAsubvc(&mess,pt2,ipoint,v2);

      MAdotvc(&mess,v1,t1,&dot);

      if( dot < 0.0 )
        {
          t1[0] = -t1[0];
	  t1[1] = -t1[1];
	  t1[2] = -t1[2];
	}
      else
	{
	  if( dot == 0.0 )
	    {
	      *msg = MSINARG;
	    }
	}

      if( 1 & *msg )
	{
	  MAdotvc(&mess,v2,t2,&dot);

	  if( dot < 0.0 )
	    {
	      t2[0] = -t2[0];
	      t2[1] = -t2[1];
	      t2[2] = -t2[2];
	    }
	  else
	    {
	      if( dot == 0.0 )
	   	{
		  *msg = MSINARG;
		}
	    }
	}

      if( 1 & *msg )
	{
	  if( MAunitvc(&mess,t1,t1)  &&  MAunitvc(&mess,t2,t2) )
	    {
	      MAaddvc(&mess,t1,t2,v3);

	      if( MAunitvc(&mess,v3,v3) )
	        {
	          if( *ext_flag )       
		    {
	              ln.point1 = ipoint;
	              ln.point2 = p0;

		      MAaddvc(&mess,ipoint,v3,ln.point2);

		      MAptlnproj(&mess,pt3,&ln,p1,&tpar);
		    }
	          else
		    {
		      MAscalvc(&mess,dis,v3,v3);

		      MAaddvc(&mess,ipoint,v3,p1);
		    }

	          MA2pttobc(&mess,ipoint,p1,bc_ln);
		}
	      else
		{
		  *msg = MSFAIL;
		}
	    }
	}
    }

  return( 1 & *msg );

}/* This has been an R.D.H. production!!! */
