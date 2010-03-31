/*

Name
  GRcopy

Abstract
  Copy a profile element into a corresponding wireframe element.
  
Synopsis

Description

Return Value

Notes

Index

Keywords
  composite,copy,profile

History
  08/30/93 : Rajiv Agrawal : Fixed the copy of an SKpoint.  If the point is part of
                             an arc, ignore the copy.
  10/06/93 : Rajiv Agrawal : Added support for Bspline copy.
  08/18/94 : Sudha         : Fix for TR# 119419168 MDS problem. - SKbspline is 
		             not understood by MDS, it fails while doing a copy
			     of an arc in MDS. To fix, check the return code properly.

 */
class implementation SKgeometry;

extern GRclassid OPP_SKline_class_id, OPP_SKarc_class_id, OPP_SKcircle_class_id,
                 OPP_SKpoint_class_id, OPP_SKcompcurve_class_id,
                 OPP_SKbspline_class_id;

from GRcompcurve import GRcopy;
from GR3dlineseg import GRcopy;
from GR3dcircle import GRcopy;
from GR3dpoint import GRcopy;
from GR3dcirarc import GRcopy;
from GRbcsubbc  import GRcopy;
extern IGRboolean WANT_POST220_BEHAVIOR;

method GRcopy(IGRlong *msg; struct GRmd_env *obj_dsenv;
              struct GRmd_env *new_dsenv; GRobjid *newobjid)
{
 IGRlong OM_stat;
 IGRchar new_class[12];
 OMuword my_classid;
 
 /* ******************************************************************* */
 
 OM_stat = OM_S_SUCCESS;
 *msg = EMS_S_Success;
 
/*
 OM_stat = om$send (msg = message GRgraphics.GRcopy(msg,obj_dsenv,new_dsenv,
                     newobjid),
                    mode = OM_e_wrt_ancestor,
                    targetid =  my_id);
 EMerr_hndlr(!(1&OM_stat&*msg), *msg, MSFAIL, wrapup);
*/
 
 /*
  * Direct invokation of GRcopy on me tells that i have to be non-variational
  * copy. In such a case, change my class to appropriate GRclass.
  */

 OM_stat = om$get_classid (object = me, p_classid = &my_classid);
 EMerr_hndlr (!(1&OM_stat), *msg, EMS_E_OMerror, wrapup);

 OM_stat = om$is_ancestry_valid (subclassid = my_classid,
                                 superclassid = OPP_SKcompcurve_class_id);
 EMerr_hndlr (!(1&OM_stat), *msg, EMS_E_OMerror, wrapup);

 if (OM_stat == OM_S_SUCCESS)
 {
   strcpy (new_class, "GRcompcurve");
   OM_stat = om$send (msg = message GRcompcurve.GRcopy(msg,obj_dsenv,new_dsenv,
                     newobjid),
                    mode = OM_e_wrt_message,
                    targetid =  my_id);
   EMerr_hndlr(!(1&OM_stat&*msg), *msg, MSFAIL, wrapup);
 }
 else
 {
   OM_stat = om$is_ancestry_valid (subclassid = my_classid,
                                   superclassid = OPP_SKline_class_id);
   EMerr_hndlr (!(1&OM_stat), *msg, EMS_E_OMerror, wrapup);

   if (OM_stat == OM_S_SUCCESS)
   {
     strcpy (new_class, "GR3dlineseg");
     OM_stat = om$send (msg = message GR3dlineseg.GRcopy(msg,obj_dsenv,new_dsenv,
                     newobjid),
                    mode = OM_e_wrt_message,
                    targetid =  my_id);
     EMerr_hndlr(!(1&OM_stat&*msg), *msg, MSFAIL, wrapup);
   }
   else
   {
     OM_stat = om$is_ancestry_valid (subclassid = my_classid,
                                     superclassid = OPP_SKarc_class_id);
     EMerr_hndlr (!(1&OM_stat), *msg, EMS_E_OMerror, wrapup);
     if (OM_stat == OM_S_SUCCESS)
     {
       strcpy (new_class, "GR3dcirarc");
       OM_stat = om$send (msg = message GR3dcirarc.GRcopy(msg,obj_dsenv,
                               new_dsenv,
                      newobjid),
                     mode = OM_e_wrt_message,
                     targetid =  my_id);
       EMerr_hndlr(!(1&OM_stat&*msg), *msg, MSFAIL, wrapup);
     }
     else
     {
       OM_stat = om$is_ancestry_valid (subclassid = my_classid,
                                       superclassid = OPP_SKcircle_class_id);
       EMerr_hndlr (!(1&OM_stat), *msg, EMS_E_OMerror, wrapup);
       if (OM_stat == OM_S_SUCCESS)
       {
        strcpy (new_class, "GR3dcircle");
        OM_stat = om$send (msg = message GR3dcircle.GRcopy(msg,obj_dsenv,
                               new_dsenv,
                     newobjid),
                    mode = OM_e_wrt_message,
                    targetid =  my_id);
        EMerr_hndlr(!(1&OM_stat&*msg), *msg, MSFAIL, wrapup);
       }
       else
       {
         OM_stat = om$is_ancestry_valid (subclassid = my_classid,
                                         superclassid = OPP_SKbspline_class_id);

	 /* fix for TR# 119419168 - for MDS 
	    ignore the return code unless it is ABORT */
	 if ( (OM_stat != OM_E_INVARG) && ( OM_stat != OM_E_NOSUCHCLASS) )
           EMerr_hndlr (!(1&OM_stat), *msg, EMS_E_OMerror, wrapup);
  
         if (OM_stat == OM_S_SUCCESS)
         {
          strcpy (new_class, "GRbcsubbc");
          OM_stat = om$send (msg = message GRbcsubbc.GRcopy(msg,obj_dsenv,
                                 new_dsenv,
                       newobjid),
                      mode = OM_e_wrt_message,
                      targetid =  my_id);
          EMerr_hndlr(!(1&OM_stat&*msg), *msg, MSFAIL, wrapup);
         }
         else
         {
           struct GRid ptvar;
           OMuint count;
           OM_S_CHANSELECT     	to_geometries, to_defpts;
           /*
            * Check if the point is connected to an arc/bspline.  If so, copy is a null
            * operation.
            */
           EMmake_chanselect ( SKgeometry_to_defpts, &to_defpts );
           EMmake_chanselect ( SKvariable_to_geometries, &to_geometries );
           om$get_objid_at_index ( objid = my_id, p_chanselect = &to_defpts,
                                   index = 0,
                                   objidaddr = &ptvar.objid, osnumaddr = &ptvar.osnum );
           om$get_channel_count ( objid = ptvar.objid, p_chanselect = &to_geometries,
                                  count = &count );
           if ((count == 1) && WANT_POST220_BEHAVIOR)
           {
             strcpy (new_class, "GR3dpoint");
             OM_stat = om$send (msg = message GR3dpoint.GRcopy(msg,obj_dsenv,
                                      new_dsenv,
                                      newobjid),
                                mode = OM_e_wrt_message,
                                targetid =  my_id);
             EMerr_hndlr(!(1&OM_stat&*msg), *msg, MSFAIL, wrapup);
           }
           else
           {
             OM_stat = OM_S_SUCCESS;
             *msg = EMS_S_Success;
             *newobjid = NULL_OBJID;
             goto wrapup;
           }
         }
        }
      }
    }
  }

  OM_stat = om$change_class (osnum = new_dsenv->md_id.osnum,
               objid = *newobjid, classname = new_class);
  EMerr_hndlr (!(1&OM_stat), *msg, EMS_E_OMerror, wrapup);
              
wrapup:
 EMWRAPUP (*msg, OM_stat, "SKgeometry.GRcopy");
 return (OM_stat);
}
end implementation SKgeometry;
