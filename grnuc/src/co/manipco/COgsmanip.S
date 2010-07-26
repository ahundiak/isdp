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
        COgsmanip - This abstract class defines certain data and 
            implements certain methods that are common between 
            various manipulation command objects.

History
            jfh     05/01/86    creation
            mrm     06/12/86    added prompts
            mrm     08/20/86    overrode delete method
            mrm     09/22/86    OM 4.0 conversion
            hgw/mrm 10/08/86    conversion for graphics set
*/

class specification COgsmanip (1:0) of COroot;

#include "igr.h"
#include "igrdp.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "lcdef.h"
#include "lc.h"
#include "codef.h"

instance COgsmanip
{
    IGRint             event_size;      /* sizeof (struct GRevent) */
    IGRint             locate_state;    /* state internal to locate */
    IGRchar            action;          /* action to take */
    IGRchar            loc_prompt[MAX_PROMPT_SIZE];     /* locate prompt */
    IGRchar            acc_prompt[MAX_PROMPT_SIZE];     /* accept prompt */
    IGRchar            reloc_prompt[MAX_PROMPT_SIZE];   /* relocate prompt */
    IGRlong            mask1, mask2;    /* for locate filter */
    IGRlong            display_flag;    /* for locate filter */
    IGRlong            init_status;     /* init success/failure flag */
    IGRboolean         obj_hilited;     /* flag, element hilited? */
    struct GRid        my_GRid;         /* co GRid -- objid & osnum */
    struct GRevent     event1;          /* input event */
    struct GRlc_locate attr;            /* locate attr - e.g. class */
    struct GRlc_stack  locate_stack;    /* stack for the locate filter */
    channel   
    {
       (rel_ordered,
        many_to_many,
        initial=2,
        increment=1)
    }                  to_graphics;     /* channel to the graphics set*/
};

override init,
/*
Motivation
        initialize instance variables, construct and connect to 
        a graphics set, get the current module information
*/
        wakeup,
/*
Motivation
        highlight any elements that were unhighlighted in a 
        prior call to the sleep method, clear prompt & status fields
*/
        sleep,
/*
Motivation
        unhighlight the elements in the graphics set, if any are
        present, clear prompt, status, and message fields
*/
        delete;
/*
Motivation
        delete graphics set & self
*/

end specification COgsmanip;
