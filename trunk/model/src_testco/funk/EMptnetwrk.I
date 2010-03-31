/*
  DESCRIPTION

    This function allows user manipulation of given point matrix
    such that the all the points of a row follows a specified constraint.

  RETURN VALUE
    
    The following outcomes are possible:
    a) A point was selected and modified. 
       (Return code: EMS_S_Success, useract: EMSuser_data)
    b) The point to be modified had been selected but processing is
       interrupted before modification. 
       (Return code is EMS_I_Interrupt, useract: EMSuser_stack).
    c) User indicates a termination of the modification processing.
       (Return code: EMS_S_Success, useract: EMSuser_moveon).
    d) User indicated a back-up before choosing a point to modify.
       (Return code: EMS_S_Success, useract: EMSuser_backup).
    e) The processing was suspended by an uninterpretable user-input,
       but at a stage where the point was not selected.
       (Return code: EMS_S_Success, useract: EMSuser_stack).
    f) An error condition occurred. 
       (Return code: EMS_E_xxx).

  HISTORY
 
    SS  :  04/21/89  :  Creation
    SS  :  09/18/89  :  Added the dispopts argument and supported the display
                        of rows-only, cols-only, rows-and-cols.

    Vadiraj : 29/05/92 : Modified for message subsystem compliance.
 Sudha  :  07/02/93  :  Modified for BSprototypes ansification

*/

class implementation Root;

#include "EMS.h"
#include "OMmacros.h"
#include "igrtypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "igetypedef.h"
#include "igrdp.h"
#include "dp.h"
#include "dpstruct.h"
#include "dpmacros.h"
#include "gr.h"
#include "godef.h"
#include "go.h"
#include "exdef.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "grdpb.h"
#include "lcdef.h"
#include "lc.h"
#include "lcmacros.h"
#include "emsdef.h"
#include "emserr.h"
#include "emsdattyp.h"
#include "EMSmsgdef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "EMSlc.h"
#include "EMSopt.h"
#include "EC_P.h"
#include "msdef.h"
#include "msmacros.h"
#include "malnpspro.h"
#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

#define FIRST  0
#define SECOND 1
#define THIRD  2

#define X 0
#define Y 1
#define Z 2

#define FULL_LINESTYLE 0

/*
 * Structure used to communicate with the dynamic-modifying
 * function. The fields pt1 and pt2 point to the points in the two
 * polyline-display buffers that must be modified with the cursor
 * motion.
 */

struct modbuff_info
   {
   IGRint numbuffs;
   IGRdouble *modpt, *pt1, *pt2;
   struct DPele_header buffs[3];
   };

#define NUM_POINT_STORE 20


%safe
static void getbuff_info();
%endsafe


void EMptnetwrk (msg, ptmat, numrows, numcols, rowcons,
                 display, md_env, reentry, proc_row, proc_col, dispopts,
                 useract, lastevent, response, response_data)
IGRlong *msg;
IGRpoint *ptmat;
IGRint numrows, numcols;
struct EMSdataconstrain rowcons[];
struct IGRdisplay *display;
struct GRmd_env *md_env;
IGRboolean reentry;
IGRint *proc_row, *proc_col;
IGRushort dispopts;
enum EMSuser_responses *useract;
struct GRevent *lastevent;
IGRint *response;
IGRchar *response_data;
{
  IGRint stat_func;
  IGRint ptinx_row, ptinx_col, event_mask;
  IGRlong ptinx, msg_loc;
  IGRdouble dumpar;
  IGRpoint ptsmem[7], dumpt, savemodpt;
  struct IGRline boreline;
  struct IGRpointset pointset;
  struct modbuff_info buff_info;
  struct IGRpolyline py1, py2;
  struct IGRpointset ps;
  struct IGRespy espy;
  struct IGResps esps;
  struct IGRdisplay full_display;
  IGRint pydynfunc();
  extern void EMconstrain(), EMremove_constraints();
extern IGRboolean EFboreline() , EMconstraint_ptondata() ;

  *msg = EMS_S_Success;

  boreline.point1 = ptsmem[0];
  boreline.point2 = ptsmem[1];
  py1.points = ptsmem[0];
  py2.points = ptsmem[3];
  ps.points = ptsmem[6];
  full_display = *display;
  full_display.style = FULL_LINESTYLE;

  /*
   * If the position of the point to be processed is known (indicated by the
   * 'reentry' flag), then the processing can directly go to the stage
   * where the new position is processed.
   */

  if (reentry)
    {
    ptinx_row = *proc_row;
    ptinx_col = *proc_col;
    goto process_newposition;
    }

  /*
   * Determine user intention. a) Locate a point by a data-point input,
   * b) all done (move-on) or c) backup or d) some unprocessable input.
   * Process accordingly.
   */

  process_pointindex:
  ex$message(msgnumb=EMS_P_IdntPtMvOn);
  event_mask = GRm_DATA | GRm_RJT_MOVEON | GRm_BACK_UP;
  stat_func = co$getevent (msg = &msg_loc, event_mask = event_mask,
               event = lastevent, response = response,
               response_data = response_data);
  ex$message(msgnumb=EMS_P_ClearPromptField);
  EMerr_hndlr (!stat_func, *msg, EMS_E_Fail, ret_end);

  switch (lastevent->response)
    {
    case EX_DATA:
      stat_func = EFboreline (&msg_loc, NULL_OBJID, lastevent, &boreline);
      EMerr_hndlr (!stat_func || EMSerror (msg_loc), *msg, EMS_E_Fail,
       ret_end);

      pointset.num_points = numrows * numcols;
      pointset.points = (IGRdouble *)ptmat;
      stat_func = MAlnpsproj (&msg_loc, &boreline, &pointset, dumpt, dumpt,
                   &dumpar, &ptinx);
      EMerr_hndlr (!stat_func || EMSerror (msg_loc), *msg, EMS_E_Fail,
       ret_end);
      ptinx--;

      ptinx_row = *proc_row = ptinx / numcols;
      ptinx_col = *proc_col = ptinx % numcols;
      break;

    case EX_RJT_MOVEON:
      *useract = EMSuser_moveon;
      goto ret_end;

    case EX_BACK_UP:
      *useract = EMSuser_backup;
      goto ret_end;

    default:
      *useract = EMSuser_stack;
      goto ret_end;
    }
    
  /*
   * A particular point for alteration has been selected. Obtain the
   * new position of the point, honoring any constraint that this
   * point may have (or not have). Update the output information
   * indicating the point that has changed.
   */

  process_newposition:
  stat_func = EMconstrain_ptondata (rowcons[ptinx_row].type,
               &md_env->md_env.matrix_type, md_env->md_env.matrix,
               rowcons[ptinx_row].data.datatype, 
               rowcons[ptinx_row].data.data.object);
  EMerr_hndlr (!stat_func, *msg, EMS_E_Fail, ret_end);

  getbuff_info (ptmat, numrows, numcols, ptinx_row, ptinx_col, display,
   dispopts, savemodpt, &buff_info, &py1, &py2, &ps, &espy, &esps);

  ex$message(msgnumb=EMS_P_00141);
  dp$dynamics (dyn_fun = pydynfunc, information = &buff_info);

  event_mask = GRm_DATA | GRm_BACK_UP;
  stat_func = co$getevent (msg = &msg_loc, event_mask = event_mask,
               event = lastevent, response = response,
               response_data = response_data);
  ex$message(msgnumb=EMS_P_ClearPromptField);
  EMerr_hndlr (!stat_func, *msg, EMS_E_Fail, ret_end);

  switch (lastevent->response)
    {
    case EX_DATA:
      if (dispopts & EMS_PTNET_DISPROWS)
        {
        IGRlong ECdisplayPointSetByBuffer0();

        OM_BLOCK_MOVE (savemodpt, buff_info.pt1, sizeof (IGRpoint));
        stat_func = ECdisplayPointSetByBuffer0 (&msg_loc, full_display,
                     *md_env, NULL_OBJID, py1.num_points, py1.points, GRbe,
                     IGRPY);
        EMerr_hndlr (EMSerror (msg_loc & stat_func), *msg, EMS_E_Fail,
         ret_end);
        }

      if (dispopts & EMS_PTNET_DISPCOLS && numrows > 1)
        {
        IGRlong ECdisplayPointSetByBuffer0();

        OM_BLOCK_MOVE (savemodpt, buff_info.pt2, sizeof (IGRpoint));
        stat_func = ECdisplayPointSetByBuffer0 (&msg_loc, full_display,
                     *md_env, NULL_OBJID, py2.num_points, py2.points, 
                     GRbe, IGRPY);
        EMerr_hndlr (EMSerror (msg_loc & stat_func), *msg, EMS_E_Fail,
         ret_end);
        }

      if (dispopts & EMS_PTNET_DISPPT)
        {
        IGRlong ECdisplayPointSetByBuffer0();

        stat_func = ECdisplayPointSetByBuffer0 (&msg_loc, full_display,
                     *md_env, NULL_OBJID, 1, savemodpt, GRbe, IGRPS);
        EMerr_hndlr (EMSerror (msg_loc & stat_func), *msg, EMS_E_Fail,
         ret_end);
        }

      EMconstrain (&lastevent->event.button);
      EMremove_constraints();

      OM_BLOCK_MOVE (&lastevent->event.button.x,
       ptmat[ptinx_row*numcols+ptinx_col], sizeof (IGRpoint));

      if (dispopts & EMS_PTNET_DISPROWS)
        {
        IGRlong ECdisplayPointSetByBuffer0();

        OM_BLOCK_MOVE (&lastevent->event.button.x, buff_info.pt1,
         sizeof (IGRpoint));
        stat_func = ECdisplayPointSetByBuffer0 (&msg_loc, *display, *md_env, 
                     NULL_OBJID, py1.num_points, py1.points, GRbd, IGRPY);
        EMerr_hndlr (EMSerror (msg_loc & stat_func), *msg, EMS_E_Fail,
         ret_end);
        }

      if (dispopts & EMS_PTNET_DISPCOLS && numrows > 1)
        {
        IGRlong ECdisplayPointSetByBuffer0();

        OM_BLOCK_MOVE (&lastevent->event.button.x, buff_info.pt2,
         sizeof (IGRpoint));
        stat_func = ECdisplayPointSetByBuffer0 (&msg_loc, *display, *md_env, 
                     NULL_OBJID, py2.num_points, py2.points, GRbd, IGRPY);
        EMerr_hndlr (EMSerror (msg_loc & stat_func), *msg, EMS_E_Fail,
         ret_end);
        }

      if (dispopts & EMS_PTNET_DISPPT)
        {
        IGRlong ECdisplayPointSetByBuffer0();

        stat_func = ECdisplayPointSetByBuffer0 (&msg_loc, *display, *md_env, 
                     NULL_OBJID, 1, &lastevent->event.button.x, GRbd, IGRPS);
        EMerr_hndlr (EMSerror (msg_loc & stat_func), *msg, EMS_E_Fail,
         ret_end);
        }

      *useract = EMSuser_data;
      break;

    case EX_BACK_UP:
      goto process_pointindex;

    default:
      *msg = EMS_I_Interrupt;
      *useract = EMSuser_stack;
      goto ret_end;
    }

ret_end:
  EMWRAPUP (*msg, stat_func, "EMlnnetwrk");
  return;
}




/*
 * Locally used function to format the display buffer used
 * in the call to perform the dynamics for the affected polylines.
 */

static void getbuff_info (pts, numrows, numcols, row, col, display, opts,
                          modpt, buff, py1, py2, ps, espy, esps)
IGRpoint *pts;
IGRint numrows, numcols, row, col;
struct IGRdisplay *display;
IGRushort opts;
IGRpoint modpt;
struct modbuff_info *buff;
struct IGRpolyline *py1, *py2;
struct IGRpointset *ps;
struct IGRespy *espy;
struct IGResps *esps;
{
  IGRshort first_inx, second_inx, third_inx;
  IGRint numpts1 = 0, numpts2 = 0;
  IGRpoint *ptsptr, *pts1, *pts2;

  pts1 = (IGRpoint *)py1->points;
  pts2 = (IGRpoint *)py2->points;

  /*
   * Obtain the polyline geometry(ies) that is affected by the movement
   * of the specified point. Also obtain a separate point geometry for
   * the point that will be modified. The output buffer is also initialized
   * with the pointer to the memory location of the actual point(s) that will
   * be modified in dynamics.
   */

  if (opts & EMS_PTNET_DISPROWS)
    {
    ptsptr = (IGRpoint *)pts[row * numcols];
    if (col == 0)
      {
      numpts1 = (numcols > 1 ? 2 : 1);
      OM_BLOCK_MOVE (ptsptr, pts1, numpts1 * sizeof (IGRpoint));
      buff->pt1 = (IGRdouble *)pts1;
      }
    else if (col == numcols-1)
      {
      numpts1 = 2;
      OM_BLOCK_MOVE (ptsptr[numcols-2], pts1, 2 * sizeof (IGRpoint));
      buff->pt1 = pts1[1];
      }
    else
      {
      numpts1 = 3;
      OM_BLOCK_MOVE (ptsptr[col-1], pts1, 3 * sizeof (IGRpoint));
      buff->pt1 = pts1[1];
      }
    }
  else
    buff->pt1 = NULL;

  if (opts & EMS_PTNET_DISPCOLS && numrows > 1)
    {
    if (row == 0)
      {
      numpts2 = 2;
      ptsptr = (IGRpoint *)pts[col];
      OM_BLOCK_MOVE (ptsptr, pts2, sizeof (IGRpoint));
      ptsptr += numcols;
      OM_BLOCK_MOVE (ptsptr, pts2[1], sizeof (IGRpoint));
      buff->pt2 = (IGRdouble *)pts2;
      }
    else if (row == numrows-1)
      {
      numpts2 = 2;
      ptsptr = (IGRpoint *)pts[(numrows-2)*numcols + col];
      OM_BLOCK_MOVE (ptsptr, pts2, sizeof (IGRpoint));
      ptsptr += numcols;
      OM_BLOCK_MOVE (ptsptr, pts2[1], sizeof (IGRpoint));
      buff->pt2 = pts2[1];
      }
    else
      {
      numpts2 = 3;
      ptsptr = (IGRpoint *)pts[(row-1)*numcols + col];
      OM_BLOCK_MOVE (ptsptr, pts2, sizeof (IGRpoint));
      ptsptr += numcols;
      OM_BLOCK_MOVE (ptsptr, pts2[1], sizeof (IGRpoint));
      ptsptr += numcols;
      OM_BLOCK_MOVE (ptsptr, pts2[2], sizeof (IGRpoint));
      buff->pt2 = pts2[1];
      }
    }
  else
    buff->pt2 = NULL;

  if (opts & EMS_PTNET_DISPPT)
    {
    OM_BLOCK_MOVE (pts[row * numcols + col], ps->points, sizeof (IGRpoint));
    buff->modpt = ps->points;
    }
  else
    buff->modpt = NULL;

  /*
   * Format the element display buffers with relevant display
   * information. The buffers might have to be reaaranged for the active
   * buffers to be contiguous and at the top of the array.
   */

  buff->numbuffs = 0;

  if (buff->pt1)
    {
    espy->is_closed = FALSE;
    py1->num_points = numpts1;
    dp$build_dis_buffer (buffer = &buff->buffs[0], type = IGRPY,
     display_att = display, ele_spec_att = espy, geometry = py1);
    buff->numbuffs++;
    }

  if (buff->pt2)
    {
    py2->num_points = numpts2;
    dp$build_dis_buffer (buffer = &buff->buffs[1], type = IGRPY,
     display_att = display, ele_spec_att = espy, geometry = py2);
    buff->numbuffs++;
    }

  if (buff->modpt)
    {
    esps->is_connected = FALSE;
    ps->num_points = 1;
    dp$build_dis_buffer (buffer = &buff->buffs[2], type = IGRPS,
     display_att = display, ele_spec_att = esps, geometry = ps);
    buff->numbuffs++;
    }

  first_inx = FIRST;
  second_inx = SECOND;
  third_inx = THIRD;
  if (!buff->pt1)
    {
    OM_BLOCK_MOVE (&buff->buffs[second_inx], &buff->buffs[first_inx],
     2 * sizeof (struct DPele_header));
    second_inx = FIRST;
    third_inx = SECOND;
    }
  if (!buff->pt2)
    {
    OM_BLOCK_MOVE (&buff->buffs[third_inx], &buff->buffs[second_inx],
     sizeof (struct DPele_header));
    }

  /*
   * Also return the point to be modified.
   */

  OM_BLOCK_MOVE (pts[row * numcols + col], modpt, sizeof (IGRpoint));

  return;
}

/*
 * Locally used function that is called by the executive dynamic-function
 * to modify the affected polyline geometry while tracking the cursor
 * according to the set constraints.
 */

IGRint pydynfunc (buff_info, newpt, mtx, objs, num_objs, buffs, num_buffs,
                  dummy1, dummy2, dummy3, dummy4, dummy5, dummy6)
struct modbuff_info *buff_info;
struct EX_button *newpt;
IGRdouble *mtx;
struct GRid **objs;
IGRint *num_objs;
struct DPele_header **buffs;
IGRint *num_buffs;
IGRchar *dummy1, *dummy2, *dummy3;
IGRchar **dummy4, **dummy5, **dummy6;
{
   IGRdouble *modpt;
   extern void EMconstrain();

   EMconstrain (newpt);

   if (buff_info->pt1)
     {
     modpt = buff_info->pt1;
     modpt[X] = newpt->x;
     modpt[Y] = newpt->y;
     modpt[Z] = newpt->z;
     }

   if (buff_info->pt2)
     {
     modpt = buff_info->pt2;
     modpt[X] = newpt->x;
     modpt[Y] = newpt->y;
     modpt[Z] = newpt->z;
     }

   if (buff_info->modpt)
     {
     modpt = buff_info->modpt;
     modpt[X] = newpt->x;
     modpt[Y] = newpt->y;
     modpt[Z] = newpt->z;
     }

   *buffs = buff_info->buffs;
   *num_buffs = buff_info->numbuffs;
   return (TRUE);
}


void EMptnetwrk_display (msg, ptmat, numrows, numcols, 
                         display, md_env, dpmode, dispopts)
IGRlong *msg;
IGRpoint *ptmat;
IGRint numrows, numcols;
struct IGRdisplay *display;
struct GRmd_env *md_env;
enum GRdpmode dpmode;
IGRushort dispopts;
{
  IGRint stat_func;
  IGRint row, col, ptinx;
  IGRlong msg_loc;
  IGRpoint ptsmem[NUM_POINT_STORE], *pts;
  extern IGRlong ECdisplayPointSetByBuffer0();
  
  *msg = EMS_S_Success;
  stat_func = TRUE;

  if (dispopts & EMS_PTNET_DISPROWS)
    {
    for (row=0, ptinx=0; row<numrows; row++, ptinx += numcols)
      {
      pts = (IGRpoint *)ptmat[ptinx];
      stat_func = ECdisplayPointSetByBuffer0 (&msg_loc, *display, *md_env, 
                   NULL_OBJID, numcols, pts, dpmode, IGRPY);
      EMerr_hndlr (EMSerror (msg_loc & stat_func), *msg, EMS_E_Fail, ret_end);
      }
    }

  if (dispopts & EMS_PTNET_DISPCOLS && numrows > 1)
    {
    if (numrows > NUM_POINT_STORE)
      pts = (IGRpoint *) om$malloc (size = numrows * sizeof (IGRpoint));
    else
      pts = ptsmem;
    EMerr_hndlr (!pts, *msg, EMS_E_NoDynamicMemory, ret_end);

    for (col=0; col<numcols; col++)
      {
      for (row=0, ptinx = col; row<numrows; row++, ptinx += numcols)
        OM_BLOCK_MOVE (ptmat[ptinx], pts[row], sizeof (IGRpoint));

      stat_func = ECdisplayPointSetByBuffer0 (&msg_loc, *display, *md_env, 
                   NULL_OBJID, numrows, pts, dpmode, IGRPY);
      EMerr_hndlr (EMSerror (msg_loc & stat_func), *msg, EMS_E_Fail, ret_end);
      }
    }

  if (dispopts & EMS_PTNET_DISPPT)
    {
    for (row=0, ptinx=0; row<numrows; row++, ptinx += numcols)
      {
      pts = (IGRpoint *)ptmat[ptinx];
      stat_func = ECdisplayPointSetByBuffer0 (&msg_loc, *display, *md_env, 
                   NULL_OBJID, numcols, pts, dpmode, IGRPS);
      EMerr_hndlr (EMSerror (msg_loc & stat_func), *msg, EMS_E_Fail, ret_end);
      }
    }

ret_end:
  EMWRAPUP (*msg, stat_func, "EMptnetwrk_display");
  return;
}

end implementation Root;
