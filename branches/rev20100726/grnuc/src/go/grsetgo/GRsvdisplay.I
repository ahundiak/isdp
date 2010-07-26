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

/*\
Name
   GSdisplay 

Description
   This method is used to display the objects owned by the graphics set.

   *msg         IGRlong        return code -- Possible values   
   *dpmode      enum GRdpode   An enum type representing display mode
   *display_id  GRid           Object id of the window or module

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
     Gray Winn    11/02/86    Creation date.
\*/

class implementation GRsvset;

#include "grimport.h"
#include "msdef.h"
#include "dpmacros.h"

method GSdisplay (IGRlong *msg; enum GRdpmode *dpmode; 
                  struct GRid *display_id)
{
IGRlong           om_msg;
IGRlong           one;
struct GRid       my_GRid;
struct GRmd_env   temp_env;
IGRmatrix         *mtx[1];

   one = 1;
   *msg = MSSUCC;
   my_GRid.objid = my_id;
   my_GRid.osnum = OM_Gw_current_OS;
   temp_env = me->path;
   mtx[0] = (IGRmatrix *)temp_env.md_env.matrix;

   om_msg = dp$display (msg = msg, osnum = display_id->osnum,
            objid = display_id->objid, mode = *dpmode,
            oids = &my_GRid, mtx_type = &temp_env.md_env.matrix_type,
            matrix = mtx);

   return ( om_msg );
}

end implementation GRsvset;
