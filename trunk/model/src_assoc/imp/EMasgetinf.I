/* ###################   APOGEE COMPILED   ################## */
class implementation EMSassoc;

#include "EMS.h"
#include "parametric.h"
#include "exmacros.h" /* For ex$get_modid */
#include "emserr.h"
#include "nddef.h"
#include "EMSerrordef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h" /* For gr$get_module_env */
#include "OMmacros.h"
#include "maidmx.h"

extern OMuword OPP_ASsource_class_id;

from EMSparamgm import EMgetgeom;

method EMget_parent_info(IGRlong *EMmsg;
                         IGRushort options;
                         IGRuint root_count;
                         IGRchar *parent_info;
                         IGRuint *root_type;
                         union EMSparent_info *roots)

/* *********************************************************************
Description
 This message returns information about the parents. This
 indirection is necessary for potentially solving the problem of
 reference files associativity.

Arguments
 Input
  options : Ubiquitous options field. Currently not supported.
  root_count: Number of parents that are being passed in, if known.
  parent_info: Information about the parents.
  root_type: Type of the root. The caller needs to indicate a type for
             each parent. For eg: If he wants to interpret his first
             parent as a distance parameter, second as point and 
             third as object then he says:
             root_type[0] = EMSdistance;
             root_type[1] = EMSpoint;
             root_type[2] = EMSgrid;
             This is defined in EMSasdef.h

 Output
  Memory for roots has to be allocated and needs to
  be equal to the that corresponding to the number of parents.
  roots: Today a parent can either be returned as an xyzpoint,
         value for a parameter or an objectid, md_env pair depending
         on the type indicated.
         This structure is defined at EMSasdef.h

Notes
 Upon exit the completion code will be one of the following:
  EMS_S_Success : If all goes well.
  EMS_E_InvalidArg: If there is not a match between parent and type.
                    or if the parent list is not passed in.
  EMS_E_Fail: Fatalistic error.

History
   09/29/88 : PP : Creation
   04/03/91 : PP : Reworked for EMS 2.0.
   07/11/91 : pp : calling NDgive_structure instead of NDgive_value
   Sudha   06/01/93    modified to handle BSprototype headers
 ************************************************************************* */

{
 IGRlong status;
 IGRint loc_root_count;
 IGRuint *root_type_ptr = NULL;
 struct GRid *parent_info_ptr = NULL;

 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;

 if (!parent_info)
 {
  struct GRid *buf_ptr;
  buf_ptr = NULL;
  loc_root_count = 0;

  status = om$send (msg = message NDnode.NDget_objects(ND_IN_BUF | ND_ROOT,
                          NULL,0,&buf_ptr,0,MAXINT, &loc_root_count),
                    targetid = my_id);
  EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);
  EMerr_hndlr(!loc_root_count, *EMmsg, EMS_E_InvalidArg, wrapup);

  parent_info_ptr = (struct GRid *) stackalloc (loc_root_count * 
                                    sizeof (struct GRid));
  EMerr_hndlr(!parent_info_ptr, *EMmsg, EMS_E_DynamicMemoryAllocated,wrapup);
  OM_BLOCK_MOVE(buf_ptr, parent_info_ptr, loc_root_count *
                 sizeof (struct GRid));
 }
 else
 {
  loc_root_count = root_count;
  parent_info_ptr = (struct GRid *)parent_info;
 }

 if (!root_type)
 {
  IGRuint mytype;

  root_type_ptr = (IGRuint *) stackalloc (loc_root_count * 
                                    sizeof (IGRint));
  EMerr_hndlr(!root_type_ptr, *EMmsg, EMS_E_DynamicMemoryAllocated,wrapup);

  status = om$send (msg = message EMSassoc.EMget_info (EMmsg, NULL,
                          &mytype, NULL,NULL),
                    targetid = my_id);
  EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

  status = om$send (msg = message EMSassoc.EMget_parent_type(EMmsg,
                          mytype, loc_root_count,
                          root_type_ptr),
                    targetid = my_id);
  EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
 }
 else
  root_type_ptr = root_type;
  
 EFasget_parent_info(EMmsg, loc_root_count,root_type_ptr,
                     (struct GRid *)parent_info_ptr,
                     roots);
 EMerr_hndlr(!(1&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

wrapup:
 if (!root_type && root_type_ptr)
  stackfree (root_type_ptr);
 if (parent_info_ptr && !parent_info)
  stackfree (parent_info_ptr);
 EMWRAPUP (status, *EMmsg, "In EMSassoc:EMget_parent_info error"); 
 return (status);
}

EFasget_parent_info(EMmsg, root_count,root_type, list, root)

/* *****************************************************************
Description
 This function gets the geometric entity of the associative object based
on the root_type desired.

Arguments
 Input
  root_count : Number of roots whose geometric entity is desired.
  root_type : Type defined in EMSasnucdef.h
  list : list of associative objects.
  
 Output
  root: array containing geometric entity. Size should be at least
        equal to root_count.

Notes
 Upon exit the completion code will be one of the following:
 EMS_S_Success : If all goes well.
 EMS_E_Fail : If there was an error in the french code.
 EMS_E_InvalidArg: If the associative object is not of an appropriate
                   class to get the geometric entity of the type desired.
                   or
                   If the type desired is not supported.
 EMS_E_Fail : If there was an error in getting the module id of the
              graphic object.

History
 09/21/88 : PP : Creation

 ******************************************************************* */

IGRlong *EMmsg;
IGRint root_count;
IGRint *root_type;
struct GRid *list;
union EMSparent_info *root;
{
 IGRboolean aflag, mimic_source=0;
 IGRlong status, msg_loc;
 IGRshort i,j;
 struct GRmdenv_info *envinfo;
 struct GRid *md_id, *root_grid;
 struct GRmd_env env;
 struct ret_struct info_struct;
 IGRint bytes_in, bytes_out;
 GRspacenum osn;

 
 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
 msg_loc = EMS_S_Success;
 aflag = pwIsActivationOn();

 bytes_in = sizeof (struct GRmd_env);

 for (i=0;i<root_count;i++)
 {
   switch (root_type[i])
   {
    case EMSpoint:
    case EMSdistance:
    case EMSangle:
    case EMSscalar:
    {
      if(aflag)
      {
        pwGetActiveModuleEnv( &env);
      }
      else
      {
      /*
       * This should return a identity environment. In case of connections
       * across reference files it does not matter.
       */
        status = gr$get_module_env(msg = EMmsg,
                            sizbuf = &bytes_in,
                            buffer = &env,
                            nret = &bytes_out);
      }

      status = om$send (msg = message NDnode.NDgive_structure (EMmsg, 
                              &info_struct,
                              &env),
                        senderid = NULL_OBJID,
                        targetid = list[i].objid,
                        targetos = list[i].osnum);
      EMerr_hndlr (!(1&status), *EMmsg, EMS_E_Fail, wrapup);                             
      if (info_struct.type == point_generic)
      {
       for (j=0;j<3;j++)
        root[i].point[j] = info_struct.var.point_st.pt[j]; 
      }
      else if (info_struct.type & parameter_generic)
      {
        root[i].value = info_struct.var.root_pm_st.value;
      }
      else
      {
       *EMmsg = EMS_E_InvalidArg;
       goto wrapup;
      }
    }
    break;

    case EMSgrid:
    case EMSlcinfo:
    {
      if (root_type[i] == EMSgrid)
      {
        envinfo = &root[i].grobj.env.md_env;
        md_id = &root[i].grobj.env.md_id;
        root_grid = &root[i].grobj.grid;
      }
      else
      {
        envinfo = &root[i].lc_info.module_info.md_env;
        root_grid = &root[i].lc_info.located_obj;
        md_id = &root[i].lc_info.module_info.md_id;
      }

      if(aflag)
      {
        osn = pwGetActiveOs();

        if(osn == OM_Gw_current_OS)
        {
          if(!EFisAncestryValid( &msg_loc, list[i].objid, list[i].osnum,
                                OPP_ASsource_class_id, FALSE))
          {
            mimic_source = TRUE;
            pwGetActiveModuleEnv(&env);
          }
        }
      }

      status = om$send (msg = message NDnode.ASreturn_go(root_grid,
                            &envinfo->matrix_type, envinfo->matrix),
                        senderid = NULL_OBJID,
                        targetid = list[i].objid,
                        targetos = list[i].osnum);
      EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);

      if(mimic_source)
      {
        memcpy(envinfo->matrix, env.md_env.matrix, sizeof(IGRmatrix));
        envinfo->matrix_type = env.md_env.matrix_type;
      }

      md_id->osnum = root_grid->osnum;
      md_id->objid = NULL_OBJID;
    }
    break;

    case EMSvector:
    {
     IGRshort mattyp;
     IGRmatrix mat;
     struct EMSgeomdata vecdata;

     if(aflag)
     {
       pwGetActiveModuleEnv(&env);
       memcpy(mat, env.md_env.matrix, sizeof(IGRmatrix));
       mattyp = env.md_env.matrix_type;
     }
     else
     {
      /*
       *  To be consistent with other pieces, send identity matrix -gvk 
       * 
       */
        status = gr$get_module_env(msg = EMmsg,
                            sizbuf = &bytes_in,
                            buffer = &env,
                            nret = &bytes_out);

     /*
      * For now do not worry about context objects for ref-files. Just
      * use an identity matrix to compute vector.
      */

     mattyp = MAIDMX;
     MAidmx (EMmsg, mat);
     }

     vecdata.geomtype = GEOMDATA_NULL;
     envinfo = &root[i].grobj.env.md_env;

    if(EFisAncestryValid(EMmsg,list[i].objid,
			 list[i].osnum,
			 OPP_EMSparamgm_class_id,FALSE))
      {
	status = om$send (msg = message EMSparamgm.EMgetgeom (EMmsg, NULL,
               &mattyp, mat, &vecdata), targetid = list[i].objid,
               targetos = list[i].osnum, senderid = NULL_OBJID);
	EMerr_hndlr (EMSerror (status & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);

	OM_BLOCK_MOVE (vecdata.vector, root[i].vector, sizeof (IGRvector));
      }
     else
     {

	 /* Must be associative clone */
	 status = om$send (msg = message NDnode.NDgive_structure (EMmsg, 
                              &info_struct,
                              &env),
			   senderid = NULL_OBJID,
			   targetid = list[i].objid,
			   targetos = list[i].osnum);
	 EMerr_hndlr (!(1&status), *EMmsg, EMS_E_Fail, wrapup); 
	OM_BLOCK_MOVE (info_struct.var.line_st.v0,root[i].vector, 
	               sizeof (IGRvector));
       }
    }
    break;

    default:
    {
     *EMmsg = EMS_E_InvalidArg;
     goto wrapup;
    }
   }
 }

wrapup:
 EMWRAPUP (*EMmsg, status, "In EFasget_struct error");
 return status;
}
end implementation EMSassoc;

