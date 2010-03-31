class implementation ECsfedloc;

/*

DESCRIPTION

  This method locates edges in a sequential manner, highlighting the
edge which comes right after the accepted one. The purpose of this
method is to simplify the interface for all local mods. For locate
purposes the parameters of the action handler have been used to do the
required locate and filtration at the edge level.

RETURNED VALUES

 EMS_I_Interrupt   For ret_msg if command is stacked.
 OM_S_SUCCESS      For successful completion.

HISTORY

04/01/93         SCW       Added locate_ref_obj instance check for location
                           of reference file objects.
05/19/92         AMD       Message subsystem compliance
02/18/92         AMD       Hilite selected edges with weight.
02/05/92         AMD       Added check for single surfaces.
10/17/91         AMD       Addeg func EFput_edge_on_same_surface which
                           forces the hilited edge to remain on the
                           same surface as the last two selected
                           edges. 
07/02/91         AMD       Added function EFhitedge to stop the
                           chaining if accept event is away from the
                           edge.
04/24/91         DLB       Added ems$getevent etc.
April, 1991      AMD       Creation

*/

#include <string.h>
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
#include "dpdef.h"
#include "grdpbdef.h"
#include "dpmacros.h"
#include "grdpbmacros.h"
#include "msmacros.h"
#include "EC_F.h"
#include "EC_I.h"
#include "EC_M.h"
#include "EC_P.h"

#define FALSE 0
#define TRUE 1

#define IDENTIFY_EDGE      0
#define CHOOSE_EDGE  1

#define DEBUG        1
#define NUMED        10

from EMSedge import EMget_props;
from EMSedge import EMgetvtxedges;
from EMSedge import EMdisplay;
from EMSedge import EMxyz_endpt;
from EMSedge import EMget_bcxyz_geom;
from EMSboundary import EMgetsurface_info;
from EMSsurface  import EMgetactiveid;
from GRowner     import GRget_number_components;
from EMSsubbs    import EMget_ele_header;

extern GRclassid OPP_EMSedge_class_id, 
                 OPP_EMSgraloop_class_id;
extern GRclassid OPP_EMSsurface_class_id;

static IGRboolean aflag;


method locate_edge ( IGRlong       *ret_msg;
                     IGRint        *response;
                     IGRchar       *response_data;
                     IGRchar       *status_string;                     
                     char          (*funcptr) () )
{
  IGRint                      i ;
  GRobjid                     *edges ;
  IGRboolean                  *is_rightend, stat_func=TRUE;
  GRobjid                     first_edge;
  OMuword                     rclass, eliclass, objspc_num ;
  OM_S_CLASSLIST              rtree_classes, elig_classes;
  struct  GRlc_locate         attributes;
  IGRlong                     sts, msg, size, display_flag,
                              eventmask1, eventmask2;
  IGRboolean                  right_vertex=TRUE;
  IGRint                      num_edges, index=0;
  OMuint                      count;
  OM_S_CHANSELECT             chan_to_common_edge;
  OM_S_OBJECT_LINKAGE         comm_edge;
  enum GRdpmode               display_mode;
  IGRchar                     loc_prompt[80];
  struct IGRline              boreline;
  IGRpoint                    point1, point2;
  IGRdouble                   beg_xyz_pt[3], end_xyz_pt[3];
  IGRdouble                   dist1, dist2;
  IGRint                      event_mask, num_elements;
  IGRboolean                  backup=FALSE; 
  IGRchar                     string[MAX_CHAR];
  IGRboolean                  hitedge=FALSE, edge_locatable=FALSE;
  GRobjid                     srfid;

  IGRlong EMgetnextedges();                    
  IGRlong EFedgeval();
  extern  IGRlong EFhitedge();
  extern  IGRlong EFput_edge_on_same_surface();
  extern  IGRlong EFhilite_edge_with_weight();
  extern IGRboolean EFedge_curves_locatable();

  *ret_msg = EMS_S_Success;  
  sts = OM_S_SUCCESS;

  objspc_num = me->ModuleInfo.md_id.osnum;

  edge_locatable = EFedge_curves_locatable();

  if(!edge_locatable)
    EFset_locate_eligibility(&msg,1,"EMSedge");

  edges = (GRobjid *) om$malloc (size = NUMED * sizeof(GRobjid));

  boreline.point1 = point1;
  boreline.point2 = point2;




  do
  {
   switch( me->process_state)
   {
     case IDENTIFY_EDGE:
      {
       extern      IGRlong EFlocate_action_handler();
       struct      EMSaction_handler was_located;

       /* The option field has been set to 6 for locating edges. This
          has been done to pass the information to edge level and do 
          the filtration of located edges there itself.
       */ 

       was_located.next = NULL;
       was_located.option = LOCATE_EDGE;
       was_located.type = 2;
       if (!(ME.ECsfedloc->numed==0))
        was_located.num_objects = me->numed;
       else 
        was_located.num_objects = 0;

       was_located.objects.same_space.space_number = 
                                    me->ModuleInfo.md_id.osnum;
       was_located.objects.same_space.objid = me->located_obj;

       eventmask1 = GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON;
       eventmask2 = GRm_DATA;

       if(!me->numed)
        ex$message ( msgnumb = EMS_P_IdentifyEdge,
                     buff    = loc_prompt)
       else
        ex$message ( msgnumb = EMS_P_IdEdgeBkupMoveon,
                     buff    = loc_prompt )

       size = sizeof(struct GRevent);
       attributes.properties   = LC_LC_ONLY | LC_DP_ONLY | LC_RW |
                                 LC_PLANAR_NON_PLANAR;
       if( me->locate_ref_obj )
       {
          aflag = pwIsActivationOn();
          if (aflag)
          {
          attributes.owner_action = LC_RIGID_COMP  | 
                                    LC_LOCALMOD    | 
                                    LC_OBJ_W_OWNER | 
                                    LC_REF_OBJECTS | /*Added for RFA*/
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
       else
       {
          attributes.owner_action = LC_RIGID_COMP  |
                                    LC_LOCALMOD    | 
                                    LC_OBJ_W_OWNER | 
                                    LC_NO_REF_HEADER;
       }
       strcpy(attributes.classes, "EMSsurface");
       display_flag = ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT |
                      LC_ERASE_LOC_ELEMENT;
        
       rtree_classes.w_count = 1;
       elig_classes.w_count = 1;
       rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;

       rclass = OPP_EMSsurface_class_id;
       eliclass = OPP_EMSedge_class_id;

       rtree_classes.p_classes = &rclass;
       elig_classes.p_classes = &eliclass;

       stat_func = lc$locate(rc = &msg, 
                 event1 = &me->event,
                 event2 = &me->event,
                 mask1 = eventmask1, 
                 mask2 = eventmask2, 
                 eventsize= &size, 
                 display_flag = display_flag,
                 response = response, 
                 response_data = response_data, 
                 locate_prompt = loc_prompt, 
                 acc_key = EMS_P_AcceptNearEndReject,
                 relocate_key = EMS_P_EdgeNotFound, 
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
           me->process_state = IDENTIFY_EDGE;
           break;
           }
         else
          /* Successful completion */
           sts = OM_S_SUCCESS;
           goto ret_end;  
       case  EX_BACK_UP:
         if(me->numed)
         {
          display_mode = GRhe ;
          sts = EFhilite_edge_with_weight( &msg, me->ModuleInfo,
                      me->located_obj[me->numed-1], display_mode );
          EMomerr_hndlr(sts, ret_end, "EFhilite_edge_with_weight");

          ME.ECsfedloc->located_obj[ME.ECsfedloc->numed-1] = NULL;
          me->rt_vertex[me->numed-1] = NULL;
          ME.ECsfedloc->numed--;        

          if(!me->numed) {sts = OM_S_SUCCESS; goto ret_end; }

          edges[index] = me->located_obj[me->numed-1];
          right_vertex = me->rt_vertex[me->numed-1];

          ME.ECsfedloc->located_obj[ME.ECsfedloc->numed-1] = NULL;
          me->rt_vertex[me->numed-1] = NULL;
          ME.ECsfedloc->numed--;        
          backup = TRUE;
          goto uniform_backup;
          }
         else
         {
          /* Exit the method with no edges */
          sts = OM_S_SUCCESS;
          goto ret_end;
          }
      case EX_DATA:
       {
        struct GRid srf_ownr;
        IGRboolean  single_surface=FALSE;
        IGRint      num_components;
        OMuint      loop_count;
        GRclassid   classid, loop_classid;
        OM_S_CHANSELECT  to_loops;
        OM_S_OBJECT_LINKAGE loop_list;

        sts = om$get_classid (
              objid = me->event.located_object[0].located_obj.objid,
              osnum = me->event.located_object[0].located_obj.osnum,
              p_classid = &classid);

        sts = om$is_ancestry_valid( subclassid = classid,
                                    superclassid = OPP_EMSedge_class_id);

        if ( sts != OM_S_SUCCESS)
         { me->process_state = IDENTIFY_EDGE;  break; }

        /* check to see if the edge is owned by a graphics loop */

        EMmake_chanselect(EMSedge_to_owner, &to_loops);

        sts = om$get_channel_objects(
               objid = me->event.located_object[0].located_obj.objid, 
               osnum = me->event.located_object[0].located_obj.osnum, 
               p_chanselect = &to_loops, 
               list = &loop_list, 
               size = 1, 
               count = &loop_count);
        EMomerr_hndlr(sts, ret_end, "om$get_channel_objects");

        sts = om$get_classid (
               objid = loop_list.S_objid, 
               osnum = me->event.located_object[0].located_obj.osnum, 
               p_classid = &loop_classid);
        EMomerr_hndlr(sts, ret_end, "om$get_classid");

        sts = om$is_ancestry_valid( subclassid = loop_classid, 
                       superclassid = OPP_EMSgraloop_class_id);
        EMomerr_hndlr(sts, ret_end, "om$is_ancestry_valid");

        if(sts == OM_S_SUCCESS) 
          {
            ex$message ( msgnumb = EMS_S_InvalidEdge);
            display_mode = GRhe ;
            sts = EFhilite_edge_with_weight( &msg, me->ModuleInfo,
                  me->event.located_object[0].located_obj.objid,
                  display_mode );
            EMomerr_hndlr(sts, ret_end, "EFhilite_edge_with_weight");

            me->process_state = IDENTIFY_EDGE;
            break;
           }          
       
        ME.COroot->ModuleInfo = me->event.located_object[0].module_info; 
        first_edge = me->event.located_object[0].located_obj.objid;
        objspc_num = me->event.located_object[0].located_obj.osnum;

        /* Check to see if the edge belongs to the same composite */
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
            ex$message ( msgnumb = EMS_S_SingleSurfNotAllowed);
            display_mode = GRhe ;
            sts = EFhilite_edge_with_weight( &msg, me->ModuleInfo,
                                             first_edge, display_mode );
            EMomerr_hndlr(sts, ret_end, "EFhilite_edge_with_weight");

            me->process_state = IDENTIFY_EDGE;
            break;
           }          

        if(!me->numed)
         me->active_GRid = srf_ownr;
        else
         if ((me->active_GRid.objid != srf_ownr.objid) ||
            (me->active_GRid.osnum != srf_ownr.osnum))
         {
          /*Nupe.*/
            ex$message ( msgnumb = EMS_S_EdgePartDiffComposite );
            display_mode = GRhe ;
            sts = EFhilite_edge_with_weight( &msg, me->ModuleInfo,
                                             first_edge, display_mode );
            EMomerr_hndlr(sts, ret_end, "EFhilite_edge_with_weight");

            me->process_state = IDENTIFY_EDGE;
            break;
          }

         /* Calculate the edge nearest to the accept point */

         EFboreline(&msg, my_id, &me->event, &boreline);

         if(!(me->uniformval == -1))
         {
          hitedge = TRUE;
          sts = EFhitedge(&msg, ME.COroot->ModuleInfo, first_edge,
                         me->event, &boreline, &hitedge);
          EMomerr_hndlr(sts, ret_end, "EFhitedge error");         
         }
         sts = om$send( msg = message EMSedge.EMxyz_endpt( &msg, NULL,
                        &ME.COroot->ModuleInfo.md_env, NULL, NULL, 
                        beg_xyz_pt, end_xyz_pt, NULL ),  
               targetid = first_edge,
               targetos = objspc_num) ;
         EMomerr_hndlr (sts, ret_end, "EMxyz_endpt"); 
                 
         BSdistptli(&msg, beg_xyz_pt, boreline.point1, 
                    boreline.point2, &dist1);

         BSdistptli(&msg, end_xyz_pt, boreline.point1, 
                    boreline.point2, &dist2);

         if ( dist1 < dist2 )
             right_vertex = FALSE;
         else
             right_vertex = TRUE;           

         num_elements = om$dimension_of(varray = me->located_obj);
         if ((me->numed + 1) >= num_elements)
         {
           sts = om$vla_set_dimension(varray = me->located_obj,
                                         size = num_elements + 2);
           EMomerr_hndlr(sts, ret_end, "set_dimension  error");

           sts = om$vla_set_dimension(varray = me->rt_vertex,
                                         size = num_elements + 2);
           EMomerr_hndlr(sts, ret_end, "set_dimension  error");
         }

         if(me->uniformval == -1)
          {
           
           edges[index] = first_edge;
           backup = TRUE;   /* simulated for right 'right_vertex' */
            goto uniform_backup;
          }
         else
          {
            me->numed++ ;
            me->located_obj[me->numed-1] = first_edge;
            me->rt_vertex[me->numed-1] = right_vertex;
            if(!hitedge)
              me->process_state = IDENTIFY_EDGE;
            else    
              me->process_state = CHOOSE_EDGE;
           }
         break;
        }
       default:
         goto ret_end;
       }
     break;               
    }

    case CHOOSE_EDGE:
     {
     IGRushort edge_options=0;
     IGRint num_buff = 10;
     IGRboolean edge_already_picked = FALSE;
 
     first_edge = me->located_obj[me->numed-1];
     right_vertex = me->rt_vertex[me->numed-1];

     num_edges = 0;
     edges = NULL;
     is_rightend=NULL;
     index = 0;

     /* Get the dominant edges for this vertex */
     edge_options = EMSvtxedges_nodegenerate | EMSvtxedges_onlydominant |
                    EMSvtxedges_noseamedge | EMSvtxedges_notangent |
                    EMSvtxedges_onlycommon;

     sts = om$send(msg = message  EMSedge.EMgetvtxedges(&msg, 
                          edge_options, right_vertex,
                          num_buff, &num_edges, &edges,
                          &is_rightend), 
                   targetid = first_edge,
                   targetos = objspc_num );
     EMomerr_hndlr ( sts, ret_end, "EMgetvtxedges"); 

     /* first hilite the edge which is on the same surface as the last
        two selected edges. */

     if(me->numed >= 2)
      EFput_edge_on_same_surface( &msg, me->located_obj[me->numed-2],
               me->located_obj[me->numed-1], &edges[1], (num_edges-1),
               &is_rightend[1], objspc_num);

     if(num_edges == 1)
      {
        me->process_state = IDENTIFY_EDGE;
       }

  
  /* Start Big loop for picking edges */ 
   for ( index=1; index<num_edges; index++)
    {
     /* Check to see if this edge or its common edge have already been
        located  */

     edge_already_picked = FALSE;
     sts = EMmake_chanselect( EMSedge_to_common_edge, &chan_to_common_edge);

     for ( i=0; i< (me->numed-1); i++ )
     {
      sts = om$get_channel_objects(
               osnum = objspc_num,
               objid = ME.ECsfedloc->located_obj[i],
               p_chanselect = &chan_to_common_edge,
               list = &comm_edge,
               size = 1,
               count = &count);
      EMomerr_hndlr ( sts, ret_end, "get_channel_objects");
 
      if((IF_EQ_OBJID( edges[index], me->located_obj[i])) || 
         (IF_EQ_OBJID( edges[index], comm_edge.S_objid)))
           {
            edge_already_picked = TRUE;
             if(index == (num_edges-1)) me->process_state = IDENTIFY_EDGE;
            break;
           } 
       }

      if ( edge_already_picked )   continue;
           
      /* Highlight the element */
  uniform_backup:
      
      display_mode = GRhd;
      sts = EFhilite_edge_with_weight( &msg, me->ModuleInfo, 
                                       edges[index], display_mode );
      EMomerr_hndlr(sts, ret_end, "EFhilite_edge_with_weight");

      if(me->uniformval!=-1)
       {
        ex$message ( msgnumb = EMS_P_AcceptNearEdge,
                     buff    = string );
        event_mask = GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON;
       }
      else
       {
        IGRchar  newstring[20];
        if(!me->numed)
          ex$message ( msgnumb = EMS_S_Enter,
                       buff    = string )
        else
          ex$message ( msgnumb = EMS_S_AcceptWith,
                       buff    = string)

        strcat( string, " ");
        strcat( string, status_string);
        ex$message ( msgnumb = EMS_S_MoveOnToReject,
                     buff    = newstring );

        strcat( string, newstring);
        event_mask = GRm_VALUE | GRm_BACK_UP | GRm_RJT_MOVEON;
       }

      stat_func = ems$getevent ( msg = &msg,
           event_mask = event_mask,
           value_type = GRIO_DISTANCE,
           prompt = string,
           response = (long *)response,
           response_data = response_data,
           event = &me->event);

     ex$message ( msgnumb = EMS_P_ClearPromptField);

     if (stat_func == FALSE)
      {
       ex$message ( msgnumb = EMS_E_FailureInputProcessing);
       *response = TERMINATE;
       goto ret_end;
      }
     if ( me->event.response == GR_UNKNOWN_TYPE )
      {
       display_mode = GRhe ;
       sts = EFhilite_edge_with_weight( &msg, me->ModuleInfo,
                                        edges[index], display_mode );
       EMomerr_hndlr(sts, ret_end, "EFhilite_edge_with_weight");

       *ret_msg = EMS_I_Interrupt;
       goto ret_end;
      }

     if((me->event.response == EX_VALUE) || 
        (me->event.response == EX_DATA))
       {
        num_elements = om$dimension_of(varray = me->located_obj);
        if ((me->numed + 2) >= num_elements)
         {
           sts = om$vla_set_dimension(varray = me->edgeval_event,
                                         size = num_elements + 2);
           EMomerr_hndlr(sts, ret_end, "set_dimension  error");
         }
        if(me->event.response == EX_VALUE)
         {
          me->edgeval_event[me->numed] = me->event; /**.event.value;**/
          hitedge = TRUE; /* simulate a hit */
         }
        else
        {
         EFboreline(&msg, my_id, &me->event, &boreline);

         sts = EFhitedge(&msg, ME.COroot->ModuleInfo, edges[index],
                         me->event, &boreline, &hitedge);
         EMomerr_hndlr(sts, ret_end, "EFhitedge error");         
        }
        if(!backup)
         {
          if( is_rightend[index])        
             right_vertex = FALSE;
          else
             right_vertex = TRUE;
         }
        num_elements = om$dimension_of(varray = me->located_obj);
        if ((me->numed + 1) >= num_elements)
         {
           sts = om$vla_set_dimension(varray = me->located_obj,
                                         size = num_elements + 2);
           EMomerr_hndlr(sts, ret_end, "set_dimension  error");
         }

        {
           sts = om$vla_set_dimension(varray = me->rt_vertex,
                                         size = num_elements + 2);
           EMomerr_hndlr(sts, ret_end, "set_dimension  error");
         }

        ME.ECsfedloc->numed++;
        me->located_obj[me->numed-1] = edges[index];
        me->rt_vertex[me->numed-1] = right_vertex;
        first_edge = edges[index];
        if(hitedge)
          me->process_state = CHOOSE_EDGE;
        else
          me->process_state = IDENTIFY_EDGE;
        backup = FALSE;
        break;
        }
       else if (me->event.response == EX_BACK_UP)
        {
         display_mode = GRhe ;
         sts = EFhilite_edge_with_weight( &msg, me->ModuleInfo,
                                          edges[index], display_mode );
         EMomerr_hndlr(sts, ret_end, "EFhilite_edge_with_weight");

         if(!me->numed) 
           {
             me->process_state = IDENTIFY_EDGE;
             goto ret_end;
           }
         edges[index] = me->located_obj[me->numed-1];
         right_vertex = me->rt_vertex[me->numed-1];
         ME.ECsfedloc->located_obj[ME.ECsfedloc->numed-1] = NULL;
         me->rt_vertex[me->numed-1] = NULL;
         ME.ECsfedloc->numed--;        
         backup = TRUE; 
         goto uniform_backup;
         }
       else if (me->event.response == EX_RJT_MOVEON)
        {
         display_mode = GRhe;
         sts = EFhilite_edge_with_weight( &msg, me->ModuleInfo,
                                          edges[index], display_mode );
         EMomerr_hndlr(sts, ret_end, "EFhilite_edge_with_weight");

         if(backup)
          {
           me->process_state = IDENTIFY_EDGE;
           backup = FALSE;
           break;
          }
         if(index == (num_edges - 1))
          me->process_state = IDENTIFY_EDGE;
         else
          continue;
         }
        else
         goto ret_end;

     }  /* end Big loop for picking edges */

     break;
    }

  default:
     goto ret_end;
    } /* me->process_state */
  }

 while( TRUE);

 ret_end:

  if(edges) om$dealloc(ptr=edges);

  if(!edge_locatable)
   EFset_locate_eligibility(&msg,0,"EMSedge");

  return(sts);

}
  

/*History
        SCW     06/29/93        Dealloced the curve pointers
        AMD     10/17/91        Increased the tolerance by 4.
	DLB	9/21/91		Pass &size(dbl) to dit_tol not value - 
				SUN crash.
        AMD     August,91       Creation.
*/


IGRlong EFhitedge(msg, module_info, edgeid, locate_event, boreline, hitedge)

IGRlong  *msg;
struct   GRmd_env module_info;
GRobjid  edgeid ;
struct   GRevent  locate_event;
struct   IGRline  *boreline;
IGRboolean   *hitedge;
{
  IGRdouble                   wintol, intpar ;
  IGRpoint                    intpoint;
  IGRint                      nret, sizd=sizeof(IGRdouble);
  struct var_list             list_var[4];
  IGRlong                     sts, ret_bytes, which_error;
  IGRdouble                   scale ;
  struct IGRbsp_curve         curve;

  extern void BSmdptcvbx();

  sts = OM_S_SUCCESS;
  *msg = EMS_S_Success;

   curve.poles = NULL;
   curve.knots = NULL;
   curve.weights = NULL;
   curve.bdrys = NULL;
                

   gr$get_dit_tolerance(msg = msg, sizbuf = &sizd,
                       buffer = &wintol, nret = &nret);

   wintol = 4*wintol;


   list_var[0].var            = VVOL_VIEWPORT_SCALE;
   list_var[0].var_ptr        = (char *)&scale;
   list_var[0].num_bytes      = sizeof(IGRdouble);
   list_var[0].bytes_returned = &ret_bytes;

   list_var[1].var            = END_PARAM;
   list_var[1].var_ptr        = NULL;
   list_var[1].num_bytes      = 0;
   list_var[1].bytes_returned = NULL;

   sts = dp$inq_set_gragad (msg = msg,
          osnum = locate_event.event.button.osnum,
          gragad_objid = locate_event.event.button.objid,
          which_error = &which_error,
          var_list = list_var);
   EMomerr_hndlr (sts, ret_end, "dp$inq_set_gragad");

   wintol /= scale; 
   

   boreline->point1[0] = 2*boreline->point1[0] - boreline->point2[0];
   boreline->point1[1] = 2*boreline->point1[1] - boreline->point2[1];
   boreline->point1[2] = 2*boreline->point1[2] - boreline->point2[2];

   sts = om$send (msg = message EMSedge.EMget_bcxyz_geom(
                  msg, &module_info.md_env, NULL, 
                  NULL, 0, MAXINT, FALSE, NULL, &curve),
           targetid = edgeid,
           targetos = module_info.md_id.osnum,              
           senderid = NULL_OBJID);
   EMomerr_hndlr (sts, ret_end, "EMget_bcxyz_geom");

   BSmdptcvbx( &curve, boreline->point1, boreline->point2,
               wintol, &intpar, intpoint, hitedge, &msg);

 ret_end:
   if( curve.poles )   om$dealloc( ptr = curve.poles );
   if( curve.knots )   om$dealloc( ptr = curve.knots );
   if( curve.weights ) om$dealloc( ptr = curve.weights );
   if( curve.bdrys )   om$dealloc( ptr = curve.bdrys );

   return (sts);

} 
            


IGRlong EFput_edge_on_same_surface( msg, edge1, edge2, edges,
                                    num_edges, right_end, osnum)

/* 
 DESCRIPTION
   This function gets the surface common to edge1 and edge2 and
proceeds to find the edge in the edges list which belong to the above
surface. It then puts this edge on top of the list.

HISTORY
 AMD       :  10/17/91   : Creation

*/

IGRlong         *msg;
GRobjid         edge1, edge2, *edges;
IGRint          num_edges;
IGRboolean      *right_end;
OMuword         osnum;
{
 IGRlong              sts;
 GRobjid              local_edges[4], srf[4], surf1, 
                      surf2, leader_surface, *tmp_edges;
 OM_S_CHANSELECT      to_common_edge;
 OM_S_OBJECT_LINKAGE  common_edge1, common_edge2, comm_edge;
 IGRint               i, j;
 OMuint               count;
 IGRboolean           *temp_end;

 *msg = EMS_S_Success;
 sts  = OM_S_SUCCESS;
 j=0; i=0; count=0;

 tmp_edges = (GRobjid *) om$malloc (size = num_edges * sizeof(GRobjid));
 temp_end = (IGRboolean *)om$malloc(size=num_edges * sizeof(IGRdouble));

 /* make a copy of edges and right_end stuff */

 for (i=0; i<num_edges; i++)
  {
   tmp_edges[i] = edges[i];
   temp_end[i]  = right_end[i];
  }

 /* Get the common edge of the two input edges */ 

 EMmake_chanselect(EMSedge_to_common_edge, &to_common_edge);

 local_edges[0] = edge1;
 sts = om$get_channel_objects( osnum = osnum,
                               objid = edge1,
                               p_chanselect = &to_common_edge,
                               list = &common_edge1,
                               size = 1,
                               count = &count);
 EMomerr_hndlr ( sts, ret_end, "get_channel_objects");

 if(count)
   local_edges[1] = common_edge1.S_objid;
 else 
   local_edges[1] = NULL_OBJID;

 count=0;
 local_edges[2] = edge2;
 sts = om$get_channel_objects( osnum = osnum,
                               objid = edge2,
                               p_chanselect = &to_common_edge,
                               list = &common_edge2,
                               size = 1,
                               count = &count);
 EMomerr_hndlr ( sts, ret_end, "get_channel_objects");

 if(count)
   local_edges[3] = common_edge2.S_objid;
 else
   local_edges[3] = NULL_OBJID;

 /* Get the surface to which these edges belong */

 for (i=0; i<4; i++)
  {
   if(local_edges[i] != NULL_OBJID)
    {
     sts = om$send ( msg = message EMSboundary.EMgetsurface_info
                           (msg, &srf[i], NULL),
                     targetid = local_edges[i],
                     targetos = osnum ,
                     senderid = NULL_OBJID);
     EMerr_hndlr(!(1&*msg&sts),*msg,EMS_E_SurfaceError,ret_end);
    }
   else
     srf[i] = NULL_OBJID;
  }  

 /* The surface in question is one that occurs more than once */

 leader_surface = NULL_OBJID;
 for(i=0; i<4; i++)
  {
   for(j=0; j<4; j++)
    {
     if((j!=i) && (srf[i] == srf[j]))
      {
       leader_surface = srf[i];
       break;
      }
    }
   if(leader_surface != NULL_OBJID) break;
  }

 /* Get the surfaces of the array of edges supplied and their common
    edges  */
 
 for (i=0; i<num_edges; i++)
  {
   sts = om$get_channel_objects(osnum = osnum,
                                objid = edges[i],
                                p_chanselect = &to_common_edge,
                                list = &comm_edge,
                                size = 1,
                                count = &count);
   EMomerr_hndlr ( sts, ret_end, "get_channel_objects");
   
   sts = om$send ( msg = message EMSboundary.EMgetsurface_info
                         (msg, &surf1, NULL),
                   targetid = edges[i],
                   targetos = osnum ,
                   senderid = NULL_OBJID);
   EMerr_hndlr(!(1&*msg&sts),*msg,EMS_E_SurfaceError,ret_end);

   sts = om$send ( msg = message EMSboundary.EMgetsurface_info
                         (msg, &surf2, NULL),
                   targetid = comm_edge.S_objid,
                   targetos = osnum,
                   senderid = NULL_OBJID);
   EMerr_hndlr(!(1&*msg&sts),*msg,EMS_E_SurfaceError,ret_end);

   /* find the edge( and its common edge) which belong to the 
      leader surface. Put this edge on top of the list and push down
      all edges above this by one */ 

   if( ((leader_surface==surf1)||(leader_surface==surf2)) && i>0 )
    {
     edges[0] = tmp_edges[i];
     right_end[0] = temp_end[i];

     edges[1] = tmp_edges[0];
     right_end[1] = temp_end[0];

      while (i > 1)
       {
        edges[i] = tmp_edges[i-1];
        right_end[i] = temp_end[i-1];
        i--;
       }
     break;
    }

  }

ret_end:
 
  if(tmp_edges) om$dealloc(ptr=tmp_edges);
  if(temp_end) om$dealloc(ptr=temp_end);

 return (sts);
}
  
end implementation ECsfedloc; 
