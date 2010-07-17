class implementation expression;

#include <OMminimum.h>
#include <OMmacros.h>
#include "expression.h"
#include "expmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "nddef.h"
#include "asbox.h"
#include "AS_status.h"
#include "ndmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "asbox.h"
#include "macro.h"
#include "madef.h"
#include "gr.h"
#include "acrepdef.h"
#include "VDmem.h"

#define AS_DEBUG

/*
#define MY_DEBUG
*/

#define OPEN_PAR "("
#define CLOSE_PAR ")"

#define PILE_INCR    10

from	ACcomplex	import  ACget_other;
from	ACcpx		import	find_macro,ACfind_exp_temp_obj;
from	ACncpx		import	ACget_rep;
from	ACmacro_defn	import	ACgive_feet_desc, ACgive_temp_desc,
				ACgive_name;
from	ACpretend	import	ACgive_downscan;
from	ACcond_def	import	ACfind_rep;

extern GRclassid OPP_ACcpx_class_id,
		 OPP_ci_mac_def_class_id,
		 OPP_ACcond_def_class_id;

extern OM_S_OBJID NULL_OBJID;


method give_recursive_formula(
	struct GRid		*macro_id; 
	char 			*formula; 
	int 			len
)
{/* give_recursive_formula*/
	char 		*c, *old_c, *strchr(), *cPtr;
	int 		parent_index;
	int 		len_formula;
	struct GRid 	parent;
	IGRlong  	status;
	int 		my_nb_macro_in_pile,i;
	struct GRid    *pile;
	int		PileSize;
	struct GRid    *my_pile_macro;
 
	VR_Get_Pile( pile, &PileSize );
        my_pile_macro = _MALLOC (PileSize, struct GRid);
        if (my_pile_macro == NULL) return OM_E_NODYNMEM;
 
	/*A Save the pile of macros whic defines my context */

	for(i=0;i<PileSize;i++) 
        {
	  my_pile_macro[i].objid = pile[i].objid;
	  my_pile_macro[i].osnum = pile[i].osnum;
        }
	my_nb_macro_in_pile = PileSize;
 
	/*A If the expression is the result of a macro, send to the
	message to the object in the macro definition	*/

	/*A processing needed to support new syntax for the
	expressions						*/
	cPtr =  (char *)strchr(me->pretty_print,'=');

	if (cPtr ) 
   	{
		c =  strchr(cPtr,'\\');
		old_c = cPtr+1;
	} else {
		c =  strchr(me->pretty_print,'\\');
		old_c = me->pretty_print;
	}

	/*C Do I have a syntax */
   	if(!c)
    	{
		/*C I don't have syntax */
		formula[0] = '\0';
    	} else {
		/*C remove leading blank */
		while (*old_c == ' ') old_c++;

		/*A copy syntax before parent */
		formula[0]='\0';
     		do
     		{
			*c = '\0';
			strcat(formula,old_c);
      			strcat(formula,OPEN_PAR);
      			*c = '\\';

			/*A get index of parent */
			parent_index = strtol(c+1,&old_c,10); 

			/*A recursion */
			status = 
			om$get_objid_at_index( objid = my_id,
				      p_chanselect = &ND_father,
				      index = parent_index,
				      objidaddr = &parent.objid,
				      osnumaddr = &parent.osnum);
			as$status(action = RET_STATUS);

			len_formula = strlen(formula);

			/*"send give_formula to %d %d  %d %d\n",
			parent.objid,parent.osnum,macro_id->objid,
							macro_id->osnum*/
			status =
			VRgive_recursive_formula( parent,*macro_id,
				formula+len_formula,len-len_formula);
			as$status();

			/*A Restore context */
                        VR_Clear_Pile();

			for(i=0;i<my_nb_macro_in_pile;i++) 
                          status = VR_Add_To_Pile (&my_pile_macro[i]);

			/*A add parenthesis */
			strcat(formula,CLOSE_PAR);
			c= strchr(old_c,'\\');
	
     		} while (c != NULL);

		/*A add the end of my formula */
 
		if(old_c != NULL) strcat(formula,old_c);
  	}
	
        _FREE (my_pile_macro);

	return OM_S_SUCCESS;

}/*end give_recursive_formula*/

end implementation expression ;
