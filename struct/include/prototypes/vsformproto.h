/*
	I/STRUCT
*/

#ifndef vsformproto_include
#	define vsformproto_include

#ifndef _STANDARDS_H_
#	include <standards.h>
#endif

#ifndef vs_include
#	include "vs.h"
#endif

extern int
VSf_repaint_gadget		__((	char		*form,
					int		gadget )) ;

extern int
VSfld_set_list			__((	char		*form,
					int		label,
					int		size,
					char		**list )) ;

extern int
VSfld_set_list_with_msgkeys	__((	char		*form,
					int		label,
					int		size,
					long		*keylist )) ;

extern int
VSfld_find_char			__((	char		*form,
					int		label,
					int		col,
					int		x,
					int		y,
					int		*charpos )) ;

extern int
VSf_is_cursor_in_fld_row	__((	char		*form,
					int		label,
					int		x,
					int		y,
					int		*row )) ;

extern int
VSg_get_layout			__((	char		*form,
					int		label,
					int		*xpos,
					int		*ypos,
					int		*width,
					int		*height )) ;

extern int
VSg_set_layout			__((	char		*form,
					int		label,
					int		xpos,
					int		ypos,
					int		width,
					int		height )) ;

extern int
VSf_get_layout			__((	char		*form,
					int		*screen,
					int		*xpos,
					int		*ypos,
					int		*width,
					int		*height )) ;

extern int
VSf_set_layout			__((	char		*form,
					int		screen,
					int		xpos,
					int		ypos,
					int		width,
					int		height )) ;

extern int
VSg_replace			__((	char		*form,
					int		oldgadget,
					int		newgadget )) ;

extern int
VSg_chg_attr			__((	char		*form,
					int		label,
					int		set,
					int		rm )) ;

extern int
VSg_chg_attr_of_gadgets		__((	char		*form,
					int		set,
					int		rm,
					... )) ;

extern int
VSg_make_group_of_gadgets	__((	char		*form,
					int		group,
					... )) ;

extern int
VSg_op_on_gadgets		__((	char	*form,
					int	(*op) __(( char	*form,
							   int	label )),
					... )) ;

extern int
VSf_enable_form			__((	char		*form,
					struct VSgadget	*labDesc )) ;

extern int
VSf_disable_form		__((	char		*form,
					struct VSgadget	*labDesc )) ;

extern int
VSfld_blank_out_rows		__((	char		*form,
					int		label,
					int		column )) ;

extern int
VSfld_del_empty_rows		__((	char		*form,
					int		label,
					int		column )) ;

extern int
VSfld_restart			__((	char		*form,
					int		label )) ;

extern int
VSfld_set_text_and_scroll	__((	char		*form,
					int		label,
					int		row,
					char		*text )) ;

extern int
VSfi_prompt			__((	char		*form,
					char		*prompt )) ;

extern int
VSfi_msg			__((	char		*form,
					char		*msg )) ;

extern int
VSfi_msgkey			__((	char		*form,
					long		msgkey )) ;

extern int
VSfi_msgkeySts			__((	char		*form,
					long		msgkey )) ;

extern int
VSfi_put_paste_buffer		__((	char		*buf )) ;

extern int
VSfld_insert_text		__((	char		*form,
					int		label,
					int		row,
					int		column,
					int		charpos,
					char		*text )) ;

extern int
VSf_get_field_count		__((	char		*form )) ;

extern int
VSf_force_initial_notify_of_fields
				__((	char		*form,
					int		*resetCount,
					struct VSgadget	**resetList )) ;

extern int
VSf_reset_fields_to_previous_initial_notify
				__((	char		*form,
					int		resetCount,
					struct VSgadget	*resetList )) ;

extern int
VSfld_flip_row_block		__((	char		*form,
					int		label,
					int		row,
					int		colums,
					int		weight )) ;

extern int
VSf_sub_form			__((	char		*form,
					int		subFormLabel,
					char		*subFormFile,
					char		**subForm )) ;

extern int
VSfld_insert_newline		__((	char		*form,
					int		label,
					int		row )) ;

extern int
VSfld_get_cursor		__((	char		*form,
					int		label,
					int		*row,
					int		*charpos )) ;

extern int
VSfld_set_cursor		__((	char		*form,
					int		label,
					int		row,
					int		charpos )) ;


extern int
VSfld_delete_word		__((	char		*form,
					int		label,
					int		row,
					int		column,
					int		charpos,
					int		*rowDeleted,
					char		**delWord )) ;

extern int
VSf_locate			__((	char		*form,
					int		rangeGadget,
					int		*p_x,
					int		*p_y,
					int		*p_gadget,
					int		relocate )) ;

extern int
VSf_rmSaveRestoreProp		__((	char		*form )) ;

extern int
VSf_display			__((	char		*form )) ;

extern char
*VSmcf_get_text			__((	char		*form,
					int		label,
					int		row,
					int		column )) ;

extern char
*VSfld_get_text			__((	char		*form,
					int		label )) ;

extern char
*VSfld_get_lines		__((	char		*form,
					int		label )) ;


extern char
**VSmcf_get_list_text		__((	char		*form,
					int		label,
					int		column )) ;

extern char
*VSfi_get_paste_buffer		__((	char		*buf )) ;

extern void
VSfld_set_lines			__((	char		*form,
					int		label,
					char		*text )) ;

extern void
VSfld_set_row_text		__((	char		*form,
					int		label,
					int		size,
					char		**list )) ;

extern void
VSmcf_set_list_text		__((	char		*form,
					int		label,
					int		column,
					int		size,
					char		**list )) ;

extern void
VSscrollField			__((	char		*form,
					int		label,
					int		pos )) ;

extern void
VSscroll_field			__((	char		*form,
					int		label,
					int		direction )) ;

extern void
VSsetGadgetModifiable		__((	struct VSgadget	*list,
					int		label,
					int		flag )) ;
#endif /* vsformproto_include */

