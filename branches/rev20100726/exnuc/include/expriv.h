
#ifndef expriv_include
#define expriv_include
#ifndef igrtypdef_include
#include "igrtypedef.h"
#endif
#ifndef ex_include
#include <ex.h>
#endif
#include "OMminimum.h"

#define	        EX_RETRIEVE_FILE_FORM 1

#define         MATCH 1
#define         EXACT_MATCH 2
#define         TOTAL_MATCH 3
#define         NO_MATCH -1
#define         AMBIGUOUS -2
#define         NEED_MORE -3
#define         IGNORE    -4
#define         BAD_KEYIN -5


#define         BLANK ' '
#define         CR 13
#define         DEL 127
#define         EXSUCC 1
#define         EXFAIL 0


#ifndef         NULL
#define         NULL            0
#endif
#ifndef         TRUE
#define         TRUE            1
#endif
#ifndef         FALSE
#define         FALSE           0
#endif

/* error codes returned from EXgetq and EXputq                          */

#define EXs_success              1      /* no error                     */
#define EXe_inv_nbytes          -1      /* invalid # bytes              */
#define EXw_ev_trunc            -1      /* event truncated              */
#define EXe_no_mem              -1      /* no memory available          */
#define EXe_queue_empty         -1      /* event queue is empty         */


/* structure for event queue management                                 */

#ifndef BACK
#define BACK 0
#endif
#ifndef FRONT
#define FRONT 1
#endif

#define EX_RCL_MAX_ENTRY     10
#define EX_RCL_MAX_LEN       257

struct EXevent_queue
{
    struct EXevent_queue *next;         /* points to next node          */
    struct EXevent_queue *prev;         /* points to previous node      */
    IGRlong     response;               /* response of event            */
    IGRlong     byte_count;             /* nbytes of buffer event       */
    IGRchar     buffer[1];              /* event data                   */
};

struct EX_cmd_ndx                       /* command table index table    */
{
    int    lo;                     /* index to 1st entry           */
    int    hi;                     /* index to last entry          */
};


struct EX_cmd_cntrl                     /* command control table        */
{
    int no_of_cmd;                 /* number of commands in table  */
    IGRlong mod_type;                   /* module type using table      */
    IGRshort reference_count;           /* number of modules using it   */
    struct EX_cmd_ndx *cmd_ndx;         /* command table index          */
    struct EX_cmd     *cmd;             /* command table                */
    struct EX_cmd_cntrl *next;          /* ptr to next link list entry  */
};

struct EX_paper_cmd                     /* paper menu command structure */
{
    int  x1;				/* lower left point */
    int  y1;
    int  x2;				/* upper right point */
    int  y2;
    int  resp;				/* response data     */
    char *input_string;                 /* string to be put on the s queue */
};

struct EX_pmenu_entry   /* paper menu entry */
{
   OM_S_OBJID win_id;   
   int  num_of_cmds;
   struct EX_paper_cmd *p_cmd;
   char menu_name[128];
};



struct OM_sd_OS_construct_args
{
  char                  *s_name;     /* pointer to name string */
  unsigned int          i_initsize;  /* NULL =>use default */
  int                   i_extsize;   /* negative number => no extension */
  unsigned int          i_init_number_objects; /* NULL =>use default */
  int                   i_extcount;  /* negative number => no extend total
                                           object count */
  unsigned int          i_number_objs;  /* number of objects in space after
                                           construct. 1=> "fresh OS" */
};
typedef struct  OM_sd_OS_construct_args       OM_S_FILEDOS_CONSTRUCT_ARGS;

struct EX_cmd_instring
{
   char *instring;
   int  size_avail;
   struct EX_cmd_instring  *next;
};

struct EX_nl 
{
   char name[15];
   struct EX_nl *next;
   struct EX_nl *prev;
};


struct EX_cmd_mode_resp_data
{
    int   mode;
    char  string[128];
};

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

extern int FEI_set_form_icon_path __((void));
extern int get_modtype_data __((char *run_name, char *logo_ptr, char *module_class, char *srch_path, char *config_path, char *product_path));
extern int EX_get_dependency __((char *srch_path, struct EX_nl *na));
extern int EX_session_init_cmd __((struct EX_cmd_cntrl *cmd_cntrl));
extern int EX_file_init_cmd __((struct EX_cmd_cntrl *cmd_cntrl));
extern IGRint EX_cmdattach __((IGRlong *msg, IGRlong module_type, struct EX_cmd_cntrl **cmd_cntrl));
extern int EX_file_create_list __((char **entry, int *num_of_entry));
extern int EX_shutdowncmd __((struct EX_cmd_cntrl *cmd_cntrl));
extern int EX_get_cmd_info __((char *string, int mode, struct EX_cmd *cmdstr));
/* init.C */
extern IGRint EX_cmdinit __((IGRlong module_type, struct EX_cmd_cntrl **cmd_list));
extern IGRlong EX_cmdsrch __((IGRlong *msg, struct EX_cmd_cntrl *cmd_cntrl, IGRchar *keyin, struct EX_cmd *cmd, IGRint *response));

/* mod_type.C */
extern int EX_rm_dup_dep __((char *srch_path1, struct EX_nl *name));

extern int EX_exit_function __((int (*function_to_execute )(),
		int (**function_previous )()));

extern int EX_exit_function_no_save __((int (*function_to_execute )(),
		int (**function_previous )()));

extern int EX_retrieve_function __((int (*function_to_execute )(),
		int (**function_previous )()));
extern int EX_save_function __((int (*function_to_execute )(),
		int (**function_previous )()));
extern int som_is_om_file __((char *filename, short *p_major, short *p_minor,
		char *p_mach_type, int *p_file_type));

#if defined(__cplusplus)
}
#endif

/*----------------------------------------------------------------------------*/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
**     ex$retrieve_function
**
**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
**
**  This macro will set up a function to be called from the retreive
**  command prior to retrieving the file.  This will give an opportunity
**  to operate on the file prior to the executive actually opening it
**  for read.  You may also change the filename during the execution of
**  the specified retrieve function, and the executive will open the
**  new file.
**
**  This macro will return the pointer to the previously defined retreive
**  function if one exists in the prev_function argument.  If a function
**  has not previously been defined,  a NULL will be returned in the
**  prev_function argument.
**
************************************************************************
**
**  Example of a macro call to set up a retrieve function
**
**  int  (*prev_function)();
**  int  (*retrieve_function)();
**
**   ex$retrieve_function ( function = retrieve_function,
**                          previous_function = &prev_function );
**
**
************************************************************************
**
**  Example of a user retrieve function
**
**  The retrieve function will receive the input filename as its only
**  argument
**
**  The buffer size of this filename is OM_K_MAXOSNAME_LEN which is 
**  defined in OMlimits.h
**
**  int retrieve_function ( file_name )
**  char *file_name;
**  {
**    char new_name[OM_K_MAXOSNAME_LEN];
**
**    .... code ....
**
**    if (prev_function)
**      (*prev_function)(file_name);
**
**    .... more code ....
**
**    if (everything_okay)
*     {
**      if (file_name_changed)
**           strncpy (file_name,new_name,OM_K_MAXOSNAME_LEN);
**      return (OM_S_SUCCESS);
**    }
**    else
**      return (SOME_ERROR);
**  }
**
************************************************************************
**
**  Status Returns from a user retrieve function
**
**    OM_S_SUCCESS - success
**    some defined failure code
**
**
**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

#omdef ex$retrieve_function ( function, previous_function )
    EX_retrieve_function ( function, previous_function )
#endomdef


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
**     ex$save_function
**
**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
**
**  This macro will set up a function to be called from the save
**  command after saving the file.  This will give an opportunity
**  to operate on the file after the save.
**
**  This macro will return the pointer to the previously defined save
**  function if one exists in the prev_function argument.  If a function
**  has not previously been defined,  a NULL will be returned in the
**  prev_function argument.
**
************************************************************************
**
**  Example of a macro call to set up a save function
**
**  int  (*prev_function)();
**  int  (*save_function)();
**
**   ex$save_function ( function = save_function,
**                          previous_function = &prev_function );
**
**
************************************************************************
**
**  Example of a user save function
**
**  The save function will receive the input filename as its only
**  argument
**
**  The buffer size of this filename is OM_K_MAXOSNAME_LEN which is 
**  defined in OMlimits.h
**
**  int save_function ( file_name )
**  char *file_name;
**  {
**    char new_name[OM_K_MAXOSNAME_LEN];
**
**    .... code ....
**
**    if (prev_function)
**      (*prev_function)(file_name);
**
**    .... more code ....
**
**    if (everything_okay)
*     {
**      if (file_name_changed)
**           strncpy (file_name,new_name,OM_K_MAXOSNAME_LEN);
**      return (OM_S_SUCCESS);
**    }
**    else
**      return (SOME_ERROR);
**  }
**
************************************************************************
**
**  Status Returns from a user save function
**
**    OM_S_SUCCESS - success
**    some defined failure code
**
**
**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

#omdef ex$save_function ( function, previous_function )
    EX_save_function ( function, previous_function )
#endomdef



/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
**     ex$exit_function
**
**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
**
**  This macro will set up a function to be called after the exit command 
**  has written the file to disk.  This "exit" function will be called
**  after the executive has written a file to disk as a consequence of
**          1) exit=y
**          2) close=y
**
**  The user exit function will receive the filename and a flag as its two
**  arguments
**
**  The macro will return the previously defined exit_function in the
**  argument prev_function if one exists - otherwise it will return a NULL
**  for the prev_function
**
**  Sample call:
**
**    static int  (*prev_function)();
**
**    status = ex$exit_function( function = exit_function,
**                               previous_function = &prev_function)
**
**  Status Returns
**
**    OM_S_SUCCESS - success
**    some defined failure code
**
**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
**
**  Example of a user exit function
**
**  The user exit function will receive two arguments
**         1)  char *file_name    file that was just written
**         2)  int   flag         flag to designate exit or save
**                                (currently set to 0 always for exit)
**
**    The buffer size of file_name is OM_K_MAXOSNAME_LEN
**
**  int exit_function ( file_name, flag )
**  char *file_name;
**  int   flag;
** 
**  {
**    .... code ....
**
**    if (prev_function)
**      (*prev_function)(file_name);
**
**    .... more code ....
**
**    if (everything_okay)
**          return (OM_S_SUCCESS);
**    else
**          return (SOME_ERROR);
**  }
*************************************************************************
*/

#omdef ex$exit_function ( function, previous_function )
    EX_exit_function ( function, previous_function )
#endomdef

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
**     ex$exit_function_no_save
**
**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
**
**  This macro will set up a call to a user function when any of the
**  following occur
**
**          1) exit=n
**          2) close=n
**          3) retrieve=n
**
**  The user exit function will receive the filename and a flag as its two
**  arguments
**
**  The macro will return the previously defined exit_function in the
**  argument prev_function if one exists - otherwise it will return a NULL
**  for the prev_function
**
**  Sample call:
**
**    static int  (*prev_function)();
**
**    status = ex$exit_function_no_save( function = exit_function_no_save,
**                               previous_function = &prev_function)
**
**  Status Returns
**
**    OM_S_SUCCESS - success
**    some defined failure code
**
**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
**
**  Example of a user exit function
**
**  The user exit function will receive two arguments
**         1)  char *file_name    file that was just written
**         2)  int   flag         (currently set to 0 always for exit)
**
**    The buffer size of file_name is OM_K_MAXOSNAME_LEN
**
**  int exit_function_no_save ( file_name, flag )
**  char *file_name;
**  int   flag;
** 
**  {
**    .... code ....
**
**    if (prev_function)
**      (*prev_function)(file_name);
**
**    .... more code ....
**
**    if (everything_okay)
**          return (OM_S_SUCCESS);
**    else
**          return (SOME_ERROR);
**  }
*************************************************************************
*/

#omdef ex$exit_function_no_save ( function, previous_function )
    EX_exit_function_no_save ( function, previous_function )
#endomdef


/*
**-------------------------------------------------------------------
**
**   macro:  ex$is_om_file
**
**     Will return TRUE (1) if given file is an OM object space of
**      either 4.4 (1.1) 
**             4.5 (1.2)
**             1.3 
**             1.4
**             2.0 (and above)
**
**     Otherwise return FALSE (0).
**
**   Arguments:
**
**       Type          Name         I/O          Description
**      ______    _______________   ___  __________________________________
**
**      char *    filename           I   Name of file to check
**      short *   p_major            O   Major version number of file
**      short *   p_minor            O   Minor version number of file
**      char *    p_mach_type        O   Machine type of file (C,S,...)
**      int *     p_file_type        O   User defined file type (cell,sheet...)
**
**
**     If file is an OM object space the function will also fill in
**      the major and minor version numbers (1.1, 1.2, 1.3, 1.4, 2.0, ...)
**
**     Also as an added bonus for 2.0 files and up - we'll return the 
**     machine type (such as C for Clipper, S for Sun, etc).  If its is 
**     less than a 2.0 file then a NULL will be returned.
**
**     Hey - why we're being so generous - we'll also return the field
**     in the header which specifies the user defined file type (such
**     as Ems_cell_file, Ems_drawing_file, etc).  Once again, if the
**     file is less than a 2.0 file then a NULL will be returned.
**
**     And since you called today - we'll throw in a set of Ginsu knives,
**     a bamboo steamer, and some wind chimes.
**
**-------------------------------------------------------------------
*/

#omdef ex$is_om_file ( filename, p_major, p_minor, p_mach_type, p_file_type )
    som_is_om_file ( filename, p_major, p_minor, p_mach_type, p_file_type )
#endomdef

#endif
