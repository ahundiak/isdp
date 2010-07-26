/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME GRaals2pt
 
     Abstract: This is the router called by command objects for
	      constructing a line segment at active angle
	      in the view from two events.
-----
%SC%

     value = GRaals2pt(msg,events,num_events,angle,ls)

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     events       GRevents	 array of pointers to events
     num_events	  IGRshort	 number of events
     angle	  IGRdouble	 angle (in radians)
     
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     msg	  IGRlong	 return code:
					MSSUCC - successful
					MSFAIL - an error occurred
					MSINARG - invalid event type

     ls		  IGRbsp_curve	 output line segment
     
     VALUE (boolean) = {TRUE,FALSE}
                        TRUE - line segment found
                        FALSE- no line segment found

-----
%MD%

     MODULES INVOKED:
	     	     GRccschoice
		     GRprerout
-----
%NB%

     NOTES:
	    The storage for the line segment must already be allocated.
	   Allow for 2 poles and 4  knots.
-----

%CH%
     CHANGE HISTORY:
	
	RDH    02/08/87 : Design date.
        MEF    09/05/89 : Altered GRaals to clip line at active angle using
                            a different BSpline routine.  Fix for v1.3.0. 
        scw    06/23/92 : Added static ANSI C prototypes
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------
This routine calls GRprerout to preprocess the events and then
calls GRccschoice to interface with the indicated objects.

----*/
/*EH*/

#include "grimport.h"
#include "igrtypedef.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "madef.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "msdef.h"
#include "grrouterpriv.h"
#include "ex.h"
#include "grio.h"
#include "grerr.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"

extern    IGRboolean    GRprerout();
extern    IGRboolean    GRccschoice();

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

static IGRboolean GRaals __((IGRlong *msg, struct GRrtevent *events, 
                             IGRshort *num_events, 
                             struct IGRbsp_curve *out_geom));

#if defined(__cplusplus)
}
#endif
#undef __



IGRboolean GRaals2pt(msg,events,num_events,angle,ls)

	   IGRlong             *msg;		/* return code		     */
	   struct GRevent      *events[];	/* events		     */
	   IGRshort            *num_events;	/* number of events	     */
	   IGRdouble	       *angle;		/* angle		     */
	   struct IGRbsp_curve *ls;		/* line segment		     */

{
  struct GRrtevent rtevents[GRMAX_LS_EVENTS];	/* router data structure     */

  IGRshort max_id,max_val;			/* max number of objects and */
						/* values per line seg event */
  IGRshort level;				/* Number of levels we are   */
						/*willing to search for a sol*/
 						/*ution on extended/composite*/
  IGRshort ccw;					/* arc orientation flag	     */

  IGRboolean view;				/* view information flag     */

  *msg = MSSUCC;

  max_id =  1;					/* max number of ids for ls  */
  max_val = 1;					/* max number of vals for ls */

  if( *num_events <= GRMAX_LS_EVENTS )		/* valid number of events?   */
  {
    if( GRprerout(msg,events,num_events,&max_id,&max_val,rtevents) )
    {
      if( rtevents[0].subtype == GRREG  ||  rtevents[1].subtype == GRREG )
      {
	level = 2;
	view = TRUE;
	ccw = 1;

	if( rtevents[0].subtype == GRREG )
	{
	  rtevents[0].val[0] = *angle;
	}
	else
	{
	  rtevents[1].val[0] = *angle;
	}
		  
	GRccschoice(msg,&level,rtevents,num_events,&view,&ccw,GRaals,ls);
      }
      else
      {
      	*msg = GRILLDEFINITION;
      }
    }
  } 
  else
  {
    *msg = MSINARG;
  }

  return( *msg == MSSUCC );

}

static IGRboolean GRaals(msg,events,num_events,out_geom)

       IGRlong		   *msg;	/* return code			*/
       struct GRrtevent    *events;	/* array of events		*/
       IGRshort		   *num_events; /* number of events		*/
       struct IGRbsp_curve *out_geom;	/* output line			*/
       
{
  struct IGRbsp_curve aa_ln;
  struct IGRbsp_curve *curves[2];
  struct IGRline line;

    
  IGRmatrix view_rot;				/* view rotation matrix      */
  IGRmatrix inv_rot;				/* inverse view rotation     */

  IGRvector dir_vc;
    
  IGRpoint pt0,pt1;
  IGRpoint prjpt1;

  IGRdouble *p;      
  IGRdouble length;
  IGRdouble poles[6];
  IGRdouble knots[4];
  IGRdouble angle;
  IGRdouble u;
  IGRdouble tol;

  IGRlong mess;  
  IGRlong which_error;				/* error flag 	  	     */
  IGRlong bytes_ret;				/* number of bytes returned  */
  IGRlong num_curves;                           /* number of curves used */

  IGRshort dim;
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

  /*
  if( GRwnparam(msg,&set0_inq1,&events[0].viewid,&which_error,VIEW_ROTATION,
  		view_rot,sizeof(IGRdouble)*16,&bytes_ret,END_PARAM) )
 */

  status = dp$inq_set_gragad( msg = msg,
                              osnum = events[0].viewid.osnum,
                              gragad_objid = events[0].viewid.objid,
                              which_error = &which_error,
                              var_list = list );


  if( status & 1)
  {
    if( events[0].subtype == GRREG )
    {
      angle = events[0].val[0];
    }
    else
    {
      angle = events[1].val[0];
    }
    
    pt0[0] = events[0].pt[0];    
    pt0[1] = events[0].pt[1];    
    pt0[2] = events[0].pt[2];    

    pt1[0] = pt0[0] + view_rot[0];
    pt1[1] = pt0[1] + view_rot[1];
    pt1[2] = pt0[2] + view_rot[2];
    
    line.point1 = pt0;
    line.point2 = pt1;

    dim = 4;
    MAtrnmx(msg,&dim,view_rot,inv_rot);

    MAlalnfpt(msg,&line,pt0,events[1].pt,&angle,inv_rot,out_geom);

    if( events[0].subtype != GRREG  ||  events[1].subtype != GRREG  &&  1 & *msg )
    {
      aa_ln.poles = poles;
      aa_ln.knots = knots;

      MAsubvc(msg,&out_geom->poles[3],&out_geom->poles[0],dir_vc);
      
      if( events[0].subtype != GRREG )
      {
        pt0[0] = events[0].pt[0];    
        pt0[1] = events[0].pt[1];    
        pt0[2] = events[0].pt[2];

	p = events[1].pt;
      }
      else
      {
        pt0[0] = events[1].pt[0];
        pt0[1] = events[1].pt[1];
        pt0[2] = events[1].pt[2];

        p = events[0].pt;
      }

      MAaddvc(msg,pt0,dir_vc,pt1);
      
      MAptlnproj(msg,p,&line,prjpt1,&u);
      
      if( events[0].subtype == GRREG )
      {
        pt0[0] = events[0].pt[0];    
        pt0[1] = events[0].pt[1];    
        pt0[2] = events[0].pt[2];    
        curves[0] = (struct IGRbsp_curve *)events[1].geoms[0];
      }
      else
      {
        pt0[0] = events[1].pt[0];
        pt0[1] = events[1].pt[1];
        pt0[2] = events[1].pt[2];
        curves[0] = (struct IGRbsp_curve *)events[0].geoms[0];
      }

      pt1[0] = pt0[0] + view_rot[0];
      pt1[1] = pt0[1] + view_rot[1];
      pt1[2] = pt0[2] + view_rot[2];

      angle += PI/2.0;

      length = 100.0;
                
      MAlalnlfpt(msg, &line, pt0, &angle, &length, inv_rot, &aa_ln);

      line.point1 = &aa_ln.poles[0];
      line.point2 = &aa_ln.poles[3];
      
      curves[1] = &aa_ln;
      num_curves = 2;
        
      BSxtlntcvbx(&line, num_curves, curves, &aa_ln, &mess);
               
      tol = 0.01;
      MAptbcproj(&mess,prjpt1,&aa_ln,&tol,p,&u);
      

      if( 1 & mess & *msg )
      {
        if( events[0].subtype == GRREG )
        {
      	  events[0].geoms[0] = (char *)&aa_ln;
      	  events[0].subtype = GRPT;
      	  events[0].props[0].type = GRCURVE;
      	  events[0].props[0].subtype = GRLN;
      	  events[0].objs[0].parms.u = u;
        }
        else
        {
          events[1].geoms[0] = (char *)&aa_ln;
      	  events[1].subtype = GRPT;
      	  events[1].props[0].type = GRCURVE;
      	  events[1].props[0].subtype = GRLN;
      	  events[1].objs[0].parms.u = u;
        }
        
        GRls2pt_rtr(msg,events,num_events,out_geom);
      }
      else
      {
      	if( !( 1 & mess ) )
      	{
      	  *msg = MSFAIL;
      	}
      }
    }  
  }
  
  return( 1 & *msg );
  
}/* This has been an R.D.H. production!!! */
      


