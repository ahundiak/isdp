class implementation EMinstance;

#include <grimport.h>
#include <DIprims.h>
#include <grerr.h>
#include <gocmacros.h>
#include <grdpbdef.h>
#include <grdpbmacros.h>
#include <assemdef.h>
#include <msmacros.h>
#include <grmessage.h>

#include <assemdef.h>
#include <assem.h>
#include <assempriv.h>

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Kapil: You can use this file to put all your overrides for the NDnodein   |
 | class. You may want to look at the ASnode source code. The ASnode class   |
 | is subclassed from GRowner and NDnodein which is just like EMinstance so  |
 | you can probably get some good ideas for what overrides are necessary for |
 | the EMinstance class.                                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Override: NDcopy                                                          |
 |                                                                           |
 | This method copys the object. This is a temporary KLUDGE to make instance |
 | objects work with Split Part. Kapil or Bill will make it do the right     |
 | thing later.                                                              |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  5/6/93     creation                                      |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method NDcopy (IGRlong         * msg;
               IGRint            cp_type;
               struct GRmd_env * fr_env;
               struct GRmd_env * to_env;
               struct GRid     * newobjid)
{
    IGRlong om_msg;

    om_msg = om$send (msg = message GRgraphics.GRcopy (msg,
                                                       fr_env,
                                                       to_env,
                                                       &newobjid->objid),
                      targetid = my_id);

    return (om_msg);
}


/*---------------------------------------------------------------------------+
 |                                                                           |
 | Override: NDdelete                                                        |
 |                                                                           |
 | This method deletes the object. This is a temporary KLUDGE to make        |
 | instance objects work with Split Part. Kapil or Bill will make it do the  |
 | right thing later.                                                        |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  5/6/93     creation                                      |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method NDdelete (struct GRmd_env * md_env)
{
    IGRlong  msg, om_msg;
    
    om_msg = om$send (msg = message GRgraphics.GRdelete (&msg, md_env),
                      targetid = my_id);
    
    return (om_msg);
}


method NDgive_structure (IGRlong *msg; struct ret_struct *str;
                         struct GRmd_env *md_env )
{
    str->type = other_generic ;
    *msg = MSSUCC;

    return (OM_S_SUCCESS);
}

method ASreturn_go ( struct GRid * go; short *mat_type; double *matrix )
{
long            msg;
struct GRmd_env mod_env;
int             sizbuf, nret;

    go->objid = my_id;
    go->osnum = OM_Gw_current_OS;


    if (matrix && mat_type)
    {
        sizbuf = sizeof(struct GRmd_env);

        gr$get_module_env ( msg = &msg,
                            sizbuf = &sizbuf,
                            buffer = &mod_env,
                            nret = &nret );

        *mat_type = mod_env.md_env.matrix_type;

        memcpy (matrix, mod_env.md_env.matrix, sizeof(IGRmatrix));
    }

    return OM_S_SUCCESS;
}

method NDdisplay ( int dp_type; enum GRdpmode dpmode; struct GRmd_env *env )
{
short           mattyp;
long            msg_loc;
double          *mat;
IGRmatrix       idmat;
struct GRid     mod_grid;

    if (!env)
    {
        mattyp = MAIDMX;
        MAidmx (&msg_loc, idmat);
        mat = idmat;
    }
    else
    {
        mattyp = env->md_env.matrix_type;
        mat = env->md_env.matrix;
    }

    GRfindmod (&mod_grid);
    om$send ( msg = message GRowner.GRdisplay ( &msg_loc, 
                                                &mattyp, 
                                                mat, 
                                                &dpmode,
                                                &mod_grid), 
                mode = OM_e_wrt_message, 
                targetid = my_id);

    return OM_S_SUCCESS;
}
               
end implementation EMinstance;


