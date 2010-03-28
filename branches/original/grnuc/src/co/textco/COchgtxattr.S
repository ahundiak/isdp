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

class specification COchgtxattr (1:0) of COgsmanip;

#include "grdpbdef.h"
#include "grdpb.h"

instance COchgtxattr
{
    struct  GRdpb_text_symb text_symb;       /* text symbology from the DPB */
    OM_S_CLASSLIST          eligible_classes;/* classes to locate           */
    GRclassid               classid;         /* id of GRtext class          */
    IGRlong                 msg_number;      /* message key for the command */
    IGRint                  chg_flag;        /* flag indicating which       */
                                             /* attribute(s) to change      */
};

override init, wakeup, sleep, execute;

end specification COchgtxattr;
