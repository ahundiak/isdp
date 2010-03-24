#target /usr/shlib/libmsg_s
##
##
##	The addresses are kept up with by the OM group so that
##	no conflict occurs between the shared libraries provided by
##	C, tools, OM, exec, and this one, the message shared library.
##
#address .text 0xf5800000
#address .data 0xf5c00000
##
##	This is a list of functions that are in the message system
##	shared library.
##
#branch
        _MS_init 1
        _MS_dis_msg 2
        _MS_out_msg 3
        _MS_fix_type 4
        _MS_format_message 5
	_MS_function 6
        _MS_init_file 7
        _MS_init_files 8
	_MS_file_init 9
        _MS_retrieve_msg 10
        _MS_search_table 11
        _MSon 12
        _MSoff 13
        _MSset 14
        _MS_onoff 15
	_MSerrbox 16
	_MS_display_message 17
	_MSmessage 18
	_MS_draw_func 19
	_MS_size_func 20
	_MSgetfont 21
	_MSmemory_init 22
	_MS_malloc 23
	_MS_free 24
	_MSget_message 25
##
##	This is a list of object files that compose the message shared
##	library.
##
#objects
        MSimport.o
        MSglobal.o
        MSmsg.o
        MSretmsg.o
        MSonoff.o
        MSfile.o
	MSerrbox.o
	MSdismsg.o
	MSmemory.o
	MSgmessage.o
##
##	These are the symbols that the message system references that
##	are not defined by the message system.  
##
#init MSimport.o
        _lmsg_strcpy _strcpy
        _lmsg_strcat _strcat
        _lmsg_strchr _strchr
        _lmsg_strlen _strlen
        _lmsg_strcmp _strcmp
        _lmsg_malloc _malloc
        _lmsg_realloc _realloc
        _lmsg_sprintf _sprintf
        _lmsg_printf _printf
        _lmsg_fgets _fgets
        _lmsg_fscanf _fscanf
        _lmsg_fclose _fclose
        _lmsg_fopen _fopen
        _lmsg_atoi _atoi
        _lmsg_Display_message _Display_message
        _lmsg_EX_getpath _EX_getpath
        _lmsg_EX_get_global _EX_get_global
        _lmsg_UI_prompt _UI_prompt
        _lmsg_Create_fpu _Create_fpu
        _lmsg_Set_fmne_fgcolor _Set_fmne_fgcolor
        _lmsg_Set_fmne_font _Set_fmne_font
        _lmsg_Display_fpu _Display_fpu
        _lmsg_Update_fmne _Update_fmne
        _lmsg_hidecursor _hidecursor
        _lmsg_showcursor _showcursor
        _lmsg_flushbuffer _flushbuffer
        _lmsg_Wait_for_events _Wait_for_events
        _lmsg_Get_button_data _Get_button_data
        _lmsg_Exit_fpu _Exit_fpu
	_lmsg__ctype __ctype
        _lmsg_sleep _sleep
	_lmsg_Set_message_font _Set_message_font
	_lmsg_Set_message_draw_func _Set_message_draw_func
	_lmsg_Set_message_size_func _Set_message_size_func
	_lmsg_FSGetBmapInfo _FSGetBmapInfo
	_lmsg_fgcolor _fgcolor
	_lmsg_FSDrawChar _FSDrawChar
	_lmsg_FSGetBmapCharInfo _FSGetBmapCharInfo
	_lmsg_Inq_message_text_size _Inq_message_text_size
	_lmsg_FSNewFont _FSNewFont
	_lmsg_FSDefCharMap _FSDefCharMap
	_lmsg_FSReadCharMapFile _FSReadCharMapFile
	_lmsg_EX_inq_language _EX_inq_language
	_lmsg_access _access
	_lmsg_FSGetOutlInfo _FSGetOutlInfo
	_lmsg_FSGetOutl3DDrawFunc _FSGetOutl3DDrawFunc
	_lmsg__FSDrawOutline3D __FSDrawOutline3D
	_lmsg_FSSetOutl3DDrawFunc _FSSetOutl3DDrawFunc
	_lmsg_FSGetOutlCharInfo _FSGetOutlCharInfo
	_lmsg_EXinq_locale _EXinq_locale
	_lmsg_EX_inq_language _EX_inq_language
	_lmsg_FEread_font _FEread_font
	_lmsg_FEadd_font _FEadd_font
	_lmsg_free _free
	_lmsg_Wait_timer _Wait_timer
