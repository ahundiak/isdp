/* #################   APOGEE  COMPILED   ######################### */
/*----

     CHANGE HISTORY:
	RC	12/04/86  : Creation date	
	RC	03/04/87  : Modified according to new design
	SS	08/24/87  : Changed the connect_edges flag to an options
			    mask. See EMSboundary-spec file.
	RC      09/30/87  : Modified such that EMED_SUBORDINATE bit is
			    set properly
        RC      10/27/87  : Modified for version 1.1
	SM	11/11/87  : Modified to support the option 
			    'EMS_COPY_INTO_DUMMYEDGE'. This options enables
			    creation of dummy edge and avoid duplication
			    of geometry.
        SS      07/27/88  : Added support for copy of model-space
                            counterparts. Also changed argument from
			    GRmdenv_info to GRmd_env.
	SS	05/04/89  : Added support for the new option 
			    EMS_COPY_IGNORECOMMON.
	SM	05-Jul-89 : Support EMS_COPY_PRIMEDGE independent of 
			    EMS_COPY_XYZ.
			    Also if the method was being executed for a prim
			    edge and the PRIMEDGE option was on, it used
			    to get the geometry and post it into the copy
			    instead of construct_and_copy. Optimised it as
			    such by ignoring the PRIMEDGE option if the method
			    is being executed for a primitive edge.
        WBC     04/04/91  : Modified to support changes to model-space
                            counterparts.
        NP	09/29/92  : When a linear edge was being constructed, NULL
			    was being passed in for "curve_type". Not any more.
----*/

class implementation EMSedge;

#include "EMS.h"
#include "ma.h"
#include "OMmacros.h"
#include "emsdef.h"
#include "emserr.h"
#include "emsmacros.h"
#include "EMSmsgdef.h"
#include "EMcp.h"
#include "EMSopt.h"
#include "EMSobjmgrdef.h"
#include "emsedgedef.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

extern GRclassid OPP_EMSlinedge_class_id, OPP_EMSbsedge_class_id, 
		 OPP_EMSpartedge_class_id;
		
extern GRclassid OPP_EMSshobjmgr_class_id;

from EMSptedge import EMpteinit;
from EMSlinedge import EMleinit;
from EMSbsedge import EMbsinit;
from EMSdumedge import EMdumedgeinit;

method EMintcopy(
   IGRlong 			*EMmsg; 
   struct GRmd_env 		*mdenvs;
   GRspacenum  			obj_osnum;
   GRspacenum  			new_osnum;
   IGRushort 		options; 
   GRobjid 			*newobjid;
   struct EMcp_info 		*copy_info)
{
  IGRboolean 		reversed, ed_copy_exists, mscexists;
  IGRushort 	props, t_props;
  IGRlong  		OM_stat, mthd_stat;
  IGRuint 	count;
  IGRint 		i, j;
  IGRdouble 		*point;
  GRobjid  		edcp_id, srfid;	
  struct GRid 		srfgrid;
  OM_S_CHANSELECT 	common_edge_chan, assoc_chan; 
  OM_S_OBJECT_LINKAGE 	ed_linkage;
  struct IGRpolyline 	poly;
  struct IGRbsp_curve 	xyzcrv;
  struct EMSpartolbasis partolb;
  extern void		EM3dto2d(), EMcpsearch();
  OMuword		clsid;
  IGRuchar		curve_type;

  *EMmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;

  xyzcrv.poles = NULL;
  xyzcrv.weights = NULL;
  xyzcrv.knots = NULL;

  /*
   * find out if I have been already copied or not.
   * If so, return my counter part's objid and I am 
   * all done
   */

  EMcpsearch (&mthd_stat, my_id, newobjid, copy_info, 0,
  	   &ed_copy_exists);
  EMerr_hndlr (!(1&mthd_stat), *EMmsg, EMS_E_Fail, wrapup);

  if (ed_copy_exists) goto wrapup;

  OM_stat = om$get_classid(objid = my_id, p_classid = &clsid);
  EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

  /* If the edge is already a primitive edge, ignore the PRIMEDGE option
  */
  if( (clsid != OPP_EMSpartedge_class_id) && 
      ((OM_stat = om$is_ancestry_valid(subclassid = clsid, 
		superclassid = OPP_EMSpartedge_class_id)) != OM_S_SUCCESS))
    options &= ~EMS_COPY_PRIMEDGE;


  if ( (options & EMS_COPY_PRIMEDGE) || (options & EMS_COPY_XYZ))
  {
    /*
     * The copy of this edge is not intended to be an exact duplicate but
     * different in either the geometry or the type of edge itself.
     */

     partolb.is_valid = FALSE;
     partolb.in_world = TRUE;
     partolb.mattyp = &mdenvs->md_env.matrix_type;
     partolb.mat = mdenvs->md_env.matrix;
     OM_stat = om$send (msg = message EMSboundary.EMgetsurface_info
                     (&mthd_stat, &srfid, &partolb), targetid = my_id);
     EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);
     EMerr_hndlr (EMSerror (mthd_stat), *EMmsg, EMS_E_EdgeError, wrapup);

     OM_stat = om$send (msg = message EMSedge.EMget_props (&mthd_stat,
                     &props), targetid = my_id);
     EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

     reversed = (props & EMED_REVERSED);
    
    if(options & EMS_COPY_XYZ)    
     {
     /*
      * The copy of this edge requested is to be it's
      * model-space counterpart.
      */
     srfgrid.objid = srfid;
     srfgrid.osnum = OM_Gw_current_OS;
     OM_stat = om$send (msg = message EMSedge.EMget_bcxyz_geom
                  (&mthd_stat, &mdenvs->md_env, &srfgrid, NULL, 0, MAXINT,
                   reversed, NULL, &xyzcrv), targetid = my_id);
     EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);
     EMerr_hndlr (EMSerror (mthd_stat), *EMmsg, EMS_E_EdgeError, wrapup);
  
     t_props = EMED_NATURAL | EMED_OPEN;
     props = (ME.EMSedge->ed_props & ~t_props) | 
             (ME.EMSedge->ed_props & EMED_XYZ_CLOSED ? NULL : EMED_OPEN) |
             EMED_XYZ;
     }
     else
     {
     OM_stat = om$send (msg = message EMSedge.EMgetbcgeom
                  (&mthd_stat, 0, MAXINT, reversed, NULL, &xyzcrv, &partolb, 
		   NULL), targetid = my_id);
     EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);
     EMerr_hndlr (EMSerror (mthd_stat), *EMmsg, EMS_E_EdgeError, wrapup);
     }

     if ( (options & EMS_COPY_XYZ) && (props & EMED_DEGENERATE))
     {
	/*
         * The model-space counterpart is to be a point-edge. The primitive
	 * edge being a point edge is possible only in case of xyz geom.
         */

        point = xyzcrv.poles;
        if (xyzcrv.rational)
          {
          point[0] /= xyzcrv.weights[0];
          point[1] /= xyzcrv.weights[0];
          }

        OM_stat = om$construct (msg = message EMSptedge.EMpteinit
                       (&mthd_stat, props, point),
                       classid = OPP_EMSptedge_class_id, osnum = new_osnum, 
                       p_objid = &edcp_id);

        EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);
     } 
     else if (xyzcrv.order == 2)
     {
        /*
         * The primitive edge is to be a linear-edge.
         */
  
        poly.num_points = xyzcrv.num_poles;
        poly.points = xyzcrv.poles;
        if (xyzcrv.rational)
          for (i=0; i<poly.num_points; i++)
            for (j=0; j<3; j++)
              poly.points[i*3+j] /= xyzcrv.weights[i];

        EM3dto2d (poly.points, poly.num_points);

        curve_type = (poly.num_points > 2) ? EMlinestring : EMlinesegment;

        OM_stat = om$construct (msg = message EMSlinedge.EMleinit
                       (&mthd_stat, props, 
                        curve_type, 
                        &poly, &partolb, NULL, 
			NULL_OBJID),
                       classid = OPP_EMSlinedge_class_id, osnum = new_osnum, 
                       p_objid = &edcp_id);
        EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);
     }
     else
     {
        /*
         * The primitive edge is to be a B-spline edge
         */

        OM_stat = om$construct (msg = message EMSbsedge.EMbsinit
                      (&mthd_stat, props, ME.EMSedge->curve_type, 
                        &xyzcrv, &partolb), classid =
                       OPP_EMSbsedge_class_id, osnum = new_osnum, 
                       p_objid = &edcp_id);
        EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);
      }

    } /* if( (options & EMS_COPY_PRIMEDGE) && (options & EMS_COPY_XYZ)) */

    else
    {
       /*
        * An exact copy of this edge is to be made. 
	* If a dummy edge is to be constructed then do so.
        */

       if(options & EMS_COPY_INTO_DUMMYEDGE)
	  OM_stat = om$construct(classid = OPP_EMSdumedge_class_id, 
			p_objid = &edcp_id, msg = message
			EMSdumedge.EMdumedgeinit(&mthd_stat, my_id, FALSE));
       else
         {
         /*
          * During the construct and copy, do not copy the property bit
          * indicating existence of model-space coutnerparts. This is
          * set only after successful creation of a copy MSC, later.
          */

         if (mscexists = ME.EMSedge->ed_props & EMED_MSCEXISTS)
           ME.EMSedge->ed_props &= ~EMED_MSCEXISTS;
/*
         if (msccommon = ME.EMSedge->ed_props & EMED_MSCCOMMON)
           ME.EMSedge->ed_props &= ~EMED_MSCCOMMON;
*/
         OM_stat = om$construct_and_copy(object = me,
	     obj_osnum = obj_osnum, osnum = new_osnum,
	      p_objid = &edcp_id);

         if (mscexists)
           ME.EMSedge->ed_props |= EMED_MSCEXISTS;
/*
         if (msccommon)
           ME.EMSedge->ed_props |= EMED_MSCCOMMON;
*/
         }
	

       EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);
     }
	
     /*
      * put my_id and my counter part's id in the copy_info
      */

     EMcpsearch (&mthd_stat, my_id, &edcp_id, copy_info, 3,
		    &ed_copy_exists);
		    	 
     EMerr_hndlr (!(1&mthd_stat), *EMmsg, EMS_E_Fail, wrapup);

     /*
      * If the copied edge is in model-space then this edge is
      * to be connected to it's copy on the association
      * channel.
      */

     if (options & EMS_COPY_XYZ)
     {
          OM_stat = EMmake_chanselect (GRnotify_notification, &assoc_chan);
	  EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

	  OM_stat = om$send (msg = message Root.connect (assoc_chan, 0,
                     edcp_id, new_osnum, assoc_chan, MAXINT),
                     targetid = my_id);
          EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);
      }

      /*
       * If the connect_edges flag is true, then
       * connect myself with my copy across the
       * common edge channel. It is assumed
       * the caller made sure that the edge
       * under consideration is not connected
       * to another edge across its common edge
       * channel if the connect_edges flag is
       * passed in as TRUE.
       */
	
	OM_stat = EMmake_chanselect (EMSedge_to_common_edge,
                   &common_edge_chan);
	EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

	if (options & EMS_COPY_ONCOMMON)
	{
	    OM_stat = om$send(msg = message Root.connect
		(common_edge_chan, 0, edcp_id, new_osnum,
		 common_edge_chan, 0),
	      targetid = my_id, targetos = obj_osnum);
	    EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);
	}
	else
	{	
	   /*
	    * turn my copy's EMED_SUBORDINATE bit off. It will be set
	    * if only I have a common edge.
	    */

	   if (me->ed_props & EMED_SUBORDINATE)
	   {

	      OM_stat = om$send (msg = message EMSedge.EMset_props (
			&mthd_stat, EMED_SUBORDINATE, EMS_O_OFF),
		      targetid = edcp_id, targetos = new_osnum);
	      EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError, wrapup);

	   }	

	   /*
            * The following is peformed always, unless the option
	    * to IGNORECOMMON is set:
            *
	    * check if the edge is connected to another edge
	    * or not. There may be two cases:
	    *	1.  edge is not connected to another edge through
	    *	    to_common_edge channel. In this case 
	    *          do nothing.
	    *	2.  edge is connected to another edge through 
	    * 	    to_common_edge chhanel. In this case, get the 
	    *	    objid of the common edge. Do a search in 
	    *	    the copy_info struct to find out if the copy
	    *	    of the common edge already exists or not. If 
	    * 	    the common edge's copy already exists, connect
	    * 	    my copy  with common edge's copy.
	    */

    	  /* 
	   * If I have a common edge, find out its objid
	   */

 	  OM_stat = om$get_channel_objects(object = me,
                  p_chanselect = &common_edge_chan,
    	          list = &ed_linkage, size = 1, count = &count);
	  EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);
	
	  if (count == 1 && !(options & EMS_COPY_IGNORECOMMON))
	  {
		   
             GRobjid	cm_edcp_id;
	
	     /* 
	      * I have a common edge. Find out if the copy
	      * of this common edge exists. If so, connect my copy
	      * to my common edge's copy.
	      */
	
             EMcpsearch (&mthd_stat, ed_linkage.S_objid,
	               &cm_edcp_id, copy_info, 0, &ed_copy_exists);
		    	 
	     EMerr_hndlr (!(1&mthd_stat), *EMmsg, EMS_E_Fail, wrapup);

	     if (ed_copy_exists)
	     {
	    	OM_stat = om$send(msg = message Root.connect
			(common_edge_chan, 0, cm_edcp_id, new_osnum,
			 common_edge_chan, 0),
		 	targetid = edcp_id,
		 	targetos = new_osnum);
		 EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
	   
		 if (me->ed_props & EMED_SUBORDINATE)
		 {
		  OM_stat = om$send (msg = message EMSedge.EMset_props (
			&mthd_stat, EMED_SUBORDINATE, EMS_O_ON),
		      targetid = edcp_id, targetos = new_osnum);
		  EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError, wrapup);
		 }
		 else
		 {
		  OM_stat = om$send (msg = message EMSedge.EMset_props (
			&mthd_stat, EMED_SUBORDINATE, EMS_O_ON),
		      targetid = cm_edcp_id, targetos = new_osnum);
		  EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError, wrapup);
		  }
   
	      } /* if (ed_copy_exists) */

            } /* if (count == 1) */
	}

  	*newobjid = edcp_id;

  /*
   * If this edge had a model-space counterpart, it should be copied
   * and attached to the copy of this edge. But if such action is expressly
   * inhibited by an option or this copy is intended for a copy of this
   * edge into model-space or if the new object space is not the current
   * object space or if the module environmemt passed in is NULL, then this
   * process is not performed.
   */

  if (ME.EMSedge->ed_props & EMED_MSCEXISTS &&
      !(options & EMS_COPY_NOMSC) &&
      !(options & EMS_COPY_XYZ) &&
      obj_osnum == new_osnum && obj_osnum == OM_Gw_current_OS &&
      mdenvs)
    {
/*    GRobjid mscobj;  */

    mthd_stat = EMS_S_Success;

    /* create an associative model-space counterpart for the created (new)
     * edge
     */
/* KLUDGE:
 * can't try to create the model-space counterpart yet since the edge is not
 * connected to its loop, which isn't connect to its loopset, etc. which
 * means the parent of the msc cannot be determined;
 * hopefully we'll be able to do this through the NDcopy mechanism,
 * whenever that's implemented
    OM_stat = om$send(msg = message EMSboundary.EMgetxyzobj(&mthd_stat, NULL,
                                                    NULL, NULL, NULL,
                                                    NULL, NULL,
                                                    OM_Gw_current_OS, &mscobj),
                      targetid = *newobjid,
                      targetos = new_osnum);

    if (! (mthd_stat & 1))
      *EMmsg = EMS_E_Fail;
 */
    }

wrapup:
    if (xyzcrv.poles)
      om$dealloc (ptr = xyzcrv.poles);
    if (xyzcrv.weights)
      om$dealloc (ptr = xyzcrv.weights);
    if (xyzcrv.knots)
      om$dealloc (ptr = xyzcrv.knots);

    EMWRAPUP (*EMmsg, OM_stat, "In EMSedge.EMintcopy");
    return(OM_stat);
}

end implementation EMSedge;
