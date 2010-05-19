/*
	 History : 92/07/27
	*** NOTE : this file is OBSOLETE
 */

#include "ciminimum.h"
#include "cimacros.h"


struct GRid 	TEMP[3];
GRobj 		MAC1,EXP,DIR;
short           num_crv,i,type;
int 		suc,stat;
char            txt[20];
struct GRmd_env	MOD_ENV;
IGRchar		mes_f[80];

main()
{
  strcpy(mes_f,"<Assoc> Place Parallelogram Plane by 3 Points");
  type=1;
  while(1)
  {
   message(mes_f);
   for(i=0;i<3;i=i+1)
    {
     strcpy(txt,"Identify point ");
     strcat(txt,itoa(i+1));

     if(!ci$locate( prompt       = txt,
		    classes      = "GRpoint",
                    properties   = LC_LC_ONLY | LC_DP_ONLY | LC_RW,
                    owner_action = LC_RIGID_COMP
                                    | LC_RIGID_OWNER | LC_FLEX_COMP
                                    | LC_FLEX_OWNER  | LC_REF_OBJECTS,
	            obj          = &(TEMP[i].objid),
                    osnum        = &(TEMP[i].osnum),
		    md_env       = &MOD_ENV)) exit;
   }

   MAC1 = NULL_OBJID;
   ci$send(msg = message ci_macro.init
		( &suc,0, "srf_plane", 3, TEMP, &type, &MOD_ENV),
	         targetid = MAC1);

 }
}

wakeup(){
	message(mes_f);
}

