/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME GRhvls2pt
 
     Abstract: This is the router called by command objects for
	      constructing a line segment horizontal or vertical
	      in the view from two events.
-----
%SC%

     value = GRhvls2pt(msg,events,num_events,hv_flag,ls)

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     events       GRevents	 array of pointers to events
     num_events	  IGRshort	 number of events
     hv_flag	  IGRboolean	 flag for horizontal - 1 or
     				 	  vertical - 0	 
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

static IGRboolean GRhvls __((IGRlong *msg, struct GRrtevent *events, 
                             IGRshort *num_events, 
                             struct IGRbsp_curve *out_geom));

#if defined(__cplusplus)
}
#endif
#undef __


IGRboolean GRhvls2pt(msg,events,num_events,hv_flag,ls)

	   IGRlong             *msg;		/* return code		     */
	   struct GRevent      *events[];	/* events		     */
	   IGRshort            *num_events;	/* number of events	     */
	   IGRboolean	       *hv_flag;	/* horizontal/vertical (1/0) */
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

	if( *hv_flag )
	{
	  ls->order = 1;
	}
	else
	{
	  ls->order = 0;
	}
	  
	GRccschoice(msg,&level,rtevents,num_events,&view,&ccw,GRhvls,ls);
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

static IGRboolean GRhvls(msg,events,num_events,out_geom)

       IGRlong		   *msg;	/* return code			*/
       struct GRrtevent    *events;	/* array of events		*/
       IGRshort		   *num_events; /* number of events		*/
       struct IGRbsp_curve *out_geom;	/* output line			*/
       
{
  struct IGRbsp_curve hv_ln;
  struct IGRline line,ext_line;
    
  IGRmatrix view_rot;				/* view rotation matrix      */

  IGRpoint pt1,pt3,pt4;
  IGRpoint prjpt1,prjpt2;
  IGRpoint diag1,diag2;

  IGRdouble *p,*p1;      
  IGRdouble poles[6];
  IGRdouble knots[4];
  IGRdouble u;
  IGRdouble tol;

  IGRlong mess;  
  IGRlong which_error;				/* error flag 	  	     */
  IGRlong bytes_ret;				/* number of bytes returned  */


  IGRboolean hv_flag;

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


  if( out_geom->order == 1 )
  {
    hv_flag = TRUE;
  }
  else
  {
    hv_flag = FALSE;
  }
  
/*  if( GRwnparam(msg,&set0_inq1,&events[0].viewid,&which_error,VIEW_ROTATION,
  		view_rot,sizeof(IGRdouble)*16,&bytes_ret,END_PARAM) )
*/

  
  status = dp$inq_set_gragad( msg = msg,
                              osnum = events[0].viewid.osnum,
                              gragad_objid = events[0].viewid.objid,
                              which_error = &which_error,
                              var_list = list );


  if( status & 1)

  {
    if( events[0].subtype == GRREG  &&  events[1].subtype == GRREG )
    {
      p = events[0].pt;
      p1 = events[1].pt;
    }
    else
    {
      if( events[0].subtype == GRREG )
      {
        p = events[1].pt;
        p1 = events[0].pt;
      }
      else
      {
	p = events[0].pt;
	p1 = events[1].pt;
      }      	
    }
    
    if( hv_flag )
    {
      pt1[0] = p[0] + view_rot[0];
      pt1[1] = p[1] + view_rot[1];
      pt1[2] = p[2] + view_rot[2];
    }
    else
    {
      pt1[0] = p[0] + view_rot[4];
      pt1[1] = p[1] + view_rot[5];
      pt1[2] = p[2] + view_rot[6];
    }
    
    line.point1 = p;
    line.point2 = pt1;
    
    if( MAptlnproj(msg,p1,&line,prjpt1,&u) )
    {
      if( events[0].subtype != GRREG  ||  events[1].subtype != GRREG )
      {
        hv_ln.poles = poles;
        hv_ln.knots = knots;

        if( hv_flag )
        {
          pt1[0] = p1[0] + view_rot[4];
          pt1[1] = p1[1] + view_rot[5];
          pt1[2] = p1[2] + view_rot[6];
        }
        else
        {
          pt1[0] = p1[0] + view_rot[0];
          pt1[1] = p1[1] + view_rot[1];
          pt1[2] = p1[2] + view_rot[2];
        }
    
        line.point1 = p1;
        line.point2 = pt1;
    
        ext_line.point1 = pt3;
        ext_line.point2 = pt4;   

        diag1[0] = GRDGNLIMITS_MIN_D;
        diag1[1] = GRDGNLIMITS_MIN_D;
        diag1[2] = GRDGNLIMITS_MIN_D;
    
        diag2[0] = GRDGNLIMITS_MAX_D; 
        diag2[1] = GRDGNLIMITS_MAX_D; 
        diag2[2] = GRDGNLIMITS_MAX_D;
    
        if( MAlncbclip(&mess,&line,diag1,diag2,&ext_line) )
        {
          MAlstobc(&mess,&ext_line,&hv_ln);
      
          tol = 0.01;
          MAptbcproj(&mess,prjpt1,&hv_ln,&tol,prjpt2,&u);
        }

        if( 1 & mess & *msg )
        {
          if( events[0].subtype == GRREG )
          {
      	    events[0].geoms[0] = (char *)&hv_ln;
      	    events[0].subtype = GRPT;
      	    events[0].props[0].type = GRCURVE;
      	    events[0].props[0].subtype = GRLN;
      	    events[0].objs[0].parms.u = u;
      	    events[0].pt[0] = prjpt2[0];
      	    events[0].pt[1] = prjpt2[1];
      	    events[0].pt[2] = prjpt2[2];
          }
          else
          {
            events[1].geoms[0] = (char *)&hv_ln;
      	    events[1].subtype = GRPT;
      	    events[1].props[0].type = GRCURVE;
      	    events[1].props[0].subtype = GRLN;
      	    events[1].objs[0].parms.u = u;
      	    events[1].pt[0] = prjpt2[0];
      	    events[1].pt[1] = prjpt2[1];
      	    events[1].pt[2] = prjpt2[2];
          }
        
          GRls2pt_rtr(msg,events,num_events,out_geom);
        }
      }
      else
      {
        MA2pttobc(msg,p,prjpt1,out_geom);
      }
    }  
  }

  
  return( 1 & *msg );
  
}/* This has been an R.D.H. production!!! */
      


