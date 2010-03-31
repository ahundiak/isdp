class implementation ECdraw;

#include <string.h>
#include "exdef.h"
#include "exmacros.h"
#include "journal.h"
#include "RAPdefs.h"
#include "gr.h"
#include "dp.h"
#include "dpdef.h"
#include "dpstruct.h"
#include "dpmacros.h"

#ifdef X11
#include "wl.h"
#include "limits.h"
#include "X11/keysym.h"
#endif

#include "bserr.h"
#include "bsparameters.h"
#include "bsmkvec.h"
#include "bsnorvec.h"
#include "bscrossp.h"
#include "bslenvec.h"
#include "bsmdistcvcv.h"
#include "bscvarrevt.h"
#include "bsdistptpts.h"
#include "bscveval.h"
#include "ma.h"
#include "maptlnpro.h"
#include "maptsxfor.h"
#include "mamulmx.h"
#include "matypemx.h"

from GRgraphics  import GRdisplay;
from GRvg        import GRgenabsg;
from RAPinlisnr  import remove_last_command, listen;

#define FIRST  0
#define SECOND 1

#define HORIZONTAL    0
#define VERTICAL      1

#define COLLINEAR     0
#define ORTHOGONAL    1

#define MAX_LEN       1e5

#define X 0
#define Y 1
#define Z 2

/*
 * Functions used in the execute method.
 */

IGRboolean EFequal_constr_lines (l1, l2)
struct IGRline *l1, *l2;
{
  IGRboolean stat_func;
  IGRlong msg_loc;
  IGRdouble tol, dumpar;
  IGRpoint projpt;
  IGRvector v1, v2, outvec;

  BSmkvec (&msg_loc, v1, l1->point1, l1->point2);
  EMerr_hndlr (msg_loc != BSSUCC, stat_func, FALSE, ret_end);

  BSmkvec (&msg_loc, v2, l2->point1, l2->point2);
  EMerr_hndlr (msg_loc != BSSUCC, stat_func, FALSE, ret_end);

  BScrossp (&msg_loc, v1, v2, outvec);
  EMerr_hndlr (msg_loc != BSSUCC, stat_func, FALSE, ret_end);

  BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, tol);
  if (BSlenvec (&msg_loc, outvec) <= tol)
  {
    stat_func = TRUE;
    MAptlnproj (&msg_loc, l1->point1, l2, projpt, &dumpar);
    if (EMSerror (msg_loc) || 
        BSdistptpts (&msg_loc, l1->point1, projpt) > tol * tol)
      stat_func = FALSE;
  }
  else
    stat_func = FALSE;

ret_end:
  return (stat_func);
}

IGRboolean EFstring_match (str1, str2)
IGRchar *str1, *str2;
{
  IGRboolean match;
  IGRint i, len1, len2;

  len1 = strlen (str1);
  len2 = strlen (str2);
  if (len1 > len2)
    len1 = len2;
  if (len1)
  {
    match = TRUE;
    for (i=0; i<len1; i++)
      if (toupper (str1[i]) != str2[i])
      {
        match = FALSE;
        break;
      }
  }
  else
    match = FALSE;

  return (match);
}

IGRboolean EFhorvert_for_datapoint (xyzpt, winpt, xvec, yvec, zvec,
                                    constr_type,
                                    numexistlines, existlines,
                                    numlines, lines)
IGRdouble 	*xyzpt;
IGRdouble 	*winpt, *xvec, *yvec, *zvec;
IGRshort 	constr_type;
IGRint 		numexistlines;
struct 		IGRline *existlines;
IGRint 		*numlines;
struct IGRline 	*lines;
{
  IGRboolean 		proceed;
  IGRshort 		idmattyp, topln_mattyp, frompln_mattyp;
  IGRint 		i, j, inx;
  IGRlong 		one = 1, stat_OM, msg_loc;
  IGRpoint 		locxyz, xpt, ypt, lnpts[2][2];
  IGRmatrix 		idmat, topln_mat, frompln_mat;
  struct IGRline 	lns[2];
  extern IGRboolean 	EFequal_constr_lines();
  extern void 		EMidmatrix(), EMtoplnxform();

  stat_OM = OM_S_SUCCESS;
  msg_loc = EMS_S_Success;

  *numlines = 0;

  /*
   * Intialize local
   */

  for (i=0; i<2; i++)
  {
    lns[i].point1 = lnpts[i][0];
    lns[i].point2 = lnpts[i][1];
  }

  /*
   * Obtain transformation to the plane and transformation back from
   * the plane.
   */

  EMidmatrix (&msg_loc, &idmattyp, idmat);
  EMtoplnxform (&msg_loc, winpt, zvec, &idmattyp, idmat,
                &topln_mattyp, topln_mat, &frompln_mattyp, 
                frompln_mat, NULL);
  EMomerr_exit (msg_loc, ret_end);

  /*
   * Obtain the modified x and y vectors and also transform the window-point
   * to the plane.
   */

  for (i=0; i<3; i++)
  {
    xpt[i] = winpt[i] + xvec[i];
    ypt[i] = winpt[i] + yvec[i];
  }
  MAptsxform (&msg_loc, &one, topln_mat, xpt, xpt);
  EMomerr_exit (msg_loc, ret_end);
  xpt[Z] = 0.0;
  MAptsxform (&msg_loc, &one, topln_mat, ypt, ypt);
  EMomerr_exit (msg_loc, ret_end);
  ypt[Z] = 0.0;

  MAptsxform (&msg_loc, &one, topln_mat, xyzpt, locxyz);
  EMomerr_exit (msg_loc, ret_end);
  locxyz[Z] = 0.0;

  /*
   * Create the constraint lines and modify them back to 
   * the original space.
   */

  for (i=0; i<3; i++)
    xpt[i] += locxyz[i];
  OM_BLOCK_MOVE (xpt, lns[HORIZONTAL].point2, sizeof (IGRpoint));

  for (i=0; i<3; i++)
    ypt[i] += locxyz[i];
  OM_BLOCK_MOVE (ypt, lns[VERTICAL].point2, sizeof (IGRpoint));

  MAptsxform (&msg_loc, &one, frompln_mat, locxyz, locxyz);
  EMomerr_exit (msg_loc, ret_end);
  for (i=0; i<2; i++)
  {
    OM_BLOCK_MOVE (locxyz, lns[i].point1, sizeof (IGRpoint));
    MAptsxform (&msg_loc, &one, frompln_mat, lns[i].point2, lns[i].point2);
    EMomerr_exit (msg_loc, ret_end);
  }

  /*
   * Check for coincidence with existing constraint lines.
   */

  inx = 0;
  for (i=HORIZONTAL; i<=VERTICAL; i++)
  {
    proceed = FALSE;
    if (constr_type == HORVERCONSTR_STATE || 
        (i == HORIZONTAL && constr_type == HORCONSTR_STATE) ||
        (i == VERTICAL && constr_type == VERCONSTR_STATE))
    {
      proceed = TRUE;
      for (j=0; j<numexistlines; j++)
      {
        if (EFequal_constr_lines (&existlines[j], &lns[i]))
        {
          proceed = FALSE;
          break;
        }
      }
    }

    if (proceed)
    {
      OM_BLOCK_MOVE (lns[i].point1, lines[inx].point1, sizeof (IGRpoint));
      OM_BLOCK_MOVE (lns[i].point2, lines[inx].point2, sizeof (IGRpoint));
      inx++;
      (*numlines)++;
    }
  }

ret_end:
  if (!EMSerror (stat_OM & msg_loc))
    return (TRUE);
  else
    return (FALSE);
}



IGRboolean EFconstr_for_datapoint (curpt, objpt, obj, constr_type, env, 
                                   winpt, zvec,
                                   numexistlines, existlines,
                                   numlines, lines)
IGRdouble 	*curpt, *objpt;
struct GRid 	*obj;
IGRshort 	constr_type;
struct GRmd_env *env;
IGRdouble 	*winpt, *zvec;
IGRint 		numexistlines;
struct IGRline 	*existlines;
IGRint 		*numlines;
struct IGRline 	*lines;
{
  IGRboolean proceed;
  IGRshort idmattyp, topln_mattyp, frompln_mattyp, cvmattyp, dum1, dum2;
  IGRshort four = 4;
  IGRint i, j, inx;
  long   one = 1, two = 2, stat_OM, msg_loc;
  IGRdouble *pars, *intpars, *pts, *pt, dumd;
  IGRpoint loccurpt, locobjpt[1], pts3[1][2], lnpts[2][2];
  IGRvector vec;
  IGRmatrix idmat, topln_mat, frompln_mat, cvmat;
  struct IGRbsp_curve *cv;
  struct IGRline lns[2];
  extern IGRboolean EFequal_constr_lines();
  extern void EMidmatrix(), EMtoplnxform();

  stat_OM = OM_S_SUCCESS;
  msg_loc = EMS_S_Success;

  *numlines = 0;

  pars = NULL;
  intpars = NULL;
  cv = NULL;

  for (i=0; i<2; i++)
  {
    lns[i].point1 = lnpts[i][0];
    lns[i].point2 = lnpts[i][1];
  }

  EMidmatrix (&msg_loc, &idmattyp, idmat);
  EMtoplnxform (&msg_loc, winpt, zvec, &idmattyp, idmat,
                &topln_mattyp, topln_mat, &frompln_mattyp, frompln_mat, NULL);
  EMomerr_exit (msg_loc, ret_end);

  MAmulmx (&msg_loc, &four, &four, &four, topln_mat, env->md_env.matrix,
           cvmat);
  EMomerr_exit (msg_loc, ret_end);

  MAtypemx (&msg_loc, cvmat, &cvmattyp);
  EMomerr_exit (msg_loc, ret_end);

  stat_OM = EMgetvggeom (&msg_loc, &cvmattyp, cvmat, obj, &cv, NULL);
  EMomerr_exit (stat_OM & msg_loc, ret_end);
  for (i=0, j=2; i<cv->num_poles; i++, j+=3)
    cv->poles[j] = 0.0;
  cv->planar = TRUE;


  MAptsxform (&msg_loc, &one, topln_mat, objpt, locobjpt[0]);
  EMomerr_exit (msg_loc, ret_end);
  locobjpt[0][Z] = 0.0;

  BSmdistptcv (cv, locobjpt[0], &dum1, &dum2, &pars, &dumd, &intpars, &msg_loc);
  EMerr_hndlr (msg_loc != BSSUCC, msg_loc, EMS_E_Fail, ret_end);

  BScveval (cv, pars[FIRST], 0, locobjpt, &msg_loc);
  EMerr_hndlr (msg_loc != BSSUCC, msg_loc, EMS_E_Fail, ret_end);

  if (constr_type == NORCONSTR_STATE || constr_type == PARCONSTR_STATE)
  {
    MAptsxform (&msg_loc, &one, topln_mat, curpt, loccurpt);
    EMomerr_exit (msg_loc, ret_end);
    loccurpt[Z] = 0.0;
 
    OM_BLOCK_MOVE (loccurpt, lns[FIRST].point1, sizeof (IGRpoint));
  }
  else
  {
    if (constr_type == COLORTHCONSTR_STATE || constr_type == COLLCONSTR_STATE)
      OM_BLOCK_MOVE (locobjpt[0], lns[COLLINEAR].point1, sizeof (IGRpoint));
    if (constr_type == COLORTHCONSTR_STATE || constr_type == ORTHOCONSTR_STATE)
      OM_BLOCK_MOVE (locobjpt[0], lns[ORTHOGONAL].point1, sizeof (IGRpoint));
  }

  BScvarrevt (cv, pars, 1, 10.0, pts3, &msg_loc);
  EMerr_hndlr (msg_loc != BSSUCC, msg_loc, EMS_E_Fail, ret_end);

  BSmkvec (&msg_loc, vec, pts3[0][1], pts3[0][0]);
  EMerr_hndlr (msg_loc != BSSUCC, msg_loc, EMS_E_Fail, ret_end);

  if (constr_type == PARCONSTR_STATE)
  {
    pt = lns[FIRST].point2;
    for (i=0; i<3; i++)
      pt[i] = loccurpt[i] + vec[i];
  }
  else if (constr_type == NORCONSTR_STATE)
  {
    pt = lns[FIRST].point2;
    pt[X] = loccurpt[X] - vec[Y];
    pt[Y] = loccurpt[Y] + vec[X];
    pt[Z] = 0.0;
  }

  if (constr_type == COLORTHCONSTR_STATE || constr_type == COLLCONSTR_STATE)
  {
    pt = lns[COLLINEAR].point2;
    OM_BLOCK_MOVE (pts3[0][1], pt, sizeof (IGRpoint));
  }
  if (constr_type == COLORTHCONSTR_STATE || constr_type == ORTHOCONSTR_STATE)
  {
    pt = lns[ORTHOGONAL].point2;
    pt[X] = locobjpt[0][X] - vec[Y]; 
    pt[Y] = locobjpt[0][Y] + vec[X];
    pt[Z] = 0.0;
  }

  if (constr_type != ORTHOCONSTR_STATE)
  {
    pts = lns[FIRST].point1;
    MAptsxform (&msg_loc, &two, frompln_mat, pts, pts);
    EMomerr_exit (msg_loc, ret_end);
  }
  if (constr_type == COLORTHCONSTR_STATE || constr_type == ORTHOCONSTR_STATE)
  {
    pts = lns[SECOND].point1;
    MAptsxform (&msg_loc, &two, frompln_mat, pts, pts);
    EMomerr_exit (msg_loc, ret_end);
  }

  if (constr_type == COLLCONSTR_STATE || constr_type == ORTHOCONSTR_STATE ||
      constr_type == COLORTHCONSTR_STATE)
  {
    inx = 0;
    for (i=COLLINEAR; i<=ORTHOGONAL; i++)
    {
      proceed = FALSE;
      if (constr_type == COLORTHCONSTR_STATE || 
          (i == COLLINEAR && constr_type == COLLCONSTR_STATE) ||
          (i == ORTHOGONAL && constr_type == ORTHOCONSTR_STATE))
      {
        proceed = TRUE;
        for (j=0; j<numexistlines; j++)
        {
          if (EFequal_constr_lines (&existlines[j], &lns[i]))
          {
            proceed = FALSE;
            break;
          }
        }
      }

      if (proceed)
      {
        OM_BLOCK_MOVE (lns[i].point1, lines[inx].point1, sizeof (IGRpoint));
        OM_BLOCK_MOVE (lns[i].point2, lines[inx].point2, sizeof (IGRpoint));
        inx++;
        (*numlines)++;
      }
    }
  }
  else
  {
    OM_BLOCK_MOVE (lns[FIRST].point1, lines[FIRST].point1, sizeof (IGRpoint));
    OM_BLOCK_MOVE (lns[FIRST].point2, lines[FIRST].point2, sizeof (IGRpoint));
    (*numlines)++;
  }

ret_end:
  if (pars)
    om$dealloc (ptr = pars);
  if (intpars)
    om$dealloc (ptr = intpars);
  if (cv)
    om$dealloc (ptr = cv);

  if (!EMSerror (stat_OM & msg_loc))
    return (TRUE);
  else
    return (FALSE);
}


IGRboolean EFdisp_inttol_constr (num, lines, disp, env, 
                                 override_color, override_style, dispmode)
IGRint num;
struct IGRline *lines;
struct IGRdisplay *disp;
struct GRmd_env *env;
IGRshort override_color;
IGRint override_style;
enum GRdpmode dispmode;
{
  IGRboolean stat_func;
  IGRint i, j;
  IGRlong msg_loc, stat_OM;
  IGRdouble delta;
  IGRpoint pts2[2];
  IGRvector lnvec;
  struct IGRdisplay loc_disp;
  struct IGRline *line;
  extern IGRlong ECdisplayPointSetByBuffer0();

  stat_func = TRUE;

  OM_BLOCK_MOVE (disp, &loc_disp, sizeof (struct IGRdisplay));
  loc_disp.color = override_color;
  loc_disp.style = override_style;

  for (i=0; i<num; i++)
  {
    line = &lines[i];
    for (j=0; j<3; j++)
    {
      lnvec[j] = line->point2[j] - line->point1[j];
      delta = lnvec[j] * MAX_LEN;
      pts2[FIRST][j] = line->point1[j] - delta;
      pts2[SECOND][j] = line->point1[j] + delta;
    }
    stat_OM = ECdisplayPointSetByBuffer0 (&msg_loc, loc_disp, *env,
               NULL_OBJID, 2, pts2, dispmode, IGRPY);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_func, FALSE,
     ret_end);
  }

ret_end:
  return (stat_func);
}


IGRboolean EFobtain_tangent (compinx, compobj, 
                             firstobj, firstpt, firsttan,
                             fileos, env,
                             endobj, endpt, endtan)
IGRint compinx;
GRobjid compobj, firstobj;
IGRdouble *firstpt, *firsttan;
GRspacenum fileos;
struct GRmd_env *env;
GRobjid *endobj;
IGRpoint endpt, endtan;
{
  IGRshort i;
  IGRlong stat_OM, msg_loc;
  GRobjid eleobj;
  GRspacenum dumos;
  IGRdouble par;
  IGRpoint pts2[1][2];
  struct IGRbsp_curve *elecv;
  OM_S_CHANSELECT chan_to_comps;

  stat_OM = OM_S_SUCCESS;
  msg_loc = EMS_S_Success;

  if (compinx == FIRST)
  {
    if (endobj)
      *endobj = NULL_OBJID;
    if (endpt && firstpt)
      OM_BLOCK_MOVE (firstpt, endpt, sizeof (IGRpoint));
    if (endtan && firsttan)
      OM_BLOCK_MOVE (firsttan, endtan, sizeof (IGRvector));
    goto ret_end;
  }

  EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);

  if (compinx > SECOND)
  {
    stat_OM = om$get_objid_at_index (osnum = fileos, objid = compobj,
               p_chanselect = &chan_to_comps, index = compinx-1,
               objidaddr = &eleobj, osnumaddr = &dumos);
    EMomerr_exit (stat_OM, ret_end);
  }
  else
    eleobj = firstobj;

  if (endobj)
    *endobj = eleobj;

  stat_OM = om$send (msg = message GRvg.GRgenabsg (&msg_loc,
             &env->md_env.matrix_type, env->md_env.matrix,
             (IGRchar **) &elecv), targetid = eleobj, targetos = fileos, 
             senderid = NULL_OBJID);
  EMomerr_exit (stat_OM, ret_end);
  EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, ret_end);

  par = 1.0;
  BScvarrevt (elecv, &par, 1, 10.0, pts2, &msg_loc);
  EMerr_hndlr (msg_loc != BSSUCC, stat_OM, OM_E_ABORT, ret_end);
  if (endpt)
    OM_BLOCK_MOVE (pts2[0][0], endpt, sizeof (IGRpoint));
  if (endtan)
  {
    OM_BLOCK_MOVE (pts2[0][1], endtan, sizeof (IGRpoint));
    for (i=0; i<3; i++)
      endtan[i] -= pts2[0][0][i];
  }

ret_end:
  if (EMSerror (stat_OM))
    return (FALSE);
  else
    return (TRUE);
}


IGRboolean EFis_tangent (prev_ptinfo, ptinfo)
struct SKcnstr_ptinfo *prev_ptinfo, *ptinfo;
{
  IGRboolean tangent;
  IGRshort prev_pttyp, pttyp;

  tangent = FALSE;

  if (prev_ptinfo)
  {
    prev_pttyp = prev_ptinfo->pttype[FIRST];
    pttyp = ptinfo->pttype[FIRST];

    if (prev_ptinfo->geomtype & SK_ARC && ptinfo->geomtype & SK_ARC)
    {
      if (pttyp == PT_COLL ||
          (prev_pttyp == PT_HORIZ && pttyp == PT_HORIZ) ||
          (prev_pttyp == PT_VERT && pttyp == PT_VERT))
        tangent = TRUE;
    }
    else
    {
      if (pttyp == PT_ORTHO ||
          (prev_pttyp == PT_HORIZ && pttyp == PT_VERT) ||
          (prev_pttyp == PT_VERT && pttyp == PT_HORIZ))
        tangent = TRUE;
    }
  }

  return (tangent);
}

/*

Name
  EFshortcut_check

Abstract
  This routine checks if the user types in a valid shortcut.
  
Synopsis
  struct GRevent  *event  - OUT - event that occurred.
  char *valid_shortcuts   - IN  - a character string enumerating all the possible
                                  shortcuts that should be checked.
  
Description
  
Return Value
  TRUE if a valid shortcut was typed.
  FALSE otherwise.
  
Notes
  Only character based events are explored futher.  All other events are put back
  on the software queue.

  No case differentiation is made.  All shortcuts are given in lowercase in the
  string valid_shortcuts (see ECdrawexec.I).
  
  Someday this functionality can be part of the ems$getevent filter so that other
  commands can also have shortcuts.
  
Index

Keywords

History
  09/13/93 : Rajiv Agrawal : extracted the code out of the execute method for
                             better maintainablity.
  02/14/94 : Shridar : Changed the WL calls for adding a <CR> to the journal.
 */

IGRboolean EFshortcut_check (struct GRevent *event, char *valid_shortcuts)
{
  int		stat_OM;
  long 		count, msg_loc;
  IGRboolean 	shortcut = FALSE;
  char 		buffer[1024];
  char          key_buffer[1];
#ifdef X11
  XEvent        xevent;
  int           total, num_of_win;
  long          error, byte;
  struct GRid   win_obj[40];
  struct var_list var_arr[2];
  WLuint32      lwin_no,  context_no;
  struct WLnative_info native_info;
#endif
  extern void   GRput_keybuff();
  extern int    EX_translate_funckey1();
    
  /*
   * wfi expects a buffer of size 1024.
   */
  
  count = 1024;
  ex$wait_for_input (response = &event->response, 
                     buffer = buffer,
                     mode = EX_ALL_CHAR_MODE, 
                     byte = (int *)&count);
  if (event->response == EX_CHAR)
  {
    if ( strchr(valid_shortcuts, tolower(buffer[0])) )
    {
      event->response = EX_STRING;
      event->event.keyin[0] = buffer[0];
      event->event.keyin[1] = '\0'; 
      shortcut = TRUE;
      /*
       * record the <CR> into the journal file.
       */
#if defined( X11 )
      xevent.type = KeyPress;
      xevent.xkey.state = 0;

      /* construct a hardware window that covers the entire screen */
      dp$get_gragad_id(msg = &msg_loc,
                       name = "*",
                       array_size = 40,
                       total_num = &total,
                       numberofids = &num_of_win,
                       found_GRids = win_obj,
                       type_gragad = (ALL_GG_CLASSES | GG_WIN_ON) );
      var_arr[0].var = WIN_NO;
      var_arr[0].var_ptr = (char *) &lwin_no;
      var_arr[0].num_bytes = sizeof (long);
      var_arr[0].bytes_returned = &byte;
      var_arr[1].var = END_PARAM;


      dp$inq_set_gragad(msg = &msg_loc,
                        osnum = win_obj[0].osnum,
                        gragad_objid = win_obj[0].objid,
                        which_error = &error,
                        var_list = var_arr);
      WLget_window_base_context( lwin_no,  &context_no );
      WLget_native_info( lwin_no, context_no, &native_info );

      xevent.xkey.keycode = XKeysymToKeycode (native_info.display,
                                  XK_Return);  /* carriage return (96) */
      xevent.xbutton.x = 1;   /* no of bytes to be written to the
                                 journal file */

      xevent.xany.window = native_info.base_win;

      JNL_record_next_event(&xevent, 1);

#else
      count = 1;
      key_buffer[0] = 0xd;
      JNL_record_event ( KEYBOARD_EVENT );
      JNL_record_input ( 1, (char *)&count );
      JNL_record_input ( 1, key_buffer );
#endif
    }
    else if (buffer[0] == '\374')
    {
      /*
       * membrane key was hit (e.g. Expand for Status form)
       */
      EX_translate_funckey1((short) buffer[1], NULL, EX_ALL_CHAR_MODE);
    }
    else if (buffer[0] == '\33')
    {
      /*
       * Escape key was hit.
       */
      GRput_keybuff(buffer);
      UI_echo("<esc>");
    }
    else if (buffer[0] == '=')
    {
      /* don't do anything ... an expression is on its way */
    }
    else if (buffer [0] == '\r')
    {
      /*
       * an empty <CR> -> back to dynamics
       */
      event->response = EX_STRING;
      event->event.keyin[0] = buffer [0];
      event->event.keyin[1] = '\0'; 
      shortcut = TRUE;
    }
    else
    {
      /*
       * Some other unknown character ... put it back in the keyboard buffer.
       * According to Shelley Heard this is a nonstandard technique.
       * Also unwrite the keyin from the PPL file (RAP).
       */
      OM_S_OBJID    listner_id;

      GRput_keybuff((char *) buffer);
      
      stat_OM = ex$get_objid_from_NOD(
                                      NODname = NOD_NAME,                /* "RAPnod" */
                                      objname = LISTENER_NAME,           /* "RAPlistener" */
                                      pobjid = &listner_id,
                                      modid = OM_GO_TransOS_0,
                                      mod_osnum = OM_Gw_TransOSnum_0);
       if (stat_OM == OM_S_SUCCESS)             /* RAP is on */
       {
         stat_OM = om$send(
                            msg = message RAPinlisnr.remove_last_command(),
                            targetid = listner_id,
                            targetos = OM_Gw_TransOSnum_0,
                            senderid = NULL_OBJID);
       }
    }
  }
  else
  {
    ex$putque (msg = &msg_loc, response = &event->response,
               byte = &count, buffer = buffer);
  }

  return shortcut;
}

/*

Name
  ECrecord_last_point

Abstract
  This function records the current cursor position in the journal and RAP file.
  
Synopsis

Description
  This function is needed to store the current cursor position in a journal file
  and a RAP file.  When a EX_VALUE or EX_STRING type of event occurs, the journal
  file does not record the cursor position. That position is used to make 
  decisions on the initial arc direction and getting the correct point in case
  a relative distance was given.
  
Return Value

Notes

Index

Keywords

History
  02/06/92 : rlw : original creation but part of the ECdraw execute method.
  10/08/93 : Rajiv Agrawal : created a function from embedded code in ECdrawexec.I
 */

EFrecord_last_point(IGRpoint lastpt, struct GRid *wingrid, 
                    int *response, char *response_data)
{
   char          string[80];
   int           type, num_bytes, *lastpt_int;
   int           recording;
   int           tmp_response, num_char;
   long          sts;
   double        tmp_response_data[EX_RESPONSE_DATA_SIZE / 8 + 1];
   OM_S_OBJID    listner_id;
   struct EX_button button;
   extern int JNL_journal(), JNL_record_info_event();
   
  /*
   * If we are creating a journal file then we need to write
   * out the lastpt since we used it in interpreting the keyin.
   *
   */
   recording = JNL_journal();
   if (recording)
   {
     lastpt_int = (int *) &lastpt[0];
     sprintf(string, "%s %x %x %x %x %x %x",
         "Sketch_Point",
         lastpt_int[0], lastpt_int[1], lastpt_int[2],
         lastpt_int[3], lastpt_int[4], lastpt_int[5]);
     num_bytes = strlen(string) + 1;   /* Want it NULL terminated */
     type = JNL_CHAR;
     JNL_record_info_event(type, num_bytes, string);
    }

  /*
   * If we are recording a PPL file (RAP) then we need to
   * unwrite this keyin, execute a place tentative point command
   * with our dynamics point, and reexecute the keyin.  This will
   * allow the playback to function properly since it will take
   * the keyin w.r.t. the tentative point.
   */

  sts = ex$get_objid_from_NOD(
                              NODname = NOD_NAME,                /* "RAPnod" */
                              objname = LISTENER_NAME,           /* "RAPlistener" */
                              pobjid = &listner_id,
                              modid = OM_GO_TransOS_0,
                              mod_osnum = OM_Gw_TransOSnum_0);
  if (sts == OM_S_SUCCESS)             /* RAP is on */
  {
    sts = om$send( msg = message RAPinlisnr.remove_last_command(),
                   targetid = listner_id,
                   targetos = OM_Gw_TransOSnum_0,
                   senderid = NULL_OBJID);
    strcpy((char *)tmp_response_data, "GRPTnPn");
    num_char = strlen((char *)tmp_response_data);
    tmp_response = EX_CMD_KEY;
    sts = om$send( msg = message RAPinlisnr.listen(
                         &tmp_response, (char *) tmp_response_data, &num_char),
                   targetid = listner_id,
                   targetos = OM_Gw_TransOSnum_0,
                   senderid = NULL_OBJID);
    button.x = lastpt[0];
    button.y = lastpt[1];
    button.z = lastpt[2];
    button.objid = wingrid->objid;
    button.osnum = wingrid->osnum;
    num_char = sizeof(struct EX_button);
    OM_BLOCK_MOVE(&button, tmp_response_data, num_char);
    tmp_response = EX_DATA;
    sts = om$send( msg = message RAPinlisnr.listen(
                         &tmp_response, (char *) tmp_response_data, &num_char),
                   targetid = listner_id,
                   targetos = OM_Gw_TransOSnum_0,
                   senderid = NULL_OBJID);
    num_char = strlen(response_data);
    sts = om$send( msg = message RAPinlisnr.listen(
                         response, response_data, &num_char),
                   targetid = listner_id,
                   targetos = OM_Gw_TransOSnum_0,
                   senderid = NULL_OBJID);
  }
  
  return OM_S_SUCCESS;
}

end implementation ECdraw;
