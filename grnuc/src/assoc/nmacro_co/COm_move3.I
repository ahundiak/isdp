/*
     jla  23_sep_86 : Design date
     jla  04-nov-86 : Associative implementation
*/

class implementation COm_move;

#include "msmacros.h"
#include "ASmessages.h"
#include <stdio.h>
#include "coparadef.h"
#include "coparamac.h"
#include "expression.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#include "griomacros.h"
#include "nd.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "AS_status.h"
#include "asbox.h"
#include "OMmacros.h"
#include "exmacros.h"
#include "macro.h"
#include "acdef.h"
#include "acmacros.h"
#include "dpmacros.h"

#define  AS_DEBUG  1

#define set_generic 0x10000000

from NDnode   import NDgive_structure,NDchange_connect,NDget_objects,
	    	NDselect_copy,NDdelete,NDmove_to_tmp_clone,NDcopy_to_tmp_root;

extern GRclassid OPP_expression_class_id;
extern GRclassid OPP_ACmacro_defn_class_id;

extern char *COm_move_form_ptr;


%safe
static IGRint TokenList[] =
 		      {
			RESET,
			GR_UNKNOWN_TYPE ,
			LOC_PARENT,  
			LOC_PARAM
		      };


static enum possible_states NewState[NUM_STATES][NUM_TOKENS] = {

/*            ****************** TOKENS ***********
   Old State  *    RESET    , UNKNOWN  , PARENT    , PARAM */

/* INITIAL    */ { INITIAL  , INITIAL  , WAIT_OBJ , WAIT_OBJ },
/* WAIT_OBJ   */ { WAIT_TEM , WAIT_OBJ , WAIT_OBJ , WAIT_OBJ },
/* WAIT_TEM   */ { WAIT_TEM , WAIT_TEM , WAIT_TEM , WAIT_TEM },
/* FULL_DEF   */ { FULL_DEF , FULL_DEF , FULL_DEF , FULL_DEF }};
 


static enum possible_actions Action[NUM_STATES][NUM_TOKENS] = {

/*            *************TOKENS ********************
   Old State  *     MOVE_ON    , UNKNOWN   , PARENT   , PARAM   */

/* INITIAL    */ { RESTART     , LOC_OBJ   , STO_OBJ  , STO_OBJ },
/* WAIT_OBJ   */ { PRO_TEMP    , LOC_OBJ   , STO_OBJ  , STO_OBJ }, 
/* WAIT_TEM   */ { NEXT_TEMP   , PRO_TEMP  , STO_TEMP , STO_TEMP},
/* FULL_DEF   */ { LOC_FORM    , LOC_FORM  , LOC_FORM , LOC_FORM}};
%endsafe





/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             execute                              */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method execute ( int *response;
                 char *response_data;
                 int  pos)
{
    IGRint      	status;         /* routine return status */
    IGRint      	event_size;     /* size of GRevent buffer */
    IGRlong     	display_flag;   /* display flag for locate filter */
    IGRlong     	input_mask;     /* mask for GRgetevent */
    IGRlong     	locate_mask;    /* mask for GRgetevent */
    IGRlong     	msg;            /* function return code */
    struct GRevent 	grevent1, grevent2;  /* event returned by GRgetevent */
    struct GRid  	context; /* object located        */
    IGRint 		resp;
    IGRint 		i,j;
    IGRint 		token;
    IGRint 		nb_obj,i_obj, ifoot;
    IGRint 		remaining_size, do_not_enable;
    struct ret_struct rst;
    int Obj_Generic;
    double Param;
    char *c,*ct1,*cf,*ct;
    struct GRid *set_obj,fence_grid,source,*obj;
    int mode_batch;
    int start_locate,some_located_not_selected,nb_selected,located_selected;
    GRclassid obj_class;
    char **lines;
    int error;
    int *info,el_type;
   
    *response = TERMINATE;
    if(COm_move_form_ptr == NULL) return OM_S_SUCCESS;

    event_size = sizeof (struct GRevent);
    locate_mask = GRm_DATA | GRm_STRING | GRm_RESET | GRm_BACK_UP;
    input_mask  = GRm_DATA | GRm_STRING | GRm_RESET | GRm_BACK_UP; 
    display_flag = ELEM_HILIGHT | ALL_WINDOWS | NO_PROJ_ACCEPT_POINT;

    nd$mod_batch(request = ND_GET,
                 p_ret_mode = &mode_batch);

    /*
     *  loop until exit condition occurs
     */

   do
    {
      switch (me->action)
      {       
	 case NIL :     /*| nil */
	   break;

	 case ERR :    /*| err  */
	   ex$message( msgnumb = AS_E_InvDefRest);


	 case RESTART : /*| restart */
	   me->state = INITIAL;
	   me->action= LOC_OBJ;
	   me->Nb_Max_Feet = 0;
	   me->Nb_Max_Temp = 0;
	   me->Nb_Max_Obj = 0;
	   me->index_to_locate = 0;
	   me->root_changed = 0;
	   me->set_index = -1;
	   me->Entry_Request = NOENT;
	   if(COm_move_form_ptr) 
	    {
	     status = om$send(msg = message COm_move.write_form
							   (COm_move_form_ptr),
			      targetid = my_id); 
	     as$status();
	     FIg_disable(COm_move_form_ptr,FORM_COPY);
	     FIg_disable(COm_move_form_ptr,FORM_MOVE);
	    }
	   break;

	 case REG_EXP : /*| reg_exp */
	   lines = NULL;
	   nb_obj = 0;
  	   status = di$ls( regexp = response_data ,
                  lines = &lines ,
                  ptr = &nb_obj,
		  options = NULL);
	   if(!(status&1)) break;
	   status = om$send(msg = message COm_move.realloc_obj
						(me->Nb_Max_Obj+nb_obj),
			    targetid = my_id);
           as$status(action = RET_STATUS);

	   me->located_obj.osnum = me->ModuleInfo.md_id.osnum;
           for(i_obj=0 ; i_obj<nb_obj ; i_obj++)
            {
  	     status = di$translate ( osnum =  me->ModuleInfo.md_id.osnum,
                                     objname = lines[i_obj],
                                     p_objid = &me->located_obj.objid,
                                     p_osnum = &me->located_obj.osnum);
	     om$get_classid(objid = me->located_obj.objid,
  	     		    osnum = me->located_obj.osnum,
			    p_classid = &obj_class);
	     if(om$is_ancestry_valid(superclassid = OPP_expression_class_id,
			      subclassid = obj_class) != OM_S_SUCCESS) continue;

             for(j=0;j<me->Nb_Max_Obj;j++)
               { if(me->Obj_List[j].objid == me->located_obj.objid) break;}
             if(j>=me->Nb_Max_Obj)
              {
               me->Obj_Info[me->Nb_Max_Obj]=ND_ROOT | ND_BODY;
               me->Obj_List[me->Nb_Max_Obj++]=me->located_obj;
              }
            }

           if(lines != NULL && nb_obj != 0)
            {
             di$free(lines = lines,
                     count = nb_obj);
	    }


	 case STO_OBJ :   /*| sto_obj */
	  if(me->action == STO_OBJ)
	  {
	   if(grevent1.response != SPECIFIED_OBJ)
	   status = EXputq_front(&msg, &resp, (long *)&event_size, (char *)&(grevent2.event));

              as$start_fence(set = &me->located_obj,
		 set_env = &grevent1.located_object[0].module_info,
                 nb_obj = &nb_obj, p_obj = &set_obj,
                 make_source = TRUE,
		 response = &resp,
		 response_data = response_data);

/*  ASstart_fence(me->located_obj,me->ModuleInfo.md_id.osnum,&nb_obj,
/* 			      &set_obj,&resp,response_data);
/****/

	   status = om$send(msg = message COm_move.realloc_obj
						(me->Nb_Max_Obj+nb_obj),
			    targetid = my_id);
           as$status(action = RET_STATUS);

           /* Store the located object */

	   start_locate = me->Nb_Max_Obj;
	   for(i_obj=0 ; i_obj<nb_obj ; i_obj++)
	    {
	/*     if(me->ModuleInfo.md_id.osnum != set_obj[i_obj].osnum) continue; */
	     status = as$make_source(go_grid = set_obj[i_obj],
                         	     as_os = me->ModuleInfo.md_id.osnum,
                         	     as_grid = &source);
	     if(source.objid == NULL_OBJID) continue;
 
	     for(j=0;j<me->Nb_Max_Obj;j++)
	          { if(me->Obj_List[j].objid == source.objid) break;}
	     if(j>=me->Nb_Max_Obj)
	         {
                  me->Obj_Info[me->Nb_Max_Obj] = ND_ROOT | ND_BODY;
                  me->Obj_List[me->Nb_Max_Obj++]=source;
                  /*"add %d %d\n",source.objid,source.osnum*/
	         }
	    }
	   ASend_fence();
	  }


/* Send them the "select_copy" message to know who is really located */

	some_located_not_selected = 0;
	for(;start_locate < me->Nb_Max_Obj;start_locate++)
           {
            remaining_size =
                      om$dimension_of(varray = me->Obj_List) - me->Nb_Max_Obj;
	    obj = me->Obj_List+me->Nb_Max_Obj;
            info = me->Obj_Info+me->Nb_Max_Obj;
            for(i=0;i<remaining_size;i++) info[i] = ND_ROOT | ND_BODY;

	    status = om$send(msg = message NDnode.NDselect_copy(&msg,0,
			       		obj,info,remaining_size,&nb_selected),
			     targetid = me->Obj_List[start_locate].objid,
			     targetos = me->Obj_List[start_locate].osnum);
	    as$status(action = RET_STATUS);
	    if(nb_selected > remaining_size)
	     {
	      status = om$send(msg = message COm_move.realloc_obj
						(me->Nb_Max_Obj+nb_selected),
			    targetid = my_id);
              as$status(action = RET_STATUS);
              remaining_size =
                      om$dimension_of(varray = me->Obj_List) - me->Nb_Max_Obj;
	      obj = me->Obj_List+me->Nb_Max_Obj;
              info = me->Obj_Info+me->Nb_Max_Obj;
	      status = om$send(msg = message NDnode.NDselect_copy(&msg,0,
			       		  obj,info,remaining_size,&nb_selected),
			     targetid = me->Obj_List[start_locate].objid,
			     targetos = me->Obj_List[start_locate].osnum);
	      as$status(action = RET_STATUS);
	     }
	     /* Only the target of the message is a selected element */
	     if(nb_selected == 1 &&
		me->Obj_List[start_locate].objid == obj[0].objid)
	      {
               me->Obj_Info[start_locate]= me->Obj_Info[start_locate] & *info;
 	       continue;
	      }

	     located_selected = 0;
	     for(i=0;i<nb_selected;i++,obj++,info++)
	      {
	       if(me->Obj_List[start_locate].objid == obj[i].objid)
		{located_selected = 1;
		 me->Obj_Info[start_locate]= me->Obj_Info[start_locate] & *info;
                 continue;
		}
	       
	       for(j=0;j<me->Nb_Max_Obj;j++)
	       {
		if(me->Obj_List[j].objid == obj->objid)
		  {
                   me->Obj_Info[j] = me->Obj_Info[j] & *info;
                   break;
                  }
	       }

	       if(j>=me->Nb_Max_Obj)
		{
                  me->Obj_Info[me->Nb_Max_Obj]=*info;
                  me->Obj_List[me->Nb_Max_Obj++]=*obj;
		}
              }
	     if(!located_selected) 
	      { 
	       some_located_not_selected = 1;
	       me->Obj_List[start_locate].objid = NULL_OBJID;
	      }
	   }

/* remove null objid if any */

	 if(some_located_not_selected)
	  {
	   for(i=0,j=0 ; i<me->Nb_Max_Obj ; i++)
            {
	     if(me->Obj_List[i].objid != NULL_OBJID)
	      {
                me->Obj_Info[j] = me->Obj_Info[i];
	       me->Obj_List[j++] = me->Obj_List[i];
	      }
	    }
	   me->Nb_Max_Obj = j;
	  }

	case GET_GRAPH :  /*| get graph */
        
	  /*| Get internal graph */

	  status = nd$get_internal_graph(p_initial = me->Obj_List,
					 nb_initial = me->Nb_Max_Obj);
	  as$status(action = RET_STATUS);

           /*| Define now template list */

	   
           status = om$send(msg = message COm_move.realloc_template
                                                         (me->Nb_Max_Obj),
                            targetid = my_id);
           as$status(action = RET_STATUS);

           status = om$send(msg = message COm_move.realloc_feet
                                                         (me->Nb_Max_Obj),
                            targetid = my_id);
           as$status(action = RET_STATUS);

           me->Nb_Max_Feet = 0;
           me->Nb_Max_Temp = 0;
           ct = me->Temp_Name;
           ct1 = me->Temp_Clone_Name;
           cf = me->Feet_Name;
           error = 0;

           for(i=0 ; i<me->Nb_Max_Obj ; i++)
             {
              struct GRid *temp;
              IGRint *info;

              temp = &me->Obj_List[i];
              info = &me->Obj_Info[i];

              if((me->Obj_Info[i] == (ND_ROOT | ND_BODY)) ||
                 (!me->Obj_Info[i]))
               {
                nd$get_type(p_object = me->Obj_List+i,
                            nb_obj   = 1,
                            p_type = &el_type);
                el_type = el_type & (ND_ROOT|ND_BODY);
               }
              else if(me->Obj_Info[i] == ND_ROOT) el_type = ND_ROOT;
              else if(me->Obj_Info[i] == ND_BODY) el_type = ND_BODY;
              else { error = 1; break;}

              status = om$send(msg = message NDnode.NDgive_structure(&msg,
                                        &rst, &me->ModuleInfo),
                         targetid = me->Obj_List[i].objid,
                         targetos = me->Obj_List[i].osnum);
              as$status(action = RET_STATUS);

              if(el_type == ND_ROOT)
               {
	        me->Temp_List [me->Nb_Max_Temp]  = me->Obj_List[i];
	        me->Temp_Clone [me->Nb_Max_Temp] = me->Obj_List[i];
                me->Temp_Value[me->Nb_Max_Temp] = rst;


	        COm_generate_name(ct,"ROOT",macro_MAX_CHAR,i,
                                me->Temp_Value[me->Nb_Max_Temp].type,
				me->Temp_List+me->Nb_Max_Temp);
	        strcpy(ct1,ct);
	        ct  += macro_MAX_CHAR;
	        ct1 += macro_MAX_CHAR;
                me->Nb_Max_Temp++;
	       }
              else if(el_type == ND_BODY)
               {
	        me->Feet_List [me->Nb_Max_Feet] = me->Obj_List[i];

	        COm_generate_name(cf,"OUTPUT",macro_MAX_CHAR,me->Nb_Max_Feet,
				rst.type, me->Feet_List+me->Nb_Max_Feet);
	        me->Feet_Type[me->Nb_Max_Feet] = rst.type;
	        cf += macro_MAX_CHAR;
		me->Nb_Max_Feet++;
	       }
	     }
            if(error)
             {
              me->action = ERR;
              me->Entry_Request = NOENT;
              break;
             }

	   status=om$send(msg = message COm_move.write_form(COm_move_form_ptr),
			  targetid = my_id);


         case LOC_OBJ :    /*| loc obj */
           me->attr.properties = LC_DP_ONLY |  LC_LC_ONLY | LC_RW;

           me->attr.owner_action = /* LC_RIGID_COMP  |*/
                            LC_RIGID_OWNER | LC_FLEX_COMP
                          | LC_FLEX_OWNER  | LC_REF_OBJECTS
			  | LC_HANDLES
			  | LC_ASSOCIATIVE | LC_EXTERN_CONSTRAINED;
			     

	   ex$message(buff = me->acc_prompt,msgnumb = AS_P_AccNextObj);
	   if(me->Nb_Max_Obj)
	      {ex$message(buff = me->loc_prompt,msgnumb = AS_P_IdNewObjStop);}
	   else
	      {ex$message(buff = me->loc_prompt,msgnumb = AS_P_IdEl1);}
	   me->Entry_Request = PARENT; 
	   Obj_Generic = ~0;
	   break;


   case STO_TEMP : /*| Store the template */

            /* Disconnect my previous set if I have one for this index */
            if(me->index_to_locate == me->set_index)
             {
              status = om$send(msg = message Root.wild_disconnect
                                                        (me->located_chansel),
                               targetid = my_id);
              as$status();
              me->set_index = -1;
             }

            /* Connect a new set if located */

            if(rst.type&set_generic)
             {
              as$start_fence(set = &me->located_obj,
                             nb_obj = &nb_obj, p_obj = &set_obj,
                             response = response, response_data = response_data,
                             type_generic = Obj_Generic);
              if(nb_obj == 0)
               {
		/*| fence not accepted */
	        me->action = PRO_TEMP;
	        me->Entry_Request = NOENT;
		break;
               }
              else
              {
               OM_S_CHANSELECT his_chan;
               status = om$make_chanselect(p_chanselect = &his_chan,
                                  channame = "GRgrset.to_owners");
               as$status(action = RET_STATUS);

               status = om$send(msg =  message Root.connect(
                                   me->located_chansel, OM_K_MAXINT,
                                   me->located_obj.objid, me->located_obj.osnum,
                                   his_chan, OM_K_MAXINT),
                                targetid = my_id);
               as$status(action = RET_STATUS);
	       me->set_index = me->index_to_locate;
              }
            }
           else
           {
            as$make_source(go_grid = me->located_obj,
                         context_grid = context,
                         as_os = me->ModuleInfo.md_id.osnum,
                         as_grid = &me->located_obj);
           }

	/* To prevent unwanted copy */
	me->root_changed = 1;
	FIg_enable(COm_move_form_ptr,FORM_COPY);
        do_not_enable = FALSE;

        for(ifoot=0 ; ifoot<me->Nb_Max_Feet ; ifoot++)
        {
         OMuword assoc_classid, foot_classid;

         status = om$get_classid(p_classid = &foot_classid,
			   objid = me->Feet_List[ifoot].objid,
			   osnum = me->Feet_List[ifoot].osnum);
         as$status(action = RET_STATUS);

         status = om$get_classid (p_classid = &assoc_classid,
                                  classname = "EMSassoc"); 
         as$status(action = RET_STATUS);

         status = om$is_ancestry_valid(subclassid = foot_classid,
                                       superclassid = assoc_classid);
         if (status == OM_S_SUCCESS)
         {
          do_not_enable = TRUE;
          break;
         }
        }

        if (!do_not_enable)
 	 FIg_enable(COm_move_form_ptr,FORM_MOVE);
        me->Temp_Clone[me->index_to_locate] = me->located_obj;
	c= me->Temp_Clone_Name + me->index_to_locate*macro_MAX_CHAR,
	COm_generate_name(c,"CLONE",macro_MAX_CHAR,me->index_to_locate,
			   me->Temp_Value[me->index_to_locate].type,
			   me->Temp_Clone+me->index_to_locate);


        me->Temp_Value[me->index_to_locate].var = rst.var;

	if(COm_move_form_ptr != NULL)
           COm_display_move_line(COm_move_form_ptr,3,
			me->index_to_locate,
			me->Temp_Name+macro_MAX_CHAR*me->index_to_locate,
			me->Temp_Clone_Name+macro_MAX_CHAR*me->index_to_locate,
			me->Temp_Value+me->index_to_locate,
			&me->located_obj);
/*"T %d is %d\n",me->index_to_locate,me->Temp_Clone[me->index_to_locate].objid*/

   case NEXT_TEMP : /*| Locate next template */

        me->index_to_locate++;
        if(me->index_to_locate>=me->Nb_Max_Temp)
	 {
	  /*|Go back to first template or ready to place */
          for(i=0;i<me->Nb_Max_Temp;i++)
            {
             if(me->Temp_Clone[i].objid != NULL_OBJID) continue;
             if (!(me->Temp_Value[i].type & parameter_generic) ||
                  (me->Temp_Value[i].type == ~0)) break;
	    }
	  
	  if(i<me->Nb_Max_Temp)
           {
            /*| go back in template list */
	    me->Entry_Request = NOENT;
	    me->action = PRO_TEMP;
	    me->index_to_locate = 0;
	    break;
	   }
	  else
	   {
	    /*| Have all the template */
            me->Entry_Request = NOENT;
	    me->action = LOC_FORM;
	    me->state = FULL_DEF;
	    if(COm_move_form_ptr != NULL)
             {FIfld_set_select(COm_move_form_ptr,TEMPLATE_LIST,-1,0,TRUE);
              FIfld_set_select(COm_move_form_ptr,TEMPLATE_LIST,-1,1,TRUE);
              FIfld_set_select(COm_move_form_ptr,TEMPLATE_LIST,-1,2,TRUE);
             }
            break;
	   }
         }

      case PRO_TEMP : 
	/*| PRepar to LOCATE a PARENT */
        me->attr.properties = LC_DP_ONLY |  LC_LC_ONLY | LC_RW;

        me->attr.owner_action = LC_RIGID_COMP
                          | LC_RIGID_OWNER | LC_FLEX_COMP
                          | LC_FLEX_OWNER  | LC_REF_OBJECTS 
			  | LC_HANDLES
			  | LC_ASSOCIATIVE | LC_EXTERN_CONSTRAINED;

	ex$message(buff = me->acc_prompt,msgnumb = AS_P_AccRej);
	ex$message(buff = me->loc_prompt,msgnumb = AS_P_IdReHiTem);

          {/* Verify that the corresponding line is displayed */
	   int first,last;

	   FIfld_get_row_offset(COm_move_form_ptr,TEMPLATE_LIST,&first);
	   if(me->index_to_locate < first)
	    {
	     FIfld_set_active_row(COm_move_form_ptr,TEMPLATE_LIST,
                            me->index_to_locate,0);
	    }
	   FIfld_get_num_vis_rows(COm_move_form_ptr,TEMPLATE_LIST,&last);
	   if(me->index_to_locate > first+last-1)
	    {
	     FIfld_set_active_row(COm_move_form_ptr,TEMPLATE_LIST,
                            me->index_to_locate,last-1);
	    }

	   /*"select row %d\n",me->index_to_locate */

           FIfld_set_select(COm_move_form_ptr,TEMPLATE_LIST,
			    me->index_to_locate,0,TRUE);
           FIfld_set_select(COm_move_form_ptr,TEMPLATE_LIST,
			    me->index_to_locate,1,TRUE);
           FIfld_set_select(COm_move_form_ptr,TEMPLATE_LIST,
			    me->index_to_locate,2,TRUE);
	   if(me->Temp_List[me->index_to_locate].objid == NULL_OBJID)
             {ex$message(buff = me->loc_prompt, msgnumb = AS_P_IdHiTem);}
	   else
             {ex$message(buff = me->loc_prompt, msgnumb = AS_P_IdReHiTem);}
          }
          

        /*| Display previous position */

	dp$erase_hilite(msg = &msg);
	if(me->Temp_Clone[me->index_to_locate].objid != NULL_OBJID)
	 {
	  COm_hilite_elem(me->Temp_Clone+me->index_to_locate,
			  me->Temp_Value[me->index_to_locate].type,
			  GRhdo,&me->ModuleInfo);
         }

        /* Select the Entry Request */

	me->state = WAIT_TEM;
        if((me->Temp_Value[me->index_to_locate].type & parameter_generic)&&
         (me->Temp_Value[me->index_to_locate].type!= ~0))
	{
          me->Entry_Request=PARAM;
          Obj_Generic=me->Temp_Value[me->index_to_locate].type;
	}
        else
        { 
          me->Entry_Request=PARENT;
          Obj_Generic=me->Temp_Value[me->index_to_locate].type;

          if(Obj_Generic&curve_generic)
                                  Obj_Generic |= line_generic|conic_generic;

	  if(Obj_Generic == 0) Obj_Generic = ~0;
	/* Do we allow a fence locate */
	  if(me->set_index == me->index_to_locate ||
	     me->set_index == -1) Obj_Generic |= set_generic;
	/*"set_index %d Obj_Generic %x\n",me->set_index,Obj_Generic */
        }
        break;


	case LOC_FORM :  /*| wait form modification */
	  
       ex$message(msgnumb = AS_P_MdPmFm);
		 
	  if(COm_move_form_ptr)
	    {
	     status = om$send(msg = message COm_move.write_form
						           (COm_move_form_ptr),
			      targetid = my_id);
	     as$status();
	    }
	  me->Entry_Request = POINT;
	  break;
	
          

	case COPY :   /*| copy sub graph */
	   /* To prevent unwanted copy */
	 
	  if(me->root_changed)
	   {
	    if(me->set_index != -1)
	     {
  	      fence_grid = me->Temp_Clone[me->set_index];

  	      Obj_Generic=me->Temp_Value[me->set_index].type;
              if(Obj_Generic&other_generic) Obj_Generic |= debug_type;
              if(Obj_Generic&curve_generic)
				      Obj_Generic |= line_generic|conic_generic;

              as$start_fence(set = &fence_grid,
                 nb_obj = &nb_obj, p_obj = &set_obj,
                 make_source = TRUE,
                 type_generic = Obj_Generic);
 	     }
	    else nb_obj = 1;

	    /* Loop on the selected element in the fence */

	    for(i_obj = 0; i_obj <nb_obj ; i_obj ++)
 	     {
  	      if(me->set_index != -1 && me->set_index != OM_K_MAXINT)
    	      {
     	       status = as$any_give_structure(go_grid = set_obj[i_obj],
                                    mod_env = &me->ModuleInfo,
                                    inst    = &rst);
     	       if(!(status&1)) continue;
     	       if(!(rst.type&Obj_Generic)) continue;

	       status = as$make_source(go_grid = set_obj[i_obj],
				       as_os= me->ModuleInfo.md_id.osnum,
				       as_grid = me->Temp_Clone+me->set_index,
				       mod_env = &me->ModuleInfo);
	       as$status();
	       if(!(status&1)) continue;
    	      }

	      status = om$send(msg = message COm_move.copy_graph(),
			   targetid = my_id);
  	      if(mode_batch != ND_DEFER) nd$exec_batch();

             }
	    if(me->set_index != -1) me->Temp_Clone[me->set_index] = fence_grid;
	    me->root_changed = 0;
	    FIg_disable(COm_move_form_ptr,FORM_COPY);
	    FIg_disable(COm_move_form_ptr,FORM_MOVE);
           }
	  else
 	   {
	    ex$message(msgnumb = AS_E_CpAb);
	   }
          FIg_set_state(COm_move_form_ptr,COPY,0);
          me->Entry_Request = NOENT;
	  me->index_to_locate = 0;
	  me->action = PRO_TEMP;
	  break;

	case MOVE :   /*| Move sub graph */
	  /* To prevent unwanted copy */
	  if(!me->root_changed)
 	   {
	    ex$message(msgnumb = AS_E_MvAb);
	   }
	  else if(me->set_index != -1)
 	   {
	    ex$message(msgnumb = AS_E_MvAbFc);
	   }
	  else
	  {
	   me->root_changed = 0;
	   FIg_disable(COm_move_form_ptr,FORM_COPY);
	   FIg_disable(COm_move_form_ptr,FORM_MOVE);
	   status = om$send(msg = message COm_move.move_graph(),
			   targetid = my_id);
  	   if(mode_batch != ND_DEFER) nd$exec_batch();
          }

          FIg_set_state(COm_move_form_ptr,MOVE,0);
          me->Entry_Request = NOENT;
	  me->index_to_locate = 0;
	  me->action = PRO_TEMP;
          break;
	
      }   /* end switch (me->state) */


    switch( me->Entry_Request)
    {
     case POINT :  /*| DATA */
          token = GRget_token(&status,TokenList,&input_mask,&grevent1,
                	      &event_size,&resp,response_data);
          break;

     case PARENT :  /*| parent */
  	  token = ASget_parent (&msg,TokenList,&grevent1,&grevent2,&locate_mask,
                                &input_mask, &event_size, &display_flag,&resp,
                                response_data,me->loc_prompt,me->acc_prompt,
                                me->reloc_prompt, &me->attr,&me->locate_stack,
                                Obj_Generic,&me->located_obj,&context,&rst);
	  
	  /*"response_data[0] %c\n",response_data[0]*/
/* Christian shit it with its translate : It returns an object located       */
/* when the user gives *						     */
/* Old                                                                       */
/*	  if(TokenList[token] != LOC_PARENT && response_data[0] == '*'       */
/* New */
          if(!strcmp(response_data,"*")
	     &&( me->state == INITIAL || me->state == WAIT_OBJ))
	    {
	     me->action = REG_EXP;
	     me->state = WAIT_OBJ;
	     me->Entry_Request = NOENT;
	    }

         break;


     case PARAM :
        token = ASget_all_param (
                &status,                        TokenList,
                &grevent1,                      &grevent2,
                &locate_mask,                   &input_mask,
                &event_size,                    &display_flag,
                &resp,                          response_data,
                me->loc_prompt,          me->acc_prompt,
                me->reloc_prompt,        &me->attr,
                &me->locate_stack,       Obj_Generic,
                &me->located_obj, &Param);
		context.objid = NULL_OBJID;
       /* To avoid problem with fence and with text expression */
        if(TokenList[token] == LOC_PARAM)
         {
          status = om$send(msg = message NDnode.NDgive_structure
                                (&msg,&rst,&me->ModuleInfo),
                           targetid = me->located_obj.objid,
                           targetos = me->located_obj.osnum);
          as$status(action = RET_STATUS);
         }
        break;

     case NOENT :  /*| Noent */
          break;

    }/* end of switch */

/* new action and new state */
	
     if(me->Entry_Request != NOENT)
      {
       me->action = (IGRint) Action[   me->state ][ token ];
       me->state =  (IGRint) NewState[ me->state ][ token ];
      }
  /*"token %d me->action %d me->state %d\n",token,me->action,me->state*/

    } while(me->Entry_Request == NOENT || TokenList[token] != GR_UNKNOWN_TYPE);

    *response = resp;
    /*"response %d\n",*response */

    return( OM_S_SUCCESS);

}   /*  end execute method */

method move_graph() 
{
 int iroot,ifoot;
 OMuint index;
 int cn_type;
 IGRlong status;

/* Will it create loops in the graph ? */
 for(iroot=0 ; iroot<me->Nb_Max_Temp ; iroot++)
  {
   if(   me->Temp_Clone[iroot].objid == me->Temp_List[iroot].objid
      && me->Temp_Clone[iroot].osnum == me->Temp_List[iroot].osnum) continue;
   for(ifoot=0 ; ifoot<me->Nb_Max_Feet ; ifoot++)
    {
     if(nd$dep_exist(l_root = me->Temp_List +iroot, nb_root = 1,
		     l_tip  = me->Feet_List +ifoot, nb_tip  = 1))
       {
        if(nd$dep_exist(l_root = me->Feet_List +ifoot, nb_root = 1,
		     l_tip  = me->Temp_Clone+iroot, nb_tip  = 1))
          {
	   ex$message(msgnumb = AS_E_Loop);
	   return OM_W_ABORT;
          } 
       }
     }
   }


/* Change roots of dependent graph */

 for(iroot=0 ; iroot<me->Nb_Max_Temp ; iroot++)
  {
   /* Is this template changed */
   if(   me->Temp_Clone[iroot].objid == me->Temp_List[iroot].objid
      && me->Temp_Clone[iroot].osnum == me->Temp_List[iroot].osnum) continue;
   for(ifoot=0 ; ifoot<me->Nb_Max_Feet ; ifoot++)
    {
     /* Does the feet depends upon the template */
     status = om$get_index(objid_c = me->Temp_List[iroot].objid,
     			   osnum_c = me->Temp_List[iroot].osnum,
			   objid   = me->Feet_List[ifoot].objid,
			   osnum2  = me->Feet_List[ifoot].osnum,
			   p_chanselect = &ND_children,
			   indexaddr = &index);
     if(!(status&1))
       {/*" foot %d does not depends on template %d\n",ifoot,iroot*/
	continue;
       }
      
     /* Change connection */

     status = om$send(msg = message NDnode.NDchange_connect(1,
						me->Temp_List+iroot,
						me->Temp_Clone+iroot),
		      targetid = me->Feet_List[ifoot].objid,
		      targetos = me->Feet_List[ifoot].osnum);
     as$status();

     cn_type = ND_COMP;
     nd$wait_batch(type = GR_GEOM_POSTED,
                   l_object = me->Feet_List+ifoot,
                   l_obj_info = &cn_type,
                   nb_obj   = 1);

    }
  }

 /* Change now orginal roots to new roots */
 for(iroot = 0 ; iroot<me->Nb_Max_Temp;iroot++)
  {
   me->Temp_List[iroot] = me->Temp_Clone[iroot];
  }
 GRabsg_del_all(); /* always the same shit */
 return OM_S_SUCCESS;
}

method copy_graph()
{
 OM_S_OBJID save_md_id;
 IGRlong status,msg;
 struct GRid *to_update,*el_extern;
 int i, j, cn_type,num_obj, nb_extern;
 struct NDcp_struct copy_info;
 int nb_to_update;
 IGRboolean tmp_edit;
 struct GRid *obj,new_root;
 int nb_new_root;

 extern void RemDupEntInRtree();

  /* init */
  save_md_id = me->ModuleInfo.md_id.objid;
  me->ModuleInfo.md_id.objid = NULL_OBJID;
  tmp_edit = FALSE;

  /* Get internal graph, taking template and feet together */

  status = om$send(msg = message COm_move.realloc_feet 
				(me->Nb_Max_Feet+me->Nb_Max_Temp),
		   targetid = my_id);
  as$status(action = RET_STATUS);

  OM_BLOCK_MOVE(me->Temp_List,me->Feet_List+me->Nb_Max_Feet,
		me->Nb_Max_Temp * sizeof(struct GRid));


  nd$get_internal_graph(p_initial = me->Feet_List,
  	       nb_initial = me->Nb_Max_Temp+me->Nb_Max_Feet);


/* 
   Find extern elements. Add them in the original/clone list and 
   search internal graph again
*/

  nd$get_list_in_graph(acc_type = ND_EXTERN,
		       p_count = &nb_extern,
		       buf_addr = &el_extern);

  if(nb_extern)
   {
    status = om$send(msg = message COm_move.realloc_template 
				(me->Nb_Max_Temp+nb_extern),
		   targetid = my_id);
    as$status(action = RET_STATUS);

    status = om$send(msg = message COm_move.realloc_feet 
				(me->Nb_Max_Feet+me->Nb_Max_Temp+nb_extern),
		   targetid = my_id);
    as$status(action = RET_STATUS);

    OM_BLOCK_MOVE(el_extern,me->Feet_List+me->Nb_Max_Temp+me->Nb_Max_Feet,
		nb_extern*sizeof(struct GRid));

    OM_BLOCK_MOVE(el_extern,me->Temp_Clone+me->Nb_Max_Temp,
		nb_extern*sizeof(struct GRid));

    num_obj = me->Nb_Max_Temp + nb_extern;

    nd$get_internal_graph(p_initial = me->Feet_List,
  	       nb_initial = me->Nb_Max_Temp+me->Nb_Max_Feet+nb_extern);
   
    /* Make sure that there is not an extern depending upon a root or
     another  extern. In that case a temporary modification of the 
     graph is necessary in order to have copy graph working properly  */
    
    nd$get_list_in_graph(acc_type = ND_ROOT,
			 p_count = &nb_new_root,
			 buf_addr = &el_extern);
    if(nb_new_root != me->Nb_Max_Temp + nb_extern)
     {
      tmp_edit = TRUE;
      for(i=0,obj=me->Feet_List+me->Nb_Max_Feet+me->Nb_Max_Temp;
	  i<nb_extern;i++,obj++)
       {
	for(j=0;j<nb_new_root;j++)
	  {if(obj->objid == el_extern[j].objid) break;}
	if(j<nb_new_root) continue;

        status = om$send(msg = message NDnode.NDcopy_to_tmp_root
			(&msg,0,&me->ModuleInfo,&me->ModuleInfo,&new_root),
		      targetid = obj->objid,
		      targetos = obj->osnum);
        if(!(msg&1)) status = OM_W_ABORT;
        as$status(action = GOTO_VALUE; value = wrapup);
        status = om$send(msg = message NDnode.NDmove_to_tmp_clone
							       (&msg,&new_root),
                     targetid = obj->objid,
                     targetos = obj->osnum);
        as$status(action = GOTO_VALUE; value = wrapup);

	/* That's because Alain reconnects the copy_to_root beam to the parent
	   containing beam's attribute */
	om$send(msg = message Root.wild_disconnect(ND_father),
			  targetid = new_root.objid,
			  targetos = new_root.osnum);
	*obj = new_root;
       }
       nd$get_internal_graph(p_initial = me->Feet_List,
  	       nb_initial = me->Nb_Max_Temp+me->Nb_Max_Feet+nb_extern);
     }
  }

/* Now copy graph for real */
  status = nd$copy_graph(msg = &msg,
		from_info = &me->ModuleInfo,
		to_info = &me->ModuleInfo,
		p_root = me->Temp_Clone,
		nb_root = me->Nb_Max_Temp+nb_extern,
		p_clone = &copy_info);
  me->ModuleInfo.md_id.objid = save_md_id;
  as$status(action = GOTO_VALUE, value = wrapup);

  /* Ask to recompute only necessary dependency                     */
 
   cn_type = ND_COMP | ND_COMP_NO_ERASE | ND_COMP_NO_REM_RT;
   to_update = (struct GRid *) copy_info.list;
   nb_to_update = 0;

   for(i=0;i<copy_info.nb_obj;i++)
    {
     if (copy_info.list[i].position & ND_ROOT)
     {
      for (j=0;j<num_obj;j++)
      {
        if (me->Temp_Clone[j].objid == copy_info.list[i].clone)
         break;
      }
/*
 * This means the element was added. Hence add to the update list.
 */
      if (j==num_obj)
      {
       to_update[nb_to_update].objid = copy_info.list[i].clone;
       to_update[nb_to_update].osnum = me->ModuleInfo.md_id.osnum;
       nb_to_update++;
      }
     }
     if(!(copy_info.list[i].position & ND_BODY)) continue;
     to_update[nb_to_update].objid = copy_info.list[i].clone;
     to_update[nb_to_update].osnum = me->ModuleInfo.md_id.osnum;
     nb_to_update++;
    }
   msg = nd$get_graph(nb_root = nb_to_update,
		      p_root = to_update);
		     
   msg = nd$update_graph(cn_type = cn_type,
		         root_compute = ND_UPT_ROOT,
		         md_env = &me->ModuleInfo);
   if(copy_info.list) om$dealloc(ptr = copy_info.list);

wrapup :

   /* Restore initial graph if temporary edition */
   
   if(tmp_edit)
    {
     me->ModuleInfo.md_id.objid = NULL_OBJID;
     for(i=0,obj=me->Feet_List+me->Nb_Max_Feet+me->Nb_Max_Temp;
	 i<nb_extern;i++,obj++)
      {
       if(obj->objid == me->Temp_Clone[me->Nb_Max_Temp+i].objid) continue;
       status = om$send(msg = message NDnode.NDmove_to_tmp_clone 
					(&msg,me->Temp_Clone+me->Nb_Max_Temp+i),
                     targetid = obj->objid,
                     targetos = obj->osnum);
       as$status();
       status = om$send(msg = message NDnode.NDdelete(&me->ModuleInfo),
		      targetid = obj->objid,
		      targetos = obj->osnum);
       as$status();
      }
    }
   me->ModuleInfo.md_id.objid = save_md_id;

   RemDupEntInRtree();

   return OM_S_SUCCESS;
 }

method realloc_template(int nb_template)
{
 long status;
 int previous_size;

  previous_size = om$dimension_of(varray = me->Temp_List);
  if(nb_template > previous_size)
   {
     previous_size = 20*(nb_template/20 +1);
     status = om$vla_set_dimension(varray = me->Temp_List,
                                   size = previous_size);
     as$status(action = RET_STATUS);
     status = om$vla_set_dimension(varray = me->Temp_Value,
                                   size = previous_size);
     as$status(action = RET_STATUS);
     status = om$vla_set_dimension(varray = me->Temp_Name,
                                   size = previous_size*macro_MAX_CHAR);
     as$status(action = RET_STATUS);

     status = om$vla_set_dimension(varray = me->Temp_Clone,
				   size = previous_size);
     as$status(action = RET_STATUS);


     status = om$vla_set_dimension(varray = me->Temp_Clone_Name,
				   size = previous_size*macro_MAX_CHAR);
     as$status(action = RET_STATUS);
   }
  return OM_S_SUCCESS;
}

method realloc_feet(int nb_feet)
{
 long status;
 int previous_size;

  previous_size = om$dimension_of(varray = me->Feet_List);
  if(nb_feet > previous_size)
   {
     previous_size = 20*(nb_feet/20 +1);
     status = om$vla_set_dimension(varray = me->Feet_List,
                                   size = previous_size);
     as$status(action = RET_STATUS);

     status = om$vla_set_dimension(varray = me->Feet_Type,
                                   size = previous_size);
     as$status(action = RET_STATUS);

     status = om$vla_set_dimension(varray = me->Feet_Name,
                                   size = previous_size*macro_MAX_CHAR);
     as$status(action = RET_STATUS);
   }
  return OM_S_SUCCESS;
}

method realloc_obj(int nb_obj)
{
 long status;
 int previous_size;

  previous_size = om$dimension_of(varray = me->Obj_List);
  if(nb_obj > previous_size)
   {
     previous_size = 20*(nb_obj/20 +1);
             status = om$vla_set_dimension(varray = me->Obj_List,
                                           size = previous_size);
             as$status(action = RET_STATUS);

             status = om$vla_set_dimension(varray = me->Obj_Info,
                                           size = previous_size);
             as$status(action = RET_STATUS);

   }
  return OM_S_SUCCESS;
}

end implementation COm_move;
