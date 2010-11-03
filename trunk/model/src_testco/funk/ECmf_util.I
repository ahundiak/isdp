class implementation  EMSedge;

#include "stdio.h"
#include "OMerrordef.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bsconic.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "msdef.h"
#include "exdef.h"
#include "ex.h"
#include "exmacros.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "ECmfdef.h"
#include "ECmf.h"
#include "EMSmsgdef.h"
#include "ECmsg.h"
#include "emserr.h"
#include "emssfintdef.h"
#include "emsmapdef.h"

#include "ECmferr.h"

#include "bsxtractpar.h"
#include "bsmdstptcv.h"

#define EQUAL_TOL 0.0001
#define RNDOPT 888
#define fi_test EMerr_hndlr (ret0, ret0, ret0, ret_end);
#define ret_err ( ( ret0 & 1 ) ^ 1 )

#define MEM_FREE( addr ) if ( addr ) { free ( addr ) ; addr = 0 ; }

extern double fabs();

from EMSsurface import EMgetedges;
from EMSsubbs import EMget_edges;
from GRcurve import GRendpts;
from ECmarchfil import do_form_notification;

%safe
static void ECrnd_opt_notify();
%endsafe

/*------------------------------------------------------------------------

FILE

  rnd_opt.C


DESCRIPTION

  display rounding options form and also code for it's notification routine.
  being a save-restore form, don't erase it till you get "default" on the queue.
  user can hit moveon, or or hit return or type "default" and hit return or 
  select on the form.  form_notification does putque.


HISTORY

        pac       11/16/92      creation
        Sudha     07/02/93      Modified for BSprototypes ansification
        ashok     04/07/94      Commented out call to FIf_set_collapse_symbol
                                as fix for TR 119418334



ARGUMENTS

        first_time    I 1 for new chain, 0 otherwise
        disp_trim     I 1 after placing a fillet, 0 otherwise
        option        O form selection #def in ECmfdef.h

-------------------------------------------------------------------------*/

int ECmf_setup_form(form_ptr, dsp_it, first_time, disp_trim, num_nodes, 
                    cmd_id, cmd_os, from_wakeup)
char **form_ptr;
IGRboolean dsp_it;
int first_time, disp_trim, num_nodes;
unsigned int cmd_id;
unsigned short cmd_os;
{

  int ret0 = 0, is_disp;

  if(from_wakeup)
    goto display_form;

  if(! (*form_ptr))
    {
    ret0=FIf_new(RNDOPT,"EMRoundMan", ECrnd_opt_notify, form_ptr);
    fi_test
/* Fix for TR 119418334 (Command causes EMS crash on SUN/SGI)
   Commenting out as it causes FORMS to crash. Where is this "my_sym"
   file to be found anyway ? - Ashok 4/7/94
 
    ret0 = FIf_set_collapse_symbol(*form_ptr, "my_sym", 1);
    fi_test
*/
    ret0 = FIf_set_cmd_oid_os(*form_ptr, cmd_id, cmd_os);
    fi_test
    }

  ret0 = FIg_reset(*form_ptr, GAD_GRP);
  fi_test

  if(num_nodes)
    {
    ret0 = FIg_disable(*form_ptr, MATLTOGGLE);
    fi_test
    }

  if(first_time)
    {
    ret0 = FIg_enable(*form_ptr, MATLTOGGLE);
    fi_test
    ret0 = FIg_disable(*form_ptr, FILLET_EXT);
    fi_test
    ret0 = FIg_disable(*form_ptr, FILL_INT);
    fi_test
    ret0 = FIg_disable(*form_ptr, FILL_TAN);
    fi_test
    ret0 = FIg_disable(*form_ptr, UNDO);
    fi_test
    ret0 = FIg_disable(*form_ptr, DIR_CHANGE);
    fi_test
    }
  else if(! disp_trim)
    {
    ret0 = FIg_disable(*form_ptr, FILLET_EXT);
    fi_test
    ret0 = FIg_disable(*form_ptr, FILL_INT);
    fi_test
    ret0 = FIg_disable(*form_ptr, FILL_TAN);
    fi_test
    }

display_form:

  if(dsp_it)
    {
    ret0 = FIf_is_displayed(*form_ptr, &is_disp);
    fi_test

    if(! is_disp)
      {
      ret0 = FIf_display(*form_ptr);
      fi_test
      }
    }

ret_end:

  if(! ret0)
    return OM_S_SUCCESS;
  else
    {
#ifdef DEBUG
    fprintf(stderr, "FI error in ECmf_setup_form %d\n", ret0);
    fflush(stderr);
#endif
    return OM_E_ABORT;
    }

}
/* ECmf_setup_form */

static void ECrnd_opt_notify(form_label, gad_label, value, form_ptr)
int form_label, gad_label;
IGRdouble value;
char * form_ptr;
{
  unsigned int cmd_oid;
  unsigned short cmd_os;
  IGRint ret0=OM_S_SUCCESS;

  ret0 = FIf_get_cmd_oid_os(form_ptr, &cmd_oid, &cmd_os);
  fi_test

  ret0 = om$send (msg = message ECmarchfil.do_form_notification(form_label, 
                        gad_label, value, form_ptr),
                        senderid = NULL_OBJID,
                        targetid = cmd_oid,
                        targetos = cmd_os);
  EMerr_hndlr (! (ret0 & 1), ret0, ret0, ret_end);
                  
  ret_end:
     ;

#ifdef DEBUG
    if(ret_err)
      fprintf(stderr, "ERROR %d in rnd_opt\n", ret0);
#endif

}
/* ECrnd_opt_notify */

/*
 *  got from Stephen and added params for v values
 *
 *  struct GRid  *surf        (I) surface of interest
 *  IGRdouble    *parm_range  (I) array of 4 doubles corresponding to
 *                                (Vmin)u0, 
 *                                Umin,Vmin,Umax,Vmax for the surface
 *                                ^^^^^^ confirm this order ... pac 04/01/93
 *
 *  IGRint       *num_minbnd_edges, *num_maxbnd_edges
 *                            (O) num of 'surf' edeges at min & max ends
 *  struct GRid  *minbnd_edges, *maxbnd_edges
 *                            (O) GRids of 'surf' edeges at min & max ends
 *  IGRdouble    *min_bnd_v   (O) if(*num_minbnd_edges == 1)
 *                                  set to V par of midpt of min bnd edge
 *                                else
 *                                  set to -1
 *  IGRdouble    *max_bnd_v   (O) if(*num_maxbnd_edges == 1)
 *                                  set to V par of midpt of max bnd edge
 *                                else
 *                                  set to -1
 */


IGRint EMis_natsf(msg, surf, parm_range,
                  num_minbnd_edges, minbnd_edges,
                  num_maxbnd_edges, maxbnd_edges, min_bnd_v, max_bnd_v)
IGRlong *msg;
struct GRid *surf;
IGRdouble *parm_range;
IGRint *num_minbnd_edges, *num_maxbnd_edges;
struct GRid **minbnd_edges, **maxbnd_edges;
IGRdouble *min_bnd_v, *max_bnd_v;
{
IGRint ii;

  struct GRid *edges=0;
  IGRint buf_size, num_edges, i;
  IGRdouble tolr, beginpt[2], endpt[2], *parmpts, *ptr_pts;
  IGRdouble vmin_u0, vmax_u0, vmin_u1, vmax_u1;
  IGRint vmin_u0_ind, vmax_u0_ind, vmin_u1_ind, vmax_u1_ind;
  IGRboolean orient_clockwise = TRUE;
  IGRlong sts, loc_msg;
  
  IGRlong bsrc;
  IGRdouble pt_on_edge[2];
  struct EMSpartolbasis pt_edge_tol;

  /* initialize */
  *msg = EMS_S_Success;
  sts = OM_S_SUCCESS;
  
  /* get parameter space tolerance */
  BSxtractpar(&loc_msg, BSTOLPARAM, &tolr);

tolr *= 1000;

  edges=0;
  buf_size = num_edges = 0;
  sts = om$send(msg = message EMSsurface.EMgetedges(&loc_msg,
						    EMS_OPT_NONDEG_NONSEAM,
						    &edges,
						    &buf_size,
						    &num_edges,
						    NULL,
						    NULL,
						    NULL,
						    NULL),
		senderid = NULL_OBJID,
		targetid = surf->objid,
		targetos = surf->osnum);
  MF_EMerr_hndlr(EMSerror(sts & loc_msg), sts, OM_E_ABORT, quit);

  parmpts = (IGRdouble *) alloca(num_edges * 2 * sizeof(IGRdouble));
  ptr_pts = parmpts;
  for (i = 0; i < num_edges; i++)
  {
    sts = om$send(msg = message EMSedge.EMendpts(&loc_msg,
						 beginpt,
						 endpt,
						 NULL,
						 NULL,
						 NULL),
		  senderid = NULL_OBJID,
		  targetid = edges[i].objid,
		  targetos = edges[i].osnum);
    MF_EMerr_hndlr(EMSerror(sts & loc_msg), sts, OM_E_ABORT, quit);
    memcpy(ptr_pts, beginpt, sizeof(IGRdouble) * 2);
    ptr_pts += 2;
  }

  /* 
   * what a hack to workaround our wonderful system! 
   * if 4 edges, force pts close to u0 (or u1) edge to be on u0 (or u1) edge
   */
  
  if(num_edges == 4)
    {
    ptr_pts = parmpts;
    for(ii=0; ii<(num_edges*2); ii+=2)
      if( fabs(ptr_pts[ii]-0.0) < fabs(ptr_pts[ii]-1.0) )
        ptr_pts[ii] = 0.0;
      else
        ptr_pts[ii] = 1.0;
    }

  /* get parametric range on u = 0 and u = 1 */
  vmin_u0 = vmin_u1 = 2.0;
  vmax_u0 = vmax_u1 = -1.0;
  vmin_u0_ind = vmax_u0_ind = vmin_u1_ind = vmax_u1_ind = 0;
  i = 0;
  ptr_pts = parmpts;
  while (i < num_edges)
  {
    if (fabs(*ptr_pts) < tolr)
    {
      if (*(ptr_pts + 1) > vmax_u0)
      {
	vmax_u0 = *(ptr_pts + 1);
	vmax_u0_ind = i;
      }
      if (*(ptr_pts + 1) < vmin_u0)
      {
	vmin_u0 = *(ptr_pts + 1);
	vmin_u0_ind = i;
      }
    }
    else if (fabs(*ptr_pts - 1.0) < tolr)
    {
      if (*(ptr_pts + 1) > vmax_u1)
      {
	vmax_u1 = *(ptr_pts + 1);
	vmax_u1_ind = i;
      }
      if (*(ptr_pts + 1) < vmin_u1)
      {
	vmin_u1 = *(ptr_pts + 1);
	vmin_u1_ind = i;
      }
    }
    i++;
    ptr_pts += 2;
  }
  if (fabs(vmin_u0 - 2.0) < tolr || fabs(vmin_u1 - 2.0) < tolr ||
      fabs(vmax_u0 + 1.0) < tolr || fabs(vmax_u1 + 1.0) < tolr)
  {
    UI_status("No points on u = 0 or u = 1.");
    sts = OM_E_ABORT;
    goto quit;
  }
  parm_range[0] = vmin_u0;
  parm_range[1] = vmax_u0;
  parm_range[2] = vmin_u1;
  parm_range[3] = vmax_u1;

  /* determine the orientation of the edges */
  if (vmin_u0_ind != (num_edges - 1))
  {
    if (fabs(parmpts[(vmin_u0_ind + 1) * 2]) < tolr)
      orient_clockwise = FALSE;
  }
  else
  {
    if (fabs(parmpts[(vmin_u0_ind - 1) * 2]) > tolr)
      orient_clockwise = FALSE;
  }

  /* allocate memory */
  *minbnd_edges = (struct GRid *) om$malloc(size = (num_edges - 2) * sizeof(struct GRid));
  MF_EMerr_hndlr(!(*minbnd_edges), sts, OM_E_ABORT, quit);
  *maxbnd_edges = (struct GRid *) om$malloc(size = (num_edges - 2) * sizeof(struct GRid));
  MF_EMerr_hndlr(!(*maxbnd_edges), sts, OM_E_ABORT, quit);

  /* get boundary edge groups */
  if (vmax_u0_ind > vmin_u0_ind)
  {
    if (orient_clockwise == TRUE)
    {
      *num_minbnd_edges = vmin_u1_ind - vmin_u0_ind;
      for (i = vmin_u0_ind; i < vmin_u1_ind; i++)
	memcpy((*minbnd_edges) + i - vmin_u0_ind, edges + i, sizeof(struct GRid));

      *num_maxbnd_edges = vmax_u0_ind - vmax_u1_ind;
      for (i = vmax_u1_ind; i < vmax_u0_ind; i++)
	memcpy((*maxbnd_edges) + i - vmax_u1_ind, edges + i, sizeof(struct GRid));
    }
    else
    {
      if (vmin_u1_ind > vmax_u0_ind)
      {
	*num_minbnd_edges = num_edges - vmin_u1_ind + vmin_u0_ind;
	for (i = vmin_u1_ind; i < num_edges; i++)
	  memcpy((*minbnd_edges) + i - vmin_u1_ind, edges + i, sizeof(struct GRid));
	for (i = 0; i < vmin_u0_ind; i++)
	  memcpy((*minbnd_edges) + i + num_edges - vmin_u1_ind, edges + i, sizeof(struct GRid));

	*num_maxbnd_edges = vmax_u1_ind - vmax_u0_ind;
	for (i = vmax_u0_ind; i < vmax_u1_ind; i++)
	  memcpy((*maxbnd_edges) + i - vmax_u0_ind, edges + i, sizeof(struct GRid));
      }
      else
      {
	*num_minbnd_edges = vmin_u0_ind - vmin_u1_ind;
	for (i = vmin_u1_ind; i < vmin_u0_ind; i++)
	  memcpy((*minbnd_edges) + i - vmin_u1_ind, edges + i, sizeof(struct GRid));

	if (vmax_u1_ind > vmax_u0_ind)
	{
	  *num_maxbnd_edges = vmax_u1_ind - vmax_u0_ind;
	  for (i = vmax_u0_ind; i < vmax_u1_ind; i++)
	    memcpy((*maxbnd_edges) + i - vmax_u0_ind, edges + i, sizeof(struct GRid));
	}
	else
	{
	  *num_maxbnd_edges = num_edges - vmax_u0_ind + vmax_u1_ind;
	  for (i = vmax_u0_ind; i < num_edges; i++)
	    memcpy((*maxbnd_edges) + i - vmax_u0_ind, edges + i, sizeof(struct GRid));
	  for (i = 0; i < vmax_u1_ind; i++)
	    memcpy((*maxbnd_edges) + i + num_edges - vmax_u0_ind, edges + i, sizeof(struct GRid));
	}
      }
    }
  }
  else
  {
    if (orient_clockwise == TRUE)
    {
      if (vmin_u1_ind > vmin_u0_ind)
      {
	*num_minbnd_edges = vmin_u1_ind - vmin_u0_ind;
	for (i = vmin_u0_ind; i < vmin_u1_ind; i++)
	  memcpy((*minbnd_edges) + i - vmin_u0_ind, edges + i, sizeof(struct GRid));

	if (vmax_u1_ind > vmin_u0_ind)
	{
	  *num_maxbnd_edges = num_edges - vmax_u1_ind + vmax_u0_ind;
	  for (i = vmax_u1_ind; i < num_edges; i++)
	    memcpy((*maxbnd_edges) + i - vmax_u1_ind, edges + i, sizeof(struct GRid));
	  for (i = 0; i < vmax_u0_ind; i++)
	    memcpy((*maxbnd_edges) + i + num_edges - vmax_u1_ind, edges + i, sizeof(struct GRid));
	}
	else
	{
	  *num_maxbnd_edges = vmax_u0_ind - vmax_u1_ind;
	  for (i = vmax_u1_ind; i < vmax_u0_ind; i++)
	    memcpy((*maxbnd_edges) + i - vmax_u1_ind, edges + i, sizeof(struct GRid));
	}
      }
      else
      {
	*num_minbnd_edges = num_edges - vmin_u0_ind + vmin_u1_ind;
	for (i = vmin_u0_ind; i < num_edges; i++)
	  memcpy((*minbnd_edges) + i - vmin_u0_ind, edges + i, sizeof(struct GRid));
	for (i = 0; i < vmin_u1_ind; i++)
	  memcpy((*minbnd_edges) + i + num_edges - vmin_u0_ind, edges + i, sizeof(struct GRid));

	*num_maxbnd_edges = vmax_u0_ind - vmax_u1_ind;
	for (i = vmax_u1_ind; i < vmax_u0_ind; i++)
	  memcpy((*maxbnd_edges) + i - vmax_u1_ind, edges + i, sizeof(struct GRid));
      }
    }
    else
    {
      *num_minbnd_edges = vmin_u0_ind - vmin_u1_ind;
      for (i = vmin_u1_ind; i < vmin_u0_ind; i++)
	memcpy((*minbnd_edges) + i - vmin_u1_ind, edges + i, sizeof(struct GRid));

      *num_maxbnd_edges = vmax_u1_ind - vmax_u0_ind;
      for (i = vmax_u0_ind; i < vmax_u1_ind; i++)
	memcpy((*maxbnd_edges) + i - vmax_u0_ind, edges + i, sizeof(struct GRid));
    }
  }

  om$dealloc(ptr = edges);

  *min_bnd_v  = -1;
  *max_bnd_v  = -1;

  BSEXTRACTPAR (&bsrc, BSTOLLENVEC, pt_edge_tol.tol);
  MF_EMerr_hndlr (bsrc != BSSUCC, sts, OM_E_ABORT, quit);

  pt_edge_tol.is_valid = TRUE;

  if(*num_minbnd_edges == 1)
    {
    sts = om$send (msg = message EMSedge.EMinternalpt (msg,
                   1, 0, pt_on_edge, NULL, &pt_edge_tol),
                   senderid = NULL_OBJID,
                   targetid = minbnd_edges[0]->objid,
                   targetos = minbnd_edges[0]->osnum);
    MF_EMerr_hndlr (EMSerror (sts & *msg), sts, OM_E_ABORT, quit);

    *min_bnd_v  = pt_on_edge[1];
    }

  if(*num_maxbnd_edges == 1)
    {
    sts = om$send (msg = message EMSedge.EMinternalpt (msg,
                   1, 0, pt_on_edge, NULL, &pt_edge_tol),
                   senderid = NULL_OBJID,
                   targetid = maxbnd_edges[0]->objid,
                   targetos = maxbnd_edges[0]->osnum);
    MF_EMerr_hndlr (EMSerror (sts & *msg), sts, OM_E_ABORT, quit);

    *max_bnd_v  = pt_on_edge[1];
    }

 quit:

#ifdef REALLY_DEBUG
 fprintf(stderr, "num_minbnd_edges %d\n", *num_minbnd_edges);
for(ii=0; ii<(*num_minbnd_edges); ii++)
 fprintf(stderr, "ed id %d\n", (*minbnd_edges)[ii].objid);

 fprintf(stderr, "num_maxbnd_edges %d\n", *num_maxbnd_edges);
for(ii=0; ii<(*num_maxbnd_edges); ii++)
 fprintf(stderr, "ed id %d\n", (*maxbnd_edges)[ii].objid);

 fprintf(stderr, "*min_bnd_v %lf\n", *min_bnd_v);
 fprintf(stderr, "num_maxbnd_edges %d\n", *num_maxbnd_edges);
 fprintf(stderr, "*max_bnd_v %lf\n", *max_bnd_v);
 fflush(stderr);
#endif

  return sts;
}


/*
 *  TBD
 */

ECfl_sf_edge(msg, active_md_env, prev_id, curr_id, prev_sf, curr_sf,
             prev_sf_type, prev_sf_hotv, curr_edge_id, curr_edge_indx,
             curr_edge_geom, uv_point)
IGRlong                        *msg;                  /* O */
struct GRmd_env                *active_md_env;        /* I */
struct GRid                    *prev_id, *curr_id;    /* I */
struct IGRbsp_surface          *prev_sf, *curr_sf;    /* I optional */
IGRint                         *prev_sf_type;         /* I */
IGRdouble                      *prev_sf_hotv;         /* I optional */
struct GRid                    *curr_edge_id;         /* O */
IGRint                         *curr_edge_indx;       /* O */
struct IGRbsp_curve            **curr_edge_geom;      /* O optional */
IGRdouble                      uv_point[];            /* O */
{

  IGRlong                      rc=BSSUCC, ret0=OM_S_SUCCESS;
  IGRboolean                   free_l_prev_sf=0, free_l_curr_sf=0, intersect;
  struct IGRbsp_surface        *l_prev_sf=0, *l_curr_sf=0;
  IGRint                       ii, array_size, num_edges;
  IGRdouble                    pt_on_surf[2], chttol, min_dist;
  IGRpoint                     from_pt, to_pt;
  struct GRid                  *edges=0;
  struct EMSpartolbasis        pt_edge_tol;


  *msg = EMS_S_Success;


  /*
   * if surface geometry is not passed in, get it
   */

  if(prev_sf)
    l_prev_sf = prev_sf;
  else
    {
    free_l_prev_sf = 1;
    ret0 = EMgetvggeom ( msg,
                         &active_md_env->md_env.matrix_type,
                         active_md_env->md_env.matrix,
                         prev_id, &l_prev_sf, 0 );
    MF_EMerr_hndlr (EMSerror (ret0 & *msg), ret0, OM_E_ABORT, ret_end);
    }

  if(curr_sf)
    l_curr_sf = curr_sf;
  else
    {
    free_l_curr_sf = 1;
    ret0 = EMgetvggeom ( msg,
                         &active_md_env->md_env.matrix_type,
                         active_md_env->md_env.matrix,
                         curr_id, &l_curr_sf, 0 );
    MF_EMerr_hndlr (EMSerror (ret0 & *msg), ret0, OM_E_ABORT, ret_end);
    }


  /*
   * get edges of prev sf
   */

  array_size = 0;
  num_edges  = 0;
  edges      = 0;

  ret0= om$send(msg = message EMSsubbs.EMget_edges(msg, MAXINT,
                EMS_OPT_NON_DEG_SEAM_XYZCLSD, active_md_env, &edges,
                &array_size, &num_edges),
                senderid = NULL_OBJID,
                targetid = prev_id->objid,
                targetos = prev_id->osnum);
  MF_EMerr_hndlr (EMSerror (ret0 & *msg), ret0, OM_E_ABORT, ret_end);

  BSEXTRACTPAR (&rc, BSTOLLENVEC, pt_edge_tol.tol);
  MF_EMerr_hndlr (rc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
  pt_edge_tol.is_valid = TRUE;

  BSEXTRACTPAR (&rc, BSTOLCHRDHT, chttol);
  MF_EMerr_hndlr (rc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

  intersect = 0;
  for(ii=0; ii<num_edges; ii++)
    {

    /*
     * get midpt of each edge
     */

    ret0 = om$send (msg = message EMSedge.EMinternalpt (msg,
                    1, 0, uv_point, NULL, &pt_edge_tol),
                    senderid = NULL_OBJID,
                    targetid = edges[ii].objid,
                    targetos = edges[ii].osnum);
    MF_EMerr_hndlr (EMSerror (ret0 & *msg), ret0, OM_E_ABORT, ret_end);

    if( (prev_sf_type) && (*prev_sf_type == FIL_ELEMENT) )
      {
      if(fabs(uv_point[1] - *prev_sf_hotv) < EQUAL_TOL)
        {
        intersect = 1;
        break;
        }
      }
    /* if(*prev_sf_type == FIL_ELEMENT) */
    else
      {

      /*
       * get mindist of this pt from fillet
       */

      if(fabs(uv_point[1] - 0.0) < EQUAL_TOL)
        uv_point[1] = 0.0;
      if(fabs(uv_point[0] - 0.0) < EQUAL_TOL)
        uv_point[0] = 0.0;

      BSsfeval(l_prev_sf, uv_point[0], uv_point[1], 0, from_pt, &rc);
      MF_EMerr_hndlr (rc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

      BSmdistptsf(&rc, l_curr_sf, from_pt, &pt_on_surf[0], &pt_on_surf[1], 
                  to_pt, &min_dist);
      MF_EMerr_hndlr (rc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

      /*
       * if mindist is within chttol, we impose this edge on fillet
       */

      if( min_dist <= chttol)
        {
        intersect = 1;
        break;
        }
      }
    /* else */

    } /* for num_edges */

  if(!intersect)
    {
    curr_edge_id->objid = NULL_OBJID;
    *curr_edge_indx   = -1;
    }
  else
    {
    curr_edge_id->objid = edges[ii].objid;
/* fix for abr */
    curr_edge_id->osnum = edges[ii].osnum;
    *curr_edge_indx   = ii;

    if(curr_edge_geom)
      {

      if(! *curr_edge_geom)
        {
        *curr_edge_geom = ( struct IGRbsp_curve * ) om$malloc(
                            size = sizeof( struct IGRbsp_curve ) );
        MF_EMerr_hndlr( (! *curr_edge_geom), *msg, EMS_E_NoDynamicMemory,
                        ret_end );
        }

        (*curr_edge_geom)->poles = NULL;
        (*curr_edge_geom)->knots = NULL;
        (*curr_edge_geom)->weights = NULL;
 
        ret0 = om$send( msg = message EMSedge.EMget_bcxyz_geom(
                        msg, &active_md_env->md_env,
                        prev_id, l_prev_sf,
                        0, MAXINT, FALSE, NULL, *curr_edge_geom ),
                        senderid = NULL_OBJID,
                        targetos = edges[ii].osnum,
                        targetid = edges[ii].objid);
        MF_EMerr_hndlr (EMSerror (ret0 & *msg), ret0, OM_E_ABORT, ret_end);

      }
    /* if(curr_edge_geom) */
    }
  /* else do intersect */
    

ret_end:

  MEM_FREE(edges);

  if(free_l_prev_sf)
    MEM_FREE(l_prev_sf);

  if(free_l_curr_sf)
    MEM_FREE(l_curr_sf);

  EMWRAPUP (*msg, ret0, "ECfl_sf_edge");
  return ret0;

}
/* ECfl_sf_edge */

/*
 * DESCRIPTION:

        Given two extent parameters, this function extracts a partial surface
        from a fillet.  The bounds of the extracted surface is u0, u1, and the
        two v-constant iso lines at each of the extent parameters.

 * Input : options              : none
           fillet_geom          : The fillet surface from which a partial
                                  surface is to be extracted.
           extent_points        : u,v parameters of two points that defines
                                  the extent of the new surface.
           direction_point_XYZ  : If the fillet is v_physically_closed, then
           direction_point_UV     one of these is used to resolve the
                                  ambiguity of which section of the fillet is
                                  required.
                                  The XYZ point need not be a point on the
                                  fillet.  It can be a point in the visinity of
                                  the fillet section that is to be retained.
                                  The UV of course must be a pair on the
                                  fillet (indicating which section is to be
                                  kept).  It is illegal to specify both, or
                                  specify NULL for both.

 * Output : msg                 : Return code.
            new_surface         : The extracted surface.  If *new_surface
                                  == NULL on entry, then memory is allocated.
                                  The caller should utilize BSfreesf(), when
                                  freeing that memory [thus, if the caller is
                                  passing in a surface, then that surface
                                  should be allocated using BSalloc()].  If
                                  NULL was passed in, then the output surface
                                  will be assigned only on no errors.

 * History :
        Janaka  : June 17, 1992 : Genesis
*/


void JANAKAextract_partial_fillet( EMmsg, options, fillet_geom,
                                   extent_points_UV, direction_point_XYZ,
                                   direction_point_UV, new_surface )
IGRlong                 *EMmsg;
IGRushort               options;
struct IGRbsp_surface   **new_surface,
                        *fillet_geom;
IGRdouble               extent_points_UV[2][2],
                        *direction_point_XYZ,
                        *direction_point_UV;
{
   IGRlong                      u_num_poles,
                                v_num_poles,
                                msg;
   IGRdouble                    distance,
                                local_dir_point_UV[2];
   IGRpoint                     min_dist_point;
   struct IGRbsp_surface        *temp_surf_ptr;

   options = options;

   /*
    * Iniatialize and do some checks.
    */
       *EMmsg = EMS_S_Success;
       if( ( !direction_point_XYZ && !direction_point_UV ) ||
           ( direction_point_XYZ && direction_point_UV ) )
       {
          *EMmsg = EMS_E_InvalidArg;
          goto wrapup;
       }
       temp_surf_ptr = *new_surface;

   /*
    * If needed, allocated memory for the new surfae.
    */
       if( !temp_surf_ptr )
       {
          u_num_poles = fillet_geom->u_num_poles;
          v_num_poles = fillet_geom->v_num_poles +
                                           2 * fillet_geom->v_order - 1;
          BSallocsf( fillet_geom->u_order,
                     fillet_geom->v_order,
                     u_num_poles,
                     v_num_poles,
                     fillet_geom->rational,
                     ( IGRshort ) 0,
                     &temp_surf_ptr,
                     &msg );

          EMerr_hndlr( msg != BSSUCC, *EMmsg, EMS_E_NoDynamicMemory,
                       wrapup );
       }

   /*
    * If needed, evaluate the direction point UV.
    */
       if( direction_point_XYZ )
       {
          BSmdistptsf( &msg,
                    fillet_geom,
                    direction_point_XYZ,
                    &local_dir_point_UV[0],
                    &local_dir_point_UV[1],
                    min_dist_point,
                    &distance );
          EMerr_hndlr( msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup );
       }
       else
          OM_BLOCK_MOVE( direction_point_UV,
                         local_dir_point_UV,
                         2 * sizeof( IGRdouble ) );

    /*
     * Do the extraction, and clean up the new surface.
     */
        BSpartofsf( fillet_geom,
                    extent_points_UV[0][V] < extent_points_UV[1][V]
                          ? extent_points_UV[0] : extent_points_UV[1],
                    local_dir_point_UV,
                    extent_points_UV[0][V] < extent_points_UV[1][V]
                          ? extent_points_UV[1] : extent_points_UV[0],
                    ( IGRint ) 1,
                    temp_surf_ptr,
                    &msg );

        EMerr_hndlr( msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup );

        /*
         * Normalize the knot vector.
         */
              BSsnorkts( temp_surf_ptr->u_order,
                         temp_surf_ptr->v_order,
                         temp_surf_ptr->u_num_poles,
                         temp_surf_ptr->v_num_poles,
                         temp_surf_ptr->u_knots,
                         temp_surf_ptr->v_knots,
                         ( IGRint ) 1,
                         &msg );
              EMerr_hndlr( msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup );

   /*
    * Assign output.
    */
       if( !( *new_surface ) )
          *new_surface = temp_surf_ptr;

wrapup:

   return;
}

IGRlong ECmf_free_copies(msg, active_md_env, num_copies, copies)
IGRlong *msg;
struct  GRmd_env *active_md_env;
IGRint  num_copies;
struct  ele_stack copies[];
{
  IGRint ii;
  IGRlong ret0=OM_S_SUCCESS;

  *msg = EMS_S_Success;

  for(ii=0; ii<num_copies; ii++)
    {
    ret0 = om$send( msg = message GRgraphics.GRdelete(msg, active_md_env),
                    targetos = copies[ii].ele_grid.osnum,
                    targetid = copies[ii].ele_grid.objid,
                    senderid = NULL_OBJID);
    MF_EMerr_hndlr (EMSerror (ret0 & *msg), ret0, OM_E_ABORT, ret_end);
 
    }
  /* for */

ret_end:

  return ret0;

}
/* ECmf_free_copies */

end implementation  EMSedge;
