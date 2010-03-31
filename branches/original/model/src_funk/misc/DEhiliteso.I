class implementation CEO_GSLOCATE;

#include "coimport.h"
#include "msdef.h"
#include "OMindex.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "gomacros.h"
#include "EMSopt.h"
#include "EMSlcdef.h"
#include "emsdef.h"
#include "igrdef.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "EMSdatumdef.h"
#include "EMdtmacros.h"
#include "exdef.h"
#include "ex.h" 
#include "exmacros.h"
#include "DItypedef.h" 
#include "DIdef.h"
#include "EMSasnuc.h"
#include "matypemx.h"

from GRgraphics  import GRdisplay, GRgetprops;
from DEso        import DEget;
from EMSsubbs    import EMget_edges, EMget_graphics_edges;
from EMSedge     import EMgetxyzobj;

extern IGRlong EMselective_fence();
extern OMuword OPP_EMSsubbs_class_id;
extern OMuword OPP_GRvg_class_id;

/*
Function
        COshowsymo

Description
        This function determines whether the calling object has a symbology
	override or not, and if so, highlight the symbology override.

History
        jsd     11/06/91    new design using Elements in View
        jack    02/24/92    Send default attributes to DEget.
        jack    02/26/92    Send the matrix and matrix type of
                            each object returned from sel. fence
                            to DEget.  Also added support for 
                            EMSgraloop, EMScusp, and EMShorizon edges.
        Sudha   07/08/93    Modified for BSprototypes ansification

*/

IGRint COshowsymo (msg, caller, vw_grid, event)

       IGRlong    *msg;
       OM_S_OBJID *caller;
struct GRid       *vw_grid;
struct GRevent    *event;

{
    IGRint               i;
    IGRint               j,tt;
    IGRint               sts;
    IGRint               array_size;
    IGRint               num_edges = 0,
                         r_num_edges = 0,
                         num_gralp_edges = 0,
                         num_horiz_edges = 0,
                         num_cusp_edges = 0,
                         bytes_ret,
                         which_error,
                         num_parents;
    IGRshort             properties;
    IGRlong              numb_objs; 
    OMuword              classes;
    GRobjid              edge_id;
    IGRboolean           b_sts;
    IGRboolean           validate_child;
    IGRboolean           found;
    enum   GRdpmode      display_mode;
    struct GRlc_info    *group_objs = NULL;
    struct GRlc_info     tmp_obj;
    struct GRid         *tmp_grid = NULL;
    struct GRid         *edges = NULL,
                        *gralp_edges = NULL,
                        *horiz_edges = NULL,
                        *cusp_edges = NULL;
    struct GRmdenv_info  md_env;
    struct GRmd_env      rp_md_env;
    OM_S_CLASSLIST       yes_classes;
    OM_S_CLASSLIST       no_classes;
    struct IGRdisplay    orig_ele_attr;
    struct var_list      list[2];
    struct GRid          ref_pln_GRid;            
    struct EMSobject_info parents[2];
    IGRshort             options = 0;


     sts  = OM_S_SUCCESS;
    *msg  = MSSUCC;
    b_sts = FALSE;

    display_mode = GRhd;

    no_classes.w_count = 0;

    classes               = OPP_GRvg_class_id;
    yes_classes.p_classes = &classes;
    yes_classes.w_count   = 1;
       
    numb_objs  = 0;
    group_objs = NULL;

    validate_child = TRUE;
    found          = FALSE;

    md_env = event->located_object[0].module_info.md_env;

    /* set up the options for the call to EMget_graphics_edges */
    options = EMS_OPT_GRALOOP | EMS_OPT_HORIZON | EMS_OPT_CUSP;

    /* get the world to view matrix for this window */
    list[0].var = WLD_TO_VIEW;
    list[0].var_ptr = (IGRchar *)rp_md_env.md_env.matrix;
    list[0].num_bytes = sizeof(IGRdouble) * 16;
    list[0].bytes_returned = (IGRlong *)&bytes_ret;

    list[1].var = END_PARAM;
    list[1].var_ptr = NULL;
    list[1].num_bytes = 0;
    list[1].bytes_returned = NULL;

    sts = dp$inq_set_gragad(msg = msg,
                            osnum = vw_grid->osnum,
                            gragad_objid = vw_grid->objid,
                            which_error = &which_error,
                            var_list = list);
    if(!(1 & sts & *msg))
      goto wrapup;

    sts = MAtypemx(msg, 
                   rp_md_env.md_env.matrix, 
                  &rp_md_env.md_env.matrix_type);
    if(!(1 & sts & *msg))
      goto wrapup;

    sts = EMselective_fence( &yes_classes,
                             &no_classes,
                             &event->located_object[0],
                              TRUE, /* break_down_composites */
                              TRUE, /* is_operation_readonly */
                             *caller,
                             &numb_objs,
                             &group_objs,
                              msg );
    if(!(1 & sts & *msg))
      goto wrapup;


    for ( i=0; i<numb_objs; i++ )
    {
      tmp_obj    = group_objs[i];
      array_size = 0;

      b_sts = EFisAncestryValid( msg,
			         tmp_obj.located_obj.objid,
			         tmp_obj.located_obj.osnum,
                                 OPP_EMSsubbs_class_id,
                                 validate_child );
      if(!(1 & *msg))
        goto wrapup;


      if ( b_sts )
      {
        num_edges  = 0;
        r_num_edges = 0;
        num_gralp_edges = 0;
        num_horiz_edges = 0;
        num_cusp_edges = 0;                  

        /* each surface can have regular edges and graphic edges
           (EMShorizon, EMScusp, EMSgraloop).
         */  

        /* first get the regular edges for this surface */
        sts = om$send( msg = message EMSsubbs.EMget_edges(
                             msg,
                             MAXINT,
                             EMS_OPT_ALL,
                            &tmp_obj.module_info,
                            &edges,
                            &array_size,
                            &r_num_edges ),
                       senderid = tmp_obj.located_obj.objid,
                       targetid = tmp_obj.located_obj.objid,
                       targetos = tmp_obj.located_obj.osnum );
        if(!(1 & sts & *msg))
          goto wrapup;


        /* now get the other edges.  horizon edges have a reference
           plane as an associative parent.  we must determine the
           reference plane for this orientation to get the horizon
           edges.
         */
        ems$get_reference_plane_for_given_orientation(
                 msg = msg,
                 env_info = &tmp_obj.module_info,
                 refpln_mxtyp = &rp_md_env.md_env.matrix_type,
                 refpln_mx = rp_md_env.md_env.matrix,
                 pln_GRid = &ref_pln_GRid);
        if(!(1 & *msg))
          goto wrapup;
  
        rp_md_env.md_id.objid = 0;
        rp_md_env.md_id.osnum = 0;   

        /* set up the parents of the horizon loop to send to 
           EMget_graphics_edges.  
         */  
        parents[0].grid.objid = ref_pln_GRid.objid;
        parents[0].grid.osnum = ref_pln_GRid.osnum;
        parents[0].env = rp_md_env;
        parents[1].grid.objid = tmp_obj.located_obj.objid;
        parents[1].grid.osnum = tmp_obj.located_obj.osnum;
        parents[1].env = tmp_obj.module_info;

        num_parents = 2;

        sts = om$send( msg = message EMSsubbs.EMget_graphics_edges(
                                             msg,
                                            &num_parents,
                                             parents,
                                             options,
                                            &num_gralp_edges,
                                            &num_horiz_edges,
                                            &num_cusp_edges,
                                            &gralp_edges,
                                            &horiz_edges,
                                            &cusp_edges ),
                       senderid = tmp_obj.located_obj.objid,
                       targetid = tmp_obj.located_obj.objid,
                       targetos = tmp_obj.located_obj.osnum );
        if(!(1 & sts & *msg))
          goto wrapup;


      for(tt=0; tt < 4; tt++)
       {
        if(tt==0)
         {
          tmp_grid = edges;
          num_edges = r_num_edges;
         }
        else 
        if(tt==1)
         {
          tmp_grid = gralp_edges;
          num_edges = num_gralp_edges;        
         }
        else
        if(tt==2)
         {
          tmp_grid = horiz_edges;
          num_edges = num_horiz_edges;        
         }
        else
        if(tt==3)
         {
          tmp_grid = cusp_edges;
          num_edges = num_cusp_edges;
         }
        else
         {
          tmp_grid = NULL;
          num_edges = 0;
         }

        
          
        for ( j=0; j<num_edges; j++,tmp_grid++ )
        {
          sts = om$send( msg = message EMSedge.EMgetxyzobj(
                               msg,
                               EMSlcopt_existingmsc,
                               NULL, NULL, NULL, NULL, NULL,
		               tmp_grid->osnum,
		              &edge_id ),
                         senderid = tmp_grid->objid,
                         targetid = tmp_grid->objid,
                         targetos = tmp_grid->osnum );

          sts = om$send( msg = message GRgraphics.GRgetprops(
                               msg,
                              &properties ),
                         senderid = edge_id,
                         targetid = edge_id,
                         targetos = tmp_grid->osnum );

          if ((sts & *msg & 1) && (properties & DEHAS_OVERRIDE ))
          {
                   IGRint     *types;
                   IGRdouble  *boundary_parms;
            struct GRid        soo;
            struct IGRdisplay *display_attributes;
                   IGRint      count;

            sts = gr$get_active_display( buffer = &orig_ele_attr );

            DEget_soo( &soo.objid,
                       &soo.osnum,
                        tmp_grid->osnum );

            sts = om$send( msg = message DEso.DEget(
                                 msg,
                                &types,
                                &boundary_parms,
                                &count,
                                &display_attributes,
                                &orig_ele_attr,
                                 edge_id,
                                 vw_grid->objid,
                                &tmp_obj.module_info.md_env.matrix_type,
                                 tmp_obj.module_info.md_env.matrix,
	                         0,
                                 0 ),
	                    senderid = edge_id,
                            targetid = soo.objid,
                            targetos = soo.osnum);

	    if (count)
	    {
	      found = TRUE;

              sts = om$send( msg = message GRgraphics.GRdisplay(
                                   msg,
	                          &md_env.matrix_type,
                                   md_env.matrix,
                                  &display_mode,
                                   vw_grid ),
                             senderid = edge_id,
                             targetid = edge_id,
                             targetos = tmp_grid->osnum );
	    } /* end if count */
          }  /* end if DEHAS_OVERRIDE */
        }   /* end num_edges loop */
       }   /* end tt loop */
 
       /* Deallocate the memory for the edges */
       if(edges)
        {
         om$dealloc(ptr = edges);          
         edges = NULL;
        }
       if(gralp_edges)
        {
         om$dealloc(ptr = gralp_edges);
         gralp_edges = NULL;
        }
       if(horiz_edges)
        {
         om$dealloc(ptr = horiz_edges);
         horiz_edges = NULL;          
        }
       if(cusp_edges)
        {
         om$dealloc(ptr = cusp_edges);          
         cusp_edges = NULL;
        }


      }   /* end if subclass of EMSsubbs */
      else
      {
        sts = om$send( msg = message GRgraphics.GRgetprops(
                             msg,
                            &properties ),
                       senderid = tmp_obj.located_obj.objid,
                       targetid = tmp_obj.located_obj.objid,
                       targetos = tmp_obj.located_obj.osnum );

        if ((sts & *msg & 1) && (properties & DEHAS_OVERRIDE ))
        {
                 IGRint     *types;
                 IGRdouble  *boundary_parms;
          struct GRid        soo;
          struct IGRdisplay *display_attributes;
                 IGRint      count;

          sts = gr$get_active_display( buffer = &orig_ele_attr );


          DEget_soo( &soo.objid,
                     &soo.osnum,
                      tmp_obj.located_obj.osnum );

          sts = om$send( msg = message DEso.DEget(
                               msg,
                              &types,
                              &boundary_parms,
                              &count,
                              &display_attributes,
                              &orig_ele_attr,
                               tmp_obj.located_obj.objid,
                               vw_grid->objid,
                              &tmp_obj.module_info.md_env.matrix_type,
                               tmp_obj.module_info.md_env.matrix,
                               0,
                               0 ),
                          senderid = tmp_obj.located_obj.objid,
                          targetid = soo.objid,
                          targetos = soo.osnum);

          if (count)
          {
	    found = TRUE;

            sts = om$send( msg = message GRgraphics.GRdisplay(
                                 msg,
                                &md_env.matrix_type,
                                 md_env.matrix,
                                &display_mode,
                                 vw_grid ),
                           senderid = tmp_obj.located_obj.objid,
                           targetid = tmp_obj.located_obj.objid,
                           targetos = tmp_obj.located_obj.osnum );
          }
	}
      }
    }

    if ( found )
      *msg = MSSUCC;
    else
      *msg = MSFAIL;

wrapup:
    if(edges)
      om$dealloc(ptr = edges);
    if(gralp_edges)
      om$dealloc(ptr = gralp_edges);
    if(horiz_edges)
      om$dealloc(ptr = horiz_edges);
    if(cusp_edges)
      om$dealloc(ptr = cusp_edges);

    return (sts);
}

end implementation CEO_GSLOCATE;
