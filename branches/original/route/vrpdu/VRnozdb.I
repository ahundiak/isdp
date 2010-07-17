/* $Id: VRnozdb.I,v 1.4 2001/02/20 01:15:27 build Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:  vrpdu / VRnozdb.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VRnozdb.I,v $
 *  Revision 1.4  2001/02/20 01:15:27  build
 *  Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *  Revision 1.3  2001/01/23 21:15:04  anand
 *  Fixed code for compilation error!
 *
 *  Revision 1.2  2001/01/11 19:22:55  anand
 *  SP merge
 *
# Revision 1.1  2000/07/10  19:08:00  pinnacle
# Created: route/vrpdu/VRnozdb.I by apazhani for Service Pack
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.4  1997/12/18  19:15:50  pinnacle
# Replaced: vrpdu/VRnozdb.I for: TR 179702478 by aharihar for route
#
# Revision 1.3  1997/12/09  15:55:10  pinnacle
# Replaced: vrpdu/VRnozdb.I for: Regression in 02.04.03.04 by aharihar for route
#
# Revision 1.2  1997/08/15  19:34:34  pinnacle
# Replaced: vrpdu for:  by hverstee for route
#
# Revision 1.4  1997/04/18  16:10:06  pinnacle
# Replaced: vrpdu/VRnozdb.I for:  by yzhu for route
#
# Revision 1.3  1997/03/19  22:09:00  pinnacle
# Replaced: vrpdu/VRnozdb.I for:  by yzhu for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.3  1996/04/22  13:50:44  pinnacle
# Replaced: vrpdu/VRnozdb.I for:  by hverstee for route240
#
# Revision 1.2  1996/01/17  17:30:12  pinnacle
# Replaced: vrpdu/VRnozdb.I for:  by r240_int for route240
#
 *
 * History:
 * 10-26-94  	Lori   		CR#179422038 Changed speclst 2nd dimension to  
 *        			VR_MAX_SPEC_NAME_LEN to use this value in     
 *        			VRGetAttrFromDB for HVAC specname list       
 * 01/17/96  	tlb  		Add prototypes, Change to ANSII style: 
 *        			VRget_spec_list, VRget_code_list_set
 * 07/10/00  	Alwin  		Added function VRaccess_rway_noz. CR179901003
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
#include "ms.h"
#include "msdef.h"
#include "msmacros.h"
#include "AS_status.h"
#include "gr.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "dberror.h"

#include "VDmem.h"
#include "VDDbDef.h"
#include "vdbmacros.h"

#include "VRdef.h"
#include "VRDbStruct.h"
#include "VRmsg.h"
#include "VRDbTbl.h"
#include "VRDbCache.h"
#include "vrpdu_pto.h"
#include "vrdbgmacros.h"

#include "VRPDBdef.h"
#include "VRPDBmac.h"
#include "VRHDBdef.h"
#include "VRHDBmac.h"
#include "VRRDBdef.h"
#include "VRRDBmac.h"

/*
#define MY_DEBUG
*/

extern GRclassid           OPP_ACrg_collect_class_id;

from ACrg_collect      import  ACset_list_attribute;
from ACrg_collect      import  ACcreate;

extern
struct VRPDB_project   VRGL_PROJ;
extern
IGRint                 VRGL_specunit;

/**************************************************************/
/**************************************************************/
/*           NEW CACHE CONTROLLERS                            */
#define    VR_PARAM_CHAR         21

%safe
static
IGRshort    nCodel = 0;
static
IGRshort    *CodeN = NULL;
static
IGRchar     *CodeL = NULL;

static
IGRshort     nSpecl = 0;
static
IGRchar     *SpecL = NULL;

static
IGRchar      CUR_parname[VR_PARAM_CHAR];

static
IGRchar     *CUR_parlst = NULL;

static
IGRshort     nCUR_parcnt = 0;
%endsafe


/**************************************************************/
/*    clear cache function                                    */

void VR_DbC_Clnoz ()
{
  _FREE (CUR_parlst);
  _FREE (CodeL);
  _FREE (CodeN);
  _FREE (SpecL);

  nSpecl = 0;
  nCodel = 0;

  nCUR_parcnt    = 0;
  CUR_parname[0] = '\0';

  return;
}
/**************************************************************/


/************************************************************************
 *                                                                      *
 * This routine extracts parameters from the reference database and     *
 * constructs a parameter box which is then returned to the caller.     *
 *                                                                      *
 * For application VR_PIPING :                                          *
 *                                                                      *
 *   This routine extracts parameters associated with the piping        *
 *   nozzle.                                                            *
 *                                                                      *
 ************************************************************************/

IGRint VRaccess_noz_db ( mesg, size, end_prep, rating, 
                         end_std, pbid, err_msg )

    IGRlong     *mesg;       /* message                        (O) */
    IGRdouble   size;        /* Nominal pipe size              (I) */
    IGRchar     *end_prep;   /* End preperation                (I) */
    IGRchar     *rating;     /* Pressure rating                (I) */
    IGRchar     *end_std;    /* End standard                   (I) */
    struct GRid *pbid;       /* Parameter box id(I=osnum)    (I/O) */
    IGRchar     *err_msg;    /* error message                  (O) */
{
   IGRint        pm_no;        /* Count for the mac_pm struct       */
   IGRchar       part_number[MAX_PDM_PARTNO_SIZE];    /* PDM part number      */
   IGRint        sts, i;
   IGRint        status;
   IGRint        rows;
   IGRchar      *table=NULL;    /* table name */
   IGRchar       search[MAX_WHERE_SIZE];    /* where clause of a select */
   IGRchar       szSelect[400];
   IGRint        currcol;
   IGRint        units_set;
   IGRint        unit_col;
   IGRdouble     SIZE;
   IGRlong       msg;
   IGRchar       npd_str[20];
   IGRint        vr_table_nozzle1;
   IGRchar       end_prep1[35]; 
   IGRchar       rating1[35];
   IGRchar       end_std1[35];
   IGRchar     **DbIO;

   IGRint        nRcol;
   IGRint        iCol;
   IGRint        nLocal;
   IGRdouble     dLocal;

   struct ACrg_coll   mac_pm[MAX_MACRO_PARAMS];  /* struct for params    */
   struct VRriscol   *RSC;
   struct VRriscol   *RSM;

   SetProc(VRaccess_noz_db); Begin 

   pm_no     = 0;
   iCol      = 0;
   units_set = -1;
   unit_col  = -1;
   DbIO      = NULL;
   RSM       = NULL;

   sts = VRenq_proj_units();

   /* Verify if the size is 0. Then don't access the database */

   if( size == 0.0 )
   { 
     *mesg = VR_E_DbShortErrMsg; 
     __DBGpr_com(" size is zero ");
     End
     return (OM_E_ABORT);
   }

   /* set npd in proper units */

   SIZE = size;

   if(VRGL_PROJ.npd_eqflag == 1 )
   {
     IGRshort  NN;
     struct VRPDB_npd   *XX;
     
     VR$PDB_NPDB (p_msg = &msg,
                  p_num = &NN);

     XX = _MALLOC (NN, struct VRPDB_npd);

     VR$PDB_NPDB (p_msg = &msg,
                  p_num = &NN,
                  p_rec = XX);

     for( i = 0; i < NN; i++ )
     {
        if (size == XX[i].npd)
              SIZE = XX[i].npd_eq;
     }

     _FREE (XX);
   }

   /* process SIZE for part_number */
/*   npd_str[0] = 0;
   process_npd(SIZE, npd_str); 
 The above two lines commented by Anand. Not required in view of partnum
 representation in table nozzle */

   /* CR179528329 */
   status = VRNozzle_table_check( &msg, &vr_table_nozzle1, NULL);
   __DBGpr_int(" vr_table_nozzle1", vr_table_nozzle1);

   if( status & msg & vr_table_nozzle1 )
     table = VRDB_PIPNOZZLE1;
   else
     table = VRDB_PIPNOZZLE;

   __DBGpr_str(" table ",table);

   sts = VRdbRisCol (&msg, table, &nRcol, &RSC);
   __DBGpr_int(" nRcol",nRcol);

   if (!(sts & OM_S_SUCCESS) || (nRcol == 0))
   {
     __DBGpr_com(" VRdbRisCol failed ");
     End
     return (OM_E_ABORT);
   }

   RSM = _MALLOC (nRcol, struct VRriscol);

   /*   locate units_set first    */

   for (i=0; i< nRcol; i++)
   {
     if(strcmp(RSC[i].colname, "units_set" )==0)
        unit_col = i;

     RSM[i] = RSC[i];
   }

   /*    construct the select statement    */

   strcpy (szSelect, RSM[0].colname);

   for (i=1; i< nRcol; i++)
   {
     strcat (szSelect,",");
     strcat (szSelect, RSM[i].colname);
   }
   __DBGpr_str(" szSelect",szSelect);

   if (vr_table_nozzle1)
   {
     /* Access the family table */
     if( !strcmp( end_prep, "<blank>"))
       sprintf( end_prep1, "' ' or end_condition is null");
     else
       sprintf( end_prep1, "'%s'", end_prep);

     if( !strcmp( end_std, "<blank>"))
       sprintf( end_std1, "' ' or end_standard is null");
     else
       sprintf( end_std1, "'%s'", end_std);

     if( !strcmp( rating, "<blank>"))
       sprintf( rating1, "' ' or pressure_class is null");
     else
       sprintf( rating1, "'%s'", rating);

     sprintf( search, "nominal_size = %f and end_condition = %s and end_standard = %s and pressure_class = %s", 
     SIZE, end_prep1, end_std1, rating1 );

     __DBGpr_str(" search",search);

   }
   else
   {
       /* create the part number */
//      sprintf(part_number, "%s", npd_str);
/* Commented by Anand. Partnums of nozzles do not have any following zeros */

      sprintf(part_number, "%g", SIZE);

      if( (strcmp(end_prep, "") != NULL) && (strcmp(end_prep, " ") != NULL) )
      {
         strcat(part_number, "_");
         strcat(part_number, end_prep);
      }
      if( (strcmp(rating, "") != NULL) && (strcmp(rating, " ") != NULL) )
      {
         strcat(part_number, "_");
         strcat(part_number, rating);
      }
      if( (strcmp(end_std, "") != NULL) && (strcmp(end_std, " ") != NULL) )
      {
         strcat(part_number, "_");
         strcat(part_number, end_std);
      }
   
      sprintf( search, "p_partnum = '%s'", part_number);

     __DBGpr_str(" p_partnum",search);
    }  

    sts =
    vdb$RisSelect (select     = szSelect,
                   table_name = table,
                   where      = search,
                   numselect  = nRcol,
                   p_numrows  = &rows,
                   p_buffer   = &DbIO);

    __DBGpr_int(" rows",rows);

    if (!(sts & OM_S_SUCCESS) || (rows == 0)) goto wrapup;

    /* Locate the units_set parameter and obtain the part_units */

    if (unit_col >= 0)
         units_set = VRDBint (DbIO[unit_col]);

    __DBGpr_int( " units_set, of nozzle obtained from DB ", units_set );
    __DBGpr_int( " Seed File units_set ", VRGL_PROJ.prj_units );

    /* Load npd_g  */
    strcpy(mac_pm[pm_no].name,"npd_g");
    mac_pm[pm_no].desc.type = AC_ATTRIB_DOUBLE;
    mac_pm[pm_no].desc.value.att_exp = size;
    pm_no += 1;     

    for (currcol = 0; currcol < nRcol; currcol++)
    {
       /*CR179528329 so far, user don't define
       the macro name by database, so we don't include them into 
       the colloctor right now(maybe late) */

      __DBGpr_str(" Attribute name", RSC[currcol].colname);
      if( strcmp( RSC[currcol].colname, "macro_name") == 0) continue;

      VRDBstr(mac_pm[pm_no].name, RSC[currcol].colname);

      if(RSC[currcol].coltype == VR_RISDB_TEXT)
      {
         VRDBstr(mac_pm[pm_no].desc.value.att_txt, DbIO[currcol]);
         mac_pm[pm_no].desc.type = RSC[currcol].partype;
	 __DBGpr_str(" Attribute text",mac_pm[pm_no].desc.value.att_txt);
         pm_no += 1;
      }
      else
      if (RSC[currcol].coltype == VR_RISDB_INT)
      {
         nLocal = VRDBint (DbIO[currcol]);
 
         __DBGpr_int( " Unit Sets value from DB", nLocal );
 
         if(units_set != VRGL_PROJ.prj_units )
         {
           mac_pm[pm_no].desc.value.att_exp =
                 converted_to_vds (mac_pm[pm_no].name,
                                 units_set,VRGL_PROJ.prj_units,
                               (double) nLocal, err_msg);
 
           /* The above "conversion" is not working properly and it won't work
           for the attribute "units_set", so I'm overriding the above value*/
 
           if( !strcmp(mac_pm[pm_no].name, "units_set" ) )
               mac_pm[pm_no].desc.value.att_exp = (double)VRGL_PROJ.prj_units;
 
         }
         else
           mac_pm[pm_no].desc.value.att_exp = (double) nLocal;

         mac_pm[pm_no].desc.type = RSC[currcol].partype;
	 __DBGpr_int(" Attribute integer",mac_pm[pm_no].desc.value.att_exp);
         pm_no += 1;
      }
      else
      if (RSC[currcol].coltype == VR_RISDB_DOUBLE)
      {
         dLocal = VRDBdbl (DbIO[currcol]);

         if(units_set != VRGL_PROJ.prj_units )
         {
           mac_pm[pm_no].desc.value.att_exp =
                 converted_to_vds (mac_pm[pm_no].name,
                                  units_set,VRGL_PROJ.prj_units,
                                  dLocal, err_msg);
         }
         else
           mac_pm[pm_no].desc.value.att_exp = dLocal;

         mac_pm[pm_no].desc.type = RSC[currcol].partype;
	 __DBGpr_dbl(" Attribute double",mac_pm[pm_no].desc.value.att_exp);
         pm_no += 1;
      }
     }

#ifdef vdsDEBUG
     printf("  Creating parameter box\n  Collection Data - %d items\n", pm_no);
     for(i=0;i<pm_no;i++)
     {
       printf("  mac_pm[%d].name: %s\n",i,mac_pm[i].name);
       printf("  mac_pm[%d].desc.type: %d\n",i,mac_pm[i].desc.type);
       if(mac_pm[i].desc.type == 1)
       {
         printf("  mac_pm[%d].desc.value: %s\n",i,mac_pm[i].desc.value.att_txt);
       }
       else
       {
         printf("  mac_pm[%d].desc.value: %lf\n",i,mac_pm[i].desc.value.att_exp);
       }
     }
#endif

     /* Create the parameter box */

     status = om$construct( classid = OPP_ACrg_collect_class_id,
                           osnum = pbid->osnum,
                           p_objid = &(pbid->objid),
                           msg = message ACrg_collect.ACcreate (&msg,""));
     as$status();

     __DBGpr_obj(" parameter box id", *pbid);

     status = om$send( msg = message ACrg_collect.ACset_list_attribute
                     (&msg,pm_no,mac_pm),
                     senderid = pbid->objid,
                     targetid = pbid->objid,
                     targetos = pbid->osnum );
     as$status();

  *mesg = ACC_S_SUCCESS;

  wrapup:
  __DBGpr_com(" calling VdsRisFreeBuffer");
  VdsRisFreeBuffer (DbIO, rows);
  _FREE (RSM);
  End
  return OM_S_SUCCESS;
}    


/********************************************************************/
/*                                                                  */
/* This routine gets the list of spec names for each application    */
/*                                                                  */
/********************************************************************/
IGRint VRget_spec_list ( 
     IGRlong    *msg,        /* Message                            (O)*/
     IGRshort   application, /* Piping, HVAC or Cabling            (I)*/
     IGRshort   *listsize,   /* Number of elements in list         (O)*/
     IGRchar    **speclist,  /* List of spec names                 (O)*/
     IGRchar    *err_ptr)    /* Error buffer                       (O)*/
{
  IGRint         sts, i;
  IGRshort       NN;
  IGRchar       *ep;

   /* Initialize */

  ep = err_ptr;

   *listsize = 0;

   sts = VRenq_proj_units();

   /*    new section for piping   */

   if (application == VR_PIPING)
   {
       struct VRPDB_spec  *XX;

       VR$PDB_SPEC (p_msg = msg,
                    p_num = &NN);

       if ((*msg != MSSUCC) || (NN == 0)) return (OM_E_ABORT);

       XX = _MALLOC (NN, struct VRPDB_spec);

       VR$PDB_SPEC (p_msg = msg,
                    p_num = &NN,
                    p_rec = XX);

       if (NN != nSpecl)
       {
         if (SpecL == NULL)
           SpecL = _MALLOC (NN * VR_MAX_SPEC_NAME_LEN, IGRchar);
         else
           SpecL = _REALLOC (SpecL, NN * VR_MAX_SPEC_NAME_LEN, IGRchar);

         nSpecl = NN;
       }

       for (i=0; i<NN; i++)
         strcpy (&SpecL[i*VR_MAX_SPEC_NAME_LEN], XX[i].key.spec_name);

       *listsize = NN;
       *speclist = SpecL;

       _FREE (XX);
   }
   else
   if (application == VR_HVAC)
   {
       struct VRHDB_spec  *XX;

       VR$HDB_SPEC (p_msg = msg,
                    p_num = &NN);

       if ((*msg != MSSUCC) || (NN == 0)) return (OM_E_ABORT);

       XX = _MALLOC (NN, struct VRHDB_spec);

       VR$HDB_SPEC (p_msg = msg,
                    p_num = &NN,
                    p_rec = XX);

       if (NN != nSpecl)
       {
         if (SpecL == NULL)
           SpecL = _MALLOC (NN * VR_MAX_SPEC_NAME_LEN, IGRchar);
         else
           SpecL = _REALLOC (SpecL, NN * VR_MAX_SPEC_NAME_LEN, IGRchar);

         nSpecl = NN;
       }

       for (i=0; i<NN; i++)
         strcpy (&SpecL[i*VR_MAX_SPEC_NAME_LEN], XX[i].key.hvac_class);

       *listsize = NN;
       *speclist = SpecL;

       _FREE (XX);
   }
   else
   if (application == VR_CABLING)
   {
       struct VRRDB_spec  *XX;

       VR$RDB_SPEC (p_msg = msg,
                    p_num = &NN);

       if ((*msg != MSSUCC) || (NN == 0)) return (OM_E_ABORT);

       XX = _MALLOC (NN, struct VRRDB_spec);

       VR$RDB_SPEC (p_msg = msg,
                    p_num = &NN,
                    p_rec = XX);

       if (NN != nSpecl)
       {
         if (SpecL == NULL)
           SpecL = _MALLOC (NN * VR_MAX_SPEC_NAME_LEN, IGRchar);
         else
           SpecL = _REALLOC (SpecL, NN * VR_MAX_SPEC_NAME_LEN, IGRchar);

         nSpecl = NN;
       }

       for (i=0; i<NN; i++)
         strcpy (&SpecL[i*VR_MAX_SPEC_NAME_LEN], XX[i].key.vendor_code);

       *listsize = NN;
       *speclist = SpecL;

       _FREE (XX);
   }
   else
       return (OM_E_INVARG);

   *msg = ACC_S_SUCCESS;
   return OM_S_SUCCESS;
}



IGRint VRget_param_list (
     IGRlong    *msg,        /* Message                            (O)*/
     IGRchar    *family_name,/* Macro family_name                  (I)*/
     IGRshort   *listsize,   /* Number of elements in list         (O)*/
     IGRchar    **paramlist,  /* List of parameters                (O)*/
     IGRchar    *err_ptr)    /* Error buffer                       (O)*/
{
  /********************************************************************/
  /*                                                                  */
  /* This routine gets the list of parameters for a macro             */
  /*                                                                  */
  /********************************************************************/

  IGRint         status;
  IGRchar      **DbIO;
  IGRint         NbRow;
  IGRint         i;
  IGRchar       *ep;

  ep = err_ptr;

  /* Initialze */

  *listsize = 0;
  status    = OM_S_SUCCESS;

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

  if ( strcmp (family_name, CUR_parname) != NULL )
  {

    status =
    vdb$RisSelect (select     = "param_name",
                   table_name = VRDB_VDSDYNPARAMS_TBL,
                   numselect  = 1,
                   p_numrows  = &NbRow,
                   p_buffer   = &DbIO);

    if (!(status & OM_S_SUCCESS)) goto wrapup;

    status = OM_E_NODYNMEM;

    if (nCUR_parcnt != NbRow)
    {
      nCUR_parcnt = 0;

      if (CUR_parlst == NULL)
        CUR_parlst = _MALLOC (NbRow * VR_PARAM_CHAR, IGRchar);
      else
        CUR_parlst = _REALLOC (CUR_parlst, NbRow * VR_PARAM_CHAR, IGRchar);

      if (CUR_parlst == NULL) goto wrapup;

      nCUR_parcnt = NbRow;
      status = OM_S_SUCCESS;
    }

    for (i=0; i< NbRow; i++)
    {
      VRDBstr (&CUR_parlst[i * VR_PARAM_CHAR], DbIO[i]);
      if (CUR_parlst[i * VR_PARAM_CHAR] == 0)
        strcpy (&CUR_parlst[i * VR_PARAM_CHAR], " ");
    }
  }
  *msg = ACC_S_SUCCESS;

  *listsize  = nCUR_parcnt;
  *paramlist = CUR_parlst;

  wrapup:
  return (status);
}


/*********************************************************************/
/*                                                                   */
/* This routine extracts the codelist set for a list_num             */
/* for different applications.                                       */
/*                                                                   */
/*********************************************************************/       
IGRint VRget_code_list_set ( 
      IGRlong     *msg,        /* Message                           (O) */
      IGRshort    application, /* VDS,Piping,HVAC,Cabling or Struct (I) */
      IGRshort    list_num,    /* Id of codelist set                (I) */
      IGRshort    *listsize,   /* No of elements in codelist set    (O) */
      IGRchar     **codelist,  /* Codelist short texts              (O) */
      IGRshort    **code_num,  /* Codelist code nums                (O) */
      IGRchar     *err_ptr     /* Error message                     (O) */
      )
{
  IGRshort      i;
  IGRshort      NN;
  IGRchar      *ep;

  SetProc(VRget_code_list_set); Begin 

  ep = err_ptr;

  __DBGpr_int(" Id of codelist set",list_num);

  /* Initialize */

  *listsize = 0;

  if (application == VR_PIPING)
  {
       struct VRPDB_cdl   *XX;

       VR$PDB_CDL  (p_msg = msg,
                    nlist = list_num,
                    p_num = &NN);

       if ((*msg != MSSUCC) || (NN == 0)) 
       {
	 End
	 return (OM_E_ABORT);
       }

       XX = _MALLOC (NN, struct VRPDB_cdl);

       VR$PDB_CDL  (p_msg = msg,
                    nlist = list_num,
                    p_num = &NN,
                    p_rec = XX);

       if (NN > nCodel)
       {
         if (CodeL == NULL)
         {
           CodeL = _MALLOC (NN * VR_SHORT_CODETEXT_SIZE, IGRchar);
           CodeN = _MALLOC (NN , IGRshort);

         }
         else
         {
           CodeL = _REALLOC (CodeL, NN * VR_SHORT_CODETEXT_SIZE, IGRchar);
           CodeN = _REALLOC (CodeN, NN , IGRshort);
         }

         nCodel = NN;
       }

       for (i=0; i<NN; i++)
       {
         strcpy (&CodeL[i*VR_SHORT_CODETEXT_SIZE], XX[i].stxt);
	 __DBGpr_str(" CodeL",&CodeL[i*VR_SHORT_CODETEXT_SIZE]);

         CodeN[i] = XX[i].ncode;
	 __DBGpr_int(" CodeN",CodeN[i]);
       }

       *listsize = NN;
       __DBGpr_int(" listsize",*listsize);

       *codelist = CodeL;
       *code_num = CodeN;

       for( i=0 ; i < *listsize ; i=i+1)
       {
	 __DBGpr_str(" codelist",(*codelist+(VR_SHORT_CODETEXT_SIZE*i)) );
	 __DBGpr_int(" code_num",*(*code_num+i));
       }

       _FREE (XX);
  }
  else
  if (application == VR_HVAC)
  {
       struct VRHDB_cdl   *XX;

       VR$HDB_CDL  (p_msg = msg,
                    nlist = list_num,
                    p_num = &NN);

       if ((*msg != MSSUCC) || (NN == 0)) 
       {
	 End
	 return (OM_E_ABORT);
       }

       XX = _MALLOC (NN, struct VRHDB_cdl);

       VR$HDB_CDL  (p_msg = msg,
                    nlist = list_num,
                    p_num = &NN,
                    p_rec = XX);

       if (NN > nCodel)
       {
         if (CodeL == NULL)
         {
           CodeL = _MALLOC (NN * VR_SHORT_CODETEXT_SIZE, IGRchar);
           CodeN = _MALLOC (NN , IGRshort);

         }
         else
         {
           CodeL = _REALLOC (CodeL, NN * VR_SHORT_CODETEXT_SIZE, IGRchar);
           CodeN = _REALLOC (CodeN, NN , IGRshort);
         }

         nCodel = NN;
       }

       for (i=0; i<NN; i++)
       {
         strcpy (&CodeL[i*VR_SHORT_CODETEXT_SIZE], XX[i].stxt);
         CodeN[i] = XX[i].ncode;
       }

       *listsize = NN;
       *codelist = CodeL;
       *code_num = CodeN;

       _FREE (XX);
  }
  else
  if (application == VR_CABLING)
  {
       struct VRRDB_cdl   *XX;

       VR$RDB_CDL  (p_msg = msg,
                    nlist = list_num,
                    p_num = &NN);

       if ((*msg != MSSUCC) || (NN == 0)) 
       {
	 End
	 return (OM_E_ABORT);
       }

       XX = _MALLOC (NN, struct VRRDB_cdl);

       VR$RDB_CDL  (p_msg = msg,
                    nlist = list_num,
                    p_num = &NN,
                    p_rec = XX);

       if (NN > nCodel)
       {
         if (CodeL == NULL)
         {
           CodeL = _MALLOC (NN * VR_SHORT_CODETEXT_SIZE, IGRchar);
           CodeN = _MALLOC (NN , IGRshort);

         }
         else
         {
           CodeL = _REALLOC (CodeL, NN * VR_SHORT_CODETEXT_SIZE, IGRchar);
           CodeN = _REALLOC (CodeN, NN , IGRshort);
         }

         nCodel = NN;
       }

       for (i=0; i<NN; i++)
       {
         strcpy (&CodeL[i*VR_SHORT_CODETEXT_SIZE], XX[i].stxt);
         CodeN[i] = XX[i].ncode;
       }

       *listsize = NN;
       *codelist = CodeL;
       *code_num = CodeN;

       _FREE (XX);
  }
  else
  {
       End
       return (OM_E_INVARG);
  }

  *msg = ACC_S_SUCCESS;
  End
  return OM_S_SUCCESS;
}

int process_npd (double  size_g,
                 char   *npd_str)
{
  char  str1[10];
  char  tmp1[10], tmp2[10];
  int   i;

  sprintf( str1,"%f", size_g);

  i = 0;
  tmp1[0]= 0;
  tmp2[0]= 0;
  while( str1[i] != '.')  i++;

  strncpy(tmp1,str1,i);
  tmp1[i]=0;

  strncpy(tmp2, &str1[i+1],5);
  tmp2[5] = 0;

  if( !VRDBint(tmp1) && VRDBint(tmp2))   /*  IF LESS THAN 1.0  */
  {
    strcpy(npd_str,".");
    if(!strncmp(&tmp2[4],"0",1))
    {
      tmp2[4] = 0;  
      if(!strncmp(&tmp2[3],"0",1))
      {
        tmp2[3] = 0;

        if(!strncmp(&tmp2[2],"0",1))
        {
          tmp2[2] = 0;
          if(!strncmp(&tmp2[1],"0",1))
          {
            tmp2[1] = 0;
          }
        }
      }

      strcat(npd_str,tmp2);
    }
    else
      strcat(npd_str,tmp2);
  }

  else 
  if( VRDBint(tmp1) && !VRDBint(tmp2))
  {
    strcpy(npd_str,tmp1);
  }
  else
    strcpy(npd_str,tmp1);         

  strcat(npd_str,".");

  if(!strncmp(&tmp2[4],"0",1))
  {
    tmp2[4] = 0;  
    if(!strncmp(&tmp2[3],"0",1))
    {
      tmp2[3] = 0;

      if(!(strncmp(&tmp2[2],"0",1)))
      {
        tmp2[2] = 0;
        if(!strncmp(&tmp2[1],"0",1))
        {
          tmp2[1] = 0;
        }
      }

      strcat(npd_str,tmp2);
    }
    else
    {
      strcat(npd_str,tmp2);
    }
  }

  return (1);
}

/************************************************************************
 *                                                                      *
 * This routine extracts parameters from the reference database and     *
 * constructs a parameter box which is then returned to the caller.     *
 *                                                                      *
 * For application VR_RWAY :                                          	*
 *                                                                      *
 *   This routine extracts parameters associated with the Raceway       *
 *   nozzle.                                                            *
 *									*
 *  IGRlong     *mesg       	message                        	(O) 	*
 *  IGRchar	*vendor_name 	Vendor Name			(I)	*
 *  IGRint   	nShape        	Shape of Nozzle 		(I)	*
 *  IGRdouble	dWidth		Width of Nozzle     		(I)	*
 *  IGRdouble	dDepth		Depth of Nozzle     		(I)	*
 *  struct GRid *PbId;        	Parameter box id(I=osnum)       (O) 	*
 *                                                                      *
 ************************************************************************/

#include <math.h>
#include "bsparameters.h"

IGRint VRaccess_rway_noz_db (	IGRlong 	*mesg, 
				IGRchar 	*vendor_name,
				IGRint  	nShape, 
				IGRdouble 	dWidth,
				IGRdouble 	dDepth,
				struct GRid	*PbId ) 
{
   IGRint        	i, pm_no, rows, currcol;
   IGRint        nRcol;
   IGRint        nLocal;
   IGRshort		vendor_no;
   IGRlong       	status;
   IGRdouble     dLocal;

   IGRchar		**DbIO=NULL;
   IGRchar		table[50];
   IGRchar		search[MAX_WHERE_SIZE], szSelect[400];
   struct VRriscol   *RSC=NULL;
   struct VRriscol   *RSM=NULL;

   struct ACrg_coll   	mac_pm[MAX_MACRO_PARAMS];
   struct VRRDB_rwaynozz	*RwNozzle=NULL;

   SetProc( Fn VRaccess_rway_noz_db ); Begin 

   *mesg = ACC_S_SUCCESS;

   vendor_no = -1;

   // Get the Vendor Number from the Name
   status = VR$RDB_SNUM(	p_nam = vendor_name,
			  	p_num = &vendor_no );

   pm_no     = 0;

   status = VRenq_proj_units();

   strcpy( table, VRDB_RWNOZZLE_TBL );

   __DBGpr_str(" table ",table);

   status = VRdbRisCol (mesg, table, &nRcol, &RSC);
   __DBGpr_int(" nRcol",nRcol);

   if (!(status & OM_S_SUCCESS) || (nRcol == 0))
   {
     __DBGpr_com(" VRdbRisCol failed ");
     End
     return (OM_E_ABORT);
   }

   RSM = _MALLOC (nRcol, struct VRriscol);
   __CheckPtr( RSM, "Memory Allocation Error", wrapup );

   for (i=0; i< nRcol; i++)
     RSM[i] = RSC[i];

   /*    construct the select statement    */
   strcpy (szSelect, RSM[0].colname);

   for (i=1; i< nRcol; i++)
   {
     strcat (szSelect,",");
     strcat (szSelect, RSM[i].colname);
   }
   __DBGpr_str(" szSelect",szSelect);

   if( nShape == VR_CIRC ) dDepth = 0.0; // If Circular DB entry would be 0.0

   // Build the WHERE clause
   sprintf( search, "vendor_no=%d AND shape=%d AND width=%g AND depth=%g",
		       vendor_no, nShape, dWidth, dDepth );
   __DBGpr_str( " Search string ", search);

   status =
   vdb$RisSelect (select     = szSelect,
		  table_name = table,
		  where      = search,
		  numselect  = nRcol,
		  p_numrows  = &rows,
		  p_buffer   = &DbIO);

   __DBGpr_int(" rows",rows);

   if (!(status & OM_S_SUCCESS) || (rows == 0)) goto wrapup;

   for (currcol = 0; currcol < nRcol; currcol++)
   {
      VRDBstr(mac_pm[pm_no].name, RSC[currcol].colname);

      if(RSC[currcol].coltype == VR_RISDB_TEXT)
      {
         VRDBstr(mac_pm[pm_no].desc.value.att_txt, DbIO[currcol]);
         mac_pm[pm_no].desc.type = RSC[currcol].partype;
         __DBGpr_str(" Attribute text",mac_pm[pm_no].desc.value.att_txt);
         pm_no += 1;
      }
      else
      if (RSC[currcol].coltype == VR_RISDB_INT)
      {
         nLocal = VRDBint (DbIO[currcol]);

         __DBGpr_int( " Unit Sets value from DB", nLocal );

	 /****
         if(units_set != VRGL_PROJ.prj_units )
         {
           if( !strcmp(mac_pm[pm_no].name, "units_set" ) )
               mac_pm[pm_no].desc.value.att_exp = (double)VRGL_PROJ.prj_units;

         }
         else
	 ****/
	 mac_pm[pm_no].desc.value.att_exp = (double) nLocal;

         mac_pm[pm_no].desc.type = RSC[currcol].partype;
         __DBGpr_int(" Attribute integer",mac_pm[pm_no].desc.value.att_exp);
         pm_no += 1;
      }
      else
      if (RSC[currcol].coltype == VR_RISDB_DOUBLE)
      {
         dLocal = VRDBdbl (DbIO[currcol]);

	 /****
         if(units_set != VRGL_PROJ.prj_units )
         {
           mac_pm[pm_no].desc.value.att_exp =
                 converted_to_vds (mac_pm[pm_no].name,
                                  units_set,VRGL_PROJ.prj_units,
                                  dLocal, err_msg);
         }
         else
	 ****/
         mac_pm[pm_no].desc.value.att_exp = dLocal;

         mac_pm[pm_no].desc.type = RSC[currcol].partype;
         __DBGpr_dbl(" Attribute double",mac_pm[pm_no].desc.value.att_exp);
         pm_no += 1;
      }
   }

#ifdef vdsDEBUG
     printf("  Creating parameter box\n  Collection Data - %d items\n", pm_no);
     for(i=0;i<pm_no;i++)
     {
       printf("  mac_pm[%d].name: %s\n",i,mac_pm[i].name);
       printf("  mac_pm[%d].desc.type: %d\n",i,mac_pm[i].desc.type);
       if(mac_pm[i].desc.type == 1)
       {
         printf("  mac_pm[%d].desc.value: %s\n",i,mac_pm[i].desc.value.att_txt);
       }
       else
         printf(" mac_pm[%d].desc.value: %lf\n",i,mac_pm[i].desc.value.att_exp);
     }
#endif

     /* Create the parameter box */

     status = om$construct( classid = OPP_ACrg_collect_class_id,
                           osnum = PbId->osnum,
                           p_objid = &(PbId->objid),
                           msg = message ACrg_collect.ACcreate (mesg,""));
     as$status();

     __DBGpr_obj(" parameter box id", *PbId);

     status = om$send( msg = message ACrg_collect.ACset_list_attribute
                     (mesg,pm_no,mac_pm),
                     senderid = PbId->objid,
                     targetid = PbId->objid,
                     targetos = PbId->osnum );
     as$status();

  *mesg = ACC_S_SUCCESS;

  wrapup:
  __DBGpr_com(" calling VdsRisFreeBuffer");
  VdsRisFreeBuffer (DbIO, rows);
  _FREE (RSM);


  End
  return OM_S_SUCCESS;
}    

end implementation Root;
