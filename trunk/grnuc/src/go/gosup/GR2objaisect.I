/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME GR2objaisect
 
     Abstract: This routine finds the closest intersection of two curve
	      objects to a given point. The natural extension of
	      the objects are considered.

-----
%SC%

      GR2objaisect(msg,obj1,env1,parms1,obj2,env2,parms2,point,viewvc,ipoint)

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
     parms2	  GRparms	 second object geometrical parameters
     point	  IGRpoint	 point identifying desired intersection
     viewvc	  IGRvector	 unit viewing vector
     
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
					MSINARG - object not a GRCURVE
					MSFAIL - an error occured

     ipoint	  IGRpoint	 intersection point
     
     VALUE (boolean) = {TRUE,FALSE}
                        TRUE - intersection point found
                        FALSE- no intersection point found

-----
%MD%

     MODULES INVOKED:
	     GRget2objgeom
	     GR2bcisectutil
	     MAplpromx
	     MArptsxform
	     GO2bcalisects  
	     MAbcueval

-----
%NB%

     NOTES:
	   In the infinite solution case, the intersection point returned
	  will be either the beginning point or end point of the interval
	  of overlap depending on which is closest to the input point.

	   The input viewing vector must be a unit vector for this routine
	  to function properly.

	   This routine will only service objects whose type returned from
	  Getprops is GRCURVE.

	   The point which is returned will be a point on the first 
	  object.            
-----

%CH%
     CHANGE HISTORY:

	RDH     05/12/86 : Design date.
	
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------
 This routine finds the closest apparent intersection of two objects
by getting their extended geometries and projecting then onto the
plane defined by the viewing vector and the approximate point of 
intersection. Then, a routine is called which finds the closest
intersection to the line formed by the input point and the viewing
vector. Finally, the parameter of the point on the first (transformed)
curve is used to evaluate the intersection point on the first
untransformed curve.

----*/
/*EH*/

class implementation GRvg;

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
extern    IGRboolean    MAplpromx();
extern    IGRboolean    MArptsxform();
extern    IGRboolean    MAaddvc();
extern    void          BSint2lns();

IGRboolean GR2objaisect(msg,obj1,env1,parms1,obj2,env2,parms2,point,viewvc,
			ipoint)

	   IGRlong             *msg;	/* return code			     */
	   struct GRid         *obj1;	/* first object and space number     */
	   struct GRmdenv_info *env1;   /* first object environment info     */
	   struct GRparms      *parms1; /* first object geometrical paras    */
	   struct GRid         *obj2;	/* second object and space info      */
	   struct GRmdenv_info *env2;   /* second object environment info    */
	   struct GRparms      *parms2; /* second object geometrical parms   */
	   IGRpoint	        point;	/* point identifying desired ipoint  */
	   IGRvector	  	viewvc; /* viewing vector		     */
	   IGRpoint	        ipoint;	/* desired intersection point	     */

{
  struct IGRbsp_curve *bc1,*bc2;	/* abstract geom pointers	     */
  struct IGRline ln;			/* degenerate line		     */
  struct IGRbsp_curve bc_ln1,bc_ln2;	/* B-spline lines		     */
  struct GRprops props1,props2;		/* geometric properties		     */
  struct IGRplane pl;			/* view plane			     */
  struct IGRline *lines[2];
  struct IGRline line1,line2;
  
  IGRmatrix tmat;			/* plane projection matrix	     */

  IGRpoint point2;			/* point for ln			     */
  IGRpoint points[2];
  
  IGRchar *ptr1,*ptr2;			/* abstract geom pointers	     */

  IGRdouble buf1[200],buf2[200];	/* default buffers for geometries    */
  IGRdouble poles1[6],knots1[4];	/* storage for ex_ln1		     */
  IGRdouble poles2[6],knots2[4];	/* storage for ex_ln2		     */
  IGRdouble saved_poles[6];
    
  IGRdouble tol;			/* tolerance for intersection	     */
  IGRdouble u1,u2;			/* u parameters of intersection point*/
  IGRdouble h;				/* homogeous factor for curve eval   */
  IGRdouble dist;
  IGRdouble t;

  IGRlong i;    
  IGRlong s1;				/* size of default buffers	     */
  IGRlong mess;				/* return code			     */
  IGRlong OMmsg,OMmsg1;

  IGRint bsrc;
  
  IGRshort option;			/* option for curve eval	     */

  IGRboolean ext_geom;			/* get extended geometry flag	     */
  IGRboolean have_lines = FALSE;
  

  *msg = MSSUCC;

  s1 = 200 * sizeof(IGRdouble);			/* size of bufs in bytes	*/

  ext_geom = TRUE;				/* get extended geometries	*/

  if( GRget2objgeom(msg,obj1,env1,&ext_geom,obj2,env2,&ext_geom,buf1,buf2,&s1,
		    &s1,&ptr1,&ptr2,&props1,&props2) )
  {
    if( props1.type == GRCURVE  &&  props2.type == GRCURVE )
    {
      bc1 = (struct IGRbsp_curve *)ptr1;
      bc2 = (struct IGRbsp_curve *)ptr2;

      pl.point = point;
      pl.normal = viewvc;

      MAplpromx(&mess,&pl,tmat);

      bc_ln1.poles = poles1;
      bc_ln1.knots = knots1;

      bc_ln2.poles = poles2;
      bc_ln2.knots = knots2;

      if( GR2bcisectutil(msg,&bc1,&bc2,parms1,parms2,&props1,&props2,&bc_ln1,
			 &bc_ln2) )
      {
        if( props1.type == GRCURVE && props1.subtype == GRLN && parms1->polygon_inx != 4 &&
            props2.type == GRCURVE && props2.subtype == GRLN && parms2->polygon_inx != 4)
        {
          have_lines = TRUE;

          for(i = 0; i < 6; ++i)
          {
            saved_poles[i] = poles1[i];
          }
        }
          
        MArptsxform(&mess,&bc1->num_poles,&bc1->rational,bc1->weights,tmat,
		    bc1->poles,bc1->poles);

        MArptsxform(&mess,&bc2->num_poles,&bc2->rational,bc2->weights,tmat,
		    bc2->poles,bc2->poles);

        if( have_lines )
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
            point[0] = points[0][0];
            point[1] = points[0][1];
            point[2] = points[0][2];

            MAptlnproj(msg,point,&line1,ipoint,&t);              
           
            line1.point1 = saved_poles;
            line1.point2 = &saved_poles[3];
              
            MAptattparm(msg,&t,&line1,ipoint);
          }
          else
          {
            *msg = MANOSOLUTION;
          }
        }
        else
        {
	  ln.point1 = point;
	  ln.point2 = point2;
	  MAaddvc(&mess,point,viewvc,point2);

	  tol = 0.01;

	  bc_ln1.planar = FALSE;
	  bc_ln2.planar = FALSE;

	  if( GO2bcclisect(msg,bc1,bc2,&ln,&tol,ipoint,&u1,&u2) )
	  {
	    OMmsg = om$send(msg = message GRvg.GRgetexgeom(msg,
			     		&env1->matrix_type,env1->matrix,ptr1),
                            senderid = NULL_OBJID,
                            targetid = obj1->objid,
                            targetos = obj1->osnum);

	    OMmsg1 = om$send(msg = message GRvg.GRgetexgeom(&mess,
			     		&env2->matrix_type,env2->matrix,ptr2),
                             senderid = NULL_OBJID,
                             targetid = obj2->objid,
                             targetos = obj2->osnum);

	    if( 1 & OMmsg & OMmsg1 & mess & *msg )
	    {
	      bc1 = (struct IGRbsp_curve *)ptr1;
	      bc2 = (struct IGRbsp_curve *)ptr2;

      	      if( GR2bcisectutil(msg,&bc1,&bc2,parms1,parms2,&props1,&props2,
				 &bc_ln1,&bc_ln2) )
	      {
	        option = FALSE;

	        if( !MAbcueval(&mess,bc1,&option,&u1,ipoint,&h) )
	        {
	          *msg = MSFAIL;
	        }
	      }
	    }
	    else
	    {
	      if( 1 & *msg )
	      {
	        if( !(1 & mess) )
	        {
	          *msg = mess;
	        }
	      }
	    }
	  }
	}
      }
    }
    else
    {
      *msg = MSINARG;
    }
  } 
 
  if( ptr2  &&  ptr2 != (char *)buf2 )		/* dealloc allocated storage */
  {
    om$dealloc(ptr = ptr2 );
  }
  if( ptr1  &&  ptr1 != (char *)buf1 )
  {
    om$dealloc(ptr = ptr1 );
  }

  return( *msg == MSSUCC );

}/* This has been an R.D.H. production!!! */

end implementation GRvg;

