




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

class specification ECmngcnstr (1:0) of COpara;

#include "igetypedef.h"
#include "igrtypedef.h"
#include <gr.h>
#include <grdpbdef.h>

instance ECmngcnstr
{
	char *fp;		   /* Main form */
	int  form_displayed;       /* is it displayed */
    
        struct GRid *prt_list;     /* List of parts' instances in the assy */
        int    num_inst;           /* Number of instances */
        int    cur_prt;            /* Current part, index into prt_list */

        struct GRid *cnstr_list;   /* List of constraints on the currently
                                    * selected part */
        struct GRid *appl_prt_list;/* List of parts that the constraints are
                                    * acting on, size same as num_cnstr */
        int    *inc_flag;          /* Flag indicating if it is incident part */
        int    num_cnstr;          /* Number of constraints in cnstr_list */
        short  cur_cnstr;          /* Currently displayed cnstr */
        short  cur_appl_prt;       /* Currently displayed appl_part */
};

override init, status_disp, sleep, wakeup, execute, delete;

message do_form( IGRlong *rc; int form_label; int g_label; double value );

message get_appl_prts_list ( IGRlong *rc );

message get_cnstr_prts_list ( IGRlong *rc );

message get_cnstr_prts_in_env( IGRlong *rc; struct GRmd_env *env );

message updateform_with_cur_part( IGRlong *rc );

message get_constr( IGRlong *rc; struct GRid *inst_id; int *ocount;
					 struct GRid **cnstr_list );

message highlight_cnstr_fea( IGRlong *msg;  struct GRid *cnstr_id ; int mode );

message edit_cnstr( IGRlong *rc; int cnstr_num );

end specification ECmngcnstr;
