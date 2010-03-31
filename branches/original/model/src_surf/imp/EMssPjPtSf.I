/* ###################   APOGEE COMPILED   ################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD

     CLASS  NAME:  EMSsubbs  
     METHOD NAME:  EMpjptsf 

     Abstract: 
-----
%SC%    

     message EMSsubbs.EMpjptsf ( &msg, &env, v_pnt1, v_pnt2, 
                                   pnt_to_prjct, &num_pnts,
                                   &&proj_pnts, &&u_pars,
                                   &&v_pars );

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   ------------------------------------
 *env           struct GRmd_env  Module environment information for 
                                 getting the abstract geometry for the
                                 surface object to which the message is
                                 being sent.

 v_pnt1         IGRpoint         point one of the vector along which the
                                 point is to be projected

 v_pnt2         IGRpoint         point two of the vector along which the
                                 point is to be projected

 pnt_to_prjct   IGRpoint         point to be projected onto the surface

 *num_pnts      IGRlong          number of projection points on the
                                 surface

 **proj_pnts    IGRdouble        Array of projection points

 **u_pars       IGRdouble        Array of u parameter values of projection
                                 points

 **v_pars       IGRdouble        Array of v parameter values of projection
                                 points

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
       *msg       IGRlong        completion code
                                 Possible return values :
                                  
                                 MSSUCC : if the method was successful in
                                          determining the projection
                                          points.

                                 MSFAIL : if the math routine could not
                                          allocate enough stack memory
                                          for the proj_pnts, u_pars, v_pars
                                          arrays. Also simultaneously an 
                                          OMerror status of OM_E_ABORT is
                                          returned

                                          Also returned if the math routine
                                          could not determine projection 
                                          points for reasons other than 
                                          memory allocation problems.

                                 EMS_E_InvalidArg : If the vector is 0 
                                          vector or if the user snaps to
                                          an object other than a surface.
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:  

        
     BSmkvec            -               returns a vector when given 
                                        two points

     BSnorvec           -               normalizes a vector

     BSpj_pt_sf         -               the math routine which projects
                                        point onto the surface and returns
                                        an array of projection points and their
                                        parameters.

     GRgetabsg          -               Gets the abstract geometry of the
                                        surface object  

     Methods:  

-----
%RL%

     RELATIONS REFERENCED:  none.
-----
%NB%

Instead of converting the surface to the world coordinate system; it is
better to get the surface and the points in the local coordinate system
and the convert the latter into the world coordinate system. This
approach should be faster than the one implemented below and may be
done at a later date.

-----
%CH%

     CHANGE HISTORY:
        
     JBK : 28-Oct-86  Normalize the vector sent to BSpj_pt_sf
     PP : 10/14/86    Design Date
     Sudha 7/07/93    Modified for BSprototypes ansification

-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

This method determines the projection points of a point in a given
direction onto a surface.  The command object which calls this
method needs to construct the point objects if it so desires.  Also
the command object can send null values for the proj_pnts, u_pars
or v_pars if it is not interested in them.  

Alogirithm :
1) Check to see if any of the pointer variables proj_pnts, u_pars,
   v_pars has a NULL address. If so make the appropriate
   assignments between the local pointer variables and the incoming
   pointer variables. See the code for further details.

2) Get the abstract geometry of the surface object.

3) If successful 
  a) Determine the vector from two points.
  b) Call the math routine to determine the projection points.

4)Deallocate memory depending on whether any of the pointer variables
  proj_pnts, u_pars, v_pars had a null address. See the code below for
  further details.

----*/
/*EH*/

class implementation EMSsubbs;

#include "EMS.h"
# ifdef DEBUG
# include <stdio.h>
# endif

# ifndef OM_D_MINIMUM
# include "OMminimum.h"     /* for gocmacros.h  */
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"     /* for gocmacros.h  */
# endif

# ifndef gocmacros_include
# include "gocmacros.h"     /* GRgetabsg macro  */
# endif

# ifndef msdef_include
# include "msdef.h" /* MS message codes */
# endif

#include "msmacros.h"
#include "bserr.h"

/* igr.h replacement */

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

/* end of igr.h replacement */
#include "OMerrordef.h"
#include "bspj_pt_sf.h"
#include "bsnorvec.h"
#include "bsmkvec.h"

#ifndef NULL
#define NULL 0
#endif

method EMpjptsf (IGRlong *msg;
                   struct GRmd_env *env;
                   IGRpoint v_pnt1;
                   IGRpoint v_pnt2;
                   IGRpoint pnt_to_prjct;
                   IGRlong *num_pnts;
                   IGRdouble **proj_pnts;
                   IGRdouble **u_pars;
                   IGRdouble **v_pars)

{

 IGRlong        status;                 /* OM return code */
 IGRlong        sts;                    /* BS return code */
 IGRlong        i;                      /* integer variable used by
                                           GRgetabsg */
 
 IGRdouble      *local_proj_pnts;       /* local pointer variable for
                                           the array of projection points */
 IGRdouble      *local_u_pars;          /* local pointer variable for
                                           the array of u parameters */
 IGRdouble      *local_v_pars;          /* local pointer variable for
                                           the array of v parameters */

 IGRchar        *ptr;                   /* characeter pointer to the
                                           abstract geometry */
 
 IGRvector      vctr;                   /* vector indicating direction in
                                           which the point is to be
                                           projected onto the surface */
 
 struct         IGRbsp_surface *surf;   /* pointer to the abstract geometry
                                           of the suraface object */

/* **************

   Initialisation

   ************** */
# if DEBUG
    fprintf (stderr, "ECpjptsfvc, &MI = 0x%x msg = 0x%x\n", env,
        msg);
# endif

 *msg = MSSUCC;

# if DEBUG
    fprintf (stderr, "ECsspjptsf, *msg = 0x%x\n", *msg);
# endif


 status = OM_S_SUCCESS;
 surf = NULL;
 local_proj_pnts = NULL;
 local_u_pars = NULL;
 local_v_pars = NULL;

/* **************

   Check to see if incoming proj_pnts, u_pars, v_pars is NULL. If not
   assign the local variables for the aforesaid parameters to
   to the incoming pointer variables

   If null assign the local pointer variables of the aforesaid
   parameters to NULL.

   ************** */

 if (proj_pnts) local_proj_pnts = *proj_pnts;

 if (u_pars) local_u_pars = *u_pars;

 if (v_pars) local_v_pars = *v_pars;


/* **************

   Get the abstract geometry of the surface object

   ************** */

 GRgetabsg (msg, &env->md_env.matrix_type, env->md_env.matrix, &ptr, i);

 if ( *msg & 1)  /* if not a valid surface */
  {
    surf = (struct IGRbsp_surface *)ptr;
    surf->num_boundaries = 0;
    
#   if DEBUG
        BSprintbsps (stderr, "EMsspjptsf", surf, TRUE);
#   endif

    sts = BSmkvec (msg, vctr, v_pnt1, v_pnt2); /* for determining the vector
                                                  when given two points */
    if (sts)
        sts = BSnorvec (msg, vctr); /* normalizing the vector */

#   if DEBUG
        fprintf (stderr, "point = %lg %lg %lg\n",
            pnt_to_prjct[0], pnt_to_prjct[1], pnt_to_prjct[2]);
        fprintf (stderr, "vector = %lg %lg %lg\n",
            vctr[0], vctr[1], vctr[2]);
#   endif

    if (sts)  /* if successful in determining the vector */
     {
       (void) BSpj_pt_sf (surf, pnt_to_prjct, vctr, num_pnts, (IGRpoint **)&local_proj_pnts,
                          &local_u_pars, &local_v_pars, msg);
                                               /* for determining the project
                                                  points on the surface */

       if (*msg == BSSUCC)
        {
         *msg = MSSUCC;
#        if DEBUG
            {
                IGRint ii;

                fprintf (stderr, "num_pnts = %d\n", *num_pnts);
                for (ii = 0; ii < *num_pnts; ii++)
                {
                    fprintf (stderr, "point = %lg %lg %lg\n",
                        local_proj_pnts[ii*3+0],
                        local_proj_pnts[ii*3+1],
                        local_proj_pnts[ii*3+2]);
                }
            }
#        endif

        }
       else /* if unsuccessful in determining projection points */
          {

            *msg = MSFAIL;
            if (*msg == BSNOSTKMEMORY) /* if no stack memory */
             {
#              if DEBUG
               fprintf (stderr, "\n Error in EMpjptsf \n");
               fprintf (stderr, "\n No stack memory \n");
#              endif
               status = OM_E_ABORT;
             } /* end if no stack memory */

          } /* end else if unsuccessful in determining the proj points */

      } /* end if successful in determining the vector */
      else /* if unsuccessful in determining the vector */
        *msg =  EMS_E_InvalidArg;
  } /* end if successful in getting the abstract geometry of the surface */
 else
    *msg =  EMS_E_InvalidArg;

/* ************

   if (input pointer addresses is not null)
    { assign input pointer to point to the array of projection points
      Do this for u and v parameter arrays too.
    } 
   else
     free memory associated with the array of projection points
     and u and v parameter arrays returned from the math routine

   ************ */

if (proj_pnts) *proj_pnts = local_proj_pnts;
else
  {
    if (local_proj_pnts) free(local_proj_pnts);
  }

if (u_pars) *u_pars = local_u_pars;
else
  {
    if (local_u_pars) free(local_u_pars);
  }

if (v_pars) *v_pars = local_v_pars;
else
  {
    if (local_v_pars) free(local_v_pars);
  }

return (status);

}

end implementation EMSsubbs;
