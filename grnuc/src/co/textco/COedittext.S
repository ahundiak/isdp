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
    CLASS NAME:  COedittext
    SUBCLASS OF: COroot

    Abstract:  This class defines certain data that is needed
               in the edit text CO.

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
                    WBC  09/08/86:  Design date.
                    WBC  09/08/86:  Creation date.
                    DEK  10/16/86:  Changes for keyboard processer.
                    DEK  08/24/87:  Remove keyboard processor.
		    jjm   3/10/93:  added pre_sleep override
----
%PD%
----------------------------------------------------------------------
                 C L A S S  D E S C R I P T I O N
----------------------------------------------------------------------

---- */

/*EH*/

class specification COedittext (1:0) of COroot;

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
#include "igrdp.h"
#include "gotext.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "dpstruct.h"

instance COedittext
{
    struct  GRevent         grevent1;        /* input event                  */
    struct  GRlc_locate     attr;            /* locate attr - e.g. class     */
    struct  GRlc_stack      locate_stack;    /* stack for the locate filter  */
    struct  GRdpb_text_symb text_symb;       /* text object's symbology      */
    struct  vfont_entry     font_info;       /* font information             */
    OM_S_CLASSLIST          eligible_classes;/* classes to locate            */
    GRclassid               classid;         /* id of GRtext class           */
    IGRshort                num_lines;       /* number of lines in string    */
    IGRshort                text_length;     /* length of the text string    */
    IGRshort                level;           /* level of located text object */
    IGRshort                text_buf_size;   /* # bytes memory allocated for */
                                             /* the text string              */
    IGRshort                properties;      /* text object's properties     */
    struct  DPele_header    ele_header;      /* struct for display info      */
    struct  IGRdisplay      disp_attr;       /* display attributes of text   */
    struct  IGResintx       text_attr;       /* element specific attr for    */
                                             /* displaying text              */
    struct  IGRestx         tx_attr;         /* element specific attr of text*/
    struct  IGRlbsys        lbs_geom;        /* local bounded system geometry*/
                                             /* of text                      */
    struct GRcc_info        cc_info;         /* current char info            */
    IGRuchar                *text_string;    /* pointer to text string       */
};

override init, wakeup, pre_sleep, sleep, execute, delete;

end specification COedittext;
