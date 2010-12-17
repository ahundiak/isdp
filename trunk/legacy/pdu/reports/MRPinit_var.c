#include "MRPstr.h"
#include "MRPmacros.h"
#include "MRPmessage.h"
#include "PDUstr.h"
#include "PDUproto.h"


extern struct MRPvar  *mrpvar;
extern FILE 	*rMRPdbg_fileptr;
extern char **string_buffer;
extern char **cd_str_buffer;
extern char **env_str_buffer;
extern char **flag_str_buffer;
extern char **file_str_buffer;
extern char **cat_str_buffer;
extern char **prt_str_buffer;
extern int MRPsingle_select;
extern int MRPuser;
extern int MRP_debug_on;

int MRPalloc_var ()
{
  /* allocate mrpvar if none exists */

if ( mrpvar == NULL )
     {
/*     _mrp_debug_mes("malloc for mrpvar"); */
     mrpvar = (struct MRPvar *) malloc( sizeof(struct MRPvar) );
/*     if ( mrpvar == NULL)
        _mrp_debug_mes("Could not malloc mrpvar"); */
     }

if ( mrpvar )
    {
     /* initialize mrp fields  */  
     mrpvar->name = NULL;
     mrpvar->passwd = NULL;
     mrpvar->pitemno = 0;
     mrpvar->bomname = NULL;
     mrpvar->catno = 0;
     mrpvar->catalog = NULL;
     mrpvar->partid = NULL;
     mrpvar->revision = NULL;
     mrpvar->filename = NULL;
     mrpvar->code = NULL;
     mrpvar->codeno = 0;
     mrpvar->code_desc = NULL;
     mrpvar->attr = NULL;
     mrpvar->attr_desc = NULL;
     mrpvar->environment = NULL;
     mrpvar->width = 0;
     mrpvar->command = 0;
     mrpvar->list_position = -1;
     mrpvar->status = -30;

     mrpvar->options = NULL;
     mrpvar->part_list = NULL;
     mrpvar->bom_list = NULL;
     mrpvar->cat_list = NULL;
     mrpvar->code_list = NULL;
     mrpvar->file_list = NULL;
     mrpvar->attr_list = NULL;
     mrpvar->env_list = NULL;
     mrpvar->transcodes_buff = NULL;
     mrpvar->transattr_buff = NULL;
     mrpvar->item = NULL;
     mrpvar->item2 = NULL;
     mrpvar->aux_ptr1 = NULL;
    }
return( MRP_S_Success );
}
