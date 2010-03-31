/*
  ABSTRACT

  This class is designed to store the default parameters in EMS.

 
  HISTORY

  PP   :      10/19/87         Creation
  PP   :      04/28/87         Added a properties field for locating
                               edges and modified the design of the
                               interface with forms such that the dpb
                               object now services the form.
  RC   :      11/30/88         Added a property field for updating
                               cross sections.
  rlw  :      03/10/89         Added conditional compliation for I/DRAW
  SS   :      03/20/91         Added bit for checking associativity on
  msm  :      04/01/91         Changed to c-based form
  scw  :      08/07/91         Removed bit for checking associativity on
*/

class specification EMSdpb (1:1) of global_class;

#include <OMminimum.h>
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "EMSerrordef.h"
#include "EMSdpb.h"
#ifndef NT
#include "FI.h"
#else
typedef char* Form;
#endif
/*------------------ INSTANCE DATA SECTION -------------------*/

instance EMSdpb
{
  IGRuchar       u_order;   
  IGRuchar       v_order; 
  IGRuchar       u_rules; 
  IGRuchar       v_rules; 
  IGRuchar       props; 
  Form           form1; 
};


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

message EMget_dpbinfo
(
  IGRlong *EMmsg;
  struct EMdpbinfo *dpbinfo;
);

#ifndef BASE_EMS

message EMget_dpb_parameter
(
  IGRlong *EMmsg;
  IGRlong parameter;
  IGRchar *buffer;
);

message EMput_dpb_parameter
(
  IGRlong *EMmsg;
  IGRlong parameter;
  IGRchar *buffer;
);

message EMupdate_form
(
  IGRlong *EMmsg;
);

message EMput_dpbinfo
(
  IGRlong *EMmsg;
  struct EMdpbinfo *dpbinfo;
);

message do_form
(
  IGRlong *msg;
  IGRint form_label;
  IGRint gadget_label;
  IGRdouble value;
);

message is_displayed
(
  IGRlong *msg;
  IGRint *displayed;
);

message disp_form
(
  IGRlong *msg;
);

message erase_form
(
  IGRlong *msg;
);

override
  wake_up,
  super_construct,
  sleep,
  delete;

#endif

end specification EMSdpb;
 

