/*
 * This file contains a collection of functions that are used in memory
 * management of the datatypes and structuresm used in "rounding".
 */

class implementation Root;

#include "OMerrordef.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "igetypedef.h"
#include "exdef.h"
#include "ex.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "msdef.h"
#include "madef.h"
#include "emsdattyp.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "EMSasnuc.h"
#include "EMSrnd.h"
#include "bstypes.h"

#define FIRST  0
#define SECOND 1

struct EMSrnd_tpint_info *EMtpint_info_free();

void EMSedge_rnd_info_free( EMmsg, num, ed_rnd_info )
IGRlong *EMmsg;
IGRint  num;
struct EMSedge_rnd_info *ed_rnd_info;
{
  IGRlong  om_stat,msg;
  IGRint   i, j;
  void EMSvtx_rnd_info_free();
  void EMtansf_rnd_info_free();

    *EMmsg = EMS_S_Success;
    om_stat= OM_S_SUCCESS;

    for( i = 0; i < num; i++)
    {
      /* Free the sub structures */

      if(ed_rnd_info[i].start_vtx) 
      {
           EMSvtx_rnd_info_free(&msg,1,ed_rnd_info[i].start_vtx);
           ed_rnd_info[i].start_vtx = NULL; 
      }

      if(ed_rnd_info[i].stop_vtx) 
      {
           EMSvtx_rnd_info_free(&msg,1,ed_rnd_info[i].stop_vtx);
           ed_rnd_info[i].stop_vtx = NULL; 
      }
     
      /* Free the rest of the fields. Since the memmory for the surface and
       * common surface is allocated by om$malloc(), om$dealloc must be used */
 
      if(ed_rnd_info[i].surf ) 
		om$dealloc(ptr = ed_rnd_info[i].surf);
      if(ed_rnd_info[i].com_surf )
		om$dealloc(ptr = ed_rnd_info[i].com_surf);
      if(ed_rnd_info[i].fill_surf ) 
		BSfreesf(&msg,ed_rnd_info[i].fill_surf);
      for (j=FIRST; j<=SECOND; j++)
        {
        if (ed_rnd_info[i].fill_isocvs[j])
          {
          BSfreecv (&msg, ed_rnd_info[i].fill_isocvs[j]);
          ed_rnd_info[i].fill_isocvs[j]=NULL;
          }
        EMdataselect_data_free (&msg, &ed_rnd_info[i].fill_isocvs_onsfs[j], 1);

         if(ed_rnd_info[i].tansf_rnd_info)
           EMtansf_rnd_info_free (ed_rnd_info[i].tansf_rnd_info);
        }
    }

return;
}



void EMSvtx_rnd_info_free( EMmsg,num,vertex_info )
IGRlong *EMmsg;
IGRint   num;
struct EMSvtx_rnd_info *vertex_info;
{
  IGRlong om_stat;
  IGRint  i,j;

  *EMmsg = EMS_E_Success;
  om_stat= OM_S_SUCCESS;

   for(i = 0; i < num; i++)
   {
    if(vertex_info->edge_ids &&
        vertex_info->edge_ids != vertex_info->edge_ids_mem)
		om$dealloc( ptr = vertex_info->edge_ids);

    if(vertex_info->edge_configs &&
       vertex_info->edge_configs != vertex_info->edge_configs_mem)
    		om$dealloc( ptr = vertex_info->edge_configs);

    for (j = 0; j < vertex_info->num_edges; j++)
      if(vertex_info->edge_infos[j])
        if( vertex_info->edge_stops[j] ) 
               vertex_info->edge_infos[j]->stop_vtx = NULL;
        else   vertex_info->edge_infos[j]->start_vtx = NULL;

    if(vertex_info->edge_stops &&
       vertex_info->edge_stops != vertex_info->edge_stops_mem)
       		om$dealloc( ptr = vertex_info->edge_stops);

    if(vertex_info->edge_infos &&
       vertex_info->edge_infos != vertex_info->edge_infos_mem)
     		om$dealloc( ptr = vertex_info->edge_infos);

   }
   
   om$dealloc(ptr = vertex_info);

 return;
}

void EMrnd_sf_info_init
(
  struct EMSrnd_sf_info *sf_info
)
{
  sf_info->objid = NULL_OBJID;
  sf_info->geom = NULL;
  sf_info->tol = 0.0;

  return;
}

void EMtansf_rnd_info_init (tansf_rnd_info)
struct EMStansf_rnd_info *tansf_rnd_info;
{
  EMrnd_sf_info_init(&tansf_rnd_info->tansf1);
  EMrnd_sf_info_init(&tansf_rnd_info->tansf2);
  EMrnd_sf_info_init(&tansf_rnd_info->fillet);

  tansf_rnd_info->fill_isocvs[0] = NULL;
  tansf_rnd_info->fill_isocvs[1] = NULL;
  tansf_rnd_info->fill_isocvs_onsfs[0].datatype = EMSdata_null;
  tansf_rnd_info->fill_isocvs_onsfs[1].datatype = EMSdata_null;

  tansf_rnd_info->props = 0;

  tansf_rnd_info->tpint_info = NULL;

  tansf_rnd_info->sibling = NULL;
  tansf_rnd_info->next = NULL;
}


void EMtansf_rnd_info_free (tansf_rnd_info)
struct EMStansf_rnd_info *tansf_rnd_info;
{
  IGRlong msg_loc=1;
  struct EMStansf_rnd_info *p_tansf=NULL, *p_next=NULL;
  BSrc rc;

  p_tansf = tansf_rnd_info;
  while (p_tansf)
  {
    if(p_tansf->props & (EMSrnd_base_fillet | EMSrnd_multi_fillet))
    {
      /*
       * The tansf node for the base fillet merely refers to the info
       * held by the EMSedge_rnd_info structure for this node. Do not
       * free the memory.
       */
      p_tansf->tansf1.geom = NULL;
      p_tansf->tansf2.geom = NULL;

      if(p_tansf->props &  EMSrnd_multi_fillet)
      {
        if (p_tansf->fillet.geom)
          BSfreesf(&rc, p_tansf->fillet.geom);
      }
      p_tansf->fillet.geom = NULL;
    }
    else
    {
      if (p_tansf->tansf1.geom)
        free(p_tansf->tansf1.geom);
      if (p_tansf->tansf2.geom)
        free(p_tansf->tansf2.geom);
      if (p_tansf->fillet.geom)
        BSfreesf(&rc, p_tansf->fillet.geom);
    }

    if(p_tansf->fill_isocvs[0])
      BSfreecv(&rc, p_tansf->fill_isocvs[0]);
    if(p_tansf->fill_isocvs[1])
      BSfreecv(&rc, p_tansf->fill_isocvs[1]);

    EMdataselect_data_free (&msg_loc, &p_tansf->fill_isocvs_onsfs[0], 1);

    EMdataselect_data_free (&msg_loc, &p_tansf->fill_isocvs_onsfs[1], 1);

    if(p_tansf->tpint_info)
      EMtpint_info_free(p_tansf->tpint_info, MAXINT);

    p_next = p_tansf->next;
    free(p_tansf);
    p_tansf = p_next;
  }

  return;
}

/*
 * DESCRIPTION
 * This fuction initialises the fields of the EMSrnd_tpint_info structure.
 *
 * Aditya  01/18/96    Creation.
 */

void EMtpint_info_init
(
  struct EMSrnd_tpint_info *tpint
)
{
  if(!tpint) return;

  tpint->int_edge = NULL_OBJID;
  tpint->int_pt[0] = 0.0;
  tpint->int_pt[1] = 0.0;
  tpint->xyzpt[0] = 0.0;
  tpint->xyzpt[1] = 0.0;
  tpint->xyzpt[2] = 0.0;
  tpint->props = 0;
  tpint->next = NULL;
  tpint->gen_tansf = NULL;
  tpint->trim_info = NULL;
  tpint->iso_inx = 0;
  tpint->intobj = NULL;

  return;
}

/*
 * DESCRIPTION
 * This function allocates memory of size struct EMSrnd_tpint_info on the
 * heap and returns a pointer to the head of the list.
 *
 * Aditya  01/18/96    Creation.
 */

struct EMSrnd_tpint_info *EMtpint_info_malloc
(
  IGRlong *msg,
  IGRint num_nodes
)
{
  IGRint inx=0;
  IGRlong msg_loc=EMS_S_Success;

  struct EMSrnd_tpint_info *p_tpint=NULL, *p_head=NULL;

  *msg = EMS_S_Success;

  if(num_nodes)
  {
    p_head = (struct EMSrnd_tpint_info *)
             malloc(sizeof(struct EMSrnd_tpint_info));
    EMerr_hndlr( !(p_head), *msg, EMS_E_NoDynamicMemory, wrapup);

    EMtpint_info_init(p_head);
  }

  p_tpint = p_head;

  for( inx=1; inx<num_nodes; inx++)
  {
    p_tpint->next = (struct EMSrnd_tpint_info *)
                                    malloc(sizeof(struct EMSrnd_tpint_info));
    EMerr_hndlr( !(p_tpint->next), *msg, EMS_E_NoDynamicMemory, wrapup);

    EMtpint_info_init(p_tpint->next);

    p_tpint = p_tpint->next;
  }

wrapup:
  if(!(1&*msg))
  {
    EMtpint_info_free (&msg_loc, p_head, MAXINT);
    p_head = NULL;
  }
  return (p_head);
}

/*
 * DESCRIPTION
 * This function frees a list of EMSrnd_tpint_info structures. The number
 * of nodes freed in the list can be specified through num_nodes. If
 * num_nodes=MAXINT all the nodes from tpint to the end of the list are 
 * freed. This function returns a pointer to the (num_nodes+1)th node or
 *  NULL if all the nodes are freed.
 *
 * Aditya  01/18/96    Creation.
 */

struct EMSrnd_tpint_info *EMtpint_info_free(tpint, num_nodes)
struct EMSrnd_tpint_info *tpint;
IGRint num_nodes;
{
  IGRint inx=0;
  struct EMSpypoint *p_pypt=NULL;
  struct EMSrnd_tpint_info *p_next=NULL, *p_tpint_loc=NULL;

  p_tpint_loc = tpint;

  for( inx=0; inx < num_nodes && p_tpint_loc; inx++)
  {
    p_next = p_tpint_loc->next;

    p_pypt = p_tpint_loc->trim_info;

    if(p_pypt && (p_tpint_loc->props & EMSrnd_tpint_head))
    {
      /*
       * Free the list of EMSpypoint and EMSsfintedpar in the first
       * pass itself. The first tpint node is marked with EMSrnd_tpint_head.
       *
       * The 'info' field points to the EMSsfintedpar type.
       */
      if(p_pypt->info)
        EMsfintedpar_free((struct EMSsfintedpar *)p_pypt->info, NULL);
      p_pypt->info =NULL;

      EMpypoint_free( p_pypt, NULL);
      p_tpint_loc->trim_info = NULL;
    }

    free(p_tpint_loc);
    p_tpint_loc = NULL;
 
    p_tpint_loc = p_next;
  }

  return(p_next);
}

end implementation Root;
