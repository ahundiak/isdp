#ifndef FIover_included
#define FIover_included

/* Environ V calls that can be overridden */

#define Clear_timer_data		_FEI_Clear_timer_data
#define Collapse_win            	_FEI_Collapse_win 
#define Create_SR_area          	_FEI_Create_SR_area 
#define Create_levwin_no_border 	_FEI_Create_levwin_no_border 
#define Create_win_user_icon    	_FEI_Create_win_user_icon 
#define Delete_SR_area          	_FEI_Delete_SR_area 
#define Delete_win              	_FEI_Delete_win 
#define Display_win             	_FEI_Display_win 
#define Display_win_marq        	_FEI_Display_win_marq 
#define Enter_SR                	_FEI_Enter_SR 
#define Exit_SR                 	_FEI_Exit_SR 
#define Get_collapse_data       	_FEI_Get_collapse_data 
#define Get_button_data         	_FEI_Get_button_data 
#define Get_delete_data         	_FEI_Get_delete_data 
#define Get_refresh_area_data   	_FEI_Get_refresh_area_data 
#define Get_user_data			_FEI_Get_user_data 
#define Set_user_data			_FEI_Set_user_data 
#define Get_win_user_icon_data  	_FEI_Get_win_user_icon_data 
#define Inq_collapse_data       	_FEI_Inq_collapse_data 
#define Inq_button_data         	_FEI_Inq_button_data 
#define Inq_delete_data         	_FEI_Inq_delete_data 
#define Inq_displayed_vs        	_FEI_Inq_displayed_vs 
#define Inq_events              	_FEI_Inq_events
#define Inq_refresh_area_data   	_FEI_Inq_refresh_area_data 
#define Inq_screen_info         	_FEI_Inq_screen_info 
#define Inq_user_data			_FEI_Inq_user_data 
#define Inq_win_collapse_stat   	_FEI_Inq_win_collapse_stat 
#define Inq_win_region			_FEI_Inq_win_region
#define Inq_win_user_icon_data  	_FEI_Inq_win_user_icon_data 
#define Inq_win_vs			_FEI_Inq_win_vs 
#define Load_SR_vlt			_FEI_Load_SR_vlt 
#define Load_symbol_file		_FEI_Load_symbol_file 
#define Modify_win              	_FEI_Modify_win 
#define Mouseposition           	_FEI_Mouseposition 
#define Mouse_win_position      	_FEI_Mouse_win_position 
#define Process_win_icon_menu   	_FEI_Process_win_icon_menu 
#define Refresh_on_move         	_FEI_Refresh_on_move 
#define Set_win_bounds          	_FEI_Set_win_bounds 
#define Set_win_button_mode     	_FEI_Set_win_button_mode 
#define Set_win_collapse_org    	_FEI_Set_win_collapse_org 
#define Set_win_collapse_symbol 	_FEI_Set_win_collapse_symbol 
#define Set_win_deltas          	_FEI_Set_win_deltas 
#define Set_win_sys_icon        	_FEI_Set_win_sys_icon 
#define Set_win_user_icon       	_FEI_Set_win_user_icon 
#define Set_win_vs_swap         	_FEI_Set_win_vs_swap
#define Start_timer			_FEI_Start_timer
#define Stop_timer			_FEI_Stop_timer
#define Uncollapse_win          	_FEI_Uncollapse_win 
#define Update_win_icon         	_FEI_Update_win_icon
#define Wait_for_next           	_FEI_Wait_for_next

#define blendarea               	_FEI_blendarea
#define blendline               	_FEI_blendline 
#define clipbox                 	_FEI_clipbox 
#define defcursor               	_FEI_defcursor 
#define draw                    	_FEI_draw 
#define drawbitmap              	_FEI_drawbitmap 
#define drawsymbols             	_FEI_drawsymbols 
#define fgcolor                 	_FEI_fgcolor 
#define flushbuffer             	_FEI_flushbuffer 
#define hidecursor              	_FEI_hidecursor 
#define linestring              	_FEI_linestring 
#define linestyle               	_FEI_linestyle 
#define move                    	_FEI_move 
#define pnt                     	_FEI_pnt 
#define popattributes           	_FEI_popattributes 
#define polyf                   	_FEI_polyf 
#define pushattributes          	_FEI_pushattributes 
#define rectf                   	_FEI_rectf 
#define showcursor              	_FEI_showcursor 
#define vsync                   	_FEI_vsync 
#define weight                  	_FEI_weight 

#define Get_scrap			_FEI_Get_scrap
#define Put_scrap			_FEI_Put_scrap

#endif
