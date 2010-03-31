/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

/*
   HISTORY

        Sudha   07/08/93        Modified for BSprototypes ansification
*/

#define INCREMENT 10
#define MAX_BUFF 500

#include "EMS.h" /* For shared libraries */
#include "OMmacros.h" /* For OM_BLOCK_MOVE */
#include "EMSerrordef.h" /* For EMSerror definitions */
#include "bsunwght_p.h"

from GRgsmgr import GRget_prism_size, GRget_prism;

IGRlong EFreturn_poles_within_fence(EMmsg,insurf,surf_env,surf_GRid,fence_env,
                                    fence_GRid,inprism_type,inprism,
                                    num_poles,buff_size,b_indices,
                                    b_poles,m_indices,m_poles)
IGRlong *EMmsg;
struct IGRbsp_surface *insurf;
struct GRmd_env *surf_env;
struct GRid *surf_GRid;
struct GRmd_env *fence_env;
struct GRid *fence_GRid;
IGRint inprism_type;
IGRchar *inprism;
IGRint *num_poles;
IGRint buff_size;
IGRint *b_indices;
IGRdouble *b_poles;
IGRint **m_indices;
IGRint **m_poles;
{
 IGRlong sts;
 IGRint i,j;
 struct IGRbsp_surface *surf = NULL;
 IGRchar *geom = NULL;
 IGRint total_poles;
 IGRint indicator_array[MAX_BUFF];
 enum EMSdatatype type;
 IGRint size;
 IGRchar *prism_ptr = NULL;
 IGRboolean malloc_done = FALSE;
 IGRdouble *pole_ptr = NULL;
 IGRint *index_ptr = NULL;
 struct GRmd_env *md_env;
 struct GRid window_GRid;
 IGRpoint ptsbuff[MAX_BUFF];
 IGRint   ind_buff[MAX_BUFF];
 IGRdouble *unweighted_poles = NULL;
 IGRint   *ind = NULL;
 IGRboolean poles_unweighted = FALSE;
 IGRint  prism_type,num_poles_fence,num_weights_fence,num_knots_fence,
         num_boundaries_fence;
 IGRint pole_index,weight_index,weight_offset,pole_offset;
 struct IGRpointset ptset;

 *EMmsg = EMS_S_Success;
 sts = OM_S_SUCCESS;
 if (m_indices)
  *m_indices = NULL;

 if (m_poles)
  *m_poles = NULL;

 *num_poles = 0;

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

 total_poles = surf->u_num_poles * surf->v_num_poles;

 if (inprism)
 {
  prism_ptr = inprism;
  prism_type = inprism_type;
 }
 else
 {
  sts = om$send (msg = message GRgsmgr.GRget_prism_size(EMmsg, fence_env,
                              &prism_type,&size,&num_poles_fence,
                              &num_weights_fence,
                              &num_knots_fence,&num_boundaries_fence),
                       senderid = NULL_OBJID,
                       targetid = fence_GRid->objid,
                       targetos = fence_GRid->osnum);
  if (!(1&sts&*EMmsg)) goto wrapup;

  prism_ptr = (IGRchar *) om$malloc(size = size);
  EMerr_hndlr(!prism_ptr,*EMmsg, EMS_E_DynamicMemoryAllocated,wrapup);

  sts = om$send (msg = message GRgsmgr.GRget_prism(EMmsg,fence_env,0,
                            prism_ptr,
                       &window_GRid),
                 senderid = NULL_OBJID,
                 targetid = fence_GRid->objid,
                 targetos = fence_GRid->osnum);
  EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
 }

 if (surf->rational)
 {
  if (surf->u_num_poles > MAX_BUFF)
  {
   unweighted_poles = (IGRdouble *)om$malloc(size = sizeof(IGRpoint) *
                                      surf->u_num_poles);
   EMerr_hndlr(!unweighted_poles,*EMmsg, EMS_E_DynamicMemoryAllocated,wrapup);
  }
  else
    unweighted_poles = (IGRdouble *) ptsbuff;

  ptset.points = unweighted_poles;
 }

 ptset.num_points = surf->u_num_poles;
 pole_index = 0;
 weight_index = 0;
 pole_offset = surf->u_num_poles * 3;
 weight_offset = surf->u_num_poles;

 if (b_poles)
  pole_ptr = b_poles;

 if (b_indices)
  index_ptr = b_indices;

 if (surf->u_num_poles > MAX_BUFF)
 {
   ind = (IGRint *) om$malloc(size = surf->u_num_poles * sizeof(IGRint));
   EMerr_hndlr(!ind, *EMmsg, EMS_E_DynamicMemoryAllocated,wrapup); 
 }
 else
   ind = ind_buff;

  for (i=0;i<surf->v_num_poles;i++)
  {
   if (surf->rational)
    sts = BSunwght_p(EMmsg, &surf->poles[pole_index], 
                          &surf->weights[weight_index],
                          &surf->u_num_poles, unweighted_poles);
    else
     ptset.points = (IGRdouble *) &surf->poles[pole_index];

   EFptsinfnc(EMmsg,&ptset,prism_type,prism_ptr,ind);
   EMerr_hndlr(!(1&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

   for (j=0;j<surf->u_num_poles;j++)
   {
    if (ind[j])
    {
     (++*num_poles);

     if (*num_poles > buff_size)
     {
      if (malloc_done)
      {
       if (m_indices)
       {
         *m_indices = (IGRint *) om$realloc(ptr = (char (*))(*m_indices),
                                    size = (OMuint) ((sizeof (IGRint)) *
                                    (*num_poles + INCREMENT)));
         EMerr_hndlr(!(*m_indices), *EMmsg, EMS_E_DynamicMemoryAllocated,
                     wrapup);
         index_ptr = &((*m_indices)[*num_poles - 1]);
       }

       if (m_poles)
       {
         *m_poles =  (IGRint *)om$realloc(ptr = (char (*))(*m_poles),
                                      size = (OMuint) ((sizeof (IGRdouble)) 
                                      * 3 *
                                      (*num_poles + INCREMENT)));
         EMerr_hndlr(!(*m_poles), *EMmsg, EMS_E_DynamicMemoryAllocated,
                   wrapup);
         pole_ptr = (IGRdouble (*)) (&((*m_poles)[3*(*num_poles - 1)]));
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
        index_ptr = &((*m_indices)[*num_poles - 1]);
       }

       if (m_poles)
       {
        *m_poles = (IGRint *)om$malloc(size = (sizeof (IGRdouble)) * 3 *
                                       (*num_poles + INCREMENT));
        EMerr_hndlr(!(*m_poles), *EMmsg, EMS_E_DynamicMemoryAllocated,
                   wrapup);
        OM_BLOCK_MOVE(b_poles, *m_poles, buff_size * (sizeof (IGRpoint)));
        pole_ptr = (IGRdouble (*)) (&((*m_poles)[3*(*num_poles - 1)]));
       }
        buff_size = (*num_poles + INCREMENT);
        malloc_done = TRUE;
       }
      }

      if (pole_ptr)
      {
       OM_BLOCK_MOVE(&ptset.points[3*j],pole_ptr,3*(sizeof (IGRpoint)));
       ++(pole_ptr);
      }

      if (index_ptr)
      {
       *index_ptr = i*(surf->u_num_poles) + j;
       ++(index_ptr);
      }
     } /* End if the pole is inside the fence */
    }
    pole_index += pole_offset;
    weight_index += weight_offset;
  }


wrapup:
 if (unweighted_poles && (unweighted_poles != ((IGRdouble *)ptsbuff)))
  om$dealloc(ptr = (unweighted_poles));

 if (ind && (ind != ind_buff))
  om$dealloc(ptr = ind_buff);

 if (!(1&*EMmsg&sts))
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

 if (!inprism && prism_ptr) om$dealloc(ptr = prism_ptr);
 if (!insurf && surf) om$dealloc (ptr = surf);
 return (sts);
}
end implementation EMSsubbs;

