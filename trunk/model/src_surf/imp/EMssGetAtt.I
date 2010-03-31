/* ###################   APOGEE COMPILED   ################## */
/* 
 DESCRIPTION

 This method gets the element specific attributes of a surface.

 RETURN VALUES

 msg                    MSSUCC if success
                        MSFAIL if problems in allocating abstract buffer
 attr                   char pointer to attributes (struct IGResbs)

 HISTORY

 07/14/86 : rlw : The beginning
 09/21/86 : rlw : OM 4.0 conversion and bit field additions
 03/27/87 : rlw : Rewritten due to the fact that the rule line counts
                  were compressed into one short and slow rule line
                  spacing was removed.
 */

class implementation EMSsubbs;

#include "EMS.h"

# ifndef msdef_include
# include "msdef.h" /* MS message codes */
# endif

/*#include "grdef.h"*/
#include "madef.h"
#include "EMSssprops.h"

method GRgetattr(IGRlong *msg; IGRchar *attr)

{
 struct IGResbs *element_specific;

 *msg = MSSUCC;
 element_specific = (struct IGResbs *) attr;
 element_specific->u_rules = me^^EMSsubbs.u_rules;
 element_specific->v_rules = me^^EMSsubbs.v_rules;
 element_specific->is_polydis = me^^EMSsubbs.ss_props & EMSIS_POLYDIS;
 element_specific->is_surfdis = TRUE;
 element_specific->is_slowdis = FALSE;
 return(OM_S_SUCCESS);
}

end implementation EMSsubbs;
