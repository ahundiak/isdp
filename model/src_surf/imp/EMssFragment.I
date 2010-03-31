/* ###################   APOGEE COMPILED   ################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: EMSsubbs      
     METHOD NAME: GRfragment    

     Abstract:  This method fragments a surface at knots of
                multiplicity of order-1. The method constructs
                new objects for only nondegenerate patches. It
                connects these objects to a complex channel
                and deletes the original object.
                
                If an error occurs, the original object is left
                intact and the new objects constructed, if any,
                are deleted before returning the control to the
                caller.

-----
%SC%    
        GRfragment(msg,env,complex,cpxchan,new_env)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   ------------------------------------
      *env         GRmd_env      data set environment structure of
                                  the object to be fragmented

      *complex    GRid           object id and object space number 
                                  for complex object

      *new_env    GRmd_env           data set information for the new 
                                      objects to be constructed
        

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
        *msg        IGRlong            completion code
                                            MSSUCC - successful completion
                                            MSFAIL - error occured
-----
%MD%

     MODULES AND METHODS INVOKED:
     Modules:
                GRgetabsg
                GRabsg_del
                om$send
                om$report_error
                om$construct

     Methods:
                GRgetsymb
                GRclipto
                GRconstruct
                GRdelete
-----
%RL%

     RELATIONS REFERENCED:
-----
%NB%

     NOTES:
-----
%CH%

     CHANGE HISTORY:  RC   10/02/86       Creation date
        
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------



----*/
/*EH*/


class implementation EMSsubbs;

#include "EMS.h"
# ifndef OM_D_MINIMUM
# include "OMminimum.h"     /* for gocmacros.h  */
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"     /* for gocmacros.h  */
# endif

# ifndef gocmacros_include
# include "gocmacros.h"     /* GRgetabsg macro  */
# endif

# ifndef msdef_include
# include "msdef.h" /* MS message codes */
# endif

#include <stdio.h>
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

/* end of EX_struct.h replacement */
#include "madef.h"
#include "OMerrordef.h"
#include "OMstackalloc.h"
#include "bsdefs.h"
#include "bserr.h"

method GRfragment(IGRlong *msg;struct GRmd_env *env;struct GRid *complex; 
                  struct GRmd_env *new_env)
{
        IGRchar         osname[OM_K_MAXOSNAME_LEN];
        IGRchar         *cache_ptr;     /* abstract buffer pointer   */
        IGRchar         classname[GRNAME_SIZE]; /* classname of out_surface */
        
        IGRint  n_u_patches = 0 ;/* no. of patches in u direction */
        IGRint  n_v_patches = 0 ;/* no. of patches in v direction */
        IGRint          index, index2;
        
        IGRlong         msg1;                   /* return code */
        IGRlong         i, j;                   /* loop index  */
        IGRlong     OMmsg;
        IGRlong         numVLA; 

        IGRboolean  status;
        IGRboolean  planar;         /* planarity check bit of out_surface */

        BSrc            rc;         /* B-spline function retirn code    */
        
        OM_S_CHANSELECT          pch_channel, owner_chan;
        
        GRobjid         pch_objid;      /* broken surface patch objid */
        GRclassid       classid;
        
        struct  IGRbsp_surface   *in_surface;
        struct  IGRbsp_surface   ***out_surface;
        struct  GRsymbology symbology;  
        struct  GRvg_construct   construct_list;
        
  extern         IGRboolean BSbreaksf();
        
        *msg = MSSUCC;
        OMmsg = OM_S_SUCCESS;
        
        index = index2 = 0;
        OMmsg = EMmake_chanselect (GRcmpowner_to_components, &owner_chan);
        if (!(1&OMmsg)) goto wrapup;
 
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
        
        in_surface = (struct IGRbsp_surface *) cache_ptr;
        in_surface->num_boundaries = 0;

        /* 
         * set planar bit to FALSE as this characteristic
         * is not used in later processing. 
         *
         * planar = TRUE   BSbreaksf will fill the planar information 
         *                  in the out_surface patches' struct.
         * planar = FALSE  BSbreaksf will not fill the planar information
         *                  in the out_surface pacthes' struct. 
         */
        
        planar = FALSE;

        /* 
         * call B-spline math function to break the surface
         * at the knots of multiplicity of (order -1).
         */

        status = BSbreaksf ( &rc,
                              in_surface,
                             &n_u_patches,
                             &n_v_patches,
                             &out_surface,
                             &planar);
                                                
        if ( !(status) || ( rc != BSSUCC )  )
        {
                *msg = MSFAIL;
                goto wrapup;
        }
        
        /*
         * get symbology. The patches will have the smbology as that
         * of input surface
         */
        
        OMmsg = om$send(mode = OM_e_wrt_object,
                        msg = message GRvg.GRgetsymb( &msg1,
                                                      &symbology),
                        senderid = my_id,                       
                        targetid = my_id);

        if ( !(1 & OMmsg) )  
        {
                OMmsg = OM_E_ABORT;
                om$report_error(sts = OMmsg);
                goto wrapup;
        }
        if ( !(1 & msg1) )
        {
                *msg = MSFAIL;
                goto wrapup;
        }

        construct_list.msg = &msg1;
        construct_list.env_info = new_env;
        construct_list.newflag = FALSE;
        construct_list.level = symbology.level;
        construct_list.properties = ME.GRgraphics->properties;
        construct_list.display = &(symbology.display_attr);
        construct_list.class_attr = 0;
        construct_list.name = 0;

        /* 
         * get the classname of the new surface
         */
        
        OMmsg = om$send(mode = OM_e_wrt_object,
                    msg = message GRvg.GRclipto ( &msg1,
                                               classname),
                    senderid = my_id,
                    targetid = my_id );
        
        if ( !(1 & OMmsg) )
        {
                OMmsg = OM_E_ABORT;
                om$report_error(sts = OMmsg);
                goto wrapup;
        }

        if ( !(1 & msg1) )
        {
                *msg = MSFAIL;
                goto wrapup;
        }

        /*
         * get the classid
         */
        
        OMmsg = om$get_classid (classname = classname,
                                 p_classid = &classid);
                                
        if ( !(1 & OMmsg))
        {
                *msg = MSFAIL;
                goto wrapup;
        }

        /*
         * fill in the channel information for
         * the patches. it is assumed to be of
         * the type EMSsubbs.owners
         */
        
        EMmake_chanselect (GRconnector_to_owners, &pch_channel);
                
        /* 
         * construct objects out of broken patches
         */
        
        for ( i = 0; i <  (n_u_patches * n_v_patches); i++ )
        {

                /*
                 * normalize the u and v knot vectors
                 */
                
                status = BSnrsfkntvc ( (*out_surface)[i] );

                if ( !status)
                {
                        *msg = MSFAIL;
                }
                
                construct_list.geometry = (IGRchar *) (*out_surface)[i];
                        
                OMmsg = om$construct(osnum = OM_Gw_current_OS,
                             classid = classid,
                             p_objid = &pch_objid,
                             neighbor = OM_GS_NULL_NEIGHBOR);

                if ( !(1 & OMmsg) )
                {
                        OMmsg = OM_E_ABORT;
                        om$report_error(sts = OMmsg);
                        goto wrapup;
             }

            OMmsg = om$send(mode = OM_e_wrt_object,
                        msg = message GRgraphics.GRconstruct(&construct_list),
                         senderid = my_id,
                         targetid = pch_objid,
                         targetos = new_env->md_id.osnum);
                                
                if ( !(1 & OMmsg))              /* the construct failed */
                {
                        OMmsg = OM_E_ABORT;
                        goto wrapup;
                }

                if ( !(1 & *(construct_list.msg) ) )
                {
                        *msg = MSFAIL;
                        goto wrapup;
                }
                                
                /*
                 * put the object on the channel
                 */
                        
        OMmsg = om$send(mode = OM_e_wrt_object,
                        msg = message Root.connect (owner_chan,
                                index2, pch_objid, new_env->md_id.osnum,
                                pch_channel, index),
                        targetid = complex->objid,
                        targetos = complex->osnum);

        if ( !(1 & OMmsg) )
            {
                        om$report_error(sts = OMmsg);
                        OMmsg = OM_E_ABORT;
                        goto wrapup;
        }
                
                 ++index;               /* increment channel index */
                        
                        
        } /* i for loop */
        
         
        wrapup:
        
        if ( !(1 & OMmsg)  ||  !(1 & *msg) )
        {
                if ( index != 0 )
                {
        
                        OMmsg = om$send(mode = OM_e_wrt_object,
                            msg = message GRgraphics.GRdelete( &msg1,
                                                                new_env),
                            senderid = my_id,
                            p_chanselect = &pch_channel,
                            from = NULL,
                            to = index );
                
                    if ( !(1 & OMmsg) )
                        {
                                OMmsg = OM_E_ABORT;
                                om$report_error(sts = OMmsg);
                        }

                        if ( !(1 & msg1) )
                        {
                                *msg = MSFAIL;
                        }
                }
        }       
        else
        {
        
                OMmsg = om$send(mode = OM_e_wrt_object,
                        msg = message GRgraphics.GRdelete ( &msg1,
                                                         env),
                        senderid = my_id,
                        targetid = my_id );
                                                
            if ( !(1 & OMmsg))
            {
                        OMmsg = OM_E_ABORT;
                        om$report_error(sts = OMmsg);
                }

                if ( !(1 & msg1) )
                {
                        *msg = MSFAIL;
                }
                        
                                                
                GRabsg_del ( cache_ptr );
        }
        
                
         return (OMmsg);
        
}
        
end implementation EMSsubbs;
