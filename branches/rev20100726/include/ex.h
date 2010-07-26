
/*ex.h*/
#ifndef ex_include
#define ex_include

#ifndef OM_D_MINIMUM
#include <OMminimum.h>
#endif

#ifndef igrtypedef_include
#include <igrtypedef.h>
#endif


#ifdef DEBUG
#define DDT(X) X
#else
#define DDT(X)
#endif

#include <exfi.h>




	/*
	 *
	 *   This include file is dependent on the following include files:
	 *
	 *	igrtypedef.h
	 *	OMlimits.h
	 *	OMminimum.h
	 *
	 */


extern OM_S_OBJID EX_active_module;
extern OMuword EX_active_OS_num;
extern int active_module_num;
extern OMuword OM_Gw_max_modules;
extern OMuword OM_Gw_max_ref_files;

extern int EX_max_modules;
extern int EX_max_ref_files;
/* Executive structures for events                                      */


struct  EX_button                       /* button structure             */
{
    IGRdouble   x;                      /* x coordinate ( in WCS )      */
    IGRdouble   y;                      /* y coordinate ( in WCS )      */
    IGRdouble   z;                      /* z coordinate ( in WCS )      */
    IGRlong     window;                 /* hardware window number       */
    OM_S_OBJID  objid;                  /* object id of the gragad      */
    uword       osnum;                  /* space # of window            */
    IGRshort    numb;                   /* button number                */
    IGRshort    clicks;                 /* transition state UP, DOWN,etc*/
    IGRshort    button_down;            /* 1 = down, 0 = up             */
};


struct EX_mouse
{
    int window;
    short x;
    short y;
    int wflag;
};


struct module_params
{
  int visible_flag;
  OM_S_OBJID module_id;
  char CS_OS_name[OM_K_MAXOSNAME_LEN];
};

struct module_instance_data
{
  int visible_flag;
};

struct EX_visible_module
{
  uword obj_space_num;
  OM_S_OBJID module_my_id;
  OM_S_OBJID filed_id;
  int        permis_flag;
  int        no_scn_menu;
/*  char       search_path[200]; */
};

struct EX_invisible_module
{
  uword obj_space_num;
  OM_S_OBJID module_my_id;
  OM_S_OBJID filed_id;
  int permis_flag;
  int numof_opens;
  int ref_flag;
};

struct EX_global
{
    IGRchar   filename[OM_K_MAXOSNAME_LEN];
                  /* current master file name(no directory path*/
                  /* filename < 15 on clipper and filename + working dir*/
                  /*     < OM_K_MAXOSNAME_LEN on X platforms*/
    IGRchar   working_dir[OM_K_MAXOSNAME_LEN];
                  /*directory where saved file is     */
    IGRchar   support_dir[OM_K_MAXOSNAME_LEN]; 
                  /*  /usrx/ige/                      */
    IGRint    module_type;
};

struct EX_var_list
{
    IGRint    var;   /* #defines in EX_def.h. EX_MODULE_TYPE...etc.*/
    IGRchar   *var_value; /* address of variable    */
    IGRint    *num_bytes;  /* when mode = EX_SET                */
                           /*     *num_byte = size of  variable */
                           /* when mode = EX_INQ                */
                           /*   *num_byte = size of variable on input */
                           /*   *num_byte = size returned on output   */   
};


struct EXlstcol
{
	IGRint stat;
	OM_S_OBJID oid;
	IGRchar string[256];
};


struct EXlstfnt
{
	IGRint	    fontid;
	IGRdouble   size;
	IGRdouble   rotation;
	IGRchar	    typeface[64];
	IGRint	    len;        
};


struct EX_form_data_st
{
    char form_name[20];
    struct EXFI_data_st data;
};


struct EX_cmd                           /* command structure                */
{
    IGRchar *msg_key_ptr;               /* ptr to message file key          */
    IGRchar *command_name_ptr;          /* ptr to command name in msg table */
    int command_nbytes;
    IGRchar command_key[13];            /* command key                      */
    IGRchar class_name[13];             /* class name                       */
    IGRlong type;                       /* cmd type                         */
    IGRlong exec_flag;                  /* values defined in exdef.h        */
    IGRlong immediate_flag;		/* 0     - suspend previous cmd     */
					/* 1     - immediate cmd            */
    IGRchar *path;                      /* the path of the config dir       */
    IGRchar *input_string;              /* string to be put on the s queue  */
    IGRlong invis_cmd;                  /* 0     - visible command          */
                                        /* 1     - invisible to print cmd   */
    IGRchar *dload_name_ptr;
};

/* warning : if you want to use path or input_string, you must copy it    */
/*           to a local variable and use the local variable.              */
/*     You will corrupt the command_table if you concatenate any string   */
/*     to the path or input_string.					  */




struct EX_echo_button
{
   OM_S_OBJID   objid;
   OMuword      osnum;
   int              x;   
   int              y;   
   int          btype;
   int          state;
   int        timetag;
 };
struct EX_funnode
{
    int isfun;  /* if 0 it's a cmdkey otherwise it's a fun */
    union {
      int  (*fun)(); 
      char *cmdkey;
    } entry;
    struct EX_funnode *next;
    struct EX_funnode *prev;
};

 
#endif
