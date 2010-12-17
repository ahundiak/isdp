#ifndef _DBA_ABD_H
#define _DBA_ABD_H

#define ABD_COMPANY     100
#define ABD_FILEDESC    101
#define ABD_PRODVER     102
#define ABD_LEGCOPY     103
#define ABD_LEGTRADE    104
#define ABD_BLKRECT     105
#define ABD_USER        106
#define ABD_USER_COMP   107
#define ABD_SERIAL_NUM  108

BOOL CALLBACK dba_about_dialog_proc(HWND, UINT, WPARAM, LPARAM);

#endif
