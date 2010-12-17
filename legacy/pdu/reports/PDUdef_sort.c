#include	<stdio.h>
#include	<FCdata.h>
#include	<PDUstr.h>
#include	<PDUerror.h>
#include	<PDUcommand.h>
#include	<PDMtypes.h>
#include	<MEMerrordef.h>
#include	<PDUproto.h>
#include	<PDMproto.h>

extern int PDM_debug_on;

int PDUsort_criteria_on_off()
  {
  int				status = PDM_S_SUCCESS;
  extern struct PDUrefresh	*refresh;

  if (strcmp (refresh->sort_criteria, "INACTIVE") == 0)
    {
    status = PDUfill_in_string (&refresh->sort_criteria, "ACTIVE");
    }
  else
    {
    status = PDUfill_in_string (&refresh->sort_criteria, "INACTIVE");
    }   
  return(status);
  }
 
