/*
Name
        LCclasschek

Description
	This function is called from the macro lc$classchek.  It checks
        whether the specified classid is valid for locate using the 
        supplied class list.

History
	rc      05/20/87    Creation date
	        07/20/87    Started documenation
	        10/26/87    Added negative class check using subclasses
        mrm     10/24/89    explicitly declare function types
                05/06/91    update to reflect dpb changes, use faster
                            mechanism to get dpb id
*/

class implementation Root;

#include "grimport.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "OMprimitives.h"
#include "OMminimum.h"
#include "OMspecify.h"
#include "exmacros.h"
#include "lcdef.h"

from GRdpb import GRcheckclass;

int LCclasschek (rc, classid_to_check, eligible_classes, mode)

IGRlong         *rc;
OMuword         classid_to_check;
OM_p_CLASSLIST  eligible_classes;
IGRint          mode;

{
    OM_p_CLASSLIST  class1;
    IGRint          ret_code;

    /*
     *  Check to see if class checks should be performed at all.
     */

    if (!LCget_class_check ())
    {
        ret_code = 1;
        *rc = 1;
        goto wrapup;
    }

    /*
     *  Check to see if the dpb classes should also be included.
     *  This is necessary because the dpb also calls this function in the
     *  method check_class.
     */

    if (mode == LC_DPB)
    {
        class1 = NULL;
        LCget_criteria_class (&class1);
        if (class1)
        {
            /*
             *  If the class check fails return 0
             */

            if (!LCcheck (rc, classid_to_check, class1, LC_NO_DPB))
            {
                ret_code = 0;
                goto wrapup;
            }
        }
    }

    ret_code = LCcheck (rc, classid_to_check, eligible_classes, mode);

wrapup:
    return (ret_code);
}


int LCcheck (rc, classid_to_check, eligible_classes, mode)
   
IGRlong		    *rc;
OM_p_CLASSLIST      eligible_classes;
OMuword             classid_to_check;
IGRint              mode;
{
    IGRlong         i;
    IGRlong	    rc1;
    OMuword         *classids;
    OM_S_OBJID      dpb_id;
    OMuword         dpb_os;

    if (!eligible_classes)
    {
        rc1 = 1;
    }
    else if (eligible_classes->p_classes == NULL)
    {
        rc1 = 1;
    }
    else
    {
        classids = (eligible_classes->p_classes);
        rc1 = 0;
        if (eligible_classes->w_count != NULL) 
        {
            if ((eligible_classes->w_flags & OM_CLST_subclass) &&
                (eligible_classes->w_flags & OM_CLST_negation))
            {
                rc1 = 1;
                for (i = 0; i < (IGRlong)eligible_classes->w_count; i++)
                {
                    *rc = om$is_ancestry_valid (superclassid = *(classids),
                                                subclassid = classid_to_check);
 	            if (*rc == OM_S_SUCCESS)
                    {
                        rc1 = 0;
	                break;
		    }
                    else if (*rc == OM_E_NOSUCHCLASS)
                    {
                        om$report_error (sts = *rc);
                        break;
                    }
		    (classids)++;
                }
            }
            else if (eligible_classes->w_flags == OM_CLST_subclass) 
            {
                for (i = 0; i < (IGRlong)eligible_classes->w_count; i++)
                {
	            *rc = om$is_ancestry_valid (superclassid = *(classids),
                                                subclassid = classid_to_check);
                    if (*rc == OM_S_SUCCESS) 
		    {
                        rc1 = 1;
	                break;
                    }
                    if( *rc == OM_E_NOSUCHCLASS)
                    {
		        om$report_error (sts=*rc);
   		        break;
                    }
		    (classids)++;
                }
            }
            else if (eligible_classes->w_flags == OM_CLST_negation) 
            {
	        rc1 = 1;
                for (i = 0; i < (IGRlong)eligible_classes->w_count; i++)
		{
	            if (classid_to_check == *(classids))  
	            {
                        rc1 = 0;
		        break;
		    }
                    (classids)++;
                }
            }
            else
            {
                for (i = 0; i < (IGRlong)eligible_classes->w_count; i++)
                {
 	            if (classid_to_check == *(classids)) 
                    {
		        rc1 = 1;
                        break;
  		    }
		    (classids)++;
                }   
            }
        }
    }
    if (mode == LC_DPB && rc1 == 1)
    {
        GRget_dpb_objid(&dpb_id, &dpb_os);

        om$send (msg = message GRdpb.GRcheckclass (rc, classid_to_check),
                 senderid = NULL_OBJID,
                 targetid = dpb_id,
                 targetos = dpb_os);

        rc1 = *rc;
        *rc = 1; 
    }
    return(rc1);
}

end implementation Root;
