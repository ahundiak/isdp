 /*
 * File:    EMpreproc.I
 *
 *
 * Description:
 *
 *     This file contains the interface routines to the math functions,
 *     and the NDcompute_node method of EMinstance.
 *
 * Notes:
 *
 * History:
 *
 *      07/09/93     Krishna Kumar    creation date 
 *      17-may-94    dkk              disable recompute for EM_EXPLODED parts
 *
 */
class implementation EMinstance;
#include "OMtypes.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "igrdef.h"
#include "igr.h"
#include "gr.h"
#include "igrdp.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "godef.h"
#include "go.h"
#include "gocmacros.h"
#include "dpdef.h"
#include "dp.h"
#include "dpstruct.h"
#include "dpmacros.h"
#include "bstypes.h"
#include "bsconic.h"
#include "exdef.h"
#include "ex.h"
#include "exmacros.h"
#include "griodef.h"
#include "grio.h"
#include "nddef.h"
#include "EMSasnuc.h"
#include "EMSsfparms.h"
#include "emssfdef.h"

#include "assemdef.h"
#include "assem.h"
#include "assemconstr.h"
#include "assemmath.h"
#include "assemmacros.h"

#ifdef DEBUG
#define verbose(x) x
#else
#define verbose(x)
#endif

from EMconstr     import EMget_ftrs_with_env, EMget_offset;
from EMSparameter import EMgetdimgeom;
from EMAdatpln    import EMget_pln_info;
from GRlinear	  import GRgetpolyline;
from EMSsurface   import EMget_params;
from GRcontext    import GRgetinstance;

extern OMuword OPP_EMSplane_class_id;
extern OMuword OPP_GR3dlineseg_class_id;
extern OMuword OPP_EMSrevol_class_id;
extern OMuword OPP_EMAdatpln_class_id;
extern OMuword OPP_EMSparamvc_class_id;
extern OMuword OPP_EMconstr_class_id;
extern OMuword OPP_EMground_class_id;
extern OMuword OPP_GR3dlinestr_class_id;

extern double BSdistptpt();

#define OINFO   0
#define SINFO   1
#define AINFO   2

/*#define DEBUG*/
#define MAX_STACK_SIZE  256

#define     CYL_AXIS    1
#define     PLANAR	2
#define	    EDGE	3

#define EM_EXPLODED 0x10000000

IGRboolean EMproc_math_error( rc, buffer )
IGRint rc;
IGRchar * buffer;
{
    switch( rc )
    {
        case ASM_MATH_SUCC:
            return( TRUE );

        case ASM_MABS_FAIL:
/*            ex$message( msgnumb = EMS_S_MATHFAILURE, buff = buffer );*/
	    strcpy( buffer,"Math Failure" );
            return( FALSE );

        case ASM_MATE_SUCC:
/*            ex$message( msgnumb = EMS_S_MATESUCC, buff = buffer );*/
	    strcpy( buffer,"Only Mate Successful");
            return( TRUE );

        case ASM_ALIGN_SUCC:
/*            ex$message( msgnumb = EMS_S_ALIGNSUCC, buff = buffer );*/
	    strcpy( buffer,"Only Align Successful" );
            return( TRUE );

        case ASM_FST_ALIGN_SUCC:
/*            ex$message( msgnumb = EMS_S_FSTALIGNSUCC, buff = buffer );*/
            strcpy( buffer,"Only First Align Successful");
            return( TRUE );

        case ASM_SEC_ALIGN_SUCC:
/*            ex$message( msgnumb = EMS_S_SECALIGNSUCC, buff = buffer );*/
            strcpy( buffer,"Only Second Align Successful");
            return( TRUE );

        case ASM_ALIGN_PART_SUCC:
/*            ex$message( msgnumb = EMS_S_ALPARTIALSUCC, buff = buffer );*/
            strcpy(buffer, "Align Partial Success");
            return( TRUE );

        case ASM_INVALID_INPUT:
/*            ex$message( msgnumb = EMS_S_INVALIDINP, buff = buffer );*/
            strcpy(buffer,"Invalid Input");
            return( FALSE );

        default:
            return( FALSE );
    }
}

method NDcompute_node ( IGRlong *rc; IGRint cn_type;
			   IGRint count; struct GRid list []; 
                           struct GRmd_env *md_env)
{
int  om_msg = OM_S_SUCCESS, i, j;
long msg = MSSUCC;
short mat_type, found = 0;
OMuword classid;
IGRmatrix matrix;
static struct GRid stk_ids[MAX_STACK_SIZE];
static int stk_cnt = 0;
struct GRid modid;
/*
unsigned int basis;
struct GRid *cnstr_list = NULL;
int num_cnstr;
*/
    ex$get_cur_mod( id = &modid.objid, osnum = &modid.osnum );

    {
    IGRuint props;
    struct  GRid my_grid;

        my_grid.objid = my_id;
        my_grid.osnum = md_env->md_id.osnum;

        /* check the application properties of the part */
        asm$get_application_props( msg = &msg,
                                   id = &my_grid,
                                   props = &props );

        /* If the part is in exploded state, donot recompute */
        if( props & EM_EXPLODED ) 
        {
            UI_status("Part is in EXPLODED state");
            *rc = ND_COMP_SUCC;
            return( OM_S_SUCCESS );
        }
    }

    for( i = 0; i < stk_cnt; i++ )
    {
        if((stk_ids[i].objid == my_id)&&(stk_ids[i].osnum == md_env->md_id.osnum))
        {
            for( j = i; j < stk_cnt; j++ )
	        stk_ids[j] = stk_ids[j+1];
            stk_cnt--;
            *rc = ND_COMP_SUCC;
            return( OM_S_SUCCESS );
        }
    }

    if( stk_cnt < MAX_STACK_SIZE )
    {
        /* Donot stack instance objects within nested reference files, because
           second recompute for these objects will not be there 24/08/94.
        */
        if (OM_Gw_current_OS == modid.osnum)
        {
            stk_ids[stk_cnt].objid = my_id;
            stk_ids[stk_cnt].osnum = md_env->md_id.osnum;
            stk_cnt++;
        }
    }

    for( i = 0; i < count; i++ )
    {
        om$get_classid( objid = list[i].objid,
                        osnum = list[i].osnum,
                        p_classid = &classid );

        if (om$is_ancestry_valid (subclassid = classid,
             superclassid = OPP_EMconstr_class_id) == OM_S_SUCCESS)
        {
            /*
             * Check if a GROUND is acting on the part then no compute
             * is required, remove the part from the stack - 05/11/94
             */
            if (om$is_ancestry_valid (subclassid = classid,
                 superclassid = OPP_EMground_class_id) == OM_S_SUCCESS)
            {
                stk_cnt--;
                stk_ids[stk_cnt].objid = 0;
                stk_ids[stk_cnt].osnum = 0;
                found = 0;
                break;
            }
	    found = 1;
            break;
        }
    }

    if( !found ) /* No constraints acting */
    {
        *rc = ND_COMP_SUCC ;
        return( OM_S_SUCCESS );
    }

    om_msg = om$send( msg = message EMinstance.EMcompute_xform_matrix( &msg,
                                                                       list,
                                                                       count,
                                                                       matrix),
                            targetid = my_id );

    if( ! ( om_msg & msg & 1 ))
    {
        *rc = ND_COMP_FAIL;
    }
    else
    {
    GRobjid newobj;
    int mode;


#ifdef DEBUG
for(i=0;i<16;i++)
printf("xform_mat[%d]=%f\n",i,matrix[i]);
#endif

	mode = GRbe;
        om_msg = om$send(msg = message GRgraphics.GRdisplay(&msg, 
					&md_env->md_env.matrix_type, 
					md_env->md_env.matrix, 
					(enum GRdpmode * )(&mode), &modid), 
        	  targetid = my_id);

        MAtypemx( &msg, matrix, &mat_type );

	if (OM_Gw_current_OS != modid.osnum) /* Not in master file */
	{
	EMmemb memb;
        struct GRid context, context1;
        OM_S_CHANSELECT context_chan, tonested_chan;
        IGRshort type, flag;
        IGRmatrix ctx_mat;
        OMuword osnum;

    	    /* First get the ref id connected to the instance */
	    om_msg = om$send (msg = message EMdescribe.EMget_memb (&msg,
                                                               NULL,
                                                               EM_GRAPHIC,
                                                               0,
                                                               &memb),
        	                  targetid = my_id);
	    if (om_msg & msg & 1)
            {
		/* Get the context on slot 0 of the ref file */
                om_msg = om$make_chanselect(channame = "GRreffile.to_context",
		                p_chanselect = &context_chan);

        	if ( 1 & om_msg)
    	        {
	            om_msg = om$get_objid_at_index(osnum = memb.id.osnum,
                                		objid = memb.id.objid,
		                                p_chanselect = &context_chan,
		                                index = 0,
		                                objidaddr = &context.objid,
		                                osnumaddr = &context.osnum);
	        }
		/* Get the context on the to_nested channel of this context */
                if (context.osnum == modid.osnum) /* should be in master OS */
	        {
		    /* Get the instance of this context, which is one level 
                       above the current ref file and use it as the matrix
                       for GRxform
		    */
    		    om_msg = om$make_chanselect(
			channame = "GRcontext.to_nested_files",
			p_chanselect = &tonested_chan);

	            om_msg = om$get_objid_at_index(osnum = context.osnum,
                                		objid = context.objid,
		                                p_chanselect = &tonested_chan,
		                                index = 0,
		                                objidaddr = &context1.objid,
		                                osnumaddr = &context1.osnum);

        	    om_msg = om$send(msg = message GRcontext.GRgetinstance
			        (&msg,&type,ctx_mat,&osnum,&flag,&context),
			        targetid = context1.objid,
			        targetos = context1.osnum);

        	    if (1 & om_msg & msg)
	            {
                    struct GRmd_env env;

                        env = *md_env;
                        memcpy(env.md_env.matrix, ctx_mat, sizeof(IGRmatrix));
                        env.md_env.matrix_type = type;
			env.md_id.objid = NULL_OBJID;
                        om_msg = om$send( msg = message GRgraphics.GRxform( &msg,
							    &env,
							    &mat_type,
							    matrix,
							    &newobj ),
				targetid = my_id );
                    }
                }
	    }
	}
        else
        {
            om_msg = om$send( msg = message GRgraphics.GRxform( &msg,
							    md_env,
							    &mat_type,
							    matrix,
							    &newobj ),
				targetid = my_id );
        }

	if( !(om_msg & msg & 1 ))
	{
	    verbose(printf("GRxform failed for obj %d\n", my_id));
        }
	mode = GRbd;
        om_msg = om$send(msg = message GRgraphics.GRdisplay(&msg, 
					&md_env->md_env.matrix_type, 
					md_env->md_env.matrix, 
					(enum GRdpmode * )(&mode), &modid),
        	  targetid = newobj);

        *rc = ND_COMP_SUCC;
    }

/*ret_end:*/
    if( !(om_msg & 1) || !(msg&1) ) /* Since Math/GRxform failed, clear the stack */
    {
        for( i = 0; i < stk_cnt; i++ )
        {
            stk_ids[i].objid = 0;
            stk_ids[i].osnum = 0;
        }
        stk_cnt = 0;
    }
/*
    if( cnstr_list )
        free( cnstr_list );
*/

    return( OM_S_SUCCESS );
}


method EMcompute_xform_matrix( IGRlong *rc; struct GRid *rootlst; 
                               IGRint rootcnt; IGRmatrix matrix )
{
IGRint  om_msg = OM_S_SUCCESS, num_cnstr, cnt, i;
IGRlong msg = MSSUCC;
IGRboolean ret;
IGRchar    buffer[256];
IGRuint basis;
OMuword classid;
struct GRid *cnstr_list = NULL, *list = NULL;

    *rc = MSSUCC;
    if( rootlst == NULL )
    {
        /*
         * Obtain the root list of the part
         */
        om_msg = om$send( msg = message NDnode.NDget_objects(ND_ROOT,NULL,
                                              0,NULL,0,OM_K_MAXINT,&cnt),
                     targetid = my_id );

        list =  ( struct GRid * )malloc((cnt + 1) * sizeof( struct GRid ));

        om_msg = om$send( msg = message NDnode.NDget_objects(ND_ROOT,list,
                                              cnt,NULL,0,OM_K_MAXINT,&cnt),
                     targetid = my_id );
    }
    else
    {
        list = rootlst;
        cnt = rootcnt;
    }
        
    /* 
     * Get the list of constraints from the roots.
     */
    num_cnstr = 0;
    cnstr_list = ( struct GRid * )malloc((num_cnstr + 1) *
                                             sizeof( struct GRid ));
    for( i = 0; i < cnt; i++ )
    {
        om$get_classid( objid = list[i].objid,
                        osnum = list[i].osnum,
                        p_classid = &classid );

        if (om$is_ancestry_valid (subclassid = classid,
             superclassid = OPP_EMconstr_class_id) == OM_S_SUCCESS)
        {
            cnstr_list = ( struct GRid * )realloc(cnstr_list, (num_cnstr + 1) *
                                                    sizeof( struct GRid ));
            cnstr_list[num_cnstr++] = list[i];
        }
    }

    /*
     * If no constraints acting on the part
     */
    if( num_cnstr == 0 )
    {
	om_msg = OM_S_SUCCESS;
        goto ret_end;
    }

    /*
     * Get the basis of the part.
     */
    om_msg = om$send( msg = message EMinstance.EMgivebasis( &msg, &basis ),
                                targetid = my_id );
    if( !( om_msg & msg & 1 ))
    {
        verbose(printf("EMgivebasis failed\n"));
        goto ret_end;
    }

    if( basis == NULL_BASIS_ID )
    {
	/*
         * Update the basis of the part, in case of copy
         */
        om_msg = om$send( msg = message EMinstance.EMupdatebasis ( &msg ),
                            targetid = my_id );

        if( !(om_msg & msg & 1 ) )
        {
            verbose(printf("updatebasis failed??\n"));
            goto ret_end;
        }
        om_msg = om$send( msg = message EMinstance.EMgivebasis( &msg, &basis ),
                                targetid = my_id );
    }

    switch( basis )
    {
        case GROUND_ONE_CONSTR:
	case NULL_BASIS_ID:
            goto ret_end;

        case MATE_ONE_CONSTR:
        case ALIGN_ONE_CONSTR:
            om_msg = Prep_one_constr( cnstr_list, num_cnstr, (int)basis, matrix );
            break;

        case MATE_MATE_PERP: 
        case MATE_MATE_ANG:  
        case MATE_ALIGN_PERP:
        case MATE_ALIGN_PAR: 
        case ALIGN_ALIGN_PAR:
        case ALIGN_ALIGN_PERP:
        case MATE_ALIGN_ANG:	
        case ALIGN_ALIGN_ANG:	
	    om_msg = Prep_two_constr( cnstr_list, num_cnstr, (int)basis, matrix );
            break;

        case MATE_MATE_MATE_PERP_PERP_PERP:
        case MATE_MATE_MATE_PERP_PERP_ANG:
        case MATE_MATE_MATE_PERP_ANG_ANG:
        case MATE_MATE_MATE_ANG_ANG_ANG:
        case MATE_MATE_ALIGN_PERP_PERP_PAR:
        case MATE_ALIGN_ALIGN_PAR_PAR_PAR:
            om_msg = Prep_three_constr( cnstr_list, num_cnstr, (int)basis, matrix );
            break;
        default:
            verbose(printf("Unknown basis\n"));
            om_msg = OM_E_ABORT;
            break;
    }

    /*
     * Process the return codes from math
     */
    ret = EMproc_math_error( om_msg, buffer );
    if( !ret )
    {
        UI_status( buffer );
        om_msg = OM_E_ABORT ;
    }

ret_end:
    if((rootlst == NULL) && (list))     /* Memory locally allocated to list */
        free( list );

    if( cnstr_list )
        free( cnstr_list );

    return( om_msg );
}

Prep_one_constr( roots, cnt, type, xform_mat )
struct GRid *roots;
int cnt, type;
IGRmatrix xform_mat;
{
int om_msg, i;
long msg;
struct GRid ft_ids[2];
struct GRmd_env envs[2];
ORIENT_INFO or_info[2];
IGRuint attrs = 0;


    if( cnt != 1 )
    {
        verbose(printf("Illegal one_constr basis\n"));
        return( 0 );
    }

    om_msg = om$send( msg = message EMconstr.EMget_ftrs_with_env( &msg,
                                                                  ft_ids,    
                                                                  envs ),
                                targetid = roots[0].objid,
                                targetos = roots[0].osnum,
                                senderid = roots[0].objid );
    if( !(om_msg & msg & 1 ))
    {
        verbose(printf("getftrswithenv failed\n"));
        return( 0 );
    }
    asm$get_constraint_attrs(msg   = &msg,
		         id    = &roots[0],
			 attrs = &attrs);

    if( type == MATE_ONE_CONSTR )
    {
        for( i = 0; i < 2; i ++ )
            get_plane_info( &ft_ids[i], &envs[i], (char *)&or_info[i], OINFO );

        if( attrs & EM_MATE_ALIGNED )
	   for(i = 0 ; i < 3; i++)
	       or_info[1].surf_normal[i] *= -1 ;

        EMoffset_matepoint( &roots[0], or_info[0].surf_point, 
                                                or_info[0].surf_normal );

        EMproj_surfvect( or_info[0].surf_point, or_info[0].surf_normal,
			 or_info[1].surf_rot_vector, 
			 or_info[0].surf_rot_vector );

        om_msg = mate( or_info[1], or_info[0], xform_mat );
    }
    else if ( type == ALIGN_ONE_CONSTR )
    {
	for( i = 0; i < 2; i ++ )
            get_axis_info( &ft_ids[i], &envs[i], &or_info[i], i, OINFO );

	if( attrs & EM_ALIGN_REVERSE )
        {
	   for(i = 0 ; i < 3; i++)
	       or_info[1].surf_normal[i] *= -1 ;
	}			 

        om_msg = align( or_info[1], or_info[0], xform_mat );
    }

    return( om_msg );
}

Prep_two_constr( roots, cnt, type, xform_mat )
struct GRid *roots;
int cnt, type;
IGRmatrix xform_mat;
{
int om_msg, i, k;
int type1, type2, constr_order;
long msg;
struct GRid ft_ids1[2], ft_ids2[2];
struct GRmd_env envs1[2], envs2[2];
SURF_INFO sur_info[4];
AXIS_INFO axi_info[4];
ORIENT_INFO or_info[2];
IGRuint attrs[2];

    if( cnt != 2 )
    {
        verbose(printf("Illegal two_constr basis\n"));
        return( 0 );
    }

    om_msg = om$send( msg = message EMconstr.EMget_ftrs_with_env( &msg,
                                                                  ft_ids1,    
                                                                  envs1 ),
                                targetid = roots[0].objid,
                                targetos = roots[0].osnum,
                                senderid = roots[0].objid );

    if( !(om_msg & msg & 1 ))
    {
        verbose(printf("getftrswithenv failed\n"));
        return( 0 );
    }

    om_msg = om$send( msg = message EMconstr.EMget_ftrs_with_env( &msg,
                                                                  ft_ids2,    
                                                                  envs2 ),
                                targetid = roots[1].objid,
                                targetos = roots[1].osnum,
                                senderid = roots[1].objid );

    if( !(om_msg & msg & 1 ))
    {
        verbose(printf("getftrswithenv2 failed\n"));
        return( 0 );
    }

    for( i = 0; i < 2; i++ )
    {
        attrs[i] = 0;
    	asm$get_constraint_attrs(msg   = &msg,
	                         id    = &roots[i],
		             	 attrs = &attrs[i]);
    }

    constr_order = 1;

    switch( type )
    {
        case MATE_MATE_PERP: 
        case MATE_MATE_ANG:  
            /*
             * Get the orient info for each of the four features participating
             * in the constraints, and send to math. Notice that the features
             * of part two (to be xformed) are the first arguments to math.
             */
            get_plane_info(&ft_ids1[1], &envs1[1], (char *)&sur_info[0], SINFO);
            get_plane_info(&ft_ids2[1], &envs2[1], (char *)&sur_info[1], SINFO);
            get_plane_info(&ft_ids1[0], &envs1[0], (char *)&sur_info[2], SINFO);
            get_plane_info(&ft_ids2[0], &envs2[0], (char *)&sur_info[3], SINFO);

            /*
             * Check if the mates are special
             */
            for( k = 0; k < 2 ; k ++ )
                if( attrs[k] & EM_MATE_ALIGNED )
                    for(i = 0 ; i < 3; i++)
                        sur_info[k].surf_normal[i] *= -1 ;

            EMoffset_matepoint( &roots[0], sur_info[2].surf_point, 
                                                sur_info[2].surf_normal );
            EMoffset_matepoint( &roots[1], sur_info[3].surf_point, 
                                                sur_info[3].surf_normal );

            if( type == MATE_MATE_PERP )
                om_msg = mate_mate_ortho(sur_info[0],sur_info[1],sur_info[2],
                                            sur_info[3], xform_mat);
            else
                om_msg = mate_mate_acute(sur_info[0],sur_info[1],sur_info[2],
                                            sur_info[3], xform_mat);
            break;

        case ALIGN_ALIGN_PAR:
        case ALIGN_ALIGN_PERP:
        case ALIGN_ALIGN_ANG:	
            /*
             * Get the axis info for each of the four features participating
             * in the constraints, and send to math.
             */
            get_axis_info(&ft_ids1[1], &envs1[1], (char *)&axi_info[0], 1, AINFO);
            get_axis_info(&ft_ids2[1], &envs2[1], (char *)&axi_info[1], 1, AINFO);

            /*
             * Check if the aligns are reversed 
             */
            for( k = 0; k < 2; k++ )
                if( attrs[k] & EM_ALIGN_REVERSE )
                    for(i = 0 ; i < 3; i++)
                        axi_info[k].axis_direction[i] *= -1 ;

            get_axis_info(&ft_ids1[0], &envs1[0], (char *)&axi_info[2], 0, AINFO);
            get_axis_info(&ft_ids2[0], &envs2[0], (char *)&axi_info[3], 0, AINFO);

            if( type == ALIGN_ALIGN_PAR )
            {
                /* Done for explode/unexplode aligns - 17/01/94 */
                EMoffset_matepoint( &roots[0], axi_info[2].axis_point,
                                               axi_info[2].axis_direction );
                EMoffset_matepoint( &roots[1], axi_info[3].axis_point,
                                               axi_info[3].axis_direction );

                om_msg = align_align_parallel( axi_info[0], axi_info[1],
                            axi_info[2], axi_info[3], constr_order, xform_mat);
            }
            else if( type == ALIGN_ALIGN_PERP )
            {
                om_msg = align_align_ortho( axi_info[0], axi_info[1], 
                            axi_info[2], axi_info[3], constr_order, xform_mat);
            }
            else if( type == ALIGN_ALIGN_ANG)
            {
                om_msg = align_align_acute( axi_info[0], axi_info[1], 
                            axi_info[2], axi_info[3], constr_order, xform_mat);
            }
            break;

        case MATE_ALIGN_PERP:
        case MATE_ALIGN_PAR: 
        case MATE_ALIGN_ANG:	
            EMgetconstrtype( roots[0], &type1 );
            EMgetconstrtype( roots[1], &type2 );


            if( type == MATE_ALIGN_PERP || type == MATE_ALIGN_ANG )
            {
                if( type1 == MATE && type2 == ALIGN )
                {
                    get_plane_info(&ft_ids1[1], &envs1[1], (char *)&sur_info[0],
                                                                        SINFO);
                    get_plane_info(&ft_ids1[0], &envs1[0], (char *)&sur_info[1],
                                                                        SINFO);
                    /*
                     * Check if the mate is special
                     */
                    if( attrs[0] & EM_MATE_ALIGNED )
	                    for(i = 0; i < 3; i++)
	                        sur_info[0].surf_normal[i] *= -1;

                    EMoffset_matepoint( &roots[0], sur_info[1].surf_point, 
                                                    sur_info[1].surf_normal );

                    get_axis_info (&ft_ids2[1], &envs2[1], (char *)&axi_info[0],
                                                                      0, AINFO);
                    get_axis_info (&ft_ids2[0], &envs2[0], (char *)&axi_info[1],
                                                                      0, AINFO);
                    /*
                     * Check if the align is reversed 
                     */
                    if( attrs[1] & EM_ALIGN_REVERSE )
	                    for(i = 0 ; i < 3; i++)
	                        axi_info[0].axis_direction[i] *= -1 ;

                    /* Done for explode - 17/01/94 */
                    EMoffset_matepoint( &roots[1], axi_info[1].axis_point, 
                                                    axi_info[1].axis_direction);
                }
                else if( type1 == ALIGN && type2 == MATE )
                {
		    constr_order = 2;

                    get_plane_info(&ft_ids2[1], &envs2[1], (char *)&sur_info[0],
                                                                        SINFO);
                    get_plane_info(&ft_ids2[0], &envs2[0], (char *)&sur_info[1],
                                                                        SINFO);
                    /*
                     * Check if the mate is special
                     */
                    if( attrs[1] & EM_MATE_ALIGNED )
	                    for(i = 0; i < 3; i++)
	                        sur_info[0].surf_normal[i] *= -1;

                    EMoffset_matepoint( &roots[1], sur_info[1].surf_point, 
                                                    sur_info[1].surf_normal );
                    get_axis_info (&ft_ids1[1], &envs1[1], (char *)&axi_info[0],
                                                                      0, AINFO);
                    get_axis_info (&ft_ids1[0], &envs1[0], (char *)&axi_info[1],
                                                                      0, AINFO);
                    /*
                     * Check if the align is reversed 
                     */
                    if( attrs[0] & EM_ALIGN_REVERSE )
                        for(i = 0 ; i < 3; i++)
                            axi_info[0].axis_direction[i] *= -1 ;

                    /* Done for explode - 17/01/94 */
                    EMoffset_matepoint( &roots[0], axi_info[1].axis_point, 
                                                    axi_info[1].axis_direction);
                }
                if( type == MATE_ALIGN_PERP )
                {
                    om_msg = mate_align_ortho( axi_info[0], sur_info[0], 
                                               axi_info[1], sur_info[1], 
                                                constr_order, xform_mat );
                }
                else if( type == MATE_ALIGN_ANG )
                {
                    om_msg = mate_align_acute( axi_info[0], sur_info[0], 
                                               axi_info[1], sur_info[1], 
                                               xform_mat );
                }
            }
            else if( type == MATE_ALIGN_PAR )
            {
		/*
		 * Take the intersection of Align axis with Mating plane as 
                 * surf_point and plane normal as surf_normal.
		 */
                if( type1 == ALIGN )
                {
                    get_plane_info(&ft_ids2[1], &envs2[1], (char *)&or_info[0],
                                                                       OINFO);
                    get_plane_info(&ft_ids2[0], &envs2[0], (char *)&or_info[1],
                                                                       OINFO);
    		    get_axispln_xpt(&ft_ids1[1],&envs1[1],&ft_ids2[1],&envs2[1],
                                                     or_info[0].surf_point);
    		    get_axispln_xpt(&ft_ids1[0],&envs1[0],&ft_ids2[0],&envs2[0],
                                                     or_info[1].surf_point);
                    /*
                     * Check if the mate is special
                     */
                    if( attrs[1] & EM_MATE_ALIGNED )
	                    for(i = 0; i < 3; i++)
	                        or_info[0].surf_normal[i] *= -1;

                    EMoffset_matepoint( &roots[1], or_info[1].surf_point, 
                                                    or_info[1].surf_normal );
                }
                else
                {
                    get_plane_info(&ft_ids1[1], &envs1[1], (char *)&or_info[0],
                                                                       OINFO);
                    get_plane_info(&ft_ids1[0], &envs1[0], (char *)&or_info[1],
                                                                       OINFO);
    		    get_axispln_xpt(&ft_ids2[1],&envs2[1],&ft_ids1[1],&envs1[1],
                                                    or_info[0].surf_point);
    		    get_axispln_xpt(&ft_ids2[0],&envs2[0],&ft_ids1[0],&envs1[0],
                                                    or_info[1].surf_point);
                    /*
                     * Check if the mate is special
                     */
                    if( attrs[0] & EM_MATE_ALIGNED )
	                    for(i = 0; i < 3; i++)
	                        or_info[0].surf_normal[i] *= -1;

                    EMoffset_matepoint( &roots[0], or_info[1].surf_point, 
                                                    or_info[1].surf_normal );
                }
                /* Reorient the plane vector of constraining part */
                EMproj_surfvect( or_info[1].surf_point, or_info[1].surf_normal,
				 or_info[0].surf_rot_vector, 
				 or_info[1].surf_rot_vector );
		/*
		 * Reverse the direction of one of the surface normals 
		 */
		for( i = 0; i < 3; i++ )
		    or_info[1].surf_normal[i] *= -1;

                om_msg = mate_align_parallel( or_info[0], or_info[1], 
                                                xform_mat );
            }
            break;
    }

    return( om_msg );
}

Prep_three_constr( roots, cnt, type, xform_mat )
struct GRid *roots;
int cnt, type;
IGRmatrix xform_mat;
{
int om_msg, i, indx, plnid, ret, k;
int type1, type2, type3, constr_order[2];
long msg;
struct GRid axis_ids[4], pln_ids[6], tmpgrid;
struct GRmd_env axis_envs[4], pln_envs[6];
SURF_INFO sur_info[6];
AXIS_INFO axi_info[4];
IGRuint   attrs[3];

    if( cnt != 3 )
    {
        verbose(printf("Illegal three_constr basis\n"));
        return( 0 );
    }


    EMgetconstrtype( roots[0], &type1 );
    EMgetconstrtype( roots[1], &type2 );
    EMgetconstrtype( roots[2], &type3 );
    for( i = 0; i < 3; i++ )
    {
        om_msg = om$send( msg = message EMconstr.EMget_ftrs_with_env( 
                                                                &msg,
                                                                &pln_ids[i*2],
                                                                &pln_envs[i*2]),
                                targetid = roots[i].objid,
                                targetos = roots[i].osnum,
                                senderid = roots[i].objid );

        if( !(om_msg & msg & 1 ))
        {
            verbose(printf("getftrswithenv for %d failed\n",i));
            return( 0 );
        }
    }

    switch( type )
    {
        case MATE_MATE_MATE_PERP_PERP_PERP:
        case MATE_MATE_MATE_PERP_PERP_ANG:
        case MATE_MATE_MATE_PERP_ANG_ANG:
        case MATE_MATE_MATE_ANG_ANG_ANG:
            for( i = 0; i < 3; i++ )
            {
                attrs[i] = 0;
    	        asm$get_constraint_attrs(msg   = &msg,
	                                 id    = &roots[i],
		                 	 attrs = &attrs[i]);
            }

            for( i = 0; i < 6; i++ )
                get_plane_info(&pln_ids[i], &pln_envs[i], (char *)&sur_info[i],
                                                                     SINFO);


            for( i = 0; i < 3; i++ )
            {
                /*
                 * Check if the mate is special
                 */
                if( attrs[i] & EM_MATE_ALIGNED )
                    for(k = 0; k < 3; k++)
                        sur_info[i*2+1].surf_normal[k] *= -1;

                EMoffset_matepoint( &roots[i], sur_info[i*2+1].surf_point, 
                                               sur_info[i*2+1].surf_normal );

            }

            om_msg = mate_mate_mate( sur_info[1], sur_info[3], sur_info[5], 
                            sur_info[0], sur_info[2], sur_info[4], xform_mat );
            break;

        case MATE_MATE_ALIGN_PERP_PERP_PAR:

            /* see which one is align */
            indx = ( type1 == ALIGN ) ? 0 : (type2 == ALIGN) ? 1 : 2;
            axis_ids[0] = pln_ids[indx*2];
            axis_ids[1] = pln_ids[indx*2+1];
            axis_envs[0] = pln_envs[indx*2];
            axis_envs[1] = pln_envs[indx*2+1];
	    constr_order[0] = 1; constr_order[1] = 2;
            if( indx != 2 ) /* should be 0 or 1 */
            {
                /*
                 * Rearrange the ids such that the first 4 are planeids 
                 */
                pln_ids[indx*2] = pln_ids[4];
                pln_envs[indx*2] = pln_envs[4];
                pln_ids[indx*2+1] = pln_ids[5];
                pln_envs[indx*2+1] = pln_envs[5];
                /*
                 * Rearrange the roots such that the first two are mates.
                 */
                tmpgrid = roots[2];
                roots[2] = roots[indx];
                roots[indx] = tmpgrid;
                                
                constr_order[indx] = 3;
            }
            for( i = 0; i < 3; i++ )
            {
                attrs[i] = 0;
    	        asm$get_constraint_attrs(msg   = &msg,
	                                 id    = &roots[i],
		                 	 attrs = &attrs[i]);
            }

            /*
             * Set up the plane info for all the four mating planes 
             */
	    for( i = 0; i < 4; i++ )
                get_plane_info(&pln_ids[i], &pln_envs[i], (char *)&sur_info[i],
                                                                       SINFO);
	    ret = get_axispln_xpt(&axis_ids[1],&axis_envs[1],&pln_ids[1],
                                  &pln_envs[1], sur_info[1].surf_point);
            if( ret <= 0 ) /* No intersection */
            {
    	        ret = get_axispln_xpt(&axis_ids[1],&axis_envs[1],&pln_ids[3],
                                  &pln_envs[3], sur_info[3].surf_point);
                if( ret <= 0 ) /* No intersection */
                {
                    verbose(printf("Illegal basis: Align not parallel to atleast one mate\n"));
                    return(0);
                }
                plnid = 3;
            }
            else plnid = 1;

            /*
             * Take the intersection point as the point on the align axis
             */
            get_axis_info (&axis_ids[1], &axis_envs[1],(char *)&axi_info[1],
                                                                      0, AINFO);
	    for( i = 0; i < 3; i++ )
                axi_info[1].axis_point[i] = sur_info[plnid].surf_point[i];

            /*
             * Check if the align is reversed 
             */
            if( attrs[2] & EM_ALIGN_REVERSE )
                for(i = 0 ; i < 3; i++)
                    axi_info[1].axis_direction[i] *= -1 ;

	    ret = get_axispln_xpt(&axis_ids[0],&axis_envs[0],&pln_ids[0],
                                  &pln_envs[0], sur_info[0].surf_point);
            if( ret <= 0 ) /* No intersection */
            {
    	        ret = get_axispln_xpt(&axis_ids[0],&axis_envs[0],&pln_ids[2],
                                  &pln_envs[2], sur_info[2].surf_point);
                if( ret <= 0 ) /* No intersection */
                {
                    verbose(printf("Illegal basis2: Align not parallel to atleast one mate\n"));
                    return(0);
                }
                plnid = 2;      
            }
            else plnid = 0;

            /*
             * Check if the mates are special
             */
            for( i = 0; i < 2; i ++ )
            {
                if( attrs[i] & EM_MATE_ALIGNED )
                    for(k = 0; k < 3; k++)
                        sur_info[i*2+1].surf_normal[k] *= -1;
            }

            EMoffset_matepoint( &roots[0], sur_info[0].surf_point, 
                                                    sur_info[0].surf_normal );
            EMoffset_matepoint( &roots[1], sur_info[2].surf_point, 
                                                    sur_info[2].surf_normal );
            /*
             * Take the intersection point as the point on the align axis
             */
            get_axis_info (&axis_ids[0], &axis_envs[0],(char *)&axi_info[0],
                                                                      0, AINFO);
	    for( i = 0; i < 3; i++ )
                axi_info[0].axis_point[i] = sur_info[plnid].surf_point[i];

            om_msg = mate_mate_align( sur_info[1], sur_info[3], axi_info[1],
                                      sur_info[0], sur_info[2], axi_info[0],
                                      constr_order, xform_mat);
            break;

        case MATE_ALIGN_ALIGN_PAR_PAR_PAR:
            /* see which one is mate */
            indx = ( type1 == MATE ) ? 0 : (type2 == MATE) ? 1 : 2;
            /*
             * NOTE: axis_ids in this case will be MATING PLANE ids 
             */
            axis_ids[0] = pln_ids[indx*2];
            axis_ids[1] = pln_ids[indx*2+1];
            axis_envs[0] = pln_envs[indx*2];
            axis_envs[1] = pln_envs[indx*2+1];
	    constr_order[0] = 1;
            if( indx != 2 ) /* should be 0 or 1 */
            {
                /*
                 * Rearrange the ids such that the first 4 are align axis ids
                 */
                pln_ids[indx*2] = pln_ids[4];
                pln_envs[indx*2] = pln_envs[4];
                pln_ids[indx*2+1] = pln_ids[5];
                pln_envs[indx*2+1] = pln_envs[5];
                /*
                 * Rearrange the roots such that the first two are aligns.
                 */
                tmpgrid = roots[2];
                roots[2] = roots[indx];
                roots[indx] = tmpgrid;
            }
            for( i = 0; i < 3; i++ )
            {
                attrs[i] = 0;
    	        asm$get_constraint_attrs(msg   = &msg,
	                                 id    = &roots[i],
		                 	 attrs = &attrs[i]);
            }
            /*
             * Set up the plane info for the two mating planes 
             */
	    for( i = 0; i < 2; i++ )
                get_plane_info(&axis_ids[i],&axis_envs[i],(char *)&sur_info[i],
                                                                       SINFO);
            /*
             * Check if the mate is special
             */
            if( attrs[2] & EM_MATE_ALIGNED )
                for(i = 0; i < 3; i++)
                    sur_info[1].surf_normal[i] *= -1;

            EMoffset_matepoint( &roots[2], sur_info[0].surf_point, 
                                                    sur_info[0].surf_normal );
            for( i = 0; i < 4; i++ )
                get_axis_info (&pln_ids[i], &pln_envs[i],(char *)&axi_info[i],
                                                                      0, AINFO);
            /*
             * Check if the aligns are reversed 
             */
            for( k = 0; k < 2; k++ )
            {
                if( attrs[k] & EM_ALIGN_REVERSE )
                    for(i = 0 ; i < 3; i++)
                        axi_info[k*2+1].axis_direction[i] *= -1 ;
            }
	    get_axispln_xpt(&pln_ids[1],&pln_envs[1],&axis_ids[1],
                                  &axis_envs[1], axi_info[1].axis_point);
	    get_axispln_xpt(&pln_ids[3],&pln_envs[3],&axis_ids[1],
                                  &axis_envs[1], axi_info[3].axis_point);
	    get_axispln_xpt(&pln_ids[0],&pln_envs[0],&axis_ids[0],
                                  &axis_envs[0], axi_info[0].axis_point);
	    get_axispln_xpt(&pln_ids[2],&pln_envs[2],&axis_ids[0],
                                  &axis_envs[0], axi_info[2].axis_point);

            om_msg = mate_align_align( sur_info[1], axi_info[1], axi_info[3],
                                       sur_info[0], axi_info[0], axi_info[2],
                                       constr_order[0], xform_mat );
            break;
    }
    return( om_msg );	
}


/*
 * Inorder to preserve the orientation of the incident part after mate,
 * take the proj. of the u-vector of incident part's plane onto the
 * the constraining part's plane, and take this projected vector as
 * the surf_rot_vector on the constraining part.
 */

EMproj_surfvect( spt, snorm, insf_vect, outsf_vect )
IGRpoint spt;
IGRvector snorm, insf_vect, outsf_vect;
{
long msg;
int  i;
IGRpoint origin, projpts[2];

    origin[0] = origin[1] = origin[2] = 0.0;
    BSproj1( &msg, origin, snorm, spt, projpts[0] );
    BSproj1( &msg, insf_vect, snorm, spt, projpts[1] );
    for( i = 0; i < 3; i++ )
        outsf_vect[i] = ( projpts[1][i] - projpts[0][i] );
    BSnorvec( &msg, outsf_vect );

    return( 1 );
}

/* 
 * Offset value has to be considered. Translate the surf_point
 * along the surf_normal by the "offset" distance.
 * The offset is subtracted from the 'point' since the normal is 
 * always into the plane.
 */

EMoffset_matepoint( cnstrid, point, normal )
struct GRid *cnstrid;
IGRpoint point;
IGRvector normal;
{
int om_msg, i;
long msg;
double offset;

    om_msg = om$send( msg = message EMconstr.EMget_offset(&msg,&offset,NULL),
                                targetid = cnstrid->objid,
                                targetos = cnstrid->osnum,
                                senderid = cnstrid->objid );

    if( !(om_msg & msg & 1 ))
    {
        verbose(printf("EMgetoffset failed\n"));
        return( 0 );
    }

/*    if( offset > 0. || offset < 0. )*/
       for( i = 0; i < 3; i++ )
           point[i] -= offset * normal[i];

   return( 1 );
}

get_axispln_xpt( axisid, aenv, pln, penv, xpoint )
struct GRid *axisid, *pln;
struct GRmd_env *aenv, *penv;
IGRpoint xpoint;
{
int  /*numint, i,*/ type;
IGRlong msg;
IGRpoint axis[2], surfpoint/*, int_pts[2]*/;
IGRvector surfvects[2], surfnormal;

    if( !EMgetaxis( axisid, aenv, axis, &type ) )
        return( 0 );

    if( !EMgetsurf( pln, penv, surfpoint, surfvects, surfnormal ))
        return(0);

/*
    numint = 0;
    BSbdlnplint( axis, surfpoint, surfnormal, &numint, int_pts, &msg);

    if( msg != 0 )
    {
        verbose(printf("axis-plane xsection failed\n"));
        return(-1);
    }
    if( numint == 0 )
        return( 0 );

    for( i = 0; i<3; i++ )
        xpoint[i] = int_pts[0][i];
*/
    BSproj1( &msg, axis[0], surfnormal, surfpoint, xpoint );

    return( 1 );
}

get_plane_info( fid, fenv, info, dtype)
struct GRid *fid;
struct GRmd_env *fenv;
char *info;
int dtype;
{
int i;
IGRpoint spoint;
IGRvector snormal, svects[2];

    /*
     * Get the surface point ( 0.5,0.5 ) and the u,v surf_vectors and 
     * the surface normal.
     */

    if( !EMgetsurf( fid, fenv, spoint, svects, snormal ) )
        return( 0 );

    if( dtype == OINFO )
    {
    ORIENT_INFO *oinfo;
    
        oinfo = (ORIENT_INFO *)info;
        for( i = 0; i < 3; i++ )
	{
            oinfo->surf_point[i] = spoint[i];
            oinfo->surf_normal[i] = snormal[i];
            oinfo->surf_rot_vector[i] = svects[0][i];
        }
    }
    else if( dtype == SINFO )
    {
    SURF_INFO *sinfo;

        sinfo = (SURF_INFO *)info;
        for( i = 0; i < 3; i++ )
	{
            sinfo->surf_point[i] = spoint[i];
            sinfo->surf_normal[i] = snormal[i];
        }
    }

    return( 1 );
}

/*
 * This routine gets the surface point at ( 0.5, 0.5 ) and the u,v vectors on
 * the surface and also the outward normal to the surface.
 */
EMgetsurf( surfid, surfenv, surfpoint, surfvects, surfnormal )
struct GRid *surfid;
struct GRmd_env *surfenv;
IGRpoint surfpoint;
IGRvector surfvects[2];
IGRvector surfnormal;
{
  int i, om_msg;
  IGRlong msg;
  IGRdouble disp_fac, pts[12];
  IGRdouble parms[2];
  struct IGRbsp_surface *surf;
  OMuword classid;

    /*
     * Check if the classid is EMSplane, otherwise check if it is EMAdatpln.
     */
    om$get_classid( objid = surfid->objid,
                    osnum = surfid->osnum,
                    p_classid = &classid );

    if (om$is_ancestry_valid (subclassid = classid,
             superclassid = OPP_EMSplane_class_id) == OM_S_SUCCESS)
    {
        om_msg = om$send( msg = message GRvg.GRgenabsg( &msg,
                                                    &surfenv->md_env.matrix_type,
                                                    surfenv->md_env.matrix, 
                                                    (IGRchar **)&surf),
                            senderid = surfid->objid,
                            targetid = surfid->objid,
                            targetos = surfid->osnum );

        if( !(om_msg & msg & 1 ))
        {
            verbose(printf("genabsg failed\n"));
            return( 0 );
        }

        disp_fac = 1.0;
        parms[0] = 0.5;
        parms[1] = 0.5;  
    
        BSsfarrevnt(surf, 1, &parms[0], 1, &parms[1], disp_fac, NULL, pts,&msg);

        for( i = 0; i < 3; i ++ )
        {
            surfpoint[i] = pts[i];
            surfvects[0][i] = pts[i+3] - pts[i];
            surfvects[1][i] = pts[i+6] - pts[i];
            if( !surf->pos_orient )
                surfnormal[i] = -(pts[i+9] - pts[i]);
            else            
                surfnormal[i] = pts[i+9] - pts[i];
        }
        return( 1 );
    }
    else if (om$is_ancestry_valid (subclassid = classid,
             superclassid = OPP_EMAdatpln_class_id) == OM_S_SUCCESS)
    {
    IGRpoint midpt;
    IGRvector vects[2], normal;

        if( !EMgetdatpln_info( surfid, surfenv, midpt, vects, normal ))
            return( 0 );

        for( i = 0; i < 3; i ++ )
        {
            surfpoint[i] = midpt[i];
            surfvects[0][i] = vects[0][i]; /* x-axis */
            surfvects[1][i] = vects[1][i]; /* y-axis */
            surfnormal[i] = normal[i];
        }

        return( 1 );
    }
    verbose(printf("Illegal geometry for mating\n"));
    return ( 0 );
}
 
get_axis_info( fid, fenv, info, flg, dtype )
struct GRid *fid;
struct GRmd_env *fenv;
char *info;
int flg, dtype;
{
int i, type;
long msg;
IGRpoint axis[2];
IGRdouble dist;
IGRpoint spoint;
IGRvector snormal;

    if( !EMgetaxis( fid, fenv, axis, &type ))
        return( 0 );

    if( type == CYL_AXIS )
    {
        /*
         * Return the arrowhead or arrowtail of the axis depending on the flg.
         * as the surf_point.
         */
        for( i = 0; i < 3; i++ )
            if( !flg )
	        spoint[i] = axis[1][i];
            else
                spoint[i] = axis[0][i];
    }
    else if( type == PLANAR )
        for( i = 0; i < 3; i++ )
	        spoint[i] = axis[0][i];
    else if( type == EDGE )
        for( i = 0; i < 3; i++ )
	        spoint[i] = axis[0][i];
    /*
     * The direction vector of the axis as the surf_normal.
     */
    dist = BSdistptpt( &msg, axis[0], axis[1] );
    for( i = 0; i < 3; i++ )
	snormal[i] = (axis[1][i] - axis[0][i])/dist;
 
    if( dtype == OINFO )
    {
    ORIENT_INFO *oinfo;
    
        oinfo = (ORIENT_INFO *)info;
        for( i = 0; i < 3; i ++ )
        {
            oinfo->surf_point[i] = spoint[i];
            oinfo->surf_normal[i] = snormal[i];
        }
        /*
         * Get the orthogonal vector to the surf_normal as surf_rot_vector
         */

        BSorthovec( &msg, oinfo->surf_normal, oinfo->surf_rot_vector );
    }
    else if( dtype == AINFO )
    {
    AXIS_INFO *ainfo;

        ainfo = (AXIS_INFO *)info;
        for( i = 0; i < 3; i ++ )
        {
            ainfo->axis_point[i] = spoint[i];
            ainfo->axis_direction[i] = snormal[i];
        }
    }

    return( 1 );
}

/*
   This routine would check if the features are centerline or axis and if yes,
   checks if one axis is within the range of other and calculates the distance
   by which the second axis has to move inorder that the two axes are non-
   overlapping. It also computes the other info required ( orient/axis ) as per
   the dtype.

   NOTE: This routine handles one align only. ie., two feature ids/envs.


EMget_expld_axis( fid, fenv, info, dtype )
struct GRid *fid;
struct GRmd_env *fenv;
char *info;
int dtype;
{
    return( 1 );
}
*/

EMgetaxis( axisid, aenv, axis, type )
struct GRid *axisid;
struct GRmd_env *aenv;
IGRpoint axis[2];
int *type;
{
int om_msg, i;
IGRlong msg;
struct EMSgeomdata geomdata;
OMuword classid;

    /*
     * Check if the classid is EMSparamvc, or EMSplane or EMAdatpln or EMSrevol
     * or GR3dlineseg ( ?? ) 
     */
    om$get_classid( objid = axisid->objid,
                    osnum = axisid->osnum,
                    p_classid = &classid );

    if (om$is_ancestry_valid (subclassid = classid,
             superclassid = OPP_EMSparamvc_class_id) == OM_S_SUCCESS)
    {
        om_msg = om$send (msg = message EMSparameter.EMgetdimgeom (&msg, NULL,
             					&aenv->md_env.matrix_type,
						aenv->md_env.matrix,
						NULL, NULL, 
						&geomdata, NULL),
			 targetid = axisid->objid,
			 senderid = axisid->objid,
			 targetos = axisid->osnum );

        if( !(om_msg & msg & 1) )
        {
            verbose(printf("getdimgeom failed\n"));
            return(0);
        }
        /*
         * The geometry returned must be a line-segment.
         */
        if( geomdata.geomtype != GEOMDATA_LINE )
        {
            verbose(printf("Illegal align Axis vector\n"));
            return(0);
        }

        for( i = 0; i < 3; i++ )
        {
            axis[0][i] = geomdata.line.line_pt1[i];
            axis[1][i] = geomdata.line.line_pt2[i];
        }
	*type = CYL_AXIS;
        return( 1 );
    }
    else if (om$is_ancestry_valid (subclassid = classid,
             superclassid = OPP_EMAdatpln_class_id) == OM_S_SUCCESS)
    {
    IGRpoint midpt;
    IGRvector vects[2], normal;

        if( !EMgetdatpln_info( axisid, aenv, midpt, vects, normal ))
            return( 0 );
        /*
         * KLUDGE: This needs to change. Maybe take the points on the
         *         edge of the plane 
         */

        for( i = 0; i < 3; i ++ )
        {
            axis[0][i] = midpt[i];
            axis[1][i] = midpt[i] + normal[i];
        }
	*type = PLANAR;
	return(1);
    }
    else if (om$is_ancestry_valid (subclassid = classid,
             superclassid = OPP_EMSplane_class_id) == OM_S_SUCCESS)
    {
    IGRpoint midpt;
    IGRvector vects[2], normal;

        if( !EMgetsurf( axisid, aenv, midpt, vects, normal ))
            return( 0 );

        for( i = 0; i < 3; i ++ )
        {
	    /*
             * KLUDGE: This needs to change. Maybe take the points on the
             *         edge of the plane 
             */
            axis[0][i] = midpt[i];
            axis[1][i] = midpt[i] + normal[i];
        }
	*type = PLANAR;
	return(1);
    }
    else if (om$is_ancestry_valid (subclassid = classid,
             superclassid = OPP_GR3dlineseg_class_id) == OM_S_SUCCESS)
    {
    IGRdouble endpts[6];
    struct IGRpolyline polyline;
    int action;

        polyline.points = endpts;
        action = 1;      
        om_msg = om$send( msg = message GRlinear.GRgetpolyline(&msg,
                                                    &aenv->md_env.matrix_type,
                                                    aenv->md_env.matrix,
	                                            &action,
	                                            &polyline),
			 targetid = axisid->objid,
			 senderid = axisid->objid,
			 targetos = axisid->osnum );

        if( !(om_msg & msg & 1 ))
        {
           verbose(printf("grgetpolyline failed\n"));
           return(0);
        }

        for( i = 0; i < 3; i ++ )
        {
            axis[0][i] = endpts[i];        
            axis[1][i] = endpts[i+3];        
        }         
	*type = EDGE;   
        return(1);
    }
    else if (om$is_ancestry_valid (subclassid = classid,
             superclassid = OPP_EMSrevol_class_id) == OM_S_SUCCESS) 
    {
     IGRushort typ;
     struct EMsurface_params params;

	om_msg = om$send( msg = message EMSsurface.EMget_params( &msg,
								NULL,
								aenv,
								&typ,
								&params),
			 targetid = axisid->objid,
			 senderid = axisid->objid,
			 targetos = axisid->osnum );

        if( !(om_msg & msg & 1) )
        {
            verbose(printf("EMget_params failed\n"));
            return(0);
        }
	if( !EMgetcenterline( &params, typ, axis ))
	    return(0);

	*type = CYL_AXIS;
	return( 1 );
    }
    return ( 0 );
}

EMgetcenterline( params, type, cen_line )
struct EMsurface_params *params;
IGRushort type;
IGRpoint cen_line[2];
{
IGRdouble pts[6];
int i;

    switch( type )
    {
        case EMcylinder:
        case EMpcylinder:
        case EMelliptical_cylinder:
        case EMcone:
        case EMpcone:        
        case EMelliptical_cone:
            OM_BLOCK_MOVE( params, pts, 6 * sizeof( IGRdouble ));

            for( i = 0; i < 3; i++ )
            {
                cen_line[0][i] = pts[i];
                cen_line[1][i] = pts[i] + pts[i+3];
            }
            break;
        case EMproject:
            for( i = 0; i < 3; i++ )
            {
                cen_line[0][i] = params->params.project.axis_point0[i];
                cen_line[1][i] = params->params.project.axis_point1[i];    
            }
            break;
        case EMsphere:
        case EMellipsoid:
        case EMfreeform_surface:
        case EMtorus:
        case EMrevol:
            /*
             * KLUDGE: Not supporting these now.
             */
            verbose(printf("Illegal geometry\n"));
            return(0);
    }
    return(1);
}
EMgetdatpln_info( plnid, plnenv, midpt, axes, normal )
struct GRid *plnid;
struct GRmd_env *plnenv;
IGRpoint midpt;
IGRvector axes[2], normal;
{
int  om_msg, i, action;
IGRuint options, props;
long msg;
struct GRid linestr;
OM_S_CHANSELECT to_comp;
OMuword classid;
struct IGRpolyline polyline;
double orig[3], xaxis[3], yaxis[3], zaxis[3];

    /*
     * Get the direction of the x and y axes and the normal from the EMAdatpln
     * and the center from the graphic handle1( GR3dlinestr ).
     */
    options = 0; /* silence compiler */
    om_msg = om$send ( msg = message EMAdatpln.EMget_pln_info (&msg,
                                                            options,
                                                            plnenv,
                                                            xaxis,
                                                            yaxis,
                                                            zaxis,
                                                            orig,
                                                            &props),
                                    senderid = plnid->objid,
                                    targetid = plnid->objid,
                                    targetos = plnid->osnum);

    if( !(om_msg & msg & 1 ))
    {
        verbose(printf("EMget_pln_info failed\n"));
        return(0);
    }
    for( i = 0; i < 3; i++ )
    {
        axes[0][i] = xaxis[i];
        axes[1][i] = yaxis[i];        
        normal[i] = zaxis[i];                
    }
#ifdef DEBUG
    printf("xax[0]=%f xax[1]=%f xax[2]=%f\n",xaxis[0],xaxis[1],xaxis[2]);
    printf("yax[0]=%f yax[1]=%f yax[2]=%f\n",yaxis[0],yaxis[1],yaxis[2]);
    printf("zax[0]=%f zax[1]=%f zax[2]=%f\n",zaxis[0],zaxis[1],zaxis[2]);
#endif

    om$make_chanselect( channame = "GRcmpowner.to_components",
    			p_chanselect = &to_comp );

    om$get_objid_at_index ( osnum= plnid->osnum,
                               objid= plnid->objid,
                               p_chanselect=&to_comp,
                               index=0,
                               objidaddr=&linestr.objid,
                               osnumaddr=&linestr.osnum);

#ifdef DEBUG
printf("plnid = %d plnos = %d lineobj = %d lineos = %d\n",plnid->objid,
						plnid->osnum, linestr.objid,
						linestr.osnum);
#endif

    om$get_classid( objid = linestr.objid,
                    osnum = linestr.osnum,
                    p_classid = &classid );

    if (om$is_ancestry_valid (subclassid = classid,
             superclassid = OPP_GR3dlinestr_class_id) == OM_S_SUCCESS)
    {
        polyline.points = (double *)malloc( 3*5*sizeof(double));
        action = 1;      
        om_msg = om$send( msg = message GRlinear.GRgetpolyline(&msg,
                                                    &plnenv->md_env.matrix_type,
                                                    plnenv->md_env.matrix,
	                                            &action,
	                                            &polyline),
	                senderid = linestr.objid,
       	                targetid = linestr.objid,
       	                targetos = linestr.osnum);       	                

        if( !(om_msg & msg & 1 ))
        {
           verbose(printf("grgetpolyline failed\n"));
           return(0);
        }
#ifdef DEBUG
for(i=0;i<polyline.num_points;i++)
printf("pt[%d]=%f\n",i,polyline.points[i]);
#endif
        /*
         * Find the mid point of these set of points.
         */            
        for(i = 0; i < 3; i++)
            midpt[i] = (polyline.points[i] + polyline.points[i+6])/2.0;
    }      

    return( 1 );
}

/*
 * Debbugging routines
 */
print_input( string, info, type )
char *string;
char *info;
int type;
{
ORIENT_INFO *oinfo;
SURF_INFO *sinfo;
AXIS_INFO *ainfo;

    switch( type )
    {
        case OINFO:
            oinfo = (ORIENT_INFO *)info;
            break;
        case SINFO:
            sinfo = (SURF_INFO *)info;
            break;                                             
        case AINFO:
            ainfo = (AXIS_INFO *)info;
            break;                                             
    }    	  
    return(1);
}


end implementation EMinstance;
