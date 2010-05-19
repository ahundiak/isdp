/* $Id: VDSudp_init.I,v 1.4 2001/02/19 21:41:20 ramarao Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vdstartup/imp / VDSudp_init.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSudp_init.I,v $
 *	Revision 1.4  2001/02/19 21:41:20  ramarao
 *	*** empty log message ***
 *	
 *	Revision 1.3  2001/02/14 15:47:48  ramarao
 *	Added debugging functions.
 *	
 *	Revision 1.2  2001/02/14 15:27:09  ramarao
 *	Added debugging globals.
 *	
 *	Revision 1.1.1.1  2001/01/04 21:09:23  cvs
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

class implementation Root;

#include "OMlimits.h"            /*                              */
#include "OMminimum.h"           /* Typedefs                     */
#include "OMerrordef.h"          /* Error codes OM_?_*           */
#include "OMprimitives.h"        /* Macros om$*()                */
#include "igetypedef.h"          /* IGE typedefs GR*             */
#include "igrtypedef.h"          /* Typedef IGR*                 */
#include "exdef.h"               /* Constants for exec (IGE)     */
#include "ex.h"                  /* Structs EX*                  */
#include "igrdef.h"              /* Constants IGR??              */
#include "igr.h"                 /* Structs IGR* for geometries  */
#include "igrdp.h"               /* Structs IGR* for display     */
#include "gr.h"                  /* Structs GR* for graphic info */
#include "godef.h"               /* Constants GR* for graphics   */
#include "go.h"                  /* Struct GR* for graphics      */
#include "griodef.h"             /* Constants for graphic I/O    */
#include "grio.h"                /* Structs for graphic I/O      */
#include "dpdef.h"               /* Constants for display        */
#include "dp.h"                  /* Enums, structs for display   */

#include "DIdef.h"
#include "DItypedef.h"
#include "DIprims.h"
#include "DIglob.h"

#include "FI.h"
#include "parametric.h"
#include "exmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "VDSpathdef.h"
#include "VDSudp_mac.h"
#include "VDSudp_priv.h"
#include "VDSpath_form.h"
#include "VDStextdef.h"

/* Global related to debugging. Not related to this file. */
%safe
long             DBG_Gb_dbg=0;
FILE            *DBG_Gb_Fp=stdout;
%endsafe

extern	int	free(),
                ASsuper_construct();

extern	int	(*AStranslate)();
extern	int	VDStranslate();

extern	int 	VDSverify_exp(),
		VDSverif_text_exp(),
		VDSAddPathsExp(),
		VDSGetPathFrmFile();
extern		FI_get_form_by_name(),
		FIf_delete(),
		FIf_erase(),
		FIg_set_text(),
		FIfld_set_text();
extern		VDSfill_textset_list(),
		VDSread_expr_dir(),
		GRdpb_get(),
		VDSget_select_text();


from	VDCmdPath		import	exp_to_instances;
from	VDCmdPath		import	form_init;
from	VDCmdPathRv	import	VDSupdate_list;
from	VDCmdPathRv	import	VDSupdate_act;
from	VDCmdLcNm	import	VDSfill_instances;

/* Debug Related Functions */
VDdbg_Gb_Set( IGRlong	bit_to_set, 
	      IGRint	on_or_off    )
{
   if( on_or_off == 0 )
   {
	if( DBG_Gb_dbg & bit_to_set )	DBG_Gb_dbg &= ~(bit_to_set) ; 
   }
   else
   {
	if( ! ( DBG_Gb_dbg & bit_to_set ) )	DBG_Gb_dbg |= (bit_to_set) ;
   }
}

/**/
/*
/* This is a startup command for the "user defined path". It allows to 
/* initialize the function which will enable the search path, verify 
/* the paths ' expressions, update the forms which are active
/*
/* */


int VDSudp_init()
{
long 			NumberOfBytes,BytesReceived,msg,sts,stat;
Form			ptr;
struct current_path 	current;
char			expr_dir[DI_PATH_MAX],path_name[DI_PATH_MAX+25];
struct GRid		tmp_obj,VDSpath_co, cur;
struct VDStextlist	text_list;
int			modif_flag, nb_main, nb_search;
struct	GRmd_env	md_env;
struct VDStextset	disp_text;
struct constr_path	*main, *search;

	main		= NULL;
	search		= NULL;
	nb_main		= 0;
	nb_search	= 0;

	AStranslate	= VDStranslate;

 sts = VDSGetPathFrmFile("VDSPathInit", &nb_main, &nb_search, &main, &search);
 if(!(sts & 1)) {
        if(main) {free(main); main = NULL;}
        if (search) {free(search);search = NULL;}
        printf("ERROR  VDSGetPathFrmFile\n");
        return FALSE ;
 }

 modif_flag = 1;

 sts = VDSAddPathsExp(nb_main, nb_search, main, search, modif_flag);
 if(!(sts & 1)) {
        printf("ERROR  VDSAddPathsExp\n");
        if(main) {free(main); main = NULL;}
        if (search) {free(search);search = NULL;}
        return FALSE ;
 }
 if(main) {free(main); main = NULL;}
 if (search) {free(search);search = NULL;}


   /**
   /*	verify if the expressions of paths are available in the current 
   /*	filename, otherwise modify them to be consistent (change absolute
   /*	paths to be in the current filename).     
   /**/

 sts = VDSverify_exp();
 if(!(sts & 1)) {printf("ERROR VDSverify_exp\n");return FALSE ;}

   /**
   /*	try to find the command "Define or Modify User Paths"
   /*	to send it the message VDCmdPath.exp_to_instances 
   /*	( Update the cmd instances with the valid expressions ).
   /**/


 sts = di$give_pathname( osnum = OM_Gw_TransOSnum_0,
			     pathname = path_name );

 if ( sts != DIR_S_SUCCESS )
	{
      		di$report_error( sts = sts,  comment = "error in give pathname" );	
     		return FALSE ;
	}

 strcat( path_name, ":IGENOD:VDCmdPath_comm_id");
 stat = di$translate ( 	objname = path_name,
			osnum	= OM_Gw_TransOSnum_0,
			p_objid = &VDSpath_co.objid,
			p_osnum = &VDSpath_co.osnum );
   /**
   /* 	Update the "Directory Paths" form if it is active but delete
   /*	all its sub forms
   /**/    

 sts = FI_get_form_by_name("VDDirPath",&ptr);
 if (sts == FI_SUCCESS && ptr != NULL)
	{
	

 		sts = FI_get_form_by_name("VDPathList",&ptr);
 		if (sts == FI_SUCCESS && ptr != NULL) FIf_erase( ptr );
 		sts = FI_get_form_by_name("VDSymb",&ptr);
 		if (sts == FI_SUCCESS && ptr != NULL) FIf_erase(ptr );
 		sts = FI_get_form_by_name("VDDirPath",&ptr);

        	sts = vds$give_exp( current   = &current);
		if(!(sts & 1)) {printf("ERROR in vds$give_exp\n"); return FALSE ;}

 		sts = vds$update_path(	form_ptr = ptr,
					current  = &current);
 		if (! (sts & 1)){printf("failure vds$update_path\n");return FALSE ;}

  		if ( stat == DIR_S_SUCCESS )
  	 	 {
	  		sts = om$send ( msg = message VDCmdPath.exp_to_instances(
									&msg),
					senderid = NULL_OBJID,
                     			targetid = VDSpath_co.objid,
					targetos = VDSpath_co.osnum );
   	  		if (! (sts & 1) || msg == OM_E_ABORT)
   		    	 {
      			   printf("VDCmdPath:failure sending exp_to_instances\n");
        		   FIfld_set_text(ptr, MESSAGE_FIELD, 0, 0,
				       "fail to restore valid paths",FALSE);
    			   return  FALSE ;
   		     	 }
	  		sts = om$send (	msg = message VDCmdPath.form_init(),
				senderid = NULL_OBJID,
                     		targetid = VDSpath_co.objid,
				targetos = VDSpath_co.osnum );
   	  		if (! (sts & 1) || msg == OM_E_ABORT)
   		 	 {
      			   printf("VDCmdPath:failure sending form_init\n");
        		   FIfld_set_text(ptr, MESSAGE_FIELD, 0, 0,
				       "fail to reinit form",FALSE);
    			   return  FALSE ;
   		 	 }

		 }
	}


   /**
   /*	try to find the command "Review Directory Paths"
   /*	to send it the message Revform_init 
   /*	( Update the cmd instances with the valid expressions ).
   /**/

 sts = di$give_pathname( osnum = OM_Gw_TransOSnum_0,
			     pathname = path_name );

 if ( sts != DIR_S_SUCCESS )
	{
      		di$report_error( sts = sts,  comment = "error in give pathname" );	
     		return  FALSE ;
	}

 strcat( path_name, ":IGENOD:VDCmdPathRv_comm_id");
 stat = di$translate ( 	objname = path_name,
			osnum	= OM_Gw_TransOSnum_0,
			p_objid = &VDSpath_co.objid,
			p_osnum = &VDSpath_co.osnum );
   /**
   /* 	Update the "Review Directory Paths" form if it is active 
   /**/    

 sts = FI_get_form_by_name("VDRevPath",&ptr);
 if (sts == FI_SUCCESS && ptr != NULL)
	{
	
        	FIfld_set_text(ptr, MESSAGE_FIELD, 0, 0,"",FALSE);

	  	sts = om$send ( msg = message VDCmdPathRv.VDSupdate_list(&msg),
					senderid = NULL_OBJID,
                     			targetid = VDSpath_co.objid,
					targetos = VDSpath_co.osnum );
   	  	if (! (sts & 1) || msg == OM_E_ABORT)
   		    	 {
      			   printf("VDCmdPathRv:failure sending VDSupdate_list\n");
        		   FIfld_set_text(ptr, MESSAGE_FIELD, 0, 0,
				       "fail to restore valid paths",FALSE);
    			   return  FALSE ;
   		     	 }
	  	sts = om$send ( msg = message VDCmdPathRv.VDSupdate_act(&msg),
				senderid = NULL_OBJID,
                    		targetid = VDSpath_co.objid,
				targetos = VDSpath_co.osnum );
   	  	if (! (sts & 1) || msg == OM_E_ABORT)
   		    	 {
      			   printf("VDCmdPathRv:failure sending VDSupdate_act\n");
        		   FIfld_set_text(ptr, MESSAGE_FIELD, 0, 0,
				       "fail to restore valid paths",FALSE);
    			   return  FALSE ;
   		     	 }


	}

   /**
   /*	try to find the command "Locate by Name"
   /*	to send it the message VDCmdLcNm.fill_instances 
   /*	( Update the cmd instances with the valid expressions ).
   /**/

 sts = VDSverif_text_exp();
 if(!(sts&1)){printf("ERROR VDSverif_exp \n"); return FALSE ;}

 sts = di$give_pathname( osnum = OM_Gw_TransOSnum_0,
			     pathname = path_name );

 sts = ex$get_cur_mod(   id    = &cur.objid,
			 osnum = &cur.osnum );

 sts = di$give_pathname( osnum    = cur.osnum,
			 pathname = expr_dir );
 strcat(expr_dir,VDS_EXPR_DIR);
 if ( sts != DIR_S_SUCCESS )
	{
      		di$report_error( sts = sts,  comment = "error in give pathname" );	
     		return FALSE  ;
	}

 strcat( path_name, ":IGENOD:VDSpath_text_id");
 stat = di$translate ( 	objname = path_name,
			osnum	= OM_Gw_TransOSnum_0,
			p_objid = &VDSpath_co.objid,
			p_osnum = &VDSpath_co.osnum );

 sts = FI_get_form_by_name("VDLocName",&ptr);
 if (sts == FI_SUCCESS && ptr != NULL)
	{
		
		sts = di$translate(	objname = expr_dir,
					p_objid = &tmp_obj.objid,
					p_osnum = &tmp_obj.osnum );
  		if( sts != DIR_S_SUCCESS ){
			/* have to create the object */
			tmp_obj.objid = NULL_OBJID;
			sts = di$mkdir( dirname = expr_dir,
					p_dirid = &tmp_obj.objid,
					p_osnum = &tmp_obj.osnum );
			if( sts != DIR_S_SUCCESS ){
			  printf("error di$mkdir\n");return FALSE ;
			}
  		}

		NumberOfBytes = sizeof(md_env);
		gr$get_module_env( 	msg    = &msg,
		    			sizbuf = &NumberOfBytes,
		    			buffer = &md_env,
		    			nret   = &BytesReceived);
 		if(!(msg&1)) {printf("error gr$get_module_env\n"); return FALSE ;}

  		sts = VDSread_expr_dir(	&text_list,
					expr_dir,
					&md_env );
  		if( ! (sts & 1)  ){
			printf(" ERROR: fct VDSread_expr_dir failed \n");
			return FALSE ;
  		}

  		sts = VDSget_select_text(	&text_list, 
						&disp_text, 
						expr_dir, 
						&md_env );
  		if( ! (sts & 1) ){
	    		printf(" ERROR: fct VDSget_select_text failed\n");
	    		return FALSE ;
  		}
		sts = VDSfill_textset_list(	&text_list,
						ptr, 
						VDS_SELECT_FLD );
		if( ! (sts & 1) ){
	  		printf(" ERROR: fct VDSfill_textset_list failed \n");
	  		return FALSE ; 
		}
		/* display the text in the fields */

		sts = FIg_set_text( ptr, VDS_EXPRES_FLD, disp_text.expres );
		if( sts != FI_SUCCESS ){ printf("error FIg_set_text\n");return FALSE ;}

		sts = FIg_set_text( ptr, VDS_PREFIX_FLD, disp_text.prefix );
		if( sts != FI_SUCCESS ){ printf("error FIg_set_text\n");return FALSE ;}

		sts = FIg_set_text( ptr, VDS_SUFFIX_FLD, disp_text.suffix );
		if( sts != FI_SUCCESS ){ printf("error FIg_set_text\n");return FALSE ;}

		sts = FIg_set_text(ptr, VDS_SELECT_FLD, disp_text.select );
		if( sts != FI_SUCCESS ){ printf("error FIg_set_text\n");return FALSE ;}

	}
 if(stat == DIR_S_SUCCESS )
  {
	  	sts = om$send ( msg = message VDCmdLcNm.VDSfill_instances(
									&msg),
				senderid = NULL_OBJID,
                    		targetid = VDSpath_co.objid,
				targetos = VDSpath_co.osnum );
   	  		if (! (sts & 1) )
   		    	 {
      			   printf("VDCmdPath: failure sending fill_instances\n");
    			   return FALSE  ;
   		     	 }
    
  }

  return TRUE;
}

end implementation Root;
