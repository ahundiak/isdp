class implementation Root;

/*
 * This function returns a bounded line which 
 * is based on the input range box
 */
# define LOCATE_KLUGE 0
# define DEBUG 0

# if DEBUG
# include <stdio.h>
# include "grdpbmacros.h"
# endif

# include "EMS.h"
# include "gocmacros.h"          /* GRgetabsg macro  */
# include "msdef.h"              /* MS message codes */
# include "madef.h"              /* MA message codes */
# include "bs.h"                 /* BS stuff         */
# include "OMmacros.h"           /* OM_BLOCK_MOVE    */

# define TRUE 1
# define FALSE 0

IGRboolean rlw_get_better_line(
  range,
  line,
  better_line,
  msg)

 IGRpoint       range[2];
 struct         IGRline *line;
 IGRpoint       better_line[2];
 IGRlong        *msg;
{
 extern  IGRboolean  MAptlnproj();
 IGRboolean     status;
 IGRlong        i;
 IGRdouble      t, min_t, max_t;
 IGRpoint       corners[8], line_pt;
/*
 * Build an array which consists of the eight corner points of
 * the input range box
 */
 corners[0][0] = range[0][0];
 corners[0][1] = range[0][1];
 corners[0][2] = range[0][2];
 corners[1][0] = range[1][0];
 corners[1][1] = range[0][1];
 corners[1][2] = range[0][2];
 corners[2][0] = range[1][0];
 corners[2][1] = range[1][1];
 corners[2][2] = range[0][2];
 corners[3][0] = range[0][0];
 corners[3][1] = range[1][1];
 corners[3][2] = range[0][2];
 corners[4][0] = range[0][0];
 corners[4][1] = range[0][1];
 corners[4][2] = range[1][2];
 corners[5][0] = range[1][0];
 corners[5][1] = range[0][1];
 corners[5][2] = range[1][2];
 corners[6][0] = range[1][0];
 corners[6][1] = range[1][1];
 corners[6][2] = range[1][2];
 corners[7][0] = range[0][0];
 corners[7][1] = range[1][1];
 corners[7][2] = range[1][2];
 for (i = 0; i < 8; i++)
  {
   status = MAptlnproj(
     msg,
     corners[i],
     line,
     line_pt,
     &t);
    if (!status) return(FALSE);
   if (i)
    {
     if (t < min_t)
      {
       min_t = t;
       better_line[0][0] = line_pt[0];
       better_line[0][1] = line_pt[1];
       better_line[0][2] = line_pt[2];
      }
     if (t > max_t)
      {
       max_t = t;
       better_line[1][0] = line_pt[0];
       better_line[1][1] = line_pt[1];
       better_line[1][2] = line_pt[2];
      }
    }
   else
    {
     min_t = t;
     max_t = t;
     better_line[0][0] = line_pt[0];
     better_line[0][1] = line_pt[1];
     better_line[0][2] = line_pt[2];
     better_line[1][0] = line_pt[0];
     better_line[1][1] = line_pt[1];
     better_line[1][2] = line_pt[2];
    }
  }
# if DEBUG
 {
  IGRlong               bytes_in, bytes_out, msg;
  IGRlong               sts, ECdisplayPointSetByBuffer(); 
  IGRpoint              dog[2];
  struct GRmd_env       ModuleInfo;
  struct IGRdisplay     ActiveDisplay;

  bytes_in = sizeof(ActiveDisplay);
  gr$get_active_display(msg = &msg, sizbuf = &bytes_in,
    buffer = &ActiveDisplay, nret = &bytes_out);
  bytes_in = sizeof(ModuleInfo);
  gr$get_module_env(msg = &msg, sizbuf = &bytes_in,
   buffer = &ModuleInfo, nret = &bytes_out);
  sts = ECdisplayPointSetByBuffer(&msg, ActiveDisplay, 
         ModuleInfo, OM_GO_TransOS_0, 4, corners[0], TRUE); 
  sts = ECdisplayPointSetByBuffer(&msg, ActiveDisplay, 
         ModuleInfo, OM_GO_TransOS_0, 4, corners[4], TRUE); 
  dog[0][0] = corners[0][0];
  dog[0][1] = corners[0][1];
  dog[0][2] = corners[0][2];
  dog[1][0] = corners[3][0];
  dog[1][1] = corners[3][1];
  dog[1][2] = corners[3][2];
  sts = ECdisplayPointSetByBuffer(&msg, ActiveDisplay, 
         ModuleInfo, OM_GO_TransOS_0, 2, dog, TRUE); 
  dog[0][0] = corners[7][0];
  dog[0][1] = corners[7][1];
  dog[0][2] = corners[7][2];
  dog[1][0] = corners[4][0];
  dog[1][1] = corners[4][1];
  dog[1][2] = corners[4][2];
  sts = ECdisplayPointSetByBuffer(&msg, ActiveDisplay, 
         ModuleInfo, OM_GO_TransOS_0, 2, dog, TRUE); 

  dog[0][0] = corners[0][0];
  dog[0][1] = corners[0][1];
  dog[0][2] = corners[0][2];
  dog[1][0] = corners[4][0];
  dog[1][1] = corners[4][1];
  dog[1][2] = corners[4][2];
  sts = ECdisplayPointSetByBuffer(&msg, ActiveDisplay, 
         ModuleInfo, OM_GO_TransOS_0, 2, dog, TRUE); 
  dog[0][0] = corners[1][0];
  dog[0][1] = corners[1][1];
  dog[0][2] = corners[1][2];
  dog[1][0] = corners[5][0];
  dog[1][1] = corners[5][1];
  dog[1][2] = corners[5][2];
  sts = ECdisplayPointSetByBuffer(&msg, ActiveDisplay, 
         ModuleInfo, OM_GO_TransOS_0, 2, dog, TRUE); 
  dog[0][0] = corners[2][0];
  dog[0][1] = corners[2][1];
  dog[0][2] = corners[2][2];
  dog[1][0] = corners[6][0];
  dog[1][1] = corners[6][1];
  dog[1][2] = corners[6][2];
  sts = ECdisplayPointSetByBuffer(&msg, ActiveDisplay, 
         ModuleInfo, OM_GO_TransOS_0, 2, dog, TRUE); 
  dog[0][0] = corners[3][0];
  dog[0][1] = corners[3][1];
  dog[0][2] = corners[3][2];
  dog[1][0] = corners[7][0];
  dog[1][1] = corners[7][1];
  dog[1][2] = corners[7][2];
  sts = ECdisplayPointSetByBuffer(&msg, ActiveDisplay, 
         ModuleInfo, OM_GO_TransOS_0, 2, dog, TRUE); 
 }
# endif
 return(TRUE);
}

end implementation Root;
