/* #######################    APOGEE COMPILED   ######################## */





 /*
 COPYRIGHT
                     COPYRIGHT INTERGRAPH CORPORATION
                              < 1986, 1987 >
  
              Including software  and  its  file formats, and
              audio-visual displays; all rights reserved; may
              only  be  used   pursuant   to  the  applicable
              software     license     agreement;    contains
              confidential  and  proprietary  information  of
              intergraph and/or other  third parties which is
              protected  by  copyright,   trade  secret,  and
              trademark  law,  and  may  not  be  provided or
              otherwise made available  without prior written
              authorization.
  
  
                         RESTRICTED RIGHTS LEGEND
              Use, duplication,  or  disclosure  by  the U.S.
              Government is  subject  to  restrictions as set
              forth in subdivision  (b)(3)(ii)  of the Rights
              in Technical Data  and Computer Software clause
              at 52.227-7013.
  
  
              Intergraph Corporation
              One Madison Industrial Park
              Huntsville, Al 35807-4201
  
 */ 

/*
Name
        COcptform - erase, copy, transform, and highlight

Synopsis
        IGRint COcptform (msg, module, t_matrix, caller_id, caller_os, 
                          chansel)

        IGRlong         *msg;           o return code
        struct GRmd_env *module;        i current module environment
        IGRdouble       *t_matrix;      i matrix to apply to graphics object
        GRobjid          caller_id;     i calling object's id
        OMuword          caller_os;     i calling object's osnum
        OM_S_CHANSELECT *chansel;       i channel the graphics set is on

Description
        This function erases, copies, transforms, and highlights graphic
        objects.  The function assumes that all operations are to be performed
        through a graphic set channel.  The resulting copy will reside in the
        module environment of the last point from the dpb.

Return values
        return value    OM_S_SUCCESS => success, else OM failure
        msg             even => success, else function failure

History
        Mike Mathis     07/28/86    Creation
                        09/22/86    OM 4.0 conversion
        Gray Winn       10/15/86    Convert to graphics sets.
        Mike Mathis     03/09/87    Revise include files
                        05/26/87    put copy in last-point module
                        07/29/88    changed arg list for COB conversion
*/

class implementation CEO_GSLOCATE;

#include "coimport.h"
#include "dpmacros.h"
#include "grgsmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

IGRint COcptform (msg, module, t_matrix, caller_id, caller_os, chansel)

IGRlong         *msg;           /* o return code */
struct GRmd_env *module;        /* i current module environment */
IGRdouble       *t_matrix;      /* i matrix to apply to graphics object */
GRobjid          caller_id;     /* i calling object's id */
OMuword          caller_os;     /* i calling object's osnum */
OM_S_CHANSELECT *chansel;       /* i channel the graphics set is on */

{
    IGRlong             status;         /* return code */
    IGRlong             size;           /* for dpb calls */
    struct EX_button    button;         /* last point entered - from dpb */
    struct GRmd_env     construct_env;  /* module to construct copy in */

    IGRboolean aflag;

    /*
     *  erase highlight plane
     */

    status = dp$erase_hilite (msg = msg,
                              objid = module->md_id.objid,
                              osnum = module->md_id.osnum);

    if (!(status & *msg & 1))
    {
        goto finish;
    }

    /*
     *  get the module to copy to -- use last_point
     */

    size = sizeof (struct EX_button);
    gr$get_last_point (msg = msg,
                       sizbuf = &size,
                       buffer = &button,
                       nret = &size);

    size = sizeof (struct GRmd_env);
    gr$get_construct_env (msg = msg,
                          point = &button,
                          sizbuf = &size,
                          buffer = &construct_env,
                          nret = &size);

    aflag = pwIsActivationOn();
    if (aflag)
    {
       pwGetActiveModuleEnv(&construct_env);
    }

    /*
     *  send message through the graphics set to copy the object,
     *  and then transform the copy
     */

    status = gr$gscptform (msg = msg,
                           target_env = &construct_env,
                           matrix = t_matrix,
                           senderid = caller_id,
                           senderos = caller_os, 
                           p_chanselect = chansel);

    if (!(status & *msg & 1))
    {
        goto finish;
    }

    /*
     *  send message through channel to highlight self
     */

    status = gr$gsdisplay (msg = msg,
                           dpmode = GRbdhd,
                           display_id = &module->md_id, 
                           senderid = caller_id,
                           senderos = caller_os,
                           p_chanselect = chansel);

    if (!(status & *msg & 1))
    {
        goto finish;
    }

finish:

    return (status & *msg & 1);
}

end implementation CEO_GSLOCATE;
