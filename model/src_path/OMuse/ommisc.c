#include "OMminimum.h"
#include "OMerrordef.h"
#include "PWminimum.h"
#include "PWapi/ommisc.h"

/*
  ABSTRACT

  This function decodes the error code returned from all of the OM APIs
  and reports the corresponding error message to standard output.
*/

void omReportError
(
  PWresult status
)
{
  som_report_error ((int) status);
  return;
}
