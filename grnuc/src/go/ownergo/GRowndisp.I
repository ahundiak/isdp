/* #######################    APOGEE COMPILED   ######################## */
/*\
Description
    The following methods will get their components context then send
    the message to each component.

History
    Gray Winn       11/03/87    Design and Coding date.
    jay wallingford 04/29/87    Optimized the making of the chansel
    mrm		    02/15/90	added GRformatele to MDS
\*/
   
class implementation GRowner;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "gocmacros.h"

extern IGRint   GRget_to_comp_chansel();

method GRdisyourself (IGRlong *msg; 
                      IGRshort *mx_type; 
                      IGRmatrix matrix;  
                      enum GRdpmode *mode;
                      struct IGRaltdisplay *alt_symb; 
                      struct DP_information *sp_info;
                      OM_p_KEY_DESC range_key)
{
    IGRlong           om_msg;
    IGRshort          local_mx_type;
    IGRmatrix         local_matrix;
    OM_S_CHANSELECT   chansel;

    if ( om_msg = GRget_to_comp_chansel( &chansel ) ) 
    {
        /*
         *  Get the component matrix.
         */
        om_msg = om$send (msg = message GRowner.GRget_matrix( msg, 
                                                              mx_type,
                                                              matrix, 
                                                              &local_mx_type, 
                                                              local_matrix), 
                          targetid = my_id);

        /*
         *  Send the display message.
         */
        om_msg = om$send(msg = message GRgraphics.GRdisyourself (msg, 
                                                                 &local_mx_type,
                                                                 local_matrix, 
                                                                 mode, 
                                                                 alt_symb, 
                                                                 sp_info, 
                                                                 range_key),
                         p_chanselect = &chansel);
 
        GR_NOTIFY_LISTENERS(msg, &om_msg, GR_DISPLAYED);
    }

    if ( !(om_msg & 1) ) om_msg = OM_W_ABORT;

    return (om_msg);
}   

extern IGRboolean        GUcpxhandler();
extern void GUcpxinit();
extern IGRboolean GUcpxwritehdr();

method GRformatele( IGRlong *msg; 
                    struct GRmd_env *mod_env;
                    IGRchar *dgn_buf; 
                    IGRchar *bs_buf; 
                    IGRchar *ele_buf;
                    IGRint *ele_size; 
                    IGRint *file_des;
                    IGRdouble *max_overflow; 
                    IGRdouble *scale_factor)
{
    IGRlong           om_msg;
    OM_S_CHANSELECT   chansel;
    struct GRmd_env   local_mod_env;
    IGRboolean	      twrite = FALSE;
    struct GRid       id;
    IGRchar           IGDSclass = 0;
    IGRboolean        format;
    IGRboolean        mark_as_cpx;
    IGRboolean        cpx_calling = TRUE;
    IGRshort          level = 1;
    extern DMis_displayable();

    /*----------------------------------------------------------

	Dimension Fix for TR # 91N3519 - Do not convert hidden
	dimension to IGDS file.

    ------------------------------------------------------------*/

    if(!DMis_displayable(my_id,OM_Gw_current_OS))
    {
		*msg = MSSUCC;
		om_msg = MSSUCC;
        	goto wrapup;
    }

    /*------------------ END OF FIX -----------------------------*/

    if ( om_msg = GRget_to_comp_chansel( &chansel ) ) 
    {
        id.osnum = OM_Gw_current_OS;
        id.objid = my_id;

        if (!GUcpxhandler ( msg, 
                            &cpx_calling, 
                            mod_env, 
                            dgn_buf, 
                            bs_buf,
                            ele_buf, 
                            ele_size, 
                            file_des, 
                            max_overflow,
                            scale_factor, 
                            &IGDSclass, 
                            &me->properties,
                            &level, 
                            &id, 
                            &format, 
                            &mark_as_cpx) )
        {
            *msg = MSSUCC;
            goto wrapup;
        }

        if (!format) goto wrapup;

	GUcpxwritehdr (msg, &twrite);

        /*
         *  Get the component context.
         */
        om_msg = om$send (msg = message GRowner.GRget_context 
                                                ( msg, 
                                                  mod_env,
                                                  &local_mod_env), 
                          targetid = my_id);

        om_msg = om$send (msg = message GRgraphics.GRformatele 
                                                ( msg, 
                                                  &local_mod_env,
                                                  dgn_buf, 
                                                  bs_buf, 
                                                  ele_buf, 
                                                  ele_size, 
                                                  file_des, 
                                                  max_overflow,
                                                  scale_factor),
                          p_chanselect = &chansel);
    }

wrapup:
    if ( twrite )
    {
       GUcpxinit();
    }
    return (om_msg);
}   

method GRplotyourself(IGRlong *msg; 
                      struct GRmd_env *mod_env;
                      IGRchar *dgn_buf; 
                      IGRchar *bs_buf; 
                      IGRchar *ele_buf; 
                      IGRint *ele_size; 
                      IGRint *file_des; 
                      IGRdouble *max_overflow; 
                      struct GRid *window_id;
                      IGRdouble *scale_factor)
{
    IGRlong           om_msg;
    OM_S_CHANSELECT   chansel;
    struct GRmd_env   local_mod_env;

    if ( om_msg = GRget_to_comp_chansel( &chansel ) ) 
    {
        /*
         *  Get the component context.
         */
        om_msg = om$send (msg = message GRowner.GRget_context 
                                                ( msg, 
                                                  mod_env,
                                                  &local_mod_env), 
                          targetid = my_id);

        om_msg = om$send (msg = message GRgraphics.GRplotyourself
                                                ( msg, 
                                                  &local_mod_env,
                                                  dgn_buf, 
                                                  bs_buf, 
                                                  ele_buf, 
                                                  ele_size, 
                                                  file_des, 
                                                  max_overflow,
                                                  window_id, 
                                                  scale_factor), 
                          p_chanselect = &chansel);
    }

    return (om_msg);
}


method GRaddwrng (IGRlong *msg; struct GRmd_env *mod_env)
{
    IGRlong           om_msg;
    OM_S_CHANSELECT   chansel;
    struct GRmd_env   local_mod_env;

    if ( om_msg = GRget_to_comp_chansel( &chansel ) ) 
    {
        /*
         *  Get the component context.
         */
        om_msg = om$send (msg = message GRowner.GRget_context (msg, 
                                                               mod_env,
                                                               &local_mod_env), 
                          targetid = my_id);

        om_msg = om$send (msg = message GRgraphics.GRaddwrng (msg, 
                                                              &local_mod_env),
                          p_chanselect = &chansel);

        GR_NOTIFY_LISTENERS(msg, &om_msg, GR_RTREE_MANIPULATION);
    }

    return (om_msg);
}

method GRremwrng (IGRlong *msg; struct GRmd_env *mod_env)
{
    IGRlong           om_msg;
    OM_S_CHANSELECT   chansel;
    struct GRmd_env   local_mod_env;

    if ( om_msg = GRget_to_comp_chansel( &chansel ) ) 
    {
        /*
         *  Get the component context.
         */
        om_msg = om$send (msg = message GRowner.GRget_context (msg, 
                                                               mod_env,
                                                               &local_mod_env), 
                          targetid = my_id);

        om_msg = om$send (msg = message GRgraphics.GRremwrng (msg, &local_mod_env),
                          p_chanselect = &chansel);

        GR_NOTIFY_LISTENERS(msg, &om_msg, GR_RTREE_MANIPULATION);
    }

    return (om_msg);
}
end implementation GRowner;

