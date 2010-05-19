class specification VDCmdChkIn (1:0) of VDS_LOCATE;



#define FP_POSTOLD       me^^CEO.forms[0].form_ptr
#define FP_POST          me^^CEO.forms[1].form_ptr
#define FP_SUB           me^^CEO.forms[2].form_ptr

#define FILE_PRINT      if (dm2_log) fprintf

#include "OMlimits.h"


instance VDCmdChkIn
{
  char catalog[81];
  char partid[81];
  char revision[81];
  char filename[81];
  char cur_filename[OM_K_MAXOSNAME_LEN];
  char in_key[20];
  char designRep[15];
  char DBserver[5];

  short idx_form;
  short processmode;
};


message maincheckin ( long * sts );

override form_notification;

message local_display_form ( long * sts );

end specification VDCmdChkIn;
