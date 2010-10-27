/*
Author:  dh
Date:  3/9/95
*/

#include "OMminimum.h"
#include "vd_ve.h"

/*  global data for VDS VE processing  - dh  */
struct VDve_elem_buf *VDvis_buf = NULL;
struct VDve_elem_buf *VDhid_buf = NULL;
IGRboolean VDve_processing = FALSE;
IGRboolean VDS_is_running = TRUE;

/* Global:  indicates special VDS-specific processing is in effect, which */
/* does not output results for "reference elements" from the entry point */
/* VDref_elem_ve_process */
IGRboolean VDS_REF_ELEM_PROCESSING = FALSE;
