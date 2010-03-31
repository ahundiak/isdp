/* ###################   APOGEE COMPILED   ################## */
/* 
   DESCRIPTION
  
   This file contains the construct method for the B-spline freeform
   curve based subclasses of the GRvg class.
  
   RETURN VALUES
   
   arglist->msg	 	completion code
  			- MSSUCC if successful
   			- GRSNOINVTRAN (severe) if input
   			  matrix is not invertible
   			- GRSDGNEXCEED (severe) if range
   			  exceeds design limits
   			- MANOMEMORY (severe) if no memory
  			- MSFAIL (severe) if failure
  
   NOTES
  
   Note that if the object id of the module object is passed in as the  
   NULL_OBJID then the object will not be added to the R-tree.
   
   ALGORITHM
  
   This method basically initializes a curve object.  The following
   steps are taken:
  
   1) Store the objects name via a GRvg.GRputname.
   2) Store the objects symbology via a GRvg.GRputsymb.
   3) Store the objects element specific attributes via a GRvg.GRputattr.
      Note that if the element specific pointer in the arglist is NULL
      then an appropriate set of default values is assumed.
   4) Store the objects geometry and place the object in the R-tree,
      if desired via a GRvg.GRpostabsg.
  
   HISTORY
  
   06/27/86 : rlw : The beginning
   09/20/86 : rlw : OM 4.0 conversion
   01/26/87 : rlw : Rewritten such that additions to the R-tree take
                    place in the post method.
   12/13/87 : rlw : Modified such that periodic is killed and knots are
                    normalized.
   06/02/88 : AIC : Set GRNO_NOTIFICATION flag.
    15 Sep 1988 AIC Do not set GRNO_NOTIFICATION bit.
   11/10/88 : PP  : Added support for active owner.
   Sudha  06/16/93     Modified for BSprototype ansification
*/

class implementation GRsubbc;

#include "EMS.h"
#include "msdef.h"			/* Has MSSUCC, MSFAIL */
#include "grownmacros.h"                /* For gr$add_to_active_owner */
#include "bserr.h"
#include "bsnorkts.h"
#include "bscnvtomkt.h"

method GRconstruct(
  struct GRvg_construct *arglist)	/* Standard construction list */
{
 IGRlong	sts;
/*
 * Initialize
 */
 *(arglist->msg) = MSSUCC;
/*
 * Set up the properties
 */
 ME.GRgraphics->properties = 
            (arglist->properties | GRIS_NEW | GRIS_POST220_OBJECT) &
                             ~GRIS_MODIFIED;
/*
 {
  extern   IGRlong	HSgetprops();

  sts = HSgetprops(&ME.GRvg->hidden_line);
 }
*/
/*
 * Load the elements name, if any
 */
 if( arglist->name )
  {
   sts = om$send(mode = OM_e_wrt_object,
                 msg = message GRvg.GRputname(
                  arglist->msg, 
                  arglist->name),
                 senderid = my_id,
                 targetid = my_id);
    if (!(1 & sts)) return(sts);
  }
/*
 * Load the symbology
 */
 {
  struct	GRsymbology symb;

  symb.level = arglist->level;
  symb.display_attr = *(arglist->display);
  sts = om$send(mode = OM_e_wrt_object,
                msg = message GRvg.GRputsymb(
                 arglist->msg, 
                 &symb),
                senderid = my_id,
                targetid = my_id);
   if (!(1 & sts)) return(sts);
 }
/*
 * Fill in the element specific data
 */
 {
  struct	IGResbc *element_specific, default_stuff;

  if (arglist->class_attr)
   element_specific = (struct IGResbc *) arglist->class_attr;
  else
   {
    struct	IGRbsp_curve *curve;

    curve = (struct IGRbsp_curve *) arglist->geometry;
    element_specific = &default_stuff;
    default_stuff.is_polydis = FALSE;
    default_stuff.is_curvedis = TRUE;
   }
  sts = om$send(mode = OM_e_wrt_object,
                msg = message GRvg.GRputattr(
                 arglist->msg, 
                 (IGRchar *) element_specific),
                senderid = my_id,
                targetid = my_id);
   if (!(1 & sts)) return(sts);
 }
/*
 * Change the geometry to make it easier
 * for the system to handle and then post it
 */
 if (!arglist->newflag)
  {
   IGRboolean	status;
   IGRlong	loc_msg;
   GRobjid	new_id;
   struct	GRpost_info info;
   struct	IGRbsp_curve *curve;

   curve = (struct IGRbsp_curve *) arglist->geometry;
   if (curve->periodic)
    {
     status = BScnvtomkt(
       &loc_msg,
       curve);
      if (!status)
       {
        *(arglist->msg) = MSFAIL;
        return(OM_E_ABORT);
       }
    } /* if (curve->periodic) */
   status = BSnorkts(
     &loc_msg,
     &curve->order,
     &curve->num_poles,
     curve->knots);
    if (!status)
     {
      *(arglist->msg) = MSFAIL;
      return(OM_E_ABORT);
     }
/*
 * Post the abstract data
 */
   info.construct_flag = TRUE;
   sts = om$send(mode = OM_e_wrt_object,
                 msg = message GRvg.GRpostabsg(
                  arglist->msg,
                  arglist->env_info,
                  &info, 
                  arglist->geometry, 
                  &new_id),
                senderid = my_id,
                targetid = my_id);
   if (!(1 & sts)) return(sts);
 } /* if (!arglist->newflag) */

/*
 * Add to the active owner.
 */

 sts = gr$add_to_active_owner(msg = arglist->msg, mod_env = arglist->env_info);
 if (!(1 & sts)) return(sts);
                
 
/*
 * End of routine
 */
 return(OM_S_SUCCESS);
}

end implementation GRsubbc;
