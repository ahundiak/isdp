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

/*----
CHANGE HISTORY:
    trc way back when ( ~3/xx/86 ) : creation date
    trc 03/05/87 : adapted to the new include file design

---- */
/*EH*/

class specification COconst (1:0) of COroot;

#include "igrdp.h"
#include "codef.h"
#include "ex.h"
#include "grdpbdef.h"
#include "grdpb.h"

instance COconst
{
    IGRdouble              ActiveAngle;
    struct IGRdisplay      ActiveDisplay;/* active display    */
    IGRshort               ActiveLevel;  /* active level      */

    IGRchar             Prompt[MAX_PROMPT_SIZE];   /* the prompt string */
    IGRint              action;       /* an action to be performed */
    IGRchar             DatabaseType[MAX_DB_TYPE_SIZE];
};


/*
 *  override the init method to call the dpb, override the sleep to
 *  clear the message fields
 */
override init, wakeup, sleep;


end specification COconst;




