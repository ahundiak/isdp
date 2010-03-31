/* ###################   APOGEE COMPILED   ################## */
class implementation EMSparampt;

/*
  HISTORY

        Sudha   06/30/93        Modified for BSprototypes ansification
*/

#include "gocmacros.h"
#include "maoptsxfo.h"


method EMparam_xform ( IGRlong          * msg; 
                       struct GRmd_env  * obj_dsenv; 
                       IGRshort         * matrix_type; 
                       IGRmatrix          matrix; 
                       GRobjid          * newobjid )
{
    *newobjid = my_id;
    *msg = EMS_S_Success;

    if (*matrix_type != MAIDMX)
    {
        IGRlong     ma_msg = MSSUCC;
        IGRlong     num = 1;
        IGRpoint    point;
        struct GRid myGRid;

        MAoptsxform ( &ma_msg, &num, matrix_type, matrix, me->pt, point );

        if (ma_msg & 1)
            memcpy (me->pt, point, sizeof(IGRpoint));
        else 
            *msg = EMS_E_Fail;

	myGRid.objid = my_id;
	myGRid.osnum = OM_Gw_current_OS;

        {
         OM_S_CHANSELECT to_children;
         OMuint child_count;
         struct GRid child_id;
         IGRint i;

         EMmake_chanselect(NDchildren_children, &to_children);
         om$get_channel_count ( objid = my_id,   
                                p_chanselect = &to_children,
                                count = &child_count );

         if (child_count > 1)
         {

          for (i=0;i<child_count;i++)
             om$get_objid_at_index ( object = me,
                                     p_chanselect = &to_children,
                                     index = 0,
                                     objidaddr = &child_id.objid,
                                     osnumaddr = &child_id.osnum );
          if (sender_id != child_id.objid)
	     nd$wait_batch(type = GR_GEOM_POSTED, l_object = &child_id, 
               nb_obj = 1);
         }
       }
 }

    return (OM_S_SUCCESS);
}

end implementation EMSparampt;
