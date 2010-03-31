/* ###################   APOGEE COMPILED   ################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:  EMSgenbs
     METHOD NAME:  EMinsktln

     Abstract: 
        
        This method takes a parameter value, either in the U or the V 
     direction, and the multiplicity as input and inserts a knotline
     at this value with the given multiplicity. If the object does not
     belong to the free-form class, the class changes to that of the
     free-form and the old object is deleted. The new object-id is 
     returned on the argument list. Any existing chanel-linkages are
     moved to this new object.

        When extended objects get supported, this new object-id may be
     one of the extended-parent-object.

-----
%SC%    


-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
      *md_env      struct 
                    GRmd_env      structure defining the transfor-
				   mation and other info about
				   the object.

      *parms       struct         parameter value(s) at which the knotline
                    GRparms         should be inserted.

      mul          IGRint         the multiplicity of the knotline

      option       IGRint         option for multiplicity and change
                                  of class
           
                                  0 - use given multiplicity.
                       
                                  1 - use multiplicity of (order - 1).
                                        
      is_udir      IGRboolean     TRUE if the knotline applies to the 
                                    u_direction, else FALSE.
      is_vdir      IGRboolean     TRUE if the knotline applies to the
                                    v_direction, else FALSE.

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
      *msg         IGRlong        return code.
                                   - MSSUCC if all was well.
                                   - MSINARG if invalid arguments or
                                        combinations thereof, occur.
                                   - MSNOMEM if memory allocation
                                        failed.   
                                   - MSFAIL on any other error.

      newid        OM_p_OBJID     Pointer to the objid that is the result
                                   of this operation. 
             
-----
%MD%

     MODULES AND METHODS INVOKED:

     Methods:  GRgenabs
               GRpostabs

     Modules:  BSallosf
               BSsf_copy
               BSfreesf
               BSadd_ukt2
               BSadd_vkt2
               EMchgclass
               GRabsg_del             
            
-----
%RL%

     RELATIONS REFERENCED:  

             None
-----
%NB%
   
       A new object might get created, and the old one deleted. This
     is something the users of this method should be aware of. In a 
     future implementation this will not be the case. The geometry
     will be able to be posted back in the original class itself,
     regardless.

-----
%CH%

     CHANGE HISTORY:
	
	SS	09/30/86 : Design date.
    gupta 03/12/87 : added option for multiplicity & handle multiple
                     inserts at a time
    gupta 10/27/87 : removed chgclass @ new technology for modifying
                     non-free form surfaces. Now only surfaces of EMSgenbs
                     can be modified here. If the surface does not belong
                     to this class then the class needs to be changed and
                     then knotlines are inserted
    dhm   04/05/88   add GR_NOTIFY_LISTENERS.
    rlw   02/24/89   Knot tolerance that was being used was not being
                     computed relative to this surface.  The logic
                     was also skipping knots without considering
                     multiplicity.  Since the math performs these checks
                     I have removed this logic from the method.
    NP	  08/18/92   Modified for ANSI compliance by casting surface geometry
		     pointers appropriately in GRgetabsg and GRpostabsg.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

     Get the abstract geometry. Copy it into a locally allocated
  buffer. Call the math function to perform the knotline insertion.
  Finally post the geometry.

----*/
/*EH*/

class implementation EMSgenbs;

#include "EMS.h"

# ifndef msdef_include
# include "msdef.h" /* MS message codes */
# endif

#include "OMerrordef.h"
#include "OMlimits.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bstypes.h"
#include "emsdef.h"
#include "EMSdef.h"
#include "emserr.h"
#include "godef.h"

# ifndef gocmacros_include
# include "gocmacros.h" /* GRgetabsg */
# endif

method EMinsktln (IGRlong *msg;
                  struct GRmd_env *md_env;
                  IGRint numu;
                  IGRdouble *uparms;
                  IGRint numv;
                  IGRdouble *vparms;
                  IGRint mul, option;
                  IGRboolean is_udir, is_vdir;
                  GRobjid *newid)
{
  IGRboolean stat_func;
  IGRchar errmsg[EMMAXERRMSG_LEN];
  IGRlong stat_OM, msg_loc, dumdum;
  IGRint i, j;
  struct IGRbsp_surface *srf, *copy_srf;
  struct GRpost_info postinfo;
  extern   void BSallocsf();
  extern   IGRboolean BSsf_copy();
  extern IGRboolean   BSfreesf();
  extern IGRboolean   BSadd_ukt2();
  extern IGRboolean   BSadd_vkt2();
  extern   IGRboolean GRabsg_del();
  extern   IGRdouble fabs();
  /*
   * Initialize
   */

  *msg = MSSUCC;
  stat_OM = OM_S_SUCCESS;
  msg_loc = BSSUCC;
  stat_func = TRUE;
  strcpy (errmsg, "EMSgenbs.EMinsktln");
  copy_srf = NULL;

  /*
   * Get the abstract geometry
   * buffer.
   */

  GRgetabsg (&msg_loc, &md_env->md_env.matrix_type, md_env->md_env.matrix,
             (IGRchar **)(&srf), dumdum);
  EMerr_hndlr (EMis_error (msg_loc), *msg, MSFAIL, ret_end);
  srf->num_boundaries = 0;
   
  /*
   * Allocate space for copying the
   * geometry into a local area and
   * then copy it.
   */

  BSallocsf (srf->u_order,srf->v_order,srf->u_num_poles,srf->v_num_poles,
             srf->rational, (IGRlong) srf->num_boundaries, &copy_srf,
             &msg_loc);
  EMerr_hndlr (msg_loc != BSSUCC, *msg, MSFAIL, ret_end);
  stat_func = BSsf_copy (&msg_loc, srf, copy_srf);
  EMerr_hndlr (! stat_func || msg_loc != BSSUCC, *msg, MSFAIL, ret_end);

  /*
   * Call the math function to insert 
   * the knotline.
   */

  if (is_udir)
    {
     if (option)
      mul = srf->u_order-1;
     for (i=0; i<numu; i++)
      {
       stat_func = BSadd_ukt2 (&msg_loc, copy_srf, &uparms[i], &mul);
        EMerr_hndlr (! stat_func || msg_loc != BSSUCC, *msg, MSFAIL, ret_end);
      }
    }  

  if (is_vdir)
   {
    if (option)
     mul = srf->v_order-1;
    for (i=0; i<numv; i++)
     {
      stat_func = BSadd_vkt2 (&msg_loc, copy_srf, &vparms[i], &mul);
       EMerr_hndlr (! stat_func || msg_loc != BSSUCC, *msg, MSFAIL, ret_end);
     }
   }

if (! is_udir && ! is_vdir)
    EMerr_hndlr (TRUE, *msg, MSINARG, ret_end);

    postinfo.construct_flag = FALSE;
    stat_OM = om$send(mode = OM_e_wrt_object,
                      msg = message GRvg.GRpostabsg
               (&msg_loc, md_env, &postinfo, (IGRchar *)copy_srf, newid),
                      senderid = my_id,
                      targetid = my_id);
    EMomerr_hndlr (stat_OM, ret_end, errmsg);
    EMerr_hndlr (EMis_error (msg_loc), *msg, MSFAIL, ret_end);

    stat_func = GRabsg_del (srf);
    EMerr_hndlr (!stat_func, *msg, MSFAIL, ret_end);

ret_end: 
   if (copy_srf) 
     {  
     stat_func = BSfreesf (&msg_loc, copy_srf);
     EMerr_hndlr_action (!stat_func || msg_loc != BSSUCC, *msg, MSFAIL, ;);
     }

   GR_NOTIFY_LISTENERS(msg, &stat_OM, GR_GEOM_MODIFIED);
   return (stat_OM);
}
   
end implementation EMSgenbs;
