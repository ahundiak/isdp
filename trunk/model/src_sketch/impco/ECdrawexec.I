/*

Name
  ECdraw.execute

Abstract
  Command object to create profiles and composite curves.
  
Synopsis

Description
  This routine creates composite curves and profiles.  It also has the
  functionality to modify profile segements and vertices.
  There are 3 main states of the command - 
    FIRSTPT_STATE :  State where the user inputs the first point.
    NEXTPT_STATE  :  All subsequent points are entered here.
    PROCESS_STATE :  This state is called after the second point has been
                     entered to create composite segments and add them to the existing
                     curve.
  
Return Value

Notes

Index

Keywords
  composite,profile,wireframe

History
  ????????   Siki       Creation - most probably like everything else.
  06/05/92   Vadiraj    Modified for message subsystem compliance.
  06/25/92   Rajiv      Modified the backup usage.  Added a status form
                        for Place profile command to place arc.  
                        Cleaned up a lot of code and removed some duplication.
  07/10/92   Rajiv      Added functionality for Autoclose profile.
  08/12/92   Rajiv      Facility for using keyboard shortcuts.
  10/15/92   Rajiv      Changed pt to IGRpoint so that it would not corrupt the event.button
                        values used for Tentative snapping.
  10/27/92   Rajiv      Added code to unwrite a keyin from the RAP file since it gets
                        rewritten after the EX_ALL_CHAR_MODE is done.
  10/28/92   Rajiv      In the autoclose mode, keep deleting redundant/conflicting constraints
                        till a closure is achieved.
  12/12/92   Rajiv      Added more kludgy code to make the shortcut technique work on the SUN.
  03/15/93   Rajiv      xevent.xbutton.x field to store nbytes to write to a Journal file on the 
                        SUN (TR#119302065)
  04/08/93   Rajiv      Changed the code so that if the user hits a return (just like that),
                        it is not interpreted as a RJT_MOVEON.  Was causing problems in journalling.
                        (TR#119222262)
  04/26/93   Rajiv      Added a shortcut for Close Profile - "c" - CR#119300150.
  06/05/93   Rajiv      Modify profile functionality added.
  08/04/93   Rajiv      Tangent (2-pt) arc functionality added.  Using local_states 3 & 4.
  10/19/93   Rajiv      Smart sketch functionality stabilized.  Moved shortcut code to ECdrawfunc.I.
  01/19/94   Sudha      In arc_state, direction was being calculated wrongly if a tentative input 
                        was given (PPL files). Get the current point from dbp. (TR# 119311018 )
  01/20/94   Rajiv      Unhighlite all the form options for Modify profile till an element is
                        selected.  (TR119415957)
  02/12/94   Rajiv      Removed the handling of GRst_ENDPOINT since smart sketch and journaling
                        have some problem.  (TR119417054).  Also updating the lastpt based on
                        the event in case smart sketch was on. This prevents 3pt arcs from getting
                        flipped. (TR119416571).
  02/15/94   Rajiv      Set the event.subtype to 0, so that it does not get eaten up by smart
                        sketch stuff.  A big last minute KLUDGE to get 'c' to journal properly.
                        (TR119417184)
  
  08/13/94   scw        Added X11 for Intel Solaris port
  09/18/96   scw        Removed printf (non-conditional)
*/

class implementation ECdraw;

#include <values.h>
#include <string.h>
#include <math.h>
#include "igrtypedef.h"
#include "igetypedef.h"
#include "exmacros.h"
#include "exdef.h"
#include "journal.h"
#include "igrdef.h"
#include "OMmacros.h"
#include "msdef.h"
#include "nddef.h"
#include "asbox.h"
#include "bserr.h"
#include "bsparameters.h"
#include "igr.h"
#include "igrdp.h"
#include "dpstruct.h"
#include "EMSasmacros.h"
#include "EMSdraw.h"
#include "EMSdatumdef.h"
#include "EMdtmacros.h"
#include "ECcmd.h"
#include "ECmsg.h"
#ifdef X11
#include "limits.h"
#include "X11/keysym.h"
#endif
#include "SSdef.h"
#include "SSmacros.h"
#include "comisc.h"
#include "wl.h"

#include "bserr.h"
#include "bsalloccv.h"
#include "bsfreecv.h"
#include "bsmdstptcv.h"
#include "bsprepcircp.h"
#include "bsmkvec.h"
#include "bsnorvec.h"
#include "bscrossp.h"
#include "bscvcv_int.h"
#include "bsdistptpt.h"
#include "bsdotp.h"
#include "bslenvec.h"
#include "bsmdistcvcv.h"
#include "bscvarrevt.h"
#include "bststcvfarc.h"
#include "ma.h"
#include "maptlnpro.h"
#include "ma2lnise.h"
#include "marotmx.h"
#include "magrotmx.h"
#include "maptsxfor.h"

#include "actparam.h"

static IGRboolean aflag;
static struct GRmd_env disp;


#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

extern GRclassid OPP_GR3dlineseg_class_id, OPP_GR3dpoint_class_id;
extern GRclassid OPP_GR3dcirarc_class_id, OPP_GR3dcircle_class_id;
extern GRclassid OPP_GRcompcurve_class_id;
extern GRclassid OPP_GRbspline_class_id, OPP_GRcurve_class_id;
extern GRclassid OPP_SKgeometry_class_id, OPP_SKarc_class_id;

from NDnode      import NDconnect;
from IGEgragad   import DPinrot;
from GRgraphics  import GRdisplay, GRdelete, GRconstruct, GRcopy, GRxform, GRchgprops;
from GRvg        import GRgenabsg;
from GRconnector import GRdisconn;
from GRcompcurve import EMmakecomp;
from GRcurve     import GRendpts;
from SKcompcurve import SKclose;
from SKvariable  import SKgetvar;

#define X 0
#define Y 1
#define Z 2

#define XMIN 0
#define YMIN 1
#define ZMIN 2
#define XMAX 3
#define YMAX 4
#define ZMAX 5

#define IS_HORIZVERT_CONSTR  0
#define NOT_HORIZVERT_CONSTR 2

#define MAX_LEN       1e5

#define FULL_STYLE    0
#define DASHED_STYLE  2
#define DOTDASHED_STYLE 4

#define FIRST  0
#define SECOND 1

#define HORIZONTAL    0
#define VERTICAL      1

#define COLLINEAR     0
#define ORTHOGONAL    1

#define TOL_HORIZ     0
#define TOL_VERT      1
#define TOL_ORTHO     2
#define TOL_COLL      3

#define MAX_WORD_LEN  20

#define NUMPTS_INCR   12

#define MODIFY_SEGMENT 1
#define MODIFY_VERTEX  2

#define CCW            1
#define CW             0

method execute (IGRint *response; IGRchar *response_data; IGRint pos)
{
  IGRboolean 		stat_func, addele, dosymm_ele, is_lastpt = FALSE, 
  			cirend = FALSE, process_ele = FALSE;
  IGRboolean 		angle_constr, tolfound, inttolfound[2], match, nochg_local_state;
  IGRboolean 		endmatch, endtanmatch, *active_tol_constr, tosymm2, toendsymm;
  IGRboolean 		auto_endsketch, auto_close_sketch, end_profile, end_merge;
  IGRboolean 		supported_event;
  IGRboolean		smart_sketch_active = FALSE;
  IGRboolean		tanarc = FALSE, parallel;
  IGRuchar   		old_weight;
  char       		valuetype[GR_MAX_CHAR], *str;
  char       		cmpstr[MAX_WORD_LEN], cmpstr_next[MAX_WORD_LEN];
  char       		prompt[GR_MAX_CHAR], 
             		*promptc = NULL, 
             		promptc_store[GR_MAX_CHAR];  /* Two kinds of prompts are
                                           needed to change between constraint
                                           ON (promptc) and OFF (prompt) states */
  char 			elemtype[GR_MAX_CHAR], postmsg_1[GR_MAX_CHAR], postmsg_2[GR_MAX_CHAR];
  char			valid_shortcuts[26];
  short      		constrcv_type = NULL, pttype, *pttypes;
  short 		action, props;
  int        		i, j, k, l, inxlim, inc, inx;
  int			numdyngeom = 0;  /* number of dynamic geometric entities to display */
  int        		num_pts, num_pts_del;
  int        		tol_constr_inx, inttol_constr_inx[2];
  int        		*compinx, dumint;
  int        		num_conflict_cnstr;
  int                   arc_dir = CCW;
  long       		msg_loc, stat_OM, cmdtype, eventmask, datptmask, addmask;
  long       		tmp_msg_loc, one = 1;
  long			dum, count;
  long			eventsize;
  double     		*poles, *vec, *ptr, *ptr1, *ptr2, *intpts;
  IGRpoint              *parpt1, *parpt2;
  double                *par1, *par2;
  double     		value, dittol, vwscale, lentol, dottol, par, otherpar, mdist;
  IGRpoint   		pt, point, pts2[2], projpt, intpt, lastpt, lastpt1, lastpt2;
  IGRpoint   		*pts;
  IGRvector  		dumvec, vec1, vec2, tanvec1, tanvec2;
  IGRmatrix  		mat;
  GRspacenum 		fileos, dumos;
  GRobjid    		eleobj, symm_eleobj, ele, *firstobj, *compobj,
             		*conflict_cnstr_objs;
  GRclassid  		objclass;
  struct GRid 		compid, eleid, datplanid, skmgr_id;
  struct GRevent 	event;
  struct EX_button      button;
  struct IGRbsp_curve 	*twopolecv, *cirarccv, *constrcv_ptr = NULL, *mrgcv, 
                        *elecv = NULL;
  struct GRvg_construct const_list;
  struct IGResbc 	esbc;
  struct GRmd_env 	*env;
  struct IGRpolyline 	py2pts;
  struct IGRline 	*line, *lines, *line1, *line2;
  struct IGRline 	*tol_constr_lines, *inttol_constr_lines, 
  			*angle_constr_line;
  struct GRlc_info 	geominfo[2];
  struct IGRdisplay 	dyndisplay[4];            /* display attributes of the dynamic geom */
  struct EMSdyngeomselect dyngeomselect[4];       /* type of dynamic geom */
  struct var_list 	list_var[2];
  struct SKcnstr_ptinfo *ptinfo = NULL, 	/* struct to hold the events for every */
                        *prev_ptinfo = NULL;	/* data point */
  enum GRdpmode 	dpmode;
  enum EMSuser_responses useract;
  OM_S_CHANSELECT 	chan_to_comps;
  Form 			form_ptr;
  extern IGRboolean 	EFequal_constr_lines(), EFstring_match();
  extern IGRboolean 	EFdisp_inttol_constr(), EFobtain_tangent();
  extern IGRboolean 	EFhorvert_for_datapoint();
  extern IGRboolean 	EFconstr_for_datapoint(), EFis_tangent();
  extern IGRboolean 	EFdo_form_abling();
  extern IGRboolean 	EMptsubtype_supported();
  extern IGRboolean     SKextend_profile();
  extern void 		EMgetwinview(), EMconstr_linarc_rbdisplay(), EMfind_tanarc_centerpt();
  extern IGRboolean 	EFmerge_curves();
  extern IGRboolean     EFshortcut_check();
  extern int            EFrecord_last_point();
  
  stat_OM = OM_S_SUCCESS;
  
  twopolecv = NULL;
  cirarccv = NULL;
  mrgcv = NULL;
  intpts = NULL;
  par1 = NULL;
  par2 = NULL;
  parpt1 = NULL;
  parpt2 = NULL;
  conflict_cnstr_objs = NULL;
  
  BSalloccv (2, 2, FALSE, NULL, &twopolecv, &msg_loc);
  EMerr_hndlr (msg_loc != BSSUCC, stat_OM, OM_E_ABORT, ret_end);
  pts2[0][X] = pts2[0][Y] = pts2[0][Z] = 0.0;
  OM_BLOCK_MOVE (pts2[0], pts2[1], sizeof (IGRpoint));
  py2pts.num_points = 2;
  py2pts.points = (IGRdouble *) pts2;
  EMcnvtpybsn (&msg_loc, 3, &py2pts, twopolecv);
  twopolecv->phy_closed = FALSE;

  BSalloccv (4, 7, TRUE, NULL, &cirarccv, &msg_loc);
  EMerr_hndlr (msg_loc != BSSUCC, stat_OM, OM_E_ABORT, ret_end);

  aflag = pwIsActivationOn();

  env = &(ME.ECelements->active_md_env);

  const_list.msg = &msg_loc;
  const_list.env_info = env;
  const_list.newflag = FALSE;
  const_list.level = ME.ECelements->active_level;
  const_list.properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE;
  const_list.geometry = NULL;
  const_list.display = &ME.ECelements->active_display;
  esbc.is_polydis = FALSE;
  esbc.is_curvedis = TRUE;
  const_list.class_attr = (IGRchar *) &esbc;
  const_list.name = NULL;

  fileos = env->md_id.osnum;
  gr$get_module_env(buffer = &disp);
                         

  for (i=FIRST; i<=SECOND; i++)
  {
    OM_BLOCK_MOVE (env, &geominfo[i].module_info, sizeof (struct GRmd_env));
    geominfo[i].located_obj.osnum = fileos;
  }

  BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, lentol);
  BSEXTRACTPAR (&msg_loc, BSTOLORTHOVEC, dottol);

  active_tol_constr = ME.ECdraw->active_tol_constr;
  tol_constr_lines = ME.ECdraw->tol_constr_lines;
  inttol_constr_lines = ME.ECdraw->inttol_constr_lines;
  pts = ME.ECdraw->inttolpt_store;
  count = ME.ECdraw->num_inttol_constr;
  for (i=0, j=0; i<count; i++, j+=2)
  {
    inttol_constr_lines[i].point1 = pts[j];
    inttol_constr_lines[i].point2 = pts[j+1];
  }
  angle_constr_line = &ME.ECdraw->angle_constr_line;
  form_ptr = ME.ECdraw->form_ptr;
  nochg_local_state = FALSE;
  auto_endsketch = FALSE;
  auto_close_sketch = FALSE;
  end_profile = FALSE;
  end_merge = FALSE;
  smart_sketch_active = ss$is_active();
    
  cmdtype = ME.super_cmd->mytype;
  if (cmdtype == LINEARC)
  {
    ex$message(msgnumb=EM_M_PlLnArCm);   
    strcpy (valid_shortcuts, "acdehilnoprsvw");
  }
  else if (cmdtype == VARPROFILE || cmdtype == ONEPROFILE)
  {
    ex$message(msgnumb=EM_M_PlProfile);
    strcpy (valid_shortcuts, "acdelrw");
  }
  else if (cmdtype == MODIFYPROFILE)
  {
    ex$message(msgnumb=EM_M_EditProfile);
    strcpy (valid_shortcuts, "adelrw");
  }

  /*
   * for the rest of the command, ModifyProfile should behave the same as PlaceProfile.
   */
  if (cmdtype == MODIFYPROFILE || cmdtype == ONEPROFILE)
    cmdtype = VARPROFILE;

  if (cmdtype == LINEARC)
    datptmask = GRm_DATA;
  else
    datptmask = GRm_PLNDATA;

  do
  {
    switch (ME.super_cmd->state)
    {
      case FIRSTPT_STATE:
        if (form_ptr)
          EFdo_form_abling (form_ptr, FIRSTPT_STATE, FALSE, FALSE, me->mytype);
        
        if (ME.super_cmd->mytype == LINEARC)
        {
          ex$message( msgnumb = EMS_P_EnterStartPoint );
        }
        else if (ME.super_cmd->mytype == VARPROFILE || ME.super_cmd->mytype == ONEPROFILE)
        {
          ex$message( msgnumb = EMS_P_EnterStptSnaptoContExistProfile );
        }
        
        ME.ECdraw->line_state = TRUE;
        
        /*
         * If we are in Modify mode, then we need to check the first segment if we
         * should go into an Arc mode.
         */
        if (ME.super_cmd->mytype == MODIFYPROFILE)
        {
          stat_OM = om$get_classid ( osnum = ME.ECdraw->modseg[0].osnum, 
                                     objid = ME.ECdraw->modseg[0].objid, 
                                     p_classid = &objclass );
          if (objclass == OPP_SKarc_class_id)
          {
            ME.ECdraw->local_state = 0;
            ME.ECdraw->line_state = FALSE;
          }
        }

        addmask = NULL;

        if (IF_NULL_OBJID (ME.ECdraw->wingrid.objid) ||
            !ME.ECdraw->cur_comp_inx)
        {
          if (!form_ptr)
            ex$message(msgnumb=EMS_I_InvkStatusFrm)
        }
        else if (cmdtype != VARPROFILE)
        {
          ex$message(msgnumb=EMS_S_BackupToUndo)
          addmask = GRm_BACK_UP;
        }

        if (smart_sketch_active)
        {
          ss$exit();

         if (aflag = pwIsActivationOn())
         {
           smart_sketch_active = FALSE;
         }
         else
         {
           ss$enter();
           ss$activate();
         }
        }

        /*
         * Get the first data point to begin the composite/profile
         */
        eventmask = datptmask | GRm_STRING | addmask;
        stat_func = ems$getevent (msg = &msg_loc, event_mask = eventmask,
                                  response = (long *)response, 
                                  response_data = response_data,
                                  event = &event);
        EMerr_hndlr (!stat_func, stat_OM, OM_E_ABORT, ret_end);
        form_ptr = ME.ECdraw->form_ptr;
        ex$message(msgnumb=EMS_P_ClearPromptField);

        switch (event.response)
        {
          case EX_DATA:
            OM_BLOCK_MOVE (&event.event.button.x, pt, sizeof (IGRpoint));
            OM_BLOCK_MOVE (pt, ME.ECdraw->firstpt, sizeof (IGRpoint));
            OM_BLOCK_MOVE (pt, ME.ECdraw->prevpts[0], sizeof (IGRpoint));
            ME.ECdraw->firsttan[X] = 1.0;
            ME.ECdraw->firsttan[Y] = 0.0;
            ME.ECdraw->firsttan[Z] = 0.0;
            OM_BLOCK_MOVE (ME.ECdraw->firsttan, ME.ECdraw->tanvec, 
                           sizeof (IGRvector));

            if (cmdtype == VARPROFILE)
            {
              ME.ECdraw->num_pts = 1;
              ptinfo = ME.ECdraw->ptinfo;
              ptinfo->geomtype = SK_POINT;

              if (EMptsubtype_supported (&event))
              {
                ptinfo->pttype[FIRST] = PT_EVENT;
                ptinfo->event = event;

                /*
                 * if the event was a Tentative snap to an existing profile
                 * then we need to do further processing to see if the profile 
                 * is being extended.  
                 * Tentative snaps cannot merge in case of MODIFY_VERTEX mode.
                 */

                if (event.subtype == GRst_KEYPOINT &&
                    ME.ECdraw->modify_state != MODIFY_VERTEX)
                  if (SKextend_profile (&msg_loc, &event))
                    ptinfo->pttype[FIRST] = PT_MERGE;
              }
              else
              {
                ptinfo->pttype[FIRST] = PT_NULL;
              }
              ptinfo->pttype[SECOND] = PT_NULL;
            }

            /*
             * Obtain the window and it's orientation.
             */

            EMgetwinview (&msg_loc, &event, &ME.ECdraw->wingrid, mat,
                          ME.ECdraw->xvec, ME.ECdraw->yvec, ME.ECdraw->zvec);
            EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, ret_end);

            if (IF_NULL_OBJID (ME.ECdraw->wingrid.objid))
            {
              ex$message(msgnumb=EMS_S_EnterDataPtInWindow)
              break;
            }

            /*
             * Obtain the window tolerance, relative to 2 times dittol.
             */

            gr$get_dit_tolerance (buffer = &dittol);
            dittol += dittol;

            list_var[0].var = VVOL_VIEWPORT_SCALE;
            list_var[0].var_ptr = (IGRchar *) &vwscale;
            list_var[0].num_bytes = sizeof (IGRdouble);
            list_var[0].bytes_returned = &dum;

            list_var[1].var = END_PARAM;
            list_var[1].var_ptr = NULL;
            list_var[1].num_bytes = 0;
            list_var[1].bytes_returned = NULL;

            stat_OM = dp$inq_set_gragad (msg = &msg_loc, 
                       osnum = ME.ECdraw->wingrid.osnum,
                       gragad_objid = ME.ECdraw->wingrid.objid,
                       which_error = &dum, var_list = list_var);
            EMomerr_exit (stat_OM, ret_end);
            EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, ret_end);

            ME.ECdraw->wintol = dittol / vwscale;

            /*
             * Obtain the construction lines color by incrementing the
             * current active color by one (1).
             */

            ME.ECdraw->constr_color = ME.ECelements->active_display.color+1;

            /*
             * Make up the initial tolerance banded constraints along the
             * view horizontal and vertical.
             */

            ptr1 = tol_constr_lines[0].point1;
            ptr2 = tol_constr_lines[0].point2;
            OM_BLOCK_MOVE (pt, ptr1, sizeof (IGRpoint));
            for (i=0; i<3; i++)
              ptr2[i] = ptr1[i] + ME.ECdraw->xvec[i];

            ptr1 = tol_constr_lines[1].point1;
            ptr2 = tol_constr_lines[1].point2;
            OM_BLOCK_MOVE (pt, ptr1, sizeof (IGRpoint));
            for (i=0; i<3; i++)
              ptr2[i] = ptr1[i] + ME.ECdraw->yvec[i];

            active_tol_constr[0] = TRUE;
            active_tol_constr[1] = TRUE;
            active_tol_constr[2] = FALSE;
            active_tol_constr[3] = FALSE;

            /*
             * Make up the start-point intersection-tolerance band. These
             * are added as default tolerance bands.
             */

            ME.ECdraw->num_inttol_constr = 0;

            inx = ME.ECdraw->num_inttol_constr;
            if (om$dimension_of (varray = ME.ECdraw->inttol_constr_lines) <
                inx + 2)
            {
              stat_OM = om$vla_set_dimension (varray = 
                         ME.ECdraw->inttol_constr_lines, size = inx + 2);
              EMomerr_exit (stat_OM, ret_end);

              stat_OM = om$vla_set_dimension (varray = 
                         ME.ECdraw->inttolpt_store, size = 2 * (inx + 2));
              EMomerr_exit (stat_OM, ret_end);

              inttol_constr_lines = ME.ECdraw->inttol_constr_lines;
              pts = ME.ECdraw->inttolpt_store;
              count = inx + 2;
              for (i=0, j=0; i<count; i++, j+=2)
              {
                inttol_constr_lines[i].point1 = pts[j];
                inttol_constr_lines[i].point2 = pts[j+1];
              }
            }
            lines = &inttol_constr_lines[inx];

            ptr1 = lines[0].point1;
            ptr2 = lines[0].point2;
            OM_BLOCK_MOVE (pt, ptr1, sizeof (IGRpoint));
            for (i=0; i<3; i++)
              ptr2[i] = ptr1[i] + ME.ECdraw->xvec[i];
            match = FALSE;
            for (i=0; i<inx; i++)
              if (EFequal_constr_lines (&inttol_constr_lines[i], &lines[0]))
              {
                match = TRUE;
                break;
              }
            if (!match)
              ME.ECdraw->num_inttol_constr++;

            ptr1 = lines[1].point1;
            ptr2 = lines[1].point2;
            OM_BLOCK_MOVE (pt, ptr1, sizeof (IGRpoint));
            for (i=0; i<3; i++)
              ptr2[i] = ptr1[i] + ME.ECdraw->yvec[i];
            match = FALSE;
            for (i=0; i<inx; i++)
              if (EFequal_constr_lines (&inttol_constr_lines[i], &lines[1]))
              {
                match = TRUE;
                break;
              }
            if (!match)
              ME.ECdraw->num_inttol_constr++;

            ME.ECdraw->angle_constr = FALSE;
            ME.ECdraw->cur_comp_inx = 0;
            ME.ECdraw->compobj = NULL_OBJID;
            auto_endsketch = FALSE;
            auto_close_sketch = FALSE;
            ME.super_cmd->state = NEXTPT_STATE;
            if (form_ptr)
              EFdo_form_abling (form_ptr, NEXTPT_STATE, FALSE, FALSE, me->mytype);
            break;

          case EX_STRING:
            str = event.event.keyin;
            if (strlen (str) > MAX_WORD_LEN)
              goto ret_end;
            
            strcpy (cmpstr, "");
            count = sscanf (str, "%s %s", cmpstr, cmpstr_next);
            if (count == 1)
              strcpy (cmpstr_next, "");

            ME.ECdraw->return_state = FIRSTPT_STATE;
            if (EFstring_match (cmpstr, "ERASE") )
            {
              ME.super_cmd->state = DELALLCONSTR_STATE;
              if (form_ptr)
                FIg_set_state_on (form_ptr, DELALLCONSTR_STATE);
            }
            else if (EFstring_match (cmpstr, "W"))
            {
              ME.super_cmd->state = REVCONSTR_STATE;
              if (form_ptr)
                FIg_set_state_on (form_ptr, REVCONSTR_STATE);
            }
            else
              goto ret_end;
            break;

          case EX_BACK_UP:
            if (auto_endsketch)
            {
              count = sizeof (struct GRevent);
              stat_OM = ex$putque (msg = &msg_loc, response = &event.response,
                                   byte = &count, buffer = (char *) &event.event);
              EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, 
                           ret_end);
              stat_OM = ex$putque (msg = &msg_loc, response = &event.response,
                                   byte = &count, buffer = (char *) &event.event);
              EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, 
                           ret_end);
              auto_endsketch = FALSE;
            }
            ME.super_cmd->state = NEXTPT_STATE;
            if (form_ptr)
              EFdo_form_abling (form_ptr, NEXTPT_STATE, FALSE, FALSE, me->mytype);
            break;

          default:
            goto ret_end;
        }
        break;
        
      case NEXTPT_STATE:
        angle_constr = ME.ECdraw->angle_constr;
        if (ME.ECdraw->line_state || ME.ECdraw->horver_state)
        {
          /*
           * Line placement mode.
           */
          promptc = prompt;
          if (ME.ECdraw->horver_state)
          {
            ex$message(msgnumb = EMS_P_InputConstptMvon, buff = prompt);
          }
          else if (ME.ECdraw->symm_state == BEGINSYMM1_STATE)
          {
            ex$message(msgnumb = EMS_P_InputStptLnofSymm, buff = prompt);
          }
          else if (ME.ECdraw->symm_state == BEGINSYMM2_STATE)
          {
            ex$message(msgnumb = EMS_P_InputEndLnofSymm, buff = prompt);
          }
          else
          {
            if (angle_constr)
            {
              ex$message(msgnumb = EMS_P_InptEndptKyinDistMvon, buff = prompt);
              promptc = prompt;
            }
            else
            {
              ex$message(msgnumb = EMS_P_InEndptKeyinAngMoveon, buff = prompt);
              promptc = promptc_store;
              ex$message(msgnumb = EMS_P_InptEndptKyinDistMvonfz, buff = promptc);
            }
          }
          UI_prompt (prompt);
          if (!smart_sketch_active) 
          {
            if (angle_constr)
            {
              if (cmdtype == VARPROFILE)
              {
                ex$message(msgnumb=EMS_S_PressDtoReleaseConstrnt);
              }
              else
              {
                ex$message(msgnumb=EMS_S_PressDtoDelConstLine);
              }
            }
            else if (ME.ECdraw->symm_state == BEGINSYMM1_STATE ||
                     ME.ECdraw->symm_state == BEGINSYMM2_STATE ||
                     ME.ECdraw->horver_state)
            {
              ex$message(msgnumb=EMS_S_BackupToUndo);
            }
            else
            {
              ex$message(msgnumb=EMS_S_PressDtoReleaseConstrnt);
            }
          }
          dyngeomselect[0].dyngeomtype = EMSdynlineseg;
          OM_BLOCK_MOVE (ME.ECdraw->prevpts[0],
                         dyngeomselect[0].dyngeom.lineseg.firstpt, 
                         sizeof (IGRpoint));
          OM_BLOCK_MOVE (&ME.ECelements->active_display, &dyndisplay[0],
                         sizeof (struct IGRdisplay));
          if (ME.ECdraw->symm_state == BEGINSYMM1_STATE ||
              ME.ECdraw->horver_state)
          {
            dyndisplay[0].weight = 0;
            dyndisplay[0].style = DASHED_STYLE;
          }
          else if (ME.ECdraw->symm_state == BEGINSYMM2_STATE)
          {
            dyndisplay[0].weight = 0;
            dyndisplay[0].style = DOTDASHED_STYLE;
          }

          numdyngeom = 1;

          constrcv_ptr = NULL;
        }
        else if (ME.ECdraw->local_state == 0)
        {
          /*
           * Arc center point placement mode.
           */
          if (angle_constr)
          {
            ex$message(msgnumb = EMS_P_InptCntrKyinRdsMvonEnd, buff = prompt);
            promptc = prompt;
          }
          else
          {
            ex$message(msgnumb = EMS_P_InptCntrKyinAngMvonEnd, buff = prompt);
            promptc = promptc_store;
            ex$message(msgnumb = EMS_P_InptCntrKyinRdsMvonfz, buff = promptc); 
          }
          UI_prompt (prompt); 

          if (angle_constr)
          {
            if (cmdtype == VARPROFILE)
            {
              ex$message(msgnumb=EMS_S_PressDtoReleaseConstrnt);
            }
            else
            {
              ex$message(msgnumb=EMS_S_PressDtoDelConstLine);
            }
          }
          else
          {
            ex$message(msgnumb=EMS_S_BackupToUndo);
          }

          dyngeomselect[0].dyngeomtype = EMSdynlineseg;
          OM_BLOCK_MOVE (ME.ECdraw->prevpts[0],
                         dyngeomselect[0].dyngeom.lineseg.firstpt, 
                         sizeof (IGRpoint));
          OM_BLOCK_MOVE (&ME.ECelements->active_display, &dyndisplay[0],
                         sizeof (struct IGRdisplay));
          dyndisplay[0].weight = 0;
          dyndisplay[0].style = DASHED_STYLE;

          dyngeomselect[1].dyngeomtype = EMSdyncircle;
          OM_BLOCK_MOVE (ME.ECdraw->prevpts[0],
                         dyngeomselect[1].dyngeom.circle.circumpt, 
                         sizeof (IGRpoint));
          OM_BLOCK_MOVE (ME.ECdraw->zvec, 
                         dyngeomselect[1].dyngeom.circle.norvec, 
                         sizeof (IGRvector));
          OM_BLOCK_MOVE (&ME.ECelements->active_display, 
                         &dyndisplay[1],
                         sizeof (struct IGRdisplay));
          dyndisplay[1].weight = 0;
          dyndisplay[1].style = DASHED_STYLE;

          numdyngeom = 2;

          constrcv_ptr = NULL;
        }
        else if (ME.ECdraw->local_state == 1 || ME.ECdraw->local_state == 2)
        {
          /*
           * Arc end point (sweep) placement mode.  
           * Local state 1 ==> CCW and 2 ==> CW direction.
           */
          ex$message(msgnumb = EMS_P_InEndptKeyinSwpMvtoRvArc, buff = prompt);
          promptc = promptc_store;
          ex$message(msgnumb = EMS_P_InputEndptMvOntoRvArc, buff = promptc);
          UI_prompt (prompt);

          /*
           * switch for the ARC direction.
           */
          OM_BLOCK_MOVE (ME.ECdraw->zvec, dumvec, sizeof (IGRvector));
          if (ME.ECdraw->local_state == 1)
          {
            arc_dir = CCW;
            for (i = 0; i < 3; i++)
              dumvec[i] = -dumvec[i];
          }
          else
          {
            arc_dir = CW;
          }

          dyngeomselect[0].dyngeomtype = EMSdynlineseg;
          OM_BLOCK_MOVE (ME.ECdraw->prevpts[1],
                         dyngeomselect[0].dyngeom.lineseg.firstpt, 
                         sizeof (IGRpoint));
          OM_BLOCK_MOVE (&ME.ECelements->active_display, &dyndisplay[0],
                         sizeof (struct IGRdisplay));
          dyndisplay[0].weight = 0;
          dyndisplay[0].style = DASHED_STYLE;

          dyngeomselect[1].dyngeomtype = EMSdynperpline;
          OM_BLOCK_MOVE (ME.ECdraw->prevpts[1],
                         dyngeomselect[1].dyngeom.perpline.fixedpt, 
                         sizeof (IGRpoint));
          OM_BLOCK_MOVE (dumvec, 
                         dyngeomselect[1].dyngeom.perpline.norvec, 
                         sizeof (IGRvector));
          OM_BLOCK_MOVE (&ME.ECelements->active_display, &dyndisplay[1],
                         sizeof (struct IGRdisplay));
          dyndisplay[1].weight = 0;
          dyndisplay[1].style = DASHED_STYLE;

          dyngeomselect[2].dyngeomtype = EMSdyncirarc;
          OM_BLOCK_MOVE (ME.ECdraw->prevpts[0],
                         dyngeomselect[2].dyngeom.cirarc.startpt, 
                         sizeof (IGRpoint));
          OM_BLOCK_MOVE (ME.ECdraw->prevpts[1], 
                         dyngeomselect[2].dyngeom.cirarc.center, 
                         sizeof (IGRpoint));
          OM_BLOCK_MOVE (dumvec, 
                         dyngeomselect[2].dyngeom.cirarc.norvec,
                         sizeof (IGRvector));
          OM_BLOCK_MOVE (&ME.ECelements->active_display, &dyndisplay[2],
                         sizeof (struct IGRdisplay));

          numdyngeom = 3;
          
          /*
           * Restrict the movement of the cursor to lie on the arc by defining
           * a constraining geometry.
           */

          BSprepcircp (&msg_loc, ME.ECdraw->prevpts[1], ME.ECdraw->prevpts[0],
                       ME.ECdraw->zvec, cirarccv, dumvec, &dumint);
          EMerr_hndlr (msg_loc != BSSUCC, stat_OM, OM_E_ABORT, ret_end);
          constrcv_type = EMSD_CIRCLE_ARC;
          constrcv_ptr = cirarccv;
        }
        else if (ME.ECdraw->local_state == 3 || ME.ECdraw->local_state == 4)
        {
          /*
           * Tangent Arc end point placement modes.  
           * Local state 1 ==> CCW and 2 ==> CW direction.
           */
          ex$message(msgnumb = EMS_P_EnterEndptKyinRadMvOntoRvArc, buff = prompt);
          promptc = promptc_store;
          ex$message(msgnumb = EMS_P_EnterEndptKyinRadMvOntoRvArc, buff = promptc);
          UI_prompt (prompt);

          /*
           * switch for the ARC direction.
           */
          OM_BLOCK_MOVE (ME.ECdraw->zvec, dumvec, sizeof (IGRvector));
          if (ME.ECdraw->local_state == 3) 
          {
            arc_dir = CCW;
            for (i = 0; i < 3; i++)
              dumvec[i] = -dumvec[i];
          }
          else
          {
            arc_dir = CW;
          }
              
          dyndisplay[0].weight = 0;
          dyndisplay[0].style = DASHED_STYLE;
          dyngeomselect[0].dyngeomtype = EMSdyntanarc;
          OM_BLOCK_MOVE (ME.ECdraw->prevpts[0],
                         dyngeomselect[0].dyngeom.tanarc.startpt, 
                         sizeof (IGRpoint));
          OM_BLOCK_MOVE (ME.ECdraw->tanvec,
                         dyngeomselect[0].dyngeom.tanarc.tanvec, 
                         sizeof (IGRvector));
          OM_BLOCK_MOVE (dumvec, 
                         dyngeomselect[0].dyngeom.tanarc.norvec,
                         sizeof (IGRvector));
          OM_BLOCK_MOVE (&ME.ECelements->active_display, 
                         &dyndisplay[0],
                         sizeof (struct IGRdisplay));

          OM_BLOCK_MOVE (ME.ECdraw->zvec, dumvec, sizeof (IGRvector));
          numdyngeom = 1;

          constrcv_ptr = NULL;
        }
        
        
        if (ME.ECdraw->modify_state == MODIFY_VERTEX)
        {
          OM_BLOCK_MOVE (&ME.ECelements->active_display, &dyndisplay[numdyngeom],
                         sizeof (struct IGRdisplay));
          dyndisplay[numdyngeom].weight = 0;
          dyndisplay[numdyngeom].style = DASHED_STYLE;
          if (ME.ECdraw->modseg_gmtype[1] & SK_LINE)
          {
            dyngeomselect[numdyngeom].dyngeomtype = EMSdynlineseg;
            OM_BLOCK_MOVE (ME.ECdraw->dyn_point,
                           dyngeomselect[numdyngeom].dyngeom.lineseg.firstpt, 
                           sizeof (IGRpoint));           
          }
          numdyngeom++;
        }

        if (smart_sketch_active)
        {
          if (!me->line_state && me->local_state)
          {
            /*
             * user in the arc-sweep definition mode.  
             */
            double points[6];
            OM_BLOCK_MOVE ( ME.ECdraw->prevpts[0], &points[0], sizeof(IGRpoint));
            OM_BLOCK_MOVE ( ME.ECdraw->prevpts[1], &points[3], sizeof(IGRpoint));
            ss$set_new_element ( type = SSARC, 
                                 points = points,
                                 new_flag = arc_dir);
          }
          else
          {
            /*
             * either the line mode or defining the center point of the arc.
             */
            ss$set_new_element ( type = SSLINE, 
                                 points = ME.ECdraw->prevpts[0]);
          }
        }
        
        EMconstr_linarc_rbdisplay (&msg_loc,
                angle_constr ? MAXDOUBLE : ME.ECdraw->wintol,
                angle_constr ? 1 : 4,
                angle_constr ? &angle_constr : active_tol_constr,
                angle_constr ? angle_constr_line : tol_constr_lines,
                ME.ECdraw->wintol,
                ME.ECdraw->num_inttol_constr, NULL, inttol_constr_lines,
                constrcv_type, constrcv_ptr,
                numdyngeom, dyndisplay, dyngeomselect,
                ME.ECdraw->symm_state == INSYMM_STATE ? ME.ECdraw->symm_mat : NULL,
                prompt, promptc,
                &tol_constr_inx, inttol_constr_inx, 
                &is_lastpt, lastpt,
                smart_sketch_active);
        EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, ret_end);

        if (angle_constr)
        {
          tol_constr_inx = NOT_HORIZVERT_CONSTR;
          is_lastpt = TRUE;
        }

        addmask = GRm_VALUE;
        if (ME.ECdraw->line_state || ME.ECdraw->horver_state)
        {
          if (tol_constr_inx >= 0 && is_lastpt)
            strcpy (valuetype, GRIO_DISTANCE);
          else
            strcpy (valuetype, GRIO_ANGLE);
        }
        else
        {
          if ((ME.ECdraw->local_state == 0 && tol_constr_inx >= 0 && is_lastpt) ||
              (ME.ECdraw->local_state == 3 || ME.ECdraw->local_state == 4))
            strcpy (valuetype, GRIO_DISTANCE);
          else
            strcpy (valuetype, GRIO_ANGLE);

          /*
           * if the user is defining the sweep of a 3-pt arc and locked onto a constraint,
           * then cannot input a value.
           */
          if ((ME.ECdraw->local_state == 1 || ME.ECdraw->local_state == 2) && 
               tol_constr_inx >= 0)
            addmask = NULL;
        }
        
        /*
         * Get the event out.  Skip if a shortcut was used.
         */
          
        if (!EFshortcut_check(&event, valid_shortcuts))
        {
          eventmask = datptmask | GRm_BACK_UP | GRm_RJT_MOVEON | GRm_TEXT_VALUE |
                      addmask;
          stat_func = ems$getevent (msg = &msg_loc, event_mask = eventmask,
                                    value_type = valuetype, event = &event,
                                    response = (long *)response,
                                    response_data = response_data);
          EMerr_hndlr (!stat_func, stat_OM, OM_E_ABORT, ret_end);

         /*
          * if the user hits an empty <CR>, the system returns an EX_VALUE with 0.0.  
          * Ignore this by changing the response to string.  - Rajiv 4/8/93.  (for some
          * reason it used to be interpreted as a MOVEON).
          */
          if ((msg_loc == GRw_no_value) || 
              (event.response == EX_VALUE && event.subtype == GRst_DEFAULT))
          {
            event.response = EX_STRING;
            strcpy (event.event.keyin, "\r");          
          }
        }
  
        form_ptr = ME.ECdraw->form_ptr;
        ex$message(msgnumb=EMS_P_ClearPromptField);

        switch (event.response)
        {
          case EX_DATA:
            OM_BLOCK_MOVE (&event.event.button.x, pt, sizeof(IGRpoint));
            if (smart_sketch_active)
              OM_BLOCK_MOVE (&event.event.button.x, lastpt, sizeof(IGRpoint));

            tolfound = tol_constr_inx >= 0;
            inttolfound[0] = inttol_constr_inx[0] >= 0;
            inttolfound[1] = inttol_constr_inx[1] >= 0;

            cirend = !ME.ECdraw->line_state && ME.ECdraw->local_state != 0;
            if (ME.ECdraw->horver_state)
              cirend = FALSE;
            tanarc = !ME.ECdraw->line_state && 
                     (ME.ECdraw->local_state == 3 || ME.ECdraw->local_state == 4);

            if (cmdtype == VARPROFILE)
            {
              if (tanarc)
                ME.ECdraw->num_pts++;
              num_pts = ME.ECdraw->num_pts;
              count = om$dimension_of (varray = ME.ECdraw->ptinfo);
              if (count <= num_pts)
              {
                stat_OM = om$vla_set_dimension (varray = ME.ECdraw->ptinfo, 
                                                size = num_pts + NUMPTS_INCR);
                EMomerr_exit (stat_OM, ret_end);

                inttol_constr_lines = ME.ECdraw->inttol_constr_lines;
                pts = ME.ECdraw->inttolpt_store;
                count = ME.ECdraw->num_inttol_constr;
                for (i=0, j=0; i<count; i++, j+=2)
                {
                  inttol_constr_lines[i].point1 = pts[j];
                  inttol_constr_lines[i].point2 = pts[j+1];
                }
              }
              ptinfo = &ME.ECdraw->ptinfo[num_pts];
              ptinfo->geomtype = ME.ECdraw->line_state ? SK_LINE : SK_ARC;
              ptinfo->pttype[FIRST] = PT_NULL;
              ptinfo->pttype[SECOND] = PT_NULL;
              if (num_pts)
                prev_ptinfo = &ME.ECdraw->ptinfo[num_pts-1];
              else
                prev_ptinfo = NULL;

              if (tanarc)
              {
                /*
                 * add the constraint on the centerpt.
                 */
                prev_ptinfo->pttype[FIRST] = PT_TANGE;
                prev_ptinfo->pttype[SECOND] = PT_NULL;
                prev_ptinfo->geomtype = SK_ARC;
              }
            }

            supported_event = FALSE;

            /*
             * Check if the the datapt is close to the old endpoint of the
             * segment being modified.  If so, modification ends.
             */
            if (cmdtype == VARPROFILE && event.subtype != GRst_KEYPOINT &&
                ME.ECdraw->modify_state == MODIFY_SEGMENT)
            {
              stat_OM = om$send ( msg = message SKvariable.SKgetvar
                                          (&msg_loc, NULL, &env->md_env.matrix_type,
                                          env->md_env.matrix, point),
                                  targetid = ME.ECdraw->vertex[1], 
                                  targetos = ME.ECdraw->modseg[0].osnum);
              EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);
              if (BSdistptpt (&msg_loc, point, pt) < lentol) 
              {
                ptinfo->pttype[FIRST] = PT_NULL;
                end_profile = TRUE;
                end_merge = TRUE;
                event.subtype = GRst_REGULAR;
              }
            }

            /*
             * Check if an event generator was used ... if so, disallow any
             * of the geometric kind of constraints unless the user is in the
             * frozen mode.
             */
            if (event.subtype != GRst_REGULAR)
            {
              if (EMptsubtype_supported (&event))
              {
                supported_event = TRUE;
                if (!angle_constr)
                  tolfound = FALSE;
              }
            }

            /*
             * Supported events take precedence over tolerance. In other words
             * if I snap and I happen to be within tolerance for horizontal, I
             * can forget about the vertical.
             */
            if (cmdtype == VARPROFILE && supported_event && !ME.ECdraw->angle_constr)
            {
              ptinfo->pttype[FIRST] = PT_EVENT;
              ptinfo->event = event;
            
              /*
               * Tentative snaps have to be explored further.
               * Tentative snaps cannot merge in case of MODIFY_VERTEX mode.
               * Also I should be in either line state or ending an arc.
               */
              if (event.subtype == GRst_KEYPOINT &&
                  ME.ECdraw->modify_state != MODIFY_VERTEX &&
                  (ME.ECdraw->line_state || ME.ECdraw->local_state))
              {
                /*
                 * If the snap was to an endpoint of an existing profile, end profile.
                 */
                if (SKextend_profile ( &msg_loc, &event ))
                {
                  ptinfo->pttype[FIRST] = PT_MERGE;
                  end_profile = TRUE;
                }

                /*
                 * SPECIAL CASE: If segment was being modified, check for end merging.
                 */
                if (ME.ECdraw->modify_state == MODIFY_SEGMENT)
                {
                  if (event.located_object[0].located_obj.objid == ME.ECdraw->modseg[1].objid)
                  {
                    ptinfo->pttype[FIRST] = PT_NULL;
                    end_profile = TRUE;
                    end_merge = TRUE;
                  }
                }
              }
            }
            else if (tolfound || inttolfound[0])
            {
              if (angle_constr)
                line1 = angle_constr_line;
              else if (tolfound)
                line1 = &tol_constr_lines[tol_constr_inx];
              else
                line1 = &inttol_constr_lines[inttol_constr_inx[0]];
              MAptlnproj (&msg_loc, pt, line1, pt, &par);

              if (cmdtype == VARPROFILE && !tanarc)
              {
                if (angle_constr || tolfound)
                {
                  if (angle_constr)
                    inx = ME.ECdraw->angle_tol_constr_inx;
                  else
                    inx = tol_constr_inx;

                  if (inx < 0)
                  {
                    ptinfo->pttype[FIRST] = PT_ANGLE;
                    ptinfo->value[FIRST] = ME.ECdraw->angle;
                  }
                  else if (inx == TOL_HORIZ)
                    ptinfo->pttype[FIRST] = PT_HORIZ;
                  else if (inx == TOL_VERT)
                    ptinfo->pttype[FIRST] = PT_VERT;
                  else if (inx == TOL_COLL)
                    ptinfo->pttype[FIRST] = PT_COLL;
                  else
                    ptinfo->pttype[FIRST] = PT_ORTHO;

                  if (!ME.ECdraw->line_state && !cirend &&
                      EFis_tangent (prev_ptinfo, ptinfo))
                    ptinfo->pttype[FIRST] = PT_TANGE;
                  else if (ME.ECdraw->line_state && 
                           prev_ptinfo->geomtype & SK_ARC &&
                           EFis_tangent (prev_ptinfo, ptinfo))
                  {
                    pttype = prev_ptinfo->pttype[FIRST];
                    if (pttype == PT_HORIZ || pttype == PT_VERT)
                      prev_ptinfo->pttype[FIRST] = PT_TANGM;
                    else
                      ptinfo->pttype[FIRST] = PT_TANGE;
                  }
                }
                else 
                {
                  BSmkvec (&msg_loc, dumvec, line1->point1, line1->point2);
                  value = fabs (BSdotp (&msg_loc, dumvec, ME.ECdraw->xvec));
                  if (fabs (1.0 - value) <= dottol)
                    ptinfo->pttype[FIRST] = PT_PT1_HORIZ;
                  else
                    ptinfo->pttype[FIRST] = PT_PT1_VERT;
                }
              }

              if (cirend && tolfound && !tanarc)
              {
                BSmdstptcv (cirarccv, pt, &par, projpt, &mdist, &msg_loc);
                OM_BLOCK_MOVE (projpt, pt, sizeof (IGRpoint));
                if (cmdtype == VARPROFILE)
                  ptinfo->pttype[SECOND] = PT_ONCIRC;
              }
              else if (inttolfound[0] && (tolfound || inttolfound[1]))
              {
                if (tolfound)
                  line2 = &inttol_constr_lines[inttol_constr_inx[0]];
                else
                  line2 = &inttol_constr_lines[inttol_constr_inx[1]];

                MA2lnisect (&msg_loc, line1, line2, &lentol, intpt,
                            &par, &otherpar);
                if (msg_loc == MSSUCC)
                {
                  OM_BLOCK_MOVE (intpt, pt, sizeof (IGRpoint));
                  if (cirend && !tanarc)
                  {
                    BSmdstptcv (cirarccv, pt, &par, projpt, &mdist, &tmp_msg_loc);
                    OM_BLOCK_MOVE (projpt, pt, sizeof (IGRpoint));
                  }
                }
                else
                {
                  inttol_constr_inx[0] = -1;
                  inttol_constr_inx[1] = -1;
                }

                if (cmdtype == VARPROFILE && msg_loc == MSSUCC)
                {
                  if (cirend)
                    ptinfo->pttype[SECOND] = PT_ONCIRC;
                  else if (tolfound)
                  {
                    BSEXTRACTPAR (&msg_loc, BSTOLORTHOVEC, dottol);
                    BSmkvec (&msg_loc, dumvec, line2->point1, line2->point2);
                    value = fabs (BSdotp (&msg_loc, dumvec, ME.ECdraw->xvec));
                    if (fabs (1.0 - value) <= dottol)
                      ptinfo->pttype[SECOND] = PT_PT1_HORIZ;
                    else
                      ptinfo->pttype[SECOND] = PT_PT1_VERT;
                  }
                  else
                    ptinfo->pttype[SECOND] = PT_PT1_VERT;
                }
              }
              else if (cirend && inttolfound[0] && !tanarc)
              {
                line = &inttol_constr_lines[inttol_constr_inx[0]];
                ptr1 = twopolecv->poles;
                ptr2 = &twopolecv->poles[3];
                OM_BLOCK_MOVE (line->point1, ptr1, sizeof (IGRpoint));
                OM_BLOCK_MOVE (line->point2, ptr2, sizeof (IGRpoint));
                for (i=0; i<3; i++)
                {
                  dumvec[i] = ptr2[i] - ptr1[i];
                  ptr1[i] += MAX_LEN * dumvec[i];
                  ptr2[i] -= MAX_LEN * dumvec[i];
                }
                BScvcv_int (&msg_loc, cirarccv, twopolecv, 
                            (int *) &count, &intpts, &par1, &par2, &dum, 
                            &ptr, &ptr1, &ptr2);
                if (msg_loc == BSSUCC && count)
                {
                  if (count > 1)
                    BSmdstptcv (cirarccv, pt, &par, projpt, &mdist, &msg_loc);
                  if (count == 1 ||
                      BSdistptpt (&msg_loc, intpts, projpt) <
                      BSdistptpt (&msg_loc, &intpts[3], projpt))
                    OM_BLOCK_MOVE (intpts, pt, sizeof (IGRpoint));
                  else 
                    OM_BLOCK_MOVE (&intpts[3], pt, sizeof (IGRpoint));
                }
                else
                {
                  count = 0;
                  BSmdistcvcv (cirarccv, twopolecv, (int *) &count, &par1, &par2,
                               &parpt1, &parpt2, &mdist, &msg_loc);
                  if (count == 1)
                    OM_BLOCK_MOVE (*parpt1, pt, sizeof (IGRpoint));
                }

                if (intpts)
                {
                  om$dealloc (ptr = intpts);
                  intpts = NULL;
                }
                if (par1)
                {
                  om$dealloc (ptr = par1);
                  par1 = NULL;
                }
                if (par2)
                {
                  om$dealloc (ptr = par2);
                  par2 = NULL;
                }
                if (parpt1)
                {
                  om$dealloc (ptr = parpt1);
                  parpt1 = NULL;
                }
                if (parpt2)
                {
                  om$dealloc (ptr = parpt2);
                  parpt2 = NULL;
                }

                if (cmdtype == VARPROFILE)
                  ptinfo->pttype[SECOND] = PT_ONCIRC;
              }
              else if (supported_event && cmdtype == VARPROFILE)
              {
                ptinfo->pttype[SECOND] = PT_PROJEVENT;
                ptinfo->event = event;
              }
            } /* end of tolfound || inttolfound[0] condition */
            else if (cirend)
            {
              /*
               * If the endpt of an arc is being defined, then project it onto
               * the arc. In case of a 2-pt arc, this is not required.
               */
              if (ME.ECdraw->local_state == 1 || ME.ECdraw->local_state == 2)
              {
                BSmdstptcv (cirarccv, pt, &par, projpt, &mdist, &msg_loc);
                OM_BLOCK_MOVE (projpt, pt, sizeof (IGRpoint));
              }
              if (cmdtype == VARPROFILE)
              {
                ptinfo->pttype[FIRST] = PT_ONCIRC;
                if (supported_event)
                {
                  ptinfo->pttype[SECOND] = PT_PROJEVENT;
                  ptinfo->event = event;
                }
              }
            }

            /*
             * Error checking on the input data point -
             * 1) Check if the new data pt is same as the previous point.  If in 
             *    arc mode, disallow a circle.
             * 2) Check if the chorvec is parallel to the previous tangent in case
             *    of a tangent-arc placement mode.  Disallow it.
             */
            if (BSdistptpt (&msg_loc, pt, ME.ECdraw->prevpts[0]) <= lentol)
            {
              if (ME.ECdraw->line_state || ME.ECdraw->horver_state ||
                  ME.ECdraw->local_state == 0)
              {
                ex$message(msgnumb=EMS_S_DegeneracyPtIgnored)
                break;
              }
              else if (ME.ECdraw->cur_comp_inx)
              {
                ex$message(msgnumb=EMS_S_CircleInCompCrvIgnored)
                break;
              }
            }
            else if (tanarc)
            {
              BSmkvec (&msg_loc, dumvec, me->prevpts[0], pt);
              BSnorvec (&msg_loc, dumvec);
              value = fabs (BSdotp(&msg_loc, dumvec, me->tanvec));
              if (fabs(1.0 - value) <= dottol)
              {
                ex$message(msgnumb=EMS_S_DegeneracyPtIgnored)
                break;
              }
            }

            if (cmdtype == VARPROFILE)
              ME.ECdraw->num_pts++;
            process_ele = TRUE;
            if (ME.ECdraw->horver_state)
              ME.super_cmd->state = ME.ECdraw->horver_state;
            else
              ME.super_cmd->state = PROCESS_STATE;
            ME.ECdraw->angle_constr = FALSE;
            break;

          case EX_BACK_UP:
            if (ME.ECdraw->horver_state)
            {
              ME.ECdraw->horver_state = FALSE;
              if (form_ptr)
              {
                FIg_set_state_off (form_ptr, HORCONSTR_STATE);
                FIg_set_state_off (form_ptr, VERCONSTR_STATE);
                EFdo_form_abling (form_ptr, NEXTPT_STATE, FALSE, 
                                  ME.ECdraw->symm_state, me->mytype);
              }
            }
            else if (ME.ECdraw->symm_state == BEGINSYMM1_STATE)
              ME.super_cmd->state = ENDSYMM_STATE;
            else if (ME.ECdraw->symm_state == BEGINSYMM2_STATE)
              ME.super_cmd->state = BEGINSYMM1_STATE;
            else if (ME.ECdraw->line_state || ME.ECdraw->local_state == 0 ||
                     ME.ECdraw->local_state == 3 || ME.ECdraw->local_state == 4 )
            {
              /*
               * Backup during line placement, center-pt placement of a 3-pt arc,
               * or end-pt placement of a 2-pt arc, implies redefine the previous
               * profile segment.
               */
              if (ME.ECdraw->line_state)
                ME.ECdraw->line_state = FALSE;
                
              if (ME.ECdraw->symm_state == INSYMM_STATE &&
                  ME.ECdraw->symm_compinx == 0)
              {
                EFdisp_inttol_constr (1, &ME.ECdraw->symm_line,
                                      &ME.ECelements->active_display, env, 
                                      ME.ECdraw->constr_color,
                                      FULL_STYLE, GRbe);
                ME.ECdraw->symm_state = FALSE;

                if (form_ptr)
                {
                  FIg_set_state_off (form_ptr, BEGINSYMM1_STATE);
                  EFdo_form_abling (form_ptr, NEXTPT_STATE, FALSE, FALSE,
                                    me->mytype);
                }
              }
              
              num_pts_del = 1;
              if (ME.ECdraw->cur_comp_inx == 0)
              {
                if (ME.super_cmd->mytype == MODIFYPROFILE)
                  ME.super_cmd->state = MODIFY_ABORT_STATE;
                else
                  ME.super_cmd->state = FIRSTPT_STATE;
              }
              else
              {
                if (ME.ECdraw->cur_comp_inx > SECOND)
                {
                  EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
                  stat_OM = om$get_objid_at_index (osnum = fileos,
                                                   objid = ME.ECdraw->compobj,
                                                   p_chanselect = &chan_to_comps,
                                                   index = ME.ECdraw->cur_comp_inx-1,
                                                   objidaddr = &eleobj, 
                                                   osnumaddr = &dumos);
                  EMomerr_exit (stat_OM, ret_end);
                  if (ME.ECdraw->symm_state)
                  {
                    stat_OM = om$get_objid_at_index (osnum = fileos,
                                                     objid = ME.ECdraw->symm_compobj,
                                                     p_chanselect = &chan_to_comps,
                                                     index = ME.ECdraw->symm_compinx-1,
                                                     objidaddr = &symm_eleobj, 
                                                     osnumaddr = &dumos);
                    EMomerr_exit (stat_OM, ret_end);
                  }
                }
                else
                {
                  eleobj = ME.ECdraw->firstobj;
                  if (ME.ECdraw->symm_state)
                    symm_eleobj = ME.ECdraw->symm_firstobj;
                }

                if (aflag)
                {
                dpmode = GRbe;
                stat_OM = om$send (msg = message GRgraphics.GRdisplay
                                         (&msg_loc, &disp.md_env.matrix_type,
                                          disp.md_env.matrix, &dpmode, &disp.md_id),
                                   targetid = eleobj, targetos = fileos);
                }
                else
                {
                dpmode = GRbe;
                stat_OM = om$send (msg = message GRgraphics.GRdisplay
                                         (&msg_loc, &env->md_env.matrix_type,
                                          env->md_env.matrix, &dpmode, &env->md_id),
                                   targetid = eleobj, targetos = fileos);
                }
                EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);

                if (ME.ECdraw->symm_state)
                {
                  if (aflag)
                  {
                  stat_OM = om$send (msg = message GRgraphics.GRdisplay
                                           (&msg_loc, &disp.md_env.matrix_type,
                                            disp.md_env.matrix, &dpmode, &disp.md_id),
                                     targetid = symm_eleobj, targetos = fileos);
                  }
                  else
                  {
                  stat_OM = om$send (msg = message GRgraphics.GRdisplay
                                           (&msg_loc, &env->md_env.matrix_type,
                                            env->md_env.matrix, &dpmode, &env->md_id),
                                     targetid = symm_eleobj, targetos = fileos);
                  }
                  EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);
                }
           
                om$get_classid (objid = eleobj, osnum = fileos,
                                p_classid = &objclass);
                if (om$is_ancestry_valid (subclassid = objclass,
                    superclassid = OPP_GR3dcirarc_class_id) == OM_S_SUCCESS)
                  num_pts_del = 2;

                stat_OM = om$send (msg = message GRgraphics.GRdelete (&msg_loc, env), 
                                   targetid = eleobj, targetos = fileos);
                EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);

                if (ME.ECdraw->symm_state)
                {
                  stat_OM = om$send (msg = message GRgraphics.GRdelete (&msg_loc, env),
                                     targetid = symm_eleobj, 
                                     targetos = fileos);
                  EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);
                }

                if (ME.ECdraw->cur_comp_inx == SECOND+1)
                {
                  compid.objid = ME.ECdraw->compobj;
                  compid.osnum = fileos;
                  stat_OM = om$send (msg = message GRconnector.GRdisconn (&msg_loc, &compid),
                                     p_chanselect = &chan_to_comps,
                                     senderid = compid.objid, 
                                     targetos = fileos);
                  EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);

                  stat_OM = om$send (msg = message GRgraphics.GRdelete (&msg_loc, env), 
                                     targetid = ME.ECdraw->compobj,
                                     targetos = fileos);
                  EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);
                }
                if (ME.ECdraw->symm_state && 
                    ME.ECdraw->symm_compinx == SECOND+1)
                {
                  compid.objid = ME.ECdraw->symm_compobj;
                  compid.osnum = fileos;
                  stat_OM = om$send (msg = message GRconnector.GRdisconn (&msg_loc, &compid),
                                     p_chanselect = &chan_to_comps, 
                                     senderid = compid.objid, targetos = fileos);
                  EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);

                  stat_OM = om$send (msg = message GRgraphics.GRdelete (&msg_loc, env),
                                     targetid = ME.ECdraw->symm_compobj,
                                     targetos = fileos);
                  EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);
                }

                ME.ECdraw->cur_comp_inx--;
                if (ME.ECdraw->symm_state)
                  ME.ECdraw->symm_compinx--;
                ME.ECdraw->line_state = TRUE;

                /*
                 * Remove eleobj from the Smart Sketch List to prevent ghost
                 * elements from persisting.
                 */
                if (smart_sketch_active)
                {
                  ss$remove_from_list ( objid = eleobj,
                                        osnum = fileos );
                }

                if (ME.ECdraw->cur_comp_inx)
                {
                  OM_BLOCK_MOVE(pts2[0], pt, sizeof(IGRpoint));
                  stat_func = EFobtain_tangent (ME.ECdraw->cur_comp_inx,
                                                ME.ECdraw->compobj, 
                                                ME.ECdraw->firstobj,
                                                ME.ECdraw->firstpt, 
                                                ME.ECdraw->firsttan,
                                                fileos, env, NULL, pt, dumvec);
                  EMerr_hndlr (!stat_func, stat_OM, OM_E_ABORT, ret_end);

                  OM_BLOCK_MOVE ( dumvec, ME.ECdraw->tanvec, sizeof(IGRvector));

                  ptr = ME.ECdraw->prevpts[0];
                  for (i=0; i<3; i++)
                    ptr[i] = pt[i] + dumvec[i];

                  tol_constr_inx = NOT_HORIZVERT_CONSTR;
                  /*
                   * goto adjusting the tolerance bands
                   */
                  process_ele = FALSE;
                  ME.super_cmd->state = PROCESS_STATE;
                }
                else
                {
                  if (ME.super_cmd->mytype == MODIFYPROFILE)
                    ME.super_cmd->state = MODIFY_ABORT_STATE;
                  else
                    ME.super_cmd->state = FIRSTPT_STATE;
                }
              }

              if (cmdtype == VARPROFILE)
                ME.ECdraw->num_pts -= num_pts_del;
            }
            else
            {
              /*
               * backup during the end-pt placement of a 3-pt arc (local_state = 1 or 2).
               */
              OM_BLOCK_MOVE (ME.ECdraw->prevpts[0], pt, sizeof (IGRpoint));
              stat_func = EFobtain_tangent (ME.ECdraw->cur_comp_inx,
                                            ME.ECdraw->compobj, ME.ECdraw->firstobj, 
                                            ME.ECdraw->firstpt, ME.ECdraw->firsttan,
                                            fileos, env, NULL, NULL, dumvec);
              EMerr_hndlr (!stat_func, stat_OM, OM_E_ABORT, ret_end);
              ptr = ME.ECdraw->prevpts[0];
              for (i=0; i<3; i++)
                ptr[i] = pt[i] + dumvec[i];
              
              nochg_local_state = TRUE;
              ME.ECdraw->local_state = 0;

              if (cmdtype == VARPROFILE)
                ME.ECdraw->num_pts--;

              tol_constr_inx = NOT_HORIZVERT_CONSTR;
              process_ele = FALSE;
              ME.super_cmd->state = PROCESS_STATE;
            }
            ME.ECdraw->angle_constr = FALSE;
            break;

          case EX_RJT_MOVEON:
            if (ME.ECdraw->horver_state)
            {
              ME.ECdraw->horver_state = FALSE;
              ME.ECdraw->angle_constr = FALSE;
              if (form_ptr)
              {
                FIg_set_state_off (form_ptr, HORCONSTR_STATE);
                FIg_set_state_off (form_ptr, VERCONSTR_STATE);
                EFdo_form_abling (form_ptr, NEXTPT_STATE, FALSE,
                                  ME.ECdraw->symm_state, me->mytype);
              }
            }
            /*
             * Check if any constraint was active .. if so, go into the frozen
             * state i.e. angle_constr = TRUE.
             */
            else if (tol_constr_inx >= 0 &&
                     !angle_constr &&
                     (ME.ECdraw->horver_state ||
                     !(!ME.ECdraw->line_state && ME.ECdraw->local_state > 0)))
            {
              ptr1 = tol_constr_lines[tol_constr_inx].point1;
              ptr2 = tol_constr_lines[tol_constr_inx].point2;
              for (i=0; i<3; i++)
                dumvec[i] = ptr2[i] - ptr1[i];
              ptr1 = ME.ECdraw->angle_constr_line.point1;
              ptr2 = ME.ECdraw->angle_constr_line.point2;
              OM_BLOCK_MOVE (ME.ECdraw->prevpts[0], ptr1, sizeof (IGRpoint));
              for (i=0; i<3; i++)
                ptr2[i] = ptr1[i] + dumvec[i] * 10.0;

              ME.ECdraw->angle_constr = TRUE;
              ME.ECdraw->angle_tol_constr_inx = tol_constr_inx;
            }
            /*
             * In case of modification, moveon in the first segment means quit.
             */
            else if (ME.super_cmd->mytype == MODIFYPROFILE &&
                     ME.ECdraw->cur_comp_inx == 0 && 
                     (ME.ECdraw->line_state || ME.ECdraw->local_state == 0))
            {
               ME.super_cmd->state = MODIFY_ABORT_STATE;
            }
            /*
             * MOVEON while sketching the first line segment means generate a point.
             */
            else if (ME.ECdraw->cur_comp_inx == 0 && ME.ECdraw->line_state)
            {
              process_ele = TRUE;
              tol_constr_inx = IS_HORIZVERT_CONSTR;
              OM_BLOCK_MOVE (ME.ECdraw->firstpt, pt, sizeof(IGRpoint));
              ME.super_cmd->state = PROCESS_STATE;
            }
            /*
             * switch the arc direction if we are in the ARC mode.
             */
            else if (!ME.ECdraw->line_state && ME.ECdraw->local_state == 1)
            {
              ME.ECdraw->local_state = 2;
            }
            else if (!ME.ECdraw->line_state && ME.ECdraw->local_state == 2)
            {
              ME.ECdraw->local_state = 1; 
            }
            else if (!ME.ECdraw->line_state && ME.ECdraw->local_state == 3)
            {
              ME.ECdraw->local_state = 4;
            }
            else if (!ME.ECdraw->line_state && ME.ECdraw->local_state == 4)
            {
              ME.ECdraw->local_state = 3;
            }
            else if (ME.ECdraw->symm_state)
            {
              ME.super_cmd->state = ENDSYMM_STATE;
            }
            /* 
             * If the last point and the first point are sufficiently 
             * close, and there are more than 2 components, then give the 
             * option to the user to Autoclose (go to the AUTOCLOSE_STATE).
             */
            else if (ME.super_cmd->mytype == VARPROFILE &&
                     ME.ECdraw->cur_comp_inx > 2 &&
                     (BSdistptpt (&msg_loc, ME.ECdraw->prevpts[0],
                      ME.ECdraw->firstpt) <= 3*ME.ECdraw->wintol))
            {
              ME.super_cmd->state = AUTOCLOSE_STATE;
            }
            /*
             * for all other cases, assume end of profile.
             */
            else
            {
              ME.super_cmd->state = END_PROFILE_STATE;
            }

            break;

          case EX_VALUE:
            value = event.event.value;
            if (!strcmp (valuetype, GRIO_DISTANCE))
            {
              /*
               * A distance value is given. The point can be generated
               * unambiguously.
               */

              ME.ECdraw->dist = value;

              cirend = !ME.ECdraw->line_state && ME.ECdraw->local_state != 0;
              if (ME.ECdraw->horver_state)
                cirend = FALSE;
              tanarc = !ME.ECdraw->line_state && 
                       (ME.ECdraw->local_state == 3 || ME.ECdraw->local_state == 4);
       
              if (cmdtype == VARPROFILE)
              {
                num_pts = ME.ECdraw->num_pts;
                count = om$dimension_of (varray = ME.ECdraw->ptinfo);
                if (count <= num_pts)
                {
                  stat_OM = om$vla_set_dimension (varray = 
                             ME.ECdraw->ptinfo, size = num_pts + NUMPTS_INCR);
                  EMomerr_exit (stat_OM, ret_end);

                  inttol_constr_lines = ME.ECdraw->inttol_constr_lines;
                  pts = ME.ECdraw->inttolpt_store;
                  count = ME.ECdraw->num_inttol_constr;
                  for (i=0, j=0; i<count; i++, j+=2)
                  {
                    inttol_constr_lines[i].point1 = pts[j];
                    inttol_constr_lines[i].point2 = pts[j+1];
                  }
                }
                ptinfo = &ME.ECdraw->ptinfo[num_pts];

                if (!tanarc) 
                {
                  if (angle_constr)
                    inx = ME.ECdraw->angle_tol_constr_inx;
                  else
                    inx = tol_constr_inx;
                  if (inx < 0)
                  {
                    ptinfo->pttype[FIRST] = PT_ANGLE;
                    ptinfo->value[FIRST] = ME.ECdraw->angle;
                  }
                  else if (inx == TOL_HORIZ)
                    ptinfo->pttype[FIRST] = PT_HORIZ;
                  else if (inx == TOL_VERT)
                    ptinfo->pttype[FIRST] = PT_VERT;
                  else if (inx == TOL_COLL)
                    ptinfo->pttype[FIRST] = PT_COLL;
                  else
                    ptinfo->pttype[FIRST] = PT_ORTHO;
                }
                
                if (num_pts)
                  prev_ptinfo = &ME.ECdraw->ptinfo[num_pts-1];
                else
                  prev_ptinfo = NULL;

                if (tanarc)
                {
                  /*
                   * add the constraint on the centerpt.
                   */
                  ptinfo->pttype[FIRST] = PT_TANGE;
                  prev_ptinfo->geomtype = SK_ARC;
                }
                else if (!ME.ECdraw->line_state && !cirend && 
                    EFis_tangent (prev_ptinfo, ptinfo))
                  ptinfo->pttype[FIRST] = PT_TANGE;
                else if (ME.ECdraw->line_state && prev_ptinfo &&
                         prev_ptinfo->geomtype & SK_ARC &&
                         EFis_tangent (prev_ptinfo, ptinfo))
                {
                  /*
                   * The current line is tangent to the previous arc.
                   */
                  pttype = prev_ptinfo->pttype[FIRST];
                  if (pttype == PT_HORIZ || pttype == PT_VERT)
                    prev_ptinfo->pttype[FIRST] = PT_TANGM;
                  else
                    ptinfo->pttype[FIRST] = PT_TANGE;
                }

                ptinfo->pttype[SECOND] = !ME.ECdraw->line_state ? PT_RADIUS : PT_DIST;
                ptinfo->value[SECOND] = ME.ECdraw->dist;
                
                ME.ECdraw->num_pts++;
              }

              if (!tanarc)
              {
                line = angle_constr ?
                       angle_constr_line : &tol_constr_lines[tol_constr_inx],
                MAptlnproj (&msg_loc, lastpt, line, projpt, &par);
                EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, ret_end);
                if (par > 0)
                {
                  ptr1 = line->point1;
                  ptr2 = line->point2;
                }
                else
                {
                  ptr1 = line->point2;
                  ptr2 = line->point1;
                }
  
                BSmkvec (&msg_loc, dumvec, ptr1, ptr2);
                BSnorvec (&msg_loc, dumvec);
     
                ptr = ME.ECdraw->prevpts[0];
                pt[X] = ptr[X] + dumvec[X] * value;
                pt[Y] = ptr[Y] + dumvec[Y] * value;
                pt[Z] = ptr[Z] + dumvec[Z] * value;
                tol_constr_inx = NOT_HORIZVERT_CONSTR;
                process_ele = TRUE;
                ME.ECdraw->angle_constr = FALSE;
                if (ME.ECdraw->horver_state)
                  ME.super_cmd->state = ME.ECdraw->horver_state;
                else
                  ME.super_cmd->state = PROCESS_STATE;
              }
              else
              {
                BSmkvec (&msg_loc, vec1, ME.ECdraw->prevpts[0], 
                         dyngeomselect[0].dyngeom.tanarc.center);
                BSnorvec (&msg_loc, vec1);
                ME.ECdraw->prevpts[1][X] = ME.ECdraw->prevpts[0][X] + vec1[X] * value;
                ME.ECdraw->prevpts[1][Y] = ME.ECdraw->prevpts[0][Y] + vec1[Y] * value;
                ME.ECdraw->prevpts[1][Z] = ME.ECdraw->prevpts[0][Z] + vec1[Z] * value;
                OM_BLOCK_MOVE (ME.ECdraw->prevpts[1], pt, sizeof(IGRpoint));
                me->local_state = me->local_state == 3 ? 1 : 2;
                ME.super_cmd->state = NEXTPT_STATE;
              }
            }
            else
            {
              /*
               * An angle value is given. The next point will be constrained
               * along this angle.
               */

              ME.ECdraw->angle = value;
              dum = 1;
              if (ME.ECdraw->line_state || ME.ECdraw->horver_state ||
                  ME.ECdraw->local_state == 0)
              {
                MArotmx (&msg_loc, ME.ECdraw->zvec, &value, mat);
                EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, ret_end);

                ptr1 = ME.ECdraw->angle_constr_line.point1;
                ptr2 = ME.ECdraw->angle_constr_line.point2;
                MAptsxform (&msg_loc, &dum, mat, ME.ECdraw->xvec, projpt);
                EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, ret_end);
                OM_BLOCK_MOVE (ME.ECdraw->prevpts[0], ptr1, sizeof (IGRpoint));
                for (i=0; i<3; i++)
                  ptr2[i] = ptr1[i] + projpt[i] * 10.0;

                ME.ECdraw->angle_constr = TRUE;
                ME.ECdraw->angle_tol_constr_inx = -1;
              }
              else
              {
                /*
                 * defining the sweep of the arc ... check for arc direction.
                 */
                OM_BLOCK_MOVE (ME.ECdraw->zvec, dumvec, sizeof (IGRvector));
                if (me->local_state == 1 || me->local_state == 3) 
                {
                  for (i = 0; i < 3; i++)
                    dumvec[i] = -dumvec[i];
                }
                MAgrotmx (&msg_loc, dumvec, ME.ECdraw->prevpts[1], &value, mat);
                EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, ret_end);

                OM_BLOCK_MOVE (&event.event.button.x, pt, sizeof(IGRpoint));
                MAptsxform (&msg_loc, &dum, mat, ME.ECdraw->prevpts[0], pt);
                EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, ret_end);
              
                if (cmdtype == VARPROFILE)
                {
                  num_pts = ME.ECdraw->num_pts;
                  count = om$dimension_of (varray = ME.ECdraw->ptinfo);
                  if (count <= num_pts)
                  {
                    stat_OM = om$vla_set_dimension (varray = 
                              ME.ECdraw->ptinfo, size = num_pts + NUMPTS_INCR);
                    EMomerr_exit (stat_OM, ret_end);

                    inttol_constr_lines = ME.ECdraw->inttol_constr_lines;
                    pts = ME.ECdraw->inttolpt_store;
                    count = ME.ECdraw->num_inttol_constr;
                    for (i=0, j=0; i<count; i++, j+=2)
                    {
                      inttol_constr_lines[i].point1 = pts[j];
                      inttol_constr_lines[i].point2 = pts[j+1];
                    }
                  }
                  ptinfo = &ME.ECdraw->ptinfo[num_pts];

                  ptinfo->pttype[FIRST] = PT_ONCIRC;
                  ptinfo->pttype[SECOND] = PT_SWEEP;
                  ptinfo->value[SECOND] = ME.ECdraw->angle;

                  ME.ECdraw->num_pts++;
                }
                
                tol_constr_inx = NOT_HORIZVERT_CONSTR;
                process_ele = TRUE;
                ME.ECdraw->angle_constr = FALSE;
                ME.super_cmd->state = PROCESS_STATE;
              }
            }
            if (!is_lastpt) 
            {
              gr$get_last_point (buffer = (char *) &button);
              lastpt[0] = button.x;
              lastpt[1] = button.y;
              lastpt[2] = button.z;
            }
            EFrecord_last_point(lastpt, &ME.ECdraw->wingrid, &event.response, &event.event);
            break;

          case EX_STRING:
            if (ME.ECdraw->horver_state)
              goto ret_end;
            str = event.event.keyin;
            if (strlen (str) > MAX_WORD_LEN)
              goto ret_end;
            strcpy (cmpstr, "");
            if (str[0] == '\r')
              break;
            count = sscanf (str, "%s %s", cmpstr, cmpstr_next);
            if (count == 1)
              strcpy (cmpstr_next, "");

            ME.ECdraw->return_state = NEXTPT_STATE;

            if (EFstring_match (cmpstr, "ARC"))
            {
              ME.super_cmd->state = ARC_STATE;
              if (form_ptr)
                FIg_set_state_on (form_ptr, ARC_STATE);
            }

            else if (EFstring_match (cmpstr, "R"))
            {
              ME.super_cmd->state = ARCBYRADIUS_STATE;
              if (form_ptr)
                FIg_set_state_on (form_ptr, ARCBYRADIUS_STATE);
            }
            
            else if (EFstring_match (cmpstr, "LINE"))
            {
              ME.super_cmd->state = LINE_STATE;
              if (form_ptr)
                FIg_set_state_on (form_ptr, LINE_STATE);
            }
            
            else if (EFstring_match (cmpstr, "CLOSE") && 
                     ME.super_cmd->mytype != MODIFYPROFILE)
            {
              /*
               * the user should be in the line mode or arc sweep definition mode.
               * user could also be placing could close the first or second non-tangent arc.
               */
              if ((ME.ECdraw->cur_comp_inx > 1 &&  
                  (ME.ECdraw->line_state || 
                  (!ME.ECdraw->line_state && ME.ECdraw->local_state > 0))) ||
                  (ME.ECdraw->cur_comp_inx <= 1 && 
                  (!ME.ECdraw->line_state && (me->local_state == 1 || me->local_state ==2 ))))
              {
                end_profile = TRUE;
                if (me->cur_comp_inx >= 1 && 
                    (me->local_state == 1 || me->local_state == 2))
                  auto_close_sketch = TRUE;
                /*
                 * Simulate an event as if the first point was selected by the user.
                 * KLUDGE: Set the subtype of the event to 0, so that journalling and
                 * smart sketch folks do not mess with it.
                 */
                eventsize = sizeof(struct GRevent);
                event.response = EX_DATA;
                event.subtype = 0;
                OM_BLOCK_MOVE (ME.ECdraw->firstpt, &event.event.button.x, sizeof(IGRpoint));
                stat_OM = ex$putque (msg = &msg_loc, response = &event.response,
                                     byte = &eventsize, buffer = (char *)&event.event);
                EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);
                ME.super_cmd->state = NEXTPT_STATE;
                if (form_ptr)
                  FIg_set_state_off (form_ptr, AUTOCLOSE_STATE);
              }
            }
            
            else if (EFstring_match (cmpstr, "W"))
            {
              ME.super_cmd->state = REVCONSTR_STATE;
              if (form_ptr)
                FIg_set_state_on (form_ptr, REVCONSTR_STATE);
            }

            else if (EFstring_match (cmpstr, "DELETE"))
              ME.super_cmd->state = DELCONSTR_STATE;

            else if (EFstring_match (cmpstr, "ERASE"))
            {
              /*
               * this used to be a two word shortcut (DELETE ALL).  Since D is
               * used for delete, "E" is for ERASE.
               */
              ME.super_cmd->state = DELALLCONSTR_STATE;
              if (form_ptr)
                FIg_set_state_on (form_ptr, DELALLCONSTR_STATE);
            }
#if 0
            else if (cmdtype == VARPROFILE)
              goto ret_end;
#endif
            /*
             * rest of the options are specific to Line/Arc composite
             * mode only.
             */
            else if (EFstring_match (cmpstr, "PARALLEL"))
            {
              ME.super_cmd->state = PARCONSTR_STATE;
              if (form_ptr)
              {
                FIg_set_state_on (form_ptr, PARCONSTR_STATE);
                EFdo_form_abling (form_ptr, PARCONSTR_STATE, FALSE, FALSE,
                                  me->mytype);
              }
            }

            else if (EFstring_match (cmpstr, "NORMAL"))
            {
              ME.super_cmd->state = NORCONSTR_STATE;
              if (form_ptr)
              {
                FIg_set_state_on (form_ptr, NORCONSTR_STATE);
                EFdo_form_abling (form_ptr, NORCONSTR_STATE, FALSE, FALSE,
                                  me->mytype);
              }
            }

            else if (EFstring_match (cmpstr, "HORIZONTAL"))
            {
              ME.super_cmd->state = HORCONSTR_STATE;
              if (form_ptr)
              {
                FIg_set_state_on (form_ptr, HORCONSTR_STATE);
                EFdo_form_abling (form_ptr, NEXTPT_STATE, TRUE, FALSE,
                                  me->mytype);
              }
              if (EFstring_match (cmpstr_next, "VERTICAL"))
              {
                ME.super_cmd->state = HORVERCONSTR_STATE;
                if (form_ptr)
                  FIg_set_state_on (form_ptr, VERCONSTR_STATE);
              }
            }

            else if (EFstring_match (cmpstr, "VERTICAL"))
            {
              ME.super_cmd->state = VERCONSTR_STATE;
              if (form_ptr)
              {
                FIg_set_state_on (form_ptr, VERCONSTR_STATE);
                EFdo_form_abling (form_ptr, NEXTPT_STATE, TRUE, FALSE,
                                  me->mytype);
              }
              if (EFstring_match (cmpstr_next, "HORIZONTAL"))
              {
                ME.super_cmd->state = HORVERCONSTR_STATE;
                if (form_ptr)
                  FIg_set_state_on (form_ptr, HORCONSTR_STATE);
              }
            }

            else if (EFstring_match (cmpstr, "I"))
            {
              ME.super_cmd->state = COLLCONSTR_STATE;
              if (form_ptr)
              {
                FIg_set_state_on (form_ptr, COLLCONSTR_STATE);
                EFdo_form_abling (form_ptr, COLLCONSTR_STATE, FALSE, FALSE,
                                  me->mytype);
              }
              if (EFstring_match (cmpstr_next, "ORTHOGONAL"))
              {
                ME.super_cmd->state = COLORTHCONSTR_STATE;
                if (form_ptr)
                  FIg_set_state_on (form_ptr, ORTHOCONSTR_STATE);
              }
            }

            else if (EFstring_match (cmpstr, "ORTHOGONAL"))
            {
              ME.super_cmd->state = ORTHOCONSTR_STATE;
              if (form_ptr)
              {
                FIg_set_state_on (form_ptr, ORTHOCONSTR_STATE);
                EFdo_form_abling (form_ptr, ORTHOCONSTR_STATE, FALSE, FALSE,
                                  me->mytype);
              }
              if (EFstring_match (cmpstr_next, "COLLINEAR"))
              {
                ME.super_cmd->state = COLORTHCONSTR_STATE;
                if (form_ptr)
                  FIg_set_state_on (form_ptr, COLLCONSTR_STATE);
              }
            }

            else if (EFstring_match (cmpstr, "SYMMETRY"))
            {
              ME.super_cmd->state = BEGINSYMM1_STATE;
              if (form_ptr)
              {
                FIg_set_state_on (form_ptr, BEGINSYMM1_STATE);
                EFdo_form_abling (form_ptr, NEXTPT_STATE, FALSE, TRUE,
                                  me->mytype);
              }
            }

            else
              goto ret_end;

            if (!is_lastpt) 
            {
              gr$get_last_point (buffer = (char *) &button);
              lastpt[0] = button.x;
              lastpt[1] = button.y;
              lastpt[2] = button.z;
            }
            EFrecord_last_point(lastpt, &ME.ECdraw->wingrid, &event.response, &event.event);
            break;

          default:
            goto ret_end;
        }
        break;

      case PROCESS_STATE:
        addele = FALSE;
        dosymm_ele = FALSE;
        tosymm2 = FALSE;
        toendsymm = FALSE;

        if (ME.ECdraw->line_state && process_ele)
        {
          /*
           * A line-segment has been fully defined starting from prevpts[0]
           * to pt. If this segment is degenerate, construct a point instead.
           * Also record the tangent-vector in the direction of this segment
           * (if not a point).
           */

          if (ME.ECdraw->symm_state != BEGINSYMM1_STATE &&
              ME.ECdraw->symm_state != BEGINSYMM2_STATE)
          {
            poles = twopolecv->poles;
            OM_BLOCK_MOVE (ME.ECdraw->prevpts[0], poles, sizeof (IGRpoint));
            OM_BLOCK_MOVE (pt, &poles[3], sizeof (IGRpoint));

            old_weight = const_list.display->weight;
            if (!ME.ECdraw->cur_comp_inx &&
                BSdistptpt (&msg_loc, pt, ME.ECdraw->prevpts[0]) <= lentol)
            {
              objclass = OPP_GR3dpoint_class_id;
              const_list.display->weight += 2;
            }
            else
              objclass = OPP_GR3dlineseg_class_id;

            const_list.geometry = (IGRchar *) twopolecv;
            stat_OM = om$construct (classid = objclass,
                       msg = message GRgraphics.GRconstruct (&const_list), 
                       osnum = fileos, p_objid = &eleobj);
            const_list.display->weight = old_weight;
            EMomerr_exit (stat_OM, ret_end);
            EMerr_hndlr (EMSerror (*const_list.msg), stat_OM, OM_E_ABORT,
                         ret_end);
 
            if (ME.ECdraw->symm_state)
              dosymm_ele = TRUE;
            addele = TRUE;
          }
          
          /*
           * Redefine the current tangent vector.
           */
          BSmkvec (&msg_loc, ME.ECdraw->tanvec, ME.ECdraw->prevpts[0], pt);
          BSnorvec (&msg_loc, ME.ECdraw->tanvec);
        }
        else if (process_ele && ME.ECdraw->local_state > 0)
        {
          /*
           * A circular arc has been fully defined, starting from prevpts[0],
           * center at prevpts[1] and ending at pt.  In case of the 
           * 2-pt tangent arc, compute the new centerpt based on pt.
           */
          OM_BLOCK_MOVE (ME.ECdraw->zvec, dumvec, sizeof (IGRvector));
          if (me->local_state == 1 || me->local_state == 3) 
          {
            for (i = 0; i < 3; i++)
              dumvec[i] = -dumvec[i];
          }
          if (ME.ECdraw->local_state == 3 || ME.ECdraw->local_state == 4) 
          {
            EMfind_tanarc_centerpt (&msg_loc, me->prevpts[0], pt, me->tanvec, 
                                    dumvec, me->prevpts[1], &parallel);
            EMerr_hndlr (msg_loc != BSSUCC || parallel, stat_OM, OM_E_ABORT, ret_end);
          }

          /*
           * First check the endpt is same as beginning, thus producing a
           * circle. If so create a circle instead.
           */          
          if (BSdistptpt (&msg_loc, pt, ME.ECdraw->prevpts[0]) <= lentol)
          {
            BSprepcircp (&msg_loc, ME.ECdraw->prevpts[1],
                         ME.ECdraw->prevpts[0], dumvec, cirarccv, dumvec, &dumint);
            EMerr_hndlr (msg_loc != BSSUCC, stat_OM, OM_E_ABORT, ret_end);
            objclass = OPP_GR3dcircle_class_id;

            if (cmdtype == VARPROFILE)
            {
              ptinfo = ME.ECdraw->ptinfo;
              pttypes = ptinfo[FIRST].pttype;
              pttypes[FIRST] = pttypes[SECOND] = PT_NULL;
              pttypes = ptinfo[SECOND].pttype;
              if (pttypes[FIRST] != PT_EVENT)
                pttypes[FIRST] = PT_NULL;
              ptinfo[SECOND].geomtype = SK_CIRCLE;
            }
          }
          else
          {
            BSprepcarc (&msg_loc, ME.ECdraw->prevpts[0], ME.ECdraw->prevpts[1],
                        pt, dumvec, cirarccv, dumvec, &dumint);
            EMerr_hndlr (msg_loc != BSSUCC, stat_OM, OM_E_ABORT, ret_end);
            objclass = OPP_GR3dcirarc_class_id;
          }

          const_list.geometry = (IGRchar *) cirarccv;
          stat_OM = om$construct (classid = objclass,
                                  msg = message GRgraphics.GRconstruct (&const_list), 
                                  osnum = fileos, p_objid = &eleobj);
          EMomerr_exit (stat_OM, ret_end);
          EMerr_hndlr (EMSerror (*const_list.msg), stat_OM, OM_E_ABORT, ret_end);

          if (ME.ECdraw->symm_state)
            dosymm_ele = TRUE;

          /*
           * Compute the new tangent vector which is perpendicular to the vector
           * defining the center and the end-pt of the arc.
           */
          BSmkvec (&msg_loc, vec1, ME.ECdraw->prevpts[1], pt);
          BScrossp (&msg_loc, dumvec, vec1, ME.ECdraw->tanvec);
          BSnorvec (&msg_loc, ME.ECdraw->tanvec);
          addele = TRUE;
        }
       
        if (dosymm_ele)
        {
          stat_OM = om$send (msg = message GRgraphics.GRcopy 
                                   (&msg_loc, env, env, &symm_eleobj), 
                             targetid = eleobj,
                             targetos = fileos);
          EMomerr_exit (stat_OM, ret_end);
          EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, ret_end);

          stat_OM = om$send (msg = message GRgraphics.GRxform 
                                   (&msg_loc, env, &ME.ECdraw->symm_mattyp, 
                                    ME.ECdraw->symm_mat, &symm_eleobj), 
                             targetid = symm_eleobj,
                             targetos = fileos);
          EMomerr_exit (stat_OM, ret_end);
          EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, ret_end);
        }

        /*
         * If this data point completely defined an element, then add it
         * to the running composite curve.
         */

        if (addele)
        {
          inxlim = dosymm_ele ? 2 : 1;
          for (inx=FIRST; inx<inxlim; inx++)
          {
            if (inx == FIRST)
            {
              compinx  = &ME.ECdraw->cur_comp_inx;
              firstobj = &ME.ECdraw->firstobj;
              compobj  = &ME.ECdraw->compobj;
              ele      = eleobj;
            }
            else
            {
              compinx  = &ME.ECdraw->symm_compinx;
              firstobj = &ME.ECdraw->symm_firstobj;
              compobj  = &ME.ECdraw->symm_compobj;
              ele      = symm_eleobj;
            }

            if (*compinx == FIRST)
              *firstobj = ele;
            else 
            {
              if (*compinx == SECOND)
              {
                stat_OM = om$construct (classid = OPP_GRcompcurve_class_id,
                                        msg = message GRgraphics.GRconstruct (&const_list),
                                        osnum = fileos, p_objid = compobj);
                EMomerr_exit (stat_OM, ret_end);
                EMerr_hndlr (EMSerror (*const_list.msg), stat_OM, OM_E_ABORT,
                             ret_end);

                count = 2;
                geominfo[0].located_obj.objid = *firstobj;
                geominfo[1].located_obj.objid = ele;
              }
              else
              {
                count = 1;
                geominfo[0].located_obj.objid = ele;
              }

              stat_OM = om$send (msg = message GRcompcurve.EMmakecomp
                                       (&msg_loc, env, count, geominfo, &dum),
                                 targetid = *compobj, targetos = fileos);
              EMomerr_exit (stat_OM, ret_end);
              EMerr_hndlr (EMSerror (msg_loc) || dum == 0 || dum == 1, stat_OM,
                           OM_E_ABORT, ret_end);
            }
            (*compinx)++;
            
            if (aflag)
            {
            dpmode = GRbd;
            stat_OM = om$send (msg = message GRgraphics.GRdisplay (&msg_loc,
                                     &disp.md_env.matrix_type, disp.md_env.matrix,
                                     &dpmode, &disp.md_id), 
                               targetid = ele, targetos = fileos);
            }
            else
            {
            dpmode = GRbd;
            stat_OM = om$send (msg = message GRgraphics.GRdisplay (&msg_loc,
                                     &env->md_env.matrix_type, env->md_env.matrix,
                                     &dpmode, &env->md_id), 
                               targetid = ele, targetos = fileos);
            }
            EMomerr_exit (stat_OM, ret_end);
            EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, ret_end);
            /*
             * If smart sketch is active, we add the new element to the 
             * list of "known" SS objects and activate the last keypoint.
             */
            if (smart_sketch_active)
            {
              ss$add_to_list( objid = ele, 
                              osnum = fileos );
              ss$activate_keypt( action = SSSET_KEYPT, 
                                 objid  = ele,
                                 osnum  = fileos, 
                                 mask   = SSKP_ENDPT2 );
            }
          }
        }
  
        /*
         * If the last data point is the same as the "firstpt" then this
         * is a closed curve. So go to initial state.
         */
  
        if (addele && 
            BSdistptpt (&msg_loc, pt, ME.ECdraw->firstpt) <= lentol)
           auto_endsketch = TRUE;

        /* 
         * If the command is operating in symmetry-mode, check if the 
         * point just introduced maps to the same point after reflection. 
         * If so, assume end of symmetry and go to the "end-symmetry" state.
         */
        
        if (dosymm_ele)
        {
          MAptsxform (&msg_loc, &one, ME.ECdraw->symm_mat, pt, lastpt);
          EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, ret_end);
          if (BSdistptpt (&msg_loc, pt, lastpt) <= lentol)
            toendsymm = TRUE;
        }

        /*
         * Adjust the tolerance band constraints
         */

        ptr1 = tol_constr_lines[0].point1;
        ptr2 = tol_constr_lines[0].point2;
        OM_BLOCK_MOVE (pt, ptr1, sizeof (IGRpoint));
        for (i=0; i<3; i++)
          ptr2[i] = ptr1[i] + ME.ECdraw->xvec[i];

        ptr1 = tol_constr_lines[1].point1;
        ptr2 = tol_constr_lines[1].point2;
        OM_BLOCK_MOVE (pt, ptr1, sizeof (IGRpoint));
        for (i=0; i<3; i++)
          ptr2[i] = ptr1[i] + ME.ECdraw->yvec[i];

        active_tol_constr[0] = TRUE;
        active_tol_constr[1] = TRUE;
        active_tol_constr[2] = FALSE;
        active_tol_constr[3] = FALSE;
 
        if (tol_constr_inx != 0 && tol_constr_inx != 1)
        {
          OM_BLOCK_MOVE (pt, tol_constr_lines[2].point1, sizeof (IGRpoint));
          ptr = tol_constr_lines[2].point2;
          OM_BLOCK_MOVE (pt, ptr, sizeof (IGRpoint));
          vec = ME.ECdraw->zvec;
          ptr1 = ME.ECdraw->line_state || ME.ECdraw->local_state == 0 ?
                  ME.ECdraw->prevpts[0] : ME.ECdraw->prevpts[1];
          ptr2 = pt;
          ptr[X] += vec[Y] * (ptr2[Z] - ptr1[Z]) - vec[Z] * (ptr2[Y] - ptr1[Y]);
          ptr[Y] += vec[Z] * (ptr2[X] - ptr1[X]) - vec[X] * (ptr2[Z] - ptr1[Z]);
          ptr[Z] += vec[X] * (ptr2[Y] - ptr1[Y]) - vec[Y] * (ptr2[X] - ptr1[X]);

          OM_BLOCK_MOVE (pt, tol_constr_lines[3].point1, sizeof (IGRpoint));
          OM_BLOCK_MOVE (ptr1, tol_constr_lines[3].point2, sizeof (IGRpoint));

          active_tol_constr[3] = TRUE;
          for (j=2; j<=3; j++)
          {
            active_tol_constr[j] = TRUE;
            for (i=0; i<2; i++)
            {
              if (EFequal_constr_lines (&tol_constr_lines[i], &tol_constr_lines[j]))
              {
                active_tol_constr[j] = FALSE;
                break;
              }
            }
          }
        }

        
        if (!nochg_local_state)
        {
          if (!ME.ECdraw->line_state && ME.ECdraw->local_state == 0)
            OM_BLOCK_MOVE (pt, ME.ECdraw->prevpts[1], sizeof (IGRpoint));
          else
            OM_BLOCK_MOVE (pt, ME.ECdraw->prevpts[0], sizeof (IGRpoint));
          
          if (ME.ECdraw->symm_state == BEGINSYMM1_STATE)
            OM_BLOCK_MOVE (pt, ME.ECdraw->symm_line.point1, sizeof (IGRpoint));
          else if (ME.ECdraw->symm_state == BEGINSYMM2_STATE)
            OM_BLOCK_MOVE (pt, ME.ECdraw->symm_line.point2, sizeof (IGRpoint));

          if (!ME.ECdraw->line_state)
          {
            if (me->local_state == 0) 
            {
              BSmkvec (&msg_loc, vec1, ME.ECdraw->prevpts[0], lastpt);
              BScrossp (&msg_loc, vec1, ME.ECdraw->tanvec, vec2);
              if (BSdotp (&msg_loc, vec2, ME.ECdraw->zvec) > 0.0)
                me->local_state = 1;
              else
                me->local_state = 2;
            }
            else
              ME.ECdraw->line_state = TRUE;
          }
          else if (ME.ECdraw->symm_state == BEGINSYMM1_STATE)
            ME.ECdraw->symm_state = BEGINSYMM2_STATE;
          else if (ME.ECdraw->symm_state == BEGINSYMM2_STATE)
            tosymm2 = TRUE;
        }
        else
        {
          OM_BLOCK_MOVE (pt, ME.ECdraw->prevpts[0], sizeof (IGRpoint));
          nochg_local_state = FALSE;
        }
        
        /*
         * Decide the next state to go.
         */
        
        if (tosymm2)
          ME.super_cmd->state = BEGINSYMM2_STATE;
        else if (toendsymm)
          ME.super_cmd->state = ENDSYMM_STATE;
        else if (auto_endsketch || end_profile)
          ME.super_cmd->state = END_PROFILE_STATE;
        else
          ME.super_cmd->state = NEXTPT_STATE;
        
        /*
         * We add the first element's start point to the smart sketch list.
         */
        if (smart_sketch_active && ME.ECdraw->cur_comp_inx > FIRST)
        {
          ss$add_to_list( objid = ME.ECdraw->firstobj, 
                          osnum = fileos );
          ss$activate_keypt( action = SSSET_KEYPT, 
                             objid  = ME.ECdraw->firstobj,
                             osnum  = fileos, 
                             mask   = SSKP_ENDPT1 );
        }
        break;

      case BEGINSYMM1_STATE:
        OM_BLOCK_MOVE (pts2[0], pt, sizeof(IGRpoint));
        stat_func = EFobtain_tangent (ME.ECdraw->cur_comp_inx,
                     ME.ECdraw->compobj, ME.ECdraw->firstobj, 
                     ME.ECdraw->firstpt, ME.ECdraw->firsttan,
                     fileos, env, NULL, pt, dumvec);
        EMerr_hndlr (!stat_func, stat_OM, OM_E_ABORT, ret_end);
        ptr = ME.ECdraw->prevpts[0];
        for (i=0; i<3; i++)
          ptr[i] = pt[i] + dumvec[i];

        tol_constr_inx = NOT_HORIZVERT_CONSTR;
        process_ele = FALSE;
        nochg_local_state = TRUE;
        ME.ECdraw->symm_compinx = 0;
        ME.ECdraw->symm_state = BEGINSYMM1_STATE;
        ME.ECdraw->line_state = TRUE;
        ME.super_cmd->state = PROCESS_STATE;
        break;

      case BEGINSYMM2_STATE:
        inx = ME.ECdraw->num_inttol_constr;
        match = FALSE;
        for (i=0; i<inx; i++)
          if (EFequal_constr_lines (&inttol_constr_lines[i],
                                  &ME.ECdraw->symm_line))
          {
            match = TRUE;
            break;
          }
        if (!match)
        {
          if (om$dimension_of (varray = ME.ECdraw->inttol_constr_lines) <
               inx + 1)
          {
            stat_OM = om$vla_set_dimension (varray = 
                       ME.ECdraw->inttol_constr_lines, size = inx + 1);
            EMomerr_exit (stat_OM, ret_end);

            stat_OM = om$vla_set_dimension (varray = 
                       ME.ECdraw->inttolpt_store, size = 2 * (inx + 1));
            EMomerr_exit (stat_OM, ret_end);

            inttol_constr_lines = ME.ECdraw->inttol_constr_lines;
            pts = ME.ECdraw->inttolpt_store;
            count = inx + 1;
            for (i=0, j=0; i<count; i++, j+=2)
            {
              inttol_constr_lines[i].point1 = pts[j];
              inttol_constr_lines[i].point2 = pts[j+1];
            }
          }
          lines = &inttol_constr_lines[inx];
          OM_BLOCK_MOVE (ME.ECdraw->symm_line.point1, lines->point1,
                         sizeof (IGRpoint));
          OM_BLOCK_MOVE (ME.ECdraw->symm_line.point2, lines->point2,
                         sizeof (IGRpoint));
          ME.ECdraw->num_inttol_constr++;
        }

        EMreflectmat (&ME.ECdraw->symm_line, ME.ECdraw->zvec,
                      ME.ECdraw->symm_mat, &ME.ECdraw->symm_mattyp);

        EFdisp_inttol_constr (1, &ME.ECdraw->symm_line,
                            &ME.ECelements->active_display, env, 
                            ME.ECdraw->constr_color,
                            DOTDASHED_STYLE, GRbd);

        OM_BLOCK_MOVE (pts2[0], pt, sizeof(IGRpoint));
        stat_func = EFobtain_tangent (ME.ECdraw->cur_comp_inx,
                     ME.ECdraw->compobj, ME.ECdraw->firstobj, 
                     ME.ECdraw->firstpt, ME.ECdraw->firsttan,
                     fileos, env, NULL, pt, dumvec);
        EMerr_hndlr (!stat_func, stat_OM, OM_E_ABORT, ret_end);
        ptr = ME.ECdraw->prevpts[0];
        for (i=0; i<3; i++)
          ptr[i] = pt[i] + dumvec[i];

        tol_constr_inx = NOT_HORIZVERT_CONSTR;
        process_ele = FALSE;
        nochg_local_state = TRUE;
        ME.ECdraw->symm_compinx = 0;         
        ME.ECdraw->symm_state = INSYMM_STATE;
        ME.ECdraw->line_state = TRUE;
        ME.super_cmd->state = PROCESS_STATE;
        break;

      case ENDSYMM_STATE:
        if (!ME.ECdraw->symm_compinx)
        {
          if (ME.ECdraw->symm_state == INSYMM_STATE)
            EFdisp_inttol_constr (1, &ME.ECdraw->symm_line,
                                  &ME.ECelements->active_display, env, 
                                  ME.ECdraw->constr_color,
                                  FULL_STYLE, GRbe);

          OM_BLOCK_MOVE (pts2[0], pt, sizeof(IGRpoint));
          stat_func = EFobtain_tangent (ME.ECdraw->cur_comp_inx,
                                        ME.ECdraw->compobj, ME.ECdraw->firstobj, 
                                        ME.ECdraw->firstpt, ME.ECdraw->firsttan, 
                                        fileos, env, NULL, pt, dumvec);
          EMerr_hndlr (!stat_func, stat_OM, OM_E_ABORT, ret_end);
          ptr = ME.ECdraw->prevpts[0];
          for (i=0; i<3; i++)
            ptr[i] = pt[i] + dumvec[i];

          tol_constr_inx = NOT_HORIZVERT_CONSTR;
          process_ele = FALSE;
          ME.ECdraw->line_state = TRUE;
          ME.ECdraw->symm_state = FALSE;
          nochg_local_state = TRUE;
          ME.super_cmd->state = PROCESS_STATE;
          if (form_ptr)
          {
            FIg_set_state_off (form_ptr, BEGINSYMM1_STATE);
            EFdo_form_abling (form_ptr, NEXTPT_STATE, FALSE, FALSE, me->mytype);
          }
          break;
        }

        stat_func =  EFobtain_tangent (ME.ECdraw->cur_comp_inx, 
                                       ME.ECdraw->compobj, ME.ECdraw->firstobj, 
                                       ME.ECdraw->firstpt, ME.ECdraw->firsttan,
                                       fileos, env, &eleobj, lastpt1, tanvec1);
        EMerr_hndlr (!stat_func, stat_OM, OM_E_ABORT, ret_end);

        stat_func =  EFobtain_tangent (ME.ECdraw->symm_compinx, 
                                       ME.ECdraw->symm_compobj, ME.ECdraw->symm_firstobj,
                                       NULL, NULL,
                                       fileos, env, &symm_eleobj, lastpt2, tanvec2);
        EMerr_hndlr (!stat_func, stat_OM, OM_E_ABORT, ret_end);

        endmatch = FALSE;
        endtanmatch = FALSE;
        if (BSdistptpt (&msg_loc, lastpt1, lastpt2) <= lentol)
        {
          endmatch = TRUE;
          BScrossp (&msg_loc, tanvec1, tanvec2, dumvec);
          if (BSlenvec (&msg_loc, dumvec) <= lentol)
            endtanmatch = TRUE;
        }

        if (endtanmatch)
        {
          geominfo[0].located_obj.objid = eleobj;
          geominfo[1].located_obj.objid = symm_eleobj;
          stat_func = EFmerge_curves (2, geominfo, NULL, NULL_OBJID,
                       &mrgcv, FALSE, &msg_loc);
          EMerr_hndlr (!stat_func || EMSerror (msg_loc), stat_OM, OM_E_ABORT,
                       ret_end);

          if (mrgcv->order > 2)
          {
            BStstcvfarc (mrgcv, &match, point, &value, cirarccv, &msg_loc);
            EMerr_hndlr (!match || msg_loc != BSSUCC, stat_OM, OM_E_ABORT,
                         ret_end);
            elecv = cirarccv;
          }
          else
          {
            OM_BLOCK_MOVE (mrgcv->poles, twopolecv->poles,
                           sizeof (IGRpoint));
            OM_BLOCK_MOVE (&mrgcv->poles[(mrgcv->num_poles-1)*3],
                           &twopolecv->poles[3], sizeof (IGRpoint));
            elecv = twopolecv;
          }

          EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
          for (inx=FIRST; inx<=SECOND; inx++)
          {
            compinx = inx == FIRST ?
                       &ME.ECdraw->cur_comp_inx : &ME.ECdraw->symm_compinx;
            if (*compinx > SECOND)
            {
              compid.objid = inx == FIRST ?
                              ME.ECdraw->compobj : ME.ECdraw->symm_compobj;
              compid.osnum = fileos;

              stat_OM = om$send (msg = message GRconnector.GRdisconn
                         (&msg_loc, &compid), p_chanselect = &chan_to_comps,
                         from = *compinx-1, to = *compinx-1,
                         senderid = compid.objid, targetos = fileos);
              EMomerr_exit (stat_OM, ret_end);
            }

            if (aflag)
            {
            dpmode = GRbe;
            stat_OM = om$send (msg = message GRgraphics.GRdisplay (&msg_loc,
                                     &disp.md_env.matrix_type, disp.md_env.matrix,
                                     &dpmode, &disp.md_id),
                               targetid = inx == FIRST ? eleobj : symm_eleobj,
                               targetos = fileos);
            }
            else
            {
            dpmode = GRbe;
            stat_OM = om$send (msg = message GRgraphics.GRdisplay (&msg_loc,
                                     &env->md_env.matrix_type, env->md_env.matrix,
                                     &dpmode, &env->md_id),
                               targetid = inx == FIRST ? eleobj : symm_eleobj,
                               targetos = fileos);
            }
            EMomerr_exit (stat_OM, ret_end);
            EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, ret_end);

            stat_OM = om$send (msg = message GRgraphics.GRdelete
                                    (&msg_loc, env), 
                               targetid = inx == FIRST ? eleobj : symm_eleobj,
                               targetos = fileos);
            EMomerr_exit (stat_OM, ret_end);
            EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, ret_end);
            (*compinx)--;
          }
        }
        else if (!endmatch)
        {
          OM_BLOCK_MOVE (lastpt1, twopolecv->poles, sizeof (IGRpoint));
          OM_BLOCK_MOVE (lastpt2, &twopolecv->poles[3], sizeof (IGRpoint));
          elecv = twopolecv;
        }

        if (endtanmatch || !endmatch)
        {
          objclass = elecv->order > 2 ?
                       OPP_GR3dcirarc_class_id : OPP_GR3dlineseg_class_id;
          const_list.geometry = (IGRchar *) elecv;
          stat_OM = om$construct (classid = objclass,
                                  msg = message GRgraphics.GRconstruct (&const_list), 
                                  osnum = fileos, p_objid = &eleobj);
          EMomerr_exit (stat_OM, ret_end);
          EMerr_hndlr (EMSerror (*const_list.msg), stat_OM, OM_E_ABORT, ret_end);
            
          if (ME.ECdraw->cur_comp_inx > (endtanmatch ? FIRST : SECOND))
          {
            geominfo[0].located_obj.objid = eleobj;
            count = 1;
            stat_OM = om$send (msg = message GRcompcurve.EMmakecomp
                                     (&msg_loc, env, count, geominfo, &dum),
                               targetid = ME.ECdraw->compobj, 
                               targetos = fileos);
            EMomerr_exit (stat_OM, ret_end);
            EMerr_hndlr (EMSerror (msg_loc) || dum == 0 || dum == 1, stat_OM,
                         OM_E_ABORT, ret_end);
          }
          else if (!endmatch && ME.ECdraw->cur_comp_inx == SECOND)
          {
            stat_OM = om$construct (classid = OPP_GRcompcurve_class_id,
                                    msg = message GRgraphics.GRconstruct (&const_list),
                                    osnum = fileos, p_objid = &ME.ECdraw->compobj);
            EMomerr_exit (stat_OM, ret_end);
            EMerr_hndlr (EMSerror (*const_list.msg), stat_OM, OM_E_ABORT, ret_end);

            geominfo[0].located_obj.objid = ME.ECdraw->firstobj;
            geominfo[1].located_obj.objid = eleobj;
            count = 2;
            stat_OM = om$send (msg = message GRcompcurve.EMmakecomp
                                     (&msg_loc, env, count, geominfo, &dum),
                               targetid = ME.ECdraw->compobj, targetos = fileos);
            EMomerr_exit (stat_OM, ret_end);
            EMerr_hndlr (EMSerror (msg_loc) || dum == 0 || dum == 1, stat_OM,
                         OM_E_ABORT, ret_end);
          }
          else
            ME.ECdraw->firstobj = eleobj;
          ME.ECdraw->cur_comp_inx++;

          if (aflag)
          {
          dpmode = GRbd;
          stat_OM = om$send (msg = message GRgraphics.GRdisplay (&msg_loc,
                                   &disp.md_env.matrix_type, disp.md_env.matrix,
                                   &dpmode, &disp.md_id),
                             targetid = eleobj, targetos = fileos);
          }
          else
          {
          dpmode = GRbd;
          stat_OM = om$send (msg = message GRgraphics.GRdisplay (&msg_loc,
                                   &env->md_env.matrix_type, env->md_env.matrix,
                                   &dpmode, &env->md_id),
                             targetid = eleobj, targetos = fileos);
          }
          EMomerr_exit (stat_OM, ret_end);
          EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, ret_end);

          if (ME.ECdraw->symm_compinx > FIRST)
          {
            inx = ME.ECdraw->symm_compinx;
            geominfo[0].located_obj.objid = 
             (endtanmatch ? inx > FIRST : inx > SECOND) ?
              ME.ECdraw->symm_compobj : ME.ECdraw->symm_firstobj;
            count = 1;
          }
          else
            count = 0;
        }
        else
        {
          if (ME.ECdraw->cur_comp_inx == SECOND)
          {
            stat_OM = om$construct (classid = OPP_GRcompcurve_class_id,
                                    msg = message GRgraphics.GRconstruct (&const_list),
                                    osnum = fileos, p_objid = &ME.ECdraw->compobj);
            EMomerr_exit (stat_OM, ret_end);
            EMerr_hndlr (EMSerror (*const_list.msg), stat_OM, OM_E_ABORT, ret_end);

            geominfo[0].located_obj.objid = ME.ECdraw->firstobj;
            geominfo[1].located_obj.objid = ME.ECdraw->symm_firstobj;
            count = 2;
          }
          else
          {
            geominfo[0].located_obj.objid = ME.ECdraw->symm_compinx > SECOND ?
                               ME.ECdraw->symm_compobj : ME.ECdraw->symm_firstobj;
            count = 1;
          }
        }

        if (ME.ECdraw->symm_compinx)
        {
          stat_OM = om$send (msg = message GRcompcurve.EMmakecomp
                                   (&msg_loc, env, count, geominfo, &dum),
                             targetid = ME.ECdraw->compobj, targetos = fileos);
          EMomerr_exit (stat_OM, ret_end);
          EMerr_hndlr (EMSerror (msg_loc) || dum == 0 || dum == 1, stat_OM,
                       OM_E_ABORT, ret_end);
          ME.ECdraw->cur_comp_inx += ME.ECdraw->symm_compinx;
        }

        OM_BLOCK_MOVE (pts2[0], pt, sizeof(IGRpoint));
        stat_func = EFobtain_tangent (ME.ECdraw->cur_comp_inx,
                     ME.ECdraw->compobj, ME.ECdraw->firstobj, 
                     ME.ECdraw->firstpt, ME.ECdraw->firsttan, 
                     fileos, env, NULL, pt, dumvec);
        EMerr_hndlr (!stat_func, stat_OM, OM_E_ABORT, ret_end);
        ptr = ME.ECdraw->prevpts[0];
        for (i=0; i<3; i++)
          ptr[i] = pt[i] + dumvec[i];

        tol_constr_inx = NOT_HORIZVERT_CONSTR;
        process_ele = FALSE;
        ME.ECdraw->line_state = TRUE;
        ME.ECdraw->symm_state = FALSE;
        nochg_local_state = TRUE;
        ME.super_cmd->state = PROCESS_STATE;
        if (form_ptr)
        {
          FIg_set_state_off (form_ptr, BEGINSYMM1_STATE);
          EFdo_form_abling (form_ptr, NEXTPT_STATE, FALSE, FALSE, me->mytype);
        }
        break;

      case DELALLCONSTR_STATE:
        if (ME.ECdraw->num_inttol_constr)
        {
          EFdisp_inttol_constr (ME.ECdraw->num_inttol_constr,
                                inttol_constr_lines, &ME.ECelements->active_display,
                                env, ME.ECdraw->constr_color, FULL_STYLE, GRbe);

          ME.ECdraw->num_inttol_constr = 0;
          ex$message(msgnumb=EMS_S_AllConstrnConstraintsFreed);
        }
        else
        {
          ex$message(msgnumb=EMS_S_NoConstraintsFound);
        }

        ME.super_cmd->state = ME.ECdraw->return_state;
        if (form_ptr)
          FIg_set_state_off (form_ptr, DELALLCONSTR_STATE);
        break;

      case DELCONSTR_STATE:
        tolfound = tol_constr_inx >= 0;
        inttolfound[0] = inttol_constr_inx[0] >= 0;
        inttolfound[1] = inttol_constr_inx[1] >= 0;
        if (!tolfound && !inttolfound[0] && !inttolfound[1])
        {
          /*
           * If the user was placing the end-pt of a tangent arc, just go into
           * placing a normal 3-pt arc.  This will kill the inherent tangency
           * constraint.
           */
          if (ME.ECdraw->local_state == 3 || ME.ECdraw->local_state == 4)
            ME.ECdraw->local_state = 0;
          else
            ex$message(msgnumb=EMS_S_NoConstraintsFound);
        }
        else if (inttolfound[0] || inttolfound[1])
        {
          count = ME.ECdraw->num_inttol_constr;
          for (inx=0; inx<2; inx++)
          {
            if (inttolfound[inx])
            {
              i = inttol_constr_inx[inx];
              EFdisp_inttol_constr (1, &inttol_constr_lines[i],
                                    &ME.ECelements->active_display, env, 
                                    ME.ECdraw->constr_color, FULL_STYLE, GRbe);

              if (i < count-1)
              {
                pts = ME.ECdraw->inttolpt_store;
                j = i * 2;
                OM_BLOCK_MOVE (pts[j+2], pts[j], 
                               (2 * (count-1-i)) * sizeof (IGRpoint));

                for (k=0, l=0; k<count-1; k++, l+=2)
                {
                  inttol_constr_lines[k].point1 = pts[l];
                  inttol_constr_lines[k].point2 = pts[l+1];
                }
              }
              count = --ME.ECdraw->num_inttol_constr;
            }
          }
        }
        else if (!angle_constr)
          active_tol_constr[tol_constr_inx] = FALSE;
        else
          ME.ECdraw->angle_constr = FALSE;

        ME.super_cmd->state = NEXTPT_STATE;
        break;

      case HORCONSTR_STATE:
      case VERCONSTR_STATE:
      case HORVERCONSTR_STATE:
        if (!ME.ECdraw->horver_state)
        {
          ME.ECdraw->horver_state = ME.super_cmd->state;
          ME.ECdraw->angle_constr = FALSE;
        }
        else
        {
          inx = ME.ECdraw->num_inttol_constr;
          inc = ME.super_cmd->state == HORVERCONSTR_STATE ? 2 : 1;
          if (om$dimension_of (varray = ME.ECdraw->inttol_constr_lines) <
              inx + inc)
          {
            stat_OM = om$vla_set_dimension (varray = 
                       ME.ECdraw->inttol_constr_lines, size = inx + inc);
            EMomerr_exit (stat_OM, ret_end);

            stat_OM = om$vla_set_dimension (varray = 
                       ME.ECdraw->inttolpt_store, size = 2 * (inx + inc));
            EMomerr_exit (stat_OM, ret_end);

            inttol_constr_lines = ME.ECdraw->inttol_constr_lines;
            pts = ME.ECdraw->inttolpt_store;
            count = inx + inc;
            for (i=0, j=0; i<count; i++, j+=2)
            {
              inttol_constr_lines[i].point1 = pts[j];
              inttol_constr_lines[i].point2 = pts[j+1];
            }
          }

          lines = &inttol_constr_lines[inx];
          stat_func = EFhorvert_for_datapoint (pt,
                       ME.ECdraw->firstpt,
                       ME.ECdraw->xvec, ME.ECdraw->yvec, ME.ECdraw->zvec,
                       ME.super_cmd->state,
                       inx, inttol_constr_lines, &count, lines);
          if (stat_func && count)
          {
            EFdisp_inttol_constr (count, lines, &ME.ECelements->active_display,
                                  env, ME.ECdraw->constr_color, DASHED_STYLE, GRbd);
            ME.ECdraw->num_inttol_constr += count;
          }
          else
          {
            ex$message(msgnumb=EMS_S_ConstraintNotAdded);
          }
        }
        ME.super_cmd->state = NEXTPT_STATE;
        break;

      case PARCONSTR_STATE:
      case NORCONSTR_STATE:
      case COLLCONSTR_STATE:
      case ORTHOCONSTR_STATE:
      case COLORTHCONSTR_STATE:
        ME.ECelements->num_elems = 0;
        ME.ECelements->num_events = 0;
        ex$message ( msgnumb = EMS_P_Curve, buff = elemtype );
        ex$message ( msgnumb = EMS_P_DefiningConstraint, buff = postmsg_1 ); 
        ex$message ( msgnumb = EMS_P_AtDefiningPoint, buff = postmsg_2 ); 
        stat_OM = om$send (msg = message ECelements.do_locate 
                                 (&msg_loc, &useract, response, response_data, 
                                 elemtype, NULL, postmsg_1, postmsg_2, 
                                 NULL, NULL),
                           targetid = my_id);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT,
                     ret_end);
        form_ptr = ME.ECdraw->form_ptr;
        if (form_ptr)
        {
          if (ME.super_cmd->state == COLORTHCONSTR_STATE)
          {
            FIg_set_state_off (form_ptr, COLLCONSTR_STATE);
            FIg_set_state_off (form_ptr, ORTHOCONSTR_STATE);
          }
          else
            FIg_set_state_off (form_ptr, ME.super_cmd->state);
          EFdo_form_abling (form_ptr, NEXTPT_STATE, FALSE, 
                            ME.ECdraw->symm_state, me->mytype);
        }

        if (useract == EMSuser_backup)
        {
          ME.super_cmd->state = NEXTPT_STATE;
          break;
        }
        else if (useract != EMSuser_data)
          goto ret_end;

        eleid = ME.ECelements->elems[FIRST].located_obj;
        OM_BLOCK_MOVE (&ME.ECelements->accev.event.button.x, pt, sizeof(IGRpoint));

        if (!ME.ECdraw->line_state && ME.ECdraw->local_state > 0)
          ptr = ME.ECdraw->prevpts[1];
        else
          ptr = ME.ECdraw->prevpts[0];
        if (ME.super_cmd->state == COLLCONSTR_STATE ||
            ME.super_cmd->state == ORTHOCONSTR_STATE ||
            ME.super_cmd->state == COLORTHCONSTR_STATE)
        {
          inx = ME.ECdraw->num_inttol_constr;
          inc = ME.super_cmd->state == COLORTHCONSTR_STATE ? 2 : 1;
          if (om$dimension_of (varray = ME.ECdraw->inttol_constr_lines) <
              inx + inc)
          {
            stat_OM = om$vla_set_dimension (varray = 
                       ME.ECdraw->inttol_constr_lines, size = inx + inc);
            EMomerr_exit (stat_OM, ret_end);

            stat_OM = om$vla_set_dimension (varray = 
                       ME.ECdraw->inttolpt_store, size = 2 * (inx + inc));
            EMomerr_exit (stat_OM, ret_end);

            inttol_constr_lines = ME.ECdraw->inttol_constr_lines;
            pts = ME.ECdraw->inttolpt_store;
            count = inx + inc;
            for (i=0, j=0; i<count; i++, j+=2)
            {
              inttol_constr_lines[i].point1 = pts[j];
              inttol_constr_lines[i].point2 = pts[j+1];
            }
          }
          lines = &inttol_constr_lines[inx];
        }
        else
          lines = &ME.ECdraw->angle_constr_line;

        stat_func = EFconstr_for_datapoint (ptr, pt, &eleid, ME.super_cmd->state,
                     env, ME.ECdraw->firstpt, ME.ECdraw->zvec,
                     ME.ECdraw->num_inttol_constr, inttol_constr_lines,
                     &count, lines);                     
        if (stat_func && count)
        {
          if (ME.super_cmd->state == COLLCONSTR_STATE ||
              ME.super_cmd->state == ORTHOCONSTR_STATE ||
              ME.super_cmd->state == COLORTHCONSTR_STATE)
          {
            EFdisp_inttol_constr (count, lines, &ME.ECelements->active_display,
                                  env, ME.ECdraw->constr_color, DASHED_STYLE, GRbd);
            ME.ECdraw->num_inttol_constr += count;
          }
          else
            ME.ECdraw->angle_constr = TRUE;
        }
        else
        {
          ex$message(msgnumb=EMS_S_ConstraintNotAdded);
        }
        ME.super_cmd->state = NEXTPT_STATE;
        break;

      case REVCONSTR_STATE:
        count = ME.ECdraw->num_inttol_constr;
        if (!count)
        {
          ex$message(msgnumb=EMS_S_NoConstraintToDisplay)
        }
        else
        {
          EFdisp_inttol_constr (ME.ECdraw->num_inttol_constr, inttol_constr_lines,
                              &ME.ECelements->active_display,
                              env, ME.ECdraw->constr_color, DASHED_STYLE, GRbd);
          if (ME.ECdraw->symm_state == INSYMM_STATE)
          {
            EFdisp_inttol_constr (1, &ME.ECdraw->symm_line,
                                &ME.ECelements->active_display, 
                                env, ME.ECdraw->constr_color,
                                FULL_STYLE, GRbe);
            EFdisp_inttol_constr (1, &ME.ECdraw->symm_line,
                                &ME.ECelements->active_display, env, 
                                ME.ECdraw->constr_color,
                                DOTDASHED_STYLE, GRbd);
          }
        }
 
        ME.super_cmd->state = ME.ECdraw->return_state;
        if (form_ptr)
          FIg_set_state_off (form_ptr, REVCONSTR_STATE);
        break;

      case ARC_STATE:
        if (ME.ECdraw->line_state || ME.ECdraw->local_state == 0)
        {
          /*
           * Switch to 2-pt arc placement in case this is not the first profile
           * segment.
           */
          if (!ME.ECdraw->cur_comp_inx)
            ME.ECdraw->local_state = 0;
          else
          {
            /*
             * We need to go into CW or CCW arc mode depending on the current
             * cursor position.  If we do not have a lastpt (happens when running PPL
             * files), then find from dpb.
             */
            if (!is_lastpt) 
            {
              gr$get_last_point (buffer = (char *) &button);
              lastpt[0] = button.x;
              lastpt[1] = button.y;
              lastpt[2] = button.z;
            }

            BSmkvec (&msg_loc, vec1, ME.ECdraw->prevpts[0], lastpt);
            BScrossp (&msg_loc, vec1, ME.ECdraw->tanvec, vec2);
            if (BSdotp (&msg_loc, vec2, ME.ECdraw->zvec) > 0.0)
              ME.ECdraw->local_state = 3;
            else
              ME.ECdraw->local_state = 4;
          }
          ME.ECdraw->line_state = FALSE;
        }
        ME.super_cmd->state = NEXTPT_STATE;
        if (form_ptr)
          FIg_set_state_off (form_ptr, ARC_STATE);
        break;
        
      case ARCBYRADIUS_STATE:
        if (ME.ECdraw->line_state || ME.ECdraw->local_state == 3 ||
            ME.ECdraw->local_state == 4)
          ME.ECdraw->local_state = 0;
        ME.ECdraw->line_state = FALSE;
        ME.super_cmd->state = NEXTPT_STATE;
        if (form_ptr)
          FIg_set_state_off (form_ptr, ARCBYRADIUS_STATE);
        break;
        
      case LINE_STATE:
        if (!ME.ECdraw->line_state && 
            (ME.ECdraw->local_state == 1 || ME.ECdraw->local_state == 2 ))
        {
          /*
           * If the user had already entered the centerpt, then we need to delete it
           * before moving to line mode.
           */
          OM_BLOCK_MOVE (ME.ECdraw->prevpts[0], pt, sizeof (IGRpoint));
          stat_func = EFobtain_tangent (ME.ECdraw->cur_comp_inx,
                                        ME.ECdraw->compobj, ME.ECdraw->firstobj, 
                                        ME.ECdraw->firstpt, ME.ECdraw->firsttan,
                                        fileos, env, NULL, NULL, dumvec);
          EMerr_hndlr (!stat_func, stat_OM, OM_E_ABORT, ret_end);
          ptr = ME.ECdraw->prevpts[0];
          for (i=0; i<3; i++)
            ptr[i] = pt[i] + dumvec[i];
          nochg_local_state = TRUE;
          ME.ECdraw->local_state = 0;

          if (cmdtype == VARPROFILE)
            ME.ECdraw->num_pts--;

          tol_constr_inx = NOT_HORIZVERT_CONSTR;
          process_ele = FALSE;
          ME.super_cmd->state = PROCESS_STATE;
        }
        else
        {
          ME.super_cmd->state = NEXTPT_STATE; 
        }
        ME.ECdraw->line_state = TRUE;
        if (form_ptr)
          FIg_set_state_off (form_ptr, LINE_STATE);
        break;

      case AUTOCLOSE_STATE:
        ex$message (msgnumb = EMS_S_FirstAndLastPtSuffClose);
        ex$message (msgnumb = EMS_P_DPforOpenProfMvOnToClose);
        eventmask = datptmask | GRm_BACK_UP | GRm_RJT_MOVEON; 
        stat_func = ems$getevent (msg = &msg_loc, event_mask = eventmask,
                                  value_type = valuetype, event = &event,
                                  response = (long *)response,
                                  response_data = response_data);
        EMerr_hndlr (!stat_func, stat_OM, OM_E_ABORT, ret_end);
        
        switch (event.response)
        {
          case EX_DATA:
            auto_close_sketch = FALSE;
            break;
          
          case EX_BACK_UP:
          case EX_RJT_MOVEON:
            auto_close_sketch = TRUE;
            break;
          
          default:
            break;
        }
        
        ME.super_cmd->state = END_PROFILE_STATE;
        break; 

      case END_PROFILE_STATE :
        /*
         * This state is only valid for profile creation/modification.
         */
        if (cmdtype == VARPROFILE &&
            (!IF_NULL_OBJID (ME.ECdraw->compobj) ||
             !IF_NULL_OBJID (ME.ECdraw->firstobj)))
        {
          addmask = NULL;
  
          /*
           * determine if we are creating a single profile element or a
           * composite curve.
           */
          if (ME.ECdraw->cur_comp_inx > SECOND)
            eleobj = ME.ECdraw->compobj;
          else
            eleobj = ME.ECdraw->firstobj;
          eleid.objid = eleobj;
          eleid.osnum = fileos;
          datplanid.objid = NULL_OBJID;
          ems$get_active_datum_plane (msg = &msg_loc,
                                      datpln = &datplanid);
          EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, ret_end);
  
          SKcreate_profile (&msg_loc,
                     SK_OPT_CREATE_GEOMETRY | SK_OPT_DISPLAY_GEOMETRY,
                     eleid.objid, env,
                     &datplanid, NULL, 
                     ME.ECdraw->firstpt, ME.ECdraw->xvec, ME.ECdraw->zvec,
                     ME.ECdraw->num_pts, ME.ECdraw->ptinfo, 
                     ME.ECdraw->num_pts > 1 ? auto_endsketch : FALSE,
                     &skmgr_id.objid);
          EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, ret_end);
          skmgr_id.osnum = fileos;
          if (msg_loc == EMS_I_FullyConstrained)
          {
            ex$message(msgnumb=EMS_S_FullyConstrained)
          }

          if (smart_sketch_active)
            SKauto_constrain (&msg_loc, NULL, env, skmgr_id, SK_AUTO_GEOMETRIC);

          if (auto_close_sketch)
          {
            stat_OM = om$send ( msg = message SKcompcurve.SKclose (
                                      &msg_loc,
                                      NULL, env, &num_conflict_cnstr,
                                      &conflict_cnstr_objs),
                                targetid = skmgr_id.objid, 
                                targetos = skmgr_id.osnum);
            EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT,
                         ret_end);
  
            if (msg_loc == EMS_I_Redundant)
            {
              /*
               * If there are some redundant constraints, then keep deleting
               * till the closure succeeds.
               */
              while (num_conflict_cnstr)
              {
                stat_OM = om$send (msg = message GRgraphics.GRdelete (&msg_loc, env),
                                   targetid = conflict_cnstr_objs[0], 
                                   targetos = fileos);
                EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);
                if (conflict_cnstr_objs)
                {
                  om$dealloc (ptr = conflict_cnstr_objs);
                  conflict_cnstr_objs = NULL;
                }
                num_conflict_cnstr = 0;
                stat_OM = om$send ( msg = message SKcompcurve.SKclose (
                                          &msg_loc,
                                          NULL, env, &num_conflict_cnstr,
                                          &conflict_cnstr_objs),
                                    targetid = skmgr_id.objid, 
                                    targetos = skmgr_id.osnum);
                EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);
              }
            }
          }

          if (ME.super_cmd->mytype == MODIFYPROFILE)
          {
            stat_OM = om$send (msg = message ECdraw.do_modification 
                                     ( &msg_loc, skmgr_id, end_merge),
                               targetid = my_id);
            EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );
          }
        }
        ME.ECdraw->firstobj = NULL_OBJID;
        ME.ECdraw->compobj = NULL_OBJID;
        end_profile = FALSE;
        if (ME.super_cmd->mytype == MODIFYPROFILE)
          ME.super_cmd->state = MODIFY_PROFILE_STATE;
        else if (ME.super_cmd->mytype == ONEPROFILE)
        {
	  *response = TERMINATE;
          goto ret_end;
        }
        else
          ME.super_cmd->state = FIRSTPT_STATE;
        break;
        
      case MODIFY_PROFILE_STATE:
        if (form_ptr)
          EFdo_form_abling (form_ptr, FIRSTPT_STATE, FALSE, FALSE, me->mytype);
        if (smart_sketch_active)
          ss$deactivate();
        stat_OM = om$send (msg = message ECdraw.modify_profile
                                 (&msg_loc, response, response_data),
                           targetid = my_id);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);
        if (smart_sketch_active)
          ss$activate();
        if (msg_loc == EMS_I_NoLocation)
          goto ret_end;
        ME.super_cmd->state = FIRSTPT_STATE;
        end_merge = FALSE;
        break;
        
      case MODIFY_ABORT_STATE:
        /*
         * This state is reached if the user aborts a modification by hitting a MOVEON
         * after selecting the modification segment or vertex without giving any new
         * data points.
         * Redisplay the selected segment and make it locatable.
         */
        action = 1;
        props = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
        stat_OM = om$send  ( msg = message GRgraphics.GRchgprops 
                                   (&msg_loc, &action, &props), 
                             targetid = ME.ECdraw->modseg[0].objid, 
                             targetos = ME.ECdraw->modseg[0].osnum);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);
   
        if (aflag)
        {
        dpmode = GRbd;
        stat_OM = om$send (msg = message GRgraphics.GRdisplay 
                                 (&msg_loc, &disp.md_env.matrix_type,
                                  disp.md_env.matrix, &dpmode, &disp.md_id),
                           targetid = ME.ECdraw->modseg[0].objid, 
                           targetos = ME.ECdraw->modseg[0].osnum);
        }
        else
        {
        dpmode = GRbd;
        stat_OM = om$send (msg = message GRgraphics.GRdisplay 
                                 (&msg_loc, &env->md_env.matrix_type,
                                  env->md_env.matrix, &dpmode, &env->md_id),
                           targetid = ME.ECdraw->modseg[0].objid, 
                           targetos = ME.ECdraw->modseg[0].osnum);
        }
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);
        
        
        if (ME.ECdraw->modify_state == MODIFY_VERTEX)
        {
          /*
           * In case of vertex modification, redisplay and make the second segment 
           * locatable also.
           */
          stat_OM = om$send  ( msg = message GRgraphics.GRchgprops 
                                     (&msg_loc, &action, &props), 
                               targetid = ME.ECdraw->modseg[1].objid, 
                               targetos = ME.ECdraw->modseg[1].osnum);
          EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);

          if (aflag)
          {
          stat_OM = om$send (msg = message GRgraphics.GRdisplay 
                                   (&msg_loc, &disp.md_env.matrix_type,
                                    disp.md_env.matrix, &dpmode, &disp.md_id),
                             targetid = ME.ECdraw->modseg[1].objid, 
                             targetos = ME.ECdraw->modseg[1].osnum);
          }
          else
          {
          stat_OM = om$send (msg = message GRgraphics.GRdisplay 
                                   (&msg_loc, &env->md_env.matrix_type,
                                    env->md_env.matrix, &dpmode, &env->md_id),
                             targetid = ME.ECdraw->modseg[1].objid, 
                             targetos = ME.ECdraw->modseg[1].osnum);
          }
          EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);
        }
        
        ME.super_cmd->state = MODIFY_PROFILE_STATE;
        break;
        
      default:
        stat_OM = OM_E_ABORT;
        goto ret_end;
    }
  }
  while (TRUE);

ret_end:
  if (twopolecv)
    BSfreecv (&msg_loc, twopolecv);
  if (cirarccv)
    BSfreecv (&msg_loc, cirarccv);
  if (intpts)
    om$dealloc (ptr = intpts);
  if (par1)
    om$dealloc (ptr = par1);
  if (par2)
    om$dealloc (ptr = par2);
  if (parpt1)
    om$dealloc (ptr = parpt1);
  if (parpt2)
    om$dealloc (ptr = parpt2);
  if (conflict_cnstr_objs)
    om$dealloc (ptr = conflict_cnstr_objs);

  if (EMSerror (stat_OM))
  {
    ex$message(msgnumb=EMS_E_ErrorInCommandExiting)
    *response = TERMINATE;
  }
  return (stat_OM);
}

end implementation ECdraw;
