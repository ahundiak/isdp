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
   GRconstruct

Description
   This method is used to perform the initilization of the graphic 
   group header. 

   *arglist       struct GRvg_construct   Structure used to contain 
                                          arguments for construction.

History
   HGW  07/20/86 : Design date.
   HGW  08/07/86 : Changed terminology.
   HGW  09/29/86 : Convert to 4.0
   HGW  10/28/87 : Changes for version 1.1
\*/

class implementation GRgrgrp;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "grownerdef.h"

method GRconstruct (struct GRvg_construct *arglist )
{
IGRlong     om_msg;
IGRlong     ret_msg;
IGRshort    prop;

   *arglist->msg = MSSUCC;
   om_msg = OM_S_SUCCESS;

   me->properties = arglist->properties | GRIS_NEW;

   /*
    *  Set the orphan properties bit in the owners properties.
    */

   prop = GR_ORPHAN;
   om_msg = om$send (
            msg = message GRowner.GRchg_owner_properties (&ret_msg, 2,
            &prop), targetid = my_id);

   if (arglist->name)
   {
      om_msg = om$send(
               msg = message GRvg.GRputname(arglist->msg, arglist->name),
               targetid = my_id);
   }

   /*
    *  Add to active owner.
    */

   om$send (msg = message GRowner.GRadd_to_active_owner (&ret_msg,
      arglist->env_info), targetid = my_id);
         
   return (om_msg);
}
end implementation GRgrgrp;
