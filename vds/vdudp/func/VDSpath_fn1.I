/* $Id: VDSpath_fn1.I,v 1.1.1.1 2001/01/04 21:09:31 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdudp/func / VDSpath_fn1.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSpath_fn1.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:31  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/10/31  20:41:30  pinnacle
# Invalid return warning
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.2  1996/03/18  11:04:44  pinnacle
# Replaced: smcomp/func/SMCmpFn.I for:  by ksundar for vds.240
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
 *	10/31/97	ah		Warning message
 * -------------------------------------------------------------------*/

/****************************************************
/*
/* funtions implementing the macros given
/* in VDSudp_mac.h and VDSudp_priv.h
/*
/* 	1. VDSGetPathFrmFile 
/* 	2. VDSAddPathsExp
/*	3. VDSAddPath
/**/

class implementation Root;

#include <stdio.h>
#include <ctype.h>
#include <string.h>

#include "OMerrordef.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "AS_status.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "parametric.h"
#include "exdef.h"
#include "ex.h"
#include "griomacros.h"
#include "FI.h"

#include "VDSpathdef.h"
#include "VDSpath_form.h"
#include "VDSudp_mac.h"
#include "VDSudp_priv.h"
#include "vdsmacros.h"

#include "VDSudpco.h"

extern IGRshort  VDexp_locate(char *Pattern, char *Source);
extern IGRboolean ASbroadcast_in_progress;

from 	text_exp 	import  NDgive_structure, modify,give_formula,list;

/*1---------------------- VDSGetPathFrmFile -----------------------------------
    
    This function read the in the given file, and fills the list of 
    paths and search paths.

	the main and search paths are allocated by the function

	return 1 if ok
	else 0

*/
int VDSGetPathFrmFile(filename, nb_main, nb_search, main, search)
IGRchar			*filename;	/* (I) file where to read the paths */
IGRint			*nb_main;	/* (O) nb main paths returned */
IGRint			*nb_search;	/* (O) nb search paths returned */
struct constr_path     	**main;		/* (O) main paths returned */
struct constr_path     	**search;	/* (O) search paths returned */

{
IGRboolean	err_flag;
IGRint		i,len, len1,nb_returned,main_size, search_size, stat, done;
IGRchar		text[2*MY_MAX], **part_exp;
FILE		*pf;

err_flag = FALSE;

if(filename == NULL || nb_main == NULL || nb_search == NULL || main == NULL
   || search == NULL){
	printf("ERROR, Invalid Arguments in VDSGetPathFrmFile\n");
	return 0;
}
part_exp = NULL;
*main = NULL;
*search = NULL;
*nb_main = *nb_search = 0;
done = 0;

/* filename must be in the current directory */

pf = NULL;
vd$openfile(	file_name 	= filename,
		product_name 	= "Vds",
		sub_path 	= "config",
		cur_dir 	= TRUE,
		p_file 		= &pf);
if(pf == NULL){
/*  printf("file [%s] not found\n",filename);*/
  return (1);
}

*search = (struct constr_path*)
              om$malloc(size = sizeof(struct constr_path)* ALLOC_INCR  );
*main   = (struct constr_path*)
              om$malloc(size = sizeof(struct constr_path)* ALLOC_INCR  );

if(*search == NULL) {
	printf("No space avalaible for search\n"); 
	err_flag = TRUE;
	goto wrapup;
}
if(*main == NULL)   {
	printf("No space avalaible for main\n")  ; 
	err_flag = TRUE;
	goto wrapup;
}
search_size = ALLOC_INCR;
main_size   = ALLOC_INCR;


while (fgets(text,2*MY_MAX-1,pf) != NULL){
  	EXP_strip(text);
  	i = 0;

  	/* enleve les tabulations et les fins de lignes */

  	while(text[i] == '\t'){
    		strcpy(text,&text[i+1]);
    		i = i+1;
   	}
  	len1 = strlen(text);

  	while( text[len1-1] == '\t' || text[len1-1] == '\n' ){
    		text[len1-1] = '\0';
    		len1 = strlen(text);
   	}
  	if (text[0] != 's' && text[0]!='m' || text[1]!='!'){
      		/* not a readable line  */
      		continue;
    	}
   
   	nb_returned = 0;
  	stat = vds$extract_all_part_exp( nb_part    = &nb_returned,
     			           	expression = text,
				   	sep_char   = '!'); 
  	if (! (stat & 1)){
		printf("error vds$extract_all_part_exp\n");
		err_flag = TRUE;
		goto wrapup;
    	}
    	len = strlen(text);
   	part_exp = (char **)om$malloc(size = nb_returned * sizeof(char*));
   	if(part_exp == NULL){
		printf("bad allocation of part_exp\n");
		err_flag = TRUE;
		goto wrapup;
    	}
   	for(i=0;i<nb_returned;i++){
        	part_exp[i] = (char *)om$malloc(size = (len + 1)*sizeof(char));
        	if(part_exp[i] == NULL){
	    		printf("bad allocation of part_exp\n");
			err_flag = TRUE;
	    		goto wrapup;
  	  	}
     	}
		 
   	stat = vds$extract_all_part_exp( expression  = text,
					nb_returned = nb_returned,
					part_exp    = part_exp,
					sep_char    = '!'); 

   	if (! (stat & 1)){
		printf("error vds$extract_all_part_exp\n");
		err_flag = TRUE;
		goto wrapup;
     	}

   	len = strlen(part_exp[1]);
    	if( len >= NAME_MAX) { 
       		printf("WARNING: path not added because its name lenght: [%s]\n",part_exp[1]);
       		continue;
     	}
    	len = strlen(part_exp[2]);
    	if( len >= MY_PATH_MAX) { 
       		printf("WARNING: path not added because its lenght: [%s]\n",part_exp[2]);
       		continue;
     	}


  	if (strcmp(part_exp[0],"s") == 0){
    		/* text begin with s! ===> search_path */
    		if(nb_returned != 3) {
			/* not a valid path */
       			continue;
		}
    		if(search_size < *nb_search + 1){
       			*search = (struct constr_path *)om$realloc(
				size = (search_size + ALLOC_INCR) * 
                                                 sizeof(struct constr_path),
 				ptr = (char *) *search );
       
       			search_size = search_size + ALLOC_INCR;
     		}
    		strcpy((*search)[*nb_search].name,part_exp[1]);
    	 	strcpy((*search)[*nb_search].path, part_exp[2]);
    		(*nb_search) ++;
     		done = 1;
   	}
  	else if (strcmp(part_exp[0],"m") == 0){
    		/* text begin with m! ==> main path */
    		if(nb_returned < 3) {
			/* not a valid path */
       			continue;
		}
    		if(main_size < *nb_main + 1){
       			*main = (struct constr_path *)om$realloc(
				size = (main_size + ALLOC_INCR) * 
                                                 sizeof(struct constr_path),
 				ptr = (char *)*main );
       
       			main_size = main_size + ALLOC_INCR;
     		}
    		strcpy((*main)[*nb_main].name,part_exp[1]);
    		strcpy((*main)[*nb_main].path,part_exp[2]);
    		if(nb_returned == 3){
      			/* no symbology given, take active */
      			strcpy((*main)[*nb_main].symbology.color,"act");
      			strcpy((*main)[*nb_main].symbology.layer,"act");
      			strcpy((*main)[*nb_main].symbology.weight,"act");
      			strcpy((*main)[*nb_main].symbology.style,"act");
      			(*main)[*nb_main].symbology.layer_name[0] = '\0';
     		}
    		else{
       			stat = vds$symb_to_text(
				txt_symb = &((*main)[*nb_main].symbology), 
		           	exp_symb = part_exp[3]);
       			if(!(stat&1)){
				printf("VDSsymb_to_text fail\n");
				err_flag = TRUE;
				goto wrapup;
			}
       			if(strncmp((*main)[*nb_main].symbology.layer,"act",3) == 0){
       				if((*main)[*nb_main].symbology.layer_name[0] != '\0'){
       					(*main)[*nb_main].symbology.layer_name[0] = '\0';
       				}
       			}
     		}
    		(*nb_main) ++;
    		done = 1;
  	}
}/* while EOF */
if(pf) fflush(pf);
if(pf)fclose(pf);

if(!done) {
  printf("Warning: Nothing readable in this file");
  goto wrapup;
}

wrapup:
if(part_exp != NULL) {
	for(i=0;i<nb_returned;i++)
             if(part_exp[i]!=NULL) 
                        {free(part_exp[i]);part_exp[i]=NULL;}
 	if(part_exp != NULL) {free(part_exp); part_exp=NULL;}
}

if(err_flag == TRUE) {
	if(main != NULL && (*main)!= NULL){free(*main); *main = NULL;}
	if(search != NULL && (*search)!= NULL){free(*search); *search = NULL;}

	return 0;
}
else	return 1;

}



/*2---------------------- VDSAddPathsExp -----------------------------------
    
    This function add the given paths in the path system (directory user_path)
    depending on the mod_flag option:
		if mod_flag = 1: if a given path name already exist in the
		paths system, this path is modified with the given one.

		if mod_flag = 0: if a given path name already exist in the
		paths system, this path is not modified .

	return 1 if ok
	else 0

*/

VDSAddPathsExp (nb_main, nb_search, main, search, mod_flag) 
IGRint 			nb_main;  /* (I) nb main path to add */
IGRint 			nb_search;/* (I) nb search path to add */	
struct constr_path     	*main;	  /* (I) main path to add */
struct constr_path     	*search;  /* (I) search path to add */	
IGRint			mod_flag; /* (I) 1 if expression must be modified */
{
IGRint			nb_expmain, nb_expsearch, found, 
			len,i, stat, nb_lines;
IGRboolean		err_flag;
IGRchar 		**lines, us_path[DI_PATH_MAX+30];
struct GRmd_env		md_env;
struct GRid		dir_obj;
struct constr_path     	*exp_main, *exp_search;	
struct GRsymbology  	symb;    

err_flag = FALSE;

if(main == NULL && search == NULL) return (1);
if(nb_main == NULL && nb_search == NULL) return (1);

if( (nb_main >0 && main == NULL) || 
    (nb_search >0 && search == NULL)){
	printf("ERROR, Invalid arguments in VDSAddPathsExp\n");
	return 0;
}
lines = NULL;
nb_lines = 0;
nb_expmain =  nb_expsearch = 0;
exp_main = exp_search = NULL;

stat = vds$init_path(user_path = us_path, dir_obj = &dir_obj,md_env = &md_env); 
if ( !(stat&1)) {
	printf("error vds$init_path\n");
	err_flag = TRUE;
	goto wrapup;
}

/* get all the paths from the directory system */

len = strlen(us_path);
strcpy(&us_path[len],":*");

stat = di$ls( regexp = us_path,
	     lines  = &lines,
	     ptr    = &nb_lines);

if (stat != DIR_S_SUCCESS) {
	di$report_error(sts=stat);
	err_flag = TRUE;
	goto wrapup;
}


stat = vds$give_exp( nb_main   = &nb_expmain, 
		    nb_search = &nb_expsearch,
		    nb_lines  = nb_lines,
		    lines     = lines);
if(!(stat & 1)) {
	printf("ERROR in vds$give_exp\n"); 
	err_flag = TRUE;
	goto wrapup;
}

if(nb_expmain){
	exp_main = (struct constr_path *)
              om$malloc(size = sizeof(struct constr_path)* nb_expmain );
	if(exp_main == NULL){
		printf("ERROR Bad dynamic allocation\n"); 
		err_flag = TRUE;
		goto wrapup;
	}		
}

if(nb_expsearch){
	exp_search = (struct constr_path *)
              om$malloc(size = sizeof(struct constr_path)* nb_expsearch );
	if(exp_search == NULL){
		printf("ERROR Bad dynamic allocation\n"); 
		err_flag = TRUE;
		goto wrapup;
	}		
}
stat = vds$give_exp( 	main_alloc   = nb_expmain, 
		     	search_alloc = nb_expsearch,
			main = exp_main,
			search = exp_search,
		     	nb_lines  = nb_lines,
		     	lines     = lines);
if(!(stat & 1)) {
	printf("ERROR in vds$give_exp\n"); 
	err_flag = TRUE;
	goto wrapup;
}

/* add the path if mod_flag = 1 */

for(i= 0; i< nb_main;i++){
	found = 0;
	if(nb_expmain){
		stat =vds$name_in_list( in_name   = main[i].name, 
			   	list      = &exp_main[0], 
			   	nb_elts   = nb_expmain,
			   	found     = &found);
		if (! (stat & 1)){
			printf("error vds$name_in_list\n");
			err_flag = TRUE;
			goto wrapup;
		}
	}
	if((!found) || mod_flag){
		stat = vds$give_symb( 	symbology = &symb,
					txt_symb = &main[i].symbology);

		/* lines NULL because if a path is added we need to add 
			the corresponding line */

		stat = VDSAddPath(&main[i], MAIN_PATH, NULL, 0, (char **)NULL);
		if(!(stat&1)){
			printf("ERROR VDSAddPath\n");
			err_flag = TRUE;
			goto wrapup;
		}			
	}

}


for(i= 0; i< nb_search;i++){
	found = 0;
	if(nb_expsearch){
		stat =vds$name_in_list( in_name   = search[i].name, 
			   	list      = &exp_search[0], 
			   	nb_elts   = nb_expsearch,
			   	found     = &found);
		if (! (stat & 1)){
			printf("error vds$name_in_list\n");
			err_flag = TRUE;
			goto wrapup;
		}
	}
	if(!found || mod_flag){
		/* lines NULL because if a path is added we need to add 
			the corresponding line */

		stat = VDSAddPath(&search[i], SEARCH_PATH, NULL, 0, 
					(char **)NULL);
		if(!(stat&1)){
			printf("ERROR VDSAddPath\n");
			err_flag = TRUE;
			goto wrapup;
		}			
	}

}




wrapup:

if(exp_main){free(exp_main);exp_main = NULL;}
if(exp_search){free(exp_search);exp_search = NULL;}
if(lines != NULL && nb_lines != 0){
    di$free(lines = lines,
            count = nb_lines);
    lines = NULL;
    nb_lines = 0;
}

if(err_flag == TRUE) return 0;
else	return 1;
}



/*22  ------------------------ VDSadd_path -----------------------------*/
/* 	function that add a path in the path or search path list
/* 	If a name is given, and if that name already exist, the function 
/*	only modify the definition of the path (to avoid duplicate name). 
/* 
/* */

VDSAddPath(path_to_add, const_flag, out_name, nb_lines, lines)

struct constr_path 	*path_to_add;	/* (I) path to add		*/
int			const_flag;	/* (I) MAIN_PATH or SEARCH_PATH */
char			*out_name ;	/* (O) name of path given	*/
int			nb_lines;	/* (I) nb_lines (0) si not lines*/
char			**lines;	/* (I) lines 			*/

/*.VDSAddPath*/
{

char			name[DI_PATH_MAX],path[DI_PATH_MAX+30], value[DI_PATH_MAX];	
char			real_name[DI_PATH_MAX], extrd_value[DI_PATH_MAX], symb[MY_MAX], 
			list_index[3],auto_name[NAME_MAX],path_to_set[MY_MAX];
struct GRmd_env 	md_env;	
int			named_flag, exp_index,name_index, wrk_index,i,
			found, len, tnb_lines, modify_flag;
struct GRid		dir_obj,exp;	
long			msg,sts;      // status not used
struct constr_path 	act_cst, cst_path;
short			rc;
struct ret_struct	ret_st;
IGRboolean save_broadcast;
IGRshort                sts_short=0;

if(nb_lines == 0 && lines != NULL){
   printf("ERROR: nb_lines null  and lines != NULL ????\n");
   goto wrapup;
}

found    	= 0;
modify_flag	= 0;

if(path_to_add == NULL )
 	{printf("ERROR, Invalid argument in VDSAddPath\n");goto wrapup;}

if(path_to_add->path != NULL){
   	len = strlen(path_to_add->path);
   	if(len >= MY_PATH_MAX){
     		printf("ERROR: len of [%s] is > MAX_LEN\n",path_to_add->path);
		goto wrapup;
	}
}
if(path_to_add->name != NULL){
  	len = strlen(path_to_add->name);
  	if(len >= NAME_MAX){
   		printf("ERROR: len of [%s] is > MAX_LEN\n",path_to_add->name);
		goto wrapup;
	}
}
if(const_flag != MAIN_PATH && const_flag != SEARCH_PATH )
 	{printf("ERROR: not a valid arg. const_flag\n"); goto wrapup;}


/* look for the directory user_path */

sts = vds$init_path(user_path = path, md_env = &md_env, dir_obj = &dir_obj); 
if ( !(sts&1)) {printf("error vds$init_path\n");goto wrapup;}


len = strlen(path);

strcat(path,":*");

if(nb_lines == 0){

   lines    = NULL;
   tnb_lines = 0;
   strcpy(&path[len],":*");

   sts = di$ls( regexp = path,
		lines  = &lines,
		ptr    = &tnb_lines);
   if (sts != DIR_S_SUCCESS) {di$report_error(sts=sts);goto wrapup;}

}
else tnb_lines = nb_lines;


exp_index  = 0;
name_index = 0;

for (i=0;i<tnb_lines;i++)
   {
    EXP_extract_lhs_rhs(lines[i],name,value);

    sts = di$split(pathname = name, name = real_name);
    if (sts != DIR_S_SUCCESS) {di$report_error(sts=sts);goto wrapup;}


     if(const_flag == MAIN_PATH)
      {
        sts_short = VDexp_locate("act_symbol_main",real_name);
        if (sts_short != 0) continue;
        sts_short = VDexp_locate("symbol_main",real_name);
        if (sts_short != 0) continue;
        sts_short = VDexp_locate("act_main",real_name);
        if (sts_short != 0) continue;
        sts_short = VDexp_locate("main",real_name);
      }
     else if(const_flag == SEARCH_PATH)
      {
        sts_short = VDexp_locate("act_search",real_name);
        if (sts_short != 0) continue;
        sts_short = VDexp_locate("search",real_name);
      }
     if (sts != 0) 
      {
	wrk_index = -1;
        if(const_flag == MAIN_PATH)
   		sscanf(&real_name[4],"%d", &wrk_index);
        else if(const_flag == SEARCH_PATH)
   		sscanf(&real_name[6],"%d", &wrk_index);


	if(exp_index < wrk_index) exp_index = wrk_index;

        EXP_extract_string(value,extrd_value);


         sts = read_exp(extrd_value,&cst_path);
  	  if (! (sts & 1))
           {
             printf("failure read_exp\n");
             goto wrapup;
           }

	wrk_index = -1;

        if(const_flag == MAIN_PATH && strncmp(cst_path.name,"path",4) == 0)
   		sscanf(&cst_path.name[4],"%d", &wrk_index);
        else if(const_flag == SEARCH_PATH&& strncmp(cst_path.name,"search",6) == 0)
   		sscanf(&cst_path.name[6],"%d", &wrk_index);

    	if(name_index < wrk_index) name_index = wrk_index;
      }

   }


	/**/
	/*|  auto name => necessary add the path */
	/**/

 if(path_to_add->name == NULL || path_to_add->name[0] == '\0')
  {
    /*|path is added with an auto name */

    cst_path.name[0] = '\0';
    if(path_to_add->path == NULL || path_to_add->path[0] == '\0'){
     	printf("ERROR: neither path_to_add->name nor in_path defined\n");
	goto wrapup;
    }
    strcpy(cst_path.path, path_to_add->path);
    sts = vds$auto_name(	index = name_index + 1,
			   	to_name = &cst_path,
			   	const_flag = const_flag,
			   	name = auto_name,
			   	named_flag = &named_flag);
    if (! (sts & 1) || named_flag == 0)
      	 {
		printf("error vds$auto_name\n");
		goto wrapup;
      	 }

    strcpy(cst_path.name, auto_name);
    if(const_flag == SEARCH_PATH)
     {
   	strcpy(&path[len],":search");
   	sprintf(list_index,"%d",exp_index + 1);
   	strcat(path,list_index);
        sts = write_exp(&cst_path, path_to_set);
	if(!(sts&1)) {printf("error write_exp\n");goto wrapup;}
   	sts = EXP_text_exp_build(path, path_to_set, md_env.md_id.osnum,
 			    &exp.objid);
   	if(!(sts&1))
    	 {
	   printf("error EXP_text_exp_build\n");
    	   goto wrapup;
    	 }
     }
    else if(const_flag == MAIN_PATH)
     {
       strcpy(&path[len],":main");
       sprintf(list_index,"%d",exp_index + 1);
       strcat(path,list_index);
        sts = write_exp(&cst_path, path_to_set);
	if(!(sts&1)) {printf("error write_exp\n");goto wrapup;}
   	sts = EXP_text_exp_build(path, path_to_set, md_env.md_id.osnum,
 			    &exp.objid);
   	if(!(sts&1))
    	 {
	   printf("error EXP_text_exp_build\n");
    	   goto wrapup;
    	 }
        strcpy(&path[len],":symbol_main");
        sprintf(list_index,"%d",exp_index + 1);
        strcat(path,list_index);
	sts = vds$text_to_symb( txt_symb = &path_to_add->symbology, 
				exp_symb = path_to_set);
   	sts = EXP_text_exp_build(path, path_to_set, md_env.md_id.osnum,
 			    &exp.objid);
   	if(!(sts&1))
    	 {
	   printf("error EXP_text_exp_build\n");
    	   goto wrapup;
    	 }

     }      
    goto success;
  }

	/**/
	/*|  given name => necessary path or modify it if name already exist */
	/*      if modify is done, verify the name of the active path 
	/*      because path must be modified if this name is the given one
	/**/


 for (i=0;i<tnb_lines;i++)
   {
    EXP_extract_lhs_rhs(lines[i],name,value);

    sts = di$split(pathname = name, name = real_name);
    if (sts != DIR_S_SUCCESS) {di$report_error(sts=sts);goto wrapup;}


     if(const_flag == MAIN_PATH)
      {
        sts_short = VDexp_locate("act_symbol_main",real_name);
        if (sts_short != 0) continue;
        sts_short = VDexp_locate("symbol_main",real_name);
        if (sts_short != 0) continue;
        sts_short = VDexp_locate("act_main",real_name);
        if (sts_short != 0) continue;
        sts_short = VDexp_locate("main",real_name);
      }
     else if(const_flag == SEARCH_PATH)
      {
        sts_short = VDexp_locate("act_search",real_name);
        if (sts_short != 0) continue;
        sts_short = VDexp_locate("search",real_name);
      }
     if (sts != 0) 
      {

        EXP_extract_string(value,extrd_value);


         sts = read_exp(extrd_value,&cst_path);
  	  if (! (sts & 1))
           {
             printf("failure read_exp\n");
             goto wrapup;
           }

	/**/
	/*|     name is found, don't add but modify existing path */
	/**/
	if(strcmp(cst_path.name,path_to_add->name) == 0) 
	 {
           modify_flag = 1;
           sts = write_exp(&cst_path, path_to_set);
	   if(!(sts&1)) {printf("error write_exp\n");goto wrapup;}
	   /*| name found */

           sts = di$translate(objname = name, p_objid = &exp.objid,
			       p_osnum = &exp.osnum);
           if (sts != DIR_S_SUCCESS) {printf("ERROR: name [%s] not found\n",name); goto wrapup;}

           /*|modify expression */

	   save_broadcast          = ASbroadcast_in_progress;
	   ASbroadcast_in_progress = TRUE;
     	   sts = om$send ( msg = message text_exp.modify( name, path_to_set,
							  &rc ),
                     senderid = NULL_OBJID,
                     targetid = exp.objid,
		     targetos = exp.osnum);
	   ASbroadcast_in_progress = save_broadcast;
           if (! (sts & 1))
              {
                printf("failure sending text_exp.modify\n");
                as$status(sts = sts,action = RET_STATUS);
                goto wrapup;
              }
	   if(const_flag == MAIN_PATH)
             {
		/* modify symbology expression */

		strcpy(symb,"symbol_main");
        	strcat(symb, &real_name[4]);
		strcpy(&path[len],":");
		strcat(path,symb);

           	sts = di$translate(objname = path, p_objid = &exp.objid,
			       p_osnum = &exp.osnum);

           	if (sts != DIR_S_SUCCESS) {printf("ERROR: name [%s] not found\n",path); goto wrapup;}

		sts = vds$text_to_symb( txt_symb = &path_to_add->symbology, 
					exp_symb = path_to_set);
        	if(!(sts&1)){printf("error vds$text_to_symb\n");goto wrapup;}

           	/*|modify expression */

		save_broadcast          = ASbroadcast_in_progress;
		ASbroadcast_in_progress = TRUE;
     	   	sts = om$send ( msg = message text_exp.modify( 	path, 
								path_to_set,
							  	&rc ),
                     		senderid = NULL_OBJID,
                     		targetid = exp.objid,
		     		targetos = exp.osnum);
		ASbroadcast_in_progress = save_broadcast;
           	if (! (sts & 1))
              	 {
                   printf("failure sending text_exp.modify\n");
                   as$status(sts = sts,action = RET_STATUS);
                   goto wrapup;
                 }
              }/* const_flag = main */

	   if(const_flag == SEARCH_PATH) strcpy(&path[len],":act_search");
	   if(const_flag == MAIN_PATH) strcpy(&path[len],":act_main");

           sts = di$translate(objname = path, p_objid = &exp.objid,
			       p_osnum = &exp.osnum);
           if (sts != DIR_S_SUCCESS) {printf("ERROR: name [%s] not found\n",path); goto wrapup;}
   	   sts = om$send ( msg = message text_exp.NDgive_structure(&msg,&ret_st, 
							  &md_env),
                     senderid = NULL_OBJID,
                     targetid = exp.objid,
		     targetos = exp.osnum);
   	   if (! (sts & 1))
      	     {
                printf("failure sending text_exp.NDgive_structure\n");
                as$status(sts = sts,action = RET_STATUS);
        	goto wrapup;
      	     }
  	   sts = read_exp(ret_st.var.text_st.text_string,&act_cst );
  	   if (! (sts & 1))
           {
             printf("failure read_exp\n");
             goto wrapup;
           }
	   /**/
	   /*|     name is also the active one , modify active path */
	   /**/

	   if(strcmp(act_cst.name,path_to_add->name) == 0) 
	    {
	      /*| the name is also the active name => modify active path */

              sts = write_exp(&cst_path, path_to_set);
	      if(!(sts&1)) {printf("error write_exp\n");goto wrapup;}

	      /*| name found */

              sts = di$translate(objname = path, p_objid = &exp.objid,
			       p_osnum = &exp.osnum);
              if (sts != DIR_S_SUCCESS) {printf("ERROR: name [%s] not found\n",path); goto wrapup;}

              /*|modify expression */

	      save_broadcast          = ASbroadcast_in_progress;
	      ASbroadcast_in_progress = TRUE;
     	      sts = om$send ( msg = message text_exp.modify( path, path_to_set,
							  &rc ),
                     senderid = NULL_OBJID,
                     targetid = exp.objid,
		     targetos = exp.osnum);
	      ASbroadcast_in_progress = save_broadcast;
              if (! (sts & 1))
               {
                 printf("failure sending text_exp.modify\n");
                 as$status(sts = sts,action = RET_STATUS);
                 goto wrapup;
               }
	      if(const_flag == MAIN_PATH)
                {
		   /* modify active symbology expression */

		   strcpy(&path[len],":act_symbol_main");	

           	   sts = di$translate(objname = path, p_objid = &exp.objid,
			       p_osnum = &exp.osnum);

           	   if (sts != DIR_S_SUCCESS) {printf("ERROR: name [%s] not found\n",path); goto wrapup;}

		   sts = vds$text_to_symb( txt_symb = &path_to_add->symbology, 
					exp_symb = path_to_set);
        	   if(!(sts&1)){printf("error vds$text_to_symb\n");goto wrapup;}

           	   /*|modify expression */

		   save_broadcast          = ASbroadcast_in_progress;
		   ASbroadcast_in_progress = TRUE;
     	   	   sts = om$send ( msg = message text_exp.modify( path, 
								path_to_set,
							  	&rc ),
                     		senderid = NULL_OBJID,
                     		targetid = exp.objid,
		     		targetos = exp.osnum);
		   ASbroadcast_in_progress = save_broadcast;
           	   if (! (sts & 1))
              	    {
                      printf("failure sending text_exp.modify\n");
                      as$status(sts = sts,action = RET_STATUS);
                      goto wrapup;
                    }
                 }/* const_flag = main  for active path */
	     }/* act_cst.name = path_to_add->name */
           break;
          } /* cst_name = in_name */
       }/* main or search found in exp */
   }/* end boucle */

if(modify_flag == 0){

  /*|add path with given name */

    if(path_to_add->path == NULL ||path_to_add->path[0] =='\0')
      {printf("ERROR: path must be defined to add path\n");goto wrapup;} 
    strcpy(cst_path.path, path_to_add->path);
    strcpy(cst_path.name, path_to_add->name);
    if(const_flag == SEARCH_PATH)
     {
   	strcpy(&path[len],":search");
   	sprintf(list_index,"%d",exp_index + 1);
   	strcat(path,list_index);

        sts = write_exp(&cst_path, path_to_set);
	if(!(sts&1)) {printf("error write_exp\n");goto wrapup;}
   	sts = EXP_text_exp_build(path, path_to_set, md_env.md_id.osnum,
 			    &exp.objid);
   	if(!(sts&1))
    	 {
	   printf("error EXP_text_exp_build\n");
    	   goto wrapup;
    	 }
     }
    else if(const_flag == MAIN_PATH)
     {
       strcpy(&path[len],":main");
       sprintf(list_index,"%d",exp_index + 1);
       strcat(path,list_index);

        sts =write_exp(&cst_path, path_to_set);
	if(!(sts&1)) {printf("error write_exp\n");goto wrapup;}
   	sts = EXP_text_exp_build(path, path_to_set, md_env.md_id.osnum,
 			    &exp.objid);
   	if(!(sts&1))
    	 {
	   printf("error EXP_text_exp_build\n");
    	   goto wrapup;
    	 }
        strcpy(&path[len],":symbol_main");
        sprintf(list_index,"%d",exp_index + 1);
        strcat(path,list_index);
	sts = vds$text_to_symb( txt_symb = &path_to_add->symbology, 
				exp_symb = path_to_set);

   	sts = EXP_text_exp_build(path, path_to_set, md_env.md_id.osnum,
 			    &exp.objid);
   	if(!(sts&1))
    	 {
	   printf("error EXP_text_exp_build\n");
    	   goto wrapup;
    	 }

     }      

}

goto success;

success:


 if(out_name != NULL)
  {
   strcpy(out_name, cst_path.name);
  }
  if(nb_lines == 0 && lines != NULL && tnb_lines != 0)
   {
    di$free(lines = lines,
            count = tnb_lines);
    lines = NULL;
    tnb_lines = 0;
   }


  return OM_S_SUCCESS;

wrapup:
  if(nb_lines == 0 && lines != NULL && tnb_lines != 0)
   {
    di$free(lines = lines,
            count = tnb_lines);
    lines = NULL;
    tnb_lines = 0;
   }
return OM_E_ABORT;
}

end implementation Root;

