/*
If the undo option is 'delete' then disconnect the edges from my loops in
so that the edges do not get deleted along with the loops in. This is because
this node did not create the edges, so should not delete them.
*/
class implementation NMtrim;

#include "EMSopt.h"
#include "OMmacros.h"
#include "nddef.h"
#include "exmacros.h"
#include "EMSssprops.h"

/* DPR_DISPLAY_BUFF_INCR */
#include "emsdef.h"

#define BUFF_INCR DPR_DISPLAY_BUFF_INCR

from NMinters import NMget_inters;
from EMSsubbs import EMset_props, EMput_range_in_rtree;
extern OMuword OPP_NMinters_class_id;

method EMdeactivate (IGRlong *EMmsg; IGRshort *option; struct GRmd_env *env;
                     GRobjid **display_ids; IGRint *display_count)
{
 IGRlong			sts = OM_S_SUCCESS;
 IGRint				i,j, count, l;
 GRobjid			*lp_in = NULL;
 union EMSssi_table		*ssi = NULL;
 struct EMSboolssi_table	*my_info = NULL;
 OM_S_CHANSELECT		to_ed, to_lp;
 IGRboolean			display;
 struct EMSinters		*inters[2];
 union EMSparent_info   	roots[2];
 unsigned int		root_type[2];
 struct GRid			parents[2], src;
 struct EMSinters		*this_inters;
 struct EMSintobj		*this_intobj;
 struct EMSdataselect		*this_data;
 struct GRid			*this_edge;

 *EMmsg = EMS_S_Success;
 inters[0] = inters[1] = NULL;

 if(*option&EMS_UNDO_SAVE) goto wrapup;
 display = *option & EMS_DO_DISPLAY;

 /* Get my source object for the intersection data
 */
 sts = om$send(msg = message NDnode.NDget_objects(ND_ROOT, parents, 2, NULL, 0,
       MAXINT, &count), targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;
 if(!count) goto wrapup;

 root_type[0] = root_type[1] = EMSgrid;
 sts = om$send(msg = message EMSassoc.EMget_parent_info(EMmsg, NULL, count, 
       (IGRchar *) parents, root_type, roots), targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;
 src = roots[SrcIdx].grobj.grid;


 if(!EFisAncestryValid(EMmsg, src.objid, src.osnum, OPP_NMinters_class_id, 
     TRUE))
  {
   *EMmsg = EMS_I_Fail;
   goto wrapup;
  }

 /* Get the intersection data.
 */
 sts = om$send(msg = message NMinters.NMget_inters(EMmsg, &inters[0], 
       &inters[1], NULL, NULL, NULL, NULL, NULL), targetid = src.objid, 
       targetos = src.osnum);
 if(!(1&*EMmsg&sts)) goto wrapup;

 sts = EMmake_chanselect(EMSbd_owner_to_comps, &to_ed);
 sts = EMmake_chanselect(EMSedge_to_owner, &to_lp);

 if(!(1&sts)) goto wrapup;

 sts = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &ssi),
       targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;

 my_info = &ssi->bool_info;
 lp_in = my_info->region_in_ids;

 for(i=0;i<my_info->num_surfaces;i++)
  {
   if (display)
    {
     IGRint     inx;                
     IGRboolean got_it = FALSE;
     for (inx=0; inx<*display_count; inx++)
      if ( (*display_ids)[inx] == my_info->surface_ids[i] )
       {
        got_it = TRUE;
        break;
       }
      if (! got_it)
       {    
        enum GRdpmode display_mode = GRbehe;
        sts = om$send(msg = message GRgraphics.GRdisplay(EMmsg,
                             &env->md_env.matrix_type, 
                             env->md_env.matrix, &display_mode,
                             &env->md_id),
                       targetid = my_info->surface_ids[i]);
        EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, *EMmsg, wrapup);

        EFrealloc_if_needed(EMmsg, display_ids, *display_count, 
                               BUFF_INCR, sizeof(GRobjid));
        if (!(1 & *EMmsg)) goto wrapup;
        (*display_ids)[*display_count] = my_info->surface_ids[i];
        (*display_count)++;

       }/* if (! got_it) */

    }/* if (display) */

   for(j=0;j<my_info->num_regions_in[i];j++)
    {
     for(l=0; l<2; l++)
      {
       this_inters = inters[l];
       while(this_inters)
        {
	 this_intobj = this_inters->cvs;
	 while(this_intobj)
	  {
	   this_data = &this_intobj->this_uvintobj;
	   if(this_data->datatype == EMSdata_object)
	    {
	     this_edge = this_data->data.object;
	     sts = om$is_objid_on_channel(objid_c = *lp_in, 
		   p_chanselect = &to_ed, objid = this_edge->objid, 
		   osnum_c = this_edge->osnum);
	     if(sts == OM_S_SUCCESS)
	      {
	       sts = om$send(msg = message Root.disconnect(to_ed, 
	             this_edge->objid, this_edge->osnum, to_lp), 
		     targetid = *lp_in);
	       if(!(1&sts)) goto wrapup;
	      }
	     else sts = OM_S_SUCCESS;
	
	    } /* if(this_data->datatype == EMSdata_object) */
	
	   this_intobj = this_intobj->next;
	
	  } /* while(this_intobj) */
	
	 this_inters = this_inters->next;
	
        } /* while(this_inters) */

      } /* for(l=0; l<2; l++) */

     lp_in++;

    }/* for(j=0;j<my_info->num_regions_in[i];j++) */

  }/* for(i=0;i<my_info->num_surfaces;i++) */

wrapup:

for(i=0; i<2; i++)
 if(inters[i])
  {
   IGRlong rc;

   if(!inters[i]) continue;
   (void) NMset_object_data_to_null(inters[i], TRUE, TRUE);
   EMinters_data_free(&rc, inters[i], MAXINT, NULL, NULL);
   EMinters_free(inters[i], MAXINT);
  }

if(1&*EMmsg&sts)
 {
  IGRlong rc;
  struct GRid md_grid;
  IGRuchar sfchange;

  sts = om$send(mode = OM_e_wrt_message, 
        msg = message EMSsfboolean.EMdeactivate(EMmsg, option, env, 
        display_ids, display_count), targetid = my_id);


  md_grid.osnum = OM_Gw_current_OS;
  ex$get_modid(mod_osnum = md_grid.osnum, 
                     mod_id =  &md_grid.objid);
  /* Put correct range of each affected surface in the Rtree. This is required
     since we mucked around with individual edges. The surface change flag
     is intentionaly set to GEOMETRICAL to force a range insertion in the
     Rtree for surfaces end up having natural loopsets after deactivate.
  */
  if(my_info && (!IF_NULL_OBJID(md_grid.objid)))
   {
    sfchange = GEOMETRICAL;
    for(i=0;i<my_info->num_surfaces;i++)
     {
      om$send(msg = message EMSsubbs.EMset_props(&rc, EMSIS_RTREE_RANGE_GOOD, 
        EMS_O_OFF), targetid = my_info->surface_ids[i]);
      om$send(msg = message EMSsubbs.EMput_range_in_rtree(&rc, NULL, NULL, 
        NULL, sfchange, &md_grid), targetid = my_info->surface_ids[i]);
     }
   }
 }

if (ssi) om$dealloc(ptr = ssi);

EMWRAPUP(*EMmsg,sts,"NMtrim.EMdeactivate")
return(sts);
}

end implementation NMtrim;
