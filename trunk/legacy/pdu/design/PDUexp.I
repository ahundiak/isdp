class implementation COpdu;

/*
   This file contains all functions for creating and manipulating 
   expressions.

   Author: Jamal Shakra
   Date: 28-11-91
*/

#include        <unistd.h>
#include        <PDUint.h>
#include        <PDUintdef.h>
#include        <PDUstr.h>
#include        <PDUpart.h>
#include        <PDUcommand.h>
#include	<DIdef.h>
#include        <msdef.h>
#include	<godef.h>
#include        <igrdp.h>
#include        <go.h>
#include        <grdpbmacros.h>
#include        <exmacros.h>
#include        <dpmacros.h>
#include	<dp.h>
#include	<dpdef.h>
#include        <lcmacros.h>
#include	<gotextdef.h>
#include	<grsymdef.h>
#include	<grsym.h>
#include	<grownerdef.h>
#include	<madef.h>
#include        <nddef.h>
#include        <grdpbdef.h>
#include        <grdpb.h>
#include        <DItypedef.h>
#include        <DIprims.h>
#include        <DImacros.h>
#include        <DIglob.h>
#include        <parametric.h>
#include        <acdef.h>
#include        <acmacros.h>
#include        <macro.h>
#include        <ACdb_info.h>
#include        <expression.h>
#include        <expmacros.h>
#include        <string.h>

/* 10/Dec/93 - raj.	*/
#include	<referr.h>
#include	<AS_status.h>

from    expression  import      give_formula;
from    NDnode      import      NDgive_structure;

/* 10/Dec/93 - raj.	*/
from    expression  import      create;

/* 10/Dec/93 - raj.	*/
extern OMuword               OPP_text_exp_class_id;

/*
 * This function creates an expression in the given directory.
 */
IGRint	PDUcreate_exp(
                      exp_type,
                      dir_path,
                      exp_name,
                      exp_value,
                      osnum
                     )

  IGRint        exp_type;       /* INPUT */
  IGRchar       *dir_path;      /* INPUT */
  IGRchar       *exp_name;      /* INPUT */
  IGRchar       *exp_value;     /* INPUT */
  OMuword       osnum;          /* INPUT */
  {
  IGRint	status;
  OM_S_OBJID    exp_id = NULL_OBJID;
  OMuword	exp_osnum;
  IGRchar       pwd[DI_PATH_MAX];
 
  /* 10/Dec/93 - raj.			*/
  char		expr1[DI_PATH_MAX];
  short		rc;
  GRclassid	class_id;
  IGRchar	dirname[DI_PATH_MAX];
  IGRlong	lstatus, msg;
 
  _pdm_debug("In the function PDUcreate_exp",0);

  _pdm_debug("expression type = %d",exp_type);
  _pdm_debug("directory = <%s>",dir_path);
  _pdm_debug("expression name = <%s>",exp_name);
  _pdm_debug("expression value = <%s>",exp_value);

  /* Need to save current directory */
  di$pwd(dirname = pwd); 

  /* change directory to dir_path */
  status = di$cd(dirname = dir_path);
  _pdm_status("di$cd",status); 

  if (exp_type == NUMERIC)
     {
      /* create numeric expression object */
      _pdm_debug("creating numeric expression object",0);
      status = exp$create(exp_name = exp_name,
                          exp_syntax = exp_value,
                          osnum = osnum,
                          p_exp_id = &exp_id,
                          p_osnum = &exp_osnum,
                          type_rq = EXP_DOUBLE
                         );
      _pdm_status("exp$create",status);
     }

  if (exp_type == TEXT)
     {
       /*
        * exp$create() for TEXT type fails if the object space
        * is a reference file. Do our own processing.
        * 10/Dec/93 - raj
        */
       GRcheckref(&msg,NULL,NULL,NULL,&osnum);

       if (msg != GRNOTREFFILE)	/* It is a reference file.	*/
       {
         _pdm_debug("PDUcreate_exp(): TEXT expression creation: START", 0);
         if (exp_name[0] != ':')
         {
           /* build a full path and then get the osnum for that path */
           di$pwd ( p_osnum = &osnum, dirname = dirname );
           DIstrcat ( dirname, exp_name );
           di$give_osnum ( pathname = dirname, p_osnum  = &osnum );
         }
         else
         {
           /* get the osnum for the full path */
           di$give_osnum ( pathname = exp_name, p_osnum  = &osnum );
         }

         exp_osnum = osnum;
  
         class_id = OPP_text_exp_class_id;
  
         lstatus = om$construct(classid = class_id,
  			  osnum = osnum,
  			  p_objid =  &exp_id);
         as$status(action = RET_STATUS);
  
         EXP_gen_name(expr1, exp_id, exp_name);
  
         lstatus = om$send(msg = message expression.create( expr1, (exp_value), &rc ),
  		     senderid = NULL_OBJID,
  		     targetid = exp_id,
  		     targetos = osnum);
         if(!(lstatus&rc&1))
         {
           om$send(msg = message  Root.delete(1), 
  	        senderid = NULL_OBJID,
  	        targetid = exp_id,
  	        targetos = osnum);
           rc = EXP_E_ABORT;
         }

         status = EXP_S_SUCCESS;
         _pdm_debug("PDUcreate_exp(): TEXT expression creation: END", 0);
       }
       else			/* Not a reference file.	*/
       {
         /* create text expression object */
         _pdm_debug("creating text expression object",0);
         status = exp$create(exp_name = exp_name,
                          exp_syntax = exp_value,
                          osnum = osnum,
                          p_exp_id =&exp_id,
                          p_osnum = &exp_osnum,
                          type_rq = EXP_TEXT
                         );
         _pdm_status("exp$create",status);
       }

       if (status == EXP_S_SUCCESS)
       {
         status = PDM_S_SUCCESS;

         /* Restore current directory */
         di$cd(dirname = pwd);
       }

       else
       {
         _pdm_debug("Error creating expression", 0);

         /* Restore current directory */
         di$cd(dirname = pwd);

         status = PDM_S_SUCCESS;
       }
     }
  return ( status );
  }

/*
 * This function modifies the value of an expression. It also creates a new
 * expression if original expression does not exist.
 */
IGRint	PDUmodify_exp(
                      exp_type,
                      dir_path,
                      exp_name,
                      new_exp_value,
                      osnum
                     )

  IGRint        exp_type;               /* INPUT */
  IGRchar       *dir_path;              /* INPUT */
  IGRchar       *exp_name;              /* INPUT */
  IGRchar       *new_exp_value;         /* INPUT */
  OMuword       osnum;                  /* INPUT */
  {
  IGRint	status;
  OM_S_OBJID    p_exp_id;
  /*
  OM_S_OBJID    exp_id;
  */
  IGRchar       pwd[DI_PATH_MAX];

  _pdm_debug("In the function PDUmodify_exp",0);

  _pdm_debug("expression type = %d",exp_type);
  _pdm_debug("directory = <%s>",dir_path);
  _pdm_debug("expression name = <%s>",exp_name);
  _pdm_debug("new expression value = <%s>",new_exp_value);

  /* Need to save current directory */
  di$pwd(dirname = pwd);

  /* change directory to dir_path */
  status = di$cd(dirname = dir_path);

  status = di$translate(
                        objname = exp_name,
                        path = dir_path,
                        p_objid = &p_exp_id
                       );

  /* modify expression object */
  status = exp$modify(
                      exp_id = p_exp_id,
                      osnum = osnum,
                      p_osnum = NULL,
                      exp_syntax = new_exp_value 
                     );
  _pdm_status("exp$modify",status);

  /* if expression is not found, create it */
  if (status == EXP_E_NOT_FOUND)
     {
      _pdm_debug("expression will be created",0);
      status = PDUcreate_exp(
                             exp_type,
                             dir_path,
                             exp_name,
                             new_exp_value,
                             osnum 
                             );
      _pdm_status("PDUcreate_exp",status);

      /* Restore current directory */
      di$cd(dirname = pwd);
     
      return(status);
     }

  if (status != EXP_S_SUCCESS) 
     {
      _pdm_debug("Error in creating expression", 0);

      status = PDM_S_SUCCESS;
    
      /* Restore current directory */
      di$cd(dirname = pwd);
     }

  else
     {
      status = PDM_S_SUCCESS;

      /* Restore current directory */
      di$cd(dirname = pwd);
     }

 return ( status );
  }

/*
 * This function deletes an expression.
 */
IGRint	PDUdelete_exp(exp_id, mod_env)

 struct    PDUid    exp_id;                 /* INPUT */
 struct    GRmd_env      mod_env;           /* INPUT */

  {
  IGRint	status;


  _pdm_debug("In the function PDUdelete_exp",0);
  _pdm_debug("expression obj id = %d", exp_id.objid);
  _pdm_debug("expression osnum = %d", exp_id.osnum);

  status = exp$delete(
                      exp_id = exp_id.objid,
                      osnum = exp_id.osnum,
                      p_osnum = NULL,
                      p_md_env = &mod_env
                     );
  _pdm_status("ex$delete",status);

  if (status == EXP_S_SUCCESS)
     {
      status = PDM_S_SUCCESS;
     }

  else
     {
      _pdm_debug("Error in deleting expression", 0);
      status = PDM_S_SUCCESS;
     }

 return ( status );
  }

/*
 * This function evaluates an expression.
 */
IGRint	PDUevaluate_exp(
                        dir_path,
                        exp_name,
                        exp_value
                       )

  IGRchar       *dir_path;         /* INPUT */
  IGRchar       *exp_name;         /* INPUT */
  IGRchar       **exp_value;       /* OUTPUT */
  {
  IGRint	status;
  OMuword       current_osnum;
  OM_S_OBJID    exp_id; 
  IGRlong       nret,buffersize;
  IGRlong       msg;
  IGRchar       full_path[DI_PATH_MAX];
  IGRchar       pwd[DI_PATH_MAX];
  IGRchar       value[EXP_MAX_LEN]; 
  struct GRmd_env mod_env;
  struct ret_struct data;

  _pdm_debug("In the function PDUevaluate_exp",0);

  _pdm_debug("directory = <%s>",dir_path);
  _pdm_debug("expression name = <%s>",exp_name);

  /* Need to save current directory */
  di$pwd(dirname = pwd);

  /* change directory to dir_path */
  status = di$cd(dirname = dir_path);
 
  strcpy(full_path, dir_path);
  strcat(full_path, ":");
  strcat(full_path, exp_name);
  _pdm_debug("full path = <%s>", full_path);

  /* extract object id of expression name in directory */
  status = di$translate(
                        objname = full_path,
                        p_objid = &exp_id
                       );

  _pdm_debug("exp objid = %d",exp_id);

  /* Get module environment info. */
  buffersize = sizeof(mod_env);
  status = gr$get_module_env ( 
                              msg = &msg,
		              sizbuf = &buffersize,
			      buffer = &mod_env,
			      nret = &nret
                             );
  _pdm_rstatus2 ("gr$get_module_env", status, msg);

  /* Find osnum associated with dir_path */
  di$give_osnum(pathname = dir_path, p_osnum = &current_osnum);
  _pdm_debug("current osnum = %d", current_osnum); 

  mod_env.md_id.osnum = current_osnum;

  /* evaluate the object given it's objid */
  status = om$send ( msg = message NDnode.NDgive_structure
                     (&msg, &data, &mod_env), 
                     senderid = NULL_OBJID,
                     targetid = exp_id,
                     targetos = current_osnum 
                   );
  _pdm_status ("NDnode.NDgive_structure", status);

  if (status == 1)
     {
      switch(data.type)
            {
             case text_type:
                  strcpy(value,data.var.text_st.text_string);
                  PDUfill_in_string(exp_value,value);
                  break;

             case double_type:
                  sprintf(value,"%f",data.var.root_pm_st.value);
                  PDUfill_in_string(exp_value,value);
                  break;

             default:
                  _pdm_debug("error in evaluating expression",0);
                  _pdm_debug("defaulting expression value to NULL string",0);
                  PDUfill_in_string(exp_value,"");
                  break;
            }
     
      /* Restore current directory */
      di$cd(dirname = pwd);

      status = PDM_S_SUCCESS;
     }

  else
     {
      _pdm_debug("SEVERE error: failed in evaluating expression",0);

      /* Restore current directory */
      di$cd(dirname = pwd); 
     }

  return ( status );
  }

/* 
 * This function extracts the RHS of an expression.
 */
IGRint	PDUextract_exp_RHS(
                           dir_path,
                           exp_name,
                           RHS,
                           osnum
                          )
  IGRchar       *dir_path;               /* INPUT */
  IGRchar       *exp_name;               /* INPUT */
  IGRchar       RHS[EXP_MAX_LEN];        /* OUTPUT */
  OMuword       osnum;                   /* INPUT */
  {
  IGRint	status;
  IGRchar       pwd[DI_PATH_MAX];
  OM_S_OBJID    exp_id; 

  _pdm_debug("In the function PDUextract_exp_RHS",0);

  _pdm_debug("directory = <%s>",dir_path);
  _pdm_debug("expression name = <%s>",exp_name);

  /* set RHS initially to "" */
  strcpy(RHS,"");

  /* Need to save current directory */
  di$pwd(dirname = pwd);

  /* change directory to dir_path */
  status = di$cd(dirname = dir_path);

  /* extract object id of expression name in directory */
  status = di$translate(
                        objname = exp_name,
                        path = dir_path,
                        p_objid = &exp_id
                       );

  _pdm_debug("exp objid = %d",exp_id);

  /* extract the RHS of the object given it's objid */
  status = om$send ( msg = message expression.give_formula(RHS),
                     senderid = NULL_OBJID,
                     targetid = exp_id,
                     targetos = osnum 
                   );
  _pdm_status ("expression.give_formula", status);

  if (status)
     {
      _pdm_debug("RHS of expression = <%s>",RHS);

      /* Restore current directory */
      di$cd(dirname = pwd);

      status = PDM_S_SUCCESS;
     }

  else
     {
      _pdm_debug("expression.give_formula failed",0);

      /* Restore current directory */
      di$cd(dirname = pwd);

      status = PDM_S_SUCCESS;
     }

  return ( status );
  }

/*
 * This function returns the type of an expression.
 */
IGRint  PDUget_exp_type(
                        dir_path,
                        exp_name,
                        exp_type
                       )

  IGRchar       *dir_path;         /* INPUT */
  IGRchar       *exp_name;         /* INPUT */
  IGRchar       **exp_type;        /* OUTPUT */
  {
  IGRint        status;
  OMuword       current_osnum;
  OM_S_OBJID    exp_id;
  IGRlong       nret,buffersize;
  IGRlong       msg;
  IGRchar       full_path[DI_PATH_MAX];
  IGRchar       pwd[DI_PATH_MAX];
  struct GRmd_env mod_env;
  struct ret_struct data;

  _pdm_debug("In the function PDUget_exp_type",0);

  _pdm_debug("directory = <%s>",dir_path);
  _pdm_debug("expression name = <%s>",exp_name);

  /* Need to save current directory */
  di$pwd(dirname = pwd);

  /* change directory to dir_path */
  status = di$cd(dirname = dir_path);

  strcpy(full_path, dir_path);
  strcat(full_path, ":");
  strcat(full_path, exp_name);
  _pdm_debug("full path = <%s>", full_path);

  /* extract object id of expression name in directory */
  status = di$translate(
                        objname = full_path,
                        p_objid = &exp_id
                       );

  _pdm_debug("exp objid = %d",exp_id);

  /* Get module environment info. */
  buffersize = sizeof(mod_env);
  status = gr$get_module_env (
                              msg = &msg,
                              sizbuf = &buffersize,
                              buffer = &mod_env,
                              nret = &nret
                             );
  _pdm_rstatus2 ("gr$get_module_env", status, msg);

  /* Find osnum associated with dir_path */
  di$give_osnum(pathname = dir_path, p_osnum = &current_osnum);
  _pdm_debug("current osnum = %d", current_osnum);

  mod_env.md_id.osnum = current_osnum;

  /* evaluate the object given it's objid */
  status = om$send ( msg = message NDnode.NDgive_structure
                     (&msg, &data, &mod_env),
                     senderid = NULL_OBJID,
                     targetid = exp_id,
                     targetos = current_osnum
                   );
  _pdm_status ("NDnode.NDgive_structure", status);

 if (status == 1)
     {
      switch(data.type)
            {
             case text_type:
                  PDUfill_in_string(exp_type, "TEXT");
                  break;

             case double_type:
                  PDUfill_in_string(exp_type, "NUMERIC");
                  break;

             default:
                  _pdm_debug("error in extracting expression type",0);
                  break;
            }

      /* Restore current directory */
      di$cd(dirname = pwd);

      status = PDM_S_SUCCESS;
     }

  else
     {
      _pdm_debug("SEVERE error: failed in evaluating expression",0);

      /* Restore current directory */
      di$cd(dirname = pwd);
     }

  return ( status );
  }

end implementation COpdu;
