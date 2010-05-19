class specification VDCzupGen (1:0) of VDS_LOCATE;

#include "VDmaster.h"
#include "VDmsg.h"

#include "VDsupMac.h"
#include "VDCzupForm.h"

instance VDCzupGen
{
  Form form_ptr;

  int  locateFlag;
  int  sleepFlag;

  TGRid  supId; /* Support curve to modify */

  TGRid  tl[VDSUP_I_MAX];  /* Template List */

  VDCsupROW rowList[132];

};

/* Need to use int here because of slic file */
message VDCsupIsBaseSurfDefined(int *msg);

message VDCsupSetSupport   (int *msg);

message VDCsupSetTrace     (int *msg; int command);

message VDCsupSetObject    (int *msg);

message VDCsupEraseHilite1 (int *msg);

message VDCsupSetLocateFlag(int *msg; int flag);

message VDCsupSetExpForm(int *msg; int rownum; int tl_index);

message VDCsupSaveFormLoc();

override init;
override delete;

end specification VDCzupGen;
