/* $Id: VSovrlngCmdi.I,v 1.2 2001/02/14 20:54:51 ramarao Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vscmd/VSovrlngCmdi.I
 *
 * Description: Beam Overlengtth Implementation
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSovrlngCmdi.I,v $
 *      Revision 1.2  2001/02/14 20:54:51  ramarao
 *      Modification related to __DBGpr_obj() macro.
 *
 *      Revision 1.1.1.1  2001/01/04 21:10:26  cvs
 *      Initial import to CVS
 *
# Revision 1.2  1999/07/23  14:08:10  pinnacle
# tr179900695
#
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.3  1998/04/12  06:10:22  pinnacle
# Replaced: vscmd/VSovrlngCmdi.I for:  by mdong for struct
#
# Revision 1.2  1998/04/09  16:07:20  pinnacle
# CR179800339
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/08/98  ah      CR179800339 Make left/right match profile card
 * 04/12/98  Ming    CR179800339
 * 07/06/99  Jay/Vin TR179900695 Image beams filtered from being added
 *                               overlengths
 *                               NULL pointer check added
 ***************************************************************************/

class implementation VSovrlngCmd ;

#include <stdio.h>
#include <string.h>
#include <sys/param.h>
#include <FI.h>
#include "OMmacros.h"
#include "acrepdef.h"
#include "grdpbdef.h"
#include "GRdpbfunc.h"
#include "GRsetinq.h"
#include "grdpbmacros.h"
#include "vsbeamdef.h"
#include "vsglobalmsg.h"
#include "vscmdmacros.h"
#include "vsiomacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
#include "vsdpb.h"
/*
 * Includes of function prototypes
 */
%safe
#include "VX_FIproto.h"
%endsafe
#include "vsaddmodattr.h"
#include "vsformproto.h"
#include "vsioproto.h"
#include "vsevalbeamcs.h"
#include "bscrossp.h"
#include "bsdotp.h"
#include "bsmkvec.h"

#define ROOT_FORM	0
/*
 * Gadget labels on root (parent) form.
 */
#define VS_K_OVL_MCF		13	/* Mcf: name, overlength vals, etc.*/
#define VS_K_SET_ACT_1_BTN	21	/* 'Set active overlength 1' button*/
#define VS_K_SET_ALL_1_BTN	22	/* 'Set all overlengths 1' button  */
#define VS_K_SET_ACT_2_BTN	23	/* 'Set active overlength 2' button*/
#define VS_K_SET_ALL_2_BTN	24	/* 'Set all overlengths 2' button  */
#define VS_K_SLCTDOVLS_MCF	20	/* Selected overlengths mcf        */
#define VS_K_READ_FILE_BTN	19	/* 'Read from file' button	   */
#define FI_MSG_FIELD            10      /* Message Field for TR179900695   */
//Added by Manoj on 1.4.1998

#define VS_K_LeftEnd	15	/* Left End select button */
#define VS_K_RightEnd	16	/* Right End select button */
/*
 * Columns of multi-column field 'VS_K_OVL_MCF'
 */
#define ELM_NAME_COL	0	/* Name of located element		*/
#define OVL1_VAL_COL	1	/* Value of 1st overlength		*/
#define OVL2_VAL_COL	2	/* Value of 2nd overlength		*/
/*
 * commented For CR-179800339
 */
//#define OVL1_POS_COL	2	/* Position of 1st overlength		*/
//#define OVL2_VAL_COL	3	/* Value of 2nd overlength		*/
//#define OVL2_POS_COL	4	/* Position of 2nd overlength		*/

#define MAXROWSIZE	64

%safe
static char	curPATH[MAXPATHLEN	+1]	= ".",
		curNAME[FILENAME_MAX	+1]	= "overlengths",
		curRGXP[VS_K_MAX_RGXP]		= "*" ;
%endsafe
extern int   COB_FI_form_notification() ;
extern GRclassid OPP_VSimgFeature_class_id; //TR179900695

from GRgraphics	import GRgetname,
		       GRgetobjinfo ;
from ACdb_info	import ACgive_db_structure ;
from VSfeature	import VSmodUsrAttributes ;
from VSbeam 	import VSextractProfile;  //added by manoj CR 179800339 

/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
static int IsValidOverlengthPosition( char *text, int type ) {

	long	m[6] ;
	int	i ;
	m[0] = VS_gI_Fore      ; m[1] = VS_gI_Aft ;
	m[2] = VS_gI_Top       ; m[3] = VS_gI_Bottom ;
	m[4] = VS_gI_Starboard ; m[5] = VS_gI_Portside ;

	for( i = 0 ; i < 5 ; i++ ) {
	  if( !strcmp( text, VSmsgkey2string( m[i] ) ) ) return 0 ;
	}
	return 1 ;

} /* IsValidOverlengthPosition */
/*----------------------------------------------------------------------------*/
static void ShipSideToWldAxis( const char* shipSide, char wldAxis[3] ) {

	/*
	 * Does the conversion:
	 * fore         -> +x
	 * aft          -> -x
	 * portside     -> +y
	 * starboard    -> -y
	 * top          -> +z
	 * bottom       -> -z 
	 */
#define IS_POSITION( p ) !strcmp( shipSide, VSmsgkey2string( VS_gI_##p ) )

	     if( IS_POSITION( Fore      ) ) strcpy( wldAxis, "+x" ) ;
	else if( IS_POSITION( Aft       ) ) strcpy( wldAxis, "-x" ) ;
	else if( IS_POSITION( Portside  ) ) strcpy( wldAxis, "+y" ) ;
	else if( IS_POSITION( Starboard ) ) strcpy( wldAxis, "-y" ) ;
	else if( IS_POSITION( Top       ) ) strcpy( wldAxis, "+z" ) ;
	else if( IS_POSITION( Bottom    ) ) strcpy( wldAxis, "-z" ) ;
	else                                strcpy( wldAxis, ""   ) ;

#undef IS_POSITION

} /* ShipSideToWldAxis */
/*----------------------------------------------------------------------------*/
static long WldAxisToShipSide( const char *shipSide ) {

	long m = VS_gI_EmptyMessage ;

	switch( shipSide[0] ) {
	  case '+' :
	    switch( shipSide[1] ) {
	      case 'x' : m = VS_gI_Fore     ; break ;
	      case 'y' : m = VS_gI_Portside ; break ;
	      case 'z' : m = VS_gI_Top      ; break ;
	    }
	    break ;
	  case '-' :
	    switch( shipSide[1] ) {
	      case 'x' : m = VS_gI_Aft      ; break ;
	      case 'y' : m = VS_gI_Starboard; break ;
	      case 'z' : m = VS_gI_Bottom   ; break ;
	    }
	    break ;
	}
	return m ;

} /* WldAxisToShipSide */
/*----------------------------------------------------------------------------*/
method fillForm() {

  long		   sts ;
  long		   msg ;
  char		   *pForm = me->forms[0].form_ptr ;
  struct GRobj_env beam ;
  int		   i ;
  int		   state ;
  char             *real_name_ptr = NULL;
  char             real_name[20];
  OMuword          image_classid;
  IGRboolean       flag = 0;
  /*
   * commented For CR-179800339, : Not needed as the form is modified
   
   FIfld_set_verify_routine( pForm, VS_K_OVL_MCF, OVL1_POS_COL,
   IsValidOverlengthPosition ) ;
   FIfld_set_verify_routine( pForm, VS_K_OVL_MCF, OVL2_POS_COL,
   IsValidOverlengthPosition ) ;
  */
  
  FIfld_set_num_rows( pForm, VS_K_OVL_MCF, me->oprndCount ) ;
  /*
   * By deafault first row is selected.
   */
  FIfld_set_select(pForm, VS_K_OVL_MCF, 0, 0, TRUE) ;
  
  for( i = 0 ; i < me->oprndCount ; i++ ) {
    GRname name ;
    struct ret_struct rs ;
    int	   rc ;
    char   *unit ;
    char   *string = rs.var.text_st.text_string ;
    
    sts = om$send( msg      = message VSlocateCmd.getLocObjAtIndex(
      &msg, i, &beam ),
	           targetid = my_id ) ;
    __CheckRC( sts, msg, "VSlocateCmd.getLocObjAtIndex", wrapup ) ;
    // Filter out image beam class - TR179900695
    sts = om$get_classid (  osnum     = beam.obj_id.osnum,
			    objid     = beam.obj_id.objid,
			    p_classid = &image_classid );
    
    if(image_classid == OPP_VSimgFeature_class_id)
    {
      flag = 1;
      goto wrapup;
    }
    /*
     * Fill 'Element Name' field.
     */
    *name = '\0' ;
    sts = om$send( msg      = message GRgraphics.GRgetname( &msg, name ),
    		   targetid = beam._objid,
    		   targetos = beam._osnum ) ;
    if( !( sts & 1 & msg ) || !*name ) {
      ex$message( msgnumb = VS_gI_Unnamed, buff = name ) ;
    }
    real_name_ptr = strrchr( name, ':' );
    
    //Modified for TR179900695
    if(real_name_ptr) {
      real_name_ptr+=1;
      strcpy( real_name, real_name_ptr );
    }
    else
    {
      strcpy( real_name,name);
    }
    FIfld_set_text( pForm, VS_K_OVL_MCF, i, ELM_NAME_COL, real_name, 0 == i ) ;
    
    /*
     * commented For CR-179800339
     */
    //  FIbtn_get_auto_pop_up_state(pForm,LEFT_LABEL,settingL);
    
    /*
     * Value of overlength 1
     */
    sts = om$send( msg      = message ACdb_info.ACgive_db_structure( &rc, NULL,
								     VS_K_bmOvrLen0Val, &rs, &beam.mod_env ),
    		   targetid = beam._objid,
    		   targetos = beam._osnum ) ;
    if( !( sts & 1 & rc ) ) {
      /*
       * If the attribute 'VS_K_bmOvrLen0Val' could not be found, then it
       * means that the beam had no overlenthgs before. Compute the beam
       * orientation (fore-aft/top-bottom/portside/starboard) and set the
       * overlength values to 0.
       */
      /*
       * commented For CR-179800339 : BEGIN
       */
      
      //char ori[3] ;
      //long op1, op2 ;
      
      //	Find  which end of the beam if is left ( param = 0
      //	param = 1)
      /*
       * The above function returns "x", "+y", "y", "-y", "z".
       */
      /*
	switch( *ori ) {
	case 'x' : op1 = VS_gI_Fore     ; op2 = VS_gI_Aft       ; break ;
	case '+' :
	case '-' :
	case 'y' : op1 = VS_gI_Portside ; op2 = VS_gI_Starboard ; break ;
	case 'z' : op1 = VS_gI_Top      ; op2 = VS_gI_Bottom    ; break ;
	default  : op1 = op2 = VS_gI_EmptyMessage               ; break ;
	}
      */
      /*
       * commented For CR-179800339:  END 
       */
      
      FIfld_set_text( pForm, VS_K_OVL_MCF, i, OVL1_VAL_COL, "0", FALSE  ) ;
      FIfld_set_text( pForm, VS_K_OVL_MCF, i, OVL2_VAL_COL, "0", FALSE  ) ;
      /*
	To display for ,aft etc. in the form 
      */
      /*
       * commented For CR-179800339
       */
      /*
	FIfld_set_text( pForm, VS_K_OVL_MCF, i, OVL1_POS_COL, VSmsgkey2string( op1 ) , FALSE  ) ;
	FIfld_set_text( pForm, VS_K_OVL_MCF, i, OVL2_POS_COL, VSmsgkey2string( op2 ) , FALSE  ) ;
      */
      continue ;
    }
    vs$system_to_unit(	msg	= &msg,
			value	= rs.var.root_pm_st.value,
			type	= GRIO_DISTANCE,
			osnum	= me->ModuleInfo._MD_OS,
			p_unit	= &unit ) ;
    FIfld_set_text( pForm, VS_K_OVL_MCF, i, OVL1_VAL_COL, unit , FALSE  ) ;
    
    /*
     * Value of overlength 2
     */
    sts = om$send( msg      = message ACdb_info.ACgive_db_structure( &rc, NULL,
								     VS_K_bmOvrLen1Val, &rs, &beam.mod_env ),
    		   targetid = beam._objid,
    		   targetos = beam._osnum ) ;
    if( !( sts & 1 & rc ) ) {
      rs.var.root_pm_st.value = 0 ;
    }
    vs$system_to_unit(	msg	= &msg,
			value	= rs.var.root_pm_st.value,
			type	= GRIO_DISTANCE,
			osnum	= me->ModuleInfo._MD_OS,
			p_unit	= &unit ) ;
    FIfld_set_text( pForm, VS_K_OVL_MCF, i, OVL2_VAL_COL, unit, FALSE  ) ;
    
    /* 
     * Position of overlength 1
     */
    sts = om$send( msg      = message ACdb_info.ACgive_db_structure( &rc, NULL,
								     VS_K_bmOvrLen0Pos, &rs, &beam.mod_env ),
    		   targetid = beam._objid,
    		   targetos = beam._osnum ) ;
    if( !( sts & 1 & rc ) ) {
      *string = '\0' ;
    } else {
      strcpy( string, VSmsgkey2string( WldAxisToShipSide( string ) ) ) ;
    }
    /*
     * commented For CR-179800339
     */
    //FIfld_set_text( pForm, VS_K_OVL_MCF, i, OVL1_POS_COL, string , FALSE  ) ;
    
    /* 
     * Position of overlength 2
     */
    sts = om$send( msg      = message ACdb_info.ACgive_db_structure( &rc, NULL,
								     VS_K_bmOvrLen1Pos, &rs, &beam.mod_env ),
    		   targetid = beam._objid,
    		   targetos = beam._osnum ) ;
    if( !( sts & 1 & rc ) ) {
      *string = '\0' ;
    } else {
      strcpy( string, VSmsgkey2string( WldAxisToShipSide( string ) ) ) ;
    }
    /*
     * commented For CR-179800339
     */
    //FIfld_set_text( pForm, VS_K_OVL_MCF, i, OVL2_POS_COL, string, FALSE  ) ;
  }
  
  FIfld_set_line_color( pForm, VS_K_SLCTDOVLS_MCF, 0, VALUES_COLUMN, FI_GREEN );
  FIfld_set_text( pForm, VS_K_SLCTDOVLS_MCF, 0, NAMES_COLUMN, "0", FALSE ) ;
  FIfld_set_text( pForm, VS_K_SLCTDOVLS_MCF, 1, NAMES_COLUMN, "0", FALSE ) ;
  FIfld_set_text( pForm, VS_K_SLCTDOVLS_MCF, 0, VALUES_COLUMN, "0", TRUE ) ;
  FIfld_set_text( pForm, VS_K_SLCTDOVLS_MCF, 1, VALUES_COLUMN, "0", FALSE ) ;
  FIg_get_state( pForm,FI_ACCEPT  ,&state );
  if (  !state ) {
    FIg_enable( pForm,FI_EXECUTE  );
    FIg_enable( pForm,FI_ACCEPT  );
  }
  
  wrapup :
    // Added for TR179900695
    if(flag) {
      //clear any left over status
      FIg_disable( pForm,FI_EXECUTE);
      FIg_disable( pForm,FI_ACCEPT);
      FIg_disable(pForm,VS_K_READ_FILE_BTN);
      FIg_set_text( pForm, FI_MSG_FIELD, " ");
      FIg_set_text(pForm, FI_MSG_FIELD, "ADDING OVERLENGTHS TO IMAGE BEAMS NOT SUPPORTED"); 
      
    }
  return OM_S_SUCCESS ;
  
} /* method fillForm */
/*----------------------------------------------------------------------------*/
method mouse( long *msg ; char *pForm ; int x, y ) {

  int	label ;

  if( FIf_find_gadget( pForm, FI_FORM_GROUP, x, y, &label ) == FI_SUCCESS ) {
      static int  prevLabel  = -1 ;
      static char *prevForm  = NULL ;
      int	  doit ;
      long m = VS_gI_EmptyMessage ;
      if( pForm == me->forms[0].form_ptr ) {
      	doit = prevLabel != label ;
      	switch( label ) {
          case VS_K_OVL_MCF : {
            int row, col ;
            static char prevCol = -1 ;
            FIfld_find_row_and_column( pForm, label, x, y, &row, &col ) ;

            if( col != prevCol || doit ) {
              switch( col ) {
                case ELM_NAME_COL : m = VS_gI_PkHrToSelElm ; break ;
                case OVL1_VAL_COL : m = VS_gI_1OvlVal      ; break ;
                case OVL2_VAL_COL : m = VS_gI_2OvlVal      ; break ;
		/*
		 * commented For CR-179800339
 	 	 */
                //case OVL1_POS_COL :  
                //case OVL2_POS_COL : m = VS_gI_OvlPosList   ; break ;
              }
              doit = TRUE ;
              prevCol = col ;
            } else m = MS_NO_MSG ;
          }
          break ;
          case VS_K_SET_ACT_1_BTN : m = VS_gI_Set1OvlValOfSelBm  ; break ;
          case VS_K_SET_ALL_1_BTN : m = VS_gI_Set1OvlValOfAllBms ; break ;
          case VS_K_SET_ACT_2_BTN : m = VS_gI_Set2OvlValOfSelBm  ; break ;
          case VS_K_SET_ALL_2_BTN : m = VS_gI_Set2OvlValOfAllBms ; break ;
          case VS_K_SLCTDOVLS_MCF : {
            int row, col ;
            static char prevCol = -1 ;
            FIfld_find_row_and_column( pForm, label, x, y, &row, &col ) ;

            if( col != prevCol || doit ) {
              switch( col ) {
              	case NAMES_COLUMN  : m = VS_gI_OvlTypeSelInFile   ; break ;
              	case VALUES_COLUMN : m = VS_gI_OvlValSelInFile    ; break ;
              }
              doit = TRUE ;
              prevCol = col ;
            } else m = MS_NO_MSG ;
          }
          break ;
          case VS_K_READ_FILE_BTN : m = VS_gI_LdOvlnFrFile       ; break ;
      	}
        if( doit ) VSfi_prompt( pForm, VSmsgkey2string( m ) ) ;
      } else if( pForm == me->ovrLngthsForm ) {
      	if( label != prevLabel ) 
      	  VSexplainDefaultValuesForm( pForm, label ) ;
      }
      prevLabel = label ; prevForm = pForm ;
  }
  *msg = MSSUCC ;
  return OM_S_SUCCESS ;

} /* method mouse */
/*----------------------------------------------------------------------------*/
static void VSdfltOvrLengthCallBack( char *defltValsForm,
				     char *ovrLngthForm,
				     int  controlType ) {

  /*
   * This is a call-back after the 'Default Values' form has been accepted or
   * canceled.
   * (`parentForm' is the 'Add Overlengths' form.)
   */
  switch( controlType ) {

    case FI_ACCEPT : {
      long	msg ;
      char      buf[MAXROWSIZE] ;
      int	nrows,
      		row,
                sel,
      		pos,
      		i,
      		j[2] ;
      double    val ;
      char      t[MS_MAX_MSG_LENGTH] ;

      FIf_erase( defltValsForm ) ;
      /*
       * Copy values and descriptions to 'Default value field' of master form.
       */
      FIfld_get_num_rows( defltValsForm, VS_K_DFLTS_MCF, &nrows ) ;

      FIfld_get_active_row( ovrLngthForm, VS_K_SLCTDOVLS_MCF, j + 0, &pos ) ;
      j[1] = 1 - j[0] ;

      *t = '\0' ;
      for( i = row = 0 ; row < nrows && i < 2 ; row++ ) {
      	FIfld_get_select( defltValsForm, VS_K_DFLTS_MCF, row, NAMES_COLUMN, &sel ) ;
      	if( !sel ) continue ;

        FIfld_get_text( defltValsForm, VS_K_DFLTS_MCF, row, VALUES_COLUMN,
                        MAXROWSIZE, (unsigned char*) buf, &sel, &pos ) ;
        vs$unit_to_system( msg	= &msg,
			   type	= GRIO_DISTANCE,
			   unit	= buf,
			   p_value= &val ) ;
        if( !( msg & 1 ) ) {
          if( *t ) strcat( t, "/" ) ;
          ex$message( msgnumb = VS_gI_InvalidValue, var = buf, type = "%s",
                      buff = t + strlen( t ) ) ;
          strcpy( buf, "0" ) ;
        }
        FIfld_set_text( ovrLngthForm, VS_K_SLCTDOVLS_MCF, j[i], VALUES_COLUMN, buf,
      		        TRUE ) ;
        FIfld_get_text( defltValsForm, VS_K_DFLTS_MCF, row, NAMES_COLUMN,
                        MAXROWSIZE, (unsigned char*) buf, &sel, &pos ) ;
        FIfld_set_text( ovrLngthForm, VS_K_SLCTDOVLS_MCF, j[i], NAMES_COLUMN, buf,
      		        FALSE ) ;
        i++ ;
      }
      if( *t ) VSfi_msg( ovrLngthForm, t ) ;
    }
    /* No break intentionally */

    case FI_CANCEL : {
      unsigned int cmdId ; unsigned short cmdOs ; long msg ;

      FIf_get_cmd_oid_os( ovrLngthForm, &cmdId, &cmdOs ) ;
      FIg_enable( ovrLngthForm, VS_K_READ_FILE_BTN ) ;
      om$send( msg      = message VSlocateCmd.stop_dynamics_in_form(
		   			                  &msg, defltValsForm ),
   	       targetid = cmdId, targetos = cmdOs, senderid = NULL_OBJID ) ;
      om$send( msg      = message VSlocateCmd.set_dynamics_in_form(
   				                           &msg, ovrLngthForm ),
   	       targetid = cmdId, targetos = cmdOs, senderid = NULL_OBJID ) ;
      /*
       * Tell the command that the form has been dismissed so it can
       * zero out its form pointer. To avoid implementing a message just
       * for this we use CEO.form_notification with the arguments form label,
       * gadget label and form set to -1, -1 and NULL respectively.
       */
       om$send( msg      = message CEO.form_notification( -1, -1, 0., NULL ),
                targetid = cmdId, targetos = cmdOs, senderid = NULL_OBJID ) ;
     }
    break ;
  }

} /* VSdfltOvrLengthCallBack */
/*----------------------------------------------------------------------------*/
/*
 * The left or right end is hilighted.  
 * Left and right are consistent with left and right of a Loft Profile Card.
 */
method  VShiliteBeamEndAsLoft( 
	struct GRobj_env support;   	/* I: stiffener or beam  	*/
	IGRchar 	 *bmEnd )       /* I: "left" or "right" 	*/
{
	long		sts, msg;
	double		o0[3], X0[3], Y0[3], Z0[3], v[3];
	double		o1[3], X1[3], Y1[3], Z1[3];
	double		SecMat[16],SecMat0[16], SecMat1[16];
	BSrc		rc;
	int		i,k;
	double		dotp;
	int             hiliteParam = -1;

	///SetProc(VShiliteBeamEndAsLoft); Begin

	/*
	 * get Section Cs at parameter 0
	 */
	__DBGpr_obj("support 1",support.obj_id);
	sts = VSevalBeamCS( &msg, &support, 0, VS_e_BOT_LEFT , SecMat0 ); 

	if( ! (sts&msg&1)){ 
		__DBGpr_com("Evaluation failed 1");
		sts = MSFAIL; goto wrapup; 
	}

	for( i=0; i<3; i++ ){
		k=i*4;
		X0[i]	= SecMat0[k];
		Y0[i]	= SecMat0[k+1];
		o0[i]	= SecMat0[k+3];
	}

	BScrossp( &rc, X0, Y0, Z0 );

	/*
	 * get Section Cs at parameter 1
	 */
	sts = VSevalBeamCS( &msg, &support, 1, VS_e_BOT_LEFT, SecMat1 ); 
	if( ! (sts&msg&1)){ 
		__DBGpr_com("Evaluation failed 2");
		sts = MSFAIL; goto wrapup; 
	}
	for( i=0; i<3; i++ ){
		k=i*4;
		X1[i]	= SecMat1[k];
		Y1[i]	= SecMat1[k+1];
		o1[i]	= SecMat1[k+3];
	}
	BScrossp( &rc, X1, Y1, Z1 );

	BSmkvec( &rc, v, o0, o1 );

	/* 
	 * compare vector direction
	 */
	dotp = BSdotp( &rc, v, Z0 );

	if( dotp > 0 ){
		__DBGpr_com("dotp > 0");
		/* sect mat is SecMat0	Z0

		for( i=0; i<16; i++ ) SecMat[i] = SecMat0[i];
		SecMat[2]	= Z0[0];
		SecMat[6]	= Z0[1];
		SecMat[10]	= Z0[2];
		*/
		if(!strcmp(bmEnd,"left")){
			hiliteParam= 0;
		}
		else if(!strcmp(bmEnd,"right")){
			hiliteParam = 1;
		} else {
			printf(" Error! ");
		}
	} else {
		if(!strcmp(bmEnd,"left")){
			hiliteParam= 1;
		}
		else if(!strcmp(bmEnd,"right")){
			hiliteParam = 0;
		} else {
			printf(" Error! ");
		}
	}
	if( hiliteParam == 1 || hiliteParam == 0 ){
		sts = MSSUCC;
	} else { 
		sts = MSFAIL ;
		goto wrapup ;
	}

	sts = om$send( msg = 	message VSovrlngCmd.displayCrossSection(
					support,
					hiliteParam ),
			targetid = my_id );
wrapup :
	//End 
	return sts;
}
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
method form_notification(	int	form_label ;
				int	gadget_label ;
				double	value ;
				char	*form ) {

  int  rsp ;
  int  row ;
  int  col ;
  int  sel ;
  int  pos ;
  long msg , sts ;
  char	*bmEnd = NULL ;

  if( -1 == form_label ) {

    me->ovrLngthsForm = NULL ;

  } else if( ROOT_FORM == form_label ) {


    switch( gadget_label ) {

      case FI_ACCEPT :
        rsp = VS_K_END_STATE ; ex$putque( msg = &msg, response = &rsp ) ;
	break ;

      case FI_EXECUTE :
        rsp = VS_K_CH_STATE ; 
        FIg_disable( form, FI_EXECUTE ); 
        FIg_disable( form, FI_ACCEPT ); 
	ex$putque( msg = &msg, response = &rsp ) ;
	break ;

      case FI_CANCEL :
        rsp = TERMINATE ; ex$putque( msg = &msg, response = &rsp ) ;
        break ;

      case FI_RESET :
        rsp = EX_RESTART ; 
        FIg_disable( form, FI_EXECUTE ); 
        FIg_disable( form, FI_ACCEPT ); 
	ex$putque( msg = &msg, response = &rsp ) ;
        break ;

      case VS_K_LeftEnd:
	bmEnd = "left" ; goto display_end ;
      case VS_K_RightEnd:
	bmEnd = "right" ;
	display_end :
	{
	struct GRobj_env bm;
	int row  = 0;
	int i ;
	int selected = 0;


	for ( i = 0 ; i<= me->oprndCount; i++){
  	    FIfld_get_select(form, VS_K_OVL_MCF, i, 0, &selected) ;
	   if ( selected ){
		row = i ;
		break; 
		}
	}
	__DBGpr_int("row ",row);
        om$send( msg      = message VSlocateCmd.getLocObjAtIndex(
						        &msg,
							row,
							&bm ),
	             targetid = my_id ) ;
	__DBGpr_obj("bm id ",bm.obj_id);
	vs$bulk_display( objenvs = &bm, dpmode = GRhe ) ;

	sts =  om$send( msg      = message VSovrlngCmd.VShiliteBeamEndAsLoft(
							bm, 
							bmEnd),
			targetid = my_id ) ;
	}
	break ;

      case VS_K_OVL_MCF :
        row = (int) value ;
        FImcf_get_active_col( form, gadget_label, &col, &pos ) ;
        switch( col ) {
          case ELM_NAME_COL : {
            struct GRobj_env  b ;
	    int i ;
            /*
	     * Unhilte all the beams before hiliting the selected object
             */
	    for( i = 0 ; i < me->oprndCount ; i++){
               om$send( msg      = message VSlocateCmd.getLocObjAtIndex(
						               &msg, row, &b ),
	             targetid = my_id ) ;
	       vs$bulk_display( objenvs = &b, dpmode = GRhe ) ;
	    }
  	    FIfld_set_select(form, VS_K_OVL_MCF, row, 0, TRUE) ;
            /*
             * Poking in 'Element Name' column, highlights the element in the
             * selected row.
             */
            om$send( msg      = message VSlocateCmd.getLocObjAtIndex(
						               &msg, row, &b ),
	             targetid = my_id ) ;
	    vs$bulk_display( objenvs = &b, dpmode = GRhd ) ;
	   } 
	   break ;
	   case OVL1_VAL_COL :
	   case OVL2_VAL_COL : {
	     double val ;
             if( row >= me->oprndCount )
             {
               FIfld_set_text( form, gadget_label, row, col, "", FALSE );
               break;
             }
	     vs$processUnitField( msg      = &msg,
	     			  form     = form,
	     			  field    = gadget_label,
	     			  row      = row,
	     			  column   = col,
	     			  osnum    = me->ModuleInfo._MD_OS,
	     			  oldValue = 0.,
	     			  newValue = &val ) ;
	     }
	     break ;

        }
        break ;

      case VS_K_READ_FILE_BTN : {
      	int x, y ;
      	FIf_get_location( form, &x, &y ) ; x += 200 ; y += 200 ;
	if( !*curPATH ) strcpy( curPATH, "." ) ;
	if( !*curNAME ) strcpy( curNAME, "overlengths" ) ;
	me->dfltInfo.numDefaultsWanted	= 2 ;
	me->dfltInfo.parentForm		= form ;
	me->dfltInfo.maxNumDefaults	= MX_DFLT_OVRLNGTHS ;
	me->dfltInfo.defaultValues	= me->defaultValues ;
	me->dfltInfo.currentDefault	= 0 ;
	me->dfltInfo.callBack		= VSdfltOvrLengthCallBack ;
	me->dfltInfo.fileForm		= NULL ;
	me->dfltInfo.fileInfo.curPATH	= curPATH ;
	me->dfltInfo.fileInfo.curNAME	= curNAME ;
	me->dfltInfo.fileInfo.curRGXP  	= curRGXP ;
	me->ovrLngthsForm		= VScreateDefaultValuesForm(
							x, y, &me->dfltInfo ) ;
	if( me->ovrLngthsForm ) {
	  FIf_set_cmd_oid_os( me->ovrLngthsForm, my_id, OM_Gw_current_OS ) ;

	  FIg_disable( form, gadget_label ) ;
	  om$send( msg = message VSlocateCmd.stop_dynamics_in_form( &msg, form),
   	           targetid = my_id ) ;
	  om$send( msg = message VSlocateCmd.set_dynamics_in_form(
		   				      &msg, me->ovrLngthsForm ),
                   targetid = my_id ) ;
	 }
      }
      break ;

      case VS_K_SET_ACT_1_BTN :
      case VS_K_SET_ACT_2_BTN : {
      	   char buf[MAXROWSIZE] ;
      	   col = VS_K_SET_ACT_1_BTN == gadget_label ? OVL1_VAL_COL
      	                                            : OVL2_VAL_COL ;
           FIfld_get_active_row( form, VS_K_OVL_MCF, &row, &pos ) ;
           FIfld_get_active_row( form, VS_K_SLCTDOVLS_MCF, &sel, &pos ) ;
      	   FIfld_get_text( form, VS_K_SLCTDOVLS_MCF, sel, VALUES_COLUMN,
      	   		   MAXROWSIZE, (unsigned char*) buf, &sel, &pos ) ;
      	   FIfld_set_text( form, VS_K_OVL_MCF, row, col, buf, FALSE ) ;
        }
        break ;

      case VS_K_SET_ALL_1_BTN :
      case VS_K_SET_ALL_2_BTN : {
      	   char buf[MAXROWSIZE] ;
      	   int	i ;
      	   col = VS_K_SET_ALL_1_BTN == gadget_label ? OVL1_VAL_COL
      	                                            : OVL2_VAL_COL ;
           FIfld_get_active_row( form, VS_K_SLCTDOVLS_MCF, &sel, &pos ) ;
      	   FIfld_get_text( form, VS_K_SLCTDOVLS_MCF, sel, VALUES_COLUMN,
      	   		   MAXROWSIZE, (unsigned char*) buf, &sel, &pos ) ;
      	   for( i = 0 ; i < me->oprndCount ; i++ ) {
      	       FIfld_set_text( form, VS_K_OVL_MCF, i, col, buf, FALSE ) ;
      	   }
        }
        break ;
      case VS_K_SLCTDOVLS_MCF :
           FIfld_get_active_row( form, gadget_label, &row, &pos ) ;
           FImcf_get_active_col( form, gadget_label, &col, &pos ) ;
           if( NAMES_COLUMN == col ) {
              FIfld_set_line_color( form, gadget_label,   row, VALUES_COLUMN, FI_GREEN ) ;
              FIfld_set_line_color( form, gadget_label, 1-row, VALUES_COLUMN, FI_YELLOW) ;
           }
           break;
    } /* switch */
  }

  return OM_S_SUCCESS ;

} /* method form_notification */ 
/*----------------------------------------------------------------------------*/
method operation( long *msg ) {

  long		   	sts ;
  long		   	msg ;
  int			i ;
  char		   	*pForm = me->forms[0].form_ptr ;
  struct GRobj_env	bm ;
  char			*attrNm[4] ;
  char			*attrVl[4] ;
  char			buf[4*20] ;


  attrNm[0] = VS_K_bmOvrLen0Val ; attrVl[0] = buf + 0 * 20 ;
  attrNm[1] = VS_K_bmOvrLen0Pos ; attrVl[1] = buf + 1 * 20 ;
  attrNm[2] = VS_K_bmOvrLen1Val ; attrVl[2] = buf + 2 * 20 ;
  attrNm[3] = VS_K_bmOvrLen1Pos ; attrVl[3] = buf + 3 * 20 ;

  for( i = 0 ; i < me->oprndCount ; i++ ) {
    char buffer[MAXROWSIZE] ;
    int     sel,
            pos ;
    double  value=0 ;

    FIfld_get_text( pForm, VS_K_OVL_MCF, i, OVL1_VAL_COL, MAXROWSIZE,
    		    (unsigned char*) buffer, &sel, &pos ) ;

    vs$unit_to_system(	msg	= &msg,
			type	= GRIO_DISTANCE,
			unit	= buffer,
			p_value	= &value ) ;

    sprintf( attrVl[0], "%g", value ) ;

    attrVl[1] = "left";

    value = 0;

    FIfld_get_text( pForm, VS_K_OVL_MCF, i, OVL2_VAL_COL, MAXROWSIZE,
    		    (unsigned char*) buffer, &sel, &pos ) ;
    vs$unit_to_system(	msg	= &msg,
			type	= GRIO_DISTANCE,
			unit	= buffer,
			p_value	= &value ) ;
    sprintf( attrVl[2], "%g", value ) ;

    attrVl[3] = "right";

    sts = om$send( msg      = message VSlocateCmd.getLocObjAtIndex(
						                 &msg, i, &bm ),
	           targetid = my_id ) ;

    if( !( sts & 1 & msg ) ) continue ;

	__DBGpr_str("attrNm 1",attrNm[0]  );
	__DBGpr_str("attrNm 1",attrNm[1]  );
	__DBGpr_str("attrNm 2",attrNm[2]  );
	__DBGpr_str("attrNm 3",attrNm[3]  );

	__DBGpr_str("attrVl 0",attrVl[0]  );
	__DBGpr_str("attrVl 1",attrVl[1]  );
	__DBGpr_str("attrVl 2",attrVl[2]  );
	__DBGpr_str("attrVl 3",attrVl[3]  );

    	om$send( msg      = message VSfeature.VSmodUsrAttributes(
					              &msg, 4, attrNm, attrVl ),
             targetid = bm._objid,
             targetos = bm._osnum ) ;
  }
  me->ret = VS_K_ACT_SUCCESS ;
  return OM_S_SUCCESS ;

} /* method operation */
/*----------------------------------------------------------------------------*/
method init( int type ; char *string ) {

	me->xsId.objid = NULL_OBJID ;

	om$send( msg    = message VSlocateCmd.init( type, string ),
		 mode   = OM_e_wrt_message,
		 targetid= my_id );

	return OM_S_SUCCESS ;
}
/*----------------------------------------------------------------------------*/
method cleanUp() {

	if( me->ovrLngthsForm ) {
		VSdeleteDftlValsForm( me->ovrLngthsForm ) ;
		me->ovrLngthsForm = NULL ;
	}
        if( !IF_NULL_OBJID( me->xsId.objid ) ) {
                vs$bulk_display(        dpmode  = GRbe,
                                        grids   = &me->xsId,
                                        theEnv  = &me->cstEnv ) ;
                vs$bulk_delete( count   = 1,
                                grids   = &me->xsId,
                                theEnv  = &me->cstEnv ) ;
        }

	return OM_S_SUCCESS ;

} /* method cleanUp */
/*----------------------------------------------------------------------------*/
method displayCrossSection(struct GRobj_env support ; int whichEnd ) {
	long	sts, msg ;

	struct GRvg_construct cst ;
	 IGRint                  size,
                                locMsg ,
                                nret ;
        struct GRsymbology      symb ;
 
	vs$cnstDefaults(        msg     = &msg,
                                symb_id = me->ModuleInfo.md_id,
                                symb    = &me->ActiveRep,
                                level   = &me->ActiveLevel,
                                display = &me->ActiveDisplay ) ;
	/*
        size = sizeof(struct GRsymbology);
        gr$get_active_display(  msg    = &locMsg,
                                sizbuf = &size,
                                buffer = (char *)&symb.display_attr,
                                nret   = &nret  );
 
        gr$get_active_level(    msg    = &locMsg,
                                sizbuf = &size,
                                buffer = (char *)&symb.level,
                                nret   = &nret   );
				*/

	__DBGpr_com("Fillthe construction list");

	symb.display_attr.weight = 2;
	vs$fill_cnst_list( 	Cnst_list 	= cst, 
				Msg 		= &msg, 
				Display         = &symb.display_attr,
				Level   	= symb.level,
				Env_info	= &me->cstEnv);

        if( om$is_objid_valid(  objid   = me->xsId.objid,
                                osnum   = me->xsId.osnum ) & 1 ) {
                /*
                 * Delete old section.
                 */
                vs$bulk_display(        dpmode  = GRhe,
                                        count   = 1,
                                        grids   = &me->xsId,
                                        theEnv  = &me->cstEnv ) ;
 
                vs$bulk_delete( count   = 1,
                                grids   = &me->xsId,
                                theEnv  = &me->cstEnv ) ;
        }


	/*
	 * get a profile (cross-section at the hilite parameter value
	 */
	__DBGpr_com("Calling VSextractProfile ");
	sts = om$send( msg 	= message VSbeam.VSextractProfile(
					&msg,
					&support.mod_env,
					NULL,
					NULL,
					whichEnd,
					&cst,
					AC_3D_REP,
					&me->xsId),
			senderid = NULL_OBJID ,
			targetid = support._objid ,
			targetos = support._osnum  );
	__CheckRC(sts, msg, "VSbeam.VSextractProfile", wrapup );

	__DBGpr_obj("cross-section id ", me->xsId);

	vs$bulk_display(dpmode	= GRhd ,
			count	= 1,
			theEnv  = &me->cstEnv,
			grids 	= &me->xsId );
wrapup :

	return sts ;
}
/*----------------------------------------------------------------------------*/

end implementation VSovrlngCmd ;

