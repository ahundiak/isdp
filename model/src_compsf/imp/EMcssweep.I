/* ###################   APOGEE COMPILED   ################## */
/* 
DESCRIPTION
===========
			
 	This method sweeps a compsite curve either along a vector making
	 a composite surface of projection of EMSprjcompsf classor around
	 an axis thereby making a composite surface of revolution of 
	 class EMSrevcompsf. Depending on the sweep type it either calls:
     1) EMplace_surface_of_projection OR
     2) EMrevolve_curve.
     to get swept surfaces.
     It then establishes connections between the swept surfaces.

NOTES
=====
		
	No effort is spent on orienting the normals of the surfaces, 
	 all the  swept surfaces have their normals pointing in the 
	 same direction, this is because the compsite curve 
	 is parametrized in one direction.

	The composite surface would delete itself (along with its 
	 children) and also the surface which he was about to father.

ARGUMENTS
=========
	
    VARIABLE		    MODE    DESCRIPTION
    --------                ----    -----------

construct_list		    Input   Construct list for the surfaces.
				     Type (struct GRvg_construct *).

curve_info		    Input   Locate info for the composite curve.
				     Output  Locate info for the 
				     individual curves to be swept.
				     Type (struct GRlc_info *).

sweep_parms		    Input   Sweep data for compsite curve.
				     Type (struct EMSsweep_data *) Refer
				      to EMSsweep.h.

recycle1st_objid	    Input   Object id of the object instantiated
				     by the command object (EMSproject or
				     EMSrevol class).	
			    Output  Passed to respective single curve
				     sweep method. This would be object 
				     id of the 1st surface formed by 
				     sweeping 1st curve in the composite 
				     curve.

RETURN VALUE
============

HISTORY
=======
	
SAM		01/11/88		Creation.

AIC		04/16/93		Prevent reading uninitialized
					memory. Also, initialize
					num_surfs on the declaration
					line (instead of on a seperate
					line) and move BSEXTRACTPAR out
					of the for loop.
Sudha      06/21/93     Modified to handle BSprototype ansification

*/

class implementation EMSswcompsf;

#include "EMS.h"
extern OMuword OPP_EMSrevol_class_id, OPP_EMSproject_class_id;

#define DEBUG 0
#if DEBUG
#include <stdio.h>
#endif
#include "msdef.h"
#include "OMmacros.h"
#include "bstypes.h"
#include "emsmacros.h"
#include "maerr.h"
#include "bs.h"
#include "bsparameters.h"
#include "bserr.h"
#include "emserr.h"
#include "OMerrordef.h"
#include "emsedgedef.h"
#include "EMSbnd.h"
#include "EMSopt.h"
#include "EMSprop.h"
#include "EMSerrordef.h"
#include "EMSsweep.h"
#include "msmacros.h"
#include "ECmsg.h"
#include "bsnorvec.h"
#include "bscvarrevt.h"
#include "bscrossp.h"

from EMSrevol	 	import EMrevolve_curve; 
from EMSproject		import EMplace_surface_of_projection;
from EMSedge		import EMconnect_edges, EMset_props,EMget_props;

method EMsweep_composite_curve( struct GRvg_construct * construct_list;
                                struct GRlc_info      * curve_info;
                                struct EMSsweep       * sweep_parms;
                                OM_S_OBJID	      * recycle1st_objid )
{
    #define TRUE  1
    #define FALSE 0

    IGRlong 			num_crvs, EMmsg,i, rc, sts=OM_S_SUCCESS; 
    IGRint			num_surfs = 0, ii;
    OM_S_CHANSELECT		to_compcrv_components;
    OMuword 			osnumaddr;
    struct  GRid		my_grid;
    GRobjid		        * individ_crv_ids, 
  			        comp_crv_id = curve_info->located_obj.objid;
    GRspacenum		        comp_crv_osnum = curve_info->located_obj.osnum;
    struct GRmd_env    		*grmd_env = &(curve_info->module_info);
    struct GRmdenv_info 	*grmdenv_info = &(grmd_env->md_env);
    GRobjid			individ_surface_id, sf_edges[4], 
				stitch_edges[2];

    struct GRprops              comp_crv_props;
    IGRshort         		csmask = GRIS_LOCATABLE | GRIS_DISPLAYABLE,
		                csaction = TRUE;
    IGRboolean                  use_grdelete_and_not_rootdelete = FALSE;
    IGRboolean                  is_compcv = TRUE;
    struct IGRbsp_curve         *ind_crv_geom = NULL;
    IGRchar                     *generic_pointer=NULL;
    IGRvector                   tangent,tangent1,tangent2,start_tangent;
    IGRushort                   prop;
    IGRpoint                    prev_crv_endpt[2],xyz[2][2];
    IGRdouble                   dist1,dist,crossp_len,chtol,params[2];
    IGRvector                   cross_vec;
    struct GRlc_info            temp_curve_info;

    rc = *(construct_list->msg) = MSSUCC;
    temp_curve_info = *curve_info;

    individ_surface_id = *recycle1st_objid;

    EMmake_chanselect ( GRcmpowner_to_components, &to_compcrv_components);

    sts = om$get_channel_count ( p_chanselect = &to_compcrv_components,
      			         objid = comp_crv_id, 
                                 osnum = comp_crv_osnum,
             	                 count = (OMuint *) &num_crvs);

    if (1 & sts)
    {
        individ_crv_ids = (GRobjid *)alloca(num_crvs * sizeof(GRobjid));
 
        for (i=0; i<num_crvs; ++i)
        {
            sts = om$get_objid_at_index ( osnum = comp_crv_osnum,
                                          objid = comp_crv_id,
       	                                  p_chanselect =&to_compcrv_components,
				          index = i,
				          objidaddr = &individ_crv_ids[i],
				          osnumaddr = &osnumaddr );
            if(!(1&sts))
            {
  	        #if DEBUG
	            fprintf(stderr, "Get objid at index (curves) error\n");
       	        # endif
                goto wrapup;
            }


        }
    }
    else
    {
        sts = OM_S_SUCCESS;
        num_crvs = 1;
        individ_crv_ids = &comp_crv_id;
        is_compcv = FALSE;
    }
 
    BSEXTRACTPAR(&rc,BSTOLLENVEC,chtol);

    for (num_surfs = 0; num_surfs < num_crvs; num_surfs++)
    {
        if((num_surfs != 0) || (individ_surface_id == NULL_OBJID))
        {
            sts = om$construct ( osnum = construct_list->env_info->md_id.osnum,
 	                         classid = (sweep_parms->type == EMProject)
				        ? OPP_EMSproject_class_id 
					: OPP_EMSrevol_class_id,
	 		         p_objid = &individ_surface_id);
            if(!(1&sts))
            {
	        #if DEBUG
	         fprintf(stderr, "Construct indvid swept surface id\n");
	        # endif
                goto delete_composite;
  	    }
  	}
         
        use_grdelete_and_not_rootdelete = FALSE;

        temp_curve_info.located_obj.objid = individ_crv_ids[num_surfs];


/********* get the end tangents of the curves ********/

        sts = om$send(msg = message GRvg.GRgenabsg(&EMmsg,
		       &grmdenv_info->matrix_type,
		       grmdenv_info->matrix,
                       &generic_pointer),
                      targetid = individ_crv_ids[num_surfs],
                      targetos = comp_crv_osnum);

   	EMerr_hndlr (!(1&sts&EMmsg),EMmsg,EMS_E_Fail,wrapup);
        ind_crv_geom = (struct IGRbsp_curve *) generic_pointer;

        params[0] = 0.0;
        params[1] = 1.0;
        BScvarrevt(ind_crv_geom,params,2,1.0,xyz,&rc);

        dist1 = dist = 0.0;
        if(num_surfs != 0)
         {
          for(ii=0;ii<3;ii++)
            dist1 += ( (prev_crv_endpt[0][ii] - xyz[1][0][ii])*
                       (prev_crv_endpt[0][ii] - xyz[1][0][ii])) ;

          dist = sqrt(dist1);
         }
          
        for(ii=0;ii<3;ii++)
           {
           tangent1[ii] = xyz[0][1][ii] - xyz[0][0][ii];
           prev_crv_endpt[0][ii] =xyz[0][0][ii];
           }
        BSnorvec(&rc,tangent1);

        for(ii=0;ii<3;ii++)
           {
           tangent2[ii] = xyz[1][1][ii] - xyz[1][0][ii];
           prev_crv_endpt[1][ii] =xyz[1][0][ii];
           }
        BSnorvec(&rc,tangent2);

        if(num_surfs > 0 && num_crvs > 2)
           if( (  dist<= chtol   ) && ( ii != 0 ) )
             {
              ex$message(msgnumb = EMS_S_IgExElmsInProf);
              sleep(1);
              continue;
              }
/*********/

        if(sweep_parms->type == EMRevolve)
	{
	    sts = om$send ( mode = OM_e_wrt_object, 
	                    msg  = message EMSrevol.EMrevolve_curve
                                      ( construct_list,
		                        &temp_curve_info,
                                        NULL,
                            (IGRpoint *)sweep_parms->data.rev_data.axis,
			                sweep_parms->data.rev_data.start_angle,
			                sweep_parms->data.rev_data.sweep_angle,
			                sweep_parms->data.rev_data.full_rev,
			                TRUE,
			                &individ_surface_id,
			                (IGRint *)&rc ),
                            senderid = my_id,
			    targetid = individ_surface_id);
	}
	else
	{
	    sts = om$send ( mode = OM_e_wrt_object,
	                    msg = message EMSproject.EMplace_surface_of_projection
                                        ( construct_list,
			                  &(temp_curve_info.located_obj),
			                  grmd_env,
			                  NULL,
			                  NULL,
			                  (double *)sweep_parms->data.prj_data.point1,
			                  (double *)sweep_parms->data.prj_data.point2,
			                  TRUE, /* Pos orient */
			                  &individ_surface_id ),
			    senderid = my_id,
			    targetid = individ_surface_id);
	}

        if( (!(1&sts)) )
	{
	    # if DEBUG 
 	        fprintf(stderr, "EMSproject or EMSrevol method error\n");
            # endif
         
            if( (!(1 & rc)) || (!(1 & *(construct_list->msg))) )
	        goto delete_composite;
            else
                goto wrapup;
	}
        
        use_grdelete_and_not_rootdelete = TRUE;

/*
        if ( is_compcv )
*/

/*
 * If creating a composite surface with just one component, we have
 * to bloody well make sure that the same has topology. Otherwise
 * shit will hit the fan.
 * pp 06/07/91
 */
        {
            sts = om$send ( msg = message EMSsurface.EMmk_nat_bdry
                                            ( &rc, 
                                              grmdenv_info,
	    	                              sf_edges ),
	                    targetid = individ_surface_id);
	
            if( (!(1&sts)) || (!(1&rc)) )
            {
	        # if DEBUG 
    	            fprintf(stderr, "EMSsubbs.EMmk_nat_bdry error\n");
                # endif
    	        goto wrapup;
    	    }
    
            if(num_surfs == 0)
    	    {
	        stitch_edges[0] = sf_edges[0];
	        stitch_edges[1] = sf_edges[2];

              OM_BLOCK_MOVE(tangent1,start_tangent,sizeof(IGRvector));
              OM_BLOCK_MOVE(tangent2,tangent,sizeof(IGRvector));
	    }
            else
            {

/* get  tolerance */


                BScrossp(&rc,tangent,tangent1,cross_vec);

                crossp_len = sqrt(cross_vec[0]*cross_vec[0]+
                                  cross_vec[1]*cross_vec[1]+
                                  cross_vec[2]*cross_vec[2]);

                if(crossp_len <= chtol)
                   {
                   prop = EMED_TANGENT ;
                   sts = om$send ( msg = message EMSedge.EMset_props
                                        (&rc,prop, EMS_O_ON),
                                         targetid = stitch_edges[1]);

                   sts = om$send ( msg = message EMSedge.EMset_props
                                        (&rc,prop, EMS_O_ON),
                                         targetid = sf_edges[0]);
                                         
                   }
    
                sts = om$send ( msg = message EMSedge.EMconnect_edges
                                        ( &rc,
                                          EMED_REVERSE_CONNECT,
                                          FALSE, 
	                                  stitch_edges[1],
                                          NULL_OBJID,
                                          NULL_OBJID,
                                          grmdenv_info ),
		                targetid = sf_edges[0] );

                if( (!(1&sts)) || (!(1&rc)) )
	        {
	            # if DEBUG 
 	                fprintf(stderr, "EMSedge.connect_edges error\n");
                    # endif
                    goto wrapup;
	        }

                OM_BLOCK_MOVE(tangent2,tangent,sizeof(IGRvector));
	        stitch_edges[1] = sf_edges[2];
            }
        }

	my_grid.objid = my_id;
	my_grid.osnum = OM_Gw_current_OS;
	
        sts = om$send( msg = message GRvg.GRrigidconn
                                    ( &rc,
	                              &my_grid,
			              (IGRlong *)&num_surfs ),
	               targetid = individ_surface_id );

        if(!(1&sts) || !(1&rc) )
        {
	    # if DEBUG 
 	        fprintf(stderr, "Connect surface to composite error\n");
            # endif
	    goto wrapup;
	}
    }

    if (is_compcv)
    {
        sts = om$send ( msg = message GRvg.GRgeomprops
                                        ( &rc,
                                          &(grmdenv_info->matrix_type),
	    	                          grmdenv_info->matrix,
		                          &comp_crv_props),
	 	       
                        targetid = comp_crv_id,
		        targetos = comp_crv_osnum);
        
        if( (!(1&sts)) || (!(1&rc)) )
        {
            # if DEBUG 
            fprintf(stderr, "GRcompcurve.GRgeomprops error\n");
            # endif
            goto wrapup;
        }

        if(comp_crv_props.phy_closed)
        {

                BScrossp(&rc,start_tangent,tangent,cross_vec);

                crossp_len = sqrt(cross_vec[0]*cross_vec[0]+
                                  cross_vec[1]*cross_vec[1]+
                                  cross_vec[2]*cross_vec[2]);

                if(crossp_len <= chtol)
                   {
                   prop = EMED_TANGENT ;
                   sts = om$send ( msg = message EMSedge.EMset_props
                                        (&rc,prop, EMS_O_ON),
                                         targetid = stitch_edges[1]);

                   sts = om$send ( msg = message EMSedge.EMset_props
                                        (&rc,prop, EMS_O_ON),
                                         targetid = stitch_edges[0]);
                   }

            sts = om$send ( msg = message EMSedge.EMconnect_edges
                                    ( &rc,
                                      EMED_REVERSE_CONNECT,
                                      FALSE, 
	                              stitch_edges[1],
                                      NULL_OBJID,
                                      NULL_OBJID,
		                      grmdenv_info ),
	    	            targetid = stitch_edges[0] );

            if( (!(1&sts)) || (!(1&rc)) )
            {
	        # if DEBUG 
 	            fprintf(stderr, "EMSedge.connect_edges error\n");
                # endif
                goto wrapup;
            }

        }
    }

    sts = om$send ( msg = message GRvg.GRchgprops (&rc, &csaction, &csmask),
                    targetid = my_id);

    if( (!(1&sts)) || (!(1&rc)) )
    {
        # if DEBUG 
            fprintf(stderr, "GRvg.GRchgprops of composite surface error\n");
        # endif
        goto wrapup;
    }

    return (OM_S_SUCCESS);

wrapup:

    if(use_grdelete_and_not_rootdelete)
    {
        sts = om$send ( msg= message GRvg.GRdelete( &rc,
                                                    &(curve_info->module_info)),
                        targetid = individ_surface_id);
        if( (!(1&sts)) || (!(1&rc)) )
        {
            # if DEBUG 
             fprintf(stderr, "GRvg.GRdelete error\n");
            # endif
        }
    }
    else
    {
        sts = om$send ( msg = message Root.delete(1),
	  	        targetid = individ_surface_id );
    }

delete_composite:

    sts = om$send ( mode = OM_e_wrt_object,
                    msg = message GRvg.GRdelete ( &rc,
                                                  &(curve_info->module_info)),
                   targetid = my_id);

    if( (!(1&sts)) || (!(1&rc)) )
    {
        # if DEBUG 
             fprintf(stderr, "GRvg.GRdelete error\n");
        # endif
    }

    return(OM_E_ABORT);
}

end implementation EMSswcompsf;



