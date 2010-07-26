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

/*
Name
        GRgencs.GRgetobjinfo

Description
        This method returns information about the object.

Synopsis
        IGRlong             *msg    O   return code
                                            MSSUCC (always succeeds)
        struct GRobj_info   *info   O   object information

History
        Kumar Talluri   11/25/86    creation date
        mrm             10/04/88    rework
*/

class implementation GRgencs;

#include "grimport.h"
#include "msdef.h"
#include "msmacros.h"
#include "grclasses.h"

method GRgetobjinfo (IGRlong *msg; struct GRobj_info *info)
{
    *msg = MSSUCC;
    ex$message (msgnumb = GC_I_coordsys, buff = info->type);
    return (OM_S_SUCCESS);
}

end implementation GRgencs;
