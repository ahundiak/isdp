/* ------------------  sli_do_class  ---------------------------------*/
#include <sli.h>

sli_do_class ( exec, class, act )
  char		* exec;
  char		* class;
  char		* act;
{
  sli_do_act ( exec, act );
  strcpy ( class, strip_quotes ( class ));
  ( * cur_act_list )->list.prev->class = class;
}
