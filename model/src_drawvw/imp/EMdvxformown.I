/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
    GRxform_owner

Description
    This method determines whether the input transformation matrix is just
    a translation matrix and if it is, sets the return values such that
    the GRxform message is sent to the components.  This class only allows
    tranlation, not rotation, of its components.

    *msg           IGRlong           completion code
    *obj_dsenv     struct GRmd_env   md_env structure 
    *matrix_type   IGRshort          the type of the matrix
    matrix         IGRmatrix         the given transformation matrix
    *newobjid      GRobjid           objid of the transformed object
    *cont          IGRint            If 1 - pass xform to all objects
                                       0 - do not pass xform to all objects

Return Values
    MSSUCC   -  if successful
    MSFAIL   -  if failure

History
    WBC : 02/13/92
\*/

class implementation EMSdrawview;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "gocmacros.h"
#include "emsdef.h"
#include "OMmacros.h"
#include "exmacros.h"
#include "EMSasectvw.h"

from NDnode import ASreturn_go;
from EMSassoc import EMget_info;

extern int EMcompute_rotation();
method GRxform_owner (IGRlong *msg; 
                      struct GRmd_env *mod_env; 
                      IGRshort *matrix_type; 
                      IGRmatrix matrix; 
                      GRobjid *newobjid; 
                      IGRint *cont)
{
    IGRlong  status,om_msg;
    IGRshort mat;
    IGRuint type;
    IGRmatrix matr,mmat;
    OM_S_CHANSELECT to_notify,to_comp,children;
    int comp_count=0,to_count=0;
    struct GRid cur_mod;
    enum GRdpmode             dpmode;
    OM_S_OBJECT_LINKAGE *notif_linkage=NULL,*comp_linkage=NULL,
		*child_linkage=NULL;
    extern OMuword OPP_EMSasectvw_class_id;

    /*  The newobjid must be assigned in this routine so that
     *  the calling routine may assume that a valid object id
     *  is in newobjid.  Note that this object can not change classes.
     */

    *msg = MSSUCC;   
    *newobjid = my_id;

     if(mod_env->md_id.objid == NULL_OBJID) goto wrapup;

     EMmake_chanselect(GRcmpowner_to_components, &to_comp);
     status = om$get_channel_count(p_chanselect = &to_comp,
                                 objid = my_id,
                                 osnum = OM_Gw_current_OS,
                                 count =(OMuint *) &comp_count);
     if (!(1&status) || (comp_count ==0)) goto wrapup;
 
     comp_linkage = (OM_S_OBJECT_LINKAGE *)om$malloc(size = 
			comp_count * sizeof(OM_S_OBJECT_LINKAGE));
     status = om$get_channel_objects(objid = my_id,
                                     osnum = OM_Gw_current_OS,
                                     p_chanselect = &to_comp,
                                     list = comp_linkage,
                                     size = comp_count,
                                     count = (OMuint *)&comp_count);
     if (!(1&status))
         goto  wrapup;

     EMmake_chanselect(GRnotify_notification, &to_notify);
     status = om$get_channel_count(p_chanselect = &to_notify,
                                 objid = comp_linkage[0].S_objid,
                                 osnum = comp_linkage[0].osnum,
                                 count =(OMuint *) &to_count);
     if (!(1&status) || (to_count ==0)) goto wrapup;
 
     notif_linkage = (OM_S_OBJECT_LINKAGE *)om$malloc(size =
                        to_count * sizeof(OM_S_OBJECT_LINKAGE));

     status = om$get_channel_objects(objid =  comp_linkage[0].S_objid,
                                     osnum = comp_linkage[0].osnum,
                                     p_chanselect = &to_notify,
                                     list = notif_linkage,
                                     size = to_count,
                                     count = (OMuint *)&to_count);
     if (!(1&status))
         goto  wrapup;

     EMmake_chanselect(NDchildren_children, &children);
     status = om$get_channel_count(p_chanselect = &children,
                                 objid = notif_linkage[0].S_objid,
                                 osnum = notif_linkage[0].osnum,
                                 count =(OMuint *) &to_count);
     if (!(1&status) || (to_count ==0)) goto wrapup;
 
     child_linkage = (OM_S_OBJECT_LINKAGE *)om$malloc(size =
                        to_count * sizeof(OM_S_OBJECT_LINKAGE));

     status = om$get_channel_objects(objid = notif_linkage[0].S_objid,
                                     osnum = notif_linkage[0].osnum,
                                     p_chanselect = &children,
                                     list = child_linkage,
                                     size = to_count,
                                     count = (OMuint *)&to_count);
     if (!(1&status))
         goto  wrapup;
     if (EFisAncestryValid(msg, child_linkage[0].S_objid,
                               child_linkage[0].osnum,
                          OPP_EMSasectvw_class_id, FALSE))
    {
       status = om$send(msg = message EMSassoc.EMget_info(&om_msg,
                                                     NULL, &type, NULL,NULL),
				targetid = child_linkage[0].S_objid,
				targetos =  child_linkage[0].osnum);
       if(!(status & 1 & om_msg))
		goto wrapup;

       if (((matrix[0] == 1.0) && (matrix[1] == 0.0) && (matrix[2] == 0.0) &&
        (matrix[4] == 0.0) && (matrix[5] == 1.0) && (matrix[6] == 0.0) &&
        (matrix[8] == 0.0) && (matrix[9] == 0.0) && (matrix[10] == 1.0) &&
        (matrix[12] == 0.0) && (matrix[13] == 0.0) && (matrix[14] == 0.0) &&
        (matrix[15] == 1.0)) && (type == EMS_ASsectvw))
           goto wrapup;

       status = EMcompute_rotation(
			&om_msg,matrix_type,matrix,
			child_linkage[0].S_objid,
			child_linkage[0].osnum);
       if(!(status & 1 & om_msg))
		goto wrapup;
       dpmode = GRbe;
 
       status = ex$get_cur_mod(id = &cur_mod.objid,
                                    osnum = &cur_mod.osnum);
            if (!(1&status)) goto wrapup;

       status = om$send(msg = message GRgraphics.GRdisplay(
                                               &om_msg,
                                               &mod_env->md_env.matrix_type,
                                               mod_env->md_env.matrix, &dpmode,
                                               &cur_mod),
                             targetid = child_linkage[0].S_objid,
			     targetos = child_linkage[0].osnum);
       if(!(status & 1 & om_msg))
                goto wrapup;

       status = om$send(msg = message GRgraphics.GRxform(
			&om_msg,
			mod_env,matrix_type,matrix,newobjid),
			targetid = child_linkage[0].S_objid,
                        targetos = child_linkage[0].osnum);
       if(!(status & 1 & om_msg))
                goto wrapup;

    }
wrapup:

    {
        om_msg = OM_S_SUCCESS;
        *cont = TRUE;
        GR_NOTIFY_LISTENERS(msg, &om_msg, GR_GEOM_XFORMED);
    }

    return (OM_S_SUCCESS);
}
end implementation EMSdrawview;
