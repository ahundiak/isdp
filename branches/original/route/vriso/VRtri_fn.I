/* $Id: VRtri_fn.I,v 1.1.1.1 2001/01/04 21:12:58 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vriso / VRtri_fn.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRtri_fn.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:58  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.3  1996/01/17  00:29:08  pinnacle
# Replaced: vriso/VRtri_fn.I for:  by r240_int for route240
#
 *
 * History:
 *	01/15/96	tlb	Add VX_FIproto.h, prototypes
 *
 *************************************************************************/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 vriso/VRtri_fn.I
 

 CHANGE HISTORY: Lori 10-27-94  : CR#179306651 Updated TRIFLEXinit
                                  to only initialize defaults file
				  name on the first initialization.
 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
class implementation VRtriflex;

#include <stdio.h>


#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"

#include "triflexdef.h"
#include "big.h"
#include "dbs.h"
#include "VRGlobMac.h"

#include "AS_status.h"

%safe
#include "VX_FIproto.h"
%endsafe

#define AS_DEBUG 1



/**********************************************************************/
/*
/*  TRIFLEXinit: function used to initialize the attributes
/*               to put in the triflex form.
/*
/**********************************************************************/
 TRIFLEXinit(isoform)
 struct ISOform *isoform;
/*.TRIFLEXinit*/
 {
  char		file_name[PATH_MAX];
  int   	status;
  IGRlong	retmsg;

  status= VR$GetUnixPath (      msg             = &retmsg,
                                product_name    = VR_ROUTE_PROD_NAME,
                                file_path       = VR_TRI_KSH_NAME,
                                product_path    = file_name,
                                product_path_len= sizeof (file_name)  );

 if ( !(status&1) )
 {
        printf("status= %d\n",status);
        printf("product Triflex not found\n");
        return OM_E_ABORT;
 }

 /*"TRIFLEX: %s\n",file_name */
  strcpy(isoform->file.design_name,VR_DEFAULT_DESIGN_NAME);

  if ( !(*(isoform->file.default_name)) )
  {	
    strcpy(isoform->file.default_name,file_name);
    strcat(isoform->file.default_name,VR_TRI_DEFAULTS_NAME);
  }
 /*"def_path: %s\n",def_path */


    isoform->crit[0].nb_page = 1;
    strcpy(isoform->crit[0].line_seq_number,"");
    strcpy(isoform->crit[0].block_number,"*");
    strcpy(isoform->crit[0].pds_class,"*");
    strcpy(isoform->crit[0].fluid_text,"*");
    /*isoform->crit[0].fluid_code= -1; */
    isoform->crit[0].other = 0;
 return (OM_S_SUCCESS);
}

/**********************************************************************/
/*
/*  TRIdefault: function used to initialize the attributes
/*                  to put in the triflex form at a given index.
/*
/**********************************************************************/

 TRIdefault (index, isoform)
 struct ISOform *isoform;
 short  index;
/*.TRIdefault*/
 {
    strcpy(isoform->crit[index].line_seq_number,"");
    strcpy(isoform->crit[index].block_number,"*");
    strcpy(isoform->crit[index].pds_class,"*");
    strcpy(isoform->crit[index].fluid_text,"*");
    /*isoform->crit[index].fluid_code= -1; */
 return (OM_S_SUCCESS);
 }

/*********************************************************/

 TRIFLEXupdate(form_ptr,  TRIattributes )
 struct ISOform  *TRIattributes;
 Form            form_ptr;

/*.TRIFLEXupdate*/
{
  extern int FIg_set_value();
  extern int FIfld_set_text();

  int			row=0;
  int			col=0;
  int			sel_flag=0;
  int			page;
  double		value,other;

		              
 FIfld_set_text( form_ptr,DESIGN_FILE, row, col, 
                 TRIattributes->file.design_name, sel_flag );
 
 FIfld_set_text( form_ptr, DEFAULT_FILE, row, col, 
                 TRIattributes->file.default_name, sel_flag );


 page = TRIattributes->index_crit;
 FIfld_set_text( form_ptr, LINE_SEQ_NO, row, col, 
                 TRIattributes->crit[page].line_seq_number, sel_flag );

 FIfld_set_text( form_ptr,PIPING_MAT_CLASS, row, col, 
                 TRIattributes->crit[page].pds_class, sel_flag );

 FIfld_set_text( form_ptr, BLOCK_NO, row, col, 
                 TRIattributes->crit[page].block_number, sel_flag );

 FIfld_set_text( form_ptr, FLUID_TEXT, row, col, 
                 TRIattributes->crit[page].fluid_text, sel_flag );
/*
 ISOset_FLDfluid(form_ptr,TRIattributes->crit[page].fluid_code);
*/
 
 value = (double) TRIattributes->crit[page].nb_page;
 FIfld_set_value( form_ptr,PAGE_NB , row, col, 
                  value, sel_flag );

 FIg_get_value(form_ptr,OTHER_EXT,&(other));
 value = (double) TRIattributes->crit[page].other;
 FIg_set_state( form_ptr, OTHER_EXT,value);

 return (OM_S_SUCCESS);
}



end implementation VRtriflex;



