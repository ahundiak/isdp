/* ###################   APOGEE COMPILED   ################## */
class implementation ECsfedloc;

/*

HISTORY

08/14/94          SCW         Clarified sleep method
04/01/93          SCW         Initialized locate_ref_obj instance to TRUE;
05/19/92          AMD         Message subsystem compliance
02/18/92          AMD         Hilite selected edges with weight.
04/24/91          DLB         Use edgeval_event etc.
April, 1991       AMD         Creation

*/

#include "lcmacros.h"
#include "EMSlc.h"
#include "griomacros.h" /* co$getevent */
#include "emserr.h"
#include "EMSaction.h" /* Structure definition for action handler */
#include "EMSasdef.h" /* For ASSOC */
#include "EMSprop.h"
#include "OMprimitives.h"
#include "EMSopt.h"
#include "emsdef.h"
#include "EMSlcdef.h"
#include "EMSlmdef.h"
#include "EMSerrordef.h"
#include "OMmacros.h"
#include "dpmacros.h"

#define RNDEDGE 0
#define RNDVERT 1
#define CHAMEDGE 2
#define CHAMVERT 3

from EMSedge import EMdisplay;

extern GRclassid OPP_EMSedge_class_id;
extern GRclassid OPP_EMSsurface_class_id;

method init(int type; char *str_ptr)
{
  IGRlong   sts;

  sts = om$send(mode = OM_e_wrt_parent,
                msg = message ECsfedloc.init(type, str_ptr),
                targetid = my_id);
  EMomerr_hndlr(sts, wrapup, "parent ECsfedloc.init error");

  me->numed = 0;
  me->num_vertex = 0;
  me->process_state = 0;
  me->rnd_construct_id.objid = NULL_OBJID;
  me->active_GRid.objid = NULL_OBJID;
  me->locate_ref_obj = TRUE;

  sts = om$vla_set_dimension(varray = me->located_obj,
                             size = 20);
  EMomerr_hndlr(sts, wrapup, "om$vla_set_dimension error");

  sts = om$vla_set_dimension(varray = me->edgeval_event,
                             size = 20) ;
  EMomerr_hndlr(sts, wrapup, "om$vla_set_dimension error");

  sts = om$vla_set_dimension(varray = me->rt_vertex,
                             size = 20) ;
  EMomerr_hndlr(sts, wrapup, "om$vla_set_dimension error");

  sts = om$vla_set_dimension(varray = me->vertex,
                             size = 10) ;
  EMomerr_hndlr(sts, wrapup, "om$vla_set_dimension error");

wrapup:
  return (sts);
}

method wakeup(int pos)
{

  IGRlong       OM_stat=OM_S_SUCCESS, msg=EMS_S_Success;

  IGRint        i, mytype;
  enum GRdpmode display_mode=GRhhd;
  IGRshort      display_flag;
  OMuword       osnum;

  osnum = me->ModuleInfo.md_id.osnum;
  mytype = ME.super_cmd->mytype;

  if(!(((mytype == RNDVERT)||(mytype == CHAMVERT)) && (me->uniformval!=-1)))
  {
   if(me->numed)
   /* Redraw the edges */
    for ( i=0; i< (ME.ECsfedloc->numed); i++)
     { 
      display_mode = GRhd ;
      OM_stat = EFhilite_edge_with_weight( &msg, me->ModuleInfo,
                  ME.ECsfedloc->located_obj[i], display_mode );
      EMomerr_hndlr(OM_stat, wrapup, "EFhilite_edge_with_weight");
     }
    }

  if(me->num_vertex)
   /* Redraw the vertices */
    for ( i=0; i< (me->num_vertex); i++) 
     {
      display_mode = GRhd ;
      display_flag = EMS_EDGE_END_PT;
      OM_stat = om$send ( msg = message EMSedge.EMdisplay ( &msg, 
                          NULL, &ME.COroot->ModuleInfo.md_env.matrix_type,
                          ME.COroot->ModuleInfo.md_env.matrix,
                          &display_mode,NULL,
                          display_flag, NULL),
         targetid = me->vertex[i].vertexid,
         targetos = osnum );
      EMomerr_hndlr(OM_stat, wrapup, "ECsfedloc.wakeup error");
     }

wrapup:
    return(OM_stat);
}


method super_cmd.sleep( int pos )
{
  IGRlong msg=EMS_S_Success;

  dp$erase_hilite(msg = &msg);

  UI_message("");
  UI_status("");
  UI_prompt("");

  return(OM_S_SUCCESS);
}

method execute(int *response; char *response_data; int pos)
{
  IGRlong sts = OM_S_SUCCESS;
  return(sts);

}
  
end implementation ECsfedloc; 
            
