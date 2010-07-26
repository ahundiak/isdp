class implementation DMtxbln;

#define AS_DEBUG 1

#include "dimmod.h"
#include "dimgraph.h"
#include "dpdef.h"
#include "fielddef.h"
#include "msdef.h"
#include "msmacros.h"
#include "DMmessages.h"
#include "bsnorvec.h"
#include "bsmkvec.h"

#define UPPER_TEXT 0
#define LOWER_TEXT 1
#define SPLIT_BLN_INDEX 8

#include <math.h>

%safe
//#include "math.h"		// XYXYX
static IGRint split = UPPER_TEXT;
%endsafe

#define 	NO_INPUT	0
#define 	NORMAL_INPUT	1
#define 	KANJI_INPUT	2
extern IGRshort GRfwd_esc_seq();

from GRtext import GRreplace_text,GRgettxattr, GRchgtextattr;
from DMsrc import DMmodify;


method dynamics(IGRint *msg;
	IGRint control;
	IGRint *level;
	IGRchar *info;
	IGRdouble *matrix;
	struct GRmd_env *md_env;
	IGRdouble cursor[3])
{
	IGRint status,rc;
	IGRint index ,i;
	IGRpoint point2;
	struct IGRline bore_line;
	IGRint num_vertex,last_vtx;
	struct DMdyn_annot *place_attr;
	struct DMplan_info *plan_info;
	IGRdouble *prev_point = NULL, refer_dir[3];
	IGRdouble target_pt[3];
	extern IGRboolean dynamics_in_progress;
	IGRint hilite, flag;
	IGRboolean last_in_cpx;
	struct GRid next[2];
	BSrc	bsrc;

	struct GRid text2_grid;


	place_attr = ( struct DMdyn_annot *)info;
	plan_info = &place_attr->plan_info;

/*** Bloody Kludge to make dynamics look at updated dim_params - For NAVSEA
 *** Will make dynamics routine slightly slow.

	if ((me->dim_state & DIM_NEEDS_UPDATE)
	||  (control & FILL_INFO))
****/
	{
		status=
		om$send(msg = message DMtxbln.fill_info(&rc,
						control,
						level,
						info,
						md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		me->dim_state &=(~DIM_NEEDS_UPDATE);
	}

	num_vertex = om$dimension_of(varray =  me->break_pt)/3;
	last_vtx = 3*(num_vertex -1);

	if(me->leader)
	{
		prev_point = &me->break_pt[ last_vtx - 3];
		if( num_vertex > 2)
		{
			BSmkvec(&bsrc,refer_dir,prev_point,&me->break_pt[last_vtx - 6]);
			BSnorvec(&bsrc,refer_dir);
		}
		else
		{
			vec_equal(place_attr->src_dir,refer_dir);
		}
		/*^
		    print_point("src_dir",refer_dir);
		    print_point("prev point",prev_point);
		*/

	}

	if(me->leader)
	{
		DMinquire_hilite(
			cursor,
			prev_point,
			target_pt,
			NULL,
			refer_dir,
			NULL,
			plan_info,
			&place_attr->win_grid,
			&hilite);

		memcpy(&me->break_pt[last_vtx],target_pt, 3*sizeof(IGRdouble));

 		DMget_direction(
			prev_point,
			target_pt,
			place_attr->plan_info.act_plan.matrix,
			&flag);

		if(flag == AN_BEFORE)
			me->bln_dir = LEFT_SIDE;
		else	me->bln_dir = RIGHT_SIDE;
	}
	else
	{
		hilite = FALSE;
		/* | modify the source point to the cursor*/
		memcpy(&me->break_pt[last_vtx],cursor, 3*sizeof(IGRdouble));

		/*^   print_point("lastvtx",me->break_pt);
		      print_point(" cursor",cursor); */

		bore_line.point1 = cursor;

		for( i = 0;i<3;i++)
			point2[i] = cursor[i] + plan_info->win_plan.matrix[8+i];
			bore_line.point2 = point2;

		status =
		om$send(msg = message DMsrc.DMmodify(
						&rc,
						md_env,
						TRUE,
						TRUE,
						&bore_line),
			p_chanselect  = &ND_father,
			from = AN_ROOT_ELEM1,
			to   = AN_ROOT_ELEM1);
		dm$status(action = RET_STATUS);

		me->bln_dir = RIGHT_SIDE;
	}

	status =
	om$send(msg = message DMroot.return_dim_go(
						&rc,
						DIM_TEXT2,
						FALSE,
						DM_TEXT,
						md_env,
						&text2_grid),
			targetid = my_id);
	dm$status(action = RET_STATUS);

	if(dynamics_in_progress)
	{
		status =
		om$send(msg = message DMannot.make_an_text(
						&rc,
						plan_info,
						&place_attr->par_senv,
						place_attr->go_grid[AN_ANNOT_TEXT],
						md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);

	    if (text2_grid.objid != NULL_OBJID)
		{
		   status =
		     om$send(msg = message DMannot.make_an_text(
		   				&rc,
		   				plan_info,
		   				&place_attr->par_senv,
		   				text2_grid,
		  				md_env),
		       	     targetid = my_id);
		   dm$status(action = RET_STATUS);
		}

		status =
		om$send(msg = message DMannot.update_leader(
						&rc,
						&num_vertex,
						NULL,
						&place_attr->par_senv,
						plan_info,
						md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		status =
		om$send(msg = message DMannot.make_an_term(
						&rc,
						plan_info,
						&place_attr->par_senv,
						place_attr->go_grid[AN_TER_TEXT],
						md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);

	}

	if(me->leader)
	{
		status=
		om$send(msg = message DMroot.position_line_string(
						&rc,
						DIM_NO_INDEX,
						&place_attr->go_grid[AN_POLY_LINE],
						md_env,
						num_vertex,
						me->break_pt),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	if (dynamics_in_progress)
	{
		place_attr->par_senv.dim_weig = (hilite)?2:0;

		status =
		om$send(msg = message DMannot.chg_an_dp(&rc, &place_attr->par_senv),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	if (!dynamics_in_progress)
	{
		/*|- clear the break pts*/

		status =
		om$vla_set_dimension(varray = me->break_pt, size = 0);
		dm$status(action = RET_STATUS);
	}

	status =
	om$send(msg = message DMroot.give_next(&rc, &last_in_cpx, next),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if (!last_in_cpx)
	{
		struct GRid c_list[10], my_grid;
		IGRint c_count;

		/*| - send compute to children */

		my_grid.objid = my_id;
		my_grid.osnum = OM_Gw_current_OS;
		c_count = 0;

		status =
		DMget_graph(
			my_grid,
			CHILDREN,
			10,
			c_list,
			&c_count);
		dm$status(action = RET_STATUS);

		for(index=0; index<c_count; index++)
		{
			status=
			om$send(msg = message NDnode.NDs_compute_node(
							(IGRlong *) msg,
							NULL,
							md_env),
				targetid = c_list[index].objid,
				targetos = c_list[index].osnum);
			dm$status(action = RET_STATUS);
		}
	}

	return(OM_S_SUCCESS);
}
method txdynamics(IGRlong *msg;
	IGRint control;
	IGRint info_flag;
	IGRint *level;
	IGRchar *info;
	struct EX_button *cursor;
	IGRuchar *character;
	IGRint numbytes;
	IGRdouble *rot_matrix;
	struct GRmd_env *md_env)
{
	IGRint status;


	*msg = OM_S_SUCCESS;

	if( info_flag & PNT_MOVED)
	{
		status=
		om$send(msg =message DMroot.dynamics((IGRint *)msg,
					control,
					level,
					info,
					rot_matrix,
					md_env,
					(IGRdouble *)cursor),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}
	else if(info_flag & TEXT_ENTERED)
	{

		status=
		om$send(msg = message DMtxbln.ANadd_text_to_buff(
					info,
					cursor->objid,
					control,
					md_env,
					(IGRdouble *)cursor,
					rot_matrix,
					(char *)character,
					numbytes),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}
	return(OM_S_SUCCESS);
}

method ANadd_text_to_buff(
	char *info;
	OM_S_OBJID pnt_objid;
	int control;
	struct GRmd_env *md_env;
	IGRdouble *pnt;
	IGRdouble *rot_matrix;
	char *string;
	int num_bytes)
{
	struct DMdyn_annot  *place_attr; /* buffer for annot structure */
	IGRint pos_end;
	IGRshort *loc_text_length, *loc_text_index;
	IGRuchar *loc_text_string;
	struct GRid active_grid, text_grid, first_grid;

	/* - local variables */

	IGRint status, rc;
	IGRlong long_rc;
	IGRint char_count, display_count = 0;
	IGRshort start_index, num_chars, true, initialise;
	IGRboolean first_in_cpx, last_in_cpx,inp_type;
	IGRshort num_disp_char,test_length,tmp_len;
	IGRuint attr_num;
	OM_S_OBJID md_id_save;
	struct GRdpb_text_symb text_symb;
	struct GRid prev, next[2], my_grid, g_list[10];
	IGRchar *LocStr,tmp_string[80],test_string[80];
	struct vfont_entry font_info;

	struct GRid text2_grid;
	struct DMsenv_param par_senv;


	status =
        om$send(msg = message DMannot.get_active_senv(&par_senv),
                targetid = my_id);
        dm$status(action = RET_STATUS);

	if (par_senv.bln_type > (SPLIT_BLN_INDEX - 1))
    {
        status = om$send(msg = message DMroot.return_dim_go(
                            &rc,
                            DIM_TEXT2,
                            TRUE,
                            DM_TEXT,
                            md_env,
                            &text2_grid),
                        targetid = my_id);
        dm$status(action = RET_STATUS);

		status = om$send(msg = message DMannot.set_text_attr(
                                             &rc,
                                             text2_grid,
                                             md_env),
                         targetid = my_id);
        dm$status(action = RET_STATUS);
    }

	place_attr = (struct DMdyn_annot *)info;

	initialise = FALSE;

	status =
	om$send(msg = message DMtxbln.get_active_balloon(
						&rc,
						&active_grid),
		targetid = my_id);
	dm$status(action = RET_STATUS);


	/*^ print_grid("active_grid", &active_grid); */

	if (active_grid.objid != my_id)
	{
		status=
		om$send(msg = OPPmargs,
			targetid = active_grid.objid,
			targetos = active_grid.osnum);
		dm$status(action = RET_STATUS);

		return(OM_S_SUCCESS);
	}

	loc_text_length = &place_attr->text_length;
	loc_text_string = place_attr->text_string;
	loc_text_index  = &place_attr->gtattr.disp_char_index;

	/*^
		printf("win objid:%d\n",pnt_objid);
		for( index = 0; index <num_bytes;index++)
		printf("%d\t0x%x\n",string[index],string[index]);
		printf("text  length:%d\n",*loc_text_length);
		printf("display char:%d\n",*loc_text_index);
	*/

	if (split == UPPER_TEXT)
	{
	status =
	om$send(msg = message DMroot.return_dim_go(
						&rc,
						DIM_TEXT,
						FALSE,
						DM_TEXT,
						md_env,
						&text_grid),
			targetid = my_id);
	dm$status(action = RET_STATUS);
	}
	else
	{
	  	status =
          		om$send(msg = message DMroot.return_dim_go(
                     			&rc,
                    			DIM_TEXT2,
                     			FALSE,
                     			DM_TEXT,
                     			md_env,
                     			&text_grid),
           	  			targetid = my_id);
       	dm$status(action = RET_STATUS);
	}
	true = TRUE;
	start_index = 0;

	GRfwd_esc_seq(
		&long_rc,
		loc_text_string,
		loc_text_length,
		&true,
		&start_index,
		&num_chars);

	DMisinput_kanji(&loc_text_string[num_chars],
			(*loc_text_length - num_chars),
			&inp_type);

	/*
	 *  Fix for 119311178 - Alt mode chars are set to normal type here
	 */
	if ((inp_type == KANJI_INPUT) ||  (inp_type == NO_INPUT))
	{
         	status = font$get_info(
				msg = &long_rc,
				font_num = &place_attr->par_misc.sixteen_bit_font,
				font_info = &font_info);
		dm$status(action = RET_STATUS);

		if(!(font_info.flags & SIXTEEN_BIT))
			inp_type = NORMAL_INPUT;
 	}

	/*^
		printf("index=%d, length=%d, num_chars=%d\n",
		*loc_text_index, *loc_text_length, num_chars);
	*/

	if (me->dim_state & DIM_IN_EDIT)
	{
		if (*loc_text_index < num_chars)
			*loc_text_index = num_chars;
		if (*loc_text_index > *loc_text_length)
			*loc_text_index = *loc_text_length;
	}

	char_count = 0;

	while(char_count < num_bytes)
	{
	   if(string[char_count] == DEL)
	   {
		if ((num_chars + 1) > *loc_text_length)
		{
			if(me->dim_state & DIM_IN_EDIT)
			{
				*loc_text_length = num_chars;
				*loc_text_index = num_chars ;
				return(OM_S_SUCCESS);
			}
			if (split == LOWER_TEXT)
			{
				split = UPPER_TEXT;

                status =
                    om$send(msg = message DMroot.return_dim_go(
                                &rc,
                                DIM_TEXT,
                                FALSE,
                                DM_TEXT,
                                md_env,
                                &text_grid),
                            targetid = my_id);
                dm$status(action = RET_STATUS);
                if (text_grid.objid != NULL_OBJID)
                {
 					status =
                        om$send(msg = message DMtxbln.initialise_text(
                                            &rc,
                                            md_env,
                                            place_attr),
                                targetid = active_grid.objid,
                                targetos = active_grid.osnum);
                        dm$status(action = RET_STATUS);
				}
			}
			else
			{
			status =
			om$send(msg = message DMroot.give_previous(&rc,
								&first_in_cpx,
								&prev),
					targetid = my_id);
			dm$status(action = RET_STATUS);

			if(!first_in_cpx)
			{
				status =
				om$send(msg = message DMroot.give_next(&rc,
								&last_in_cpx,
								next),
					targetid = my_id);
				dm$status(action = RET_STATUS);

				if(last_in_cpx)
					active_grid = prev;
				else	active_grid = next[0];

				status =
				om$send(msg = message DMroot.set_dim_state(BIT_OR, DIM_IN_PLACEMENT),
					targetid = active_grid.objid,
					targetos = active_grid.osnum);
				dm$status(action = RET_STATUS);

				if (par_senv.bln_type > (SPLIT_BLN_INDEX - 1))
					split = LOWER_TEXT;
				else
					split = UPPER_TEXT;

				status =
				om$send(msg = message DMtxbln.initialise_text(
								&rc,
								md_env,
								place_attr),
					targetid = active_grid.objid,
					targetos = active_grid.osnum);
				dm$status(action = RET_STATUS);

				my_grid.objid = my_id;
				my_grid.osnum = OM_Gw_current_OS;

				status =
				DMdelete_dimension(&rc, TRUE, md_env, &my_grid);
				dm$status(action = RET_STATUS);

				return(OM_S_SUCCESS);
			}
			}
			char_count++;
			continue;
		}

		if((*loc_text_index - num_chars) > 0)
		{
			*loc_text_index -= ((inp_type == KANJI_INPUT) ? 2:1);

			DMdelete_text(
				loc_text_string,
				loc_text_length,
				*loc_text_index,
				(inp_type == KANJI_INPUT ? 2:1));

			status =
			om$send(msg = message DMannot.get_active_senv(
						&place_attr->par_senv),
					targetid = my_id);
			dm$status(action = RET_STATUS);

			if(inp_type == KANJI_INPUT)
				num_disp_char = (*loc_text_length - num_chars)/2;
			else	num_disp_char = *loc_text_length - num_chars;

			if (num_disp_char <= 0)
			{
				*loc_text_length = num_chars;
				*loc_text_index = num_chars;
			}

			/*^ printf("nim_disp_char = %d\n",num_disp_char); */

			status = DMget_bln_txt_width(
					FALSE,
					&num_disp_char,
					&place_attr->par_senv,
					text_grid,
					md_env);
		}
	   }
	   else
	   {

		if(string[char_count] == EX_LEFT_ARROW)
		{
		    if(*loc_text_index > num_chars)
			--(*loc_text_index);
		}
		else if(string[char_count] == EX_RIGHT_ARROW)
		{
		    if (*loc_text_index < *loc_text_length)
			++(*loc_text_index);
		}
		else if ((string[char_count] > 0x1b) &&
				  (string[char_count] < 0x7f))
		{
			if(inp_type == KANJI_INPUT)
			{
                                ex$message(msgnumb = DM_I_InputKanji);
				break;
			}
			if((*loc_text_length - num_chars) < (int)place_attr->par_senv.bln_size)
			{
				if(*loc_text_index < num_chars)
					*loc_text_index = num_chars;
				DMinsert_text(
					loc_text_string,
					&string[char_count],
					*loc_text_index,
					1,
					loc_text_length);

				++(*loc_text_index);

				num_disp_char = *loc_text_length - num_chars;

				/*^ printf("nim_disp_char = %d\n",num_disp_char); */

				status = DMget_bln_txt_width(
						FALSE,
						&num_disp_char,
						&place_attr->par_senv,
						text_grid,
						md_env);
			}
			else	break;
		}
		else if (string[char_count] & 0x80)
		{
			DMget_exact_str(loc_text_string,
					*loc_text_length,
					test_string,
					&test_length);

			if(((test_length/2  < (int)place_attr->par_senv.bln_size) &&
			((inp_type == NO_INPUT) || (inp_type == KANJI_INPUT))) ||
				/*
				 * this is for Kanji input
				 */
			((test_length  < (int)place_attr->par_senv.bln_size) &&
			(inp_type == NORMAL_INPUT)))
				/*
				 * this is for ALT mode characters
			 	 */
			{
				LocStr = tmp_string;
				tmp_len = 0;
				if(inp_type == NO_INPUT)
				{
					/*| This is first char entered */
					change_font(LocStr,
						    place_attr->par_misc.sixteen_bit_font,
						    tmp_len);
					*LocStr++ = string[char_count++];
					*LocStr++ = string[char_count];
					tmp_len = 2;
					inp_type = KANJI_INPUT;
				}
				else if (inp_type == KANJI_INPUT)
				{
					*LocStr++ = string[char_count++];
					*LocStr++ = string[char_count];
					tmp_len = 2;
				}
				else
				{
					*LocStr++ = string[char_count++];
					tmp_len = 1;
				}

				DMinsert_text(
					loc_text_string,
					tmp_string,
					*loc_text_index,
					tmp_len,
					loc_text_length);

				(*loc_text_index)+=tmp_len;
/*
				num_disp_char = *loc_text_length - num_chars;
*/
				DMget_exact_str(loc_text_string,
						*loc_text_length,
						test_string,
						&test_length);

				test_length /=2;
				/*^ printf("num_disp_char = %d\n",test_length); */

				status = DMget_bln_txt_width(
						FALSE,
						&test_length,
						&place_attr->par_senv,
						text_grid,
						md_env);
			}
		}
		else if (string[char_count] == 0x9)
		{
			if(split == UPPER_TEXT && par_senv.bln_type > (SPLIT_BLN_INDEX -1))
            {
                split = LOWER_TEXT;
                status =
                    om$send(msg = message DMroot.return_dim_go(
                                &rc,
                                DIM_TEXT2,
                                FALSE,
                                DM_TEXT,
                                md_env,
                                &text2_grid),
                            targetid = my_id);
                dm$status(action = RET_STATUS);
                if (text2_grid.objid != NULL_OBJID)
                {
                     status =
                        om$send(msg = message DMtxbln.initialise_text(
                                            &rc,
                                            md_env,
                                            place_attr),
                                targetid = active_grid.objid,
                                targetos = active_grid.osnum);
                        dm$status(action = RET_STATUS);

                    text_grid.objid = text2_grid.objid;
                    text_grid.osnum = text2_grid.osnum;
                }
            }
			else
			{
			if(split == LOWER_TEXT && par_senv.bln_type > (SPLIT_BLN_INDEX-1))
            {
                split = UPPER_TEXT;
                status =
                    om$send(msg = message DMroot.return_dim_go(
                                &rc,
                                DIM_TEXT,
                                FALSE,
                                DM_TEXT,
                                md_env,
                                &text2_grid),
                            targetid = my_id);
                dm$status(action = RET_STATUS);
                if (text2_grid.objid != NULL_OBJID)
                {
                     status =
                        om$send(msg = message DMtxbln.initialise_text(
                                            &rc,
                                            md_env,
                                            place_attr),
                                targetid = active_grid.objid,
                                targetos = active_grid.osnum);
                        dm$status(action = RET_STATUS);

                    text_grid.objid = text2_grid.objid;
                    text_grid.osnum = text2_grid.osnum;
                }
            }
			}
		}
		else if( string[char_count] == 0xd )
		{
		    if(me->dim_state & DIM_IN_EDIT)
		    {
				*loc_text_index = num_chars;
				return(OM_S_SUCCESS);
		    }

        status = om$send( msg = message  DMroot.get_first_in_cpx(
                        &rc,&first_grid),
            targetid = my_id);
                dm$status(action = RET_STATUS);

        status =
                DMget_graph( first_grid,
                        CHILDREN|DIMENSIONS_ONLY,
                        10,
                        g_list,
                        &display_count);
                dm$status(action = RET_STATUS);

		    if(display_count < 9)
		    {
			status =
			om$send(msg = message DMtxbln.stack_balloon(
								&rc,
								&active_grid,
								md_env),
					targetid = my_id);
			dm$status(action = RET_STATUS);

			split = UPPER_TEXT;

			initialise = TRUE;
		    }
		    else
		    {
			printf("No. of balloon exceeds stack size\n");
		    }
		    break;
		}
	    }
	    char_count++;
	}

	text_symb.Active_width = place_attr->par_senv.txt_widt;
	attr_num = GRTEXT_WIDTH;

	md_id_save = md_env->md_id.objid;
	md_env->md_id.objid = NULL_OBJID;

	status =
	om$send(msg = message GRtext.GRchgtextattr(
					&long_rc,
					md_env,
					attr_num,
					&text_symb),
		targetid = text_grid.objid,
		targetos = text_grid.osnum);
	dm$status(action = RET_STATUS);

	md_env->md_id.objid = md_id_save;

	status=
	om$send( msg = message GRtext.GRreplace_text( &long_rc,
						md_env,
						*loc_text_length,
						(IGRuchar *)loc_text_string),
			targetid = text_grid.objid,
			targetos = text_grid.osnum);
	dm$status(action = RET_STATUS);

	/*^
		printf("index=%d, length=%d, num_chars=%d\n",
		*loc_text_index, *loc_text_length, num_chars);
	*/

	if (me->dim_state & DIM_IN_EDIT)
	{
		pos_end = *loc_text_length - *loc_text_index;

		status=
		om$send(msg = message GRtext.GRgettxattr(&long_rc,
						  NULL,
						  loc_text_length,
						  NULL),
			targetid = text_grid.objid,
			targetos = text_grid.osnum);
		dm$status(action = RET_STATUS);

		*loc_text_index = *loc_text_length - pos_end;
	}

	/*^
		printf("index=%d, length=%d, num_chars=%d\n\n\n",
		*loc_text_index, *loc_text_length, num_chars);
	*/

	if(initialise)
	{
		me->dim_state &= ~DIM_IN_PLACEMENT;

		status =
		om$send(msg = message DMroot.set_dim_state(BIT_OR, DIM_IN_PLACEMENT),
			targetid = active_grid.objid,
			targetos = active_grid.osnum);
		dm$status(action = RET_STATUS);

		status =
		om$send(msg = message DMtxbln.initialise_text(
							&rc,
							md_env,
							place_attr),
				targetid = active_grid.objid,
				targetos = active_grid.osnum);
		dm$status(action = RET_STATUS);

		/*^ print_grid("active_grid",&active_grid); */
	}

	/*^
		analyse_string(loc_text_string,*loc_text_length);
		printf("length:%ld\n",*loc_text_length);
		printf("loc_text_index = %d\n",*loc_text_index);
	*/

	return(OM_S_SUCCESS);
}
method initialise_text(
	IGRint *msg;
	struct GRmd_env *md_env;
	struct DMdyn_annot *place_attr)
{
	IGRint status, rc;
	IGRlong long_rc;
	IGRuchar *text_string;
	struct GRid text_grid;
    struct DMsenv_param par_senv;


    status =
        om$send(msg = message DMannot.get_active_senv(&par_senv),
                targetid = my_id);
    dm$status(action = RET_STATUS);

	if (split == UPPER_TEXT)
	{
	status =
	om$send(msg = message DMroot.return_dim_go(
						&rc,
						DIM_TEXT,
						FALSE,
						DM_TEXT,
						md_env,
						&text_grid),
			targetid = my_id);
	dm$status(action = RET_STATUS);
	}
	else
	{
	  status =
	    om$send(msg = message DMroot.return_dim_go(
	  					&rc,
	   					DIM_TEXT2,
	   					FALSE,
	   					DM_TEXT,
	   					md_env,
	   					&text_grid),
	       		targetid = my_id);
	  dm$status(action = RET_STATUS);
	}

	text_string = NULL;

	status =
	om$send(msg = message GRtext.GRgettxattr(
					&long_rc,
					NULL,
					&place_attr->text_length,
					&text_string),
		targetid = text_grid.objid,
		targetos = text_grid.osnum);
	dm$status(action = RET_STATUS);

	place_attr->gtattr.disp_char_index = place_attr->text_length;

	memcpy(place_attr->text_string, text_string, place_attr->text_length);

	if(text_string) free(text_string);

	*msg = OM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

#argsused
IGRint DMget_bln_txt_width (flag,txt_length,par_senv,text_grid,md_env)
	 IGRboolean  flag;
	 IGRshort  *txt_length;
	 struct DMsenv_param  *par_senv;
	 struct GRid  text_grid;
	 struct GRmd_env  *md_env;
{
	IGRint status;
	IGRshort text_length, test_length;
	IGRlong long_rc;
	IGRuchar *text_string,test_str[80];
	IGRdouble str_limit, str_width;
	IGRboolean inp_type;

	if(flag)
	{
		text_string = NULL;

		status =
		om$send(msg = message GRtext.GRgettxattr(
						&long_rc,
						NULL,
						&text_length,
						&text_string),
			senderid = NULL_OBJID,
			targetid = text_grid.objid,
			targetos = text_grid.osnum);
		dm$status(action = RET_STATUS);

		DMget_exact_str(text_string,
				text_length,
				test_str,
				&test_length);

		DMisinput_kanji(test_str,test_length,&inp_type);

		if(text_string) free(text_string);

		if(inp_type == KANJI_INPUT)
			text_length = test_length/2;
		else
			text_length = test_length;
	}
	else
	{
		/*^ printf("txt_length = %d\n",*txt_length); */
		text_length = *txt_length;
	}

	str_limit = (par_senv->bln_size - 1) * par_senv->txt_heig;
	str_width = text_length * par_senv->txt_widt;

	if(str_width > str_limit)
	{
		par_senv->txt_widt = str_limit / text_length;
	}

	/*^
		printf("str_limit = %f\n",str_limit);
		printf("str_width = %f\n",str_width);
		printf("txt_width = %f\n",par_senv->txt_widt);
		printf("text_length = %d\n",text_length);
	*/

	return(OM_S_SUCCESS);
}

DMisinput_kanji (string,length,inp_type)
	 char  *string;
	 short  length;
	 IGRboolean  *inp_type;
{
	int i;
	i = 0;
	*inp_type = NO_INPUT;

	while(i< length)
	{
		if(string[i] & 0x80)
		{
			*inp_type = KANJI_INPUT;
			break;
		}
		else if(string[i] == ESC &&
			string[i+1] == 'f')
		{
			i+=4;
		}
		else
		{
			*inp_type = NORMAL_INPUT;
			break;
		}
	}
	return(TRUE);
}

DMget_exact_str (string,length,test_str,test_len)
	 char  *string;
	 short  length;
	 char  *test_str;
	 short  *test_len;
{
	IGRlong long_rc;
	IGRboolean multi_mode;
	IGRshort start_index,num_chars;
	multi_mode = TRUE;
	start_index = 0;

	GRfwd_esc_seq(&long_rc,string,&length,&multi_mode,
		      &start_index,&num_chars);
	memcpy(test_str,&string[num_chars],(length - num_chars));
	*test_len = length - num_chars;

	return(TRUE);
}

end implementation DMtxbln;
