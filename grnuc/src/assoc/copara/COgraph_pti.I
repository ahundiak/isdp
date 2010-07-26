class implementation COgraph_pt;

#include "msmacros.h"
#include "ASmessages.h"
#include "grmsg.h"
#include <stdio.h>
#include "coparadef.h"
#include "expression.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "griomacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "AS_status.h"
#include "asbox.h"
#include "OMmacros.h"
#include "exmacros.h"
#include "macro.h"
#include "acmacros.h"

#define NUM_STATES 	2
#define NUM_ACTIONS 	8
#define NUM_TOKENS 	6

#define  AS_DEBUG  1


from NDnode import NDprint_root;

extern GRclassid OPP_expression_class_id;
extern GRclassid OPP_ACmacro_defn_class_id;


enum possible_states { 	INITIAL ,
			HAV_OBJ 
		     };

enum possible_actions {	NIL,
			ERR,
			RESTART,
			LOC_OBJ,
			STO_OBJ,
			STO_NAME,
			MAC_PRINT,
			GRA_PRINT
	 	       };

enum possible_entries { PARENT,
			NOENT };

%safe
static IGRint TokenList[] =
 		      {
			DATA,
			STRING ,
			RESET,
			D_RESET,
			GR_UNKNOWN_TYPE ,
			LOC_PARENT  
		      };


static enum possible_states NewState[NUM_STATES][NUM_TOKENS] = {

/*            *********************** TOKENS ********************
   Old State  *   DATA    , STRING  , RESET   , D_RESET , UNKNOWN , PARENT   */

/* INITIAL    */ {INITIAL , HAV_OBJ , INITIAL , INITIAL , INITIAL , HAV_OBJ  },
/* HAVE_OBJ   */ {INITIAL , HAV_OBJ , INITIAL , INITIAL , HAV_OBJ , HAV_OBJ  }};



static enum possible_actions Action[NUM_STATES][NUM_TOKENS] = {

/*            *********************** TOKENS ********************
   Old State  *    DATA  , STRING   , MOVE_ON , D_RESET  , UNKNOWN , PARENT   */

/* INITIAL    */ { ERR   , STO_NAME , RESTART , RESTART  , LOC_OBJ , STO_OBJ  },
/* HAVE_OBJ   */ { ERR   , STO_NAME , GRA_PRINT,RESTART  , LOC_OBJ , STO_OBJ }};

%endsafe



/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             wakeup                               */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method wakeup ( int pos)
{
 ex$message( msgnumb = AC_M_Gpr);
 return( OM_S_SUCCESS);
}



/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             execute                              */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method execute ( int *response;
                 char *response_data;
                 int  pos)
{
    IGRint      	status;         /* routine return status */
    IGRint      	size;     /* size of GRevent buffer (struct GRevent) */
    IGRlong     	display_flag;   /* display flag for locate filter */
    IGRlong     	input_mask;     /* mask for GRgetevent */
    IGRlong     	locate_mask;    /* mask for GRgetevent */
    IGRlong     	msg;            /* function return code */
    FILE 		*stream;        /* where to print  */
    struct GRevent 	grevent1, grevent2; /* event returned by GRgetevent */
    struct GRid  	located_obj;               /* object located        */
    struct GRid  	context,as_prov;
    GRclassid 		obj_class;
    IGRint 		resp;
    struct ret_struct 	obj_struct;                                 
    IGRint 		token;
    IGRint 		obj_generic;
    IGRint 		is_it_a_macro;
    IGRint 		nb_obj,nb_assoc,i_obj;
    IGRboolean		exit_while;
    struct GRid 	*obj_to_print;
    IGRint 		previous_size,new_size;
    enum possible_entries entry_requested;
   
    *response = TERMINATE;

    obj_generic = 0xffffffff;
    size = sizeof (struct GRevent);
    locate_mask = GRm_DATA | GRm_STRING | GRm_RESET | GRm_BACK_UP;
    input_mask  = GRm_DATA | GRm_STRING | GRm_RESET | GRm_BACK_UP; 
    display_flag = ELEM_HILIGHT | ALL_WINDOWS;




    /*
     *  loop until exit condition occurs
     */

   do
    {
      
      exit_while = FALSE;

      switch (me->action)
      {       
	 case NIL :     /*| nil */
		 break;

	 case ERR :    /*| err  */
		 ex$message( msgnumb = AS_E_InvDefRest);


	 case RESTART : /*| restart */
		 me->state = INITIAL;
		 me->action= LOC_OBJ;
		 me->p_count = 0;
		 entry_requested = NOENT;
		 break;



	 case STO_OBJ :   /*| sto_obj */
		if(grevent1.response != SPECIFIED_OBJ)
	           status = EXputq_front(&msg, &resp, (IGRlong *)&size,
(IGRchar *)&(grevent2.event));
		ASstart_fence(located_obj,me->ModuleInfo.md_id.osnum,&nb_obj,
			      &obj_to_print,&resp,response_data);
		previous_size = om$dimension_of(varray = me->list_id);
		if(me->p_count+nb_obj >= previous_size)
		   {
		    new_size =10*(1+(me->p_count+nb_obj)/10);
		    status = om$vla_set_dimension(varray = me->list_id,
						  size = new_size);
	            as$status(action = RET_STATUS);
		   }

		for(i_obj=0 ; i_obj<nb_obj ; i_obj++)
		  {
        	   me->list_id[me->p_count++]=obj_to_print[i_obj];
		  }
		ASend_fence();


        case LOC_OBJ :    /*| loc obj */
		ex$message( buff =  me->acc_prompt, msgnumb = AS_P_AccNextObj);
	        if(me->p_count) { ex$message( buff =  me->loc_prompt,
                                    	      msgnumb = AS_P_IdNewObjStop); }
	        else 		{ ex$message( buff =  me->loc_prompt,
					      msgnumb = GR_P_Id1stEle); }
		entry_requested = PARENT; 
		break;

	case STO_NAME :    /*| sto name */
                {
                IGRint status;
		status = di$translate( objname = response_data,
				       p_objid = &located_obj.objid,
				       p_osnum = &located_obj.osnum);

		if(status != DIR_S_SUCCESS)
		  {
		    ex$get_cur_mod ( osnum = &located_obj.osnum );
 		    status = ac$find_macro_defn (
				action		= ACfind_no_load,
		       	    	macro_name 	= response_data,
		            	p_macro_defn_id = &located_obj
						);
		   if(located_obj.objid==NULL_OBJID)
                     {
		      break;
		      }
		  }
                }

        /* is the located object a parameter or a macro */

          status=om$get_classid(osnum = located_obj.osnum,
				objid = located_obj.objid,
			        p_classid = &obj_class);
	  as$status(action = RET_STATUS);

          if(om$is_ancestry_valid(subclassid = obj_class,
                  superclassid = OPP_ACmacro_defn_class_id) == OM_S_SUCCESS)
               {
                /*| this name is a macro */
                me->action = MAC_PRINT;
                me->p_count=1;
               }
            else
               {
                /*| this name is a parameter or something else */
                grevent1.response = SPECIFIED_OBJ;
                me->action = STO_OBJ;
                entry_requested = NOENT;
                break;
               }


	case GRA_PRINT :   /*| grap print */

	/* take name and open the file */

        entry_requested = PARENT;

	if(me->p_count == 0)
        {
          ex$message( msgnumb = AS_E_NoObjPr);
          break;
        }

	ex$message( msgnumb = AS_P_Filename);
	token = GRget_token(&msg,TokenList,&input_mask,&grevent1,&size,
			    &resp,response_data);

        if (TokenList[token] == STRING || resp == STRING)
        {
          if(strlen(grevent1.event.keyin) == 0) stream = stdout;
          else if((stream=fopen(grevent1.event.keyin,"w"))==0) return(1);

          is_it_a_macro = (me->action == MAC_PRINT);
          asprinter_init(&me->ModuleInfo,stream,is_it_a_macro);

          ex$message( msgnumb = AS_S_GprInprog);

          /* print the graph */

          if(me-> action == GRA_PRINT)
          {
            /* make source with located objects */

            nb_assoc = 0;
            for(i_obj=0;i_obj<me->p_count;i_obj++)
	    {
              status = as$make_source(go_grid = me->list_id[i_obj],
				      as_os= me->ModuleInfo.md_id.osnum,	
				      mod_env = &me->ModuleInfo,
				      as_grid = &as_prov);
	      if(status&1) me->list_id[nb_assoc++] = as_prov;
            }
            /*"nb_assoc %d \n",nb_assoc*/

            /* Get the real roots of the associative elements.  */
	  
            nd$get_graph(p_root = me->list_id, nb_root = nb_assoc);
            nd$get_list_in_graph(acc_type = ND_ROOT,
			         p_count  = &me->p_count,
			         size     = me->p_count,
			         list     = me->list_id);
            asprinter_exec_print(me->p_count,me->list_id);
          }

          /* print a macro */
          else if (me-> action == MAC_PRINT)
	       {
                 status = om$send(msg      = message NDnode.NDprint_root
						     (&me->ModuleInfo,stream),
	            	          targetid = located_obj.objid, 
	            	          targetos = located_obj.osnum);
  	         as$status(action = RET_STATUS);
	       }

          /* end the graph printer */
          asprinter_end();

          /* close the file */
          if (strlen(grevent1.event.keyin) != 0) fclose(stream); 

	  /* restart the command */
          ex$message( msgnumb = AS_S_ToutBon);
          me->p_count = 0;
        }
        else 
        {
          if( TokenList[token] == GR_UNKNOWN_TYPE )
          {
            /*| command interruption */
            me->state       = HAV_OBJ;
            me->action      = GRA_PRINT;
            exit_while      = TRUE;
          }
	  else 
          {
            me->state       = INITIAL;
	    me->action      = LOC_OBJ;
	    me->p_count     = 0;
            entry_requested = NOENT;
          }
       }

        break;
	
      }   /* end switch (me->state) */


      if( exit_while ) break; /* exit the while loop */

    switch( entry_requested)
    {
     case PARENT :  /*| parent */
  	  token = ASget_parent (&msg,TokenList,&grevent1,&grevent2,&locate_mask,
                                &input_mask, &size, &display_flag,&resp,
                                response_data,me->loc_prompt,me->acc_prompt,
                                me->reloc_prompt, &me->attr,&me->locate_stack,
                                obj_generic,&located_obj,&context,&obj_struct);
          break;
     
     case NOENT :  /*| Noent */
          break;

    }/* end of switch */

/* new action and new state */
	
     if(entry_requested != NOENT)
      {
       me->action = (IGRint) Action[   me->state ][ token ];
       me->state =  (IGRint) NewState[ me->state ][ token ];
      }
  /*"token %d me->action %d me->state %d\n",token,me->action,me->state*/

    } while(entry_requested == NOENT || TokenList[token] != GR_UNKNOWN_TYPE);

    *response = resp;
    /*"response %d\n",*response */

    return( OM_S_SUCCESS);

}   /*  end execute method */

end implementation COgraph_pt;
