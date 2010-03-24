
/*----
%CH           
   change history: 

         ht 7/21/86          add cell btree named object
         rc 7/28/86          removed queries from named objects
         HT 1/24/88          change to 1.2 add batch
*/

class implementation module;

#include <OMindex.h>
#include <OMmacros.h>
#include <igetypedef.h>
#include <igewindef.h>
#include <igewindow.h>
#include <igewinmacros.h>
#include <exmacros.h>
#include <DItypedef.h>
#include <DIdef.h>
#include <DIglob.h>
#include <DIprims.h>
#include <string.h>

from cmdserver import init_cs;
from global_class import place, super_construct;

#define initdebug 0

extern struct EX_global EX_global_var;
extern char EX_runname[];

method mod_init( int mod_type; char *cmdsvr; int numof_supers;
                  char *listof_supers; int vis_flag)
{
  char os_name[OM_K_MAXOSNAME_LEN];
  int status;


  OM_S_OBJID            NOD_object;
  int                   vlen;

#ifdef TIMING_TEST
	EX_start_timing();
#endif

  vlen = om$dimension_of( varray = ME.module->application );

  if ((int)strlen(EX_runname) > vlen )
  {
      status = om$vla_set_dimension ( varray = ME.module->application ,
                                      size   = strlen(EX_runname) + 5 );
  }
  strcpy( ME.module->application , EX_runname);

  if (vis_flag == 1 )
  {
     EX_global_var.module_type = -1;
  }

  status = om$os_number_to_name(osnum = OM_Gw_current_OS,
                                osname = os_name);
  check_error_status(status,"OM_convert_OS_number_to_name error");
  if(!(1&status)) return(OM_W_ABORT);


 /************************************/
 /*   construct IGENOD               */
 /************************************/
  status = ex$get_NOD(NODname = "IGENOD",pobjid = &NOD_object,create=TRUE,
                        modid=my_id, mod_osnum=OM_Gw_current_OS);
  check_error_status(status,"In modinit Error constructing IGENOD object");
  if(!(1&status)) return(OM_W_ABORT);
  status=  ex$add_name_to_NOD( NODname="IGENOD", mod_osnum=OM_Gw_current_OS,
                                objname = "MODULE",objid=my_id); 
 
  status = di$mkdir( dirname="usr",osnum=OM_Gw_current_OS);
  if( ( status != DIR_S_SUCCESS)  && ( status != DIR_E_DIR_DUP) )
  {
     printf(" In modinit create usr dir error <%x>\n",status);
  }
  status = di$mkdir( dirname="ref",osnum=OM_Gw_current_OS);
  if( ( status != DIR_S_SUCCESS)  && ( status != DIR_E_DIR_DUP) )
  {
     printf(" In modinit create ref dir error <%x>\n",status);
  }
  status = di$mkdir( dirname="cell",osnum=OM_Gw_current_OS);
  if( ( status != DIR_S_SUCCESS)  && ( status != DIR_E_DIR_DUP) )
  {
     printf(" In modinit create cell dir error <%x>\n",status);
  }


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


#ifdef TIMING_TEST
	EX_end_timing("Module init time");
#endif


  return(OM_S_SUCCESS);

} /* method init */

end implementation module;

