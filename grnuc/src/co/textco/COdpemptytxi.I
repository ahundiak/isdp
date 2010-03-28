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
              Intergraph and/or other  third parties which is
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

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     CLASS NAME   COdpemptytx

     METHOD NAMES COexecute

     Abstract:    This method toggles the display on/off mode for empty
               text elements.
-----
%SC%
             COdpemptytx_COexecute_method (IGRint *response;
                                           IGRchar *response_data;
                                           IGRint pos)
-----
%EN%
 
     ON ENTRY:

        NAME        DATA TYPE              DESCRIPTION
     ----------    ------------   -----------------------------------
     response      IGRint         
     response_data IGRchar
     pos           IGRint
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                      DESCRIPTION
     ----------   ------------   -----------------------------------
     *message       IGRlong         Completion code
                                    - MSSUCC if successful
                                    - MSFAIL (severe) if failure

     VALUE (IGRboolean) = TRUE            - if successful
                          FALSE           - if failure
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:    

     Methods:

-----
%RL%

     RELATIONS REFERENCED:

-----
%UI%

     USER INTERFACE DESCRIPTION:

-----
%NB%

     NOTES:  

-----
%CH%
     CHANGE HISTORY:
        
        WBC  03/31/88 : Design date.
        WBC  03/31/88 : Creation date.
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
    This method toggles the display on/off mode for empty text
elements.  If display is turned on, empty text elements'
displayable and locatable bits will be set and the text will be
displayed.  If display is turned off, empty text elements will be
erased and their displayable and locatable bits will be cleared.
----*/
/*EH*/

class implementation COdpemptytx;

#include "coimport.h"
#include "igr.h"
#include "igrdp.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grmessage.h"
#include "exmacros.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "grdpbmacros.h"
#include "OMmacros.h"
#include "gomacros.h"
#include "refdef.h"

from GRtext      import GRdpemptytext;
from OMObjSpace  import pass;
from Super_rfmgr import GRselectpass;

/*---------------------------------------------------------------*/
/*                       method COexecute                        */
/*---------------------------------------------------------------*/

method execute ( IGRint *response;
                 IGRchar *response_data;
                 IGRint pos )
{
    IGRboolean        display_on;
    IGRlong           temp_msg, status, msg_num;
    extern IGRint     GRrf_empty_text_display();
    IGRshort          pass_to_nested_files;
    IGRulong  	      ref_properties;
    OM_S_CLASSLIST    classlist;          /* classes to send message to  */
    OM_S_OBJID        os_objid;           /* current object space's objid*/
    OM_S_MESSAGE      pass_msg;           /* message to pass to graphics */
    GRclassid         classid;            /* id of GRtext class          */
    GRobjid           ref_mgr_id;         /* objid of Reference Manager  */
    IGRlong           nbytes_in_buffer, nbytes_transferred;
    struct GRmd_env   env;
    struct GRfunction_info buffer;

    struct function_arguments
    {
        IGRlong *msg;
        IGRint  (*empty_text_function)();
        IGRchar *info;
    } function_args;

    struct empty_text_arguments
    {
        IGRboolean   display_on;
        GRclassid    classid;
    } empty_text_args;

    /*
     *  turn empty text display on or off, according to which command
     *  was selected
     */

    if (me^^super_cmd.mytype)
    {
        ex$message(msgnumb = GRC_M_EmTxOn);
        display_on = TRUE;
        msg_num = GR_I_EmptyTxDispOn;
    }
    else
    {
        ex$message(msgnumb = GRC_M_EmTxOff);
        display_on = FALSE;
        msg_num = GR_I_EmptyTxDispOff;
    }

    /* 
     *  get classid from classname
     */

    status = om$get_classid(classname = "GRtext",
                            p_classid = &classid);

    if (status & 1)
    {
        classlist.w_count = 1;
        classlist.w_flags = OM_CLST_subclass;
        classlist.p_classes = &classid;

        nbytes_in_buffer = sizeof(env);

        status = gr$get_display_env(msg = &temp_msg,
                                    sizbuf = &nbytes_in_buffer,
                                    buffer = &env,
                                    nret = &nbytes_transferred);

        if (status & temp_msg & 1)
        {
            status = om$osnum_to_oso_objid(osnum = env.md_id.osnum,
                                           p_objid = &os_objid);

            if (status & 1)
            {
                /*
                 *  send the GRdpemptytext message to all text objects in the
                 *  active (master) object space
                 */

                om$send(mode = OM_e_wrt_object,
                        msg = message OMObjSpace.pass
                                    (&classlist,
                                     OM_e_wrt_object,
                                     message GRtext.GRdpemptytext
                                           (&temp_msg,
                                            display_on,
                                            &env.md_env.matrix_type,
                                            env.md_env.matrix)),
                        senderid = my_id,
                        targetid = os_objid,
                        targetos = env.md_id.osnum);

                /*
                 *  if any reference files are attached, send a GRdpemptytx
                 *  message to their text objects
                 */

                status = ex$get_objid_from_NOD(NODname = "IGENOD",
                                               objname = REFERENCE_FILE_MANAGER,
                                               pobjid = &ref_mgr_id,
                                               mod_osnum = env.md_id.osnum);

                if (status & 1)
                {
                    status = om$make_message(classname = "GRgraphics",
                                             methodname = "GRfunction",
                                             size = sizeof(struct function_arguments),
                                             p_arglist = &function_args,
                                             p_msg = &pass_msg);

                    if (status & 1)
                    {
                        go$build_user_function_buffer(buffer = &buffer,
                                                      md_env = &env,
                                                      pass_on = TRUE,
                                                      your_info = (IGRchar *)&empty_text_args);

                        function_args.empty_text_function = GRrf_empty_text_display;
                        function_args.msg = &temp_msg;
                        function_args.info = (IGRchar *)&buffer;
                        empty_text_args.display_on = display_on;
                        empty_text_args.classid = classid;
                        ref_properties = 0;
                        pass_to_nested_files = TRUE;

                        status = om$send(msg = message Super_rfmgr.GRselectpass
                                            (&temp_msg,&ref_properties,
                                             &pass_to_nested_files,&pass_msg,
                                             &env.md_env.matrix_type,
                                             env.md_env.matrix,
                                             &env.md_id.objid,
                                             &env.md_id.osnum),
                                         targetid = ref_mgr_id,
                                         targetos = env.md_id.osnum);
                    }
                }
            }
        }
    }
    ex$message(field = ERROR_FIELD,
               msgnumb = msg_num,
               time = 2);

    *response = TERMINATE;

    return(OM_S_SUCCESS);
}

end implementation COdpemptytx;
