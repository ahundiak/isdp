/* $Id: vdgenfamfil.h,v 1.1.1.1 2001/01/04 21:07:31 cvs Exp $ */

/* I/VDS
 *
 * File:     VDSequip/slic/vdgenfamfil.h
 *
 * Description:
 *      prototype file for VDSgenfam.h 
 *
 * History:
 *      31/03/94       Chaya Rao  
 *
 *              this file is created to be a prototype file for VDSgenfam.h, 
 *              which is the include file for VDgenfamfil.sl and
 *              VDgenfamfnc.I. 
 */
#if defined(__STDC__) || defined(__cplusplus)
#ifndef __
#define __(args) args
#endif
#else
#ifndef __
#define __(args) ()
#endif
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* VDgenfamfnc.I */
int VD_get_list_data __((	char *form_ptr,
				IGRint review_only,
				IGRint family));
void VD_set_up_part_list __((   IGRchar *form_ptr,
                                IGRchar *macro_name,
                                IGRchar *macro_lib,
                                IGRchar *myfile ));
void VD_add_mesg __((           char *mess,
                                char *mess3,
                                char *form_ptr, int i));
int read_part_from_part_file __((IGRchar *form_ptr,
                                 IGRchar *macro_name,
				 IGRint  *modifyrownum,
				 IGRint  append));
int VD_part_parse __((           IGRchar sttmp[MAXWORD ]));
int VD_avoid_mess2 __((         IGRchar *form_ptr,
                                IGRint family,
                                IGRint get_serv,
                                IGRchar *save_text,
                                IGRint row));
void VDreset_messages_fields __((char *form_ptr));
int VDcheck_for_cpt __((        struct GRid *obj));
int VD_check_for_reserved_words __((IGRchar *form_ptr,
                                    IGRchar errors[MAXWORD ]));
int VD_check_family_list_attrs_names __((IGRchar *form_ptr,
                                         IGRint *check_errors,
                                         IGRchar errors[MAXWORD ]));
int VD_check_family_duplicate_attrs_names __((IGRchar *form_ptr,
                                              IGRint *check_errors,
                                              IGRchar errors[MAXWORD ]));
int VDcleanup_list __((                 IGRchar *form_ptr,
                                        IGRint gadget_number));
int VD_pars_line __((                   char *input,
                                        char *ptype,
                                        char *name,
                                        char *type,
                                        char *deflt));
void VD_post_line __((                IGRchar *output,
                                      IGRchar *ptype,
                                      IGRchar *name,
                                      IGRchar *type,
                                      IGRchar *deflt,
                                      IGRint family));

#if defined(__cplusplus)
}
#endif

