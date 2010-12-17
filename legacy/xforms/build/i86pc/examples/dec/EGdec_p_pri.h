/****************************************************************/
/* EGdec_p_pri.h -                                             */
/*    This is the X/Forms (XFORMSDP SN01252) ANSI-C             */
/*    function prototype header file for private functions      */
/****************************************************************/
/* Copyright 1992 Intergraph Corporation                        */
/* All Rights Reserved, Including this Release Note, the        */
/* Product it Describes, its File Formats, and Visual Displays  */
/****************************************************************/


#ifndef EGDEC_P_PRI_H_INCLUDED 
#define EGDEC_P_PRI_H_INCLUDED 1

#include <X11/Xproto.h>

    /*********************************/
    /****  Dec Example Functions  ****/
    /*********************************/


/* dec.c */
extern int Syntax(char *pn, char *arg);
extern int Sync_on(void);
extern int Sync_off(void);
extern void test_note(int f_label, int g_label, double value, Form fp);
extern int init_test(char *form_name);
extern int main(int argc, char *argv[]);

/* dec_fei.c */
extern char FEI_map_character(XKeyEvent *key, unsigned char *character);

/* dec_motif.c */
extern int Check_for_DEC(unsigned char c, unsigned char *new_c);

/* dec_table.c */
extern int Check_for_DEC(unsigned char c, unsigned char *new_c);

#endif
