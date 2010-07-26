/* #######################    APOGEE COMPILED   ######################## */
/*
Name
        LCcheck_class

Description
        This is mostly guesswork, but it appears that this function is
        intended to determine whether the specified classid is in a list
        maintained in the dpb.

History
        rc      ??/??/??    creation
        mrm     08/21/90    removed from delivery since I can't find
                            anything that calls this function
        scw     07/10/92    ansi conversion
*/

#include "grimport.h"
#include "OMlimits.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdp.h"
#include "gr.h"
#include "ex.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"


#argsused
IGRint LCcheck_class (classid_to_check)
OMuword classid_to_check;
{
#ifdef LEAVE_THIS_IN
    IGRlong       	msg;
    OM_S_OBJID 		dpb_id;
    GRspacenum 		dpb_os;
    IGRlong    		which_error, bytes_returned;
    struct dpb_var_list var_list;
    IGRint 		number_classes;
    OM_S_CLASSLIST 	dpb_class;
    IGRint  		ret_code, ii;

    ret_code = 0;
    msg = get_dpb_objid (&dpb_id, &dpb_os);
    
    var_list.var = DPB_NUMBER_CLASSES;
    var_list.var_ptr = &number_classes;
    var_list.num_bytes = sizeof (number_classes);
    var_list.bytes_returned = &bytes_returned;

    gr$set_inq (var_list = &var_list,
                which_error = &which_error,
                msg = &msg,
                count = 1);

    if (number_classes) {
        dpb_class.w_count = number_classes;
        dpb_class.p_classes = (OMuword *) malloc 
                           (sizeof (OMuword) * number_classes);
        dpb_class.w_flags = 0;

        var_list.var = DPB_CLASSES;
        var_list.var_ptr = &dpb_class;
        var_list.num_bytes = sizeof (number_classes);
        var_list.bytes_returned = &bytes_returned;

        gr$set_inq (var_list = &var_list,
                which_error = &which_error,
                msg = &msg,
                count = 1);

        for (ii = 0; ii < number_classes; ii++) {
            if (dpb_class.p_classes[ii] == classid_to_check) {
                ret_code = 1;
                break;
            }
        }
        free (dpb_class.p_classes);
    }
    else {
        ret_code = 1;
    }
    return (ret_code);
#else
    printf("Hey - Call Mike and tell him how you called LCcheck_class!!\n");
    return(0);
#endif
}
