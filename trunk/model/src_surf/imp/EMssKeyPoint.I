/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

# include "OMminimum.h"         /* for gocmacros.h                  */
# include "igrtypedef.h"        /* for gocmacros.h                  */
# include "gocmacros.h"         /* GRgetabsg macro                  */
# include "msdef.h"             /* MS message codes                 */
# include "madef.h"             /* MA message codes                 */
# include "bserr.h"             /* BS message codes                 */
# include "EMSbnddef.h"         /* EMS loopset properties keywords  */
# include "EMSlmdef.h"          /* Has EMS_GET_MOD_VERT             */
# include "emsdef.h"            /* MAXDOUBLE                        */
# include "EMSlogic.h"          /* EMSmsgReport                     */
# include "EMStypedef.h"        /* EMSmsgReport                     */
# include "EMScmacros.h"        /* EMSmsgReport                     */
# include "EMSfrtdef.h"         /* RLT_BUFFER_SIZE                  */
# include "OMlimits.h"          /* lc.h replacement                 */
# include "igetypedef.h"
# include "ex.h"
# include "igr.h"
# include "igrdp.h"
# include "dp.h"
# include "godef.h"
# include "gr.h"
# include "go.h"
# include "griodef.h"
# include "grio.h"
# include "lcdef.h"
# include "lc.h"                /* struct GRlc_stack */
# include "emsdef.h"            /* channel definitions for EMmake_chanselect */

# define A_VERY_BIG_NUMBER MAXDOUBLE
# define A_VERY_VERY_BIG_NUMBER MAXDOUBLE

from EMSgradata import EMkeypoint;
from EMSloopset import EMget_props;

extern IGRchar  EMSrltBuffer[RLT_BUFFER_SIZE];
extern IGRint   EFrule_lines_on_off();

method GRkeypoint(
  IGRlong *EMmsg;                       /* Error return code */
  IGRshort *matrix_type;                /* My matrix type */
  IGRmatrix matrix;                     /* My matrix */
  struct IGRline *boreline;             /* Bore line for projection */
  IGRpoint keypoint;                    /* Closest keypoint */
  struct GRparms *key_parm)             /* Parameters for keypoint */
/* 
 DESCRIPTION
  
 This method returns the closest keypoint of a B-spline
 object to the input line.  If the polygon is on then
 the poles are considered to be keypoints.  If the surface
 is being displayed then the following point are considered
 to be keypoints:

 1) All modifiable vertices - as if this surface were in a solid
 2) The endpoints of all displayed rulelines
  
 RETURN VALUES
 
 keypoint             The keypoint on the polygon or smooth surface
  
 key_parm             Information about the keypoint found.  Contains
                      the (u,v) parameters or pole indices.  
  
 EMmsg                MSSUCC if success
                      MANOMEMORY if no memory
                      MSFAIL if problems 
  
 BUGS

 If the surface has boundaries then it is certainly possible that the
 closest keypoint will not be chosen.  This is because for modifiable
 vertices distances are computed in parametric space.  This would
 not really be a problem except that there is a hard-coded maximum
 stack size that vertices are able to add themselves to.

 HISTORY
  
 06/27/86 : rlw : The beginning
 09/21/86 : rlw : OM 4.0 conversion
 01/26/87 : rlw : Rewritten as per nucleus changes to return GRparms
 05/26/87 : rlw : Rewritten to use loopsets and frt objects, if present.
 07/15/87 : AIC : Changed A_VERY_BIG_NUMBER and A_VERY_VERY_BIG_NUMBER
                  to MAXDOUBLE; Removed assumption that no keypoints
                  returned implies no graphics data objects are present.
                  Changed error handlers. Took send to graphics data
                  objects out of the loop.

 18 September 87    AIC     Allow for frt objects on a natural surface.

 17 April   1989    AIC     Support MSC.
 18 July    1989    pp      Made prj_line_to_pole non-static.
 05-June-91         Jack    Only deal with rule lines if rule lines are
                            on.  2.0.1 Horizon Loops.            
 20-July-91         AIC     Make rule lines on/off window-specific.
 10/07/91           DLB     gradata.EMkeypoint was passed NULL for window
			    id instead of real window id.  gradat keypoint
                            implem. was referencing win id with obvious 
			    results on SUN.  Moved the get_win_id call
			    above the gradat.keypoint send and passed win_grid
			    to the keypoint mthd.
 
 08/18/92:          NP 	    The "matrix_type" argument comes in  as "IGRshort *" 
			    while the EMgetRuleLineTable method expects an "IGRint *"
			    thereby causing a problem in ANSI compile. Correctly 
			    typecast.    

*/
{
  IGRchar       *generic_pointer;
  IGRlong       sts;
  IGRdouble     poly_distsq, surf_distsq;
  IGRpoint      poly_point, surf_point;
  struct        GRparms poly_parms, surf_parms;
  struct        IGRbsp_surface *surface;
  struct        IGResbs element_specific;
  struct        IGResqbs *rlt = NULL;

  /*
   * Initialize
   */
  sts = OM_S_SUCCESS;
  *EMmsg = MSSUCC;

  /*
   * Find out if the polygon and/or pattern display is on
   */
  sts = om$send(msg = message EMSsubbs.GRgetattr(EMmsg,
                (IGRchar *)&element_specific), targetid = my_id);
  if(!(1 & *EMmsg & sts)) goto wrapup;

  /*
   * Generate my abstract data
   */
  GRgetabsg(EMmsg, matrix_type, matrix, &generic_pointer, i);
  if(! (1 & *EMmsg)) goto wrapup;
  surface = (struct IGRbsp_surface *) generic_pointer;

  if(element_specific.is_polydis)
  {
    IGRboolean   status, prj_line_to_pole();
    IGRlong      u_index, v_index;
    IGRdouble    poly_parameter;
    IGRpoint     poly_line;

    /*
     * Project this point onto the polygon
     */
    status = prj_line_to_pole(EMmsg, surface, boreline, poly_line,
                              &poly_parameter, poly_point, &u_index,
                              &v_index, &poly_distsq);
    if(! status) { *EMmsg = MSFAIL; goto wrapup; }
    poly_parms.u = u_index;
    poly_parms.v = v_index;
    poly_parms.polygon_inx = 1;
  }

  if(element_specific.is_surfdis)
  {
    IGRdouble           gradata_distsq;
    IGRpoint            gradata_point;
    struct GRparms      gradata_parms;
    OM_S_CHANSELECT     to_helpers;
    OM_S_CHANSELECT     to_my_loopset;
    struct GRid         win_grid;
    GRobjid             window_id;
    GRspacenum          window_os;
    void                EMSsubbs_get_locate_window();

    /*
     * Project this point onto the surface
     */
    EMmake_chanselect(EMSsubbs_to_loopset, &to_my_loopset);
    EMmake_chanselect(EMSrequester_to_helpers, &to_helpers);

    /*
     * Send to the graphics data objects.
     * If noone responds, use my rule line table
     */

    EMSsubbs_get_locate_window(&window_id, &window_os); /*Moved up-DLB*/
    
    win_grid.objid = window_id;  /*Added 10/07/91 - DLB*/
    win_grid.osnum = window_os;
     
    surf_distsq = A_VERY_BIG_NUMBER;
    gradata_distsq = A_VERY_VERY_BIG_NUMBER;
    *EMmsg = EMS_I_NoResponse;
    sts = om$send(msg = message EMSgradata.EMkeypoint(EMmsg, surface,
                    matrix_type, matrix, boreline, &gradata_distsq,
                    gradata_point, &gradata_parms, &win_grid),
                  p_chanselect = &to_helpers);
    if(sts IS OM_W_UNKNOWN_MSG) sts = OM_S_SUCCESS;
    if(! (1 & *EMmsg & sts)) goto wrapup;

    if(*EMmsg IS EMS_I_NoResponse &&
        EFrule_lines_on_off(window_id, window_os))
    {
      void              EFrltKeyPt();
      IGRuint           ls_count;
      OM_S_CHANSELECT   to_loopset;

      EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);
      om$get_channel_count(object = me,
                           p_chanselect = &to_loopset,
                           count = &ls_count);

      sts = om$send(msg = message EMSsubbs.EMgetRuleLineTable(
                        EMmsg,
/*                      ls_count ? FALSE : TRUE, */
                        TRUE,
                        NULL,
                        NULL,
                        surface,
                        (IGRint *)matrix_type,
                        matrix,
                        EMSrltBuffer,
                        RLT_BUFFER_SIZE,
                        &rlt),
                    targetid = my_id);
      if(! (1 & *EMmsg & sts)) goto wrapup;

      /*
       * We now have a natural rule line table.  Call a function which
       * will find the closest point in this table to the input boreline.
       */
      surf_distsq = A_VERY_BIG_NUMBER;
      EFrltKeyPt(surface, rlt, boreline, surf_point, &surf_parms,
                 &surf_distsq, EMmsg);
      if(! (1 & *EMmsg)) goto wrapup;

    } /* if no graphics data object responds */

    if (gradata_distsq < surf_distsq)
    {
      surf_distsq = gradata_distsq;
      surf_point[0] = gradata_point[0];
      surf_point[1] = gradata_point[1];
      surf_point[2] = gradata_point[2];
      surf_parms = gradata_parms;
    } /* if (gradata_distsq < surf_distsq) */

    surf_parms.polygon_inx = 0;
  }

  /*
   * Return the one with minimum distance
   */
  if (element_specific.is_polydis &&
      ((!element_specific.is_surfdis) ||
       (poly_distsq < surf_distsq)))
  {
    *key_parm = poly_parms;
    keypoint[0] = poly_point[0];
    keypoint[1] = poly_point[1];
    keypoint[2] = poly_point[2];
  }
  else if (element_specific.is_surfdis)
  {
    *key_parm = surf_parms;
    keypoint[0] = surf_point[0];
    keypoint[1] = surf_point[1];
    keypoint[2] = surf_point[2];
  }
  else
  {
    *EMmsg = MSINARG;
    return(OM_E_ABORT);
  }

  key_parm->leaf_id.objid = my_id;
  key_parm->leaf_id.osnum = OM_Gw_current_OS;

/*
 * End of routine
 */
wrapup:
  if (rlt && (rlt ISNT (struct IGResqbs *)EMSrltBuffer)) om$dealloc(ptr = rlt);
  EMSmsgReport(sts, "\tEMSsubbs.EMsskeypoint", FALSE);
  EMSmsgReport(*EMmsg, "\tEMSsubbs.EMsskeypoint", FALSE);
  *EMmsg = MSSUCC;
  return(OM_S_SUCCESS);
}

/*
 * This function computes the minimum distance between the input line
 * and the polygon points.  It returns the closest pole, the minimum distance
 * squared, the offsets to the closest pole, the point on the line, and the
 * parameter on the line.  The pole offsets are zero relative, i.e. the
 * x coordinate of the closest pole is:
 * surface->pole[(u_pole_index + v_pole_index * surface->u_num_poles) * 3]
 */

#define STATIC_UNWEIGHTED_SIZE 50

short prj_line_to_pole(msg, surface, line, line_point, line_parameter,
                              projected_point, u_pole_index, v_pole_index, 
                              minimum_distsq)

int             *msg;
struct          IGRbsp_surface *surface;
struct          IGRline *line;
IGRdouble        line_point[3];
IGRdouble       *line_parameter;
IGRdouble        projected_point[3];
int             *u_pole_index, *v_pole_index;
IGRdouble       *minimum_distsq;

{
 short          status;
 extern short   MAlnpsproj(), MA2pt2dis(), BSunwght_p();
 int            pole_index, weight_index, pole_offset, weight_offset;
 int            loc_msg, pole_number, num_bytes, i;
 IGRdouble      distsq, pnt_on_line[3], pole[3], t_of_line, *unweighted_poles;
 IGRdouble      static_unweighted_poles[STATIC_UNWEIGHTED_SIZE][3];
 struct         IGRpointset point_set;

/*
 * Loop around all the poles
 */ 
 *msg = MSSUCC;
 *minimum_distsq = A_VERY_BIG_NUMBER;           /* Hopefully big enough */
 pole_index = 0;
 weight_index = 0;
 pole_offset = surface->u_num_poles * 3;
 weight_offset = surface->u_num_poles;
 point_set.num_points = surface->u_num_poles;
 if (surface->rational)
  {
   if (surface->u_num_poles > STATIC_UNWEIGHTED_SIZE)
    {
     num_bytes = surface->u_num_poles * 3 * sizeof(double);
     unweighted_poles = (double *) malloc(num_bytes);
     if (!unweighted_poles)
      {
       *msg = MANOMEMORY;
       goto wrapup;
      }
    }
   else
    unweighted_poles = &static_unweighted_poles[0][0];
   point_set.points = unweighted_poles;
  }
 for (i = 0; i < surface->v_num_poles; i++)
  {
   if (surface->rational)
    status = BSunwght_p(&loc_msg, &surface->poles[pole_index], 
                        &surface->weights[weight_index],
                        &surface->u_num_poles, unweighted_poles);
   else
    point_set.points = (double *) &surface->poles[pole_index];
   status = MAlnpsproj(msg, line, &point_set, pnt_on_line, pole,
                       &t_of_line, &pole_number);
    if (!status) goto wrapup;
   status = MA2pt2dis(msg, pnt_on_line, pole, &distsq);
    if (!status) goto wrapup;
   if (distsq < *minimum_distsq)
    {
     *minimum_distsq = distsq;
     projected_point[0] = pole[0];
     projected_point[1] = pole[1];
     projected_point[2] = pole[2];
     *u_pole_index = pole_number - 1;
     *v_pole_index = i;
     line_point[0] = pnt_on_line[0];
     line_point[1] = pnt_on_line[1];
     line_point[2] = pnt_on_line[2];
     *line_parameter = t_of_line;
    }
   pole_index += pole_offset;
   weight_index += weight_offset;
  }

wrapup:
  if(surface->rational && 
     unweighted_poles &&
     (unweighted_poles != &static_unweighted_poles[0][0])) 
  free(unweighted_poles);

  if(*msg & 1) return(TRUE);
  else return(FALSE);
}

end implementation EMSsubbs;
