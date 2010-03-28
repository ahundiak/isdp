/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: GRvg
     METHOD NAME: GRccschoice

     Abstract: This routine drives the routers for the command objects
	      processing any extened/composite curves and surfaces.

-----
%SC%    

     GRccschoice(msg,level,events,num_events,view,ccw,router,geom)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     level	  IGRshort	 number of levels permitted for each
				 extended or composite curve/surface
				 to try and find a solution on.
     events	  GRrtevents     array of router events
     num_events   IGRshort	 the number of events
     view	  IGRboolean	 flag to get view vector
     ccw	  IGRshort	 flag for arc view orientation
				 1->counter-clockwise, 0->clockwise
     router	  IGRboolean     specific router function to be called
     
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     msg	  IGRlong	 return code:
					MSSUCC - successful
					MSFAIL - an error occurred
                                        MANOTCOMPLETE - view
                                 information in event one is not
                                 valid     
     geom	  IGRbsp_curve	 output geometry from router
     
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:
		     MAutoparms
		     BSxtlntcvbx
		     
	      ONE OF:
		     GRar2ptrad_router
		     GRar3pt_router
		     GRarcnptang_router
		     GRcr3pt_router
		     GRcrcnrad_router
		     GRcrdiam_router
		     GReaaxaxpt_router
		     GReaaxptax_router
		     GRelaxaxpt_router
		     GRelcnaxpt_router



     Methods:
		     GRgeomprops
		     GRgetexsize
		     GRgetexgeom	     
-----
%RL%

     RELATIONS REFERENCED:
			  
-----
%NB%

     NOTES:
	   The ccw flag is used as follows:
	
		1 - return arc oriented counter-clockwise in the view
		0 - return arc oriented clockwise in the view
-----
%CH%

     CHANGE HISTORY:

	RDH  02/04/86  : Creation date.
	
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
 This routine first checks to see if the view vector is needed and
if so gets it using the first events view information. If the ccw
flag is 1, the view vector from the view rotation matrix is 
used. If the ccw flag is 0, the negation of the view vector from
the view rotation matrix is used.
 Nextthe  routine checks the incoming events for extended and composite
curves and surfaces. If any are found, the sub curve or surface
identified by the tentative point in the event is used to try and 
find the desired geometry. If this fails, the routine keeps trying
to find sub curves or surfaces to the level indicated by the input;

 The only type of input which has objects associated with it is the
input point.

----*/
/*EH*/

class implementation GRvg;

#include "grimport.h"
#include "OMminimum.h"
#include "godef.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "grrouterpriv.h"
#include "msdef.h"
#include "bserr.h"

extern    IGRboolean    MAutoparms();
extern    IGRboolean    MAlstobc();
extern    void          BSxtlntcvbx();

IGRboolean GRccschoice(msg,level,events,num_events,view,ccw,router,geom)


	   IGRlong             *msg;		/* return code		     */
	   IGRshort  	       *level;		/* max "levels" to search for*/
						/* solution on		     */
	   struct GRrtevent    *events;		/* the router events	     */
	   IGRshort	       *num_events;	/* number of events	     */
	   IGRboolean	       *view;		/* flag to get view vector   */
	   IGRshort	       *ccw;		/* flag for arc orientation  */
	   IGRboolean    (*router)();
	   struct IGRbsp_curve *geom;		/* output geometry	     */

{
  struct IGRbsp_curve *bc;			/* ptr to a B-spline curve   */
  struct IGRline line;				/* line for extensions       */
  struct IGRbsp_curve *curves[100];             /* ptrs for BSxtlntcvbx      */
  struct IGRbsp_curve pts_cv;                   /* for GRREG points          */
  struct IGRpolyline py;                        /* range of GRREG points     */
  struct IGRbsp_surface *bs;
  struct IGRbsp_curve tmp_cv1,tmp_cv2;
        
  IGRmatrix view_rot;				/* view rotation matrix      */

  IGRpoint pjpt;				/* project point   	     */
  
  IGRdouble t;					/* t parameter		     */
  IGRdouble tol;				/* project tolerance	     */
  IGRdouble pts_poles[6];                       /* poles for pts_cv          */
  IGRdouble pts_knots[4];                       /* knots for pts_cv          */
  IGRdouble points[303];                        /* for py                    */
    
  IGRlong i,j;					/* indexes		     */
  IGRlong mess;					/* return code		     */
  IGRlong ext_size;				/* size of extended geometry */
  IGRlong which_error;				/* error flag 	  	     */
  IGRlong bytes_ret;				/* number of bytes returned  */
  IGRlong segnum;                               /* segment number            */
  IGRlong num_curves = 0;                       /* number of curves          */
  IGRlong count = 0;                            /* index for curve ptr array */
  IGRlong sf_count = 0;
  
  IGRint  bsrc;                                 /* return code for BS...     */
  
  
  *msg = MSSUCC;

  
  if( *view )					/* Do we need view info?    */
  {
    IGRlong  status;
    struct var_list list[2];

    list[0].var = VIEW_ROTATION;
    list[0].var_ptr = (char *)view_rot;
    list[0].num_bytes = sizeof(IGRdouble)*16;
    list[0].bytes_returned= &bytes_ret;
    list[1].var = END_PARAM;
    list[1].var_ptr = NULL;
    list[1].num_bytes = 0;
    list[1].bytes_returned = NULL;

    status = dp$inq_set_gragad( msg = msg,
                              osnum = events[0].viewid.osnum,
                              gragad_objid = events[0].viewid.objid,
                              which_error = &which_error,
                              var_list = list );


    if( status & 1)
    {
      if( *ccw )				/* get view vector for ccw   */
      {
        events[0].vc[0] = view_rot[8];
        events[0].vc[1] = view_rot[9];
        events[0].vc[2] = view_rot[10];
      }
      else					/* get -view vector for cw   */
      {
        events[0].vc[0] = -view_rot[8];
        events[0].vc[1] = -view_rot[9];
        events[0].vc[2] = -view_rot[10];
      }
    }
  }

  for( i=0; i < *num_events; ++i)		/* zero out all pointers     */
  {
    for( j=0; j < events[i].num_id; ++j)
    {
      events[i].geoms[j] = 0;   		/*zero pointer indicates that*/
    }				        	/* no storage to retrieve at */
  }						/* the end of this routine   */


  py.points = points;
  py.num_points = 0;
  
  for( i=0; i < *num_events  &&  *msg == MSSUCC; ++i)
  {
    if( events[i].type == GRD_POINT )   	/* is this a point?    	     */
    {
      if( events[i].subtype != GRREG ) 	        /* do we need objects?	     */
      {
				                /* process objects	     */

        for( j=0; j < events[i].num_id  &&  *msg == MSSUCC; ++j)
	{
	  om$send(msg = message GRvg.GRgeomprops(msg,&events[i].objs[j].mat_type,      events[i].objs[j].matrix,&events[i].props[j]),
                  senderid = NULL_OBJID,
                  targetid = events[i].objs[j].objid,
                  targetos = events[i].objs[j].osnum);

	  if( *msg == MSSUCC )
	  {
        	    				/* get geometry[j]'s size    */

	    om$send(msg = message GRvg.GRgetexsize(msg,&events[i].objs[j].mat_type,events[i].objs[j].matrix,&ext_size),
                    senderid = NULL_OBJID,
                    targetid = events[i].objs[j].objid,
                    targetos = events[i].objs[j].osnum);

            if (!(*msg & 1))
              goto wrapup;
	            				/* allocate stack storage    */

	    events[i].geoms[j] = om$malloc(size = ext_size);

            if (!events[i].geoms[j])
            {
              *msg = MSFAIL;
              goto wrapup;
            }
						/* get the geometry	     */

	    om$send(msg = message GRvg.GRgetexgeom(msg,&events[i].objs[j].mat_type,events[i].objs[j].matrix,events[i].geoms[j]),
                    senderid = NULL_OBJID,
                    targetid = events[i].objs[j].objid,
                    targetos = events[i].objs[j].osnum);

	    if( *msg & 1 )
	    {
	      if( events[i].props[j].type == GRCURVE )
	      {
	        bc = (struct IGRbsp_curve *)events[i].geoms[j];

                curves[num_curves] = bc;
                ++num_curves;
                            
	        if( events[i].props[j].subtype == GRLN )
                {
		  MAutoparms(msg,bc,&events[i].objs[j].parms.u,&segnum,&t);
                  if (!(*msg & 1))
                    goto wrapup;

                  MA2pttobc(&mess,&bc->poles[(segnum - 1) * 3],
                            &bc->poles[segnum * 3],events[i].geoms[j]);
                  if (!(mess & 1))
                    goto wrapup;
	        }
	        else
	        {
	          if( events[i].props[j].subtype == GRCN )
		  {
		    events[i].objs[j].parms.u = events[i].objs[j].parms.v;
	          }
	        }
	      }
#ifndef IDRAW	      
	      else
	      {
	        bs = (struct IGRbsp_surface *)events[i].geoms[j];
	        if( sf_count == 0 )
	        {
	          tmp_cv1.num_poles = bs->u_num_poles * bs->v_num_poles;
	          tmp_cv1.poles = bs->poles;
	          tmp_cv1.weights = bs->weights;
	          tmp_cv1.rational = bs->rational;
       
                  curves[num_curves] = &tmp_cv1;
                  
                  ++sf_count;
                }
                else
                {
	          tmp_cv2.num_poles = bs->u_num_poles * bs->v_num_poles;
	          tmp_cv2.poles = bs->poles;
	          tmp_cv2.weights = bs->weights;
	          tmp_cv2.rational = bs->rational;
       
                  curves[num_curves] = &tmp_cv2;
                }

                ++num_curves;
              }
#endif
	    }
	  }
	}
      }
      else
      {
        if( py.num_points )
        {
          points[6] = events[i].pt[0];
          points[7] = events[i].pt[1];
          points[8] = events[i].pt[2];
                 
          py.num_points = 3;
               
          MApyextents(msg,&py,points,&points[3]);
          if (!(*msg & 1))
            goto wrapup;

          py.num_points = 2;
        }
        else
        {
          points[0] = events[i].pt[0];
          points[1] = events[i].pt[1];
          points[2] = events[i].pt[2];

	  points[3] = events[i].pt[0];
	  points[4] = events[i].pt[1];
	  points[5] = events[i].pt[2];
	  
	  py.num_points = 2;
        }
      }
    }
  }
  
  if( *msg == MSSUCC  &&  num_curves > 0 )
  {
    if( py.num_points )
    {
      pts_cv.poles = pts_poles;
      pts_cv.knots = pts_knots;
      
      MA2pttobc(msg,points,&points[3],&pts_cv);
      if (!(*msg & 1))
        goto wrapup;
      
      curves[num_curves] = &pts_cv;
      
      num_curves++;
    }
        
    for( i=0; (i < *num_events  &&  (1 & *msg)); ++i)
    {
      if( events[i].type == GRD_POINT && events[i].subtype != GRREG )
      {
        for( j=0; (j < events[i].num_id  &&  (1 & *msg)); ++j)
        {
          if( events[i].props[j].subtype == GRLN )
          {
            line.point1 = curves[count]->poles;
            line.point2 = &curves[count]->poles[3];
          
            BSxtlntcvbx(&line,num_curves,curves,curves[count],&bsrc);
          
            if( bsrc == BSSUCC )
            {
              tol = 0.01;
            
              MAptbcproj(msg,events[i].pt,curves[count],&tol,pjpt,
                         &events[i].objs[j].parms.u);
              if (!(*msg & 1))
                goto wrapup;
            }
            else
            {
              *msg = MSFAIL;
            }
          }
 
          ++count;
        }
      }
    }
  }

  if( *msg == MSSUCC )
  {
    (*router)(msg,events,num_events,geom);
  }
  
wrapup:	  
  for( i = *num_events - 1; i >= 0; --i)	/* deallocate all storage    */
  {						/* allocated by this routine */
    for( j = events[i].num_id - 1; j >= 0; --j)
    {
      if (events[i].geoms[j] ); 
        om$dealloc(ptr =  events[i].geoms[j] ); 
    }
  }

  return( *msg == MSSUCC );
               
}/* This has been an R.D.H. production!!! */

end implementation GRvg;
