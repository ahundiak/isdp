class implementation DEso;

#include <stdio.h>
#include <memory.h>
#include <tools.h>
#include <limits.h>
#include <sys/param.h>
#include "msdef.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMindex.h"
#include "exmacros.h"
#include "gr.h"
#include "DEso.h"
#include "DEglob.h"
#include "DEsomacros.h"
#include "igrmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "dp.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "refdef.h"
#include "ref.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include <alloca.h> 

from GRreffile import GRinquireref;

method pre_delete ( long *msg )
/*
   Whenever a window is deleted, we need to clean up the soo.
*/
{
  int   status;
  short index;
  DEsoe *ptr, *last;
  
  *msg = MSSUCC;
  
  /* find the index of the guy on our channel */
  status = om$send ( msg = message DEso.DEget_view_index ( msg, &index, 0,
                                                           0, sender_id, 
                                                           NULL_OBJID ),
                     targetid = my_id );
  if (!(status & 1)) return status;
  if (*msg != MSSUCC) return OM_E_ABORT;
  
  /* traverse the table and delete each entry that point to the deleted window. */
  last = &me->soo [om$dimension_of ( varray = me->soo )];
  for (ptr = &me->soo [0]; ptr < last; ptr++)
    if (ptr->type != DE_DELETED && ptr->type != DE_EMPTY)
      if (ptr->view == index)
      {
        ptr->type = DE_DELETED;
        me->used--;
      }
      else
        if (ptr->view > index)
           ptr->view--;

  return status;
}


method view_saved ( long *msg; struct GRid *saved_vw, *stub_id )
/*
   A saved view has been created.  We copy the override of the original
   view so that they can be re-activated later in the game.
*/
{
  int   status, nb_entries, size;
  short new_index, index;
  DEsoe *ptr, *last, *local_soos;
  
  *msg = MSSUCC;
  
  /* find the index of the guy on our channel */
  status = om$send ( msg = message DEso.DEget_view_index ( msg, &index, 0,
                                                           1, sender_id, 
                                                           NULL_OBJID ),
                     targetid = my_id );
  if (!(status & 1)) return status;
  if (*msg != MSSUCC) return OM_E_ABORT;
  
  /* traverse the table and copy each entry to the new view */
  if (size = om$dimension_of ( varray = me->soo ))
  {
    last = &me->soo [size];
    local_soos = (DEsoe *)alloca ( size * sizeof ( DEsoe ) );
    for (nb_entries = 0, ptr = &me->soo [0]; ptr < last; ptr++)
      if (ptr->type != DE_DELETED && ptr->type != DE_EMPTY && ptr->view == index)
        local_soos [nb_entries++] = *ptr;
    
    /* get the new index */
    status = om$send ( msg = message DEso.DEget_view_index ( msg, &new_index, 0,
                                                             1, saved_vw->objid, 
                                                             NULL_OBJID ),
                       targetid = my_id );
    if (!(status & 1)) { return status; }
    if (*msg != MSSUCC) { return OM_E_ABORT; }
    
    for (ptr = local_soos, last = &local_soos [nb_entries]; ptr < last; ptr++)
      /* we must make sure that the object is still valid */
      if (om$is_objid_valid ( osnum = me->osnum, 
                              objid = ptr->objid ) == OM_S_SUCCESS)
      {
        status = om$send ( msg = message DEso.DEadd ( msg, ptr->type, ptr->objid, 
                                                      ptr->u1, ptr->u2, &ptr->osymb,
                                                      NULL, new_index, 
                                                      NULL, ptr->context ),
                           targetid = my_id );
        if (!(status & 1)) { return status; }
        if (*msg != MSSUCC) { return OM_E_ABORT; }
      }
  }

  return status;
}


method view_recalled ( long *msg; struct GRid *gragad, *stub_id )
{
  return om$send ( msg = message IGEwinsup.view_saved ( msg, gragad, stub_id ),
                   senderid = sender_id,
                   targetid = my_id );
}


DEref_view_recalled ( msg, ref_id, win_id )
                      long        *msg    /* return status              OUT */;
                      struct GRid *ref_id /* the reference file         IN  */;
                      struct GRid *win_id /* the view we are recalling  IN  */;
{
  int                   view_type, num_gragad, total_gragad, temp;
  long                  status, size, ret_msg, ret_bytes,
                        which_error;
  short                 zero = 0;
  char                  saved_view [MAXPATHLEN];
  struct GRid           gragad_grids [5];
  struct var_list       params [2];
  struct GRmd_env       mod_env, ref_env;
  struct GRinquire_list request [3];

  status = OM_S_SUCCESS;
  *msg = 1;

  size = sizeof ( struct GRmd_env );
  status = gr$get_module_env ( msg    = &ret_msg, 
                               sizbuf = &size, 
                               buffer = &mod_env, 
                               nret   = &temp );
  request[0].var = SAVED_VIEW_NAME;
  request[0].var_ptr = saved_view;
  request[0].num_requested = MAXPATHLEN;

  request[1].var = ENVIRONMENT_INFO;
  request[1].var_ptr = (char *)&ref_env;
  request[1].num_requested = sizeof(struct GRmd_env);

  request[2].var = END_REPORT_REQUEST;
  request[2].var_ptr = NULL;
  request[2].num_requested = 0;

  om$send( msg = message GRreffile.GRinquireref( msg, &mod_env, request, &temp,
                                             (IGRboolean *)&zero, 
                                             (struct GRinfo_processor *)NULL ),
           senderid = NULL_OBJID,
           targetos = ref_id->osnum,
           targetid = ref_id->objid );
  dp$get_gragad_id( msg = msg,
                    mod_GRid = &ref_env.md_id,
                    name = saved_view,
                    array_size = 5,
                    total_num = &total_gragad,
                    numberofids = &num_gragad,
                    found_GRids = gragad_grids,
                    type_gragad = ALL_TYPES,
                    search_priority = GRDP_SAVEDVIEWS );

  /* no views are found, give up and go home */
  if(!total_gragad) return OM_S_SUCCESS;

  params[0].var = VIEW_TYPE;
  params[0].var_ptr = (char *)&view_type;
  params[0].num_bytes = sizeof ( IGRint );
  params[0].bytes_returned = &ret_bytes;

  params[1].var = END_PARAM;
  params[1].var_ptr = NULL;
  params[1].num_bytes = 0;
  params[1].bytes_returned = NULL;

  dp$inq_set_gragad ( msg = msg,
                      inq0_set1 = 0,
                      osnum = gragad_grids [0].osnum,
                      gragad_objid = gragad_grids [0].objid,
                      which_error = &which_error,
                      var_list = params );
  if (view_type == TYPE_SAVVW)
  {
    OM_S_OBJID  soo, ref_soo;
    struct GRid context_id;
    DEsoe       *soes;
    int         i, count = 0;
    short       saved_ndx, wn_ndx, ctx_ndx;

    /* the DEso we copy from is the DEso of the master when the ref 
       is the master */
    di$translate ( objname = "soo_master",
                   path = "IGENOD",
                   osnum = gragad_grids [0].osnum,
                   p_objid = &ref_soo );

    if (ref_soo != NULL_OBJID)
    {
      /* The DEso object must be connected to the saved view */
      om$send ( msg = message DEso.DEget_view_index ( msg, &saved_ndx, NULL, NULL,
                                                      gragad_grids [0].objid, NULL_OBJID ),
                senderid = NULL_OBJID,
                targetid = ref_soo,
                targetos = gragad_grids [0].osnum );
      if (*msg == MSSUCC)
      {
        /* make sure there is a DEso object for the reference file */
      de$create_soo ( msg = msg, osnum = gragad_grids [0].osnum, p_objid = &soo );

        /* get the so's entries from the saved view */
        om$send ( msg = message DEso.DEdump ( &count, &soes, 0 ), 
                  senderid = NULL_OBJID,
                  targetid = ref_soo,
                  targetos = gragad_grids [0].osnum );

        if (count)
        {
          /* add the context of the attachment */
          GRfindcontext( msg, &mod_env.md_env.matrix_type, mod_env.md_env.matrix,
                         &ref_env.md_id.osnum, &context_id );
          om$send ( msg = message DEso.DEget_view_index ( msg, &wn_ndx, &ctx_ndx, 1,
                                                          win_id->objid, 
                                                          context_id.objid ),
                    senderid = NULL_OBJID,
                    targetid = soo,
                    targetos = win_id->osnum );
    
          /* copy their soo's into the local DEso */
          for (i = 0; i < count; i++)
            if (soes [i].view == saved_ndx)
              om$send ( msg = message DEso.DEadd ( msg, soes [i].type, soes [i].objid,
                                                   soes [i].u1, soes [i].u2,
                                                   &soes [i].osymb, NULL, wn_ndx,
                                                   NULL, ctx_ndx ),
                        senderid = NULL_OBJID,
                        targetid = soo,
                        targetos = win_id->osnum );
        }
      }
    }
  }

  return OM_S_SUCCESS;
}

end implementation DEso;
