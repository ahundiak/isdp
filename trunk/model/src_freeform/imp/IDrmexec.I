class implementation IDrmpls;

#include <stdio.h>
#include "EMS.h"
#include "EC_F.h"
#include "EC_I.h"
#include "EC_M.h"
#include "EC_P.h"
#include "exmacros.h"   /* For ex$put_que*/  
#include "dpmacros.h"   /* For dp$erase_hilite */
#include "griomacros.h" /* For co$get_event */
#include "OMmacros.h"   /* For OM_BLOCK_MOVE */
#include "EMSmvpl.h"   /* For EMMOVE_POLES_ALONG_SPECIFIED_VECTORS */
#include "bserr.h"
#include "igrdef.h"     /* For IGRPS */
#include "grdpbmacros.h" /* For gr$get_dit.. */
#include "EMSssprops.h" /* For EMSIS_POLYDIS */
#include "dp.h" /* For struct var_list */
#include "dpdef.h" /* For VVOL_VIEWPORT.. */
#include "bsparameters.h" /* For BSEXT.. */
#include "alloca.h"
#include "IDrmplsi.h" /* prototypes */
#include "msmacros.h"    /* prototypes */
#include "IDffcmd.h"
#include "IDffmsg.h"

/* command object mytype */

#define MOVE_POLES 0

/* command object states */

#define IDENTIFY_SURFACE 3
#define INPUT_POLE 4
#define ACCEPT_REJECT_POLE 5
#define ACCEPT_REJECT_NEW_SURFACE 8
#define ID_SURFACE_GEOM		1
#define ID_CURVE_GEOM		0

#define INCREMENT 10

#if DEBUG
#define ERROR(sts_stupid, error_number, error_message)\
 {\
  if(!(sts_stupid & 1 & error_number))\
   {\
    fprintf(stderr, "\n*************************");\
    fprintf(stderr, "\nIn IDrmpls error condition encountered");\
    *response = TERMINATE;\
    fprintf(stderr, "\n%s", error_message);\
    om$report_error(sts = sts_stupid);\
    fprintf(stderr, "\n*************************");\
    return(OM_E_ABORT);\
   }\
 }
#else
#define ERROR(sts_stupid, error_number, error_message)\
 {\
  if(!(sts_stupid & 1 & error_number))\
   {\
    *response = TERMINATE;\
    ex$message(msgnumb = EMS_F_0002)\
    return(OM_E_ABORT);\
   }\
 }
#endif

from GRvg import GRgetsize, GRgetsymb,GRgetgeom,GRgetattr, GRpostabsg;
from EMSsubbs import EMdynmod,EMmove_poles;
from GRgraphics import GRdisplay,GRdelete;
from EMSsubbs import EMgenerate_node_pt_surf;

extern OMuword OPP_GRbspline_class_id, OPP_EMSsubbs_class_id;

method execute(int *response; char *response_data; int pos)
{
    IGRlong sts,msg;
    IGRint locate_mask, accept_mask, event_mask, display_flag;
    IGRchar string[80];
    struct GRlc_locate attributes;
    struct GRevent event;
    IGRboolean onpolygon;
    OMuword r_classes[5], e_classes[5];
    OM_S_CLASSLIST	rtree_classes, eligible_classes;
    struct GRevent accept_event;
    struct GRmd_env *md_env = NULL;
    long 		event_size;
    IGRint event_response = EX_DATA;
    IGRboolean loop = TRUE; /* used in while loop to supress warning message */

    sts = OM_S_SUCCESS;
    msg = MSSUCC;

    locate_mask = GRm_DATA | GRm_BACK_UP;
    accept_mask = GRm_DATA;

    ex$message(field = MESSAGE_FIELD, msgnumb = IDFFC_M_RMRWPLS);

    display_flag = 
      ONE_WINDOW		|	/* Hilite in only one window */
      ELEM_HILIGHT		| 	/* Hilite the whole element */
      NO_PROJ_ACCEPT_POINT	| 	/* Don't project the accept point */
      ACC_REJ_CYCLE		|	/* Run through accept reject cycle */
      RELOCATE			| 	/* Relocate if none found */
      LC_REGULAR_HIGHLIGHT	|	/* Use regular hilite not 1/2 */
      LC_ERASE_ALL;			/* Erase the hilite plane */

    attributes.properties = 
        LC_LC_ONLY		|	/* Locate locatable objects */
        LC_DP_ONLY		|	/* Locate displayable objects */
        IGN_MOD_BIT             |	/* Ignore modified and new props */
        LC_PLANAR_NON_PLANAR    ;	/* Planarity doesn't matter */

    rtree_classes.w_flags = OM_CLST_subclass;
    rtree_classes.p_classes = &r_classes[0];
    eligible_classes.w_flags = OM_CLST_subclass;
    eligible_classes.p_classes = &e_classes[0];

    /* -----------------------------------------------------------------
     * Enter infinite loop.
     * ----------------------------------------------------------------- */
    do
    {

        /* put these in to limit user options to only deleting ROW of poles  */
        me->mytype = MOVE_POLES;

        switch (ME.super_cmd->state)
        {
            /* ---------------------------------------------------- */
            /* initial state                                        */
            /* ---------------------------------------------------- */
   	    case 0:
    		ME.super_cmd->state = IDENTIFY_SURFACE;
   	    break;

            /* ---------------------------------------------------- */
            /* Here, we locate the surface the user wants to change */
            /* ---------------------------------------------------- */
   	    case IDENTIFY_SURFACE:
      	    {
       		attributes.properties |= LC_WRITE_ONLY;

       		attributes.owner_action = 
        		LC_FLEX_COMP   |
        		LC_REF_OBJECTS |    /* Objects in ref. files are O.K. */
        		LC_NO_REF_HEADER;    /* No reference file headers */

       		rtree_classes.w_count = 1;
       		eligible_classes.w_count = 1;
       		r_classes[0] = OPP_EMSsubbs_class_id;
       		e_classes[0] = OPP_EMSsubbs_class_id;

       		sts = lc$locate(
         		rc =		&msg,
         		event1 =	&me->locate_event,
         		event2 =	&accept_event,
         		mask1 =		locate_mask,
         		mask2 =		accept_mask,
         		display_flag =	display_flag,
			locate_key = 	IDFF_P_IdentSurf,
			acc_key = 	IDFF_P_AccptRejSurf,
         		relocate_key = 	EMS_I_00011,
         		attributes = 	&attributes,
         		stack = 	&me->locate_stack,
         		rtree_classes = &rtree_classes,
         		eligible_classes =     &eligible_classes);
       		ERROR(sts, 1, "GRlclocate error")

       
       		if (!(1&msg))
       		{
        		if (ME.IDrmpls->locate_event.response == EX_BACK_UP)
         			ME.super_cmd->state = IDENTIFY_SURFACE;
        		else return(OM_S_SUCCESS);
       		}
       		else
       		{
        		struct GRid lcobj;

        		ME.IDrmpls->surface = accept_event.located_object[0];
        		lcobj = ME.IDrmpls->surface.located_obj;

        		sts = dp$erase_hilite(msg = &msg);
        		ERROR(sts, msg, "erase hilite error")

        		if (me->mytype == MOVE_POLES)
        		{
         		    sts = om$send (msg = message 
                                IDrmpls.display_polygon(TRUE,TRUE),
                       		    targetid = my_id);
         		    ERROR(sts,1,"Error in displaying polygon")
        		}

        		sts = om$send (msg = message IDrmpls.store_geom(&msg),
                       		targetid = my_id);
        		ERROR(sts,msg,"Error in storing geometry")

        		ME.super_cmd->state = INPUT_POLE;
       		}
      	    }
   	    break;

            /* ---------------------------------------------------- */
            /* Have the user select a pole representing a row.      */
            /* ---------------------------------------------------- */
   	    case INPUT_POLE:
   	    {
    		event_mask = GRm_DATA | GRm_RJT_MOVEON | 
			GRm_RESTART | GRm_BACK_UP;

		if (me->mytype == MOVE_POLES )
      		{
		  if (me->num_poles == 0)
		  {
		    ex$message(msgnumb = IDFF_P_InputPole, buff = string);
		  }
		  else
		  {
		    ex$message(msgnumb = IDFF_P_InpPolMvOn, buff = string);
		  }
      		}

    		sts = co$getevent(
     			msg =		&msg,
     			event_mask = 	event_mask,
     			prompt =	string,
     			response =	response,
     			response_data =	response_data,
     			event =		&event);

    		if (! (1 & sts)) return(OM_E_ABORT);

    		if (event.response == GR_UNKNOWN_TYPE) return (OM_S_SUCCESS);
    		else if (event.response == EX_BACK_UP)
    		{
     			if (me->num_pole_events == 0) /* At the start then */
     			{

      				ME.super_cmd->state = IDENTIFY_SURFACE;

      				if (me->mytype == MOVE_POLES)
      				{
					/*
 					* Erase the polygon should we go back 
					* to the state where we relocate
 					* the surface.
 					*/
       					sts = om$send (msg = message 
					    IDrmpls.display_polygon(FALSE,TRUE),
                     				targetid = my_id);
       					ERROR(sts,1,
						"Error in displaying polygon")

      				}
     			}
     			else
     			{
      				sts = om$send(msg = message 
					IDrmpls.display_pole_event(FALSE),
                     			targetid = my_id);
      				ERROR(sts,1,"display pole event")

      				sts = om$send(msg = message 
					IDrmpls.backup_pole_event(),
                     			targetid = my_id);
      				ERROR(sts,1,"backup pole event")
     			}
    		}
    		else if (event.response == EX_DATA)
    		{
			/*
 			* Get the pole index.
 			*/
       				/*
        			* See if a fence or a solid has been located. 
				* If so use the same
        			* to determine any poles which are inside and 
				* then go to the
        			* state input pole again in which case he 
				* may decide to input
        			* more poles or moves on.
        			*/

        			IGRboolean volume_located = FALSE;
        			struct GRid volume_GRid;
        			IGRint type;

        			md_env = &event.located_object[0].module_info;

        			if (!volume_located)
        			{
         			     sts = om$send (msg = message 
					IDrmpls.get_pole_position(&event,
                           		&me->from_pole_inx,&onpolygon),
                       			targetid = my_id);
         			    ERROR(sts,1,"get_pole_position error")

        			    if (onpolygon)
         			    {
					{
          				   IGRint pole_index;

            				   pole_index = me->from_pole_inx;

            				   sts = om$send (msg = message 
						IDrmpls.store_row(me->row,
                                 		pole_index),
                           			targetid = my_id);
            				   if (!(1&sts)) return (OM_E_ABORT);

            				   sts = om$send (msg = message 
					      IDrmpls.display_pole_event(TRUE),
                           		      targetid = my_id);
            				   ERROR(sts,1,
						"display_pole_event error")

            				   ME.super_cmd->state = 
						ACCEPT_REJECT_POLE;
         			       }
        			    }
         			    else
         			    {
          				ME.super_cmd->state = INPUT_POLE;
          				if (me->mytype == MOVE_POLES)
					{
					  ex$message(field = ERROR_FIELD,
						     msgnumb = IDFF_W_PolNotFound);
					}
         			    }
        			}
        			else
        			{
         			    IGRint oldnum;

         			    oldnum = me->num_poles;

         			    if (type & FENCE_LOCATED)
         			    {
				      if (me->mytype == MOVE_POLES)
				      {
					ex$message(field = ERROR_FIELD,
						   msgnumb = IDFF_M_PrcPolFence);
				      }
         			    }
         			    else if (type & SOLID_LOCATED)
         			    {
				      if (me->mytype == MOVE_POLES)
				      {
					ex$message(field = ERROR_FIELD,
						   msgnumb = IDFF_M_PrcPolSolid);
				      }
         			    }

         
         			    sts = om$send (msg = message 
					IDrmpls.storepoles_in_volume(&msg, 
                              		type,md_env, &volume_GRid),
                        		targetid = my_id);
         			    ERROR(sts,msg,"process volume"); 

        			}
    		}
    		else if (event.response == EX_RJT_MOVEON)
    		{
    		}
   	    }
   	    break;

            /* ---------------------------------------------------- */
            /* Have the user tell us whether we found the correct   */
            /* row of poles.  If not, then toggle the direction of  */
            /* our row on the surface.  ( from u to v, etc )        */
            /* ---------------------------------------------------- */
   	    case ACCEPT_REJECT_POLE:
   	    {
    		event_mask = GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON;


    		if (me->mytype == MOVE_POLES)
		{
		  ex$message(msgnumb = IDFF_P_AccptPolDir, buff = string);
		}
		ex$message(field = ERROR_FIELD, msgnumb = IDFF_M_HiSfPtChg);

    		sts = co$getevent(
     			msg =		&msg,
     			event_mask = 	event_mask,
     			prompt =	string,
     			response =	response,
     			response_data =	response_data,
     			event =		&event);
    		if (! (1 & sts)) return(OM_E_ABORT);

	        /* ----------------------------	*/
	        /* turn off highlighted poles	*/
	        /* ----------------------------	*/
		sts = om$send(msg = message 
        			IDrmpls.display_pole_event(FALSE),
                        	targetid = my_id);
      		ERROR(sts,1,"display_pole_event error")

                switch(event.response)
                {
                    case GR_UNKNOWN_TYPE:
                    case EX_RESTART:
                        return(OM_S_SUCCESS);

                    case EX_BACK_UP:
                    {
                        /* ---------------------------------------- */
                        /* User has backed up, maybe wants to       */
                        /* choose a different row of poles.         */
                        /* ---------------------------------------- */
      			ME.super_cmd->state = INPUT_POLE;
      			sts = om$send(msg=message IDrmpls.backup_pole_event(),
                           	targetid = my_id);
      			ERROR(sts,1,"display_pole_event error")
    		    }
                    break;

                    case EX_RJT_MOVEON:
    		    {
                        /* ---------------------------------------- */
                        /* User rejected row, so toggle direction.  */
                        /* ---------------------------------------- */
      			sts = om$send (msg = message 
				IDrmpls.backup_pole_event(),
                           	targetid = my_id);
      			ERROR(sts,1,"backup_pole_event error")

      			me->row = !me->row;

      			sts = om$send (msg = message IDrmpls.store_row(me->row,
                           	me->from_pole_inx),
                   		targetid = my_id);
      			if (!(1&sts)) return (OM_E_ABORT);

      			sts = om$send (msg = message 
				IDrmpls.display_pole_event(TRUE),
                           	targetid = my_id);
      			ERROR(sts,1,"display_pole_event error")

      			ME.super_cmd->state = ACCEPT_REJECT_POLE;
    		    }
                    break;

                    case EX_DATA:
    		    {
                        /* ---------------------------------------- */
                        /* User has accepted the row, so delete it. */
                        /* ---------------------------------------- */
		        if(! IDsurf_has_enough_rows_to_delete_one(me->surf_ptr,
			    !me->row))
		        {
			    ex$message(field = ERROR_FIELD,
				       msgnumb = IDFF_E_RmRwPlMinRws);

     		            ME.super_cmd->state = IDENTIFY_SURFACE;
  		    	    if (me->surf_ptr) om$dealloc(ptr = me->surf_ptr);
		    	    sts =om$send(msg = message IDrmpls.init_variables(),
                    		    mode = OM_e_wrt_message,
                    		    targetid = my_id);
  		    	    if (!(1&sts)) return (OM_E_ABORT);
		            goto fini1;
		        }
       		        sts = om$send(	msg = message IDrmpls.
				change_surface_by_deleting_row(),
                     		targetid = my_id);
  		        if (!(1&sts)) 
                        {
			    ex$message(field = ERROR_FIELD,
				       msgnumb = IDFF_E_MAERR);
                            return (OM_E_ABORT);
                        }
                        else
                        {
     		            ME.super_cmd->state = ACCEPT_REJECT_NEW_SURFACE;
                        }
fini1:
  		        if (!(1&sts)) 
                        {
     		            ME.super_cmd->state = IDENTIFY_SURFACE;
  		    	    if (me->surf_ptr) om$dealloc(ptr = me->surf_ptr);
		    	    sts =om$send(msg = message IDrmpls.init_variables(),
                    		    mode = OM_e_wrt_message,
                    		targetid = my_id);
  		    	    if (!(1&sts)) return (OM_E_ABORT);
                        }

    		    }  /* EX_DATA */

                    default:
                        return(OM_S_SUCCESS);

                }    /* --- switch(event.response)  --- */    


   	    }
   	    break;   /*  --- End state ACCEPT_POLE ---  */

            /* ---------------------------------------------------- */
            /* ---------------------------------------------------- */
   	    case ACCEPT_REJECT_NEW_SURFACE:
   	    {
    		event_mask = GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON;


    		if (me->mytype == MOVE_POLES)
		{
		  ex$message(msgnumb = IDFF_P_IdentSurf, buff = string);
		}

		ex$message(field = ERROR_FIELD, msgnumb = IDFF_P_BckMovUndo);
    		sts = co$getevent(
     			msg =		&msg,
     			event_mask = 	event_mask,
     			prompt =	string,
     			response =	response,
     			response_data =	response_data,
     			event =		&event);
    		if (! (1 & sts)) return(OM_E_ABORT);

    		if (event.response == GR_UNKNOWN_TYPE) return (OM_S_SUCCESS);
    		else if (event.response == EX_BACK_UP)
    		{
                        /* ---------------------------------------- */
                        /* User has rejected new surface, so        */
                        /* restore the original surface.            */
                        /* ---------------------------------------- */
  		        sts =om$send (msg = message 
                            IDrmpls.restore_original_geometry(&msg,
				(struct GRlc_info *) &me->surface.located_obj,
				&me->surface.located_obj.objid),
                    		mode = OM_e_wrt_message,
                    		targetid = my_id);
  		        if (!(1&sts)) return (OM_E_ABORT);
  		        sts =om$send (msg = message 
                            IDundo.delete_saved_geom(ID_SURFACE_GEOM),
                    		mode = OM_e_wrt_message,
                    		targetid = my_id);
  		        if (!(1&sts)) return (OM_E_ABORT);
     		        ME.super_cmd->state = IDENTIFY_SURFACE;
  		    	if (me->surf_ptr) om$dealloc(ptr = me->surf_ptr);
		    	sts =om$send (msg = message IDrmpls.init_variables(),
                    		mode = OM_e_wrt_message,
                    		targetid = my_id);
  		    	if (!(1&sts)) return (OM_E_ABORT);
			ex$message(field = ERROR_FIELD,
				   msgnumb = IDFF_M_SurfRestored);
    		}
    		else if (event.response == EX_RJT_MOVEON)
    		{
                        /* ---------------------------------------- */
                        /* User has rejected new surface, so        */
                        /* restore the original surface.            */
                        /* ---------------------------------------- */
  		        sts =om$send (msg = message 
                            IDrmpls.restore_original_geometry(&msg,
				(struct GRlc_info *) &me->surface.located_obj,
				&me->surface.located_obj.objid),
                    		mode = OM_e_wrt_message,
                    		targetid = my_id);
  		        if (!(1&sts)) return (OM_E_ABORT);
  		        sts =om$send (msg = message 
                            IDundo.delete_saved_geom(ID_SURFACE_GEOM),
                    		mode = OM_e_wrt_message,
                    		targetid = my_id);
  		        if (!(1&sts)) return (OM_E_ABORT);
     		        ME.super_cmd->state = IDENTIFY_SURFACE;
  		    	if (me->surf_ptr) om$dealloc(ptr = me->surf_ptr);
		    	sts =om$send (msg = message IDrmpls.init_variables(),
                    		mode = OM_e_wrt_message,
                    		targetid = my_id);
  		    	if (!(1&sts)) return (OM_E_ABORT);
			ex$message(field = ERROR_FIELD,
				   msgnumb = IDFF_M_SurfRestored);
    		}
    
    		else if (event.response == EX_DATA)
    		{
                        /* ---------------------------------------- */
                        /* User has accepted the row, so delete it. */
                        /* ---------------------------------------- */
		        ex$message(field = ERROR_FIELD,
				   msgnumb = IDFF_M_RwPolSucDel);

     		        ME.super_cmd->state = IDENTIFY_SURFACE;

  		    	if (me->surf_ptr) om$dealloc(ptr = me->surf_ptr);
		    	sts =om$send (msg = message IDrmpls.init_variables(),
                    		mode = OM_e_wrt_message,
                    		targetid = my_id);
  		    	if (!(1&sts)) return (OM_E_ABORT);

                        /* -------------------------------------------  */
                        /* feed event back into locate for next surface */
                        /* -------------------------------------------  */
	 		event_size = sizeof(struct GRevent) - sizeof(long) * 2;
	                event_response = EX_DATA;
	                sts = ex$putque(msg= &msg, byte = &event_size, 
                                response = &event_response,
		                buffer = (IGRchar *) &event.event);

    		}  /* EX_DATA */
   	    }
   	    break;


        }    /* switch on state    */
    } while (loop);

    return (OM_S_SUCCESS);
}

end implementation IDrmpls;


