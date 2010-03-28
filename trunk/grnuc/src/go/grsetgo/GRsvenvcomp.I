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
   GSenv_compare 

Description
   This method will compare the module environment and properties
   of a saveset with another saveset.

   *msg          IGRlong            return code
   *mod_env      struct GRmd_env    module environment
   *env_properties IGRint           module properties.
   *sv_id        struct GRid        the save set id

Notes
   The env_properties may be NULL.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
     Gray Winn    11/02/86    Creation date.
\*/

class implementation GRsvset;

#include "grimport.h"
#include "msdef.h"
#include "grgsdef.h"
#include "madef.h"

method GSenv_compare (IGRlong *msg; struct GRmd_env *mod_env;
                       IGRint *env_properties; struct GRid *sv_id)
{
IGRint            i;
IGRint            flag;
IGRint            prop;

   *msg = MSFAIL;
   if (env_properties)
   {
      prop = *env_properties;
   }else
   {
      prop = me->properties & GSIS_SV_PROP_MASK;
   }

   if (mod_env)
   {
      if ( (mod_env->md_id.osnum == me->path.md_id.osnum) &&
           (mod_env->md_id.objid == me->path.md_id.objid) )
      {
         if (mod_env->md_env.matrix_type == 
            me->path.md_env.matrix_type)
         {
            if ((prop & GSIS_SV_PROP_MASK) == 
                (me->properties & GSIS_SV_PROP_MASK) )
            {
               if ( (mod_env->md_env.matrix_type == MAIDMX) &&
                    (me->path.md_env.matrix_type == MAIDMX) )
               {
                  *msg = MSSUCC;
                  sv_id->objid = my_id;
                  sv_id->osnum = OM_Gw_current_OS;
               }else
               {
                  flag = TRUE;
                  for (i=0; (i < 16) && flag; ++i)
                  {
                     if (mod_env->md_env.matrix[i] != 
                        me->path.md_env.matrix[i])
                     {
                        flag = FALSE;
                     }
                  }            
                  if (flag)
                  {
                     *msg = MSSUCC;
                     sv_id->objid = my_id;
                     sv_id->osnum = OM_Gw_current_OS;
                  }
               }
            }
         }
      }
   }else
   {
      *msg = MSFAIL;
   }      
   return (OM_S_SUCCESS);
}

end implementation GRsvset;
