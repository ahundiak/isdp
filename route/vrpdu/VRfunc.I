/* $Id: VRfunc.I,v 1.5 2001/10/15 00:25:23 anand Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrpdu / VRfunc.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRfunc.I,v $
 *	Revision 1.5  2001/10/15 00:25:23  anand
 *	Rollback of fix JTS TR MP 5586 (will need to redeliver fix
 *	for Pload).
 *	
 *	Revision 1.3  2001/02/20 01:15:24  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.2  2001/01/12 23:22:31  anand
 *	SP merge
 *	
# Revision 1.2  2000/05/15  21:35:14  pinnacle
# Replaced: route/vrpdu/VRfunc.I for:  by apazhani for Service Pack
#
# Revision 1.1  2000/05/11  22:07:58  pinnacle
# Created: route/vrpdu/VRfunc.I by apazhani for Service Pack
#
# Revision 1.6  2000/03/02  16:47:02  pinnacle
# (No comment)
#
# Revision 1.5  2000/02/10  19:25:02  pinnacle
# (No comment)
#
# Revision 1.4  2000/02/08  21:08:36  pinnacle
# (No comment)
#
# Revision 1.2  1999/04/18  08:21:38  pinnacle
# Replaced: vrpdu/VRfunc.I for:  by apazhani for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/08/15  19:34:34  pinnacle
# Replaced: vrpdu for:  by hverstee for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.3  1996/04/22  13:52:18  pinnacle
# Replaced: vrpdu/VRfunc.I for:  by hverstee for route240
#
# Revision 1.2  1996/01/17  17:30:00  pinnacle
# Replaced: vrpdu/VRfunc.I for:  by r240_int for route240
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	01/17/96  tlb	Add prototypes,
 *			Change to ANSII style:
 *				VRget_straight, VRget_bend, VRget_reducer,
 *				VRget_codelist, VRget_label
 *	04/18/99  	Alwin	Added a function to obtain the No. of Connect Pts.
 *  02/04/2000  Alwin Added 4 functions to obtain the Insulation & Material info
 *                  	from DB. CR179900696
 *  02/09/2000  Alwin Modified the functions to fetch the contents from the
 *					  Cache.
 *  05/10/2000  Alwin Modified the functions to fetch both Acoustical as well
 *					  Thermal Insulation values from the DB.
 *  05/15/2000  Alwin Commented the Implementation VRget_reducer, as its not
 *					  used any more. More over leads to compilation warnings
 *
 *************************************************************************/
class implementation Root;

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "OMminimum.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "msdef.h"
#include "VRdef.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "VRDbStruct.h"
#include "dberror.h"
#include "VRmsg.h"
#include "ms.h"
#include "msdef.h"
#include "msmacros.h"
#include "VRDbTbl.h"
#include "VRDbCache.h"
#include "vrpdu_pto.h"

#include "VRPDBdef.h"
#include "VRPDBmac.h"
#include "VRHDBdef.h"
#include "VRHDBmac.h"
#include "VRRDBdef.h"
#include "VRRDBmac.h"
#include "vdbmacros.h"
#include "VDmem.h"
#include "vrdbgmacros.h"
#include "VRRwDimen.h" /* declaration of the function is available */

extern VRenq_proj_units(); // defined vrpdu/VRXunits.I

/*
#define MY_DEBUG 1
*/

/********************************************************************/
/*                                                                  */
/* This routine extracts default AABBCC code of a pipe, duct or tray*/
/*                                                                  */
/********************************************************************/
IGRint VRget_straight (
     IGRlong     *msg,        /* Message                          (O) */
     IGRshort    application, /* Piping, HVAC or Cabling          (I) */
     IGRchar     *spec_name,  /* spec name , hvac class or        (I) */
                              /* vendor code                          */
     IGRchar     *comp_code,  /* AABBCC code of pipe, duct or tray(O) */
     IGRchar     *err_ptr     /* Error message buffer                 */
     )
{
  IGRshort       NN;
  IGRchar       *ep;

  ep = err_ptr;         /*  get rid of warning   */

   if (application == VR_PIPING)
   {
       struct VRPDB_spec_key  YY;
       struct VRPDB_spec      XX;

       strcpy (YY.spec_name, spec_name);
       YY.spec_no = VRPDB_UNDEF;

       VR$PDB_SPEC (p_msg = msg,
                    keyin = &YY,
                    p_num = &NN,
                    p_rec = &XX);

       if ((*msg != MSSUCC) || (NN == 0)) return (OM_E_ABORT);

       strcpy (comp_code, XX.data.dflt_pipe);

    }
    else
    if (application == VR_HVAC)
    {
       struct VRHDB_spec_key  YY;
       struct VRHDB_spec      XX;

       strcpy (YY.hvac_class, spec_name);
       YY.class_no = VRHDB_UNDEF;

       VR$HDB_SPEC (p_msg = msg,
                    keyin = &YY,
                    p_num = &NN,
                    p_rec = &XX);

       if ((*msg != MSSUCC) || (NN == 0)) return (OM_E_ABORT);

       strcpy (comp_code, XX.data.dflt_duct);

    }
    else
    if (application == VR_CABLING)
    {
       struct VRRDB_spec_key  YY;
       struct VRRDB_spec      XX;

       strcpy (YY.vendor_code, spec_name);
       YY.vendor_no = VRRDB_UNDEF;

       VR$RDB_SPEC (p_msg = msg,
                    keyin = &YY,
                    p_num = &NN,
                    p_rec = &XX);

       if ((*msg != MSSUCC) || (NN == 0)) return (OM_E_ABORT);

       strcpy (comp_code, XX.data.dflt_run);

    }

  *msg = ACC_S_SUCCESS;
  return OM_S_SUCCESS;
}


/*********************************************************************/
/*                                                                   */
/* This routine extracts the default bend AABBCC code from the       */
/* reference database for different applications.                    */
/*                                                                   */
/*********************************************************************/
IGRint VRget_bend (
      IGRlong     *msg,        /* Message                           (O) */
      IGRshort    application, /* Piping , HVAC or Cabling          (I) */
      IGRchar     *spec_name,  /* spec name, hvac class or          (I) */
                               /* vendor code                           */
      IGRdouble   angle,       /* bend angle                        (I) */
      IGRint      comp_type,   /* change of direction type          (I) */
                               /*  Piping - 0=non-reducing, 1=reducing   */
                               /*  Hvac   - 0=non-reducing, 1=reducing   */
                               /*  Cabling - 0=horiz, 1=vert up, 2=vert down */
      IGRchar     *comp_code,  /* AABBCC code of the fitting        (O) */
      IGRchar     *err_ptr     /* Error message                     (O) */
      )
{
  IGRshort       snum;
  IGRchar       *ep;

  ep = err_ptr;         /*  get rid of warning   */

  switch (application)
  {
    case VR_PIPING:

       VR$PDB_SNUM (p_nam = spec_name,
                    p_num = &snum);       /*   get spec number   */

       VR$PDB_BEND (p_msg = msg,
                    spec  = snum,
                    angle = angle,
                    rcode = comp_type,
                    dia   = 0.0,          /*   to be implemented ....  */
                    p_code = comp_code);
       break;

    case VR_HVAC:

       VR$HDB_SNUM (p_nam = spec_name,
                    p_num = &snum);       /*   get spec number   */

       VR$HDB_BEND (p_msg = msg,
                    spec  = snum,
                    angle = angle,
                    ctype = comp_type,
                    width = 0.0,          /*   to be implemented ....  */
                    p_code = comp_code);
       break;

    case VR_CABLING:

       VR$RDB_SNUM (p_nam = spec_name,
                    p_num = &snum);       /*   get spec number   */

       VR$RDB_BEND (p_msg = msg,
                    spec  = snum,
                    angle = angle,
                    ctype = comp_type,
                    width = 0.0,          /*   to be implemented ....  */
                    p_code = comp_code);
       break;

    default:
       *msg = MSFAIL;
       break;
  }

  if (*msg != MSSUCC) return (OM_E_ABORT);

  *msg = ACC_S_SUCCESS;
  return OM_S_SUCCESS;
}

/*************************************************************************/
/*                                                                       */
/* This routine extracts the default reducer AABBCC code from reference  */
/* database for different applications.                                  */
/*                                                                       */
/*************************************************************************/
#if 0 
IGRint VRget_reducer (
    IGRlong       *msg,        /* Message                  */
    IGRshort      application, /* Piping, HVAC or Cabling  */
    IGRchar       *spec_name,  /* spec name, hvac class or */
                               /* vendor code              */
    IGRint        comp_type,   /* component type :         */
                               /* 0=concentric, 1=eccentric*/
    IGRchar       comp_code,   /* AABBCC code of reducer   */
    IGRchar       *err_ptr     /* Error message            */
    )
{
  IGRshort       NN;
  IGRchar       *ep;

  ep = err_ptr;         /*  get rid of warning   */

  switch (application)
  {
     case VR_PIPING:
     {
       struct VRPDB_spec_key  YY;
       struct VRPDB_spec      XX;

       strcpy (YY.spec_name, spec_name);
       YY.spec_no = VRPDB_UNDEF;

       VR$PDB_SPEC (p_msg = msg,
                    keyin = &YY,
                    p_num = &NN,
                    p_rec = &XX);

       if ((*msg != MSSUCC) || (NN == 0)) return (OM_E_ABORT);

       if ( comp_type == 0 )
         strcpy (comp_code, XX.data.dflt_con);
       else
         strcpy (comp_code, XX.data.dflt_ecc);
     }
     break;

     case VR_HVAC:
     {
       struct VRHDB_spec_key  YY;
       struct VRHDB_spec      XX;

       strcpy (YY.hvac_class, spec_name);
       YY.class_no = VRHDB_UNDEF;

       VR$HDB_SPEC (p_msg = msg,
                    keyin = &YY,
                    p_num = &NN,
                    p_rec = &XX);

       if ((*msg != MSSUCC) || (NN == 0)) return (OM_E_ABORT);

       if ( comp_type == 0 )
         strcpy (comp_code, XX.data.dflt_con);
       else
         strcpy (comp_code, XX.data.dflt_ecc);
     }
     break;

     case VR_CABLING:
     {
       struct VRRDB_spec_key  YY;
       struct VRRDB_spec      XX;

       strcpy (YY.vendor_code, spec_name);
       YY.vendor_no = VRRDB_UNDEF;

       VR$RDB_SPEC (p_msg = msg,
                    keyin = &YY,
                    p_num = &NN,
                    p_rec = &XX);

       if ((*msg != MSSUCC) || (NN == 0)) return (OM_E_ABORT);

       if ( comp_type == 0 )
         strcpy (comp_code, XX.data.dflt_con);
       else
         strcpy (comp_code, XX.data.dflt_ecc);
     }
     break;

  }

  *msg = ACC_S_SUCCESS;
  return OM_S_SUCCESS;
}
#endif 

IGRint VRget_adapter ( msg, spec_name, end_prep_1, end_prep_2,
                       comp_code,err_ptr )

    IGRlong   *msg;        /* Message                */
    IGRchar   *spec_name;  /* spec name              */
    IGRint    end_prep_1;  /* first end prep         */
    IGRint    end_prep_2;  /* second end prep        */
    IGRchar   *comp_code;  /* AABBCC code of adapter */
    IGRchar   *err_ptr;    /* Error message          */
{
/**************************************************************************/
/*                                                                        */
/* This routine extracts default adapter AABBCC code for piping from      */
/* reference database.                                                    */
/*                                                                        */
/**************************************************************************/

    int sts;

     if(VdsRisAttach() != OM_S_SUCCESS)
     {
       if(err_ptr != NULL)
       {
         ex$message(msgnumb = VR_E_RisInitFailed,
                    buff   = err_ptr);
       }
       *msg = VR_E_RisInitFailed;
       return(OM_E_ABORT);
     }

    sts = 0;
    /* Get AABBCC code from VDS database */
    sts = get_adapter ( spec_name, end_prep_1, end_prep_2,
                        comp_code,err_ptr);
    if ( sts != 1 )
    {
      *msg = VR_E_DbShortErrMsg;
      return (OM_E_ABORT);
    }
    *msg = ACC_S_SUCCESS;
    return OM_S_SUCCESS;
}

IGRint VRget_transition ( msg, spec_name, shape_code,
                          comp_code,err_ptr )

    IGRlong    *msg;         /* Message                   */
    IGRchar    *spec_name;   /* Hvac class                */
    IGRint     shape_code;   /* code for end shapes       */
    IGRchar    *comp_code;   /* AABBCC code of transition */
    IGRchar    *err_ptr;     /* Error message buffer      */
{
  /*************************************************************************/
  /*                                                                       */
  /* This routine extracts the default transition AABBCC code from the     */
  /* reference database.                                                   */
  /*                                                                       */
  /*************************************************************************/

    int   sts;


     if(VdsRisAttach() != OM_S_SUCCESS)
     {
       if(err_ptr != NULL)
       {
         ex$message(msgnumb = VR_E_RisInitFailed,
                    buff   = err_ptr);
       }
       *msg = VR_E_RisInitFailed;
       return(OM_E_ABORT);
     }

    sts = 0;
    /* GET AABBCC Code from VDS database  */
    sts = get_transition ( spec_name, shape_code, comp_code,err_ptr );

    if ( sts != 1 )
    {
      *msg = VR_E_DbShortErrMsg;
      return (OM_E_ABORT);
    }
    *msg = ACC_S_SUCCESS;
    return OM_S_SUCCESS;
}


/*************************************************************************/
/*                                                                       */
/* This routine extracts the code list texts for different applications  */
/*                                                                       */
/*************************************************************************/
IGRint VRget_codelist (
     IGRlong     *msg,         /* Message                         */
     IGRshort    application,  /* Piping, Hvac, Cabling or Struct */
     IGRint      list_num,     /* code list number                */
     IGRint      code_num,     /* code number                     */
     IGRchar     *short_txt,   /* short code list text            */
     IGRchar     *long_txt,    /* long code list text             */
     IGRchar     *err_ptr      /* Error buffer                    */
     )
{
  IGRshort       NN;
  IGRchar       *ep;

  ep = err_ptr;         /*  get rid of warning   */

  switch (application)
  {
     case VR_PIPING:
     {
       struct  VRPDB_cdl    XX;

       VR$PDB_CDL (p_msg = msg,
                   nlist = list_num,
                   ncode = code_num,
                   p_num = &NN,
                   p_rec = &XX);

       if ((*msg != MSSUCC) || (NN == 0)) return (OM_E_ABORT);

       strcpy (short_txt, XX.stxt);
       strcpy (long_txt, XX.ltxt);
     }
     break;

     case VR_HVAC:
     {
       struct  VRHDB_cdl    XX;

       VR$HDB_CDL (p_msg = msg,
                   nlist = list_num,
                   ncode = code_num,
                   p_num = &NN,
                   p_rec = &XX);

       if ((*msg != MSSUCC) || (NN == 0)) return (OM_E_ABORT);

       strcpy (short_txt, XX.stxt);
       strcpy (long_txt, XX.ltxt);
     }
     break;

     case VR_CABLING:
     {
       struct  VRRDB_cdl    XX;

       VR$RDB_CDL (p_msg = msg,
                   nlist = list_num,
                   ncode = code_num,
                   p_num = &NN,
                   p_rec = &XX);

       if ((*msg != MSSUCC) || (NN == 0)) return (OM_E_ABORT);

       strcpy (short_txt, XX.stxt);
       strcpy (long_txt, XX.ltxt);
     }
     break;
  }

  *msg = ACC_S_SUCCESS;
  return OM_S_SUCCESS;
}

/*************************************************************************/
/*                                                                       */
/* This routine retreives the No. of Connect point of a component, given the
 * Component Code and shape_code.
 *
 *      Given : comp_code, spec_name & shape_code
 *      Output : comp_nbcpt
 *      Mainly written for RACEWAY, may be modified to use for HVAC also.
/*                                                                       */
/*************************************************************************/
IGRlong VRGetComp_NbCpt (
     IGRlong     *msg,         /* Message               (O)     */
     IGRshort    application,  /* Hvac  or Rway         (I)     */
     IGRint      shape_code,   /* Shape code            (I)     */
     IGRchar     *spec_name,   /* Hvac/Rway class       (I)     */
     IGRchar     *comp_code,   /* comp code             (I)     */
     IGRint      *NbCpt        /* Nb. of connect point in Component (O) */
     )
{
  IGRshort      spec_no;
  IGRlong       sts;

  SetProc( Fn VRGetComp_NbCpt ); Begin

  if ( application == VR_RWAY )
  {
    IGRint               rows;
    IGRchar              **DbIO=NULL;
    IGRchar              short_code[10], select[20], szWhere[200];
    struct VRRDB_ct_key  CompType;
    struct VRRDB_ct     *Rec=NULL;

    /* From the spec_name get the spec_no using the below macro */
    sts = VR$RDB_SNUM ( p_nam = spec_name,
                        p_num = &spec_no );

    __DBGpr_int( " Spec No ", spec_no );

    strcpy( select, "short_code" );

    sprintf (szWhere, "comp_code = '%s' AND rway_type = %d AND vendor_no = %d",
                                 comp_code, shape_code, spec_no );

    __DBGpr_str( " szWhere is ", szWhere );

    sts =
    vdb$RisSelect (select     = select,
                   table_name = "rway_comps",
                   where      = szWhere,
                   numselect  = 1,
                   p_numrows  = &rows,
                   p_buffer   = &DbIO);

    if (!(sts & OM_S_SUCCESS) || (rows == 0))
    {
      printf("Failed accessing rway_comps for %s where %s\n", select, szWhere );
      *msg = MSFAIL;
      End
      return( OM_S_SUCCESS );
    }

    strcpy ( short_code, DbIO[0] ); //store the short_code
    __DBGpr_str( " Short Code ", short_code );
    VdsRisFreeBuffer( DbIO, rows ); //free the memory allocated

    rows = 0;
    strcpy( CompType.comp_code, comp_code );
    strcpy( CompType.sh_code, short_code );
    CompType.comp_type = VRRDB_UNDEF;

    sts = VR$RDB_CT(p_msg = msg,
                    keyin = &CompType,
//                    p_num = (IGRshort*)&rows,
                    p_num = (IGRshort*)&rows,
                    p_rec = NULL );

    __DBGpr_int( " Nb rows returned from 'rway_comp_type' table ", rows );
    if( rows > 0 )
    {
        Rec = _MALLOC ( rows, struct VRRDB_ct );

        if( Rec == NULL )
        {
          __DBGpr_com( " Memory allocation error " );
          End
          return OM_E_NODYNMEM;
        }

        sts = VR$RDB_CT(p_msg = msg,
                        keyin = &CompType,
                        p_num = (IGRshort*)&rows,
                        p_rec = Rec );

        *NbCpt = Rec[0].data.ct_nmcp;
        __DBGpr_int( " No. of Connect point ", *NbCpt );

        _FREE( Rec );
    }
  }

  *msg = ACC_S_SUCCESS;
  End
  return OM_S_SUCCESS;
}

/*************************************************************************/
/*                                                                       */
/* This routine retreives the Material Class information based on the    *
 * selected spec_name. Revised as per CR179901312
 *
 *	For the insulation case: spec_name : should come with an input of 
 *										 either "A" or "T". 
 *		"A"	- Acoustic and
 *		"T"	- Thermal Insulation
 *
 *      Given : spec_name
 *      Output : Material_class 
 *      Mainly written for HVAC
/*                                                                       */
/*************************************************************************/
IGRint VRHGet_Material_Insulation_ClassInfo( 
	IGRlong     *msg,       		/* Message              (O) */
	IGRchar 	*spec_name, 		/* Spec Name 		 	(I)	*/
	IGRint		*nbMaterialClass, 	/* Nb. Material Class  	(O)	*/
	IGRchar 	**material_class, 	/* Material Class		(O)	*/
	IGRint		*nbInsulationClass, /* Nb. Insulation Class (O)	*/
	IGRchar 	**insulation_class 	/* Insulation Class		(O)	*/
	)
{
  IGRlong       		sts, i;
  IGRshort             	rows=0;

  SetProc( Fn VRHGet_Material_Insulation_ClassInfo ); Begin

  if( spec_name && nbMaterialClass && material_class && nbInsulationClass && insulation_class ) return OM_E_INVARG;

  /**********************************************************************/
  /*			Fetch the Material Class Info First						*/
  /**********************************************************************/

  if( material_class || nbMaterialClass )
  {
     IGRshort		spec_no;

	 sts = VR$HDB_SNUM ( p_nam = spec_name,
                        p_num = &spec_no );

	/* Get the nummber of Material */
	sts = VR$HDB_MATERIAL(  p_msg = msg,
                    		spec  = spec_no,
							p_num = &rows );

	if (!(sts & OM_S_SUCCESS) || (rows == 0))
	{
	  *msg = MSFAIL;
	  End
	  return( OM_S_SUCCESS );
	}

	if ( nbMaterialClass )
	  *nbMaterialClass = rows;

	if( material_class )
	{
	  struct VRHDB_material		*pMatRec=NULL;

	  pMatRec = _CALLOC( rows, struct VRHDB_material );
	  __CheckPtr( pMatRec, "Failed to Allocate memory: Material spec",quit);

	  sts = VR$HDB_MATERIAL(  p_msg = msg,
							  spec  = spec_no,
							  p_num = &rows,
							  p_rec = pMatRec );

	  for( i=0; i<rows; i++ )
	  {
		  //strcpy( material_class[i], pMatRec[i].key.material_class );
		  // we need to return the duct_material for the corresponding spec
		  strcpy( material_class[i], pMatRec[i].data.duct_matl );
		  __DBGpr_str( "Material Class ", material_class[i] );
	  }
	  _FREE( pMatRec );
	}
  }

  /**********************************************************************/
  /*			Fetch the Insulation Class Info 						*/
  /**********************************************************************/

  if( insulation_class || nbInsulationClass )
  {
	IGRint					nIndex = 0;
	struct VRHDB_insulation	*pInsulRec=NULL;

	rows = 0;

	/* Get the no. of Insulation classes available */
	sts = VR$HDB_INSULATION(p_msg = msg,
							p_num = &rows );

	__DBGpr_int( "Total No. of Insulation classes in db ", rows );

	if (!(sts & OM_S_SUCCESS) || (rows == 0))
	{
	  *msg = MSFAIL;
	  End
	  return( OM_S_SUCCESS );
	}

	pInsulRec = _CALLOC( rows, struct VRHDB_insulation );
	__CheckPtr( pInsulRec, "Failed to Allocate memory: Insulation spec",quit);

	/* Get the no. of Insulation classes available */
	sts = VR$HDB_INSULATION(p_msg = msg,
							p_num = &rows,
							p_rec = pInsulRec );

	__DBGpr_str( " Insulation Type ", spec_name );
	for( i=0; i<rows; i++ )
	{
		if( pInsulRec[i].insul_type[0] == spec_name[0] )
		{
			if( insulation_class )
			  strcpy( insulation_class[nIndex], pInsulRec[i].insul_class );	
			nIndex++;
		}
	}

	if( nbInsulationClass ) *nbInsulationClass = nIndex;

	_FREE( pInsulRec );
  }

quit:
  *msg = ACC_S_SUCCESS;
  End
  return OM_S_SUCCESS;
}

/*************************************************************************/
/*                                                                       */
/* This routine retreives the Insulation & Material Thicknesses given the*
 * insulation & Material classes respectively.
 *
 *      Given : material_class, insulation_class
 *      Output : Material_thickness, insulation_thickness 
 *      Mainly written for HVAC
/*                                                                       */
/*************************************************************************/
IGRint VRHGet_Material_Insulation_Thickness( 
	IGRlong     *msg,       		/* Message              (O) */
	IGRchar 	*material_class, 	/* Material Class		(I)	*/
	IGRdouble 	*dMaterialThickness,/* Insulation Thickness	(O)	*/
	IGRchar 	*insulation_class, 	/* Insulation Class		(I)	*/
	IGRdouble 	*dInsulThickness 	/* Insulation Thickness	(O)	*/
	)
{
  IGRshort             	i, rows=0;
  IGRlong				sts;
  IGRlong				units_set;

  SetProc( Fn VRHGet_Material_Insulation_Thickness ); Begin

  if ( dMaterialThickness && dInsulThickness ) return OM_E_INVARG;

  units_set = VRenq_proj_units();
  __DBGpr_int( " Units Set ", units_set );

  if( material_class )
  {
	struct VRHDB_material	*pMatRec=NULL;

	// get the cache content....please don't free the memory */
	sts = VR$HDA_MATERIAL( p_num = &rows, p_ptr = &pMatRec );

	if (!(sts & OM_S_SUCCESS) || (rows == 0))
	{
	  *msg = MSFAIL;
	  End
	  return( OM_S_SUCCESS );
	}

	for ( i=0; i<rows; i++ )
	{
		if( strcmp( pMatRec[i].data.duct_matl, material_class ) ) continue;

		if ( dMaterialThickness )
		{
		  if ( units_set == VR_IMPERIAL_UNITS )
			*dMaterialThickness = pMatRec[i].data.dDuctThick_imp;
		  else 
			*dMaterialThickness = pMatRec[i].data.dDuctThick_met;
		}
	}
  }

  if( insulation_class )
  {
	struct VRHDB_insulation	*pInsulRec=NULL;

	// get the number of material specs available */
	sts = VR$HDA_INSULATION( p_num = &rows, p_ptr = &pInsulRec );

	if (!(sts & OM_S_SUCCESS) || (rows == 0))
	{
	  *msg = MSFAIL;
	  End
	  return( OM_S_SUCCESS );
	}

	for ( i=0; i<rows; i++ )
	{
		if( strcmp( pInsulRec[i].insul_class, insulation_class ) ) continue;

		if ( dInsulThickness )
		{
		  if ( units_set == VR_IMPERIAL_UNITS )
			*dInsulThickness = pInsulRec[i].dInsulThick_imp;
		  else 
			*dInsulThickness = pInsulRec[i].dInsulThick_met;
		}
		break;
	}
  }

quit:
  *msg = ACC_S_SUCCESS;
  End
  return OM_S_SUCCESS;
}


/*************************************************************************/
/*                                                                       */
/* This routine used for updating the lists of Material or Insulation    *
 * based on the input 
 *
 *      Given : material_class or insulation_class
 *		In the case of Insulation:
 *			we have two different cases 
 *					1. Thermal Insulation ( szText = "T" ) ( I )
 *					2. Acoustical Insulation ( szText = "A" ) ( I )
 *      Mainly written for HVAC
/*                                                                       */
/*************************************************************************/
IGRint VRUpdMaterial_InsulationList( 
		IGRchar 	*form_ptr, 
		IGRboolean 	bIsMaterial, 
		IGRchar		*szText, // field text ( Material or Insulation class )
		IGRint		gadget_to_update )
{
	IGRint          i, nbClass=0;
	IGRlong         msg, sts;

	SetProc( Fn VRUpdMaterial_InsulationList ); Begin

	if( bIsMaterial )
	{
		/* Get the Material Class information from the DB */
		sts = VRHGet_Material_Insulation_ClassInfo( &msg, szText,
					&nbClass, NULL, NULL, NULL );
		__DBGpr_int( "No. of Material Classes ", nbClass );
	}
	else
	{
		/* Get the Insulation Class information from the DB */
		sts = VRHGet_Material_Insulation_ClassInfo( &msg, szText,
					NULL, NULL, &nbClass, NULL );
		__DBGpr_int( "No. of Insulation Classes ", nbClass );
	}

	if( sts & msg && ( nbClass != 0) )
	{
	   IGRchar      **class; // 24 is the DB limit

	   class = _CALLOC( nbClass, IGRchar*);
	   if ( !class ) return OM_E_NODYNMEM;

	   for( i=0; i<nbClass; i++ )
	   {
			class[i] = _CALLOC( 25, IGRchar );
			if ( !class[i] ) return OM_E_NODYNMEM;
	   }

	   if( bIsMaterial )
	   {
		   /* Get the Material Class information from the DB */
		   sts = VRHGet_Material_Insulation_ClassInfo( &msg, szText,
					   NULL, class, NULL, NULL );
	   }
	   else
	   {
		   nbClass = 0;
		   /* Get the Insulation Class information from the DB */
		   sts = VRHGet_Material_Insulation_ClassInfo( &msg, szText,
						NULL, NULL, &nbClass, class );
	   }

	   FIfld_set_list_num_rows(form_ptr, gadget_to_update, 0, nbClass);
	   for( i=0; i<nbClass; i++ )
	   {
		  /** Set the information in the gadget DUCT_MATER **/
		 VDfld_set_list_text( form_ptr, gadget_to_update, i, 0, class[i], 0 );
	   }
	   _LOOPFREE( class, nbClass ); // free the allocated memory
	}
	else if( nbClass == 0 )
	{
	   FIfld_set_list_num_rows(form_ptr, gadget_to_update, 0, nbClass);
	   FIg_set_text( form_ptr, gadget_to_update, " " );
	}


	End
	return 0;
}

IGRint VRUpdMaterial_InsulationThickness( 
		IGRchar 	*form_ptr, 
		IGRboolean 	bIsMaterial, 
		IGRchar		*szText, // field text ( Material or Insulation class )
		IGRint		gadget_to_update )
{
	IGRint 			sts;
	IGRlong			retmsg; 
	IGRdouble		dThickness=0.0;

	SetProc ( Fn VRUpdMaterial_InsulationThickness ); Begin

	if( bIsMaterial )
	{
	   // Get Material Thickness
       sts = VRHGet_Material_Insulation_Thickness( &retmsg, szText, 
										&dThickness, NULL, NULL );
	}
	else
	{
	   // Get Insulation Thickness
       sts = VRHGet_Material_Insulation_Thickness( &retmsg, NULL, NULL,
                                        szText, &dThickness );
	}

	FIg_set_value( form_ptr, gadget_to_update, dThickness );

	End
	return 0;
}

end implementation Root;
