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
   GScopy 

Description
   This method is used to make a copy of the original objects.  This 
   method disconnects the original object. The objects are copied to 
   the target_env.

   *msg           IGRlong           return code 
   *target_env    GRmd_env          Environment to copy objects to.
   matrix         IGRmatrix         Matrix defining transformation.
   *owner_id      GRid              Owner object.

Notes
   The owner_id argument may be NULL.  If the argument is NULL then 
   the copies are connected to the graphics set.  If it is not NULL
   it must contain the object id of the save set.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
     Gray Winn    11/02/86    Creation date.
\*/

class implementation GRfcset;

#include "grimport.h"
#include "msdef.h"
#include "grgsdef.h"

extern IGRboolean     MAtypemx();

method GScopy (IGRlong *msg; struct GRmd_env *target_env; 
               IGRmatrix matrix; struct GRid *owner_id)
{
IGRlong           om_msg;
IGRshort          matrix_type;
struct GRmd_env   temp_env;
GRobjid           temp_id;
OM_S_CHANSELECT   chansel;

   *msg = MSSUCC;
   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRgrset.to_sets";
   
   me->properties &= (0xffffffff ^ GRIS_BACKGROUND_DISPLAY);

   if (me->properties & GRIS_POST_PROCESSING)
   {
      /*
       *  Then call the post_processing_function with the
       *  copy_flag set.
       */

      om_msg = om$send (msg = message GRgrset.GSpost_processing (msg,
               target_env, owner_id, 1), targetid = my_id);

      if (om_msg & *msg & 1)
      {
         if (matrix)
         {
            MAtypemx(msg, matrix, &matrix_type);
            om_msg = om$send (msg = message GRgrset.GSpass(msg,
                     message GRgraphics.GRxform (msg, &temp_env,
                     &matrix_type, matrix, &temp_id),
                     &temp_env),
                     p_chanselect = &chansel);
         }
      }
   }else
   {
      /*
       *  Send the copy message to owner.
       */

      om_msg = om$send (mode = OM_e_wrt_message,
               msg = message GRgrset.GScopy (msg, target_env, matrix,
               owner_id), targetid = my_id);
   }
   return (om_msg);
}

end implementation GRfcset;
