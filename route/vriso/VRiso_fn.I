/* $Id: VRiso_fn.I,v 1.1.1.1 2001/01/04 21:12:58 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:  vriso / VRiso_fn.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VRiso_fn.I,v $
 *  Revision 1.1.1.1  2001/01/04 21:12:58  cvs
 *  Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.6  1997/02/02  22:37:32  pinnacle
# Replaced: vriso/VRiso_fn.I for:  by kddinov for route
#
# Revision 1.5  1997/01/21  16:09:24  pinnacle
# Replaced: vriso/VRiso_fn.I for:  by kddinov for route
#
# Revision 1.4  1997/01/09  18:01:36  pinnacle
# Replaced: vriso/VRiso_fn.I for:  by kddinov for route
#
# Revision 1.3  1997/01/09  14:54:52  pinnacle
# Replaced: vriso/VRiso_fn.I for:  by kddinov for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.3  1996/03/21  23:23:48  pinnacle
# Replaced: vriso/VRiso_fn.I for:  by hverstee for route240
#
# Revision 1.2  1996/01/17  00:27:52  pinnacle
# Replaced: vriso/VRiso_fn.I for:  by r240_int for route240
#
 *
 * History:
 *  01/15/96  tlb  Add VX_FIproto.h, prototypes
 *
 *  10/31/96  KDD  ISOupdate_main (set the FI_USER_MAIL field)
 *		   ISOinit_main 
 *
 *************************************************************************/
/* -------------------------------------------------------------- */
/*
/*
/*  * 31-Oct-91  1.4.3.7  
/*
/*    Bruno
/*    - Remove the ex$get_path and call the VRGetPath
/*      function.
/*    - "config/iso/..." names are no longer hardcoded any
/*      where but defined in the .h file.
/*
/* -------------------------------------------------------------- */

class implementation VRiso;

#include <stdio.h>

#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"

#include "VRGlobMac.h"
#include "ISOformdef.h"
#include "big.h"
#include "dbs.h"

#include "AS_status.h"

%safe
#include "VX_FIproto.h"
%endsafe

#define AS_DEBUG 1
/*
#define MY_DEBUG 1
*/
extern int  prj_units_set;

extern  char    QUEUE[];
extern  char    user_mail[];

/**********************************************************************/
/*
/*  ISOinit_main: function used to initialize the attributes
/*               to put in the isogen main form.
/*
/**********************************************************************/

int   ISOinit_main (struct ISOform   *isoform)

{
  char     	file_name[PATH_MAX];
  int      	status;
  IGRlong  	retmsg;
  char		error_message[128];

/******
* Nov-10-96 KDD	Search path DOESN'T depend on QUEUE value. 
* Isogen (NT and Unix) operate on isogen.idf and are kicked off by ISOclient.sh
* If QUEUE == ISOGEN checks to see if the product ISOGEN is loaded
******/

 if ( !strcmp(QUEUE, "ISOGEN") ) { 
	status= VR$GetUnixPath (     msg     = &retmsg,
	                      product_name   = VR_ISO_PROD_NAME,
	                          file_path  = VR_ISO_KSH_NAME,
	                       product_path  = file_name,
	                    product_path_len = sizeof (file_name)  );

	if ( !(status & OM_S_SUCCESS) ) {
	   printf("status= %d\n",status);
	   printf("\nVRiso_fn.I: product Isogen not found\n\n");
	   return OM_E_ABORT;
	}
 }

        status= VR$GetUnixPath (     msg     = &retmsg,
                              product_name   = VR_ROUTE_PROD_NAME,
                                  file_path  = VR_ISO_CLIENT_KSH_NAME,
                               product_path  = file_name,
                            product_path_len = sizeof (file_name)  );

         if ( !(status & OM_S_SUCCESS) ) {
            printf("status= %d\n",status);
	    sprintf(error_message, "script $ROUTE/%s not found", 
			VR_ISO_CLIENT_KSH_NAME );

            printf("\nVRiso_fn.I: %s.\nReload I/Route with Isogen option\n\n", 
			error_message); 

	    UI_status(error_message);
            return OM_E_ABORT;
         }

 strcpy(isoform->file.seed_name,file_name);
 strcat(isoform->file.seed_name,VR_ISO_SEED_NAME);

 strcpy(isoform->file.default_name,file_name);
 if( prj_units_set < 10 )
         strcat(isoform->file.default_name,VR_ISO_DEF_IMP_NAME);
 else if(prj_units_set >=10 && prj_units_set < 20 )
         strcat(isoform->file.default_name,VR_ISO_DEF_MIX_NAME);
 else if(prj_units_set >= 20)
         strcat(isoform->file.default_name,VR_ISO_DEF_MET_NAME);


 strcpy(isoform->file.design_name,VR_DEFAULT_DESIGN_NAME);
 
#ifdef MY_DEBUG
 printf ("VRiso_fn.I iso: %s\n",file_name);
 printf ("VRiso_fn.I seed_path: %s\n",isoform->file.seed_name);
 printf ("VRiso_fn.I def_path: %s\n",isoform->file.default_name);
#endif

wrapup:

  strcpy(user_mail, ""); 

  return (OM_S_SUCCESS);
}/* end ISOini_main */

/**********************************************************************/
/*
/*  ISOinit_sub: function used to initialize the attributes
/*               to put in the isogen sub form.
/*
/**********************************************************************/
int  ISOinit_sub (struct ISOform *isoform)

{

  isoform->crit[0].nb_page = 1;
  strcpy(isoform->crit[0].line_seq_number,"");
  strcpy(isoform->crit[0].block_number,"*");
  strcpy(isoform->crit[0].pds_class,"*");
  strcpy(isoform->crit[0].fluid_text,"*");
  isoform->crit[0].other = 0;

  return (OM_S_SUCCESS);
}

/**********************************************************************/
/*
/*  ISOdefault_sub: function used to initialize the attributes
/*                  to put in the isogen sub form at a given index.
/*
/**********************************************************************/

int  ISOdefault_sub (short     index,
              struct ISOform * isoform)

{
   strcpy(isoform->crit[index].line_seq_number,"");
   strcpy(isoform->crit[index].block_number,"*");
   strcpy(isoform->crit[index].pds_class,"*");
   strcpy(isoform->crit[index].fluid_text,"*");

    /*isoform->crit[index].fluid_code= -1; */

  return (OM_S_SUCCESS);
}

/*********************************************************/

int  ISOupdate_main(Form       form_ptr,
             struct ISOform  * ISOattributes )

{
  int      row=0;
  int      col=0;
  int      sel_flag=0;

  /*| before set text */

  FIfld_set_text( form_ptr, SEED_FILE, row, col, 
                  ISOattributes->file.seed_name, sel_flag );
                  
  FIfld_set_text( form_ptr,DESIGN_FILE, row, col, 
                  ISOattributes->file.design_name, sel_flag );

  FIfld_set_text( form_ptr, DEFAULT_FILE, row, col, 
                  ISOattributes->file.default_name, sel_flag );

  FIfld_set_text( form_ptr, FI_USER_MAIL, row, col, 
                  user_mail, sel_flag );

  return (OM_S_SUCCESS);
}
  
/*********************************************************/

int   ISOupdate_sub(Form       form_ptr,
             struct ISOform  * ISOattributes )

{
  int      page;
  int      row=0;
  int      col=0;
  int      sel_flag=0;
  double   value,other;

  page = ISOattributes->index_crit;
  FIfld_set_text( form_ptr, LINE_SEQ_NO, row, col, 
                  ISOattributes->crit[page].line_seq_number, sel_flag );

  FIfld_set_text( form_ptr,PIPING_MAT_CLASS, row, col, 
                  ISOattributes->crit[page].pds_class, sel_flag );

  FIfld_set_text( form_ptr, BLOCK_NO, row, col, 
                  ISOattributes->crit[page].block_number, sel_flag );

  FIfld_set_text( form_ptr,FLUID_TEXT, row, col, 
                  ISOattributes->crit[page].fluid_text, sel_flag );

  /*"fluid: %s\n",ISOattributes->crit[page].fluid_text*/

  /* ISOset_FLDfluid(form_ptr,ISOattributes->crit[page].fluid_code);*/
 
  value = (double) ISOattributes->crit[page].nb_page;
  FIfld_set_value (form_ptr,PAGE_NB , row, col, value, sel_flag );

  FIg_get_value   (form_ptr,OTHER_EXT,&(other));
  value = (double) ISOattributes->crit[page].other;
  FIg_set_state( form_ptr, OTHER_EXT,value);

  return(OM_S_SUCCESS);
}

end implementation VRiso;

