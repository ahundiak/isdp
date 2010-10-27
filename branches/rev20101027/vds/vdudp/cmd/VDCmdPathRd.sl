/* $Id: VDCmdPathRd.sl,v 1.1.1.1 2001/01/04 21:09:31 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdudp/cmd / VDCmdPathRd.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdPathRd.sl,v $
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

command_string       VDC_M_RaFl, 0, VDRaFl
command_table        "vds.cmd"
class                VDCmdPathRd
super_class          VDCmdPath
product_name         "$VDS"


specification

instance
{
struct GRid	VDSread_co;
int		overr_option;
}

implementation

#include "stdio.h"
#include "string.h"
#include "OMmacros.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "expression.h"

#include "vdsmacros.h"

#include "VDSudp_mac.h"
#include "VDSudp_priv.h"

#include "VDSudpco.h"
#include "VDmsg.h"

#include "AS_status.h"
#define AS_DEBUG 1

/**********************************************************/

state_table

#include "VDmsg.h"
#include "VDSudpco.h"

state start
	message_key	VD_M_RaFl
	prompt_key	VD_P_OvExPath
	filter		get_event

  on EX_STRING
	do get_option						state get_name

  on EX_BACK_UP
	do status_key VD_S_ComTerm				state terminate

state get_name
	message_key	VD_M_RaFl
	prompt_key	VD_P_EnFlNm
	filter		get_event

  on EX_STRING
	do read_file	
		on RETURN_CODE = "NO_FILE"			state no_file
		on RETURN_CODE = "SEVERE_ERROR"			state haveError
								state terminate

  on EX_BACK_UP
	do status_key VD_S_ComTerm				state terminate

state no_file
   status_key VD_S_FlNtFnd
	on ELSE							state -

state haveError
   status_key VD_S_ReadErr 
	on ELSE							state terminate

/* -------------------------------------------------------- */
action get_option
/*.get_option */
{
me->ret = SUCCESS;

  if(me->event1.event.keyin[0] == '\0' || me->event1.event.keyin[0] == 'y' ||
     me->event1.event.keyin[0] == 'Y' )
         me->overr_option = 1;
  else   me->overr_option = 0;


return OM_S_SUCCESS;

}
/* -------------------------------------------------------- */
action read_file
/*.read_file*/
{
 char			file[DI_PATH_MAX], file_name[MY_MAX],text[2*MY_MAX], 
 			chg_exp[DI_PATH_MAX],tmp[2*DI_PATH_MAX+10],
 			tmp3[2*DI_PATH_MAX+10],**part_exp;
 FILE			*pf;
 int			done = 0, i,len, len1;
 long			msg, sts, stat;
 int			nb_returned,main_size, search_size, nb_main, nb_search;
 struct constr_path     *main;
 struct constr_path     *search;

me->ret = SUCCESS;

main = NULL;
search = NULL;
part_exp = NULL;

nb_main = main_size = 0;
nb_search = search_size = 0;

strcpy(file_name, me->event1.event.keyin);

pf = NULL;
vd$openfile(	file_name 	= file_name,
		product_name 	= "Vds",
		sub_path 	= "config",
		cur_dir 	= TRUE,
		p_file 		= &pf);
if(pf == NULL){
  printf("file [%s] not found\n",file_name);
  me->ret = NO_FILE;
  return OM_S_SUCCESS;
 }
 
stat = VDSget_filename(file);
if(!(stat&1)) {printf("VDSget_filename fail\n"); goto wrapup;}

search = (struct constr_path*)
              om$malloc(size = sizeof(struct constr_path)* ALLOC_INCR_3  );
main   = (struct constr_path*)
              om$malloc(size = sizeof(struct constr_path)* ALLOC_INCR_3  );

if(search == NULL) {printf("No space avalaible for search\n"); goto wrapup;}
if(main == NULL)   {printf("No space avalaible for main\n")  ; goto wrapup;}

search_size = ALLOC_INCR_3;
main_size   = ALLOC_INCR_3;

while (fgets(text,2*MY_MAX-1,pf) != NULL)
 {
  EXP_strip(text);
  i = 0;

  /* enleve les tabulations et les fins de lignes */

  while(text[i] == '\t')
   {
    strcpy(text,&text[i+1]);
    i = i+1;
   }
  len1 = strlen(text);

  while( text[len1-1] == '\t' || text[len1-1] == '\n' )
   {
    text[len1-1] = '\0';
    len1 = strlen(text);
   }

  if (text[0] != 's' && text[0]!='m' || text[1]!='!')
    {
      /*"WARNING: not a readable line  [%s]\n",text*/
      continue;
    }
   
   nb_returned = 0;
  stat = vds$extract_all_part_exp( nb_part    = &nb_returned,
     			           expression = text,
				   sep_char   = '!'); 
  if (! (stat & 1))
    { 
	printf("error vds$extract_all_part_exp\n");
	goto wrapup;
    }
   len = strlen(text);
   part_exp = (char **)om$calloc(num = nb_returned, size = sizeof(char*));
   if(part_exp == NULL)
    {
	printf("bad allocation of part_exp\n");
	goto wrapup;
    }
   for(i=0;i<nb_returned;i++)
    {
        part_exp[i] = (char *)om$malloc(size = (len + 1)*sizeof(char));
        if(part_exp[i] == NULL)
	  {
	    printf("bad allocation of part_exp\n");
	    goto wrapup;
  	  }
     }

   stat = vds$extract_all_part_exp( 	expression  = text,
					nb_returned = nb_returned,
					part_exp    = part_exp,
					sep_char    = '!'); 

   if (! (stat & 1))
     { 
	printf("error vds$extract_all_part_exp\n");
	goto wrapup;
     }
#ifdef DEBUG
   printf("\nText = %s\n",text);
   for(i=0;i<nb_returned;i++)  {printf("part_exp[i]: [%s]\n",part_exp[i]);}
#endif

    len = part_exp[1] ? strlen(part_exp[1]) : 0;
    if( len >= NAME_MAX)  
     {
       printf("WARNING: path not added because its lenght: [%s]\n",part_exp[1]);
       continue;
     }
    len = part_exp[2] ? strlen(part_exp[2]) : 0;
    if( len >= MY_PATH_MAX)  
     {
       printf("WARNING: path not added because its lenght: [%s]\n",part_exp[2]);
       continue;
     }


  if (strcmp(part_exp[0],"s") == 0)
   {

    /*|text begin with s! --------------------*/

    if(nb_returned != 3) {printf("error in search expression\n");goto wrapup;}
    if(search_size < nb_search + 1)
     {

       search = (struct constr_path *)om$realloc(size = (search_size + ALLOC_INCR_3) *  sizeof(struct constr_path),
			   ptr =  (char *)search );
       search_size = search_size + ALLOC_INCR_3;
     }
    strcpy(search[nb_search].name,part_exp[1]);
    if(part_exp[2][0] == ':'){

    		/*|if path absolute verify filename */

      		stat = VDSextract_part_exp(&part_exp[2][1], tmp, tmp3, ':');
        	if(!(stat&1)) {/*|nothing after filename */ strcpy(tmp,tmp3);}
        	if(strcmp(&file[1],tmp) != 0)
         	  {
           		/*| Not same file name ==> not ok */
	   		strcpy(chg_exp,file);
           		strcat(chg_exp,":");
           		strcat(chg_exp,tmp3);
  	 	  }
    	
    }
    else strcpy(chg_exp, part_exp[2]);
    strcpy(search[nb_search].path,chg_exp);
    nb_search = nb_search + 1;
     done = 1;
   }
  else if (strcmp(part_exp[0],"m") == 0)
   {

    /*|text begin with m! -------------------*/

    if(nb_returned < 3) {printf("error in main expression\n");goto wrapup;}
    if(main_size < nb_main + 1)
     {
       main = (struct constr_path *)om$realloc(size = (main_size + ALLOC_INCR_3) * sizeof(struct constr_path),
			 ptr =  (char *)main );
       
       main_size = main_size + ALLOC_INCR_3;
     }
    strcpy(main[nb_main].name,part_exp[1]);
    if(part_exp[2][0] == ':'){

    		/*|if path absolute verify filename */

      		stat = VDSextract_part_exp(&part_exp[2][1], tmp, tmp3, ':');
        	if(!(stat&1)) {/*|nothing after filename */ strcpy(tmp,tmp3);}
        	if(strcmp(&file[1],tmp) != 0)
         	  {
           		/*| Not same file name ==> not ok */
	   		strcpy(chg_exp,file);
           		strcat(chg_exp,":");
           		strcat(chg_exp,tmp3);
  	 	  }
    	
    }
    else strcpy(chg_exp, part_exp[2]);
    strcpy(main[nb_main].path,part_exp[2]);
    if(nb_returned == 3)
     {
      /*|no symbology given, take active */
      strcpy(main[nb_main].symbology.color,"act");
      strcpy(main[nb_main].symbology.layer,"act");
      strcpy(main[nb_main].symbology.weight,"act");
      strcpy(main[nb_main].symbology.style,"act");
      main[nb_main].symbology.layer_name[0] = '\0';
     }
    else
     {
       sts = vds$symb_to_text(txt_symb = &main[nb_main].symbology, 
		           exp_symb = part_exp[3]);
       if(!(sts&1)){printf("VDSsymb_to_text fail\n");goto wrapup;}
       if(strncmp(main[nb_main].symbology.layer,"act",3) == 0){
       		if(main[nb_main].symbology.layer_name[0] != '\0'){
		        ex$message(msgnumb = VD_I_ActLvNo);
       			main[nb_main].symbology.layer_name[0] = '\0';
       		}
       }
     }
    nb_main = nb_main + 1;
    done = 1;
  }
 }/* while EOF */
if(pf) fflush(pf);
if(pf)fclose(pf);

if(!done)
 {
   ex$message(msgnumb = VD_E_NoRdFile);
   goto success;
 }

 status     = om$send(  targetid = me->VDSread_co.objid,
 			targetos = me->VDSread_co.osnum,
			mode   = OM_e_wrt_message,
			msg    = message VDCmdPath.add_path( &msg,nb_main,
   						nb_search,  main, search,
						me->overr_option));
 if(!(status & 1))
  {
   printf("error sending message VDCmdPath.add_path\n");
   goto wrapup;
  }


ex$message(msgnumb = VD_S_RdFiCmp);
goto success;
success:

if(part_exp != NULL) 
  {
    for(i=0;i<nb_returned;i++) 
    if(part_exp[i]!=NULL) 
          {om$dealloc(ptr = part_exp[i]);part_exp[i]=NULL;}
    om$dealloc(ptr = part_exp);
    part_exp=NULL;
                     
  }
if(main != NULL) {om$dealloc(ptr = main); main = NULL;}
if(search != NULL) {om$dealloc(ptr =search); search = NULL;}

return OM_S_SUCCESS;
wrapup:
	if(pf) fflush(pf);
	if(pf)fclose(pf);

	/*|dealloc */
	if(part_exp != NULL) 
         {
 	    for(i=0;i<nb_returned;i++) 
            if(part_exp[i]!=NULL) 
                     {om$dealloc(ptr =part_exp[i]);part_exp[i]=NULL;}
 	    om$dealloc(ptr = part_exp);
            part_exp=NULL;
                     
          }
	if(main != NULL) {om$dealloc(ptr =main); main = NULL;}
	if(search != NULL) {om$dealloc(ptr = search); search = NULL;}
	me->ret = SEVERE_ERROR;
	return OM_S_SUCCESS;
		

}

/* -------------------------------------------------------- */

action init
/*.init*/
{
 char 	path_name[DI_PATH_MAX];

 status     = om$send(  targetid = my_id,
			mode   = OM_e_wrt_message,
			msg    = message CEO_LOCATE.init( type, str_ptr ) );
 as$status( action = RET_STATUS );
 status = di$give_pathname( osnum = OM_Gw_TransOSnum_0,
			    pathname = path_name );

 if ( status != DIR_S_SUCCESS )
   {
     di$report_error( sts = status,  comment = "error in give pathname" );	
     return ( OM_I_STOP_SENDING );
   }

 strcat( path_name, COMMAND_NAME );

 
 status = di$translate (  objname = path_name,
			  osnum	  = OM_Gw_TransOSnum_0,
			  p_objid = &me->VDSread_co.objid,
			  p_osnum = &me->VDSread_co.osnum );

  if ( status != DIR_S_SUCCESS )
  {
   printf("ERROR: this command must only be used with the form VDDirPath\n");
   me->state = _terminate;
   return ( OM_I_STOP_SENDING );
  }

}

/* -------------------------------------------------------- */

action delete
/*.delete*/
{

   status = om$send( targetid = my_id,
			mode   = OM_e_wrt_message,
			msg    = message CEO_LOCATE.delete ( 0 ));
   return ( OM_S_SUCCESS );
}


