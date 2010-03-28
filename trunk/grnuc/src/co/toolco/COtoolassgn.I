/* #######################    APOGEE COMPILED   ######################## */
/******************************************************************************

Methods:

    assign

Description:    

    The assign method assigns one date type to another. The types
    that may be defined are found in toolco.h.

History:    

    jay wallingford     04/10/89    creation date

Bugs:       

    There are no known bugs.

Notes:

******************************************************************************/

class implementation COtools;

#include <coimport.h>
#include <msdef.h>
#include <msmacros.h>
#include <growner.h>

extern IGRint GRget_window_matrix();
 
method assign ( IGRchar * from_value;
                IGRchar * to_value;
                IGRint type )
{
    IGRint size, sts;

    switch ( type )
    {
    case CO_str_to_str:
        strcpy(to_value, from_value);
        break;
    case CO_dbl_to_dbl:
        *(double *)to_value = *(double *)from_value;
        break;
    case CO_dbl_to_int:
        *(int *)to_value = *(double *)from_value;
        break;
    case CO_int_to_int:
        *(int *)to_value = *(int *)from_value;
        break;
    case CO_int_to_dbl:
        *(double *)to_value = *(int *)from_value;
        break;
    case CO_cin_to_int:
        *(int *)to_value = (int)from_value;
        break;
    case CO_cin_to_dbl:
        *(double *)to_value = (int)from_value;
        break;
    case CO_btn_to_btn:
        *(struct EX_button *)to_value = *(struct EX_button *)from_value;
        break;
    case CO_btn_to_pnt:
        ((double *)to_value)[0] = ((struct EX_button *)from_value)->x;
        ((double *)to_value)[1] = ((struct EX_button *)from_value)->y;
        ((double *)to_value)[2] = ((struct EX_button *)from_value)->z;
        break;
    case CO_btn_to_grid:
        ((struct GRid *)to_value)->objid = ((struct EX_button *)from_value)->objid;
        ((struct GRid *)to_value)->osnum = ((struct EX_button *)from_value)->osnum;
        break;
    case CO_btn_to_mtx:
        GRget_window_matrix ( &sts,
                              ((struct EX_button *)from_value)->osnum,
                              ((struct EX_button *)from_value)->objid,
                              (double *)to_value,
                              NULL );
        break;
    case CO_evt_to_evt:
        *((struct GRevent *)to_value) = *((struct GRevent *)from_value);
        break;
    case CO_mtx_to_mtx:
        size = sizeof(double) * 16;
        OM_BLOCK_MOVE( from_value, to_value, size );
        break;
    case CO_gschan_to_grid:
        {
        struct GRobj_env    obj_info;
        struct GRid         my_grid;

        my_grid.objid = my_id;
        my_grid.osnum = OM_Gw_current_OS;

        GRgsget_simple_object ( &sts, 
                                &my_grid,
                                (OM_S_CHANSELECT *)from_value,
                                &obj_info );

        *((struct GRid *)to_value) = obj_info.obj_id;

        }
        break;
    case CO_msg_to_str:
        ex$message ( msgnumb = (IGRint)from_value,
		     buff = (IGRchar *)to_value );
        break;
    default:
        break;
    }

    return OM_S_SUCCESS;    
}

end implementation COtools;

