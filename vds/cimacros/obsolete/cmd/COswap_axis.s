#include "ciminimum.h"
#include "cimacros.h"
#include "cieveryone.h"


#define  MACRO_NAME    "ref_bypla"  /* Name of the macro                      */

char *template_name[NB_TEMPLATE];   /* Names of the templates of the macro    */
char *feet_name[NB_FEET];           /* Names of the feet of the macro         */
struct GRid temp_obj[NB_TEMPLATE];  /* Template objects of the macro          */
GRobj  macro_def_id;                /* Identifier of the macro definition     */
struct GRmd_env		MOD_ENV;
char			loc_mes[80],loc_prompt[80], exp_prompt[80];



int    stat;                   /* Returned status of the definition       */
double			exp_default;
int             	suc;


extern ASmake_source_from_env();


main()
{

 strcpy(loc_mes,"<Assoc> Swap Ref_pla axis");
 message(loc_mes);


 while(1){

step1:

  if ( !ci$locate ( prompt       = "Identify the from coordinate system",
                    properties   = LC_LC_ONLY | LC_DP_ONLY | LC_RW,
                    owner_action = LC_RIGID_COMP
                                      | LC_RIGID_OWNER | LC_FLEX_COMP
                                      | LC_FLEX_OWNER  | LC_REF_OBJECTS,
		    obj          = &(temp_obj[0].objid),
		    osnum        = &(temp_obj[0].osnum),
                    classes      = "GRlbsys",
                    md_env       = &MOD_ENV  ) ) goto step0;

   	  ci$get_module_info(md_env = &MOD_ENV);


 }/* end of while */

}/* end of main */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
wakeup(){
	message(loc_mes);
}

