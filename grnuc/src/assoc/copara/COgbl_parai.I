class implementation COgbl_para;

#include <FI.h>
#include "msmacros.h"
#include "ASmessages.h"
#include "parametric.h"
#include "coparadef.h"
#include "AS_status.h"
#include "asbox.h"
#include "nddef.h"
#include "ndmacros.h"
#include "OMmacros.h"
#include "comisc.h"

#define NULL 0

extern IGRboolean NDtell_user;

/*--------------------------------------------------------------*/
/*	method: wakeup						*/
/*--------------------------------------------------------------*/

method wakeup ( int pos)

{

  switch(me->mytype)
   {
    case 0 :
      break;

    case 1 :
      ex$message( msgnumb = AC_M_ATPS);
      break;

    case 10 :
    case 11 :
    case 12 :
      ex$message( msgnumb = AC_M_Bat);
      break;

    case 20 :
      ex$message( msgnumb = AC_M_Update);
      break;

    case 30 :
    case 31 :
    case 32 :
    case 33 :
    case 34 :
    case 35 :
       ex$message( msgnumb = AC_M_Graph);
       break;

    case 40 :
    case 41 :
       ex$message(msgnumb = AC_M_NamFail);
       break;

    }
 

    return ( OM_S_SUCCESS);
}

/*--------------------------------------------------------------*/
/*	method: execute						*/
/*--------------------------------------------------------------*/

method execute ( int *response;
		 char *response_data;
		 int pos)

{
 IGRint resp,token;
 IGRlong msg;
 IGRlong locate_mask,input_mask;
 IGRint  size;
 IGRlong display_flag;
 struct ret_struct obj_struct;
 struct GRevent grevent1,grevent2;
 struct GRid tr_point;
 struct GRid  context;

 static IGRint TokenList[] =
			{ RESET,
			  GR_UNKNOWN_TYPE,
			  LOC_PARENT
			};

    *response = TERMINATE;
/* initialization for locate */

   size = sizeof(struct GRevent);
   locate_mask = GRm_DATA | GRm_STRING | GRm_RESET;
   input_mask = GRm_DATA | GRm_RESET;
   display_flag = ELEM_HILIGHT | ALL_WINDOWS;


    switch (me->mytype)

/* parameter type definition */
      {
	case 0: 
		if (G_active_para_type == PARAM_NEW)
		{
		   G_active_para_type = PARAM_SHARE;
		   ex$message( msgnumb = AS_S_ShParaOn);
		}
		else
		{
		   G_active_para_type = PARAM_NEW;
		   ex$message( msgnumb = AS_S_ShParaOff);
		}
		break;

/* track point definition */

	case 1: 

	     if (IF_EQ_OBJID(G_active_trackpoint.objid,NULL_OBJID))
	     {

                /*
                 *  call locate filter to locate an object 
                 */



                 ex$message( buff =  me->loc_prompt, msgnumb = AS_P_IdPnt);

                 token = ASget_parent(&msg,TokenList,&grevent1,&grevent2,
                    &locate_mask, &input_mask, &size, &display_flag,
                    &resp, response_data, 
		    me->loc_prompt, me->acc_prompt, 
                    me->reloc_prompt, &me->attr, &me->locate_stack,
                    point_generic,&tr_point,&context,&obj_struct);

                if( TokenList[token] == GR_UNKNOWN_TYPE )
                {
                  *response = resp;
                  break;
                }
         
                if( tr_point.osnum != me->ModuleInfo.md_id.osnum ) 
		{
		  G_active_trackpoint.objid = NULL_OBJID;
		  ex$message( msgnumb = AS_S_TPnwos);
	        }
                else if (token == 2)
		{
                   G_active_trackpoint.objid = tr_point.objid;
                   G_active_trackpoint.osnum = tr_point.osnum;
		   ex$message( msgnumb = AS_S_TPactive);
                }
		else 
                {
		   G_active_trackpoint.objid = NULL_OBJID;
		   ex$message( msgnumb = AS_E_TPNDef);
                }
             }
             else
	     {
		G_active_trackpoint.objid = NULL_OBJID;
		ex$message( msgnumb = AS_S_TPdisact);
             }

             break;


/* change batch mode */

     case 10 :
       {
        IGRint batch_mode;
/*
 * Modified the following code to make "Delay update" command a toggle.
 * Prasad 01/04/91
 */
         nd$mod_batch(request = ND_INQ,
                      p_ret_mode = &batch_mode);
                      
         if (batch_mode != ND_DEFER)
         {
	  nd$mod_batch(request    = ND_SET,
	 	       req_mode   = ND_DEFER);
	  ex$message( msgnumb = AS_S_UpdDlyd);
          GRdelay_button(GR_DELAY_ON);
         }
         else
         {
	  nd$mod_batch(request   = ND_SET,
		      req_mode   = ND_IMMEDIATE);
	  ex$message( msgnumb = AS_S_UpdImmD);
          GRdelay_button(GR_DELAY_OFF);
         }
	 break;
       }
		
     case 11 :
	 nd$mod_batch(request    = ND_SET,
		      req_mode   = ND_IMMEDIATE);
	 ex$message( msgnumb = AS_S_UpImm);
	 break;
		
     case 12 :
	 nd$mod_batch(request    = ND_SET,
		      req_mode   = ND_TRANSACTION);
	 ex$message( msgnumb = AS_S_UpTrans);
	 break;
		

/* Update depency */

    case 20 :
      ex$message( msgnumb = AS_S_Update);
      nd$exec_batch(defer_flag = ND_UNCONDITIONAL);
      ex$message( msgnumb = AS_S_ToutBon);
      break;

/* change graph mode */

     case 30 :
        nd$mod_graph(request  = ND_SET,
		     req_mode = ND_BROAD_COP); 
        ex$message( msgnumb = AS_S_Broad_Cop);
	break;

     case 31 :
        nd$mod_graph(request  = ND_SET,
		     req_mode = ND_NO_BROAD_COP); 
        ex$message( msgnumb = AS_S_No_Broad_Cop);
	break;

     case 32 :
        nd$mod_graph(request  = ND_SET,
		     req_mode = ND_CONN_COP); 
        ex$message( msgnumb = AS_S_Conn_Cop);
	break;

     case 33 :
        nd$mod_graph(request  = ND_SET,
		     req_mode = ND_NO_CONN_COP); 
        ex$message( msgnumb = AS_S_No_Conn_Cop);
	break;

     case 34 :
        nd$mod_graph(request  = ND_SET,
		     req_mode = ND_BROAD_DEL); 
        ex$message( msgnumb = AS_S_Broad_Del);
	break;

     case 35 :
        nd$mod_graph(request  = ND_SET,
		     req_mode = ND_NO_BROAD_DEL); 
        ex$message( msgnumb = AS_S_No_Broad_Del);
	break;

    case 40 :
	ex$message(msgnumb = AS_S_ElemFailNamed);
	NDtell_user = TRUE;
       break;

    case 41 :
	ex$message(msgnumb = AS_S_ElemFailNoNamed);
	NDtell_user = FALSE;
       break;

    }  /* end switch  */

    return ( OM_S_SUCCESS);

}		/* end execute method */

end implementation COgbl_para;

