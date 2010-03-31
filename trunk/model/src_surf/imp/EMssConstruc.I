/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

#define REPARAMETERIZE_IN_U_ONLY  0
#define REPARAMETERIZE_IN_V_ONLY  1
#define REPARAMETERIZE_IN_U_AND_V 2

#include "bserr.h"     /* BSSUCC message code */
#include "msdef.h"     /* MS message codes             */

#define HSURF_BUNDLES   1

#if HSURF_BUNDLES
#include "hssymbmacros.h"
#include "hsurf.h"
#else
extern   IGRlong        HSgetprops();
#endif

extern OMuword OPP_EMSgenbs_class_id;

method GRconstruct(struct GRvg_construct *arglist)
/* 
   DESCRIPTION
  
   This file contains the construct method for the B-spline
   surface based subclasses of the GRvg class.
  
   RETURN VALUES
   
   arglist->msg         completion code
                        - MSSUCC if successful
                        - GRSNOINVTRAN (severe) if input
                          matrix is not invertible
                        - GRSDGNEXCEED (severe) if range
                          exceeds design limits
                        - MANOMEMORY (severe) if no memory
                        - MSFAIL (severe) if failure
                        - EMS_I_NoMoreLoops if boundaries were passed in
                          and there was an error in creating loopset out
                          of them.  
   NOTES
  
   Note that if the object id of the module object is passed in as the  
   NULL_OBJID then the object will not be added to the R-tree.
   
   ALGORITHM
  
   This method basically initializes a surface object.  The following
   steps are taken:
  
   1) Store the objects name via a GRvg.GRputname.
   2) Store the objects symbology via a GRvg.GRputsymb.
   3) Store the objects element specific attributes via a GRvg.GRputattr.
      Note that if the element specific pointer in the arglist is NULL
      then an appropriate set of default values is assumed.
   4) Reparameterize and normal the knots. (If no boundaries)
   5) Store the objects geometry and place the object in the R-tree,
      if desired via a GRvg.GRpostabsg.
  
   HISTORY
  
   06/27/86 : rlw : The beginning
   09/20/86 : rlw : OM 4.0 conversion
   01/26/87 : rlw : Rewritten such that additions to the R-tree take
                    place in the post method.
   05/15/87 : AIC : Do not generate element specific attributes.
   08/01/87 : AIC : Set my EMSIS_FRT_VERSION bit.
   10/07/87 : rlw : Modified to reparameterize the input surface if it
                    has no boundaries.  The knots are also normalized
                    in this case.  Please, please, tell me if you find
                    it necessary to remove this code as you will likely
                    break alot of code which depends on this.
   12/15/87 : SM  : Create a loopset (send message EMunpack to myself)
                    if there are boundaries present.
   03/10/88 : AIC : Modified to allow passing no geometry.
   06/02/88 : AIC : Set GRNO_NOTIFACTION flag.
   06/17/88 : rlw : Changed the EMSsubbs class to EMSgenbs as the former
                    is now an abstract class.  Also inserted code to
                    make periodic surfaces non-periodic as I think this
                    was causing some problems.
   07/04/88: sam : Changed such that for unpack even the bdrys field is
   		   checked along with num_boundaries field of the surface
		   geometry. (This is a GET AROUND: The range reduced 
		   surface is a new surface with boundaries coming on it 
		   later, but setting num_boundaries to 0 calls
		   BSarclnpars() which changes the knot vec and hence 
		   the xyz is different for the boundaries, hence in 
		   EMpartSf() mtehod I set num_boundaries to 1 if any 
		   loopset on the parent surface but bdrys to NULL so 
		   that unpacking is done iff num_boundaries is set to 1
		   and bdrys is non NULL.
   06/21/89 : rlw : As per Dieter's request removed logic to reparameterize
                    surface.
*/
{
  IGRlong        sts;


  /*
   * Initialize
   */
  sts = OM_S_SUCCESS;
  *(arglist->msg) = MSSUCC;
  if(arglist->newflag) goto wrapup;     /* Why? */

  /*
   * Set up the properties
   */
  ME.GRgraphics->properties = 
       (arglist->properties | GRIS_NEW | GRIS_POST220_OBJECT) &
                               ~GRIS_MODIFIED;
#if HSURF_BUNDLES
  {
    struct  HSrender_bundle         rend;
    IGRchar                         *app;
    IGRint                          size;
    IGRlong                         loc_msg;

    hs$get_app_entry_size(msg = &loc_msg, size = &size, active=1);
    if (size)
       app = (char *) malloc(size +8);
    else
       app = NULL;
    hs$get_rendering_bundles(rend_bundle = &rend, extra_rend_bundle = app);
    hs$add_symb_entry(msg = &loc_msg, entry = &rend, app_entry = app,
                      index = &me->hidden_line);
    if (app)
        free(app);
  }
#else
  sts = HSgetprops(&me->hidden_line);
  if(! (1 & sts)) goto wrapup;
#endif

  /*
   * Load the elements name, if any
   */
  if( arglist->name )
  {
    sts = om$send(msg = message GRvg.GRputname(arglist->msg,
                  arglist->name), senderid = my_id,targetid = my_id);
    if (!(1 & sts)) goto wrapup;
  }

  /*
   * Load the symbology
   */
  {
    struct        GRsymbology symb;

    symb.level = arglist->level;
    symb.display_attr = *(arglist->display);
    sts = om$send(msg = message GRvg.GRputsymb(arglist->msg, &symb),
                  senderid = my_id, targetid = my_id);
    if (!(1 & sts)) goto wrapup;
  }

  /*
   * Fill in the element specific data
   */
  {
    struct        IGResbs *element_specific;

    element_specific = (struct IGResbs *) arglist->class_attr;

    sts = om$send(msg = message GRvg.GRputattr
                  (arglist->msg, (IGRchar *) element_specific),
                  senderid = my_id, targetid = my_id);
    if (!(1 & sts)) goto wrapup;
  }

  if((struct IGRbsp_surface *) arglist->geometry)
  {
    /*
     * Reparameterize the input surface if no boundaries are present,
     * and I am a freeform surface
     */
    if (! ((struct IGRbsp_surface *) arglist->geometry)->num_boundaries)
    {
      OMuword      class_id;

      sts = om$get_classid(object = me, p_classid = &class_id);
      if (! (1 & sts)) { *(arglist->msg) = MSFAIL; goto wrapup; }

      if (class_id == OPP_EMSgenbs_class_id)
      {
  extern         void		BSarclnpars();
 extern  IGRboolean  BSscnvtomkt();
        IGRboolean	status;
        IGRlong		loc_msg, BSnrsfkntvc();

        status = BSscnvtomkt(
          &loc_msg,
          arglist->geometry);
         if (! status)
          {
           *(arglist->msg) = MSFAIL;
           sts = OM_E_ABORT;
           goto wrapup;
          }
#if PUT_IT_BACK_IN
        BSarclnpars(&loc_msg,REPARAMETERIZE_IN_U_ONLY,arglist->geometry);
        if(loc_msg != BSSUCC)
        { *(arglist->msg) = MSFAIL; sts = OM_E_ABORT; goto wrapup; }
#endif
        /*
         * Normalize the knots (Note: this function is in src_funk/misc)
         */
        (void) BSnrsfkntvc(arglist->geometry);
      } /* if (class_id == OPP_EMSgenbs_class_id) */
    } /* if (!surface->num_boundaries) */
  } /* if (surface) */

  /*
   * Post the abstract data (The post message is sent even if there
   * is no geometry in order to update the Rtree.)
   */
  if(arglist->geometry)
  {
    GRobjid       new_id;
    struct        GRpost_info info;

    info.construct_flag = TRUE;
    sts = om$send(msg = message GRvg.GRpostabsg(arglist->msg,
                  arglist->env_info, &info, arglist->geometry, &new_id),
                  senderid = my_id, targetid = my_id);
    if (!(1 & sts)) goto wrapup;
  }

  /*
   * If the surface has any boundaries, construct loops out of them.
   * NOTE: Unpacking must take place after posting because unpacking
   * causes the genabsg method for this object to be invoked.
   */
  if( (arglist->geometry) &&
      (((struct IGRbsp_surface *)arglist->geometry)->num_boundaries) &&
      (((struct IGRbsp_surface *)arglist->geometry)->bdrys)
    )
  {
    sts = om$send(msg = message EMSsubbs.EMunpack(arglist->msg,arglist),
                  targetid = my_id);
    /* Even if there is an error in creating the loopset out of
     * boundaries do not return a bad return code. Set the return code
     * to EMS_I_NoMoreLoops in such situations and let the caller decide
     * the action to be taken.
     */
    if(!(1&sts)){sts=OM_S_SUCCESS; *(arglist->msg)=EMS_I_NoMoreLoops;}
  }

wrapup:
  EMSmsgReport(sts, "EMSsubbs.GRconstruct", FALSE);
  return(sts);
}

end implementation EMSsubbs;
