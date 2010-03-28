/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME	GRorthaddpts
 
     Abstract:

		This function adds a set of points to the end of 
	an orthogonal (planar) line string
	
-----
%SC%

     VALUE = GRorthaddpts(msg,env,osnum,objid,num,points,option,
			  vector,new_objid)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *env	  GRmd_env	 structure defining the transformation
				 and other info about the object
     *osnum	  GRspacenum	 space number of graphics object
     *objid	  GRobjid	 object id of graphics object
     *num	  IGRshort	 number of points to add
     *points	  IGRdouble	 array of 3-D points to add
     *option	  IGRshort	 (not used at this time)
     vector	  IGRvector	 vector defining projection 
				 direction (may be degenerate)
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg	  IGRlong	 completion code
				  - MSSUCC if successful
				  - GRSNOINVTRAN (severe) if input 
				    matrix is not invertible
				  - GRSDGNEXCEED (severe) if range
				    exceeds design limits
				  - MSFAIL (severe) if other error
				    (possibly no memory)

     *new_objid	 GRobjid	 used if object changes classes,
				 otherwise is same as original id

     VALUE (IGRboolean) = TRUE	  - if successful
			= FALSE   - if an error occurred

-----
%MD%

     MODULES AND METHODS INVOKED:
     Modules:
		MAdetplane
		MAaddvc
		MAlnplproj
		MA2pt2dis
		GRorthoseg

     Methods:
		GRgenabsg
		GRputpolyline

-----
%NB%

     NOTES:	None.
-----
%CH%
     CHANGE HISTORY:
	
	RDH  04/13/88 : (re)creation date
	MEF  12/05/89 : Added support to prevent the creation of zero
			length segments.

-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------

	Looping thru the given points, as soon as the object defines
	a unique plane then project the remaining points onto that
	plane along the given vector and add these points.  Until a
	plane is found, merely add points.

----*/
/*EH*/

class implementation GRlinear;

#include "grimport.h"
#include "bserr.h"
#include "bsparameters.h"
#include "grerr.h"
#include "msdef.h"
#include "madef.h"

#define BUFSIZE 303

IGRlong GRorthaddpts(msg,env,osnum,objid,num,points,option,vector,new_objid)

IGRlong    *msg;			/* output - completion code	*/
struct     GRmd_env *env;		/* input - environment		*/
GRspacenum *osnum;			/* input - space number 	*/	
GRobjid    *objid;			/* input - object id		*/
IGRshort   *num;			/* input - number of pts to add	*/	
IGRdouble  *points;			/* input - points to add	*/
IGRshort   *option;			/* input - add option		*/
					/*	   0 for polygons	*/
					/* 	   1 for linestrings	*/
IGRvector  vector;			/* input - projection direction	*/
GRobjid	   *new_objid;			/* output - object id of new	*/
					/* 	    object		*/

{
  struct IGRbsp_curve *bc;		/* abstract geometry pointer	*/
  struct IGRpolyline py;		/* othopolyline			*/
  struct IGRplane pl;			/* plane of orthogonal string	*/
  struct IGRline ln;			/* line to intersect plane	*/
  struct GRpost_info post_info;		/* post geometry information	*/

  IGRvector n;				/* plane normal			*/

  IGRpoint pl_pt;			/* plane defining point		*/
  IGRpoint pt2;				/* point 2 of ln		*/
  IGRpoint ln_pt,proj_pt;		/* project points		*/

  IGRdouble pts_buf[BUFSIZE];		/* polyline pts default buffer	*/
  IGRdouble tol;			/* planarity tolerance		*/
  IGRdouble dist;			/* distance between points	*/
  IGRdouble t;				/* t parameter			*/

  IGRlong size;				/* size of buffer		*/
  IGRlong i,j;				/* indexs			*/
  IGRlong mess;				/* return code			*/
  IGRlong OMmsg;			/* OM return code		*/

  IGRboolean have_plane;		/* plane is defined flag	*/

  IGRshort pts_indx;			/* Index into checked points array */
  IGRshort num_sav;
  IGRlong msg2;				/* Local return message */
  IGRdouble chkd_points[60];		/* Points checked to insure 0 length */
					/*  segments are not create.         */
  IGRdouble *pts_ptr;			/* Pointer to points array */
  IGRdouble dist_sqtol;			/* tolerance */
  IGRboolean scan_points;
  IGRboolean status;

  *msg = MSSUCC;
  OMmsg = OM_S_SUCCESS;

  *new_objid = *objid;

  py.points = 0;
  bc = 0;

  pts_indx = 0;
  num_sav = *num;			/* Save the number of pts */

/*
 * Check to see if space needs to allocated.
 */
        if (*num == 1)             	/* There is only 1 pt */
          pts_ptr = points;
        else
          if (*num <= 20)         	/* There are 20 or less pts */
            pts_ptr = chkd_points;
        else                      	/* There are more than 20 pts */
        {
          pts_ptr = (double *)om$malloc( size = (sizeof(double) * *num *3));
          if (pts_ptr == 0)
          {
            *msg = MSFAIL;
            OMmsg = OM_E_ABORT;
            goto wrapup;
          }
        }

  if( ! GRabsg_test(msg,&env->md_env.matrix_type,env->md_env.matrix,
		    osnum,objid,&bc) )
  {
    OMmsg = om$send(msg = message GRvg.GRgenabsg(msg,&env->md_env.matrix_type,
						 env->md_env.matrix,(char **)&bc),
		    senderid = *objid,
		    targetid = *objid,
		    targetos = *osnum);
  }

  if( bc == 0 )
  {
    *msg = MSFAIL;
  }

  status = BSEXTRACTPAR(&msg2,BSTOLSQLENVEC,dist_sqtol);
  if (!status)
  {
    *msg = MSFAIL;
    OMmsg = OM_E_ABORT;
    goto wrapup;
  }

  if (*num > 1)             	/* Multiple pts were sent */
  {
    scan_points = FALSE;    	/* Wait until segment between last pole    */
                                /*  of curve and first point to add is not */
                                /*  of 0 length                            */
    for(i=3; i <= (*num * 3); i+=3)
    {
      if (scan_points)
      {
        MA2pt2dis(msg, points[i-6], &points[i-3], &dist);
        if (dist > dist_sqtol)
        {                       /* No segment of length 0 was found */
          pts_ptr[pts_indx]   = points[i-3];
          pts_ptr[pts_indx+1] = points[i-2];
          pts_ptr[pts_indx+2] = points[i-1];
          pts_indx+=3;
        }
      }
      else
      {                         /* Check against last pole in curve */
        MA2pt2dis(msg, &bc->poles[bc->num_poles*3-3],
                       &points[i-3], &dist);
        if (dist > dist_sqtol)
        {                       /* No segment of length 0 was found */
          pts_ptr[pts_indx]   = points[i-3];
          pts_ptr[pts_indx+1] = points[i-2];
          pts_ptr[pts_indx+2] = points[i-1];
          scan_points = TRUE;
          pts_indx+=3;
        }
      }
    }
    *num = pts_indx/3;        	/* The number of pts creating valid lengths*/
    if (*num == 0)          	/* All pts were duplicates */
    {
      *msg = GRILLDEFINITION;
      OMmsg = OM_E_ABORT;
      goto wrapup;
    }
  }
  else                      	/* One point was sent */
  {
    MA2pt2dis(msg, &bc->poles[bc->num_poles*3-3], pts_ptr, &dist);
    if (dist <= dist_sqtol)
    {                       	/* A segment of length 0 was found */
      *msg = GRILLDEFINITION;
      OMmsg = OM_E_ABORT;
      goto wrapup;
    }
  }


  if( 1 & OMmsg & *msg )
  {
    have_plane = FALSE;

    size = (bc->num_poles + *num + 2) * 3;

    if( size < BUFSIZE )			/* try to use default buffer*/
    {
      py.points = malloc( size * sizeof(IGRdouble) );
    }
    else
    {
      py.points = pts_buf;
    }

    py.num_points = bc->num_poles;		/* set up ortho polyline */

    for(i = 0; i < bc->num_poles * 3; ++i)
    {
      py.points[i] = bc->poles[i];
    }

    tol = 0.000001;				/* set planarity tol	*/

    pl.normal = n;
    pl.point = pl_pt;

    ln.point2 = pt2;

    for(i = 0; (i < *num) && (1 & *msg); ++i)
    {
      if( !have_plane )				/* get plane		*/
      {
	MAdetplane(&mess,py.points,&py.num_points,&tol,&pl);

	have_plane = ( mess != MASDGENRAT );
      }

      dist = 0.0;
						/* find last segment	*/
      for(j = py.num_points - 1; j > 0; --j)
      {
	MA2pt2dis(&mess,&py.points[j * 3],&py.points[(j - 1) * 3],&dist);

	if( dist != 0.0 )			/* segment		*/
	{
	  break;
	}
      }

      if( dist == 0.0 )				/* all segments zero so add */
      {
	py.points[py.num_points * 3]     = pts_ptr[3 *  i];
	py.points[py.num_points * 3 + 1] = pts_ptr[3 *  i + 1];
	py.points[py.num_points * 3 + 2] = pts_ptr[3 *  i + 1];

	py.num_points++;
      }
      else					/* put in plane and find*/
      {						/* orthogonal segment	*/
	if( have_plane )
	{					/* project into plane	*/
	  ln.point1 = &points[3 * i];

	  MAaddvc(&mess,ln.point1,vector,ln.point2);

	  MAlnplproj(&mess,&ln,&pl,ln_pt,proj_pt,&t);

	  if( ! (1 & mess) )
	  {
	    *msg = MSFAIL;
	  }
	}
	else					/* no plane for projection*/
	{
	  proj_pt[0] = pts_ptr[3 * i];
	  proj_pt[1] = pts_ptr[3 * i + 1];
	  proj_pt[2] = pts_ptr[3 * i + 2];
	}

	if( 1 & *msg )				/* get ortho point	*/
	{
	  GRorthoseg(msg,&py.points[(j - 1) * 3],&py.points[j * 3],proj_pt,
		     &py.points[py.num_points * 3]);
 
	  py.num_points++;
	}
      }						/* end dist == 0	*/
    }						/* end for i		*/

    if( 1 & *msg )
    {
      post_info.construct_flag = FALSE;

      OMmsg = om$send(msg = message GRlinear.GRputpolyline(msg,env,&post_info,
					     &py,new_objid),
		      senderid = NULL_OBJID,
		      targetid = *objid,
		      targetos = *osnum);
     }
  }

  GRabsg_del_all();				/*remove orig from cache*/
      
  if( py.points && py.points != pts_buf)
  {
    free( py.points );
  }

wrapup:
        *num = num_sav;        /* Restore the number of pts sent */
        if (*num > 20)         /* Dealloc space if more than 20 pts were sent */
          om$dealloc(ptr = pts_ptr);
  return(OMmsg);

}/* This has been an R.D.H. production!!! */

end implementation GRlinear;
