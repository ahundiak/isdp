/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME GR2objisect
 
     Abstract: This routine finds the closest intersection of two
	      objects to a given point. The natural extension of
	      the objects are considered.

-----
%SC%

     GR2objisect(msg,obj1,env1,parms1,obj2,env2,parms2,point,ipoint)

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     obj1	  GRid		 first object and space number
     env1	  GRmdenv_info	 first object environment information
     parms1	  GRparms	 geometric parameters for object 1
     obj2	  GRid		 second object and space number
     env2	  GRmdenv_info	 second object environment information
     parms2	  GRparms	 geometric parameters for object 2
     point	  IGRpoint	 point identifying desired intersection
     
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

     ipoint	  IGRpoint	 intersection point
     
     VALUE (boolean) = {TRUE,FALSE}
                        TRUE - intersection found
                        FALSE- no intersection found

-----
%MD%

     MODULES INVOKED:
		GRget2objgeom
		GR2bcisectutil
		GO2bcclisect
-----
%NB%

     NOTES:
	   In the infinite solution case, the intersection point returned
	  will be either the beginning point or end point of the interval
	  of overlap depending on which is closest to the input point.
            
-----

%CH%
     CHANGE HISTORY:

	RDH     05/12/86 : Design date.
	
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------
 This routine gets the object geometries and properties and then
prepares the geometries for intersection. This preparation entails
clipping any linear geometries against the other geometry's range
cube.

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
#include "maerr.h"

extern    IGRboolean    GRget2objgeom();
extern    IGRboolean    GR2bcisectutil();
extern    IGRboolean    GO2bcclisect();
extern    IGRboolean    GObcsclisect();
extern    void          BSint2lns();

IGRboolean GR2objisect(msg,obj1,env1,parms1,obj2,env2,parms2,point,ipoint)

	   IGRlong             *msg;	/* return code			     */
	   struct GRid         *obj1;	/* first object and space number     */
	   struct GRmdenv_info *env1;   /* first object environment info     */
	   struct GRparms      *parms1; /* first object geometrical paras    */
	   struct GRid         *obj2;	/* second object and space info      */
	   struct GRmdenv_info *env2;   /* second object environment info    */
	   struct GRparms      *parms2; /* second object geometrical parms   */
	   IGRpoint	        point;	/* point identifying desired ipoint  */
	   IGRpoint	        ipoint;	/* desired intersection point	     */

{
  struct IGRbsp_curve *bc1,*bc2;	/* abstract geom pointers	     */
  struct IGRbsp_curve bc_ln1,bc_ln2;	/* B-spline lines		     */
  struct IGRbsp_surface *bs1,*bs2;	/* abstract geom pointers	     */
  struct IGRline ln;			/* degenerate line		     */
  struct GRprops props1,props2;		/* geometric properties	             */
  struct IGRline *lines[2];
  struct IGRline line1,line2;
  
  IGRchar *ptr1,*ptr2;			/* abstract geom pointers	     */

  IGRpoint points[2];

  IGRdouble buf1[200],buf2[200];	/* default buffers for geometries    */
  IGRdouble poles1[6],knots1[4];	/* for bc_ln1			     */
  IGRdouble poles2[6],knots2[4];	/* for bc_ln2			     */
  IGRdouble tol;			/* tolerance for intersection	     */
  IGRdouble u1,u2,u3;			/* parameters of intersection point  */
  IGRdouble dist;
  
  IGRlong s1;				/* sizes of buf1 and buf2 resp.	     */

  IGRint bsrc;

  IGRboolean ext_geom;		 	/* extended geometry flag	     */



  *msg = MSSUCC;

  s1 = 200 * sizeof(IGRdouble);

  ext_geom = TRUE;

  if( GRget2objgeom(msg,obj1,env1,&ext_geom,obj2,env2,&ext_geom,buf1,buf2,&s1,
		    &s1,&ptr1,&ptr2,&props1,&props2) )
  {
    bc1 = (struct IGRbsp_curve *)ptr1;

#ifndef IDRAW

    if( props1.type == GRSURFACE )
    {
      bs1 = (struct IGRbsp_surface *)ptr1;
    }

#endif

    bc2 = (struct IGRbsp_curve *)ptr2;

#ifndef IDRAW

    if( props2.type == GRSURFACE )
    {
      bs2 = (struct IGRbsp_surface *)ptr2;
    }

#endif

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
	}
	else
	{
	  *msg = MANOSOLUTION;
	}
      }
      else
      {
        ln.point1 = point;
        ln.point2 = point;

        tol = 0.01;

        bc_ln1.planar = FALSE;		/* Lines must be non-planar */
	bc_ln2.planar = FALSE;		/* for the math routines to */
						/* work.		    */
	if( props1.type == GRCURVE  &&  props2.type == GRCURVE )
	{
	  GO2bcclisect(msg,bc1,bc2,&ln,&tol,ipoint,&u1,&u2);
	}
	else
	{
	  *msg = MSINARG;
	  
#ifndef IDRAW
	 
	  if( props1.type == GRCURVE  &&  props2.type == GRSURFACE )
	  {
	    GObcsclisect(msg,bc1,bs2,&ln,&tol,ipoint,&u1,&u2,&u3);
	  }
	  else
	  {
	    if( props1.type == GRSURFACE  &  props2.type == GRCURVE )
	    {
	      GObcsclisect(msg,bc2,bs1,&ln,&tol,ipoint,&u1,&u2,&u3);
	    }
	  }
#endif
	}
      }
    }
  }
  
  if( ptr2  &&  ptr2 != (char *)buf2 )			/* dealloc allocated storage */
  {
    om$dealloc(ptr = ptr2 );
  }
  if( ptr1  &&  ptr1 != (char *)buf1 )
  {
    om$dealloc(ptr = ptr1 );
  }

  return( *msg == MSSUCC );

}/* This has been an R.D.H. production!!! */

