/* $Id: VSpledatCmdi.I,v 1.1.1.1 2001/01/04 21:10:26 cvs Exp $ */

/***************************************************************************
 * I/STRUCT
 *
 * File:	struct/vscmd/VSpledatCmdi.I
 *
 * Description:
 *      These routines allow the placement and modification of edge attribute
 *      macros. Code was later added to add/delete plates as parents to the
 *      macros so that two curves could be obtained from the intersection of
 *      the plates with a curved surface for the purpose of placing a con-
 *      tinuously changing bevel on the plate edge. These curves can be created
 *      with the Bevel Curves button on form, VSedgeAttr.frm. The call to
 *      create the curves, VSgetBevelCurves, is in file, VSedgebevel.I.
 *
 * Dependencies:
 *	Form, struct/config/english/forms/VSedgeAttr.frm
 *	#defines for gadgets, struct/include/vsedgeattr.h
 *
 * Revision History:
 *	$Log: VSpledatCmdi.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:26  cvs
 *	Initial import to CVS
 *	
# Revision 1.5  2000/04/05  21:28:24  pinnacle
# Replaced: vscmd/VSpledatCmdi.I for:  by impd252 for struct
#
# Revision 1.4  1999/05/12  14:55:56  pinnacle
# (No comment)
#
# Revision 1.3  1999/05/04  16:33:08  pinnacle
# ah
#
# Revision 1.2  1999/05/04  16:21:22  pinnacle
# traceFlag = 120
#
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.10  1998/01/02  05:26:52  pinnacle
# Replaced: vscmd/VSpledatCmdi.I for:  by rchennup for struct
#
# Revision 1.9  1997/10/31  15:03:52  pinnacle
# assigned sts below SetProc
#
 *
 * History:
 *      MM/DD/YY        AUTHOR  DESCRIPTION
 *      10/07/97	ejm	CR179700200: Need ability to place a contin-
 *				uously changing bevel on plate edge.
 *
 *				Added methods, SetPlate, AddPlate, DeletePlate;
 *				added cases for Add and Del buttons and Bevel
 *				Curves button under form_notification; added 
 *				code to process plates under method, modify_mac.
 *
 *				Also, so this code would compile on Solaris,
 *				typecast 5th argument in FIfld_set_list_text to
 *				(unsigned char *) and inactivated inclusion of
 *				VX_FIproto.h.
 *      05/04/99        ah      Added traceFlag = 120 and did some formatting
 *      05/12/99	ejm	Added DTHK attribute
 ***************************************************************************/


class implementation VSplEdAtCmd;

#include <math.h>
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "EMSmsgdef.h"
#include "acrepdef.h"
#include "gr.h"
#include "FI.h"
/*
%safe
#include "VX_FIproto.h"
%endsafe
*/
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "AS_status.h"
#include "exmacros.h"
#include "grmacros.h"
#include "dpmacros.h"
#include "growner.h"
#include "nddef.h"
#include "madef.h"
#include "macro.h"
#include "asmacros.h"
#include "ndmacros.h"
#include "vsplatedef.h"
#include "vsbmaxisdef.h"
#include "expmacros.h"
#include "expression.h"
#include "vsdbgmacros.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vscmdmacros.h"
#include "EMSssprops.h"
#include "ACrg_collect.h"
#include "ACattrib.h"
#include "vsedgeattr.h"
#include "vdsmacros.h"      /* vd$get_name */

#include "VDobj.h"

%safe
static int xx=-1,yy,heig,wid,screen;
%endsafe

typedef char PROC_STRING[100];
static PROC_STRING *list, **spec, **attrib;
static int    num_procs, proc_len[50];
static double plate_thk;

/*
#define DEBUG           1
*/


from  NDnode	   import  ASreturn_go, NDget_objects, 
			   NDchg_state,NDchange_connect,NDconnect,NDdisconnect;
from  NDmacro      import  ACreturn_foot, ACgive_structure;
from  GRgraphics   import  GRdisplay,GRchgprops, GRgetname, GRconstruct;
from  GRvg	   import  GRchgname, GRputsymb, GRgetsymb, GRchgweight;
from  ACrg_collect import  AClist_attribute, ACadd_list_attribute;
from  ci_macro     import  init;
from  ACcpx        import  find_macro;
from  ACcpx_defn   import  ACgive_name;
from  VSedge3Datt  import  ACmplace;

extern GRclassid	OPP_nci_macro_class_id,	OPP_VSplate_class_id,
                        OPP_ACrg_collect_class_id, OPP_ASsource_class_id,
                        OPP_ACpretend_class_id, OPP_VSedge3Datt_class_id;

extern OM_S_CHANSELECT	AS_to_comp;
extern struct GRid NULL_GRID;
extern void UI_status();

#define MY_ERROR 530
#define LOCATE_EDGE 531
#define VS_NOOBJ_SELECTED 101
#define MAX_PLATE_PARENTS 10
#define MAX_OBJ 20           /* as defined in NDget_objects (NDchannel.I)  */

/* Global */
#if 1
%safe
int ptlcnt;
int set_flag;
int add_flag;
int del_flag;
%endsafe
#endif

#if 0
extern int ptlcnt;
extern int set_flag;
extern int add_flag;
extern int del_flag;
#endif

static int traceFlag;




VSseekFields (     struct ACrg_coll	*list,
		   IGRint		nb,
		   IGRchar 		*array  )
{
IGRint  i;

  for (i=0;i<nb;i++)
  {
    if (!strcmp(list[i].name,array))  return i;
  }
  return -1;
}

IGRlong VSopen_file (  IGRchar   *name, 
			     FILE      **ptfile  )
{
IGRint		i;
IGRlong		sts;
IGRchar		complete_path[DI_PATH_MAX],path[DI_PATH_MAX];

  // search ratio_setup file in the current directory
  *ptfile = fopen(name,"r");
  if (*ptfile == NULL) {
     // get product path
    for( i=0; ; i++ ) {
      sts = ex$get_path(      index   = i,
                              path    = path,
                              len     = DI_PATH_MAX,
                              type    = EX_CONFIG_PATH );
      if( ! (sts&1))  break;
      // t(he first path could be the user path, search in it.
      if (i==0) {
        sprintf( complete_path, "%s%s", path,name);
        *ptfile = fopen( complete_path, "r" );
        if(*ptfile != NULL)      break;
      }
      sprintf( complete_path, "%sconfig/drawing/%s", path,name);
      *ptfile = fopen( complete_path, "r" );
      if(*ptfile != NULL)      break;
    }
  } 
  return 1;
}

long VSfillACrg(  struct ACrg_coll        *ACrg,
		  IGRdouble 		  *list_att,
		  IGRchar  		  **list_att_txt  )
{
 SetProc( VSfillACrg ) ;	Begin

        strcpy(ACrg[ATT_IDX_DTHK].name,ATT_DEL_THK);
        ACrg[ATT_IDX_DTHK].desc.type = AC_ATTRIB_DOUBLE;
        ACrg[ATT_IDX_DTHK].desc.value.att_exp = list_att[ATT_IDX_DTHK];

        strcpy(ACrg[ATT_IDX_LO].name,ATT_LO);
        ACrg[ATT_IDX_LO].desc.type = AC_ATTRIB_DOUBLE;
        ACrg[ATT_IDX_LO].desc.value.att_exp = list_att[ATT_IDX_LO];

        strcpy(ACrg[ATT_IDX_LB].name,ATT_LB);
        ACrg[ATT_IDX_LB].desc.type = AC_ATTRIB_DOUBLE;
        ACrg[ATT_IDX_LB].desc.value.att_exp = list_att[ATT_IDX_LB];

        strcpy(ACrg[ATT_IDX_SO].name,ATT_SO);
        ACrg[ATT_IDX_SO].desc.type = AC_ATTRIB_DOUBLE;
        ACrg[ATT_IDX_SO].desc.value.att_exp = list_att[ATT_IDX_SO];

        strcpy(ACrg[ATT_IDX_SB].name,ATT_SB);
        ACrg[ATT_IDX_SB].desc.type = AC_ATTRIB_DOUBLE;
        ACrg[ATT_IDX_SB].desc.value.att_exp = list_att[ATT_IDX_SB];

        strcpy(ACrg[ATT_IDX_A].name,ATT_A);
        ACrg[ATT_IDX_A].desc.type = AC_ATTRIB_DOUBLE;
        ACrg[ATT_IDX_A].desc.value.att_exp = list_att[ATT_IDX_A];

        strcpy(ACrg[ATT_IDX_TYPE_ANGLE].name,ATT_TYPE_ANGLE);
        ACrg[ATT_IDX_TYPE_ANGLE].desc.type = AC_ATTRIB_TEXT;
        strcpy(ACrg[ATT_IDX_TYPE_ANGLE].desc.value.att_txt,
                                   list_att_txt[ATT_IDX_TYPE_ANGLE]);

        strcpy(ACrg[ATT_IDX_TYPE_CHAMF].name,ATT_TYPE_CHAMF);
        ACrg[ATT_IDX_TYPE_CHAMF].desc.type = AC_ATTRIB_DOUBLE;
        ACrg[ATT_IDX_TYPE_CHAMF].desc.value.att_exp = 
                                            list_att[ATT_IDX_TYPE_CHAMF];
       
        strcpy(ACrg[ATT_IDX_B].name,ATT_B);
        ACrg[ATT_IDX_B].desc.type = AC_ATTRIB_DOUBLE;
        ACrg[ATT_IDX_B].desc.value.att_exp = list_att[ATT_IDX_B];
      
        strcpy(ACrg[ATT_IDX_V].name,ATT_V);
        ACrg[ATT_IDX_V].desc.type = AC_ATTRIB_DOUBLE;
        ACrg[ATT_IDX_V].desc.value.att_exp = list_att[ATT_IDX_V];
     
        strcpy(ACrg[ATT_IDX_Y].name,ATT_Y);
        ACrg[ATT_IDX_Y].desc.type = AC_ATTRIB_DOUBLE;
        ACrg[ATT_IDX_Y].desc.value.att_exp = list_att[ATT_IDX_Y];
    
        strcpy(ACrg[ATT_IDX_X].name,ATT_X);
        ACrg[ATT_IDX_X].desc.type = AC_ATTRIB_DOUBLE;
        ACrg[ATT_IDX_X].desc.value.att_exp = list_att[ATT_IDX_X];

        strcpy(ACrg[ATT_IDX_H].name,ATT_H);
        ACrg[ATT_IDX_H].desc.type = AC_ATTRIB_DOUBLE;
        ACrg[ATT_IDX_H].desc.value.att_exp = list_att[ATT_IDX_H];
  
        strcpy(ACrg[ATT_IDX_C].name,ATT_C);
        ACrg[ATT_IDX_C].desc.type = AC_ATTRIB_DOUBLE;
        ACrg[ATT_IDX_C].desc.value.att_exp = list_att[ATT_IDX_C];
 
        strcpy(ACrg[ATT_IDX_N].name,ATT_N);
        ACrg[ATT_IDX_N].desc.type = AC_ATTRIB_DOUBLE;
        ACrg[ATT_IDX_N].desc.value.att_exp = list_att[ATT_IDX_N];

        strcpy(ACrg[ATT_IDX_T].name,ATT_T);
        ACrg[ATT_IDX_T].desc.type = AC_ATTRIB_DOUBLE;
        ACrg[ATT_IDX_T].desc.value.att_exp = list_att[ATT_IDX_T];

        strcpy(ACrg[ATT_IDX_ALLOWANCE].name,ATT_ALLOWANCE);
        ACrg[ATT_IDX_ALLOWANCE].desc.type = AC_ATTRIB_DOUBLE;
        ACrg[ATT_IDX_ALLOWANCE].desc.value.att_exp = 
                                              list_att[ATT_IDX_ALLOWANCE];

        strcpy(ACrg[ATT_IDX_PROCESS].name,ATT_PROCESS);
        ACrg[ATT_IDX_PROCESS].desc.type = AC_ATTRIB_TEXT;
        strcpy(ACrg[ATT_IDX_PROCESS].desc.value.att_txt,
                                   list_att_txt[ATT_IDX_PROCESS]);

        strcpy(ACrg[ATT_IDX_SPEC_NB].name,ATT_SPEC_NB);
        ACrg[ATT_IDX_SPEC_NB].desc.type = AC_ATTRIB_TEXT;
        strcpy(ACrg[ATT_IDX_SPEC_NB].desc.value.att_txt, 
                                   list_att_txt[ATT_IDX_SPEC_NB]);

	strcpy(ACrg[ATT_IDX_ABS].name,ATT_ABS );
	ACrg[ATT_IDX_ABS].desc.type = AC_ATTRIB_DOUBLE;
	ACrg[ATT_IDX_ABS].desc.value.att_exp = list_att[ATT_IDX_ABS];
End        
        return OM_S_SUCCESS;
}

long VSGetNextWord(          IGRchar  *buf, 
			     IGRchar  *out_buf, 
			     IGRint   size_out_buf, 
			     IGRchar  **next_buf)
{
 int i, j;
 char *ptr;
 if(buf == NULL) return 0;

 ptr = NULL;

/*| Take out first spaces */
 for(i=0;i<strlen(buf);i++)
  {
   if(buf[i] != ' ' && buf[i] != '\t' && buf[i] != '\0' ) 
   { ptr = &buf[i]; break; }
  }

 for( j=i; j<strlen(buf); j++ )
  {
   if(buf[j] == ' ' || buf[j] == '\t' || buf[j] == '\0' ) 
   { ptr = &buf[j]; break; }
  }

 if( j == strlen(buf) )
 {
   *next_buf = NULL;
   if( ptr ) strcpy( out_buf, ptr );
   return 1;
 }

 if(ptr == NULL)
  {
   *next_buf = NULL;
  }
 else
  {
   /* prepare for the next word */
   if( ptr[0] == '\0' )  *next_buf = NULL;
   else                  *next_buf = &ptr[1];
   *ptr = '\0';
  }

/*| Take out first spaces */
 for(i=0;i<strlen(buf);i++)
  {
   if(buf[i] != ' ' && buf[i] != '\t') { ptr = &buf[i]; break; }
  }

 if(ptr == NULL ) { out_buf[0] = '\0'; return 1; }

 /* Take last first spaces */
 for(i=strlen(ptr)-1;i>0;i--)
  {
   if(ptr[i] != ' ' && ptr[i] != '\t') { ptr[i+1] = '\0'; break; }
  }

 if(strlen(ptr) < 1) { out_buf[0] = '\0'; return 1; }

 strncpy(out_buf, ptr, size_out_buf-1);
 if(strlen(ptr) > size_out_buf-1) out_buf[size_out_buf-1] = '\0';
 else                             out_buf[strlen(ptr)]    = '\0';
 /* Extracted word done */
 return 1;

}

long VSreadAttrFile(  	     IGRchar    *name,
		             IGRchar	*form_ptr,
		             IGRint	gadget1,
		             IGRint	gadget2     )
{
FILE	    *ptfile=NULL;
IGRint      i, list_ind=0, num_specs=0;
IGRchar	    cc, word[100], *next_buf=NULL;;

  list = NULL; spec = NULL; attrib=NULL;
  num_procs=0;
  VSopen_file (name, &ptfile);
  if (ptfile == NULL) goto quit;
  
  list      = _MALLOC( 1, PROC_STRING );
  spec      = _MALLOC( 1, PROC_STRING * );
  attrib    = _MALLOC( 1, PROC_STRING * );

  while (EOF != fscanf(ptfile,"%s",word)) {
     cc = word[0];
     if (cc == '%' ) {
	  list = _REALLOC( list, (num_procs+1), PROC_STRING );
          if (word[1] == '\0') fscanf(ptfile,"%s", list[num_procs++] );
          else strcpy( list[num_procs++],&word[1]);

	  spec = _REALLOC( spec, num_procs, PROC_STRING * );
	  attrib = _REALLOC( attrib, num_procs, PROC_STRING * );
	  spec[num_procs-1] = _MALLOC( 1, PROC_STRING );
	  attrib[num_procs-1] = _MALLOC( 1, PROC_STRING );
	  num_specs = 0;
     }
     else if (cc == '#' ) {
	  IGRchar buffer[100], abs_word[30];
          spec[num_procs-1] = _REALLOC( spec[num_procs-1], 
					( num_specs+1 ), PROC_STRING );
	  attrib[num_procs-1] = _REALLOC( attrib[num_procs-1],
					( num_specs+1 ), PROC_STRING );

	  if (word[1] == '\0') //fscanf(ptfile,"%s", buffer );
	                         fgets( buffer, 99, ptfile );
	  else strcpy( buffer, &word[1]);

	  buffer[strlen(buffer)-1] = abs_word[0] = '\0';
          for(i=0;i<strlen(buffer);i++)
          {
             if(buffer[i] != ' ' && buffer[i] != '\t' ) break;
  	  }

	  VSGetNextWord( &buffer[i], spec[num_procs-1][num_specs], 30,&next_buf );
	  if ( next_buf ) VSGetNextWord( next_buf, abs_word, 30, &next_buf );

	  if( abs_word && abs_word[0] != '\0' )
	  {
	    if( abs_word[0] == 'A' ) 
		strcat( spec[num_procs-1][num_specs], " ABS" );
	    else if( abs_word[0] == 'R' )
		strcat( spec[num_procs-1][num_specs], " REL" );
          }

	  if( next_buf ) strcpy( attrib[num_procs-1][num_specs], next_buf );
          else           strcpy( attrib[num_procs-1][num_specs], "" );
	  proc_len[num_procs-1] = (++num_specs);
     }
  }

  FIfld_set_num_rows ( form_ptr, gadget1, num_procs );
  for( i=0; i<num_procs; ++i )
  {
     if (i == 0 ) FIfld_set_list_text(form_ptr,gadget1,i, 0,(unsigned char *)list[i],TRUE);
     else         FIfld_set_list_text(form_ptr,gadget1,i, 0,(unsigned char *)list[i],FALSE);
  }

  FIfld_set_num_rows ( form_ptr, gadget2, proc_len[0] );
  for( i=0; i<proc_len[0]; ++i )
  {
     IGRint  index;
     IGRchar array[80], temp[100];
     word[0] = '\0';
     strcpy( temp, spec[0][i] );
     VSGetNextWord( spec[0][i], word, 30,&next_buf );
     strcpy( spec[0][i], temp );

     for( index=0; index < i; ++index )
     {
	strcpy( temp, spec[0][index] );
	VSGetNextWord( spec[0][index],  array, 30,&next_buf );
	strcpy( spec[0][index], temp );
	if( !strcmp( word, array ) ) break;
     }
     if( index != i ) 	continue;

     if ( list_ind == 0 ) 
	FIfld_set_list_text(form_ptr,gadget2,list_ind, 0, (unsigned char *)word, TRUE);
     else if( word[0] != '\0' )
	FIfld_set_list_text(form_ptr,gadget2,list_ind, 0, (unsigned char *)word, FALSE);
     ++list_ind;
  }

quit:
  fclose(ptfile);
  return 1;
}

long VSgetProcSpec ( IGRchar	*name,
		     IGRchar	*form_ptr,
		     IGRint	gadget1,
		     IGRint	gadget2     )
{
FILE	   *ptfile;
IGRchar	   word[50],cc;
IGRint     iproc=0,ispec=0;
  
  VSopen_file (name, &ptfile);
  if (ptfile == NULL) goto quit;
  
  while (EOF != fscanf(ptfile,"%s",word)) {
    cc = word[0];
    if (cc == '%' || cc == '#') {
      if (word[1] == '\0') fscanf(ptfile,"%s",word);
      else strcpy(word,&word[1]);
      if (cc == '%') {
        if (iproc == 0)
          FIfld_set_list_text(form_ptr,gadget1,iproc, 0,(unsigned char *)word,TRUE);
        else
          FIfld_set_list_text(form_ptr,gadget1,iproc, 0,(unsigned char *)word,FALSE);
        iproc++;
      }
      else {
        if (ispec == 0)
          FIfld_set_list_text(form_ptr,gadget2,ispec, 0,(unsigned char *)word,TRUE);
        else
          FIfld_set_list_text(form_ptr,gadget2,ispec, 0,(unsigned char *)word,FALSE);
        ispec++;
      }
    }
  }

  fclose(ptfile); 
 quit :
 return OM_S_SUCCESS;
}

void VSdispObj( struct GRid 	*obj,
	        struct GRmd_env *module,
	        enum GRdpmode   *mode,
		IGRint		code     )
{
IGRint		loc_msg, dim;
IGRlong		msg, status;
IGRshort	mat_type,mm_type;
IGRdouble	mat[16], *mm;
struct GRid 	buff;

  if (code) {
    status = dp$erase_hilite(msg=&loc_msg,
                             objid = module->md_id.objid,
                             osnum = module->md_id.osnum);
  }
  buff = *obj;
  status = om$send(  msg = message NDnode.ASreturn_go
				(&buff,&mat_type,mat),
                        targetid = obj->objid,
		        targetos = obj->osnum,
			senderid = NULL_OBJID);
  if (mat_type != MAIDMX ) {
    if (module->md_env.matrix_type != MAIDMX ) {
      dim = 4;
      MAmulmx(&loc_msg,&dim,&dim,&dim,module->md_env.matrix, mat,mat);
      MAtypemx( &loc_msg, mat, &mat_type);
      mm = mat;
      mm_type = mat_type;
    }
    else {
      mm = mat;
      mm_type = mat_type;
    }
  }
  else {
    mm = module->md_env.matrix;
    mm_type = module->md_env.matrix_type;
  }
   status =
        om$send(msg = message GRgraphics.GRdisplay(
                             &msg,
                             &mm_type,
                             mm,
                             mode,
                             &module->md_id ),
               targetid = buff.objid,
               targetos = buff.osnum,
               senderid = NULL_OBJID);
}

IGRlong VSfillAttrForm( IGRchar *form_ptr,
		        IGRchar	*input_str    )
{
     IGRint      is_rel;
     IGRboolean  is_default=FALSE, warn1=FALSE, warn2=FALSE;
     IGRdouble   dbl_val, val_t=0.0, T, X, Y, H, C, N;
     IGRchar buffer[100], word[32], *next_buf=NULL;
     if( input_str[0] == '\0' ) 	goto quit;

     strcpy( buffer, input_str );
     FIg_get_state( form_ptr, G_ABS_TOGG, &is_rel );
     VSGetNextWord(buffer, word, 30, &next_buf);
     if( word[0] == '\0' ) strcpy( word, "0.00" );
     FIfld_set_text(form_ptr,G_T,0, 0, word,FALSE);
     sscanf(word,"%lf",&dbl_val);
     if( isalpha(word[0]) ) 
     {
        FIfld_set_value( form_ptr, G_T, 0, 0, plate_thk, FALSE );
        is_default = TRUE;
     }
     else   val_t = dbl_val;
     T = val_t;

     if( is_rel ) 
     {
	if( dbl_val <= 0.0 ) dbl_val = 1;
        if( is_default ) dbl_val *= plate_thk;
	else             dbl_val  = val_t;
        FIfld_set_value( form_ptr, G_T, 0, 0, dbl_val, FALSE );
	T = dbl_val;
     }
     else if( dbl_val <= 0.0 )
     {
	FIfld_set_value( form_ptr, G_T, 0, 0, plate_thk, FALSE );
	T = plate_thk;
     }

     if( next_buf ) strcpy( buffer, next_buf);
     else           goto quit;

     VSGetNextWord(buffer, word, 30, &next_buf);
     if( word[0] == '\0' ) strcpy( word, "0.00" );
     FIfld_set_text(form_ptr,G_A,0, 0, word,FALSE);
     if( next_buf ) strcpy( buffer, next_buf);
     else           goto quit;

     VSGetNextWord(buffer, word, 30, &next_buf);
     if( word[0] == '\0' ) strcpy( word, "0.00" );
     FIfld_set_text(form_ptr,G_B,0, 0, word,FALSE);
     if( next_buf ) strcpy( buffer, next_buf);
     else           goto quit;

     VSGetNextWord(buffer, word, 30, &next_buf);
     if( word[0] == '\0' ) strcpy( word, "0.00" );
     FIfld_set_text(form_ptr,G_V,0, 0, word,FALSE);
     sscanf(word,"%lf",&dbl_val);
     if( is_rel )
     {
        if( is_default ) dbl_val *= plate_thk;
        else             dbl_val *= val_t;
	FIfld_set_value( form_ptr, G_V, 0, 0, dbl_val, FALSE );
     }
     if( next_buf ) strcpy( buffer, next_buf);
     else           goto quit;

     VSGetNextWord(buffer, word, 30, &next_buf);
     if( word[0] == '\0' ) strcpy( word, "0.00" );
     FIfld_set_text(form_ptr,G_LB,0, 0, word,FALSE);
     sscanf(word,"%lf",&dbl_val);
     if( is_rel )
     {
        if( is_default ) dbl_val *= plate_thk;
        else             dbl_val *= val_t;
	FIfld_set_value( form_ptr, G_LB, 0, 0, dbl_val, FALSE );
     }
     if( next_buf ) strcpy( buffer, next_buf);
     else           goto quit;

     VSGetNextWord(buffer, word, 30, &next_buf);
     if( word[0] == '\0' ) strcpy( word, "0.00" );
     FIfld_set_text(form_ptr,G_SB,0, 0, word,FALSE);
     sscanf(word,"%lf",&dbl_val);
     if( is_rel )
     {
        if( is_default ) dbl_val *= plate_thk;
        else             dbl_val *= val_t;
        FIfld_set_value( form_ptr, G_SB, 0, 0, dbl_val, FALSE );
     }
     if( next_buf ) strcpy( buffer, next_buf);
     else           goto quit;

     VSGetNextWord(buffer, word, 30, &next_buf);
     if( word[0] == '\0' ) strcpy( word, "0.00" );
     FIfld_set_text(form_ptr,G_LO,0, 0, word,FALSE);
     sscanf(word,"%lf",&dbl_val);
     if( is_rel )
     {
        if( is_default ) dbl_val *= plate_thk;
        else             dbl_val *= val_t;
        FIfld_set_value( form_ptr, G_LO, 0, 0, dbl_val, FALSE );
     }
     if( next_buf ) strcpy( buffer, next_buf);
     else           goto quit;

     VSGetNextWord(buffer, word, 30, &next_buf);
     if( word[0] == '\0' ) strcpy( word, "0.00" );
     FIfld_set_text(form_ptr,G_SO,0, 0, word,FALSE);
     sscanf(word,"%lf",&dbl_val);
     if( is_rel )
     {
        if( is_default ) dbl_val *= plate_thk;
        else             dbl_val *= val_t;
        FIfld_set_value( form_ptr, G_SO, 0, 0, dbl_val, FALSE );
     }
     if( next_buf ) strcpy( buffer, next_buf);
     else           goto quit;

     VSGetNextWord(buffer, word, 30, &next_buf);
     if( word[0] == '\0' ) strcpy( word, "0.00" );
     FIfld_set_text(form_ptr,G_X,0, 0, word,FALSE);
     sscanf(word,"%lf",&dbl_val);
     if( is_rel )
     {
        if( is_default ) dbl_val *= plate_thk;
        else             dbl_val *= val_t;
	FIfld_set_value( form_ptr, G_X, 0, 0, dbl_val, FALSE );
     }
     X = dbl_val;
     if( next_buf ) strcpy( buffer, next_buf);
     else           goto quit;

     VSGetNextWord(buffer, word, 30, &next_buf);
     if( word[0] == '\0' ) strcpy( word, "0.00" );
     FIfld_set_text(form_ptr,G_Y,0, 0, word,FALSE);
     sscanf(word,"%lf",&dbl_val);
     if( is_rel )
     {
        if( is_default ) dbl_val *= plate_thk;
        else             dbl_val *= val_t;
	FIfld_set_value( form_ptr, G_Y, 0, 0, dbl_val, FALSE );
     }
     Y = dbl_val;
     if( next_buf ) strcpy( buffer, next_buf);
     else           goto quit;

     VSGetNextWord(buffer, word, 30, &next_buf);
     if( word[0] == '\0' ) strcpy( word, "0.00" );
     FIfld_set_text(form_ptr,G_H,0, 0, word,FALSE);
     sscanf(word,"%lf",&dbl_val);
     if( is_rel )
     {
        if( is_default ) dbl_val *= plate_thk;
        else             dbl_val *= val_t;
	FIfld_set_value( form_ptr, G_H, 0, 0, dbl_val, FALSE );
     }
     H = dbl_val;
     if( next_buf ) strcpy( buffer, next_buf);
     else           goto quit;

     VSGetNextWord(buffer, word, 30, &next_buf);
     if( word[0] == '\0' ) strcpy( word, "0.00" );
     FIfld_set_text(form_ptr,G_C,0, 0, word,FALSE);
     sscanf(word,"%lf",&dbl_val);
     if( is_rel )
     {
        if( is_default ) dbl_val *= plate_thk;
        else             dbl_val *= val_t;
	FIfld_set_value( form_ptr, G_C, 0, 0, dbl_val, FALSE );
     }
     C = dbl_val;
     if( next_buf ) strcpy( buffer, next_buf);
     else           goto quit;

     VSGetNextWord(buffer, word, 30, &next_buf);
     if( word[0] == '\0' ) strcpy( word, "0.00" );
     FIfld_set_text(form_ptr,G_N,0, 0, word,FALSE);
     sscanf(word,"%lf",&dbl_val);
     if( is_rel )
     {
        if( is_default ) dbl_val *= plate_thk;
        else             dbl_val *= val_t;
	FIfld_set_value( form_ptr, G_N, 0, 0, dbl_val, FALSE );
     }
     N = dbl_val;
     if( next_buf ) strcpy( buffer, next_buf);
     else           goto quit;

     VSGetNextWord(buffer, word, 30, &next_buf);
     if( word[0] == '\0' ) strcpy( word, "0.00" );
     FIfld_set_text(form_ptr,G_ALLOWANCE,0, 0, word,FALSE);
     sscanf(word,"%lf",&dbl_val);
     if( is_rel )
     {
        if( is_default ) dbl_val *= plate_thk;
        else             dbl_val *= val_t;
	FIfld_set_value( form_ptr, G_ALLOWANCE, 0, 0, dbl_val, FALSE );
     }
     if( next_buf ) strcpy( buffer, next_buf);
     else           goto quit;

     VSGetNextWord(buffer, word, 30, &next_buf);
     if( word[0] == '\0' )  strcpy( word, "R" );
     FIfld_set_text(form_ptr,G_TYPE_ANGLE,0, 0, word,FALSE);
     if( next_buf ) strcpy( buffer, next_buf);

     if( fabs( T-X-Y )   > 0.0001 )    warn1 = TRUE;
     if( fabs( T-H-C-N ) > 0.0001 )    warn2 = TRUE;

     if( warn1 )
     {
	if( !is_rel ) FIfld_set_value( form_ptr, G_T, 0, 0, plate_thk, FALSE );
	else
	{
	   X = T-Y;
	   FIfld_set_value( form_ptr, G_X, 0, 0, X, FALSE );
	}
  	FIg_set_text(form_ptr,G_FI_MSG_FIELD,"Warning: T = X+Y is not matching");
     }

     if( warn2 )
     {
	if( !is_rel ) FIfld_set_value( form_ptr, G_T, 0, 0, plate_thk, FALSE );
	else
	{
	   H = T-C-N;
	   FIfld_set_value( form_ptr, G_H, 0, 0, X, FALSE );
	}
  	FIg_set_text(form_ptr,G_FI_MSG_FIELD,"Warning: T = H+C+N is not matching");
     }

     if( warn1 && warn2 )
     {
	FIg_set_text(form_ptr,G_FI_MSG_FIELD,"Warning: T = X+Y and T = H+C+N are not matching");
     }

quit:
     return 1;
}

/* ************************************************************************** */
int	VShilitePlateAH ( 
			IGRchar			*type,	/* VS_m_ in vsdef.h */
			struct	GRlc_info	*entry,
			struct	LC_action_args	*args,
			enum	GRlocate_action	*action	)
{
long            loc_msg, sts = LC_RELOCATE;
enum GRdpmode   mode = GRhd;
struct GRid	*lchild = NULL;
IGRint		num_ancestors;
IGRuchar	weight=3;
struct GRsymbology symb;

        //c Check if transitional locate action

  if( *action == start_transition || *action == end_transition ) {
    sts = LCptlocact( type, entry, args, action ) ;
    goto wrapup ;
  }
  if ( vs$is_ancestry_valid ( object  = &(entry->located_obj),
                              classid = OPP_VSedge3Datt_class_id ) ) {

      sts = om$send ( msg =  message NDnode.NDget_objects(
                                                ND_IN_BUF | ND_ROOT,
                                                (struct GRid *)NULL,
                                                0,
                                                &lchild,
                                                0,
                                                OM_K_MAXINT,
                                                &num_ancestors ),
                    senderid  = NULL_OBJID,
                    targetid  = entry->located_obj.objid,
                    targetos  = entry->located_obj.osnum);
      if (num_ancestors == 0) {sts = MSSUCC; goto wrapup;}
      VSdispObj(&lchild[0],&(entry->module_info),&mode,1);
     
      sts=om$send(msg = message GRvg.GRgetsymb(
                                                 &loc_msg, &symb),
                    senderid  = NULL_OBJID,
                    targetid  = entry->located_obj.objid,
                    targetos  = entry->located_obj.osnum);
        sts=om$send(msg = message GRvg.GRchgweight(
                                                 &loc_msg, &weight),
                    senderid  = NULL_OBJID,
                    targetid  = entry->located_obj.objid,
                    targetos  = entry->located_obj.osnum);
        sts=om$send(msg = message GRgraphics.GRdisplay(
                             &loc_msg,
                             &(entry->module_info.md_env.matrix_type),
                             entry->module_info.md_env.matrix,
                             &mode,
                             &(entry->module_info.md_id) ),
               targetid = entry->located_obj.objid,
               targetos = entry->located_obj.osnum,
               senderid = NULL_OBJID);
        sts=om$send(msg = message GRvg.GRchgweight(
                                         &loc_msg, &(symb.display_attr.weight)),
                    senderid  = NULL_OBJID,
                    targetid  = entry->located_obj.objid,
                    targetos  = entry->located_obj.osnum);
      sts = LCptlocact ( type, entry, args, action );
#if 0
    }
    else sts = LC_RELOCATE;
#endif
  }
  else sts = LC_RELOCATE;

wrapup :
  return sts;
}

method init_instance  (long *sts){
IGRint	i, status=OM_S_SUCCESS;

  me->edge_attr.obj_id.objid = NULL_OBJID;
  for (i=0; i< ATT_NB_ATT;i++)
    me->list_att[i] = me->old_list_att[i] = 0;

  me->list_att_txt[ATT_IDX_TYPE_ANGLE] = me->word;
  me->list_att_txt[ATT_IDX_PROCESS] = &me->word[50];
  me->list_att_txt[ATT_IDX_SPEC_NB] = &me->word[100];

  me->old_list_att_txt[ATT_IDX_TYPE_ANGLE] = me->word1; 
  me->old_list_att_txt[ATT_IDX_PROCESS] = &me->word1[50];
  me->old_list_att_txt[ATT_IDX_SPEC_NB] = &me->word1[100];

//  VSgetProcSpec("EdgeAttr_setup",me->forms[0].form_ptr,G_PROCESS,G_SPEC_NB);

  VSreadAttrFile("edge_setup",me->forms[0].form_ptr,G_PROCESS,G_SPEC_NB );

  FIg_get_text(me->forms[0].form_ptr,G_PROCESS,
                            me->list_att_txt[ATT_IDX_PROCESS]);
  FIfld_set_default_text(me->forms[0].form_ptr,G_PROCESS,
                         0,0,me->list_att_txt[ATT_IDX_PROCESS],0 );

  FIg_get_text(me->forms[0].form_ptr,G_SPEC_NB,
                                     me->list_att_txt[ATT_IDX_SPEC_NB]);
  FIfld_set_default_text(me->forms[0].form_ptr,G_SPEC_NB,
                         0,0,me->list_att_txt[ATT_IDX_SPEC_NB],0 );

  strcpy(me->list_att_txt[ATT_IDX_TYPE_ANGLE], DEFAULT_ANGLE);
  FIfld_set_default_text(me->forms[0].form_ptr,G_TYPE_ANGLE,
                         0,0,me->list_att_txt[ATT_IDX_TYPE_ANGLE],0 );

  if (me->mytype == 0)
    me->process_step = 0;
  else {
    FIg_erase(me->forms[0].form_ptr,G_TYPE_CHAMF);
    me->process_step = 1;
  }

  if ( status == OM_S_SUCCESS ) goto quit ;
quit:
  return status ;

}

method free_spec_data  (long *sts){
IGRint	i, status=OM_S_SUCCESS;

  for( i=0; i<num_procs; ++i )
  {
     if( spec && spec[i] ) 
     { 
        _FREE( spec[i] );
     }
  }
  _FREE( spec );

  for( i=0; i<num_procs; ++i )
  {
     if( attrib && attrib[i] )
     {
        _FREE( attrib[i] );
     }
  }
  _FREE( attrib );
  _FREE( list );
  num_procs = 0;

  if ( status == OM_S_SUCCESS ) goto quit ;
quit:
  return status ;
}

/********+++++++++++++++++++++++++++++++++++++++++++++++++++++++++*************/

method assign_action_handler (long *sts)
{
  int status;
  status = 1;
  /* states numbered from 0 (zero) */
  /* Could not get this method to accept a plate object, so, commented out    */
  /* it's execute in VSpledatCmd.t file under state GETEDATT.                 */
  if( me->state == 7 ) /* state   locate_plate; allow identification of plate */
    me->action_handler = (char (*)()) NULL;/* This doesn't have desired effect*/
  else
    me->action_handler = (char (*)()) VShilitePlateAH;
  return status;
}

method chg_process_step (long *sts)
{
  int status;
  status = 1;
  dp$erase_hilite( msg = &status ) ;
  FIg_enable(me->forms[0].form_ptr,G_TYPE_CHAMF);
  FIg_enable(me->forms[0].form_ptr,FI_EXECUTE);
  FIg_enable(me->forms[0].form_ptr,FI_ACCEPT);
  FIg_enable(me->forms[0].form_ptr,FI_RESET);
  me->action_handler = (char (*)()) NULL;
  me->process_step = 0;
  return status;
}


/***************************************************************************
/*c This method returns the number of macros in macrosOcId
/*c action getChildMacro(parentId,macName,macrosOcId,numMaxMacros)
****************************************************************************/

method VSgetChldMac(
struct GRid     parentId;               /* I As source object */
char            *macName;               /* I macro name */
struct GRid     *macrosOcId;            /* Grid list allocated by caller*/
IGRint          numMaxMacros;           /* number of ID allocated */
IGRint          *numMacros              /* O number of ID found */
)
{
OMuword         ids_cl;
IGRchar         *theMacroName;
struct GRid     *GridBuffer,theMacroId;
IGRint     	status, i=0, numObjects=0, numMacro=0;

status = OM_E_INVARG;

 if ( !numMacros || !macrosOcId || !macName ) goto wrapup;

 *numMacros = 0;

 status= om$send ( msg =  message NDnode.NDget_objects( ND_IN_BUF |ND_CHILDREN,
                        (struct GRid *)NULL,
                        0,
                        &GridBuffer,
                        0,
                        OM_K_MAXINT,
                        &numObjects),
		senderid	= NULL_OBJID,
                targetid        = parentId.objid,
                targetos        = parentId.osnum);

  __CheckRC( status, 1, "NDnode.NDget_objects", wrapup );
  __DBGpr_objlist( "NDget_objects", numObjects, GridBuffer );

/*
 * keep the nci_macros
 */


 while ((i<numObjects)&&( numMacro<numMaxMacros))  {
        om$get_classid( osnum           = GridBuffer[i].osnum,
                        objid           = GridBuffer[i].objid,
                        p_classid       = &ids_cl       ) ;

//        if( om$is_ancestry_valid( superclassid = OPP_nci_macro_class_id ,
//                                  subclassid   =ids_cl  ) ==OM_S_SUCCESS) {
                status= om$send ( msg = message ACcpx.find_macro(&theMacroId),
				senderid	= NULL_OBJID,
                        	targetid        = GridBuffer[i].objid,
                        	targetos        = GridBuffer[i].osnum);

		__CheckRC( status, 1, "ACcpx.find_macro", wrapup );

                status= om$send ( msg = message ACcpx_defn.ACgive_name(
								&theMacroName),
				senderid	= NULL_OBJID,
                        	targetid        = theMacroId.objid,
                        	targetos        = theMacroId.osnum);

		__CheckRC( status, 1, "ACcpx_defn.ACgive_name", wrapup );
		__DBGpr_str("found macro", theMacroName );
		__DBGpr_obj("id", theMacroId );
                /*
                 *keep correct nci_macro
                 */
                if (!strcmp(theMacroName,macName))      {
                        macrosOcId[numMacro].objid = GridBuffer[i].objid;
                        macrosOcId[numMacro].osnum = GridBuffer[i].osnum;
                        numMacro = numMacro + 1;
                }
//        } /* end if nci_macro */
        i = i + 1;
  } /** end while **/

 *numMacros = numMacro;

wrapup:
	if ( status == OM_S_SUCCESS ) goto quit ;		// for COB
quit:
	return status;

} /*c end method getChildMacro */

method VSplEdAtCmdributes( long * ret )
{

 struct GRmd_env	loc_env;
 struct	GRobj_env	*pltList = NULL;
 IGRint		  	count, status=OM_S_SUCCESS, sts, 
			current_obj;
 IGRlong		l_msg;
 IGRboolean		fl_edge_loop;
 struct edge_set        edge_attrvals;

 SetProc( VSplEdAtCmdributes ) ;	Begin
 
 if ( !ret ) goto wrapup;			//no argument, so leave

 *ret		= OM_S_SUCCESS;
 loc_env	= me->ModuleInfo;
 fl_edge_loop	= (IGRboolean)FALSE;
 	/*
	 * Get located stiffener(s).
	 */
        count = om$dimension_of( varray = me->locObjs ) ;
	if( count <= 0 ) { sts = OM_W_ABORT ; goto wrapup ; }

	if( !( pltList = _MALLOC( count, struct GRobj_env ) ) ) {
		l_msg = EMS_E_NoDynamicMemory ; sts = OM_W_ABORT ; goto wrapup ;
	}

	status = om$send( msg	= message VSlocateCmd.getLocObjs(
						       &l_msg, count, pltList ),
		       targetid = my_id ) ;
	__CheckRC( status, l_msg, "VSlocateCmd.getLocObjs", wrapup ) ;

	edge_attrvals.DTHK   = me->list_att[ATT_IDX_DTHK];
	edge_attrvals.L_OFF  = me->list_att[ATT_IDX_LO];
	edge_attrvals.L_BASE = me->list_att[ATT_IDX_LB];
	edge_attrvals.S_OFF  = me->list_att[ATT_IDX_SO];
	edge_attrvals.S_BASE = me->list_att[ATT_IDX_SB];
	edge_attrvals.A = me->list_att[ATT_IDX_A];
	edge_attrvals.B = me->list_att[ATT_IDX_B];
	edge_attrvals.V = me->list_att[ATT_IDX_V];
	edge_attrvals.X = me->list_att[ATT_IDX_X];
	edge_attrvals.Y = me->list_att[ATT_IDX_Y];
	edge_attrvals.H = me->list_att[ATT_IDX_H];
	edge_attrvals.C = me->list_att[ATT_IDX_C];
	edge_attrvals.N = me->list_att[ATT_IDX_N];
	edge_attrvals.T = me->list_att[ATT_IDX_T];
        if( me->list_att[ATT_IDX_ABS] )	edge_attrvals.is_absolute = TRUE;
        else				edge_attrvals.is_absolute = FALSE;
	edge_attrvals.allowance = me->list_att[ATT_IDX_ALLOWANCE];
	edge_attrvals.add_material = (int) me->list_att[ATT_IDX_TYPE_CHAMF];
	strcpy( edge_attrvals.process, me->list_att_txt[ATT_IDX_PROCESS]);
	strcpy( edge_attrvals.spec_ind, me->list_att_txt[ATT_IDX_SPEC_NB]);
	edge_attrvals.groove_type = me->list_att_txt[ATT_IDX_TYPE_ANGLE][0];

        for ( current_obj=0;current_obj<count;++current_obj ){
	   IGRint               nb_edges=0;
	   struct	GRid	*edgeIds=NULL;

           status = vs$place_or_get_edgeattr( msg        = &l_msg,
                                   	   plate         = pltList[current_obj],
                                   	   edge_attrvals = &edge_attrvals,
                                   	   cst_env       = &me->cstEnv,
					   num_edges     = &nb_edges,
					   edge_list     = &edgeIds    );
	   __CheckRC( status, l_msg, "vs$place_or_get_edgeattr", quit ) ;

           /*
            * Display edges.
            */

           vs$bulk_display( count  = nb_edges,
                            dpmode = GRbd,
                            grids  = edgeIds,
                            theEnv = &me->cstEnv ) ;
	   _FREE( edgeIds );

	}
	status = OM_S_SUCCESS;
wrapup:			////////////// cleanup GOTO

    End
    return ( status );
    
quit:
  return OM_S_SUCCESS;
    
} /*c end method PlEdgAtt */


IGRlong GetObjName(struct GRid *objId, IGRchar *objName)
{
  struct GRid  goId;
  IGRlong sts;

  *objName = 0;

  /* If it is a source, ask graphic for name first
   * Do this to prevent the source object from generating a
   * fake name when the underlying graphic has it's own name
   */
  goId.osnum = NULL;
  goId.objid = NULL;

  sts = om$send(
    msg = message NDnode.ASreturn_go(
      &goId,NULL,NULL
    ),
    senderid = NULL_OBJID,
    targetid = objId->objid,
    targetos = objId->osnum
  );
  if ((sts & 1) && (goId.objid != NULL_OBJID)) {
    *objName = 0;

    vd$get_name(obj = &goId, name = objName);

      printf("Object %d,%d %d,%d '%s'\n",
        objId->osnum,objId->objid,
        goId.osnum,goId.objid,
        objName);

    if (*objName) {
      return MSSUCC;
    }
  }

  /* Ask original objects */
/*
  vd$get_name(obj = objId, name = objName);
printf("Object %d,%d '%s'\n",objId->osnum,objId->objid,objName);
*/
  return MSSUCC;
}


method SetPlate(int *msg)
{
  int		i, sts, num, numRows=0;
  IGRchar       objName[DI_PATH_MAX];
  struct GRid	*parent_list=NULL;


  SetProc( SetPlate ); Begin


  set_flag  = 0;
  add_flag  = 0;
  del_flag  = 0;
  ptlcnt    = 0;


  /* Clear plate field of previous data */
  FIfld_set_num_rows(me->forms[0].form_ptr,G_FLD_PLATES,numRows);

  sts = om$send ( msg =  message NDnode.NDget_objects(
                                 ND_IN_BUF | ND_ROOT,
                                 (struct GRid *)NULL,
                                 0,
                                 &parent_list,
                                 0,
                                 OM_K_MAXINT,
                                 &num ),
	    targetid  = me->edge_attr.obj_id.objid,
            targetos  = me->edge_attr.obj_id.osnum);

  if (!(sts&1)) {
    goto quit;
  }

  /* First three parents are hardcoded into this macro's definition */

  if( num > 3 )
  {
    __DBGpr_com("");
    __DBGpr_com("Parent List of plates, in SetPlate");
  }

  for( i=3; i<num; i++)
  {
    VSgetName( &parent_list[i], objName);
    if (*objName == 0) {
      strcpy(objName,"Defined");
    }

    __DBGpr_str("  ", objName );
    __DBGpr_ith_obj("  ", i, parent_list );

    FIfld_set_text(me->forms[0].form_ptr,G_FLD_PLATES,numRows,0,objName,0);
    numRows++;

    /* Store id away */

    me->ptl[ptlcnt] = parent_list[i];
    ptlcnt++;

  } /* for */

  set_flag = 1;


quit:

  End

  *msg = OM_S_SUCCESS;
  return sts;

} /* SetPlate */


method DeletePlate(int *msg)
{
  IGRint rowNum,pos,i;
  IGRlong sts;


  SetProc( DeletePlate ); Begin


  sts = OM_S_SUCCESS;

  if( !(set_flag) )
  {
    UI_status(" Select Edge Attribute Macro   First !!!");
    goto quit;
  }

  *msg = MSSUCC;

  sts = FIfld_get_active_row(me->forms[0].form_ptr,G_FLD_PLATES,&rowNum,&pos);
  if (sts != FI_SUCCESS) return MSSUCC;

#ifdef vsDEBUG
  printf("\n	Plate object to be deleted = %d,  rowNum = %d\n\n", me->ptl[rowNum].objid, rowNum);
#endif

  FIfld_delete_rows(me->forms[0].form_ptr,G_FLD_PLATES,rowNum,1);

/*
  printf("  DeletePlate:  tl list before delete\n");
  for(i = 0; i < ptlcnt; i++) {
    printf("  me->ptl[%d].objid = %d\n", i, me->ptl[i].objid);
  }
*/

  /* Revise plate list starting with row to delete */

  for( i=0+rowNum; i < ptlcnt; i++) {
    me->ptl[i] = me->ptl[i+1]; 
  }

  ptlcnt--;

/*
  printf("  DeletePlate:  tl list after delete\n");
  for(i = 0; i < ptlcnt; i++) {
    printf("  me->ptl[%d].objid = %d\n", i, me->ptl[i].objid);
  }
*/

  del_flag = 1;


quit:

  End

  return sts;
}

/* -----------------------------------------------------
 * Hooks object to form
 * Always returns success
 */
method AddPlate  (long *msg)
{
  int		i, numRows, num;
  IGRchar	objName[DI_PATH_MAX];
  IGRlong	sts;
  struct GRid	objId, asId, *parent_list=NULL;


  SetProc( AddPlate ); Begin


  sts = OM_S_SUCCESS;

  if( !(set_flag) )
  {
    UI_status(" Select Edge Attribute Macro   First !!!");
    goto quit;
  }

  objId = me->event1.located_object[0].located_obj;

  /* Source It, that is, make a link between parent object and macro  */
  as$make_source( go_grid = objId,
                  mod_env = &me->event1.located_object[0].module_info,
                  as_os   = me->ModuleInfo.md_id.osnum,
                  as_grid = &asId);

  /* asId is the object id to use in the list of macro parents! */

  sts = om$send ( msg =  message NDnode.NDget_objects(
                                 ND_IN_BUF | ND_ROOT,
                                 (struct GRid *)NULL,
                                 0,
                                 &parent_list,
                                 0,
                                 OM_K_MAXINT,
                                 &num ),
	    targetid  = me->edge_attr.obj_id.objid,
            targetos  = me->edge_attr.obj_id.osnum);

  if (!(sts&1)) {
     goto quit;
  }

  for( i=3; i<num; i++)
  {
    if( parent_list[i].objid == asId.objid )
    {
      UI_status(" Plate picked duplicates an existing macro plate");
      goto quit;
    }
  }

  /* find the object name */

  VSgetName(&asId, objName);
  if (*objName == 0) {
    strcpy(objName,"Defined");
  }

  FIfld_get_num_rows(me->forms[0].form_ptr,G_FLD_PLATES,&numRows);

  FIfld_set_text(me->forms[0].form_ptr,G_FLD_PLATES,numRows,0,objName,0);

  /* Store id away */

  __DBGpr_com("\n");
  __DBGpr_obj("Plate object to be added", asId );
  __DBGpr_com("\n");

  me->ptl[ptlcnt]   = asId;
  ptlcnt++;

/*
  printf("\n   Parent List, in AddPlate:\n");
  for( i=0; i<ptlcnt; i++ )
   printf("\n  me->ptl[%d].objid = %d\n", i, me->ptl[i].objid);
*/

  ASend_fence();

  add_flag = 1;


quit:

  End

  *msg = OM_S_SUCCESS;
  return sts;
}


method form_notification ( int form_label ; int gadget_label ; double value ;
                           char * form_ptr )
{
  int  i, j, i_msg, status = OM_S_SUCCESS, cur_proc=0, list_ind=0;
  char tmp1[50], tmp2[50];
  struct GRid 	basecrvId, offsetcrvId;

  SetProc( form_notification ); Begin


  if( form_ptr == NULL ) return( OM_E_INVARG );

  switch (gadget_label) {

    case FI_EXECUTE :
    case FI_ACCEPT :
      status = om$send(msg = message VSplEdAtCmd.save_all(&me->ret),
                     targetid = my_id);
      if (!(status&me->ret&1)) {
          FIg_set_state_off(form_ptr,gadget_label);
          ex$message( field = ERROR_FIELD,
		      in_buff = "Placement failed" );
          goto quit;
      }

      ex$message( field = ERROR_FIELD,
                  in_buff = "" );

      if (me->process_step == 0) {
        status = om$send(msg = message VSplEdAtCmd.VSplEdAtCmdributes(&me->ret),
                             targetid = my_id);
        if (!(status&me->ret&1)) {
          FIg_set_state_off(form_ptr,gadget_label);
          ex$message( field = ERROR_FIELD,
		      in_buff = "Placement failed" );
          goto quit;
        }
        me->process_step = 1;
        FIg_disable(form_ptr,G_TYPE_CHAMF);
      }
      else {
        status = om$send(msg = message VSplEdAtCmd.modify_mac(&me->ret),
                             targetid = my_id);
      }

      FIg_set_state_off(form_ptr,gadget_label);
      if ( gadget_label == FI_EXECUTE )
      {  _put_response(resp = LOCATE_EDGE); }
      else
      {  _put_response(resp = TERMINATE); }

      break;

    case G_SWAP:
        FIg_get_text(form_ptr,G_LO,tmp1);
        FIg_get_text(form_ptr,G_LB,tmp2);
        FIfld_set_text(form_ptr,G_LO,0, 0, tmp2,FALSE);
        FIfld_set_text(form_ptr,G_LB,0, 0, tmp1,FALSE);

        FIg_get_text(form_ptr,G_SO,tmp1);
        FIg_get_text(form_ptr,G_SB,tmp2);
        FIfld_set_text(form_ptr,G_SO,0, 0, tmp2,FALSE);
        FIfld_set_text(form_ptr,G_SB,0, 0, tmp1,FALSE);

        FIg_get_text(form_ptr,G_A,tmp1);
        FIg_get_text(form_ptr,G_B,tmp2);
        FIfld_set_text(form_ptr,G_A,0, 0, tmp2,FALSE);
        FIfld_set_text(form_ptr,G_B,0, 0, tmp1,FALSE);

        FIg_get_text(form_ptr,G_X,tmp1);
        FIg_get_text(form_ptr,G_Y,tmp2);
        FIfld_set_text(form_ptr,G_X,0, 0, tmp2,FALSE);
        FIfld_set_text(form_ptr,G_Y,0, 0, tmp1,FALSE);

        FIg_get_text(form_ptr,G_H,tmp1);
        FIg_get_text(form_ptr,G_N,tmp2);
        FIfld_set_text(form_ptr,G_H,0, 0, tmp2,FALSE);
        FIfld_set_text(form_ptr,G_N,0, 0, tmp1,FALSE);
        FIg_set_state_off(form_ptr,gadget_label);
	break;

    case G_COPY_PARM:
	FIg_disable(form_ptr, G_INCRIMENT );
	FIg_disable(form_ptr, G_DECRIMENT );
	_put_response(resp = VS_K_LOAD_ATTR );
	break;

    case G_INCRIMENT:
        dp$erase_hilite( msg = &status ) ;
	++me->cur_edge;
	me->event1.located_object[0].located_obj = me->edge_list[me->cur_edge];
	vs$bulk_display( dpmode = GRhd, 
			 grids  = &me->edge_list[me->cur_edge],
			 theEnv = &me->edge_attr.mod_env );
        status = om$send( msg = message VSplEdAtCmd.control_edge( &me->ret ),
			targetid = my_id );

        status = om$send( msg = message VSplEdAtCmd.SetPlate( &me->ret ),
			targetid = my_id );
        if( !(status&1) ) printf("\n   SetPlate failed\n");

	FIg_set_state_off(form_ptr,gadget_label);
	break;

    case G_DECRIMENT:
        dp$erase_hilite( msg = &status ) ;
	--me->cur_edge;
	me->event1.located_object[0].located_obj = me->edge_list[me->cur_edge];
	vs$bulk_display( dpmode = GRhd, 
			 grids  = &me->edge_list[me->cur_edge],
			 theEnv = &me->edge_attr.mod_env );
        status = om$send( msg = message VSplEdAtCmd.control_edge( &me->ret ),
			targetid = my_id );

        status = om$send( msg = message VSplEdAtCmd.SetPlate( &me->ret ),
			targetid = my_id );
        if( !(status&1) ) printf("\n   Set Plate failed\n");

	FIg_set_state_off(form_ptr,gadget_label);
	break;

    case G_PROCESS:
        FIfld_get_num_rows( form_ptr, G_SPEC_NB, &j );
        for(i=0; i<j; ++i)
          FIfld_set_list_text( form_ptr, G_SPEC_NB, i, 0, (unsigned char *)"",FALSE );

        FIg_get_text(form_ptr,gadget_label,tmp1);
        for( i=0; i<num_procs; ++i )
        {
	  if( !strcmp( tmp1, list[i] ) )
          {
	     FIfld_set_num_rows ( form_ptr, G_SPEC_NB, proc_len[i] );
             for( j=0; j<proc_len[i]; ++j )
  	     {
     		IGRint  index;
     		IGRchar *next_buf=NULL, array[80], temp_arr[100];
     		tmp2[0] = '\0';
		strcpy( temp_arr, spec[i][j] );
     	  	VSGetNextWord( spec[i][j], tmp2, 30,&next_buf );
		strcpy( spec[i][j], temp_arr );

     		for( index=0; index < j; ++index )
     		{
		   strcpy( temp_arr, spec[i][index] );
		   VSGetNextWord( spec[i][index],  array, 30,&next_buf );
		   strcpy( spec[i][index], temp_arr );
		   if( !strcmp( tmp2, array ) ) break;
     		}
     		if( index != j ) continue;

     	        if (list_ind == 0 ) 
                {
		   FIfld_set_list_text(form_ptr,G_SPEC_NB,list_ind, 0, (unsigned char *)tmp2,TRUE);
	           FIfld_set_text(form_ptr,G_SPEC_NB,0, 0, tmp2,FALSE);
                }
     		else
		   FIfld_set_list_text(form_ptr,G_SPEC_NB,list_ind,0,(unsigned char *)tmp2,FALSE);
		++list_ind;
             }
             break;
          }
        }

    case G_SPEC_NB:
    case G_ABS_TOGG:
        FIg_get_text(form_ptr,G_PROCESS,tmp1);
        for( i=0; i<num_procs; ++i )
	  if( !strcmp( tmp1, list[i] ) ) { cur_proc=i; break; }

        FIg_get_text(form_ptr,G_SPEC_NB,tmp1);
  	FIg_get_state( form_ptr, G_ABS_TOGG, &i);

	if( i==0 ) strcat( tmp1, " ABS" );
	else       strcat( tmp1, " REL" );

        for( i=0; i<proc_len[cur_proc]; ++i )
        {
	   if( !strcmp( tmp1, spec[cur_proc][i] ) )
           {
	      VSfillAttrForm( form_ptr, attrib[cur_proc][i] );
	      break;
           }
        }
	break;

    case G_ADD_PLATES:
          _put_response( resp = gadget_label );
        break;

    case G_DEL_PLATES:
          status = om$send( msg = message VSplEdAtCmd.DeletePlate(&i_msg),
                            targetid = my_id );
        break;

    case G_BEVEL_CURVES:

        /* Obtain top and bottom bevel curves along macro's edge_3d parent */
        status = VSgetBevelCurves(me->edge_attr.obj_id,
                                  me->edge_attr.mod_env,
                                  &basecrvId,
                                  &offsetcrvId );
        if( !(status&1) ) printf("\n   Bevel Curves not obtained\n");

        __DBGpr_obj("basecrvId", basecrvId);
        __DBGpr_obj("offsetcrvId", offsetcrvId);

	break;

    case FI_CANCEL :
      ptlcnt = 0;
      FIg_set_state_off(form_ptr,FI_CANCEL);
      _put_response(resp = TERMINATE);
      break;

    case FI_RESET :
      ptlcnt = 0;
      if (!me->mytype && me->process_step)
        FIg_disable(form_ptr,G_TYPE_CHAMF);
      break;
  }

quit:

      End ;
      return status;
}

method DispArrowGadgets (long *ret)
{
struct GRobj_env	surf_obj,GObj, *pltList = NULL;
       int		i,dim,status,count,index=-1;
       OMuword          TEMP_cl;
       long		sts, l_msg;
       struct ret_struct rs;

        count = om$dimension_of( varray = me->locObjs ) ;
	if( count <= 0 ) { sts = OM_W_ABORT ; goto quit ; }

	if( !( pltList = _MALLOC( count, struct GRobj_env ) ) ) {
		l_msg = EMS_E_NoDynamicMemory ; sts = OM_W_ABORT ; goto quit ;
	}

	sts = om$send( msg	= message VSlocateCmd.getLocObjs(
						       &l_msg, count, pltList ),
		       targetid = my_id ) ;
	__CheckRC( sts, l_msg, "VSlocateCmd.getLocObjs", quit ) ;

  if(count){

  FIg_enable(me->forms[0].form_ptr,FI_EXECUTE);
  FIg_enable(me->forms[0].form_ptr,FI_ACCEPT);
  FIg_enable(me->forms[0].form_ptr,FI_RESET);

  // Get the plate thickness
  sts = om$send(  msg      = message NDmacro.ACgive_structure
                              ( &status, &index, VS_K_plThcknsAttr,
				&rs, &pltList[0].mod_env ),
                        targetid = pltList[0]._objid,
                        targetos = pltList[0]._osnum  );
  __CheckRC( sts, status, "NDmacro.ACgive_structure", quit );
  plate_thk = rs.var.root_pm_st.value;
/*
  me->list_att[ATT_IDX_T] = rs.var.root_pm_st.value;

  FIfld_set_value( me->forms[0].form_ptr, G_T, 0, 0, 
			(double)me->list_att[ATT_IDX_T], FALSE );
  FIg_set_default_value( me->forms[0].form_ptr, G_T, me->list_att[ATT_IDX_T] );
*/

   // Unhighlight old side and normal.
  dp$erase_hilite( msg = &status ) ;

  for (i=0;i<count;i++)
  {
    om$get_classid( osnum           = pltList[i]._osnum  ,
                    objid           = pltList[i]._objid  ,
                    p_classid       = &TEMP_cl      ) ;

    GObj = pltList[i];
    if( om$is_ancestry_valid( superclassid = OPP_ACpretend_class_id,
                                  subclassid    = TEMP_cl ) == OM_S_SUCCESS ) {

        __DBGpr_obj( "got reference object before ret_go",GObj.obj_id );

        status = om$send( msg  = message NDnode.ASreturn_go(
                                        &GObj.obj_id,
                                        &GObj._matrix_type,
                                         GObj._matrix ),
                        senderid = NULL_OBJID,
                        targetid = pltList[i]._objid,
                        targetos = pltList[i]._osnum );

        if (!(status&1)) continue;

        status = om$get_classid( osnum   = GObj.obj_id.osnum  ,
                                 objid   = GObj.obj_id.objid  ,
                                 p_classid   = &TEMP_cl);
    }
    if( om$is_ancestry_valid( superclassid  = OPP_VSplate_class_id,
                              subclassid    = TEMP_cl ) == OM_S_SUCCESS ) {

        status= om$send( msg = message NDmacro.ACreturn_foot(
                                        &l_msg,
                                        VS_K_plBotSfPath,
                                        &surf_obj.obj_id,
                                        &surf_obj.mod_env.md_env.matrix_type,
                                        surf_obj.mod_env.md_env.matrix ),
                        senderid = NULL_OBJID,
                        targetid = GObj.obj_id.objid,
                        targetos = GObj.obj_id.osnum ) ;
        if (!(status&l_msg&1)) continue;
        if (GObj.mod_env.md_env.matrix_type != MAIDMX) {
          dim = 4;
          MAmulmx(&status,&dim,&dim,&dim,GObj.mod_env.md_env.matrix,
                  surf_obj.mod_env.md_env.matrix,
                  surf_obj.mod_env.md_env.matrix);
          MAtypemx( &status, surf_obj.mod_env.md_env.matrix,
                    &surf_obj.mod_env.md_env.matrix_type);
        }

    }
    else surf_obj = GObj;

    vs$bulk_display(count = 1,
                    dpmode = GRhdo,
                    objenvs = &surf_obj);

    // Display normal
    VSdisplaySurfaceNormal(&status,&surf_obj,TRUE,&me->ActiveDisplay,GRhd);
          ex$message( field = ERROR_FIELD,
		      in_buff = "Base" );
  }
  FIg_disable( me->forms[0].form_ptr, G_INCRIMENT );
  FIg_disable( me->forms[0].form_ptr, G_DECRIMENT );
  for( i=(strlen(spec[0][0])); i>0; --i )
     if( spec[0][0][i] == ' ' || spec[0][0][i] == '\t' ) break;
  if( spec[0][0][i+1] == 'R' )
	 FIg_set_state(me->forms[0].form_ptr,G_ABS_TOGG, 1 );
  else
         FIg_set_state(me->forms[0].form_ptr,G_ABS_TOGG, 0 );

  VSfillAttrForm( me->forms[0].form_ptr, attrib[0][0] );
  FIf_display( me->forms[0].form_ptr );
  FIfld_set_num_rows( me->forms[0].form_ptr, G_FLD_PLATES, 5);
 }
 else	sts=VS_NOOBJ_SELECTED;

quit:
  return sts;
}

method form_pos (long *sts)
{
  if( !spec && !attrib )
       VSreadAttrFile("edge_setup",me->forms[0].form_ptr,
					G_PROCESS,G_SPEC_NB );
  if (xx != -1 ) {
    FIf_set_location(me->forms[0].form_ptr, xx,yy);
    FIf_set_size(me->forms[0].form_ptr, heig,wid);
    FIf_set_screen(me->forms[0].form_ptr, screen);
  }
  FIg_enable(me->forms[0].form_ptr,G_LO);
  FIg_enable(me->forms[0].form_ptr,G_SO);
  FIg_enable(me->forms[0].form_ptr,G_LB);
  FIg_enable(me->forms[0].form_ptr,G_SB);
  FIg_enable(me->forms[0].form_ptr,G_A);
  FIg_enable(me->forms[0].form_ptr,G_TYPE_ANGLE);
  FIg_enable(me->forms[0].form_ptr,G_TYPE_CHAMF);
  FIg_enable(me->forms[0].form_ptr,G_B);
  FIg_enable(me->forms[0].form_ptr,G_V);
  FIg_enable(me->forms[0].form_ptr,G_Y);
  FIg_enable(me->forms[0].form_ptr,G_X);
  FIg_enable(me->forms[0].form_ptr,G_H);
  FIg_enable(me->forms[0].form_ptr,G_C);
  FIg_enable(me->forms[0].form_ptr,G_N);
  FIg_enable(me->forms[0].form_ptr,G_T);
  FIg_enable(me->forms[0].form_ptr,G_ALLOWANCE);
  FIg_enable(me->forms[0].form_ptr,G_PROCESS);
  FIg_enable(me->forms[0].form_ptr,G_SPEC_NB);
  FIg_enable(me->forms[0].form_ptr,FI_CANCEL);
  FIg_enable(me->forms[0].form_ptr,FI_EXECUTE);
  FIg_enable(me->forms[0].form_ptr,FI_ACCEPT);
  FIg_enable(me->forms[0].form_ptr,FI_RESET);
  FIg_enable(me->forms[0].form_ptr,G_COPY_PARM);
  FIg_enable(me->forms[0].form_ptr,G_SWAP);
  FIg_enable(me->forms[0].form_ptr,G_ABS_TOGG);
  FIg_enable(me->forms[0].form_ptr,G_SPEC_NB);
  if (me->mytype == 0)
  {
    FIg_erase(me->forms[0].form_ptr, G_MOD_EDGE);
    FIg_erase(me->forms[0].form_ptr, G_FLD_PLATES);
    FIg_erase(me->forms[0].form_ptr, G_NAM_PLATES);
    FIg_erase(me->forms[0].form_ptr, G_ADD_PLATES);
    FIg_erase(me->forms[0].form_ptr, G_DEL_PLATES);
    FIg_erase(me->forms[0].form_ptr, G_BEVEL_CURVES);
    FIg_display(me->forms[0].form_ptr, G_PL_EDGE);
  }
  else 
  {
    FIg_enable(me->forms[0].form_ptr,G_INCRIMENT);
    FIg_enable(me->forms[0].form_ptr,G_DECRIMENT);
    FIg_erase(me->forms[0].form_ptr, G_PL_EDGE);
    FIg_display(me->forms[0].form_ptr, G_MOD_EDGE);
  }
  return OM_S_SUCCESS;
}

method erase_hilite (long *sts)
{
int     status,loc_msg;

  status = dp$erase_hilite(msg=&loc_msg,
                           objid = me->ModuleInfo.md_id.objid,
                           osnum = me->ModuleInfo.md_id.osnum);

  FIf_get_size(me->forms[0].form_ptr,&heig,&wid);
  FIf_get_location(me->forms[0].form_ptr,&xx,&yy);
  FIf_get_screen(me->forms[0].form_ptr,&screen);
  FIg_disable(me->forms[0].form_ptr,FI_CANCEL);
  FIg_disable(me->forms[0].form_ptr,FI_EXECUTE);
  FIg_disable(me->forms[0].form_ptr,FI_ACCEPT);
  FIg_disable(me->forms[0].form_ptr,FI_RESET);
  FIg_disable(me->forms[0].form_ptr,G_LO);
  FIg_disable(me->forms[0].form_ptr,G_SO);
  FIg_disable(me->forms[0].form_ptr,G_LB);
  FIg_disable(me->forms[0].form_ptr,G_SB);
  FIg_disable(me->forms[0].form_ptr,G_A);
  FIg_disable(me->forms[0].form_ptr,G_TYPE_ANGLE);
  FIg_disable(me->forms[0].form_ptr,G_TYPE_CHAMF);
  FIg_disable(me->forms[0].form_ptr,G_B);
  FIg_disable(me->forms[0].form_ptr,G_V);
  FIg_disable(me->forms[0].form_ptr,G_Y);
  FIg_disable(me->forms[0].form_ptr,G_X);
  FIg_disable(me->forms[0].form_ptr,G_H);
  FIg_disable(me->forms[0].form_ptr,G_C);
  FIg_disable(me->forms[0].form_ptr,G_N);
  FIg_disable(me->forms[0].form_ptr,G_T);
  FIg_disable(me->forms[0].form_ptr,G_ALLOWANCE);
  FIg_disable(me->forms[0].form_ptr,G_PROCESS);
  FIg_disable(me->forms[0].form_ptr,G_COPY_PARM);
  FIg_disable(me->forms[0].form_ptr,G_INCRIMENT);
  FIg_disable(me->forms[0].form_ptr,G_DECRIMENT);
  FIg_disable(me->forms[0].form_ptr,G_SWAP);
  FIg_disable(me->forms[0].form_ptr,G_ABS_TOGG);
  FIg_disable(me->forms[0].form_ptr,G_SPEC_NB);
  return status;
}

method dis_en_able_gadgets (long *sts)
{
  IGRint count;

  count = om$dimension_of( varray = me->locObjs ) ;

  if (!count) {
    FIg_disable(me->forms[0].form_ptr,FI_EXECUTE);
    FIg_disable(me->forms[0].form_ptr,FI_ACCEPT);
    FIg_disable(me->forms[0].form_ptr,FI_RESET);
  }
  if (me->edge_attr.obj_id.objid == NULL_OBJID && me->process_step == 1) {
    FIg_disable(me->forms[0].form_ptr,FI_EXECUTE);
    FIg_disable(me->forms[0].form_ptr,FI_ACCEPT);
    FIg_disable(me->forms[0].form_ptr,FI_RESET);
  }
  return OM_S_SUCCESS;
}

method control_edge (long *sts)
{
  struct GRid 	   *lchild=NULL, *ext=NULL;
  int         	   j,i,num=0, num1=0, edge_ind;
  long		   l_msg;
  struct ACrg_coll ACrg[ATT_NB_ATT];
  char             tmp[50];
  long 		   status;

  traceFlag = VDdbgGetTraceFlag(120);
  if (traceFlag) {
    printf(">>> VSpledatCmd.control_edge %d State = %d\n",ATT_NB_ATT,me->state);
  }

  if( me->state != 3 ) {
    me->edge_attr.obj_id  = me->event1.located_object[0].located_obj;
    me->edge_attr.mod_env = me->event1.located_object[0].module_info;
    memcpy((IGRchar *) me->edge_attr.mod_env.md_env.matrix,
	   (IGRchar *) me->event1.located_object[0].module_info.md_env.matrix,
	   (IGRint) (16 * sizeof(IGRdouble)) );

    if (traceFlag) {
      vdobj$Print(objOE = &me->edge_attr);
    }
      
    status = om$send ( msg =  message NDnode.NDget_objects(
							   ND_IN_BUF | ND_ROOT,
							   (struct GRid *)NULL,
							   0,
							   &lchild,
							   0,
							   OM_K_MAXINT,
							   &num ),
		       targetid  =me->edge_attr.obj_id.objid,
		       targetos  = me->edge_attr.obj_id.osnum);
    if (!(status&1)) {
      *sts = MY_ERROR;
      if (traceFlag) printf("Problem getting parents\n");  
      goto quit;
    }

    if (num >= ATT_T_IDX_BOX) {
      me->old_box = lchild[ATT_T_IDX_BOX];
      status = om$send(msg = message ACrg_collect.AClist_attribute
		       (&l_msg,ATT_NB_ATT,ACrg,&num),
                       targetid = lchild[ATT_T_IDX_BOX].objid,
                       targetos = lchild[ATT_T_IDX_BOX].osnum);
      
      if (traceFlag) vdobj$Print(objID = &lchild[ATT_T_IDX_BOX]);
     
      if (!(status&l_msg&1)) {
	*sts = MY_ERROR;
        if (traceFlag) printf("Problem getting attribute list\n");
	goto quit;
      }
    }
    else {
      *sts = MY_ERROR;
      if (traceFlag) printf("Problem getting parents, num = %d, ATT_T_IDX_BOX = %d\n",
			    num,ATT_T_IDX_BOX);
      goto quit;
    }

    status = om$send ( msg =  message NDnode.NDget_objects(
							   ND_IN_BUF | ND_ROOT,
							   (struct GRid *)NULL,
							   0,
							   &ext,
							   0,
							   0,
							   &num1 ),
		       targetid  = lchild[1].objid,
		       targetos  = lchild[1].osnum );

    status = VSgetChildrenGoThruPretends( &l_msg,  &ext[0], &num1, &lchild );
    edge_ind = 0;
    for (i=0;i<num1;i++)
    {
      if( vs$is_ancestry_valid( object  = lchild + i,
				classid = OPP_VSedge3Datt_class_id ) )
      {
        lchild[edge_ind] = lchild[i];
	++edge_ind;
      }
    }
    if (traceFlag) printf("Edges Found %d\n",edge_ind);
    
    me->edge_count = edge_ind;
    om$vla_set_dimension(varray = me->edge_list,
			 size   = me->edge_count );
    if( !me->edge_list ) {
      if (traceFlag) printf("Problem allocating edge_list\n");
      goto quit;
    }
    
    for( i=0;i<edge_ind; i++ ) {
      me->edge_list[i] = lchild[i];
      if( me->edge_list[i].objid == me->edge_attr.obj_id.objid )
      {
	me->cur_edge = i;
      }
    }

    if( !me->cur_edge ) FIg_disable(me->forms[0].form_ptr,G_DECRIMENT );
    else		FIg_enable (me->forms[0].form_ptr,G_DECRIMENT );
    
    if( me->cur_edge==(me->edge_count-1) ) FIg_disable(me->forms[0].form_ptr,G_INCRIMENT );
    else			           FIg_enable (me->forms[0].form_ptr,G_INCRIMENT );

    if (traceFlag) {
      printf("Current edge is %d of %d\n",me->cur_edge,me->edge_count);
    }
   
    for (i=0;i<num;i++)
    {
      if (
	  i == ATT_IDX_TYPE_ANGLE ||
	  i == ATT_IDX_PROCESS ||
	  i == ATT_IDX_SPEC_NB 
	  ) {
	strcpy(me->list_att_txt[i],ACrg[i].desc.value.att_txt);
	strcpy(me->old_list_att_txt[i],ACrg[i].desc.value.att_txt);
      }
      else
	me->list_att[i] = me->old_list_att[i]=ACrg[i].desc.value.att_exp;
    }
    FIf_display( me->forms[0].form_ptr );
  }
  else // State == 3
  {
    struct GRid temp_obj;
    temp_obj = me->event1.located_object[0].located_obj;
    status = om$send ( msg =  message NDnode.NDget_objects(
							   ND_IN_BUF | ND_ROOT,
							   (struct GRid *)NULL,
							   0,
							   &lchild,
							   0,
							   OM_K_MAXINT,
							   &num ),
		       targetid  = temp_obj.objid,
		       targetos  = temp_obj.osnum);
    if (!(status&1)) {
      *sts = MY_ERROR;
      goto quit;
    }
    if (num >= ATT_T_IDX_BOX) {
      status = om$send(msg = message ACrg_collect.AClist_attribute
		       (&l_msg,ATT_NB_ATT,ACrg,&num),
                       targetid = lchild[ATT_T_IDX_BOX].objid,
                       targetos = lchild[ATT_T_IDX_BOX].osnum);
      if (!(status&l_msg&1)) {
	*sts = MY_ERROR;
	goto quit;
      }

    }
  }

  // The processing
  if ((j=VSseekFields(ACrg,num,ATT_LO)) != -1) {
    sprintf(tmp,"%.2lf",ACrg[j].desc.value.att_exp);
    FIfld_set_text        (me->forms[0].form_ptr,G_LO,0,0, tmp,FALSE);
    FIfld_set_default_text(me->forms[0].form_ptr,G_LO,0,0,tmp,0 );
  }
  if ((j=VSseekFields(ACrg,num,ATT_LB)) != -1) {
    sprintf(tmp,"%.2lf",ACrg[j].desc.value.att_exp);
    FIfld_set_text        (me->forms[0].form_ptr,G_LB,0,0, tmp,FALSE);
    FIfld_set_default_text(me->forms[0].form_ptr,G_LB,0,0,tmp,0 );
  }
  if ((j=VSseekFields(ACrg,num,ATT_SO)) != -1) {
    sprintf(tmp,"%.2lf",ACrg[j].desc.value.att_exp);
    FIfld_set_text        (me->forms[0].form_ptr,G_SO,0,0, tmp,FALSE);
    FIfld_set_default_text(me->forms[0].form_ptr,G_SO,0,0,tmp,0 );
  }
  if ((j=VSseekFields(ACrg,num,ATT_SB)) != -1) {
    sprintf(tmp,"%.2lf",ACrg[j].desc.value.att_exp);
    FIfld_set_text        (me->forms[0].form_ptr,G_SB,0,0, tmp,FALSE);
    FIfld_set_default_text(me->forms[0].form_ptr,G_SB,0,0,tmp,0 );
  }
  if ((j=VSseekFields(ACrg,num,ATT_A)) != -1) {
    sprintf(tmp,"%.2lf",ACrg[j].desc.value.att_exp);
    FIfld_set_text        (me->forms[0].form_ptr,G_A,0,0, tmp,FALSE);
    FIfld_set_default_text(me->forms[0].form_ptr,G_A,0,0,tmp,0 );
  }
  if ((j=VSseekFields(ACrg,num,ATT_TYPE_ANGLE)) != -1) {
    FIfld_set_text        (me->forms[0].form_ptr,G_TYPE_ANGLE,0,0,ACrg[j].desc.value.att_txt, FALSE);
    FIfld_set_default_text(me->forms[0].form_ptr,G_TYPE_ANGLE,0,0,ACrg[j].desc.value.att_txt,0 );
  }
  if ((j=VSseekFields(ACrg,num,ATT_TYPE_CHAMF)) != -1) {
    FIg_set_state        (me->forms[0].form_ptr,G_TYPE_CHAMF,(int) ACrg[j].desc.value.att_exp);
    FIg_set_default_value(me->forms[0].form_ptr,G_TYPE_CHAMF,ACrg[j].desc.value.att_exp);
  }
  if ((j=VSseekFields(ACrg,num,ATT_B)) != -1) {
    sprintf(tmp,"%.2lf",ACrg[j].desc.value.att_exp);
    FIfld_set_text(me->forms[0].form_ptr,G_B,0,
		   0, tmp,FALSE);
    FIfld_set_default_text(me->forms[0].form_ptr,G_B,0,0,tmp,0 );
  }
  if ((j=VSseekFields(ACrg,num,ATT_V)) != -1) {
    sprintf(tmp,"%.2lf",ACrg[j].desc.value.att_exp);
    FIfld_set_text(me->forms[0].form_ptr,G_V,0,
		   0, tmp,FALSE);
    FIfld_set_default_text(me->forms[0].form_ptr,G_V,0,0,tmp,0 );
  }
  if ((j=VSseekFields(ACrg,num,ATT_Y)) != -1) {
    sprintf(tmp,"%.2lf",ACrg[j].desc.value.att_exp);
    FIfld_set_text(me->forms[0].form_ptr,G_Y,0,
		   0, tmp,FALSE);
    FIfld_set_default_text(me->forms[0].form_ptr,G_Y,0,0,tmp,0 );
  }
  if ((j=VSseekFields(ACrg,num,ATT_X)) != -1) {
    sprintf(tmp,"%.2lf",ACrg[j].desc.value.att_exp);
    FIfld_set_text(me->forms[0].form_ptr,G_X,0,
		   0, tmp,FALSE);
    FIfld_set_default_text(me->forms[0].form_ptr,G_X,0,0,tmp,0 );
  }
  if ((j=VSseekFields(ACrg,num,ATT_H)) != -1) {
    sprintf(tmp,"%.2lf",ACrg[j].desc.value.att_exp);
    FIfld_set_text(me->forms[0].form_ptr,G_H,0,
		   0, tmp,FALSE);
    FIfld_set_default_text(me->forms[0].form_ptr,G_H,0,0,tmp,0 );
  }
  if ((j=VSseekFields(ACrg,num,ATT_C)) != -1) {
    sprintf(tmp,"%.2lf",ACrg[j].desc.value.att_exp);
    FIfld_set_text(me->forms[0].form_ptr,G_C,0,
		   0, tmp,FALSE);
    FIfld_set_default_text(me->forms[0].form_ptr,G_C,0,0,tmp,0 );
  }
  if ((j=VSseekFields(ACrg,num,ATT_N)) != -1) {
    sprintf(tmp,"%.2lf",ACrg[j].desc.value.att_exp);
    FIfld_set_text(me->forms[0].form_ptr,G_N,0,
		   0, tmp,FALSE);
    FIfld_set_default_text(me->forms[0].form_ptr,G_N,0,0,tmp,0 );
  }
  if ((j=VSseekFields(ACrg,num,ATT_T)) != -1) {
    sprintf(tmp,"%.2lf",ACrg[j].desc.value.att_exp);
    FIfld_set_text(me->forms[0].form_ptr,G_T,0,
		   0, tmp,FALSE);
    FIfld_set_default_text(me->forms[0].form_ptr,G_T,0,0,tmp,0 );
  }
  if ((j=VSseekFields(ACrg,num,ATT_ALLOWANCE)) != -1) {
    sprintf(tmp,"%.2lf",ACrg[j].desc.value.att_exp);
    FIfld_set_text(me->forms[0].form_ptr,G_ALLOWANCE,0,
		   0, tmp,FALSE);
    FIfld_set_default_text(me->forms[0].form_ptr,G_ALLOWANCE,0,0,tmp,0 );
  }
  if ((j=VSseekFields(ACrg,num,ATT_PROCESS)) != -1) {
    FIfld_set_text(me->forms[0].form_ptr,G_PROCESS,0,
		   0, ACrg[j].desc.value.att_txt,FALSE);
    FIfld_set_default_text(me->forms[0].form_ptr,G_PROCESS,
			   0,0,ACrg[j].desc.value.att_txt,0 );
  }
  if ((j=VSseekFields(ACrg,num,ATT_SPEC_NB)) != -1) {
    FIfld_set_text(me->forms[0].form_ptr,G_SPEC_NB,0,
		   0, ACrg[j].desc.value.att_txt,FALSE);
    FIfld_set_default_text(me->forms[0].form_ptr,G_SPEC_NB,
			   0,0,ACrg[j].desc.value.att_txt,0 );
  }
  if ((j=VSseekFields(ACrg,num,ATT_ABS)) != -1) {
    if( ACrg[j].desc.value.att_exp < 0.5 )
      FIg_set_state(me->forms[0].form_ptr,G_ABS_TOGG, 1 );
    else
      FIg_set_state(me->forms[0].form_ptr,G_ABS_TOGG, 0 );
  }
  if (traceFlag) printf("Done with regular processing %d\n",*sts);
  
quit : 
  FIg_enable(me->forms[0].form_ptr,FI_EXECUTE);
  FIg_enable(me->forms[0].form_ptr,FI_RESET);

  if (traceFlag) {
    printf("### VSpledatCmd.control_edge, Status = %d\n",*sts);
  }
  return OM_S_SUCCESS;
}

method modify_mac (long *sts)
{
struct GRid 		my_grid;
int	    		i,icnt,b_mod,cn_type,num,num_root;
struct GRid 		box;
long        		status,loc_msg;
struct ACrg_coll 	ACrg[ATT_NB_ATT];
struct GRid             *parent_list=NULL;
struct GRid             disconn_list[MAX_PLATE_PARENTS];
  


  SetProc(modify_mac); Begin



  for (i=0;i<ATT_NB_ATT;i++)
  {
    if (
         i == ATT_IDX_TYPE_ANGLE ||
         i == ATT_IDX_PROCESS ||
         i == ATT_IDX_SPEC_NB 
        ) {
      if (strcmp(me->list_att_txt[i],me->old_list_att_txt[i]))
        break;
    }
    else
      if (me->list_att[i] != me->old_list_att[i]) break;
  }

  icnt = i;

  if (i < ATT_NB_ATT) 
  {
    box.objid = NULL_OBJID;
    box.osnum = me->ModuleInfo.md_id.osnum;
    status = om$construct(classid = OPP_ACrg_collect_class_id,
                              osnum   = box.osnum,
                              p_objid = &box.objid);
    if (!(status&1)) {
      *sts = MY_ERROR;
      goto quit;
    }

    om$send( msg = message NDnode.NDchg_state(ND_DEL_NO_CH, ND_DEL_NO_CH ),
                 targetid = box.objid,
                 targetos = box.osnum );
    
             /* prepare ACrg collection */
    VSfillACrg(ACrg,me->list_att,me->list_att_txt);

    strcpy(ACrg[ATT_IDX_TYPE].name,ATT_TYPE);
    ACrg[ATT_IDX_TYPE].desc.type = AC_ATTRIB_DOUBLE;
    ACrg[ATT_IDX_TYPE].desc.value.att_exp = 1;

    status = om$send(msg = message ACrg_collect.ACadd_list_attribute
                         (&loc_msg, ATT_NB_ATT, ACrg),
                         targetid = box.objid,
                         targetos = box.osnum);
     if(!(status & loc_msg & 1)) {
       *sts = MY_ERROR;
       goto quit;
     }

    status = om$send(msg = message NDnode.NDchange_connect
                      (1,&me->old_box,&box),
                      targetid = me->edge_attr.obj_id.objid,
                      targetos = me->edge_attr.obj_id.osnum);
    if (!(status&1)) {
      *sts = MY_ERROR;
      goto quit;
    }
  } /* if (i < ATT_NB_ATT) */

/*
      me->edge_attr.obj_id  = me->event1.located_object[0].located_obj;
      me->edge_attr.mod_env = me->event1.located_object[0].module_info;
      memcpy((IGRchar *) me->edge_attr.mod_env.md_env.matrix,
             (IGRchar *) me->event1.located_object[0].module_info.md_env.matrix,
             (IGRint) (16 * sizeof(IGRdouble)) );
*/

  /* Process any plates */

  if( (add_flag) || (del_flag) )
  {
    status = om$send ( msg =  message NDnode.NDget_objects(
                                            ND_IN_BUF | ND_ROOT,
                                            (struct GRid *)NULL,
                                            0,
                                            &parent_list,
                                            0,
                                            OM_K_MAXINT,
                                            &num ),
                 targetid  = me->edge_attr.obj_id.objid,
                 targetos  = me->edge_attr.obj_id.osnum);

    if (!(status&1)) {
      *sts = MY_ERROR;
      goto quit;
    }

    __DBGpr_com("\n");
    __DBGpr_com("Parent List, in modify_mac, before changing plate items");
    __DBGpr_objlist("  ", num, parent_list );

    __DBGpr_com("Plate List, in modify_mac (VSpledatCmdi.I)");
    __DBGpr_objlist("  ", ptlcnt, me->ptl );

    __DBGpr_com("\n\n");

    /* First three parents are hardcoded into this macro and always exist */

    if( num > 3 )
    {
      num_root = num - 3;

      for( i=0; i<num_root; i++)
	disconn_list[i]   = parent_list[3+i];

      status = om$send(msg = message NDnode.NDdisconnect
                      (num_root, &disconn_list[0]),
                      targetid = me->edge_attr.obj_id.objid,
                      targetos = me->edge_attr.obj_id.osnum);

      if (!(status&1)) {
        *sts = MY_ERROR;
        goto quit;
      }
    } /* num > 3 */

    status = om$send(msg = message NDnode.NDconnect
                    (ptlcnt, &me->ptl[0], NULL_GRID, ND_ADD),
                targetid = me->edge_attr.obj_id.objid,
                targetos = me->edge_attr.obj_id.osnum);

    if (!(status&1)) {
      *sts = MY_ERROR;
      goto quit;
    }
  }


  if( (add_flag) || (del_flag) || (icnt < ATT_NB_ATT) )
  { 
    /* RECOMPUTE MACRO */

    my_grid = me->edge_attr.obj_id;
    cn_type    = ND_COMP; /* recompute the object */
    status = nd$wait_batch(type        = GR_GEOM_POSTED,
                           nb_obj      = 1,
                           l_object    = &my_grid,
                           l_obj_info  = &cn_type );

    nd$mod_batch(request     = ND_INQ,
                 p_ret_mode  = &b_mod );   

    if( b_mod != ND_DEFER ){
       nd$exec_batch();
    }

    if( icnt < ATT_NB_ATT )
    {
      for (i=0;i<ATT_NB_ATT;i++)
      {
        if (
             i == ATT_IDX_TYPE_ANGLE ||
             i == ATT_IDX_PROCESS ||
             i == ATT_IDX_SPEC_NB 
            ) {
          strcpy(me->old_list_att_txt[i],me->list_att_txt[i]);
        }
        else
          me->old_list_att[i] = me->list_att[i];
      } /* for */
    } /* if( i < ATT_NB_ATT ) */
  } /* if( ptlcnt > 0 || i < ATT_NB_ATT ) */


quit : 

  End

  return OM_S_SUCCESS;
}

/* get the object name */
VSgetName(obj,pt_name)
struct GRid *obj;
char *pt_name;
{
char name[100];
IGRlong  loc_msg,status;
int j;
IGRshort	mat_type;
IGRdouble	mat[16];
struct GRid buff;
GRclassid	cid;

  buff = *obj;
  om$get_classid(osnum = obj->osnum,
                 objid = obj->objid,
                 p_classid = &cid);
  if (om$is_ancestry_valid(subclassid     = cid,
                           superclassid = OPP_ASsource_class_id )
             == OM_S_SUCCESS ) {
    status = om$send(  msg = message NDnode.ASreturn_go
				  (&buff,&mat_type,mat),
                          targetid = obj->objid,
		          targetos = obj->osnum,
			  senderid = NULL_OBJID);
  }
  status = om$send(msg = message GRvg.GRgetname(&loc_msg,name),
                   targetid = buff.objid,
                   targetos = buff.osnum,
		   senderid = NULL_OBJID);
  if(!(status & loc_msg & 1)) return 0;
  else {
    /* just the name, without path */
    for(j = strlen(name)-1;name[j] != ':'; j--);
    strcpy(pt_name,name+j+1);
    return 1;
  }
}

method save_all  (long *sts)
{
char  tmp[50];
int   i;
long	status;

  *sts = MY_ERROR;
  
  dp$erase_hilite( msg = &status ) ;

  FIg_get_text(me->forms[0].form_ptr,G_LO,tmp);
  sscanf(tmp,"%lf",&me->list_att[ATT_IDX_LO]);
  FIg_set_default_value(me->forms[0].form_ptr,G_LO,me->list_att[ATT_IDX_LO]);

  FIg_get_text(me->forms[0].form_ptr,G_LB,tmp);
  sscanf(tmp,"%lf",&me->list_att[ATT_IDX_LB]);
  FIg_set_default_value(me->forms[0].form_ptr,G_LB,me->list_att[ATT_IDX_LB]);

  FIg_get_text(me->forms[0].form_ptr,G_SO,tmp);
  sscanf(tmp,"%lf",&me->list_att[ATT_IDX_SO]);
  FIg_set_default_value(me->forms[0].form_ptr,G_SO,me->list_att[ATT_IDX_SO]);

  FIg_get_text(me->forms[0].form_ptr,G_SB,tmp);
  sscanf(tmp,"%lf",&me->list_att[ATT_IDX_SB]);
  FIg_set_default_value(me->forms[0].form_ptr,G_SB,me->list_att[ATT_IDX_SB]);

  FIg_get_text(me->forms[0].form_ptr,G_A,tmp);
  sscanf(tmp,"%lf",&me->list_att[ATT_IDX_A]);
  FIg_set_default_value(me->forms[0].form_ptr,G_A,me->list_att[ATT_IDX_A]);

  FIg_get_text(me->forms[0].form_ptr,G_TYPE_ANGLE,
                                    me->list_att_txt[ATT_IDX_TYPE_ANGLE]);
  FIfld_set_default_text(me->forms[0].form_ptr,G_TYPE_ANGLE,
                         0,0,me->list_att_txt[ATT_IDX_TYPE_ANGLE],0 );

  FIg_get_text(me->forms[0].form_ptr,G_B,tmp);
  sscanf(tmp,"%lf",&me->list_att[ATT_IDX_B]);
  FIg_set_default_value(me->forms[0].form_ptr,G_B,me->list_att[ATT_IDX_B]);

  FIg_get_text(me->forms[0].form_ptr,G_V,tmp);
  sscanf(tmp,"%lf",&me->list_att[ATT_IDX_V]);
  FIg_set_default_value(me->forms[0].form_ptr,G_V,me->list_att[ATT_IDX_V]);

  FIg_get_text(me->forms[0].form_ptr,G_Y,tmp);
  sscanf(tmp,"%lf",&me->list_att[ATT_IDX_Y]);
  FIg_set_default_value(me->forms[0].form_ptr,G_Y,me->list_att[ATT_IDX_Y]);

  FIg_get_text(me->forms[0].form_ptr,G_X,tmp);
  sscanf(tmp,"%lf",&me->list_att[ATT_IDX_X]);
  FIg_set_default_value(me->forms[0].form_ptr,G_X,me->list_att[ATT_IDX_X]);

  FIg_get_text(me->forms[0].form_ptr,G_H,tmp);
  sscanf(tmp,"%lf",&me->list_att[ATT_IDX_H]);
  FIg_set_default_value(me->forms[0].form_ptr,G_H,me->list_att[ATT_IDX_H]);

  FIg_get_text(me->forms[0].form_ptr,G_C,tmp);
  sscanf(tmp,"%lf",&me->list_att[ATT_IDX_C]);
  FIg_set_default_value(me->forms[0].form_ptr,G_C,me->list_att[ATT_IDX_C]);

  FIg_get_text(me->forms[0].form_ptr,G_N,tmp);
  sscanf(tmp,"%lf",&me->list_att[ATT_IDX_N]);
  FIg_set_default_value(me->forms[0].form_ptr,G_N,me->list_att[ATT_IDX_N]);

  FIg_get_text(me->forms[0].form_ptr,G_T,tmp);
  sscanf(tmp,"%lf",&me->list_att[ATT_IDX_T]);
  FIg_set_default_value(me->forms[0].form_ptr,G_T,me->list_att[ATT_IDX_T]);

  FIg_get_state( me->forms[0].form_ptr, G_ABS_TOGG, &i );
  if( i ) me->list_att[ATT_IDX_ABS] = 0;
  else    me->list_att[ATT_IDX_ABS] = 1;

  FIg_get_text(me->forms[0].form_ptr,G_ALLOWANCE,tmp);
  sscanf(tmp,"%lf",&me->list_att[ATT_IDX_ALLOWANCE]);
  FIg_set_default_value(me->forms[0].form_ptr,G_ALLOWANCE,
                        me->list_att[ATT_IDX_ALLOWANCE]);

  FIg_get_state(me->forms[0].form_ptr,G_TYPE_CHAMF, &i);
  me->list_att[ATT_IDX_TYPE_CHAMF] = i;
  FIg_set_default_value(me->forms[0].form_ptr,G_TYPE_CHAMF,
                                            me->list_att[ATT_IDX_TYPE_CHAMF]);

  FIg_get_text(me->forms[0].form_ptr,G_PROCESS,
                                     me->list_att_txt[ATT_IDX_PROCESS]);
  FIfld_set_default_text(me->forms[0].form_ptr,G_PROCESS,
                          0,0,me->list_att_txt[ATT_IDX_PROCESS],0 );

  FIg_get_text(me->forms[0].form_ptr,G_SPEC_NB,
                                  me->list_att_txt[ATT_IDX_SPEC_NB]);
  FIfld_set_default_text(me->forms[0].form_ptr,G_SPEC_NB,
                         0,0,me->list_att_txt[ATT_IDX_SPEC_NB],0 );

  if( me->list_att[ATT_IDX_ALLOWANCE]  < 0.0 )
  {
     FIg_set_text(me->forms[0].form_ptr,G_FI_MSG_FIELD,"Allowance should not be negative");
     *sts = MSFAIL;
     return OM_S_SUCCESS;
  }

/*
  if( me->list_att[ATT_IDX_ALLOWANCE]  < 0.5*me->list_att[ATT_IDX_V] )
  {
     FIg_set_text(me->forms[0].form_ptr,G_FI_MSG_FIELD,"Check: Allowance >= 0.5*V");
     *sts = MSFAIL;
     return OM_S_SUCCESS;
  }

  if( me->list_att[ATT_IDX_T] - (me->list_att[ATT_IDX_H] + 
	me->list_att[ATT_IDX_C] + me->list_att[ATT_IDX_N] ) > 0.0001 )
  {
     FIg_set_text(me->forms[0].form_ptr,G_FI_MSG_FIELD,"Check: T=H+C+N");
     *sts = MSFAIL;
     return OM_S_SUCCESS;
  }
  if( me->list_att[ATT_IDX_T] - (me->list_att[ATT_IDX_X] +
		me->list_att[ATT_IDX_Y] ) > 0.0001 )
  {
     FIg_set_text(me->forms[0].form_ptr,G_FI_MSG_FIELD,"Check: T=X+Y");
     *sts = MSFAIL;
     return OM_S_SUCCESS;
  }

  if( me->list_att[ATT_IDX_LO] < me->list_att[ATT_IDX_SO] )
  {
     FIg_set_text(me->forms[0].form_ptr,G_FI_MSG_FIELD,"Check: L_OFF>=S_OFF");
     *sts = MSFAIL;
     return OM_S_SUCCESS;
  }

  if( me->list_att[ATT_IDX_LB] < me->list_att[ATT_IDX_SB] )
  {
     FIg_set_text(me->forms[0].form_ptr,G_FI_MSG_FIELD,"Check: L_BASE>=S_BASE");
     *sts = MSFAIL;
     return OM_S_SUCCESS;
  }

  if( me->list_att[ATT_IDX_A] < 0.0 || me->list_att[ATT_IDX_B] < 0.0 )
  {
     FIg_set_text(me->forms[0].form_ptr,G_FI_MSG_FIELD,"Angles A and B should be positive");
     *sts = MSFAIL;
     return OM_S_SUCCESS;
  }
*/
  *sts = MSSUCC;
  return OM_S_SUCCESS;
}

method	VSsetSymbNameDisp (		IGRlong		*msg;
					IGRchar		*name;
					IGRchar		*matchKey;
				struct	GRid		*matchId;
				struct	GRid		tar_geom;
				enum	GRdpmode	*dpmode		)
{
	IGRint		sts=OM_S_SUCCESS;
struct	GRsymbology	loc_symb;
	IGRchar		loc_path[DI_PATH_MAX];

	/* Extract symbology and path from EMS directories */
	loc_path[0] = '\0';
	sts = VDSget_dir_and_symb ( msg, matchId, matchKey, NULL, loc_path,
				    &loc_symb.level, &loc_symb.display_attr );
	__CheckRC( sts, *msg, "VDSget_dir_and_symb", wrapup );

	/* Change symbology of target object */
	sts = om$send ( msg = message GRvg.GRputsymb ( msg, &loc_symb),
			targetid = tar_geom.objid,
			targetos = tar_geom.osnum );
	if (!(sts & 0x00000001 & (*msg)))
		printf( "Warning : occurence symbology not changed\n");

	/* Redisplay target object (if wanted) */
	if (dpmode)	gr$display_object ( object_id = &tar_geom,
					    md_env    = &me->ModuleInfo,
					    mode      = *dpmode );
wrapup:
	return (sts);
}

end implementation VSplEdAtCmd;
