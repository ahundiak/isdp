class implementation Root;

#include "stdio.h"
#include "stdlib.h"
#include "string.h"
#include "OMindex.h"
#include "OMlimits.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igrdp.h"
#include "igr.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "dp.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "igrdef.h"
#include "exmacros.h"
#include "griomacros.h"
#include "grerr.h"
#include "OMmacros.h"
#include "dpdef.h"
#include "dpmacros.h"

#define ASM_INVALID_SEEDFILE 2

/** Extern Variable Seedfile **/
extern char EX_seedfile[];



IGRint rfCreateRefFile( IGRlong *msg, IGRchar *filename)
{

  struct GRmd_env md_env,ref_mod;
  IGRchar seed_file[DI_PATH_MAX];
  IGRint   sts,rc;
  IGRint   file_no;
  IGRchar  path[250];
  IGRchar  cmd[128];
  IGRchar  copyos[DI_PATH_MAX];
  IGRint   master_units;
  IGRint   seed_units;
  IGRlong  nbytes_in_buff, nbytes_trans;

  copyos[0] = NULL;
  seed_file[0] = NULL;
  sts = 0;
 
  /** Get the current Module environment **/
 
  nbytes_in_buff = sizeof(struct GRmd_env);
  sts = gr$get_module_env(msg = msg,
                          sizbuf = &nbytes_in_buff,
                          buffer = &md_env,
                          nret = &nbytes_trans);
  if(!(*msg & sts & 1))
  {
     goto quit;
  }
 
  ASMget_product_data("Exnuc",NULL,NULL,NULL,NULL,copyos);
  if(copyos[0] == NULL)
  {
     printf("Failed to find Exnuc in product_data\n");
     *msg = MSFAIL;
     sts = OM_E_ABORT;
     goto quit;
  }
 
  strcat(copyos,"bin/copyOS");
 
  /* get the default seedfile */
  if(!EX_get_seed_file(EX_seedfile,seed_file))
  {
     printf("Failed to find default seedfile\n");
     *msg = MSFAIL;
     sts = OM_E_ABORT;
     goto quit;
  }
 
  /* check for database units */
  sts = co$unit_database_type(osnum = md_env.md_id.osnum,
                              db_type = &master_units);
  if(sts == MSSUCC)
  {
     DIstmocpy ( path, "ref", seed_file, 0, md_env.md_id.osnum );
 
     sts = ex$retrieve_module(
            msg = &rc,
            filename=seed_file,
            flag=EX_read_only,
            ftype = EX_invisible,
            fstat=EX_old_module,
            type = EX_ref,
            mod_type = 2,
            mount_name = path,
            file_no=&file_no);
     if (!( 1 & sts))
     {
        printf("retrieve_module failed: sts = %d, msg = %d\n", sts, *msg);
        *msg = MSFAIL;
        goto quit;
     }
 
     sts = ex$get_invis_info_by_index(
            index = file_no,
            mod_id = &ref_mod.md_id.objid,
            mod_osnum = &ref_mod.md_id.osnum);
     if (!( 1 & sts)) 
           printf("Get ref info: sts = %d\n", sts);
 
     /* get the seedfile database units type */
     sts = co$unit_database_type(osnum = ref_mod.md_id.osnum,
                                 db_type = &seed_units);
     /* close the seedfile */
 
     ex$close_module(ftype = EX_invisible, flag = 0,index = file_no);
     if(sts == MSSUCC)
     {
        if(master_units != seed_units)
        {
           *msg = ASM_INVALID_SEEDFILE;
           sts = OM_E_ABORT;
           goto quit;
        }
     }
  }
 
  if(strcmp(seed_file,filename) != 0)
  {
      sprintf(cmd,"%s %s %s",copyos, seed_file, filename);
 
      /* Fork the copyOS command */
      system(cmd);
  }
 
quit:
  return(OM_S_SUCCESS);
}

end implementation Root;
