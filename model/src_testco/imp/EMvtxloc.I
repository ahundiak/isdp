/* ###################   APOGEE COMPILED   ################## */
class implementation ECsfedloc;

/*

DESCRIPTION

  This method locates vertices in a sequential manner. The purpose of this
method is to simplify the interface for all local mods. For locate
purposes the parameters of the action handler have been used to do the
required locate and filtration at the edge level. 
  A vertex is defined by the largest edge id which has its stop point
at that vertex.

RETURNED VALUES

 EMS_I_Interrupt   For ret_msg if command is stacked.
 OM_S_SUCCESS      For successful completion.

HISTORY

04/01/93         SCW       Added locate_ref_obj instance check for location
                           of reference file objects.
03/15/93         SCW       Added toggle checks for edge locate eligibility
05/19/92         AMD       Message subsystem compliance
04/24/91         DLB       Use ems$getevent; stuff into edgeval_event.
April, 1991      AMD       Creation

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
#include "EMSasmacros.h"
#include "exmacros.h"
#include "msmacros.h"
#include "EC_F.h"
#include "EC_I.h"
#include "EC_M.h"
#include "EC_P.h"

#define ID_VERTEX    0
#define CHOOSE_EDGE  1

#define DEBUG        1
#define NUMED        10

from EMSedge import EMget_props;
from EMSedge import EMgetvtxedges;
from EMSedge import EMdisplay;
from EMSedge import EMxyz_endpt;
from EMSboundary import EMgetsurface_info;
from EMSsurface  import EMgetactiveid;
from GRowner     import GRget_number_components;

extern GRclassid OPP_EMSedge_class_id;
extern GRclassid OPP_EMSsurface_class_id;

static IGRboolean aflag;


method locate_vertex(IGRlong       *ret_msg;
                     IGRint        *response;
                     IGRchar       *response_data;
                     IGRchar       *status_string;
                     char          (*funcptr) () )
{
  IGRint                      i, j ;
  GRobjid                     *edges=NULL ;
  IGRboolean                  *is_rightend=NULL, stat_func=TRUE;
  GRobjid                     first_edge ;
  OMuword                     rclass, eliclass, objspc_num ;
  OM_S_CLASSLIST              rtree_classes, elig_classes;
  struct  GRlc_locate         attributes;
  IGRlong                     sts, msg, size, display_flag,
                              eventmask1, eventmask2;
  IGRboolean                  right_vertex=TRUE, edge_in_buffer=FALSE,
                              edge_locatable=FALSE;
  IGRint                      num_edges,index, num_eligible_edge;
  OMuint                      count;
  OM_S_CHANSELECT             chan_to_common_edge;
  OM_S_OBJECT_LINKAGE         comm_edge;
  enum GRdpmode               display_mode;
  IGRshort                    disp_flag;
  IGRchar                     locate_prompt[54], accept_prompt[54],
                              relocate_prompt[54] ;
  IGRint                      event_mask,num_elements;
  IGRchar                     string[MAX_CHAR];
  GRobjid                     eligible_edge[20], *located_objects = NULL;
  GRclassid                   classid;

/*  struct GRevent              accept_event; */ 

  IGRlong EMgetnextedges();                    
  extern  IGRlong EFhilite_edge_with_weight();
  extern  IGRboolean EFedge_curves_locatable();
  extern  IGRint EFset_locate_eligibility();

  *ret_msg = EMS_S_Success;
  sts = OM_S_SUCCESS;
  objspc_num = me->ModuleInfo.md_id.osnum;

  edge_locatable = EFedge_curves_locatable();
  if( !edge_locatable )
  {
     EFset_locate_eligibility(&msg,1,"EMSedge");
     if(!(1&msg)) goto ret_end;
  }

/*
  edges = (GRobjid *) om$malloc (size = NUMED * sizeof(GRobjid));
*/

  do
  {
   switch( me->process_state)
   {
     case ID_VERTEX:
      {
       extern      IGRlong EFlocate_action_handler();
       struct      EMSaction_handler was_located;

       /* The option field has been set to 7 for locating vertices. This
          has been done to pass the information to edge level and do 
          the filtration of located vertices there itself.
       */ 

       was_located.next = NULL;
       was_located.option = LOCATE_VERTEX;
       was_located.type = 2;
       if (me->num_vertex)
        was_located.num_objects = me->num_vertex;
       else 
        was_located.num_objects = 0;

       was_located.objects.same_space.space_number = 
                                    me->ModuleInfo.md_id.osnum;
       located_objects = (GRobjid *) om$malloc 
                     (size = (me->num_vertex+1) * sizeof(GRobjid));
       for(i=0; i<me->num_vertex; i++)
           located_objects [i]  = me->vertex[i].vertexid;
       was_located.objects.same_space.objid = located_objects;

       eventmask1 = GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON;
       eventmask2 = GRm_DATA | GRm_BACK_UP;

       if (me->num_vertex)
       {
        i = me->num_vertex + 1;
        ex$message ( msgnumb = EMS_P_IdentVertex,
                     type    = "%d",
                     var     = `i`,
                     buff    = locate_prompt)
       }
      else
       {
        ex$message ( msgnumb = EMS_P_IdentVertex1,
                     buff    = locate_prompt)
       }

       if(me->uniformval!=-1)
        {
         ex$message ( msgnumb = EMS_P_AcceptWithNextVertexRj,
                      buff    = accept_prompt)
         
         ex$message ( msgnumb = EMS_P_VertexNotFound,
                      buff    = relocate_prompt)
        }
       else
        {
         ex$message ( msgnumb = EMS_P_AcceptReject,
                      buff    = accept_prompt)
         
         ex$message ( msgnumb = EMS_P_VertexNotFound,
                      buff    = relocate_prompt)
        }

       size = sizeof(struct GRevent);
       attributes.properties   = LC_LC_ONLY | LC_DP_ONLY | LC_RW |
                                 LC_PLANAR_NON_PLANAR;
       if( me->locate_ref_obj )
       {
          attributes.owner_action = LC_RIGID_COMP  |
                                    LC_LOCALMOD    |
                                    LC_OBJ_W_OWNER |
                                    LC_REF_OBJECTS |
                                    LC_NO_REF_HEADER;
       }
       else
       {
          aflag = pwIsActivationOn();
          if (aflag)
          {
          attributes.owner_action = LC_RIGID_COMP  |
                                    LC_LOCALMOD    |
                                    LC_OBJ_W_OWNER |
                                    LC_REF_OBJECTS | /*added for RFA*/
                                    LC_NO_REF_HEADER;
          }
          else
          {
          attributes.owner_action = LC_RIGID_COMP  |
                                    LC_LOCALMOD    |
                                    LC_OBJ_W_OWNER |
                                    LC_NO_REF_HEADER;
          }
       }

       strcpy(attributes.classes, "EMSvertex");
       display_flag = ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT |
                      LC_ERASE_LOC_ELEMENT;
        
       rtree_classes.w_count = 1;
       elig_classes.w_count = 1;
       rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;

       rclass = OPP_EMSsurface_class_id;
       eliclass = OPP_EMSedge_class_id;

       rtree_classes.p_classes = &rclass;
       elig_classes.p_classes = &eliclass;


       stat_func=lc$locate(rc = &msg, 
                 event1 = &me->event,
                 event2 = &me->event,
                 mask1 = eventmask1, 
                 mask2 = eventmask2, 
                 eventsize= &size, 
                 display_flag = display_flag,
                 response = response, 
                 response_data = response_data, 
                 locate_prompt = locate_prompt, 
                 acc_prompt = accept_prompt,
                 relocate_prompt = relocate_prompt,
                 attributes = &attributes,
                 act_handler = EFlocate_action_handler,
                 act_args = &was_located, 
                 stack = &ME.ECsfedloc->locate_stack, 
                 rtree_classes = &rtree_classes, 
                 eligible_classes = &elig_classes);
       

       if( (!stat_func) || ( me->event.response == GR_UNKNOWN_TYPE ))
        {
         *ret_msg = EMS_I_Interrupt;
         goto ret_end;
        }
  
      switch (me->event.response)
      {
       case EX_RJT_MOVEON:
         if(!me->numed)
          {
           me->process_state = ID_VERTEX;
           break;
          }
         else
          /* Succesful completion */
           sts = OM_S_SUCCESS;
           goto ret_end;
       case EX_BACK_UP:
         if(me->num_vertex)
          {
            display_mode = GRhe ;
            disp_flag = EMS_EDGE_END_PT;
            sts = om$send ( msg = message EMSedge.EMdisplay ( &msg, NULL,
                        &ME.COroot->ModuleInfo.md_env.matrix_type,
                        ME.COroot->ModuleInfo.md_env.matrix,
                        &display_mode,NULL,
                        disp_flag, NULL),
            targetid = me->vertex[me->num_vertex-1].vertexid,
            targetos = objspc_num,
            senderid = NULL_OBJID);
            EMomerr_hndlr ( sts, ret_end, "EMSedge.EMdisplay");

            for(i=0; i<me->vertex[me->num_vertex-1].vertex_numed; i++)
             {
              if(me->uniformval == -1)
               {
                display_mode = GRhe ;
                sts = EFhilite_edge_with_weight( &msg, me->ModuleInfo,
                          me->located_obj[me->numed-1], display_mode );
                EMomerr_hndlr(sts, ret_end, "EFhilite_edge_with_weight");
               }
               me->located_obj[me->numed-1] = NULL;
               me->numed--;
             }                    
            me->vertex[me->num_vertex-1].vertexid = NULL ;
            me->vertex[me->num_vertex-1].vertex_numed = NULL;
            me->num_vertex--;
            break;
           } 
          else
            return(OM_S_SUCCESS);  
       case EX_DATA:

        sts = om$get_classid (
              objid = me->event.located_object[0].located_obj.objid,
              osnum = me->event.located_object[0].located_obj.osnum,
              p_classid = &classid);

        sts = om$is_ancestry_valid( subclassid = classid,
                                    superclassid = OPP_EMSedge_class_id);
        if ( sts != OM_S_SUCCESS)
         { me->process_state = ID_VERTEX;  break; }

        ME.COroot->ModuleInfo = me->event.located_object[0].module_info; 
        first_edge = me->event.located_object[0].located_obj.objid;

        num_elements = om$dimension_of(varray = me->vertex);
        if (me->num_vertex + 1 >= num_elements)
         {
          sts = om$vla_set_dimension(varray = me->vertex,
                                         size = num_elements + 2);
          EMomerr_hndlr(sts, ret_end, "set_dimension  error");
         }
        
        objspc_num = me->event.located_object[0].located_obj.osnum;
        /* Check to see if the vertex belongs to the same composite */
       {
        GRobjid   srfid;
        struct GRid srf_ownr;
        IGRboolean single_surface=FALSE;
        IGRint     num_components;

        sts = om$send ( msg = message EMSboundary.EMgetsurface_info
                            (&msg, &srfid, NULL),
                           targetid = first_edge,
                           targetos = objspc_num );
        EMerr_hndlr(!(1&msg&sts),msg,EMS_E_SurfaceError,ret_end);

        sts = om$send(msg = message EMSsurface.EMgetactiveid(&msg,
                              &srf_ownr, NULL),
                        targetid = srfid,
                        targetos = objspc_num);
        EMerr_hndlr(!(1&msg&sts),msg,EMS_E_SurfaceError,ret_end);

        /* Check to see if this is a single surface */
        if ( srf_ownr.objid == srfid ) /* Single surface */
         {
          single_surface = TRUE;
         }
        else 
         {
          sts = om$send (msg = message GRowner.GRget_number_components(
                         ret_msg, &num_components),
                   targetid = srf_ownr.objid,
                   targetos = srf_ownr.osnum);
          EMomerr_hndlr(sts, ret_end, "GRget_number_components");

          if (num_components == 1)
            single_surface = TRUE;
          else
            single_surface = FALSE;
          }
        
        if(single_surface) 
          {
            ex$message ( msgnumb = EMS_S_SingleSurfNotAllowed );
            display_mode = GRhe ;
            disp_flag = EMS_EDGE_END_PT;
            sts = om$send ( msg = message EMSedge.EMdisplay ( &msg, NULL,
                        &ME.COroot->ModuleInfo.md_env.matrix_type,
                        ME.COroot->ModuleInfo.md_env.matrix,
                        &display_mode,NULL,
                        disp_flag, NULL),
               targetid = first_edge,
               targetos = objspc_num );
            EMerr_hndlr (!(1 & sts), msg, EMS_E_Fail,ret_end);

            me->process_state = ID_VERTEX;
            break;
           }          

        if(!me->numed)
         me->active_GRid = srf_ownr;
        else
         if ((me->active_GRid.objid != srf_ownr.objid) ||
            (me->active_GRid.osnum != srf_ownr.osnum))
         {
          /*Nupe.*/
            ex$message ( msgnumb = EMS_S_VertexPartDiffComposite);
            display_mode = GRhe ;
            disp_flag = EMS_EDGE_END_PT;
            sts = om$send ( msg = message EMSedge.EMdisplay ( &msg, NULL,
                        &ME.COroot->ModuleInfo.md_env.matrix_type,
                        ME.COroot->ModuleInfo.md_env.matrix,
                        &display_mode,NULL,
                        disp_flag, NULL),
               targetid = first_edge,
               targetos = objspc_num );
            EMerr_hndlr (!(1 & sts), msg, EMS_E_Fail,ret_end);

            me->process_state = ID_VERTEX; 
            break;
          }
        }

        me->num_vertex++;
        me->vertex[me->num_vertex-1].vertexid = 
                      me->event.located_object[0].located_obj.objid;

       if(me->uniformval!=-1)
        { 
         size = sizeof(me->event.event) + sizeof (IGRint); 
         sts = ex$putque(msg = &msg, response = response,
                     byte = &size, buffer = (char *)&me->event.event);
         EMomerr_hndlr ( sts, ret_end, "ex$putque error");
         }
 
         me->process_state = CHOOSE_EDGE;
       break;
      default:
       goto ret_end;
     } /* me->event.response */

    break;
   }      /* ID_VERTEX */

  case CHOOSE_EDGE:
    { 
     IGRushort edge_options;
     IGRint num_buff = 10;
     index = 0;
     num_eligible_edge=0;
     num_edges = 0;
     is_rightend=NULL;
     edges=NULL;

     first_edge = me->vertex[me->num_vertex-1].vertexid;

     /* Get the dominant edges for this vertex */
     edge_options = EMSvtxedges_nodegenerate | EMSvtxedges_onlydominant
                  | EMSvtxedges_noseamedge;

     sts = om$send(msg = message  EMSedge.EMgetvtxedges(&msg, 
                          edge_options, right_vertex,
                          num_buff, &num_edges, &edges,
                          &is_rightend), 
                   targetid = first_edge,
                   targetos = objspc_num );
     EMomerr_hndlr ( sts, ret_end, "EMgetvtxedges");
           
   /* Check to see if this edge or its common edge have already been
      located  */
   

   sts = EMmake_chanselect( EMSedge_to_common_edge, &chan_to_common_edge);

   for ( i=0; i< (num_edges); i++ )
   {
    edge_in_buffer = FALSE;
    for ( j=0; j<(me->numed); j++ )
     {
      sts = om$get_channel_objects(
               osnum = objspc_num,
               objid = me->located_obj[j],
               p_chanselect = &chan_to_common_edge,
               list = &comm_edge,
               size = 1,
               count = &count);
      EMomerr_hndlr ( sts, ret_end, "get_channel_objects");

      if( ((IF_EQ_OBJID( edges[i], me->located_obj[j])) || 
           (IF_EQ_OBJID( edges[i], comm_edge.S_objid))))
            {
             edge_in_buffer = TRUE;
             break;
            }
      }
      if(!edge_in_buffer)
        {
          eligible_edge[num_eligible_edge] = edges[i];
          num_eligible_edge++;
         }
    }

    me->vertex[me->num_vertex-1].vertex_numed = num_eligible_edge;

    if(me->uniformval!=-1) 
     {
      for(i=0; i<num_eligible_edge; i++)
       {
         num_elements = om$dimension_of(varray = me->located_obj);
         if (me->numed + 1 >= num_elements)
         {
           sts = om$vla_set_dimension(varray = me->located_obj,
                                         size = num_elements + 2);
           EMomerr_hndlr(sts, ret_end, "set_dimension  error");
          }
         me->numed++;
         me->located_obj[me->numed-1] = eligible_edge[i];
        }
        if(located_objects) 
          {
          om$dealloc(ptr=located_objects);
          located_objects = NULL;
          }
        if(is_rightend) 
          {
          om$dealloc(ptr=is_rightend);
          is_rightend = NULL;
          }
        if(edges) 
          {
          om$dealloc(ptr=edges);
          edges = NULL;
          }
       me->process_state = ID_VERTEX;
       break;
      }

    while((index < num_eligible_edge) && (index >= 0))
    {
     /* Highlight the element */
     display_mode = GRhd ;
     sts = EFhilite_edge_with_weight( &msg, me->ModuleInfo,
                        eligible_edge[index], display_mode );
     EMomerr_hndlr(sts, ret_end, "EFhilite_edge_with_weight");

     {
      ex$message ( msgnumb = EMS_S_Enter,
                   buff    = string );
      strcat( string, " ");
      strcat( string, status_string);
     }

     event_mask = GRm_VALUE | GRm_BACK_UP ;

     stat_func = ems$getevent ( msg = &msg,
           event_mask = event_mask,
           value_type = GRIO_DISTANCE,
           prompt = string,
           response = (long *)response,
           response_data = response_data,
           event = &me->event);

     ex$message ( msgnumb = EMS_P_ClearPromptField );

     if (stat_func == FALSE)
      {
       ex$message ( msgnumb = EMS_E_FailureInputProcessing );
       *response = TERMINATE;
       goto ret_end;
      }

     if ( me->event.response == GR_UNKNOWN_TYPE )
      {
       display_mode = GRhe ;
       sts = EFhilite_edge_with_weight( &msg, me->ModuleInfo, 
                         eligible_edge[index], display_mode );
       EMomerr_hndlr(sts, ret_end, "EFhilite_edge_with_weight");

       if(index)
       {
        for(i=0; i<index; i++)
        {
         display_mode = GRhe ;
         sts = EFhilite_edge_with_weight( &msg, me->ModuleInfo, 
                 me->located_obj[me->numed - 1], display_mode );
         EMomerr_hndlr(sts, ret_end, "EFhilite_edge_with_weight");

         me->located_obj[me->numed-1] = NULL;
         me->numed--;
        }
       }        
       *ret_msg = EMS_I_Interrupt;
       goto ret_end;
      }

     if(me->event.response == EX_VALUE)
      {
        num_elements = om$dimension_of(varray = me->located_obj);
        if (me->numed + 1 >= num_elements)
         {
          sts = om$vla_set_dimension(varray = me->located_obj,
                                        size = num_elements + 2);
          EMomerr_hndlr(sts, ret_end, "set_dimension  error");

          sts = om$vla_set_dimension(varray = me->edgeval_event,
                                    size = num_elements + 2);
          EMomerr_hndlr(sts, ret_end, "set_dimension  error");
          }

        me->numed++;
        me->edgeval_event[me->numed-1] = me->event;
        me->located_obj[me->numed-1] = eligible_edge[index];
        index++;
       }
      else if (me->event.response == EX_BACK_UP)
       {
          display_mode = GRhe ;
          sts = EFhilite_edge_with_weight( &msg, me->ModuleInfo, 
                              eligible_edge[index], display_mode );
          EMomerr_hndlr(sts, ret_end, "EFhilite_edge_with_weight");

         if(!index)
          {
           display_mode = GRhe ;
           sts = EFhilite_edge_with_weight( &msg, me->ModuleInfo, 
                              eligible_edge[index], display_mode );
           EMomerr_hndlr(sts, ret_end, "EFhilite_edge_with_weight");

           display_mode = GRhe ;
           disp_flag = EMS_EDGE_END_PT;
           sts = om$send ( msg = message EMSedge.EMdisplay ( &msg, NULL,
                        &ME.COroot->ModuleInfo.md_env.matrix_type,
                        ME.COroot->ModuleInfo.md_env.matrix,
                        &display_mode,NULL,
                        disp_flag, NULL),
            targetid = me->vertex[me->num_vertex-1].vertexid,
            targetos = objspc_num,
           senderid = NULL_OBJID);
           EMomerr_hndlr ( sts, ret_end, "EMSedge.EMdisplay");
           me->vertex[me->num_vertex-1].vertexid = NULL ;
           me->num_vertex--;
          } 
         else
          {
           me->located_obj[me->numed-1] = NULL;
           me->numed--;
           }

         index--;
        } 
       else /* default */
        goto ret_end;
      } /*  while loop */

      me->process_state = ID_VERTEX;
/* fix for mlk */
     if(is_rightend) 
       {
       om$dealloc(ptr=is_rightend);
       is_rightend = NULL;
       }
     if(edges) 
       {
       om$dealloc(ptr=edges);
       edges = NULL;
       }
     break;
    }  /* case CHOOSE_EDGE */

   default:
      goto ret_end;

   } /* ME.super_cmd->super_cmd */

  }
 while (TRUE);

 ret_end:

     if(is_rightend) 
       {
       om$dealloc(ptr=is_rightend);
       is_rightend = NULL;
       }
     if(edges) 
       {
       om$dealloc(ptr=edges);
       edges = NULL;
       }
  if(located_objects) 
    {
    om$dealloc(ptr=located_objects);
    located_objects=NULL;
    }

  if( !edge_locatable )
     EFset_locate_eligibility(&msg,0,"EMSedge");
 
 return(sts);

}
  
end implementation ECsfedloc; 
            
