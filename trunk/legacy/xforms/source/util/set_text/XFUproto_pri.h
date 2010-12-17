/****************************************************************/
/* XFUproto_pri.h -                                             */
/*    This is the X/Forms (XFORMSDP SN01252) ANSI-C             */
/*    function prototype header file for private functions      */
/****************************************************************/
/* Copyright 1992 Intergraph Corporation                        */
/* All Rights Reserved, Including this Release Note, the        */
/* Product it Describes, its File Formats, and Visual Displays  */
/****************************************************************/


#ifndef XFUPROTO_PRI_H_INCLUDED 
#define XFUPROTO_PRI_H_INCLUDED 1

/* #include "FIgadget.h" */
#include "getsetdef.h"

    /***********************************/
    /***  X/Forms Utility Functions  ***/
    /***********************************/


/* main.c */
extern void notification_routine(void);

/* set_text.c */
extern int FIf_set_text(Form form_ptr, FILE *infp, char *form_name, char *text_file_name);

#endif
