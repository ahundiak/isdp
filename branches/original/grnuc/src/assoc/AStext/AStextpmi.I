
class implementation AStextpm ;

#define DEBUG 
#include "OMmacros.h"
#include "ASmatrix.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "fontdef.h"
#include "font.h"
#include "gotextdef.h"
#include "gotext.h"
#include "drawparam.h"


method  ASevaluate(IGRint num;struct GRid *list; IGRint *type;
		   struct GRmd_env *md_env)
{
IGRchar text_buf[80],*text = NULL;
IGRdouble value;
struct ret_struct text_def;
IGRint i,j,ic;
IGRlong msg,status,sts;

/* find the value and the parameter in the parent list */
/* Pour le moment format fixe pour tester. Prendre par la suite le format
   dans un text expression */

text_buf[0] = 0;
for (i=0; i<num ; i++)
 {
  if (*(type+i) == double_type)
     {
      status=om$send(msg = message NDnode.NDgive_structure
							(&msg,&text_def,md_env),
			targetid = (list+i)->objid,
			targetos = (list+i)->osnum);

	  /** If the expression value is undefined , set it to zero 
		- TR#119526770  **/

	  if (text_def.var.root_pm_st.value !=  MAXDOUBLE)
	  {
      	value = text_def.var.root_pm_st.value;
	  }
	  else
	  {
		text_def.var.root_pm_st.value = 0;
      	value = text_def.var.root_pm_st.value;
	  }

      if((status&1))
        {
	 /* Search if there is a format defined */
	 for(j=i+1;j<num;j++)
	  {
  	   if (*(type+j) == text_type)
     	   {
      	    status=om$send(msg = message NDnode.NDgive_structure
							(&msg,&text_def,md_env),
			targetid = (list+j)->objid,
			targetos = (list+j)->osnum);
	    if(status&1) break;
	   }
	  }
	 if(j<num)
          {

	   /*| user format defined */
	   sts = sprintf(text_buf,text_def.var.text_st.text_string,value);
	   if(sts<0) j = num;
	  }
	 if(j>=num)
	  {
	   /*| default format */
	   sts = sprintf(text_buf,"%10.3lf",value);
	  }
	 for(ic=0;ic<10 && text_buf[ic] == ' ';ic++);
	 text = text_buf+ic;
	 break;
        }
     }
  else if(*(type+i) == text_type)
     {
      status=om$send(msg = message NDnode.NDgive_structure
							(&msg,&text_def,md_env),
			targetid = (list+i)->objid,
			targetos = (list+i)->osnum);
      if((status&1)) text = text_def.var.text_st.text_string;
	       else  text = text_buf;
      break;
     }
 }

status = AStext_store(text,strlen(text));
return(status);
}
 
end implementation AStextpm ;
