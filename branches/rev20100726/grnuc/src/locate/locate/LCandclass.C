/* #######################    APOGEE COMPILED   ######################## */
#include "grimport.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "igrtypedef.h"

/*
 *	This routine will take two classlists, logically and them together
 *	and place the result in the second argument.
 */

LCandclass (rc, dpb_class, command_class)
IGRlong     *rc;
OM_p_CLASSLIST command_class, dpb_class;
{
    IGRint ii,      /* dpb_class count */
           jj,      /* command_class count */
           kk = 0;  /* output_class count  -- replaces dpb_class */
    IGRshort *d_class, *c_class;
    IGRshort found = 0;
    IGRint   ret_code;

/*
 *	Insure that there are classes to check
 */

    if (command_class && command_class->w_count) {
        ret_code = 1;
        d_class = (IGRshort *)dpb_class->p_classes;

/*
 *	if the subclass and negation flags are on then classes in the list
 *	and thier subclasses are not allowed to pass the class check.
 */

        if (command_class->w_flags & OM_CLST_subclass &&
            command_class->w_flags & OM_CLST_negation) {
/*
 *	Cycle through the dpb classes
 */

            for (ii = 0; ii < (IGRint)dpb_class->w_count; ii++, (d_class)++) {
                found = 0;
                c_class = (IGRshort *)command_class->p_classes;
/*
 *	Cycle through the command specified classes
 */

                for (jj = 0; jj < (IGRint)command_class->w_count; jj++, (c_class)++) {
                    if (om$is_ancestry_valid (superclassid = *d_class,
                                            subclassid = *c_class) 
                        == OM_S_SUCCESS) {
                        found = 1;
                        break;
                    }
                    else if (om$is_ancestry_valid (superclassid = *c_class,
                                            subclassid = *d_class) 
                        == OM_S_SUCCESS) {
                        found = 1;
                        break;
                    }
                }
/*
 *	Add the class if it passed the ancestery checks.  It is inserted
 *	at index kk. 
 */

                if (!found) {
                    dpb_class->p_classes[kk++] = *d_class;   
                }
            }
        }

/*
 *	Check to see if only the subclass flag is on
 */

        else if (command_class->w_flags & OM_CLST_subclass) {

/*
 *	Cycle through the dpb classes
 */

            for (ii = 0; ii < (IGRint)dpb_class->w_count; ii++, (d_class)++) {
                c_class = (IGRshort *)command_class->p_classes;

/*
 *	Cycle through the command classes
 */

                for (jj = 0; jj < (IGRint)command_class->w_count; jj++, (c_class)++) {
                    if (om$is_ancestry_valid (superclassid = *d_class,
                                            subclassid = *c_class) 
                        == OM_S_SUCCESS) {
                        dpb_class->p_classes[kk++] = *c_class;   
			break;
                    }
                    else if (om$is_ancestry_valid (superclassid = *c_class,
                                                subclassid = *d_class) 
                         == OM_S_SUCCESS) {
    		        dpb_class->p_classes[kk++] = *d_class;   
			break;
                    }
                }
            }
        }

/*
 *	Check to see if only negation is on for the classlist.
 */
	
        else  if (command_class->w_flags & OM_CLST_negation) {

/*
 *	Cycle through the dpb classes.
 */

            for (ii = 0; ii < (IGRint)dpb_class->w_count; ii++, (d_class)++) {
                found = 0;
                c_class = (IGRshort *)command_class->p_classes;

/*
 *	Cycle through the command spcified classes.
 */

                for (jj = 0; jj < (IGRint)command_class->w_count; jj++, (c_class)++) {
                    if (*c_class == *d_class) {
                        found = 1;
                        break;
                    }
                }

/*
 *	If the class passes the criteria of not being in the classlist
 *	mark it as acceptable.
 */

                if (!found) {
                    dpb_class->p_classes[kk++] = *d_class;
                }
            }
        }

/*
 *	This case is for no flags specified in the classlist.  The classes
 *	must be the same in both lists to pass.
 */

        else {

/*
 *	Cycle through the dpb class list.
 */

            for (ii = 0; ii < (IGRint)dpb_class->w_count; ii++, (d_class)++) {
                c_class = (IGRshort *)command_class->p_classes;

/*
 *	Cycle through the command class list.
 */

                for (jj = 0; jj < (IGRint)command_class->w_count; jj++, (c_class)++) {
                    if (*c_class == *d_class) {
                        dpb_class->p_classes[kk++] = *c_class;
                        break;
                    }
                }
            }
        }
/*
 *	Set the number of classes in the list to the number of classes
 *	that actually passed the classlist.
 */

        dpb_class->w_count = kk;
    }

/*
 *	This case is taken when the command does not specify any classes
 *	that it wants to restrict on.
 */

    else {
        *rc = 1;
        ret_code = 1;
    }
    return (ret_code);
}

