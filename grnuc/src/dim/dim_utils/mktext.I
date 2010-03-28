/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:39:32 $
$Locker:  $
$Log: mktext.I,v $
Revision 1.1.1.1  2001/12/17 22:39:32  hans
Initial import to CVS

# Revision 340.0  1997/05/27  23:09:56  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.0  1996/01/11  21:24:04  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.2  1995/01/05  04:54:36  sudha
# COMMENT : for SGI compiler error
#
# Revision 320.1  1994/12/27  11:53:23  sudha
# COMMENT : Purify fixes
#
# Revision 240.5  1993/11/02  14:23:35  samuel
# COMMENT : Fix for TR 119311177 - Alt mode chars are accepted
#
# Revision 240.4  1993/08/03  14:13:46  samuel
# COMMENT : Fix for TR 119300474.
#
# Revision 240.3  1993/06/07  11:02:28  gvk
# COMMENT : TR# 11910377 - Added a space after sep in dual mode - June 7,'93
#
# Revision 220.2  1992/12/18  22:07:10  gvk
# COMMENT : Message Sub System Changes
#
# Revision 220.1  1992/09/09  14:15:47  scott
# COMMENT : ANSI/SGI fixes
#
# Revision 220.0  1992/08/29  06:28:07  root
# COMMENT : Corresponds to Rel201.2 in 2.0.1 RCS
#
# Revision 201.2  1992/08/14  07:22:29  gvk
# COMMENT : Does not initialize the action variable
#
# Revision 201.1  1992/07/31  18:45:44  poo
# COMMENT :
#
# Revision 201.0  1992/07/19  15:33:20  gvk
# COMMENT : ANSI compilation and deleting obsolete functions.
#
Revision 201.11  1992/01/22  07:35:04  dimdp20
COMMENT : Dimension Fixes Release - S. Poovannan - Jan. 22 1992.

*/

class implementation DMannot;

#include "gotextdef.h"
#include "exdef.h"
#include "dpdef.h"
#include "dimfont.h"
#include "fielddef.h"
#include "grmsg.h"
#include "msdef.h"
#include "msmacros.h"

#include "DMcmd.h"
#include "DMmsg.h"


#define AS_DEBUG	1

/*----------- action for text update --------------------------

 NO_ACTION	0x0000 ...............Annotation requires no changes.
 COMPUTE_DIM	0x0001 ...............Complete update is required.
 PARTIAL_UPDATE	0x0002 ...............Part of Text String modified.
 UPDATE_BOX	0x0004 ...............GT,Datums Needs to update Lines.
 INS_LF		0x0008 ...............Text with leader, New line.
 INS_CHAR	0x0010 ...............Single char added.
 DEL_LF		0x0020 ...............Deleted Line Feed. Modify Esc'sq.
 DEL_CHAR	0x0040 ...............Single char delete.

 BLN_CREATE		0x0100 .......<CR> Add a new Balloon.
 BLN_DELETE		0x0200 .......Deleted Last char in a Balloon.
 BLN_ADJ_TXT_WIDT	0x0400 .......Numchars more than bln-width.
 BLN_TXT_SIZE_ERR	0x0800 .......String too long for text height.

-----------------------------------------------------------------*/

#define ASCII_CHAR     0x1c
#define FRACTION_SYMBOL 16
#define WHITE_SPACE_COMPENSATION 0.331366

extern GRfwd_esc_seq();
extern double fabs();

DMmake_annot_text(
	text_string,
	text_length,
	text_buff_size,
	estx,
	symb_type,
	character,
	numbytes,
	gtattr,
	tole_mode,
	type,
	sixteen_font,
	current_index,
	action,
	bln_limit)
IGRuchar *text_string;		/* Buffer to append or delete chars.*/
IGRshort *text_length;		/* Length of current text string.*/
IGRshort *text_buff_size;	/* Allocated buffer size */
struct IGRestx  *estx;		/* Text attributes, font, height ...*/
IGRboolean	symb_type;	/* Type of input normal char or sp symbol */
IGRchar		*character;	/* String to add/delete*/
IGRint		numbytes;	/* Size of the above string*/
struct GTattr	*gtattr;	/* structures to store the type of symbols*/
IGRboolean	tole_mode;	/* Type of geometric tolerance symbol */
IGRint		type;		/* Annotation type */
IGRshort 	sixteen_font,	/* Current text font */ 
		*current_index;	/* Index at characters are added/deleted */
IGRint		*action;	/* Modification type for above operations */
IGRint 		bln_limit;	/* Max. number of chars for current balloon*/

/*.DMmake_annot_text*/
{
	IGRint status,rc;
	IGRboolean insert_mode;
	IGRint index,t_index;
	IGRlong long_rc;
	IGRuchar loc_string[128] , *StrPtr;
	IGRshort NumBytes ,BytestoDel, disp_char_del;
	struct vfont_entry loc_font_info;
	IGRchar symbol_char;
	struct DMenv_param env_param;


	/*^
		printf("chars :%d\n",numbytes);
		printf("text length:%ld\n",*text_length);
		printf("active_font:%d\n",gtattr->active_font);
	*/

        *action = NO_ACTION;
        *current_index = 0;
	symbol_char = '\0';

	loc_font_info.flags = 0;

	status =
	DMcheck_buff_size(text_string,text_length,text_buff_size);
	dm$status(action = RET_STATUS);

	for( index = 0; index < numbytes; index++)
	{
		StrPtr = loc_string;
		NumBytes = BytestoDel = 0;
		insert_mode = TRUE;

                DMset_display_index(gtattr, &insert_mode, 
				    character[index]);
		
		status =	
		DMcheck_buff_size(
			text_string,
			text_length,
			text_buff_size);
		dm$status(action = RET_STATUS);


	switch(symb_type)
	{
	case TOL_MODE:

	if(type == DATUM_FRAME)  return(OM_S_SUCCESS);

	DMchange_text_mode(
		text_string,
		text_length,
		text_buff_size,
		gtattr,
		estx,
		tole_mode,
		type);
		
	*action |= COMPUTE_DIM;
	break;

	case TOL_SYMBOL:

	DMreplace_tol_sym(
		text_string,
		text_length,
		character,
		tole_mode,
		estx,
		gtattr);

	*action |= UPDATE_BOX;
	break;

	case SEPERATOR:

	gtattr->prev_disp_char = SEPERATOR;

	DMadd_seperator(StrPtr,&NumBytes,gtattr);

	DMadd_annot_char(
		text_string,
		text_length,
		loc_string,
		NumBytes,
		gtattr,
		type,
		current_index);

	*action |= UPDATE_BOX;
	break;

	case GEOM_SYMBOL:

	gtattr->prev_disp_char = GEOM_SYMBOL;

	DMadd_symbol_char( StrPtr, &NumBytes, 
			   *character, estx->height,
			   estx->width, gtattr);

	DMadd_annot_char(
		text_string,
                text_length,
                loc_string,
                NumBytes,
                gtattr,
                type,
                current_index);
	*action |= UPDATE_BOX;
	break;

	case AN_CHANGE_FONT:
	/* Check for end of string*/

	gtattr->prev_disp_char = AN_CHANGE_FONT;

	change_font(StrPtr,gtattr->active_font,NumBytes);

	DMadd_annot_char(
		text_string,
                text_length,
                loc_string,
                NumBytes,
                gtattr,
                type,
                current_index);
	break;
	case AN_16BIT_CHAR:
	case AN_NORMAL:

        if (gtattr->fraction_flag
	||  character[index] == FRACTION_KEY)
        {
              DMmake_frac(
			gtattr,
			character[index],
			text_string,
			text_length,
			type,
			current_index);

		if (gtattr->fraction_flag)
			break;
		else	*action |= PARTIAL_UPDATE;
	}

	if(character[index] & 0x80)
	{
		/*| 16BIT INPUT  */

		if(!index)
		{
			status =
			font$get_info(
				msg = &long_rc,
	          		font_num = &sixteen_font,
				font_info = &loc_font_info);
			dm$status(action = RET_STATUS);
		}

		if ((gtattr->disp_char[gtattr->disp_char_index-1] != AN_16BIT_CHAR) &&
			(loc_font_info.flags & SIXTEEN_BIT))
		{
			gtattr->prev_disp_char = AN_CHANGE_FONT;

			change_font(StrPtr,sixteen_font,NumBytes);

			DMadd_annot_char(
				text_string,
               			text_length,
                                loc_string,
                                NumBytes,
                                gtattr,
                                type,
                                current_index);
		}
		
		StrPtr = loc_string;
		
		if (!(loc_font_info.flags & SIXTEEN_BIT))
		{
		/*	ex$message(msgnumb = DM_I_ActiveFontNotKanji); */
	               	gtattr->prev_disp_char = AN_NORMAL;
 		 	memcpy(StrPtr,&character[index],1);
			NumBytes = 1;
		}
		else
		{
                	gtattr->prev_disp_char = AN_16BIT_CHAR;
			memcpy(StrPtr,&character[index],2);
			index ++;
			NumBytes = 2;
		}
		
		DMadd_annot_char(
			text_string,
                        text_length,
                        loc_string,
                        NumBytes,
                        gtattr,
                        type,
                        current_index);

		if (loc_font_info.flags & SIXTEEN_BIT)
		{
			DMadd_change_font(
				gtattr,
                        	&t_index,
				text_string,
				text_length,
				type,
				current_index);
		}
		*action |= PARTIAL_UPDATE;
		break;
	}

	gtattr->prev_disp_char = AN_NORMAL;

	if ((character[index] == 0xa)
	||  (character[index] == 0xd))
	{


		if(type == FEATURE_CONTROL_FRAME)
		{
			if (tole_mode == DUAL_MODE_OFF 
			&& gtattr->disp_char[gtattr->disp_char_index-1] == SEPERATOR
			&& gtattr->disp_char_index >= (gtattr->num_disp_char-1))
			{
				*action |= SET_DUAL_MODE;
				DMchange_text_mode(
					text_string,
					text_length,
					text_buff_size,
					gtattr,
					estx,
					DUAL_MODE_ON,
					type);

				*action |= COMPUTE_DIM;
				continue;
			}
			else
			{
				/*|- Add Block Seperator  */
				gtattr->prev_disp_char = SEPERATOR;
				gtattr->active_font = 0;

				DMadd_seperator( StrPtr, 
						&NumBytes, gtattr);
			}
		}	   	
		else if(type == DATUM_FRAME)
		{
			gtattr->prev_disp_char = SEPERATOR;
			gtattr->active_font = 0;

			DMadd_seperator( StrPtr, &NumBytes, gtattr);
		}
		else if (type == TEXT_WITH_BALLOON)
		{
			*action |= BLN_CREATE;
			break;
		}		
		else
		{
			*action |= INS_LF;
			gtattr->prev_disp_char = LINE_FEED;

			DMadd_line_feed( StrPtr, &NumBytes);
		}

		DMadd_annot_char(
			text_string,
                        text_length,
                        loc_string,
                        NumBytes,
                        gtattr,
                        type,
                        current_index);


		*action |= UPDATE_BOX;
	}
	else if( character[index] == EX_LEFT_ARROW )
	{
		/*|- get previous valid index */
					
		DMget_possible_posn(gtattr,AN_BEFORE);
	}
	else if( character[index] == EX_RIGHT_ARROW )
	{
		/*|- get next valid index */

		DMget_possible_posn(gtattr,AN_AFTER);
	}
	else if( character[index] == DEL)
	{
		if (gtattr->fraction_flag) 
                {
                        if (gtattr->substr_len) 
                        {
                               gtattr->substr_len--;
                               gtattr->substring[gtattr->substr_len] = 0;
                        }
                        else 
                        {
                                gtattr->fraction_flag = FALSE;
                        }
		}

		DMcompute_bytes_to_del(
				&rc,
				text_string,
				text_length,
				gtattr,
				current_index,
				&BytestoDel,
				&disp_char_del,
				action,
				type);

		/*"Bytes to del:%ld\n",BytestoDel*/
		/*"disp char del:%ld\n",disp_char_del*/

						
		if (BytestoDel == 0)  
			*action |= BLN_DELETE;

		if (insert_mode)
		{
			int i;
			*current_index -= BytestoDel;
				
			DMdelete_text(
				text_string,
				text_length,
				*current_index,
				BytestoDel);

			gtattr->num_disp_char -= disp_char_del;

	 		for( i = gtattr->disp_char_index;
	 			     i< gtattr->num_disp_char ; i++)
				gtattr->disp_char[i] = 
				gtattr->disp_char[i+disp_char_del];

			*action |= BLN_ADJ_TXT_WIDT;
		}
		else
		{
			*text_length -= BytestoDel;
			gtattr->num_disp_char -= disp_char_del;
		}


		*action |= PARTIAL_UPDATE;

		if ((*action) & SET_SINGLE_MODE
			&&  type == FEATURE_CONTROL_FRAME)
		{
			DMchange_text_mode(
				text_string,
				text_length,
				text_buff_size,
				gtattr,
				estx,
				DUAL_MODE_OFF,
				type);

			return(TRUE);
		}
	}
	else if((character[index] >0x1b)
	&& (character[index] <0x7f))
	{
		gtattr->prev_disp_char = AN_NORMAL;

		/*| check for keyboard equivalents */

		if( type == FEATURE_CONTROL_FRAME)
		{
			if (character[index] == 'd')
			{
				gtattr->prev_disp_char = GEOM_SYMBOL;
        			dm$get_dim_param(
                			type = DM_ENV_PARAM,
                			dim_objid = NULL_OBJID,
                			dim_osnum = OM_Gw_current_OS,
                			p_data = (char *) &env_param);

 				if (( env_param.dim_stan == DIM_STAN_ANS ) ||
 					( env_param.dim_stan == DIM_STAN_BSI ))
 				{
 					symbol_char = 'W';
 					gtattr->active_font = gtattr->ter_font;
				}
				else
				{
					OM_S_OBJID mod_id;
					OMuword    mod_os;
					IGRint     status;

					symbol_char = '`';
                                 	status = ex$get_cur_mod(id=&mod_id,osnum=&mod_os);
					if ( status ) 
					gtattr->active_font =  
					DMmap_font ( mod_os, FONT_31);
					else
                               			gtattr->active_font=0; 
				}
			}
			else if(character[index] =='m')
			{
				gtattr->prev_disp_char = GEOM_SYMBOL;
				symbol_char = 'm';
				gtattr->active_font = gtattr->geom_font;
			}
			else if(character[index] =='l')
			{
				gtattr->prev_disp_char = GEOM_SYMBOL;
				symbol_char = 't';
				gtattr->active_font = gtattr->geom_font;
			}
			else if(character[index] =='s')
			{
				gtattr->prev_disp_char = GEOM_SYMBOL;
				symbol_char = 's';
				gtattr->active_font = gtattr->geom_font;
			}
			else if(character[index] =='p')
			{
				gtattr->prev_disp_char = GEOM_SYMBOL;
				symbol_char = 'p';
				gtattr->active_font = gtattr->geom_font;
			}
			else
			{
				StrPtr[0]= character[index];
				NumBytes = 1;
			}

  			*action |= UPDATE_BOX;
		}
		else
		{
			if ((type == TEXT_WITH_BALLOON)
			&&  ((gtattr->disp_char_index+1) > bln_limit))
			{
				*action |= BLN_TXT_SIZE_ERR;
				break;
			}

			StrPtr[0]= character[index];
			NumBytes = 1;
 			*action |= PARTIAL_UPDATE;
		}

		if( gtattr->prev_disp_char == GEOM_SYMBOL)
			DMadd_symbol_char(
				StrPtr,
				&NumBytes,
				symbol_char,
				estx->height,
				estx->width,
				gtattr);

		DMadd_annot_char(
			text_string,
                        text_length,
                        loc_string,
                        NumBytes,
                        gtattr,
                        type,
                        current_index);
		gtattr->active_font = gtattr->text_font;

		*action |= BLN_ADJ_TXT_WIDT;
	}

	break;

	default:

	/*" Unknown symb_type:%d\n",symb_type*/
	break;
	} /* End of switch*/
	} /* End of for */

	return(TRUE);
}

DMadd_annot_char(
	text_string,
        length, 
        Str,
        Bytes,
        gtattr,
        type,
        current_index)
IGRuchar *text_string, *Str;
struct GTattr *gtattr;
IGRshort *length;
IGRint Bytes, type;
IGRshort *current_index;
/*.DMadd_annot_char*/
{
	int i;

	if (!Bytes) return(TRUE);

	*current_index = 0;

	DMcompute_valid_index(
		text_string,
		length,
		current_index,
		gtattr,
		type);

 	/*^
 		printf("currIndex:%d\tBytes :%d\n",*current_index,Bytes);
 		printf("disp index;%ld\n",gtattr->disp_char_index);
 		printf("num char %ld\n",gtattr->num_disp_char);
 	*/

	DMinsert_text(text_string,Str,*current_index,Bytes,length);

 	for (i=gtattr->num_disp_char; i>gtattr->disp_char_index; i--)
	    gtattr->disp_char[i] = gtattr->disp_char[i-1];

	gtattr->disp_char[gtattr->disp_char_index] = gtattr->prev_disp_char;
	gtattr->disp_char_index++;
	gtattr->num_disp_char++;

	return(TRUE);	
}

DMadd_seperator(str, length, gtattr)
IGRuchar *str;
short *length;
struct GTattr *gtattr;
/*.DMadd_seperator*/
{
	double half,twice;
	IGRuchar *txt_str;

	txt_str =&str[*length];
	half = -0.5; twice = 2.0;

	/* Move vertically down by 0.5 */

	vertical_move(txt_str,half,*length);
	Y_scale(txt_str,twice,*length);
	change_font(txt_str,gtattr->active_font,*length);
	*txt_str++ = gtattr->sep_symbol;
	(*length)++;
	change_font(txt_str,gtattr->text_font,*length);
	half = -half;
	Y_scale(txt_str,half,*length);
	vertical_move(txt_str,half,*length);
	return(TRUE);
}

DMadd_line_feed(str, length)
IGRuchar *str;
short *length;
/*.DMadd_line_feed*/
{
	IGRuchar *txt_str;
	
	txt_str = &str[*length];
	
	*txt_str++ = ESC;
	*txt_str++ = '\012';
	*length +=2;
	return(TRUE);
}

DMadd_symbol_char(str,length,symb_char,height,width,gtattr)
IGRuchar *str;
short *length;
char symb_char;
double height,width;
struct GTattr *gtattr;
/*.DMadd_symbol_char*/
{
	double scale;
	IGRuchar *txt_str;

	txt_str = &str[*length];
	scale = height/width;
	/*"scale:%lf\n",scale*/
	if(fabs(scale -1.0) > 1.0e-4)
	{
		X_scale(txt_str,scale,*length);
	}

	change_font(txt_str,gtattr->active_font,*length);
	*txt_str++ = symb_char;
	(*length)++;

	change_font(txt_str,gtattr->text_font,*length);
	if(fabs(scale -1.0) > 1.0e-4)
	{
		scale = 1/scale;
		X_scale(txt_str,scale,*length);
	}
	return(TRUE);
}

DMadd_dual_field(str,length,gtattr)
IGRuchar *str;
short *length;
struct GTattr *gtattr;
/*.DMadd_dual_field*/
{
	int eof_exists;
	double zero = 0;
	double value = -1.5;
	IGRuchar *txt_ptr;
	double white_space = WHITE_SPACE_COMPENSATION;

	/* - Fix to check if end of field exists , if exists  do insert text 
	     to be cleaned up later */

	if(str[*length -2] == ESC && str[*length-1] == 'E')
		eof_exists = TRUE;
	else   eof_exists = FALSE;

	txt_ptr = &str[*length];
	if(!eof_exists)
		end_field(txt_ptr,*length);

	move_to_field(txt_ptr,TOL_FIELD,RIGHT_CENTER,zero,zero,*length);
	vertical_move(txt_ptr,value,*length);
	horizon_move(txt_ptr, white_space, *length);
	gtattr->field_num = TOL_FIELD +2;
	start_field(txt_ptr,gtattr->field_num,0,*length);
/*
	if(eof_exists)
		end_field(txt_ptr,*length);
*/

	return(TRUE);
}

DMreplace_tol_sym(string,text_length,symb_char,tole_mode,estx,gtattr)
IGRuchar *string;
short *text_length;
char symb_char;
IGRboolean tole_mode;
struct IGRestx *estx;
struct GTattr *gtattr;
/*.DMreplace_tol_sym*/
{
	IGRdouble zero = 0.0;
	IGRuchar *txt_ptr;

	/*"dual mode:%d\n",tole_mode*/

	if(!DMis_tol_sym_exists(string,text_length))
	{
		/*| Tol Symbol do not exist*/

		*text_length = 0;
		txt_ptr = string;
		gtattr->tol_symbol = symb_char;
		DMmake_tol_symbol(string,text_length,estx,gtattr,tole_mode);

		gtattr->field_num++;
		if(tole_mode == DUAL_MODE_ON)
		{
			/* active mode is dual mode */
			move_to_field(txt_ptr,TOL_FIELD,RIGHT_TOP,
				      zero,zero,*text_length);
		}
	}
	else
	{
		gtattr->tol_symbol = symb_char;
		DMmake_tol_symbol(string,text_length,estx,gtattr,tole_mode);
	}
	return(TRUE);
}

#argsused
DMchange_text_mode(string,length,buff_size,gtattr,estx,dual_mode,type)
IGRuchar *string;
IGRshort  *length;
IGRshort *buff_size;
struct GTattr *gtattr;
struct IGRestx *estx;
IGRboolean dual_mode;
IGRint type;
/*.DMchange_text_mode*/
{
	IGRshort num_chars,loc_length;
	IGRshort index,just;
	IGRdouble zero,half;
	char field_pos[256],LocStr[128],*loc_str;
	int field_no,active_field;
	int move_type;
	enum {
		moveinV,moveinY,moveinX,
		moveinM,Fieldbegin,Fieldend,
		moveinH	};
	double white_space = WHITE_SPACE_COMPENSATION;

	index = active_field = just = move_type = 0;
	zero = 0.0; half = -0.5;
	loc_length = num_chars = 0;
	loc_str = LocStr;
	field_no = 0;
	/*"active mode:%ld\tlength :%d\n",dual_mode,*length*/

	DMmake_tol_symbol(string,length,estx,gtattr,dual_mode);

	index = 0;
	if(*length)
	{
		while(!(string[index] == ESC && string[index +1] == 'E'))
			index++;
		index+=2;  /* skip the end field */
	}

	while( index < *length)
	{
		if( string[index] != ESC)
		{
			/* check for 16bit font*/

			index++;
			continue;
		}
		switch(string[index+1])
		{
		case 'H':
		case 'J':
		case 'j':
			index += 10;
			break;
		case 'y':
			index += 10;
			break;
		case 'v':
			index+= 10;
			break;
		case 's':
			index+= 10;
			break;
		case 'x':
			move_type = moveinX;
			index +=10;
			break;
		case 'h':
			index += 10 ;
			break;
		case 'w':
			index += 3 ;
			break;
		case 'E':
			active_field--;
			field_no = field_pos[active_field];
			index+=2;
			break;
		case 'F':
			field_no =
			field_pos[active_field] = string[index+2];
			/*"field no:%d\n",field_pos[active_field]*/
			index+=4;
			if(field_pos[active_field] == TOL_FIELD +1)
				just = RIGHT_CENTER;
			else if(field_pos[active_field] == TOL_FIELD+2)
				just = RIGHT_CENTER;
			if((just && dual_mode) && string[index+1] != 'M')
			{

				move_to_field(loc_str,TOL_FIELD,
				    just,zero,zero,
				    loc_length);
				half = 0.5;
				vertical_move(loc_str,half,loc_length);
						/* - add a horizontal move - */
				horizon_move(loc_str, white_space, loc_length);
				DMinsert_text(string,LocStr,
				    index,loc_length,length);
			}
			else if(just && string [index+1] == 'M')
			{
				/*| -remove escape if exits*/
				DMdelete_text(string,length,index,40);
				index -=40;
			}
			active_field++;
			break;
		case 'M':
			index += 20;
			break;
		case 'm':
			index+=19;
			break;
		case 'f':
			index += 4;
			break;

	        case 'p':
	        	index += 3;
        	    	break;
		default:
			/*"unknown char at index[%d]:%d",index,string[index+1]*/
			index++;
			break;
		}
	}

	if(dual_mode == DUAL_MODE_ON)
		DMadd_dual_field(string,length,gtattr);

	DMupdt_disp_chars(string,length,gtattr,dual_mode,type);
	gtattr->disp_char_index = gtattr->num_disp_char;

	return(TRUE);
}

DMinsert_text(src_str,append_str,index,numbytes,length)
IGRuchar *src_str,*append_str;
int index,numbytes;
IGRshort *length;
/*.DMinsert_text*/
{
	int CopyFr,CopyTo;
	CopyTo = index +numbytes;
	CopyFr = index;
 	OM_BLOCK_MOVE( &src_str[CopyFr], &src_str[CopyTo],(*length - CopyFr));
	memcpy(&src_str[CopyFr],append_str,numbytes);
	*length += numbytes;
	return(TRUE);
}

DMdelete_text(src_str,strlength,DeleteFrom,BytestoDel)
IGRuchar *src_str;
IGRshort *strlength;
IGRshort BytestoDel,DeleteFrom;
/*.DMdelete_text*/
{
	OM_BLOCK_MOVE(
	        &src_str[DeleteFrom + BytestoDel],
		&src_str[DeleteFrom],
	       (*strlength - (DeleteFrom + BytestoDel)));
	(*strlength) -= BytestoDel;
	return(TRUE);
}

DMcompute_valid_index(text_string,text_length,
			CurrIndex,gtattr,type)
IGRuchar *text_string;
IGRshort *text_length;
IGRshort *CurrIndex;
struct GTattr *gtattr;
IGRboolean type;
/*.DMcompute_valid_index*/
{
	int i;
	short start_index;

	/*"disp_index:%ld\n",gtattr->disp_char_index*/

	*CurrIndex = start_index = 0;
	i = 0;
	if(type == FEATURE_CONTROL_FRAME)
	{
		while(!((text_string[i] == ESC) && (text_string[i+1] == 'E')))
			i++;
		i+=2;
		start_index = 1;
	}
	else
	{
		while(!((text_string[i] == ESC) && (text_string[i+1] == 'F')))
			i++;
	}

	*CurrIndex = i;
	/*"CurrIndex:%d\n",*CurrIndex */
	for( i= start_index; i< gtattr->disp_char_index;i++)
	{
		/*"dispindex:%d\n",gtattr->disp_char[i]*/

		switch(gtattr->disp_char[i])
		{
		case AN_NORMAL:
			(*CurrIndex)++;
			break;
		case LINE_FEED:
			*CurrIndex += 2;
			if((*CurrIndex + 10 < *text_length) && 
			   (text_string[*CurrIndex] == ESC &&
			   text_string[*CurrIndex + 1] == 'H'))
			*CurrIndex += 10;
			break;
		case TOL_SYMBOL:
			/*"skipping tol symbol\n"*/
			break;
		case SEPERATOR:
			*CurrIndex +=49;
			break;
		case GEOM_SYMBOL:
			if(text_string[*CurrIndex +1] == 'x')
			{	/*| scale changed */
				*CurrIndex +=29;
			}
			else *CurrIndex += 9;
			break;
        	case  FRACTION_SYMBOL :
			*CurrIndex += 8;
			break;
		case AN_CHANGE_FONT:
			*CurrIndex +=4;
			break;
		case AN_16BIT_CHAR:
			*CurrIndex +=2;
			break;
		case AN_TEXT_BEGIN:
			*CurrIndex +=( 4);
			break;
		case AN_DUAL_BEGIN:
			*CurrIndex +=( 4);
			break;
		case AN_SPACE:
			if (gtattr->disp_char[i-1] != MOVE_TO_FIELD)
				*CurrIndex +=( 10);
			break;
		case MOVE_TO_FIELD:
			if (gtattr->disp_char[i+1] == AN_SPACE)
				*CurrIndex += 40;
			else
				*CurrIndex += 30;
			break;
		case AN_END_FIELD:
			*CurrIndex += ( 2); /* skip to end of field */
			break;
		default:
			/*"valid index: unknown index:%d\n",gtattr->disp_char[i]*/
			break;
		}
	}
	while(gtattr->disp_char_index < gtattr->num_disp_char && 
		gtattr->disp_char[gtattr->disp_char_index] == AN_16BIT_CHAR )
	{
		*CurrIndex +=2;
		gtattr->disp_char_index++;
	}
	return(TRUE);
}

DMis_tol_sym_exists(string,length)
IGRuchar *string;
IGRshort *length;
/*.DMis_tol_sym_exists*/
{
	IGRlong long_rc;
	IGRint status;
	IGRboolean multi_mode;
	short num_chars;
	short symbol_index;

	symbol_index = 0;
	num_chars = -1;
	if(!(*length))
		return(FALSE);
	/*^analyse_string(string,*length);*/
	while(TRUE)
	{
		if( (string[symbol_index] == ESC) &&
		    (string[symbol_index+1] == 'F'))
		{
			if(string[symbol_index+2] == TOL_FIELD)
				return(TRUE);
			else return(FALSE);
		}
		else if(!num_chars) return(FALSE);

		multi_mode = FALSE;
		status = 
		    GRfwd_esc_seq(&long_rc,string,length,&multi_mode,
				  &symbol_index,&num_chars);
		/*"numchars:%d\n",num_chars*/
		symbol_index += num_chars;
	}
}

DMadd_tolerance_symbol(string,length,gtattr,tole_mode,estx,type)
IGRuchar *string;
IGRshort *length;
struct GTattr *gtattr;
IGRboolean tole_mode;
struct IGRestx *estx;
IGRchar type;
/*.DMadd_tolerance_symbol*/
{
	IGRuchar *txt_ptr;

	/*"tol symbol:%c\n",gtattr->tol_symbol*/
	/*tole mode:%d\n",tole_mode*/
	/*text length:%d\n",*length*/

	if(type == FEATURE_CONTROL_FRAME)
		DMreplace_tol_sym(string,length,gtattr->tol_symbol,
				  tole_mode,estx,gtattr);
	txt_ptr = &string[*length];
	start_field(txt_ptr,(TOL_FIELD +1),0,(*length));
	if(type == DATUM_FRAME)
	{
		gtattr->active_font = 0;
		DMadd_seperator(string,length,gtattr);
	}
	return(TRUE);
}

DMget_possible_posn(gtattr,flag)
struct GTattr *gtattr;
IGRboolean flag;
/*.DMget_possible_posn*/
{
	IGRshort ActivePosn;
	IGRshort Index;
	IGRboolean next_index;

	Index = ((flag == AN_AFTER) ? 1 :-1);
	ActivePosn = gtattr->disp_char_index;

	do 
	{
	/*^
		printf("get posn:%d\n",ActivePosn);
		printf("index:%d\n",gtattr->disp_char[gtattr->disp_char_index]);
	*/
		next_index = FALSE;
		switch(gtattr->disp_char[ActivePosn])
		{
		case AN_NORMAL:
		case LINE_FEED:
		case GEOM_SYMBOL:
		case SEPERATOR:
	        case FRACTION_SYMBOL:
			ActivePosn = ActivePosn + Index;
			if(gtattr->disp_char[ActivePosn] == AN_TEXT_BEGIN)
				next_index = TRUE;
			if(gtattr->disp_char[ActivePosn] == MOVE_TO_FIELD)
				next_index = TRUE;
			break;
		case AN_16BIT_CHAR:
			ActivePosn = ActivePosn + Index;
			next_index = TRUE;
			break;
		case AN_CHANGE_FONT:
			ActivePosn = ActivePosn + Index;
			if(gtattr->disp_char[ActivePosn] == AN_16BIT_CHAR)
				next_index = TRUE;
			break;
		case TOL_SYMBOL:
			ActivePosn +=1;
			next_index = TRUE;
			break;
		case AN_TEXT_BEGIN:
			ActivePosn+=1;
			if(gtattr->disp_char[ActivePosn] == MOVE_TO_FIELD)
			ActivePosn+=1;
			break;
		case AN_END_FIELD:
			ActivePosn += Index;
			if(ActivePosn+1  > gtattr->num_disp_char)
				ActivePosn -=1;
			else if ( Index != -1)
			{
				ActivePosn+=Index;
				next_index = TRUE;
			}
			break;
		case MOVE_TO_FIELD:
			ActivePosn+=Index;
			next_index =TRUE;
			break;
		 case AN_DUAL_BEGIN:
			ActivePosn += Index;
			next_index = TRUE;
			break;
		case AN_SPACE:
			ActivePosn += Index;
			next_index = TRUE;
			break;
		default:
			/*"getposn: index:%d\n",gtattr->disp_char[ActivePosn]*/
			break;
		}
	
	}while(next_index);
	gtattr->disp_char_index = ActivePosn;
	/*"disp index:%d\n",ActivePosn*/
	return(TRUE);
}

#argsused
DMupdt_disp_chars(string,length,gtattr,dual_mode,type)
IGRuchar *string;
IGRshort  *length;
struct GTattr *gtattr;
IGRboolean dual_mode,type;
/*.DMupdt_disp_chars*/
{
	IGRlong long_rc;
	IGRshort index,active_font;
	struct vfont_entry cur_font_info;
	char field_pos[256];
	int field_no,active_field;
	int move_type ;
	enum  {
		moveinH,moveinV,moveinX,moveinY,moveinCR,
		    Fieldstart,Fieldend,Change_font	};

	active_field = field_no = 0;
	move_type = 0;
	gtattr->num_disp_char = 0;
	cur_font_info.flags = 0;

	/*"length :%d\n",*length*/
	/*^analyse_string(string,*length);*/

	index = 0;
	if(type == FEATURE_CONTROL_FRAME)
	{
		while(!(string[index] == ESC &&  string[index +1] == 'E'))
			index++;
		index+=2;	/* end field*/
		gtattr->disp_char[gtattr->num_disp_char++] = TOL_SYMBOL;
	}

	/*^	printf("index:%ld\n",index);*/

	while(index < *length)
	{
		if(string[index] != ESC)
		{
			if(string[index] & 0x80)
			{
				/*| SIXTEEN_BIT_INPUT*/
				if (cur_font_info.flags & SIXTEEN_BIT)
				{
					gtattr->disp_char[gtattr->num_disp_char++]= AN_16BIT_CHAR;
					index+=2;
				}
				else
				{	/* Alt mode char */
					gtattr->disp_char[gtattr->num_disp_char++]= AN_NORMAL;
					index++;
				}
			}
			else
			{
				gtattr->disp_char[gtattr->num_disp_char++]= AN_NORMAL;
				index++;
			}
			move_type = 0;
			continue;
		}
		switch(string[index+1])
		{
		case 'H':
		case 'J':
		case 's':
		case 'j':
			index+=10;
			break;
		case 'y':
			if(move_type == moveinV)
			{
				gtattr->disp_char[gtattr->num_disp_char++]=
				    SEPERATOR;
				index+=39;
			}
			else index+=10;
			move_type = moveinY;
			break;
		case 'v':
			index+=10;
			move_type = moveinV;
			break;
		case 'x':
			move_type = moveinX;
			index+=10;
			break;
		case 'h':
			gtattr->disp_char[gtattr->num_disp_char++]=
			    AN_SPACE;
			move_type = moveinH;
			index += 10 ;
			break;
		case 'w':
			index += 3 ;
			break;
		case 'E':
			active_field--;
			field_no = field_pos[active_field];
			if( field_no  ==(TOL_FIELD+1) )
			{
				gtattr->disp_char[gtattr->num_disp_char++] = AN_END_FIELD;
				index+=2;
			}
			break;
		case 'F':
			/*|field begin occured */
			field_pos[active_field] = string[index+2];
			index+=4;

			if( field_pos[active_field] == (TOL_FIELD + 1))
			{
				if(type != FEATURE_CONTROL_FRAME)
					gtattr->num_disp_char = 0;
				gtattr->disp_char[gtattr->num_disp_char++] = AN_TEXT_BEGIN;
			}
			else if(field_pos[active_field] == (TOL_FIELD+2) )
			{
				gtattr->disp_char[gtattr->num_disp_char++] = AN_DUAL_BEGIN;
			}
			active_field++;
			break;
		case 'M':
			gtattr->disp_char[gtattr->num_disp_char++] = MOVE_TO_FIELD;
			index += 20;
			break;
		case 'm':
			index+=19;
			break;
		case LINE_FEED:
			index +=2;
			gtattr->disp_char[gtattr->num_disp_char++] =  LINE_FEED;
			break;
		case 'f':
			if( (string[index +5] == ESC) && 
			    (string[index+6] == 'f'))
			{
				gtattr->disp_char[gtattr->num_disp_char++] =
				    GEOM_SYMBOL;
				if(move_type == moveinX)
					index +=19;
				else index +=9 ;
			}
			else if( (string[index +5] == ESC) &&
                            (string[index+6] == 'p'))
                       {     gtattr->disp_char[gtattr->num_disp_char++] =
                                   FRACTION_SYMBOL;
                             index += 8;
                       }
                       else 
			{
				memcpy(&active_font,&string[index+2],2);
				font$get_info(msg = &long_rc,
				    	      font_num = &active_font,
				    	      font_info = &cur_font_info);
				gtattr->disp_char[gtattr->num_disp_char++]=
				    		AN_CHANGE_FONT;
				index+=4;
			}
			break;
		default:
			/*^

				printf("string[%d]:%d\n",index+1,string[index+1]);
				printf("flags:%d\n",cur_font_info.flags);
			*/

			index+=2;
			break;
		}
	}
	/*^
		for( index = 0; index < gtattr->num_disp_char;index++)
			printf("disp char[%d]:%d\n",index,gtattr->disp_char[index]);
	*/
	return(TRUE);
}

DMcompute_bytes_to_del(
	msg,
	text_string, 
	text_length, 
	gtattr,
	current_index,
	BytestoDel,
	disp_char_del,
	action,
	type)
IGRint *msg;
IGRuchar *text_string;
IGRshort *text_length;
struct GTattr *gtattr;
IGRshort *current_index;
IGRshort *BytestoDel,*disp_char_del;
IGRboolean type;
IGRint *action;
/*.DMcompute_bytes_to_del*/
{
	IGRint next_index, tmp_index;

	*BytestoDel = 0;
	*disp_char_del = 0;
	DMcompute_valid_index(text_string,text_length,current_index,gtattr,type);

/*	printf("current index:%d\n",*current_index); */
		tmp_index = *current_index;
	do
	{
		next_index = FALSE;
		gtattr->disp_char_index-- ;
		switch( gtattr->disp_char[gtattr->disp_char_index])
		{
		case AN_NORMAL:
			*BytestoDel += 1;
			break;
		case LINE_FEED:
			if(text_string[tmp_index -9] == 'H' &&
			   text_string[tmp_index -10] == ESC)
				*BytestoDel += 12;
			else 
				*BytestoDel += 2;
			break;
		case TOL_SYMBOL:
			*BytestoDel = 0;    /* should't delete it */
			break;
		case SEPERATOR:
			*BytestoDel += 49;
			if(gtattr->disp_char[gtattr->disp_char_index-1] == TOL_SYMBOL
			|| gtattr->disp_char[gtattr->disp_char_index-1] == AN_TEXT_BEGIN )
			{
				*BytestoDel = 0;
				gtattr->disp_char_index++;
				(*disp_char_del)--;
			}
			break;
		case GEOM_SYMBOL:
			if(text_string[tmp_index -9] == 'x')
				*BytestoDel += 29;
			else
				*BytestoDel += 9;
			break;

	        case FRACTION_SYMBOL :
			*BytestoDel  += 8;
			break;
		case AN_CHANGE_FONT:
			*BytestoDel += 4;
			if(gtattr->disp_char[gtattr->disp_char_index-1] == AN_16BIT_CHAR)
				next_index = TRUE;
			break;
		case AN_16BIT_CHAR:
			*BytestoDel += 2;
			next_index = TRUE;
			break;
		case AN_TEXT_BEGIN:
			*BytestoDel = 0;

			(*disp_char_del)--;
			gtattr->disp_char_index++;
			break;
		case AN_END_FIELD:
			*BytestoDel += 2;
			break;
		case AN_DUAL_BEGIN:
			*BytestoDel += 4;
			*action |= SET_SINGLE_MODE;
			next_index = TRUE;
			break;
		case AN_SPACE:
			if(gtattr->disp_char[gtattr->disp_char_index-1] 
						      == MOVE_TO_FIELD)
				next_index = TRUE;
			*BytestoDel += 10;
			break;
		case MOVE_TO_FIELD:
			if(gtattr->disp_char[gtattr->disp_char_index-1] 
						      == AN_TEXT_BEGIN)
			{
				(*disp_char_del)--;
				gtattr->disp_char_index++;
			}
			else
			{
				*BytestoDel += 30;
				next_index = TRUE;
			}
			break;
		default:
			/*"dispindex:%d\n",gtattr->disp_char[gtattr->disp_char_index]*/
			break;
		}
		(*disp_char_del)++;
		tmp_index -= *BytestoDel;
	}while(next_index);
	*msg = OM_S_SUCCESS;
	return(TRUE);
}

DMmake_tol_symbol(string,
                  text_length,
                  estx,
                  gtattr,
                  dualmode)
IGRuchar *string;
short *text_length;
struct IGRestx *estx;
struct GTattr *gtattr;
IGRboolean dualmode;
/*.DMmake_tol_symbol*/
{
	IGRshort index,BytestoDel;
	IGRuchar loc_string[256],*LocStr;
	IGRdouble y_value,s_value,factor;
	IGRshort zero = 0;

	/* - Find the index of the first end field character*/
	
	index = BytestoDel = 0;
	if(*text_length)
	{
		while(!(string[index] == ESC && string[index+1] == 'E') )
		      index++;
		BytestoDel = index +2;
	}
	
	/* - Build text string for dual mode */
	index = 0;
	LocStr = loc_string;
	start_field(LocStr,TOL_FIELD,0,index);
	if(dualmode)
	{
		y_value = -1.5;
		s_value = 4.0;
	}
	else
	{
		s_value = 2.0;
		y_value = -0.5;
	}
	vertical_move(LocStr,y_value,index);
	Y_scale(LocStr,s_value,index);

	change_font(LocStr,zero,index);
	*LocStr++ = gtattr->sep_symbol;
	index++;

	if(gtattr->tol_symbol != TOL_SYMBOL_NONE)
	{
		s_value = (dualmode ? 0.25 :0.5);
		y_value = (dualmode ? 1.5 :0.5);

		Y_scale (LocStr,s_value,index);
		vertical_move(LocStr,y_value,index);

		factor = estx->height/estx->width;
		if(fabs(factor -1.0) >1.0e-4)
		{
			X_scale(LocStr,factor,index);
		}

		change_font(LocStr,gtattr->geom_font,index);
		*LocStr++ = gtattr->tol_symbol;
		index++;

		if(fabs(factor -1.0) >1.0e-4)
		{
			factor = 1/factor;
			X_scale(LocStr,factor,index);
		}
		if(dualmode)
		{
			y_value = -1.5;
			s_value = 4.0;
		}
		else
		{
			s_value = 2.0;
			y_value = -0.5;
		}
		vertical_move(LocStr,y_value,index);
		Y_scale (LocStr,s_value,index);

		change_font(LocStr,zero,index);
		*LocStr++ = gtattr->sep_symbol;
		index++;
		change_font(LocStr,gtattr->text_font,index);
	}

	if(dualmode)
	{
		s_value = 0.25;
		y_value = 1.5;
	}
	else
	{
		s_value = y_value = 0.5;
	}
	Y_scale (LocStr,s_value,index);
	vertical_move(LocStr,y_value,index);
	end_field(LocStr,index);
	
	/* - Replace the first field text with current */
	DMdelete_text(string,text_length,0,BytestoDel);
	DMinsert_text(string,loc_string,0,index,text_length);

	return(TRUE);
}


IGRint DMcompute_disp_char_posn(
	text_string,
	text_length,
	gtattr,
	index,
	type)
IGRuchar *text_string;
IGRshort *text_length;
IGRshort index;
struct GTattr *gtattr;
IGRboolean type;
/*.DMcompute_disp_char_posn*/
{
	int i;
	short CurrIndex;
	IGRint next_index=0;

	gtattr->disp_char_index = 0;
	/*| - update the current index if just moves are there */
		i = 0;
	if(type == FEATURE_CONTROL_FRAME)
	{
		while(!((text_string[i] == ESC) && (text_string[i+1] == 'E')))
			i++;
		i+=2;   /* ESC E*/
		gtattr->disp_char_index++;
	}
	else
	{
		while(!((text_string[i] == ESC) && (text_string[i+1] == 'F')))
			i++;
	}

	if( index < (i + 4))
	{
		gtattr->disp_char_index++;
		return(TRUE);
	}
	else
		CurrIndex = i;

	/*"CurrIndex:%d\n",CurrIndex */
	
	for( i = gtattr->disp_char_index; i< gtattr->num_disp_char;i++)
	{
		/*"dispindex:%d\n",gtattr->disp_char[i]*/
		if(CurrIndex > index && !next_index)
		{
			gtattr->disp_char_index = i;
			break;
		}
		next_index = FALSE;
		switch(gtattr->disp_char[i])
		{
		case AN_NORMAL:
			(CurrIndex)++;
			break;
		case TOL_SYMBOL:
				/*|CASE TOL_SYMBOL:should not come here */
			break;
		case SEPERATOR:
			CurrIndex +=49;
			break;
		case GEOM_SYMBOL:
			if(text_string[CurrIndex +1] == 'x')
			{	/*| scale changed */
				CurrIndex +=29;
			}
			else CurrIndex += 9;
			break;
	        case FRACTION_SYMBOL :
        		CurrIndex += 8;
			break;
		case AN_CHANGE_FONT:
			CurrIndex +=4;
			break;
		case AN_16BIT_CHAR:
			CurrIndex +=2;
			break;
		case LINE_FEED:
			CurrIndex +=2;
			if((CurrIndex +10  < *text_length) &&
			   (text_string[CurrIndex +1] == 'H' &&
			   text_string[CurrIndex ] == ESC ))
				CurrIndex +=10;
			break;
		case AN_TEXT_BEGIN:
			CurrIndex +=(4);
			next_index = TRUE;
			break;
		case AN_DUAL_BEGIN:
			CurrIndex +=(4);
			break;
		case AN_SPACE:
			CurrIndex +=(10);
			break;
		case MOVE_TO_FIELD:
			CurrIndex +=30;
			next_index = TRUE;
			break;
		case AN_END_FIELD:
			CurrIndex +=2;
			next_index = TRUE;
			break;
		default:
			/*"compute posn unknown index:%d\n",gtattr->disp_char[i]*/
			break;
		}
	}
	return(TRUE);
}


DMinquire_add_seperator( text_string,text_length,gtattr,text_buff_size,type)
IGRuchar *text_string;
IGRshort *text_length;
IGRshort *text_buff_size;
struct GTattr *gtattr;
IGRint type;
/*.DMinquire_add_seperator*/
{
	IGRint status;
	IGRshort numbytes = 0;
	IGRchar loc_string[80];

	if((*text_length + 50) >= *text_buff_size)
	{
		*text_buff_size +=TEXT_BUF_SIZE;
		text_string =
		(IGRuchar *)om$realloc(ptr  =  (char *)text_string,
		    	   size = (OMuint ) *text_buff_size);
		dm$status(action = RET_STATUS);
	}

	if(type != TEXT_WITH_LEADER)
	{
		if( gtattr->disp_char[gtattr->num_disp_char - 1] != SEPERATOR &&
		 gtattr->disp_char[gtattr->num_disp_char - 1] != AN_TEXT_BEGIN &&
		 gtattr->disp_char[gtattr->num_disp_char - 1] != AN_END_FIELD &&
	    	 gtattr->num_disp_char > 1)
		{
			gtattr->active_font = 0;
			DMadd_seperator(loc_string,&numbytes,gtattr);
			DMinsert_text(text_string,loc_string,
				      *text_length,numbytes,text_length);

		}
	
	}
	text_string[*text_length] = ESC;
	text_string[*text_length+1] = 'E';
	*text_length +=2;
		
	return(TRUE);
}


DMadd_change_font(
	gtattr,
	index,
	text_string,
	length,
	type,
	current_index)
struct GTattr *gtattr;
IGRuchar *text_string;
int *index;
short *length;
int type;
IGRshort *current_index;
{
        IGRshort i;
	int NumBytes;
	IGRuchar *StrPtr,loc_string[80];

	StrPtr = loc_string;
	NumBytes = 0;
	*index = -1;
	i = gtattr->disp_char_index;
	while( i < gtattr->num_disp_char && 
		gtattr->disp_char[i] == AN_16BIT_CHAR) i++;

	if( gtattr->disp_char[i] != AN_CHANGE_FONT)
	{
		gtattr->prev_disp_char = AN_CHANGE_FONT;
		change_font(StrPtr,gtattr->text_font,NumBytes);

		DMadd_annot_char(
			text_string,
                        length,
                        loc_string,
                        NumBytes,
                        gtattr,
                        type,
                        current_index);

		gtattr->disp_char_index--;
	}

	return(TRUE);
}

IGRint DMret_disp_char(
	inp_str,
	inp_length,
	num_str,
	str,
	len)
IGRuchar *inp_str;
short inp_length;
short *num_str;
IGRuchar **str;
short *len;
/*.DMret_disp_char*/
{
	int i,j;

	*num_str = 0;
	j = 0;

	/*^
		analyse_string(inp_str,inp_length);
		printf("inp_length = %d\n",inp_length);
	*/

	for(i = 0; i < inp_length;)
	{
		if(inp_str[i] != ESC)
		{
			str[*num_str][j++] = inp_str[i];
			i++;
			str[*num_str][j] = '\0';
			len[*num_str] = j;
			continue;
		}
		
		switch(inp_str[i+1])
		{
			case 'j':
			case 'J':
				i+=10;
				break;
			case 'h':
			case 'H':
				i+=10;
				break;

			case 'f':
				i+=4;
				break;
		
			case 'F':
				(*num_str) = inp_str[i+2] -1;
				i+=4;
				j=0;
				break;
			case 10 :
				i+=2;
				break;

			case 'E' :
				i+=2;
				str[*num_str][j++] = '\0';
				len[*num_str] = j;
				break;
			default:
				printf(" Weld: char ESC %d\n",inp_str[i+1]);
					i+=2;
				break;
		}
	}

 	(*num_str) += 1;

	/*^
		printf("num_str = %d\n", *num_str);
		for (i=0; i<*num_str; i++)
	    	printf("str[%d] = <%s>, len = %d\n",i, str[i], len[i]);
	*/

	return(TRUE);
}

DMmake_frac(gtattr,char_index,text_string,text_length,type,current_index)
struct GTattr *gtattr;
char char_index;
IGRuchar *text_string;
IGRshort *text_length;
char type;
IGRshort *current_index;
{
	IGRlong long_rc;
	IGRuchar fraction[10];
	IGRshort  num_chars;

	if (char_index == FRACTION_KEY)
	{
		/* check to see if active fraction font */

		ex$message (msgnumb = GR_P_EnterFraction);

		gtattr->fraction_flag = TRUE;
		gtattr->substr_len = 0;
		gtattr->substring[gtattr->substr_len] = 0;
	}
	else
	{
		/* already have fraction key */
		if (char_index > 0x2e && char_index < 0x3a)
		{
			gtattr->substring[gtattr->substr_len] = char_index;
			gtattr->substr_len++;
			gtattr->substring[gtattr->substr_len] = 0;

			ex$message (in_buff = gtattr->substring,
				  field = KEYIN_FIELD);
		}
		else
		{
			/* nonnumeric character "ends"
					 * fraction */
			gtattr->fraction_flag = FALSE;
			ex$message (in_buff = "",
					field = KEYIN_FIELD);

			/* ex$message (msgnumb = GR_P_EntTxtDtPtOrg);*/

			num_chars = 0;
			GRgen_fraction(
				&long_rc,
				gtattr->substring,
				fraction,
				&num_chars);

		 	if (long_rc == MSFAIL) 
			{
				ex$message (msgnumb = GR_E_NoActFracFont);
			}
			else 
                        {
                        	if (long_rc == MSSUCC)
                                   gtattr->prev_disp_char = FRACTION_SYMBOL; 
                                else
				   gtattr->prev_disp_char = AN_NORMAL; 
                                   
				DMadd_annot_char(
					text_string,
					text_length,
					fraction,
					num_chars,
					gtattr,
					type,
					current_index);
			}
		}
	}

	return(TRUE);
}

DMset_display_index(gtattr, insert_mode, char_index)
struct GTattr *gtattr;
IGRboolean *insert_mode;
IGRchar char_index;
/*.DMset_display_index*/
{
	if( gtattr->disp_char_index >= gtattr->num_disp_char)
        {
        	gtattr->disp_char_index = gtattr->num_disp_char;
                *insert_mode = FALSE;
	}
	else
	if((gtattr->disp_char[gtattr->disp_char_index -1] == AN_16BIT_CHAR) &&
           (gtattr->disp_char[gtattr->disp_char_index] == AN_CHANGE_FONT) &&
          !(char_index & 0x80))
        {
        	if (char_index != EX_LEFT_ARROW )
                   gtattr->disp_char_index++;
        }

        return(TRUE);
}

IGRint DMcheck_buff_size(text_string,text_length,text_buff_size)
unsigned char *text_string;
IGRshort *text_length,*text_buff_size;
/*.DMcheck_buff_size*/
{
	IGRint status;

	if((*text_length + 50) >= *text_buff_size)
	{
		/*"text length:%d\ttext buff;%d\n",*text_length, *text_buff_size*/

		*text_buff_size +=TEXT_BUF_SIZE;

		text_string = (unsigned char *)om$realloc(
				ptr = (char *)text_string,
		    	   	size = (OMuint)*text_buff_size);
		dm$status(action = RET_STATUS);
	}

	return(TRUE);
}

end implementation DMannot;


