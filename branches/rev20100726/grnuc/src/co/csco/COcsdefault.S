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
Abstract
        This class is for the command objects which set the
        default coord system and define const plane from a
        coord system. Since half of the logical flow and the
        initialization is same for the two commands, these
        two commands are grouped to-gether.

History
        10/15/86  Kumar Talluri  Design and Implementation.
*/

class specification COcsdefault (1:0) of COconst;

#include "igr.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "igr.h"
#include "griodef.h"
#include "grio.h"
#include "lcdef.h"
#include "lc.h"

instance COcsdefault
{
   IGRlong            size;             /* size GRevent struct */
   struct GRevent     loc_event;        /* locate point struct */
   struct GRlc_locate loc_attr;         /* locate attributes; class, levels */
   struct GRlc_stack  locate_stack;     /* stack structure */
};

override init, wakeup, execute;

end specification COcsdefault;
