




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


class specification IGEwinsup (1:0) of Root;


#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igewinchan.h"
#include "dpchan.h"
#include "OMerrordef.h"


instance IGEwinsup
{
   channel winsup_to_gra_gad gra_gad;
};




message  pre_update(IGRlong *msg; struct GRid *gragad_id; 
		    struct DP_information *dp_info; struct GRmd_env *md_env);

message  post_update(IGRlong *msg; struct GRid *gragad_id);

message  pre_single_display(IGRlong *msg; struct GRid *gragad_id;
			    struct GRid *graphic_id);

message  post_single_display(IGRlong *msg; struct GRid *gragad_id;
			     struct GRid *graphic_id);


message pre_delete( IGRlong *msg);

message pre_plot( IGRchar *user_data);

message post_plot(IGRchar *user_data);

message view_changed (IGRlong *msg);

message view_saved (IGRlong *msg; struct GRid *saved_vw; struct GRid *stub_id);

message view_recalled (IGRlong *msg; struct GRid *gragad; struct GRid *stub_id);

end specification  IGEwinsup;

