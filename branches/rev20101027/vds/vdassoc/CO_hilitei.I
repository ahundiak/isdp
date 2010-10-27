/* $Id: CO_hilitei.I,v 1.1.1.1 2001/01/04 21:07:41 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdassoc / CO_hilitei.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: CO_hilitei.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:41  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/10/30  20:10:38  pinnacle
# Fixed Warnings
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	10/30/97	ah		Fix UnInit References
 * -------------------------------------------------------------------*/

/*
 * ADZ, JLA ; Hilite gives error messages on display of objects if classes,
 * 	      which are rejected by the method NDdisplay.
 *	      Specially by classes : ACpretend and ACrg_collect.
 *		Action: as$status removed on line 197(198), and 265(266)
 */

class implementation CO_hilite;

#include "msmacros.h"
#include "ASmessages.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"
#include "codef.h"
#include "dpmacros.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "ex.h"
#include "parametric.h"
#include "OMmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "AS_status.h"
#include "coparadef.h"
#include "asdef.h"
#include "asmacros.h"
#include "asbox.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "griomacros.h"
#include "expression.h"

from expression import list;
from NDnode import NDdisplay,NDget_objects;

extern GRclassid OPP_expression_class_id;

#define AS_DEBUG


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             execute                              */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method execute ( int *response;
                 char *response_data;
                 int  pos)
{

#define NUM_STATES 3
#define NUM_ACTION 6
#define NUM_TOKENS 4

enum possible_entry {
		     PARENT,
		     POINT ,
		     NOENT };

enum possible_states {
		INITIAL,
		DIR_HILITE ,
		ALL_HILITE  };

enum possible_actions {
		NIL,
		ERR,
		LOC_OBJ,
		HIL_DIR,
		HIL_ALL,
		ERASE };

static IGRint TokenList[] = {
		DATA,
		RESET,
		GR_UNKNOWN_TYPE,
		LOC_PARENT };
			  

static enum possible_states NewState[NUM_STATES][NUM_TOKENS] = {
/*            ********************* TOKENS **********************
   Old State  *   DATA       ,   RESET   ,  UNKNOWN   , PARENT */

/* INITIAL    */ {INITIAL    , INITIAL   , INITIAL    , DIR_HILITE },
/* DIR_ROOT_HI*/ {ALL_HILITE , INITIAL   , DIR_HILITE , ALL_HILITE },
/* ALL_ROOT_HI*/ {INITIAL    , INITIAL   , ALL_HILITE , ALL_HILITE }};

static enum possible_actions Action[NUM_STATES][NUM_TOKENS] = {
/*            ********************* TOKENS **********************
   Old State  *   DATA       ,   RESET   ,  UNKNOWN   , PARENT */

/* INITIAL    */ {NIL        , NIL       , LOC_OBJ    , HIL_DIR    },
/* DIR_ROOT_HI*/ {HIL_ALL    , ERASE     , HIL_DIR    , HIL_ALL    },
/* ALL_ROOT_HI*/ {ERASE      , ERASE     , HIL_ALL    , NIL        }};

    IGRint      status;         /* routine return status */
    IGRint      size;           /* size of GRevent buffer (struct GRevent) */
    IGRlong     display_flag;   /* display flag for locate filter */
    IGRlong     input_mask;     /* mask for GRgetevent */
    IGRlong     locate_mask;    /* mask for GRgetevent */
    IGRint i,count;
    IGRint type;
    IGRint token;
    struct ret_struct ret_st;
    enum possible_entry entry_requested;
    struct GRevent grevent1,grevent2;
    IGRint resp;
    struct GRid located_object;
    struct GRid  context;
    GRclassid obj_clas;
    IGRchar formula[EXP_MAX_LEN];

    /* 
     * Initialize return code for error
     */

    *response = TERMINATE;

    /* get rid of uninit warning, might even fix something */
    entry_requested = NOENT;
    token = 0;

    /*
     *  Initialization for locate 
     */

    locate_mask = GRm_DATA | GRm_STRING | GRm_RESET;
    input_mask = GRm_DATA | GRm_RESET;
    display_flag = ELEM_HILIGHT | ALL_WINDOWS;
    size = sizeof (struct GRevent);



    /*
     *   loop until an unknown event is received
     */

 do
  {
   switch(me->action)
   {
    case NIL :
	/*| action NIL */
	break;

    case ERR :
	/*| action ERR */
	ex$message( msgnumb = AS_E_InvDefRest);
	me->state = INITIAL;
	me->action = LOC_OBJ;

    case LOC_OBJ :
	/*| action LOC_OBJ */
	entry_requested = PARENT;
        break;

    case HIL_DIR :
	/*| action HIL_DIR */
     	if(me->mytype == 0)
          { 
	   type = ND_ROOT;
	  }
      	else
	  {
	   type = ND_CHILDREN;
	  }

	if(me->object.objid == NULL_OBJID)
		{
		 ex$message( msgnumb = AS_E_NConstEle);
		 me->action = LOC_OBJ;
		 me->state  = INITIAL;
		 entry_requested = NOENT;
		 break;
		}

        status = om$send(msg = message NDnode.NDget_objects(type|ND_IN_BUF,
					 NULL,0,&me->list,0,OM_K_MAXINT,&count),
		     targetid = me->object.objid,
		     targetos = me->object.osnum);
	as$status(action = RET_STATUS);

	for(i=0 ; i<count ; i++)
	   {
	    /*" hilite de %d %d\n",me->list[i].objid,me->list[i].osnum */

	    status=om$get_classid(osnum=me->list[i].osnum,
				  objid=me->list[i].objid,
				  p_classid = &obj_clas );

	    if((om$is_ancestry_valid (subclassid = obj_clas,
	     superclassid = OPP_expression_class_id) != OM_S_SUCCESS))
	      {
               status = om$send(msg = message NDnode.NDdisplay
						(0,GRhdo,&me->ModuleInfo),
		         targetid = me->list[i].objid,
		         targetos = me->list[i].osnum);
	       /*  as$status(); */
	      }
	    else
	      {
#define SIZE_MESS 55
	       /*print parameter in UI_status */

	       status = om$send(msg = message expression.list(formula),
			     targetid = me->list[i].objid,
			     targetos = me->list[i].osnum);
	       if(!(status &1))continue;
	       /*" list is OK len %d\n",strlen(formula) */
	       if(me->mytype == 0)
                { formula[SIZE_MESS-1] = '\0';
	          UI_status(formula);
		}
               else 		printf("%s \n",formula);
	       /*| apres UI_status */
	      }
	   }
	
	entry_requested = POINT;

     	if(me->mytype == 0){ ex$message( msgnumb = AS_P_DtoHiRoots); }
     	 else 		   { ex$message( msgnumb = AS_P_HiAllDep); }
	break;

    case HIL_ALL :
	/*| action HIL_ALL */
   	switch(me->mytype)
       	 {
       	  case 0:   /* roots elements */
             status = nd$get_graph(p_tip = &me->object,nb_tip = 1);
   	     as$status(action = RET_STATUS);

	     status = nd$get_list_in_graph(acc_type = ~0,
				       rej_type = ND_TIP,
				       p_count = &count, buf_addr = &me->list);
	     as$status(action = RET_STATUS);

             break;
  
       	  case 1:   /* deppending elements */
       	     status = nd$get_graph(p_root = &me->object,nb_root = 1);
  	     as$status(action = RET_STATUS);

	     status = nd$get_list_in_graph(acc_type = ND_BODY,
				       p_count = &count, buf_addr = &me->list);
	     as$status(action = RET_STATUS);
       	     break;
         }

	/* expression now */

	for(i=0 ; i<count ; i++)
	   {
	    /*" hilite de %d %d\n",me->list[i].objid,me->list[i].osnum */
	    status=om$get_classid(osnum=me->list[i].osnum,
				  objid=me->list[i].objid,
				  p_classid = &obj_clas );

	    if((om$is_ancestry_valid (subclassid = obj_clas,
	             superclassid = OPP_expression_class_id) != OM_S_SUCCESS))
	      {
               status = om$send(msg = message NDnode.NDdisplay
						       (0,GRhd,&me->ModuleInfo),
		         targetid = me->list[i].objid,
		         targetos = me->list[i].osnum);
	       /* as$status(); */
	      }
	    else
	      {
	       status = om$send(msg = message expression.list(formula),
			     targetid = me->list[i].objid,
			     targetos = me->list[i].osnum);
	       if(!(status &1))continue;
               printf("%s \n",formula);
	      }
	   }

	 entry_requested = POINT;
	 ex$message( msgnumb = AS_P_DatResCont);
	 break;


    case ERASE :
	/*| action ERASE */
        dp$erase_hilite(msg = &status);
	entry_requested = NOENT;
 	me->action = LOC_OBJ;
        break;
   } /* end of switch  */


   switch (entry_requested)
    {
     case PARENT :
	/*| get a parent*/

        /* en attendant de passer directement message number */
        ex$message( buff =  me->loc_prompt, msgnumb = AS_P_IdEle);
        ex$message( buff =  me->acc_prompt, msgnumb = AS_P_AccRej);
        ex$message( buff =  me->reloc_prompt, msgnumb = AS_E_EleNotFound);
        me->attr.owner_action |= LC_HANDLES;

	token = ASget_parent (&status,TokenList, &grevent1, &grevent2,
             &locate_mask, &input_mask, &size, &display_flag,
             &resp,response_data,me->loc_prompt,me->acc_prompt,
             me->reloc_prompt,&me->attr,&me->locate_stack,
             ~0,&located_object,&context,&ret_st);

        if(resp == STRING)
            {
	     /*| parameter */
             status = di$translate( objname = response_data,
                                    p_objid = &me->object.objid,
                                    p_osnum = &me->object.osnum);

             if(status == DIR_S_SUCCESS)
              for(token=0 ; TokenList[token] != LOC_PARENT ; token++);
            }
        else if( TokenList[token] == LOC_PARENT )
            {
	     as$make_source(go_grid = located_object,
			    as_os = located_object.osnum,
		            as_grid = &me->object);
	     }

	 break;

     case NOENT :
	 /*| noent */
	 token = 0;  /* just to avoid problem */
	 status = OM_S_SUCCESS;
	 break;

     case POINT :
	/*| get a point*/
	token = GRget_token(&status,TokenList,&input_mask,&grevent2,&size,
			    &resp,response_data);
	break;

    }


/* new action and new state */


     if(entry_requested != NOENT)
      {
       me->action = (IGRint) Action[   me->state ][ token ];
       me->state =  (IGRint) NewState[ me->state ][ token ];
      }

/*" new action %d new state %d\n",me->action,me->state */


    }  while( entry_requested == NOENT || TokenList[token] != GR_UNKNOWN_TYPE);
                                                                  /* end do */

  *response = resp;
  dp$erase_hilite(msg = &status);
  return( OM_S_SUCCESS);

}   /*  end execute method */

end implementation CO_hilite;
