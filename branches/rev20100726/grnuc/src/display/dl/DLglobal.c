#include <stdio.h>
#include <stdlib.h>
#include <float.h>
#include <math.h>

#include "wl.h"
#include "igrtypedef.h"
#include "igr.h"
#include "dl.h"
#include "dl_internal.h"

double *DLIbuf = NULL;      /* Big Dog malloc for polygon/linestrings */
int DLIterm_flag = FALSE;
int DLIfb_tags_flag = 0;
int DLIreport_errors = FALSE;

/* globals for linestring buffering */
struct WLpoint DLIsaved_points[DLI_NUM_SAVED_POINTS];
int DLInum_points = 0;

