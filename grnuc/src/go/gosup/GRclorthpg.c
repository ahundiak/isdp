/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME GRclorthpg
 
     Abstract: This routine finds the point needed to close an
	      orthogonal polygon.

-----
%SC%

     VALUE = GRclorthpg(msg,pg)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     pg		  IGRpolyline	 The polygon to close 

-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     msg	  IGRlong	 return code:
					MSSUCC - successful

     pg		  IGRpolyline	 the closed polygon (same as input)     

     VALUE (boolean) = {TRUE,FALSE}
                        TRUE - pg closed
                        FALSE- pg not closed

-----
%MD%

     MODULES INVOKED:

-----
%NB%

     NOTES:
            The polygon must contain storage for at least two 
	   additional points.

-----

%CH%
     CHANGE HISTORY:

	RDH  06/11/86  : Creation date. (Implementation of algorithm.)
        scw  06/23/92  : Added static ANSI C prototypes
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/

#include "grimport.h"
#include "igrdef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "madef.h"
#include "mapriv.h"
#include "msdef.h"

extern    IGRboolean    MAsubvc();
extern    IGRboolean    MAdotvc();
extern    IGRboolean    MA2lnisect();

/*
 *  ANSI static prototype
 */
#if defined(__STDC__) || defined(__cplusplus)
#define __(p) p
#else
#define __(p) ()
#endif
#if defined(__cplusplus)
extern "C" {
#endif

static IGRboolean GRfindfirst __((IGRlong *msg, struct IGRpolyline *pg, 
                                  IGRlong *i, IGRlong *j));
static IGRboolean GRfindlast __((IGRlong *msg, struct IGRpolyline *pg, 
                                 IGRlong *i, IGRlong *j));
static IGRboolean GRfindfperp __((IGRlong *msg, struct IGRpolyline *pg, 
                                  IGRdouble *tol, IGRvector vc));
static IGRboolean GRfindlperp __((IGRlong *msg, struct IGRpolyline *pg, 
                                  IGRdouble *tol, IGRvector vc));

#if defined(__cplusplus)
}
#endif
#undef __



IGRboolean GRclorthpg(msg,pg)

	   IGRlong            *msg;		/* return code		     */
	   struct IGRpolyline *pg;		/* polygon to close	     */
{
  struct IGRline ln1,ln2,ln3,ln4;		/* lines to intersect	     */

  IGRpoint ipt;					/* intersection point        */
  IGRpoint pt3, pt4;				/* points for ln1 and ln2    */

  IGRvector vc;					/* normal vector	     */

  IGRdouble t1, t2;				/* intersection t parameters */
  IGRdouble tol;				/* intersection tolerance    */
  IGRdouble dis;				/* distance from pt1 to ptn  */

  IGRshort num;					/* number of points to add   */

  IGRlong i,j,k,l,n;				/* indexes		     */
  IGRlong mess;					/* return code		     */

  IGRboolean cut_away;				/* cut away rule flag	     */
  IGRboolean value;				/* function return value     */


  *msg = MSSUCC;

  MA2pt2dis(&mess,&pg->points[0],&pg->points[(pg->num_points - 1) * 3],&dis);

  if( dis > 0.0 )
    {
      tol = 0.000000001;
      cut_away = FALSE;

      if( GRfindfirst(msg,pg,&i,&j) &&  GRfindlast(msg,pg,&k,&l) )
	{
	  num = 1;

	  n = pg->num_points;

	  ln1.point1 = &pg->points[i * 3];
	  ln1.point2 = &pg->points[j * 3];

	  ln2.point1 = &pg->points[k * 3];
	  ln2.point2 = &pg->points[l * 3];

	  value =  MA2lnisect(msg,&ln1,&ln2,&tol,ipt,&t1,&t2);

          if( value  &&  t1 <= 0.0  &&  t2 <= 0.0 )
            {
              if( t1 != 0.0  &&  t2 != 0.0 )
	        {
		  ++num;
	        }
            }
          else
            {
	      if( GRfindfperp(msg,pg,&tol,vc) )
		{
		  ln3.point1 = ln1.point1;
		  ln3.point2 = pt3;

		  MAaddvc(&mess,ln3.point1,vc,ln3.point2);

		  value = MA2lnisect(&mess,&ln3,&ln2,&tol,ipt,&t1,&t2);

		  if( value )
		    {
		      if( t2 != 0.0 )
			{
			  ++num;

			  if( t2 > 0.0 )
			    {
			      --n;

			      cut_away = TRUE;
			    }
			}
		    }
		  else
		    {
		      if( GRfindlperp(msg,pg,&tol,vc) )
			{
			  ln4.point1 = ln2.point1;
			  ln4.point2 = pt4;

			  MAaddvc(&mess,ln4.point1,vc,ln4.point2);

			  value = MA2lnisect(&mess,&ln3,&ln4,&tol,ipt,&t1,&t2);

			  if( value )
			    {
			      if( t1 != 0.0 )
				{
				  ++num;
				}
			    }
			  else
			    {
			      *msg = MSFAIL;
			    }
			}
		    }
		}
	    }

	  if( value )
	    {
	      ++(pg->num_points);

	      if( num == 1 )
		{
	          pg->points[n * 3]     = pg->points[0];
	          pg->points[n * 3 + 1] = pg->points[1]; 
	          pg->points[n * 3 + 2] = pg->points[2];
		}
	      else
		{
		  pg->points[n * 3]     = ipt[0];
		  pg->points[n * 3 + 1] = ipt[1];
		  pg->points[n * 3 + 2] = ipt[2];

		  ++n;

		  pg->points[n * 3]     = pg->points[0];
		  pg->points[n * 3 + 1] = pg->points[1];
		  pg->points[n * 3 + 2] = pg->points[2];

		  if( !cut_away )
		    {
		      ++(pg->num_points);
		    }
		}  
	    }
	}
    }

  return( *msg == MSSUCC );

}/* This has been an R.D.H. production!!! */


static IGRboolean GRfindfirst(msg,pg,i,j)

       IGRlong 		  *msg;
       struct IGRpolyline *pg;
       IGRlong 		  *i;
       IGRlong		  *j;
{
  IGRdouble dis;

  IGRlong k;
  IGRlong mess;


  *msg = MSSUCC;

  for(k = 0; k < pg->num_points - 1; ++k)
     {
       MA2pt2dis(&mess,&pg->points[k * 3],&pg->points[(k + 1) * 3],&dis);

       if( dis > 0.0 )
         {
	   *i = k;
	   *j = k + 1;
	   break;
         }
     }

  if( k >= pg->num_points - 1 )
    {
      *msg = MASDGENRAT;
    }

  return( *msg == MSSUCC );

}/* This has been an R.D.H. production!!! */



static IGRboolean GRfindlast(msg,pg,i,j)

       IGRlong 		  *msg;
       struct IGRpolyline *pg;
       IGRlong 		  *i;
       IGRlong		  *j;
{
  IGRdouble dis;

  IGRlong k;
  IGRlong mess;


  *msg = MSSUCC;

  for(k = pg->num_points - 1; k > 0; --k)
     {
       MA2pt2dis(&mess,&pg->points[k * 3],&pg->points[(k - 1) * 3],&dis);

       if( dis > 0.0 )
         {
	   *i = k;
	   *j = k - 1;
	   break;
         }
     }

  if( k == 0 )
    {
      *msg = MASDGENRAT;
    }

  return( *msg == MSSUCC );

}/* This has been an R.D.H. production!!! */
	  


static IGRboolean GRfindfperp(msg,pg,tol,vc)

       IGRlong		  *msg;
       struct IGRpolyline *pg;
       IGRdouble	  *tol;
       IGRvector	   vc;

{
  struct IGRpolyline py;

  IGRvector v1;

  IGRdouble dot_pro;

  IGRlong k,l;
  IGRlong mess;

  IGRboolean done;



  *msg = MSSUCC;

  if( GRfindfirst(msg,pg,&k,&l) )
    {
      MAsubvc(&mess,&pg->points[k * 3],&pg->points[l * 3],v1);

      py.points     = &pg->points[l * 3];
      py.num_points = pg->num_points - l;

      done = FALSE;

      while( !done  && *msg == MSSUCC )
	   {
	     if( GRfindfirst(msg,&py,&k,&l) )
	       {
		 MAsubvc(&mess,&py.points[l * 3],&py.points[k * 3],vc);

		 MAdotvc(&mess,v1,vc,&dot_pro);

		 if( MAabsolute(dot_pro) <= *tol )
		   {
		     done = TRUE;
		   }
		 else
		   {
		     py.points     = &py.points[l * 3];
		     py.num_points = py.num_points - l;
		   }
	       }
	   }
    }

  return( *msg == MSSUCC );

}/* This has been an R.D.H. production!!! */


static IGRboolean GRfindlperp(msg,pg,tol,vc)

       IGRlong		  *msg;
       struct IGRpolyline *pg;
       IGRdouble	  *tol;
       IGRvector	   vc;

{
  struct IGRpolyline py;

  IGRvector v1;

  IGRdouble dot_pro;

  IGRlong k,l;
  IGRlong mess;

  IGRboolean done;

  *msg = MSSUCC;

  if( GRfindlast(msg,pg,&k,&l) )
    {
      MAsubvc(&mess,&pg->points[k * 3],&pg->points[l * 3],v1);

      py.points     = pg->points;
      py.num_points = l + 1;

      done = FALSE;

      while( !done  && *msg == MSSUCC )
	   {
	     if( GRfindlast(msg,&py,&k,&l) )
	       {
		 MAsubvc(&mess,&py.points[k * 3],&py.points[l * 3],vc);

		 MAdotvc(&mess,v1,vc,&dot_pro);

		 if( MAabsolute(dot_pro) <= *tol )
		   {
		     done = TRUE;
		   }
		 else
		   {
		     py.num_points = l + 1;
		   }
	       }
	   }
    }

  return( *msg == MSSUCC );

}/* This has been an R.D.H. production!!! */
