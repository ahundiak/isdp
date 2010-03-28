class implementation ci_macro;

#include "ASmacroi.h"
#include "parametric.h"
#include "macro.h"
#include "nddef.h"
#include "cierrordef.h"
#include "ciexecmacros.h"

from ACmacro_defn import ACgive_name;
from ci_mac_def import ACgive_cim_desc ;
from ci import set_value;

#define MAX_CHAR 	80

/*===========================================================================*/

method NDprint(struct GRmd_env *md_env; FILE *stream)
{
  IGRint        status, msg, count;             
  char          name[MAX_CHAR], *macro_name;
  struct 	ci_mac_st *desc;
  IGRint	temp_feet_num, intern_feet_num, extern_feet_num,
		i, j, succ;
  struct GRid mac_def,ci_macro_id,my_grid;
  char class_name[OM_K_MAXCLASS_LEN];

  if(test_ci1("NDprint", my_id, OM_Gw_current_OS,
                &ci_macro_id, me->internal_buffer ))
   {
     CIpushlist  arglist[2];
     my_grid.objid = my_id;
     my_grid.osnum = OM_Gw_current_OS;

     status = om$send( msg = message ci.set_value (&msg, "me",
                        me->internal_buffer, sizeof(char *)),
                      targetid = ci_macro_id.objid ,
                      targetos = OM_Gw_TransOSnum_0);

     status = om$send( msg = message ci.set_value
                  (&msg, "CI_MACRO_ID", (char *) &my_grid, sizeof(struct GRid)),
                      targetid = ci_macro_id.objid ,
                      targetos = OM_Gw_TransOSnum_0);

                arglist[0].addr = &md_env               ;
                arglist[0].size = sizeof(md_env)        ;
                arglist[1].addr = &stream               ;
                arglist[1].size = sizeof(stream)        ;


    ci$push( argc = 2, argv = arglist ) ;
    status=run_ci("NDprint" ,ci_macro_id );
   }
  else
   {
    status = om$send( msg = message ACcpx.find_macro(&mac_def),
                    targetid = my_id);
    as$status(action = RET_STATUS);

    status = om$send(msg = message ACmacro_defn.ACgive_name(&macro_name), 
		 targetid=mac_def.objid,targetos=mac_def.osnum );
    as$status ( action = RET_STATUS );

    status = om$send ( msg =message ci_mac_def.ACgive_cim_desc ( &succ, &desc,
			&temp_feet_num, &intern_feet_num, &extern_feet_num),
                   targetid=mac_def.objid,targetos=mac_def.osnum  );
    as$status ( action = RET_STATUS );

    as$printer_set_name( prefix = "CI_MACRO", name = name);


    if (strcmp(name,"")!=0)
    {
      unsigned int *dum;

      as$printer_print_parents ( count = &count );

      /* must fill the internal */
   
      for(i=0; i< (desc->int_size / 4) ; i++)
      {
        dum=(unsigned int *)  &(me->internal_buffer [ i*4 ] );
        fprintf(stream, "ci_mac_inter[%d] = %#X; \n", i,*dum);
      }

      if(desc->int_size % 4 )
      {
        fprintf(stream, "ci_mac_inter[%d] = 0x",i);

        for(j=0; j< (desc->int_size % 4) ; j++)
          fprintf(stream, "%x", me->internal_buffer [ ((i*4) + j) ] );
 
        for(j=0; j< 4 - (desc->int_size % 4) ; j++)
          fprintf(stream, "00");

        fprintf(stream, ";\n");
      }

/* To make it also work for nci_macro jla 11/oct/90 */

     om$get_classname(objid = my_id,
		    osnum = OM_Gw_current_OS,
		    classname =  class_name);
		 
    
      fprintf(stream, 
	"send %s.obj_init(&suc, \"%s\", %d, list, ci_mac_inter) to %s;\n",
	class_name,macro_name, count, name );
     }
  }
  return(OM_S_SUCCESS);
}

/*===========================================================================*/

end implementation ci_macro;

