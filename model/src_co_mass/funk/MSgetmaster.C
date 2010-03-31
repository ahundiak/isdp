/* ###################   APOGEE COMPILED   ################## */
# include "EMS.h"
# include "OMminimum.h"
# include "igrtypedef.h"
# include "ex.h"
# include "igr.h"
# include "igrdp.h"
# include "igetypedef.h"
# include "madef.h"
# include "griodef.h"
# include "godef.h"
# include "gr.h"
# include "go.h"
# include "grio.h"
# include "griomacros.h"
# include "EMSlogic.h"

void MSget_master_string(msg, object_space_num, master_units, factor)

IGRlong	 *msg;
OMuword	 object_space_num;
IGRchar	 *master_units;
IGRdouble *factor;
{
  IGRshort	only_one = 1;
  IGRshort	field_size;
  IGRlong	i, count, status;

  status = co$cvt_imp_to_wrk(
			msg = msg,
			unit_type = "UOM_DISTANCE",
			osnum = object_space_num,
			primary = 1.0,
			result = factor);

  /*
   * 12/03/92 - JSD - All of the callers to MSget_master_string
   * have master_units defined to be an 80 character array.
   * We must specify field size when calling co$cvt_imp_to_alias
   * to prevent the default of 150.
   */
  field_size = sizeof(IGRchar) * 80;
	
  status = co$cvt_imp_to_alias(
			msg = msg,
			unit_type = "UOM_DISTANCE",
			osnum = object_space_num,
/*			precision = 1, */
			num_alias = &only_one,
			field_size = &field_size,
			working_units = factor,
			cvt_list = master_units);
			
/* strip master_units to contain 'clean' master units */

/* pattern: ...1 ... */

  count = 0;
  while((master_units[count] == '1')  ||
        (master_units[count] == '0')  || 
        (master_units[count] == '.')  )
        count++;
	
  count += 1;	/* points to the first character of primary unit */

  i = 0;
  while(master_units[count])
   {
     master_units[i] = master_units[count];
     count ++;
     i ++;
   }
  master_units[i] = NULL;

/*********************************
count points to the NULL character + 1 
get rid of blanks at the end 
points to the last character 
  count -= 1;		
  while( (master_units[count] IS NULL) OR (master_units[count] IS ' '))
   {
     master_units[count] = NULL;
     count --;
   }
*********************************/
  return;
}
