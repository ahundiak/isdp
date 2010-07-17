/* $Id: VRNozfldlst.I,v 1.3 2002/04/10 19:55:06 louis Exp $  */ 
/*************************************************************************
 * I/ROUTE
 *
 * File:	vrpdu / VRNozfldlst.I
 *
 * Description:
 *   The functions are used 
 *    - to update the Nominal Size, End Condition,Press Class and End Standard.
 *
 * Dependencies:
 *  
 *
 * Revision History:
 *	$Log: VRNozfldlst.I,v $
 *	Revision 1.3  2002/04/10 19:55:06  louis
 *	TR5649-standardize tolerances
 *	
 *	Revision 1.2  2001/02/20 01:14:49  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.1.1.1  2001/01/04 21:13:01  cvs
 *	Initial import to CVS
 *	
# Revision 1.3  1999/05/05  12:57:56  pinnacle
# Replaced: vrpdu/VRNozfldlst.I for:  by sbilla for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.5  1998/04/06  18:07:46  pinnacle
# Replaced: vrpdu/VRNozfldlst.I for:  by lawaddel for route
#
# Revision 1.4  1998/04/01  18:44:46  pinnacle
# Replaced: vrpdu/VRNozfldlst.I for:  by lawaddel for route
#
# Revision 1.3  1997/12/16  15:29:30  pinnacle
# Replaced: vrpdu/VRNozfldlst.I for: Regression in 02.04.03.05 by aharihar for route
#
# Revision 1.2  1997/08/15  19:34:34  pinnacle
# Replaced: vrpdu for:  by hverstee for route
#
# Revision 1.7  1997/05/05  14:53:00  pinnacle
# Replaced: vrpdu/VRNozfldlst.I for:  by yzhu for route
#
# Revision 1.6  1997/05/02  13:41:40  pinnacle
# Replaced: vrpdu/VRNozfldlst.I for:  by yzhu for route
#
# Revision 1.5  1997/05/01  14:09:02  pinnacle
# Replaced: vrpdu/VRNozfldlst.I for:  by yzhu for route
#
# Revision 1.4  1997/04/18  16:09:54  pinnacle
# Replaced: vrpdu/VRNozfldlst.I for:  by yzhu for route
#
# Revision 1.3  1997/03/19  22:09:32  pinnacle
# Replaced: vrpdu/VRNozfldlst.I for:  by yzhu for route
#
 *
 * History:
 *	02/05/97   yzhu		Create 
 *	12/16/97   Anand	Resolved some problems in
 *				VRupdate_field_list_set (regression in
 *				02.04.03.05 - problem in placing nozzle when
 *				in nozzle1. lists not getting updated properly.
 *      04/01/98   law          VRget_field_list_set needs fixed length buffer
 *      05/04/99    Reddy       Doble value comparision corrected
 *      04/05/02    law         TR5649-standardize tolerance with VRGetTol
 *                              Also deleted 3 'j' donothing loops 
 *************************************************************************/

class implementation Root;

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "OMminimum.h"
#include "OMmacros.h"
#include "OMerrordef.h"

#include "igetypedef.h"
#include "igrtypedef.h"
#include "AS_status.h"
#include "gr.h"
#include "ms.h"
#include "msdef.h"
#include "msmacros.h"
#include "VRdef.h"
#include "dberror.h"

#include "VDDbDef.h"
#include "VRMath.h"
#include "VRDbCache.h"
#include "VRDbStruct.h"
#include "VRmsg.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "VRDbTbl.h"
#include "VRPDBdef.h"
#include "VRPDBmac.h"
#include "vrdbgmacros.h"

/**************************************************************/
/*             GLOBALS                                        */

extern
struct VRPDB_project   VRGL_PROJ;
extern
IGRint                 VRGL_specunit;

/**************************************************************/
/*            NEW DYNAMIC STATICS                             */

%safe
static
IGRshort             nNPD = 0;

static
struct VRPDB_npd    *pNPD = NULL;

/*        TBD ******************************
static
IGRdouble           *pNPDCUR = NULL;
static
IGRdouble           *pNPDNUL = NULL;
*********************************************/

%endsafe
/**************************************************************/

static
int    prj_units_used;

/**************************************************************/
/* these static externals to be initialized at DB change      */
/* get npd list_from_nozzel1			              */
static  double    npdlst0[VR_MAX_NPDLIST_SIZE];
static  double    npdlst_cur[VR_MAX_NPDLIST_SIZE];
static  short     old_npdlstsize0;
static  short     old_npdlstsize_cur;

/**************************************************************/
/* these static externals to be initialized at DB change      */
/* VRget_field_list_set 				      */
static struct VRfieldlist  temp_fieldlist;
static struct VRfieldlist  cache_fieldlist[VR_MAX_FIELDLIST_CACHE];
static struct VRfieldlist  cache_fieldlist_cur[VR_MAX_FIELDLIST_CACHE];
static int    curr_cache_size0;
static int    curr_cache_size1;
static int    SLOT;

/**************************************************************/
/* these static externals to be initialized at DB change      */
/* VRget_macro_list_set                                       */
static struct VRmacrolist  cache_macrolist;
static struct VRmacrolist  cache_macrolist_cur;

/* ---------------------------------------------------------------------------
  Functions: strcmpnoza,  strcmpnozd

  Abstract
     those functions are used to sort table according attributes.

     strcmpnoza : string comparison on ascending
     strcmpnozd : string comparison on descending


  Arguments
     struct VRfieldlist       *elm1          I/O     element list
     struct VRfieldlist       *elm2          I/O     element list


  Example:

  Status/Return Code
     status == -1 , reference strings unequal
                    or second string is NULL_VAL_STR
     status == 1  , first string is NULL_VAL_STR
     status == else , return normal
----------------------------------------------------------------------------*/
struct VRsortstrlist
{
   char           field[VR_SHORT_FIELDTEXT_SIZE];
};


int strcmpnoza( struct VRsortstrlist *elm1,
                struct VRsortstrlist *elm2 )
{

     if( !strcmp( elm1->field, elm1->field ))
     {
          return(-1);
     }
     else 
          return( strcmp( elm1->field, elm2->field ) );
}

int strcmpnozb( struct VRsortstrlist *elm1,
                struct VRsortstrlist *elm2 )
{

     if( !strcmp( elm1->field, elm1->field ))
     {
          return(-1);
     }
     else 
          return( strcmp( elm2->field, elm1->field ) );
}


/**************************************************************/
/*    clear cache function                                    */

void VR_DbC_Clnfl ()
{
  int      i;
  
  /* for field list */ 
  curr_cache_size0 = 0;
  curr_cache_size1 = 0;
  SLOT            = -1;

  for (i=0; i<VR_MAX_FIELDLIST_CACHE; i++)
  {
    cache_fieldlist[i].application = 0;
    cache_fieldlist[i].field_name[0] = '\0';
    cache_fieldlist[i].count       = 0;
    cache_fieldlist_cur[i].application = 0;
    cache_fieldlist_cur[i].field_name[0] = '\0';
    cache_fieldlist_cur[i].count       = 0;
  }

  /* for macro list */
    cache_macrolist.application = 0;
    cache_macrolist.field_name[0] = '\0';
    cache_macrolist.count       = 0;
    cache_macrolist_cur.application = 0;
    cache_macrolist_cur.field_name[0] = '\0';
    cache_macrolist_cur.count       = 0;

  /* for npt list */ 
  for (i=0; i<VR_MAX_NPDLIST_SIZE; i++)
  {
    npdlst0[i]      = 0.0;
    npdlst_cur[i]      = 0.0;
  }

  old_npdlstsize0 = 0;
  old_npdlstsize_cur = 0;


/********************************/
  nNPD = 0;
  pNPD = NULL;      /*  DO NOT FREE, direct cache pointer     */

  return;
}


/*********************************************************************
 * Function: VRNozzle_table_check                                    * 
 *                                                                   *
 * This routine checks if the table nozzle1 is used and set gloable  *
 * value VRTABLENOZZLE1      					     *
 * return code:						             *	
 *   if the Table nozzle1 exists,				     * 
 *		vr_table_nozzle1 = 1;                                *
 *		msg = ACC_S_SUCCESS;                                 *
 * 		return OM_S_SUCCESS;                                 *
 *   else                                                            *
 *		vr_table_nozzle1 = 0;                                *
 *		msg = VR_E_RisInitFailed or VR_E_DbShortErrMsg       * 
 * 		return OM_E_ABORT;                                   *
 *********************************************************************/
IGRint VRNozzle_table_check(
    IGRlong     *msg,       	      /* message                (O) */
    IGRint      *vr_table_nozzle1,    /* useing table nozzle1   (O) */
    IGRchar     *err_msg)             /* Error buffer         (O/I) */
{

  /* init vr_table_nozzle1 */
  *vr_table_nozzle1 = 0;

  /* check if the data base is connnected */
  if(VdsRisAttach() != OM_S_SUCCESS)
  {
       if(err_msg != NULL)
       {
         ex$message(msgnumb = VR_E_RisInitFailed,
                    buff   = err_msg);
       }
       *msg = VR_E_RisInitFailed;
       return(OM_E_ABORT);
  }

  /* check if table nozzle exists */

  if (VdsVerifyRisTable (VRDB_PIPNOZZLE1) != VDS_DBTABLE_FOUND)

  {
        *msg = VR_E_DbShortErrMsg;
        return(OM_E_ABORT);
  }

  *vr_table_nozzle1 = 1;
  *msg = ACC_S_SUCCESS;

  return OM_S_SUCCESS;
}


/*********************************************************************
 * Function: VRget_npd_list_from_nozzle1                             *
 *                                                                   *
 * This routine get initial lists of nozzle1 parameters:	     *
 *    Nominal size						     *
 * 								     *	
 * return code:                                                      *
 *              msg = ACC_S_SUCCESS;                                 *
 *              return OM_S_SUCCESS;                                 *
 *   else                                                            *
 *              vr_table_nozzle1 = 0;                                *
 *              msg = VR_E_RisInitFailed or VR_E_DbShortErrMsg       *
 *              return OM_E_ABORT;                                   *
 *********************************************************************/
IGRint VRget_npd_list_from_nozzle1( 
      IGRlong     *msg,        /* Message                           (O) */
      IGRshort    application, /* Piping only                       (I) */
      IGRchar     *fieldname,  /* field name                        (I) */
      IGRshort    *listsize,   /* No of elements in npd list        (O) */
      IGRdouble   **npdlist,   /* List of allowable npds            (O) */
      IGRchar     *err_msg     /* Error buffer                      (O) */
      )
{

  int           sts, i,ii;
  struct VRrisdat      outdata[VR_MAX_NPDLIST_SIZE];
  int           rows;
  int           cols;
  int           par_cnt;
  char          *table=NULL;            /* table name */
  char          *select=NULL;           /* select list */
  char          search[MAX_WHERE_SIZE];         /* where clause of a select */
  char          ris_str[MAX_RIS_STR_SIZE];
  double 	size;

  SetProc(VRget_npd_list_from_nozzle1); Begin
  /* Initialize */
  *listsize = 0;

  if(VdsRisAttach() != OM_S_SUCCESS)
  {
     VRdb_err_msg(VR_E_RisInitFailed, err_msg,NULL,NULL,NULL);
     *msg = VR_E_RisInitFailed;
     return(OM_E_ABORT);

  }

  if ( application != VR_PIPING || 
       strcmp( fieldname, "NOZZLE1" ) )
  {
     VRdb_err_msg(VR_E_RisInitFailed, err_msg,NULL,NULL,NULL);
     *msg = VR_E_RisInitFailed;
     return(OM_E_ABORT);
  }

  if (VRenq_proj_units() < 0) return (OM_E_ABORT);

  /* get real used units set number: 1 ---> english 20 --- metric */ 
   if( VRGL_PROJ.npd_eqflag == 1 )
   {
        if ( VRGL_PROJ.prj_units == 1)
             prj_units_used = 20;
        else
             prj_units_used = 1;
   }
   else 
             prj_units_used = VRGL_PROJ.prj_units;

  /* get npd allowed list */
  VR$PDA_NPDB (p_num = &nNPD,
               p_ptr = &pNPD);

  if (nNPD == 0) return(OM_E_ABORT);

  /* check if cache exists for npdlst1 */ 
  if( old_npdlstsize0)
  {
      *npdlist = npdlst0;
      *listsize = old_npdlstsize0;
  }
  else
  {
    ii = 0;
    /* get equivelent value */ 
    for( i = 0; i < nNPD; i++ )
    { 
      if( VRGL_PROJ.npd_eqflag == 1 )
        size = pNPD[i].npd_eq;
      else
        size = pNPD[i].npd;

      /* Access the nozzle1 table */
      table = VRDB_PIPNOZZLE1;
      select = "distinct nominal_size";
      sprintf( search, "WHERE nominal_size = %f and units_set = %d", 
		size, prj_units_used);

      sprintf( ris_str,"SELECT %s FROM %s %s", select, table, search );
      sts = RISexecute_query( ris_str, outdata, &rows, &cols, &par_cnt);
      if (sts == 1 && rows != 0)
      {
        npdlst0[ii] = pNPD[i].npd;
        ii = ii + 1;
      } 
    } /* for */

    *npdlist = npdlst0;
    if ( ii <= VR_MAX_NPDLIST_SIZE )
    {
    	old_npdlstsize0 = (short) ii;
    	*listsize = old_npdlstsize0;
    }
    else
    {
         printf(" VRget_npd_lst_from_nozzle1: Cache Overflow \n");
         *listsize = VR_MAX_NPDLIST_SIZE;
         old_npdlstsize0 = *listsize;
    }
  } /*else */

  /* make a current array */
  old_npdlstsize_cur = old_npdlstsize0;
  for( i = 0; i < old_npdlstsize0; i++ )
  {
  	 npdlst_cur[i] = npdlst0[i];
  }  
  
  *msg = ACC_S_SUCCESS;
  End
  return OM_S_SUCCESS;
}
/*********************************************************************
 * Function: VRget_macro_list_set                                    *
 *                                                                   *
 * This routine get initial lists of nozzle1 parameters:             *
 *    macro_name       						     *
 *                                                                   *
 * return code:                                                      *
 *              msg = ACC_S_SUCCESS;                                 *
 *              return OM_S_SUCCESS;                                 *
 *   else                                                            *
 *              msg = VR_E_RisInitFailed or VR_E_DbShortErrMsg       *
 *              return OM_E_ABORT;                                   *
 *********************************************************************/
IGRint VRget_macro_list_set (
      IGRlong     *msg,        /* Message                           (O) */
      IGRshort    application, /* VDS,Piping,HVAC,Cabling or Struct (I) */
      IGRchar     *field_name, /* name  of fieldlist set            (I) */
      IGRshort    *listsize,   /* No of elements in list set        (O) */
      IGRchar     **macrolist, /* fieldlist  short texts            (O) */
      IGRchar     *err_ptr     /* Error message                     (O) */
      )
{
  int           sts, i, j , ii;
  struct VRrisdat      outdata[900];
  int           rows;
  int           cols;
  int           par_cnt;
  char          *table=NULL;            /* table name */
  char          select[MAX_WHERE_SIZE]; /* select list */
  char          search[MAX_WHERE_SIZE];         /* where clause of a select */
  char          order[50];          /* order clause of a select */
  char          ris_str[MAX_RIS_STR_SIZE];

  int           in_cache=0;
  int           slot;
  char          disp_err[100];

  SetProc(VRget_macro_list_set); Begin

  /* Initialize */

  slot      = -1;
  *listsize = 0;

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

  /* IF IN CACHE  */
  if(cache_macrolist.application == application &&
           strcmp(cache_macrolist.field_name, field_name) == 0)
       {
           in_cache = 1;
           /*         garbage variable ????       */
           /*         slot = i;                   */    slot = 0;
       }
  if(in_cache)
  {
     *macrolist = (char *)(cache_macrolist.field);
     *listsize = cache_macrolist.count;
  }
  else
  {
     /* Access the nozzle1 table */

        table = VRDB_PIPNOZZLE1;
        sprintf( select, " distinct %s", field_name);
        sprintf(order,"ORDER by %s", field_name );
        sprintf( search, "WHERE  units_set = %d", prj_units_used);

        sprintf( ris_str,"SELECT %s FROM %s %s %s ", select,table,search,order);

        sts = RISexecute_query( ris_str, outdata, &rows, &cols, &par_cnt);
        if (sts != 1 || rows == 0)
        {
           printf("Failed accessing %s for fieldlist set.\n", table);
           printf("SELECT <%s>\nFROM <%s>\n%s\n ", select, table, search);
           sprintf(disp_err, "field_name %s", field_name);
           if(err_ptr != NULL)
           {
             ex$message ( msgnumb = VR_E_DbLongErrMsg,
                          type    = "%s%s%s",
                          var     = `table,"Row",disp_err`,
                          buff    = err_ptr);
           }
           *msg = VR_E_DbShortErrMsg;
           return(OM_E_ABORT);
         }


      /* CACHE EXTRACTED ROW */
      ii = 0;
      cache_macrolist.application = application;
      strcpy(cache_macrolist.field_name, field_name);


      for(i = 0; i < rows && i < VR_MAX_FIELDLIST_SIZE; i++)
      {
           if(outdata[i].data.val.attr_c[0] != 0) {
                    /* if || in database, skip it */
                strncpy(cache_macrolist.field[ii],
                                        outdata[i].data.val.attr_c,20 );
                ii = ii + 1;
         }
      } /* for */
      *macrolist = (char *)(cache_macrolist.field) ;
      if( ii <= VR_MAX_FIELDLIST_SIZE )
           {
             cache_macrolist.count = (short) ii;
             *listsize =  cache_macrolist.count;
           }
      else
           {
             printf("VRget_code_list_set: Cache overflow\n");
             *listsize = VR_MAX_FIELDLIST_SIZE;
             cache_macrolist.count = VR_MAX_FIELDLIST_SIZE;
           }
        /* make a current array */
  	cache_macrolist_cur.application = cache_macrolist.application;
  	strcpy(cache_macrolist_cur.field_name,
                                cache_macrolist.field_name);
  	cache_macrolist_cur.count = cache_macrolist.count;

  	for( j = 0; j < cache_macrolist.count; j++) {
         	strcpy( cache_macrolist_cur.field[j],
                                cache_macrolist.field[j]);
  	}
  }

  *msg = ACC_S_SUCCESS;
  End
  return OM_S_SUCCESS;
}

/*********************************************************************
 * Function: VRget_field_list_set                                    *
 *                                                                   *
 * This routine get initial lists of nozzle1 parameters:             *
 *    end_condition, pressure class, end_standard        	     *
 * return code:                                                      *
 *              msg = ACC_S_SUCCESS;                                 *
 *              return OM_S_SUCCESS;                                 *
 *   else                                                            *
 *              msg = VR_E_RisInitFailed or VR_E_DbShortErrMsg       *
 *              return OM_E_ABORT;                                   *
 *********************************************************************/
IGRint VRget_field_list_set (
      IGRlong     *msg,        /* Message                           (O) */
      IGRshort    application, /* VDS,Piping,HVAC,Cabling or Struct (I) */
      IGRchar     *field_name, /* name  of fieldlist set            (I) */
      IGRshort    contsize,    /* No of elements in controllist set (I) */
      IGRchar     *contlist,   /* control list                      (I) */
      IGRshort    *listsize,   /* No of elements in list set        (O) */
      IGRchar     **fieldlist, /* fieldlist  short texts            (O) */
      IGRchar     *err_ptr     /* Error message                     (O) */
      )
{
  int           sts, i, j , ii, j0;
  struct VRrisdat      outdata[900];
  int           rows;
  int           cols;
  int           par_cnt;
  char          *table=NULL;            /* table name */
  char          select[MAX_WHERE_SIZE];           /* select list */
  char          search[MAX_WHERE_SIZE];         /* where clause of a select */
  char          order[50];          /* order clause of a select */
  char          ris_str[MAX_RIS_STR_SIZE];
  int           in_cache=0;
  int           slot,j1, proj_no, i1;
  double	size;
  struct VRsortstrlist tempstr[VR_MAX_FIELDLIST_SIZE];
 

  SetProc(VRget_field_list_set); Begin

  /* Initialize */
  slot      = -1;
  *listsize = 0;

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

  /* Get project no */
  sts = VdsGetPrjNo( &proj_no);
  if(!sts)
  {
     *msg = VR_E_DbShortErrMsg;
     return(OM_E_ABORT);
  }


  for(i=0; i < curr_cache_size0; i++ )
  {
       if(cache_fieldlist[i].application == application &&
           strcmp(cache_fieldlist[i].field_name, field_name) == 0)
       {
           in_cache = 1;
           slot = i;
           break;
       }
  }
  if( contsize == 0 && contlist == NULL && !in_cache) {
       printf(" No lists are store in the cache\n"); 
       *msg = VR_E_DbShortErrMsg;
       return(OM_E_ABORT);
  }
  if(in_cache)
  { 
     *fieldlist = (char *)(cache_fieldlist[slot].field);
     *listsize = cache_fieldlist[slot].count;
  }
  else
  {
    /* get list their norminal_sizes are in npdlst0 */
    ii = 0;
    for( j0 = 0; j0 < old_npdlstsize0; j0++ ) {
      size = npdlst0[j0];

      
      if(VRGL_PROJ.npd_eqflag == 1 ) {
        /* get equivelent value */
        for( i = 0; i < nNPD; i++ )
        {
	   /*BILLA  Double value comparison problem */
           if( fabs(npdlst0[j0] - pNPD[i].npd) < VRGetTol(VR_DIST_TOL)  )
           {
              size = pNPD[i].npd_eq;
              break;
           }
        }
      } /* if(VRGL_PROJ.npd_eqflag == 1 ) */

      /* Access the nozzle1 table */

      table = VRDB_PIPNOZZLE1;
      sprintf( select, " distinct %s", field_name);
      sprintf(order,"ORDER by %s", field_name );

      sprintf( search, "WHERE  nominal_size = %f and units_set = %d", 
			size, prj_units_used);

      sprintf( ris_str,"SELECT %s FROM %s %s %s ", select,table,search,order);
 
      sts = RISexecute_query( ris_str, outdata, &rows, &cols, &par_cnt);
      if (sts == 1 && rows != 0)
      {
	for(i = 0; i < rows && i < VR_MAX_FIELDLIST_SIZE; i++){
         for(i1=0; i1< ii; i1++) {
            if( !strcmp(temp_fieldlist.field[i1],
                       outdata[i].data.val.attr_c)               
               || ( !strcmp( temp_fieldlist.field[i1], "<blank>") &&
                         outdata[i].data.val.attr_c[0] == 0)
               || ( !strcmp( temp_fieldlist.field[i1], "<blank>") &&
                    !strcmp(outdata[i].data.val.attr_c, " ")))
                 break;
         } 
         if ( i1 == ii) { /* not found before */
          /* compare with control list: first string with 9 char is not used*/

/************ law restructured Mar31-1998 ****************/
        j1 = 0;
        for(j=0;j<contsize*VR_SHORT_CODETEXT_SIZE;j+=VR_SHORT_CODETEXT_SIZE){
           if (j1 == (contsize - 1))        break;
           if(contlist[j]) {
                 if(!strcmp( &contlist[j], outdata[i].data.val.attr_c )){
                  if(outdata[i].data.val.attr_c[0] == 0 ) {
                    strcpy(temp_fieldlist.field[ii], "<blank>");
                  }
                  else {
                   /******* law 04/02/98 *********/
                   strncpy(temp_fieldlist.field[ii],
                                        outdata[i].data.val.attr_c,79);

                   temp_fieldlist.field[ii][79] = '\0'; /* law 04/02/98 */
                  }
                  ii = ii + 1;
                  break;
                 }
/*                 else if ( !strcmp(outdata[i].data.val.attr_c, "null") ||
                           !strcmp(outdata[i].data.val.attr_c, "NULL") ||
 */              else if (outdata[i].data.val.attr_c[0] == 0) {	
                    /* if there are | | in database, list it as "<blank>" */
                    strcpy(temp_fieldlist.field[ii],"<blank>");
                    ii = ii + 1;
                    break;
                 }
                 j1++;
              } /* if */
          } /* for(j=0,j1=0;;j++) */
         } /* for i1 == ii */
        } /* for i loop */
      } /* if sts == 1 */
    } /* for j0 loop */

    /*using temp_fieldlist to sort */
    for(j = 0; j < ii; j++){
                strcpy(tempstr[j].field, temp_fieldlist.field[j]);
    }
    qsort( tempstr, ii, sizeof(struct VRsortstrlist),
                      (int (*)())strcmpnoza );


    /* get cache_fieldlist */
    for(j = 0; j < ii; j++){
        if( !strcmp( temp_fieldlist.field[j], tempstr[j].field) )
                strcpy(cache_fieldlist[curr_cache_size0].field[j],
					temp_fieldlist.field[j]);
    }
 
    *fieldlist = (char *)(cache_fieldlist[curr_cache_size0].field) ;
    cache_fieldlist[curr_cache_size0].application = application;
    strcpy(cache_fieldlist[curr_cache_size0].field_name, field_name);
    if( ii <= VR_MAX_FIELDLIST_SIZE )
    {
             cache_fieldlist[curr_cache_size0].count = (short) ii;
             *listsize =  cache_fieldlist[curr_cache_size0].count;
    }
    else
    {
             printf("VRget_code_list_set: Cache overflow\n");
             *listsize = VR_MAX_FIELDLIST_SIZE;
             cache_fieldlist[curr_cache_size0].count = VR_MAX_FIELDLIST_SIZE;
    }
    curr_cache_size0++;
  
    if( !ii ) {
       printf(" No lists found\n");
       *msg = VR_E_DbShortErrMsg;
       return(OM_E_ABORT);
    }

    /* make a current array */
    curr_cache_size1 = curr_cache_size0;
    cache_fieldlist_cur[curr_cache_size1-1].application = 
             cache_fieldlist[curr_cache_size1-1].application;
    strcpy(cache_fieldlist_cur[curr_cache_size1-1].field_name,
	  	cache_fieldlist[curr_cache_size1-1].field_name);
    cache_fieldlist_cur[curr_cache_size1-1].count = 
		cache_fieldlist[curr_cache_size1-1].count;
    for( j = 0; j < cache_fieldlist[curr_cache_size1-1].count; j++) {
	    strcpy( cache_fieldlist_cur[curr_cache_size1-1].field[j], 
		cache_fieldlist[curr_cache_size1-1].field[j]);
   }
  } /* else */
  *msg = ACC_S_SUCCESS;
  End
  return OM_S_SUCCESS;
}
/*********************************************************************
 * Function: VRupdate_field_list_set                                 *
 *                                                                   *
 * This routine update lists of nozzle1 parameters:                  *
 * nominal_size, end_condition, pressure class, end_standard         *
 * return code:                                                      *
 *              msg = ACC_S_SUCCESS;                                 *
 *              return OM_S_SUCCESS;                                 *
 *********************************************************************/

IGRint VRupdate_field_list_set (
      IGRlong     *msg,        /* Message                           (O) */
      IGRshort    application, /* VDS,Piping,HVAC,Cabling or Struct (I) */
      IGRdouble   nominal_size,/* nominal_sizedlist                 (I) */
      IGRchar     *end_condition,/* end_condition                   (I) */
      IGRchar     *pressure_class,/* pressure_class                 (I) */
      IGRchar     *end_standard,/* end_standard                     (I) */
      IGRshort    *size_num,   /* No of elements in sizelist set    (O) */
      IGRdouble   **sizelist,  /* nominal_size list    		    (O) */
      IGRshort    *cond_num,   /* No of elements in condlist set    (O) */
      IGRchar     **condlist,  /* end_condition                     (O) */
      IGRshort    *pres_num,   /* No of elements in preslist set    (O) */
      IGRchar     **preslist,  /* pressure_class      		    (O) */
      IGRshort    *stan_num,   /* No of elements in sizelist set    (O) */
      IGRchar     **stanlist,  /* end_standard list                 (O) */
      IGRchar     *macro_name, /* macro_name                        (O) */
      IGRchar     *err_ptr     /* Error message                     (O) */
      )
{
  int           sts, i, j, ii, i1;
  struct 	VRrisdat      outdata[900];
  int           rows;
  int           cols;
  int           par_cnt;
  char          *table=NULL;            /* table name */
  char          *select=NULL;           /* select list */
  char          order[50];              /* order clause of a select */
  char          tempwhere[MAX_WHERE_SIZE];  /* select clause of a select */
  char          where_string[MAX_WHERE_SIZE];   /* where clause of a select */
  char          ris_str[MAX_RIS_STR_SIZE];
  int           proj_no, in_cache, slot;
  double	size;
  int		first_str=0;
  IGRchar       end_condition1[35];
  IGRchar       pressure_class1[35];
  IGRchar       end_standard1[35];
  
  SetProc(VRupdate_field_list_set); Begin
  /* init */
  __DBGpr_com(" static variables - predefined");
  __DBGpr_int("old_npdlstsize0 ",old_npdlstsize0 );
  __DBGpr_int("old_npdlstsize_cur ",old_npdlstsize_cur );
  __DBGpr_int("curr_cache_size0 ",curr_cache_size0 );
  __DBGpr_int("curr_cache_size1 ",curr_cache_size1 );

  *size_num = 0;
  *cond_num = 0;
  *pres_num = 0;
  *stan_num = 0;
  strcpy( macro_name, "");

  if(VdsRisAttach() != OM_S_SUCCESS)
  {
       if(err_ptr != NULL)
       {
         ex$message(msgnumb = VR_E_RisInitFailed,
                    buff   = err_ptr);
       }
       *msg = VR_E_RisInitFailed;
       End
       return(OM_E_ABORT);
  }

  /* Get project no */
  sts = VdsGetPrjNo( &proj_no);
  if(!sts)
  {
     *msg = VR_E_DbShortErrMsg;
     End
     return(OM_E_ABORT);
  }


  table = VRDB_PIPNOZZLE1;
  where_string[0] = '\0';
  tempwhere[0] = '\0';

  strcat(  where_string, "WHERE ");  

  __DBGpr_dbl(" nominal_size",nominal_size);
  if ( nominal_size != 0 )
  {
      size = nominal_size;
      if(VRGL_PROJ.npd_eqflag == 1 )
      {
        /* get equivelent value */
        for( i = 0; i < nNPD; i++ )
        {
           if(nominal_size == pNPD[i].npd)
           {
              size = pNPD[i].npd_eq;
              break;
           }
        }
      }
      if( !first_str )
      {
         first_str = 1;
         sprintf( tempwhere, " nominal_size = %f", size);
      }
      else 
         sprintf( tempwhere, " and nominal_size = %f ", size);
      strcat(  where_string, tempwhere);

      __DBGpr_str(" where_string is",where_string);

  } /* if nominal_size */
 
  __DBGpr_str(" end_condition",end_condition);

  if ( strcmp( end_condition, "EMPTY" ) != 0)
  {
    if ( strcmp( end_condition, "<blank>" ) == 0)
    { 
      if( !first_str )
      {
         first_str = 1;
         sprintf( tempwhere, "end_condition = ' ' or end_condition is null"); 
      }
      else 
         sprintf(tempwhere," and end_condition = ' ' or end_condition is null"); 
    } 
    else { 
      if( !first_str ) {
         first_str = 1;
         sprintf( tempwhere, "end_condition = '%s'", end_condition);
      }
      else 
         sprintf( tempwhere, " and end_condition = '%s'", end_condition);
    }
    strcat(  where_string, tempwhere);

    __DBGpr_str(" where_string is",where_string);

  } /* if end_condition */

  __DBGpr_str(" pressure_class",pressure_class);

  if ( strcmp( pressure_class, "EMPTY" ) != 0)
  {
    if ( strcmp( pressure_class, "<blank>" ) == 0 )
    {  
      if( !first_str )
      {
         first_str = 1;
         sprintf( tempwhere, " pressure_class = ' ' or pressure_class is null");
      }
      else 
         sprintf( tempwhere, " and pressure_class = ' ' or pressure_class is null");
    }
    else
    {
      if( !first_str )
      {
         first_str = 1;
         sprintf( tempwhere, " pressure_class = '%s'", pressure_class);
      }
      else 
         sprintf( tempwhere, " and pressure_class = '%s'", pressure_class);
    } 
    strcat(  where_string, tempwhere);

    __DBGpr_str(" where_string is",where_string);

  }

  __DBGpr_str(" end_standard",end_standard);

  if ( strcmp( end_standard, "EMPTY" ) != 0)
  {
    if ( strcmp( end_standard, "<blank>" ) == 0 )
    { 
      if( !first_str )
      {
         first_str = 1;
         sprintf( tempwhere, " end_standard = ' ' or end_standard is null");
      }
      else
         sprintf( tempwhere, " and end_standard = ' ' or end_standard is null");
    }
    else {
     if( !first_str ) {
         sprintf( tempwhere, " end_standard = '%s'", end_standard);
     } 
     else 
       sprintf( tempwhere, " and end_standard = '%s'", end_standard);
   }   
   strcat(  where_string, tempwhere);

   __DBGpr_str(" where_string is",where_string);

  }

  /* add units_set select */
  if( !first_str ) {
      first_str = 1;
      sprintf( tempwhere, " units_set = %d", prj_units_used);
  }
  else
      sprintf( tempwhere, " and  units_set = %d", prj_units_used);
  strcat(  where_string, tempwhere);

  /* extract size list */ 
  if ( nominal_size != 0 ) {
       for( i = 0; i < old_npdlstsize_cur; i++ ) {
         npdlst_cur[i] = 0;
       } 
       old_npdlstsize_cur = 1;
       npdlst_cur[0] = nominal_size;
 
       *size_num = old_npdlstsize_cur;
       *sizelist = npdlst_cur;
  }
  else { 
      select = "distinct nominal_size";
      sprintf(order,"ORDER by nominal_size" );
      sprintf( ris_str,"SELECT %s FROM %s %s %s", select, table, 
            where_string, order);
      sts = RISexecute_query( ris_str, outdata, &rows, &cols, &par_cnt);
      if (sts != 1 || rows == 0)
      {
       printf("Failed accessing %s for nominal_size.\n",table);
       printf("SELECT <%s>\nFROM <%s>\n%s\n%s\n ", select, 
		table, where_string,order);
       *msg = VR_E_DbShortErrMsg;
       End
       return (OM_E_ABORT);
      } 
      else {
        ii = 0;
        for(i = 0; i < par_cnt && i < VR_MAX_NPDLIST_SIZE; i++) {
          for( j = 0; j <  old_npdlstsize0; j++) {
           size = npdlst0[j]; 
           if(VRGL_PROJ.npd_eqflag == 1 ) {
            /* get equivelent value */
            for( i1 = 0; i1 < nNPD; i1++ )
            {
              if(npdlst0[j] == pNPD[i1].npd)
              {
                  size = pNPD[i1].npd_eq;
                  break;
              }
            }
           }
           if( fabs(size - outdata[i].data.val.attr_dbl) <
                                                 VRGetTol(VR_DIST_TOL) )
           {
                npdlst_cur[ii] = outdata[i].data.val.attr_dbl;
                ii++;
                break;
           } 
          } /* for j */
        } /* for i */ 
        if( old_npdlstsize_cur > ii )
          for( i = ii; i < old_npdlstsize_cur; i++ ) {
         	npdlst_cur[i] = 0;
          } 
             
	old_npdlstsize_cur = ii;
        *size_num = old_npdlstsize_cur;
        *sizelist = npdlst_cur;
      }
  }

  /* extract end condition list  */
  slot = -1;
  in_cache = 0;
  if ( strcmp( end_condition, "EMPTY" ) != 0) {
     for(i=0; i < curr_cache_size1; i++ )
     {
       if(cache_fieldlist_cur[i].application == application &&
           strcmp(cache_fieldlist_cur[i].field_name, "end_condition") == 0)
       {
           in_cache = 1;
           slot = i;
           break;
       }
     }
     if(in_cache) {
         for( j = 0; j < cache_fieldlist_cur[slot].count; j++) {
                 cache_fieldlist_cur[slot].field[j][0] = '\0';
         }
         cache_fieldlist_cur[slot].count = 1;
         strcpy( cache_fieldlist_cur[slot].field[0], end_condition);
         *cond_num = cache_fieldlist_cur[slot].count;
         *condlist = (char *) (cache_fieldlist_cur[slot].field);
     } 
     else {
          printf(" Can not update %s list \n", end_condition);
          *msg = VR_E_DbShortErrMsg;
	  End
          return (OM_E_ABORT);
     }
  }
  else {   /* extract end condition list  */
      select = "distinct end_condition";
      sprintf(order,"ORDER by end_condition" );
      sprintf( ris_str,"SELECT %s FROM %s %s %s", select, table,
            where_string, order);

      __DBGpr_str(" ris_str",ris_str);

      sts = RISexecute_query( ris_str, outdata, &rows, &cols, &par_cnt);

      __DBGpr_int(" Number of rows returned by RISquery",rows);

      if (sts != 1 || rows == 0)
      {
       printf("Failed accessing %s for end_condition.\n",table);
       printf("SELECT <%s>\nFROM <%s>\n%s\n%s\n ", select,
                table, where_string,order);
       *msg = VR_E_DbShortErrMsg;
       End
       return (OM_E_ABORT);

      }
      else {
        for(i=0; i < curr_cache_size1; i++ )
        {
       	   if(cache_fieldlist_cur[i].application == application &&
           strcmp(cache_fieldlist_cur[i].field_name, "end_condition") == 0)
           {
           	in_cache = 1;
           	slot = i;
           	break;
           }
        }

	__DBGpr_int(" in_cache",in_cache);
	__DBGpr_int(" slot",slot);

        if(in_cache) {
          ii = 0;

	  __DBGpr_int(" par_cnt ", par_cnt );

          for(i = 0; i < par_cnt && i < VR_MAX_FIELDLIST_SIZE; i++){
            /*** The J loop is unnecessary with the breaks given ***/
            /*** The performance seems OK, no apparent errors    ***/
// 	    for( j = 0; j <  cache_fieldlist[slot].count; j++) {
            j = 0;
	     __DBGpr_str("field content in cache",cache_fieldlist[slot].field[j]);
	     __DBGpr_str("output of RISquery",outdata[i].data.val.attr_c);

	     if ( !strcmp( cache_fieldlist[slot].field[j], "<blank>") &&
                       outdata[i].data.val.attr_c[0] == 0)
	     {
                 cache_fieldlist_cur[slot].field[ii][0] = '\0';
                 strcpy( cache_fieldlist_cur[slot].field[ii], "<blank>" );
                ii++;
//                break;
             }
             else
	     {
                 cache_fieldlist_cur[slot].field[ii][0] = '\0';
                 strncpy( cache_fieldlist_cur[slot].field[ii],
                   outdata[i].data.val.attr_c,9);
                ii++;
//                break;
             }
//            } /* for j*/
          }

          if( cache_fieldlist_cur[slot].count > ii )
	  {
	    __DBGpr_int(" cache_fieldlist_cur[slot].count",cache_fieldlist_cur[slot].count);
	    __DBGpr_int(" ii (will be less than above)",ii);

            for( i = ii; i < cache_fieldlist_cur[slot].count; i++ )
                 cache_fieldlist_cur[slot].field[i][0] = '\0';
          } 
          cache_fieldlist_cur[slot].count = ii;
          *cond_num = cache_fieldlist_cur[slot].count;
          *condlist = (char *) (cache_fieldlist_cur[slot].field);
        }
        else {
          printf(" Can not update %s list \n", end_condition);
          *msg = VR_E_DbShortErrMsg;
	  End
          return (OM_E_ABORT);
        }
      }
  }

  /* extract pressure_class list  */
  slot = -1;
  in_cache = 0;
  if ( strcmp( pressure_class, "EMPTY" ) != 0) {
     for(i=0; i < curr_cache_size1; i++ )
     {
       if(cache_fieldlist_cur[i].application == application &&
           strcmp(cache_fieldlist_cur[i].field_name, "pressure_class") == 0)
       {
           in_cache = 1;
           slot = i;
           break;
       }
     }
     if(in_cache) {
         for( j = 0; j < cache_fieldlist_cur[slot].count; j++) {
                 cache_fieldlist_cur[slot].field[j][0] = '\0';
         }
         cache_fieldlist_cur[slot].count = 1;
         strcpy( cache_fieldlist_cur[slot].field[0], pressure_class);
         *pres_num = cache_fieldlist_cur[slot].count;
         *preslist = (char *) (cache_fieldlist_cur[slot].field);
     }
     else {
          printf(" Can not update %s list \n", pressure_class);
          *msg = VR_E_DbShortErrMsg;
	  End
          return (OM_E_ABORT);
     }
  }
  else {   
      select = "distinct pressure_class";
      sprintf(order,"ORDER by pressure_class" );
      sprintf( ris_str,"SELECT %s FROM %s %s %s", select, table,
            where_string, order);

      __DBGpr_str(" ris_str for pressure_class",ris_str);

      sts = RISexecute_query( ris_str, outdata, &rows, &cols, &par_cnt);

      __DBGpr_int(" Number of rows returned by RISexecute_query",rows);

      if (sts != 1 || rows == 0)
      {
       printf("Failed accessing %s for pressure_class.\n",table);
       printf("SELECT <%s>\nFROM <%s>\n%s\n%s\n ", select,
                table, where_string,order);
          *msg = VR_E_DbShortErrMsg;
	  End
          return (OM_E_ABORT);

      }
      else {
        for(i=0; i < curr_cache_size1; i++ )
        {
           if(cache_fieldlist_cur[i].application == application &&
           strcmp(cache_fieldlist_cur[i].field_name, "pressure_class") == 0)
           {
                in_cache = 1;
                slot = i;
                break;
           }
        }
        if(in_cache) {
          ii = 0;
          for(i = 0; i < par_cnt && i < VR_MAX_FIELDLIST_SIZE; i++) {
            /*** The j loop is unneccessary with the breaks ***/
            j = 0;
//            for( j = 0; j <  cache_fieldlist[slot].count; j++) {

	     __DBGpr_str("field content in cache",cache_fieldlist[slot].field[j]);
	     __DBGpr_str("output of RISquery",outdata[i].data.val.attr_c);

	     if ( !strcmp( cache_fieldlist[slot].field[j], "<blank>") &&
                       outdata[i].data.val.attr_c[0] == 0)
	     {
                 cache_fieldlist_cur[slot].field[ii][0] = '\0';
                 strcpy( cache_fieldlist_cur[slot].field[ii], "<blank>" );
                ii++;
//                break;
             }
             else
	     {
                 cache_fieldlist_cur[slot].field[ii][0] = '\0';
                 strncpy( cache_fieldlist_cur[slot].field[ii],
                   outdata[i].data.val.attr_c,9);
		 __DBGpr_str(" pressure_class (corrected)",cache_fieldlist_cur[slot].field[ii]);
                ii++;
//                break;
             }
//            }
          }
          if( cache_fieldlist_cur[slot].count > ii )
	  {
	    __DBGpr_int(" cache_fieldlist_cur[slot].count",cache_fieldlist_cur[slot].count);
	    __DBGpr_int(" ii (will be less than above)",ii);

          for( i = ii; i < cache_fieldlist_cur[slot].count; i++ )
                 cache_fieldlist_cur[slot].field[i][0] = '\0';
          } 
          cache_fieldlist_cur[slot].count = ii;
          *pres_num = cache_fieldlist_cur[slot].count;
          *preslist = (char *) (cache_fieldlist_cur[slot].field);
        }
        else {
          printf(" Can not update %s list \n", pressure_class);
          *msg = VR_E_DbShortErrMsg;
	  End
          return (OM_E_ABORT);
        }
     }
  }

  /* extract end_standard list  */
  slot = -1;
  in_cache = 0;
  if ( strcmp( end_standard, "EMPTY" ) != 0) {
     for(i=0; i < curr_cache_size1; i++ )
     {
       if(cache_fieldlist_cur[i].application == application &&
           strcmp(cache_fieldlist_cur[i].field_name, "end_standard") == 0)
       {
           in_cache = 1;
           slot = i;
           break;
       }
     }
     if(in_cache) {
         for( j = 0; j < cache_fieldlist_cur[slot].count; j++) {
            cache_fieldlist_cur[slot].field[j][0] = '\0';
         }
         cache_fieldlist_cur[slot].count = 1;
         strcpy( cache_fieldlist_cur[slot].field[0], end_standard);
         *stan_num = cache_fieldlist_cur[slot].count;
         *stanlist = (char *) (cache_fieldlist_cur[slot].field);
     }	  
     else {
          printf(" Can not update %s list \n", end_standard);
          *msg = VR_E_DbShortErrMsg;
	  End
          return (OM_E_ABORT);
     }
 
  }
  else {
      select = "distinct end_standard";
      sprintf(order,"ORDER by end_standard" );
      sprintf( ris_str,"SELECT %s FROM %s %s %s", select, table,
            where_string, order);

      __DBGpr_str(" ris_str for distinct end_standard",ris_str);

      sts = RISexecute_query( ris_str, outdata, &rows, &cols, &par_cnt);

      __DBGpr_int(" rows returned by RISexecute_query",rows);

      if (sts != 1 || rows == 0)
      {
       printf("Failed accessing %s for end_standard.\n",table);
       printf("SELECT <%s>\nFROM <%s>\n%s\n%s\n ", select,
                table, where_string,order);
          *msg = VR_E_DbShortErrMsg;
	  End
          return (OM_E_ABORT);
      }
      else {
        for(i=0; i < curr_cache_size1; i++ )
        {
           if(cache_fieldlist_cur[i].application == application &&
           strcmp(cache_fieldlist_cur[i].field_name, "end_standard") == 0)
           {
                in_cache = 1;
                slot = i;
                break;
           }
        }
        if(in_cache) {
          ii = 0;
          for(i = 0; i < par_cnt && i < VR_MAX_FIELDLIST_SIZE; i++) {
            /**** j loop is unnecessary with the breaks in the if blocks ***/
//            for( j = 0; j <  cache_fieldlist[slot].count; j++) {
            j = 0;
	     __DBGpr_str("field content in cache",cache_fieldlist[slot].field[j]);
	     __DBGpr_str("output of RISquery",outdata[i].data.val.attr_c);

	     if ( !strcmp( cache_fieldlist[slot].field[j], "<blank>") &&
                       outdata[i].data.val.attr_c[0] == 0)
	     {
                 cache_fieldlist_cur[slot].field[ii][0] = '\0';
                 strcpy( cache_fieldlist_cur[slot].field[ii], "<blank>" );
                ii++;
//                break;
             }
             else
	       {
		 cache_fieldlist_cur[slot].field[ii][0] = '\0';
                 strncpy( cache_fieldlist_cur[slot].field[ii],
                   outdata[i].data.val.attr_c,19); /** law 04/02/98 **/
                   /** law 04/02/98 **/
                 cache_fieldlist_cur[slot].field[ii][19] = '\0';
		__DBGpr_str(" End std (corrected)",cache_fieldlist_cur[slot].field[ii]);
                ii++;
//                break;
             }
//            }
          }
          if( cache_fieldlist_cur[slot].count > ii )
	  {
	    __DBGpr_int(" cache_fieldlist_cur[slot].count",cache_fieldlist_cur[slot].count);
	    __DBGpr_int(" ii (will be less than above)",ii);

          for( i = ii; i < cache_fieldlist_cur[slot].count; i++ )
                 cache_fieldlist_cur[slot].field[i][0] = '\0';
          } 
          cache_fieldlist_cur[slot].count = ii;
          *stan_num = cache_fieldlist_cur[slot].count;
          *stanlist = (char *) (cache_fieldlist_cur[slot].field);
        }
        else {
          printf(" Can not update %s list \n", pressure_class);
          *msg = VR_E_DbShortErrMsg;
	  End
          return (OM_E_ABORT);
        }
      }
  }
  
  /* find relative macro_name if nominal_size != 0, end_condition != EMPTY
     pressure_class != EMPTY and end_standard != EMPTY */

  if( nominal_size != 0 &&  
      strcmp( end_condition, "EMPTY") &&
      strcmp( pressure_class, "EMPTY")&& 
      strcmp( end_standard, "EMPTY") ) 
  {

        size = nominal_size;
        if(VRGL_PROJ.npd_eqflag == 1 ) {
            /* get equivelent value */
            for( i1 = 0; i1 < nNPD; i1++ )
            {
	      /*BILLA  Double value comparison problem */
              if( fabs(nominal_size - pNPD[i1].npd) < VRGetTol(VR_DIST_TOL) )
              {
                  size = pNPD[i1].npd_eq;
                  break;
              }
            }
        } 

        table = VRDB_PIPNOZZLE1;
        select = "macro_name";
        if( !strcmp( end_condition, "<blank>"))
            sprintf( end_condition1, "' ' or end_condition is null");
        else
            sprintf( end_condition1, "'%s'", end_condition);

        if( !strcmp( pressure_class, "<blank>"))
            sprintf( pressure_class1, "' ' or pressure_class is null");
        else
            sprintf( pressure_class1, "'%s'", pressure_class);

        if( !strcmp( end_standard, "<blank>"))
            sprintf( end_standard1, "' ' or end_standard is null");
        else
            sprintf( end_standard1, "'%s'", end_standard);

        sprintf( where_string, "WHERE nominal_size = %f and end_condition = %s and pressure_class = %s and end_standard = %s and units_set = %d", 
        	size, end_condition1, pressure_class1, end_standard1, 
		prj_units_used);

        sprintf( ris_str,"SELECT %s FROM %s %s", select, table,
                 where_string);

        sts = RISexecute_query( ris_str, outdata, &rows, &cols, &par_cnt);
        if (sts != 1 || rows == 0)
        {
           printf("Failed accessing %s for fieldlist set.\n", table);
           printf("SELECT <%s>\nFROM <%s>\n%s\n ", select, table, where_string);
           *msg = VR_E_DbShortErrMsg;
	   End
           return (OM_E_ABORT);
        }
        /* pick up macro_name from first row which matchs with input conds */ 
        if( outdata[0].data.val.attr_c != 0 ) 
           strcpy(macro_name, outdata[0].data.val.attr_c);
  }
  *msg = ACC_S_SUCCESS;
  End
  return OM_S_SUCCESS;
}

end implementation Root;

