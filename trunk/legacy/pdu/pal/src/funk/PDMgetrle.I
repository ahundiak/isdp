/* This file contains routines to get the RLE file name attached to 
   catalog
*/
class implementation ci;

#include <stdio.h>
#include <malloc.h>
#include <string.h>
#include <PDUstr.h>
#include "MEMstruct.h"
#include "MEMerrordef.h"
#include "OMminimum.h"
#include "OMtypes.h"
#include "OMmacros.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "ciexecmacros.h"
#include "PALglbs.h"
#include "COmdef.h"
#include "FI.h"
#include "MOmacros.h"
#include "PDUcommand.h"
#include "PDUerror.h"       
from ACmacro_defn import ACgive_upscan;

#include "MEMstruct.h"
#include "PALglbs.h"

/*#include "PDUproto.h"*/
#ifndef bld21
#include "PALfunkpro.h"
#endif
#include "PALpdmrpro.h"

/* 23/Nov/93 - raj.	*/
#include "PDUfile_def.h"

/* ------------------------   extern variables ---------------------------*/

extern int NumCatalogs, MacroDisplayed ;
extern char CatNameList[MAX_CATALOGS][TBL_LEN];
extern struct	PDUrefresh *refresh ;
extern char ViewOrTblList[][6];
extern	int  PDU_cat_selected , PDU_comm_attribs ;

extern MEMptr PDU_storage_area;

/* ----------------------------------------------------------------------*/

char PALrlefname[20];
char PALsortfname[40];

display_fig(form_label, fp, glabel, mod_env)
int form_label ;
Form fp;
int glabel ;
struct GRmd_env *mod_env;
{
	/* this function displays sketch of for the current comp_type 
           in a seperate form if RLE file is available. 

	   If catalog is parametric, RLE file gets copied locally when
	   'copy_and_load_macro_lib() function is invoked. Name of the RLE
	    file can be obtained from pdmparamloc table. 

	   If part is not parameteric  copy RLE file locally.

	   If part is parametric but RLE file is not available, show
	   macro view. This window can be deleted when user picks up
	   another catalog. If macro view is displayed, MacroDisplayed 
	   will be set to TRUE and 'show sketch' gadget will be disabled.
	   
	*/
	GRobjid   ppl_objid;
	int i, sts , response ;
	char filename[200] ;
	char cat_type[5];
	char	*msg;	/* 23/Nov/93 - raj.	*/

	/* Get ViewOrTblList index */
	if( PDU_comm_attribs) {
		for( i = 0 ; i < NumCatalogs ; ++ i ) 
			if(!strcmp(refresh -> rev_catalog,CatNameList[i]))
				break;

		if( i == NumCatalogs ) return(0);
	        PDMquery_catalog_type(CatNameList[i], cat_type);
        	_pdm_debug("1.cat_type = <%s>", cat_type);
	}
	else
	{
		i = 0 ;
	        PDMquery_catalog_type(refresh->rev_catalog, cat_type);
        	_pdm_debug("2.cat_type = <%s>", cat_type);
	}

	if(!GetRleFileName(filename))
		return(0);

	strcpy( ViewOrTblList[i], cat_type );
	_pdm_debug("catalog type: %s", ViewOrTblList[i]);
	
	/* Copy rle file only if it not a parametric part. For parametric parts
	   this file anyway gets copied locally in 'copy_and_load_macro_lib()
	*/
	if( strcmp(ViewOrTblList[i],"P")  && strcmp(ViewOrTblList[i],"CID") 
			&& strcmp(ViewOrTblList[i],"PXT")
			&& strcmp(ViewOrTblList[i],"EID")){
		if(!copy_rlefile(filename) )
			return(0);
	}
	else{
		if( !copy_and_load_macro_lib(refresh -> rev_catalog) )
			return(0);
	}
              
        if( access(filename, 04) != 0 ) 
        {					  
		if( !strcmp(ViewOrTblList[i],"P")
			|| !strcmp(ViewOrTblList[i],"PXT")
			|| !strcmp(ViewOrTblList[i],"CID") 
				|| !strcmp(ViewOrTblList[i],"EID")){

			if( !show_macro_view(fp,mod_env) )
				return(0);

			MacroDisplayed = TRUE;

			/* 23/Nov/93 - raj. Moved message from notification
			   to here, so that message is displayed only when
			   a macro view is displayed.
			*/
                        msg = (char *)PDUtranslate_message(PDM_I_SKETCH_TOGGLE);
                        FIg_set_text(fp, FI_MSG_FIELD, msg);

/*			FIg_disable(fp,glabel);*/

			return(1);
		}

		/* file doesn't exist. */
   		_pdm_debug ("Sketch is not available for this part\n",0);
		FIg_set_state_off(fp,glabel);
		return (0);	
        }

	_pdm_debug(" file local: ", 0);

	strcpy(PALrlefname,filename);

	sts = ci$load(file_name	= "IDrast3.u",
		file_id		= &ppl_objid,
		sender_id	= NULL_OBJID);

	_MO_omerr_chk("Load file: ",sts,wrapup);

	_pdm_debug( "Loaded IDrast3.u",0);
	
   	sts = ci$run(file_id = &ppl_objid, entry = "sketch_init", 
			sender_id=NULL_OBJID, retval = &response);

	_MO_omerr_chk("Run PPL file: ",sts,wrapup);

	return(1);

wrapup:
	return(0);
}


GetRleFileName(filename )
char *filename ;
	
	/* Get the Rle File name for a given catalog and part */
{

	int   max_rows=1, err_code , sts ;
	char query[256], *output_str , *ptr ;

	if(( refresh -> rev_partid != NULL && strcmp(refresh -> rev_partid,""))
	  &&( refresh -> rev_revision != NULL && strcmp(refresh -> rev_revision,""))){
		sprintf(query, "select p_sketch from %s where n_itemname='%s' and n_itemrev = '%s'", refresh -> rev_catalog,
					refresh -> rev_partid,refresh -> rev_revision) ;

		_pdm_debug("GetRleFileName(): query: <%s>", query);

		sts = RISquery(query,&max_rows,&output_str,&err_code);

		if( sts < 0 )
			free(output_str);
	}
	else
		sts = -1 ;

	if( sts < 0 ) {

		sprintf(query,"select p_rle from pdmparamloc where n_catalogname='%s'",
					refresh -> rev_catalog);

		sts = RISquery(query,&max_rows,&output_str,&err_code);

		if( sts < 0 ) {
			free(output_str);
			_pdm_debug("Error getting RLE sketch file name\n",0);
			return(0);
		}
	}

	
	ptr = strtok(output_str,"~");

	if( ptr!= NULL )
		strcpy(filename,ptr);
	else
	{
		filename[0]='\0' ;
		return (0);
	}

	_pdm_debug("sketch file name: %s", filename);

	return(1);
}


copy_rlefile(filename)
char *filename;
{	
	int	sts = 0;
	long	status;
	int	char_index, type;
  	char	*line = NULL;
	char	**data_ptr, str[1024] ;
	MEMptr	file_buffer=NULL, return_buffer=NULL ;
	
	/* copy RLE file from server */

	if( strlen(filename) < 1 )
		return(0);

  /* create file buffer */
  type = PDU_FILE_BUFFER;

  status = PDUformat_buffer (type, &file_buffer);
  _pdm_status("PDUformat_buffer", status);

  if (status != PDM_S_SUCCESS)
    {
    PDUmessage(status, 's');
    return(status);
    }

  line = (char*) malloc ((file_buffer->row_size)+1);

  /* load part information into file buffer */

     memset (line, NULL, file_buffer->row_size);
     char_index = 0;

     /* add the n_catalogno and n_itemno columns to the buffer */
     line[char_index++] = '\1';    /* entry for n_catalono */
     line[char_index++] = '\1';    /* entry for n_itemno */

     /* add the refresh information to the buffer */
     if ((strlen (refresh->rev_catalog )) && refresh->rev_catalog)
       PDUadd_buffer_string(line, &char_index, refresh->rev_catalog);
     else
       line[char_index++] = '\1';

     if ((strlen (refresh->rev_partid )) && refresh->rev_partid)
       PDUadd_buffer_string(line, &char_index, refresh->rev_partid);
     else
       line[char_index++] = '\1';

     if ((strlen (refresh->rev_revision )) && refresh->rev_revision)
       PDUadd_buffer_string(line, &char_index, refresh->rev_revision);
     else
       line[char_index++] = '\1';

     if ((strlen (filename )) && filename)
       PDUadd_buffer_string(line, &char_index, filename);
     else
       line[char_index++] = '\1';

     line[char_index++] = '\1';    /* entry for p_action */

     _pdm_debug("line = <%s>", line);

     status = MEMwrite (file_buffer, line);

     if (status != MEM_S_SUCCESS)
       {
       _pdm_debug("Error writing to file buffer", 0);
       _pdm_status("MEMwrite()", status);

       free ((char *)line);

       /* close buffers */
       if (file_buffer)  MEMclose(&file_buffer);
       return(PDM_E_WRITE_BUFFER);
       }

    MEMprint_buffer("file buffer", file_buffer, "/usr/tmp/pdu.dbg");

	sts = PDMcopy(file_buffer,  &return_buffer);

	data_ptr = (char **)return_buffer -> data_ptr ;

	if(!strcmp(data_ptr[return_buffer -> columns -1],"SUCCESS"))
	{
		if (file_buffer)
		   MEMclose(&file_buffer);
		if (return_buffer)
		   MEMclose(&return_buffer);
		free ((char *)line);
		return(1);
	}

	if (file_buffer)
	   MEMclose(&file_buffer);
	if (return_buffer)
	   MEMclose(&return_buffer);
	free ((char *)line);

	if( sts == PDM_S_SUCCESS )
		return(1);

	return(0);
}


struct sup *lcl_dup;
struct GRid def_gragad, def_hdr, def_id , def_window ;
delete_window(fp,glabel)
Form fp ;
int glabel ;
{
	int Nb_Max_Temp = 0 ;

	if( !MacroDisplayed )
          return(1);
		
        if(def_hdr.objid != NULL_OBJID && def_window.objid != NULL_OBJID)
         {
	  ACerase_macro
	    (&def_hdr,&def_id,lcl_dup,Nb_Max_Temp,&def_gragad);

          om$send(msg = message Root.delete(1),
                            targetid = def_window.objid,
                            senderid = def_window.objid,
                            targetos = def_window.osnum);
          def_window.objid = NULL_OBJID;
          
	  FIg_enable (fp,glabel );

        }


	MacroDisplayed = FALSE ;
	return(1);

}

#define TABLE 21
#define DATA_COL 1

show_macro_view(fp,mod_env)
struct GRmd_env *mod_env ;
Form fp;
{

	int    hdr_symb ,no,props, screen , sts , mtype  ;
	enum ACm_poss_scroll hdr_scroll ;
	enum ACm_poss_hdr    hdr_type   ;
	struct GRid macro_id , hdr_def; 
	char post_placement[DI_PATH_MAX] , search_path[DI_PATH_MAX] ,macname[20];
        char *msg;

	/* Get macro name from 'catalog' table has attribute by 
	   name 'macro'  else get from 'pdmparamloc' table	*/
	if ( !get_macro_name(macname,refresh -> rev_catalog,fp,TABLE,DATA_COL) )
		return(0);

	FIf_get_screen(fp,&screen);
        FIf_cvrt_to_perm_win ( fp );     /* Fix for TR#139222800 */


/*	strcpy(macname,"testmac"); */

	if(!get_mac_hdr(macname,&macro_id,mod_env))
		return(0);

	GetMacroType(&macro_id,&mtype);

	if(mtype == 0 )     /* For ci_macros no $def entry in dir */
	{
                msg = (char *)PDUtranslate_message(PDM_E_NO_MACRO_VIEW);
                FIg_set_text(fp, FI_MSG_FIELD, msg);
		return(0);
	}

	sts = om$send( msg = message ACmacro_defn.ACgive_upscan(
				&no,&props,&lcl_dup),
                      senderid = macro_id. objid,
                      targetid = macro_id. objid,
                      targetos = macro_id. osnum );

	_MO_omerr_chk("PDUis_macro_edited(): ACgive_upscan : ", sts, wrapup);

	def_id.objid = NULL_OBJID ;

	COm_get_option_grid(&macro_id, &def_id,NULL);

	_pdm_debug("after get_option_grid: def_id:  %d", def_id.objid);

	if( def_id.objid  == NULL_OBJID )
		return(0);

	COm_get_options(&macro_id, &hdr_symb,&hdr_scroll,&hdr_type,&hdr_def,
			search_path,post_placement,&def_hdr,mod_env);

	ACcreate_window(def_hdr.osnum,&def_window,&def_gragad,screen,100,100,483,360+15);

	ACdisplay_macro(&def_hdr,&def_id,lcl_dup,no,&def_gragad);

	return(1);
wrapup:
	return(0);
}

extern int PDU_command;
int palresponse;
WaitForEvent()
{
	/* Waits for an event to be put on the queue and returns the
	   response
	*/

	IGRint		response, sts ;
	GRobjid   	ppl_objid;

/*	int responses[1];
	char *strings[1];
	

	PDU_command = PDC_M_EV_WAIT;
	responses[0] = EX_CMD_KEY;
	strings[0] = "PEvWt";

	PDUprepare_queue(responses,strings,1);
*/

	/* get an entry at the front of the queue */

	sts = ci$load(file_name	= "ev_wait.u",
		file_id		= &ppl_objid,
		sender_id	= NULL_OBJID);

	_MO_omerr_chk("Load PPL file: ",sts,wrapup);

	if( ppl_objid == NULL_OBJID )
		return(0);


   	sts = ci$run(file_id = &ppl_objid, entry = "wait_for_event", sender_id=NULL_OBJID,
		retval = &response );

	_MO_omerr_chk("Run PPL file : ",sts,wrapup);

	_pdm_debug("retval: %d", response );


	if( palresponse )
		return(1);
wrapup:
		return(0);
	
}

extern struct GRid *PDU_part_id ;

PALgetcsid(csid)
struct GRid *csid ;
{
	IGRint		response, sts ;
	GRobjid ppl_objid ;
	sts = ci$load(file_name	= "get_cs_id.u",
		file_id		= &ppl_objid,
		sender_id	= NULL_OBJID);

	_MO_omerr_chk("Load PPL file 'get_cs_id': ",sts,wrapup);

	if( ppl_objid == NULL_OBJID )
		return(0);


   	sts = ci$run(file_id = &ppl_objid, entry = "getcsidppl",sender_id=NULL_OBJID,
		retval = &response );

	_MO_omerr_chk("Run PPL file : ",sts,wrapup);

	if( PDU_part_id == NULL )
		return(0);

	*csid = *PDU_part_id ;


	free( (char *) PDU_part_id);
	PDU_part_id = NULL ;
	return(1);
wrapup:
	return(0);

}


PALcritfile(flag, noattrs)
int flag, noattrs;
{
	IGRint		response, sts ;
	GRobjid ppl_objid ;
	extern Form cur_form_f;

	sts = ci$load(file_name	= "get_fname.u",
		file_id		= &ppl_objid,
		sender_id	= NULL_OBJID);

	_MO_omerr_chk("Load PPL file 'get_fname': ",sts,wrapup);

	if( ppl_objid == NULL_OBJID )
		return(0);

   	sts = ci$run(   file_id = &ppl_objid,
			entry = "getfilename",
			sender_id=NULL_OBJID,
			retval = &response );

	_MO_omerr_chk("Run PPL file : ",sts,wrapup);

	if( !PALsortfname[0] )
		return(0);

	if( flag == 1 )
		SaveCriteria( cur_form_f, PALsortfname, noattrs );
	else
		RestoreCriteria( cur_form_f, PALsortfname, noattrs );

	return(1);
wrapup:
	return(0);
}
	

IGRint PALis_grraster()

  {

   IGRint status,sts;
   IGRint response;
   static IGRint flag = FALSE;
   IGRchar path[256];
   GRobjid ppl_objid;

   _pdm_debug("Entering PALis_grraster", 0);

   if (!PALget_path("Grnuc", path))
   {
     _pdm_debug("Could not find Grnuc path", 0);
     return (0);
   }

   _pdm_debug("path = <%s>", path);

   strcat(path, "/config/dload/raster");
   status = PDUverify_file(path);
   _pdm_status("PDUverify_file", status);

   if (status != PDM_S_SUCCESS)
     {
     _pdm_debug("grraster is not loaded", 0);
     PDUmessage(PDM_I_GRRASTER_NOT_LOADED, 's');
     return(PDM_I_GRRASTER_NOT_LOADED);
     }

   if (!PALget_path("Grnuc", path))
   {
     _pdm_debug("Could not find Grnuc path", 0);
     return (0);
   }

   _pdm_debug("path = <%s>", path);

   strcat(path, "/ppl/bin/grraster.e");
   status = PDUverify_file(path);
   _pdm_status("PDUverify_file", status);

   if (status != PDM_S_SUCCESS)
     {
     _pdm_debug("grraster is not loaded", 0);
     PDUmessage(PDM_I_GRRASTER_NOT_LOADED, 's');
     return(PDM_I_GRRASTER_NOT_LOADED);
     }

   if (!flag)
     {
     sts = ci$load(file_name = "grraster",
                file_id         = &ppl_objid,
                sender_id       = NULL_OBJID);

     if( ppl_objid == NULL_OBJID )
     {
     _pdm_debug("ci$load FAILED", 0);
      return(0);
     }


     sts = ci$run(file_id = &ppl_objid,
                sender_id=NULL_OBJID,
                retval = &response );
     flag = TRUE;
     status = PDM_S_SUCCESS;
     }
   status = PDM_S_SUCCESS;

  _pdm_debug("Leaving PALis_grraster", 0);
  return(status);
  }

IGRint PALget_path(prod, path)
char *prod, *path;
{

	FILE *fp1 ;
	char s1[30], s2[30], s3[30], s4[256], str[150] , s[30],*pt;
	static char s5[256] ;
        char *env_var_name;
        char prod_path[80];

        /* ALR  2/7/94  Support of INGRHOME */
        env_var_name = (char *)getenv("INGRHOME");
        sprintf(prod_path,"%s/product_data\0",env_var_name);
	fp1 = fopen(prod_path,"r");

	_pdm_debug("PALget_path(): for product: %s", prod);
	
	strcpy (path, "");
	/* 11/Dec/93 - raj.	*/
	strcpy(s1, "");
	strcpy(s2, "");
	strcpy(s3, "");
	strcpy(s4, "");

	if( fp1 == NULL )
	{
	  _pdm_debug("Error opening product_data file");
	  return(0);
	}

	sprintf(s,"\"%s\"",prod);

	pt = fgets(str,149, fp1) ;

	while ( pt != NULL )
	{
	  _pdm_debug("Line : <%s>", str);
	  sscanf(str,"%s %s %s %s %s\n",s1,s2,s3,s4,path);
	  if( ! strcmp(s1,s) )
	  {
	    _pdm_debug("Path for product is: <%s>", path);
            fclose(fp1);	/* 09/Dec/93 - raj.	*/
	    return(1);
          }
          pt = fgets(str,149, fp1) ;
	}

	fclose(fp1);

	_pdm_debug("Found no path for product", 0);
	
	return(0);
}

end implementation ci;
