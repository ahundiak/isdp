/*----

     Abstract:  This method allows to change parents of a parametric
        object by another.

     CHANGE HISTORY:

        ch   11-jan-86 : Design date
        dp   02-nov-87 : Modif for the parameters.
        jla    sept-88 : swap children
	Sudha 06/20/94 : Initialize located_obj.objid in execute method - Purify

*/

class implementation COchangroot;


#include "coparadef.h"
#include "AS_status.h"
#include "expression.h"
#include "expmacros.h"
#include "nddef.h"
#include "lcmacros.h"
#include "ndmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "asbox.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "griomacros.h"
#include "msmacros.h"
#include "ASmessages.h"
#include "OMmacros.h"
#include "OMprimitives.h"
#include "dpmacros.h"
#include "madef.h"

#define AS_DEBUG

from GRgraphics   import  GRdisplay;
from ASnode       import  ASpossible_parent, NDchange_connect;
from NDnode 	  import  NDget_objects,NDdisplay;

extern GRclassid OPP_expression_class_id;

#define SWAP_ROOT 1
#define SWAP_CHILDREN 2

#define MAX_OBJ 5

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                                  wakeup                                    */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method wakeup( IGRint Centring_Attribute)
{
  UI_prompt("");
       if(me->mytype & SWAP_ROOT)     {ex$message( msgnumb = AC_M_ChRoot);}
  else if(me->mytype & SWAP_CHILDREN) {ex$message( msgnumb = AC_M_ChChild);}
  return(OM_S_SUCCESS);
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                                   execute                                  */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method execute
  (
  int  *response;                /* type of response                          */
  char *response_data;           /* contents of the response                  */
  int  pos                       
 )
  {
#define NUM_STATES 4
#define NUM_ACTIONS 8
#define NUM_TOKENS 5


enum possible_states { 	INITIAL,
		        HAV_OBJ,
			HAV_OLD,
			HAV_NEW
		     };

enum possible_actions {	NIL,
			ERR,
			LOC_OBJ,
			STO_OBJ,
			LOC_OLD,
			STO_OLD,
			LOC_NEW,
			CHANGE
		       };

enum possible_entry {
		     PARENT,
		     PARAM,
	             NOENT
		    };

static IGRint TokenList[] =
 		      { RESET,
		        STRING,
			GR_UNKNOWN_TYPE ,
			LOC_PARENT,
                        LOC_PARAM
		      };


static enum possible_states NewState[NUM_STATES][NUM_TOKENS] = {

/*        *********************** TOKENS *****************************
   Old State  *   RESET     ,  STRING   , UNKNOWN   , PARENT , PARAM */

/* INITIAL    */ {INITIAL   , INITIAL   , INITIAL   , HAV_OBJ, INITIAL },
/* HAV_OBJ    */ {INITIAL   , HAV_OBJ   , HAV_OBJ   , HAV_OLD, HAV_OBJ },
/* HAV_OLD    */ {HAV_OBJ   , HAV_OLD   , HAV_OLD   , HAV_NEW, HAV_OLD },
/* HAV_NEW    */ {INITIAL   , INITIAL   , INITIAL   , INITIAL, INITIAL }};


static enum possible_actions Action[NUM_STATES][NUM_TOKENS] = {

/*        *********************** TOKENS *******************************
   Old State  *   RESET     ,  STRING   , UNKNOWN   , PARENT   , PARAM */

/* INITIAL    */ {LOC_OBJ   , LOC_OBJ   , LOC_OBJ   , STO_OBJ  , LOC_OBJ },
/* HAV_OBJ    */ {LOC_OBJ   , LOC_OBJ   , LOC_OLD   , STO_OLD  , LOC_OBJ },
/* HAV_OLD    */ {LOC_OLD   , LOC_OLD   , LOC_NEW   , CHANGE   , CHANGE  },
/* HAV_NEW    */ {LOC_OBJ   , LOC_OBJ   , LOC_OBJ   , LOC_OBJ  , LOC_OBJ }};

                                            
  enum GRdpmode     DisplayMode;    /* display mode for display msg send */
  IGRlong     status;         /* routine return status */
  IGRint      size;           /* size of GRevent buffer (struct GRevent) */
  IGRlong     display_flag;   /* display flag for locate filter */
  IGRlong     input_mask;     /* mask for GRgetevent */
  IGRlong     locate_mask;    /* mask for GRgetevent */
  IGRlong     msg;      /* function return code */
  IGRdouble   param_value;    /* Value of the parameter                     */
  IGRint resp;
  struct GRevent grevent1, grevent2;     /* event returned by GRgetevent */
  struct GRid  DisplayGrid;
  struct GRid  located_obj;              /* object located               */
  struct GRid  context;
  IGRint token = 0;
  struct ret_struct ret_geom;
  enum possible_entry entry_requested = NOENT;
  IGRint i_root,root_count,nb_to_change,i_to_change;
  struct GRid *root,*obj_to_change,*buffer;
  struct GRid _to_change[MAX_OBJ];
  IGRchar *ptr;
  IGRint cn_type;
  int req_type = 0;
  

  /* return initialisization and control type of command */

  *response = TERMINATE;
  if(me->mytype != SWAP_ROOT &&
     me->mytype != SWAP_CHILDREN ) return (OM_W_ABORT);

  /*| get module id and space number */

  status = GRfindmod(&DisplayGrid);
  as$status();

  /*| Initialization for locate */

  size = sizeof (struct GRevent);
  locate_mask = GRm_DATA | GRm_STRING | GRm_RESET | GRm_SPECIFIED_OBJ;
  input_mask  = GRm_DATA | GRm_STRING | GRm_RESET | GRm_SPECIFIED_OBJ;
  display_flag = ELEM_HILIGHT | ALL_WINDOWS;

  /*| Loop until exit condition occurs */

  do
    {
     switch (me->action)
       {       
       case NIL:
       /*| case NIL:*/
       break;

	 case ERR  :
	   ex$message( msgnumb = AS_E_InvDefRest);
           break;

         case LOC_OBJ:
	   /*| LOC_OBJ */

	   if(me->mytype & SWAP_CHILDREN)
             {
  	      /*| not necessary for change children */
	      me->state = HAV_OBJ;
	      me->action = LOC_OLD;
              entry_requested = NOENT;
	      break;
             }
	   else
	     {
	      /*| locate object to change root */
              ex$message(buff = me->loc_prompt,
			 msgnumb = AS_P_IdObjRoottoChange);
              ex$message(buff = me->acc_prompt, msgnumb = AS_P_AccRej);
              dp$erase_hilite(msg = &status);
	      me->attr.properties = LC_DP_ONLY | LC_LC_ONLY | LC_WRITE_ONLY;
              entry_requested = PARENT;
	      req_type = ~0;
	     }
           break;

         case STO_OBJ:

         /*| case STO_OBJ */

           /*
            *  store object to change root in the instances
            */

	    me->object = located_obj;
            /*" Element = %d\n",me->object.objid*/

         case LOC_OLD:
            /*| 1/2 hilite the old parents and prompt to identify one of them */

	  if(me->mytype == SWAP_ROOT)
	   {
            ex$message(buff = me->loc_prompt, msgnumb = AS_P_IdKeyRoottoChange);

	    nd$get_graph(nb_tip = 1, p_tip = &me->object);
	    nd$get_list_in_graph(buf_addr = &root, p_count = &root_count,
				 rej_type = ND_TIP);
	    /*" root_count %d\n",root_count */

	    for(i_root=0 ; i_root<root_count ; i_root++)
	      {
               status = om$send(msg = message NDnode.NDdisplay
					(0,GRhhd,&me->ModuleInfo),
                         targetid = root[i_root].objid,
                         targetos = root[i_root].osnum);
               as$status();
	      }
	    }
	  else
	    {
             ex$message(buff=me->loc_prompt,msgnumb = AS_P_IdKeyChildtoChange);
	    }

	    me->attr.properties = LC_DP_ONLY | LC_LC_ONLY | LC_RW;
            ex$message(buff = me->acc_prompt, msgnumb = AS_P_AccRej);
            entry_requested = PARENT;
	    req_type = ~0;
          break;

	case STO_OLD:
  
            /*| Store the information about the parent */

            me->root[0] = located_obj;
            me->context[0] = context;
	    me->type[0] = ret_geom.type;
            /*" Old root = %d\n",me->root[0].objid*/

	case LOC_NEW:

            /*| locate the new root*/
 
             ex$message( buff = me->acc_prompt, msgnumb = AS_P_AccRej);
             if(me->type[0]&parameter_generic)
              {
	       ex$message( buff =  me->loc_prompt, msgnumb = AS_P_IdKeyNewPara);
               entry_requested = PARAM;
              }
             else
              {
	       ex$message( buff =  me->loc_prompt, msgnumb = AS_P_IdNewRoot);
               entry_requested = PARENT;
              }
	     req_type = me->type[0];
	     break;

	case CHANGE:

            /*| Store information about new root in the instance */

            me->root[1] = located_obj;
            me->context[1] = context;
            /*" New root = %d\n",me->root[1].objid*/
             
	    /* prepare restart of command */
            entry_requested = NOENT;
            me->action = LOC_OBJ;
            me->state = INITIAL;

            /* get object to change root or chldren */


	    ptr = NULL;
	    if(me->mytype == SWAP_ROOT)
	      {
               as$make_source( go_grid = me->object, 
			       as_os= me->ModuleInfo.md_id.osnum,
	    	               as_grid = &me->object);

               if(IF_NULL_OBJID(me->object.objid))
	        {
	         ex$message( msgnumb = AS_E_InvDefRest);
	         break;
	        }
	      }

	   /* jla 28 Apr 92 : change dependent acrross reference files */

	   if(me->root[0].osnum == me->ModuleInfo.md_id.osnum) 
	   {
            /* Root and dependency are in the same OS */
            as$make_source( go_grid = me->root[0],
			    context_grid = me->context[0],
	                    as_os = me->ModuleInfo.md_id.osnum, 
			    as_grid = &me->root[0] );

	    /*"change children of %d\n",me->root[0].objid */

            if(IF_NULL_OBJID(me->root[0].objid)) return OM_W_ABORT;

	    status=om$send(msg=message NDnode.NDget_objects
						 (ND_CHILDREN|ND_IN_BUF,
						  NULL,0,&buffer,0,OM_K_MAXINT,
						  &nb_to_change),
			      targetid = me->root[0].objid,
			      targetos = me->root[0].osnum);
	    as$status(action = RET_STATUS);
	    /*" --> %d\n", nb_to_change */

	    if(nb_to_change > MAX_OBJ)
		 { ptr = om$malloc( size = nb_to_change*sizeof(struct GRid));
		   if(ptr == NULL) return(OM_W_ABORT);
		   obj_to_change = (struct GRid *) ptr;
		 }
	       else
		 {
		  obj_to_change = _to_change;
		 }

	    /*
		 For the change root command change only connection on
		 object that are dependent upon the swap root and parent
		 of the object to change root.
	    */

	    for(i_to_change = 0; i_to_change < nb_to_change; i_to_change++)
	      {
	       obj_to_change[i_to_change] = buffer[i_to_change];
	      }

	    for(i_to_change = 0; i_to_change < nb_to_change; i_to_change++)
	      {
	        if(  (me->mytype == SWAP_ROOT)
	              && !nd$dep_exist(l_root = &obj_to_change[i_to_change],
					nb_root = 1,
			   		l_tip  = &me->object,
				 	nb_tip = 1 ))
   		      { obj_to_change[i_to_change].objid = NULL_OBJID;}
	      }
 
            /*| get if necessary source for the new roots */

            as$make_source( go_grid = me->root[1],
			    context_grid = me->context[1],
	                    as_os = me->ModuleInfo.md_id.osnum, 
			    as_grid = &me->root[1] );
	    as$status(action = RET_STATUS);


        /* 3 loops for batch purpose */
        DisplayMode = GRbe;
        for (i_to_change = 0; i_to_change < nb_to_change; i_to_change++)
          {
	     if(obj_to_change[i_to_change].objid == NULL_OBJID) continue;
             om$send( msg = message GRgraphics.GRdisplay( &msg,
                      			&me->ModuleInfo.md_env.matrix_type,
                      			me->ModuleInfo.md_env.matrix,
                      			&DisplayMode, &DisplayGrid),
                      targetid = obj_to_change[i_to_change].objid,
		      targetos = obj_to_change[i_to_change].osnum);
          }

        for (i_to_change = 0; i_to_change < nb_to_change; i_to_change++)
          {
	   IGRint i, nb_roots;
	   char   flag;

	   if(obj_to_change[i_to_change].objid == NULL_OBJID) continue;

           /*| Verify if there is a loop */
	   if(nd$dep_exist(l_root = &obj_to_change[i_to_change], nb_root = 1,
			   l_tip  = &me->root[1], nb_tip = 1 )) continue;

           /*| Verify the new root is not already one and the located is */
	   status=om$send(msg=message NDnode.NDget_objects
						 (ND_ROOT|ND_IN_BUF,
						  NULL,0,&buffer,0,OM_K_MAXINT,
						  &nb_roots),
                      targetid = obj_to_change[i_to_change].objid,
		      targetos = obj_to_change[i_to_change].osnum);
	   as$status(action = RET_STATUS);
           flag = FALSE;
           for(i=0;i<nb_roots;i++) 
	     if(IF_EQ_OBJID(buffer[i].objid,me->root[1].objid)) flag = TRUE;
	   if(flag) continue;
       
           flag = TRUE;
           for(i=0;i<nb_roots;i++) 
	     if(IF_EQ_OBJID(buffer[i].objid,me->root[0].objid)) flag = FALSE;
	   if(flag) continue;
	
           /*| Swap the connections of the object */
           status = om$send(msg = message ASnode.NDchange_connect( 1,
						    &me->root[0], &me->root[1]), 
		     	     targetid = obj_to_change[i_to_change].objid,
		     	     targetos = obj_to_change[i_to_change].osnum);
           as$status(action = RET_STATUS);

	   cn_type = ND_COMP;
	   nd$wait_batch(type = GR_GEOM_POSTED,
               		 l_object = &obj_to_change[i_to_change],
               		 l_obj_info = &cn_type,
               		 nb_obj   = 1);

          }

        /*| Display object */
        GRabsg_del_all();
        DisplayMode = GRbd;
        for (i_to_change = 0; i_to_change < nb_to_change; i_to_change++)
          {
	    if(obj_to_change[i_to_change].objid == NULL_OBJID) continue;
            om$send( msg = message GRgraphics.GRdisplay( &msg,
                     			&me->ModuleInfo.md_env.matrix_type,
                     			me->ModuleInfo.md_env.matrix,
                     			&DisplayMode, &DisplayGrid),
                     targetid = obj_to_change[i_to_change].objid,
		     targetos = obj_to_change[i_to_change].osnum);
           }
	   if(ptr != NULL)
	     {om$dealloc(ptr = ptr); /*| dealloc ptr */}
	  }
	else if(me->root[1].osnum != me->ModuleInfo.md_id.osnum)
	  {
	   OM_S_OBJECT_LINKAGE *pretend;
	   struct GRid obj_grid;
 	   OM_S_CHANSELECT misc_chan;
           GRspacenum prev_osnum, dummy;
           IGRboolean prev_tag;
           OMuint dummy_tag;
	   
	   /* Root and dependency are in different OS */

           status = om$get_channel_count(objid = me->root[0].objid,
				osnum = me->root[0].osnum,
                                p_chanselect = &AS_notification,
                                count = (OMuint *)&nb_to_change);

    	   status = om$make_chanselect(channame = "GRcontext.to_misc",
            			       p_chanselect = &misc_chan);
           as$status(action = RET_STATUS);

 
	   if(nb_to_change)
	   {
   	    pretend =(OM_S_OBJECT_LINKAGE *) om$malloc
                            (size = nb_to_change * sizeof(OM_S_OBJECT_LINKAGE));
    	    if(!pretend) return OM_W_ABORT;

            status = om$get_channel_objects(objid = me->root[0].objid,
				osnum = me->root[0].osnum,
                                p_chanselect = &AS_notification,
                                list = pretend,
                                size = nb_to_change,
                                count = (OMuint *)&nb_to_change);
	    for(i_to_change=0 ; i_to_change<nb_to_change ; i_to_change++)
	     {
	      if(pretend[i_to_change].osnum != me->ModuleInfo.md_id.osnum)
								 continue;
	      status = om$send(msg = message Root.wild_disconnect(AS_listeners),
			       targetid = pretend[i_to_change].S_objid,
			       targetos = pretend[i_to_change].osnum);
	      status = om$send(msg = message Root.connect(
						AS_listeners,OM_K_MAXINT,
				      me->context[1].objid,me->context[1].osnum,
				      misc_chan,OM_K_MAXINT),
			       targetid = pretend[i_to_change].S_objid,
			       targetos = pretend[i_to_change].osnum);

     	      prev_tag = om$enable_tag_connects( flag = TRUE );

              om$set_tag_os( p_prev_osnum = &prev_osnum,
                             osnum        = me->root[1].osnum);

              /*
                  Make sure both objects are tagged.  The object in the
                  reference file *must* have the tag to avoid ISO connections.
                  The object in the master file does not necessarily have to
                  have the tag, but it doesn't hurt to put it there just in
                  case.  The return status from om$add_tag is ignored; someone
                  may have turned off tagging for a valid reason.
              */

              if (i_to_change == 0)
              {
                  status = om$objid_to_tag(osnum = me->root[1].osnum,
                                           objid = me->root[1].objid,
                                           p_tag = &dummy_tag);
                  if (status == OM_W_NOTTAGGED)
                  {
                      om$add_tag(osnum = me->root[1].osnum,
                                 objid = me->root[1].objid,
                                 p_tag = &dummy_tag);
                  }
              }
                                    
              status = om$objid_to_tag(osnum = pretend[i_to_change].osnum,
                                       objid = pretend[i_to_change].S_objid,
                                       p_tag = &dummy_tag);
              if (status == OM_W_NOTTAGGED)
              {
                  om$add_tag(osnum = pretend[i_to_change].osnum,
                             objid = pretend[i_to_change].S_objid,
                             p_tag = &dummy_tag);
              }

              status = om$send(msg = message Root.connect(
                                                AS_listeners,OM_K_MAXINT,
                                      me->root[1].objid,me->root[1].osnum,
                                      AS_notification,OM_K_MAXINT),
                               targetid = pretend[i_to_change].S_objid,
                               targetos = pretend[i_to_change].osnum);

              om$set_tag_os( p_prev_osnum = &dummy, osnum = prev_osnum );

	      obj_grid.objid = pretend[i_to_change].S_objid;
	      obj_grid.osnum = pretend[i_to_change].osnum;
	      nd$wait_batch(type = GR_GEOM_POSTED,
               		 l_object = &obj_grid,
               		 l_obj_info = &cn_type,
               		 nb_obj   = 1);

	     }
	    if(pretend) om$dealloc(ptr = pretend);
	   }
	  }
        else ex$message(msgnumb = AS_E_ChFail);

         break;
        }   /* end switch (ME.super_cmd->state) */

    switch (entry_requested)
	{

    case PARENT :
	/*| Get_parent */
/*
 * Do this to locate reference planes.
 * pp 08/18/92
 */
        me->attr.owner_action |= LC_HANDLES;
        located_obj.objid = NULL_OBJID;
        if ((me->mytype & SWAP_ROOT) && (me->action != STO_OLD) && (me->action != STO_OBJ))
          /* Don't locate profile stuff */
          token = ASget_parent2 (&msg,TokenList, &grevent1, &grevent2,
                       &locate_mask, &input_mask, &size, &display_flag,
                       &resp, response_data, me->loc_prompt,
                       me->acc_prompt, me->reloc_prompt,
                       &me->attr, &me->locate_stack,
                       req_type,&located_obj,&context,&ret_geom);
        else
          token = ASget_parent (&msg,TokenList, &grevent1, &grevent2,
                       &locate_mask, &input_mask, &size, &display_flag,
                       &resp, response_data, me->loc_prompt,
                       me->acc_prompt, me->reloc_prompt,
                       &me->attr, &me->locate_stack,
                       req_type,&located_obj,&context,&ret_geom);
        
        if(TokenList[token] == STRING)
            {
             IGRlong rc;

             /*| The parent is a parameter or a macro*/

 	     rc = di$translate( objname = response_data,
				p_objid = &located_obj.objid,
				p_osnum = &located_obj.osnum);

	     if(rc == DIR_S_SUCCESS)
	      {
	       status = as$any_give_structure(go_grid = located_obj,
					      mod_env = &me->ModuleInfo,
					      inst = &ret_geom);
	       if(status&1)
		        for(token=0 ; TokenList[token] != LOC_PARENT ; token++);
	      }

            }/* end if(TokenList[token] == STRING) */
	break;


    case PARAM :
	/*| Get_param */
        located_obj.objid = NULL_OBJID; /* purify fix */
	token = ASget_all_param (&msg,TokenList, &grevent1, &grevent2,
                       &locate_mask, &input_mask, &size, &display_flag,
                       &resp, response_data, me->loc_prompt,
                       me->acc_prompt, me->reloc_prompt,
                       &me->attr, &me->locate_stack,
                       req_type,&located_obj,&param_value);
	context.objid = NULL_OBJID;
        if(IF_NULL_OBJID(located_obj.objid))
          {
          ex$message( msgnumb = AS_E_ParaNFound);
          entry_requested = NOENT;
          me->action   = LOC_NEW;
          ME.super_cmd->state = HAV_OLD;
        }

	break;

     case NOENT:
     /*| case NOENT */
	break;
     
     default :
	return(0);  /* waiting something better .... */

	}  /* end switch entry_requested  */

    /*| new action and new state */

    if( entry_requested != NOENT)
     {
       me->action = (IGRint) Action[   ME.super_cmd->state ][ token ];
       ME.super_cmd->state =  (IGRint) NewState[ ME.super_cmd->state ][ token ];
     }


  /*"token : %d \n new_action : %d \n",token,me->action */
  /*"new_state : %d \n",ME.super_cmd->state */

   }  while(  entry_requested == NOENT ||
             TokenList[token] != GR_UNKNOWN_TYPE);   /* end do */

    *response = resp;
    dp$erase_hilite(msg = &status);
    return( status);

}   /*  end execute method */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                                 Get Parents                                */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

/* 
  select a parent with a given type
  Return its objid, objspace and give_structure
  This duplicates the code is ASget_par.I to avoid locating profiles for change
  root. Next release, we'll add an argument to as$get_parent.
*/

struct ctl_par_arg           /* Arguments for the act. handler(parents,param) */
{
  IGRint type_generic;       /* Type for the selection criteria               */
  struct GRlc_stack *stack;  /* Contains the information of the stack         */
  IGRint num_eligible;       /* Number of eligible elements if any            */
			     /* If 0, all elements are eligible		      */
  struct GRid *eligible;     /* Array of eligible elements                    */
  IGRint num_non_eligible;   /* Number of non eligible elements if any 	      */
  struct GRid *non_eligible; /* Array of non eligible 			      */
  char *macro_name;          /* macro name				      */
  GRclassid classid;         /* eligible class				      */
};

#omdef as$get_parent2(
   msg = NULL,
   TokenList = TokenList,
   event1 = NULL,
   event2 = NULL,
   locate_mask = GRm_DATA|GRm_STRING|GRm_RESET|GRm_BACK_UP,
   input_mask =  GRm_DATA|GRm_STRING|GRm_RESET|GRm_BACK_UP, 
   event_size = sizeof(struct GRevent),
   display_flag = ELEM_HILIGHT | ALL_WINDOWS, 
   response = response,
   response_data = response_data,
   loc_prompt   = me->loc_prompt,
   acc_prompt   = me->acc_prompt,
   reloc_prompt = me->reloc_prompt, 
   attr = &me->attr,
   locate_stack = &me->locate_stack,
   type_generic = ~0,
   macro_name = NULL,
   nb_eligible = 0,
   eligible = NULL,
   nb_non_eligible = 0,
   non_eligible = NULL,
   returned_obj,
   returned_context,
   returned_struct = NULL)

ASget_var_parent2( (msg) , (TokenList) , (event1) , (event2),
   (locate_mask) , (input_mask) , (event_size) , (display_flag),
   (response) , (response_data) , (loc_prompt) , (acc_prompt) , (reloc_prompt),
   (attr) , (locate_stack),
   (type_generic) , (macro_name),
   (nb_eligible) , (eligible) , (nb_non_eligible) , (non_eligible),
   (returned_obj), (returned_context) , (returned_struct))

#endomdef

IGRint ASget_parent2
  (
  ret_code,TokenList,event1,event2,locate_mask,input_mask,event_size,
  display_flag,response,response_data,locate_prompt,acc_prompt,relocate_prompt,
  attributes,stack,type_generic,located_obj,context,obj_struct )

  IGRlong   *ret_code;            /* Return code from ls$locate               */
  IGRint    TokenList[];          /* List of token of the command object      */
  struct    GRevent   *event1;    /* Event for the locate point               */
  struct    GRevent   *event2;    /* Event for the accept point               */
  IGRlong   *locate_mask;         /* Mask for the locate                      */
  IGRlong   *input_mask;          /* Mask for the input events                */
  IGRint    *event_size;          /* Size of the returned event               */
  IGRlong   *display_flag;        /* Flag to define the display mode          */
  IGRint    *response;            /* Response returned from GRgetevent        */
  IGRchar   *response_data;       /* Response data returned from GRgetevent   */
  IGRchar   *locate_prompt;       /* Prompt for the locate step               */
  IGRchar   *acc_prompt;          /* Prompt for the accept step               */
  IGRchar   *relocate_prompt;     /* Prompt for the relocate step             */
  IGRint    type_generic;         /* Type of entity to select                 */
  struct GRlc_locate *attributes; /* Attributes to be found                   */
  struct GRlc_stack  *stack;      /* Contains objid and context               */
  struct GRid        *located_obj;/* Located object                           */
  struct GRid        *context;    /* Context object                           */
  struct ret_struct  *obj_struct; /* Structure of the returned object         */

  /*.ASget_parent*/
  {
  long status;
  status = as$get_parent2(
		msg = ret_code,
		TokenList = TokenList,
		event1 = event1,
		event2 = event2,
		locate_mask = *locate_mask,
		input_mask = *input_mask,
		event_size = *event_size,
		display_flag = *display_flag,
		response = response,
		response_data = response_data,
		loc_prompt = locate_prompt,
		acc_prompt = acc_prompt,
		reloc_prompt = relocate_prompt,
		attr = attributes,
		locate_stack = stack,
		type_generic = type_generic,
		returned_obj = located_obj,
		returned_context = context,
		returned_struct  = obj_struct );
  return status;
 }

IGRint ASget_var_parent2
  ( ret_code,TokenList,event1,event2,locate_mask,input_mask,event_size,
  display_flag,response,response_data,locate_prompt,acc_prompt,relocate_prompt,
  attributes,stack,type_generic,macro_name,nb_eligible,eligible,
  nb_non_eligible,non_eligible,located_obj,context,obj_struct )

  IGRlong   *ret_code;            /* Return code from ls$locate               */
  IGRint    TokenList[];          /* List of token of the command object      */
  struct    GRevent   *event1;    /* Event for the locate point               */
  struct    GRevent   *event2;    /* Event for the accept point               */
  IGRlong   locate_mask;         /* Mask for the locate                      */
  IGRlong   input_mask;          /* Mask for the input events                */
  IGRint    event_size;          /* Size of the returned event               */
  IGRlong   display_flag;        /* Flag to define the display mode          */
  IGRint    *response;            /* Response returned from GRgetevent        */
  IGRchar   *response_data;       /* Response data returned from GRgetevent   */
  IGRchar   *locate_prompt;       /* Prompt for the locate step               */
  IGRchar   *acc_prompt;          /* Prompt for the accept step               */
  IGRchar   *relocate_prompt;     /* Prompt for the relocate step             */
  struct GRlc_locate *attributes; /* Attributes to be found                   */
  struct GRlc_stack  *stack;      /* Contains objid and context               */
  IGRint    type_generic;         /* Type of entity to select                 */
  char *macro_name;
  struct GRid *eligible,*non_eligible;
  int nb_eligible,nb_non_eligible;
  struct GRid        *located_obj;/* Located object                           */
  struct GRid        *context;    /* Context object                           */
  struct ret_struct  *obj_struct; /* Structure of the returned object         */
 {
  IGRlong status,msg,loc_ret_code;
  IGRint  index_token;            /* Index returned for the tokenlist         */
  struct  ctl_par_arg act_parms;  /* Contains the value for the selection     */
  struct  GRevent  loc_event1,loc_event2;
  struct  GRevent  locate_event;  /* Event for the locate point               */
  struct  GRmd_env *mod_env;      /* Information about the environment        */
  int is_set; 			  /* Located object is a set		      */
  int ASctl_parent_type ();
  OM_S_CLASSLIST eligible_classes, *p_eligible;
  GRclassid list_of_classes [5];
  GRclassid SKconstraint_class_id;
  GRclassid SKgeometry_class_id;
  GRclassid SKmgr_class_id;
  GRclassid SKvariable_class_id;
  GRclassid SKgmhndlpt_class_id;

  if(event1 == NULL) event1 = &loc_event1;
  if(event2 == NULL) event2 = &loc_event2;
  if(ret_code == NULL) ret_code = &loc_ret_code;


/*"get_parent with type %x\n",type_generic */

  /* Initialize the arguments for the action handler */
  act_parms.type_generic = type_generic;
  act_parms.stack        = stack;
  act_parms.macro_name   = macro_name;
  act_parms.num_eligible   = nb_eligible;
  act_parms.eligible   = eligible;
  act_parms.num_non_eligible   = nb_non_eligible;
  act_parms.non_eligible   = non_eligible;

  /* Call locate filter to locate an object  */

/* en attendant que le locate par nom marche mieux */

  locate_mask = (locate_mask | GRm_SPECIFIED_OBJ) & (~GRm_STRING);

  *ret_code = MSSUCC;

/*********
lc$locate takes eventsize as *int.  The following call was just passing int.
I added the & to event_size.  This was a hidden problem on the clipper but
crashes on the sparc. - Dave Brann 10/5/91.
**********/

/*********
The default class list was being used (GRgraphics) but we want to prevent
the locate of profile components.  The w_flags are defined in lcmacros.h
Jimmy Dodd 03/04/92.
**********/
            
  if (om$get_classid ( classname = "SKconstraint", 
         p_classid = &SKconstraint_class_id ) == OM_S_SUCCESS)
  {
    om$get_classid ( classname = "SKvariable", p_classid = &SKvariable_class_id );
    om$get_classid ( classname = "SKmgr", p_classid = &SKmgr_class_id );
    om$get_classid ( classname = "SKgeometry", p_classid = &SKgeometry_class_id );
    om$get_classid ( classname = "SKgmhndlpt", p_classid = &SKgmhndlpt_class_id );
    eligible_classes.w_count   = 5;
    eligible_classes.w_flags   = 3;
    eligible_classes.p_classes = list_of_classes;
    list_of_classes[0] = SKconstraint_class_id;
    list_of_classes[1] = SKvariable_class_id;
    list_of_classes[2] = SKgmhndlpt_class_id;
    list_of_classes[3] = SKgeometry_class_id;
    list_of_classes[4] = SKmgr_class_id;
    p_eligible = &eligible_classes;
  }
  else
    p_eligible = NULL;

  status = lc$locate(rc =ret_code,
                     event1=event1,
                     event2=event2,
                     event3=&locate_event,
                     mask1=locate_mask,
                     mask2=input_mask,
		     eventsize=&event_size,  /*added & - DLB 10/5/91*/
                     display_flag=display_flag,
                     response=response,
                     response_data=response_data,
                     locate_prompt=locate_prompt,
                     acc_prompt=acc_prompt,
                     relocate_prompt=relocate_prompt,
                     attributes=attributes,
                     stack=stack,
                     act_handler=ASctl_parent_type,
		     unhilight_mode = GRhe,
		     eligible_classes = p_eligible, /*added JSD 3/4/92*/
                     act_args=&act_parms);
  /*| After lc$locate */
/*^
   printf("lc$locate status %d ret_code %x response %d\n located_obj %d %d\n",
    status, *ret_code, *response,
    locate_event.located_object[0].located_obj.objid,
    locate_event.located_object[0].located_obj.osnum);
*/

is_set = 0;
if((status&1) && (*ret_code == LC_OBJ_LOCATED))
{
 int stat_class;
  GRclassid obj_class;
  extern GRclassid OPP_GRgrset_class_id;
  stat_class = om$get_classid(p_classid = &obj_class,
    		 objid = locate_event.located_object[0].located_obj.objid,
    		 osnum = locate_event.located_object[0].located_obj.osnum);
  if(   (stat_class&1)
     && (om$is_ancestry_valid( superclassid = OPP_GRgrset_class_id,
     			       subclassid = obj_class) != OM_S_SUCCESS))
   {
   }
  else
   {
    /*| Does not erase fence contents */
    is_set = 1;
   }
}

 /* 
    Locate by name jla 13-oct-89 
 */
  if(*response == STRING)
    {
     char real_name[DI_PATH_MAX];
     int status_dir;
     extern int (*AStranslate) ();

     /*| try translate */
     /*| SUPPOSED TO BE IN CURRENT MODULE BECAUSE I DON'T KNOW HOW TO GET */
     /*| TRANSFORMATION MATRIX						  */

     strcpy ( real_name, response_data );
     if(AStranslate)
      {
	/*| Attention au trou .... */
	status_dir = AStranslate( response_data,
   		   &locate_event.located_object[0].located_obj.objid,
   		   &locate_event.located_object[0].located_obj.osnum,
		   NULL);
      }
     else
      {
       status_dir = di$translate( objname = real_name,
   		   p_objid = &locate_event.located_object[0].located_obj.objid,
   		   p_osnum = &locate_event.located_object[0].located_obj.osnum);
      }
     /*"status %d %x\n",status_dir,status_dir*/
     if(status_dir == DIR_S_SUCCESS)
       {
        event1->response = SPECIFIED_OBJ;
	*ret_code = LC_OBJ_LOCATED;
        locate_event.located_object[0].module_info.md_env.matrix_type = MAIDMX;
        MAidmx(&msg,locate_event.located_object[0].module_info.md_env.matrix);
        /*" %d %d located\n",locate_event.located_object[0].located_obj.objid,locate_event.located_object[0].located_obj.osnum*/
 
       }
    }

  /* Check the return code */

  if(!(status&1)) goto FAILURE; /* filter error */

  if(*ret_code != LC_OBJ_LOCATED) goto INTERRUP;/*No element located */

  /*| An element has been located. */

   located_obj->objid = locate_event.located_object[0].located_obj.objid;
   located_obj->osnum = locate_event.located_object[0].located_obj.osnum;
      

   mod_env = &locate_event.located_object[0].module_info;


/* modif momo 04-01-89 */
/*| get the module env of the located object in event1 */

    event1->located_object[0].module_info = *mod_env;

/* end of modif */

   /*"look for the context matrix type: %d\n",mod_env->md_env.matrix_type*/
   status = GRfindcontext( &msg, &mod_env->md_env.matrix_type, 
                     mod_env->md_env.matrix, &located_obj->osnum, context );
   if(status == OM_S_SUCCESS && msg == MSSUCC )
        {
          /*"context object found: %d, %d\n", context->objid, context->osnum */
          if(context->osnum == located_obj->osnum)
            {
             /*|context dans le meme os */
            }
        }
      else
       {
        context->objid = NULL_OBJID;
        /*"context pas trouve msg = %d\n",msg */
        }

    status = NDctl_parent_type(&msg, type_generic, macro_name, located_obj,
			       mod_env);

    if(!(status&msg&1)) goto FAILURE;

    /* Get if possile the structure of the object selected */
    status=as$any_give_structure(
		           go_grid = (*located_obj),
                           mod_env = mod_env,
			   inst    = obj_struct);
    as$status(action = RET_STATUS);

/*    if(   !(status&1)                       
/*       || !(obj_struct->type & type_generic)) goto FAILURE; 
/****/


/*|SUCCESS : object with right type located */
  for (index_token=0;TokenList[index_token] != LOC_PARENT;index_token++);
  return(index_token);

FAILURE : /*| Failure in locate process */ 
  for (index_token=0; TokenList[index_token] != GR_UNKNOWN_TYPE;index_token++);
  return(index_token);

INTERRUP : /*| Command interupted (by another command for example */
  for (index_token=0; TokenList[index_token] != *response && 
         TokenList[index_token] != GR_UNKNOWN_TYPE; index_token++);
  return(index_token);
}/* end function ASget_parent */

end implementation COchangroot;


