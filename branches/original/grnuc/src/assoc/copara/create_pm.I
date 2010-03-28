
class implementation COpara;

#include "expression.h"
#include "expmacros.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#include "griomacros.h"
#include "OMmacros.h"
#include "coparadef.h"
#include "nddef.h"
#include "AS_status.h"
#include "ASmessages.h"
#define AS_DEBUG

from NDnode import NDchg_state, NDgive_structure;


extern (*AStranslate) ();

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                           create_param                          */
/* Just to maintain compatibility with earlier release             */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

IGRint create_param(param_val, param_id, osnum, response, response_data)
GRobjid  *param_id;
IGRdouble param_val;
GRspacenum osnum;
IGRlong *response;
IGRchar *response_data;
{
struct GRevent grevent;
static IGRint TokenList[] =
			{
			 DATA  ,
			 STRING,
			 GR_UNKNOWN_TYPE,
			 LOC_PARAM
			};
IGRint  token;
IGRlong input_mask,msg;
IGRlong size;

	input_mask = GRm_DATA | GRm_STRING;
	size = sizeof(struct GRevent);

        token = AScreate_pm (TokenList,&input_mask,&grevent,
			     param_val,param_id,osnum,
                             response, response_data);
	if(TokenList[token] == LOC_PARAM)
         {
	  return (OM_S_SUCCESS);
	 }
	else
         {
	  EXputq_front(&msg,response,&size,&grevent.event);
	  return(OM_W_ABORT);
         }
 }

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                           AScreate_pm                           */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

AScreate_pm(TokenList,input_mask,grevent,param_val,param_id,osnum,response,
	    response_data)
IGRint *TokenList;
IGRlong *input_mask;
struct GRevent *grevent;
GRobjid  *param_id;
IGRdouble param_val;
GRspacenum osnum;
IGRlong *response;
IGRchar *response_data;
  
{
IGRint msg,rt,status;
IGRint  token;
IGRlong size;
char *strchr(),*equal;
#define SIZE_MESS 55
char *name_exp,null_name = '\0';
/* get the name of the expression */

     size = sizeof(struct GRevent);

     while(1)
     {
        ex$message(msgnumb = AS_P_PmNm,type="%6.3lf",
                   var=`param_val`);
	token = GRget_token(&msg,TokenList,&input_mask,grevent,&size,
			    response,response_data);
	name_exp = NULL;
	switch (*response)
        {
	 case STRING :
          /*| on verifie que le nom n'existe pas deja */

          if(response_data[0] != 0)
            {
             rt = di$translate(objname = response_data,
			       p_objid  = param_id); 
             if(rt == DIR_S_SUCCESS)
	       {
	        ex$message(msgnumb = AS_E_ParaExists);
		continue;
               }

    	     equal = strchr(response_data,'=');
    	     if(equal != NULL)
               {
		 ex$message(msgnumb = AS_E_IllName);
	 	 continue;
               }
	     name_exp = response_data;
	    }

	 case RESET :
	 case MOVE_ON :
          rt = exp$create(exp_name=name_exp,
			  exp_value = param_val,
			  osnum = osnum,
			  p_exp_id = param_id);
	   
          if(rt != OM_S_SUCCESS)
          {
	    ex$message(msgnumb = AS_E_NCrePara);
	    continue;
	  }
	  else if( name_exp != NULL )
          {
	   /* There are creasy people to define loooooong parameter names ...*/
	   if(strlen(name_exp) > SIZE_MESS-32) name_exp[SIZE_MESS-32] = '\0';
           ex$message(msgnumb = AS_S_PmValue,type="%s%6.3lf",
                      var=`name_exp,param_val`);
          }
	  else 
          {
             status = om$send(msg = message NDnode.NDchg_state
                                              (ND_DEL_NO_CH , ND_DEL_NO_CH ),
			 senderid = NULL_OBJID,
                         targetid = *param_id,
                         targetos = osnum);
             as$status();

             ex$message(msgnumb = AS_S_PmValue,type="%s%6.3lf",
                        var=`&null_name,param_val`);
          }
	  for(token=0; TokenList[token] != LOC_PARAM ; token++);
          return(token);

       default :
          return(token);
     }
   }
}

ASget_param_from_string(response_data,type_generic,param,param_value,md_env)
char *response_data;
int type_generic;
struct GRid *param;
double *param_value;
struct GRmd_env *md_env;
{
 IGRchar *equal, *strchr();  
 char real_name[DI_PATH_MAX];
 int type_req;
 long msg,status;
 struct ret_struct str;
#define SIZE_MESS 55

    /*| Do i have to find the parameter by its name or to create a new one?*/

    if(type_generic == text_type) type_req = EXP_TEXT;
    else			  type_req = EXP_DOUBLE;
    param->objid = NULL_OBJID;

    /*"type_generic %d type_req %d\n",type_generic,type_req */ 
    equal = strchr(response_data,'=');
    if(equal != NULL)
        {
	 /*| create a new parameter with name */
        *equal = '\0';
	status = exp$translate(exp_name = response_data,
				  p_exp_id = &param->objid,
				  p_osnum  = &param->osnum );
	if(status&1)
	 {
	  ex$message(msgnumb = AS_E_ParaExists);
	  param->objid = NULL_OBJID;
         }

        else
          {
	   status = exp$create(exp_name = response_data,
			         exp_syntax = equal+1,
			         p_exp_id = &param->objid,
			         p_osnum  = &param->osnum,
				 type_rq = type_req);

           if(!(status&1)) param->objid = NULL_OBJID;
           else
           {
            if( response_data[0] != '\0' )
            {
             /* There are creasy people to define loooooong parameter names ..*/
             if(strlen(response_data) > SIZE_MESS-32)
					    response_data[SIZE_MESS-32] = '\0';

	     ex$message(msgnumb = AS_S_PmValue,type="%s%s",
			var=`response_data,equal+1`);
            }
           }
	  }
        }
      else
        {
          /*| try to find an existing one */

          /* Stupid user mode */

          di$cvt_name_from_input(u_path = response_data,
			         s_path = real_name);

          if(AStranslate)
           {
	     /*| Attention au trou .... */
	     status = AStranslate(response_data,
				&param->objid,
				&param->osnum,
		   		NULL);
           }
          else
           {
	      status = di$translate(objname = real_name,
				  p_objid = &param->objid,
				  p_osnum = &param->osnum );

           }
        /*"ret_code %d objid %d osnum %d\n",status,param->objid,param->osnum */
          
         if(status != DIR_S_SUCCESS)
          {

           /*| try to create a parameter without name */
	
	   status = exp$create(exp_name = 0,
			       exp_syntax = response_data,
			       p_exp_id = &param->objid,
			       osnum    = md_env->md_id.osnum,
			       p_osnum  = &param->osnum,
			       type_rq = type_req);

           if(!(status&1)) param->objid = NULL_OBJID;
	 
	   else 
	    {
             status = om$send(msg = message NDnode.NDchg_state
                                              (ND_DEL_NO_CH,ND_DEL_NO_CH),
			 senderid = NULL_OBJID,
                         targetid = param->objid,
                         targetos = param->osnum);
             as$status();
	    }

          }
        }

      if(IF_NULL_OBJID(param->objid)) return OM_W_ABORT;

/*| receive its value from expression */

      status = om$send(msg = message NDnode.NDgive_structure
					(&msg,&str,md_env),
                       senderid = NULL_OBJID,
                       targetid = param->objid,
		       targetos = param->osnum);
      if(!(status&1) ||
          (str.type&type_generic) != type_generic ) return OM_W_ABORT;
      if(type_generic != text_type) *param_value = str.var.root_pm_st.value;
      return OM_S_SUCCESS;
}
end implementation COpara;
