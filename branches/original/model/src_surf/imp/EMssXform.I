/* ###################   APOGEE COMPILED   ################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:   EMSsubbs    
     METHOD NAME:   GRxform

     Abstract: 

        This method transforms the geometry of a 
        graphics object by a matrix.  

-----
%SC%    

     GRxform(EMmsg,obj_dsenv,mx_type,mx,newobjid)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   ------------------------------------
     *obj_dsenv   GRmd_env       md_env structure 
     *mx_type IGRshort       the type of the matrix as determined
                                 by math function MAtypemx()
     mx       IGRmatrix      the given transformation matrix

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
     *newobjid    GRobjid        objid of the transformed object
     *EMmsg         IGRlong        completion code
                                    - MSSUCC if successful
                                    - GRIZRNGCHG (info) if 2-d 
                                        object transforms to other
                                        than a constant elevation
                                        and is adjusted
                                    - GRSNOINVTRAN (severe) if
                                        matrix in env_info is not 
                                        invertible
                                    - GRSDGNEXCEED (severe) if 
                                        design space limits are 
                                        exceeded
                                    - MSFAIL (severe) if failure

-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:   
                MArptsxform
                MAoptsxform
     Methods:
                GRgenabsg
                GRpostabsg

-----
%RL%

     RELATIONS REFERENCED:      None.
-----
%NB%

     NOTES:                     None.
-----
%CH%

     CHANGE HISTORY:
        
        RLW     06/27/86 : Modified for surface
        RLW     09/21/86 : OM 4.0 modifications

        AIC     10 Mar 88   Call EMmodifiedClass to insure class
                            integrity.
        dhm     04/05/88 : Added GR_NOTIFY_LISTENERS.
        SS      08/26/88 : Modified notification to the new scheme
        DLB   05/01/91  Xform any EMSparameter object on parent channel.  This
                        abstract class wont have the parent channel and
                        therefore is a bit dirty but im going for a lean and
                        mean impl. rather than adding an override at all the
                        EMA classes. 
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

        After calling GRgetabsg to get the abstract data (B-spline
        surface data structure), transform the surface.  Then post the 
        modified geometry back into the object.

----*/
/*EH*/

class implementation EMSsubbs;

# include "EMS.h"
# include "OMminimum.h"     /* for gocmacros.h  */
# include "igrtypedef.h"     /* for gocmacros.h  */
# include "godef.h"
# include "gocmacros.h"     /* GRgetabsg macro  */
# include "msdef.h" /* MS message codes */
# include "ma.h"

#define TRUE 1
#define FALSE 0

#include "bserr.h"
#include "bsparameters.h"

from EMSparameter import EMparam_xform;

method GRxform(IGRlong *EMmsg; struct GRmd_env *obj_dsenv; 
               IGRshort *mx_type; IGRmatrix mx; GRobjid *newobjid)
{
  IGRboolean	notify;
  char          *absgptr;
  short         status;
  extern IGRshort MArptsxform(), MAoptsxform();
  int           sts, total_poles;
  IGRshort      bssts;
  IGRint        rc;
  IGRdouble     determinant;
  IGRdouble     zero_tol;
  struct        IGRbsp_surface *surface;
  struct        GRpost_info info;
  extern IGRdouble     fabs();

  /*
   * Initialize.
   */
  sts = OM_S_SUCCESS;
  *EMmsg = MSSUCC;
  *newobjid = my_id;
  notify = EMcheck_inhibit_postproc();

  if (*mx_type ISNT MAIDMX)
  {
    int     modif;
    extern int EFmatrixClassification();

    if (ME.GRgraphics->properties & GRIS_ASSOCIATIVE)
    {
      IGRlong msg_loc;
      OM_S_CHANSELECT to_father;
      EMmake_chanselect(NDfather_father, &to_father);
      om$send(msg = message EMSparameter.EMparam_xform(&msg_loc,
                    obj_dsenv, mx_type, mx, newobjid),
              p_chanselect = &to_father);
    }

    /*
     * Generate my abstract data
     */
    GRgetabsg(EMmsg, &obj_dsenv->md_env.matrix_type,
              obj_dsenv->md_env.matrix, &absgptr, i);
    if (!(1 & *EMmsg)) goto wrapup;

    /*
     * Prepare for the modification
     */
    modif = EFmatrixClassification(mx);
    sts = om$send(msg = message EMSsubbs.EMmodifiedClass(EMmsg, modif,
                  newobjid), targetid = my_id);
    if(! (1 & *EMmsg & sts)) goto wrapup;

    /*
     * Transform the poles
     */
    surface = (struct IGRbsp_surface *) absgptr;
    surface->num_boundaries = 0;
    total_poles = surface->u_num_poles * surface->v_num_poles;
    if (surface->rational)
      status = MArptsxform(EMmsg, &total_poles, &surface->rational,
                           surface->weights, mx, surface->poles,
                           surface->poles);
    else
      status = MAoptsxform(EMmsg, &total_poles, mx_type, mx,
                           surface->poles, surface->poles);
    if (!(1 & *EMmsg)) { *EMmsg = MSFAIL; goto wrapup; }

    bssts = BSEXTRACTPAR (&rc, BSTOLCLOSETOZERO, zero_tol);

    determinant = mx[0] * (mx[5] * mx[10] - mx[6] * mx[9]) -
                  mx[1] * (mx[4] * mx[10] - mx[6] * mx[8]) +
                  mx[2] * (mx[4] * mx[9] - mx[5] * mx[8]);
    if (fabs(determinant + 1.0) < zero_tol) /* reflection */
      surface->pos_orient = !surface->pos_orient;

    /*
     * Post the changes in the data base
     */
    info.construct_flag = FALSE;
    sts = om$send(msg = message GRvg.GRpostabsg(EMmsg, obj_dsenv, &info,
                  absgptr, newobjid), targetid = *newobjid);
    if (!(1 & sts)) goto wrapup;
  }

wrapup:
  if (notify)
    {
    if (!EMSerror (*EMmsg))
      sts = om$send (msg = message EMSsurface.EMpostxform (EMmsg, NULL,
             obj_dsenv, mx_type, mx, OPPmargs, NULL), targetid = my_id);
    EMrestore_postproc();
    }

  EMWRAPUP(*EMmsg, sts, "EMSsubbs.GRxform")
  return(sts);
}

end implementation EMSsubbs;
