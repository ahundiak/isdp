/* ceo/get_form_oid.I */
/*
   given a label return form objid
*/
class implementation CEO;

#include <stdio.h>

#ifdef DEBUG
#include <COB_DBflags.h>
#define TFLAG ( COBtrace || CEO_debug )
#endif


method get_form_oid (
  int	  	  label;
  OM_S_OBJID	* form_oid;
  int		* index;
  int		* sts )
{
  int	  ii;

  _bugprint(bflag=TFLAG, str =
	"+CEO.get_form_oid:  label=%d, *form_oid=%d, *index=%d,  *sts=%d\n",
	var = `label, *form_oid, *index, *sts` )

  * index = -1;
  * sts = COB_E_FORM_NOT_FOUND;
  * form_oid = NULL_OBJID;

  for ( ii=0; ii < me->number_of_forms; ii++)
    {
       if ( me->forms[ii].label == label )
	 {
	    * form_oid = me->forms[ii].oid;
	    * index = ii;
	    * sts = OM_S_SUCCESS;
	    break;
	 }
    }

  _bugprint(bflag=TFLAG, str =
	"-CEO.get_form_oid:  label=%d, *form_oid=%d, *index=%d, *sts=%d\n",
	var = `label, *form_oid, *index, *sts` )
  return OM_S_SUCCESS;
}
end implementation CEO;
