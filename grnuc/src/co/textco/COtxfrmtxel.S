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
%GP%
----
%HD%
    CLASS NAME:  COtxfrmtxel
    SUBCLASS OF: COroot

    Abstract:  This class defines certain data that is needed
               in the text from text element input generator CO.

----
%CD%
    CHANNELS DECLARED:
                       none.
----
%SC%

----
%MD%
    MESSAGES DECLARED:

----
%RL%
     RELATIONS REFERENCED:
----
%NB%
 NOTES:

----
%CH%
 CHANGE HISTORY:
                    WBC  03/29/88:  Design date.
                    WBC  03/29/88:  Creation date.
----
%PD%
----------------------------------------------------------------------
                 C L A S S  D E S C R I P T I O N
----------------------------------------------------------------------
    This command object class supports an input generator that puts
text from a text element onto the software queue.
---- */

/*EH*/

class specification COtxfrmtxel (1:0) of COroot;

#include "igr.h"
#include "codef.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "dp.h"
#include "lcdef.h"
#include "lc.h"
#include "fontdef.h"
#include "font.h"
#include "gotext.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "igrdp.h"
#include "dpstruct.h"

instance COtxfrmtxel
{
    IGRchar                 loc_prompt[40];  /* locate prompt                */
    IGRchar                 acc_prompt[40];  /* accept prompt                */
    IGRchar                 reloc_prompt[40];/* relocate prompt              */
    struct  GRevent         grevent1;        /* input event                  */
    struct  GRlc_locate     attr;            /* locate attr - e.g. class     */
    struct  GRlc_stack      locate_stack;    /* stack for the locate filter  */
    struct  GRdpb_text_symb text_symb;       /* text object's symbology      */
    struct  extents         text_extents;    /* extents of the text object   */
    struct  vfont_entry     font_info;       /* font information             */
    OM_S_CLASSLIST          eligible_classes;/* classes to locate            */
    GRclassid               classid;         /* id of GRtext class           */
};

override init, wakeup, sleep, execute;

end specification COtxfrmtxel;
