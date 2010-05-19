/* $Id: VDSText_fn.I,v 1.1.1.1 2001/01/04 21:08:53 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdlocate/func / VDSText_fn.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSText_fn.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:53  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.2  1995/11/29  13:53:20  pinnacle
# Replaced: ./vdlocate/func/VDSText_fn.I for:  by ksundar for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*\
Description
   This is the implementation file containing supporting 
   functions for the class VDCmdLcNm

History
   12-09-91 Genesis at ISDC


	- VDSset_null_text
	- VDSget_select_text
	- VDSread_expr_dir
	- VDSsplit_string
	- VDSadd_in_textset_list
	- VDSwrite_expr_dir
	- VDSclean_expr_dir
	- VDSset_active_textset
	- VDSfill_textset_list
	- VDSset_null_list_entry
	- VDStextset_part_expression
	- VDSshow_textset_list
	- VDSget_textset
	- VDSget_contend

\*/


class implementation Root;

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "godef.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DIomac.h"
#include "DImacros.h"
#include "expression.h"
#include "expmacros.h"
#include "OMerrordef.h"
#include "OMprimitives.h"
#include "parametric.h"
#include "OMminimum.h"
#include "FI.h"

#include "AS_status.h"
#include "VDSpathdef.h"
#include "VDSudp_mac.h"
#include "exdef.h"
#include "exmacros.h"
#include "VDStextdef.h"

from	text_exp	import	NDgive_structure;



#define AS_DEBUG	1

/* ---------------------------------------------------------------------- */
/* VDSset_null_text							  */
/* ---------------------------------------------------------------------- */
int	VDSset_null_text( textset )

struct	VDStextset	*textset;
/*\
Description
	Initialisation values for the structure VDStextset
\*/
/*.VDSset_null_text*/
{
  if( textset == NULL ){
	printf(" ERROR: fct VDSset_null_text, no textset list available \n");
	goto wrapup;
  }

  textset->exp_name[0] = '\0';

  textset->select[0] = '\0';
  textset->expres[0] = '\0';
  textset->prefix[0] = '\0';
  textset->suffix[0] = '\0';

  return TRUE;

wrapup:

  return FALSE;
}

/* ---------------------------------------------------------------------- */
/* VDSget_select_text							  */
/* ---------------------------------------------------------------------- */
int	VDSget_select_text( list, text, expr_dir, mod_env )

struct	VDStextlist	*list;	   /*(I) list of textset */
struct	VDStextset	*text;	   /*(O) select text of the list */
IGRchar			*expr_dir; /*(I) directory :<filename>:set_ref */
struct	GRmd_env	*mod_env;  /*(I) Module environment info*/ 
/*\
Description
	This function fills the argument "text" if the select expression in 
	the "set_refer" dir correspond to a text in the given list.
	"text" is then this found text, otherwise "text" is set to NULL (\0).
	


\*/
/*.VDSget_select_text*/
{
IGRint		i, resp;
IGRlong		msg, status;
IGRchar		select_str[DI_PATH_MAX];
IGRchar		part2[DI_PATH_MAX];
struct	GRid	tmp_obj;
struct	ret_struct ret_str;

  if( list == NULL || expr_dir == NULL || mod_env == NULL){
	printf(" ERROR: fct VDSget_select_text, input arg cannot be NULL \n");
	goto wrapup;
  }
  if( text == NULL ){
	printf(" ERROR: fct VDSget_select_text, no textset structure defined \n");
	goto wrapup;
  }

  resp = VDSset_null_text( text );
  if( ! resp ){
    printf(" ERROR: fct VDSset_null_text failed\n");
    goto wrapup;
  }

  /*| find expressions string */
  tmp_obj.objid = NULL_OBJID;
  status = di$translate( 	objname = VDS_ACT_SELECT,
				path	= expr_dir,
				p_objid = &tmp_obj.objid,
				p_osnum = &tmp_obj.osnum );
  if( status == DIR_S_SUCCESS ){
  /* 
   * get the exp_syntax for the VDS_ACT_SELECT
   */
    /*"VDS_ACT_SELECT id: %d, %d\n",tmp_obj.objid,tmp_obj.osnum*/
    status = om$send( msg = message text_exp.NDgive_structure(
					&msg,
					&ret_str,
					mod_env ),
			targetid = tmp_obj.objid,
			targetos = tmp_obj.osnum,
			senderid = NULL_OBJID );

    /*" VDS_ACT_SELECT contend : <%s>\n", ret_str.var.text_st.text_string */
    if(ret_str.var.text_st.text_string[0] == '\0') {
    	/*|no select text */
    	return TRUE;
    }
    tmp_obj.objid = NULL_OBJID;
    status = di$translate( 	objname = ret_str.var.text_st.text_string,
				path	= expr_dir,
				p_objid = &tmp_obj.objid,
				p_osnum = &tmp_obj.osnum );
    if( status == DIR_S_SUCCESS ){
    /* 
     * get the exp_syntax for the default expression
     */
     /*"VDS_ACT_SELECT contend id: %d, %d\n",tmp_obj.objid,tmp_obj.osnum*/

	status = om$send( msg = message text_exp.NDgive_structure(
					&msg,
					&ret_str,
					mod_env ),
			targetid = tmp_obj.objid,
			targetos = tmp_obj.osnum,
			senderid = NULL_OBJID );
  
	/*" string : <%s>\n", ret_str.var.text_st.text_string */

	resp = VDStextset_part_expression( ret_str.var.text_st.text_string,
				    select_str, part2 );
  	if( resp == FALSE ){
    	  printf("ERROR: fct VDStextset_part_expression failed \n");
    	  goto wrapup;
	}
	/*" select: <%s>\n", select_str */
	for( i=0; i<list->num_textset; i++ ){
	  /*" select : <%s>\n", list->text[i].select */
	  if( strcmp( list->text[i].select, select_str ) == 0 ){

	    strcpy( text->select, list->text[i].select );
	    strcpy( text->prefix, list->text[i].prefix );
	    strcpy( text->expres, list->text[i].expres );
	    strcpy( text->suffix, list->text[i].suffix );
	
	    break;
    	  }
	}
    }
  }

/*^
printf("text result: sel: <%s>, pref: <%s>, expres: <%s>, suff: <%s>\n",
				text->select,text->prefix,
				text->expres,text->suffix);
*/

  return TRUE;

wrapup:
  return FALSE;
}

/* ---------------------------------------------------------------------- */
/* VDSread_expr_dir							  */
/* ---------------------------------------------------------------------- */
int	VDSread_expr_dir( list, expr_dir, mod_env)

struct	VDStextlist	*list;		/*(O) list returned	*/
IGRchar			*expr_dir;	/*(I) directory :<filename>:set_ref */
struct	GRmd_env	*mod_env;	/*(I) Module environment info */
/*\
Description
	This function read the expression from the directory an stored
	the found information in a list (malloc list and init it)
        list->text must be initialised and deallocate by the user 
\*/
/*.VDSread_expr_dir*/
{
IGRchar		loc_expr[DI_PATH_MAX];
IGRchar		expr_name[DI_PATH_MAX];
IGRint		option, i, nb_lines;
struct	GRid	tmp_obj;
DIgrid		*exp;
IGRlong		resp, status, msg;
struct	ret_struct 	ret_str;
struct	VDStextset	textset;

  exp = NULL;
  nb_lines = 0;

  if( list == NULL ){
	printf(" ERROR: fct VDSread_expr_dir, no textset list available \n");
	goto wrapup;
  }
  if( expr_dir == NULL || mod_env == NULL){
	printf(" ERROR: fct VDSread_expr_dir, input arg cannot be NULL \n");
	goto wrapup;
  }

/*"expr_dir input: %s\n",expr_dir */
 

  /* | delete the previous situation (free list->text) */
  if( list->text != NULL )
	free(  list->text );

  list->text = NULL;

  list->num_textset = 0;
  list->max_textset = 0;
  list->inc_textset = 10;
  list->max_textset += list->inc_textset;

  /*" allocate list->text of %d\n", list->max_textset */

  list->text = (struct VDStextset *)malloc( 
		list->max_textset * sizeof( struct VDStextset ));
  if( list->text == NULL ){
	printf("ERROR: fct VDSread_expr_dir, bad allocation of testlist(%d)\n", list->max_textset );
	goto wrapup;
  }
  for( i=0; i<list->max_textset; i++ ){
    /*" set null text in list.text[%d] \n", i */
    resp = VDSset_null_text( &(list->text[i]) );
    if( ! resp ){
	  printf(" ERROR: fct VDSset_null_text failed \n");
	  goto wrapup;
    }
  }

/**/
/*| test if directory exist */
/**/

  tmp_obj.objid = NULL_OBJID;
  status = di$translate( objname = expr_dir,
			 p_objid = &tmp_obj.objid,
			 p_osnum = &tmp_obj.osnum);
  if( !(status&1 )){
	printf(" ERROR: fct VDSread_expr_dir, directory %s doesn't exist\n",expr_dir);
	goto wrapup;
  }
  sprintf( loc_expr, "%s:%s*", expr_dir, VDS_EXP_NAME );

  /*" loc_expr to dump : <%s>\n", loc_expr */

  nb_lines = 0;
  exp      = NULL;

  status = di$dump(	regexp = loc_expr,
			lines  = NULL ,
			ptr    = &nb_lines,
			grids  = &exp);

  if( status != DIR_S_SUCCESS ){
	if( status == DIR_W_NAME_NOT_FOUND ){
    		/*| no lines found */ 
    		if( exp ) {free( exp );exp = NULL;}
    		return TRUE;
	}
	else {di$report_error( sts = status ); goto wrapup;}
  }

  if( nb_lines == 0 ){
    /*| no results found */
    if( exp ) {free( exp );exp = NULL;}
    return TRUE;
  }    
	

  /*" nb_lines: %d \n", nb_lines */
  for( i=0; i<nb_lines; i++){

    /*" exp[%d]: [%d,%d]\n", i, exp[i].objid, exp[i].osnum */

    /* test expression of type */
    expr_name[0] = '\0';
    status = di$untranslate( 	objname = expr_name,
				objid	= exp[i].objid,
				osnum	= exp[i].osnum );
    if( status == DIR_S_SUCCESS ){
    	/*" untranslate expr_name : <%s>\n", expr_name */
	/*| get expression */
	status = om$send( msg = message text_exp.NDgive_structure(
					&msg,
					&ret_str,
					mod_env ),
			  targetid = exp[i].objid,
			  targetos = exp[i].osnum,
			  senderid = NULL_OBJID );
	if(! (status & 1)){
          printf(" ERROR: failure text_exp.NDgive_structure\n");
          as$status( sts = status, action = RET_STATUS);
          goto wrapup;
	}
	/*"ret_str: <%s>\n", ret_str.var.text_st.text_string */
	resp = VDSsplit_string( ret_str.var.text_st.text_string, &textset );
	if( ! resp ){
	  printf("\nERROR In Locate by name expressions\n");
	  printf("WARNING expression <%s> is not stored\n", ret_str.var.text_st.text_string);
	  printf("select must be < %d\n",VDS_SELECT_MAX);
	  printf("prefix must be < %d\n",VDS_PREFIX_MAX);
	  printf("expres must be < %d\n",VDS_EXPRES_MAX);
	  printf("suffix must be < %d\n",VDS_SUFFIX_MAX);
	  continue;
	}
        option = 1; /* if texset already exist,modify it with textset */
	resp = VDSadd_in_textset_list( list, &textset, option, NULL );
	if( ! resp ){
	  printf(" ERROR: fct VDSadd_in_textset_list failed\n");
	  goto wrapup;
	}
    }
  } /* for .. */
  
  /*^ VDSshow_textset_list( list ); */

  if( exp ) {free( exp );exp = NULL;}
  return TRUE;

wrapup:
  if( exp ) {free( exp );exp = NULL;}
  return FALSE;
}

/* ---------------------------------------------------------------------- */
/* VDSsplit_string							  */
/* ---------------------------------------------------------------------- */
int	VDSsplit_string( string, textset )

IGRchar			*string;   /*(I) string that must be split */
struct	VDStextset	*textset;  /*(O) result(prefix, exp, suffix) */
/*\
Description
	Split the string by the VDS_SEPARATOR ('|') and set the result into
	the textset structure
\*/
/*.VDSsplit_string*/
{
IGRchar	my_str[DI_PATH_MAX], select[DI_PATH_MAX],prefix[DI_PATH_MAX],
	expres[DI_PATH_MAX],suffix[DI_PATH_MAX];
IGRint	resp1, resp2, resp3, len;

  if( string == NULL || textset == NULL){
	printf(" ERROR: fct VDSsplit_string, no arg can be NULL \n");
	return FALSE;
  }


  len = strlen(string);

  /*" string : <%s>, len: %d\n", string ,len*/
  if(len > DI_PATH_MAX) {
	/*^printf("ERROR:fct VDSsplit_string, string is > DI_PATH_MAX\n");*/
	return FALSE;
  }
  resp1 = VDStextset_part_expression( string, select, my_str );
  resp2 = VDStextset_part_expression( my_str, prefix, my_str );
  resp3 = VDStextset_part_expression( my_str, expres, suffix );

  if(( resp1 == FALSE ) || (resp2 == FALSE ) || (resp3 == FALSE )){
    	/*^printf("ERROR: fct VDStextset_part_expression failed [%d/%d/%d]\n",  
						resp1, resp2, resp3 );*/
    	return FALSE;
  }

  if( VDS_SELECT_MAX < strlen( select )){
	/*^printf("ERROR: fct VDSsplit_string, select string must be < VDS_SELECT_MAX\n");*/
    	return FALSE;
  }
  else strcpy(textset->select,select);

  if( VDS_PREFIX_MAX < strlen( prefix )){
	/*^printf("ERROR: fct VDSsplit_string, select string must be < VDS_PREFIX_MAX\n");*/
    	return FALSE;
  }
  else strcpy(textset->prefix,prefix);

  if( VDS_EXPRES_MAX < strlen( expres )){
	/*^printf("ERROR: fct VDSsplit_string, expres string must be < VDS_EXPRES_MAX\n");*/
    	return FALSE;
  }
  else strcpy(textset->expres,expres);

  if( VDS_SUFFIX_MAX < strlen( suffix )){
	/*^printf("ERROR: fct VDSsplit_string, suffix string must be < VDS_SUFFIX_MAX\n");*/
    	return FALSE;
  }
  else strcpy(textset->suffix, suffix);

/*^
printf("text result: sel: <%s>, pref: <%s>, expres: <%s>, suff: <%s>\n",
				textset->select,textset->prefix,
				textset->expres,textset->suffix);
*/
  return TRUE;
}

/* ---------------------------------------------------------------------- */
/* VDSadd_in_textset_list						  */
/* ---------------------------------------------------------------------- */
int	VDSadd_in_textset_list( list, text ,option, added)

struct	VDStextlist	*list;  /*(I) list of textset where to add */
struct	VDStextset	*text;  /*(I) text to add */
int			option; /*(I) override option */
int			*added; /*(O) 1 if text added or replace an other*/
/*\
Description
	Add the text into the list (if name of textset already exist,
	modify it if option = 1, else don't add the textset)
\*/
/*.VDSadd_in_textset_list*/
{
IGRint		index, resp, i, forget=0;

  if( added != NULL) *added = 0;
  if( list == NULL ){
	printf("ERROR: fct VDSadd_in_textset_list, no textset list available \n");
	goto wrapup;
  }
  if( text == NULL ){
	printf("ERROR: fct VDSadd_in_textset_list,no string defined \n");
	goto wrapup;
  }
  /*"option: %d\n",option */
/*
  printf("list -- num_textset: %d, max_textset: %d, inc_textset: %d\n",
						list->num_textset,
						list->max_textset,
						list->inc_textset);
*/
  if( list->num_textset >= list->max_textset ){
    list->max_textset += list->inc_textset;
    list->text = ( struct VDStextset *) om$realloc(
		ptr = (char *) list->text,
		size = list->max_textset * sizeof( struct VDStextset ));

    if( list->text == NULL ){
	printf(" ERROR: fct VDSadd_in_textset_list,bad reallocation of testlist(%d)\n", list->max_textset );
	goto wrapup;
    }
    for( i=list->num_textset; i<list->max_textset; i++ ){
	resp = VDSset_null_text( &(list->text[i]) );
	if( ! resp ){
	  printf(" ERROR: fct VDSset_null_text failed\n");
	  goto wrapup;
	}
    }
  }
  
  index = -1;
  /*" num_textset : %d\n", list->num_textset */
  if( text->select[0] != '\0' ){
    for( i=0; i<list->num_textset; i++ ){
      /*| try to  find a corresponding select name */
      if( strcmp( text->select, list->text[i].select ) == 0 ){
	index = i;
	if(option == 0) forget = 1;
	break;
      }
    }
    /*"index i: %d, forget: %d\n",i,forget*/
    if( index < 0 ){
      	index = list->num_textset;
      	/*| increment of list */
      	list->num_textset++;
    }
    if(!forget){
    	/*| copy textset */
    	strcpy( list->text[index].select, text->select );
    	strcpy( list->text[index].prefix, text->prefix );
    	strcpy( list->text[index].expres, text->expres );
    	strcpy( list->text[index].suffix, text->suffix );
    	/*^ 
		printf(" [%d] s:<%s> p:<%s> e:<%s> s:<%s>\n", index,
			list->text[index].select, list->text[index].prefix,
			list->text[index].expres, list->text[index].suffix );
     	*/
	if(added != NULL) *added = 1;
    }
  }

  return TRUE;

wrapup:

  return FALSE;
}


/* ---------------------------------------------------------------------- */
/* VDSwrite_expr_dir							  */
/* ---------------------------------------------------------------------- */
int	VDSwrite_expr_dir( list, expr_dir )

struct	VDStextlist	*list;     /*(I) list of textset to write */
IGRchar			*expr_dir; /*(I) directory :<filename>:set_ref */
/*\
Description
	This function cleans up the expression directory, then 
	write the new expressions given by list in the expression directory.
\*/
/*.VDSwrite_expr_dir*/
{
IGRint		resp, i;
IGRint		dir_index;
IGRchar		string[DI_PATH_MAX];
IGRchar		act_path[DI_PATH_MAX];
IGRlong		status;
GRobjid		tmp_obj;
GRspacenum	cur_os;

  act_path[0] = '\0';

  if( list == NULL ){
	printf(" ERROR: fct VDSwrite_expr_dir, no textset list available \n");
	goto wrapup;
  }
  if( expr_dir == NULL ){
	printf(" ERROR: VDSwrite_expr_dir, no expression directory defined \n");
	goto wrapup;
  }
  
  /*| clean up the directory before writing the new one */

  resp = VDSclean_expr_dir( expr_dir );
  if( ! resp ){
    printf(" ERROR: fct VDSclean_expr_dir failed\n");
    goto wrapup;
  }

  /*| get current working directory */
  status = di$pwd( dirname = act_path );
  if( status != DIR_S_SUCCESS){
    printf(" ERROR: cannot get active working directory\n");
    goto wrapup;
  }
  /* " act_path :<%s>\n", act_path */

  /*| chg dir to expression directory */
  status = di$cd( dirname = expr_dir );
  if( status !=  DIR_S_SUCCESS ){
    printf(" ERROR: cannot change dir to [%s]\n", expr_dir);
    goto wrapup;
  }

  ex$get_cur_mod( osnum = &cur_os );

  dir_index = 0;
  for( i=0; i<list->num_textset; i++ ){
    if( list->text[i].select[0] != '\0' ){
	
	/*| create expression name */
	list->text[i].exp_name[0] = '\0';
	sprintf( list->text[i].exp_name, "%s%d", VDS_EXP_NAME, dir_index );

	/* concatenate the expression */
	strcpy( string, list->text[i].select );
	strcat( string, VDS_SEPARATOR );
	strcat( string, list->text[i].prefix );
	strcat( string, VDS_SEPARATOR );
	strcat( string, list->text[i].expres );
	strcat( string, VDS_SEPARATOR );
	strcat( string, list->text[i].suffix );

	/*" exp <%s> : name <%s>\n", list->text[i].exp_name, string  */

	status = exp$create(	exp_name = list->text[i].exp_name,
				exp_syntax = string,
				osnum  = cur_os,
				type_rq  = EXP_TEXT,
				p_exp_id = &tmp_obj );
	if(status != EXP_S_SUCCESS){
		printf("ERROR exp$create\n");
		goto wrapup;
	}
	dir_index++;

    } /* if .. */
  } /* for .. */

  /*" total : %d \n", dir_index */
  /*^ VDSshow_textset_list( list ); */

  /*| reset the working directory */
  status = di$cd( dirname = act_path );
  if( status !=  DIR_S_SUCCESS ){
    printf(" ERROR: cannot change dir to [%s]\n", act_path);
    goto wrapup;
  }

  return TRUE;

wrapup:
  if(act_path[0] != '\0'){
  	/*| reset the working directory */
  	status = di$cd( dirname = act_path );
  	if( status !=  DIR_S_SUCCESS ){
    		printf(" ERROR: cannot change dir to [%s]\n", act_path);
  	}
   }

  return FALSE;
}


/* ---------------------------------------------------------------------- */
/* VDSclean_expr_dir							  */
/* ---------------------------------------------------------------------- */
int	VDSclean_expr_dir( expr_dir )

IGRchar		*expr_dir;  /*(I) directory :<filename>:set_ref */
/*\
Description
	This function deletes the expression from the given directory.
	Only the expression names with the extention name are deleted.
\*/
/*.VDSclean_expr_dir*/
{
IGRchar		loc_expr[DI_PATH_MAX];
int		i,nb_lines;
struct GRid	tmp_obj;
DIgrid		*exp;	
long		status;

  if( expr_dir == NULL ){
	printf(" ERROR: fct VDSclean_expr_dir, no expression directory defined \n");
	goto wrapup;
  }

  /* init */
  exp   	= NULL;
  nb_lines 	= 0;

/*
 * test if directory exist
 */
  tmp_obj.objid = NULL_OBJID;
  status = di$translate( objname = expr_dir,
			 p_objid = &tmp_obj.objid,
			 p_osnum = &tmp_obj.osnum);
  if( !(status&1 )){
	printf(" ERROR: fct VDSclean_expr_dir,directory %s doesn't exist\n",expr_dir);
	goto wrapup;
  }

  sprintf( loc_expr, "%s:%s*", expr_dir, VDS_EXP_NAME );
  /*" loc_expr : <%s>\n", loc_expr */

  /*| read the directory information */
  nb_lines = 0;
  status = di$dump(	regexp = loc_expr,
			lines  = NULL ,
			ptr    = &nb_lines,
			grids  = &exp);

  if( status != DIR_S_SUCCESS ){
	if( status == DIR_W_NAME_NOT_FOUND ){
    		/*| no lines found */ 
    		if( exp ) {free( exp );exp = NULL;}
    		return TRUE;
	}
	else {di$report_error( sts = status ); goto wrapup;}
  }
  if( nb_lines == 0 ){
    /*| no lines found */ 
    if( exp ) {free( exp );exp = NULL;}
    return TRUE;
  }    
  /*" nb_lines: %d \n", nb_lines */
  for( i=0; i<nb_lines; i++){
    /*| delete expression */
    status = om$send ( 	msg = message Root.delete(0),
			senderid = NULL_OBJID,
			targetid = exp[i].objid,
			targetos = exp[i].osnum );
    if(! (status & 1)){
	printf(" ERROR: msg Root.delete[%d,%d] failed\n", exp[i].objid, exp[i].osnum );
	as$status( sts = status, action = RET_STATUS);
	goto wrapup;
    }
  } /* for .. */

  /*| delete the active expression */
  tmp_obj.objid = NULL_OBJID;
  status = di$translate( 	objname = VDS_ACT_SELECT,
				path	= expr_dir,
				p_objid = &tmp_obj.objid,
				p_osnum = &tmp_obj.osnum );
  if( status == DIR_S_SUCCESS ){
    /*" delete act expression: %d, %d\n", tmp_obj.objid,tmp_obj.osnum*/
    status = om$send (	msg = message Root.delete(0),
			senderid = NULL_OBJID,
			targetid = tmp_obj.objid,
			targetos = tmp_obj.osnum );
    if(! (status & 1)){
	printf(" ERROR: msg Root.delete failed\n");
	as$status( sts = status, action = RET_STATUS);
	goto wrapup;
    }
  }
  
  if( exp ) {free( exp );exp = NULL;}
  return TRUE;

wrapup:

  if( exp ) {free( exp );exp = NULL;}
  return FALSE;
}


/* ---------------------------------------------------------------------- */
/* VDSset_active_textset						  */
/* ---------------------------------------------------------------------- */
int	VDSset_active_textset( list, expr_dir, select )

struct	VDStextlist	*list;	   /*(I) list of textset where select is*/
IGRchar			*expr_dir; /*(I) directory :<filename>:set_ref */
IGRchar			*select;   /*(I) select text to set */

/*\
Description
	This function create or modify the expression in expr_dir concerning
	the select_text. (If select is not in the list, the select expression
	is set to '\0'

\*/
/*.VDSset_active_textset*/
{
IGRint		i;
IGRlong		status;
IGRchar		act_path[DI_PATH_MAX];
IGRchar		expr_syntax[DI_PATH_MAX];
struct	GRid	tmp_obj;

  act_path[0] = '\0';

  if( list == NULL ){
	printf(" ERROR: fct VDSset_active_textset, no textset list available \n");
	goto wrapup;
  }
  if( expr_dir == NULL ){
	printf(" ERROR: fct VDSset_active_textset, no expression direcory defined \n");
	goto wrapup;
  }
  if( select == NULL ){
	printf(" ERROR: fct VDSset_active_textset, no textset structure defined \n");
	goto wrapup;
  }

  expr_syntax[0] = '\0'; /* initialisation */

  if( select[0] == '\0' ){
    /*| empty select string */
    expr_syntax[0] = '\0';
  }
  else{
    expr_syntax[0] = '\0';
    /*" search_str : <%s>\n", select */
    for( i=0; i<list->num_textset; i++ ){
      /*" select : <%s>\n", list->text[i].select */
      if( strcmp( list->text[i].select, select ) == 0 ){

	strcpy( expr_syntax, list->text[i].exp_name );
      }
    }
  }

  /*| get current working directory */
  status = di$pwd( dirname = act_path );
  if( status != DIR_S_SUCCESS){
    printf(" ERROR: cannot get active working directory\n");
    goto wrapup;
  }

  /*| cd expression directory */
  status = di$cd( dirname = expr_dir );
  if( status !=  DIR_S_SUCCESS ){
    printf(" ERROR: cannot change dir to [%s]\n", expr_dir);
    goto wrapup;
  }

  tmp_obj.objid = NULL_OBJID;
  status = di$translate( 	objname = VDS_ACT_SELECT,
				path	= expr_dir,
				p_objid = &tmp_obj.objid,
				p_osnum = &tmp_obj.osnum );

  if( status != DIR_S_SUCCESS ){
	/*" create VDS_ACT_SELECT <%s>\n", expr_syntax */
	status = exp$create(	exp_name = VDS_ACT_SELECT,
				exp_syntax = expr_syntax,
				type_rq	 = EXP_TEXT,
				p_exp_id = &tmp_obj.objid );
	if(status != EXP_S_SUCCESS){
		printf("ERROR exp$create\n");
		goto wrapup;
	}
  }
  else{	/*" modify VDS_ACT_SELECT <%s>\n", expr_syntax */
	status = exp$modify(	exp_name = VDS_ACT_SELECT,
				exp_syntax = expr_syntax );
	if(status != EXP_S_SUCCESS){
		printf("ERROR exp$modify\n");
		goto wrapup;
	}
  }

  /*| reset the working directory */
  status = di$cd( dirname = act_path );
  if( status !=  DIR_S_SUCCESS ){
    printf(" ERROR: cannot change dir to [%s]\n", act_path);
    goto wrapup;
  }

  return TRUE;

wrapup:
  if(act_path[0] != '\0'){
  	status = di$cd( dirname = act_path );
  	if( status !=  DIR_S_SUCCESS ){
    		printf(" ERROR: cannot change dir to [%s]\n", act_path);
  	}
  }
  return FALSE;
}

/* ---------------------------------------------------------------------- */
/* VDSfill_textset_list							  */
/* ---------------------------------------------------------------------- */
int	VDSfill_textset_list( list, form, label )

struct	VDStextlist	*list;  /*(I) list of textset  */
IGRchar			*form;  /*(I) form "VDLocName" */
IGRint			label;  /*(I) label of the multicolumn field to fill */
/*\
Description
	This function fills the multicolumn field in the
	form VDLocName.
\*/
/*.VDSfill_textset_list*/
{
IGRint	rc, i, row ;

  if( list == NULL ){
	printf(" ERROR: fct VDSfill_textset_list, no  list available \n");
	goto wrapup;
  }
  if( form == NULL ){
	printf(" ERROR: fct VDSfill_textset_list, no  form ptr available \n");
	goto wrapup;
  }

  /*" num_textset: %d\n", list->num_textset */

/*
 * Sets number of row, then fills them with list.
 */

  /*| find the nnumber of active entries */
  row = 0;
  for( i=0; i<list->num_textset; i++ )
    if( list->text[i].select[0] != '\0' ) row++;
   
  rc = FIfld_set_list_num_rows(	form, label, 0, row ) ;
  if( rc != FI_SUCCESS ){ 
	printf("ERROR: fct VDSfill_textset_list, FIfld_set_list_num_rows fail\n");
	goto wrapup;
  }

  row = 0;
  for( i=0; i<list->num_textset; i++ ){
    if( list->text[i].select[0] != '\0' ){
      /*" row[%d] : <%s>\n", row, list->text[i].select */
      rc = VDfld_set_list_text( form, label, row++, 0,
				list->text[i].select, FALSE ) ;
      if( rc != FI_SUCCESS ){ 
	printf("ERROR: fct VDSfill_textset_list, VDfld_set_list_text fail\n");
	goto wrapup;
      }
    }
  }

  return TRUE ;

  wrapup:
  return FALSE;

} /* VSfill_textset_list */


/* ---------------------------------------------------------------------- */
/* VDSset_null_list_entry						  */
/* ---------------------------------------------------------------------- */
int	VDSset_null_list_entry( list, select )

struct	VDStextlist	*list;   /*(I) list of textset */
IGRchar			*select; /*(I) name of textset to set to null in list*/
/*\
Description
	This function looks for select string in the textset list.select.
	If available the corresponding textset will be set to zero.
\*/
/*.VDSset_null_list_entry*/
{
IGRint	i, resp;

  if( list == NULL ){
	printf(" ERROR: fct VDSset_null_list_entry, no textset list available \n");
	goto wrapup;
  }
  if( select == NULL ){
	printf(" ERROR: fct VDSset_null_list_entry, no textset available \n");
	goto wrapup;
  }
  /*" select : <%s>\n", select */

  if( select[0] == '\0' )	return TRUE;

  for( i=0; i<list->num_textset; i++ ){
    if( strcmp( list->text[i].select, select ) == 0 ){
	/*|text found, set it to null */
	resp = VDSset_null_text( &(list->text[i]) );
	if( ! resp ){
	  printf(" ERROR: fct VDSset_null_text failed\n");
	  goto wrapup;
	}
    }
  }

  return TRUE;

wrapup:

  return FALSE;

} /* VDSset_null_list_entry */

/* ---------------------------------------------------------------------- */
/* VDStextset_part_expression						  */
/* ---------------------------------------------------------------------- */
int	VDStextset_part_expression( exp, p1, p2 )

IGRchar		*exp; /*(I) express to extract part */
IGRchar		*p1;  /*(O) part before '|' */
IGRchar 	*p2;  /*(O) part after '|' */
/*\
Description
	This function cuts a string into two parts in case an predefined
	separator character ('|') is found, p1 and p2 must be allocated of
	exp length to have no pb of memory.
\*/
/*.VDStextset_part_expression*/
{
IGRint	i, length, len;

  if( exp == NULL || p1 == NULL || p2 == NULL ){
    printf(" ERROR: fct VDStextset_part_expression, arguments cannot be NULL\n");
    goto wrapup;
  }
  len = strlen(exp);

  /* " exp: <%s>\n", exp */
  /* " sep: %c\n", VDS_TEST_SEP */

  /* look for the char */
  for( i=0, length=strlen(exp); (i<length) && (exp[i] != VDS_TEST_SEP); i++);

  /* " index found: %d\n", i */

  if( i == length ){
    /*| no sep_char in input */
    p1[0] = '\0';
    strcpy( p2, exp );
    goto wrapup;
  }
  else{
    strncpy (p1, exp, i);
    p1[i]='\0';
    strcpy ( p2, &(exp[i+1]) );
  }

  /* " p1 : <%s>\n", p1 */
  /* " p2 : <%s>\n", p2 */

  return TRUE;
wrapup:
  return FALSE;

}

/* ---------------------------------------------------------------------- */
/* VDSshow_textset_list( list )						  */
/* ---------------------------------------------------------------------- */
int	VDSshow_textset_list( list ) /*(I) list of textset to show */

struct	VDStextlist	*list;
/*\
Description
	This function print the current textset list
\*/
/*.VDSshow_textset_list*/
{
IGRint	i;

  if( list == NULL ){
    printf(" List == NULL \n");
    return TRUE;
  }

  if( list->text == NULL ){
    printf(" List->text == NULL \n");
    return TRUE;
  }

  printf("\n");
  printf(" max_textset : %d\n", list->max_textset );
  printf(" inc_textset : %d\n", list->inc_textset );
  printf(" num_textset : %d\n", list->num_textset );
  printf("index\t: exp_name \t| select \t| prefix\t| expres\t| suffix\n");
  for( i=0; i<list->num_textset; i++ ){
    /* find the previous select name */
    printf("[%d]\t:<%s>\t| <%s>\t| <%s>\t| <%s>\t| <%s>\n",
			i,
			list->text[i].exp_name,
			list->text[i].select,
			list->text[i].prefix,
			list->text[i].expres,
			list->text[i].suffix );
  }
  printf("\n");

return TRUE;
}
/* ---------------------------------------------------------------------- */
/* VDSget_textset( list , select, text, found)				  */
/* ---------------------------------------------------------------------- */
int	VDSget_textset( list, select, text, found) 

struct	VDStextlist	*list;/*(I) list of textset where select is searched */
IGRchar			*select; /*(I) select text to search */
struct	VDStextset	*text;   /*(O) return textset  */
int			*found;  /*(O) override option */
/*\
Description
	This function try to find in the list, the structure textset 
	which have the given select text. textset is the returned structure
	if the search success, otherwise textset is set to null and found = 0.
\*/
/*.VDSget_textset*/
{

int	i,resp;
	
if(text == NULL){
	printf("ERROR: fct VDSget_textset, argument text cannot be NULL  \n");
	goto wrapup;
}
if( list == NULL ){
	printf("ERROR: fct VDSget_textset, no textset list available \n");
	goto wrapup;
}
if( select == NULL ){
	printf("ERROR: fct VDSget_textset, no select text available \n");
	goto wrapup;
}
if(select[0] == '\0'){
	printf("ERROR: fct VDSget_textset, no select text available \n");
	goto wrapup;
}
if(found != NULL) *found = 0;

/*^
printf("select to search: %s\n",select);
printf("list->num_textset: %d\n",list->num_textset);
for (i=0;i<list->num_textset;i++) 
	printf("list select: %s\n", list->text[i].select);
*/

resp = VDSset_null_text( text);
if( ! resp ){
	  printf(" ERROR: fct VDSset_null_text failed \n");
	  goto wrapup;
}

for(i=0;i<list->num_textset;i++){
	if(strcmp(select,list->text[i].select) == 0){
		strcpy(text->exp_name,list->text[i].exp_name);
		strcpy(text->select,list->text[i].select);
		strcpy(text->prefix,list->text[i].prefix);
		strcpy(text->expres,list->text[i].expres);
		strcpy(text->suffix,list->text[i].suffix);
		if(found != NULL) *found = 1;
		break;
	}
}



/*^
 printf("text: <%s>\t| <%s>\t| <%s>\t| <%s>\t| <%s>\n",	text->exp_name,
							text->select,
							text->prefix,
							text->expres,
							text->suffix );
 
*/

return TRUE;

wrapup:
  if(found != NULL) *found = 0;
  return FALSE;

}

/* ---------------------------------------------------------------------- */
/* VDSget_contend( select, return_exp, found)			  */
/* ---------------------------------------------------------------------- */
int	VDSget_contend( select, return_exp, found) 

IGRchar			*select; /*(I) expres select text to search */
IGRchar			*return_exp; /*(O) return expres (EXP_MAX_LEN) */
int			*found	; /*(O) 0 if not found */
/*\
Description
	This function reads in the expr_dir in order to find the textset
	corresponding to the given select text, and fills "return_exp" with 
	prefix , expres, suffix or concatenation of the three depending
	of what part of the expression is required:
		select_p to return the prefix expression
		select_e to return the expres expression 
		select_s to return the suffix expression 
	 
	This function was implemented to use indirection in expression:
	ie if we have an expression defined by:
	
	select		prefix		expres		suffix
	set1		F[1-4]		:plane		:pl*
	
	we can define for example other expressions:
	set2		F7		$set1_p		:obj1
	set4		F[1-4]		$set2_s, plane
	
	$set1_p will be given by this function which will return "F[1-4],F7"
	in return_exp if select is "set1_p"
	
\*/
/*.VDSget_contend*/
{

int			len,flag, resp;
struct	VDStextlist	list;
IGRlong			NumberOfBytes;
IGRlong			BytesReceived;
struct	VDStextset	text;
long			status, msg;
struct GRmd_env		md_env;
IGRchar			x_sel[DI_PATH_MAX],expr_dir[DI_PATH_MAX];


  list.text = NULL;

  list.num_textset = 0;
  list.max_textset = 0;
  list.inc_textset = 0;

if(select == NULL){
	printf("ERROR: fct VDSget_contend, argument select cannot be NULL  \n");
	goto wrapup;
}
if( return_exp == NULL ){
	printf("ERROR: fct VDSget_contend, return_exp cannot be NULL\n");
	goto wrapup;
}
if(select[0] == '\0'){
	if(found != NULL) *found = 0;
	return_exp[0] = '\0';
	return TRUE;
}
return_exp[0] = '\0';
if(found != NULL) *found = 0;

NumberOfBytes = sizeof(md_env);
gr$get_module_env( msg    = &msg,
		   sizbuf = &NumberOfBytes,
		   buffer = &md_env,
		   nret   = &BytesReceived);
if(!(msg&1)) {printf("error gr$get_module_env\n"); goto wrapup;}

status = di$give_pathname(osnum  = md_env.md_id.osnum,
 			  pathname = expr_dir );
if( status != DIR_S_SUCCESS )
	{printf("ERROR di$give_pathname\n"); goto wrapup;}
	
strcat( expr_dir, VDS_EXPR_DIR );

/*"expr_dir: %s\n",expr_dir*/
/*"select: %s\n",select*/

resp = VDSread_expr_dir( &list, expr_dir, &md_env);
if( ! resp  ){
	printf(" ERROR: fct VDSread_expr_dir failed \n");
	goto wrapup;
}

/*^

printf("list.num_textset: %d\n",list.num_textset);
for (i=0;i<list.num_textset;i++) 
	printf("list select: %s\n", list.text[i].select);
*/

len = strlen(select);

/*"select[len-2]: %c\n",select[len-2]*/

x_sel[0] = '\0';

if(select[len-2] == '_') {
	strncpy(x_sel,select,len-2);
	x_sel[len-2] = '\0';
}
else {
	if(found != NULL) *found = 0;
	return_exp[0] = '\0';
	return TRUE;
}

/*"x_sel to get: %s\n",x_sel*/

resp = VDSget_textset( &list,x_sel,&text,&flag);
if( ! resp  ){
	printf(" ERROR: fct VDSget_textset failed \n");
	goto wrapup;
}
if(!flag ) {
	if(found != NULL) *found = 0;
	return_exp[0] = '\0';
	return TRUE;
}

/*^
printf("found text: %s, %s, %s, %s, %s\n",
			text.exp_name,
			text.select,
			text.prefix,
			text.expres,
			text.suffix );
*/
 
if(select[len-1] == 'p') strcpy(return_exp, text.prefix);
else if(select[len-1] == 'e') strcpy(return_exp, text.expres);
else if(select[len-1] == 's') strcpy(return_exp, text.suffix);
else {
		if(found != NULL) *found = 0;
		/*|select suffix not avalaible (not p,e or s) */
		return_exp[0] = '\0';
		return TRUE;
}

if(found != NULL) *found = 1;

/*"return_exp: %s\n",return_exp*/

   if( list.text != NULL){ free(list.text);list.text = NULL;}
return TRUE;

wrapup:
  if( list.text != NULL){ free(list.text);list.text = NULL;}
  if(found != NULL) *found = 0;
  return FALSE;

}

/* ---------------------------------------------------------------------- */
/* VDSverif_text_exp( )			  				  */
/* ---------------------------------------------------------------------- */
int	VDSverif_text_exp() 

/*\
Description

	This function verify the expressions in the expr_dir directory.
	If some expression are given in an absolute way, modify them to
	be in the current filename. Verification is made in prefix part
	if not NULL else in expres part if not NULL else in suffix part.
	
\*/
/*.VDSverif_text_exp*/
{

char			filename[DI_PATH_MAX],expr_dir[DI_PATH_MAX],
			loc_expr[DI_PATH_MAX],expr_name[DI_PATH_MAX], 
			to_mod[DI_PATH_MAX],util[DI_PATH_MAX],before[DI_PATH_MAX],
			tmp[DI_PATH_MAX],tmp1[DI_PATH_MAX],after[DI_PATH_MAX];
int			resp,i,nb_lines, mode, len, change;
IGRlong			NumberOfBytes;
IGRlong			BytesReceived;
long			sts, status, msg;
struct GRmd_env		md_env;
DIgrid			*exp;	
struct	ret_struct 	ret_str;
struct	VDStextset	textset;

exp   		= NULL;
nb_lines 	= 0;

/* get current filename */

resp = VDSget_filename(filename);
if(!(resp & 1)){printf("error VDSget_filename\n");goto wrapup;}

/*"filename: %s\n",filename */
len = strlen(filename);
change = 0;

NumberOfBytes = sizeof(md_env);
gr$get_module_env( msg    = &msg,
		   sizbuf = &NumberOfBytes,
		   buffer = &md_env,
		   nret   = &BytesReceived);
if(!(msg&1)) {printf("error gr$get_module_env\n"); goto wrapup;}

status = di$give_pathname(osnum  = md_env.md_id.osnum,
 			  pathname = expr_dir );
if( status != DIR_S_SUCCESS )
	{printf("ERROR di$give_pathname\n"); goto wrapup;}
	
strcat(expr_dir, VDS_EXPR_DIR );

/*"expr_dir: %s\n",expr_dir*/
	
sprintf(loc_expr,"%s:%s*", expr_dir, VDS_EXP_NAME );

/*"loc_expr: %s\n",loc_expr*/

status = di$dump(	regexp = loc_expr,
			lines  = NULL ,
			ptr    = &nb_lines,
			grids  = &exp);

if( status != DIR_S_SUCCESS ){
	if( status == DIR_W_NAME_NOT_FOUND ){
    		/*| no lines found */ 
    		if( exp ) {free( exp );exp = NULL;}
    		return TRUE;
	}
	else {di$report_error( sts = status ); goto wrapup;}
}

if( nb_lines == 0 ){
    /*| no results found */
    if( exp ) {free( exp );exp = NULL;}
    return TRUE;
}    

/*" nb_lines: %d \n", nb_lines */

for( i=0; i<nb_lines; i++){

    /*" exp[%d]: [%d,%d]\n", i, exp[i].objid, exp[i].osnum */

    /* test expression of type */
    expr_name[0] = '\0';
    status = di$untranslate( 	objname = expr_name,
				objid	= exp[i].objid,
				osnum	= exp[i].osnum );
    if( status == DIR_S_SUCCESS ){
    	/*" untranslate expr_name : <%s>\n", expr_name */
	/*| get expression */
	status = om$send( msg = message text_exp.NDgive_structure(
					&msg,
					&ret_str,
					&md_env ),
			  targetid = exp[i].objid,
			  targetos = exp[i].osnum,
			  senderid = NULL_OBJID );
	if(! (status & 1)){
          printf(" ERROR: failure text_exp.NDgive_structure\n");
          as$status( sts = status, action = RET_STATUS);
          goto wrapup;
	}
	/*"ret_str: <%s>\n", ret_str.var.text_st.text_string */
	
	resp = VDSsplit_string( ret_str.var.text_st.text_string, &textset );
	if( ! resp ){
	  printf("WARNING expression <%s> is deleted\n", ret_str.var.text_st.text_string);
	  printf("select must be < %d\n",VDS_SELECT_MAX);
	  printf("prefix must be < %d\n",VDS_PREFIX_MAX);
	  printf("expres must be < %d\n",VDS_EXPRES_MAX);
	  printf("suffix must be < %d\n",VDS_SUFFIX_MAX);
	  
     	  /*|delete expression */
     	  sts = om$send ( msg = message Root.delete(0),
                              senderid = NULL_OBJID,
                              targetid = exp[i].objid,
		              targetos = exp[i].osnum);
     	  if (! (sts & 1))
        	  {
          	  printf("failure sending Root.delete\n");
          	  as$status(sts = sts,action = RET_STATUS);
          	  goto wrapup;
        	  }
	  continue;
	}
	
	/*"textset: %s, %s, %s\n",textset.prefix,textset.expres,textset.suffix */
	
	/* 
	   search for absolute path in prefix if it is not null , else in 
	   expres else in suffix 
	*/
	
	mode = 0; 
	loc_expr[0] = '\0';  
	if(textset.prefix[0] != '\0') 
		{mode = 1; strcpy(loc_expr,textset.prefix);}
	else if(textset.expres[0] != '\0') 
		{mode = 2; strcpy(loc_expr,textset.expres);}
	else if(textset.suffix[0] != '\0') 
		{mode = 3; strcpy(loc_expr,textset.suffix);}
	else {/*|textset seem to be null */ continue;}	
	
	/*"mode: %d, loc_expr: %s\n",mode, loc_expr*/
	
	to_mod[0] = '\0';
	change = 0;
	status = OM_S_SUCCESS;
	
	while(status & 1){
		/*"while loc_expr: %s\n",loc_expr */
		status = VDSextract_part_exp(loc_expr, before, after,',');
		if(!(status & 1)) {/*|plus de ',' */ strcpy(before,after);}
		/*"before: %s\n",before */
		EXP_strip(before);
		if(before[0] == ':'){
			if(strncmp(before,filename,len)){
				/*|chg to actual filename */
				util[0] = '\0';
				sts = VDSextract_part_exp(	&before[1],
								before ,
								tmp1,':');
				if(!(sts & 1)) tmp1[0] = '\0';
				else sprintf(tmp,":%s",tmp1);
				/*"tmp: %s\n",tmp */
  				sprintf( util, "%s%s", filename,tmp );
  				/*"util: %s\n",util */
  				change = 1;
				strcat(to_mod,util);
			}
			else strcat(to_mod, before);
		}
		else strcat(to_mod, before);
		if(status & 1) strcat(to_mod,",");
		/*"to_mod end while: %s\n",to_mod */
		strcpy(loc_expr,after);
	}/* end while */
	
	/*"final to_mod: %s\n",to_mod */
	
	if(change){
		/* expression need to be modified with current filename */
		
		if(mode == 1) strcpy(textset.prefix,to_mod);
		else if(mode == 2) strcpy(textset.expres,to_mod);
		else if(mode == 3) strcpy(textset.suffix,to_mod);
		strcpy(loc_expr,textset.select);
		strcat(loc_expr, VDS_SEPARATOR );
		strcat(loc_expr,textset.prefix);
		strcat(loc_expr, VDS_SEPARATOR );
		strcat(loc_expr,textset.expres);
		strcat(loc_expr, VDS_SEPARATOR );
		strcat(loc_expr,textset.suffix);
		
		/*"name to modify: %s, exp: %s\n",expr_name,loc_expr*/
		
		status = exp$modify(	exp_name   = expr_name,
					exp_syntax = loc_expr );
		if(status != EXP_S_SUCCESS){
			printf("ERROR exp$modify\n");
			goto wrapup;
		}
	}
 
    } /* success of untranslate */
} /* for .. */


if( exp ) {free( exp );exp = NULL;}
return TRUE;

wrapup:
  if( exp ) {free( exp );exp = NULL;}
  return FALSE;

}

end implementation Root;



