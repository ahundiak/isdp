#include <stdio.h>

#include "OMminimum.h"
#include "igrtypedef.h"
#include "igr.h"
#include "hplot.h"
#include "HStl_window.h"
#include "HStl_global.h"
#include "HPglobal.h"
#include "HPtiming.h"
#include "HPdef.h"
#include "hsdisplay.h"
#include "HSd_fixedpt.h"
#include "HPpr_hplot_f.h"

extern FILE *HPreport_file;

/*---HPenter_HSURF------------------------------------------------*/

/*
NAME
        HPenter_HSURF
        
KEYWORD
        HSplot
        initialization
        question coding
        
DESCRIPTION
        Initializes hsurf for shaded plotting
        
GLOBALS USED
        HPreport_file: Pointer to an output report file.  This is only
                       open if the report file already exist.
        HPglobal
        HPenv_var
        tiling_parms
        
FUNCTIONS CALLED
        HPopen_reprot_file
        HPtiming_start
        
NOTES
        QUESTION
                HPglobal.debug should be set the HPenv_var.debug in
                HPinit.c
                
HISTORY
        ??/??/??	M. Lanier
                Created
                
*/

int HPenter_HSURF (void)

   {
   FILE *HPopen_report_file ();

   HPreport_file = HPopen_report_file ();
   HPglobal.debug = HPenv_var.debug;
   HPtiming_start (0);
   
   if( HPglobal.bytes_per_pixel == 7 )
      tiling_parms.processing_mode |= HS_PMODE_PHONG_LIGHTS;
   else
      tiling_parms.processing_mode |= HS_PMODE_SHADED_PLOT;

   return (HP_I_Success);
   }

/*---HPexit_HSURF------------------------------------------------*/

/*
NAME
        HPexit_HSURF
        
KEYWORD
        HSplot
        
DESCRIPTION
        Wrap up an hsurf shaded plotting session.
        
GLOBALS USED
        tiling_parms
        HPglobal
        HPreport_file

FUNCTIONS CALLED
        HPtiming_stop
        HPtiming_report
        HPclose_report_file

HISTORY
        ??/??/??	M. Lanier
                Created
*/

int HPexit_HSURF (void)

   {
   tiling_parms.processing_mode &= ~HS_PMODE_SHADED_PLOT;
   tiling_parms.processing_mode &= ~HS_PMODE_PHONG_LIGHTS;

   HPtiming_stop (0);

   if (HPglobal.debug)
      HPtiming_report (stderr);

   if (HPreport_file != NULL)
      {
      HPtiming_report (HPreport_file);
      HPclose_report_file (HPreport_file);
      }

   return (HP_I_Success);
   }
