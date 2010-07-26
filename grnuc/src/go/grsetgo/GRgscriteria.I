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
   GScriteria_pass

Description
   This method will check each of its objects for the given criteria
   if the object does not pass the criteria it will be removed from
   the graphics set.  This method will use the same structures as 
   locate to define the search criteria.

   *msg              IGRlong              Return code
   *loc_env          struct GRmd_env      The environment for a locate
   *attributes       struct GRlc_locate   The attributes describing the
                                          criteria that the object must
                                          pass.
   *classinfo        struct GRlc_classes  The classes to be located
   *levels           IGRchar              The levels to search.

Notes
   If levels are NULL then elements on all levels will be accepted.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
   Gray Winn   06/04/87    Creation date
\*/


class implementation GRgrset;

#include "grimport.h"
#include "msdef.h"

method GScriteria_pass (IGRlong *msg; struct GRmd_env *locate_env;
                        struct GRlc_locate *attributes;
                        struct GRlc_classes *classinfo;
                        IGRchar *levels)
{
IGRlong           om_msg;
OM_S_CHANSELECT   chansel;

   *msg = MSSUCC;
   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRgrset.to_sets";

   om_msg = om$send (
            msg = message GRgrset.GScriteria_pass (msg, locate_env,
            attributes, classinfo, levels),
            p_chanselect = &chansel);

   return (om_msg);
}
end implementation GRgrset;
