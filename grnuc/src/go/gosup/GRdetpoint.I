/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME GRdetpoint
 
     Abstract: This routine takes a line and an object which is
	       linear and planar and finds a the point of 
	       intersection of the line and plane. In addition,
	       if the ortho flag is set, the intersection point
	       is modified such that the last point of the object
	       and the "intersection point" form a line segment
	       orthogonal to the last non_zero length segment
	       of the object.
-----
%SC%

     VALUE = GRdetpoint(msg,objid,mat_type,matrix,line,ortho,point)

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     objid	  GRid		 object id and space number
     mat_type	  IGRshort	 matrix type
     matrix	  IGRmatrix	 module environment matrix
     line	  IGRline	 line to define point
     ortho	  IGRboolean	 flag to force orthogonality
     
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     msg	  IGRlong	 return code:
					MSSUCC - successful
					MSFAIL - failure

     point	  IGRpoint	 point in plane of the element (and
				 possibly orthogonal to last segment)
     
     VALUE (IGRlong ) = OM return code

-----
%MD%

     MODULES INVOKED:
		      GRdetplane
		      MA2pt2dis
		      GRorthoseg
-----
%NB%

     NOTES:
            
-----

%CH%
     CHANGE HISTORY:
	
	RDH  11/12/87  : Creation date.
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------
 This routine determines the plane of the object and then finds the
intersection point of the line and plane. If the ortho flag is set
the routine then finds the last non-zero length segment of the 
object and calls GRorthoseg to adjust the intersection point so as to
maintain orthogonality of the last segment and the segment made up
of the last point of the object and the intersection point.

----*/
/*EH*/

class implementation GRvg;

#include "grimport.h"
#include "igrtypedef.h"
#include "igr.h"
#include "msdef.h"

#define BUFF_SIZE 1600

IGRlong GRdetpoint(msg,objid,mat_type,matrix,line,ortho,point)

	IGRlong		*msg;		/* return code			*/
	struct GRid  	*objid;		/* object id and space number	*/
	IGRshort	*mat_type;	/* matrix type			*/
	IGRdouble	*matrix;	/* environment matrix		*/
	struct IGRline 	*line;		/* line to define point		*/
	IGRboolean	*ortho;		/* orthogonality flag		*/
	IGRpoint	 point;		/* determined point		*/

{
  struct IGRbsp_curve *bc;		/* B-spline curve pointer	*/
  struct IGRplane pl;			/* plane of object		*/

  IGRpoint	pl_pt;			/* point for pl			*/

  IGRvector	normal;			/* normal vector for pl		*/

  IGRdouble	bc_buff[200];		/* default curve buffer		*/
  IGRdouble	t;			/* t parameter of ipt		*/
  IGRdouble	tol;			/* tolerance for intersection	*/
  IGRdouble 	dist;			/* distance squared		*/
  
  IGRlong	i;
  IGRlong	size;
  IGRlong	OMmsg;			/* OM return code		*/



  *msg = MSSUCC;
  OMmsg = OM_S_SUCCESS;

  
  pl.point = pl_pt;
  pl.normal = normal;

  OMmsg = om$send(msg = message GRvg.GRdetplane(msg,mat_type,matrix,&pl),
		  senderid = NULL_OBJID,
		  targetid = objid->objid,
		  targetos = objid->osnum);

  if( 1 & OMmsg & *msg )
  {
    tol = 0.0000000000001;

    MAlnplisect(msg,line,&pl,&tol,point,&t);    

    if( *msg != MANOSOLUTION )
    {
      if( *ortho )
      {
	OMmsg = om$send(msg = message GRvg.GRgetsize(msg,mat_type,matrix,&size),
			senderid = NULL_OBJID,
			targetid = objid->objid,
			targetos = objid->osnum);

	if( 1 & OMmsg & *msg )
	{
	  bc = 0;

	  if( size < BUFF_SIZE )
	  {
	    bc = (struct IGRbsp_curve *)bc_buff;
	  }
	  else
	  {
	    bc = (struct IGRbsp_curve *) malloc(size);
	  }

	  if( bc )
	  {
	    OMmsg = om$send(msg = message GRvg.GRgetgeom(msg,mat_type,matrix,
							 (char *)bc),
			    senderid = NULL_OBJID,
			    targetid = objid->objid,
			    targetos = objid->osnum);

	    if( 1 & OMmsg & *msg )
	    {
	      if( bc->order == 2 )
	      {
	        dist = 0.0;

	        for(i = bc->num_poles -1; (i > 0 && dist == 0.0); --i)
		{
		  MA2pt2dis(msg,&bc->poles[i*3],&bc->poles[(i-1)*3],&dist);
		}

		if( dist > 0.0 )
		{
		  GRorthoseg(msg,&bc->poles[(i+1)*3],&bc->poles[i*3],point,
			     point);
		}
	      }
	    }

	    if( bc && bc != (struct IGRbsp_curve *)bc_buff )
	    {
	      free( bc );
	    }
	  }
	}
      }
    }
  }

  return( OMmsg );

}/* This has been an R.D.H. production!!! */

end implementation GRvg;
