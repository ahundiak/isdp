/* $Id: VRaccess_db.c,v 1.2 2002/04/15 20:01:46 anand Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrpdu / VRaccess_db.c
 *
 * Description:
 *	Extracts macro params and connect point attributes from 
 *	PDM/PDU database 
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRaccess_db.c,v $
 *	Revision 1.2  2002/04/15 20:01:46  anand
 *	Removed version.h and associated dependencies. version.h is
 *	an include file in $EXNUC.
 *	
 *	Revision 1.1.1.1  2001/01/04 21:13:01  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.2  1997/08/15  19:34:34  pinnacle
 * Replaced: vrpdu for:  by hverstee for route
 *
 * Revision 1.1  1996/04/22  14:59:00  pinnacle
 * Created: vrpdu/VRaccess_db.c by hverstee for route240
 *
 * Revision 1.2  1996/01/17  17:31:20  pinnacle
 * Replaced: vrpdu/access_db.c for:  by r240_int for route240
 *
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *
 *************************************************************************/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "igrtypedef.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "VRDbStruct.h"
#include "dberror.h"
#include "VRmsg.h"
#include "vrpdu_pto.h"

extern	      UI_status();

#if 0
#define   VERSION   "2.0.0"

extern int   prj_units_set;

int access_db (

char             *fam_name,    /* family or macro name                  (I) */
char             *part_num,    /* part number of the component          (I) */
short		 comp_type,
struct ACrg_coll mac_pm[],     /* macro parameters                      (O) */
int		 *pm_no,       /* cnt of parameters already in mac_pm (I/O) */
char             *err_ptr,     /* error message buffer                  (O) */
int              *flag)        /* flag for column "o1"                  (O) */

{

/****************************************************************************/
/*                                                                          */
/* This routine extracts connect point attributes and macro parameters from */
/* the PDM/PDU tables.                                                      */
/*                                                                          */
/*  Algorithm :                                                             */
/*            1)Call RISexecute_query to load a row of data containing the  */
/*              part number from the table with the family name in the      */
/*              nfm database.                                               */
/*	      2)Determine start column for parameters.                      */
/*            3)Load params into the mac_pm struct.			    */
/*                                                                          */
/*    Routines :                                                            */
/*              RISexecute_query                                            */
/****************************************************************************/

  int		sts, i;
  struct VRrisdat 	outdata[MAX_RIS_QUERY_PAR];
  int           rows;
  int           cols;
  int           par_cnt;
  char		table[MAX_ATTR_LEN];		/* table name */
  char		*select=NULL;    	/* select list */
  char		search[MAX_WHERE_SIZE];		/* where clause of a select */
  char          ris_str[MAX_RIS_STR_SIZE];
  int           firstcol,  currcol, unit_col;
  char          tmp[20];
  char          disp_err[100];
  int           part_units;

  unit_col   = -1;
  part_units = prj_units_set;

#ifdef DEBUG
printf("  access_db of version: %s\n", VERSION);
#endif

/* Load catalog part */
#ifdef DEBUG 
printf("  Accessing PDM catalog\n");
#endif

UI_status("Processing.         ");

    sprintf( table , "%s",fam_name);
    select = "*";
    sprintf( search, "WHERE %s = '%s'", "n_itemname", part_num );
    sprintf( ris_str,"SELECT %s FROM %s %s", select, table, search );

    sts = RISexecute_query( ris_str, outdata, &rows, &cols, &par_cnt);
    if (sts != 1 || rows == 0)
    {
           printf("Error locating part in PDM part catalog\n");
           printf("Family name: <%s>\n", fam_name);
           printf("Search criteria: <%s>\n", search);
           sprintf(disp_err,"n_itemname '%s'",part_num);
           VRdb_err_msg(VR_E_DbLongErrMsg,err_ptr,table,"Row",disp_err);
	   return (ACC_E_PDM_FAMILY);
    }

UI_status("Processing..        ");


#ifdef DEBUG
printf("  Locating 1st parameter\n");
#endif

/* Skip all the PDM and NFM paramaters  */

        for(i=0; i < par_cnt &&
                 (strncmp(outdata[i].name,"p_", 2) == NULL 
              || strncmp(outdata[i].name,"n_", 2) == NULL);
              i++){}
	firstcol=i;


#ifdef DEBUG
printf("  Loading collection\n");
#endif

/* Locate the units_set parameter and obtain the part_units */

       while( i < par_cnt)
       {
           if(strcmp(outdata[i].name,"units_set" )==0)
           {
		part_units = outdata[i].data.val.attr_int;
                unit_col = i;
                break;
           }
           i++;
       }                           

/* If units_set is not defined in the PDM family table */

       if( i == par_cnt )
       {
          /* Set units_set to prj_units_set */
          part_units = prj_units_set;
          unit_col = -1;
          printf("Units_set not defined in family table\n");
          printf("Family name:%s\n",fam_name);
          printf("Setting project units set as the default units set...\n");
          VRdb_err_msg(VR_E_DbUnitErrMsg,err_ptr,NULL,NULL,NULL);
       }

       *flag = 0;
       currcol = firstcol;
       while(currcol < par_cnt)
       {
           if(currcol == unit_col)
           {
               currcol++;
               continue;
           } 
	   if(( strcmp( outdata[currcol].name,"dry_wt") == 0) && (( comp_type == 0) || (comp_type == 12 )))
	   {
		strcpy(tmp,"dry_uwt");
	   } 
	   else
	   if(( strcmp( outdata[currcol].name,"wet_wt") == 0) && (( comp_type == 0) || (comp_type == 12 )))
	   {
		strcpy(tmp,"wet_uwt");
	   }
	   else
           	strcpy(tmp, outdata[currcol].name);

           	strcpy(mac_pm[*pm_no].name, outdata[currcol].name);

           /* Set flag if column o1 exists */
           if(strcmp(mac_pm[*pm_no].name, "o1") == 0 )
           {
             *flag = 1;
           }
           if(outdata[currcol].data.type == VR_RISDB_TEXT)
           {
             strcpy(mac_pm[*pm_no].desc.value.att_txt, outdata[currcol].data.val.attr_c);
             mac_pm[*pm_no].desc.type = AC_ATTRIB_TEXT;
             *pm_no += 1;
           }
           else if (outdata[currcol].data.type == VR_RISDB_INT)
           {
	     if(( prj_units_set != part_units ) && (outdata[currcol].data.val.attr_int != -9999) && (outdata[currcol].data.val.attr_int != -32768))
	     {
		mac_pm[*pm_no].desc.value.att_exp = 
			converted_to_vds(tmp, part_units,prj_units_set,
				(double)outdata[currcol].data.val.attr_int,err_ptr); 
/*
		printf("mac_pm value = %f\n\n", mac_pm[*pm_no].desc.value.att_exp );

*/
	     }
	     else
             	mac_pm[*pm_no].desc.value.att_exp = (double)outdata[currcol].data.val.attr_int;
             mac_pm[*pm_no].desc.type = AC_ATTRIB_DOUBLE;
             *pm_no += 1;
           }
           else if (outdata[currcol].data.type == VR_RISDB_DOUBLE)
           {
	     if(( prj_units_set != part_units ) && (outdata[currcol].data.val.attr_dbl != -9999.0) && (outdata[currcol].data.val.attr_dbl != -32768.0))
	     {
		mac_pm[*pm_no].desc.value.att_exp = 
			converted_to_vds(tmp,part_units, prj_units_set,
					outdata[currcol].data.val.attr_dbl,err_ptr); 
/*
		printf("mac_pm value = %f\n\n", mac_pm[*pm_no].desc.value.att_exp );
*/
	     }
	     else
             	mac_pm[*pm_no].desc.value.att_exp = outdata[currcol].data.val.attr_dbl;
             mac_pm[*pm_no].desc.type = AC_ATTRIB_DOUBLE;
             *pm_no += 1;
           }
           currcol += 1;
        }
	strcpy(mac_pm[*pm_no].name,"units_set");
	mac_pm[*pm_no].desc.type = AC_ATTRIB_DOUBLE;
	mac_pm[*pm_no].desc.value.att_exp = prj_units_set;
	*pm_no += 1;

/*
	printf(" pm_no = %d\n", *pm_no );
*/

UI_status(" ");

	return (1);
}


#endif 
