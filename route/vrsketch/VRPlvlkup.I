/* $Id: VRPlvlkup.I,v 1.9 2002/04/10 20:33:30 louis Exp $ */

/***************************************************************************
 * I/ROUTE
 *
 * File:    vrsketch/VRPlvlkup.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VRPlvlkup.I,v $
 *  Revision 1.9  2002/04/10 20:33:30  louis
 *  tr5649-standardize tolerance
 *
 *  Revision 1.8  2001/04/25 21:00:45  anand
 *  TR JTS MP 5075
 *
 *  Revision 1.7  2001/04/17 23:03:26  anand
 *  JTS TR MP 4485
 *
 *  Revision 1.6  2001/03/16 16:01:06  anand
 *  Put in a qsort call against CR 179901322 rejection.
 *
 *  Revision 1.5  2001/02/20 01:17:11  build
 *  Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *  Revision 1.4  2001/02/11 18:11:32  ahundiak
 *  Renamed VDris2 to VDrisc
 *
 *  Revision 1.3  2001/01/30 18:16:05  anand
 *  JTS CR MP 4118
 *
 *  Revision 1.2  2001/01/16 19:54:16  anand
 *  SP merge
 *
 *
# Revision 1.6  2000/10/16  19:09:36  pinnacle
# ah
#
# Revision 1.5  2000/10/06  13:56:54  pinnacle
# Replaced: route/vrsketch/VRPlvlkup.I for:  by lawaddel for Service Pack
#
# Revision 1.4  2000/06/15  14:39:02  pinnacle
# Replaced: route/vrsketch/VRPlvlkup.I for:  by apazhani for Service Pack
#
# Revision 1.3  2000/06/09  19:20:06  pinnacle
# Replaced: route/vrsketch/VRPlvlkup.I for:  by aharihar for Service Pack
#
# Revision 1.2  2000/05/22  15:27:00  pinnacle
# Replaced: route/vrsketch/VRPlvlkup.I for:  by apazhani for Service Pack
#
# Revision 1.1  2000/05/16  13:59:10  pinnacle
# Created: route/vrsketch/VRPlvlkup.I by apazhani for Service Pack
#
 *
 * Description:
 *    PURPOSE:  Get a part number for a component from the database
 *
 *    This module controls a form that allows the operator to
 *    choose a component directly from the database. The program restricts the
 *    order of selection of component definitions. Up to the selection of size
 *    of the component, the selection criteria can be restarted. If only one
 *    selection of definition is available, the processing will automatically
 *    select the single choice. Thus if only one size and type of valve is in
 *    the database, selecting the "valve" family class will fetch the part
 *    number. Reselecting the same definition will not rebuild the query for
 *    the next field, or any following fields that followed that definition.
 *
 *	FORM_NAME livelook	Enter new location (if changed)
 * Gadget name   Gadget no.
 * SPEC_NAME     11
 * FAMILY_CLASS  13
 * FAMILY_CODE   15
 * COMP_CODE     17
 * OPTION_CODE   19
 * IN_OUT_SIZE   21
 * COMP_NUMBER   25
 * PART_DESCR    22
 *
 * The arguments for use are:
  first_entry - Boolean flag for init processing
  gad_label   - gadget label
  fp          - form pointer
  OB          - Address of struct PipingLiveLookup values.
                This structure includes both control variables and
                return values for piping parts from the database.
 * Note that processing the first entry and storage of values is the
   responsibility of the calling process the design is intended to be called
   from form-notification processing.
 *
 * Dependencies: Driver for VRlvlkfrm form.
 *
 * Revision History:
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *      10/07/97   L. Waddell   CR179308634 - Processing for Livelookup
 *                              for piping parts from the database.
 *
 *      10/07/97   H. Anand	Removed stuff related to piping_spec_eq table,
 *                              implemented cache for DB access, wrote a new
 *                              function VR_IsAlreadyInList for simulating
 *                              'DISTINCT' keyword in SQL for querying cache.
 *      12/01/98   Reddy        TR179800925 - Live lookup form was
 *  				not showing the comonent dimensions in
 *				metric sizes when connected to metric database
 *      07/12/99   L. Waddell   TR179900564 - Equivalent size needed for
 *                              identifying descriptions.
 *      07/22/99   L.Waddell    TR179800615 - reinstalled comp-code filter.
 *      08/09/99   L.Waddell    TR179900783 - Size filters broken
 *      02/24/00   law          tr179900924 - Fixed the size filter again
 *      Mar 2000   Anand	Changed definition of OB to accomodate Rway LLU
 *      05/16/00   Alwin	Modified to fetch only the listed commodities
 *				for the Metric System. TR179900994
 *      05/22/00   Alwin	TR179900964. Modified to fix the errors related
 *				to sorting/displaying metric sizes. 
 *				Cleaned up the code little bit. Checked the 
 *				unfreed memory problem, fixed the selection of
 *				default diameters and added lots of comments.
 *	10/06/00   law		TR179901546-crash in piping livelookup-Unions
 *	01/30/01   Anand	JTS CR MP4118 - Alphabetically sorted lists.
 *      02/11/01   ah           Renamed VDris2.g to VDrisc.h
 *	04/24/01   Anand	JTS TR MP5075 - Regression from 2.6.1 (sorting
 *				algo of 4118 - x&p prblms)!!
 *      04/08/02   law          TR5649-standardize tolerance with VRGetTol
 ************************************************************/

class implementation Root;

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <strings.h>

#include "OMminimum.h"
#include "OMmacros.h"

#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"

#include "FI.h"       /* Forms Include File */
#include "vdbmacros.h"
#include "godef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "vrdbgmacros.h"
#include "vrparameters.h"
#include "VRact_params.h"
#include "exmacros.h"
#include "vrdef.h"
#include "VRMath.h"
#include "VRattr_def.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "parametric.h"

#define DONT_EXTERN	1
#include "VRlivlkup.h"
#undef DONT_EXTERN

#include "VRDbStruct.h"
#include "VDmem.h"
#include "VRDbTbl.h"
#include "VRPDBdef.h"
#include "VRPDBmac.h"
#include "bsparameters.h"
#include "VRDbCache.h"
#include "VRmsg.h"
#include "vrpdu_pto.h"
#include "VDtypedef.h"
#include "VDrisc.h"
#include "VDfrm.h"

from    ACncpx  import          ACgive_structure;
from    ACrg_collect import     ACget_named_attribute;

/************************************************************
  Constants for the form.
 ************************************************************/

#define SPEC_NAME     11
#define FAMILY_CLASS  13
#define FAMILY_CODE   15
#define COMP_CODE     17
#define OPTION_CODE   19
#define IN_OUT_SIZE   21
#define COMP_NUMBER   25
#define PART_DESCR    22

extern struct VRPDB_project   VRGL_PROJ;
extern IGRint                 VRGL_specunit;

/****************************************************************************
   The objective is to control the gadgets from the .I and return the findings
   in the return structure. The "finished" flag signals that the return
   structure has been populated.
****************************************************************************/

int VRPlvlkup(first_entry,gad_label,fp,OB)
struct PipingLiveLookup *OB;
Form fp;  /* Use this variable for the forms functions. */
int first_entry;
int *gad_label;
{
  IGRboolean	VR_IsAlreadyInList(char *,char **,int);

  IGRint 		i, j, err_flg;
  IGRint 		col,row, row_no, row_no1;
  IGRint 		insel_flag, sel_flag, r_pos, rows, rows1;
  IGRint 		status, no_choice, strtin, fldlen;
  IGRint 		no_default, size, ret_size, FootIndex;
  IGRint 		g_label, sts;
  IGRint  		proj_units; 
  IGRint		SortIndex; // Added by Anand for CR MP4118

  IGRshort		NumComp, NumCodeList;
  IGRshort 		no_ranges=0;

  IGRdouble 		gdiadel, rdiadel;
  IGRdouble 		input_dia_val, output_dia_val;
  IGRdouble		active_Rdia, active_Gdia;
  IGRdouble             *dConv_InputDia=NULL, *dConv_OutputDia=NULL;

  IGRlong		msg;
  IGRchar 		**result=NULL, **result1=NULL;
  IGRchar               **strCommodCode=NULL;
  IGRchar 		fldlenstr[2]; 
  IGRchar		input_dia[9], output_dia[9];
  IGRchar 		temp_buff[20], commod_code[21];
  IGRchar		outfld[41], err_msg[41];
  IGRchar 		select_buff[MAX_SELECT_SIZE], query[MAX_WHERE_SIZE];

  struct VRPDB_cdl	*CodeRec=NULL;
  struct VRPDB_comps	*CompPtr=NULL;
  struct VRPDB_ranges   *diameters=NULL;

  struct GRid		TmpId;
  struct GRmd_env	mod_env;     
  struct ret_struct	ParamAttr;

  SetProc( VRPlvlkup ); Begin 

  col = 0;
  status = 1;
  sel_flag = 0;

  g_label = *gad_label;

  ex$get_cur_mod( osnum = &TmpId.osnum );
  __DBGpr_int( " OSNUM ", TmpId.osnum );

  TmpId.objid = NULL_OBJID;
  VR$active_params( operation     = VR_RETRIEVE,
		    VRproduct     = VR_PIPING,
		    act_param_id  = &TmpId,
		    status        = status );

  size = sizeof(mod_env);
  gr$get_module_env( msg    = &msg,
		     sizbuf = &size,
		     buffer = &mod_env,
		     nret   = &ret_size );

  om$send( msg     = message ACncpx.ACgive_structure
			 ( (IGRint*)&msg, &FootIndex, VR_N_RDIAMETER_DB, 
			 &ParamAttr, &mod_env),
	  senderid = NULL_OBJID,
	  targetid = TmpId.objid,
	  targetos = TmpId.osnum );
  active_Rdia = ParamAttr.var.root_pm_st.value;
  __DBGpr_dbl( " ACTIVE R-Diameter ", active_Rdia );

  om$send( msg      = message ACncpx.ACgive_structure
			  ( (IGRint*)&msg, &FootIndex, VR_N_GDIAMETER_DB, 
			  &ParamAttr, &mod_env),
	   senderid = NULL_OBJID,
	   targetid = TmpId.objid,
	   targetos = TmpId.osnum );
  active_Gdia = ParamAttr.var.root_pm_st.value;
  __DBGpr_dbl( " ACTIVE G-Diameter ", active_Gdia );

  /* If first entry, setup defaults */
  if( first_entry )
  {
     IGRchar 	*SpecList=NULL;
     IGRchar	default_spec[10];

     /******** Define default spec and sizes **********/
      om$send( msg      = message ACncpx.ACgive_structure
		       ( (IGRint*)&msg, &FootIndex, VR_N_CLASS_AN, 
		       &ParamAttr, &mod_env),
		 senderid = NULL_OBJID,
		 targetid = TmpId.objid,
		 targetos = TmpId.osnum );
      strcpy( default_spec, ParamAttr.var.text_st.text_string );
      __DBGpr_str( " Active Spec Name ", default_spec );

      status = FIg_set_text ( fp, SPEC_NAME, default_spec );

     /* Build the query to get the spec_names in the database .*/
     __DBGpr_com(" About to call VRget_spec_list");
     rows = 0;
     status = VRget_spec_list ( &msg, VR_PIPING,
			(IGRshort *)&rows, &SpecList, NULL);

     __DBGpr_int(" No of elements in spec list", rows);

     /******************** Start the Form Population ******************/
     /* Stack the associative list */
     FIfld_set_list_num_rows(fp,SPEC_NAME,col,rows);
     sel_flag = 0;

     for( row_no=0; row_no<rows; row_no++ )
     {
       if(!strcmp( default_spec, &SpecList[row_no*VR_MAX_SPEC_NAME_LEN]))
	   sel_flag=1;
       else
	   sel_flag=0;
       FIfld_set_list_text( fp, SPEC_NAME, row_no, col, 
			     (IGRuchar*)&SpecList[row_no*VR_MAX_SPEC_NAME_LEN], 
			     sel_flag);
     }

     /* Set the processing order filters */
     OB->not_proc_spec   = 0;
     OB->not_proc_fam_cl = 1;
     OB->not_proc_fam_cd  = 1;
     OB->not_proc_cmp_cd = 1;
     OB->not_proc_opt_cd = 1;
     OB->not_proc_size = 1;

     g_label = SPEC_NAME;

     /************************************************************
      Loop until the user presses the cancel or accept buttons.
     ************************************************************/

     status=FIg_disable(fp,FAMILY_CLASS);
     status=FIg_disable(fp,FAMILY_CODE);
     status=FIg_disable(fp,COMP_CODE);
     status=FIg_disable(fp,OPTION_CODE);
     status=FIg_disable(fp,IN_OUT_SIZE);
     status=FIg_disable(fp,COMP_NUMBER);
     status=FIg_disable(fp,FI_ACCEPT);
     FIfld_set_num_rows(fp,FAMILY_CODE,0);
     FIfld_set_num_rows(fp,COMP_CODE,0);
     FIfld_set_num_rows(fp,OPTION_CODE,0);
     FIfld_set_list_num_rows(fp,IN_OUT_SIZE,col,0);
     status = FIg_set_text ( fp, IN_OUT_SIZE,"" );
     status = FIg_set_text ( fp, PART_DESCR,"" );
     status = FIg_set_text ( fp, COMP_NUMBER,"" );
  } /* End first entry */

  /* Move the not done loop to the calling routine */
  no_choice = TRUE;
  while (no_choice )
  {
	 IGRboolean		default_dia_found;
	 IGRint 		text_size, proj_no, tot_no_rows;
	 IGRint                 nConvArraySize=0, k;
	 IGRdouble 		SIZE_1,SIZE_2;
	 IGRchar 		catalog_name[VRPDB_CHAR_FAM];
	 IGRchar 		part_desc[41];

	 /* Determine which gadget was manipulated */
	 err_flg = 0;
	 switch ( g_label )
	 {
		case FI_CANCEL:     /* Member of group FI_CTRL_GROUP */

		   /* Erase the displayed form */
		   OB->not_proc_spec   = 1;
		   OB->not_proc_fam_cl = 1;
		   OB->not_proc_fam_cd  = 1;
		   OB->not_proc_cmp_cd = 1;
		   OB->not_proc_opt_cd = 1;
		   OB->not_proc_size = 1;

	   	End
		return (status);

		case FI_ACCEPT:     /* Member of group FI_CTRL_GROUP */

		   /* Erase the displayed form */
		   no_choice = 0;
		   break;

		case SPEC_NAME:  /* Sequenced to FAMILY_CLASS    */
				 /* Field Type:    ASCII    */

	       /* Below lines added by Anand for CR179901322 */
		{
		    IGRchar		*SpecList=NULL;
		    IGRint		nSpec=0;
		    IGRint 		NewListCnt=0, SelIndex=-1;
		    IGRint 		SelFlag=0, UniqueFlg=0;
		    IGRshort		temp=0;


		    /*| -- Get Spec Name List */
		    status = VRget_spec_list ( &msg, VR_PIPING,
						(IGRshort *) &nSpec, 
						&SpecList, NULL);
		    __CheckRC(status, msg, "VRget_spec_list failed!", quit);

		    qsort( SpecList, nSpec, VR_MAX_SPEC_NAME_LEN, strcmp );

		    __DBGpr_int("No. of Specs from DB",nSpec);

	/* Filter the DB ( Original ) Spec list as needed for the user */
		    status = VDfrm_fld_set_sub_list(fp, g_label, -1, SpecList,
						    VR_MAX_SPEC_NAME_LEN,
						    nSpec, &NewListCnt, 0,
						    &SelIndex, &UniqueFlg );

		    __DBGpr_int( " Unique Flag ", UniqueFlg );

		    if( UniqueFlg == 1 )
		    {
			/* Unique match has been found out of User Keyed in
			 * string, so we need to proceed further. */

			FIfld_get_text_length( fp, g_label, 0, 0, &text_size );
			status = FIfld_get_text( fp, g_label,0,0,text_size, 
					  	 (IGRuchar *) OB->spec_nam_txt,
						 &insel_flag,&r_pos);
			__DBGpr_str( " Selected Spec ",OB->spec_nam_txt);

		    }
		    else
		    {
			__DBGpr_com(" User yet to identify unique spec");
			End
			return status;
		    }
	       /* Above lines added by Anand for CR179901322 */

		   /* Use Spec_name to get spec_no */
		VR$PDB_SNUM ( p_nam = OB->spec_nam_txt,
			p_num = &temp );

		sprintf( OB->spec_no_str, "%d", temp);

		sprintf( OB->list_nm_str,"380");
		}


/* 380 is the list_num where Family class names have been provided. This
  overcomes the need to have piping_spec_eq to implement the LLP - Anand */

	   status = VR$PDB_CDL( p_msg = &msg ,
				nlist = 380 ,
				p_num = &NumCodeList );
	   
	   __DBGpr_int(" NumCodeList ->380 (1)",NumCodeList);

	   if( NumCodeList > 0 )
	   {
		 CodeRec = _CALLOC( NumCodeList, struct VRPDB_cdl );
		 
		 status = VR$PDB_CDL(     p_msg = &msg ,
					  nlist = 380 ,
					  p_num = &NumCodeList ,
					  p_rec = CodeRec );

		 __DBGpr_int(" NumCodeList ->380 (2)",NumCodeList);

		 if( !(status & OM_S_SUCCESS)|| (msg != MSSUCC) || (CodeRec == NULL) )
		 {
			__DBGpr_com(" Failed cache access for codelist 380");
			End
			return (status);
		 }
	   }
	   else
	   {
		 __DBGpr_com(" FAILED CACHE ACCESS FOR CODELIST 380");
		 End
		 return(status);
	   }

	   /* CompPtr is made to point to the cache. So, confine its
	  scope only as long as is required. DO NOT FREE CompPtr */
	   {
		__DBGpr_str(" Spec String in OB",OB->spec_no_str);

		VR$PDB_SET ( p_msg = &msg ,
				 spec  = atoi(OB->spec_no_str));
		__DBGpr_str(" Spec String in OB",OB->spec_no_str);
		status=VR$PDA_COMP(p_num = &NumComp, p_ptr = &CompPtr);

		if( (!status & OM_S_SUCCESS) || CompPtr == NULL )
		{
			__DBGpr_com(" CACHE ACCESS FOR PIPING COMPS FAILED");
			End
			return(status);
		}

		for( i=0 , rows=0 ; i <=NumCodeList-1  ; i=i+1 )
		{
		/*filter through family classes to get unique set of families */
		/* As found unique, put in associative list of family class */

		   if( VR_IsAlreadyInList( CodeRec[i].stxt , result , rows ) )
		       continue;

		/* To make the items in the associative list of family class
		   dependent upon the spec, compare code_num against family_code
		   of piping_comps - Anand */

		   __DBGpr_int(" codenum",CodeRec[i].ncode);
		   for( row_no=0 ; row_no<NumComp ; row_no++ )
		   {
		   if( CodeRec[i].ncode == CompPtr[row_no].data.famcode ) break;

		      while ( ( CompPtr[row_no].data.famcode == 
				CompPtr[row_no+1].data.famcode ) && 
			      ( row_no < NumComp-1 ) 
			    ) row_no++;
		   }
		   if( row_no == NumComp ) continue;

		   if( rows==0 )
		   {
		       result = _CALLOC( 1 , char * );
		       result[0] = _CALLOC(VRPDB_CHAR_STXT,char );
		       strcpy( result[0] , CodeRec[i].stxt );
		   }
		   else
		   {
		       IGRboolean	bFoundPlace=FALSE;

		       result = _REALLOC( result , rows+1 , char * );
		       result[rows]= _CALLOC(VRPDB_CHAR_STXT,char );

		       /* Below lines added by Anand for CR MP4118 */
		       for( SortIndex=rows ; SortIndex>0 ; SortIndex-- )
		       {
			   /* Put the new entry in its sorted location */
			   if( strcmp( CodeRec[i].stxt,
				       result[SortIndex-1] ) > 0 )
			   {
			       strcpy(result[SortIndex],CodeRec[i].stxt);
			       bFoundPlace=TRUE;
			       break;
			   }
			   else
			       strcpy(result[SortIndex],result[SortIndex-1]);
		       }
		       if( bFoundPlace == FALSE )
			   strcpy( result[0] , CodeRec[i].stxt );
		       /* Above lines added by Anand for CR MP4118 */
		   }
		   rows ++ ;

		   __DBGpr_str(" result",result[rows-1]);
		} //for i loop ends

		__DBGpr_int(" Final NumCodelist", rows);
		__DBGpr_int(" Original Num", NumCodeList);

		_FREE( CodeRec );
	   }

	   /********** populate the next list **********/

	   FIfld_set_num_rows(fp,FAMILY_CLASS,rows);
	   if(rows == 1) sel_flag = 1;
	   else 	 sel_flag = 0;

	   for (row_no = 0;row_no < rows; row_no = row_no + 1)
		  FIfld_set_text(fp, FAMILY_CLASS, row_no, col, 
						result[row_no],sel_flag);

	   if(rows > 0)
	   {
		  OB->not_proc_spec   = 0;
		  status=FIg_enable(fp,FAMILY_CLASS);
		  vdb$RisFreeBuffer (  buffer  =    result,
				       size    =    rows);
	   }
	   if(rows == 1)
	   {
		 g_label = FAMILY_CLASS;
		 no_choice = 1;
	   }
	   else if (rows > 1)
	   {
		 no_choice = 0; 
		 break; /* Note that the break is conditional */
	   }
	   else
	   {
		 OB->not_proc_spec   = 1;
		 status = FIg_set_text ( fp, SPEC_NAME,"" );
		 err_flg = 1;
		 no_choice = 0;
		 status=FIg_disable(fp,FAMILY_CLASS);
		 FIfld_set_num_rows(fp,FAMILY_CLASS,0);
		 strcpy(err_msg,"This spec has NO Family Classes");
	   }


		   OB->not_proc_fam_cl = 1;
		   OB->not_proc_fam_cd  = 1;
		   OB->not_proc_cmp_cd = 1;
		   OB->not_proc_opt_cd = 1;
		   OB->not_proc_size = 1;

		   FIfld_set_num_rows(fp,FAMILY_CODE,0);
		   FIfld_set_num_rows(fp,COMP_CODE,0);
		   FIfld_set_num_rows(fp,OPTION_CODE,0);
		   FIfld_set_list_num_rows(fp,IN_OUT_SIZE,col,0);

		   status = FIg_set_text ( fp, IN_OUT_SIZE,"" );
		   status = FIg_set_text ( fp, PART_DESCR,"" );
		   status = FIg_set_text ( fp, COMP_NUMBER,"" );

		   status=FIg_disable(fp,FAMILY_CODE);
		   status=FIg_disable(fp,COMP_CODE);
		   status=FIg_disable(fp,OPTION_CODE);
		   status=FIg_disable(fp,IN_OUT_SIZE);
		   status=FIg_disable(fp,COMP_NUMBER);
		   status=FIg_disable(fp,FI_ACCEPT);


		case FAMILY_CLASS: /* Sequenced to FAMILY_CODE  */
				   /* Field Type:    ASCII    */
		   if(OB->not_proc_spec)
		   {
		       /* Put out error message of last process and get out */
		       err_flg = 1;
		       strcpy(err_msg,"SPEC NAME must be defined");
		       break;
		   }
		   
		   /* Get the text string */
		   FIfld_get_active_row(fp,g_label,&row,&r_pos);
		   FIfld_get_text_length( fp, g_label, row, 0, &text_size );
		   status = FIfld_get_text ( fp, g_label,row,0,text_size, 
		   (IGRuchar*)OB->loc_fam_class,&insel_flag,&r_pos);

		   __DBGpr_str(" Family class selected",OB->loc_fam_class);

		   if ( status != FI_SUCCESS )
		   {
			  End
			  return(status);
		   }

		   /* Code to process text string "text" */
		   /* Process Family class to get family code lists*/
		   /* Build the query to get the family_code in the database  */


	   status = VR$PDB_CDL( p_msg = &msg ,
				nlist = 380 ,
				p_num = &NumCodeList );
	   
	   __DBGpr_int(" NumCodeList (1)",NumCodeList);

	   if( NumCodeList > 0 )
	   {
	   CodeRec = _CALLOC( NumCodeList, struct VRPDB_cdl );
	   
	   status = VR$PDB_CDL(     p_msg = &msg ,
					nlist = 380 ,
					p_num = &NumCodeList ,
					p_rec = CodeRec );

	   __DBGpr_int(" NumCodeList (2)",NumCodeList);

	   if(!(status & OM_S_SUCCESS)||msg != MSSUCC||CodeRec == NULL)
	   {
		  __DBGpr_com(" Failed cache access for codelist 380");
		  End
		  return (status);
	   }
	   }
	   else if( NumCodeList <= 0 )
	   {
	   __DBGpr_com(" FAILED CACHE ACCESS FOR CODELIST 380");
	   End
	   return(status);
	   }

	   __DBGpr_str(" Spec String in OB",OB->spec_no_str);

	   VR$PDB_SET ( 	p_msg = &msg ,
			 spec  = atoi(OB->spec_no_str));

	   CompPtr = NULL;
	   status= VR$PDA_COMP(	p_num = &NumComp, 
				 p_ptr = &CompPtr);

	   if( (!status & OM_S_SUCCESS) || CompPtr == NULL )
	   {
	    __DBGpr_com(" CACHE ACCESS FOR PIPING COMPS FAILED");
	      End
	      return(status);
	   }

	   __DBGpr_int("NumComp",NumComp);

	   for( i=0 , rows=0 ; i <=NumCodeList-1  ; i=i+1 )
	   {
	   IGRint comp_code_notOK;
	    __DBGpr_str(" Long txt in cache",CodeRec[i].ltxt);
	    __DBGpr_str(" short txt",CodeRec[i].stxt);
	    __DBGpr_str(" Fam class in OB",OB->loc_fam_class);
	    __DBGpr_int(" No rows in list",rows);

	    if(   VR_IsAlreadyInList( CodeRec[i].ltxt , result , rows )
		   || strcmp( CodeRec[i].stxt , OB->loc_fam_class) )
		   continue;

	    /* For each unique family_code, check if a compcode exists*/
	    comp_code_notOK = 1;
	    for(j=0;(j<NumComp && comp_code_notOK); j++)
	    {
	       if(CompPtr[j].data.famcode == CodeRec[i].ncode)
	       {
		   if(CompPtr[j].key.comp_code[0] != '\0')
		   {
		       comp_code_notOK = 0;
		       __DBGpr_str("comp_code found for",CodeRec[i].ltxt);
		   }
	       }
	    }

	    if( comp_code_notOK )
	    {
		__DBGpr_str("no comp_code found for",CodeRec[i].ltxt);
	    	continue;
	    }

	    if( rows == 0)
	    {
		result    = _CALLOC( 1 , char * );
		result[0] = _CALLOC( VRPDB_CHAR_LTXT , char );
		strcpy( result[0] , CodeRec[i].ltxt );
	    }
	    else
	    {
		IGRboolean	bFoundPlace=FALSE;

		result = _REALLOC( result , rows+1 , char *);
		result[rows]=_CALLOC(VRPDB_CHAR_LTXT,char );

		/* Below lines added by Anand for CR MP4118 */
		for( SortIndex=rows ; SortIndex>0 ; SortIndex-- )
		{
		    /* Put the new entry in its sorted location */
		    if( strcmp( CodeRec[i].ltxt,
				result[SortIndex-1] ) > 0 )
		    {
			strcpy( result[SortIndex] , CodeRec[i].ltxt );
			bFoundPlace=TRUE;
			break;
		    }
		    else
			strcpy( result[SortIndex] , result[SortIndex-1] );
		}
		if( bFoundPlace == FALSE )
		    strcpy( result[0] , CodeRec[i].ltxt );
		/* Above lines added by Anand for CR MP4118 */
	    }
	    rows ++ ;

	    __DBGpr_str(" result",result[rows-1]);

	   }
	   __DBGpr_int(" Final long text - NumCodelist", rows);

	   _FREE( CodeRec );


	   if ( status != 1 )
	   {
		  End
		  return(status);
	   }
	   /* Make the query */
	   if(rows == 1)
		 sel_flag = 1;
	   else
		 sel_flag = 0;
	   FIfld_set_num_rows(fp,FAMILY_CODE,rows);
	   for (row_no = 0;row_no < rows; row_no = row_no + 1)
	   {
		FIfld_set_text(fp,FAMILY_CODE,row_no,col, 
				result[row_no],sel_flag);
	   }
	   FIfld_set_num_rows(fp,COMP_CODE,0);
	   FIfld_set_num_rows(fp,OPTION_CODE,0);
	   FIfld_set_num_rows(fp,IN_OUT_SIZE,0);

	   status = FIg_set_text ( fp, IN_OUT_SIZE,"" );
	   status = FIg_set_text ( fp, PART_DESCR,"" );
	   status = FIg_set_text ( fp, COMP_NUMBER,"" );

	   status=FIg_disable(fp,COMP_CODE);
	   status=FIg_disable(fp,OPTION_CODE);
	   status=FIg_disable(fp,IN_OUT_SIZE);
	   status=FIg_disable(fp,COMP_NUMBER);
	   status=FIg_disable(fp,FI_ACCEPT);

	   if(rows > 0)
	   {
		  status=FIg_enable(fp,FAMILY_CODE);
		  vdb$RisFreeBuffer (   buffer  =    result,
					size    =    rows);
		  OB->not_proc_fam_cl = 0;
		  OB->not_proc_fam_cd = 1;
		  OB->not_proc_cmp_cd = 1;
		  OB->not_proc_opt_cd = 1;
		  OB->not_proc_size = 1;
	   }
	   if(rows == 1)
	   {
		  g_label = FAMILY_CODE;
		  no_choice = 1;
	   }
	   else if(rows > 1)
	   { 
		  no_choice = 0;
		  break; /* Note that the break is conditional */
	   }
	   else
	   {
	     OB->not_proc_fam_cl = 1;
	     err_flg=1;
	     strcpy(err_msg,"No family codes for this family class");
	     FIfld_get_active_row(fp,FAMILY_CLASS,&row,&r_pos);
		     status = FIfld_set_select ( fp, FAMILY_CLASS,row,col,0 );
		     status=FIg_disable(fp,FAMILY_CODE);
		     no_choice = 0;
		     break;
	   }

	   case FAMILY_CODE:     /* Sequenced to COMP_CODE    */
				 /* Field Type:    ASCII    */

		   if(OB->not_proc_fam_cl)
		   {
			  /*Put out error message of last process and get out */
			  err_flg = 1;
			  strcpy(err_msg,"FAMILY CLASS must be defined");
			  break;
		   }

		   /* Get the text string */
		   FIfld_get_active_row(fp,g_label,&row,&r_pos);

		   FIfld_get_text_length( fp, g_label, row, 0, &text_size );
		   status = FIfld_get_text ( fp, g_label,row,0,text_size, 
				(IGRuchar*)OB->loc_fam_code,&insel_flag,&r_pos);

		   if ( status != FI_SUCCESS )
		   {
			  End
			  return(status);
		   }
		   /* Process Family class to get family code lists*/

	   status = VR$PDB_CDL( p_msg = &msg ,
				nlist = 380 ,
				p_num = &NumCodeList );

	   __DBGpr_int(" NumCodeList (1)",NumCodeList);

	   if( NumCodeList > 0 )
	   {
	   CodeRec = _CALLOC( NumCodeList, struct VRPDB_cdl );

	   status = VR$PDB_CDL(     p_msg = &msg ,
					nlist = 380 ,
					p_num = &NumCodeList ,
					p_rec = CodeRec );

	   __DBGpr_int(" NumCodeList (2)",NumCodeList);

	   if(!(status & OM_S_SUCCESS)||msg != MSSUCC||CodeRec == NULL)
	   {
		  __DBGpr_com(" Failed cache access for codelist 380");
		  End
		  return (status);
	   }
	   }
	   else if( NumCodeList <= 0 )
	   {
	   __DBGpr_com(" FAILED CACHE ACCESS FOR CODELIST 380");
	   End
	   return(status);
	   }


	   for( i=0 ; i < NumCodeList ; i=i+1 )
	   {
	  if(  !strcmp( CodeRec[i].stxt , OB->loc_fam_class ) && 
		   !strcmp( CodeRec[i].ltxt , OB->loc_fam_code) )
	  {
		   sprintf(OB->loc_code_nm,"%d", CodeRec[i].ncode);
		   break;
	  }
	   }

	   _FREE( CodeRec );


		   /* Code to process text string "text" */
		   /* Build the query to get the family_code in the database  */
		   /* Make the query */
	  __DBGpr_str(" Spec String in OB",OB->spec_no_str);

	  VR$PDB_SET (  p_msg = &msg ,
			spec  = atoi(OB->spec_no_str));

	  CompPtr = NULL;
	  status=VR$PDA_COMP(p_num = &NumComp, p_ptr = &CompPtr);

	  if( (!status & OM_S_SUCCESS) || CompPtr == NULL )
	  {
		  __DBGpr_com(" CACHE ACCESS FOR PIPING COMPS FAILED");
		  End
		  return(status);
	  }

	  __DBGpr_int("NumComp",NumComp);

	  for( i=0 , rows=0 ; i <=NumComp-1  ; i=i+1 )
	  {
	      __DBGpr_int(" Index, i",i);
	      __DBGpr_int(" Family code",CompPtr[i].data.famcode);
	      __DBGpr_int(" OB's loc code",atoi(OB->loc_code_nm) );
	      __DBGpr_str(" Comp Code",CompPtr[i].key.comp_code);

	      if(    VR_IsAlreadyInList( CompPtr[i].key.comp_code ,
								result , rows )
		  || CompPtr[i].data.famcode != atoi(OB->loc_code_nm) )
		  continue;

	      if( rows == 0 )
	      {
		  result    = _CALLOC( 1 , char * );
		  /*** comp_code only has 6 characters & key.comp_code has 8 */
		  result[0] = _CALLOC( VRPDB_CHAR_CODE , char );
		  strcpy( result[0] , CompPtr[i].key.comp_code );
	      }
	      else
	      {
		  IGRboolean	bFoundPlace=FALSE;

		  result = _REALLOC( result , rows+1 , char * );
		  /*** comp_code only has 6 characters & key.comp_code has 8 */
		  result[rows]=_CALLOC(VRPDB_CHAR_CODE,char );

		  /* Below lines added by Anand for CR MP4118 */
		  for( SortIndex=rows ; SortIndex>0 ; SortIndex-- )
		  {
		      /* Put the new entry in its sorted location */
		      if( strcmp( CompPtr[i].key.comp_code,
				  result[SortIndex-1] ) > 0 )
		      {
			  strcpy( result[SortIndex], CompPtr[i].key.comp_code );
			  bFoundPlace=TRUE;
			  break;
		      }
		      else
			  strcpy( result[SortIndex], result[SortIndex-1] );
		  }
		  if( bFoundPlace == FALSE )
		      strcpy( result[0] , CompPtr[i].key.comp_code );
		  /* Above lines added by Anand for CR MP4118 */
	      }
	      rows ++ ;


	      __DBGpr_str(" result",result[rows]);

	  }
	  __DBGpr_int(" Num of distinct comp codes",rows);

		   FIfld_set_num_rows(fp,OPTION_CODE,0);
		   FIfld_set_list_num_rows(fp,IN_OUT_SIZE,col,0);
		   status = FIg_set_text ( fp, IN_OUT_SIZE,"" );
		   status = FIg_set_text ( fp, PART_DESCR,"" );
		   status = FIg_set_text ( fp, COMP_NUMBER,"" );

		   status=FIg_disable(fp,OPTION_CODE);
		   status=FIg_disable(fp,IN_OUT_SIZE);
		   status=FIg_disable(fp,COMP_NUMBER);
		   status=FIg_disable(fp,FI_ACCEPT);
		   if(rows == 1)
			  sel_flag = 1;
		   else
			  sel_flag = 0;

		   FIfld_set_num_rows(fp,COMP_CODE,rows);
		   for (row_no = 0;row_no < rows; row_no = row_no + 1)
		   {
		  	FIfld_set_text(fp,COMP_CODE,row_no,col,
				result[row_no],sel_flag);
		   }
		   if(rows > 0)
		   {
			  OB->not_proc_fam_cd  = 0;
			  status=FIg_enable(fp,COMP_CODE);
			  vdb$RisFreeBuffer (   buffer  =    result,
						size    =    rows);
		   }
		   /* Process family class to get family code */
		   OB->not_proc_cmp_cd = 1;
		   OB->not_proc_opt_cd = 1;
		   OB->not_proc_size = 1;
		   if(rows == 1)
		   {
			  g_label = COMP_CODE;
			  no_choice = 1;
		   }
		   else if(rows > 1)
		   {
			  no_choice = 0;
			  break; /* Note that the break is conditional */
		   }
		   else
		   {
			  status=FIg_disable(fp,COMP_CODE);
			  OB->not_proc_fam_cd  = 1;
			  err_flg=1;
			  strcpy(err_msg,"No comp-codes for this family code");
			  g_label = FAMILY_CLASS;
			  FIfld_get_active_row(fp,g_label,&row,&r_pos);
			  status = FIfld_set_select ( fp,g_label,row,col,0 );
			  FIfld_set_num_rows(fp,COMP_CODE,0);
			  no_choice = 0;
			  break;
		   }
		case COMP_CODE: 	/* Sequenced to OPTION_CODE    */
					/* Field Type:    ASCII    */

		   if(OB->not_proc_fam_cd)
		   {
			 /* Put out error message of last process and get out */
			  err_flg = 1;
			  strcpy(err_msg,"FAMILY CODE must be defined");
			  break;
		   }
		   /* Get the text string */
		   FIfld_get_active_row(fp,g_label,&row,&r_pos);
		   FIfld_get_text_length( fp, g_label, row, 0, &text_size );
		   status = FIfld_get_text ( fp, g_label,row,0,text_size, 
				(IGRuchar*)OB->loc_cmp_code,&insel_flag,&r_pos);

		   if ( status != FI_SUCCESS )
		   {
			  End
			  return(status);
		   }
		   /* Code to process text string "text" */
		   /* Use COMP_CODE to get list of option codes */

		   /* Build the query to get the option_code in the database  */
		   /* and make the query */

		   /* Build list of option_codes */

	   /* Access piping_codelist for list_num=400 (thru cache) so that
		  you fill the option_code list with the long_txt corresponding
	  to code_num being opt_code in piping_comps. */


	   status = VR$PDB_CDL( p_msg = &msg ,
				nlist = 400 ,
				p_num = &NumCodeList );

	   if( NumCodeList > 0 )
	   {
	   CodeRec = _CALLOC( NumCodeList, struct VRPDB_cdl );
	   
	   status = VR$PDB_CDL(     p_msg = &msg ,
					nlist = 400 ,
					p_num = &NumCodeList ,
					p_rec = CodeRec );

	   if(!(status & OM_S_SUCCESS)||msg!=MSSUCC||CodeRec==NULL)
	   {
		  __DBGpr_com(" Failed cache access for codelist 400");
		  End
		  return (status);
	   }
	   }
	   else if(NumCodeList <= 0)
	   {
	   __DBGpr_com(" FAILED CACHE ACCESS FOR CODELIST 400");
	   End
	   return(status);
	   }

	   /* Access Piping Comps thru Cache */

	   {

	  __DBGpr_str(" spec string in ob", OB->spec_no_str );

	  VR$PDB_SET ( p_msg = &msg ,
			   spec  = atoi(OB->spec_no_str));

	  CompPtr = NULL;
	  status=VR$PDA_COMP(p_num = &NumComp, p_ptr = &CompPtr);

	  if( (!status & OM_S_SUCCESS) || CompPtr == NULL )
	  {
		  __DBGpr_com(" CACHE ACCESS FOR PIPING COMPS FAILED");
		  End
		  return(status);
	  }

	  __DBGpr_int("NumComp",NumComp);

	   /* process CompPtr to retrieve distinct opt_codes, check if
		  family code in piping_comps is equal to chosen code_num,
		  and proceed to populate the option code list in the form.
	   */

	  for( i=0 , rows=0 ; i <=NumComp-1  ; i=i+1 )
	  {
	      if( CompPtr[i].data.famcode != atoi(OB->loc_code_nm) )
		  continue;

	      for( rows1=0 ; rows1 < NumCodeList ; rows1=rows1+1 )
	      {
		  IGRboolean	bFoundPlace=FALSE;

		  if( CodeRec[rows1].ncode != CompPtr[i].key.option ||
		      VR_IsAlreadyInList(CodeRec[rows1].ltxt, result, rows) )
		  continue;

		  if( rows == 0 )
		  {
		      result = _CALLOC ( 1 , char * );
		      result[0]=_CALLOC( VRPDB_CHAR_LTXT , char );
		      strcpy( result[0] , CodeRec[rows1].ltxt );
		  }
		  else
		  {
		      result = _REALLOC( result , rows+1 , char * );
		      result[rows]=_CALLOC( VRPDB_CHAR_LTXT , char );

		      /* Below lines added by Anand for CR MP4118 */
		      for( SortIndex=rows ; SortIndex>0 ; SortIndex-- )
		      {
			  /* Put the new entry in its sorted location */
			  if( strcmp( CodeRec[rows1].ltxt,
				      result[SortIndex-1] ) > 0 )
			  {
			      strcpy( result[SortIndex], CodeRec[rows1].ltxt );
			      bFoundPlace=TRUE;
			      break; // breaks out of for(SortIndex=...) loop
			  }
			  else
			      strcpy( result[SortIndex], result[SortIndex-1] );
		      }
		      if( bFoundPlace == FALSE )
			  strcpy( result[0] , CodeRec[rows1].ltxt );
		      /* Above lines added by Anand for CR MP4118 */
		  }
		  rows ++ ;
		  break; // breaks out of for(rows1=0;...) loop
	      }
	  }

	  /* Fill up the form */
	  FIfld_set_num_rows( fp, OPTION_CODE, rows );
	  for( i=0 ; i<rows ; i++ )
	  {
	      if( !strcmp( result[i], "DEFAULT" ) )
	      {
		  FIfld_set_active_row( fp, OPTION_CODE, rows, 0 );
		  sel_flag = 1;
	      }
	      else
		  sel_flag = 0;
	      FIfld_set_text( fp, OPTION_CODE, i, col, result[i], sel_flag );
	  }

	  if(rows > 0)
	  {
		 vdb$RisFreeBuffer (  buffer  =    result,
				      size    =    rows);
	  }
	  __DBGpr_int(" Num of distinct option codes",rows);

	  _FREE( CodeRec );
	   }

		   status=FIg_disable(fp,IN_OUT_SIZE);
		   status=FIg_disable(fp,COMP_NUMBER);
		   status=FIg_disable(fp,FI_ACCEPT);

		   FIfld_set_list_num_rows(fp,IN_OUT_SIZE,col,0);

		   status = FIg_set_text ( fp, IN_OUT_SIZE,"" );
		   status = FIg_set_text ( fp, PART_DESCR,"" );
		   status = FIg_set_text ( fp, COMP_NUMBER,"" );

		   if(rows > 0)
		   {
			  OB->not_proc_cmp_cd = 0;
			  status=FIg_enable(fp,OPTION_CODE);
		   }

		   OB->not_proc_opt_cd = 1;
		   OB->not_proc_size = 1;
		   if(rows == 1)
		   {
			  g_label = OPTION_CODE;
			  no_choice = 1;
		   }
		   else if(rows > 1)
		   {
			  no_choice = 0;
			  break; /* Note that the break is conditional */
		   }
		   else
		   {
			  status=FIg_disable(fp,OPTION_CODE);
			  OB->not_proc_cmp_cd = 1;
			  err_flg=1;
			  strcpy(err_msg,"No option codes for this comp code");
			  g_label = COMP_CODE;
			  FIfld_get_active_row(fp,g_label,&row,&r_pos);
			  status = FIfld_set_select ( fp,g_label,row,col,0 );
			  FIfld_set_num_rows(fp,OPTION_CODE,0);
			  no_choice = 0;
			  break;
		   }

	case OPTION_CODE: /* Sequenced to IN_OUT_SIZE    */
			  /* Field Type:    INTEGER    */
	    if(OB->not_proc_cmp_cd)
	    {
		   /* Put out error message of last process and get out */
		   err_flg = 1;
		   strcpy(err_msg,"COMP CODE must be defined");
		   break;
	    }
	    /* Get the value of the current active row */

	    /* Get the text string */
	    FIfld_get_active_row(fp,g_label,&row,&r_pos);
	    FIfld_get_text_length( fp, g_label, row, 0, &text_size );
	    status = FIfld_get_text ( fp, g_label,row,0,text_size, 
			 (IGRuchar*)OB->opt_code_des,&insel_flag,&r_pos);
	    if ( status != FI_SUCCESS ) /* Field Type:    ASCII    */
	    {
		    no_choice = 0;
		    break;
	    }
	   /* Feed the text back to get the number */


	   status = VR$PDB_CDL( p_msg = &msg ,
				nlist = 400 ,
				p_num = &NumCodeList );

	   if( NumCodeList > 0 )
	   {
	      CodeRec = _CALLOC( NumCodeList, struct VRPDB_cdl );

	      status = VR$PDB_CDL(     p_msg = &msg ,
					   nlist = 400 ,
					   p_num = &NumCodeList ,
					   p_rec = CodeRec );

	      if(!(status & OM_S_SUCCESS)||msg!=MSSUCC||CodeRec==NULL)
	      {
		     __DBGpr_com(" Failed cache access for codelist 400");
		     End
		     return (status);
	      }
	   }
	   else if(NumCodeList <= 0) 
	   {
	      __DBGpr_com(" FAILED CACHE ACCESS FOR CODELIST 400");
	      End
	      return(status);
	   }

	   for( i=0 ; i < NumCodeList ; i=i+1 )
	   {
	       if( ! strcmp( OB->opt_code_des , CodeRec[i].ltxt ) )
	       {
		       sprintf(OB->opt_code_num,"%d",CodeRec[i].ncode);
		       break;
	       }
	   }
	   _FREE( CodeRec );

	 /*** INSERT THE EXTRA QUERY STATEMENTS HERE. ALWIN ****/
	 /* This is the place, before enabling the size's gadgets we need 
	 ensure the following ...

	 STEP 1. From the commodity_code, find out the size ranges from the
	 PIPING_COMPS table ( size_g_high, size_g_low, size_r_high &
	 size_r_low ).

	 STEP 2. For all the commodity_code obtained above find out all the 
	 listed sizes in the PIPING_COMMOD_CODE table.

	 STEP 3. From the size list obtained in the STEP 2. Check whether they
	 are all listed in the PIPING_NPD_ALLOWED table. If not they should 
	 not be displayed in the gadget list.

	 STEP 4. From the list obtained in the STEP 3, check whichever falls
	 within the ranges obtained in the STEP 1 display them in the 
	 gadget list.

	 ***** THIS IS VERY IMPORTANT FOR LIVE LOOKUP. *******************/

	   /* Do the processing to get the input/output sizes from the cache  */

	 /*********************************/
	 /************* STEP 1 ************/
	 /*********************************/
	 {
	      IGRshort 		NumSpecs=0;
	      struct VRPDB_spec	*SpecPtr=NULL;

	      /* to store the size ranges so that we can display only
	      the commdities whose sizes fall within this range. Alwin */
	      __DBGpr_str(" spec string in ob", OB->spec_no_str );

	      VR$PDB_SET ( p_msg = &msg ,
			       spec  = atoi(OB->spec_no_str));
	      __DBGpr_str(" spec string in ob", OB->spec_no_str );

	      CompPtr = NULL;
	      status=VR$PDA_COMP(p_num = &NumComp, p_ptr = &CompPtr);

	      if( (!status & OM_S_SUCCESS) || CompPtr == NULL )
	      {
		    __DBGpr_com(" CACHE ACCESS FOR PIPING COMPS FAILED");
		    End
		    return(status);
	      }

	      __DBGpr_int("NumComp",NumComp);
	      __DBGpr_str(" Comp code in OB",OB->loc_cmp_code);
	      __DBGpr_str(" Opt  code in OB",OB->opt_code_num);
	      __DBGpr_str(" Fam  code in OB",OB->loc_code_nm);

	      for( i=0 , rows=0 ; i <=NumComp-1  ; i=i+1 )
	      {
		 if(   ( strcmp(CompPtr[i].key.comp_code,OB->loc_cmp_code) )
		    || ( CompPtr[i].key.option   != atoi(OB->opt_code_num) ) 
		    || ( CompPtr[i].data.famcode != atoi(OB->loc_code_nm)  ) 
		   ) continue;

		 rows ++ ;
		 if( rows == 1 )
		 {
		   result = _CALLOC( rows , char * );
		   diameters = _CALLOC( rows, struct VRPDB_ranges );
		 }
		 else
		 {
		   result = _REALLOC( result , rows , char * );
		   diameters = _REALLOC( diameters, rows, struct VRPDB_ranges );
		 }
                 /* commod_code  has 20 chars, VRPDB_CHAR_COMMOD is 24 */
		 result[rows-1]=_CALLOC(VRPDB_CHAR_COMMOD,char );

		 strcpy( result[rows-1],CompPtr[i].data.commodity );
		 __DBGpr_str(" result-commodity",result[rows-1]);

		 /* storing the size ranges from the Cache so that we can
		 process later. Alwin */
		 diameters[rows-1].dia1_h = CompPtr[i].dia.dia1_h;
		 diameters[rows-1].dia1_l = CompPtr[i].dia.dia1_l;
		 diameters[rows-1].dia2_h = CompPtr[i].dia.dia2_h;
		 diameters[rows-1].dia2_l = CompPtr[i].dia.dia2_l;
		 no_ranges = rows; 
	      }
	      __DBGpr_int(" Num of items in commodity list",rows);
	 } // STEP 1 loop ends here

	 if( rows > 0 ) status = FIg_enable( fp, IN_OUT_SIZE );
	 else status = FIg_disable( fp, IN_OUT_SIZE );

	 status=FIg_disable(fp,COMP_NUMBER);
	 status=FIg_disable(fp,FI_ACCEPT);
	 OB->not_proc_opt_cd = 0;
	 OB->not_proc_size = 1;
	 status = FIg_set_text ( fp, IN_OUT_SIZE,"" );
	 status = FIg_set_text ( fp, PART_DESCR,"" );
	 status = FIg_set_text ( fp, COMP_NUMBER,"" );

	 /*********************************/
	 /************* STEP 2 ************/
	 /*********************************/
	 {
	    // Add up all the commodity_codes to make a single query stmt.
	    /* Alwin
	     * SELECT DISTINCT size_g,size_r,si_comm_code FROM 
	     *	  piping_commod_code WHERE si_comm_code IN ("commod1, commod2");
	     */	
	    strcpy(query,"si_comm_code IN (");
	    for ( row_no=0 ; row_no<no_ranges ; row_no=row_no+1 )
	    {
		if( row_no == no_ranges-1 )
		       sprintf(commod_code,"'%s')",result[row_no]);
		else
		       sprintf(commod_code,"'%s',",result[row_no]);

		strcat(query,commod_code);
			__DBGpr_str(" query so far prepared",query);
	    }
	    __DBGpr_str("Final query prepared for piping_commod_code",query);

	    strcpy(select_buff,"distinct size_g,size_r,si_comm_code");
	    __DBGpr_str( " Select clause",select_buff);

	    rows1 = 0;
	    status = vdb$RisSelect(   select = select_buff,
				      table_name = "piping_commod_code",
				      where  = query,
				      numselect  = 3, 
				      p_numrows  = &rows1, 
				      p_buffer   = &result1 );
	    if ( (status != 1) || (rows1 == 0) )
	    {
	      End
	      return(status);
	    }
	 } // STEP 2 loop ends here

	 __DBGpr_int(" rows1",rows1);

#ifdef vdsDEBUG
   for( i=0 ; i < 3*rows1 ; i=i+1 )
  printf(" res1[%2d]=<%s>\n" ,i, result1[i]);
#endif

	 dConv_InputDia = _CALLOC( rows1, IGRdouble );
	 __CheckPtr( dConv_InputDia, " Memory Allocation Error - dConv_InputDia ", quit );
	 dConv_OutputDia = _CALLOC( rows1, IGRdouble );
	 __CheckPtr( dConv_OutputDia, " Memory Allocation Error - dConv_OutputDia", quit );

	 strCommodCode = _CALLOC( rows1, IGRchar* );
	 __CheckPtr( strCommodCode, " Memory Allocation Error - strCommodCode ", quit );
	 for( i=0; i<rows1; i++ )
	 {
	     /*** tr179901546 -need spaces for terminator ****/
	     strCommodCode[i] = _CALLOC( 21, IGRchar );
	     __CheckPtr( strCommodCode, " Memory Allocation Error - strCommodCode", quit );
	 }

	 proj_units = VRenq_proj_units() ; 
	 __DBGpr_int( " Project Units from DB ", proj_units );  

	 /*********************************/
	 /************* STEP 3 ************/
	 /*********************************/
	 {
	    IGRshort		nRows = 0;			
	    IGRdouble		*npd=NULL, *npd_equiv=NULL; 
	    struct VRPDB_npd  	*NpdPtr=NULL;

	    VR$PDA_NPD( p_num=&nRows , p_ptr=&NpdPtr );
	    __DBGpr_int("nRows (of piping_npd_allowed)",nRows);

	    if( nRows )
	    {
	      npd = _MALLOC( nRows, IGRdouble );
	      npd_equiv = _MALLOC( nRows, IGRdouble );
	    }

	    __CheckPtr( npd, " Memory Allocation Error - npd ", quit );
	    __CheckPtr( npd_equiv, " Memory Allocation Error-npd_equiv", quit );

	    __DBGpr_com("Allocation for npd, npdequiv successful!");

	    for( i=0; i<nRows; i++ )
	    {
	      npd[i]       = (NpdPtr+i)->npd;
	      npd_equiv[i] = (NpdPtr+i)->npd_eq;
	    }

	    // Convert the Ranges obtained in the first step
	    if( proj_units==VR_METRIC_UNITS )
	    {
	       __DBGpr_com( " Converting the ranges to Metric Units ... " );
	       __DBGpr_dbl( " BSBASISVAL ", BSBASISVAL );
	       for( i=0; i<no_ranges; i++ )
	       {
		 // These variables are very much needed, these are one
		 // which make sure, that converted values won't be processed
		 /* or converted again. Alwin for TR179900964 */
		 IGRboolean	bFound_G_Low, bFound_G_High;
		 IGRboolean	bFound_R_Low, bFound_R_High;

		 __DBGpr_dbl( " dia_green_high ", diameters[i].dia1_h );
		 __DBGpr_dbl( " dia_green_low ", diameters[i].dia1_l );
		 __DBGpr_dbl( " dia_red_high ", diameters[i].dia2_h );
		 __DBGpr_dbl( " dia_red_low ", diameters[i].dia2_l );

		 bFound_G_Low = bFound_G_High = FALSE;
		 bFound_R_Low = bFound_R_High = FALSE;
		 for( j=0; j<nRows; j++ )
		 {
		    if( !bFound_G_High && 
			fabs( diameters[i].dia1_h - npd[j] ) < VRGetTol(VR_DIST_TOL) )
		    {
		      diameters[i].dia1_h = npd_equiv[j];
		      bFound_G_High = TRUE;
		    }

		    if( !bFound_G_Low && 
			fabs( diameters[i].dia1_l - npd[j] ) < VRGetTol(VR_DIST_TOL) )
		    {
		      diameters[i].dia1_l = npd_equiv[j];
		      bFound_G_Low = TRUE;
		    }

		    if( !bFound_R_High &&
			fabs( diameters[i].dia2_h - npd[j] ) < VRGetTol(VR_DIST_TOL) ) 
		    { 
		      diameters[i].dia2_h = npd_equiv[j];
		      bFound_R_High = TRUE;
		    }

		    if( !bFound_R_Low &&
			fabs( diameters[i].dia2_l - npd[j] ) < VRGetTol(VR_DIST_TOL) )
		    {
		      diameters[i].dia2_l = npd_equiv[j];
		      bFound_R_Low = TRUE;
		    }
		 }

		 __DBGpr_dbl( " Conv. dia_green_low ", diameters[i].dia1_l );
		 __DBGpr_dbl( " Conv. dia_green_high ", diameters[i].dia1_h );
		 __DBGpr_dbl( " Conv. dia_red_high ", diameters[i].dia2_h );
		 __DBGpr_dbl( " Conv. dia_red_low ", diameters[i].dia2_l );
	       }
	    } // (proj_units==VR_METRIC_UNITS) loop ends

	    nConvArraySize = 0;
	    for( j=0; j<rows1; j++ )   
	    {
	      IGRdouble dInputDia, dOutputDia;

	      dInputDia = atof( result1[3*j] );
	      __DBGpr_dbl( " Green Diameter ", dInputDia );

	      dOutputDia = atof( result1[3*j+1] );
	      __DBGpr_dbl( " Red Diameter ", dOutputDia );

	      for( i=0; i<nRows; i++ )
	      {
		 /*
		  * The conditions are rewritten ....
		  * We need to check whether "input_dia" is listed in the
		  * PIPING_NPD_ALLOWED table ( NPD for Imperial and NPD_EQUIV 
		  * for Metric units ). If its not listed, there's no point
		  * in proceeding with "output_dia".
		  */ 

		 IGRboolean   bFoundDiameters = FALSE;

		 if( fabs( dInputDia - npd[i] ) < VRGetTol(VR_DIST_TOL) )
		 {
		    IGRboolean	bZeroDia = FALSE;
		    for( k=0; k<nRows; k++ )
		    {
		       // if dOutputDia = 0 OR dOutputDia = npd ...
		       if( dOutputDia < VRGetTol(VR_DIST_TOL) )
		       {
			  bZeroDia = TRUE;
                          bFoundDiameters = TRUE;
                          break;
		       }
			
		       if ( fabs( dOutputDia - npd[k] ) < VRGetTol(VR_DIST_TOL) )
		       {
			  bFoundDiameters = TRUE;
			  break;
		       }
		    }

		    if( bFoundDiameters )
		    {
			if (proj_units==VR_METRIC_UNITS)
			{
			  dConv_InputDia[nConvArraySize] = npd_equiv[i];
			  dConv_OutputDia[nConvArraySize] = npd_equiv[k];
			  if( bZeroDia ) dConv_OutputDia[nConvArraySize] = 0.0;
			}
			else // IMPERIAL UNITS
			{
			  dConv_InputDia[nConvArraySize] = npd[i];
			  dConv_OutputDia[nConvArraySize] = npd[k];
			  if( bZeroDia ) dConv_OutputDia[nConvArraySize] = 0.0;
			}

			strcpy( strCommodCode[nConvArraySize], result1[j*3+2] );
			nConvArraySize ++ ;
			i = nRows;
		    }
		 } // if loop Inputdia ends here
	      } // Loop i ends here 
	    } // Loop j ends here

	    _FREE( npd);
	    _FREE( npd_equiv );
	} // STEP 3 loop ends here

	if( rows1 > 0 )
	{
	   vdb$RisFreeBuffer(buffer  =    result1,
			     size    =    rows1*3);
	}

	__DBGpr_int( " Valid entries - verifying npd_allowed", nConvArraySize );

	/*********************************/
	/************* STEP 4 ************/
	/*********************************/
	{
	   default_dia_found = FALSE;

	   tot_no_rows = 0;
	   FIfld_set_max_num_chars( fp, IN_OUT_SIZE, 0, 41 );
	   //FIfld_set_list_num_rows( fp, IN_OUT_SIZE, col, nConvArraySize );
	   for( row_no=0; row_no<no_ranges; row_no++ ) // rows -> No. of Ranges
	   {
	     /*********************/
	     /* 01234567890123456789012345678901234567890 */
	     /*  nnnn.ddXnnnn.dd   ^This-is-si_comm_code- */
	     /*  ^ is the no. of characters in output_dia */
	     /*********************************************/
	     /* Build list of input/output sizes */

	     __DBGpr_int(" Range no. ", row_no );

	     for( row_no1=0; row_no1<nConvArraySize; row_no1++ )
	     {
		IGRint 		idx;
		IGRdouble 	dInputDia, dOutputDia;
		IGRdouble	npd_g_low, npd_g_high;
		IGRdouble	npd_r_low, npd_r_high;

		dInputDia = dConv_InputDia[row_no1];
		__DBGpr_dbl( " Green Diameter ", dInputDia );

		dOutputDia = dConv_OutputDia[row_no1];
		__DBGpr_dbl( " Red Diameter ", dOutputDia );

		__DBGpr_int(" row_no1",row_no1);
		__DBGpr_str(" si_comm_code-result ",result[row_no]);
		__DBGpr_str(" si_comm_code-result1",strCommodCode[row_no1]);

		if( strcmp( strCommodCode[row_no1], result[row_no] ) ) continue;

		/*
		 * Check whether the values (dConv_InputDia & dConv_OutputDia) 
		 * fall between the ranges ( diameters ).
		 *
		 *	npd_low <= dInputDia <= npd_high
		 *
		 * the above condition has to be checked both input diameter
		 * as well as the output diameter. Alwin
		 */
		npd_g_low = diameters[row_no].dia1_l;
		npd_g_high = diameters[row_no].dia1_h;
		npd_r_low = diameters[row_no].dia2_l;
		npd_r_high = diameters[row_no].dia2_h;

		if( 
		   (  ( fabs( dInputDia - npd_g_high ) < VRGetTol(VR_DIST_TOL) ) ||
		      ( dInputDia < npd_g_high )        ) &&
		   (  ( fabs( dInputDia - npd_g_low ) < VRGetTol(VR_DIST_TOL) ) ||
		      ( npd_g_low < dInputDia )        ) &&
		   (  ( fabs( dOutputDia - npd_r_high ) < VRGetTol(VR_DIST_TOL) ) ||
		      ( dOutputDia < npd_r_high )        ) &&
		   (  ( fabs( dOutputDia - npd_r_low ) < VRGetTol(VR_DIST_TOL) ) ||
		      ( npd_r_low < dOutputDia )        ) 
		  ) 
		{
		   sprintf( input_dia, "%g", dConv_InputDia[row_no1] );
		   sprintf( output_dia, "%g", dConv_OutputDia[row_no1] );
		   strcpy(outfld,"                                        ");
		   strtin = 8 - strlen(input_dia);
		   sprintf(&outfld[strtin],"%s",input_dia);
		   outfld[8] = 'X';
		   fldlen=strlen(output_dia);
		   strncpy(&outfld[9],output_dia,fldlen);
		   sprintf(&outfld[19],"%d",fldlen);
		   strcpy(&outfld[20],result[row_no]);
		   strcpy(commod_code,result[row_no]);

		   __DBGpr_str(" IN_OUT_SIZE",outfld);

		   /*
		    * Automatically selecting the default diameters. If the
		    * NPD_G & NPD_R is same as that of the Active Parameters 
		    * value then, we need to display that SIZE gadget.
		    */
		   if( fabs( dConv_InputDia[row_no1] -
			       active_Gdia ) < VRGetTol(VR_DIST_TOL) ) 
		   {
		       if( ( fabs( dConv_OutputDia[row_no1] -
			       active_Rdia ) < VRGetTol(VR_DIST_TOL) ) ||
		           ( dConv_OutputDia[row_no1] < VRGetTol(VR_DIST_TOL) )
		         )
		       {
			  status = FIg_set_text( fp, IN_OUT_SIZE,outfld );
			  default_dia_found = TRUE;
		       }
		   }

		   FIfld_set_list_text(fp,IN_OUT_SIZE,tot_no_rows,col,
						   (IGRuchar*)outfld,sel_flag);
		   tot_no_rows++;
		   FIfld_set_list_num_rows( fp, IN_OUT_SIZE, col, 
						tot_no_rows );
		} // bIsValidSize ends
	     } //end of loop row_no1
	   } //end of loop row_no
	} // STEP 4 loop ends here

	_FREE( dConv_InputDia );
	_FREE( dConv_OutputDia );
	_LOOPFREE( strCommodCode, rows1 );

	if( no_ranges )
	   _FREE( diameters );

	if(rows > 0)
	{
	    vdb$RisFreeBuffer ( buffer  =    result,
				size    =    rows);
	}

	if(tot_no_rows == 1)
	{
	    g_label = IN_OUT_SIZE;
	    FIg_set_text(fp,g_label,outfld);
	    no_choice = 1;
	}
	else if (default_dia_found)
	{
	       g_label = IN_OUT_SIZE;
	       no_choice = 1;
	}
	else if (tot_no_rows > 1)
	{
	       no_choice = 0;
	       break; /* Note that the break is conditional */
	}
	else
	{
	       status=FIg_disable(fp,IN_OUT_SIZE);
	       status=FIg_disable(fp,FI_ACCEPT);
	       OB->not_proc_opt_cd = 1;
	       err_flg=1;
	       strcpy(err_msg,"No sizes for this option code");
	       g_label = OPTION_CODE;
	       FIfld_get_active_row(fp,g_label,&row,&r_pos);
	       status = FIfld_set_select ( fp,g_label,row,col,0 );
	       FIfld_set_list_num_rows(fp,IN_OUT_SIZE,col,0);

	       no_choice = 0;
	       break;
	 }


	case IN_OUT_SIZE:     /* Sequenced to     */

	if(OB->not_proc_opt_cd)
	{
	   /* Put out error message of last process and get out */
	   err_flg = 1;
	   strcpy(err_msg,"OPTION CODE must be defined");
	   break;
	}
	/* Get the text string */
	FIfld_get_text_length( fp, g_label, 0, 0, &text_size );

	status = FIfld_get_text ( fp, g_label,0,0,text_size, 
		   (IGRuchar*)outfld,&insel_flag,&r_pos);

	__DBGpr_str( " Text from IN_OUT_SIZE gadget ", outfld );

	if ( status != FI_SUCCESS )
	{
	   End
	   return(status);
	}

	/* Code to process text string "text" */
	j=0;
	for (i=0;i<8;i=i+1)
	{
	      if(outfld[i] != ' ')
	      {
		input_dia[j] = outfld[i];
		j=j+1;
	      }
	}
	input_dia[j] = '\0';
	fldlenstr[0] = outfld[19];
	fldlenstr[1] = '\0';
	fldlen = atoi(fldlenstr);
	strncpy(output_dia,&outfld[9],fldlen);
	output_dia[fldlen] = '\0';
	strcpy(commod_code,&outfld[20]);

	OB->default_Gdia = (double) atof(input_dia);
	output_dia_val = (double) atof(output_dia);
	/* If R_DIA = 0, R_DIA = G_DIA */
	if(output_dia_val > VRGetTol(VR_DIST_TOL)) /* modified tr179900564 */
	{
	    OB->default_Rdia = output_dia_val;
	}
	else
	{
	    OB->default_Rdia = OB->default_Gdia;
	    output_dia_val = 0.0;
	}
	/* Added for tr179900564 */
	sts = VRenq_proj_units();

	proj_no = 0;          /*    NOT USED   */
	/* Get the active unit */
	sts = Get_piping_spec_units( proj_no, OB->spec_nam_txt,err_msg);
	if(sts != 1)
	{
	       End
	       return (OM_E_ABORT);
	}

	/* If the active unit different from Db unit */
	if( VRGL_PROJ.prj_units != VRGL_specunit )
	{
	   SIZE_1 = get_allowed_npd(VRGL_PROJ.prj_units,VRGL_specunit,
			    OB->default_Gdia,OB->spec_nam_txt,proj_no,err_msg);
	   SIZE_2 = get_allowed_npd(VRGL_PROJ.prj_units,VRGL_specunit,
			    output_dia_val,OB->spec_nam_txt,proj_no,err_msg);
	}
	else
	{
	   SIZE_1 = OB->default_Gdia;
	   SIZE_2 = output_dia_val;
	}
	sprintf (query, "si_comm_code = '%s' and size_g = %f and size_r = %f",
				   commod_code, SIZE_1, SIZE_2);

	/* Make the query */
	rows = 0;
	status = vdb$RisSelect(  
		select      =      "pdm_part_num",
		table_name  =      "piping_commod_code",
		where       =      query,
		numselect   =      1,
		p_numrows   =      &rows,
		p_buffer    =      &result ); 

	if ( (status != 1) || (rows == 0) )
	{
	   UI_status("PDM_PART_NUM not defined");
	   End
	   return(status);
	}

	strcpy( OB->pdm_partnum, result[0] );
	if(rows > 0)
	{
	    vdb$RisFreeBuffer ( buffer  =    result,
				size    =    rows);
	}

	OB->not_proc_size = 0;
	status = FIg_enable(fp,FI_ACCEPT);
	status = FIg_enable(fp,COMP_NUMBER);
	status = FIg_set_text ( fp, PART_DESCR,"" );
	status = FIg_set_text ( fp, COMP_NUMBER,"" );

	VR$PDB_SET ( p_msg = &msg ,
		 spec  = atoi(OB->spec_no_str));

	CompPtr = NULL;
	status=VR$PDA_COMP(p_num = &NumComp, p_ptr = &CompPtr);

	if( (!status & OM_S_SUCCESS) || CompPtr == NULL )
	{
	  __DBGpr_com(" CACHE ACCESS FOR PIPING COMPS FAILED");
	  End
	  return(status);
	}

	__DBGpr_int("NumComp",NumComp);
	__DBGpr_str(" Comp code in OB",OB->loc_cmp_code);
	__DBGpr_str(" Opt  code in OB",OB->opt_code_num);
	__DBGpr_str(" Fam  code in OB",OB->loc_code_nm);
	__DBGpr_str(" Commodity ",commod_code);

	rows = 0;
	for( i=0; i <=NumComp-1  ; i=i+1 )
	{
	   if(   strcmp(CompPtr[i].key.comp_code,OB->loc_cmp_code)
		  || CompPtr[i].key.option   != atoi(OB->opt_code_num)
		  || CompPtr[i].data.famcode != atoi(OB->loc_code_nm)
		  || strcmp(CompPtr[i].data.commodity,commod_code) )
		  continue;

	   rows = 1;
	   strcpy( catalog_name, CompPtr[i].data.famnam );
	   __DBGpr_str(" Family name ", catalog_name );
	   break;
	}

	if( rows > 0 )
	{
	   sprintf( query,"n_itemname = '%s'", OB->pdm_partnum );
	   rows = 0;
	   status = vdb$RisSelect(  
		    select      =     "n_itemdesc",
		    table_name  =      catalog_name,
		    where       =      query,
		    numselect   =      1,
		    p_numrows   =      &rows,
		    p_buffer    =      &result );
	   if ( (status != 1) || (rows==0) )
	   {
	      End 
	      return(status);
	   }
	   if(rows > 0)
	   {
		  strcpy( part_desc, result[0] );
		  status = FIg_set_text ( fp, PART_DESCR,part_desc );

		  vdb$RisFreeBuffer (  buffer  =    result,
							   size    =    rows);
		  status = FIg_set_text ( fp, COMP_NUMBER,"" );
		  status = FIg_enable(fp,COMP_NUMBER);
		  status = FIfld_pos_cursor(fp,COMP_NUMBER,0,0,0,0,0,0);
	   }
	}
	else	UI_status( "Family name not defined in DB" );

	no_choice = 0;
	break;


	case COMP_NUMBER:

	   if(OB->not_proc_size)
	   {
	      /* Put out error message of last process and get out */
	      err_flg = 1;
	      break;
	   }

	   /* Get the text string */
	   FIfld_get_text_length( fp, g_label, 0, 0, &text_size );
	   status = FIfld_get_text ( fp, g_label,0,0,text_size, 
			(IGRuchar*)OB->comp_num_fld,&insel_flag,&r_pos);
	   
	   /* Code to process text string "text" */
	   no_choice = 0;
	   break;

        default:
	  printf("unknown key = %d\n",g_label);
	  no_choice = 0;
	  break;
	 } /* END switch ( g_label ) */
	 if(err_flg)
	 {
	    /* Put error message in err field */
	    __DBGpr_com( err_msg );
	 }
  } /* End while no choice looping */

  End
  return (status);

quit:
	_FREE( dConv_InputDia );
	_FREE( dConv_OutputDia );
	_LOOPFREE( strCommodCode, rows1 );

	if( no_ranges )
	{
	    _FREE( diameters );
	    vdb$RisFreeBuffer (  buffer  =    result,
				 size    =    no_ranges );
	}
	if( rows1 > 0 )
	{
	   vdb$RisFreeBuffer(buffer  =    result1,
			     size    =    rows1*3);
	}

	End
	return (status);
}

IGRboolean VR_IsAlreadyInList( char *NewItem , char **List , int Rows )
{
    int	i;
    SetProc( VR_IsAlreadyInList ); Begin

    if( Rows == 0 )
	return( FALSE );

/* For unknown reasons, the below for statement will not work on the double
 * pointer. So, we try and optimise! */
/*    for( i=Rows-1 ; i<=0 ; i-- )   */

    if( !strcmp( NewItem , List[Rows-1] ) )
	return( TRUE );

    for( i=0 ; i<Rows ; i++ )
    {
	if( !strcmp( NewItem , List[i] ) )
	    return( TRUE );
    }

    End
    return( FALSE );
}

end implementation Root;
