#include <stdio.h>
#include <memory.h>
#include "EMS.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "msdef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "igetypedef.h"
#include "dpstruct.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "exdef.h"
#include "ex.h"
#include "exmacros.h"
#include "igrdef.h"
#include "dpmacros.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "griomacros.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "EMSdraw.h"
#include "journal.h"
#include "dpgraphics.h"
#include "msmacros.h"
#include "SSdef.h"
#include "SSmacros.h"

#include "bserr.h"
#include "bsprepcarc.h"
#include "bsalloccv.h"
#include "bsfreecv.h"
#include "bsmdstptcv.h"
#include "bsprepcircp.h"
#include "bsprepcarc.h"
#include "bslldist.h"
#include "bscrossp.h"
#include "bsmkvec.h"
#include "bsnorvec.h"
#include "bscvcv_int.h"
#include "bsdistptpts.h"
#include "bsmalloc.h"

#include "ma.h"
#include "maang3pt.h"
#include "maptlnpro.h"
#include "ma2lnise.h"
#include "maptsxfor.h"
#include "marptsxfo.h"
#include "mabccopy.h"

#define MAX_LEN	              	 1e5

#define MAX_DISPLAY_BUFFS        5*2
#define MAX_INTTOLDISP_BUFFS     2
#define MAX_TOLLINE_CONSTR       5

#define STATIC_INTTOLLINE_CONSTR 15

static IGRint dyngeom();

struct modbuff_info
{
  IGRdouble 		tol;
  IGRdouble 		tolsq;

  IGRint 		num_tol_constr;
  IGRboolean 		*active_tol_constr;
  struct IGRline 	*tol_constr;

  IGRdouble 		inttol;
  IGRdouble 		inttolsq;

  IGRint 		num_inttol_constr;
  IGRboolean 		*active_inttol_constr;
  struct IGRline 	*inttol_constr;
  struct IGRpolyline 	*inttol_py;

  IGRshort 		constr_geom_type;
  struct IGRbsp_curve 	*constrcv;       
                                         
  struct IGRline 	constrline;
  struct IGRbsp_curve 	*twopolecv;

  IGRint 		oldweights[MAX_DISPLAY_BUFFS];

  IGRdouble 		*copymat;
  IGRint 		num_display_geom;
  struct IGRdisplay 	*display_att;
  struct EMSdyngeomselect *display_geom;
  struct IGRpolyline 	*pys;
  struct IGRbsp_curve 	**cvs;

  struct IGRpolyline 	*inttol_disppy;

  struct DPele_header 	dpheaders[MAX_DISPLAY_BUFFS+MAX_INTTOLDISP_BUFFS];

  IGRboolean 		on_constr;
  IGRchar 		*prompt, *promptc;

  IGRint 		tol_constr_inx;
  IGRint 		inttol_constr_inx[2];
  IGRboolean 		is_lastpt;
  IGRpoint 		lastpt;
  IGRboolean            smart_sketch_active;
};
/*

Name
  EMconstr_linarc_rbdisplay

Abstract
  Rubber-band display for the Place Profile/Linearc command.
  
Synopsis
  long 			*msg 			return code
  double 		tol			tolerance value for tolerance band activation
  int 			num_tol_constr      	number of tolerance bands
  IGRboolean 		active_tol_constr[]	flag to tell if the tol band is active or not
  struct IGRline 	tol_constr[]		definition of tolerance bands

  double 		inttol			intersection tolerance value
  int 			num_inttol_constr	no. of intersection tolerance contraints
  IGRboolean 		active_inttol_constr[]  which intersection constraints are active ?
  struct IGRline 	inttol_constr[]		definition of intersection bands

  short 		constr_geom_type	type of constraining geometry
  struct IGRbsp_curve 	*constr_geom		constraining geometry

  IGRint 		num_display_geom	number of dynamic geoms
  struct IGRdisplay 	display_att[]		display attrs of the dynamic geoms
  struct EMSdyngeomselect display_geom[]	description of the dynamic geoms

  IGRdouble 		*copymat		matrix used in symmetry mode.
  
  char 			*prompt			prompt when the constraint is not locked
  char			*promptc		prompt when the constraint is locked.

  int 			*tol_constr_inx		which tolerance band was hit.	(OUT)
  int 			inttol_constr_inx[2]	which intersection bands were hit. (OUT)

  IGRboolean 		*is_lastpt              always returned as TRUE??? (OUT)
  IGRpoint 		lastpt			lastpt from dynamics (OUT)
  IGRboolean		smart_sketch_active	whether smart sketch is on/off (IN).

Description

Return Value

Notes

Index

Keywords

History
  06/18/93 : Rajiv Agrawal : Added documentation and cleanup.
  08/04/93 : Rajiv Agrawal : Tangent (2-pt) arc functionality added.
  09/28/93 : Rajiv Agrawal : Added BS and MA prototypes.
  02/17/94 : Rajiv Agrawal : Modify the response data to put the new button value on the 
                             queue after peeking since we might have modified the datapoint. 
                             Happens only during journaling. (TR119417282).
 */

void EMconstr_linarc_rbdisplay (msg, 
                                tol,
                                num_tol_constr, active_tol_constr, tol_constr,
                                inttol,
                                num_inttol_constr, active_inttol_constr, inttol_constr,
                                constr_geom_type, constr_geom,
                                num_display_geom, display_att, display_geom,
                                copymat,
                                prompt, promptc,
                                tol_constr_inx, inttol_constr_inx,
                                is_lastpt, lastpt,
                                smart_sketch_active)
IGRlong 		*msg;
IGRdouble 		tol;
IGRint 			num_tol_constr;
IGRboolean 		active_tol_constr[];
struct IGRline 		tol_constr[];
IGRdouble 		inttol;
IGRint 			num_inttol_constr;
IGRboolean 		active_inttol_constr[];
struct IGRline 		inttol_constr[];
IGRshort 		constr_geom_type;
struct IGRbsp_curve 	*constr_geom;	
IGRint 			num_display_geom;
struct IGRdisplay 	display_att[];	
struct EMSdyngeomselect display_geom[];	
IGRdouble 		*copymat;
IGRchar 		*prompt, *promptc;
IGRint 			*tol_constr_inx;
IGRint 			inttol_constr_inx[2];
IGRboolean 		*is_lastpt;
IGRpoint 		lastpt;
IGRboolean		smart_sketch_active;
{
  IGRint 		i, j, dum, inxlim, pyinx, cvinx, buffinx;
  IGRint 		num_loc_display_geom;
  IGRlong 		msg_loc, one=1;
  IGRdouble 		*ptr1, *ptr2;
  IGRpoint 		pts[MAX_DISPLAY_BUFFS+MAX_INTTOLDISP_BUFFS][2];
  IGRpoint 		inttolpts_mem[STATIC_INTTOLLINE_CONSTR][2], *inttolpts;
  IGRpoint 		pts2[2];
  IGRvector 		linevec;
  struct IGRline 	*ln;
  struct IGRpolyline 	*inttolpys, *intdisppys;
  struct IGRpolyline 	pys[MAX_DISPLAY_BUFFS+MAX_INTTOLDISP_BUFFS];
  struct IGRpolyline 	inttolpys_mem[STATIC_INTTOLLINE_CONSTR];
  struct IGRpolyline 	py2pts;
  struct IGRbsp_curve 	*cvs[MAX_DISPLAY_BUFFS], *twopolecv;
  struct modbuff_info 	buffinfo;
  struct IGRespy 	espy;
  struct IGResbc 	esbc;
  struct IGRdisplay 	inttol_display_att;
  enum EMSdyngeomtype 	dyngeomtype;

  /*
   * Initialize output variables
   */

  *msg = EMS_S_Success;
  *tol_constr_inx = -1;
  if (inttol_constr_inx)
    for (i=0; i<2; i++)
      inttol_constr_inx[i] = -1;
  *is_lastpt = FALSE;

  /*
   * Initialize internal variables
   */

  for (i=0; i<MAX_DISPLAY_BUFFS; i++)
    cvs[i] = NULL;
  twopolecv = NULL;
  inttolpys = NULL;
  inttolpts = NULL;

  num_loc_display_geom = num_display_geom + (copymat ? num_display_geom : 0);
  EMerr_hndlr (num_loc_display_geom > MAX_DISPLAY_BUFFS ||
               num_tol_constr > MAX_TOLLINE_CONSTR,
   *msg, EMS_E_InvalidArg, ret_end);

  espy.is_closed = FALSE;
  esbc.is_polydis = FALSE;
  esbc.is_curvedis = TRUE;

  dum = sizeof (struct IGRdisplay);
  gr$get_active_display (msg = &msg_loc, sizbuf = &dum,
                         buffer = &inttol_display_att, nret = &dum);
  inttol_display_att.weight = 2;
  inttol_display_att.style = 2;

  inxlim = num_loc_display_geom + MAX_INTTOLDISP_BUFFS;
  for (i=0; i<inxlim; i++)
  {
    pys[i].num_points = 2;
    pys[i].points = (IGRdouble *)pts[i];
  }
  intdisppys = &pys[num_loc_display_geom];
  
  /*
   * Allocate space for dynamic curves
   */
  cvinx = 0;
  for (i = 0; i < num_display_geom; i++)
  {
    if (display_geom[i].dyngeomtype == EMSdyncircle ||
        display_geom[i].dyngeomtype == EMSdyncirarc ||
        display_geom[i].dyngeomtype == EMSdyntanarc)
    {
      BSalloccv (4, 7, TRUE, NULL, &cvs[cvinx++], &msg_loc);
      EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_NoDynamicMemory, ret_end);
      if (copymat)
      {
        BSalloccv (4, 7, TRUE, NULL, &cvs[cvinx++], &msg_loc);
        EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_NoDynamicMemory, ret_end);
      }
    }
  }      

  if (num_inttol_constr > STATIC_INTTOLLINE_CONSTR)
  {
    inttolpys = (struct IGRpolyline *)om$malloc (size = num_inttol_constr * 
                  sizeof (struct IGRpolyline));
    inttolpts = (IGRpoint *)om$malloc (size = num_inttol_constr * 2 * sizeof (IGRpoint));
  }
  else
  {
    inttolpys = inttolpys_mem;
    inttolpts = (IGRpoint *)inttolpts_mem;
  }
  EMerr_hndlr (!inttolpys || !inttolpts, *msg, EMS_E_NoDynamicMemory, ret_end);

  for (i=0, j=0; i<num_inttol_constr; i++, j+=2)
  {
    inttolpys[i].num_points = 2;
    inttolpys[i].points = inttolpts[j];
  }

  /*
   * Put in the tolerance-band, line constraints. Also put in the other
   * tolerance-band constraints that can participate to contribute
   * towards intersection key-points.
   */

  buffinfo.smart_sketch_active = smart_sketch_active;
  buffinfo.tol = tol;
  buffinfo.tolsq = tol * tol;
  buffinfo.inttol = inttol;
  buffinfo.inttolsq = inttol * inttol;

  if (smart_sketch_active)
    buffinfo.num_tol_constr = 0;
  else
    buffinfo.num_tol_constr = num_tol_constr;
  buffinfo.active_tol_constr = active_tol_constr;
  buffinfo.tol_constr = tol_constr;

  if (smart_sketch_active)
    buffinfo.num_inttol_constr = 0;
  else
    buffinfo.num_inttol_constr = num_inttol_constr;
  buffinfo.active_inttol_constr = active_inttol_constr;
  buffinfo.inttol_constr = inttol_constr;

  /*
   * If the rubber banding has to be completely constrained (always constrained
   * to lie on a geometry) fill in this geometry.
   */

  if (constr_geom)
  {
    if (constr_geom_type == EMSD_CIRCLE_ARC ||
        constr_geom_type == EMSD_BOUNDED_CURVE)
      buffinfo.constrcv = constr_geom;
    else
    {
      buffinfo.constrline.point1 = &constr_geom->poles[0];
      buffinfo.constrline.point2 = &constr_geom->poles[3];
      buffinfo.constrcv = constr_geom;
    }
    buffinfo.constr_geom_type = constr_geom_type;
 
    BSalloccv (2, 2, FALSE, NULL, &twopolecv, &msg_loc);
    EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_NoDynamicMemory, ret_end);
    pts2[0][X] = pts2[0][Y] = pts2[0][Z] = 0.0;
    OM_BLOCK_MOVE (pts2[0], pts2[1], sizeof (IGRpoint));
    py2pts.num_points = 2;
    py2pts.points = (IGRdouble *)pts2;
    EMcnvtpybsn (&msg_loc, 3, &py2pts, twopolecv);
    twopolecv->phy_closed = FALSE;
    buffinfo.twopolecv = twopolecv;
  }
  else
  {
    buffinfo.constr_geom_type = EMSD_NULL_GEOM;
    buffinfo.twopolecv = NULL;
  }

  /*
   * Plug in the logical geometry to be displayed. The real display geometry
   * is driven based on the data in these structures. If a copy of this
   * geometry is to be displayed with a given matrix transformation, then
   * initialize the matrix.
   */

  buffinfo.copymat = copymat;
  buffinfo.num_display_geom = num_display_geom;
  buffinfo.display_att = display_att;
  buffinfo.display_geom = display_geom;

  /*
   * Store the incoming weights for display in the information buffer
   * to be restored if they get changed at any point.
   */

  for (i = 0; i < num_display_geom; i++)
    buffinfo.oldweights[i] = display_att[i].weight;

  /*
   * Format the display buffers. Also format two additional buffers to
   * potentially display an intersection-tolerance band when it does get
   * hit. Also the set of polylines is constructed that correspond to the
   * intersection-tolerance band lines with extended lengths. These can
   * be moved into the display buffers when they get hit, thus initializing
   * the intersection-polyline display buffers. If a copy of the geometry
   * is to be displayed, then a copy buffer is initialized adjacent to
   * the original geometry buffer.
   */

  pyinx = 0;
  cvinx = 0;
  buffinx = 0;
  for (i = 0; i < num_display_geom; i++)
  {
    dyngeomtype = display_geom[i].dyngeomtype;
    if (dyngeomtype == EMSdynlineseg || dyngeomtype == EMSdynperpline)
    {
      for (j=0; j<(copymat?2:1); j++)
      {
        if (dyngeomtype == EMSdynlineseg)
          OM_BLOCK_MOVE (display_geom[i].dyngeom.lineseg.firstpt,
                         pys[pyinx].points, sizeof (IGRpoint));
        if (j==1)
          MAptsxform (&msg_loc, &one, copymat, pys[pyinx].points, pys[pyinx].points);

        dp$build_dis_buffer (buffer = &buffinfo.dpheaders[buffinx],
                             type = IGRPY, display_att = &display_att[i], 
                             ele_spec_att = &espy, geometry = &pys[pyinx]);

        buffinx++;
        pyinx++;
      }
    }
    else
    {
      for (j=0; j<(copymat?2:1); j++)
      {
        dp$build_dis_buffer (buffer = &buffinfo.dpheaders[buffinx],
                             type = IGRBC, display_att = &display_att[i], 
                             ele_spec_att = &esbc, geometry = cvs[cvinx]);

        buffinx++;
        cvinx++;
      }
    }
  }
  buffinfo.pys = pys;
  buffinfo.cvs = cvs;

  for (i=0; i<num_inttol_constr; i++)
  {
    ln = &inttol_constr[i];
    for (j=0; j<3; j++)
      linevec[j] = ln->point2[j] - ln->point1[j];
    ptr1 = inttolpys[i].points;
    ptr2 = &inttolpys[i].points[3];
    OM_BLOCK_MOVE (ln->point1, ptr1, sizeof (IGRpoint));
    OM_BLOCK_MOVE (ln->point1, ptr2, sizeof (IGRpoint));
    for (j=0; j<3; j++)
    {
      ptr1[j] += MAX_LEN * linevec[j];
      ptr2[j] -= MAX_LEN * linevec[j];
    }
  }
  buffinfo.inttol_py = inttolpys;

  for (i=0; i<MAX_INTTOLDISP_BUFFS; i++)
  {
    dp$build_dis_buffer (buffer = &buffinfo.dpheaders[buffinx], type = IGRPY,
                         display_att = &inttol_display_att, ele_spec_att = &espy,
                         geometry = &intdisppys[i]);
    buffinx++;
  }
  buffinfo.inttol_disppy = intdisppys;
 
  /*
   * Prompts that may be supplied (for on and off constraints) are
   * stored in the buffinfo. Initially, the point is recorded as being
   * off any constraint.
   */

  buffinfo.on_constr = FALSE;
  buffinfo.prompt = prompt;   
  buffinfo.promptc = promptc;

  /*
   * Invoke the dynamics function. Check if any tolerance band constraint
   * was hit. If so, return it's index.
   */

  buffinfo.tol_constr_inx = -1;
  for (i=0; i<2; i++)
    buffinfo.inttol_constr_inx[i] = -1;
  buffinfo.is_lastpt = FALSE;
  /*
   * Modified 01/31/92 : rlw
   *
   * The line/arc composite command depends on the dynamics function (dyngeom)
   * to snap to constraints.  As such when the data is replayed through either
   * RAP or journaling the snapping does not occur.  Herein lies the problem.
   * I have modified to code to detect this and to call the snapping logic
   * in cases where the input is already on the queue.  This should fix all
   * cases where data points are input.
   *
   * Modified 02/01/92 : rlw
   *
   * Support is now available for Resets in journaling and RAP.
   *
   * Modified 02/03/92 : rlw
   *
   * Support is now available for keyins in journaling.
   *
   * Modified 02/06/92 : rlw
   *
   * Support is now available for keyins in RAP.
   */
  {
    extern IGRint JNL_playback();
    IGRint        journaling, response, something_on_queue;

    journaling = JNL_playback();
    something_on_queue = ex$peek_event_queue(resp = &response);
    if (journaling || 
       (something_on_queue && 
        ((response == EX_DATA) || (response == EX_RJT_MOVEON) ||
         (response == EX_STRING))))
    {
      IGRlong   sts, response, sizeof_stuff, call_dyngeom = FALSE;
      IGRdouble response_data[EX_RESPONSE_DATA_SIZE / 8 + 1];
      struct    GRevent event;
      struct    EX_button curpt;
      /*
       * Get the event off of the queue
       */
      sts = co$getevent(msg = &msg_loc,
                        event_mask = -1,               /* Get anything */
                        nbytes = &sizeof_stuff,
                        response = &response,
                        response_data = response_data,
                        event = &event);
      if (! (1 & sts)) goto ret_end;
     
      /*
       * Put the event back on the queue.  In case of a datapt, it might have gotten
       * modified by reading a journal log for a smart sketch point.
       */
      if (journaling && response == EX_DATA) 
        memcpy( response_data, &event.event.button, sizeof_stuff);

      sts = ex$putque ( msg = &msg_loc,
                        response = (int *)&response,
                        byte = &sizeof_stuff,
                        buffer = (char *)response_data);
      if (! (1 & sts)) goto ret_end;
     
      /*
       * Modified 02/03/92 : rlw
       *
       * If we are journaling and the user keyed in a value then
       * we need to find out the last coordinates of the cursor
       * when the profile was originally placed.  This is done by
       * reading, if present, and information event from the journal
       * file.  If we find the right event then it will contain the
       * coordinates of the point that this keyin is to be taken w.r.t..
       * 
       * Modified 03/12/92 : rlw
       *
       * Modified to accomodate API differences in journaling on the Sun.
       */
      if (journaling && 
          ((event.response == EX_VALUE && event.subtype != GRst_DEFAULT ) ||
            (event.response == EX_STRING)))
      {
         char   string[JNL_MAX_CHAR], identifier[JNL_MAX_CHAR];
         int    event, type, num_bytes, *xyz_int;
         double xyz[3];
#ifdef X11
         XEvent xevent;
  
         JNL_echo_input(sizeof(XEvent), (char *)(&xevent));
         event = xevent.type;
         type = xevent.xkey.serial;
         num_bytes = xevent.xkey.x;
#else
         JNL_echo_input(4, (char *)&event);
         JNL_echo_input(4, (char *)&type);
         JNL_echo_input(4, (char *)&num_bytes);
#endif
         if (!((event == JNL_INFO_EVENT) && (type == JNL_CHAR)))
         {
           fprintf(stderr, "shortcut journaling mismatch %d %d\n", event, type);
           *msg = EMS_E_Fail;
           goto ret_end;
         }

         JNL_echo_input(num_bytes, (char *)string);
         sscanf(string, "%s", identifier);
         
         if (strcmp("Sketch_Point", identifier))
         {
           fprintf(stderr, "shortcut journaling mismatch, string = %s\n", string);
           *msg = EMS_E_Fail;
           goto ret_end;
         }
         xyz_int = (int *) &xyz[0];
         sscanf(string, "%s %x %x %x %x %x %x", identifier,
                &xyz_int[0], &xyz_int[1], &xyz_int[2],
                &xyz_int[3], &xyz_int[4], &xyz_int[5]);
         call_dyngeom = TRUE;
         curpt.x = xyz[0];
         curpt.y = xyz[1];
         curpt.z = xyz[2];
      }
      /*
       * If we have a point or reset then call the dynamics function to deposit
       * the coordinates when the input was given.
       */
      else if ((event.nbytes >= sizeof(struct EX_button)) &&   /* safety net */
           ((response == EX_DATA) || (response == EX_RJT_MOVEON)))
      {
         call_dyngeom = TRUE;
         curpt.x = event.event.button.x;
         curpt.y = event.event.button.y;
         curpt.z = event.event.button.z;
      }
      /*
       * Facts:
       *  o We got a number
       *  o We are not running a journal file.
       *  o We have the value before the user has seen the dynamics
       *
       * Possiblities:
       *  o The user is running interactive and has keyed in a value before
       *    seeing the dynamics to know what it means.  Unlikely though possible.
       *  o The user is running a PPL (RAP) file and it has the event on the
       *    queue.  Very likely.
       *
       * In either possible case, we will take the keyin w.r.t. the last point
       * that was input.  This should not hurt in the case of a fast interactive
       * user and will work when running RAP.  RAP will be OK because we recorded,
       * using the place tenative point command, the cursor location at the time
       * of keyin in the .u file.
       */
      else if (event.response == EX_VALUE)
      {
         IGRlong num_bytes;
  
         call_dyngeom = TRUE;
         sizeof_stuff = sizeof(struct EX_button);
         sts = gr$get_last_point(
           msg = &msg_loc,
           sizbuf = &sizeof_stuff,
           buffer = &curpt,
           nret = &num_bytes);
          if (! (1 & sts)) goto ret_end;
      }
      /*
       * Call the dynamics function such that the required snapping occurs
       */
      if (call_dyngeom)
      {
        IGRint num_buffs = 0;
        struct DPele_header *buffs = NULL;
 
        dyngeom(&buffinfo, &curpt,
                NULL, NULL, NULL,
                &buffs, &num_buffs,
                NULL, NULL, NULL, NULL, NULL, NULL);
      }
    }
    else
      dp$dynamics (dyn_fun = dyngeom, information = &buffinfo);
  }

  /*
   * Return output
   */
  *tol_constr_inx = buffinfo.tol_constr_inx;
  if (inttol_constr_inx)
    for (i=0; i<2; i++)
      inttol_constr_inx[i] = buffinfo.inttol_constr_inx[i];
  if (*is_lastpt = buffinfo.is_lastpt)
    OM_BLOCK_MOVE (buffinfo.lastpt, lastpt, sizeof (IGRpoint));

ret_end:
  for (i=0; i<MAX_DISPLAY_BUFFS; i++)
    if (cvs[i])
      BSfreecv (&msg_loc, cvs[i]);
  if (twopolecv)
    BSfreecv (&msg_loc, twopolecv);
  if (inttolpys && inttolpys != inttolpys_mem)
    om$dealloc (ptr = inttolpys);
  if (inttolpts && inttolpts != (IGRpoint *)inttolpts_mem)
    om$dealloc (ptr = inttolpts);
  return;
}

/*

Name
  dyngeom

Abstract
  Dynamics routine for Place Profile command.
    
Synopsis

Description

Return Value

Notes

Index

Keywords

History
  06/18/93 : Rajiv Agrawal : added documentation and cleanup.

 */

#argsused
static IGRint dyngeom (buffinfo, curpt, mtx, objs, num_objs, buffs, num_buffs,
                       dummy1, dummy2, dummy3, dummy4, dummy5, dummy6)
struct modbuff_info 	*buffinfo;
struct EX_button 	*curpt;
IGRdouble 		*mtx;
struct GRid 		**objs;
IGRint 			*num_objs;
struct DPele_header 	**buffs;
IGRint 			*num_buffs;
IGRchar 		*dummy1, *dummy2, *dummy3;
IGRchar 		**dummy4, **dummy5, **dummy6;
{
  IGRboolean 		found, intfound[2], cvcvint, do_mdist, parallel;
  IGRboolean 		*active_tol_constr, *active_inttol_constr;
  IGRshort 		constr_type;
  int 			i, j, inx, dum, pyinx, cvinx;
  int 			num_tol_constr, num_inttol_constr, num_display_geom;
  int 			numints, degrees_of_freedom;
  long 			msg_loc, numovs, one=1, two=2;
  double 		*newpt, *fixedpt, *norvec, *copymat, *pt, *pt1, *pt2;
  double 		par, mdistpar, otherpar, mdist;
  double 		inttolsq, tolsq;
  double 		*intpts, *par1, *par2, *ovpts, *ovpar1, *ovpar2, angles[3];
  IGRvector 		dumvec, fixvec;
  IGRpoint 		projpt, drawpt, tolpt, inttolpt, intpt, 
  			mdistpt, /* minimum distance point */
  			pts2[2];
  struct IGRpolyline 	*pys;
  struct IGRbsp_curve 	**cvs, *tcv, *cv;
  struct IGRline 	*ln, *ln1, *ln2, *tol_constr, *inttol_constr;
  struct EMSdynperpline *dynperpline;
  struct EMSdyncirarc 	*dyncirarc;
  struct EMSdyntanarc   *dyntanarc;
  struct EMSdyncircle 	*dyncircle;
  struct IGRpolyline 	py2pts;
  enum EMSdyngeomtype 	dyngeomtype;
  struct EMSdyngeomselect *dyngeomselect;
  
  /*
   * newpt is the location of the current cursor.  It will change if there
   * any constraints that get locked on.
   */
  newpt = &curpt->x;
  tolsq = buffinfo->tolsq;
  num_tol_constr = buffinfo->num_tol_constr;
  active_tol_constr = buffinfo->active_tol_constr;
  tol_constr = buffinfo->tol_constr;
  inttolsq = buffinfo->inttolsq;
  num_inttol_constr = buffinfo->num_inttol_constr;
  active_inttol_constr = buffinfo->active_inttol_constr;
  inttol_constr = buffinfo->inttol_constr;
  num_display_geom = buffinfo->num_display_geom;
  constr_type = buffinfo->constr_geom_type;
  copymat = buffinfo->copymat;

  cvcvint = FALSE;
  intpts = NULL;
  par1 = NULL;
  par2 = NULL;
  ovpts = NULL;
  ovpar1 = NULL;
  ovpar2 = NULL;

  degrees_of_freedom = 0;
  found = FALSE;
  buffinfo->tol_constr_inx = -1;
  for (i=0; i<2; i++)
  {
    intfound[i] = FALSE;
    buffinfo->inttol_constr_inx[i] = -1;
  }

  /*
   * CHECK #1 : Check if the newpoint is within tolerance of any of the
   *            tolerance bands.
   */

  for (i=0; i<num_tol_constr; i++)
  {
    if (active_tol_constr[i])
    {
      MAptlnproj (&msg_loc, newpt, &tol_constr[i], tolpt, &par);
      if (BSdistptpts (&msg_loc, newpt, tolpt) <= tolsq)
      {
        OM_BLOCK_MOVE (tolpt, newpt, sizeof (IGRpoint));
        buffinfo->tol_constr_inx = i;
        found = TRUE;
        degrees_of_freedom++;
        break;
      }
    }
  }
  
  /*
   * CHECK #2 : If there is a constraining geometry then apply that to the point.
   *            This is done by replacing the incoming new point by the minimum
   *            distance point. Doing this for an infinite line is wrong here;
   *            to be corrected later if anybody is using this. None as of 5/29/90.
   */

  if (constr_type == EMSD_CIRCLE_ARC)
  {
    BSmdstptcv (buffinfo->constrcv, newpt, &mdistpar, mdistpt, &mdist,
                &msg_loc);
    OM_BLOCK_MOVE (mdistpt, newpt, sizeof (IGRpoint));
    degrees_of_freedom++;
  }
  else if (constr_type == EMSD_INFI_LINE)
  {
    MAptlnproj (&msg_loc, newpt, &buffinfo->constrline, mdistpt, &par);
    OM_BLOCK_MOVE (mdistpt, newpt, sizeof (IGRpoint));
    degrees_of_freedom++;
  }

  /*
   * CHECK #3: If there are any intersection/other tolerance bands, check if the
   *           point comes close to any of these. If they do then check if this is
   *           possible intersection point (the point coming close to two tolerance
   *           bands including the tolerance band from above). If so move the
   *           newpt to the intersection. But if the point has zero degrees of freedom,
   *           then skip this intersection tolerance band check.
   */


  if (degrees_of_freedom < 2)
  {
    if (found)
      ln1 = &tol_constr[buffinfo->tol_constr_inx];

    for (i=0; i<2; i++)
    {
      for (j=0; j<num_inttol_constr; j++)
      {
        if ((active_inttol_constr ? active_inttol_constr[j] : TRUE) &&
            (i == 0 ? TRUE : inx != j))
        {
          MAptlnproj (&msg_loc, newpt, &inttol_constr[j], inttolpt, &par);
          if (BSdistptpts (&msg_loc, newpt, inttolpt) <= inttolsq)
          {
            pt = inttolpt;
            if (i == 0 ? found : intfound[0])
            {
              ln2 = &inttol_constr[j];
              MA2lnisect (&msg_loc, ln1, ln2, &buffinfo->inttol, intpt, &par,
                          &otherpar);
              if (msg_loc == MSSUCC)
                pt = intpt;
              else
                continue;
            }
  
            OM_BLOCK_MOVE (pt, newpt, sizeof (IGRpoint));
            inx = buffinfo->inttol_constr_inx[i] = j;
            intfound[i] = TRUE;
            degrees_of_freedom++;
            break;
          }
        }
      }

      if (!intfound[i] || found)
        break;
      else
        ln1 = &inttol_constr[buffinfo->inttol_constr_inx[0]];
    }
  }

  /*
   * If the point was on a constraining geometry and was found to be on 
   *   a) one intersection tolerance band 
   *          or 
   *   b) two intersection tolerance bands,
   * then the point is refined to be 
   *   a) the intersection between the constraining geometry and the tolerance band
   *          or 
   *   b) the minimum distance point from the intersection of the 
   *      tolerance bands to the constraining geometry.
   */

  if (constr_type != EMSD_NULL_GEOM)
  {
    cvcvint = intfound[0] && !intfound[1];
    do_mdist = intfound[0] && intfound[1];
  }
  else
  {
    cvcvint = FALSE;
    do_mdist = FALSE;
  }

  if (cvcvint)
  {
    ln = &inttol_constr[buffinfo->inttol_constr_inx[0]];
    tcv = buffinfo->twopolecv;
    pt1 = tcv->poles;
    pt2 = &tcv->poles[3];
    OM_BLOCK_MOVE (ln->point1, pt1, sizeof (IGRpoint));
    OM_BLOCK_MOVE (ln->point2, pt2, sizeof (IGRpoint));
    for (i=0; i<3; i++)
    {
      dumvec[i] = ln->point2[i] - ln->point1[i];
      pt1[i] += MAX_LEN * dumvec[i];
      pt2[i] -= MAX_LEN * dumvec[i];
    }
    BScvcv_int (&msg_loc, buffinfo->constrcv, tcv, 
                &numints, &intpts, &par1, &par2, &numovs, &ovpts, &ovpar1, &ovpar2);
    if (msg_loc == BSSUCC && numints)
    {
      do_mdist = FALSE;
      if (numints == 1 || BSdistptpts (&msg_loc, intpts, mdistpt) < 
                          BSdistptpts (&msg_loc, &intpts[3], mdistpt))
        OM_BLOCK_MOVE (intpts, newpt, sizeof (IGRpoint));
      else 
        OM_BLOCK_MOVE (&intpts[3], newpt, sizeof (IGRpoint));
    }
    else
      do_mdist = TRUE;
  }

  if (do_mdist)
  {
    if (constr_type == EMSD_CIRCLE_ARC)
    {
      BSmdstptcv (buffinfo->constrcv, newpt, &par, projpt, &mdist, &msg_loc);
      OM_BLOCK_MOVE (projpt, newpt, sizeof (IGRpoint));
    }
    else if (constr_type == EMSD_INFI_LINE)
      MAptlnproj (&msg_loc, newpt, &buffinfo->constrline, newpt, &par);
  }

  /*
   * END OF CONSTRAINTS CHECKING TO MODIFY THE CURRENT POINT.
   * Output this "newpt". It may potentially become the last point.
   */

  buffinfo->is_lastpt = TRUE;
  OM_BLOCK_MOVE (newpt, buffinfo->lastpt, sizeof (IGRpoint));

  /*
   * If a transition of state of the newpoint lying on a tolerance band
   * to off it (or vice versa) has occurred, some actions may be
   * required.
   */

  if (found ^ buffinfo->on_constr)
  {
    /*
     * If the newpoint is within a tolerance band, up the weight else
     * display in original weight. Do not up the weight if the point is
     * only within intersection-tolerance bands.
     */

    for (i=0; i<num_display_geom; i++)
      if (found)
        buffinfo->display_att[i].weight = buffinfo->oldweights[i] + 2;
      else
        buffinfo->display_att[i].weight = buffinfo->oldweights[i];

    /*
     * Prompts supplied are used. If the newpoint is within a tolerance
     * band, prompt with 'promptc' else with 'prompt'. 
     */

    if (found)
      ex$message(field = PROMPT_FIELD, justification = RIGHT_JUS,
                 in_buff = buffinfo->promptc)
    else
      ex$message(field = PROMPT_FIELD, justification = RIGHT_JUS,
                 in_buff = buffinfo->prompt); 

    /*
     * Toggle the record of the state of the new-point.
     */

    buffinfo->on_constr = !buffinfo->on_constr;
  }

  /*
   * Change the geometry in the display buffers according to this new
   * point. Also, add the display geometry into the last one or two
   * display buffers if intfound[0], intfound[1] is set.
   */

  pys = buffinfo->pys;
  cvs = buffinfo->cvs;
  pyinx = 0;
  cvinx = 0;
  for (inx=0; inx<num_display_geom; inx++)
  {
    dyngeomselect = &buffinfo->display_geom[inx];
    dyngeomtype = dyngeomselect->dyngeomtype;
    switch (dyngeomtype)
    {
      case EMSdynlineseg:
        OM_BLOCK_MOVE (newpt, &pys[pyinx].points[3], sizeof (IGRpoint));
        pyinx++;
        if (copymat)
        {
          pt1 = &pys[pyinx-1].points[3];
          pt2 = &pys[pyinx].points[3];
          MAptsxform (&msg_loc, &one, copymat, pt1, pt2);
          pyinx++;
        }
        break;

      case EMSdynperpline:
        dynperpline = &dyngeomselect->dyngeom.perpline;
        fixedpt = dynperpline->fixedpt;
        for (i=0; i<3; i++)
          fixvec[i] = newpt[i] - fixedpt[i];
        norvec = dynperpline->norvec;
        drawpt[X] = newpt[X] +
                     (norvec[Y] * fixvec[Z] - norvec[Z] * fixvec[Y]) * MAX_LEN;
        drawpt[Y] = newpt[Y] +
                     (norvec[Z] * fixvec[X] - norvec[X] * fixvec[Z]) * MAX_LEN;
        drawpt[Z] = newpt[Z] +
                     (norvec[X] * fixvec[Y] - norvec[Y] * fixvec[X]) * MAX_LEN;
        OM_BLOCK_MOVE (newpt, &pys[pyinx].points[0], sizeof (IGRpoint));
        OM_BLOCK_MOVE (drawpt, &pys[pyinx].points[3], sizeof (IGRpoint));
        pyinx++;
        if (copymat)
        {
          pt1 = pys[pyinx-1].points;
          pt2 = pys[pyinx].points;
          MAptsxform (&msg_loc, &two, copymat, pt1, pt2);
          pyinx++;
        }
        break;

      case EMSdyncircle:
        dyncircle = &dyngeomselect->dyngeom.circle;
        BSprepcircp (&msg_loc, newpt, dyncircle->circumpt, dyncircle->norvec,
                     cvs[cvinx], dumvec, &dum);
        if (msg_loc != BSSUCC)
        {
          py2pts.num_points = 2;
          py2pts.points = (IGRdouble *)pts2;
          OM_BLOCK_MOVE (dyncircle->circumpt, pts2[0], sizeof (IGRpoint));
          OM_BLOCK_MOVE (dyncircle->circumpt, pts2[1], sizeof (IGRpoint));
          EMcnvtpybsn (&msg_loc, 3, &py2pts, cvs[cvinx]);
        }
        cvinx++;
        if (copymat)
        {
          cv = cvs[cvinx-1];
          tcv = cvs[cvinx];
          MAbccopy (&msg_loc, cv, tcv);
          MArptsxform (&msg_loc, &cv->num_poles, &cv->rational, cv->weights,
                       copymat, cv->poles, tcv->poles);
          cvinx++;
        }
        break;

      case EMSdyncirarc:
        dyncirarc = &dyngeomselect->dyngeom.cirarc;
        MAang3pt (&msg_loc, dyncirarc->startpt, dyncirarc->center, 
                  newpt, angles);
        if (IS_NEAR_360 (angles[0]))
        {
          BSprepcircp (&msg_loc, dyncirarc->center, dyncirarc->startpt,
                       dyncirarc->norvec, cvs[cvinx], dumvec, &dum);
        }
        else
        {
          BSprepcarc (&msg_loc, dyncirarc->startpt, dyncirarc->center, newpt,
                      dyncirarc->norvec, cvs[cvinx], dumvec, &dum);
        }
        if (msg_loc != BSSUCC)
        {
            py2pts.num_points = 2;
            py2pts.points = (IGRdouble *)pts2;
            OM_BLOCK_MOVE (dyncirarc->startpt, pts2[0], sizeof (IGRpoint));
            OM_BLOCK_MOVE (dyncirarc->startpt, pts2[1], sizeof (IGRpoint));
            EMcnvtpybsn (&msg_loc, 3, &py2pts, cvs[cvinx]);
        }
        cvinx++;
        if (copymat)
        {
          cv = cvs[cvinx-1];
          tcv = cvs[cvinx];
          MAbccopy (&msg_loc, cv, tcv);
          MArptsxform (&msg_loc, &cv->num_poles, &cv->rational, cv->weights,
                       copymat, cv->poles, tcv->poles);
          cvinx++;
        }
        break;

      case EMSdyntanarc:
        /*
         * Arc that is tangent to the previous segment and ends at newpt.
         */
        dyntanarc = &dyngeomselect->dyngeom.tanarc;
        EMfind_tanarc_centerpt (&msg_loc, dyntanarc->startpt, newpt, 
                                dyntanarc->tanvec, dyntanarc->norvec, 
                                dyntanarc->center, &parallel);
        if (!parallel && msg_loc == BSSUCC) 
        {
          OM_BLOCK_MOVE (dyntanarc->norvec, dumvec, sizeof(IGRvector));
          if (!BSprepcarc (&msg_loc, dyntanarc->startpt, dyntanarc->center, newpt,
                      dyntanarc->norvec, cvs[cvinx], dumvec, &dum)) { goto ret_end; };
          
          if (buffinfo->smart_sketch_active)
            ss$update_new_element (point2 = dyntanarc->center);
  
          cvinx++;
          if (copymat)
          {
            cv = cvs[cvinx-1];
            tcv = cvs[cvinx];
            MAbccopy (&msg_loc, cv, tcv);
            MArptsxform (&msg_loc, &cv->num_poles, &cv->rational, cv->weights,
                         copymat, cv->poles, tcv->poles);
            cvinx++;
          }
        }
        break;
        
      default:
        break;
    }
  }

  for (i=0; i<2; i++)
    if (intfound[i])
      OM_BLOCK_MOVE ( buffinfo->inttol_py[buffinfo->inttol_constr_inx[i]].points,
                      buffinfo->inttol_disppy[i].points,
                      2 * sizeof (IGRpoint));

  if (cvcvint)
  {
    if (intpts)
      BSdealloc((char *) intpts);
    if (par1)
      BSdealloc((char *) par1);
    if (par2)
      BSdealloc((char *) par2);
  }

  /*
   * Output the buffers for display
   */

  *num_buffs = num_display_geom + (copymat ? num_display_geom : 0) +
                (intfound[0] ? 1 : 0) + (intfound[1] ? 1 : 0);
  *buffs = buffinfo->dpheaders;

ret_end:
  return (TRUE);
}

EMfind_tanarc_centerpt (long *msg, IGRpoint startpt, IGRpoint endpt, IGRvector tanvec, 
                        IGRvector norvec, IGRpoint centerpt, IGRboolean *parallel)
{
  int           i;
  double	mdist;
  IGRpoint      midpt, centerpt1, centerpt2;
  IGRvector     chordvec, orthovec, perbisvec;
                           
  for (i=0; i<3; i++) 
    midpt[i] = 0.5*(endpt[i] + startpt[i]);
  
  /*
   * intersect the normal to the tanvec (orthovec) and the perpendicular bisector (perbisvec)
   * of the chord joining the start and endpt (chordvec) to get the actual centerpt. 
   */
  if (!BSmkvec (msg, chordvec, startpt, endpt))              return BSFAIL;
  if (!BSnorvec(msg, chordvec))                              return BSFAIL;
  if (!BScrossp(msg, tanvec, norvec, orthovec))              return BSFAIL;
  if (!BSnorvec(msg, orthovec))                              return BSFAIL;
  if (!BScrossp(msg, chordvec, norvec, perbisvec))           return BSFAIL;
  if (!BSnorvec(msg, perbisvec))                             return BSFAIL;
  if (!BSlldist(msg, startpt, midpt, orthovec, perbisvec, 
                parallel, &mdist, centerpt1, centerpt2))     return BSFAIL;
 for (i=0; i<3; i++)
    centerpt[i] = 0.5*(centerpt1[i] + centerpt2[i]);
 
 return BSSUCC;
}                


