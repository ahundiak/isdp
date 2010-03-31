/*
  DESCRIPTION:

    This method constructs the offset composite surface of this object
    given the distance to offset and a Boolean flag indicating inward or
    outward offset. The following options are supported:
    EMS_opt_offsetS_extend_start
    EMS_opt_offsetS_shorten_start
    EMS_opt_offsetS_by_delta_at_start
    EMS_opt_offsetS_extend_stop
    EMS_opt_offsetS_shorten_stop
    EMS_opt_offsetS_by_delta_at_stop

    If the curve is closed, then the start and stop refer to the planar
    faces at the start and sweep angle respectively. When the curve is open,
    only the extend/shorten option can be excercised and the extension or
    shortening is interpreted to mean bring about the offset to line up with
    the original curve's start/stop point.

  HISTORY:

    SS   :  03/30/92  :  Creation
   ashok :  09/15/92  :  Initializing 'uparm' before sending 'GRmidpoint' 
			 message. Also made changes to handle surfaces created
			 by revolving closed profiles. However the options
			 to shorten and extend are not supported yet.
 Sudhakar:  10/01/92  :  Modified to support "no_offsetsfs" in my components.
   Ashok		 Of course only planar components are eligible. If
			 the compisite surface is created by revolving an
		         open curve then only planer surfaces at the ends are
			 eligible "no-offset" surfaces and both can be present
			 in the "no_offsetsfs" list (ie maximum 2). If
			 the revolve curve is closed then any planar component
			 of the composite surface is an eligible "no-offset"
			 surface but there can be only one such surface in
			 the list (ie maximum 1 ).
 Sudhakar:  10/09/92  :  Added code to "trim" the offset surface at its ends
			 by "distance" if incoming option is appropriately set
			 for solids of revolution with sweep_angle < 360 deg.
 Sudhakar:  10/29/92  :  Modified code for open-curve-based sweep-solids with
                         open-caps such that the 'butt_end' boolean option
                         is set for end-segments/tangent-at-endpt inclined at
                         angles between 84 and 96 degrees with the axis of
                         revolution. Also added the capability to generate
                         solids-of-revolution for open-curves with the 
                         end-segments/tangent-at-endpts leaning 'inwards'.
   sam   :  01/19/93  :  Added addtional argumants to EMoffset .
 Sudhakar:  01/29/93  :  Forced to do composite offset unless 
                         USE_SMART_OFFSET is set.
 Sudhakar:  03/19/93  :  Modifying to take care of multiple offset distances
                         and any surface being an open surface. 
                         Used the new option 'EMS_opt_offsetS_of_sfsolid'
                         as the condition for finding the endcap offset dists.
 Sudhakar:  05Jul'93  :  Modified to take care of problems with
                         curve touching axis of revolution (TR# 11925726)
                         and start and stop planes for 'rev_sweep < 360'.
 Sudha   :  7/21/93   :  BSprototype ansification.
 Sudhakar:  09/08/93  :  Modified to invoke the 'general offset algorithm'
                         if and only :
                          i) this special algorithm fails and
                         ii) this 'EMoffset' has not been called from
                             the 'EMoffset' at the 'EMSsfsolid' level.
                         Got rid of the USE_SMART_OFFSET ifdef.
 Sudhakar: 01/28/94   :  Modified to not invoke the general algorithm if the
                         "EMS_opt_offsetS_special_algo_only" option is set.
*/

class implementation EMSrevcompsf;

%safe
#include <math.h>
%endsafe
#include "OMmacros.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bsicmpcvoff.h"
#include "emssfintdef.h"
#include "EMSconstruct.h"
#include "gr.h"
#include "emssfint.h"
#include "magrotmx.h"
#include "maptlnpro.h"
#include "maptsxfor.h"
#include "bsdotp.h"
#include "bscrossp.h"
#include "bsnorvec.h"
#include "bsmkvec.h"
#include "bslenvec.h"
#include "bsdistptpt.h"

#define FIRST  0
#define SECOND 1
#define THIRD  2

#define START  0
#define STOP   1

#define REV_CRV	   0
#define REV_BASE   1
#define REV_DIR    2
#define REV_START  3
#define REV_SWEEP  4

#define OFFCENTRE_PARAM 0.475

#define EXTENSION_FACTOR  3

extern GRclassid OPP_GR3dlineseg_class_id, OPP_GRcompcurve_class_id;

from expression import NDgive_value;
from EMSparamgm import EMgetgeom;
from GRcurve import EMcvtanorm, EMcvoffset, GRmidpoint, GRendpts, GRdisextend;
from GRcurve import EMcrvcrvint, GR2ptpartdel;
from GRcompcurve import EMmakecomp;
from EMSsubbs import EMsftanorm, EMgetbsdef;
from EMSsfboolean import EMboolean;
from EMSdpr import EMmake_primitive1;
from EMSplane import EMplane_of_curve;

method EMoffset (IGRlong *msg; IGRushort options;
                 IGRshort *mattyp; IGRmatrix mat;
                 struct GRvg_construct *construct_list;
                 IGRboolean is_natural_normal;
                 IGRdouble distance;
                 IGRint num_spec_thick;
                 IGRdouble *val_spec_thick;
                 struct GRobjid_set *spec_thick_sf_sets;
                 IGRint num_nooffsetsfs; GRobjid *nooffsetsfs;
                 IGRchar status_str[];
                 GRobjid *constructed_object;
                 struct EMSerror_help *errkey_list)
{
  IGRboolean is_composite, volume_on_cvside, endcap[2], endadd[2], is_closed;
  IGRchar *save_ptr;
  IGRushort chkopt;
  IGRshort dum_s, tmattyp, num_iter;
  IGRint i, j, k, num_inters, num_overlaps, *off_code;
  OMuint count;
  IGRint dum1, dum2;
  IGRlong stat_OM, msg_loc, inx;
  IGRdouble rev_start, rev_sweep, upar, vpar, knots[4];
  IGRdouble t, delta, coltol, chttol, *cpoles, *cpoles1;
  IGRvector vec, axis_vec, test_vec, view_vec, crv_side_vec, solid_side_vec;
  IGRpoint pt, axis_pts[2], tanpts[2], nrmpts[2], poles[2];
  IGRpoint endpts[2], old_endpts[2], old_endpts_axis[2], *int_pts;
  IGRmatrix tmat;
  GRobjid obj1, obj2, tmpobj, cp_rev_crv, endcrv,save_objid;
  GRclassid objclass;
  GRspacenum dumos;
  struct IGRbsp_surface srfdef;
  struct IGRbsp_curve line_crv, *cgeom;
  struct IGRpolyline py;
  struct IGRline ln;
  struct GRprops gmprops;
  struct GRparms *my_inters;
  struct GRmd_env md_env;
  struct GRparms uparm;
  struct GRid *paramids, rev_crv, off_rev_crv/*, tmp_grid*/;
  struct GRlc_info cvinfo;
  struct EMSsweep sweep_info;
  struct EMSgeomdata geom;
  OM_S_CHANSELECT chan_to_comps, chan_to_owners;
  extern IGRdouble fabs();

  IGRdouble   *offdists=NULL, *new_offdists=NULL;
  struct GRid  solid_GRid;
  IGRdouble    endoff[2], endseg_offdistance;
  IGRint       index, tcount, newcount;
  /* enum  GRdpmode      display_mode = GRbd;  */


  extern void EFget_offsetdistance_for_surface();


 IGRboolean   is_member[2], butt_end[2], ends_lined, trim_ends[2];
 IGRpoint     seg_endpts[2];
 IGRint       delin;
 OM_S_OBJECT_LINKAGE  *owner_comps;
 IGRdouble    dotp;


  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  paramids = NULL;
  my_inters = NULL;
  int_pts = NULL;
  off_rev_crv.objid = NULL_OBJID;
  owner_comps = NULL;
  butt_end[0] = butt_end[1] = FALSE;
  ends_lined = FALSE;
  trim_ends[0] = trim_ends[1] = FALSE;
  endadd[0] = endadd[1] = FALSE;
  cgeom = NULL;
  cpoles = cpoles1 = NULL;

  EMgetmdenv (&md_env, mattyp, mat, OM_Gw_current_OS);
  BSEXTRACTPAR (&msg_loc, BSTOLCOLLINVEC, coltol);
  BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, chttol);

  /*
   * Obtain the parent information - curve, axis points and the rev angles.
   */

  stat_OM = om$send (msg = message EMSassoc.EMpack_paraminfo (&msg_loc,
             NULL, NULL, NULL, NULL, NULL,(IGRint *) &count, &paramids, NULL,
             NULL, NULL, OM_e_wrt_object), targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  EMerr_hndlr (count != 5, *msg, EMS_E_InvalidCase, ret_end);

  rev_crv = paramids[REV_CRV];
  
  stat_OM = om$send (msg = message EMSparamgm.EMgetgeom (&msg_loc, NULL,
             mattyp, mat, &geom), targetid = paramids[REV_BASE].objid);
  EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);
  EMerr_hndlr (geom.geomtype != GEOMDATA_POINT, *msg, EMS_E_InvalidCase,
   ret_end);
  OM_BLOCK_MOVE (geom.point, axis_pts[FIRST], sizeof (IGRpoint));

  stat_OM = om$send (msg = message EMSparamgm.EMgetgeom (&msg_loc, NULL,
             mattyp, mat, &geom), targetid = paramids[REV_DIR].objid);
  EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);
  EMerr_hndlr (geom.geomtype != GEOMDATA_VECTOR, *msg, EMS_E_InvalidCase,
   ret_end);
  OM_BLOCK_MOVE (geom.vector, axis_vec, sizeof (IGRpoint));
  for (i=X; i<=Z; i++)
    axis_pts[SECOND][i] = axis_pts[FIRST][i] + axis_vec[i];

  stat_OM = om$send (msg = message expression.NDgive_value (&rev_start),
             targetid = paramids[REV_START].objid);
  EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_InvalidCase, ret_end);

  stat_OM = om$send (msg = message expression.NDgive_value (&rev_sweep),
             targetid = paramids[REV_SWEEP].objid);
  EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_InvalidCase, ret_end);

 /* Setting locl variable 'trim_ends' to indicate if the offset
    solid needs to be trimmed at the ends by 'distance' - S'kar 9th oct.'92*/
  if (rev_sweep < 360)
    for (i=START; i<=STOP; i++)
      if (options & (i== START ? (EMS_opt_offsetS_extend_start |
                                 EMS_opt_offsetS_shorten_start)
                              : (EMS_opt_offsetS_extend_stop |
                                 EMS_opt_offsetS_shorten_stop))) 
         trim_ends[i] = TRUE;


  /*
   * Determine if the curve flows such that the volume enclosed by this
   * surface is on the right or not, when viewed along a vector perpendicular
   * to the plane containing the axis and the starting point of the curve.
   */
  uparm.u = 0.5;		/* initialize uparm; else the message below  */
  uparm.polygon_inx = 0;        /* fails for wireframe primitives. If passed */
  uparm.leaf_id.objid = NULL_OBJID; /* as NULL it fails for composite curve  */

  stat_OM = om$send (msg = message GRcurve.GRmidpoint (&msg_loc, mattyp, mat,
             &uparm, pt), targetid = rev_crv.objid, targetos = rev_crv.osnum);
  EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);

  BSmkvec (&msg_loc, vec, axis_pts[FIRST], pt);
  BScrossp (&msg_loc, axis_vec, vec, view_vec);
  BSnorvec (&msg_loc, view_vec);

  om$get_classid (objid = rev_crv.objid, osnum = rev_crv.osnum,
   p_classid = &objclass);
  if (om$is_ancestry_valid (subclassid = objclass,
       superclassid = OPP_EMScomposite_class_id) == OM_S_SUCCESS)
    is_composite = TRUE;
  else
    is_composite = FALSE;

/* Check if the "revolve" curve is closed */

  om$send (msg = message GRvg.GRgeomprops (&msg_loc, mattyp, mat, &gmprops),
   targetid = rev_crv.objid);
  EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);

  if (gmprops.phy_closed) is_closed = TRUE;
  else is_closed = FALSE;

  uparm.u = OFFCENTRE_PARAM;
  uparm.polygon_inx = 0;
  uparm.leaf_id.objid = NULL_OBJID;
  EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
  if (is_composite)  
    stat_OM = om$send (msg = message GRcurve.EMcvtanorm (&msg_loc,
               mattyp, mat, NULL, 1, &uparm, NULL, NULL, 1.0, NULL,
               TRUE, NULL, (IGRdouble *) tanpts, NULL),
               p_chanselect = &chan_to_comps, senderid = rev_crv.objid,
               from = FIRST, to = FIRST);
  else
    stat_OM = om$send (msg = message GRcurve.EMcvtanorm (&msg_loc,
               mattyp, mat, NULL, 1, &uparm, NULL, NULL, 1.0, NULL,
               TRUE, NULL, (IGRdouble *) tanpts, NULL),
               targetid = rev_crv.objid, targetos = rev_crv.osnum);
  EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);

  BSmkvec (&msg_loc, vec, tanpts[FIRST], tanpts[SECOND]);
  BScrossp (&msg_loc, vec, view_vec, crv_side_vec);
  BSnorvec (&msg_loc, crv_side_vec);
  EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_InvalidCase, ret_end);

  stat_OM = om$send (msg = message EMSsubbs.EMgetbsdef (&msg_loc, &srfdef),
             p_chanselect = &chan_to_comps, from = FIRST, to = FIRST);
  EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);

  upar = OFFCENTRE_PARAM;
  vpar = 0.0;
  stat_OM = om$send (msg = message EMSsubbs.EMsftanorm (&msg_loc,
             mattyp, mat, NULL, 1, &upar, 1, &vpar, 1.0, NULL,
             FALSE, TRUE, (IGRdouble *) nrmpts, NULL),
             p_chanselect = &chan_to_comps, from = FIRST, to = FIRST);
  EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);

  BSmkvec (&msg_loc, solid_side_vec, nrmpts[FIRST], nrmpts[SECOND]);
  if (!srfdef.pos_orient)
    for (i=X; i<=Z; i++)
      solid_side_vec[i] = -solid_side_vec[i];

  if (BSdotp (&msg_loc, crv_side_vec, solid_side_vec) > 0.0)
    volume_on_cvside = TRUE;
  else
    volume_on_cvside = FALSE;

  /* Skar - Begin 
   * Determine the offset distances of the surfaces associated with
   * various segments of the curve 
   */
  if(is_composite)
    {
     count = 0;
     om$get_channel_count (objid = rev_crv.objid, osnum = rev_crv.osnum,
       p_chanselect = &chan_to_comps, count = &count);
    }
  else
    count = 1;

  if(count)
    {
     offdists = (IGRdouble *) om$malloc (size = count * sizeof(IGRdouble));
     new_offdists = (IGRdouble *) om$malloc(size = (count+2)*sizeof(IGRdouble));
                                       /* 2 - for the end-caps, if needed */
     for(i=0; i<count; i++)
       {
        /* Get the surface at the 'i'th index of the revolved surface */

        tmpobj = NULL_OBJID;
        om$get_objid_at_index (objid = my_id,
        osnum = rev_crv.osnum, p_chanselect = &chan_to_comps, index = i,
        objidaddr = &tmpobj, osnumaddr = &dumos);

        /* Determine the corresponding offset distance */
        EFget_offsetdistance_for_surface(tmpobj, distance,
                                            num_spec_thick,
                                            val_spec_thick,
                                            spec_thick_sf_sets,
                                            num_nooffsetsfs,
                                            nooffsetsfs,
                                            &offdists[i]);
#ifdef DEBUG
  printf("Offset distance of surface-id [ %d] = %lf\n", tmpobj, offdists[i]);
#endif
       }
    }
  /* Skar - End */

  /*
   * The curve that is used to offset must take into account the
   * end conditions. So a new curve is made up with additional pieces at the
   * ends representing the end-caps (if any) or a reflection of the ending
   * segment about the axis. Work on a copy of the rev-crv.
   */

  OM_BLOCK_MOVE (&md_env, &cvinfo.module_info, sizeof (struct GRmd_env));
  cvinfo.located_obj.osnum = rev_crv.osnum;

  stat_OM = om$send (msg = message GRgraphics.GRcopy (&msg_loc, &md_env,
             &md_env, &cp_rev_crv), targetid = rev_crv.objid,
             targetos = rev_crv.osnum);
  EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);


 /* Begin Preprocessing for Perpendicular (to the axis) end-segments(s)
                 Added on 9/30/92 - M.Sudhakar  */

 if (is_composite)
 {
    if(!is_closed)
    {
     
     count = 0;
     om$get_channel_count (objid = cp_rev_crv, osnum = rev_crv.osnum,
       p_chanselect = &chan_to_comps, count = &count);

     for (i=START, k=0, delin=0; i<=STOP; i++, k=count-1)
     {
        tmpobj = NULL_OBJID;
        om$get_objid_at_index (objid = my_id,
        osnum = rev_crv.osnum, p_chanselect = &chan_to_comps, index = k,
        objidaddr = &tmpobj, osnumaddr = &dumos);
     
        for (j=0, is_member[i]=FALSE; j<num_nooffsetsfs; j++)
        {
         if (tmpobj == nooffsetsfs[j])
             {
              is_member[i] = TRUE;
              break;
             };
        };
        if(!is_member[i])
        {
         if (options & (i == START ? (EMS_opt_offsetS_extend_start |
                                      EMS_opt_offsetS_shorten_start)
                                   : (EMS_opt_offsetS_extend_stop |
                                      EMS_opt_offsetS_shorten_stop)))
          {
             stat_OM = om$send (msg = message GRcurve.GRendpts (&msg_loc, 
				      mattyp, mat, seg_endpts[START], 
				      seg_endpts[STOP]), senderid = cp_rev_crv,
                                p_chanselect = &chan_to_comps, from = k, 
			        to = k);
             EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, 
			  ret_end);

             BSmkvec (&msg_loc, vec, seg_endpts[START], seg_endpts[STOP]);
	     BSnorvec(&msg_loc, vec);
#ifdef DEBUG           
printf("BSdotp = %lf\n", BSdotp (&msg_loc, axis_vec, vec) );
#endif

            if (fabs(BSdotp (&msg_loc, axis_vec, vec)) <=cos(84*3.141592/180.0))
             {
             /* End segment is-perpendicular to axis  */
               options &= (i == START ? ~(EMS_opt_offsetS_extend_start |
                                          EMS_opt_offsetS_shorten_start)
                                   : ~(EMS_opt_offsetS_extend_stop |
                                       EMS_opt_offsetS_shorten_stop));
	       butt_end[i] = TRUE;
             }; /* end of if (BSdotp...   */
 
          };  /* end of if (options....   */

        } /* end of if(!member) */

     } /* end of for (i=START...   loop  */
    } /* end of if part of if (!is_closed)  */

 } /* end of if(is_composite)   */

 else /* curve is not a composite */
 {
    /* If the curve is open then check if the tangent at the end points is
    perpendicular to the axis of revolution. If so and if that end has an
    end-cap to be left "open" (indicated by appropriate bit set in "options")
    then that  set  "butt_end" to TRUE */

    if(!is_closed)
      for(i=START; i<=STOP; i++)
      {
	if (options & (i == START ? (EMS_opt_offsetS_extend_start |
                                      EMS_opt_offsetS_shorten_start)
                                   : (EMS_opt_offsetS_extend_stop |
                                      EMS_opt_offsetS_shorten_stop)))

	{
	   uparm.u = i;
  	   uparm.polygon_inx = 0;
  	   uparm.leaf_id.objid = NULL_OBJID;
    	   stat_OM = om$send (msg = message GRcurve.EMcvtanorm (&msg_loc,
               mattyp, mat, NULL, 1, &uparm, NULL, NULL, 1.0, NULL,
               TRUE, NULL, (IGRdouble *) tanpts, NULL),
               targetid = cp_rev_crv, targetos = rev_crv.osnum);
          EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);

           BSmkvec (&msg_loc, vec, tanpts[FIRST], tanpts[SECOND]);
	   BSnorvec(&msg_loc, vec);
          if (fabs(BSdotp (&msg_loc, axis_vec, vec)) <= cos(84*3.141592/180.0))
           {
               /* End segment is-perpendicular to axis  */
               options &= (i == START ? ~(EMS_opt_offsetS_extend_start |
                                          EMS_opt_offsetS_shorten_start)
                                   : ~(EMS_opt_offsetS_extend_stop |
                                       EMS_opt_offsetS_shorten_stop));
	       butt_end[i] = TRUE;
             }; /* end of if (BSdotp...   */

	} /* if(options & ....) */

      } /* for(i=START...) */

 } /* else of if(is_composite) */          

 /* End Preprocessing for Perpendicular (to the axis) end-segments(s)
                 Added on 9/30/92 - M.Sudhakar  */

 /* Since the profile has changed from 'closed' to 'open' this algorithm
    may not be able to tackle the situation. Hence use the general
    composite offset algorithm 
  if(closed_to_open)
    {
     stat_OM = 0;
     *msg = EMS_E_Fail;
     goto ret_end;
    }
 */

  if(!is_closed)  /* End-conditions to be handled only for open curves */
  {
    if (!is_composite)
    {
      stat_OM = om$construct (classid = OPP_GRcompcurve_class_id,
                 msg = message GRgraphics.GRconstruct (construct_list),
                 p_objid = &tmpobj);
       EMerr_hndlr (EMSerror (stat_OM & *construct_list->msg), *msg,
       EMS_E_OMerror, ret_end);
  
      cvinfo.located_obj.objid = cp_rev_crv;
      stat_OM = om$send (msg = message GRcompcurve.EMmakecomp (&msg_loc,
                 &md_env, 1, &cvinfo, &inx), targetid = tmpobj);
      EMerr_hndlr (EMSerror (msg_loc & stat_OM) || inx == 0, *msg, EMS_E_Fail,
       ret_end);
  
      cp_rev_crv = tmpobj;
    }
  
    stat_OM = om$send (msg = message GRcurve.GRendpts (&msg_loc, mattyp, mat,
               old_endpts[START], old_endpts[STOP]),
               targetid = cp_rev_crv);
    EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);
  
    EMmake_chanselect (GRconnector_to_owners, &chan_to_owners);
    ln.point1 = axis_pts[FIRST];
    ln.point2 = axis_pts[SECOND];
    py.num_points = 2;
    py.points = (IGRdouble *) axis_pts;
    line_crv.poles = (IGRdouble *) poles;
    line_crv.knots = knots;
    line_crv.weights = NULL;
    line_crv.bdrys = NULL;
    EMcnvtpybsn (&msg_loc, 3, &py, &line_crv);

       /* Check for the case where the old-endpoints are in a line
          perpendicular to the axis. In this case the offset process
          fails if ends are extended. Hence end-extensions are not
          added, but options are set for extension/shorten and end-cap
          is set to true    */
    BSmkvec (&msg_loc, vec, old_endpts[FIRST], old_endpts[SECOND]);
    BSnorvec(&msg_loc, vec);
    if(fabs(BSdotp (&msg_loc, axis_vec, vec)) <= coltol)
       ends_lined = TRUE; /* Line joining old-endpts is-perpendicular to axis */
       
    count = 0;
    om$get_channel_count (objid = cp_rev_crv, osnum = rev_crv.osnum,
                          p_chanselect = &chan_to_comps, count = &count);
  
    for (i=START, j=STOP, k=0; i<=STOP; i++, j--, k=count-1)
    {
      BSmkvec (&msg_loc, vec, axis_pts[FIRST], old_endpts[i]);
      BScrossp (&msg_loc, axis_vec, vec, test_vec);
      if (BSlenvec (&msg_loc, test_vec) > coltol)
      {
        if (ends_lined)
        {
          /* Line joining old-endpts is perpendicular to axis  */
           endcap[i]= TRUE;
           endadd[i]= FALSE;

           MAptlnproj (&msg_loc, old_endpts[i], &ln, old_endpts_axis[i], &t);
           EMerr_hndlr (msg_loc != MSSUCC, *msg, EMS_E_Fail, ret_end);

           if (i == START)
             options |= (EMS_opt_offsetS_extend_start |
			 EMS_opt_offsetS_shorten_start);
           else
             options |= (EMS_opt_offsetS_extend_stop | 
			 EMS_opt_offsetS_shorten_stop);

           continue;
        }; /* end of if (ends_lined.... */

       /* The line joining old-endpts is not perpendicular to axis */ 

        endcap[i] = TRUE;
        endadd[i] = TRUE;
        
      /* Skar - Begin */
      /* End-planes donot exist if the curve was originally closed
         and became opne because of choice of open surface(s) OR
         if the input is only a surface and not a solid of revolution. */

        if(options & EMS_opt_offsetS_of_sfsolid)  
          { 
          /* Find the offset distance corresponding to the end-cap */
           stat_OM = om$get_objid_at_index(objid = my_id,
                                 osnum = rev_crv.osnum,
                                 index = 0,
                                 objidaddr = &solid_GRid.objid,
                                 osnumaddr = &solid_GRid.osnum,
                                 p_chanselect = &chan_to_owners);
#ifdef DEBUG
 printf("The Solid id = %d\n", solid_GRid.objid);
#endif
           EMerr_hndlr(!(1&stat_OM), *msg, EMS_E_OMerror, ret_end);

           stat_OM = om$get_objid_at_index(objid = solid_GRid.objid,
                                 osnum = solid_GRid.osnum,
                                 index = (i == START ? 1 : 2),
                                 objidaddr = &tmpobj,
                                 osnumaddr = &dumos,
                                 p_chanselect = &chan_to_comps);
           EMerr_hndlr(!(1&stat_OM), *msg, EMS_E_OMerror, ret_end);
#ifdef DEBUG
 printf("The end-plane id = %d\n", tmpobj);
#endif

           /* Determine the corresponding offset distance */
           EFget_offsetdistance_for_surface(tmpobj, distance,
                                            num_spec_thick,
                                            val_spec_thick,
                                            spec_thick_sf_sets,
                                            num_nooffsetsfs,
                                            nooffsetsfs,
                                            &endoff[i]);
#ifdef DEBUG
   printf("Offset distance of end-cap [%d] = %lf\n", i, endoff[i]);
#endif

          }  

        /* Skar - End */
  
        MAptlnproj (&msg_loc, old_endpts[i], &ln, old_endpts_axis[i], &t);
        EMerr_hndlr (msg_loc != MSSUCC, *msg, EMS_E_Fail, ret_end);
  
        OM_BLOCK_MOVE (old_endpts_axis[i], poles[i], sizeof (IGRpoint));
        OM_BLOCK_MOVE (old_endpts[i], poles[j], sizeof (IGRpoint));
        save_ptr = construct_list->class_attr;
        construct_list->class_attr = NULL;
        construct_list->geometry = (IGRchar *) &line_crv;
        save_objid = construct_list->env_info->md_id.objid;
        construct_list->env_info->md_id.objid = md_env.md_id.objid;
        stat_OM = om$construct (classid = OPP_GR3dlineseg_class_id,
                   msg = message GRvg.GRconstruct (construct_list), 
                   p_objid = &tmpobj);
        construct_list->class_attr = save_ptr;
        construct_list->env_info->md_id.objid = save_objid;
        EMerr_hndlr (EMSerror (stat_OM & *construct_list->msg), *msg,
         EMS_E_Fail, ret_end);
      }
      else
      {
        endcap[i] = FALSE;
        if (i == STOP && !is_composite && !endcap[START])
        {
          endadd[i] = FALSE;
          continue;
        }
        endadd[i] = TRUE;

        /* Skar - Begin */
        /* Set the offset distance same as that of the extreme segment */
        if(i == START)
           endoff[i] = offdists[k];
        else
           if(endadd[START])
              endoff[i] = offdists[k-1]; /* since count would be incremented.*/
           else
              endoff[i] = offdists[k];
      
#ifdef DEBUG
printf("Curve touching axis.\n");
printf("-offset distance of end-cap [%d] = %lf\n", i, endoff[i]);
#endif
        /* Skar - End */
  
        EMreflectmat (&ln, view_vec, tmat, &tmattyp);
  
        stat_OM = om$send (msg = message GRgraphics.GRcopy (&msg_loc, &md_env,
                   &md_env, &tmpobj), senderid = cp_rev_crv,
                   p_chanselect = &chan_to_comps, from = k, to = k);
        EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);
  
        stat_OM = om$send (msg = message GRgraphics.GRxform (&msg_loc, &md_env,
                   &tmattyp, tmat, &tmpobj), targetid = tmpobj);
        EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);
      }
  
      cvinfo.located_obj.objid = tmpobj;
      stat_OM = om$send (msg = message GRcompcurve.EMmakecomp (&msg_loc,
                 &md_env, 1, &cvinfo, &inx), targetid = cp_rev_crv);
      EMerr_hndlr (EMSerror (msg_loc & stat_OM) || inx == 0, *msg, EMS_E_Fail,
       ret_end);
      count++;
    }
  } /* if(!is_closed) */

  /*
   * Offset the curve towards the correct side and get rid of the
   * copy. Also get rid of the pseudo-end pieces added in to take care
   * of the end condition.
   */

  count = 0;

  if(!is_closed || is_composite)
    om$get_channel_count (objid = cp_rev_crv, osnum = rev_crv.osnum,
     p_chanselect = &chan_to_comps, count = &count);

  if (count)
    {
    off_code = (IGRint *) alloca (count * sizeof (IGRint));
    for (i=0; i<count; i++)
      off_code[i] = BSCONSTOFF;
    }
  else
    off_code = NULL;

  /* Skar - Begin */
  if(count)
    {
     newcount = count;
     if(!is_closed)
       {
        if(endadd[START])
           newcount--;
        if(endadd[STOP])
           newcount--;
       }

     index = 0;
     if(!is_closed && endadd[START])
           index++;
     for(i=0; i<newcount; i++)
       {
           new_offdists[index] = offdists[i];
           index++;
       }

     if(!is_closed && endadd[START])
        if((endoff[START] != 0.0) &&        /*corresponds to open surf*/
           (options & EMS_opt_offsetS_of_sfsolid))

           new_offdists[0] = endoff[START];
        else
           new_offdists[0] = new_offdists[1];
          
     if(!is_closed && endadd[STOP])
       {
        if((endoff[STOP] != 0.0) && /*corresponds to open surf*/
           (options & EMS_opt_offsetS_of_sfsolid))
           new_offdists[index] = endoff[STOP];
        else
           new_offdists[index] = new_offdists[index-1];
        index++;
       }
#ifdef DEBUG
 printf("count = %d; newcount = %d\n", count, newcount);
#endif
    } 
  else   /* Case of a single curve */
    {
     new_offdists[0] = offdists[0];
#ifdef DEBUG
 printf(" Single offset distance = %lf\n", new_offdists[0]);
#endif
    }
  /* Skar - End */


  save_ptr = construct_list->class_attr;
  construct_list->class_attr = NULL;
  save_objid = construct_list->env_info->md_id.objid;
        construct_list->env_info->md_id.objid = md_env.md_id.objid;
  stat_OM = om$send (msg = message GRcurve.EMcvoffset (&msg_loc, 
             mattyp, mat, construct_list, &new_offdists[0], view_vec,
             is_natural_normal ? volume_on_cvside : !volume_on_cvside,
             FALSE, off_code, FALSE, TRUE, &off_rev_crv,
             NULL, NULL, NULL), targetid = cp_rev_crv,
             targetos = rev_crv.osnum);
  construct_list->env_info->md_id.objid = save_objid;
  construct_list->class_attr = save_ptr;
  EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);
  EMerr_hndlr (msg_loc == EMS_I_BSerror || msg_loc == EMS_I_InvalidArg ||
   msg_loc == EMS_I_Degenerate, *msg, EMS_I_Degenerate, ret_end);

/* Temporary - Begin  
     stat_OM = om$send(msg = message GRgraphics.GRdisplay(&msg_loc,
                                    mattyp, mat, &display_mode,
                                    &construct_list->env_info->md_id),
                                 targetid = off_rev_crv.objid);
     EMerr_hndlr(!(1&stat_OM&msg_loc),*msg,EMS_E_Fail,ret_end);
   Temporary - End */

  stat_OM = om$send (msg = message GRgraphics.GRdelete (&msg_loc, &md_env),
             targetid = cp_rev_crv, targetos = rev_crv.osnum);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_OMerror, ret_end);

  if(!is_closed)
  {
    count = 0;
    om$get_channel_count (objid = off_rev_crv.objid,
                          p_chanselect = &chan_to_comps, count = &count);
    for (i=START, j=0; i<=STOP; i++, j=count-1)
    {
      if (!endadd[i])
        continue;
  
      stat_OM = om$send (msg = message GRgraphics.GRdelete (&msg_loc, &md_env),
                 p_chanselect = &chan_to_comps, senderid = off_rev_crv.objid,
                 from = j, to = j);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_OMerror, ret_end);
      count--;
    }

    if (!is_composite)
    {
      /* Added code to support butt ends */
      if(!butt_end[START] && !butt_end[STOP])
      {
      	tmpobj = NULL_OBJID;
      	om$get_objid_at_index (objid = off_rev_crv.objid,
       	osnum = off_rev_crv.osnum, p_chanselect = &chan_to_comps, index = FIRST,
       	objidaddr = &tmpobj, osnumaddr = &dumos);
  
      	om$send (msg = message GRconnector.GRdisconn (&msg_loc, &off_rev_crv), 
       	targetid = tmpobj, targetos = off_rev_crv.osnum);
  
      	om$send (msg = message GRgraphics.GRdelete (&msg_loc, &md_env),
       	targetid = off_rev_crv.objid, targetos = off_rev_crv.osnum);
  
      	off_rev_crv.objid = tmpobj;
      }
      else
	/* A butt needs to be provided at one or both ends. So the offset
	   curve needs to remain a composite curve
        */
	is_composite = TRUE;
    }
  } /* if(!is_closed) */

  /*
   * If the resultant offset should be stretched or shortened at either or
   * both ends, do so by adjusting the relevant parameters. A "delta"
   * stretch (or shortening) is a constant multiple of the current cht.
   * In the case of open curves, the stretch/shortening applies in the
   * polynomial direction of the end-curves. For closed curves it applies
   * in the direction of the sweep.
   */

  if(is_composite)
  {
     count = 0;
     om$get_channel_count (objid = off_rev_crv.objid,
      p_chanselect = &chan_to_comps, count = &count);
  }

  om$send (msg = message GRvg.GRgeomprops (&msg_loc, mattyp, mat, &gmprops),
   targetid = off_rev_crv.objid);

  if (! gmprops.phy_closed)
  {
    for (i=START, j=0; i<=STOP; i++, j=count-1)
    {
      delta = EXTENSION_FACTOR * distance;
      if (i == START)
       {
        chkopt = EMS_opt_offsetS_extend_start | EMS_opt_offsetS_shorten_start;
       }
      else
       {
        chkopt = EMS_opt_offsetS_extend_stop | EMS_opt_offsetS_shorten_stop;
       };

      if ((!endcap[i] || !(options & chkopt)) &&
          (!endcap[i] || !butt_end[i]) )
        continue;

      if (endcap[i] && butt_end[i])

       {
       /* Construct and add the butt element to the off_rev_crv 
          and continue   1/10/92  M.Sudhakar  */

        stat_OM = om$send (msg = message GRcurve.GRendpts (&msg_loc,
                  mattyp, mat, endpts[START], endpts[STOP]), 
                  targetid = off_rev_crv.objid);
        EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);

	k = (i==START ? STOP : START);
      
        OM_BLOCK_MOVE (old_endpts[i], poles[i], sizeof (IGRpoint));
        OM_BLOCK_MOVE (endpts[i], poles[k], sizeof (IGRpoint));
        save_ptr = construct_list->class_attr;
        construct_list->class_attr = NULL;
        construct_list->geometry = (IGRchar *) &line_crv;
        stat_OM = om$construct (classid = OPP_GR3dlineseg_class_id,
                   msg = message GRvg.GRconstruct (construct_list), 
                   p_objid = &tmpobj);
        construct_list->class_attr = save_ptr;
        EMerr_hndlr (EMSerror (stat_OM & *construct_list->msg), *msg,
         EMS_E_Fail, ret_end);

        cvinfo.located_obj.objid = tmpobj;
        stat_OM = om$send (msg = message GRcompcurve.EMmakecomp (&msg_loc,
                 &md_env, 1, &cvinfo, &inx), targetid = off_rev_crv.objid);

        EMerr_hndlr (EMSerror (msg_loc & stat_OM) || inx == 0, *msg, EMS_E_Fail,
         ret_end);

      /* Increment the count as another segment has been added to the 
         composite curve  and go on to the next index of for-loop */
	count++;
        continue;
       }; /* end of if(endcap[i] && butt_end[i] */

      if(ends_lined)
      {
        OM_BLOCK_MOVE (old_endpts[i], poles[START], sizeof (IGRpoint));
        OM_BLOCK_MOVE (old_endpts[i], poles[STOP], sizeof (IGRpoint));

        if(i==START)
        {
           stat_OM = om$send (msg = message GRcurve.GRendpts (&msg_loc, mattyp,
			            mat, endpts[START], endpts[STOP]), 
				    targetid = off_rev_crv.objid);
           EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, 
	   ret_end);
	   t = BSdistptpt(&msg_loc, old_endpts[START], endpts[STOP]);
	}

	BSmkvec(&msg_loc, vec, old_endpts[i], 
		  old_endpts[i==START?STOP:START]);
	BSnorvec(&msg_loc, vec);

        for(k=X; k<=Z; k++)
        {
	  poles[START][k] += 0.95 * t * vec[k];
	  poles[STOP][k]  -= 0.95 * t * vec[k];

	}
      }
      else
      {
        OM_BLOCK_MOVE (old_endpts_axis[i], poles[START], sizeof (IGRpoint));
        OM_BLOCK_MOVE (old_endpts[i], poles[STOP], sizeof (IGRpoint));
	uparm.u = i;
  	uparm.polygon_inx = 0;
  	uparm.leaf_id.objid = NULL_OBJID;
        if (is_composite)  
          stat_OM = om$send (msg = message GRcurve.EMcvtanorm (&msg_loc,
                 mattyp, mat, NULL, 1, &uparm, NULL, NULL, 1.0, NULL,
                 TRUE, NULL, (IGRdouble *) tanpts, NULL),
                 p_chanselect = &chan_to_comps, senderid = off_rev_crv.objid,
                 from = j, to = j);
        else
          stat_OM = om$send (msg = message GRcurve.EMcvtanorm (&msg_loc,
                 mattyp, mat, NULL, 1, &uparm, NULL, NULL, 1.0, NULL,
                 TRUE, NULL, (IGRdouble *) tanpts, NULL),
                 targetid = off_rev_crv.objid, targetos = rev_crv.osnum);
        EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);

        BSmkvec (&msg_loc, vec, tanpts[FIRST], tanpts[SECOND]);
        BSnorvec (&msg_loc, vec);
        dotp =  fabs(BSdotp (&msg_loc, axis_vec, vec));
#ifdef DEBUG
printf("dotp = %lf, cos(84) = %lf\n", dotp, cos(84*3.141592/180.0));
printf("distance, dotp, distance/dotp = %lf, %lf, %lf\n", distance, dotp, 
                                                  (distance/dotp));
#endif
        EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_InvalidCase, ret_end);
        if (dotp <= cos(84*3.141592/180.0))
          {
          /* The line is close to vertical, hence do not extend. Should be
             butt-end case.  */ 
           if(is_member[i])
                continue;
           else
             {
#ifdef DEBUG
printf("ERROR ---Line too close to vertical but butt-end not set.\n");
#endif
               EMerr_hndlr (EMSerror (0), *msg, EMS_E_Fail, ret_end);
             }
          }
        else
           /* Extend the line-segment such that it can have an intersection
              even for end-segments/tangents-at-endpts leaning 'inwards' */
           /* Skar - Begin */
           /* Get the offset distance at the end-segment */
           tcount = count + (endadd[START] ? 1 : 0) + (endadd[STOP] ? 1 : 0);
           if(i == START)
             {
              index = 0;
              if(endadd[START]) index++;
             }
           else
             {
              index = tcount-1;
              if(endadd[STOP]) index--;
             }
           endseg_offdistance = new_offdists[index];
#ifdef DEBUG
printf("endseg_offdistance [%d] = %lf\n", endseg_offdistance);
#endif
           /* Skar - End */ 
           
           for (k=X; k<=Z; k++)
             if ((poles[STOP][k] - poles[START][k]) != 0.0)
               poles[STOP][k] += 1.2 * (endseg_offdistance/dotp)* 
                             ((poles[STOP][k] - poles[START][k])/
                              fabs(poles[STOP][k] - poles[START][k]));
      }
#ifdef DEBUG
printf("LINE POINT 1 : %lg %lg %lg\n", poles[0][0],poles[0][1], poles[0][2]);
printf("LINE POINT 2 : %lg %lg %lg\n", poles[1][0],poles[1][1], poles[1][2]);
#endif
/* Put the code for extending the curve and doing cvcvint inside a 'for' loop
   in order to try to get the required intersection within 5 iterations - Ashok
*/
      for(num_inters=0, num_iter=0; (!num_inters) && num_iter<5; 
			                           num_iter++, delta+=delta/2)
      {
        stat_OM = om$send (msg = message GRcurve.GRendpts (&msg_loc, mattyp, mat,
                  endpts[START], endpts[STOP]), targetid = off_rev_crv.objid);
        EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);
#ifdef DEBUG
printf("delta=%lg\n", delta);
printf("END POINT 1 : %lg %lg %lg\n", endpts[0][0],endpts[0][1], endpts[0][2]);
printf("END POINT 2 : %lg %lg %lg\n", endpts[1][0],endpts[1][1], endpts[1][2]);
#endif
        if (is_composite)
          stat_OM = om$send (msg = message GRcurve.GRdisextend (&msg_loc,
                   &md_env, endpts[i], &delta, pt), 
                   senderid = off_rev_crv.objid, targetos = off_rev_crv.osnum,
                   p_chanselect = &chan_to_comps, from = j, to = j);
        else
          stat_OM = om$send (msg = message GRcurve.GRdisextend (&msg_loc,
                   &md_env, endpts[i], &delta, pt),
                   targetid = off_rev_crv.objid, targetos = off_rev_crv.osnum);
        EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);


        num_overlaps = dum1 = dum2 = 0;
        stat_OM = om$send (msg = message GRcurve.EMcrvcrvint (&msg_loc, NULL,
                  &md_env.md_env, &line_crv, NULL, NULL, TRUE,(IGRlong *)&dum1,
        (IGRlong *)&num_inters, NULL, &my_inters, NULL, (IGRdouble **) &int_pts,
        (IGRlong *)&dum2, (IGRlong *)&num_overlaps, NULL, NULL, NULL),
                   targetid = off_rev_crv.objid);
#ifdef DEBUG
printf("num_inters = %d\n", num_inters);
#endif
        EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);
        EMerr_hndlr (num_inters > 1, *msg, EMS_E_InvalidCase, ret_end);

      }

      EMerr_hndlr (num_inters != 1, *msg, EMS_E_InvalidCase, ret_end);
      endcrv = NULL_OBJID;
      om$get_objid_at_index (objid = off_rev_crv.objid, 
       p_chanselect = &chan_to_comps, index = j,
       objidaddr = &endcrv, osnumaddr = &dumos);

      stat_OM = om$send (msg = message GRcurve.GRendpts (&msg_loc, mattyp, mat,
                 endpts[START], endpts[STOP]), targetid = off_rev_crv.objid);
      EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);

      uparm.u = i == START ? 0.0 : 1.0;
      uparm.polygon_inx = 0;
      uparm.leaf_id.objid = endcrv;
      stat_OM = om$send (msg = message GRcurve.GR2ptpartdel (&msg_loc, &md_env,
                 endpts[i], int_pts[FIRST], &uparm, &my_inters[FIRST],
                 &obj1, &obj2, &dum_s), targetid = off_rev_crv.objid);
      EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);

      if (IF_NULL_OBJID (obj1))
        off_rev_crv.objid = obj2;
      else
        off_rev_crv.objid = obj1;

   /* Redetermine the classification of the offset-rev-crv as GR2ptpartdel
      may result in a non-composite object - S'kar 15th Oct 92.*/

      om$get_classid (objid = off_rev_crv.objid, osnum = rev_crv.osnum,
        p_classid = &objclass);
      if (om$is_ancestry_valid (subclassid = objclass,
       superclassid = OPP_EMScomposite_class_id) == OM_S_SUCCESS)
          is_composite = TRUE;
      else
          is_composite = FALSE;


    } /* for(i==START .... ) */

/* Post-Process the offset curve. If the curve is an open curve with its
   end-points lying on a perpendicular to the axis of revolution, then close
   it off before revolving it. - Ashok - Oct 7, 92
   -Block Start-
*/
    if(!is_closed && ends_lined)
    {
       /* Construct and add the line segment to the off_rev_crv 
          to close off the composite curve  7/10/92  Ashok  */

        stat_OM = om$send (msg = message GRcurve.GRendpts (&msg_loc,
                  mattyp, mat, endpts[START], endpts[STOP]), 
                  targetid = off_rev_crv.objid);
        EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);
      
        OM_BLOCK_MOVE (endpts[STOP], poles[START], sizeof (IGRpoint));
        OM_BLOCK_MOVE (endpts[START], poles[STOP], sizeof (IGRpoint));
        save_ptr = construct_list->class_attr;
        construct_list->class_attr = NULL;
        construct_list->geometry = (IGRchar *) &line_crv;
        stat_OM = om$construct (classid = OPP_GR3dlineseg_class_id,
                   msg = message GRvg.GRconstruct (construct_list), 
                   p_objid = &tmpobj);
        construct_list->class_attr = save_ptr;
        EMerr_hndlr (EMSerror (stat_OM & *construct_list->msg), *msg,
        EMS_E_Fail, ret_end);

        cvinfo.located_obj.objid = tmpobj;
        stat_OM = om$send (msg = message GRcompcurve.EMmakecomp (&msg_loc,
                 &md_env, 1, &cvinfo, &inx), targetid = off_rev_crv.objid);

        EMerr_hndlr (EMSerror (msg_loc & stat_OM) || inx == 0, *msg, EMS_E_Fail,
         ret_end);

    } /* if(!closed && ....) */
/* -Block End- */

  } /* if( ! gmprops.phy_closed ) */
  else  /* ie curve is phy_closed */
  {
/* DO NOTHING  -  S'kar 9th oct.'92 
    delta = 10 * EMS_ZEROANGLE_DEG;

    if (options & EMS_opt_offsetS_extend_start ||
        options & EMS_opt_offsetS_shorten_start)
      {
      *msg = EMS_I_NotSupported;
      }

    if (options & EMS_opt_offsetS_extend_stop ||
        options & EMS_opt_offsetS_shorten_stop)
      {
      *msg = EMS_E_NotSupported;
      }
*/
  /* Determine the offset distances for the end-planes, if the
     sweep-angle < 360 and this surface belongs to an 'sfsolid'.
  */
     if((rev_sweep < 360.0) && 
           (options & EMS_opt_offsetS_of_sfsolid))
     {
        EMmake_chanselect (GRconnector_to_owners, &chan_to_owners);

       /* Get the id of the 'Sfsolid' of this surface */
        stat_OM = om$get_objid_at_index(objid = my_id,
                                 osnum = rev_crv.osnum,
                                 index = 0,
                                 objidaddr = &solid_GRid.objid,
                                 osnumaddr = &solid_GRid.osnum,
                                 p_chanselect = &chan_to_owners);
#ifdef DEBUG
 printf("The SfSolid id = %d\n", solid_GRid.objid);
#endif
       EMerr_hndlr(!(1&stat_OM), *msg, EMS_E_OMerror, ret_end);

       /* Find the offset distances corresponding to the end-caps */
       for (i=START; i<=STOP; i++)
       {
           stat_OM = om$get_objid_at_index(objid = solid_GRid.objid,
                                 osnum = solid_GRid.osnum,
                                 index = (i == START ? 2 : 1),
                                 objidaddr = &tmpobj,
                                 osnumaddr = &dumos,
                                 p_chanselect = &chan_to_comps);
           EMerr_hndlr(!(1&stat_OM), *msg, EMS_E_OMerror, ret_end);
#ifdef DEBUG
 printf("The end-plane id = %d\n", tmpobj);
#endif
           /* Determine the corresponding offset distance */
           EFget_offsetdistance_for_surface(tmpobj, distance,
                                            num_spec_thick,
                                            val_spec_thick,
                                            spec_thick_sf_sets,
                                            num_nooffsetsfs,
                                            nooffsetsfs,
                                            &endoff[i]);
#ifdef DEBUG
   printf("Offset distance of end-cap [%d] = %lf\n", i, endoff[i]);
#endif

        } /* end of for(i=START.....) */
     } /* end of if((rev_sweep < 360.0).....) */

  } /* end of else of if(!gmprops.phy_closed) */


  /*
   * Construct and initialize the offset surface of revolution.
   */

  tmpobj = NULL_OBJID;
  cvinfo.located_obj = off_rev_crv;
  OM_BLOCK_MOVE (&md_env, &cvinfo.module_info, sizeof (struct GRmd_env));

  sweep_info.type = EMRevolve;
  sweep_info.data.rev_data.axis = (IGRdouble *) axis_pts;
  sweep_info.data.rev_data.start_angle = rev_start;
  sweep_info.data.rev_data.sweep_angle = rev_sweep;
  sweep_info.data.rev_data.full_rev = rev_sweep == 360.0;

  save_ptr = construct_list->class_attr;
  construct_list->class_attr = NULL;
  stat_OM = om$construct (classid = OPP_EMSrevcompsf_class_id,
             msg = message EMSswcompsf.EMsweep_composite_curve
             (construct_list, &cvinfo, &sweep_info, &tmpobj),
             p_objid = constructed_object);
  construct_list->class_attr = save_ptr;
  EMerr_hndlr (EMSerror (1 & stat_OM), *msg, EMS_E_Fail, ret_end);

  stat_OM = EMconvert_into_plane(&msg_loc, NULL, NULL, NULL, NULL, NULL,
                        NULL, NULL, construct_list->env_info, 
                        *constructed_object, rev_crv.osnum);



/*   Portion added to handle generation of void solids for closed-
     curve based(rev_sweep<360) thin-walled solids  - Sudhakar 9/22/92    */


  if (trim_ends[START] || trim_ends[STOP])
                                               
   {
    /* The closed-curve is not being swept by 360 degrees. Hence
       to make it a closed solid, the offset surface being generated 
       should be shortened at the ends by the thickness of the thin-
       walled solid. This shortening should be normal to the end-
       planes. This is achieved by generating the offset planes at
       the beginning and end of sweep, with the offset being inwards
       from the planes */

IGRlong          size; 
IGRmatrix        tmat1;
IGRdouble        rev_angle, rev_start_rad, rev_angle_rad;
IGRpoint         midpt1, midpt2;
IGRvector        start_pl_nor, stop_pl_nor;
IGRpoint         solid_side_pt;
GRobjid          start_pl_id, stop_pl_id;
GRobjid          temp_id[3], cutting_plane_ids[2];
struct  GRid     boolean_grid;
IGRint           num_cut_planes;
IGRushort        optionsEMboolean;
IGRlong          num_points, num_pts;


      stat_OM = om$send (msg = message GRvg.GRgetsize(&msg_loc, 
                         mattyp, mat, &size),
                 targetid = rev_crv.objid);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_OMerror, ret_end);
     
      cgeom = (struct IGRbsp_curve *) malloc(size);

      stat_OM = om$send (msg = message GRvg.GRgetgeom(&msg_loc, 
                         mattyp, mat, (IGRchar *)cgeom),
                 targetid = rev_crv.objid);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_OMerror, ret_end);
        
      num_points = cgeom->num_poles;

      cpoles = (IGRdouble *) malloc (3 * num_points * sizeof(IGRdouble));
      cpoles1 = (IGRdouble *) malloc (3 * num_points * sizeof(IGRdouble));


      for(i=0; i< 3*num_points; i++)
       {
          cpoles[i] = cgeom->poles[i];
       };

      /* Un-weight the poles, if necessary  */

      if(cgeom->rational)
       {
        for(i=0; i<num_points; i++)
          for(j=0; j<3; j++)
           cpoles[i*3+j] /= cgeom->weights[i];
       };


    /* Get the transformed versions of the poles of the curve:
       midpt1 - at the (rev_start) angle
       midpt2 - at the (rev_start+rev_sweep) angle */ 

   if(trim_ends[START])
     {

    /* Set up the rotation matrix for transforming the points of the
       curve_plane to the starting angle  'rev_start'  */

       rev_start_rad = (rev_start * 3.1415927)/180.0;

       MAgrotmx(&msg_loc, axis_vec, axis_pts[FIRST], &rev_start_rad, &tmat1[0]);

       num_pts = num_points;
       MAptsxform(&msg_loc, &num_pts, &tmat1[0], cpoles, cpoles1);

       EMerr_hndlr (msg_loc != MSSUCC, *msg, EMS_E_InvalidCase, ret_end);

    /* Processing of Start Plane */
         for (i=0; i<3; i++)
           midpt1[i] = cpoles1[i];
         BSmkvec (&msg_loc, vec, axis_pts[FIRST], midpt1);
         BScrossp (&msg_loc, axis_vec, vec, start_pl_nor);
         BSnorvec (&msg_loc, start_pl_nor); /* normal inward into the surface */
         EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_InvalidCase, ret_end);


     /* Translate all points along normal by 'endoff[START]' to lie
        on trimming plane  */

         for(i=0; i<num_points; i++)
          for(j=0; j<3; j++)
             cpoles1[i*3+j]=cpoles1[i*3+j]+endoff[START]*start_pl_nor[j];


     /* Reverse the start_plane normal for boolean operation  */
         for(i=0; i<3; i++)
             start_pl_nor[i] = -start_pl_nor[i];
         for(i=0; i<3; i++)
             solid_side_pt[i]=midpt1[i]+endoff[START]*start_pl_nor[i];

        if(cgeom->rational)
         {
          for (i=0; i<num_points; i++)
           for (j=0; j<3; j++)
            cgeom->poles[i*3+j] = cpoles1[i*3+j]* cgeom->weights[i];
         }
        else
         {
          for (i=0; i<3*num_points; i++)
            cgeom->poles[i] = cpoles1[i];
         };

        /* create the object that will be the Plane object */

        stat_OM = om$construct(classid = OPP_EMSplane_class_id,
                              p_objid = &start_pl_id,
                              osnum = md_env.md_id.osnum);
        EMerr_hndlr (!(1 & stat_OM), *msg, EMS_E_Fail, ret_end);

        construct_list->geometry = NULL;
        save_ptr = construct_list->class_attr;
        construct_list->class_attr = NULL;

        stat_OM = om$send(mode = OM_e_wrt_object,
                     msg = message EMSplane.EMplane_of_curve
             (&msg_loc, construct_list, NULL, cgeom, NULL, TRUE, TRUE,
               solid_side_pt, NULL),
                     senderid = start_pl_id,
                     targetid = start_pl_id);
        construct_list->class_attr = save_ptr; 


        if (! (1 & stat_OM))
         {
            stat_OM = om$send(mode = OM_e_wrt_object,
                             msg = message GRgraphics.GRdelete(&msg_loc,
                                             &md_env),
                             senderid = start_pl_id,
                             targetid = start_pl_id);
            EMerr_hndlr (EMSerror (stat_OM & msg_loc),
                           *msg, EMS_E_OMerror, ret_end);
            return(OM_E_ABORT);
          };

        stat_OM = om$send(mode = OM_e_wrt_object,
                     msg = message EMSsurface.EMalgnnrml
             (&msg_loc, EMS_SET_POS_ORIENT, NULL, solid_side_pt, &md_env),
                     senderid = start_pl_id,
                     targetid = start_pl_id);
        EMerr_hndlr (!(1 & stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);



     }; /* end of if-extend-start */

   if(trim_ends[STOP])
    {
      /* Processing for Stop Plane  */

       rev_angle = rev_start + rev_sweep;
       rev_angle_rad = (rev_angle * 3.1415927) / 180.0;

       MAgrotmx(&msg_loc, axis_vec, axis_pts[FIRST], &rev_angle_rad, &tmat1[0]);

       num_pts = num_points;
       MAptsxform(&msg_loc, &num_pts, &tmat1[0], cpoles, cpoles1);

       EMerr_hndlr (msg_loc != MSSUCC, *msg, EMS_E_InvalidCase, ret_end);

         for (i=0; i<3; i++)
           midpt2[i] = cpoles1[i];

         BSmkvec (&msg_loc, vec, axis_pts[FIRST], midpt2);
         BScrossp (&msg_loc, axis_vec, vec, stop_pl_nor);
         BSnorvec (&msg_loc, stop_pl_nor);
         EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_InvalidCase, ret_end);

     /* Reverse the stop_plane to point into the solid  */
         for(i=0; i<3; i++)
             stop_pl_nor[i] = -stop_pl_nor[i];


     /* Translate all points along normal by 'endoff[STOP]' to lie
        on trimming plane  */

         for(i=0; i<num_points; i++)
          for(j=0; j<3; j++)
             cpoles1[i*3+j]=cpoles1[i*3+j]+endoff[STOP]*stop_pl_nor[j];

     /* Reverse the stop_plane normal for boolean operation  */
         for(i=0; i<3; i++)
             stop_pl_nor[i] = -stop_pl_nor[i];
         for(i=0; i<3; i++)
             solid_side_pt[i]=midpt2[i]+endoff[STOP]*stop_pl_nor[i]; 

        if(cgeom->rational)
         {
          for (i=0; i<num_points; i++)
           for (j=0; j<3; j++)
            cgeom->poles[i*3+j] = cpoles1[i*3+j]* cgeom->weights[i];
         }
        else
         {
          for (i=0; i<3*num_points; i++)
            cgeom->poles[i] = cpoles1[i];
         };

        /* create the object that will be the Plane object */

        stat_OM = om$construct(classid = OPP_EMSplane_class_id,
                              p_objid = &stop_pl_id,
                              osnum = md_env.md_id.osnum);
        EMerr_hndlr (!(1 & stat_OM), *msg, EMS_E_Fail, ret_end);

        construct_list->geometry = NULL;
        save_ptr = construct_list->class_attr;
        construct_list->class_attr = NULL;

        stat_OM = om$send(mode = OM_e_wrt_object,
                     msg = message EMSplane.EMplane_of_curve
             (&msg_loc, construct_list, NULL, cgeom, NULL, TRUE, TRUE,
               solid_side_pt, NULL),
                     senderid = stop_pl_id,
                     targetid = stop_pl_id);
        construct_list->class_attr = save_ptr; 


        if (! (1 & stat_OM))
         {
            stat_OM = om$send(mode = OM_e_wrt_object,
                             msg = message GRgraphics.GRdelete(&msg_loc,
                                                &md_env),
                             senderid = stop_pl_id,
                             targetid = stop_pl_id);
            EMerr_hndlr (EMSerror (stat_OM & msg_loc),
                           *msg, EMS_E_OMerror, ret_end);
            return(OM_E_ABORT);
          };

        stat_OM = om$send(mode = OM_e_wrt_object,
                     msg = message EMSsurface.EMalgnnrml
             (&msg_loc, EMS_SET_POS_ORIENT, NULL, solid_side_pt, &md_env),
                     senderid = stop_pl_id,
                     targetid = stop_pl_id);
        EMerr_hndlr (!(1 & stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);



     };  /* end of if-shorten-stop */


     /* create the object that will be the difference (boolean) solid */

     num_cut_planes = 0;
     if(trim_ends[START])
       {
        num_cut_planes++;
        cutting_plane_ids[num_cut_planes-1]= start_pl_id;
       }; 
     if(trim_ends[STOP])
       {
        num_cut_planes++;
        cutting_plane_ids[num_cut_planes-1]= stop_pl_id;
       };

    for ( i=0; i<=num_cut_planes; i++)
     {

       stat_OM = om$construct(classid = OPP_EMSsfboolean_class_id,
                           p_objid = &temp_id[i],
                           osnum = md_env.md_id.osnum);
       EMerr_hndlr (!(1 & stat_OM), *msg, EMS_E_Fail, ret_end);
     };

    optionsEMboolean = EMSsfbool_opt_HandleStop;
    optionsEMboolean |= EMSsfbool_opt_SingleTopology;
    temp_id[0]= *constructed_object;

    for (i=0; i<num_cut_planes; i++)
       {

       construct_list->geometry=NULL; 
       save_ptr = construct_list->class_attr;
       construct_list->class_attr = NULL;
       stat_OM = om$send(msg = message EMSsfboolean.EMboolean(&msg_loc,
                          mattyp, mat,
                          temp_id[i], 
                          1, &cutting_plane_ids[i],
                          construct_list, EMSbool_difference,
                          optionsEMboolean, NULL, NULL,
                          NULL, NULL, NULL),
                             senderid = my_id,
                             targetid = temp_id[i+1],
                             targetos = md_env.md_id.osnum);
       
        construct_list->class_attr = save_ptr; 

        };
       

     if (1 & stat_OM & msg_loc)
         {
    stat_OM = om$send(msg = message EMSdpr.EMmake_primitive1(&msg_loc,
                                &md_env, &boolean_grid),
                                senderid = my_id,
                                 targetid = temp_id[num_cut_planes],
                                 targetos = md_env.md_id.osnum);


          EMerr_hndlr (!(1 & stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
         };

  /* Return the EMSrevol surface without the closing planes generated by
     the boolean difference operations  */
    
     count = 0;
     om$get_channel_count (objid = boolean_grid.objid, osnum = rev_crv.osnum,
                          p_chanselect = &chan_to_comps, count = &count);
  

    if(num_cut_planes > 0)
      {
       for (i=count-1; i>(count-1)-num_cut_planes; i--)
        {
         /* Remove the closing planes at the last 'num_cut_planes' indices */
         tmpobj = NULL_OBJID;
         om$get_objid_at_index (objid = boolean_grid.objid,
           osnum = md_env.md_id.osnum, p_chanselect = &chan_to_comps,
           index = i, objidaddr = &tmpobj, osnumaddr = &dumos);

         om$send (msg = message GRconnector.GRdisconn (&msg_loc, &boolean_grid),
           targetid = tmpobj, targetos = rev_crv.osnum);

         om$send (msg = message GRgraphics.GRdelete (&msg_loc, &md_env),
           targetid = tmpobj, targetos = rev_crv.osnum);

        };

       count = count-num_cut_planes;

      };  /* end of if(num_cut-planes) .. */


    if(count == 1)
     {
      tmpobj = NULL_OBJID;
      om$get_objid_at_index (objid = boolean_grid.objid,
       osnum = md_env.md_id.osnum, p_chanselect = &chan_to_comps,
       index = FIRST, objidaddr = &tmpobj, osnumaddr = &dumos);

      om$send (msg = message GRconnector.GRdisconn (&msg_loc, &boolean_grid),
       targetid = tmpobj, targetos = rev_crv.osnum);
  
      om$send (msg = message GRgraphics.GRdelete (&msg_loc, &md_env),
       targetid = boolean_grid.objid, targetos = rev_crv.osnum);

      *constructed_object = tmpobj;
     }
    else
     {
      /* The surface is a composite surface */
  
      *constructed_object = boolean_grid.objid;

     };


 }; /* end of if-less-than-360 i.e. closed curve shell solid */

ret_end:
  if (paramids)
    om$dealloc (ptr = paramids);
  if (my_inters)
    om$dealloc (ptr = my_inters);
  if (int_pts)
    om$dealloc (ptr = int_pts);
  if (owner_comps)
    om$dealloc (ptr = owner_comps);
  if (off_rev_crv.objid != NULL_OBJID)
    om$send (msg = message GRgraphics.GRdelete (&msg_loc, &md_env),
     targetid = off_rev_crv.objid);
  if (trim_ends[START] || trim_ends[STOP])
    {
     if(cgeom) free (cgeom);
     if(cpoles) free (cpoles);
     if(cpoles1) free (cpoles1);
    };
  if (offdists)
    om$dealloc (ptr = offdists);
  if (new_offdists)
    om$dealloc (ptr = new_offdists);

  EMWRAPUP (*msg, stat_OM, "EMSrevcompsf.EMoffset"); 
  if((1 & stat_OM) || (options & EMS_opt_offsetS_of_sfsolid) ||
                      (options & EMS_opt_offsetS_special_algo_only))
       return (stat_OM);
  else
      /* Invoke the 'general offset' algorithm. */
       return (om$send (msg = message EMScompsurf.EMoffset (msg, options,
           mattyp, mat, construct_list, is_natural_normal, distance,
           num_spec_thick, val_spec_thick, spec_thick_sf_sets,
           num_nooffsetsfs, nooffsetsfs, status_str, constructed_object,
           errkey_list),
           mode = OM_e_wrt_message, targetid = my_id));
}

end implementation EMSrevcompsf;
