class implementation COadd_opt;


#include "coparadef.h"
#include "coparamac.h"
#include "AS_status.h"
#include "asdef.h"
#include "asbox.h"
#include "asmacros.h"
#include "nddef.h"
#include "OMmacros.h"
#include "OMprimitives.h"
#include "dpmacros.h"
#include "exmacros.h"

#define AS_DEBUG 1
#include "msmacros.h"
#include "ASmessages.h"


from GRgraphics import GRdisplay, GRgetprops;
from ASnode     import ASadd_opt;
from NDnode     import NDmove_to_root,NDdisplay,NDget_objects,NDdelete,
                       NDchg_state;
from NDnode     import NDattach_to_cs,NDdetach_from_cs;
from NDnode     import NDattach_to_track_pt,NDdetach_from_track_pt;
from GRvg       import GRchgprops;
from ACcpx      import find_macro;
from ACmacro_defn import ACgive_name;
from GRowner	import GRdrop;

#define OPT_POINT_LOC 0x01
#define OPT_CS_LOC    0x02
#define ERASE              0x04
#define DISPLAY              0x08
#define CS_MANIP      0x20


#define ATTACH_TO_TRACK   0x1d  /* dec 29  */
#define DETACH_FROM_TRACK 0x1c  /* dec 28  */
#define ATTACH_TO_CS      0x22  /* dec 34  */
#define DETACH_FROM_CS    0x20  /* dec 32  */
#define MOVE_TO_ROOT      0x40  /* dec 64  */
#define REM_OVERRIDE      0x88  /* dec 136 */
 
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             wakeup                               */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method wakeup ( int pos)
{
 me->acc_opt =  AS_P_AccRej;
 me->loc_obj =  AS_P_IdNewObjStop;
 me->acc_obj =  AS_P_AccNextObj;

 switch (me->mytype)
  {
   case ATTACH_TO_TRACK :
     ex$message(msgnumb = AC_M_AtObjTrack);
     me->loc_opt =  AS_P_IdTrkPnt;
     me->loc_obj =  AS_P_IdObjAttach;
     break;

   case ATTACH_TO_CS :
     ex$message(msgnumb = AC_M_AtObjCoor);
     me->loc_opt = AS_P_IdCoordSys  ;
     me->loc_obj =  AS_P_IdObjAttach;
     break;
 
   case DETACH_FROM_TRACK : 
     ex$message(msgnumb = AC_M_DisTP);
     me->loc_obj =  AS_P_IdObjDettach;
     break;
 
   case DETACH_FROM_CS :
     ex$message(msgnumb = AC_M_DisRef);
     me->loc_obj =  AS_P_IdObjDettach;
     break;
 
   case MOVE_TO_ROOT :
     ex$message(msgnumb = AC_M_ChtNAS);
     me->loc_obj = AS_P_IdObjNAS;
     break;
 
   case REM_OVERRIDE :
     ex$message(msgnumb = AC_M_RemParOvr);
     me->loc_obj = AS_P_IdCurve;
     break;
   
   default : 
     printf("unkown command\n");
     printf("COadd_opt mytype x ->%x  d-> %d\n",me->mytype,me->mytype);
     me->mytype = 0;
     return(OM_W_ABORT);
  }

 return( OM_S_SUCCESS);
}



/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             execute                              */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method execute ( int *response; char *response_data; int  pos)
{

#define NUM_STATES  2
#define NUM_ACTIONS 6
#define NUM_TOKENS  4


enum possible_states {         INITIAL,
                        HAV_OPT 
                     };

enum possible_actions {        NIL,
                        ERR,
                        LOC_OPT,
                        STO_OPT,
                        LOC_OBJ,
                        STO_OBJ
                       };

enum possible_entry {
                     PARENT,
                     NOENT
                    };

static IGRint TokenList[] =
                       { RESET,
                        MOVE_ON,
                        GR_UNKNOWN_TYPE ,
                        LOC_PARENT
                      };


static enum possible_states NewState[NUM_STATES][NUM_TOKENS] = {

/*        *********************** TOKENS ***********************
   Old State  *   RESET   , MOVE_ON   , UNKNOWN   ,   PARENT */

/* INITIAL    */ {INITIAL , INITIAL   , INITIAL   , HAV_OPT   },
/* HAV_OPT    */ {INITIAL , INITIAL   , HAV_OPT   , HAV_OPT   }};

static enum possible_actions Action[NUM_STATES][NUM_TOKENS] = {

/*        *********************** TOKENS ***********************
   Old State  *   RESET     , MOVE_ON   ,  UNKNOWN   , PARENT  */

/* INITIAL    */ {LOC_OPT   , LOC_OPT   ,  LOC_OPT   , STO_OPT    },
/* HAV_OPT    */ {LOC_OPT   , LOC_OPT   ,  LOC_OBJ   , STO_OBJ    }};
                                            

    IGRlong      msg,status;     /* routine return status */
    IGRint      size;           /* size of GRevent buffer (struct GRevent) */
    IGRlong     display_flag;   /* display flag for locate filter */
    IGRlong     input_mask;     /* mask for GRgetevent */
    IGRlong     locate_mask;    /* mask for GRgetevent */

    IGRint resp;
    struct GRevent grevent1, grevent2;     /* event returned by GRgetevent */
    struct GRid  DisplayGrid, located_obj;
    struct ret_struct ret_geom;
    IGRint mask;
    struct GRid *obj_to_modify;  /* array of object to attach to option. root*/ 
    IGRint      i_obj,                 /* index in the array                              */
                nb_obj;          /* number of objects in array                       */
    struct GRid context;
    struct GRid obj_to_m;
    struct GRid contents;
    IGRint count;
    GRclassid classid;


    IGRint token;
    enum possible_entry entry_required;
   
    *response = TERMINATE;
    if(me->mytype == 0) return (OM_W_ABORT); /* unkown command */

    /*| Get module id and space number. */
    status = GRfindmod(&DisplayGrid);
    as$status(action = RET_STATUS);

    /*| Initialization for locate  */
    size = sizeof (struct GRevent);
    locate_mask = GRm_DATA | GRm_STRING | GRm_RESET | GRm_MOVE_ON;
    input_mask  = GRm_DATA | GRm_RESET;

   do
    {
     switch (me->action)
      {       
       case NIL:
         break;

       case ERR:
         ex$message( msgnumb = AS_E_InvDefRest);
         break;

       case LOC_OPT  : /*|  Identify the future opt point   */

         display_flag = ELEM_HILIGHT | ALL_WINDOWS;
         entry_required = PARENT;
         me->attr.properties =  LC_DP_ONLY | LC_LC_ONLY | LC_RW;

         if     (me->mytype & OPT_POINT_LOC)
           {
            mask = point_generic;
           }
         else if(me->mytype & OPT_CS_LOC)
           {
            mask = ref_generic;
           }
         else
           {
            entry_required = NOENT;
            me->state = HAV_OPT  ;
            me->action = LOC_OBJ ;
            me->opt_root.objid = NULL_OBJID;
           }
         break;

       case STO_OPT  : /*|  store the information about optionnal object */

         status = as$make_source(go_grid = located_obj,
                        context_grid = context,
                        as_os = me->ModuleInfo.md_id.osnum,
                        as_grid = &me->opt_root);

       case LOC_OBJ: /*| Identify object to modify  */
          mask = ~0;
          entry_required = PARENT;
          display_flag = ELEM_HILIGHT | ALL_WINDOWS | LC_ACCEPT_CURSOR;
          me->attr.properties =  LC_DP_ONLY | LC_LC_ONLY | LC_WRITE_ONLY;
          if (me->mytype == ATTACH_TO_TRACK ||
              me->mytype == DETACH_FROM_TRACK)
          {
            me->attr.owner_action |= (LC_INTERMIDIATE | LC_BOTTOM_UP);
          }              

          if (me->mytype == ATTACH_TO_CS)
          {
            me->attr.owner_action |= LC_HANDLES;
          }              

          break;

       case STO_OBJ: /*| Modify object */
          if((token != 0) && (grevent1.response != SPECIFIED_OBJ))
                EXputq_front(&msg, &resp, (IGRlong *)&size, (IGRchar *)&(grevent2.event));

           ASstart_fence(located_obj,me->ModuleInfo.md_id.osnum,
                         &nb_obj,&obj_to_modify, &resp,response_data);
           /*"nb_obj %d first %d\n",nb_obj,obj_to_modify[0].objid */

           /* create contents if necessary */
           contents.objid = NULL_OBJID;
           if(me->mytype == ATTACH_TO_CS)
                {
                status = asmake_contents(me->opt_root,&contents);
                as$status(action = RET_STATUS);
               }

           for(i_obj=0 ; i_obj<nb_obj ; i_obj++)
              {
               as$make_source(go_grid = obj_to_modify[i_obj],
                              as_os= me->ModuleInfo.md_id.osnum,
                              as_grid = &obj_to_m);
               if(!status&1) continue;

               if(me->mytype & ERASE)
                {
                  status=om$send(msg = message NDnode.NDdisplay
                                                    (0,GRbehe,&me->ModuleInfo ),
                              targetid = obj_to_m.objid,
                              targetos = obj_to_m.osnum);
                  as$status();        
                }

               switch(me->mytype)
                {
                 case ATTACH_TO_TRACK   :
                        status = om$send( msg         = message 
                                                NDnode.NDattach_to_track_pt(
                                                        &msg,
                                                        me->opt_root,
                                                        &obj_to_m,
                                                        &me->ModuleInfo),
                            targetid = obj_to_m.objid,
                            targetos = obj_to_m.osnum);
                        /*^ as$status(); */
                 break;
                 
                 case ATTACH_TO_CS :
                  status = om$send(msg =  message NDnode.NDattach_to_cs(&msg,
                              me->opt_root,contents,&obj_to_m,&me->ModuleInfo),
                                targetid = obj_to_m.objid,
                                targetos = obj_to_m.osnum);

                 break;

                  case DETACH_FROM_TRACK :
                        status = om$send( msg         = message 
                                                NDnode.NDdetach_from_track_pt(
                                                        &msg,
                                                        me->opt_root,
                                                        &obj_to_m,
                                                        &me->ModuleInfo),
                            targetid = obj_to_m.objid,
                            targetos = obj_to_m.osnum);
                        /*^ as$status(); */
                  break;

                  case DETACH_FROM_CS :
                  status = om$send(msg =  message NDnode.NDdetach_from_cs(&msg,
                               me->opt_root,contents,&obj_to_m,&me->ModuleInfo),
                                targetid = obj_to_m.objid,
                                targetos = obj_to_m.osnum);
                  break;

                 case MOVE_TO_ROOT :
                  /* 
                   * if the guy is a constraint: forget it 
                   */
                  om$get_classid ( osnum = obj_to_m.osnum, objid = obj_to_m.objid,
                    p_classid = &classid );
                  if((om$is_ancestry_valid ( subclassid = classid,
                                superclassname="SKconstraint" ) == OM_S_SUCCESS) ||
                     (om$is_ancestry_valid ( subclassid = classid,
                                superclassname="SKgeometry" ) == OM_S_SUCCESS))
                    break;

                  /*
                   * Erase the guy
                   */
                  om$send ( msg = message NDnode.NDdisplay ( 0, GRbehe, &me->ModuleInfo ),
                    targetid = obj_to_m.objid, targetos = obj_to_m.osnum );
          
                  /* if the guy is a dimension, send a GRdrop message */
                  if(om$is_ancestry_valid ( subclassid = classid,
                                superclassname="DMroot" ) == OM_S_SUCCESS)
                  {
			status =
			om$send(msg = message GRowner.GRdrop(&msg, &me->ModuleInfo),
				targetid = obj_to_m.objid,
				targetos = obj_to_m.osnum);
			break;		
                  }
                  
                  status = om$send( msg = message NDnode.NDmove_to_root(&msg,
                                                    &obj_to_m, &me->ModuleInfo),
                                targetid = obj_to_m.objid,
                                targetos = obj_to_m.osnum );
                  /*
                   * Re-display the guy
                   */
                  {
                    enum GRdpmode DisplayMode = GRbd;
                    
                    om$send ( msg = message GRgraphics.GRdisplay ( &msg,
                      &me->ModuleInfo.md_env.matrix_type, me->ModuleInfo.md_env.matrix, 
                      &DisplayMode, &me->ModuleInfo.md_id ), targetid = obj_to_m.objid, 
                      targetos = obj_to_m.osnum );
                  }
                  break;

                case REM_OVERRIDE :
                 {
                  struct GRid modifier,null_grid;
                     IGRlong rc;
                      IGRboolean action = 1;
                      IGRshort mask = GRIS_DISPLAYABLE | GRIS_LOCATABLE;
 
                  null_grid.objid = NULL_OBJID;
                  ASfind_modifier(obj_to_m,null_grid,&modifier);

                  if(!IF_NULL_OBJID(modifier.objid))
                   {
                       status = om$send(msg = message GRvg.GRchgprops
                                                            (&rc,&action,&mask),
                                     targetid = obj_to_m.objid,
                                     targetos = obj_to_m.osnum);
                        as$status();

                        status = om$send(msg = message NDnode.NDchg_state
                                                               (ND_DIS_BY_CH,0),
                                     targetid = obj_to_m.objid,
                                     targetos = obj_to_m.osnum);
                        as$status();

                    status=om$send(msg = message NDnode.NDdisplay
                                                    (0,GRbehe,&me->ModuleInfo ),
                              targetid = modifier.objid,
                              targetos = modifier.osnum);
                    as$status();        

                        status = om$send(msg = message NDnode.NDdelete
                                                     (&me->ModuleInfo),
                                     targetid = modifier.objid,
                                     targetos = modifier.osnum);
                        as$status();
                    }
                   break;
                  }
                }
  
              if(me->mytype & DISPLAY)
                {
                 status=om$send(msg = message NDnode.NDdisplay
                                                     (0,GRbd, &me->ModuleInfo ),
                              targetid = obj_to_m.objid,
                              targetos = obj_to_m.osnum);
                 as$status();        
                }

             } /*end loop on object */


           /* delete contents if not used */
           if(me->mytype == ATTACH_TO_CS)
                {
                status = om$send(msg = message NDnode.NDget_objects(ND_CHILDREN,
                                        NULL,0,NULL,1,0,&count),
                                 targetid = contents.objid,
                                 targetos = contents.osnum);
                if((status&1) && count == 0)
                  {
                   /*| delete contents */
                   status = om$send(msg = message NDnode.NDdelete
                                                              (&me->ModuleInfo),
                                    targetid = contents.objid,
                                    targetos = contents.osnum);
                   as$status();
                       }
               }

           ASend_fence();
      }  /* end  switch (me->action) */

  switch (entry_required)
  {

   case PARENT :    /*| get parent */

    if(me->state == INITIAL)
      {
        ex$message( buff =  me->loc_prompt, msgnumb = me->loc_opt);
        ex$message( buff =  me->acc_prompt, msgnumb = me->acc_opt);
        ex$message( buff =  me->reloc_prompt, msgnumb = AS_E_EleNotFound);
      }
    else
      {
        ex$message( buff =  me->loc_prompt, msgnumb = me->loc_obj);
        ex$message( buff =  me->acc_prompt, msgnumb = me->acc_obj);
        ex$message( buff =  me->reloc_prompt, msgnumb = AS_E_EleNotFound);

      }
    token = ASget_parent( &msg,TokenList, &grevent1, &grevent2,
                       &locate_mask, &input_mask, &size, &display_flag,
                       &resp, response_data, me->loc_prompt,
                       me->acc_prompt, me->reloc_prompt,
                       &me->attr, &me->locate_stack,
                       mask,&located_obj,&context,&ret_geom);

    if ( (msg&1) &&
	 (me->mytype == ATTACH_TO_CS) && 
	 (me->action == STO_OPT || me->action ==  STO_OBJ ))
    {
      IGRshort properties = 0;
      IGRint is_naughty_object = 0;
      
      /* In this case we may have located one of the naughty objects 
       * (constraints, v.g. solid, or dimmensions.  These elements 
       * should not be attached to a coordinate system.  At some later
       * date, these elements should be eliminated in the locate process
       * itself.  Thus this fix can be classified as a KLUDGE! 
       * Shelley Heard 3/19/92
       */
      status = om$send( msg = message GRgraphics.GRgetprops( &msg, 
                                                             &properties), 
                        senderid = NULL_OBJID,
                        targetid = located_obj.objid,
                        targetos = located_obj.osnum );

      if ( properties & GRIS_ASSOCIATIVE )
      {
         is_naughty_object = 1;
      }
      else
      { 
         GRclassid located_classid;
         extern GRclassid OPP_DIroot_class_id;
         extern GRclassid OPP_SKconstraint_class_id;

         status = om$get_classid ( osnum=located_obj.osnum,
                                   objid=located_obj.objid,
                                   p_classid = &located_classid );

         if((om$is_ancestry_valid(
	       subclassid   = located_classid,
               superclassid = OPP_DIroot_class_id)==OM_S_SUCCESS) ||
            (om$is_ancestry_valid(
	       subclassid   = located_classid,
               superclassid = OPP_SKconstraint_class_id)==OM_S_SUCCESS))
         {
            is_naughty_object = 1;
         }
      }    

      if (is_naughty_object) 
      {
         UI_status ("Attachment failed! Not a valid element type");
	 sleep ( 2 );
      }
    }
    break;

   case NOENT:    /*| no entry */
    break;
     

  } 

 /* new action and new state */

    if( entry_required != NOENT)
     {
       me->action = (IGRint) Action[   me->state ][ token ];
       me->state =  (IGRint) NewState[ me->state ][ token ];
     }

  /*" action %d state %d\n",me->action, me->state */


   }  while(entry_required == NOENT || TokenList[token] != GR_UNKNOWN_TYPE);

    *response = resp;
    return( OM_S_SUCCESS);

}   /*  end execute  */


end implementation COadd_opt;



