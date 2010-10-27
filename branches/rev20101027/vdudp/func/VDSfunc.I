/* $Id: VDSfunc.I,v 1.1.1.1 2001/01/04 21:09:31 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdudp/func / VDSfunc.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSfunc.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:31  cvs
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

/****************************************************
/*
/* funtions for VDSpath command
/* 
/* 	1.  VDSadd_layer_def
/* 	2.  VDSget_filename	-
/* 	3.  VDSchg_exp_filename
/* 	4.  VDScreate_path -
/* 	5.  VDSremove_user_path
/* 	6.  VDSexp_to_symb
/* 	7.  VDSexp_path
/* 	8.  VDSis_pathdir
/* 	9.  write_exp
/* 	10. read_exp
/* 	12. VDSverify_ref -
/* 	13. VDSverify_exp
/* 	14. VDSget_path_from_obj
/*	15. VDSverify_layer
/*	16. VDSinit_symb
/*	17. VDSadd_buff
/*
/****************************************************/

class implementation Root;

#include <stdio.h>
#include <ctype.h>
#include <string.h>

#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "godef.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "expression.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIprims.h"
#include "DImacros.h"
#include "OMerrordef.h"
#include "OMprimitives.h"
#include "parametric.h"
#include "OMminimum.h"

#include "AS_status.h"
#include "VDSpathdef.h"
#include "VDSudp_mac.h"
#include "VDSudp_priv.h"
#include "exdef.h"
#include "exmacros.h"
#include "EMSmsgdef.h"

#include "adpdef.h"
#include "igewindef.h" 
#include "igecolordef.h"
#include "igecolor.h"
#include "igecolmacros.h" 


#define AS_DEBUG 1


extern IGRboolean ASbroadcast_in_progress;

from 	text_exp 	import  NDgive_structure, modify;
from	GRvg		import	GRgetsymb;
from 	DPlvldir	import 	get_lvl_def,add_name_to_lvldir;

/*1  ----------------------- VDSadd_layer_def ---------------------------*/
/*
/*   Take the layer names in the array of paths and add to layer def
/*	IGRlong			*msg		(O)return code
/*	IGRint			nb_path		(I)number of path (symbology)
/*	struct constr_path	*paths		(I)path and symbology
/*	
/**/

VDSadd_layer_def(msg, nb_path, paths)
IGRlong			*msg;
IGRint			nb_path;
struct constr_path	*paths;

/*.VDSadd_layer_def*/
{
IGRlong		NumberOfBytes, BytesReceived;
long		stat;
IGRboolean	found,err_flag;
IGRchar		symb_name[SYMB_CHAR],buff_name[256],buffer[256],***layer_part,
		**tab_taken,ems_file[DI_PATH_MAX]; 
struct GRid	dplvldir;
IGRint		i,j,k,l,nb_taken,nb_returned,len, buff_len, *layer_nb,
		*name_index;
IGRshort	short_level;

if(msg == NULL || nb_path == 0 || paths == NULL  ){
        if(msg != NULL) *msg = EMS_E_InvalidArg;
        return(0);
}


err_flag = FALSE;
*msg = EMS_S_Success;

nb_returned = 0;
layer_part = NULL;
layer_nb = NULL;
tab_taken = NULL;
name_index = NULL;

 /*| Get the level manager object id */
 	
VDSget_filename(ems_file);
strcat(ems_file,":IGENOD:DPLVLDIR");
stat = di$translate(objname = ems_file,
                    p_objid = &dplvldir.objid,
                    p_osnum = &dplvldir.osnum);
if(!(stat&1)){
   	printf("Error in di$translate\n");
	err_flag = TRUE;
	goto wrapup;
}
/*|store all parts of layer_name (name, gp1, gp2 separated by ':' )*/

layer_part = NULL;
layer_part = (char ***)om$malloc(size = nb_path*sizeof(char**));
if(layer_part == NULL){
	printf("bad allocation of layer_part\n");
	err_flag = TRUE;
	goto wrapup;
}
layer_nb = NULL;
layer_nb = (int *)om$malloc(size = nb_path*sizeof(int));
if(layer_nb == NULL){
 	printf("bad allocation of layer_nb\n");
	err_flag = TRUE;
	goto wrapup;
}
name_index = NULL;
name_index = (int *)om$malloc(size = nb_path*sizeof(int));
if(name_index == NULL){
 	printf("bad allocation of name_index\n");
	err_flag = TRUE;
	goto wrapup;
}
for(i=0;i<nb_path;i++){
	layer_nb[i] = 0;
	layer_part[i] = NULL;
	name_index[i] = 0;
}
for(i=0;i<nb_path;i++){
	layer_nb[i] = 0;
	layer_part[i] = NULL;
	if(paths[i].symbology.layer_name[0] != '\0'){

		len = strlen(paths[i].symbology.layer_name);

		stat = vds$extract_all_part_exp( 
			nb_part = &layer_nb[i],
		      	expression = paths[i].symbology.layer_name,
			sep_char = ':'); 
		if (! (stat & 1)){ 
			printf("error vds$extract_all_part_exp\n");
			err_flag = TRUE;
			goto wrapup;
		}

        	layer_part[i] = NULL;
        	layer_part[i] = (char **)om$malloc(size = layer_nb[i]*sizeof(char*));
        	if(layer_part[i] == NULL){
			printf("bad allocation of layer_part[i]\n");
			err_flag = TRUE;
			goto wrapup;
       		}
        	for(k=0;k<layer_nb[i];k++)	layer_part[i][k] = NULL;
        	
           	for(k=0;k<layer_nb[i];k++){
           		layer_part[i][k] = NULL;
             		layer_part[i][k] = (char *)om$malloc(size = (len+1)*sizeof(char));
             		if(layer_part[i][k] == NULL){
				printf("bad allocation of layer_part[i]\n");
				err_flag = TRUE;
				goto wrapup;
   			}
		}	

        	/*|vds$extract_all_part_exp */
		 
		stat = vds$extract_all_part_exp( 
				expression  = paths[i].symbology.layer_name,
				nb_returned = layer_nb[i],
				part_exp    = layer_part[i],
				sep_char = ':'); 

        	if (! (stat & 1)){ 
			printf("error vds$extract_all_part_exp\n");
			err_flag = TRUE;
			goto wrapup;
		}
                  	    
		/*|create definition of names*/

		name_index[i]=0;
		while(layer_part[i][name_index[i]][0] == '\0') name_index[i]++;

		if(name_index[i] >= layer_nb[i]){
			/*|No layer name defined */
			
			continue;
		}
		strcpy(buffer,layer_part[i][name_index[i]]);
		strcat(buffer,"=");
		if(strncmp(paths[i].symbology.layer,"act",3) == 0){
    			NumberOfBytes = sizeof( short_level);
    			gr$get_active_level(	msg = msg,
            				sizbuf = &NumberOfBytes,
            				buffer = &short_level,
            				nret = &BytesReceived);

    			if ( !((*msg)&1)){
    				printf("error get_active_level\n");
				err_flag = TRUE;
				goto wrapup;
    			}
    			sprintf(symb_name,"%d",(int)short_level);
    			
		}
		else strcpy(symb_name,paths[i].symbology.layer);
		strcat(buffer,symb_name);
		stat = VDSadd_buff(msg, &dplvldir, buffer);
   		if (! (stat & (*msg) & 1 )){
     			printf("Error VDSadd_buffer\n");
			continue;
     			
    		}
			
	}
}	
nb_returned = 0;
for(i=0;i<nb_path;i++){
	if(layer_part[i] != NULL && layer_nb != NULL){
		nb_returned = nb_returned + layer_nb[i];
	}
}
/* tab_taken is the array of layer_gp already taken */
if(nb_returned ){
     tab_taken = NULL;
     tab_taken = (char **)om$malloc(size = nb_returned * sizeof(char*));
     if(tab_taken == NULL){
     	printf("bad allocation of tab_taken\n");
	err_flag = TRUE;
	goto wrapup;
     }
     for(i=0;i<nb_returned;i++){
     	tab_taken[i] = NULL;
     	tab_taken[i] = (char *)om$malloc(size = LAYER_CHAR *sizeof(char));
     	if(tab_taken[i] == NULL){
     		printf("bad allocation of tab_taken\n");
		err_flag = TRUE;
		goto wrapup;
     	}
     	tab_taken[i][0] = '\0';
     }
     /*|create definition of gpe names */
     nb_taken = 0;
     for(i=0;i<nb_path;i++){
        if(layer_part[i] != NULL && layer_nb != NULL){
             if(layer_nb[i] >1 && name_index[i] < layer_nb[i]){
                for(k=name_index[i]+1;k<layer_nb[i];k++){
                	if(layer_part[i][k][0] == '\0') continue;
                        found = FALSE;
                        for(l=0;l<nb_taken;l++){
                                if(strcmp(layer_part[i][k],tab_taken[l]) == 0){
                                        /*|layer_gp already taken*/
                                        found = TRUE;
                                        break;
                                }
                        }
                        if(found) continue;
                        /*| fill buffer */
                        strcpy(buffer,layer_part[i][k]);
                        strcat(buffer,"=");
			strcpy(buff_name, buffer);
                        strcat(buffer,layer_part[i][name_index[i]]);

                        for(l=0;l<nb_path;l++){
                           if(l == i) continue;
                           for(j=1;j<layer_nb[l];j++){
                               if(strcmp(layer_part[i][k],layer_part[l][j]) == 0){
                                      strcat(buffer,",");

				      buff_len = strlen(buffer);
				      if( (buff_len + strlen(layer_part[l][name_index[j]]) + 2) > 256){
						stat = VDSadd_buff(msg, &dplvldir, buffer);
   						if (! (stat & (*msg) & 1 )){
							strcpy(buffer,buff_name);
     							printf("Error VDSadd_buffer\n");
							continue;
     			
    						}
						strcpy(buffer,buff_name);
					    
				      }
                                      strcat(buffer,layer_part[l][name_index[j]]);
                               }
                           }       
                        }

			stat = VDSadd_buff(msg, &dplvldir, buffer);
   			if (! (stat & (*msg) & 1 )){
     				printf("Error VDSadd_buffer\n");
				continue;
     			
    			}
                        /*|fill tab_taken*/
                        strcpy(tab_taken[nb_taken],layer_part[i][k]);
                        nb_taken ++;                    
                }                               
            }
        }
     }
}


wrapup:

if(layer_part != NULL) {
   	for(i=0;i<nb_path;i++){ 
             	if(layer_part[i]!=NULL && layer_nb != NULL){
             		for(k=0;k<layer_nb[i];k++){
             			if(layer_part[i][k] != NULL){
             				free(layer_part[i][k]);
             				layer_part[i][k] = NULL;
             			}
             		}
             		free(layer_part[i]);layer_part[i]=NULL;
             	}
	}
	if(layer_part != NULL)free(layer_part);
	layer_part=NULL;
}
if(tab_taken != NULL){
	for(i=0;i<nb_returned;i++){
		if(tab_taken[i] != NULL)
			{free(tab_taken[i]); tab_taken[i] = NULL;}
	}
	free(tab_taken);tab_taken = NULL;
}
if(layer_nb != NULL){free(layer_nb);layer_nb = NULL;}
if(name_index != NULL){free(name_index);name_index = NULL;}

if(err_flag) return(0);
else return(1);

}

/*2  ----------------------- VDSget_filename---------------------------*/
/*
/*  return the current filename
/*
/**/

VDSget_filename(filename)
char	*filename ;   /* (O) output filename	*/
/*.VDSget_filename*/
{
IGRlong		NumberOfBytes;
IGRlong		BytesReceived;
long		msg,sts;
struct GRmd_env md_env; 


 filename[0] = '\0';
 NumberOfBytes = sizeof(md_env);
 gr$get_module_env( msg    = &msg,
		    sizbuf = &NumberOfBytes,
		    buffer = &md_env,
		    nret   = &BytesReceived);
 if(!(msg&1)) {printf("error gr$get_module_env\n"); return OM_E_ABORT;}


 sts = di$give_pathname(osnum = md_env.md_id.osnum, pathname = filename);
 if(sts != DIR_S_SUCCESS) {printf("error di$give_pathname\n"); return OM_E_ABORT;}


 return OM_S_SUCCESS;

}

/*3  ----------------------- VDSchg_exp_filename ---------------------------*/
/*
/*  verify if the path expression given by its name and id is consistent
/*  with filename (if absolute path, must begin with ":filename") and if not
/*  correct the expression 
/*
/**/

VDSchg_exp_filename(name_exp, exp_id, file_name, md_env)
char		*name_exp;
struct GRid     *exp_id; 
char		*file_name;
struct GRmd_env *md_env; 

/*.VDSchg_exp_filename*/
{
char			chg_exp[DI_PATH_MAX],**wrk_search;
int			nb_part, i;
long			msg,sts;
char			tmp[2*DI_PATH_MAX+10], tmp2[2*DI_PATH_MAX+10], tmp3[2*DI_PATH_MAX+10];
struct ret_struct  	ret_st;
short			rc;
IGRboolean save_broadcast;


nb_part = 0;
wrk_search = NULL;

sts = om$send( msg = message text_exp.NDgive_structure(&msg,&ret_st,md_env),
     			senderid = NULL_OBJID,
     			targetid = exp_id->objid,
			targetos = exp_id->osnum);
if(!(sts&1)) { printf("VDSpath_fn, text_exp.NDgive_structure ERROR\n"); return(OM_S_SUCCESS);}

sts = VDSextract_part_exp(ret_st.var.text_st.text_string, tmp, tmp2, '!');


if(!(sts&1)) 
 {
   /*|path without name => active or ref */

   if(ret_st.var.text_st.text_string[0] != ':') return OM_S_SUCCESS;
   sts = VDSextract_part_exp(&ret_st.var.text_st.text_string[1], tmp, tmp2, ':');


   if(!(sts&1)) {/*|nothing after filename */ strcpy(tmp,tmp2);}


   if(strcmp(&file_name[1],tmp) == 0)
      {
       		/*| Same file name ==> ok */

       		return OM_S_SUCCESS;
      }
   else 
      {
       		/*| Not same file name ==> not ok */

       		strcpy(tmp3,file_name);
       		strcat(tmp3,":");
       		strcat(tmp3,tmp2);

		save_broadcast = ASbroadcast_in_progress;
		ASbroadcast_in_progress = TRUE; /* Don't make a wait batch */
       		sts = om$send( msg = message text_exp.modify(name_exp,tmp3,&rc),
     			senderid = NULL_OBJID,
     			targetid = exp_id->objid,
			targetos = exp_id->osnum);
		ASbroadcast_in_progress = save_broadcast;
       		if(!(sts&1)) 
         		{ printf("VDSpath_fn, text_exp.modify ERROR\n"); return(OM_E_ABORT);}
      }

 } /* end active or ref */
else
 {

   strcpy(chg_exp,tmp);
   strcat(chg_exp,"!");

   sts = VDSextract_part_exp(tmp2, tmp, tmp3, ',');

   if(!(sts&1)) 
    {
      	/*|no , in path => it is a main or a only one path search*/

      	if(tmp2[0] != ':') return OM_S_SUCCESS;
      	sts = VDSextract_part_exp(&tmp2[1], tmp, tmp3, ':');

      	if(!(sts&1)) {/*|nothing after filename */ strcpy(tmp,tmp3);}

      	if(strcmp(&file_name[1],tmp) == 0)
          {
           	/*| Same file name ==> ok */
           	return OM_S_SUCCESS;
          }
      	else 
          {
           	/*| Not same file name ==> not ok */
	   	strcat(chg_exp,file_name);
           	strcat(chg_exp,":");
           	strcat(chg_exp,tmp3);

		save_broadcast = ASbroadcast_in_progress;
		ASbroadcast_in_progress = TRUE;   /* Don't make a wait batch */
           	sts = om$send( msg = message text_exp.modify(name_exp,chg_exp,
							     &rc),
     			senderid = NULL_OBJID,
     			targetid = exp_id->objid,
			targetos = exp_id->osnum);
		ASbroadcast_in_progress = save_broadcast;
           	if(!(sts&1)) 
             		{ printf("VDSpath_fn, text_exp.modify ERROR\n"); return(OM_E_ABORT);}
  	  }
      
    }/* end main */
   else
    {
      	/*|more than one path => it is a search */

      	sts = vds$extract_all_part_exp( nb_part = &nb_part,
     		             	      expression = tmp2); 
      	if(sts != 1) {printf("vds$extract_all_part_exp fail\n"); goto wrapup;}


      	wrk_search = (char **)om$malloc(size = nb_part*sizeof(char*));
      	if(wrk_search == NULL)
	  {
	  	printf("bad allocation of wrk_search\n");
	  	goto wrapup;
  	  }
      	for(i=0;i<nb_part;i++)
     	  {
          	wrk_search[i] = NULL;
          	wrk_search[i] = (char *)om$malloc(size = (strlen(tmp2)+2) *
							sizeof(char));
          	if(wrk_search[i] == NULL)
		    {
			printf("bad allocation of wrk_path\n");
			goto wrapup;
  		    }
  	  }
      	/*|fill wrk_search */
      	sts = vds$extract_all_part_exp( nb_returned = nb_part, 
			  		expression  = tmp2, 
     			  		part_exp    = wrk_search);	
      	if(sts != 1) {printf("vds$extract_all_part_exp fail\n"); goto wrapup;}
      	for(i=0; i< nb_part; i++)
         {
         	if(wrk_search[i][0] == '\0') continue;
        	if(i != 0 ) strcat(chg_exp,",");
      		if(wrk_search[i][0] != ':') 
          	  {
	    		strcat(chg_exp,wrk_search[i]);
            		continue;
          	  }
      		sts = VDSextract_part_exp(&wrk_search[i][1], tmp, tmp3, ':');
        	if(!(sts&1)) {/*|nothing after filename */ strcpy(tmp,tmp3);}

        	if(strcmp(&file_name[1],tmp) == 0)
         	  {
           		/*| Same file name ==> ok */
	    		strcat(chg_exp,wrk_search[i]);
            		continue;
         	  }
       		else 
         	  {
           		/*| Not same file name ==> not ok */
	   		strcat(chg_exp,file_name);
           		strcat(chg_exp,":");
           		strcat(chg_exp,tmp3);
  	 	  }
         }/* end boucle i */

	save_broadcast = ASbroadcast_in_progress;
	ASbroadcast_in_progress = TRUE;   /* Don't make a wait batch */
     	sts = om$send( msg = message text_exp.modify(name_exp,chg_exp,&rc),
     			senderid = NULL_OBJID,
     			targetid = exp_id->objid,
			targetos = exp_id->osnum);
	ASbroadcast_in_progress = save_broadcast;
      	if(!(sts&1)) 
             { printf("VDSpath_fn, text_exp.modify ERROR\n"); goto wrapup;}

    }/* end search */

  
 }/* end main or search */

if(wrk_search != NULL) 
   {
 	  for(i=0;i<nb_part;i++)
           { 
             if(wrk_search[i]!=NULL) 
                        {free(wrk_search[i]);wrk_search[i]=NULL;}
           }
 	  if(wrk_search != NULL) {free(wrk_search); wrk_search=NULL;}
                     
   }

return OM_S_SUCCESS;

wrapup:

if(wrk_search != NULL) 
   {
 	  for(i=0;i<nb_part;i++)
           { 
             if(wrk_search[i]!=NULL) 
                        {free(wrk_search[i]);wrk_search[i]=NULL;}
           }
 	  if(wrk_search != NULL) {free(wrk_search); wrk_search=NULL;}
                     
   }
 return OM_E_ABORT;
}

/*4---------------------- VDScreate_path -----------------------------------
    This function is used to create all the directories defining the given path
    if needed.
*/
VDScreate_path( path)
char 	*path; /* (I) path to create */

/*.VDScreate_path*/
{
long		sts;
char 		dirname[DI_PATH_MAX],name[DI_PATH_MAX],current[DI_PATH_MAX+30],
		active[DI_PATH_MAX];
int		flag;
struct GRid 	dir;


 flag = 0;
 sts = di$pwd(dirname = active);

 strcpy(current,active);


if(path[0] == ':') 
 {
   path = &path[1];
   sts = VDSextract_part_exp(path, dirname, name,':');

   strcpy(path,":");
   strcat(path,dirname);
   strcpy(dirname,path);
   strcpy(current,dirname);
   sts = di$translate ( objname = dirname,
			 p_objid = &dir.objid,
			 p_osnum = &dir.osnum );

    if ( sts != DIR_S_SUCCESS ) 
     {
      sts = di$mkdir(dirname = dirname);
      if(sts != DIR_S_SUCCESS) 
           {printf("ERROR: cannot create [%s]\n",dirname);return 0;}
     }
    sts = di$cd(dirname = dirname , path = current);     
    if(sts != DIR_S_SUCCESS) 
        {printf("ERROR cannot change dir to [%s]\n", dirname);return 0;}
    strcpy(path, name);
 }
while (flag == 0)
{

 sts = VDSextract_part_exp(path, dirname, name,':');

 if(!(sts & 1))
  {
    flag = 1;
    sts = di$mkdir(dirname = path);
    if(sts != DIR_S_SUCCESS) 
	{printf("ERROR: cannot create [%s]\n",path);return 0;}
  } 
 else
 {
    sts = di$translate ( objname = dirname,
			 path    = current,
			 p_objid = &dir.objid,
			 p_osnum = &dir.osnum );

    if ( sts != DIR_S_SUCCESS ) 
     {

      sts = di$mkdir(dirname = dirname);
      if(sts != DIR_S_SUCCESS) 
           {printf("ERROR: cannot create [%s]\n",dirname);return 0;}
     }
    sts = di$cd(dirname = dirname , path = current);     
    if(sts != DIR_S_SUCCESS) 
           {printf("ERROR: cannot change directory to [%s]\n",dirname);return 0;}
    strcpy(path, name);
    strcat(current,":");
    strcat(current,dirname);
  }
 }
sts = di$cd(dirname = active);     
if(sts != DIR_S_SUCCESS) 
           {printf("ERROR: cannot change directory to [%s]\n",active);return 0;}

return OM_S_SUCCESS;
}


/*5---------------------- VDSremove_user_path -----------------------------------
    This macro is used to remove all the expressions in the user_path
    directory
*/
VDSremove_user_path()
/*.VDSremove_user_path*/
{
char		path[DI_PATH_MAX];	
struct GRmd_env md_env;	
char		**lines;
int		i,nb_lines;
struct digrid	*exp;	
long		sts;

lines 		= NULL;
nb_lines 	= 0;
exp   		= NULL;


/* look for the directory user_path */

sts = VDSis_pathdir(path ,&md_env );
if(!(sts&1)) {printf("ERROR: directory user_path doesn't exist\n");goto wrapup;}
strcat(path,":*");


 sts = di$dump( regexp = path,
		lines  = NULL ,
		ptr    = &nb_lines,
		grids  = &exp);
 if (sts != DIR_S_SUCCESS) {di$report_error(sts=sts);goto wrapup;}

 for (i=0;i<nb_lines;i++)
   {
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
    }

  if(exp != NULL) {free(exp);exp = NULL;}   
  if(lines != NULL && nb_lines != 0)
   {
    di$free(lines = lines,
            count = nb_lines);
    lines = NULL;
    nb_lines = 0;
   }


return OM_S_SUCCESS;
wrapup:
  if(exp != NULL) {free(exp);exp = NULL;}   
  if(lines != NULL && nb_lines != 0)
   {
    di$free(lines = lines,
            count = nb_lines);
    lines = NULL;
    nb_lines = 0;
   }

return OM_E_ABORT;
}

/*6---------------------- VDSexp_to_symb -----------------------------------
    This function is used to return the symbology given by the expression

    struct GRsymbology  *symbology    : (O) return symbology		
    char 		*exp_symb     : (I)value of symbology expression 
    int			*act_symb     : (O) 1 = active symbology
*/
VDSexp_to_symb(symbology, exp_symb, act_symb)
struct GRsymbology  *symbology;    
char 		    *exp_symb;
int		    *act_symb;
/*.VDSexp_to_symb*/
{

int 		  len;
char		  save_exp[MY_MAX],sep_char,before[MY_MAX],after[MY_MAX],
		  symb_name[MY_MAX],symb_value[MY_MAX], after1[MY_MAX];
IGRlong		  NumberOfBytes;
IGRlong		  BytesReceived;
long		  msg,sts;
struct IGRdisplay active_display;
int		  wrk_value,non_act;

sep_char =',';

if(symbology == NULL || exp_symb == NULL || act_symb == NULL)
 {printf("arguments symbology, exp_symb and act_symb cannot be NULL\n");return OM_E_ABORT;}

len = strlen(exp_symb);
if(len >=MY_MAX){printf("ERROR: [%s] is too long\n",exp_symb);return OM_E_ABORT;}


strcpy(save_exp,exp_symb);

sts = VDSextract_part_exp(save_exp, before, after,sep_char);
if(!(sts & 1)){printf("ERROR: no ',' found \n");return OM_E_ABORT;}



if( before[0] == '\0') {printf("ERROR: nothing before ','\n");return OM_E_ABORT;}
EXP_extract_lhs_rhs(before,symb_name,symb_value);


*act_symb = 0;
non_act = 0;

   /*|active symb */
   NumberOfBytes = sizeof( active_display);
   gr$get_active_display(	msg = &msg,
            			sizbuf = &NumberOfBytes,
            			buffer = &active_display,
            			nret = &BytesReceived);

   if ( !(msg&1)) {printf("error get_active_display\n");return OM_E_ABORT;}

/*| a mettre dans la color */
       
if(strncmp(symb_value,"act",3)==0) 
  {
     /*|active color */
      symbology->display_attr.color = active_display.color;
  }
else
  {
     if(isalpha(symb_value[0]))
      {
	/*|color by name */
	if( !(ige$get_color_from_name(
			name = symb_value,
			color = (IGRshort *) &symbology->display_attr.color)))
	  {
 	    printf("ERROR: not a valid color name \n");
	    return OM_E_ABORT;	
	  }
      }
     else
     {
      	sscanf(symb_value,"%d", &wrk_value);
	if(wrk_value >= 512 || wrk_value <= 0)
    		{printf("ERRROR, invalid color in expression\n");return OM_E_ABORT;}
    	symbology->display_attr.color = (short unsigned)wrk_value;
     }
    non_act = 1;
  }


strcpy(save_exp,after);

sts = VDSextract_part_exp(save_exp, before, after,sep_char);
if(!(sts & 1)){printf("ERROR: no ',' found\n");return OM_E_ABORT;}


if( before[0] == '\0') {printf("ERROR: nothing before ','\n");return OM_E_ABORT;}
EXP_extract_lhs_rhs(before,symb_name,symb_value);


/*| take layer value */

sts = VDSextract_part_exp(symb_value, before, after1,':');
if(!(sts & 1)){
	/*|ERROR: no ':' found ie no name */
	after1[0] = '\0';
}
else {
	if( before[0] == '\0') {printf("ERROR: nothing before ':'\n");return OM_E_ABORT;}
	strcpy(symb_value,before);
}


/*| a mettre dans level */

if(strncmp(symb_value,"act",3)==0)
  {
    /*|active display */
    NumberOfBytes = sizeof( symbology->level);
    gr$get_active_level(	msg = &msg,
            			sizbuf = &NumberOfBytes,
            			buffer = &symbology->level,
            			nret = &BytesReceived);

    if ( !(msg&1)) {printf("error get_active_level\n");return OM_E_ABORT;}
  }
else
  {
   if(isalpha(symb_value[0]))
    {printf("ERRROR, invalid level in expression\n");return OM_E_ABORT;}
   sscanf(symb_value,"%d", &wrk_value);
    if(wrk_value < GR_LO_LAYER || wrk_value > GR_HI_LAYER) 
     {printf("ERRROR, invalid level in expression\n");return OM_E_ABORT;}
    symbology->level = (short) wrk_value; 
    non_act = 1;
  }

strcpy(save_exp,after);


sts = VDSextract_part_exp(save_exp, before, after,sep_char);
if(!(sts & 1)){printf("ERROR: no ',' found\n");return OM_E_ABORT;}

if( before[0] == '\0') {printf("ERROR: nothing before ','\n");return OM_E_ABORT;}
EXP_extract_lhs_rhs(before,symb_name,symb_value);


/*| a mettre dans weight */

if(strncmp(symb_value,"act",3)==0)
  {
    /*|active display */
    symbology->display_attr.weight = active_display.weight;
  }
else
  {
   if(isalpha(symb_value[0]))
    {printf("ERRROR, invalid weight in expression\n");return OM_E_ABORT;}
   sscanf(symb_value,"%d", &wrk_value);
    if(wrk_value < GR_LO_WEIGHT || wrk_value > GR_HI_WEIGHT) 
     {printf("ERRROR, invalid weight in expression\n");return OM_E_ABORT;}
    symbology->display_attr.weight= (char unsigned) wrk_value; 
    non_act = 1;
  }

EXP_extract_lhs_rhs(after,symb_name,symb_value);

/*| a mettre dans style */


if(strncmp(symb_value,"act",3)==0)
  {
    /*|active display */
    symbology->display_attr.style = active_display.style;
  }
else
  {
   if(isalpha(symb_value[0]))
    {printf("ERRROR, invalid style in expression\n");return OM_E_ABORT;}
   sscanf(symb_value,"%d", &wrk_value);
    if(wrk_value < GR_LO_STYLE || wrk_value > GR_HI_STYLE) 
     {printf("ERRROR, invalid style in expression\n");return OM_E_ABORT;}
    symbology->display_attr.style= (char unsigned)wrk_value;
    non_act = 1;
  }


if (non_act == 0) *act_symb = 1;
return OM_S_SUCCESS;
}

/*7---------------------- VDSexp_path--------------------------*/
/* function which create or modify the expression of a path  */

VDSexp_path(path_to_set, path_name, osnum)
char    	*path_to_set; 	/* (I) value of the expression		*/
char    	*path_name;	/* (I) (path + name of the expression)	*/
DIspacenum	osnum;		/* (I) osnum of the directory of the exp*/

/*.VDSexp_path*/
{
long		sts;
short		rc;
struct GRid	exp;
int		len;
char		dirname[MY_MAX];
IGRboolean save_broadcast;


if(path_to_set == NULL || path_name == NULL)
 {printf("arguments path_to_set and path_name cannot be NULL\n");return OM_E_ABORT;}

len = strlen(path_to_set);
if(len >=MY_MAX)
   {printf("ERROR: len of [%s] is > MAX_LEN\n",path_to_set);return OM_E_ABORT;}

sts = di$split(pathname = path_name, name = dirname);
if (sts != DIR_S_SUCCESS) {di$report_error(sts=sts);return OM_E_ABORT;}


len = strlen(dirname);
if(len >= MY_MAX)
  {printf("ERROR: len of [%s] is > MAX_LEN\n",dirname);return OM_E_ABORT;}

 sts = di$translate(objname = path_name, p_objid = &exp.objid,p_osnum = &exp.osnum);
 if (sts != DIR_S_SUCCESS)
   {
    /*|construct expression */

    sts = EXP_text_exp_build(path_name, path_to_set , osnum, &exp.objid);

    if(sts != EXP_S_SUCCESS) 
	{printf("error EXP_text_exp_build\n");return OM_E_ABORT;}
   }
 else
   {
     /*|modify expression */

     save_broadcast = ASbroadcast_in_progress;
     ASbroadcast_in_progress = TRUE;   /* Don't make a wait batch */
     sts = om$send ( msg = message text_exp.modify( path_name, path_to_set,
							  &rc ),
                     senderid = NULL_OBJID,
                     targetid = exp.objid,
		     targetos = exp.osnum);
     ASbroadcast_in_progress = save_broadcast;
     if (! (sts & 1))
      {
        printf("failure sending text_exp.modify\n");
        as$status(sts = sts,action = RET_STATUS);
        return OM_E_ABORT;
      }
    }


return OM_S_SUCCESS;

}

/*8----------------------- VDSis_pathdir ---------------------------*/
/* function which return if the directory user_path exist or not */

VDSis_pathdir(path,md_env)
char		*path;		/* (O) return dir user_path */
struct GRmd_env *md_env;	/* (O) return md_env  */
/*.VDSis_pathdir*/
{
IGRlong		NumberOfBytes;
IGRlong		BytesReceived;
long		msg,sts;
struct GRid	dir;

if(path == NULL || md_env == NULL)
 {printf("ERROR: arguments cannot be NULL\n");return OM_E_ABORT;}

 strcpy(path,"PATH_NOT_FOUND");
 NumberOfBytes = sizeof(*md_env);
 gr$get_module_env( msg    = &msg,
		    sizbuf = &NumberOfBytes,
		    buffer = md_env,
		    nret   = &BytesReceived);
 if(!(msg&1)) {printf("error gr$get_module_env\n"); return OM_E_ABORT;}

 
 sts = di$give_pathname(osnum = md_env->md_id.osnum, pathname = path);
 if(sts != DIR_S_SUCCESS) {printf("error di$give_pathname\n"); return OM_E_ABORT;}
 strcat(path,":user_path");

 sts = di$translate(objname = path, p_objid = &dir.objid,p_osnum = &dir.osnum);
 if (sts != DIR_S_SUCCESS)  return OM_E_ABORT;
 return OM_S_SUCCESS;

 }
/*9----------------------- write_exp ---------------------------*/
/* return the expression of (name/path) structure	       */

write_exp(in_struct, expression)
struct constr_path *in_struct;  /* (I) path and/or name  */
char		   *expression; /* (O) return expression */
/*.write_exp*/
{
int 	len;

if(in_struct == NULL || expression == NULL)
 {printf("ERROR: arguments cannot be NULL\n");return OM_E_ABORT;}

len = strlen(in_struct->path);
if(len >= MY_PATH_MAX)
 {
   printf("ERROR: [%s] cannot be longer than MY_PATH_MAX\n",in_struct->path);
   return OM_E_ABORT;
 }
len = strlen(in_struct->name);
if(len >= NAME_MAX)
 {
   printf("ERROR: [%s] cannot be longer than NAME_MAX\n",in_struct->name);
   return OM_E_ABORT;
 }
 if(in_struct->name[0] != '\0')
  {
   strcpy(expression,in_struct->name);
   strcat(expression,"!");
   strcat(expression,in_struct->path);
  }
 else strcpy(expression,in_struct->path);
 
return OM_S_SUCCESS;
}

/*10----------------------- read_exp ---------------------------*/
/* return the structure	 (name/path) of  the expression       */

read_exp(expression,out_struct )
struct constr_path *out_struct;  /* (O) path and/or name  */
char		   *expression;  /* (I) expression        */
/*.read_exp*/
{
char	before[MY_MAX],after[MY_MAX],sep_char;
long	sts;
int	len;

if(out_struct == NULL || expression == NULL)
 {printf("ERROR: arguments cannot be NULL\n");return OM_E_ABORT;}
sep_char = '!';
len = strlen(expression);
if(len >= MY_MAX){printf("[%s] is too long\n",expression);return OM_E_ABORT;}

  sts = VDSextract_part_exp(expression, before, after,sep_char);
  if(!(sts&1))
     { 
       printf("ERROR: no sep_char '!' found\n");
       return OM_E_ABORT;
     }
   else
     {
      len = strlen(before);
      if(len >= NAME_MAX)
          {printf("[%s] is too long\n",before);return OM_E_ABORT;}
      len = strlen(after);
      if(len >= MY_PATH_MAX)
          {printf("[%s] is too long\n",after);return OM_E_ABORT;}

      strcpy(out_struct->name,before);
      strcpy(out_struct->path,after);
     }
return OM_S_SUCCESS;
}



/*12  ----------------------- VDSverify_ref ---------------------------*/
/*
/*  verify if reference path is valid (must be defined in absolute way,
/*  must be existing in the current design file). return OM_S_SUCCESS if
/*  in_ref is valid, OM_E_ABORT else. "file_name" is the path to
/*  set by default in the current filename.
/**/

VDSverify_ref(in_ref,file_name)
char	*in_ref ;     /* (I) input ref_path to test validity	*/
char	*file_name ;   /* (O) output "filename:usr"	*/
/*.VDSverify_ref*/
{
 long			sts;
 struct GRid 		dir;

 /* Extract the file name */

    strcpy(file_name,"NOT_FOUND");
    sts = VDSget_filename(file_name);
    if(!(sts&1)) printf("VDSget_filename fail\n"); 


 if(in_ref[0] != ':')
      {
	printf("ERROR:ref_path must be defined in absolute way\n");
	return OM_E_ABORT;
      }

 sts = di$translate( objname = in_ref,
		     p_objid = &dir.objid,
	             p_osnum = &dir.osnum);
 if(sts != DIR_S_SUCCESS){di$report_error(sts = sts); return OM_E_ABORT;}

 return OM_S_SUCCESS;
}
/*13  ----------------------- VDSverify_exp ---------------------------*/
/*
/*  verify if the expressions in the directory : ":filename:user_path"
/*  are valid. If not (not in current filename) modify the expressions
/*  to be in the current filename. If the directory ":filename:user_path"
/*  doesn't exist, return OM_S_SUCCESS.
/*
/**/
VDSverify_exp()
/*.VDSverify_exp*/
{
char		name[DI_PATH_MAX],value[DI_PATH_MAX],path[DI_PATH_MAX+30],
		sv_path[DI_PATH_MAX+30], **lines;
struct GRmd_env wrk_env; 
int		len, i, nb_lines;
long		sts;
char 		file_name[DI_PATH_MAX];
struct digrid	*exp;
struct GRid	c_ref;

lines 		= NULL;
nb_lines	= 0;
exp   		= NULL;

 sts = VDSis_pathdir(path ,&wrk_env );
 if(!(sts&1))
   {
    /*|directory user_path doesn't exist */
    return OM_S_SUCCESS;
   }

 len = strlen(path);
 strcpy(sv_path, path);
 sts = VDSget_filename(file_name);
 if(!(sts&1)) {printf("VDSget_filename fail\n"); goto wrapup;}

	/**/
 	/*| 	verify ref_path .............. */
	/**/

 strcpy(&path[len],":ref_path");
 sts = di$translate(objname = path, p_objid = &c_ref.objid,p_osnum = &c_ref.osnum);
 if (sts != DIR_S_SUCCESS) {printf("Cannot get the ref path\n"); goto wrapup;}

 sts = VDSchg_exp_filename(path, &c_ref, file_name, &wrk_env );
 if(!(sts & 1)) { printf("ERROR VDSchg_exp_filename\n"); goto wrapup;}

	/**/
 	/*| 	verify act_dir .............. */
	/**/

 strcpy(&path[len],":active_dir");
 sts = di$translate(objname = path, p_objid = &c_ref.objid,p_osnum = &c_ref.osnum);
 if (sts != DIR_S_SUCCESS) {printf("Cannot get the act_dir\n"); goto wrapup;}

 sts = VDSchg_exp_filename(path, &c_ref, file_name, &wrk_env );
 if(!(sts & 1)) { printf("ERROR VDSchg_exp_filename\n"); goto wrapup;}

	/**/
 	/*| 	verify act_main .............. */
	/**/

 strcpy(&path[len],":act_main");
 sts = di$translate(objname = path, p_objid = &c_ref.objid,p_osnum = &c_ref.osnum);
 if (sts != DIR_S_SUCCESS) {printf("Cannot get the act_dir\n"); goto wrapup;}

 sts = VDSchg_exp_filename(path, &c_ref, file_name, &wrk_env );
 if(!(sts & 1)) { printf("ERROR VDSchg_exp_filename\n"); goto wrapup;}


	/**/
 	/*| 	verify act_search .............. */
	/**/

 strcpy(&path[len],":act_search");
 sts = di$translate(objname = path, p_objid = &c_ref.objid,p_osnum = &c_ref.osnum);
 if (sts != DIR_S_SUCCESS) {printf("Cannot get the act_dir\n"); goto wrapup;}

 sts = VDSchg_exp_filename(path, &c_ref, file_name, &wrk_env );
 if(!(sts & 1)) { printf("ERROR VDSchg_exp_filename\n"); goto wrapup;}

	/**/
 	/*| 	verify main paths .............. */
	/**/

 strcpy(path, sv_path);
 strcat(sv_path,":main");
 strcat(sv_path,"*");

 sts = di$dump( regexp = sv_path,
		lines  = &lines,
		ptr    = &nb_lines,
		grids  = &exp);
 if (sts != DIR_S_SUCCESS) {di$report_error(sts=sts);goto wrapup;}

 for (i=0;i<nb_lines;i++)
   {

    	EXP_extract_lhs_rhs(lines[i],name,value);


    	sts = VDSchg_exp_filename(name, (struct GRid *)&exp[i], file_name, &wrk_env );
    	if(!(sts & 1)) { printf("ERROR VDSchg_exp_filename\n"); goto wrapup;}

   }/* end boucle sur line */


  if(exp != NULL) {free(exp);exp = NULL;}   
  if(lines != NULL && nb_lines != 0)
   {
    di$free(lines = lines,
            count = nb_lines);
    lines = NULL;
    nb_lines = 0;
   }

	/**/
 	/*| 	verify search paths .............. */
	/**/

 strcpy(sv_path, path);
 strcat(sv_path,":search");
 strcat(sv_path,"*");

 sts = di$dump( regexp = sv_path,
		lines  = &lines,
		ptr    = &nb_lines,
		grids  = &exp);
 if (sts != DIR_S_SUCCESS) {di$report_error(sts=sts);goto wrapup;}



 for (i=0;i<nb_lines;i++)
   {
    	EXP_extract_lhs_rhs(lines[i],name,value);


    	sts = VDSchg_exp_filename(name, (struct GRid *)&exp[i], file_name, &wrk_env );
    	if(!(sts & 1)) { printf("ERROR VDSchg_exp_filename\n"); goto wrapup;}

   }/* end boucle sur line */


  if(exp != NULL) {free(exp);exp = NULL;}   
  if(lines != NULL && nb_lines != 0)
   {
    di$free(lines = lines,
            count = nb_lines);
    lines = NULL;
   }
    nb_lines = 0;

 return OM_S_SUCCESS;

 wrapup:
/*|dealloc line and exp */

  if(exp != NULL) {free(exp);exp = NULL;}   
  if(lines != NULL && nb_lines != 0)
   {
    di$free(lines = lines,
            count = nb_lines);
    lines = NULL;
   }
    nb_lines = 0;

 return OM_E_ABORT;
}


/*14  ----------------------- VDSget_path_from_obj ---------------------------*/
/*
/*  Given an object, return its path if it is a named object, otherwise
/*  return the path (first in the User defined path) which have the same
/*  symbology (if doesn't exist return the current directory). If the path
/*  doesn't exist, return the active dir and set found to 0.also return
/*  the id of the returned path.
/**/


VDSget_path_from_obj(obj, path, path_id, found)
struct GRid	*obj; 	  /* (I) input object		*/
char		*path ;   /* (O) output dir + path	*/
struct GRid	*path_id; /* (O) id of returned path	*/
int		*found;   /* (O) 0 if not named and symbology unknown 
				 in path system */

/*.VDSget_path_from_obj*/
{
long			msg,status;
struct GRsymbology 	path_symb,symbology;
int			err_flag, wrk_symb,i,nb_main;
struct constr_path 	*exp_main;
char			symb_text[MY_MAX], untr_path[DI_PATH_MAX];

 exp_main = NULL; 
 wrk_symb = 0;
 err_flag = 0;

 if(found != NULL) *found = 0;
 status = di$untranslate(  objname = untr_path,
    		           objid   = obj->objid,
		           osnum   = obj->osnum);

 if(status == DIR_S_SUCCESS){ 

	status = di$split(pathname =  untr_path,
			  dirname  =  path);
 	if(status !=DIR_S_SUCCESS){ 
		di$report_error(sts = status, comment = "ERROR di$split");
		err_flag = 1;
		goto wrapup;
	}

 	status = di$translate(	objname = path, 
				p_objid = &path_id->objid,
				p_osnum = &path_id->osnum);
 	if (status != DIR_S_SUCCESS)
		   {di$report_error(sts = status);err_flag = 1;goto wrapup;} 
	if(found != NULL) *found = 1; 
	goto wrapup;
 }
 if(status != DIR_W_NAME_NOT_FOUND && status != DIR_W_NO_NAME){ 
  	di$report_error(sts = status, comment = "ERROR untranslate");
	err_flag = 1;
	goto wrapup;
 }
 status = om$send ( msg = message GRvg.GRgetsymb(&msg,&symbology),
                              senderid = NULL_OBJID,
                              targetid = obj->objid,
                              targetos = obj->osnum);
 if (! (status & 1))
      {
        printf("failure sending GRvg.GRgetsymb\n");
        as$status(action = RET_STATUS);
	err_flag = 1;
	goto wrapup;
      }

 status = vds$give_exp( nb_main   = &nb_main);
 if(!(status & 1)) 
	{printf("ERROR in vds$give_exp\n"); err_flag = 1;goto wrapup;}

 exp_main = (struct constr_path *)om$malloc(size = nb_main*
						sizeof(struct constr_path));
 if(exp_main == NULL){
      printf("bad allocation of exp_main\n");
      err_flag = 1;
      goto wrapup;
 }
 status = vds$give_exp( main_alloc   = nb_main, 
 		        main   	     = exp_main);

 if(!(status & 1)) 
  	{printf("ERROR in vds$give_exp\n"); err_flag = 1;goto wrapup;}

 

 for (i=0;i< nb_main;i++){
	status = VDStext_to_symb(&exp_main[i].symbology, symb_text);
        if(!(status&1))
	   {printf("error vds$text_to_symb\n");err_flag = 1;goto wrapup;}

 	status = VDSexp_to_symb(&path_symb, symb_text, &wrk_symb);
 	if(!(status&1)){
		printf("error VDSexp_to_symb\n");
		err_flag = 1; 
		goto wrapup;
	}

	if(path_symb.level == symbology.level && 
	   path_symb.display_attr.color == symbology.display_attr.color &&
	   path_symb.display_attr.weight == symbology.display_attr.weight &&
	   path_symb.display_attr.style == symbology.display_attr.style){

    		/*|path_symb == symbology */
		if(found != NULL) *found = 1;
		strcpy(path, exp_main[i].path);
		VDSpath_name(path,path);

 		status = di$translate(	objname = path, 
					p_objid = &path_id->objid,
					p_osnum = &path_id->osnum);
 		if (status != DIR_S_SUCCESS){
			di$report_error(sts = status);
			err_flag = 1;
			goto wrapup;
		} 
		if(found != NULL) *found = 1; 
		goto wrapup;
	}
 }


if(found != NULL) *found = 0;
status  = di$pwd(dirname = path); 
if(status != DIR_S_SUCCESS){
		di$report_error(sts = status);
		err_flag = 1;
		goto wrapup;
} 
status = di$translate(	objname = path, 
			p_objid = &path_id->objid,
			p_osnum = &path_id->osnum);
if (status != DIR_S_SUCCESS){
			di$report_error(sts = status);
			err_flag = 1;
			goto wrapup;
} 

wrapup:
 
 if(exp_main != NULL) {free(exp_main);exp_main = NULL;}
 if (err_flag) return OM_E_ABORT;
 return OM_S_SUCCESS;
}

/*15  ----------------------- VDSverify_layer ---------------------------*/
/*
/*   Verify if the given name already exist with the same definition.
/*   (If exist found = TRUE)
/*
/*	IGRlong			*msg		(O)return code
/*	struct GRid		*lvldir		(I)lvldir object
/*	char			*buffer		(I)buffer to verify
/*	IGRboolean		*found		(O) TRUE if exist
/**/

VDSverify_layer(msg, lvldir, buffer,found)
IGRlong			*msg;
struct GRid		*lvldir	;
char			*buffer;
IGRboolean		*found	;

/*.VDSverify_layer*/
{
long		stat;
IGRboolean	err_flag;
IGRint		nb_char;
IGRchar		*ptr_to_next, col1[256], col2[256],layer_name[256], 
		*start_string,layer_def[256], *equal, *null_char;

if(msg == NULL || lvldir == NULL || buffer == NULL
  || found == NULL ){
        if(msg != NULL) *msg = EMS_E_InvalidArg;
        return(0);
}


err_flag = FALSE;
*msg = EMS_S_Success;
*found = FALSE;
ptr_to_next = NULL;

start_string = &(buffer[0]);
equal = strchr(buffer,'=');
nb_char = equal - start_string;

strncpy(layer_name,buffer,nb_char);
layer_name[nb_char] = '\0';


equal++;

null_char = strchr(buffer,'\0');

nb_char = null_char - equal ;

strncpy(layer_def,equal,nb_char);
layer_def[nb_char] = '\0';

while(1){
	stat = om$send(msg = message DPlvldir.get_lvl_def(
						(int *)msg, 
						&ptr_to_next,
						(sizeof(col1)),
						col1,
						(sizeof(col2)),
						col2),
		senderid = NULL_OBJID,
		targetid = lvldir->objid,
		targetos = lvldir->osnum);
	as$status(sts = stat);
	if (! ((*msg) &  1 )){
     		/*|end of buffer */
     		*msg = EMS_S_Success;
     		break;
	}
	stat = GRmatch(layer_name, col1);
	if(stat){
		/*|col1 match to layer_name */
		stat = GRmatch(layer_def, col2);
		if(stat){
			/*|col2 match to layer_def */
			*found = TRUE;
			goto wrapup;
		}
	}
}

wrapup:
if(err_flag) return(0);
else return(1);

}
/*16  ----------------------- VDSinit_symb ---------------------------*/
/*
/*   Init the struct txt_symb to "act" of the struct constr_path
/*
/*	struct constr_path	*str_path
/**/

VDSinit_symb(str_path)
struct constr_path	*str_path;

/*.VDSinit_symb*/
{

if(str_path == NULL ) return(0);
strcpy(str_path->symbology.color, "act");
strcpy(str_path->symbology.style, "act");
strcpy(str_path->symbology.layer, "act");
strcpy(str_path->symbology.weight, "act");
str_path->symbology.layer_name[0] = '\0';
return(1);
}


/*17  ----------------------- VDSadd_buff ---------------------------*/
/*
/*   add the buffer to lvldir if it doesn't exist
/*
/*	
/**/
VDSadd_buff(msg, lvldir, buffer)
IGRlong			*msg;
struct GRid		*lvldir	;
char			*buffer;

/*.VDSadd_buff*/
{
IGRboolean	found,err_flag;
IGRint		stat;

err_flag = FALSE;
*msg = EMS_S_Success;

stat = VDSverify_layer(	msg, 
			lvldir,
			buffer,
			&found);
		
if (! (stat & (*msg) & 1 )){
     	printf("Error VDSverify_layer\n");
	err_flag = TRUE;
	goto wrapup;
}
if(found == FALSE){
	stat = om$send(msg = message DPlvldir.add_name_to_lvldir
							((int *)msg, buffer),
                         senderid = NULL_OBJID,
                         targetid = lvldir->objid,
                         targetos = lvldir->osnum);
   	as$status(sts = stat);
   	if (!stat || ! ( 1 & (*msg) ) || !(stat & (*msg) &1 )){
     		printf("Error to store layer name : %s\n", buffer);
     		err_flag = TRUE;
		goto wrapup;
    	}
}

wrapup:

if(err_flag) return(0);
else return(1);

}


end implementation Root;
