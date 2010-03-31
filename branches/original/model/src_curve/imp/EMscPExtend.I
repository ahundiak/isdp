/* ###################   APOGEE COMPILED   ################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: GRsubbc
     METHOD NAME: GRptextend

     Abstract: This routine extends one endpoint of a B-spline curve
	       to an approximate point using the first or last polynomial
               Bspline segment. 

-----
%SC%    

	GRptextend(msg,env,endpoint,ext_pt,newend);

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     env	  GRmd_env	 environment information
     endpoint	  IGRpoint	 endpoint to extend
     ext_pt	  IGRpoint	 approximate point to extend to

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     msg	  IGRlong	 return code:
					MSSUCC - successful
					MSFAIL - severe error
					MSINARG - object is not open
					BSINARG - if extension point
						  is not in the right
						  direction
					GRSNOINVTRAN - if input matrix
						  is not invertible
					GRSDGNEXCEED - if the design
						  file limits are exceeded

     newend	  IGRpoint	 new end point
                                 is a dummy argument and is not
                                 returned
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:
	     BSpolyxttpt - is the math routine which accepts data 
                           defining a B-spline curve, a point on
                           the curve close to the end of extension, and
                           an extension point. It returns the 
                           curve extended to the extension point by
                           using the extension of the first or last
                           polynomial segment.
             BSalloccv   - allocates the necessary memory for a Bspline
                           curve structure when the no of boundaries,
                           max no of poles and order is known and is 
                           supplied as input to the routine.
             BSfreecv    - frees the memory associated with the curve
                           structure
             BScv_endpt  - returns the endpoint closest to the proximity 
                           point
     Methods:
	     GRgenabsg
	     GRpostabsg
             GRabsg_del
-----
%RL%

     RELATIONS REFERENCED:
			  
-----
%NB%

     NOTES:
-----
%CH%

     CHANGE HISTORY:
	
    pp     09/24/86  Design date
    dhm    02/22/88  Added GR_NOTIFY_LISTENERS
    pp     07/28/88  Fixed a bug pointed out by doree wherin I
                     was resetting the message field at the end.
    rlw    10/11/88  Prasad did not initialize the ec pointer such that
                     if the input curve was physically closed he was
                     freeing garbage memory.
    Sudha  06/16/93     Modified for BSprototype ansification

-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
 This method gets the abstract geometry of the object and checks to
see if the curve is open.  If both of these parameters
are correct, the distances from endpoint to the first and last poles
is computed and the pole which is closest to endpoint identifies 
which end of the curve to extend. The correct segment of the curve
is then used as a line for ext_pt to be projected onto. The project
point becomes the new endpoint and the objects new abstract geometry
is then posted.

----*/
/*EH*/

class implementation GRsubbc;  

#include "EMS.h"
#include "OMminimum.h"     /* for gocmacros.h  */
#include "igrtypedef.h"     /* for gocmacros.h  */
#include "godef.h"
#include "gocmacros.h"     /* GRgetabsg macro  */
#include "msdef.h" /* MS message codes */
#include "igrdef.h"
#include "madef.h"
#include "bserr.h"
#include "emsmacros.h"
#include "bspolyxttpt.h"
#include "bsfreecv.h"
#include "bscv_endpt.h"
#include "bsalloccv.h"

#ifndef FALSE
#define FALSE 0
#endif
#ifndef TRUE
#define TRUE 1
#endif

method GRptextend(IGRlong *msg; struct GRmd_env *env; IGRpoint endpoint,
		  ext_pt,newend)
{
  struct 	IGRbsp_curve *bc;	/* abstract geometry pointer of the
                 	                   original curve */
  struct 	IGRbsp_curve *ec;       /* abstract geomery pointer of the 
                                           extended curve */
  struct 	GRpost_info info;       /* contains information for posting */
 
  IGRchar 	*ptr;			/* abstract geometry pointer */

  GRobjid 	newid;			/* new object id	     */

  IGRlong 	i;			/* indexes		     */
  IGRlong       max_poles ;
  IGRlong 	OMmsg, sts;			/* OM return code	     */
  IGRshort	max_boundaries;		/* max number of boundaries */
  IGRshort	order ;

  IGRboolean	rational;
  extern   IGRboolean 	BSpolyxttpt (); 		/* function declarations     */


  *msg = MSSUCC;
  OMmsg = OM_S_SUCCESS;
  ec = NULL;			/* rlw : 10/11/88 */

					/* get abstract geometry     */
  GRgetabsg(msg,&env->md_env.matrix_type,env->md_env.matrix,&ptr,i);

  if( *msg & 1 )
    {
      bc = (struct IGRbsp_curve *)ptr;

      if( !bc->phy_closed  ) /* valid curve to extend?    */
	{
          if ( bc->rational )
           {
             max_poles = bc->num_poles + 6 * (2 * bc->order -1);
             max_boundaries = bc->num_boundaries;
             rational = TRUE;
           }
          else
           {
             max_poles = bc->num_poles + 3 * (2 * bc->order -1);
             max_boundaries = bc->num_boundaries;
             rational = FALSE ;
           }

       order = bc->order ;
       (void) BSalloccv (order, max_poles, rational, max_boundaries, &ec, msg);

       if ( *msg == BSSUCC)
        {
          sts = BSpolyxttpt (msg, bc, endpoint, ext_pt, ec);
          EMerr_hndlr(!sts, *msg, MSFAIL, wrap_up);
          if ( *msg == BSSUCC)
           {
              sts = BScv_endpt(msg, ec, ext_pt, newend);
              EMerr_hndlr(!sts, *msg, MSFAIL, wrap_up);
              info.construct_flag = FALSE ;
              OMmsg = om$send(mode = OM_e_wrt_object,
                              msg = message GRvg.GRpostabsg (msg, env, &info, (IGRchar *)ec,
                                               &newid),
                              senderid = my_id,
                              targetid = my_id);
              EMomerr_hndlr(OMmsg,wrap_up,
                            "GRbspline.GRptextend - GRvg.GRpostabsg")

              if ( *msg == MSSUCC ) 
                {
                  GRabsg_del ( ptr );
                }
              else
                {
                  OMmsg = OM_E_ABORT;
                }
           }
          else
           {
            OMmsg = OM_E_ABORT;
            *msg = MSINARG;
           }
         }
         else
          {
           OMmsg = OM_E_ABORT;
           EMomerr_hndlr(OMmsg,wrap_up,
                         "GRbspline.GRptextend- No stack memory")
          }
       } /* end if part of (bc->phy_closed) */

       else /* begin else part of if (bc->phy_closed)  */
        {
          *msg = MSINARG; 	/* invalid input */
          OMmsg = OM_E_ABORT ;
        } /* end else part of (bc->phy_closed) */

      } /* end if part of (msg & 1) */
     else /* begin else part of (msg & 1) */
       {
         OMmsg = OM_E_ABORT ;   /* failed to get input */
       }  /* end else part of (msg & 1) */

 wrap_up:
   if (ec)
    {
     BSrc rc;

      BSfreecv (&rc, ec);
      if (BSERROR(rc))
      {
        *msg = MSFAIL;
      }
    }
  GR_NOTIFY_LISTENERS(msg, &OMmsg, GR_GEOM_MODIFIED);
  return( OMmsg );

}

end implementation GRsubbc;   
