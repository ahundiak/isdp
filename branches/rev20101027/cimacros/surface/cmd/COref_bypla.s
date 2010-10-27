#include "ciminimum.h"
#include "cimacros.h"
#include "expmacros.h"
/*
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
*/

#define EXP_SCALAR 0
#define EXP_DISTANCE 1
#define EXP_ANGLE 2

struct GRid 	TEMP[5];
struct GRmd_env MOD_ENV;
GRobj 		MAC1;
IGRint 		suc;
IGRdouble	exp_default;
IGRchar		loc_mes[80],loc_prompt[80], exp_prompt[80];
IGRint		exp_value;
IGRchar		*exp_true_name, exp_true_value[80];

extern 		ASmake_source_from_env();
extern int
		DImain(),
		DIfast_trans(),
		EXP_translate_exp(),
		EXP_create();

main()
{
   strcpy(loc_mes,"<Assoc> Place Coordinate System by Planes");

while(1)
{
   message(loc_mes);
        

step1:	
        if(!ci$locate( prompt       = "Identify XY plane",
                       classes      = "EMSsubbs",
                       properties   = LC_LC_ONLY | LC_DP_ONLY | LC_RW,
                       owner_action = LC_RIGID_COMP  |
                                      LC_RIGID_OWNER | LC_FLEX_COMP |
                                      LC_FLEX_OWNER  | LC_REF_OBJECTS,
	               obj          = &(TEMP[2].objid),
                       osnum        = &(TEMP[2].osnum),
                       md_env       = &MOD_ENV    )) break;

	ASmake_source_from_env( &TEMP[2],&MOD_ENV,&TEMP[2]);	


step2:

        if(!ci$locate( prompt       = "Identify ZX plane to get X support",
                       classes      = "EMSsubbs",
                       properties   = LC_LC_ONLY | LC_DP_ONLY | LC_RW,
                       owner_action = LC_RIGID_COMP  |
                                      LC_RIGID_OWNER | LC_FLEX_COMP |
                                      LC_FLEX_OWNER  | LC_REF_OBJECTS,
	               obj          = &(TEMP[1].objid),
                       osnum        = &(TEMP[1].osnum),
                       md_env       = &MOD_ENV    )) goto step1;
	ASmake_source_from_env( &TEMP[1],&MOD_ENV,&TEMP[1]);	

   	if(!ci$locate( 	prompt       = "Identify YZ plane",
                  	classes      = "EMSsubbs",
                  	properties   = LC_LC_ONLY | LC_DP_ONLY | LC_RW,
                  	owner_action = LC_RIGID_COMP  |
                                       LC_RIGID_OWNER | LC_FLEX_COMP |
                                       LC_FLEX_OWNER  | LC_REF_OBJECTS,
	          	obj          = &(TEMP[0].objid),
                  	osnum        = &(TEMP[0].osnum),
                  	md_env       = &MOD_ENV    )) goto step2;

	ASmake_source_from_env( &TEMP[0],&MOD_ENV,&TEMP[0]);	

	ci$get_module_info(md_env = &MOD_ENV);


	TEMP[3].objid = NULL_OBJID;
	TEMP[3].osnum = MOD_ENV.md_id.osnum;
			
	exp_true_name = NULL;
	exp_value = 145;	
	strcpy(exp_true_value, itoa(exp_value));
	suc  = exp$create( exp_name   = exp_true_name,
			   exp_syntax = exp_true_value,
			   osnum      = MOD_ENV.md_id.osnum,
			   p_exp_id   = &TEMP[3].objid,
			   p_osnum    = &TEMP[3].osnum );

	if( suc == 1 ){

		ci$send(msg      = message NDnode.NDchg_state( 
                                                   (char)16,(char)16 ),
                    	targetid = TEMP[3].objid,
                    	targetos = TEMP[3].osnum  );
	}
	else{
		status(" error creating the expression ");
		exit;
	} 

   	MAC1 = NULL_OBJID;   

   	ci$send(msg = message nci_macro.init( &suc,
                                              0,
				              "ref_bypla",
					      4,
					      TEMP,
					      NULL,
                                              &MOD_ENV ),
		targetid = MAC1,
	        targetos = MOD_ENV.md_id.osnum );

	   if( suc == 0 ){
		write("placement of nci_macro \"ref_bypla\" failed\n");
		status("placement of nci_macro \"ref_bypla\" failed");
      		ci$send(msg = message Root.delete(0),
			targetid = MAC1,
			targetos = MOD_ENV.md_id.osnum );
	   }

}

}

wakeup(){
	message(loc_mes);
}
