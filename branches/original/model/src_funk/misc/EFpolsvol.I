/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

#define INCREMENT 10

#include "EMS.h" /* For shared libraries */
#include "OMmacros.h" /* For OM_BLOCK_MOVE */
#include "EMSconstruct.h" /* For EMS_S_INSOLID */
#include "EMSerrordef.h" /* For EMSerror definitions */

from EMSsolid import EMpoint_locate;

IGRlong EFreturn_poles_within_solid(EMmsg,insurf,surf_env,surf_GRid,solid_env,
                                    solid_GRid,num_poles,buff_size,b_indices,
                                    b_poles,m_indices,m_poles)
IGRlong *EMmsg;
struct IGRbsp_surface *insurf;
struct GRmd_env *surf_env;
struct GRid *surf_GRid;
struct GRmd_env *solid_env;
struct GRid *solid_GRid;
IGRint *num_poles;
IGRint buff_size;
IGRint *b_indices;
IGRdouble *b_poles;
IGRint **m_indices;
IGRint **m_poles;
{
 IGRlong status;
 IGRlong location;
 IGRint i,j;
 struct IGRbsp_surface *surf = NULL;
 IGRchar *geom = NULL;
 IGRboolean malloc_done = FALSE;
 IGRdouble point[3],*pt;
 IGRboolean world = TRUE;
 IGRpoint *pole_ptr = NULL;
 IGRint *index_ptr = NULL;
 IGRint total_poles;
 IGRpoint range[2];
 enum EMSdatatype type;

 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;

 if (m_indices)
  *m_indices = NULL;

 if (m_poles)
  *m_poles = NULL;


 if (insurf)
  surf = insurf;
 else if (surf_env && surf_GRid)
 {
  EMgetvggeom(EMmsg, &surf_env->md_env.matrix_type, surf_env->md_env.matrix,
             surf_GRid, &geom, &type);
  EMerr_hndlr(!(1&*EMmsg), *EMmsg, EMS_E_SurfaceError, wrapup);
        
  EMerr_hndlr((type != EMSdata_surface), *EMmsg, EMS_E_InvalidArg, wrapup);
 
  surf = (struct IGRbsp_surface *) geom;
 }
 else
 {
  *EMmsg = EMS_E_InvalidArg;
  goto wrapup;
 }

 *num_poles = 0;

 if (b_poles)
  pole_ptr = (IGRpoint *)b_poles;
 if (b_indices)
  index_ptr = b_indices;

 status = om$send (msg = message GRvg.GRgetrang (EMmsg, 
                       &solid_env->md_env.matrix_type, 
                        solid_env->md_env.matrix, &world,
                      (IGRdouble *)range),
                   senderid = NULL_OBJID,
                   targetid = solid_GRid->objid,
                   targetos = solid_GRid->osnum);
 EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_SurfaceError, wrapup);

 total_poles = surf->u_num_poles * surf->v_num_poles;

 for (i=0;i<total_poles;i++)
 {
   if (surf->rational)
   {
    for (j=0;j<3;j++)
      point[j] = surf->poles[3*i+j]/surf->weights[i];
    pt = point;
   }
   else
    pt = &surf->poles[3*i];

   location = EMS_S_UNKNOWN;

   status = om$send (msg = message EMSsolid.EMpoint_locate(EMmsg, solid_env,
                           NULL,pt,range, (IGRulong *)&location),
                     senderid = NULL_OBJID,
                     targetid = solid_GRid->objid,
                     targetos = solid_GRid->osnum);
   EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

   if (location == EMS_S_INSOLID)
   {
    (++*num_poles);

    if (*num_poles > buff_size)
    {
     if (malloc_done)
     {
      if (m_indices)
      {
       *m_indices = (IGRint *) om$realloc(ptr = (char (*))(*m_indices),
                                    size = (sizeof (IGRint)) *
                                    (*num_poles + INCREMENT));
       EMerr_hndlr(!(*m_indices), *EMmsg, EMS_E_DynamicMemoryAllocated,
                   wrapup);
      pole_ptr = (IGRpoint *) (&((*m_poles)[3*(*num_poles - 1)]));
      }

      if (m_poles)
      {
       *m_poles =  (IGRint *)om$realloc(ptr = (char (*))(*m_poles),
                                      size = (sizeof (IGRdouble)) * 3 *
                                      (*num_poles + INCREMENT));
       EMerr_hndlr(!(*m_poles), *EMmsg, EMS_E_DynamicMemoryAllocated,
                    wrapup);
       index_ptr = (IGRint *) (&((*m_indices)[*num_poles - 1]));
      }

      buff_size = (*num_poles + INCREMENT);

     }
     else
     {
      if (m_indices)
      {
       *m_indices = (IGRint *)om$malloc(size = (sizeof (IGRint)) *
                                      (*num_poles + INCREMENT));
       EMerr_hndlr(!(*m_indices), *EMmsg, EMS_E_DynamicMemoryAllocated,
                  wrapup);
       OM_BLOCK_MOVE(b_indices,*m_indices,buff_size * (sizeof (IGRint)));
       index_ptr = (IGRint *)(&((*m_indices)[*num_poles - 1]));
      }

      if (m_poles)
      {
       *m_poles = (IGRint *)om$malloc(size = (sizeof (IGRdouble)) * 3 *
                                       (*num_poles + INCREMENT));
       EMerr_hndlr(!(*m_poles), *EMmsg, EMS_E_DynamicMemoryAllocated,
                   wrapup);
       OM_BLOCK_MOVE(b_poles, *m_poles, buff_size * (sizeof (IGRpoint)));

       pole_ptr = (IGRpoint *)(&((*m_poles)[3*(*num_poles - 1)]));
      }


      buff_size = (*num_poles + INCREMENT);
      malloc_done = TRUE;

    }
   }

   if (pole_ptr)
   {
    OM_BLOCK_MOVE(pt,pole_ptr,3*(sizeof (IGRpoint)));
    ++(pole_ptr);
   }

   if (index_ptr)
   {
    *index_ptr = i;
    ++(index_ptr);
   }
  } /* End if the pole is in solid */
 }

wrapup:
 if (!(1&*EMmsg&status))
 {
  if (malloc_done)
  {
   if (m_indices && (*m_indices))
   {
     om$dealloc(ptr = (*m_indices));
     *m_indices = NULL;
   }
   if (m_poles && (*m_poles)) 
   {
     om$dealloc(ptr = (*m_poles));
     *m_poles = NULL;
   }
  }
 }
 if (!insurf && surf) om$dealloc (ptr = surf);
 return (status);
}
end implementation EMSsubbs;

