




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

class specification IGEgadget (1:0) of Root;

#include "igrtypedef.h"
#include "igewinchan.h"
#include "ex.h"
#include "igetypedef.h"
#include "msdef.h"
#include "OMerrordef.h"

instance IGEgadget
{
   IGRint                       win_no;
   
   IGRint                       min_x_dep;
   IGRint                       min_y_dep;
   IGRint                       max_x_dep;
   IGRint                       max_y_dep;

   IGRdouble                    min_x_indep;
   IGRdouble                    min_y_indep;
   IGRdouble                    max_x_indep;
   IGRdouble                    max_y_indep;

   channel parent_to_children   to_children;
   channel children_to_parent   to_parent;
};

message clear ( IGRlong *msg );

message activate ( IGRlong *msg; IGRint win_no );

message convert_pnt ( IGRlong *msg; int *response; struct EX_button *pnt);

/* handle collapse icon  */
message clpicon (IGRlong *msg; IGRint *flag);

/* handle pop icon */
message covicon( IGRlong *msg;struct IGEdit_range *range);

/* handle delete icon */
message delicon( IGRlong *msg );

/* handle stretch move */
message movicon( IGRlong *msg; IGRint *win_no; IGRint *flag; 
                 IGRint *minx; IGRint *miny; IGRint *maxx; IGRint *maxy);

                
message dep_extents(IGRlong *msg; IGRint *min_x; IGRint *min_y; 
                    IGRint *max_x; IGRint *max_y);

message indep_extents(IGRlong *msg; IGRdouble *min_x; IGRdouble *min_y; 
                    IGRdouble *max_x; IGRdouble *max_y);
                

message calc_dep_extents(IGRlong *msg;   IGRdouble min_x_indep; 
					 IGRdouble min_y_indep; 
					 IGRdouble max_x_indep; 
					 IGRdouble max_y_indep;
					 IGRint *min_x_dep; 
					 IGRint *min_y_dep; 
					 IGRint *max_x_dep; 
					 IGRint *max_y_dep);


message calc_indep_extents(IGRlong *msg; IGRint min_x_dep; 
					 IGRint min_y_dep; 
					 IGRint max_x_dep; 
					 IGRint max_y_dep;
					 IGRdouble *min_x_indep; 
					 IGRdouble *min_y_indep; 
					 IGRdouble *max_x_indep; 
					 IGRdouble *max_y_indep);


message range_intersect(IGRlong *msg; IGRdouble min_x; IGRdouble min_y;
                        IGRdouble max_x; IGRdouble max_y; 
                        IGRboolean *intersect);

message add_gadget(IGRlong *msg; GRobjid *gadget_id; IGRint num_gadgets);

message change_process_from(IGRlong *msg; IGRint pid; IGRint time_out);

message change_process_to(IGRlong *msg; IGRint pid; IGRint time_out);

message change_gadget_size(IGRlong *msg;IGRint dep_indep;
                           IGRdouble min_x, min_y, max_x, max_y);



reject clear, activate, convert_pnt;

end specification IGEgadget;
