/*
  ACcpx_defni.I
  robert patience
  21_jul_86
*/
class implementation ACcpx_defn;

#include "ctype.h"
#include "ASmacroi.h"
#include "macro.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"

#define AS_DEBUG

extern GRclassid OPP_ACtmp_defn_class_id;
from ACtmp_defn import ACset_mac_name;
 
method ACreturn_symb_def(struct GRid *symb;GRspacenum osnum)
{
 struct GRid my_grid;
 char file_name[OM_K_MAXOSNAME_LEN];
 IGRlong status;
 IGRint invisible_index;

/*" return symbolic definition valid for myself in the OS %d\n", osnum */

/* Is this definition already in the hcode table */
 
my_grid.objid = my_id;
my_grid.osnum = OM_Gw_current_OS;

ACret_in_real(my_grid,symb,1);


if(IF_NULL_OBJID(symb->objid))
  {
    ACos_to_path(OM_Gw_current_OS,file_name,&invisible_index);
    if(file_name[0] == '\0')
      {
       status = om$os_number_to_name(osnum = OM_Gw_current_OS,
				     osname = file_name);
       as$status();
      }
    status = om$construct(osnum = osnum,
			  p_objid = &symb->objid,
		          classid = OPP_ACtmp_defn_class_id);		 
    as$status();
    symb->osnum = osnum;
    status = om$send(msg = message ACtmp_defn.ACset_mac_name
						(file_name,me->macro_name),
		     targetos = symb->osnum,
		     targetid = symb->objid);
    as$status();
    ACadd_in_symbol(*symb,my_grid,1);
  }


/*" %d %d return %d %d\n",my_id,OM_Gw_current_OS,symb->objid,symb->osnum */

return (OM_S_SUCCESS);
 
}

/* Return the real definition of the macro */

method ACreturn_real_def(struct GRid *real;char *h_code)
{
/* I am the real definition */

 real->objid = my_id;
 real->osnum = OM_Gw_current_OS;
 return(OM_S_SUCCESS);
}
 
end implementation ACcpx_defn;
