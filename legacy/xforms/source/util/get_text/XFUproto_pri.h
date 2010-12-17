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

#include "FIgadget.h"
#include "BAGgetopt.h"

    /***********************************/
    /***  X/Forms Utility Functions  ***/
    /***********************************/


/* BAGgetopt.c */
extern int BAGgetopt(int argc, char **argv, char *optstring);

/* get_text.c */
extern int _FI_g_output_text(struct FIgadget_obj *gadget, FILE *outfp);
extern int FIf_get_text(Form form_ptr, FILE *outfp, char *form_name);

/* main.c */
extern void notification_routine(void);
extern void print_usage(void);
extern int API_HANDLE_SHUTDOWN(void);

#endif
