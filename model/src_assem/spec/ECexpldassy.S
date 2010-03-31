




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

class specification ECexpldassy (1:0) of COpara;
#include "igetypedef.h"
#include "igrtypedef.h"
#include <gr.h>
#include <grdpbdef.h>

instance ECexpldassy
{
    char    *fp;      /* Form ptr for display of options form */
    int     depth, 
	    statenum, 
	    newstate,
            disable_cnstr;

    double  offset;

    struct GRid tableid;    /* ID of the table storing exploded states */
    struct GRid partid;
    struct GRmd_env partenv;
};

message EMexpld_assy( IGRlong *rc; struct GRid *partid; struct GRmd_env *env;
                   int depth; double offset; int state );

message do_form( IGRlong *rc; IGRint f_label,g_label; IGRdouble value );

message EMsetup_optform(IGRlong *msg; struct GRid *partid; struct GRmd_env *env );


override init, status_disp, wakeup, sleep, delete, execute;

end specification ECexpldassy;
