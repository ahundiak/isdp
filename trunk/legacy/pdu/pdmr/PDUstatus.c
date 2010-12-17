#include <stdio.h>
#include "PDUerror.h"
#include "PDUsts_st.h"
#include "PDUproto.h"

struct PDUsts_st PDUsts_st;
PDUsts_ptr PDUsts;

int PDUsetup_status_structure ()
  {
	PDUsts = &PDUsts_st;
	return (PDM_S_SUCCESS);
  }
