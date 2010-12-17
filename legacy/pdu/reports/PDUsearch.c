#include	<stdio.h>
#include	<PDUstr.h>
#include	<PDUerror.h>
#include	<FCdata.h>
#include	<PDUcommand.h>
#include	<PDMtypes.h>
#include	<MEMerrordef.h>
#include	<PDUproto.h>

int PDUsearch_on_off ()
  {
  int				status = PDM_S_SUCCESS;
  extern struct PDUrefresh	*refresh;

  if (strcmp (refresh->search_criteria, "INACTIVE") == 0)
    {
    status = PDUfill_in_string (&refresh->search_criteria, "ACTIVE");
    }
  else
    {
    status = PDUfill_in_string (&refresh->search_criteria, "INACTIVE");
    }   

  return(status);
  }
