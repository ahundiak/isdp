/* ###################   APOGEE COMPILED   ################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:       EMSsubbs
     METHOD NAME:       EMbstobz

     Abstract:  This method extracts bezier patches from a 
                given B-spline patch. The method returns a 
                list of objids corresponding to the bezier
                patches (nondegenerate) being extracted.
                        

-----
%SC%    

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   ------------------------------------
*construct_list   GRvg_construct    construction list

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
**addr_pch_objid   GRobjid      pointer to an array of bezier
                                 patches' objids.
                                
*nondeg_pch        IGRint       no. of nondegenerate bezier patches
                                 extracted.
                                
        *msg       IGRlong      return code
                                 - MSSUCC      successful
                                 - MSNOMEM     memory allocation failed
                                 - MSFAIL      any other failure
-----
%MD%

     MODULES AND METHODS INVOKED:
     Modules:
                GRgetabsg
                OM_stack_alloc
                OM_stack_dealloc
                BSallocsf
                BSfreesf
                BSpchtobz
                malloc
                OM_convert_OS_number_to_name
                OM_construct_object_by_name
        
     Methods:
                GRclipto

-----
%RL%

     RELATIONS REFERENCED:
-----
%NB%

     NOTES:

-----
%CH%

     CHANGE HISTORY:
                
                RC : 9/25/86   creation date
               rlw : 01/05/88 : removed print statements
               rlw : 01/20/89 : Modified such that input construct list is
                                not changed.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------



----*/
/*EH*/

class implementation EMSsubbs;

#include "EMS.h"

# ifndef msdef_include
# include "msdef.h" /* MS message codes */
# endif

/*#include "grdef.h"*/

/* grutildef.h replacement */

# ifndef griodef_include
# include "griodef.h"
# endif

/* end of grutildef.h replacement */

/* EX_def.h replacement */

# ifndef exdef_include
# include "exdef.h"
# endif

/* end of EX_def.h replacement */

/* EX_struct.h replacement */

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef OMlimits_include
# include "OMlimits.h"
# endif

# ifndef OMminimum_include
# include "OMminimum.h"
# endif

# ifndef ex_include
# include "ex.h"
# endif

# ifndef OM_D_MINIMUM
# include "OMminimum.h"     /* for gocmacros.h  */
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"     /* for gocmacros.h  */
# endif

# ifndef gocmacros_include
# include "gocmacros.h"     /* GRgetabsg macro  */
# endif

/* end of EX_struct.h replacement */
#include "madef.h"
#include "OMerrordef.h"
#include "OMstackalloc.h"
#include "bsdefs.h"
#include "bserr.h"
#include "emsdef.h"

method EMbstobz (struct GRvg_construct *construct_list;
                 GRobjid **addr_pch_objid;
                 IGRint  *nondeg_pch;
                 IGRlong *msg)
{
        IGRchar  classname[GRNAME_SIZE];
        IGRchar  osname[OM_K_MAXOSNAME_LEN];
        IGRchar  *cache_ptr;     

        IGRint   new_objts_constructed = 0;
        
        IGRshort u_order;
        IGRshort v_order;
        IGRlong  u_num_poles, v_num_poles;
        IGRlong  msg1;                  /* return code */
        IGRlong  i, j, k;                       /* loop index  */
        IGRlong  OMmsg;
        IGRint   n_u_spans;             /* no. of spans in u direction */
        IGRint   n_v_spans;             /* no. of spans in v direction */
        IGRint   n_bz_patches;          /* no. of bezier patches */
                                        /* (includeing degenerate ones)*/
        IGRint   u_num_bez;
        IGRint   v_num_bez;
        
        IGRboolean  *u_deg_ind;
        IGRboolean  *v_deg_ind;
        IGRboolean  status = TRUE;

        BSrc        rc = BSSUCC;        /* B-spline fn. return code */
        GRobjid     *pch_objid;
                
        struct  GRmd_env        *env;
        struct  IGRbsp_surface  *surface; 
        struct  IGRbsp_surface **bezier_ptr;    
        struct  IGResbs         esbs_attr;      
        struct  GRsymbology symbology;  
        struct  GRvg_construct cons_list;
        
        pch_objid = NULL;
        u_deg_ind = NULL;
        v_deg_ind = NULL;
        bezier_ptr = NULL;
        *msg = MSSUCC;
        OMmsg = OM_S_SUCCESS;
        env = construct_list->env_info;
        cons_list = *construct_list;
        
        /*
         * get the B-spline surface geometry in the abstract buffer
         */
        
        GRgetabsg ( &msg1,
                    &(env->md_env.matrix_type),
                     env->md_env.matrix,
                    &cache_ptr,
                     i );
        
        if ( !( 1 & msg1 ) )
        {
                *msg = MSFAIL;
                goto wrapup;
        }
        
        surface = (struct IGRbsp_surface *) cache_ptr;
        surface->num_boundaries = 0;
        
        n_u_spans = surface->u_num_poles - surface->u_order + 1;
        n_v_spans = surface->v_num_poles - surface->v_order + 1;
        n_bz_patches = n_u_spans * n_v_spans;
        
        /*
         * allocate memory for an array containing pointers 
         * to local buffer of bezier patches.
         */
        
        bezier_ptr = (struct IGRbsp_surface **) OM_stack_alloc( 
                        n_bz_patches * sizeof(struct IGRbsp_surface *) );

        if ( bezier_ptr == NULL)
        {
                *msg = MSNOMEM;
                goto wrapup;
        }
        
        /* 
         * allocate local buffer for bezier patches
         */
        
        for ( j = 0; j < n_bz_patches; j++ )
        {
        
                 BSallocsf (surface->u_order,
                                    surface->v_order,
                                    surface->u_order,
                                    surface->v_order,
                                    surface->rational,
                                    surface->num_boundaries,
                                   &bezier_ptr[j],
                                   &rc );
                                
                if ( rc != BSSUCC) 
                {
                        *msg = MSFAIL;
                        goto wrapup;
                }
                /*
                 * set the rational field of the curve as it may be
                 * messed up and will trouble during free
                 */
                        
                bezier_ptr[j]->rational = surface->rational;
                        
                /*
                 * 
                 */
                bezier_ptr[j]->num_boundaries = surface->num_boundaries;
        }

        /*
         * allocate space for arrays of degenerate indicators in
         * u and v directions
         *    (0) - degenerate
         *    (1) - non_degenerate
         */
        
        u_deg_ind = (IGRboolean *) OM_stack_alloc( n_u_spans *
                                   sizeof(IGRboolean) );
        
        if ( u_deg_ind == NULL)
        {
                *msg = MSNOMEM;
                goto wrapup;
        }
        
        v_deg_ind = (IGRboolean *) OM_stack_alloc( n_v_spans *
                                   sizeof(IGRboolean) );
        
        if ( v_deg_ind == NULL)
        {
                *msg = MSNOMEM;
                goto wrapup;
        }

        /* 
         * call B-spline math function to extract bezier patches
         * from the given B-spline surface.
         */
        
        status = BSpchtobz ( &rc,
                              surface,
                             &bezier_ptr,
                             &u_num_bez,
                             &v_num_bez,
                              u_deg_ind,
                              v_deg_ind);
                                                
        if ( !(status) || (rc != BSSUCC) )
        {
                *msg = MSFAIL;
                goto wrapup;
        }
        
        /*
         * allocate space for an array containing objids of 
         * bezier patches
         */
        
        *nondeg_pch = u_num_bez * v_num_bez;
        pch_objid = (GRobjid *) malloc ( (*nondeg_pch) * 
                                       sizeof(GRobjid) );
        if ( pch_objid == NULL)
        {
                *msg = MSNOMEM;
                goto wrapup;
        }
        
        *addr_pch_objid = pch_objid;
        
        /*
         * get the symbology of the original object. The
         * new objects should have the same symbology
         */
        
        OMmsg = om$send(mode = OM_e_wrt_object,
                    msg = message GRvg.GRgetsymb( &msg1,
                                                  &symbology),
                    senderid = my_id,
                    targetid = my_id);

        if ( !(1 & OMmsg) )
        {
                OMmsg = OM_E_ABORT;
                goto wrapup;
        }
        if ( !(1 & msg1) )
        {
                *msg = MSFAIL;
                goto wrapup;
        }

        /*
         * convert osnum to osname
         */
        
        OMmsg = om$os_number_to_name(osnum = env->md_id.osnum,
                                 osname = osname );

        if ( !( 1 & OMmsg ) )
        {
                OMmsg = OM_E_ABORT;
                goto wrapup;
        }
        
        /*
         * get classname of the new patches
         */
        
        OMmsg = om$send(mode = OM_e_wrt_object,
                    msg = message GRvg.GRclipto ( &msg1,
                                                   classname),
                    senderid = my_id,
                    targetid = my_id);
                                                        
        if ( !(1 & OMmsg))
        {
                OMmsg = OM_E_ABORT;
                goto wrapup;
        }
        if ( !(1 & msg1) )      
        {
                *msg = MSFAIL;
                goto wrapup;
        }
        
        for ( j = 0; j < *nondeg_pch; j++ )
        {

                /* 
                 * since the knot vectors (u, v) of 
                 * the bezier patches returned by
                 * the math function are not
                 * normalized, they are normalized
                 * before constructing the corresponding
                 * objects.
                 */
                
                u_order = bezier_ptr[j]->u_order;
                u_num_poles = bezier_ptr[j]->u_num_poles;

                for ( k = 0; k < u_order; k++)
                   bezier_ptr[j]->u_knots[k] = 0;
                
                for ( k = u_num_poles; k < (u_num_poles + u_order); k++)
                        bezier_ptr[j]->u_knots[k] = 1;

                v_order = bezier_ptr[j]->v_order;
                v_num_poles = bezier_ptr[j]->v_num_poles;
                
                for ( k = 0; k < v_order; k++)
                   bezier_ptr[j]->v_knots[k] = 0;
                
                for ( k = v_num_poles; k < (v_num_poles + v_order); k++)
                        bezier_ptr[j]->v_knots[k] = 1;
                        
                cons_list.geometry = (IGRchar *) bezier_ptr[j];
                cons_list.newflag = FALSE;
                cons_list.level = symbology.level;
                cons_list.properties = ME.GRgraphics->properties;
                cons_list.display = &(symbology.display_attr);
                cons_list.class_attr = NULL;
                cons_list.name = NULL;
                
                OMmsg =  om$construct(osname = osname,
                              classname = classname,
                              p_objid = &pch_objid[j],
                              neighbor = OM_GS_NULL_NEIGHBOR);
                                                
                if ( !(1 & OMmsg) )
                {
                        *msg = MSFAIL;
                        goto wrapup;
                }

        OMmsg = om$send(mode = OM_e_wrt_object,
                      msg = message GRgraphics.GRconstruct(&cons_list),
                        senderid = my_id,
                        targetid = pch_objid[j],
                        targetos = env->md_id.osnum);
                                
                if ( !(1 & OMmsg))              /* the construct failed */
                {
                        OMmsg  = OM_E_ABORT;
                        goto wrapup;
                }
                if ( !(1 & *(construct_list->msg)) )    /* the construct failed */
                {
                        *msg = MSFAIL;
                        goto wrapup;
                }
                ++ new_objts_constructed;
        }
         
        wrapup:
         
        if (u_deg_ind) OM_stack_dealloc(u_deg_ind);

        if (v_deg_ind) OM_stack_dealloc(v_deg_ind);
        
            for ( j = 0; j < n_bz_patches; j++ )

                if (bezier_ptr[j])
                        BSfreesf (&rc, bezier_ptr[j]);
                
        if (bezier_ptr) OM_stack_dealloc (bezier_ptr);
         
        /* 
         * if the method fails and new objects (if any ) are
         * constructed in the method, they have to be deleted
         * before exiting this method.
         */
        
        if ( !(1 & OMmsg)  ||  !(1 & *msg) )
        {
                for (j = 0; j < new_objts_constructed; j++)
                
                        OMmsg = om$send(mode = OM_e_wrt_object,
                            msg = message GRgraphics.GRdelete ( &msg1,
                                                                 env),
                            senderid = my_id,
                            targetid = pch_objid[j],
                            targetos = env->md_id.osnum);
                                                
            if ( !(1 & OMmsg))
            {
                        OMmsg = OM_E_ABORT;
                }

                if ( !(1 & msg1) )
                {
                        *msg = MSFAIL;
                }

        }
         return (OMmsg);
        
}

end implementation EMSsubbs;
