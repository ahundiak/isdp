/* $Id $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdroot / VDprocAttr.I
 *
 * Description:
 *     message VDprod_info is used to calculate default mass, center of gravity
 *	       ,volume, dimension, area and range with density = 1.0.
 *     Note:  we need overwrite the method for special class if we can find 
 *		density for that class object        
 *  
 * Dependencies:
 *     Always return OM_S_SUCCESS. if can not find some values, set them = 0.0
 * 
 * Revision History:
 *	$Log $
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *      12/04/97	yzhu		create
 * -------------------------------------------------------------------*/

class implementation VDSroot;

#include <stdio.h>
#include <math.h>
#include "OMerrordef.h"
#include "OMmacros.h"
#include "nddef.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIprims.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "v_dbgmacros.h"
#include "v_measmacros.h"
#include "vdprocinfo.h"

method VDprocAttr( long  		*msg;                 
                   struct GRmd_env 	*md_env;	     	
                   int	  		flag;		   
	           VDprcAttr    	*prcAttr )     
{
	IGRlong                 status = OM_S_SUCCESS;
        struct GRid             MyId, part;
   	IGRboolean   		world = 1;
	IGRchar			errmsg[80];
        IGRint 			rc, i, j; 
	IGRint 		        direct_ind; 
        IGRchar 	        foot_name[80];
        struct ret_struct       str;
        IGRdouble		mass;
        IGRdouble               area;
        IGRdouble               volume;
        GRrange      		range, moment;
        IGRpoint                cog;

        SetProc( VDSroot.VDprocAttr ); Begin

        MyId.objid = my_id;
        MyId.osnum = OM_Gw_current_OS;

        __DBGpr_obj ("MyId", MyId);
        __DBGpr_int ("flag", flag);

        /* get graphics */
        status = om$send( msg = message NDnode.ASreturn_go( &part,
                                                &md_env->md_env.matrix_type,
                                                md_env->md_env.matrix ),
                                targetid= MyId.objid,
                                targetos= MyId.osnum);

        CheckRC ( status, *msg ); 
        __DBGpr_obj ("part", part);

        /* for default density
	prcAttr->density = 1.0;
        	
        /* calculate mass : just get a default mass */
        if ( flag & VD_PROC_MASS ) {
          /* from vd_$get_mass_props to calculate mass */ 
          status = 
          vd_$get_mass_props ( msg      = msg,
                               surfId   = &part ,
                               surfEnv  = md_env,
                               density  = prcAttr->density,
                               mass     = &mass );

          if( status & *msg & 1 )  {
              prcAttr->mass = mass;
              __DBGpr_dbl( "Get mass from vd_$get_mass_props", prcAttr->mass);
          }
          else {
           
            /* use GRgetrang */ 
            status =
            om$send( msg = message GRgraphics.GRgetrang(msg,
                                        &md_env->md_env.matrix_type,
                                        md_env->md_env.matrix,
                                        &world,
                                        range),
                                targetid = part.objid,
                                targetos = part.osnum );
            if( status & *msg & 1 )  {
               prcAttr->mass = prcAttr->density * fabs( (range[5] - range[2])*
                                               (range[4] - range[1])*
                                               (range[3] - range[0]));
               __DBGpr_dbl( "Get mass from GRgetrang", prcAttr->mass);
            }
            else { 
              sprintf (errmsg, "Can not find mass for object %d", part.objid);
              UI_status( errmsg );
              prcAttr->mass = 0.0;
              __DBGpr_dbl( "Can not get mass", prcAttr->mass);
            }
         }
        }

        /* calculate volume */
        if ( flag & VD_PROC_VOLUME ) {
          /* from vd_$get_mass_props to calculate volume */
          status =
          vd_$get_mass_props ( msg      = msg,
                               surfId   = &part ,
                               surfEnv  = md_env,
                               density  = prcAttr->density,
                               volume   = &volume );

          if( status & *msg & 1 )  {
              prcAttr->volume = volume;
              __DBGpr_dbl("Get volume from vd_$get_mass_props",prcAttr->volume);
          }
          else {
            /* from GRgetrang to calculate volume */
            status =
            om$send( msg = message GRgraphics.GRgetrang(msg,
                                        &md_env->md_env.matrix_type,
                                        md_env->md_env.matrix,
                                        &world,
                                        range),
                                targetid = part.objid,
                                targetos = part.osnum );

            if ((status & *msg & 1)  ){
               prcAttr->volume = fabs( (range[5] - range[2])*
                                      (range[4] - range[1])*
                                      (range[3] - range[0]));
               __DBGpr_dbl( "Get volume from GRgetrang", prcAttr->volume);
            }
            else {
              sprintf (errmsg, "Can not find volume for object %d", part.objid);
              UI_status( errmsg );
              prcAttr->volume = 0.0;
              __DBGpr_dbl( "Can not get volume", prcAttr->volume);
            }
          }
        }
     
        /* calculate area */
        if ( flag & VD_PROC_AREA ) {
             /* from vd_$get_mass_props to calculate area */
             status =
             vd_$get_mass_props (msg      = msg,
                               surfId   = &part ,
                               surfEnv  = md_env,
                               density  = prcAttr->density,
                               area     = &area );

             if( status & *msg & 1 )  {
                 prcAttr->area = area;
                 __DBGpr_dbl( "Get area from vd_$get_mass_props",
                                                   prcAttr->area);
             }
             else {
               sprintf (errmsg, "Can not find area for object %d", part.objid);
               UI_status( errmsg );
               prcAttr->area = 0.0;
               __DBGpr_dbl( "Can not get area ",  prcAttr->area);
             }
        }
 
        /* calculate COG   */
        if ( flag & VD_PROC_COG ) {
          /* from vd_$get_mass_props to calculate cog */
          status =
          vd_$get_mass_props (msg      = msg,
                               surfId   = &part ,
                               surfEnv  = md_env,
                               density  = prcAttr->density,
                               centroid = cog );

          if( status & *msg & 1 )  {
                 prcAttr->cog[0] = cog[0];
                 prcAttr->cog[1] = cog[1];
                 prcAttr->cog[2] = cog[2];
                 __DBGpr_vec( "Get cog from vd_$get_mass_props",
                                                   prcAttr->cog);
          }
          else {
           /* get cog by using ACncpx.ACgive_structure */ 
           for ( i =0; i < 3; i++ ) {
             direct_ind = -1;
             if( i == 0 )
            	strcpy( foot_name, "cog_x");
             else if( i == 1 )
            	strcpy( foot_name, "cog_y");
             else if( i == 2 )
                strcpy( foot_name, "cog_z");

             status = 
             om$send(    msg     = message ACncpx.ACgive_structure(
                                                                 &rc,
                                                                 &direct_ind,
                                                                 foot_name,
                                                                 &str,
                                                                 md_env ),
                      mode     = OM_e_wrt_message,
                      targetid = my_id );
             CheckRC( status, rc);
             if( rc & 1 )  {
               prcAttr->cog[i] = str.var.root_pm_st.value;
               __DBGpr_dbl( "Get cog from ACgive_structure", prcAttr->cog[i]);
             }
             else {
               /* get cog from GRgetrang */
               status =
               om$send( msg = message GRgraphics.GRgetrang(msg,
                                        &md_env->md_env.matrix_type,
                                        md_env->md_env.matrix,
                                        &world,
                                        range),
                                targetid = part.objid,
                                targetos = part.osnum );
               if( status & *msg & 1 )  {
                 if( i == 0 )
                     prcAttr->cog[i] = (range[3] + range[0])/2.0; 
                 else if( i == 1 )
                     prcAttr->cog[i] = (range[4] + range[1])/2.0; 
                 else
                     prcAttr->cog[i] = (range[5] + range[2])/2.0;
 
                 __DBGpr_dbl( "Get cog[i] from GRgetrang", prcAttr->cog[i]);
               }
               else {
                sprintf (errmsg, "Can not find COG for object %d", part.objid);
                UI_status( errmsg );
                prcAttr->cog[i] = 0.0;
                __DBGpr_dbl( "Can not get cog ", prcAttr->cog[i] );
               }
            } /* if rc */
          } /* for */
         } /* if status */
        } /* if */


        /* calculate dimention  */
        if ( flag & VD_PROC_DIM ) {
            status =
            om$send( msg = message GRgraphics.GRgetrang(
                                        msg,
                                        &(md_env->md_env.matrix_type),
                                        md_env->md_env.matrix,
                                        &world,
                                        range),
                                targetid = part.objid,
                                targetos = part.osnum );

            if (!(status & *msg & 1) ){
             sprintf (errmsg, "Can not find range for object %d", part.objid);
             UI_status( errmsg );
             for( j=0; j<3; j++ ) prcAttr->dim[j] = 0.0;
             __DBGpr_vec( "Can not get dim ", prcAttr->dim);
            }
            else {
                 prcAttr->dim[0] = fabs (range[3] - range[0]);
                 prcAttr->dim[1] = fabs (range[4] - range[1]);
                 prcAttr->dim[2] = fabs (range[5] - range[2]);

                 __DBGpr_vec( "Get dim from GRgetrang", prcAttr->dim);
            } 
        }

        /* calculate range */
        if ( flag & VD_PROC_RANGE ) {
            status =
            om$send( msg = message GRgraphics.GRgetrang(
                                        msg,
                                        &(md_env->md_env.matrix_type),
                                        md_env->md_env.matrix,
                                        &world,
                                        range),
                                targetid = part.objid,
                                targetos = part.osnum );

    	    if (!(status & *msg & 1) ){
             sprintf (errmsg, "Can not find range for object %d", part.objid); 
             UI_status( errmsg );  
             for( j=0; j<6; j++ ) prcAttr->range[j] = 0.0;
            }
            else 
               for( j=0; j<6; j++ ) prcAttr->range[j] = range[j];
        
            /* print */  
            for( j=0; j<6; j++ ) __DBGpr_dbl( "range[j]", prcAttr->range[j]);
        }

        /* calculate moment */
        if ( flag & VD_PROC_MOMENT ) {
             status =
             vd_$get_mass_props (msg      = msg,
                               surfId   = &part ,
                               surfEnv  = md_env,
                               density  = prcAttr->density,
                               moment   = moment );

             if( status & *msg & 1 )  {
               for( j=0; j<6; j++ ) prcAttr->moment[j] = moment[j];
               for( j=0; j<6; j++ ) 
                __DBGpr_dbl( "Get moment[j] from vd_$get_mass_props", 
				prcAttr->moment[j]);
             }
             else {
               sprintf (errmsg, "Can not find COG for object %d", part.objid);
               UI_status( errmsg );
               for( j=0; j<6; j++ ) prcAttr->moment[j] = 0.0;
               for( j=0; j<6; j++ ) 
                __DBGpr_dbl( "Can not get moment[j]", prcAttr->moment[j]);
             }
        }

        *msg = MSSUCC;
        End
        return OM_S_SUCCESS;
}


/**********************************************************/
long VDproc_Attr(msg, grid, md_env, mass, 
                 volume, area, cog, dim, range, moment)
IGRlong 	*msg;                           /* O */ 
struct GRid 	grid;				/* I */
struct GRmd_env *md_env;  /* I */
IGRdouble      *mass;		  /* O */
IGRdouble      *volume;		/* O */
IGRdouble      *area;		  /* O */
IGRpoint        cog;			/* O */
IGRpoint        dim;			/* O */
GRrange         range;		/* O */ 
GRrange		      moment;   /* O */
{
        IGRlong                 status = OM_S_SUCCESS;
        int			flag, i;
        VDprcAttr               prcAttr;

        SetProc( VDproc_Attr ); Begin

        /* set flag */
        flag = 0;

        if ( mass   ) flag = flag | VD_PROC_MASS; 
        if ( volume ) flag = flag | VD_PROC_VOLUME; 
        if ( area   ) flag = flag | VD_PROC_AREA; 
        if ( cog    ) flag = flag | VD_PROC_COG; 
        if ( dim    ) flag = flag | VD_PROC_DIM; 
        if ( range  ) flag = flag | VD_PROC_RANGE; 
        if ( moment ) flag = flag | VD_PROC_MOMENT; 

        __DBGpr_int( "flag", flag);

	/* get prcAttr */ 
        status = 
        om$send ( msg = message VDSroot.VDprocAttr ( 
				msg, md_env, flag, &prcAttr ),
                                senderid = grid.objid,
                                targetid = grid.objid,
                                targetos = grid.osnum ) ;

        CheckRC( status, *msg );
   
        if ( mass   ) {
                *mass = prcAttr.mass;
                __DBGpr_dbl( "mass", *mass);
        }
        if ( volume ) { 
                *volume = prcAttr.volume; 
                __DBGpr_dbl( "volume", *volume);
        }
        if ( area   ) {
		*area = prcAttr.area;
                __DBGpr_dbl( "area", *area);
        }
        if ( cog    ) {
                 for ( i = 0; i < 3; i++ ) cog[i] = prcAttr.cog[i];
                 __DBGpr_vec( "cog", cog);
        }
        if ( dim    ) {
		 for ( i = 0; i < 3; i++ ) dim[i] = prcAttr.dim[i];
                 __DBGpr_vec( "dim", dim);
        }
        if ( range  ) { 
		 for ( i = 0; i < 6; i++ ) range[i] = prcAttr.range[i];
        
                 /* print */
                 for( i=0; i<6; i++ ) 
			__DBGpr_dbl( "range[i]", range[i]);
        }
        if ( moment ) { 
		 for ( i = 0; i < 6; i++ ) moment[i] = prcAttr.moment[i];
                 /* print */
                 for( i=0; i<6; i++ ) 
			__DBGpr_dbl( "moment[i]", moment[i]);
	}
        *msg = MSSUCC;
	End

        return OM_S_SUCCESS;
 
}

end implementation VDSroot;

