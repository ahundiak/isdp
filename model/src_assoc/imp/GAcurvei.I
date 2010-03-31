class implementation GAcurve;

#include "OMmacros.h"

/*
 * File compiles with warnings on these two lines, but there is no
 * reasonable solution that I know. AIC
 */
from GAcompcurve import GRdetplane;
from GAbspline import GRdetplane;

from EMSboundary import EMgetsurface_info;

method GAreturn_yourself (IGRlong *EMmsg; struct GRid *edge_GRid;
                          struct GRid *msc_GRid)
{
 IGRlong status;
 int is_msc;
 OM_S_OBJID edge_id;
 OMuword edge_os;

 status = OM_S_SUCCESS;
 *EMmsg = MSSUCC;

 om$send (msg = message GAcurve.GAis_msc(EMmsg, &is_msc),
          targetid = my_id);

 if (!is_msc) return (OM_S_SUCCESS);
 
 status = om$send(msg = message GAcurve.GAget_msc_component(
                         EMmsg, &edge_id,
                         &edge_os),
                  targetid = my_id);
 if (!(1&status&*EMmsg)) goto wrapup;

 if ((edge_GRid->objid == edge_id) &&
     (edge_GRid->osnum == edge_os))
 {
  msc_GRid->objid = my_id;
  msc_GRid->osnum = OM_Gw_current_OS;
 }

wrapup:
 status = OM_I_STOP_SENDING;
 return (status);
}

method GRdetplane(
  IGRlong	*msg; 
  IGRshort	*matrix_type; 
  IGRmatrix	matrix;
  struct	IGRplane *plane)
/* ******************************************************************
Description
 This method is being overriden to prevent flipping problems in
 curves that are mirror copied. In such a case, the plane normal
 is determined from the parent curve if it exists.

History
 AIC:06/11/93 : Return appropriate return codes
 pp: 07/16/92 : Creation

 ***************************************************************** */

{
 IGRlong status;
 IGRuint info_size;
 IGRlong msg_loc;
 IGRuint type;
 IGRint is_msc = FALSE;
 IGRchar *info_ptr;
 struct IGRplane temp_plane;
 IGRvector normal;
 IGRpoint point;

 temp_plane.normal = normal;
 temp_plane.point = point;

 status = OM_S_SUCCESS;
 *msg = MSSUCC;

 if( me->type != EMSuniq_normal) /* Else return stored normal */
   {
     if (EFisAncestryValid(&msg_loc, my_id, OM_Gw_current_OS, 
			   OPP_GRcompcurve_class_id, FALSE))
       {
	 status = om$send (mode = OM_e_wrt_parent,
			   msg = message GAcompcurve.GRdetplane(msg,
				 matrix_type, matrix, plane),
			   targetid = my_id);
	 EMerr_hndlr(!(1&status&*msg), *msg, MSFAIL, wrapup);
       }
     else
       {
	 status = om$send (mode = OM_e_wrt_parent,
			   msg = message GAbspline.GRdetplane(msg,
				 matrix_type, matrix, plane),
			   targetid = my_id);
	 EMerr_hndlr(!(1&status&*msg), *msg, MSFAIL, wrapup);
       }
   }

 if (me->type == EMS_ASfunction || me->type == EMSuniq_normal)
 {
   status = om$send (msg = message EMSassoc.EMget_info(&msg_loc,NULL,&type,
                           &info_size, NULL),
                     targetid = my_id);
   EMerr_hndlr(!(1&status), *msg, MSFAIL, wrapup);

   if (info_size > 0)
   {
     info_ptr = (IGRchar *) stackalloc(info_size);
     EMerr_hndlr(!info_ptr, *msg, EMS_E_NoStackMemory, wrapup);
   }
   else
     info_ptr = NULL;

   status = om$send (msg = message EMSassoc.EMget_info(&msg_loc, NULL, &type,
                         &info_size, 
                         &info_ptr),
                   targetid = my_id);
   EMerr_hndlr(!(1&status), *msg, MSFAIL, wrapup);

   if( type == EMSuniq_normal)
     {
       OM_BLOCK_MOVE(info_ptr,plane->point,3*sizeof(double));
       OM_BLOCK_MOVE(info_ptr + 3*sizeof(double), plane->normal,3*sizeof(double));
       return(status);
     }
   if (!(strcmp(info_ptr,"EFmirror_copy")))
   {
    struct GRid curve_GRid;
    struct GRmd_env md_env;
    OM_S_CHANSELECT father;

    curve_GRid.objid = NULL_OBJID;

    EMmake_chanselect(NDfather_father, &father);
/*
 * Index 0 on the parent channel is the parent curve.
 */

    om$send (msg = message NDnode.ASreturn_go(&curve_GRid,
                            &md_env.md_env.matrix_type, 
                             md_env.md_env.matrix),
                      p_chanselect = &father,
                      from = 0,
                      to = 0);
    if (curve_GRid.objid != NULL_OBJID)
    {
      status = om$send ( msg = message GRcurve.GRdetplane(msg,
                           &md_env.md_env.matrix_type, 
                           md_env.md_env.matrix, 
                           &temp_plane),
                     targetid = curve_GRid.objid,
                     targetos = curve_GRid.osnum);
      if (*msg == MSSUCC)
      {
        OM_BLOCK_MOVE(temp_plane.normal, plane->normal, sizeof (IGRvector));
      }
    }
   }
 }
 else
 {
  om$send (msg = message GAcurve.GAis_msc(&msg_loc, &is_msc),
          targetid = my_id);

  if (is_msc)
  {
   OM_S_OBJID component_id, srfid;
   OMuword component_os;

   component_id = NULL_OBJID;
   srfid = NULL_OBJID;

   om$send (msg = message GAcurve.GAget_msc_component(&msg_loc,
                           &component_id, &component_os),
                     targetid = my_id);
   if (component_id != NULL_OBJID)
   {
     om$send (msg = message EMSboundary.EMgetsurface_info(&msg_loc,
                    &srfid, NULL),
              targetid = component_id,
              targetos = component_os);

     if (srfid != NULL_OBJID)
     {

      om$send (msg = message GRvg.GRdetplane(&msg_loc,matrix_type, matrix,
                     &temp_plane),
              targetid = srfid,
              targetos = component_os);
      if (1&msg_loc)
      {
        OM_BLOCK_MOVE(temp_plane.normal, plane->normal, sizeof (IGRvector));
      }
     }
   }
  }
 }

wrapup:
 return (status);
}

#include <stdio.h>
#include "REcurve.h"
#include "EMSkey.h"

extern OMuword OPP_GR3dlineseg_class_id;
extern OMuword OPP_GR3dcircle_class_id;
extern OMuword OPP_GR3dcirarc_class_id;
extern OMuword OPP_GR3dlinestr_class_id;
extern OMuword OPP_GR3dellipse_class_id;
extern OMuword OPP_GR3dellarc_class_id;
extern OMuword OPP_GR3dpoint_class_id;
extern OMuword OPP_GR3dpolygon_class_id;
extern OMuword OPP_GR3dorthpoly_class_id;
extern OMuword OPP_GR3dorthlnst_class_id;
extern OMuword OPP_GR3dpllnstr_class_id;
extern OMuword OPP_GR3dinfline_class_id;
extern OMuword OPP_EMScomposite_class_id;
extern OMuword OPP_GRsubbc_class_id;
extern OMuword OPP_GRvg_class_id;


method debug()
/*
Description
    This method prints the associative type and info for this model space
    counterpart and then sends the debug message on to its parent so that
    its geometry will also be printed.

History
   WBC    04/21/93  Creation.
*/
{
    IGRlong              OM_stat;
    IGRint               index,
                         num_keys,
                         assoc_type;
    IGRuint              info_size;
    struct EMSobjid_key *objid_key;
    struct EMSkey       *key;
    OM_S_MESSAGE         debug_msg;
    OM_S_OBJID           component_id;
    GRclassid            classid;
    IGRchar              classname[OM_K_MAXCLASS_LEN];

    /* determine which parent class the debug message should be sent to
     * based on the current object's classid
     */

    OM_stat = om$get_classid(objid = my_id,
                             p_classid = &classid);

    if (1 & OM_stat)
    {
        if (om$is_ancestry_valid(superclassid = OPP_GR3dlineseg_class_id,
                                 subclassid = classid) == (OM_S_SUCCESS))
            strcpy(classname, "GR3dlineseg");
        else if (om$is_ancestry_valid(superclassid = OPP_GR3dcircle_class_id,
                                      subclassid = classid) == (OM_S_SUCCESS))
            strcpy(classname, "GR3dcircle");
        else if (om$is_ancestry_valid(superclassid = OPP_GR3dcirarc_class_id,
                                      subclassid = classid) == (OM_S_SUCCESS))
            strcpy(classname, "GR3dcirarc");
        else if (om$is_ancestry_valid(superclassid = OPP_GR3dlinestr_class_id,
                                      subclassid = classid) == (OM_S_SUCCESS))
            strcpy(classname, "GR3dlinestr");
        else if (om$is_ancestry_valid(superclassid = OPP_GR3dellipse_class_id,
                                      subclassid = classid) == (OM_S_SUCCESS))
            strcpy(classname, "GR3dellipse");
        else if (om$is_ancestry_valid(superclassid = OPP_GR3dellarc_class_id,
                                      subclassid = classid) == (OM_S_SUCCESS))
            strcpy(classname, "GR3dellarc");
        else if (om$is_ancestry_valid(superclassid = OPP_GR3dpoint_class_id,
                                      subclassid = classid) == (OM_S_SUCCESS))
            strcpy(classname, "GR3dpoint");
        else if (om$is_ancestry_valid(superclassid = OPP_GR3dpolygon_class_id,
                                      subclassid = classid) == (OM_S_SUCCESS))
            strcpy(classname, "GR3dpolygon");
        else if (om$is_ancestry_valid(superclassid = OPP_GR3dorthpoly_class_id,
                                      subclassid = classid) == (OM_S_SUCCESS))
            strcpy(classname, "GR3dorthpoly");
        else if (om$is_ancestry_valid(superclassid = OPP_GR3dorthlnst_class_id,
                                      subclassid = classid) == (OM_S_SUCCESS))
            strcpy(classname, "GR3dorthlnst");
        else if (om$is_ancestry_valid(superclassid = OPP_GR3dpllnstr_class_id,
                                      subclassid = classid) == (OM_S_SUCCESS))
            strcpy(classname, "GR3dpllnstr");
        else if (om$is_ancestry_valid(superclassid = OPP_GR3dinfline_class_id,
                                      subclassid = classid) == (OM_S_SUCCESS))
            strcpy(classname, "GR3dinfline");
        else if (om$is_ancestry_valid(superclassid = OPP_EMScomposite_class_id,
                                      subclassid = classid) == (OM_S_SUCCESS))
            strcpy(classname, "EMScomposite");
        else if (om$is_ancestry_valid(superclassid = OPP_GRsubbc_class_id,
                                      subclassid = classid) == (OM_S_SUCCESS))
            strcpy(classname, "GRsubbc");
        else if (om$is_ancestry_valid(superclassid = OPP_GRvg_class_id,
                                      subclassid = classid) == (OM_S_SUCCESS))
            strcpy(classname, "GRvg");
        else
            strcpy(classname, "GRgraphics");
    }
    else
        strcpy(classname, "GRgraphics");

    OM_stat = om$make_message(classname = classname,
                              methodname = "debug",
                              size = OPPmargs->size,
                              p_arglist = OPPmargs->p_arglist,
                              p_msg = &debug_msg);

    /* list the MSC's id and geometry */

    if (1 & OM_stat)
    {
        om$send(mode = OM_e_wrt_message,
                msg = &debug_msg,
                targetid = my_id);
    }
    else
    {
        om$send(mode = OM_e_wrt_parent,
                msg = message GRcurve.debug(),
                targetid = my_id);
    }

    info_size = om$dimension_of(varray = ME.EMSassoc->info);

    fprintf(stderr, "ME.EMSassoc->info array size = %d\n", info_size);

    switch (ME.EMSassoc->type)
    {
        case EMSmsc_id:

            fprintf(stderr, "ME.EMSassoc->type = EMSmsc_id\n");
            component_id = *(OM_S_OBJID *)ME.EMSassoc->info;

            if (component_id == NULL_OBJID)
                fprintf(stderr, "Component id = NULL_OBJID\n");
            else
                fprintf(stderr, "Component id = %d\n", component_id);
            break;

        case EMSmsc_key:

            fprintf(stderr, "ME.EMSassoc->type = EMSmsc_key\n");
            key = (struct EMSkey *) ME.EMSassoc->info;
            num_keys = info_size / sizeof(struct EMSkey);

            for (index = 0; index < num_keys; index = index + 1)
            {
                fprintf(stderr, "key[%d].sub_item_type = %hd\n", index, key[index].sub_item_type);
                fprintf(stderr, "key[%d].chan_count = %hd\n", index, key[index].chan_count);
                fprintf(stderr, "key[%d].chan_index = %hd\n", index, key[index].chan_index);
            }
            break;

        case EMSmsc_id_key:

            fprintf(stderr, "ME.EMSassoc->type = EMSmsc_id_key\n");
            objid_key = (struct EMSobjid_key *) ME.EMSassoc->info;
            key = (struct EMSkey *) objid_key->key_info;
            num_keys = (info_size - sizeof (struct EMSobjid_key)) / sizeof(struct EMSkey);

            if (objid_key->objid == NULL_OBJID)
                fprintf(stderr, "Component id = NULL_OBJID\n");
            else
                fprintf(stderr, "Component id = %d\n", objid_key->objid);

            for (index = 0; index < num_keys; index = index + 1)
            {
                fprintf(stderr, "key[%d].sub_item_type = %hd\n", index, key[index].sub_item_type);
                fprintf(stderr, "key[%d].chan_count = %hd\n", index, key[index].chan_count);
                fprintf(stderr, "key[%d].chan_index = %hd\n", index, key[index].chan_index);
            }
            break;

        case EMSmsc_match_failed:

            fprintf(stderr, "ME.EMSassoc->type = EMSmsc_match_failed\n");
            break;

        default:

            assoc_type = (IGRint) ME.EMSassoc->type;
            fprintf(stderr, "ME.EMSassoc->type = %d (unknown)\n", assoc_type);
            break;
    }

    return(OM_S_SUCCESS);
}


end implementation GAcurve;

