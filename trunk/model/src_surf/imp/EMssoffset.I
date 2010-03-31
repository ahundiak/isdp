/*
DESCRIPTION

This method constructs a surface by offseting itself.

RETURN VALUES

constructed_object  The offset surface.

construct_list->msg MSSUCC - successful
                    MSFAIL - if failure
                    MANOMEMORY - if no memory could be allocated

NOTE

If an error occurs, no object will be returned.

CAVEATS
         - the offset surface function can return multiple surfaces in
	   cases of surface of projection or surface of revolution where
	   offsetting the curve results in a loop being trimmed.  Currently
	   only the first offset surface is kept.


HISTORY

15 Feb 1995 Sanjay Added the call to "BSsftgeomsf" as the BSroutine BScdoffsrf
                   requires the geometric properties of the surface to be set
                   before it gets called. Fix for TR# 119524850. 
25 Nov 1993 ashok Modified to create appropriate class for the offset surface
		  based on its surface-type.
22 Sep 1993 ashok Added option to use loopset range to extract partial surface
		  and offset this partial surface instead.
01 may 1993 ashok Removed option to extend. Seperate method to offset surface
		  by distance is now available.
19 Jan 1993 Sam   Added addtional arguments to EMoffset . ( These were needed
                  to support composite offset .) 
30 Oct 1992 Byron Rewote this method. Calling new math function to offset sf.
	 	  Also added option to extend the offset surface.
10 Aug 1989 PP  Changed arguments so that module environment is passed in
                instead of matrix and matrixtype and fixed problems
                during topology copy and set options to not copy
                MSC.
27 Sep 1988 AIC Changed declarations of ..._class_id external
                variables from OMword to OMuword.
12 Jul 1988 jBk Modified to use kluge of setting num_boundaries
                to 1 while bdrys is NULL in order to prevent
                reparameterization of offset while posting.
                Also, leave geometry field of input construct
                list as I found it.
13 Jun 1988 jBk Added option to copy topology and check
                xyz-closure and degeneracy of the copied edges.
10 Jun 1988 jBk Added soon to be used option argument.
                Renamed EMoffset_surface message to
                EMgenerate_offset_surface.
                Corrected out of date NOTE comment.
19 Nov 1987 rlw Rewritten and renamed.

*/

class implementation EMSsubbs;

#include "EMS.h"
#include "EMSasdef.h"

%safe
#include <math.h>
%endsafe


# include "bsgeom_cvsf.h"
# include "EMSopt.h"    /* EMS_OPT_ALL EMS_opt_offsetS_copy_topology */
# include "EMSprop.h"   /* EMED_XYZ_CLOSED EMED_DEGENERATE */
# include "ems_m_inc.h" /* Includes the world */
# include "gocmacros.h" /* Include generate abstract macro */
# include "EMS_E.h"     /* EMS_E_InsufficientDynamicMemory */
# include "emssfint.h" /*  Include to include struct EMSerror_help */

# include "bscdoffsrf.h"
# include "bsfreecv.h"
# include "bsfreesf.h"
# include "bssftgeomsf.h"

# define MAX_AUTO_OBJECT_LINKAGES 9 /* used to avoid om$malloc */

extern OMuword OPP_EMSplane_class_id;
extern OMuword OPP_EMScylindr_class_id;
extern OMuword OPP_EMScone_class_id;
extern OMuword OPP_EMSpcone_class_id;
extern OMuword OPP_EMSpcylindr_class_id;
extern OMuword OPP_EMSsphere_class_id;
extern OMuword OPP_EMStorus_class_id;
extern OMuword OPP_EMSgenbs_class_id;
extern OMuword OPP_EMAplane_class_id;
extern OMuword OPP_EMAcylindr_class_id;
extern OMuword OPP_EMAcone_class_id;
extern OMuword OPP_EMApcone_class_id;
extern OMuword OPP_EMApcylindr_class_id;
extern OMuword OPP_EMAsphere_class_id;
extern OMuword OPP_EMAtorus_class_id;
extern OMuword OPP_EMAgenbs_class_id;

from EMSboundary import EMtpcopy;

from EMSedge import EMtst_xyz_clsd;
from EMSedge import EMtst_degn;
from EMSedge import EMset_props;
from EMSloopset import EMmakeFRT, EMgetrange;

method EMoffset(
    IGRlong *msg; 
    IGRushort option;
    IGRshort *mattyp; IGRmatrix mat;
    struct GRvg_construct *construct_list;
    IGRboolean is_natural_normal;
    IGRdouble distance;
    IGRint num_spec_thick;
    IGRdouble *val_spec_thick;
    struct GRobjid_set *spec_thick_sf_sets;
    IGRint num_nooffsetsfs; GRobjid *nooffsetsfs;
    IGRchar *status_str;
    OM_S_OBJID *constructed_object;
    struct EMSerror_help *errkey_list
)
{
 IGRshort		type;
 IGRchar        	*generic_pointer;
 OMuword        	classid;
 IGRdouble		range[4];
 IGRlong        	loc_msg, sts;
 struct IGRbsp_surface	*surface = NULL, *offset_surface = NULL;
 OMuint 		boundaryCount = 0;
 OM_S_CHANSELECT 	boundariesChannel;

 struct BSgeom_bsp_surf geom_surf, **offsfs = NULL;
 IGRboolean		closed, partial=FALSE;
 IGRint			i, numsf=0;


/*
 * Initialize
*/
  *msg = MSSUCC;
  sts = OM_S_SUCCESS;
  offset_surface = NULL;
  *constructed_object = NULL_OBJID;

  boundariesChannel.type = OM_e_addr;
  boundariesChannel.u_sel.addr = &me->to_loopset;

/*
 * Get my geometry.
 */
  GRgetabsg(msg, mattyp, mat, &generic_pointer, loc_msg);
  if (! (1 & *msg)) goto wrapup;
  surface = (struct IGRbsp_surface *) generic_pointer;

/*
 * Check if a part of myself needs to be extracted before offsetting
 */

  if (option & EMS_opt_offsetS_by_range)
  {
	/* If topology is to be copied onto the offset then error out.
	   Because this relies on parametrization being maintained. And
	   parametrization will not be maintained if a partial surface
	   is extracted.
	*/
        if(option & EMS_opt_offsetS_copy_topology)
	{
	   *msg = EMS_E_Fail;
	   goto wrapup;
	}
        sts = om$get_channel_count (
            object = me,
            p_chanselect = &boundariesChannel,
            count = &boundaryCount
        );
        if (EMSerror (sts)) goto wrapup;

	if(boundaryCount ISNT 0)
	{
	   sts = om$send(msg = message EMSloopset.EMgetrange(msg, range),
		         senderid = my_id,
                         p_chanselect = &boundariesChannel);
           if (!(1 & sts & *msg)) goto wrapup;

	   if(range[0] < 0.0) range[0] = 0.0;
	   if(range[1] < 0.0) range[1] = 0.0;
	   if(range[2] > 1.0) range[2] = 1.0;
	   if(range[3] > 1.0) range[3] = 1.0;

	   if(range[0] > 0.0 || range[1] > 0.0 || 
              range[2] < 1.0 || range[3] < 1.0) partial = TRUE;
	}
  }
  if(partial)
  {
	IGRdouble	mid_uv[2];

	mid_uv[0] = (range[0] + range[2]) / 2.0;
	mid_uv[1] = (range[1] + range[3]) / 2.0;
	surface = NULL;
	sts = om$send(msg = message EMSsubbs.EMpartsf(msg, construct_list,
			    range, mid_uv, &range[2], 2, NULL, &surface, FALSE,
			    FALSE),
		      targetid = my_id);
        if (!(1 & sts & *msg)) goto wrapup;
  }

/*
 * fill geometric surface structure (BSgeom_bsp_surf)
*/
  getsftype( my_id, OM_Gw_current_OS, &geom_surf.type );
  geom_surf.bspsf = surface;
  geom_surf.bounded = TRUE;
  geom_surf.urange[ 0 ] = geom_surf.vrange[ 0 ] = 0.0;
  geom_surf.urange[ 1 ] = geom_surf.vrange[ 1 ] = 1.0;
  geom_surf.sfgen_cv = NULL;
  geom_surf.geom_prop = FALSE;


/*
 * Determine which class should be created
*/

/*
THIS BLOCK COMMENTED OUT. USE getsfclassid ON THE SURFACE TYPE OF THE OFFSET
SURFACE RETURNED BY MATH TO DETERMINE THE CLASS - Ashok 25/Nov/93.

  sts = om$get_classid(object = me, p_classid = &classid);
  if (! (1 & sts))
  {
    *msg = MSFAIL;
    goto wrapup;
  }

  if ((classid == OPP_EMSplane_class_id)     ||
      (classid == OPP_EMScylindr_class_id)   ||
      (classid == OPP_EMScone_class_id)      ||
      (classid == OPP_EMSpcone_class_id)     ||
      (classid == OPP_EMSpcylindr_class_id)  ||
      (classid == OPP_EMSsphere_class_id)    ||
      (classid == OPP_EMStorus_class_id))
  {

  }

  else if(om$is_ancestry_valid(subclassid = classid,
		superclassid = OPP_EMSproject_class_id) == OM_S_SUCCESS)
	  classid = OPP_EMSproject_class_id;
  else if(om$is_ancestry_valid(subclassid = classid,
		superclassid = OPP_EMSrevol_class_id) == OM_S_SUCCESS)
	  classid = OPP_EMSrevol_class_id;


  else
  {
    if (classid == OPP_EMAplane_class_id) 
        classid = OPP_EMSplane_class_id;
    else if (classid == OPP_EMAcylindr_class_id)
        classid = OPP_EMScylindr_class_id;
    else if (classid == OPP_EMAcone_class_id)
        classid = OPP_EMScone_class_id;
    else if (classid == OPP_EMApcone_class_id)
        classid = OPP_EMSpcone_class_id;
    else if (classid == OPP_EMApcylindr_class_id)
        classid = OPP_EMSpcylindr_class_id;
    else if (classid == OPP_EMAsphere_class_id)
        classid = OPP_EMSsphere_class_id;
    else if (classid == OPP_EMAtorus_class_id)
        classid = OPP_EMStorus_class_id;

    else if (classid == OPP_EMAproject_class_id)
        classid = OPP_EMSproject_class_id;
    else if (classid == OPP_EMArevol_class_id)
        classid = OPP_EMSrevol_class_id;

    else
        classid = OPP_EMSgenbs_class_id;
  }
*/
  /* if offset distance is zero there is no need to call math */

  if(distance == 0.0)
  {
    offset_surface = surface;
    type = geom_surf.type;
    goto cons_obj;
  }

  /*
   * Get the geometric properties of the surface.
   */
  BSsftgeomsf (&geom_surf, TRUE, 0, &loc_msg);
  if (loc_msg != BSSUCC)
  {
    *msg = MSFAIL;
    goto wrapup;
  }

/*
 * Call the math
 */
  closed = surface->u_phy_closed || surface->v_phy_closed;
  BScdoffsrf( &geom_surf, distance, is_natural_normal, closed,
		&numsf, &offsfs, &loc_msg );
  if (loc_msg != BSSUCC)
  {
    *msg = MSFAIL;
    offset_surface = NULL;
    goto wrapup;
  }
  for (i=0; i<numsf; i++)
    offsfs[i]->bspsf->pos_orient = surface->pos_orient;

  offset_surface = offsfs[0]->bspsf;
  type = offsfs[0]->type;

  cons_obj:
    /*
        Fill the instance data and construct.  If I am going to
        copy boundaries, I must fix the post data such that
        num_boundaries is 1 while bdrys is NULL so the posted
        surface will not be reparameterized.
    */

    boundaryCount = 0;
    if (option & EMS_opt_offsetS_copy_topology AND
        EMSokay (sts) AND EMSokay (*msg))
    {
        sts = om$get_channel_count (
            object = me,
            p_chanselect = &boundariesChannel,
            count = &boundaryCount
        );

        if (EMSerror (sts)) goto wrapup;

        if (boundaryCount /* ISNT 0 */)
        {
            if (boundaryCount ISNT 1)
            {
                sts = OM_E_ABORT;
                goto wrapup;
            }
            else /* I am going to copy topology */
            {
                offset_surface->num_boundaries = 1;
                offset_surface->bdrys = NULL;
            }
        }
    }

    /* intentional block */
    {
        IGRchar *old_geometry;

        old_geometry = construct_list->geometry;
        construct_list->geometry = (IGRchar *) offset_surface;
        getsfclassid(type, &classid);
        sts = om$construct (
            classid = classid,
            msg = message GRgraphics.GRconstruct (construct_list),
            p_objid = constructed_object,
            osnum = construct_list->env_info->md_id.osnum
        );

        /* reset construct_list */
        construct_list->geometry = old_geometry;
    }

    /* reset num_boundaries of posted data to zero */
    offset_surface->num_boundaries = 0;

    if (EMSerror (sts))
    {
        if (*constructed_object != NULL_OBJID)
        {
            sts = om$send (
                msg = message Root.delete(1),
                targetid = *constructed_object,
                targetos = construct_list->env_info->md_id.osnum
            );
        }
        *msg = *(construct_list->msg);
        goto wrapup;
    }

    /*
        copy and tweak topology
    */
    if (boundaryCount AND EMSokay (sts) AND EMSokay (*msg))
    {
        OM_S_OBJID newBoundaryId;
        OM_S_CHANSELECT loopsetToSurf, surfToLoopset;
        struct GRid *edges = NULL;
        IGRint edgesNum = 0;
        IGRint ee;
        IGRushort options;
        OMuword targetos;
        struct GRmdenv_info *mdenv_info;
        OM_S_OBJECT_LINKAGE olink;
        struct GRmd_env mdenvs[2];
        IGRuint count;

        targetos = construct_list->env_info->md_id.osnum;
        mdenv_info = &construct_list->env_info->md_env;

        loopsetToSurf.type = OM_e_name;
        loopsetToSurf.u_sel.name = "EMSloopset.to_surface";

        surfToLoopset.type = OM_e_name;
        surfToLoopset.u_sel.name = "EMSsubbs.to_loopset";

        sts = om$get_channel_objects (
            object = me,
            p_chanselect = &boundariesChannel,
            list = &olink,
            size = 1,
            count = &count
        );

        if (count ISNT 1) sts = OM_E_ABORT;

        options = EMS_COPY_NOMSC;

        EMgetmdenv (&mdenvs[0], mattyp, mat, OM_Gw_current_OS);
        OM_BLOCK_MOVE(construct_list->env_info,&mdenvs[1],
                      sizeof(struct GRmd_env));

        options = EMS_COPY_NOMSC;

        if (EMSokay (sts)) sts = om$send (
            msg = message EMSboundary.EMtpcopy (
                msg,               /* msg */
                mdenvs,
                OM_Gw_current_OS,   /* obj_osnum */
                targetos,           /* new_osnum */
                options,            /* options */
                &newBoundaryId      /* newobjid */
            ),
            targetid = olink.S_objid,
            targetos = olink.osnum
         );


        if (EMSokay (sts)) sts = om$send (
            msg = message Root.connect (
                loopsetToSurf,
                0,
                *constructed_object,
                targetos,
                surfToLoopset,
                0
            ),
            targetid = newBoundaryId,
            targetos = targetos
        );

        if (EMSokay (sts))
        {
            IGRint zero = 0;

            sts = om$send (
                msg = message EMSsurface.EMgetedges (
                    msg,           /* EMmsg */
                    EMS_OPT_ALL,    /* option */
                    &edges,         /* edges */
                    &zero,          /* buf_size */
                    &edgesNum,      /* num_edges */
                    NULL,           /* surf_list */
                    NULL,           /* numed_list */
                    NULL,           /* list_size */
                    NULL            /* num_in_list */
                ),
                targetid = *constructed_object,
                targetos = targetos
            );
        }

        for (ee = 0; ee < edgesNum AND EMSokay (sts); ee++)
        {
            IGRboolean xyzClosed, degenerate;
            OM_S_OBJID edgeId;
            OMuword edgeOs;

            edgeId = edges[ee].objid;
            edgeOs = edges[ee].osnum;

            sts = om$send (
                msg = message EMSedge.EMtst_xyz_clsd (
                    msg,                   /* EMmsg */
                    NULL,                   /* srf_geom */
                    *constructed_object,    /* srf_id */
                    mdenv_info,             /* md_env_info */
                    &xyzClosed              /* is_xyz_closed */
                ),
                targetid = edgeId,
                targetos = edgeOs
            );

            if (EMSokay (sts))
            {
                IGRushort properties = EMED_XYZ_CLOSED;
                IGRshort option = 0;

                if (xyzClosed) option = 1;

                sts = om$send (
                    msg = message EMSedge.EMset_props (
                        msg,       /* EMmsg */
                        properties, /* props */
                        option      /* option */
                    ),
                    targetid = edgeId,
                    targetos = edgeOs
                );
            }

            if (EMSokay (sts)) sts = om$send (
                msg = message EMSedge.EMtst_degn (
                    msg,                   /* EMmsg */
                    NULL,                   /* surf */
                    *constructed_object,    /* srf_id */
                    mdenv_info,             /* md_env */
                    &degenerate             /* is_degen */
                ),
                targetid = edgeId,
                targetos = edgeOs
            );

            if (EMSokay (sts))
            {
                IGRushort properties = EMED_DEGENERATE;
                IGRshort option = 0;

                if (degenerate) option = 1;

                sts = om$send (
                    msg = message EMSedge.EMset_props (
                        msg,       /* EMmsg */
                        properties, /* props */
                        option      /* option */
                    ),
                    targetid = edgeId,
                    targetos = edgeOs
                );
            }
        } /* for (ee = 0; ee < edgesNum AND EMSokay (sts); ee++) */

        if (boundaryCount AND EMSokay (sts))
        {
            sts = om$send (
                msg = message EMSloopset.EMmakeFRT (
                    msg,
                    *constructed_object
                ),
                targetid = newBoundaryId,
                targetos = targetos
            );
        }

        if (edges) om$dealloc (ptr = edges);

        if (EMSerror (*msg) OR EMSerror (sts))
        {
            if (EMSokay (*msg)) *msg = EMS_E_OperationFailed;
            if (EMSokay (sts)) sts = OM_E_ABORT;
        }

    } /* end if (option & EMS_opt_offsetS_copy_topology) */

/*
 * End of routine
 */
wrapup:
 *(construct_list->msg) = *msg;

 /* free output allocated */
 if(partial && surface) (void)BSfreesf(&loc_msg, surface);
 if( offsfs )
 {
    for(i=0; i<numsf; i++)
    {
       if( offsfs[i] )
       {
          if( offsfs[i]->bspsf )
             (void)BSfreesf(&loc_msg, offsfs[i]->bspsf );
          offsfs[i]->bspsf=NULL;
          if( offsfs[i]->sfgen_cv );
             (void)BSfreecv(&loc_msg, offsfs[i]->sfgen_cv );
          offsfs[i]->sfgen_cv=NULL;
          free((char *) offsfs[i] );
          offsfs[i]=NULL;
       }
    }
    free((char *)offsfs );
    offsfs =NULL;
 }


 if (1 & *msg)
  return(OM_S_SUCCESS);
 else
  return(OM_E_ABORT);
}

end implementation EMSsubbs;
