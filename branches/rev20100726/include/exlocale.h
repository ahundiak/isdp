#ifndef ex_locale
#define ex_locale
#include <stdio.h>

struct EX_fonts
{
int properties;
short body_size;
char name[40]; /*logical font name*/
char tf[15]; /*typeface found in /usr/FS/typeface*/
char cm[15]; /*character mapping in config/lang/cm*/
char ff[15]; /* font file */
};

struct EX_alias_name
{
    IGRchar 		   name[15];
};

struct EX_alias 
{
    IGRint		   number_alias;
    IGRchar                alias[15];
    struct EX_alias_name   *name;
    struct EX_alias 	   *next;
};

/*properties word*/
/*  bit0 =,  0 for 7 bit,             =1 for 16 bit font*/
/*  bit1 =,  0 for outline font,      =1 for bitmap font*/
/*  bit2 =,  0 for non fraction font, =1 for fraction font */

struct EX_next_font /*this structure is used in EX_locale_struct*/
{
struct EX_next_font *ptr_next;
struct EX_fonts desc;
};


struct EX_locale_struct
{
int pid;                  /*pid of logical keyboard*/
char language[80];        /*language of this locale*/
char logkbd[80];          /*logical keyboard full path*/
char def_msg_font[15];
char def_text_font[15];
char def_msg_font16[15];
char def_text_font16[15];
struct EX_next_font *font; /*pointer to all fonts for this locale*/
struct EX_locale_struct *next;
struct EX_alias         *alias; /* pointer to aliases for this font */
int  sdbflag;
};

/* rc = 0 keyin.C sends hardware key to keyboard process*/
/* rc = 1 requests keyboard process to send pid to exec*/
struct EX_logkbd_buf
{
int rc;
int nbytes;
union
 {
 char buffer[1024];
 int int_data;
 }data;
};

struct EX_locale_var
{
    IGRint  var;
    void *var_ptr;    /* generic pointer.  case of var to determine ptr type */
};

#define EX_No_Flags    -1

/*----------------------------------------------------------------------------*/
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
/*keyin.C*/
extern int EX_translate_funckey __((short entry,struct EX_logkbd_buf *buf));
extern int EX_translate_funckey1 __((short entry,struct EX_logkbd_buf *buf,
                                    int mode));
/* exfont.C */
extern int EX_read_font_table __((IGRchar *language, struct EX_locale_struct *locale));
extern int EX_read_font_line __((IGRchar *line, struct EX_locale_struct *locale, int *p_err_num));
extern int EXprocess_alias __((IGRchar *line));
extern int EXget_alias __((IGRchar *alias_name, struct EX_alias *alias));

/* exlanguage.C */
extern int EX_set_language __((IGRchar *language));
extern int EX_inq_language __((IGRchar *language));

/* exlocale.C */
extern void EX_set_locale __((IGRint flag, IGRchar *language));

/* exlocinit.C */
extern int EX_init_locale __((void));
extern int EX_default_init __((struct EX_locale_struct *locale));
extern char *EXfgets __((IGRchar *string, IGRint size, FILE *locale_file));

/* exlogkbd.C */
extern int EX_create_logical_keyboard __((void));
extern int EX_syserror __((char *msg));

/* exreadloc.C */
extern int EX_read_locale __((struct EX_locale_struct *locale, FILE *file));

/* exset_inq.C */
extern int EXset_locale __((IGRlong *msg, IGRint count, IGRint *which_error, struct EX_locale_var *var, IGRint flags, IGRchar *identifier));
extern int EXinq_locale __((IGRlong *msg, IGRint count, IGRint *which_error, struct EX_locale_var *var, IGRint flags, IGRchar *identifier));
extern int EX_get_font __((IGRlong *msg, struct EX_locale_struct *locale, IGRchar *identifier, struct EX_fonts *parameters, IGRint flags));
extern int EXfont_number __((struct EX_locale_struct *locale));
extern int EXfill_font __((struct EX_locale_struct *locale, struct EX_fonts temp_font[]));


#if defined(__cplusplus)
}
#endif

/*----------------------------------------------------------------------------*/

/*
	This macro will set the structues assocaited with the locale.
	The arguments are as follows:
	
	IGRint		count		How many items to set
	IGRint		*which_error	If there is more than one item to
	                                be set and an error occured, where
	                                did the error occur.

 struct EX_locale_var   *var            This will specifiy what is to be set.
 					If count is greater than 1 this will
 					be an array.
 					
	IGRint		flags		TBD
	IGRchar		*identifier     TBD
	
*/

#omdef ex$set_locale (msg, count = 1,
                      which_error = NULL,
                      var,
                      flags = EX_No_Flags,
                      identifier = NULL)

    EXset_locale ((msg),  (count), (which_error), (var), (flags), (identifier) )
    

#endomdef

/*
	This macro will inquire the structues assocaited with the locale.
	The arguments are as follows:
	
	IGRint		count		How many items to inquire
	IGRint		*which_error	If there is more than one item to
	                                be inquired and an error occured, where
	                                did the error occur.

 struct EX_locale_var   *var            This will specifiy what is to be 
 					inquired. If count is greater than 
 					1 this will be an array.
 					
	IGRint		flags		TBD
	IGRchar		*identifier     TBD
	
*/

#omdef ex$inq_locale (msg, 
		      count = 1,
                      which_error = NULL,
                      var,
                      flags =  EX_No_Flags,
                      identifier = NULL)

    EXinq_locale ( (msg), (count), (which_error), (var), (flags), (identifier) )
    

#endomdef

/*
 *  This macro will return the active language.  The language will be
 *  determined by files in the configuration directories.  Eventually
 *  the language may be changed at runtime.  This macro will always reflect
 *  the current language.
 *
 *  Argument                Type            Description
 *
 *      language           IGRchar *          A string that shows the current
 *                                            lanugage.
 *
 *                                            The maximum length of the string
 *                                            is 14 characters.  The max size 
 *                                            of a filename in UNIX.
 *                                            
 *  Function Return Codes:
 *
 *          1           Success
 *          0           Failure
 */
 
#omdef ex$language (language)
    EX_inq_language ( (language) )
#endomdef

#endif
