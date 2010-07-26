/* #######################    APOGEE COMPILED   ######################## */
/* ceo_locate/arg_lc_info.I -- JAJ:02-15-88 */
/*
  function COB_process_GRlc_info_arg():
    translates a string (known to describe a GRlc_info structure)
    into its variable name value for the CEO.arg_name_to_value method

  function COB_process_GRid_arg():
    translates a string (known to describe a GRid structure)
    into its variable name value for the CEO.arg_name_to_value method

  function COB_process_GRmd_env_arg():
    translates a string (known to describe a GRmd_env structure)
    into its variable name value for the CEO.arg_name_to_value method

  function COB_process_GRmdenv_info_arg():
    translates a string (known to describe a GRmd_env structure)
    into its variable name value for the CEO.arg_name_to_value method

  function COB_process_GRparms_arg():
    translates a string (known to describe a GRparms structure)
    into its variable name value for the CEO.arg_name_to_value method

  function COB_process_GRdpb_scale_arg():
    translates a string (known to describe a GRdpb_scale structure)
    into its variable name value for the CEO.arg_name_to_value method

  function COB_process_IGRdisplay_arg():
    translates a string (known to describe a IGRdisplay structure)
    into its variable name value for the CEO.arg_name_to_value method
*/

class implementation CEO_LOCATE;

#include <coimport.h>	/* must be 1st for shared libs-- JAJ:11-01-88 */
#include <stdio.h>

#ifdef DEBUG
#include <COB_DBflags.h>
#define TFLAG ( COBtrace || CEO_LOCATE_debug )
#endif


void  COB_process_GRlc_info_arg ( addr_mode, p_lc_info, arg,
			data, ret_type, is_const )
	/* Incoming */
  int		  addr_mode;	/* == _COB_regular  for regular data  */
				/* == _COB_indirect for "*<arg>"      */
				/* == _COB_address  for "&<arg>"      */
struct GRlc_info* p_lc_info; /* ptr to real GRlc_info to get data from*/
  char  	* arg;		/* arg string to find a value for;    */
				/*   starts at			      */
			/*   me->event1.located_object[2].located_obj */
			/*                                ^	      */
	/* Outgoing */
  COB_arg_union	* data;		/* value of arg string variable       */
  int		* ret_type;	/* type of value found for arg string */
				/*   (see COB_arg.h)		      */
  char		* is_const; 	/* set to 1 => this variable value is */
				/*   "constant" and needn't be looked */
				/*   up ever again		      */
{
  int		arg_num = -1;
  char	      * ch;
  extern	COB_fetch_first_arg_num();

  _bugprint(bflag=TFLAG,str=
   "+COB_process_GRlc_info_arg(arg='%s', addr_mode=%d, p_lc_info=(0x)%x):\n",
    var = `arg, addr_mode, p_lc_info` )

  * ret_type = _COB_UNKNOWN_ARG;
  * is_const = 0;


  if ( ! strcmp ( arg, "located_obj" ) )
    {
      if ( addr_mode == _COB_address )
	{
	  data->p = (char *) & (p_lc_info->located_obj);
	  * ret_type = _COB_arg_p;
	  /***  * is_const = 1;		JAJ:02/04/91  ***/
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      "[&located_obj] data->p=(0x)%x  =?=  & p_lc_info->located_obj=(0x)%x\n",
    	      var=`data->p, &(p_lc_info->located_obj)`)
	}
    }  /*** &located_obj ***/
  else if ( ! strncmp ( arg, "located_obj.", 12 ) )
    {
      _bugprint(bflag=CEO_LOCATE_debug,str=
	    "Calling COB_process_GRid_arg ('%s', p_GRid=(0x)%x )\n",
	    var = `&arg[12], & (p_lc_info->located_obj)` )
      COB_process_GRid_arg ( addr_mode,
				& p_lc_info->located_obj,
				& arg[12], data, ret_type, is_const );
    }  /*** located_obj.____ ***/
  else if ( ! strcmp ( arg, "module_info" ) )
    {
      if ( addr_mode == _COB_address )
	{
	  data->p = (char *) & (p_lc_info->module_info);
	  * ret_type = _COB_arg_p;
	  /***  * is_const = 1;		JAJ:02/04/91  ***/
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      "[&module_info] data->p=(0x)%x =?=  & p_lc_info->module_info=(0x)%x\n",
    	      var=`data->p, &(p_lc_info->module_info)`)
	}
    }  /*** &module_info ***/
  else if ( ! strncmp ( arg, "module_info.", 12 ) )
    {
      _bugprint(bflag=CEO_LOCATE_debug,str=
	    "Calling COB_process_md_env_arg ('%s', p_GRid=(0x)%x )\n",
	    var = `&arg[12], & (p_lc_info->module_info)` )
      COB_process_GRmd_env_arg ( addr_mode,
				& ( p_lc_info->module_info ),
				& arg[12], data, ret_type, is_const );
    }  /*** module_info.____ ***/
  else if ( ! strcmp ( arg, "proj_pnt" ) )
    {
      if ( addr_mode == _COB_regular )
	{
	  data->p = (char *) p_lc_info->proj_pnt;
	  * ret_type = _COB_arg_p;
	  /***  * is_const = 1;		JAJ:02/04/91  ***/
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      "[proj_pnt] data->p=(0x)%x  =?=  p_lc_info->proj_pnt=(0x)%x\n",
    	      var=`data->p, p_lc_info->proj_pnt`)
	}
    }  /*** & proj_pnt ***/
  else if ( ! strncmp ( arg, "proj_pnt[", 9 ) )
    {
#define IGRPOINT_DIM 3
      arg_num = COB_fetch_first_arg_num ( arg, &ch );
      if ( arg_num < 0  ||  arg_num >= IGRPOINT_DIM )
	{
	  fprintf ( stderr,
	    "\nCOB_process_GRlc_info_arg():  Index of IGRpoint structure \"proj_pnt[%d]\"\n\tin state table argument is out of range\n\n", arg_num );
	  goto quit;
	}

      if ( addr_mode == _COB_regular )
	{
	  data->d = p_lc_info->proj_pnt[arg_num];
	  * ret_type = _COB_arg_d;
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      "  data->d=%lf  =?=  p_lc_info->proj_pnt[%d]=%lf\n",
    	      var=`data->d, arg_num, p_lc_info->proj_pnt[arg_num]`)
	}
      else if ( addr_mode == _COB_address )
	{
	  data->p = (char *) & (p_lc_info->proj_pnt[arg_num]);
	  * ret_type = _COB_arg_p;
	  /***  * is_const = 1;		JAJ:02/04/91  ***/
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      "  data->p=(0x)%x  =?=  & p_lc_info->proj_pnt[%d]=(0x)%x\n",
    	      var=`data->p, arg_num,&(p_lc_info->proj_pnt[arg_num])`)
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      "  *data->p=%lf  =?=  p_lc_info->proj_pnt[%d]=%lf\n",
    	      var=`*data->p, arg_num, p_lc_info->proj_pnt[arg_num]`)
	}
    }  /*** proj_pnt[x] ***/
  else if ( ! strcmp ( arg, "geom_parms" ) )
    {
      if ( addr_mode == _COB_address )
	{
	  data->p = (char *) & p_lc_info->geom_parms;
	  * ret_type = _COB_arg_p;
	  /***  * is_const = 1;		JAJ:02/04/91  ***/
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      "[&geom_parms] data->p=(0x)%x  =?=  & p_lc_info->geom_parms=(0x)%x\n",
    	      var=`data->p, &(p_lc_info->geom_parms)`)
	}
    }  /*** & geom_parms ***/
  else if ( ! strncmp ( arg, "geom_parms.", 11 ) )
    {
      _bugprint(bflag=CEO_LOCATE_debug,str=
       "Calling COB_process_GRparms_arg ('%s', p_geom_parms=(0x)%x )\n",
	    var = `&arg[11], & (p_lc_info->geom_parms)` )
      COB_process_GRparms_arg ( addr_mode,
			& ( p_lc_info->geom_parms ),
			& arg[11], data, ret_type, is_const );
    }  /*** geom_parms.____ ***/

quit:
  _bugprint(bflag=TFLAG,str=
    "-COB_process_GRlc_info_arg():  data->[l] = %ld, *ret_type = %d\n",
    var = `data->l, *ret_type` );

} /*** end of function COB_process_GRlc_info_arg () ***/



COB_process_GRid_arg ( addr_mode, p_GRid, arg,
			data, ret_type, is_const )
	/* Incoming */
  int		  addr_mode;	/* == _COB_regular  for regular data  */
				/* == _COB_indirect for "*<arg>"      */
				/* == _COB_address  for "&<arg>"      */
  struct GRid * p_GRid;		/* ptr to real GRid to get data from  */
  char  	* arg;		/* arg string to find a value for;    */
				/*   starts at			      */
		/*   me->event1.located_object[2].located_obj.osnum   */
		/*                                            ^	      */
	/* Outgoing */
  COB_arg_union	* data;		/* value of arg string variable       */
  int		* ret_type;	/* type of value found for arg string */
				/*   (see COB_arg.h)		      */
  char		* is_const;	/* set to 1 => this variable value is */
				/*   "constant" and needn't be looked */
				/*   up ever again		      */
{
  _bugprint(bflag=TFLAG,str=
   "+COB_process_GRid_arg(arg='%s', addr_mode=%d, p_GRid=(0x)%x):\n",
    var = `arg, addr_mode, p_GRid` )

  * ret_type = _COB_UNKNOWN_ARG;
  * is_const = 0;


  if ( ! strcmp ( arg, "osnum" ) )
    {
      if ( addr_mode == _COB_regular )
	{
	  data->us = p_GRid->osnum;
	  * ret_type = _COB_arg_us;
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      "[osnum] data->us=%hd  =?=  p_GRid->osnum=%hd\n",
    	      var=`data->us, p_GRid->osnum`)
	}
      else if ( addr_mode == _COB_address )
	{
	  data->p = (char *) & (p_GRid->osnum);
	  * ret_type = _COB_arg_p;
	  /***  * is_const = 1;		JAJ:02/04/91  ***/
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      "[&osnum] data->p=(0x)%x  =?=  & p_GRid->osnum=(0x)%x\n",
    	      var=`data->p, &(p_GRid->osnum)`)
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      " * data->p=%hd  =?=  p_GRid->osnum=%hd\n",
    	      var=`*data->p, p_GRid->osnum`)
	}
    }  /*** osnum ***/
  else if ( ! strcmp ( arg, "objid" ) )
    {
      if ( addr_mode == _COB_regular )
	{
	  data->oid = p_GRid->objid;
	  * ret_type = _COB_arg_oid;
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      "[objid] data->oid=%d  =?=  p_GRid->objid=%d\n",
    	      var=`data->oid, p_GRid->objid`)
	}
      else if ( addr_mode == _COB_address )
	{
	  data->p = (char *) & (p_GRid->objid);
	  * ret_type = _COB_arg_p;
	  /***  * is_const = 1;		JAJ:02/04/91  ***/
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      "[&objid] data->p=(0x)%x  =?=  & p_GRid->objid=(0x)%x\n",
    	      var=`data->p, &(p_GRid->objid)`)
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      " * data->p=%d  =?=  p_GRid->objid=%d\n",
    	      var=`*data->p, p_GRid->objid`)
	}
    }  /*** objid ***/


  _bugprint(bflag=TFLAG,str=
    "-COB_process_GRid_arg():  data->[l] = %ld, *ret_type = %d\n",
    var = `data->l, *ret_type` );
 
  return( 1 );

} /*** end of function COB_process_GRid_arg () ***/



COB_process_GRmd_env_arg ( addr_mode, p_GRmd_env, arg,
			data, ret_type, is_const )
	/* Incoming */
  int		  addr_mode;	/* == _COB_regular  for regular data  */
				/* == _COB_indirect for "*<arg>"      */
				/* == _COB_address  for "&<arg>"      */
struct GRmd_env * p_GRmd_env;  /*ptr to real GRmd_env to get data from*/
  char  	* arg;		/* arg string to find a value for;    */
				/*   starts at			      */
		/*   me->event1.located_object[2].module_info.md_id   */
		/*                                            ^	      */
	/* Outgoing */
  COB_arg_union	* data;		/* value of arg string variable       */
  int		* ret_type;	/* type of value found for arg string */
				/*   (see COB_arg.h)		      */
  char		* is_const;	/* set to 1 => this variable value is */
				/*   "constant" and needn't be looked */
				/*   up ever again		      */
{
  _bugprint(bflag=TFLAG,str=
   "+COB_process_GRmd_env_arg(arg='%s', addr_mode=%d, p_GRmd_env=(0x)%x):\n",
    var = `arg, addr_mode, p_GRmd_env` )

  * ret_type = _COB_UNKNOWN_ARG;
  * is_const = 0;


  if ( ! strcmp ( arg, "md_id" ) )
    {
      if ( addr_mode == _COB_address )
	{
	  data->p = (char *) & (p_GRmd_env->md_id);
	  * ret_type = _COB_arg_p;
	  /***  * is_const = 1;		JAJ:02/04/91  ***/
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      "[&md_id] data->p=(0x)%x  =?=  & p_GRmd_env->md_id=(0x)%x\n",
    	      var=`data->p, &(p_GRmd_env->md_id)`)
	}
    }  /*** &md_id ***/
  else if ( ! strncmp ( arg, "md_id.", 6 ) )
    {
      _bugprint(bflag=CEO_LOCATE_debug,str=
	    "Calling COB_process_GRid_arg ('%s', p_GRid=(0x)%x )\n",
	    var = `&arg[6], & (p_GRmd_env->md_id)` )
      COB_process_GRid_arg ( addr_mode,
				& ( p_GRmd_env->md_id ),
				& arg[6], data, ret_type, is_const );
    }  /*** md_id.____ ***/
  else if ( ! strcmp ( arg, "md_env" ) )
    {
      if ( addr_mode == _COB_address )
	{
	  data->p = (char *) & (p_GRmd_env->md_env);
	  * ret_type = _COB_arg_p;
	  /***  * is_const = 1;		JAJ:02/04/91  ***/
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      "[&md_env] data->p=(0x)%x  =?=  & p_GRmd_env->md_env=(0x)%x\n",
    	      var=`data->p, &(p_GRmd_env->md_env)`)
	}
    }  /*** &md_id ***/
  else if ( ! strncmp ( arg, "md_env.", 7 ) )
    {
      _bugprint(bflag=CEO_LOCATE_debug,str=
	    "Calling COB_process_GRid_arg ('%s', p_GRid=(0x)%x )\n",
	    var = `&arg[7], & (p_GRmd_env->md_env)` )
      COB_process_GRmdenv_info_arg ( addr_mode,
				& ( p_GRmd_env->md_env ),
				& arg[7], data, ret_type, is_const );
    }  /*** md_env.____ ***/


  _bugprint(bflag=TFLAG,str=
    "-COB_process_GRmd_env_arg():  data->[l] = %ld, *ret_type = %d\n",
    var = `data->l, *ret_type` );

    return( 1 );

} /*** end of function COB_process_GRmd_env_arg () ***/



COB_process_GRmdenv_info_arg ( addr_mode, p_GRmdenv_info, arg,
			data, ret_type, is_const )
	/* Incoming */
  int		  addr_mode;	/* == _COB_regular  for regular data  */
				/* == _COB_indirect for "*<arg>"      */
				/* == _COB_address  for "&<arg>"      */
  struct GRmdenv_info * p_GRmdenv_info;
			/* ptr to real GRmdenv_info to get data from  */
  char  	* arg;		/* arg string to find a value for;    */
				/*   starts at			      */
	/*   me->event1.located_object[2].module_info.md_env.matrix   */
	/*                                                   ^	      */
	/* Outgoing */
  COB_arg_union	* data;		/* value of arg string variable       */
  int		* ret_type;	/* type of value found for arg string */
				/*   (see COB_arg.h)		      */
  char		* is_const;	/* set to 1 => this variable value is */
				/*   "constant" and needn't be looked */
				/*   up ever again		      */
{
  int		arg_num = -1;
  char	      * ch;
  extern	COB_fetch_first_arg_num();

  _bugprint(bflag=TFLAG,str=
   "+COB_process_GRmdenv_info_arg(arg='%s', addr_mode=%d, p_GRmdenv_info=(0x)%x):\n",
    var = `arg, addr_mode, p_GRmdenv_info` )

  * ret_type = _COB_UNKNOWN_ARG;
  * is_const = 0;


  if ( ! strcmp ( arg, "matrix_type" ) )
    {
      if ( addr_mode == _COB_regular )
	{
	  data->s = p_GRmdenv_info->matrix_type;
	  * ret_type = _COB_arg_s;
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      "[matrix_type] data->s=%hd  =?=  p_GRmdenv_info->matrix_type=%hd\n",
    	      var=`data->s, p_GRmdenv_info->matrix_type`)
	}
      else if ( addr_mode == _COB_address )
	{
	  data->p = (char *) & (p_GRmdenv_info->matrix_type);
	  * ret_type = _COB_arg_p;
	  /***  * is_const = 1;		JAJ:02/04/91  ***/
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      "[&matrix_type] data->p=(0x)%x  =?=  & p_GRmdenv_info->matrix_type=(0x)%x\n",
    	      var=`data->p, &(p_GRmdenv_info->matrix_type)`)
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      "  *data->p=%hd  =?=  p_GRmdenv_info->matrix_type=%hd\n",
    	      var=`*data->p, p_GRmdenv_info->matrix_type`)
	}
    }  /*** &matrix_type ***/
  else if ( ! strcmp ( arg, "matrix" ) )
    {
      if ( addr_mode == _COB_regular )
	{
	  data->p = (char *) p_GRmdenv_info->matrix;
	  * ret_type = _COB_arg_p;
	  /***  * is_const = 1;		JAJ:02/04/91  ***/
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      "[matrix] data->p=(0x)%x  =?=  p_GRmdenv_info->matrix=(0x)%x\n",
    	      var=`data->p, p_GRmdenv_info->matrix`)
	}
    }  /*** &matrix ***/
  else if ( ! strncmp ( arg, "matrix[", 7 ) )
    {
#define IGRMATRIX_DIM 16
      arg_num = COB_fetch_first_arg_num ( arg, &ch );
      if ( arg_num < 0  ||  arg_num >= IGRMATRIX_DIM )
	{
	  fprintf ( stderr,
	    "\nCOB_process_GRmd_env_arg():  Reference to IGRmatrix element %d in state table argument is invalid\n\n", arg_num );
	  goto quit;
	}

      if ( addr_mode == _COB_regular )
	{
	  data->d = p_GRmdenv_info->matrix[arg_num];
	  * ret_type = _COB_arg_d;
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      "  data->d=%lf  =?=  p_GRmdenv_info->matrix[%d]=%lf\n",
    	      var=`data->d, arg_num, p_GRmdenv_info->matrix[arg_num]`)
	}
      else if ( addr_mode == _COB_address )
	{
	  data->p = (char *) & (p_GRmdenv_info->matrix[arg_num]);
	  * ret_type = _COB_arg_p;
	  /***  * is_const = 1;		JAJ:02/04/91  ***/
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      "  data->p=(0x)%x  =?=  & p_GRmdenv_info->matrix[%d]=(0x)%x\n",
    	      var=`data->p, arg_num,&(p_GRmdenv_info->matrix[arg_num])`)
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      "  *data->p=%lf  =?=  p_GRmdenv_info->matrix[%d]=%lf\n",
    	      var=`*data->p, arg_num, p_GRmdenv_info->matrix[arg_num]`)
	}
    }  /*** matrix[x] ***/

quit:
  _bugprint(bflag=TFLAG,str=
    "-COB_process_GRmdenv_info_arg():  data->[l] = %ld, *ret_type = %d\n",
    var = `data->l, *ret_type` );

  return( 1 );

} /*** end of function COB_process_GRmdenv_info_arg () ***/



COB_process_GRparms_arg ( addr_mode, p_GRparms, arg,
			data, ret_type, is_const )
	/* Incoming */
  int		  addr_mode;	/* == _COB_regular  for regular data  */
				/* == _COB_indirect for "*<arg>"      */
				/* == _COB_address  for "&<arg>"      */
  struct GRparms * p_GRparms; /* ptr to real GRparms to get data from */
  char  	* arg;		/* arg string to find a value for;    */
				/*   starts at			      */
			/*  me->event1.located_object[2].geom_parms.u */
			/*                                          ^ */
	/* Outgoing */
  COB_arg_union	* data;		/* value of arg string variable       */
  int		* ret_type;	/* type of value found for arg string */
				/*   (see COB_arg.h)		      */
  char		* is_const;	/* set to 1 => this variable value is */
				/*   "constant" and needn't be looked */
				/*   up ever again		      */
{
  _bugprint(bflag=TFLAG,str=
   "+COB_process_GRparms_arg(arg='%s', addr_mode=%d, p_GRparms=(0x)%x):\n",
    var = `arg, addr_mode, p_GRparms` )

  * ret_type = _COB_UNKNOWN_ARG;
  * is_const = 0;


  if ( ! strcmp ( arg, "u" ) )
    {
      if ( addr_mode == _COB_regular )
	{
	  data->d = p_GRparms->u;
	  * ret_type = _COB_arg_d;
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      "[u] data->d=%lf  =?=  p_GRparms->u=%lf\n",
    	      var=`data->d, p_GRparms->u`)
	}
      else if ( addr_mode == _COB_address )
	{
	  data->p = (char *) & (p_GRparms->u);
	  * ret_type = _COB_arg_p;
	  /***  * is_const = 1;		JAJ:02/04/91  ***/
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      "[&u] data->p=(0x)%x  =?=  & p_GRparms->u=(0x)%x\n",
    	      var=`data->p, &(p_GRparms->u)`)
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      "  *data->p=%lf  =?=  p_GRparms->u=%lf\n",
    	      var=`*data->p, p_GRparms->u`)
	}
    }  /*** u ***/
  else if ( ! strcmp ( arg, "v" ) )
    {
      if ( addr_mode == _COB_regular )
	{
	  data->d = p_GRparms->v;
	  * ret_type = _COB_arg_d;
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      "[v] data->d=%lf  =?=  p_GRparms->v=%lf\n",
    	      var=`data->d, p_GRparms->v`)
	}
      else if ( addr_mode == _COB_address )
	{
	  data->p = (char *) & (p_GRparms->v);
	  * ret_type = _COB_arg_p;
	  /***  * is_const = 1;		JAJ:02/04/91  ***/
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      "[&v] data->p=(0x)%x  =?=  & p_GRparms->v=(0x)%x\n",
    	      var=`data->p, &(p_GRparms->v)`)
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      "  *data->p=%lf  =?=  p_GRparms->v=%lf\n",
    	      var=`*data->p, p_GRparms->v`)
	}
    }  /*** v ***/
  else if ( ! strcmp ( arg, "polygon_inx" ) )
    {
      if ( addr_mode == _COB_regular )
	{
	  data->s = p_GRparms->polygon_inx;
	  * ret_type = _COB_arg_s;
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      "[polygon_inx] data->s=%hd  =?=  p_GRparms->polygon_inx=%hd\n",
    	      var=`data->s, p_GRparms->polygon_inx`)
	}
      else if ( addr_mode == _COB_address )
	{
	  data->p = (char *) & (p_GRparms->polygon_inx);
	  * ret_type = _COB_arg_p;
	  /***  * is_const = 1;		JAJ:02/04/91  ***/
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      "[&polygon_inx] data->p=(0x)%x  =?=  & p_GRparms->polygon_inx=(0x)%x\n",
    	      var=`data->p, &(p_GRparms->polygon_inx)`)
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      "  *data->p=%hd  =?=  p_GRparms->polygon_inx=%hd\n",
    	      var=`*data->p, p_GRparms->polygon_inx`)
	}
    }  /*** polygon_inx ***/
  else if ( ! strcmp ( arg, "leaf_id" ) )
    {
      if ( addr_mode == _COB_address )
	{
	  data->p = (char *) & (p_GRparms->leaf_id);
	  * ret_type = _COB_arg_p;
	  /***  * is_const = 1;		JAJ:02/04/91  ***/
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      "[&leaf_id] data->p=(0x)%x  =?=  & p_GRparms->leaf_id=(0x)%x\n",
    	      var=`data->p, &(p_GRparms->leaf_id)`)
	}
    }  /*** &leaf_id ***/
  else if ( ! strncmp ( arg, "leaf_id.", 8 ) )
    {
      _bugprint(bflag=CEO_LOCATE_debug,str=
	    "Calling COB_process_GRid_arg ('%s', p_GRid=(0x)%x )\n",
	    var = `&arg[8], & (p_GRparms->leaf_id)` )
      COB_process_GRid_arg ( addr_mode,
				& ( p_GRparms->leaf_id ),
				& arg[8], data, ret_type, is_const );
    }  /*** leaf_id.____ ***/


  _bugprint(bflag=TFLAG,str=
    "-COB_process_GRparms_arg():  data->[l] = %ld, *ret_type = %d\n",
    var = `data->l, *ret_type` );
 
  return( 1 );

} /*** end of function COB_process_GRparms_arg () ***/



void  COB_process_GRdpb_scale_arg ( addr_mode, p_GRdpb_scale, arg,
			data, ret_type, is_const )
	/* Incoming */
  int		  addr_mode;	/* == _COB_regular  for regular data  */
				/* == _COB_indirect for "*<arg>"      */
				/* == _COB_address  for "&<arg>"      */
  struct GRdpb_scale * p_GRdpb_scale; /* ptr to real GRdpb_scale to get data from */
  char  	* arg;		/* arg string to find a value for;    */
				/*   starts at			      */
				/*  me->ActiveScale.Active_xscale     */
				/*                  ^		      */
	/* Outgoing */
  COB_arg_union	* data;		/* value of arg string variable       */
  int		* ret_type;	/* type of value found for arg string */
				/*   (see COB_arg.h)		      */
  char		* is_const;	/* set to 1 => this variable value is */
				/*   "constant" and needn't be looked */
				/*   up ever again		      */
{
  _bugprint(bflag=TFLAG,str=
   "+COB_process_GRdpb_scale_arg(arg='%s', addr_mode=%d, p_GRdpb_scale=(0x)%x):\n",
    var = `arg, addr_mode, p_GRdpb_scale` )

  * ret_type = _COB_UNKNOWN_ARG;
  * is_const = 0;


  if ( ! strcmp ( arg, "Active_xscale" ) )
    {
      if ( addr_mode == _COB_regular )
	{
	  data->d = p_GRdpb_scale->Active_xscale;
	  * ret_type = _COB_arg_d;
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      "[Active_xscale] data->d=%lf  =?=  p_GRdpb_scale->Active_xscale=%lf\n",
    	      var=`data->d, p_GRdpb_scale->Active_xscale`)
	}
      else if ( addr_mode == _COB_address )
	{
	  data->p = (char *) & (p_GRdpb_scale->Active_xscale);
	  * ret_type = _COB_arg_p;
	  /***  * is_const = 1;		JAJ:02/04/91  ***/
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      "[&Active_xscale] data->p=(0x)%x  =?=  & p_GRdpb_scale->Active_xscale=(0x)%x\n",
    	      var=`data->p, &(p_GRdpb_scale->Active_xscale)`)
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      "  *data->p=%lf  =?=  p_GRdpb_scale->Active_xscale=%lf\n",
    	      var=`*data->p, p_GRdpb_scale->Active_xscale`)
	}
    }  /*** Active_xscale ***/
  else if ( ! strcmp ( arg, "Active_yscale" ) )
    {
      if ( addr_mode == _COB_regular )
	{
	  data->d = p_GRdpb_scale->Active_yscale;
	  * ret_type = _COB_arg_d;
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      "[Active_yscale] data->d=%lf  =?=  p_GRdpb_scale->Active_yscale=%lf\n",
    	      var=`data->d, p_GRdpb_scale->Active_yscale`)
	}
      else if ( addr_mode == _COB_address )
	{
	  data->p = (char *) & (p_GRdpb_scale->Active_yscale);
	  * ret_type = _COB_arg_p;
	  /***  * is_const = 1;		JAJ:02/04/91  ***/
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      "[&Active_yscale] data->p=(0x)%x  =?=  & p_GRdpb_scale->Active_yscale=(0x)%x\n",
    	      var=`data->p, &(p_GRdpb_scale->Active_yscale)`)
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      "  *data->p=%lf  =?=  p_GRdpb_scale->Active_yscale=%lf\n",
    	      var=`*data->p, p_GRdpb_scale->Active_yscale`)
	}
    }  /*** Active_yscale ***/
  else if ( ! strcmp ( arg, "Active_zscale" ) )
    {
      if ( addr_mode == _COB_regular )
	{
	  data->d = p_GRdpb_scale->Active_zscale;
	  * ret_type = _COB_arg_d;
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      "[Active_zscale] data->d=%lf  =?=  p_GRdpb_scale->Active_zscale=%lf\n",
    	      var=`data->d, p_GRdpb_scale->Active_zscale`)
	}
      else if ( addr_mode == _COB_address )
	{
	  data->p = (char *) & (p_GRdpb_scale->Active_zscale);
	  * ret_type = _COB_arg_p;
	  /***  * is_const = 1;		JAJ:02/04/91  ***/
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      "[&Active_zscale] data->p=(0x)%x  =?=  & p_GRdpb_scale->Active_zscale=(0x)%x\n",
    	      var=`data->p, &(p_GRdpb_scale->Active_zscale)`)
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      "  *data->p=%lf  =?=  p_GRdpb_scale->Active_zscale=%lf\n",
    	      var=`*data->p, p_GRdpb_scale->Active_zscale`)
	}
    }  /*** Active_zscale ***/


  _bugprint(bflag=TFLAG,str=
    "-COB_process_GRdpb_scale_arg():  data->d=%lf, *ret_type = %d\n",
    var = `data->d, *ret_type` );

} /*** end of function COB_process_GRdpb_scale_arg () ***/



void   COB_process_IGRdisplay_arg ( addr_mode, p_IGRdisplay, arg,
			data, ret_type, is_const )
	/* Incoming */
  int		  addr_mode;	/* == _COB_regular  for regular data  */
				/* == _COB_indirect for "*<arg>"      */
				/* == _COB_address  for "&<arg>"      */
  struct IGRdisplay * p_IGRdisplay; /* ptr to real IGRdisplay to get data from */
  char  	* arg;		/* arg string to find a value for;    */
				/*   starts at			      */
				/*  me->ActiveDisplay.rgb_value	      */
				/*                    ^		      */
				/*  rgb_value is no longer a field of */
				/*  the display structures.	      */
	/* Outgoing */
  COB_arg_union	* data;		/* value of arg string variable       */
  int		* ret_type;	/* type of value found for arg string */
				/*   (see COB_arg.h)		      */
  char		* is_const;	/* set to 1 => this variable value is */
				/*   "constant" and needn't be looked */
				/*   up ever again		      */
{
  _bugprint(bflag=TFLAG,str=
   "+COB_process_IGRdisplay_arg(arg='%s', addr_mode=%d, p_IGRdisplay=(0x)%x):\n",
    var = `arg, addr_mode, p_IGRdisplay` )

  * ret_type = _COB_UNKNOWN_ARG;
  * is_const = 0;


  if ( ! strcmp ( arg, "rgb_value" ) )
    {
#ifdef RBG_WERE_STILL_WITH_US
      if ( addr_mode == _COB_regular )
	{
	  data->i = p_IGRdisplay->rgb_value;
	  * ret_type = _COB_arg_i;
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      "[rgb_value] data->i=%d  =?=  p_IGRdisplay->rgb_value=%d\n",
    	      var=`data->i, p_IGRdisplay->rgb_value`)
	}
      else if ( addr_mode == _COB_address )
	{
	  data->p = (char *) & (p_IGRdisplay->rgb_value);
	  * ret_type = _COB_arg_p;
	  /***  * is_const = 1;		JAJ:02/04/91  ***/
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      "[&rgb_value] data->p=(0x)%x  =?=  & p_IGRdisplay->rgb_value=(0x)%x\n",
    	      var=`data->p, &(p_IGRdisplay->rgb_value)`)
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      "  *data->p=%d  =?=  p_IGRdisplay->rgb_value=%d\n",
    	      var=`*data->p, p_IGRdisplay->rgb_value`)
	}
#endif
    }  /*** rgb_value ***/
  else if ( ! strcmp ( arg, "color" ) )
    {
      if ( addr_mode == _COB_regular )
	{
	  data->us = p_IGRdisplay->color;
	  * ret_type = _COB_arg_us;
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      "[color] data->us=%hd  =?=  p_IGRdisplay->color=%hd\n",
    	      var=`data->us, p_IGRdisplay->color`)
	}
      else if ( addr_mode == _COB_address )
	{
	  data->p = (char *) & (p_IGRdisplay->color);
	  * ret_type = _COB_arg_p;
	  /***  * is_const = 1;		JAJ:02/04/91  ***/
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      "[&color] data->p=(0x)%x  =?=  & p_IGRdisplay->color=(0x)%x\n",
    	      var=`data->p, &(p_IGRdisplay->color)`)
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      "  *data->p=%hd  =?=  p_IGRdisplay->color=%hd\n",
    	      var=`*data->p, p_IGRdisplay->color`)
	}
    }  /*** color ***/
  else if ( ! strcmp ( arg, "weight" ) )
    {
      if ( addr_mode == _COB_regular )
	{
	  data->uc = p_IGRdisplay->weight;
	  * ret_type = _COB_arg_uc;
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      "[weight] data->uc=%c  =?=  p_IGRdisplay->weight=%c\n",
    	      var=`data->uc, p_IGRdisplay->weight`)
	}
      else if ( addr_mode == _COB_address )
	{
	  data->p = (char *) & (p_IGRdisplay->weight);
	  * ret_type = _COB_arg_p;
	  /***  * is_const = 1;		JAJ:02/04/91  ***/
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      "[&weight] data->p=(0x)%x  =?=  & p_IGRdisplay->weight=(0x)%x\n",
    	      var=`data->p, &(p_IGRdisplay->weight)`)
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      "  *data->p=%c  =?=  p_IGRdisplay->weight=%c\n",
    	      var=`*data->p, p_IGRdisplay->weight`)
	}
    }  /*** weight ***/
  else if ( ! strcmp ( arg, "style" ) )
    {
      if ( addr_mode == _COB_regular )
	{
	  data->uc = p_IGRdisplay->style;
	  * ret_type = _COB_arg_uc;
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      "[style] data->uc=%c  =?=  p_IGRdisplay->style=%c\n",
    	      var=`data->uc, p_IGRdisplay->style`)
	}
      else if ( addr_mode == _COB_address )
	{
	  data->p = (char *) & (p_IGRdisplay->style);
	  * ret_type = _COB_arg_p;
	  /***  * is_const = 1;		JAJ:02/04/91  ***/
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      "[&style] data->p=(0x)%x  =?=  & p_IGRdisplay->style=(0x)%x\n",
    	      var=`data->p, &(p_IGRdisplay->style)`)
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      "  *data->p=%c  =?=  p_IGRdisplay->style=%c\n",
    	      var=`*data->p, p_IGRdisplay->style`)
	}
    }  /*** style ***/


  _bugprint(bflag=TFLAG,str=
    "-COB_process_IGRdisplay_arg():  data->d=%lf, *ret_type = %d\n",
    var = `data->d, *ret_type` );

} /*** end of function COB_process_IGRdisplay_arg () ***/

end implementation CEO_LOCATE;
