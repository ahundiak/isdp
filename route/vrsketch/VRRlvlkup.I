/* $Id: VRRlvlkup.I,v 1.4 2002/04/10 20:33:30 louis Exp $  */

/***************************************************************************
 * I/ROUTE
 *
 * File:	vrsketch/VRRlvlkup.I
 *
 * Description:
 * 	Implementation for Raceway live lookup functionality.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRRlvlkup.I,v $
 *	Revision 1.4  2002/04/10 20:33:30  louis
 *	tr5649-standardize tolerance
 *	
 *	Revision 1.3  2001/02/20 01:17:13  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.2  2001/01/16 19:54:19  anand
 *	SP merge
 *	
# Revision 1.4  2000/06/28  20:02:26  pinnacle
# Replaced: route/vrsketch/VRRlvlkup.I for:  by aharihar for Service Pack
#
# Revision 1.3  2000/06/08  20:25:20  pinnacle
# Replaced: route/vrsketch/VRRlvlkup.I for:  by aharihar for Service Pack
#
# Revision 1.2  2000/05/12  16:48:04  pinnacle
# Replaced: route/vrsketch/VRRlvlkup.I for:  by aharihar for Service Pack
#
# Revision 1.6  2000/04/04  21:15:30  pinnacle
# Replaced: vrsketch/VRRlvlkup.I for:  by aharihar for route
#
# Revision 1.5  2000/04/03  16:38:44  pinnacle
# Replaced: vrsketch/VRRlvlkup.I for: TR 179901301 by aharihar for route
#
# Revision 1.4  2000/03/31  22:15:14  pinnacle
# Replaced: vrsketch/VRRlvlkup.I for: TR 179901276 by aharihar for route
#
# Revision 1.3  2000/03/27  16:52:42  pinnacle
# Replaced: vrsketch/VRRlvlkup.I for: CR 179801143 by aharihar for route
#
# Revision 1.2  2000/03/27  01:25:14  pinnacle
# Replaced: vrsketch/VRRlvlkup.I for: CR179801143 by aharihar for route
#
 *
 * History:
 *
 * DD MMM YY   AUTHOR	DESCRIPTION
 * 
 * March  2k	Anand	Creation (for CRs 179801143 & 179900991)
 * 22 Mar 2k	Anand	Linked Width and Depth field-lists, sorted entries,
 *			etc. (for CR 179900991)
 * 31 Mar 2k	Anand	TR 179901276 - Tray selector cosmetic changes.
 * 			TR 179901308 - Remove shape criterion for querying
 * 			sizes. Scheme for family code in Rway comps has
 * 			changed.
 * 04 Apr 2k	Anand	TR 179901301 - Maintain Accept button disabled until
 *			outlet size is selected.
 * 12 Apr 2k	Anand	CR 179901471 - Sorted Family class and Comp code fields
 *			alphabetically; the inlet and outlet sizes numerically
 *			(Raceway Live Look up form). Used C function 'qsort'
 *			and implemented function SizeWidDepSort for this
 *			purpose.
 * 12 Jun 2k	Anand	CR 179901687 - Display/Highlight active width/depth
   04/08/02     law     TR5649-standardize tolerance with VRGetTol
 * 
 ***************************************************************************/


class implementation Root;

#include <stdio.h>
#include <math.h>
#include "FI.h"
#include "AS_status.h"
#include "VDtypedef.h"
#include "VDmem.h"
#include "vdbmacros.h"
#include "vrparameters.h"
#include "vrtools_pto.h"
#include "VRattr_def.h"
#include "VRact_params.h"
#include "VRdef.h"
#include "VRMath.h"
#include "VRRwDimen.h"
#include "VRRDBdef.h"
#include "VRRDBmac.h"
#include "VRsketchdef.h"

#define DONT_EXTERN	1
#include "VRlivlkup.h"
#undef DONT_EXTERN

#include "vrdbgmacros.h"

/* Gadgets */

#define FI_RESET  3
#define FI_CANCEL 4
#define FI_ACCEPT 1

#define MSGFLD	10
#define	VENDOR	12
#define	FAMILY	15
#define	C_CODE	17
#define	INLET	26
#define	C_DESC	24
#define	OUTLET	25
#define	TAG_NO	29

from ACrg_collect	import ACget_named_attribute;

/* Externs */
extern int FIg_get_text_length();
extern int FIg_get_text();
extern int strcasecmp();

int VRGetSelText ( fp, g_label, text, text_size )
 Form fp; /* Pointer to the form */
 int g_label; /* The label of the gadget */
 char ** text; /* The text contained in the field */
 int * text_size; /* The space allocated for the text */
{
    int status;
    int text_len;
    int select_flag;
    int row = 0;
    int col = 0;
    int pos = 0;

    /* Get the row for the field or MCF */

    FIfld_get_active_row ( fp, g_label, &row, &pos );
    FIfld_get_text_length ( fp, g_label, row, col, &text_len );

    /* Increment text_len because of NULL */

    text_len++;

    if ( * text_size < text_len )
    {
	if ( * text_size > 0 )
	{
	    /* Realloc space for larger string */
	    * text = _REALLOC ( * text, text_len, char );
	}
	else
	{
	    /* Calloc space for string */
	    * text = _CALLOC ( text_len, char );
	}
	* text_size = text_len;
    }

    if ( ! * text )
    {
	* text_size = 0;
	return ( OM_E_NODYNMEM );
    }

    status = FIfld_get_text ( fp, g_label, row, col, * text_size,
						   *text, &select_flag, &pos );
    return ( OM_S_SUCCESS );
}


IGRint SizeWidDepSort( const IGRchar *a, const IGRchar *b )
{
    IGRdouble A_Width, A_Depth, B_Width, B_Depth;

    SetProc( qsort_calls_SizeWidDepSort ); Begin

    sscanf( a, "%lf x %lf", &A_Width, &A_Depth);
    sscanf( b, "%lf x %lf", &B_Width, &B_Depth);

    if( A_Width > B_Width )
	return 1;
    if( A_Width < B_Width )
	return -1;
    if( A_Depth > B_Depth )
	return 1;
    if( A_Depth > B_Depth )
	return -1;
    return 0;
}


void CleanupField( Form fp, int Gadg )
{
    IGRint	NumRows=0;

    FIfld_get_num_rows( fp, Gadg, &NumRows );
    while( NumRows )
    {
	--NumRows;
	FIfld_set_text( fp, Gadg, NumRows, 0, "", FALSE );
    }
    FIfld_set_num_rows( fp, Gadg, 0 );

    FIfld_get_list_num_rows( fp, Gadg, 0, &NumRows );
    while( NumRows )
    {
	--NumRows;
	FIfld_set_list_text( fp, Gadg, NumRows, 0, "", FALSE );
    }
    FIfld_set_list_num_rows( fp, Gadg, 0, 0 );
}

IGRint VRRwayLLUformUpdate( IGRint ProcGadgetId, Form fp,
					       struct RwayLiveLookup *LLUB )
{
    SetProc( VRRwayLLUformUpdate ); Begin

    /* All the elements of the RwayLiveLookup structure except for
     * VendorNo (viz., LLUB->VendorNo) are initialised below. The
     * VendorNo alone is expected to be set to the default spec from the
     * active params before kicking off live lookup */

    switch( ProcGadgetId )
    {
      case FI_RESET:
      case VENDOR:
	  CleanupField( fp, FAMILY );
	  FIg_disable( fp, FAMILY );
	  LLUB->FamilyNo = 0;

      case FAMILY:
	  CleanupField( fp, C_CODE );
	  FIg_disable( fp, C_CODE );
	  LLUB->CompCode[0] = '\0';
	  LLUB->Macro[0] = '\0';
	  LLUB->CompTopo = 0;
	  LLUB->ShapeCode = 0;
	  LLUB->Sh_Code[0] = '\0';

      case C_CODE:
	  CleanupField( fp, INLET );
	  FIg_disable( fp, INLET );
	  LLUB->InlWidth = 0.0;
	  LLUB->InlDepth = 0.0;

      case INLET:
	  CleanupField( fp, OUTLET );
	  FIg_disable( fp, OUTLET );
	  LLUB->OutDepth = 0.0;
	  LLUB->OutWidth = 0.0;

      case OUTLET:
	  FIfld_set_text( fp, TAG_NO, 0, 0, "", FALSE );
	  LLUB->CompNumb = NULL;
	  FIg_disable( fp, FI_ACCEPT );
	  break;

      default:
	  __DBGpr_com(" Shouldn't be here!");
	  End
	  return OM_E_INVARG;

    }
    End
    return OM_S_SUCCESS;
}

IGRint VRRacewayLiveLookUp ( IGRlong *msg, Form fp, IGRint GadgetLabel,
			   struct RwayLiveLookup *LivBuf,
			   IGRboolean *Proc_LLU, IGRboolean *LLU_Form,
			   char *FutureExpansion )
{
    IGRlong retcode;
    char *text=NULL;
    int text_size = 0;
    int i,j,status;
    static IGRshort NumCDL=0;
    static struct VRRDB_cdl *CodeList=NULL;
    extern IGRboolean VR_IsAlreadyInList(char *,char **,int);

    SetProc( RacewayLiveLookup ); Begin
    __DBGpr_int(" Num items in CDL (static verify)",NumCDL );
    __DBGpr_int(" GadgetLabel",GadgetLabel);

    if( *Proc_LLU == FALSE )
    {
	status = VR$RDB_CDL( p_msg = &retcode,
			     nlist = VR_R_LIVELOOKUP_LSTNUM,
			     p_num = &NumCDL);
	as$status( action = RET_STATUS );

	if( NumCDL == 0 || retcode != MSSUCC )
	{
	    *Proc_LLU = FALSE;
	    UI_status("DB tables not configured for Raceway Live Look up!");
	    __DBGpr_com(" Codelist not populated for live look up!");
	    End
	    return OM_E_ABORT;
	}
	__DBGpr_int(" Number of entries in Codelist table", NumCDL);

	CodeList = _CALLOC( NumCDL , struct VRRDB_cdl );
			    /* NOTE: CodeList is a static pointer. It is freed
			     *       in case FI_ACCEPT below. */
	if( CodeList == NULL )
	{
	    *Proc_LLU = FALSE;
	    __DBGpr_com(" No memory for caching Raceway Codelist Table!");
	    End
	    return OM_E_NODYNMEM;
	}

	status = VR$RDB_CDL( p_msg = &retcode,
			     nlist = VR_R_LIVELOOKUP_LSTNUM,
			     p_num = &NumCDL,
			     p_rec = CodeList );
	as$status( action = RET_STATUS );

	/* Live look up just kicked off */
	*Proc_LLU = TRUE;

	End
	return OM_S_SUCCESS;
    }

    switch( GadgetLabel )
    {
      case FI_RESET:
      {
	  IGRshort		NumSpecs=0;
	  struct VRRDB_spec_key	*Specs=NULL;

	  VRRwayLLUformUpdate( FI_RESET, fp, LivBuf );

	  status = VR$RDB_SLST( p_msg = &retcode,
			        p_num = &NumSpecs );
	  as$status( action = RET_STATUS );

	  __DBGpr_int(" Number of specs", NumSpecs);
	  Specs = _CALLOC( NumSpecs , struct VRRDB_spec_key );
	  if( Specs==NULL )
	  {
	      __DBGpr_com(" Couldn't alloc for Specs");
	      return OM_E_NODYNMEM;
	  }

	  status = VR$RDB_SLST( p_msg = &retcode,
			        p_num = &NumSpecs,
			        p_rec = Specs );
	  as$status( action = RET_STATUS );

	  FIfld_set_list_num_rows( fp, FAMILY, 0, NumSpecs );
	  for( i=0 ; i<NumSpecs ; i++ )
	  {
	      if( (Specs+i)->vendor_no == LivBuf->VendorNo )
	      {
		  FIfld_set_text( fp, VENDOR, 0, 0,
					    (Specs+i)->vendor_code, FALSE);
		  FIfld_set_list_text( fp, VENDOR, i, 0,
					    (Specs+i)->vendor_code, TRUE );
	      }
	      else
		  FIfld_set_list_text( fp, VENDOR, i, 0,
					    (Specs+i)->vendor_code, FALSE );
	  }

	  _FREE( Specs );
	  FIfld_set_text( fp, MSGFLD, 0, 0, "Pick Vendor Name", FALSE );
	  LivBuf->GadgProc = FI_RESET;
	  break;
      }

      case VENDOR:
      {
	  IGRshort		NumComps=0, SpecNum=0;
	  IGRint		FamListRows=0;
	  struct VRRDB_comps	*Comp; // CAUTION: Do *NOT* free this.
	  IGRchar		**LstTxt=NULL;

	  VRRwayLLUformUpdate( VENDOR, fp, LivBuf );

	  /* Get the vendor name picked by user */
	  status = VRGetSelText( fp, VENDOR, &text, &text_size );
	  __DBGpr_str(" Spec name chosen", text);

	  /* Get vendor number from rway_spec table */
	  status = VR$RDB_SNUM( p_nam = text , p_num = &SpecNum );
	  as$status( action = RET_STATUS );
	  __DBGpr_int(" Spec num of chosen spec",SpecNum );
	  __DBGpr_int(" Current spec num", LivBuf->VendorNo );

	  if( LivBuf->VendorNo == SpecNum )
	  {
	      /* Get pointer to location caching the "rway_comps" table */
	      VR$RDA_COMP( p_num = &NumComps, p_ptr = &Comp );
	      as$status( action = RET_STATUS );
	      __DBGpr_int(" Number of entries in Comps table", NumComps);

	      if( NumComps == 0 || Comp == NULL )
	      {
		  __DBGpr_com(" Cache access failed!");
		  End
		  return OM_E_ABORT;
	      }
	  }
	  else
	  {
	      LivBuf->VendorNo = SpecNum;

	      /* Force cache update */

	      /* 1. (Re)Load cache for the active spec */
	      VR$RDB_SET( p_msg = &retcode, spec = (LivBuf->VendorNo) );
	      as$status( action = RET_STATUS );

	      /* 2. Try access cache again */
	      VR$RDA_COMP( p_num = &NumComps, p_ptr = &Comp );
	      as$status( action = RET_STATUS );
	      __DBGpr_int(" Number of entries in Comps table", NumComps);

	      /* 3. Give up! :( */
	      if( NumComps == 0 || Comp == NULL )
	      {
		  __DBGpr_com(" Cache access failed!");
		  End
		  return OM_E_ABORT;
	      }
	  }

	  /* Query for family class based on chosen spec */
	  for( i=0 ; i<NumCDL ; i++ )
	      for( j=0 ; j<NumComps ; j++ ) // NumCDL usually << NumComps
	      {
		  if( (Comp+j)->data.famcode != (CodeList+i)->ncode ||
		      VR_IsAlreadyInList( (CodeList+i)->ltxt, LstTxt,
			  		   FamListRows )
		    )
		      continue;

		  __DBGpr_int(" Num items in Family list",FamListRows );
		  if( FamListRows )
		      LstTxt = _REALLOC( LstTxt, FamListRows+1, IGRchar * );
		  else
		      LstTxt = _CALLOC( 1 , IGRchar * );
		  *(LstTxt+FamListRows) = _CALLOC ( 13, IGRchar );
			  /* Use strNcpy below to ensure that the text in the
			   * list is only 12 characters long. The rway_codelist
			   * table's long text column supports 80 characters.*/
		  strncpy( *(LstTxt+FamListRows), (CodeList+i)->ltxt, 12);
		  __DBGpr_str("New item in Family list",*(LstTxt+FamListRows));
		  ++ FamListRows;
	      }

	  if( FamListRows )
	  {
	      IGRchar	*Louis;

	      __DBGpr_int(" Num of Fam List rows",FamListRows );
	      FIg_enable( fp, FAMILY );
	      FIfld_set_num_rows( fp, FAMILY, FamListRows );

	      Louis = _CALLOC( 13*FamListRows, IGRchar );
	      for( i=0 ; i<FamListRows ; i++ )
		  strcpy( &Louis[13*i], *(LstTxt+i) );

#ifdef vdsDEBUG
	      printf("CHECK %d %s\n", __LINE__ , __FILE__);
#endif 
	      qsort( (void *) Louis, FamListRows, 13*sizeof(IGRchar),
								  strcasecmp );
#ifdef vdsDEBUG
	      printf("after qsort of Family %d %s\n", __LINE__ , __FILE__);
#endif 

	      for( i=0 ; i<FamListRows ; i++ )
	      {
		  __DBGpr_str(" fam", &Louis[i*13]);
		  FIfld_set_text( fp, FAMILY, i, 0, &Louis[i*13], 0);
	      }

	      FIfld_set_text( fp, MSGFLD, 0, 0, "Select Family Class", FALSE );
	      _FREE( Louis );
	  }
	  else
	      FIfld_set_text( fp, MSGFLD, 0, 0, "No Family Class to select!",
								       FALSE );

	  vdb$RisFreeBuffer( buffer = LstTxt,
			     size   = FamListRows );

	  LivBuf->GadgProc = VENDOR;
	  break;
      }

      case FI_CANCEL:
      {
	  *LLU_Form = FALSE;
	  *Proc_LLU = FALSE;
	  _FREE( CodeList );

	  /* Erase the displayed form */
	  FIf_erase ( fp );

	  break;
      }

      case FI_ACCEPT:
      {
	  *Proc_LLU = FALSE;
	  *LLU_Form = FALSE;
	  _FREE( CodeList );

	  /* Erase the displayed form */
	  FIf_erase ( fp );

	  /* Process form data */

	  break;
      }

      case FAMILY:
      {
	  IGRshort		NumComps=0;
	  IGRint		CCListRows=0;
	  struct VRRDB_comps	*Comp; // CAUTION: Do *NOT* free this.
	  IGRchar		**LstTxt;

	  VRRwayLLUformUpdate( FAMILY, fp, LivBuf );

	  /* Get the family class selected by user */
	  status = VRGetSelText ( fp, FAMILY, &text, &text_size );
	  __DBGpr_str("family class selected",text);

	  for( i=0 ; i<NumCDL ; i++ )
	      if( ! strncmp( text, (CodeList+i)->ltxt, 12 ) )
	      {
		  LivBuf->FamilyNo = (CodeList+i)->ncode;
		  break;
	      }
	  __DBGpr_int(" Codenum in rway_codelist",LivBuf->FamilyNo);

	  /* Get pointer to location caching the "rway_comps" table */
	  VR$RDA_COMP( p_num = &NumComps, p_ptr = &Comp );
	  as$status( action = RET_STATUS );
	  __DBGpr_int(" Number of entries in Comps table", NumComps);

	  for( i=0 ; i<NumComps ; i++ ) 
	  {
	      if( (Comp+i)->data.famcode != LivBuf->FamilyNo ||
		  VR_IsAlreadyInList( (Comp+i)->key.comp_code, LstTxt,
		      		      CCListRows )
		)
		  continue;

	      __DBGpr_int(" Num items in Comp code list",CCListRows);
	      if( CCListRows )
		  LstTxt = _REALLOC( LstTxt, CCListRows+1, IGRchar * );
	      else
		  LstTxt = _CALLOC( 1 , IGRchar * );
	      *(LstTxt+CCListRows) = _CALLOC ( 10, IGRchar );
	      strcpy( *(LstTxt+CCListRows) , (Comp+i)->key.comp_code );
	      __DBGpr_str(" New item in comp code list",*(LstTxt+CCListRows));
	      ++ CCListRows;
	  }

	  if( CCListRows )
	  {
	      IGRchar	*Louis;

	      FIg_enable( fp, C_CODE );
	      FIfld_set_num_rows( fp, C_CODE, CCListRows );

	      Louis = _CALLOC( 13*CCListRows, IGRchar );
	      for( i=0 ; i<CCListRows ; i++ )
		  strcpy( &Louis[13*i], *(LstTxt+i) );

#ifdef vdsDEBUG
	      printf("CHECK %d %s\n", __LINE__ , __FILE__);
#endif 
	      qsort( (void *) Louis, CCListRows, 13*sizeof(IGRchar),
								  strcasecmp );
#ifdef vdsDEBUG
	      printf("CHECK %d %s\n", __LINE__ , __FILE__);
#endif 
	      for( i=0 ; i<CCListRows ; i++ )
	      {
		  __DBGpr_str(" lst", &Louis[i*13]);
		  FIfld_set_text( fp, C_CODE, i, 0,  &Louis[i*13], 0);
	      }

	      FIfld_set_text( fp, MSGFLD, 0, 0, "Select Comp Code", FALSE );
	      _FREE( Louis );
	  }
	  else
	      FIfld_set_text( fp, MSGFLD, 0, 0, "No Comp codes to select!",
								       FALSE );

	  vdb$RisFreeBuffer( buffer = LstTxt,
			     size   = CCListRows );

	  LivBuf->GadgProc = FAMILY;
	  break;

      }

      case C_CODE:
      {
	  IGRshort		NumComps=0;
	  struct VRRDB_comps	*Comp; // CAUTION: Do *NOT* free this.
	  IGRchar		**LstTxt=NULL;
	  IGRint		NumInRows=0, ShapeCodeIfTran=-1;
	  IGRboolean		bIsTransition=FALSE;

	  VRRwayLLUformUpdate( C_CODE, fp, LivBuf );

	  /* Get the comp code selected by user */
	  status = VRGetSelText ( fp, C_CODE, & text, & text_size );
	  as$status( action = RET_STATUS );
	  __DBGpr_str(" Comp code",text);

#ifdef DONOTDELETE

	  /* Commented out since DB tables were chosen to be populated to take
	   * care of shape. Might have to revert back to this later on, if
	   * Avondale does not want to use this DB scheme.
	   * 					    Anand for TR 179901308 */

	  /* Work to find out shape of chosen component */

	  /* Find out if it is a shape transition component */
	  status = VRGetShapeFrmCompCode( text, &bIsTransition,
		  			  &ShapeCodeIfTran, VR_RWAY );
	  as$status( action = RET_STATUS );

	  if( bIsTransition )
	  {
	      __DBGpr_int(" A shape transition component",ShapeCodeIfTran);
	      LivBuf->ShapeCode = ShapeCodeIfTran;
	  }
	  else
	  {
	      struct ACrg_coll	Attrib;
	      struct GRid	ActParamId;

	      __DBGpr_com(" Take active shape");

	      ActParamId.osnum = OM_Gw_current_OS;
	      VR$active_params( operation    = VR_RETRIEVE,
				VRproduct    = VR_RWAY,
				act_param_id = &ActParamId,
				status       = status );
	      as$status( action = RET_STATUS );
	      __DBGpr_obj(" Active param id",ActParamId );

	      strcpy(Attrib.name, VR_N_SHAPE_IN); 
	      status = om$send(msg = message ACrg_collect.ACget_named_attribute
							 ( &retcode, &Attrib ),
			  senderid = NULL_OBJID,  
			  targetid = ActParamId.objid,
			  targetos = ActParamId.osnum );
	      as$status( action = RET_STATUS );
	      LivBuf->ShapeCode= Attrib.desc.value.att_exp;
	  }
	  __DBGpr_int(" Shape code ",LivBuf->ShapeCode);
#endif

	  /* Get pointer to location caching the "rway_comps" table */
	  VR$RDA_COMP( p_num = &NumComps, p_ptr = &Comp );
	  as$status( action = RET_STATUS );
	  __DBGpr_int(" Number of entries in Comps table", NumComps);

	  /* Query rway_comptype table to populate Description field in form */
	  for( i=0 ; i<NumComps ; i++ ) 
	      if( ! strcmp( (Comp+i)->key.comp_code, text)   &&
	      	  (Comp+i)->data.famcode == LivBuf->FamilyNo ) // &&
	//	  (Comp+i)->key.rType == LivBuf->ShapeCode )
	      {
		  IGRshort		NumCT=0;
		  struct VRRDB_ct_key	CTKey;
		  struct VRRDB_ct	CT;

		  strcpy( LivBuf->CompCode,	(Comp+i)->key.comp_code);
		  strcpy( LivBuf->Macro,	(Comp+i)->data.famnam);
		  strcpy( LivBuf->Sh_Code,	(Comp+i)->data.sh_code);
		  LivBuf->ShapeCode = (Comp+i)->key.rType;

		  strcpy( CTKey.comp_code, LivBuf->CompCode );
		  strcpy( CTKey.sh_code, LivBuf->Sh_Code );
		  CTKey.comp_type = LivBuf->ShapeCode;

		  status = VR$RDB_CT( p_msg = &retcode,
			  	      keyin = &CTKey,
				      p_num = &NumCT,
				      p_rec = &CT );
		  as$status( action = RET_STATUS );

		  if( NumCT == 0 || retcode != MSSUCC )
		  {
		      __DBGpr_com(" Query to CompType failed!");
		      End
		      return OM_E_ABORT;
		  }

		  if( NumCT != 1 )
		      printf(" Multiple matches found for rway_comptype query. Taking first match\n");

		  LivBuf->CompTopo = CT.data.ct_topo;
		  LivBuf->NbCpts   = CT.data.ct_nmcp;
		  FIfld_set_text( fp, C_DESC, 0, 0, CT.data.descr, FALSE );

		  break;
	      }

	  for( ; i<NumComps ; i++ ) 
	  {
	      IGRchar	NewSize[16];
	      sprintf(NewSize,"%5.1lf x %-.1lf", (Comp+i)->data.dWid1,
							(Comp+i)->data.dDep1 );

	      if( ! strcmp( (Comp+i)->key.comp_code, text)   &&
	      	  (Comp+i)->data.famcode == LivBuf->FamilyNo &&
	//	  (Comp+i)->key.rType == LivBuf->ShapeCode   &&
		  ! VR_IsAlreadyInList( NewSize, LstTxt, NumInRows )
		)
	      {
		  __DBGpr_int(" Num items in Inlet size list",NumInRows);
		  if( NumInRows )
		      LstTxt = _REALLOC( LstTxt, NumInRows+1, IGRchar * );
		  else
		      LstTxt = _CALLOC( 1 , IGRchar * );
		  *(LstTxt+NumInRows) = _CALLOC ( 16, IGRchar );
		  strcpy( *(LstTxt+NumInRows) , NewSize );
		  __DBGpr_str(" Adding to Inlet size list",*(LstTxt+NumInRows));
		  ++ NumInRows;
	      }
	  }
	  __DBGpr_int(" Number of Inlet sizes", NumInRows );

	  if( NumInRows )
	  {
	      IGRchar		*OneBlock=NULL;
	      struct ACrg_coll	Attrib;
	      struct GRid	ActParamId;
	      IGRdouble		ActWid=0.0, ActDep=0.0;

	      FIg_enable( fp, INLET );
	      FIfld_set_list_num_rows( fp, INLET, 0, NumInRows );

	      OneBlock = _CALLOC( 16*NumInRows, IGRchar );
	      for( i=0 ; i<NumInRows ; i++ )
		  strcpy( &OneBlock[16*i], *(LstTxt+i) );

	      qsort( (void *) OneBlock, NumInRows, 16*sizeof(IGRchar),
							      SizeWidDepSort );

	      ActParamId.objid = NULL_OBJID;
	      ex$get_cur_mod( osnum = &ActParamId.osnum );
	      __DBGpr_obj(" Active param id",ActParamId );
	      VR$active_params( operation    = VR_RETRIEVE,
				VRproduct    = VR_RWAY,
				act_param_id = &ActParamId,
				status       = status );
	      as$status( action = RET_STATUS );
	      __DBGpr_obj(" Active param id",ActParamId );

	      strcpy(Attrib.name, VR_N_WIDTH1_DB); 
	      status = om$send(msg = message ACrg_collect.ACget_named_attribute
							 ( &retcode, &Attrib ),
			  senderid = NULL_OBJID,  
			  targetid = ActParamId.objid,
			  targetos = ActParamId.osnum );
	      as$status( action = RET_STATUS );
	      ActWid = Attrib.desc.value.att_exp;
	      __DBGpr_dbl(" Active Width",ActWid);

	      strcpy(Attrib.name, VR_N_DEPTH1_DB); 
	      status = om$send(msg = message ACrg_collect.ACget_named_attribute
							 ( &retcode, &Attrib ),
			  senderid = NULL_OBJID,  
			  targetid = ActParamId.objid,
			  targetos = ActParamId.osnum );
	      as$status( action = RET_STATUS );
	      ActDep = Attrib.desc.value.att_exp;
	      __DBGpr_dbl(" Active Depth",ActDep);

	      for( i=0 ; i<NumInRows ; i++ )
	      {
		  IGRdouble	dWid=0.0, dDep=0.0;

		  sscanf( &OneBlock[16*i], "%lf x %lf", &dWid, &dDep );

		  if( fabs(dWid-ActWid)<VRGetTol(VR_DIST_TOL) &&
		      ( fabs(dDep)<VRGetTol(VR_DIST_TOL) ||
                        fabs(dDep-ActDep)<VRGetTol(VR_DIST_TOL) ) )
		  {
		      FIfld_set_list_text( fp, INLET, i, 0, &OneBlock[16*i],
									FALSE );
		      FIfld_set_text( fp, INLET, 0, 0, &OneBlock[16*i], FALSE );
		      FIfld_set_list_select( fp, INLET, i, 0, TRUE );
		      __DBGpr_str(" Highlight print", &OneBlock[16*i]);
		  }
		  else
		      FIfld_set_list_text( fp, INLET, i, 0, &OneBlock[16*i],
								       FALSE );
	      }

	      FIfld_set_text( fp, MSGFLD, 0, 0, "Select Inlet size", FALSE );
	      _FREE( OneBlock );
	  }
	  else
	      FIfld_set_text( fp, MSGFLD, 0, 0,
		      "No Inlet size available for chosen comp_code!", FALSE );

	  vdb$RisFreeBuffer( buffer = LstTxt, size = NumInRows );

	  LivBuf->GadgProc = C_CODE;
	  break;
      }

      case INLET:
      {
	  IGRshort		NumComps=0;
	  struct VRRDB_comps	*Comp; // CAUTION: Do *NOT* free this.
	  IGRchar		**LstTxt=NULL;
	  IGRint		NumOutRows=0;

	  VRRwayLLUformUpdate( INLET, fp, LivBuf );

	  /* Get the inlet size selected by user */
	  status = VRGetSelText ( fp, INLET, & text, & text_size );
	  sscanf(text,"%lf x %lf",&(LivBuf->InlWidth),&(LivBuf->InlDepth));
	  __DBGpr_dbl(" Inlet Width",(LivBuf->InlWidth));
	  __DBGpr_dbl(" Inlet Depth",(LivBuf->InlDepth));

	  /* Get pointer to location caching the "rway_comps" table */
	  VR$RDA_COMP( p_num = &NumComps, p_ptr = &Comp );
	  as$status( action = RET_STATUS );
	  __DBGpr_int(" Number of entries in Comps table", NumComps);

	  for( i=0 ; i<NumComps ; i++ ) 
	  {
	      IGRchar	NewSize[16];
	      sprintf(NewSize,"%5.1lf x %-.1lf", (Comp+i)->data.dWid2,
							(Comp+i)->data.dDep2 );

	      if( ! strcmp( (Comp+i)->key.comp_code, LivBuf->CompCode ) &&
		  (Comp+i)->data.famcode == LivBuf->FamilyNo 		&&
//		  (Comp+i)->key.rType    == LivBuf->ShapeCode		&&
		  (Comp+i)->data.dWid1   == LivBuf->InlWidth		&&
		  (Comp+i)->data.dDep1   == LivBuf->InlDepth		&&
		  ! VR_IsAlreadyInList( NewSize, LstTxt, NumOutRows )
		)
	      {
		  __DBGpr_int(" Num items in Outlet size list",NumOutRows);
		  if( NumOutRows )
		      LstTxt = _REALLOC( LstTxt, NumOutRows+1, IGRchar * );
		  else
		      LstTxt = _CALLOC( 1 , IGRchar * );
		  *(LstTxt+NumOutRows) = _CALLOC ( 16, IGRchar );
		  strcpy( *(LstTxt+NumOutRows) , NewSize );
		  __DBGpr_str(" Added Outlet size list",*(LstTxt+NumOutRows));
		  ++ NumOutRows;
	      }
	  }
	  __DBGpr_int(" Number of Outlet sizes", NumOutRows );

	  if( NumOutRows )
	  {
	      IGRchar	*OneBlock;

	      FIg_enable( fp, OUTLET );
	      FIfld_set_list_num_rows( fp, OUTLET, 0, NumOutRows );

	      OneBlock = _CALLOC( 16*NumOutRows, IGRchar );
	      for( i=0 ; i<NumOutRows ; i++ )
		  strcpy( &OneBlock[16*i], *(LstTxt+i) );

	      qsort( (void *) OneBlock, NumOutRows, 16*sizeof(IGRchar),
							      SizeWidDepSort );

	      for( i=0 ; i<NumOutRows ; i++ )
		  FIfld_set_list_text( fp, OUTLET, i, 0, &OneBlock[16*i],
								       FALSE );

	      FIfld_set_text( fp, MSGFLD, 0, 0, "Select Outlet size", FALSE );
	      _FREE( OneBlock );
	  }
	  else
	      FIfld_set_text( fp, MSGFLD, 0, 0,
			      "No Outlet size for chosen inlet size!", FALSE );

	  vdb$RisFreeBuffer( buffer = LstTxt, size = NumOutRows );

	  LivBuf->GadgProc = INLET;
	  break;
      }

      case OUTLET:
      {
	  VRRwayLLUformUpdate( OUTLET, fp, LivBuf );

	  /* Get the text string */
	  status = VRGetSelText ( fp, OUTLET, & text, & text_size );

	  /* Code to process text string "text" */
	  sscanf(text,"%lf x %lf",&(LivBuf->OutWidth),&(LivBuf->OutDepth));
	  __DBGpr_dbl(" Outlet Width",(LivBuf->OutWidth));
	  __DBGpr_dbl(" Outlet Depth",(LivBuf->OutDepth));

	  FIfld_set_text( fp, MSGFLD, 0, 0, "Key in Comp Number", FALSE );
	  FIfld_pos_cursor( fp, TAG_NO, 0, 0, 0, 0, 0, 0 );

	  FIg_enable( fp, FI_ACCEPT );
	  LivBuf->GadgProc = OUTLET;
	  break;

      }

      case TAG_NO:
      {
	  status = VRGetSelText ( fp, TAG_NO, & text, & text_size );
	  LivBuf->CompNumb = _CALLOC( text_size, IGRchar ); 
	  strcpy( LivBuf->CompNumb, text );

	  break;
      }
    } /* END switch ( GadgetLabel ) */

    _FREE( text );
    End
    return OM_S_SUCCESS;

} /* END notification_routine() */


/* Below function viz., VRRwayTraySelector implements CR 179900991 */

IGRint VRRwayTraySelector( Form fp, IGRint Gdgt, IGRint SketchMode,
						   struct GRid *ParameterID )
{
    struct VRRDB_comps *Comp; // CAUTION: Do NOT free this.
    IGRlong		msg;
    IGRint		ShapeCode;
    IGRint		i, j, status;
    IGRuchar		ListStr[10];
    IGRint		ListWidCnt=0 , ListDepCnt=0;
    IGRdouble	       *ListWid=NULL ,*ListDep=NULL;
    IGRdouble		QryWidth=0.0 , QryDepth=0.0;
    IGRshort		NumComps=0   , dSpecNum=0;
    struct ACrg_coll	Attr;

    SetProc( VRRwayTraySelector ); Begin

    FIfld_set_list_num_rows( fp, FRM_WIDTH_1, 0, 0 );
    FIfld_set_list_num_rows( fp, FRM_DEPTH_1, 0, 0 );

    if( SketchMode == VR_MANUAL )
    {
	End
	return OM_S_SUCCESS;
    }

    switch( Gdgt )
    {
      case FRM_WIDTH_1:
	  FIfld_get_value( fp, Gdgt, 0, 0, &QryWidth, &i, &j );
	  __DBGpr_dbl(" Refine depth list for width=",QryWidth);
	  break;

      case FRM_DEPTH_1:
	  FIfld_get_value( fp, Gdgt, 0, 0, &QryDepth, &i, &j );
	  __DBGpr_dbl(" Refine Width list for Depth=",QryDepth);
	  break;
/*
      case FI_RESET:

      case FI_ACCEPT:
*/
    }

    __DBGpr_com(" Sketch mode is Automati'que'!");
    __DBGpr_obj(" Parameter ID", (*(ParameterID)) );
    strcpy(Attr.name, VR_N_SHAPE_IN); 
    status = om$send(msg =
		message ACrg_collect.ACget_named_attribute ( &msg, &Attr ),
		senderid = NULL_OBJID,  
		targetid = ParameterID->objid,
		targetos = ParameterID->osnum );
    as$status( action = RET_STATUS );
    __DBGpr_dbl(" Shape code ",Attr.desc.value.att_exp);
    ShapeCode = Attr.desc.value.att_exp;

    VR$RDA_COMP( p_num = &NumComps, p_ptr = &Comp );
    as$status( action = RET_STATUS );
    __DBGpr_int(" Number of entries in Comps table", NumComps);

    if( NumComps == 0 || Comp == NULL )
    {
	/* Force cache update */

	/* 1. Get "spec_name" from the active parameters */
	strcpy(Attr.name, VR_N_CLASS_AN ); 
	status = om$send(msg =
		    message ACrg_collect.ACget_named_attribute ( &msg, &Attr ),
		    senderid = NULL_OBJID,  
		    targetid = ParameterID->objid,
		    targetos = ParameterID->osnum );
	as$status( action = RET_STATUS );
	__DBGpr_str(" Spec name ",Attr.desc.value.att_txt);

	/* 2. From the spec_name, get the spec_no */
	VR$RDB_SNUM( p_nam = Attr.desc.value.att_txt,
		     p_num = &dSpecNum );
	as$status( action = RET_STATUS );
	__DBGpr_int("spec_num from spec_name ",dSpecNum);

	/* 3. (Re)Load cache for the active spec */
	VR$RDB_SET( p_msg = &msg, spec = dSpecNum );
	as$status( action = RET_STATUS );

	/* 4. Try access cache again */
	VR$RDA_COMP( p_num = &NumComps, p_ptr = &Comp );
	as$status( action = RET_STATUS );
	__DBGpr_int(" Number of entries in Comps table", NumComps);

	/* 5. Give up! :( */
	if( NumComps == 0 || Comp == NULL )
	{
	    __DBGpr_com(" Cache access failed!");
	    End
	    return OM_S_SUCCESS;
	}
    }

    for( i=0 ; i<NumComps ; i++ )
    {
	if( strcmp((Comp+i)->key.comp_code,"TRAY") ||
	    (Comp+i)->key.rType != ShapeCode )
	    continue;

	if( Gdgt == FRM_WIDTH_1 && QryWidth != 0.0 &&
	    fabs( (Comp+i)->data.dWid1 - QryWidth ) > VRGetTol(VR_DIST_TOL) )
	    continue;

	if( Gdgt == FRM_DEPTH_1 && QryDepth != 0.0 &&
	    fabs( (Comp+i)->data.dDep1 - QryDepth ) > VRGetTol(VR_DIST_TOL) )
	    continue;

	__DBGpr_int(" No. widths in list",ListWidCnt);
	for( j=ListWidCnt-1 ; j>=0 ; j-- )
	    if( *(ListWid+j) == (Comp+i)->data.dWid1 )
		break;

	// At this point, if j>=0 the width entry is already in the list.

	if( j<0 )
	{
	    if( ListWidCnt )
		ListWid = _REALLOC( ListWid, ListWidCnt+1, IGRdouble );
	    else
		ListWid = _CALLOC ( 1, IGRdouble );

	    /* Put the new entry in its sorted location */
	    for( j=ListWidCnt ; j>=0 ; j-- )
	    {
		if( (Comp+i)->data.dWid1 > *(ListWid+j-1) )
		{
		    *(ListWid+j) = (Comp+i)->data.dWid1;
		    break;
		}
		else
		    *(ListWid+j) = *(ListWid+j-1);
	    }
	    __DBGpr_dbl("New Width in list",*(ListWid+j));
	    __DBGpr_int(" Its location",j);
	    ++ ListWidCnt;
	}

	if( ShapeCode == VR_RECT || ShapeCode == VR_CIRC )
	    continue;

	__DBGpr_int(" No. depths in list",ListDepCnt);
	for( j=ListDepCnt-1 ; j>=0 ; j-- )
	    if( *(ListDep+j) == (Comp+i)->data.dDep1 )
		break;

	// At this point, if j>=0 the depth entry is already in the list.

	if( j<0 )
	{
	    if( ListDepCnt )
		ListDep = _REALLOC( ListDep, ListDepCnt+1, IGRdouble );
	    else
		ListDep = _CALLOC ( 1, IGRdouble );

	    /* Put the new depth in its sorted location */
	    for( j=ListDepCnt ; j>=0 ; j-- )
	    {
		if( (Comp+i)->data.dDep1 > *(ListDep+j-1) )
		{
		    *(ListDep+j) = (Comp+i)->data.dDep1;
		    break;
		}
		else
		    *(ListDep+j) = *(ListDep+j-1);
	    }
	    __DBGpr_dbl("New Depth in list",*(ListDep+j));
	    __DBGpr_int(" Its location",j);
	    ++ ListDepCnt;
	}
    }

    FIfld_set_list_num_rows( fp, FRM_WIDTH_1, 0, ListWidCnt);
    for( i=0 ; i<ListWidCnt ; i++ )
    {
	sprintf((char *)ListStr,"%.2lf",*(ListWid+i));
	FIfld_set_list_text( fp, FRM_WIDTH_1, i, 0, ListStr, FALSE);
    }

    FIfld_set_list_num_rows( fp, FRM_DEPTH_1, 0, ListDepCnt);
    for( i=0 ; i<ListDepCnt ; i++ )
    {
	sprintf((char *)ListStr,"%.2lf",*(ListDep+i));
	FIfld_set_list_text( fp, FRM_DEPTH_1, i, 0, ListStr, FALSE);
    }

    _FREE( ListWid );
    _FREE( ListDep );

    End
    return OM_S_SUCCESS;
}

end implementation Root;
