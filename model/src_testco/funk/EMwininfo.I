/*
  DESCRIPTION

    This file contains functions that afford a simpler interface to
    obtain window information useful at a higher level. After the
    intialize call information, for a given window, the relevant pieces
    of information are obtatined just once and stored in a static
    array.
  
  HISTORY

    SS  :  07/17/89  :  Creation
 Sudha  :  07/02/93  :  Modified for BSprototypes ansification
*/

class implementation Root;

#include "EMS.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "exdef.h"
#include "ex.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "emsdef.h"
#include "emserr.h"
#include "mainvmx.h"

#define INCR_SIZE 4

%safe
static IGRdouble dittol;
static IGRshort num_win = 0;
static struct GRid *_winid = NULL;
static IGRint *_win_no = NULL;
static IGRshort *_wvpmattyp = NULL;
static IGRdouble *memptr = NULL;
static IGRmatrix (*_vwmat) = NULL;
static IGRmatrix (*_wvmat) = NULL;
static IGRmatrix (*_wvpmat) = NULL;
static IGRdouble *_pixtol = NULL;
static IGRdouble (*_clipdepth)[2] = NULL;
static IGRshort win_data_size = 0;
%endsafe

/*
 * This function should be called whenever there is a doubt that the windowing
 * information could have changed. After this call, information for each
 * window is obatined afresh.
 */

IGRboolean EMinit_wininfo ()
{
  IGRboolean stat_func;
  IGRint num_bytes, ret_bytes;
  IGRlong msg;

  stat_func = TRUE;

  num_bytes = sizeof (IGRdouble);
  gr$get_dit_tolerance (msg = &msg, sizbuf = &num_bytes, buffer = &dittol, 
   nret = &ret_bytes);
  EMerr_hndlr (EMSerror (msg), stat_func, FALSE, ret_end);

  num_win = 0;

ret_end:
  return (stat_func);
}


/*
 * Given a button, this function returns one or more of the following:
 * i) world-to-view matrix, ii) view-to-world matrix, iii) the current pixel
 * or dit tolerance mapped to world, iv) z-clipping depths. 
 * Any one of these output arguments can be set to NULL if not required.
 * The memory for each of these arguments must be allocated by the
 * user.
 *
 * The function first searches to see if this information is already stored, 
 * for the window (graphic gadget) indicated as input. If so it retrieves
 * it from the local memory. Else it obtains it by invoking the display-macro
 * with window graphic-gadget object-id
 */

IGRboolean EMgetwininfo (winobjid, winosnum, wvmat, vwmat, wvpmat, wvpmattyp,
                         win_no, wpixtol, vppixtol, clipdepth)
GRobjid winobjid;
GRspacenum winosnum;
IGRdouble *wvmat, *vwmat, *wvpmat, *wpixtol, *clipdepth,*vppixtol;
IGRshort *wvpmattyp, *win_no;
{
  IGRboolean stat_func;
  IGRchar *ptr;
  IGRint datinx;
  IGRlong ret_bytes;
  IGRlong msg_loc, dperr;
  IGRdouble vscale;
  GRrange vvol;
  IGRshort  i_four = 4;
  struct var_list winparlist[7];

  stat_func = TRUE;

  for (datinx=0; datinx<num_win; datinx++)
    if (winobjid == _winid[datinx].objid && 
        winosnum == _winid[datinx].osnum)
      goto output;

  if (!win_data_size)
    {
    ptr = om$malloc (size = INCR_SIZE * sizeof (struct GRid));
    EMerr_hndlr (!ptr, stat_func, FALSE, ret_end);
    _winid = (struct GRid *) ptr;

    ptr = om$malloc (size = INCR_SIZE * sizeof (IGRint));
    EMerr_hndlr (!ptr, stat_func, FALSE, ret_end);
    _win_no = (IGRint *) ptr;

    ptr = om$malloc (size = INCR_SIZE * sizeof (IGRshort));
    EMerr_hndlr (!ptr, stat_func, FALSE, ret_end);
    _wvpmattyp = (IGRshort *) ptr;

    ptr = om$malloc (size = INCR_SIZE * (3 * sizeof (IGRmatrix) +
           sizeof (IGRdouble) + 2 * sizeof (IGRdouble)));
    EMerr_hndlr (!ptr, stat_func, FALSE, ret_end);
    memptr = (IGRdouble *)ptr;
    _vwmat = (IGRmatrix *) ptr;
    _wvmat = (IGRmatrix *) (ptr += INCR_SIZE * sizeof (IGRmatrix));
    _wvpmat = (IGRmatrix *) (ptr += INCR_SIZE * sizeof (IGRmatrix));
    _pixtol = (IGRdouble *) (ptr += INCR_SIZE * sizeof (IGRmatrix));
    _clipdepth = (IGRdouble (*)[2]) (ptr += INCR_SIZE * sizeof (IGRdouble));

    win_data_size = INCR_SIZE;
    }
  else if (num_win == win_data_size)
    {
    ptr = om$realloc (size = (num_win + INCR_SIZE) * sizeof (struct GRid),
           ptr = (char *)_winid);
    EMerr_hndlr (!ptr, stat_func, FALSE, ret_end);
    _winid = (struct GRid *) ptr;

    ptr = om$realloc (size = (num_win + INCR_SIZE) * sizeof (IGRint),
           ptr = (char *)_win_no);
    EMerr_hndlr (!ptr, stat_func, FALSE, ret_end);
    _win_no = (IGRint *) ptr;

    ptr = om$realloc (size = (num_win + INCR_SIZE) * sizeof (IGRshort),
           ptr = (char *)_wvpmattyp);
    EMerr_hndlr (!ptr, stat_func, FALSE, ret_end);
    _wvpmattyp = (IGRshort *) ptr;

    ptr = om$realloc (size = (num_win + INCR_SIZE) * (3 * sizeof (IGRmatrix) +
           sizeof (IGRdouble) + 2 * sizeof (IGRdouble)), ptr = (char *)memptr);
    EMerr_hndlr (!ptr, stat_func, FALSE, ret_end);
    memptr = (IGRdouble *)ptr;
    _vwmat = (IGRmatrix *) ptr;
    _wvmat = (IGRmatrix *) (ptr += (num_win + INCR_SIZE) * 
              sizeof (IGRmatrix));
    _wvpmat = (IGRmatrix *) (ptr += (num_win + INCR_SIZE) * 
               sizeof (IGRmatrix));
    _pixtol = (IGRdouble *) (ptr += (num_win + INCR_SIZE) *
               sizeof (IGRmatrix));
    _clipdepth = (IGRdouble (*)[2]) (ptr += (num_win + INCR_SIZE) *
                  sizeof (IGRdouble));

    win_data_size += INCR_SIZE;
    }

  /*
   * Obtain the various values for the window in 
   * question.
   */

  winparlist[0].var = WLD_TO_VIEW;
  winparlist[0].var_ptr = (char *)_wvmat[num_win];
  winparlist[0].num_bytes = sizeof (IGRmatrix);
  winparlist[0].bytes_returned = &ret_bytes;

  winparlist[1].var = WLD_TO_VIEWPORT;
  winparlist[1].var_ptr = (char *)_wvpmat[num_win];
  winparlist[1].num_bytes = sizeof (IGRmatrix);
  winparlist[1].bytes_returned = &ret_bytes;

  winparlist[2].var = WLD_VIEWPORT_TYPE;
  winparlist[2].var_ptr = (char *)&_wvpmattyp[num_win];
  winparlist[2].num_bytes = sizeof (IGRmatrix);
  winparlist[2].bytes_returned = &ret_bytes;

  winparlist[3].var = WIN_NO;
  winparlist[3].var_ptr = (char *)&_win_no[num_win];
  winparlist[3].num_bytes = sizeof (IGRint);
  winparlist[3].bytes_returned = &ret_bytes;

  winparlist[4].var = VVOL_VIEWPORT_SCALE;
  winparlist[4].var_ptr = (char *)&vscale;
  winparlist[4].num_bytes = sizeof (IGRdouble);
  winparlist[4].bytes_returned = &ret_bytes;

  winparlist[5].var = VW_VOLUME;
  winparlist[5].var_ptr = (char *)vvol;
  winparlist[5].num_bytes = sizeof (GRrange);
  winparlist[5].bytes_returned = &ret_bytes;

  winparlist[6].var = END_PARAM;
  winparlist[6].var_ptr = NULL;
  winparlist[6].num_bytes = 0;
  winparlist[6].bytes_returned = NULL;

  stat_func = dp$inq_set_gragad (msg = &msg_loc, osnum = winosnum,
               gragad_objid = winobjid, which_error = &dperr,
               var_list = winparlist);
  EMerr_hndlr (EMSerror (stat_func & msg_loc), stat_func, FALSE, ret_end);

  stat_func = MAinvmx (&msg_loc, &i_four, _wvmat[num_win],
               _vwmat[num_win]);
  EMerr_hndlr (!stat_func || EMSerror (msg_loc), stat_func, FALSE, ret_end);

  _pixtol[num_win] = dittol / vscale;

  _clipdepth[num_win][0] = vvol[2];
  _clipdepth[num_win][1] = vvol[5];

  _winid[num_win].objid = winobjid;
  _winid[num_win].osnum = winosnum;

  datinx = num_win++;

  /*
   * Output the relevant data
   */

  output:
  if (wvmat)
    OM_BLOCK_MOVE (_wvmat[datinx], wvmat, sizeof (IGRmatrix));
  if (vwmat)
    OM_BLOCK_MOVE (_vwmat[datinx], vwmat, sizeof (IGRmatrix));
  if (wvpmat)
    OM_BLOCK_MOVE (_wvpmat[datinx], wvpmat, sizeof (IGRmatrix));
  if (wvpmattyp)
    *wvpmattyp = _wvpmattyp[datinx];
  if (win_no)
    *win_no = _win_no[datinx];
  if (wpixtol)
    *wpixtol = _pixtol[datinx];
  if (vppixtol)
    *vppixtol = dittol;
  if (clipdepth)
    OM_BLOCK_MOVE (_clipdepth[datinx], clipdepth, 2*sizeof (IGRdouble));

ret_end:
  return (stat_func);
}

end implementation Root;
