/* #######################    APOGEE COMPILED   ######################## */
class implementation GRowner;

#include "grimport.h"
#include "msdef.h"
#include "gocmacros.h"
#include <bsvalues.h>

extern IGRint       GRget_to_comp_info();
extern IGRboolean   MAptln2dis();
extern IGRboolean   MA2pt2dis();

method GRapprojpt ( IGRlong *msg; 
                    IGRshort *matrix_type;
                    IGRmatrix matrix; 
                    struct GRparms *locate_parms;
                    struct IGRline *boreline; 
                    IGRpoint proj_pt;
                    struct GRparms *proj_parms)
{
    IGRlong           om_msg;
    IGRlong           ret_msg;
    IGRint            count;
    IGRint            i;
    IGRshort          local_mx_type;
    IGRmatrix         local_matrix;
    IGRdouble         dis_sq;
    IGRdouble         new_dis_sq;
    OM_S_CHANSELECT   chansel;
    IGRpoint          new_proj_pt;
    struct GRparms    new_proj_parms;

    if ( om_msg = GRget_to_comp_info ( &chansel,
                                       OM_Gw_current_OS,
                                       my_id,
                                       &count ) ) 
    {
        om_msg = om$send (msg = message GRowner.GRget_matrix ( msg, 
                                                               matrix_type,
                                                               matrix, 
                                                               &local_mx_type, 
                                                               local_matrix), 
                          targetid = my_id);

        if (om_msg & 1) 
        {
            om_msg = om$send ( msg = message GRvg.GRapprojpt ( msg, 
                                                               &local_mx_type,
                                                               local_matrix, 
                                                               locate_parms,
                                                               boreline, 
                                                               proj_pt, 
                                                               proj_parms),
                               p_chanselect = &chansel,
                               from = NULL, 
                               to = NULL);

            if ((om_msg & *msg & 1) && (count > 1)) 
            {
                if (MAptln2dis(&ret_msg, proj_pt, boreline, &dis_sq)) 
                {
                    for (i=0; i < count; ++i) 
                    {
                        /*
                         *  Pass this method on to the components one at a time.
                         */
                        om_msg = om$send ( msg = message GRvg.GRapprojpt(msg, 
                                                                         &local_mx_type,
                                                                         local_matrix,
                                                                         locate_parms,  
                                                                         boreline,
                                                                         new_proj_pt,
                                                                         &new_proj_parms),
                                           p_chanselect = &chansel,
                                           from = i, 
                                           to = i);
    
                        if (om_msg & *msg & 1) 
                        {
                            if ( MAptln2dis(&ret_msg, new_proj_pt, boreline, &new_dis_sq)) 
                            {
                                if (new_dis_sq < dis_sq) 
                                {
                                    dis_sq = new_dis_sq;
                                    proj_pt[0] = new_proj_pt[0];
                                    proj_pt[1] = new_proj_pt[1];
                                    proj_pt[2] = new_proj_pt[2];
                                    *proj_parms = new_proj_parms;
                                }
                            }
                            else 
                            {
                                *msg = MSFAIL;
                                om_msg = OM_E_ABORT;
                            }
                        }
                    }
                }
                else 
                {
                    *msg = MSFAIL;
                    om_msg = OM_E_ABORT;
                }
            }
        }
    }

    return(om_msg);
}

method GRlnproject( IGRlong *msg; 
                    IGRshort *matrix_type;
                    IGRmatrix matrix; 
                    struct IGRline *line;
                    IGRpoint ln_pt,proj_pt; 
                    IGRdouble *t;
                    struct GRparms *proj_parms)
{
    IGRlong           om_msg;
    IGRlong           ret_msg;
    IGRint            count;
    IGRint            i;
    IGRshort          local_mx_type;
    IGRmatrix         local_matrix;
    IGRdouble         dis_sq;
    IGRdouble         new_dis_sq;
    IGRdouble         new_t;
    OM_S_CHANSELECT   chansel;
    IGRpoint          new_proj_pt;
    IGRpoint          new_ln_pt;
    struct GRparms    new_proj_parms;

    if ( om_msg = GRget_to_comp_info ( &chansel,
                                       OM_Gw_current_OS,
                                       my_id,
                                       &count ) ) 
    {
        om_msg = om$send (msg = message GRowner.GRget_matrix (msg, 
                                                              matrix_type,
                                                              matrix, 
                                                              &local_mx_type, 
                                                              local_matrix), 
                          targetid = my_id);

        if (om_msg & 1) 
        {
            om_msg = om$send ( msg = message GRvg.GRlnproject ( msg, 
                                                                &local_mx_type,
                                                                local_matrix, 
                                                                line, 
                                                                ln_pt, 
                                                                proj_pt, 
                                                                t, 
                                                                proj_parms),
                               p_chanselect = &chansel,
                               from = NULL, 
                               to = NULL);

            if ((om_msg & *msg & 1) && (count > 1)) 
            {
                if (MA2pt2dis(&ret_msg, ln_pt, proj_pt, &dis_sq)) 
                {
                    for (i=0; i < count; ++i) 
                    {
                        /*
                         *  Pass this method on to the components one at a time.
                         */
                        om_msg = om$send ( msg = message GRvg.GRlnproject(msg, 
                                                                          &local_mx_type,
                                                                          local_matrix, 
                                                                          line, 
                                                                          new_ln_pt, 
                                                                          new_proj_pt, 
                                                                          &new_t,
                                                                          &new_proj_parms),
                                           p_chanselect = &chansel,
                                           from = i, 
                                           to = i);

                        if (om_msg & *msg & 1) 
                        {
                            if (MA2pt2dis(&ret_msg, new_ln_pt, new_proj_pt,&new_dis_sq)) 
                            {
                                if (new_dis_sq < dis_sq) 
                                {
                                    dis_sq = new_dis_sq;
                                    *t = new_t;
                                    proj_pt[0] = new_proj_pt[0];
                                    proj_pt[1] = new_proj_pt[1];
                                    proj_pt[2] = new_proj_pt[2];
                                    ln_pt[0] = new_ln_pt[0];
                                    ln_pt[1] = new_ln_pt[1];
                                    ln_pt[2] = new_ln_pt[2];
                                    *proj_parms = new_proj_parms;
                                }
                            }
                            else 
                            {
                                *msg = MSFAIL;
                                om_msg = OM_E_ABORT;
                            }
                        }                                          
                    }
                }
                else 
                {
                    *msg = MSFAIL;
                    om_msg = OM_E_ABORT;
                }
            }
        }
    }

    return(om_msg);
}

method GRptproject( IGRlong *msg; 
                    IGRshort *matrix_type;
                    IGRmatrix matrix; 
                    IGRpoint point; 
                    IGRpoint proj_pt;
                    struct GRparms *proj_parms)
{
    IGRlong           om_msg;
    IGRlong           ret_msg;
    IGRint            count;
    IGRint            i;
    IGRshort          local_mx_type;
    IGRmatrix         local_matrix;
    IGRdouble         dis_sq;
    IGRdouble         new_dis_sq;
    OM_S_CHANSELECT   chansel;
    IGRpoint          new_proj_pt;
    struct GRparms    new_proj_parms;

    if ( om_msg = GRget_to_comp_info ( &chansel,
                                       OM_Gw_current_OS,
                                       my_id,
                                       &count ) ) 
    {
        om_msg = om$send (msg = message GRowner.GRget_matrix (msg, 
                                                              matrix_type,
                                                              matrix, 
                                                              &local_mx_type, 
                                                              local_matrix), 
                          targetid = my_id);

        if (om_msg & 1) 
        {
            om_msg = om$send ( msg = message GRvg.GRptproject(msg, 
                                                              &local_mx_type,
                                                              local_matrix, 
                                                              point, 
                                                              proj_pt, 
                                                              proj_parms),
                               p_chanselect = &chansel,
                               from = NULL, 
                               to = NULL);

            if ((om_msg & *msg & 1) && (count > 1)) 
            {
                if (MA2pt2dis(&ret_msg, point, proj_pt, &dis_sq)) 
                {
                    for (i=0; i < count; ++i) 
                    {
                        /*
                         *  Pass this method on to the components one at a time.
                         */
                        om_msg = om$send ( msg = message GRvg.GRptproject(msg, 
                                                                          &local_mx_type,
                                                                          local_matrix, 
                                                                          point, 
                                                                          new_proj_pt, 
                                                                          &new_proj_parms),
                                           p_chanselect = &chansel,
                                           from = i, 
                                           to = i);

                        if (om_msg & *msg & 1) 
                        {
                            if (MA2pt2dis(&ret_msg, point, new_proj_pt, &new_dis_sq)) 
                            {
                                if (new_dis_sq < dis_sq) 
                                {
                                    dis_sq = new_dis_sq;
                                    proj_pt[0] = new_proj_pt[0];
                                    proj_pt[1] = new_proj_pt[1];
                                    proj_pt[2] = new_proj_pt[2];
                                    *proj_parms = new_proj_parms;
                                }
                            }
                            else 
                            {
                                *msg = MSFAIL;
                                om_msg = OM_E_ABORT;
                            }
                        }                                          
                    }
                }
                else 
                {
                    *msg = MSFAIL;
                    om_msg = OM_E_ABORT;
                }
            }
        }
    }

    return(om_msg);
}

method GRkeypoint ( IGRlong *msg; 
                    IGRshort *matrix_type; 
                    IGRmatrix matrix; 
                    struct IGRline *boreline; 
                    IGRpoint keypoint; 
                    struct GRparms *key_parms)
{
    IGRlong           om_msg;
    IGRlong           ret_msg;
    IGRint            count;
    IGRint            i;
    IGRshort          local_mx_type;
    IGRmatrix         local_matrix;
    IGRdouble         dis_sq = MAXDOUBLE;	/* AIC */
    IGRdouble         new_dis_sq;
    OM_S_CHANSELECT   chansel;
    IGRpoint          new_keypoint;
    struct GRparms    new_key_parms;

    if ( om_msg = GRget_to_comp_info ( &chansel,
                                       OM_Gw_current_OS,
                                       my_id,
                                       &count ) ) 
    {
        om_msg = om$send (msg = message GRowner.GRget_matrix (msg, 
                                                              matrix_type,
                                                              matrix, 
                                                              &local_mx_type, 
                                                              local_matrix), 
                          targetid = my_id);

        if (om_msg & 1) 
        {

/*	    FIXED FOR NAVSEA - AIC

	    The need for this section of code was eliminated by initializing
	    dis_sq to MAXDOUBLE.

            om_msg = om$send ( msg = message GRvg.GRkeypoint ( msg, 
                                                               &local_mx_type,
                                                               local_matrix, 
                                                               boreline, 
                                                               keypoint, 
                                                               key_parms),
                               p_chanselect = &chansel,
                               from = NULL, 
                               to = NULL);

            if ((om_msg & *msg & 1) && (count > 1)) 
            {
                if (MAptln2dis(&ret_msg, keypoint, boreline, &dis_sq)) 
                {

*/
		    om_msg = OM_W_WARNING; /* AIC */
                    for (i=0; i < count; ++i) 
                    {
			IGRlong	loc_om_msg;	/* AIC */

                        /*
                         *  Pass this method on to the components one at a time.
                         */
                        loc_om_msg = om$send ( msg = message GRvg.GRkeypoint( msg, 
                                                                          &local_mx_type,
                                                                          local_matrix, 
                                                                          boreline, 
                                                                          new_keypoint, 
                                                                          &new_key_parms),
                                           p_chanselect = &chansel, 
                                           from = i, 
                                           to = i);

                        if (loc_om_msg & *msg & 1) 
                        {
                            if (MAptln2dis(&ret_msg, new_keypoint, boreline, &new_dis_sq)) 
                            {
                                if (new_dis_sq < dis_sq) 
                                {
				    om_msg = OM_S_SUCCESS; /* AIC */
                                    dis_sq = new_dis_sq;
                                    keypoint[0] = new_keypoint[0];
                                    keypoint[1] = new_keypoint[1];
                                    keypoint[2] = new_keypoint[2];
                                    *key_parms = new_key_parms;
                                }
                            }

/*	FIXED FOR NAVSEA - AIC

	Even though the math routine failed, the method should not.
	Rather, it should not evaluate the result for the best keypoint.

                            else 
                            {
                                *msg = MSFAIL;
                                om_msg = OM_E_ABORT;
                            }
*/
                        }
                    }

/* FIXED FOR NAVSEA - AIC

	The need for this section of code was eliminated by initializing
	dis_sq to MAXDOUBLE.

                }
                else 
                {
                    *msg = MSFAIL;
                    om_msg = OM_E_ABORT;
                }
            }
*/
        }
    }

    return(om_msg);
}

method GRprojpt(IGRlong *msg; 
                IGRshort *matrix_type; 
                IGRmatrix matrix; 
                struct GRparms *locate_parms; 
                IGRpoint point;
                IGRpoint proj_pt; 
                struct GRparms *proj_parms)
{
    IGRlong           om_msg;
    IGRlong           ret_msg;
    IGRint            count;
    IGRint            i;
    IGRshort          local_mx_type;
    IGRmatrix         local_matrix;
    IGRdouble         dis_sq;
    IGRdouble         new_dis_sq;
    OM_S_CHANSELECT   chansel;
    IGRpoint          new_proj_pt;
    struct GRparms    new_proj_parms;

    if ( om_msg = GRget_to_comp_info ( &chansel,
                                       OM_Gw_current_OS,
                                       my_id,
                                       &count ) ) 
    {
        om_msg = om$send (msg = message GRowner.GRget_matrix (msg, 
                                                              matrix_type,
                                                              matrix, 
                                                              &local_mx_type, 
                                                              local_matrix), 
                          targetid = my_id);

        if (om_msg & 1) 
        {
            om_msg = om$send ( msg = message GRvg.GRprojpt( msg, 
                                                            &local_mx_type,
                                                            local_matrix, 
                                                            locate_parms, 
                                                            point, 
                                                            proj_pt, 
                                                            proj_parms),
                               p_chanselect = &chansel,
                               from = NULL, 
                               to = NULL);

            if ((om_msg & *msg & 1) && (count > 1)) 
            {
                if (MA2pt2dis(&ret_msg, point, proj_pt, &dis_sq)) 
                {
                    for (i=0; i < count; ++i) 
                    {
                        /*
                         *  Pass this method on to the components one at a time.
                         */
                        om_msg = om$send ( msg = message GRvg.GRprojpt(msg, 
                                                                       &local_mx_type,
                                                                       local_matrix, 
                                                                       locate_parms, 
                                                                       point, 
                                                                       new_proj_pt,
                                                                       &new_proj_parms),
                                           p_chanselect = &chansel,
                                           from = i, 
                                           to = i);

                        if (om_msg & *msg & 1) 
                        {
                            if (MA2pt2dis(&ret_msg, point, new_proj_pt, &new_dis_sq)) 
                            {
                                if (new_dis_sq < dis_sq) 
                                {
                                    dis_sq = new_dis_sq;
                                    proj_pt[0] = new_proj_pt[0];
                                    proj_pt[1] = new_proj_pt[1];
                                    proj_pt[2] = new_proj_pt[2];
                                    *proj_parms = new_proj_parms;
                                }
                            }
                            else 
                            {
                                *msg = MSFAIL;
                                om_msg = OM_E_ABORT;
                            }
                        }
                    }
                }
                else 
                {
                    *msg = MSFAIL;
                    om_msg = OM_E_ABORT;
                }
            }
        }
    }

    return(om_msg);
}

method GRptdis( IGRlong *msg; 
                IGRshort *matrix_type; 
                IGRmatrix matrix; 
                IGRpoint point; 
                IGRdouble *distance)
{
    IGRlong           om_msg;
    IGRint            count;
    IGRint            i;
    IGRshort          local_mx_type;
    IGRmatrix         local_matrix;
    IGRdouble         new_distance;
    OM_S_CHANSELECT   chansel;

    if ( om_msg = GRget_to_comp_info ( &chansel,
                                       OM_Gw_current_OS,
                                       my_id,
                                       &count ) ) 
    {
        om_msg = om$send (msg = message GRowner.GRget_matrix (msg, 
                                                              matrix_type,
                                                              matrix, 
                                                              &local_mx_type, 
                                                              local_matrix), 
                          targetid = my_id);

        if (om_msg & 1) 
        {
            om_msg = om$send ( msg = message GRvg.GRptdis(msg, 
                                                          &local_mx_type,
                                                          local_matrix, 
                                                          point, 
                                                          distance),
                               p_chanselect = &chansel,
                               from = NULL, 
                               to = NULL);

            if ((om_msg & *msg & 1) && (count > 1)) 
            {
                for (i=0; i < count; ++i) 
                {
                    /*
                     *  Pass this method on to the components one at a time.
                     */
                    om_msg = om$send ( msg = message GRvg.GRptdis(msg, 
                                                                  &local_mx_type,
                                                                  local_matrix, 
                                                                  point, 
                                                                  &new_distance),
                                       p_chanselect = &chansel,
                                       from = i, 
                                       to = i);

                    if (om_msg & *msg & 1) 
                    {
                        if (new_distance < *distance) 
                        {
                            *distance = new_distance;
                        }
                    }
                    
                }
            }
        }
    }

    return(om_msg);
}

end implementation GRowner;
