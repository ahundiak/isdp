/* ###################   APOGEE COMPILED   ################## */
class implementation ECtasurfs;

/*

ABSTRACT: 

This Command Object gives a measure of tangency between two surfaces along an
edge joining the two surfaces by calculating the surface normals along the 
edge on both surfaces and expressing the deviation.

HISTORY:

BL  06/19/89  	Creation date.
BL  08/14/89  	The plot process was being forked from the current directory 
		and needed to be forked from the product directory.
BL  08/17/89	Added the init method and changed GRgetevent to co$getevent.
pp  10/04/89    Made changes so that when outputting to database and no 
		variation was detected in tangency the legend has information 
		about only one color.
BL  12/27/89	Made change to an error message showing it needs a composite
		surface and the delete() method.
pp  01/25/90    Changed GRIO_SCALAR to GRIO_DISTANCE for length of normals.
10/05/91    DLB Added & to event_size in lc$locate.
Tapadia 5/25/92 Modified for message sub-system compliance 
NP  04/12/93    fopen() could not create a file ptr and fprintf was crashing.
                Added check for NULL file ptr.
Sudha 7/5/93    Modified for BSprototypes ansification

*/

#include "EMS.h"
#include <stdio.h>
%safe
#include <math.h> 	/* For fabs */
%endsafe
#include "OMerrordef.h"
#include "OMmacros.h"
#include "igr.h"
#include "igrtypedef.h"
#include "griodef.h"	/* for UOM_ANGLE */
#include "grio.h"	/* for struct GRIOreadout_spec */
#include "igrdef.h"
#include "codef.h"
#include "ex.h"
#include "exdef.h"	/* for EX_PRODUCT_PATH */
#include "exmacros.h"
#include "griomacros.h"	/* co$getevent */
#include "EMSbnd.h"
#include "EMSopt.h"
#include "EMSlmdef.h"
#include "lcdef.h"
#include "lcmacros.h"
#include "msdef.h"
#include "emsdef.h"	/* for MAXINT */
#include "emserr.h"
#include "dpmacros.h"
#include "bserr.h"
#include "bsparameters.h"	/* for BSEXTRACTPAR() */
#include "EC_M.h"
#include "EC_S.h"
#include "EC_P.h"
#include "EC_E.h"
#include "bsdistptpt.h"


#define MAXNUM		30
#define MAXNUM9		270
#define MAXCOLOR	6
#define MAXCOLOR2	12


#define FAIL		0

#if DEBUG
#define ERROR(sts, errmsg) \
{ \
  if(! (1 & sts)) \
  { \
	printf("\nIn ECtasurfs: %s\n", errmsg); \
	goto ret_end; \
  } \
}
#else
#define ERROR(sts, errmsg) \
{ \
  if(! (1 & sts))  goto ret_end; \
}
#endif


from GRgraphics import GRdisplay;
from EMSedge import EMget_bcxyz_geom;
from EMSboundary import EMget_edges;
from EMSsubbs  import EMget_tan_btn_surfs;


method init(int type; char *str_ptr)
{
  IGRlong  sts;

  /* initialize */
  sts = OM_S_SUCCESS; 
  ME.super_cmd->state = 0;
  ME.ECelement->elem_hilit = FALSE;
  me->curve.poles = NULL;
  me->curve.knots = NULL;
  me->curve.weights = NULL;
  me->curve.bdrys = NULL;

  return(sts);

} /* init */


method wakeup(IGRint pos)
{
    IGRlong msg_loc, stat_OM;
    enum GRdpmode dpmode;

    stat_OM = OM_S_SUCCESS;
    ex$message(msgnumb = EMS_P_ClearPromptField);
    ex$message(msgnumb = EM_M_MeaTanBet2Surf);

    stat_OM = om$send(mode = OM_e_wrt_message, 
		msg = message ECelement.wakeup(pos),
		targetid = my_id);
    ERROR(stat_OM, "wakeup.wakeup error");

    if(ME.ECelement->elem_hilit)
    {
	dpmode = GRbdhd;
    	stat_OM = om$send(msg = message GRgraphics.GRdisplay(&msg_loc, 
		&ME.ECelement->elem.module_info.md_env.matrix_type,
                ME.ECelement->elem.module_info.md_env.matrix, &dpmode, 
                &ME.ECelement->md_env.md_id),
                targetid = ME.ECelement->elem.located_obj.objid,
                targetos = ME.ECelement->elem.located_obj.osnum );
    	ERROR((stat_OM & msg_loc), "wakeup.GRdisplay error");
    } 

 ret_end:  return(stat_OM);

} /* wakeup */


method delete(int f_defer_flag)
{
  IGRlong  sts, msg_loc;
  
  if(me->curve.poles)  om$dealloc(ptr = me->curve.poles);
  if(me->curve.knots)  om$dealloc(ptr = me->curve.knots);
  if(me->curve.weights)  om$dealloc(ptr = me->curve.weights);
  if(me->curve.bdrys)  om$dealloc(ptr = me->curve.bdrys);
  if(ME.ECelement->elem_hilit)  sts = dp$erase_hilite(msg = &msg_loc);
    
  sts = om$send(mode = OM_e_wrt_message, msg = message Root.delete(1),
        	targetid = my_id);

  return(sts);

} /* delete */


method execute(IGRint *response; IGRchar *response_data; IGRint pos)
{
  IGRchar  key_in = NULL;
  static IGRint  double_size, point_size, event_size;
  IGRint  i, num_of_colors, *color;
  GRobjid  *objects, objs[MAXNUM];
  IGRlong  sts, msg_loc, event_mask;
  IGRdouble  *range_scale, ranges[MAXCOLOR2];
  IGRdouble  *angles, angle[MAXNUM], *polyline, polylines[MAXNUM9];
  struct GRid	*edges;
  struct GRevent  event;
  enum GRdpmode  dpmode;

  /* initialize */
  sts = OM_S_SUCCESS;
  *response = TERMINATE;
  color = NULL;	objects = NULL;
  edges = NULL;
  angles = polyline = range_scale = NULL; 
  double_size = sizeof(IGRdouble);
  point_size = 3 * double_size;
  event_size = sizeof(struct GRevent);

  do 
  {
    switch(ME.super_cmd->state)
    {
      case 0:
      {
  	IGRboolean  stat_func;
  	IGRchar  locate_prompt[MAX_PROMPT_SIZE];
	IGRchar  relocate_prompt[MAX_PROMPT_SIZE];
	IGRlong  in_all_win, object_was_located;
  	struct GRlc_locate  lc_attr;
  	struct GRevent  accev;
  	OMuword  rclass, eliclass;
  	OM_S_CLASSLIST  rtree_classes, elig_classes;
  	extern OMuword  OPP_EMSsubbs_class_id;

        if(ME.ECelement->elem_hilit)
        {
           dpmode = GRbdhe;
           sts = om$send(msg = message GRgraphics.GRdisplay(&msg_loc, 
		&ME.ECelement->elem.module_info.md_env.matrix_type, 
		ME.ECelement->elem.module_info.md_env.matrix, 
		&dpmode, &ME.ECelement->md_env.md_id),
                targetid = ME.ECelement->elem.located_obj.objid,
                targetos = ME.ECelement->elem.located_obj.osnum);
           ERROR((sts & msg_loc), "execute(0).GRdisplay error");

           ME.ECelement->elem_hilit = FALSE;
        } /* if */

        in_all_win = ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT;

        rtree_classes.w_count = 1;
        elig_classes.w_count = 1;
        rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;
        rtree_classes.p_classes = &rclass;
        elig_classes.p_classes = &eliclass;

        rclass = OPP_EMSsubbs_class_id;
        eliclass = OPP_EMSsubbs_class_id;
        strcpy(lc_attr.classes, "EMSsubbs");
	ex$message(msgnumb = EMS_P_00031, buff = locate_prompt);
	ex$message(msgnumb = EMS_I_00011, buff = relocate_prompt);  
        lc_attr.properties = LC_LC_ONLY | LC_DP_ONLY | LC_RW;
        lc_attr.owner_action = LC_RIGID_COMP | LC_FLEX_COMP |
          	LC_REF_OBJECTS |  /* locate reference objects */
                LC_NO_REF_HEADER; /* no reference file header */

/****
DLB 10/5/91	Added & to event_size.  Crash on SUN.
****/

        stat_func = lc$locate(rc = &object_was_located, 
		event1 = &ME.ECelement->locev,
                event2 = &accev, 
		mask1 = GRm_DATA | GRm_BACK_UP, 
		mask2 = GRm_DATA,
                eventsize = &event_size, 
		display_flag = in_all_win,
                response = response, response_data = response_data,
                locate_prompt = locate_prompt, 
		acc_prompt = "Accept(with edge)/Reject",
                relocate_prompt = relocate_prompt,
                attributes = &lc_attr, 
		stack = &ME.ECelement->locate_stack,
                rtree_classes = &rtree_classes, 
                eligible_classes = &elig_classes);

	ex$message(msgnumb = EMS_S_ClearStatusField);
        ex$message(msgnumb = EMS_P_ClearPromptField);

	if(stat_func == FALSE)
	{
	   ex$message(msgnumb = EMS_E_FailInputProcExit);
	   goto ret_end;
	} /* if */
        if(!object_was_located)
        {
           if(ME.ECelement->locev.response == EX_BACK_UP)  
	   {
		ex$message(msgnumb = EMS_I_00005);
		break;
	   }
           else  return(OM_S_SUCCESS);
        } /* if */

        if(accev.response == EX_DATA)
	{
	   IGRlong qsize;

           ME.ECelement->elem_hilit = TRUE;
           ME.ECelement->elem.located_obj.objid = me->pair.surf0 =
		accev.located_object[0].located_obj.objid;
           ME.ECelement->elem.located_obj.osnum =
		accev.located_object[0].located_obj.osnum;
           ME.ECelement->elem.module_info = 
		accev.located_object[0].module_info;

	   /* accept with edge */
           qsize = sizeof(accev) - 2 * sizeof(IGRint);
           sts = ex$putque(msg = &msg_loc, response = response,
                byte = &qsize, buffer = (char *)&accev.event);
           ERROR((sts & msg_loc), "execute(0).putque error");

	   /* index for get edge event */
	   me->pick_edge = TRUE;
           ME.super_cmd->state = 1;
	} /* if */
	else  goto  ret_end;
        break;

      } /* case 0 */

      /* 
       * Identify the edge between two stitched surfaces
       */

      case 1:
	if(!ME.ECelement->elem_hilit)
	{
          dpmode = GRhd;
          sts = om$send(msg = message GRgraphics.GRdisplay(&msg_loc,
		&ME.ECelement->elem.module_info.md_env.matrix_type,
                ME.ECelement->elem.module_info.md_env.matrix,
                &dpmode, &ME.ECelement->md_env.md_id),
                targetid = me->pair.surf0,
                targetos = ME.ECelement->elem.located_obj.osnum);
          ERROR((sts & msg_loc), "execute(1).GRdisplay error");

	  ME.ECelement->elem_hilit = TRUE;
	}

	if(!me->pick_edge)  ex$message(msgnumb = EMS_P_IdentifyEdge)

    	event_mask = GRm_DATA | GRm_BACK_UP;
  	sts = co$getevent(msg = &msg_loc, event_mask = event_mask,
		response = response, response_data = response_data, 
		event = &event);
        ex$message(msgnumb = EMS_P_ClearPromptField);
	ex$message(msgnumb = EMS_S_ClearStatusField);
	if(!(1 & sts) || msg_loc == MSFAIL)
	{
	   sts = FAIL;
	   goto  ret_end;
	}

        switch(event.response)
        {
  	   IGRchar  accept_prompt[MAX_PROMPT_SIZE];
	   IGRboolean  hili;
	   IGRint  num_edges, buf_size;
  	   struct GRevent  accev;
	   OM_S_CHANSELECT  to_loopset;

           case EX_DATA:
		sts = om$make_chanselect(channame= "EMSsubbs.to_loopset",
			p_chanselect = &to_loopset);
            	ERROR(sts, "execute(1).make_chanselect error");

		/* get the non-stitchable edges in the located surface */

        	num_edges = buf_size = 0;
        	sts = om$send(msg=message EMSboundary.EMget_edges(&msg_loc,
                    	MAXINT, EMS_OPT_NON_DEG_STITCHED,
                    	&edges, &buf_size, &num_edges),
            		senderid = me->pair.surf0,
            		p_chanselect = &to_loopset,
			targetos = ME.ECelement->elem.located_obj.osnum);
            	ERROR((sts & msg_loc), "execute(1).EMget_edges error");
        	if(!num_edges)
        	{
		   ex$message(msgnumb =  EMS_S_ThisIsNotComp);
        	   ME.super_cmd->state = 0;
        	   break;
        	}

        	sts = dp$erase_hilite(msg = &msg_loc);
		ex$message(msgnumb = EMS_P_AccRejEdge, buff = accept_prompt);

        	sts = EMtpselect(&msg_loc, edges, 
			ME.ECelement->elem.located_obj, num_edges,
                 	EMS_GET_MOD_EDGE, NULL, event,
                 	&ME.ECelement->elem.module_info, 
			accept_prompt, &event_mask,
                 	&event_size, response, response_data,
                 	&accev, &hili);
		me->pick_edge = FALSE; /* for get edge event index */
		me->pair.edge0 = accev.located_object[0].located_obj.objid;
  		if(edges) 
		{ 
		   om$dealloc(ptr = edges);  
		   edges = NULL; 
		}
            	ERROR((sts & msg_loc), "execute(1).EMtpselect error");

            	if(accev.response == GR_UNKNOWN_TYPE || 
			accev.response == EX_BACK_UP)  break;

		ME.super_cmd->state = 2;
            	break;	

           case EX_BACK_UP:
            	ME.super_cmd->state = 0;
            	break;
           default:
            	goto ret_end;

        } /* switch */
        ME.ECelement->elem_hilit = FALSE;
        sts = dp$erase_hilite(msg = &msg_loc);	
        break;

      /* 
       * Input number of points along the common edge needed to be measured
       */

      case 2:
	ex$message(msgnumb = EMS_P_KeyinNumPts);

        event_mask = GRm_VALUE | GRm_BACK_UP | GRm_RJT_MOVEON;
  	sts = co$getevent(msg = &msg_loc, event_mask = event_mask,
		value_type = GRIO_SCALAR, response = response, 
		response_data = response_data, event = &event);
        ex$message(msgnumb = EMS_P_ClearPromptField);
	if(!(1 & sts) || msg_loc == MSFAIL)
	{
	   sts = FAIL;
	   goto  ret_end;
	}
        if(msg_loc == GRw_no_value)  event.response = EX_RJT_MOVEON;

        switch(event.response)
        {
           case EX_RJT_MOVEON:
            	me->num_pts = 10;
            	ME.super_cmd->state = 3;
            	break;
           case EX_VALUE:
            	me->num_pts = (IGRint) event.event.value;
            	if(me->num_pts <= 2)  
			ex$message(msgnumb = EMS_S_InvInp)
            	else  	
			ME.super_cmd->state = 3;
            	break;
           case EX_BACK_UP:
            	ME.super_cmd->state = 1;
            	break;
	   default : goto ret_end;

        } /* switch */
        break;

      case 3:
	ex$message(msgnumb = EMS_P_OutInDbaseGraph);

        event_mask = GRm_STRING | GRm_BACK_UP | GRm_RJT_MOVEON;
  	sts = co$getevent(msg = &msg_loc, event_mask = event_mask,
		response = response, response_data = response_data, 
		event = &event);
        ex$message(msgnumb = EMS_P_ClearPromptField);
	ex$message(msgnumb = EMS_S_ClearStatusField);
	if(!(1 & sts) || msg_loc == MSFAIL)
	{
	   sts = FAIL;
	   goto ret_end;
	}
        if(msg_loc == GRw_no_value)  event.response = EX_RJT_MOVEON;

        switch(event.response)
        {
           case EX_STRING:
		if(event.event.keyin[1] != '\0')
		{
            	   ex$message(msgnumb = EMS_S_InvInp);
		   break;
		}
		else  key_in = toupper(event.event.keyin[0]);

            	if(key_in == 'D')  
		{
		   me->graph_only = FALSE;
            	   ME.super_cmd->state = 4;
		} /* if */
            	else if(key_in == 'G')
		{
		   me->graph_only = TRUE;
		   /* initialize */
		   me->norm_len = 3.0;
            	   ME.super_cmd->state = 6;
		} /* else if */
		else  ex$message(msgnumb = EMS_S_InvInp)
            	break;
	   case EX_RJT_MOVEON:
		me->graph_only = TRUE;
		/* initialize */
		me->norm_len = 3.0;
            	ME.super_cmd->state = 6;
		key_in = 'G';
		break;
           case EX_BACK_UP:
              	ME.super_cmd->state = 2;
            	break;
           default:
            	goto  ret_end;

        } /* switch */

	if(key_in == 'D' || key_in == 'G')
	{
	   /* initialize */
	   if(me->curve.poles && me->curve.knots)
	   {
    		om$dealloc(ptr = me->curve.poles);
    		om$dealloc(ptr = me->curve.knots);
	    	me->curve.poles = me->curve.knots = NULL;
    		if(me->curve.weights)  om$dealloc(ptr = me->curve.weights);
    		if(me->curve.bdrys)  om$dealloc(ptr = me->curve.bdrys);
	    	me->curve.weights = me->curve.bdrys = NULL;
	   }

	   /* get the located edge's geometry */
	   sts = om$send(msg = message EMSedge.EMget_bcxyz_geom(&msg_loc,
			&ME.ECelement->elem.module_info.md_env,
			&ME.ECelement->elem.located_obj, NULL, 0,
			MAXINT, FALSE, NULL, &me->curve),
			targetid = me->pair.edge0,
			targetos = ME.ECelement->elem.located_obj.osnum);
           ERROR((sts & msg_loc), "execute(3).EMget_bcxyz_geom error");

	   key_in = '\0';  /* initialize */
	} /* if */
        break;

      case 4:
      {
  	IGRpoint  start_pt, xyz;
  	extern IGRint  EFrblineseg();

	ex$message(msgnumb = EMS_P_EnterLenNormals);
	if(me->curve.rational)
	{
	   IGRdouble  poles[3];

	   poles[0] = me->curve.poles[0] / me->curve.weights[0];
	   poles[1] = me->curve.poles[1] / me->curve.weights[0];
	   poles[2] = me->curve.poles[2] / me->curve.weights[0];
	   OM_BLOCK_MOVE(poles, start_pt, point_size);
	} /* if */
	else  OM_BLOCK_MOVE(me->curve.poles, start_pt, point_size);

        sts = EFrblineseg(start_pt, &ME.ECelement->active_display);

        event_mask = GRm_VALUE | GRm_DATA | 
		GRm_RJT_MOVEON | GRm_BACK_UP;
  	sts = co$getevent(msg = &msg_loc, event_mask = event_mask,
		value_type = GRIO_DISTANCE, response = response, 
		response_data = response_data, event = &event);
        ex$message(msgnumb = EMS_P_ClearPromptField);
	ex$message(msgnumb = EMS_S_ClearStatusField);
	if(!(1 & sts) || msg_loc == MSFAIL)
	{
	    sts = FAIL;
	    goto  ret_end;
	}
        if(msg_loc == GRw_no_value)
	{
	    ex$message(msgnumb = EMS_I_00006);
	    break;
	} /* if */

        switch(event.response)
        {

           case EX_DATA:

                xyz[0] = event.event.button.x;
                xyz[1] = event.event.button.y;
                xyz[2] = event.event.button.z;

            	me->norm_len = BSdistptpt(&msg_loc, xyz/*&event.event.button*/,
			start_pt);

		if(me->norm_len <= 0.0)
		{
		   ex$message(msgnumb = EMS_S_LenMustBePos);
		   break;
		} /* if */
		else	ME.super_cmd->state = 5;
            	break;

           case EX_VALUE:
            	me->norm_len = event.event.value;
		if(me->norm_len <= 0.0)
		{
		   ex$message(msgnumb = EMS_S_LenMustBePos);
		   break;
		} /* if */
              	else  ME.super_cmd->state = 5;
            	break;

           case EX_BACK_UP:
            	ME.super_cmd->state = 3;
            	break;

	   default : goto ret_end;

        } /* switch */
      } /* case 4 */
      break;

      case 5:
	ex$message(msgnumb = EMS_P_InUppLftPtLegend);

        event_mask = GRm_DATA | GRm_BACK_UP;
  	sts = co$getevent(msg = &msg_loc, event_mask = event_mask,
		response = response, response_data = response_data, 
		event = &event);
        ex$message(msgnumb = EMS_P_ClearPromptField);
	ex$message(msgnumb = EMS_S_ClearStatusField);
	if(!(1 & sts) || msg_loc == MSFAIL)
	{
	   sts = FAIL;
	   goto  ret_end;
	}
	if(msg_loc == GRw_no_value)
	{
	   ex$message(msgnumb = EMS_I_00006);
	   break;
	} /* if */

	if(event.response == EX_DATA)
	{
	   me->button = event.event.button;
           ME.super_cmd->state = 6;
	} /* if */
	else if(event.response == EX_BACK_UP)  ME.super_cmd->state = 4;	
	else  goto ret_end;
	break;

      case 6:
      {
	ex$message(msgnumb = EMS_S_ProcessingOne);

	/* initialize */
	angles = polyline = range_scale = NULL;
	color = NULL;	objects = NULL;

    	sts = dp$erase_hilite(msg = &msg_loc);
        ERROR((msg_loc & sts), "execute(6).erase_hilite error");

        ME.ECelement->elem_hilit = FALSE;

	if(me->num_pts > MAXNUM)
	{
	   angles = (IGRdouble *) om$malloc(size = me->num_pts * double_size);
           if(!angles)  goto ret_end;
	   polyline = (IGRdouble *) om$malloc(size=9*me->num_pts*double_size);
           if(!polyline)  goto ret_end;
	}
	else
	{
	   angles = angle;
	   polyline = polylines;
	}

	ex$message(msgnumb = EMS_S_ProcessingOne);

        sts = om$send(msg = message EMSsubbs.EMget_tan_btn_surfs(&msg_loc, 
		&ME.ECelement->elem.module_info.md_env, 
		&ME.ECelement->elem.located_obj, 
		&me->pair.edge0, &me->curve, me->num_pts, 
		&me->norm_len, NULL, polyline, angles),
                targetid = ME.ECelement->elem.located_obj.objid,
                targetos = ME.ECelement->elem.located_obj.osnum);
        ERROR((msg_loc & sts), "execute(6).EMget_tan_btn_surfs error");

	ex$message(msgnumb = EMS_S_ProcessingTwo);

	if(me->graph_only)	
	{
	  FILE  *out_file=NULL;
	  IGRdouble  j, *tag;
	  IGRchar  proc_name[80], *cptr[4];

	  /* create a data file for ploting a graph */

	  out_file = fopen("/tmp/datfile", "w");
          if (out_file == NULL)
          {  /* if outfile file does not have write permissions or cannot be
              * created.
              */
             ex$message(msgnumb = EMS_E_OpenFileW, var = "/tmp/datfile", 
                        type    = "%s");
             sleep (3);
             sts = FAIL;
             goto ret_end;
          }
	  fprintf(out_file, "%d\n", me->num_pts);

	  tag = angles;
	  for(j = 1 ; tag < angles + me->num_pts ; j+=1)
	    	fprintf(out_file, "%lf %lf\n", j, *tag++);

	  fprintf(out_file, "%d\n", -1);
	  fprintf(out_file, "%s\n", "Tangency between Two Surfaces");
	  fprintf(out_file, "%s\n", "Number points");
	  fprintf(out_file, "%s\n", "Tangency value (degree)");
	  fclose(out_file);

	  ex$message(msgnumb = EMS_S_Processing);

          /* 
           * Find and execute the plot executable image
           */
          {
            IGRint  file_absent;
	    IGRboolean  not_done, path_found;
            extern int  access();

	    file_absent = not_done = TRUE;
            for(i = 0 ; (i < 20) && not_done ; ++i)
            {
               path_found = ex$get_path(index = i, path = proc_name,
    			len = sizeof(proc_name),
                     	type = EX_PRODUCT_PATH);
               if(path_found)
               {
                  strcat(proc_name, "/bin/graph");
                  file_absent = access(proc_name, 0);
                  if(!file_absent)  not_done = FALSE;
               }
               else  not_done = FALSE;
            } /* for */

	    ex$message(msgnumb = EMS_S_ProcessingFour);

            if(file_absent)  ex$message(msgnumb = EMS_E_PlExeImaNotFound) 
            else
            {
		/* display graph */
                cptr[0] = proc_name;
                cptr[1] = "-tang";
		cptr[2] = "/tmp/datfile";
		cptr[3] = NULL;
                ex$fork (num_entry = 3, argu = cptr);
		ex$message(msgnumb = EMS_S_GraphDisplayed);
            }
          }

	} /* if graph_only */
        else
        {
	  struct GRvg_construct  const_list;
	  IGRboolean  one_color;
	  IGRint  color_index;
          IGRdouble  cross_tol;
	  IGRdouble  max_ang, min_ang, range, *tag, *tag1;
	  GRobjid  group_id, *tag2;

	  /* initialize */
	  one_color = FALSE;

          const_list.msg = &msg_loc;
          const_list.newflag = FALSE;
          const_list.env_info = &ME.ECelement->md_env;
          const_list.level = ME.ECelement->active_level;
          const_list.properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE 
					| GRIS_NEW;
          const_list.display = &ME.ECelement->active_display;
          const_list.class_attr = NULL;
          const_list.name = NULL;  

	  /* since the returned angles[] are ranged from 0 to PI */
	  max_ang = 0.0; 
	  min_ang = 180.0;

	  for(tag = angles ; tag < angles + me->num_pts ; ++tag)
	  {
	     if(*tag > max_ang)  max_ang = *tag;
	     if(*tag < min_ang)  min_ang = *tag;
	  }

	  sts = EMget_colors(&msg_loc, &num_of_colors, &color);
	  ERROR((sts & msg_loc), "execute(6).EMget_colors error");

	  if(num_of_colors > MAXCOLOR)
	  {
	     range_scale = (IGRdouble *) om$malloc(size = 2 * num_of_colors 
			* double_size);
             if(!range_scale)  goto ret_end;
	  }
	  else  range_scale = ranges;

	  if(me->num_pts > MAXNUM)
	  {
	     objects = (GRobjid *) om$malloc(size = me->num_pts * 
			sizeof(GRobjid));
             if(!objects)  goto ret_end;
	  }
	  else  objects = objs;

	  ex$message(msgnumb = EMS_S_Processing);

	  range = fabs(max_ang - min_ang);

      	  sts = BSEXTRACTPAR(&msg_loc, BSTOLCOLLINVEC, cross_tol);
      	  ERROR(sts, "BSEXTRACTPAR error");

	  if(range < cross_tol) 
	  {
	    one_color= TRUE;
	    /* for EMlegend use */
	    color_index = num_of_colors - 1; 
	    const_list.display->color = color[color_index];
	    range_scale[0] = range_scale[1] = min_ang;

	    tag1 = polyline;
	    tag2 = objects; 
	    for( ; tag2 < objects + me->num_pts ; tag1 += 9, ++tag2)
	    {
	       /* construct tangency objects */
	       sts = EFplace_line_string(
			ME.ECelement->elem.located_obj.objid, 
			&const_list, 3, tag1, tag2, &msg_loc);
	       ERROR((msg_loc & sts),"EFplace_line_string(1) error");

	    } /* for */
	  } /* if one_color */
	  else  
	  {
	    IGRushort  *tag3;
	    IGRint  j, num;
	    IGRdouble  incr, lovalue;

	    color_index = 0;
	    incr = range / num_of_colors;

	    lovalue = min_ang;
	    for(i = j = 0 ; i < num_of_colors ; ++i)
	    {
	      range_scale[j++] = lovalue;
	      range_scale[j++] = lovalue + incr;
	      lovalue += incr;
	    }

	    tag = angles; 
	    tag1 = polyline;
	    tag2 = objects;
	    tag3 = &const_list.display->color;
	    for( ; tag2 < objects + me->num_pts ; tag1 += 9, ++tag2)
	    {
	      range = *tag++ - min_ang;
	      num = (IGRint) (range / incr);

	      if(num == num_of_colors)  --num;
	      *tag3 = color[num];

	      /* construct tangency objects */

	      sts = EFplace_line_string(ME.ECelement->elem.located_obj.objid, 
			&const_list, 3, tag1, tag2, &msg_loc);
	      ERROR((msg_loc & sts), "EFplace_line_string(2) error");

	    } /* for */
	  } /* else more than one color */

	  ex$message(msgnumb = EMS_S_ProcessingFour);

	  sts = EFbuild_graphic_group((IGRlong) me->num_pts, objects, 
			NULL, &const_list, &group_id, &msg_loc);
	  ERROR((msg_loc & sts), "execute(1).EFbuild_graphic_group error");

          dpmode = GRbd;
          sts = om$send(msg = message GRgraphics.GRdisplay(&msg_loc, 
			&ME.ECelement->md_env.md_env.matrix_type, 
			ME.ECelement->md_env.md_env.matrix,
                        &dpmode, &ME.ECelement->md_env.md_id),
			targetid = group_id,
			targetos = ME.ECelement->md_env.md_id.osnum);
          ERROR((sts & msg_loc), "execute(6).GRdisplay error");

	  EMlegend(&msg_loc, me->button.window, me->button.objid,
		me->button.osnum, &me->button.x,
                (one_color ? 1 : num_of_colors), 
		&color[color_index], range_scale);
          ERROR(msg_loc, "execute(6).EMlegend error");
/*
		num_of_colors,color,range_scale);
           	pp (10/04/89)
*/

	  ex$message(msgnumb = EMS_S_TangencyDisplayed);

	  if(me->num_pts > MAXNUM && objects)  om$dealloc(ptr = objects);
	  if(num_of_colors > MAXCOLOR && range_scale) 
		om$dealloc(ptr = range_scale); 
	  if(color)  om$dealloc(ptr = color);

        } /* else if not output to graph */

  	if(me->num_pts > MAXNUM)
  	{
	   if(angles)  free(angles);
	   if(polyline)  free(polyline);
  	}

        ME.super_cmd->state = 0;

      } /* end of case 6 */
      break;

      default:
	ex$message(msgnumb = EMS_F_CommandIllegalState);
        goto ret_end;

    } /* switch */

  } while( TRUE ); /* do */

ret_end:
  if(ME.super_cmd->state == 1 && edges)  om$dealloc(ptr = edges);
  else if(ME.super_cmd->state == 6)
  {
     if(color)  free(color);
     if(range_scale && num_of_colors > MAXCOLOR)  free(range_scale);
     if(me->num_pts > MAXNUM)
     {
      	if(angles)  free(angles);
      	if(polyline)  free(polyline);
      	if(objects)  free(objects);
     }
  }

  return(sts);

} /* execute */

end implementation ECtasurfs;

