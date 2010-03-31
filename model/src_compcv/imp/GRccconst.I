/* ###################   APOGEE COMPILED   ################## */
/*
 DESCRIPTION

   This file contains the construct method for the B-spline composite
   curve class.  
  
   RETURN VALUES
   
   arglist->msg	 	completion code
  			- MSSUCC if successful
  			- MSFAIL (severe) if failure
  
 NOTES
  
   This method merely initializes the composite curve shell.
   
 ALGORITHM
  
   This method basically initializes a composite curve object.  The following
   steps are taken:
  
   1) Store the objects name via a GRvg.GRputname.
   2) Store the objects symbology via a GRvg.GRputsymb.
  
 HISTORY

   11/12/86 : gk  : creation date
   05/06/87 : rlw : Rewritten
   11/20/87 : AIC DLB : Remove references to GRvg.
   06/02/88 : AIC : Set GRNO_NOTIFICATION bit.
   15 Sep 1988 AIC Do not set GRNO_NOTIFICATION bit.
   11/10/88 : pp : Added code to support active owners.
*/

class implementation GRcompcurve;

#include "EMScc.h"
#include "msdef.h"			/* Has MSSUCC, MSFAIL */

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
 * (Don't) Load the symbology
 *
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
 */

/*
 * Fill in the element specific data
 */
 {
/* Composite curves have no element specific attributes at this time */
 }

/*
 * Add the composite to the active owner. 
 */

 sts = om$send (msg = message GRowner.GRadd_to_active_owner(arglist->msg,
                   arglist->env_info),
                   targetid = my_id);
 if (!(1&sts&*(arglist->msg))) return(sts);

/* End active owner support */

/*
 * End of routine
 */
 return(OM_S_SUCCESS);
}

end implementation GRcompcurve;
