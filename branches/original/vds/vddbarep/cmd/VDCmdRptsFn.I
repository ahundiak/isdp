/* $Id: VDCmdRptsFn.I,v 1.1.1.1 2001/01/04 21:08:33 cvs Exp $  */

/* I/VDS
 *
 * File:	VDSdbarep/VDRptsFn.I 
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdRptsFn.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:33  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.2  1995/11/29  13:55:26  pinnacle
# Replaced: ./vddbarep/cmd/VDCmdRptsFn.I for:  by ksundar for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 *	03/31/94	adz		vdbmacros conversion.
 *
 */
class implementation Root;

#include <stdio.h>
#include <string.h>
#include "msmacros.h"
#include "FI.h"
#include "dbadev.h"
#include "vdbmacros.h"

#include "VDmsg.h"
#include "VDRptsDef.h"


/*+fi
  Internal Function VDSetCatFld

  Abstract
	This function sets the associated list field of catalog field with the
	list of catalogs, parts and revisions, and also sets the catalogi
	field with the active row.

  Algorithm
      <Optional>

  Notes/Remarks
	Raju	1 Sep 1993	Creation

  Examples
      <Optional>

  Returns
      <Description>
*/

void VDSetCatFld( long *msg,		/* O - return message	*/
		  Form  *fp,		/* I - form pointer	*/
		  int field,		/* I - field to set the catalog list */
		  int *act_field )	/* I - current active row no.	*/
/*
-fi*/

{
int		row, nb_assmb;
char		**ass_cat=NULL;
char		**ass_part=NULL;
char		**ass_rev=NULL;
char		proj_nb[20];
char		proj_rev[12];
char		proj_units[20];
char		tmp_text[90];
long		sts;


  *msg = 1;
  /*  get project number, revision and units */
  sts = VDGetProjectNumRev( proj_nb, proj_rev, proj_units);
  /* Is it necessary to check the return status ????? */

  /*get the list of assembly catalogs , parts and revisions*/
  if(VDGetProjectAssmb(proj_nb,proj_rev,&ass_cat,&ass_part,&ass_rev,&nb_assmb)
	!= 1 )       /* Error getting the list */
  {  ex$message(msgnumb=VD_E_RpGtAsLs);
     *msg = 0;
     goto wrapup;
  }

  if ( nb_assmb == 0 )       /* No parts are posted */
  {  ex$message(msgnumb=VD_E_RpNoPrPs);
     *msg = 0;
     goto wrapup;
  }

  if ( *act_field > nb_assmb-1 )
     *act_field = nb_assmb-1;

#ifdef RAJU_DBG
  for (row = 0; row < nb_assmb; ++row)
    printf("row = %d, ass_cat = %s, ass_part = %s, ass_rev = %s\n", row,
      ass_cat[row], ass_part[row], ass_rev[row] );
#endif

  for(row = 0; row < nb_assmb; ++row)
  {
     sprintf(tmp_text,"%-26s %-16s  %-20s",ass_cat[row], ass_part[row],
		 ass_rev[row] );

     if (VDfld_set_list_text( fp, field, row, 0, tmp_text, 0) != FI_SUCCESS)
     {
       /* Error setting the list */
       *msg = 0;
       goto wrapup;
     }

     if ( row == *act_field )
	FIfld_set_text( fp, field, 0, 0, tmp_text, 0);
  }

wrapup:
/* free memory */
/*
  for(ii=0; ii<nb_assmb; ii++)
  { if ( ass_cat[ii] ) free (ass_cat[ii]);
    if ( ass_part[ii] ) free (ass_part[ii]);
    if ( ass_rev[ii] ) free (ass_rev[ii]);
  }
  if ( ass_cat ) { free (ass_cat); ass_cat = NULL; }
  if ( ass_part ) { free (ass_part); ass_part = NULL; }
  if ( ass_rev ) { free (ass_rev); ass_rev = NULL; }
*/

  VDSfree_arrays ( nb_assmb, ass_cat, ass_part, ass_rev );    
  return;

}

/*+fi
  Internal Function VDSetPrjFld

  Abstract
	This function sets the field with the project no.

  Algorithm
      <Optional>

  Notes/Remarks
	Raju   1 Sep 1993      Creation
  Examples
      <Optional>

  Returns
      <Description>

*/

void VDSetPrjFld( long *msg,		/* O - return status	*/
		  Form  *fp,		/* I - form pointer	*/
		  int field )		/* I - filed for project no. */
/*
-fi*/
{
long		sts;
char		proj_nb[20];
char		proj_ver[12];
char		proj_units[20];

  *msg = 1;
  /*  get project number, revision and units */
  sts = VDGetProjectNumRev( proj_nb, proj_ver, proj_units);
  /* Is it necessary to check the return status ????? */

  FIfld_set_text( fp, field, 0, 0, proj_nb, 0);

}

/*+fi
  Internal Function VDSetRevLst

  Abstract
	This function gives the no. of revisions for the project

  Algorithm
      <Optional>

  Notes/Remarks
	Raju   1 Sep 1993      Creation

  Examples
      <Optional>

  Returns
      <Description>

*/

void VDGetPrjRevList( long *msg,	/* O - return message	*/
		      int *num	)	/* O - no. of revisions */
/*
-fi*/
{
long		sts;
char		proj_nb[20];
char		proj_ver[12];
char		proj_units[20];
char		where[100];
char		**buf = NULL;


  *msg = 1;
  sts = VDGetProjectNumRev( proj_nb, proj_ver, proj_units);
  sprintf(where,"prj_number='%s'", proj_nb);

  sts =
  vdb$RisSelect(        select		= "prj_version",
                        table_name	= "vds_project",
                        where   	= where,
                        numselect	= 1,
                        p_numrows	= num,
                        p_buffer 	= &buf );

  if( sts != SUCCESS ){

        ex$message(msgnumb=VD_E_PrVdsPrj);
	*msg = 0;
        goto wrapup;
  }

wrapup:
  sts =
  vdb$RisFreeBuffer ( buffer = buf, size = *num );

  return;
}

/*+fi
  Internal Function VDSetPrjRev

  Abstract
	This function sets the associated field of the given field with the
	list of revisions. Also sets the given field with the active row
	of revision.

  Algorithm
      <Optional>

  Notes/Remarks
	Raju   1 Sep 1993      Creation

  Examples
      <Optional>

  Returns
      <Description>

*/
void VDSetPrjRev( long *msg,		/* O - return message	*/
		  Form  *fp,		/* I - form pointer	*/
		  int field,		/* I - field for the revision */
		  int *act_field )	/* I - active row of revision */
/*
-fi*/
{
long		sts;
char		proj_nb[20];
char		proj_ver[12];
char		proj_units[20];
int		num, row;
char		**buf=NULL, where[100];


  *msg = 1;
  sts = VDGetProjectNumRev( proj_nb, proj_ver, proj_units);
  sprintf(where,"prj_number='%s'", proj_nb);

  sts =
  vdb$RisSelect(        select          = "prj_version",
                        table_name      = "vds_project",
                        where           = where,
                        numselect       = 1,
                        p_numrows       = &num,
                        p_buffer        = &buf );


  if( sts != SUCCESS ){

        ex$message(msgnumb=VD_E_PrVdsPrj);
	*msg = 0;
        goto wrapup;
  }
  if ( num == 0) { ex$message(msgnumb=VD_E_PrVdsPrj);  *msg = 0;
        goto wrapup;}

  if ( *act_field > num-1 )
       *act_field = num-1;

  for(row = 0; row < num; ++row)
  {
     if (VDfld_set_list_text( fp, field, row, 0, buf[row], 0) != FI_SUCCESS)
     {
       /* Error setting the list */
       *msg = 0;
       goto wrapup;
     }

     if ( row == *act_field )
	FIfld_set_text( fp, field, 0, 0, buf[row], 0);
  }

wrapup:

  sts =
  vdb$RisFreeBuffer ( buffer = buf, size = num );

  return;
}


/*+fi
  Internal Function VDSetTemp

  Abstract
	This function sets the associated field of the given field with the
	list of templates. Also sets the given field with the active row
	of template.

  Algorithm
      <Optional>

  Notes/Remarks
	Raju   1 Sep 1993      Creation

  Examples
      <Optional>

  Returns
      <Description>

*/
void VDSetTemp ( long *msg,		/* O - return message	*/
		 char *TempLib,		/* I - Template library */
		 int *TempNo,		/* I - active template no. */
		 Form *fp,		/* I - form pointer	*/
		 int field  )		/* I - tempalte field	*/
/*
-fi*/
{
struct dba_template  *TempList;
int row, nb_temp;
char	temp_string[100];

  *msg = 1;

  if ( dba_list_library( TempLib, DBA_REPORTS, &TempList, &nb_temp ))
  {  ex$message(msgnumb=VD_E_RpTmLs, buff= temp_string);
     FIg_set_text( fp, FI_MSG_FIELD, temp_string );
     *msg = 0;
     goto wrapup;
  }

  if ( nb_temp == 0 ) /* Empty library */
  {  ex$message(msgnumb=VD_E_EmLb, buff= temp_string);
     FIg_set_text( fp, FI_MSG_FIELD, temp_string );
     *msg = 0;
     goto wrapup;
  }

  if ( *TempNo > nb_temp-1 )
	*TempNo = nb_temp - 1;

  FIfld_set_list_num_rows ( fp, field, 0, nb_temp );
  for(row = 0; row < nb_temp; ++row)
  {
     sprintf(temp_string,"%-20s %-40s ",
		TempList[row].name,TempList[row].description);
     if (VDfld_set_list_text( fp, field, row, 0, temp_string, 0) != FI_SUCCESS)
     {
       /* Error setting the list */
/*       ex$message(msgnumb=VD_E_PrUsNotSel); */
       *msg = 0;
       goto wrapup;
     }

     if ( row == *TempNo )
	FIfld_set_text( fp, field, 0, 0, temp_string, 0);
  }

  if ( TempList )  free ( TempList );

wrapup:
  return;

}

/*+fi
  Internal Function VDSetCatList2

  Abstract
	This function sets the associated field of the second catalog field
	with the list of catalogs which are revisions of first catalog.
	Also sets the field with the first row of catalogs in the list.

  Algorithm
      <Optional>

  Notes/Remarks
	Raju   1 Sep 1993      Creation

  Examples
      <Optional>

  Returns
      <Description>

*/
void VDSetCatList2( long *msg, 		/* O - return message	*/
		    Form *fp,		/* I - form pointer	*/
		    int field1,		/* I - field for first revision */
		    int field2,		/* I - field for second revision */
		    int *Part2	)	/* O - active row in second revision */

/*
-fi*/
{
char	PartText[ VD_MAX_PART_LEN ], msg_buff[81];
int	sel_flag, r_pos, num_row;
char	AssCat[20], AssPart[20], AssRev[20];
char	AssCat1[20], AssPart1[20], AssRev1[20];
int	ii, i1;

	*msg = 1;

	FIfld_get_text ( fp, field1, 0, 0, VD_MAX_PART_LEN,
		PartText, &sel_flag, &r_pos );
	sscanf( PartText, "%s %s %s", AssCat, AssPart, AssRev );

	FIfld_get_list_num_rows ( fp, field1, 0, &num_row );

	/* if num_row < 1 ???????? */
	i1 = 0;
	for( ii=0; ii<num_row; ii++)
	{  FIfld_get_list_text ( fp, field1, ii, 0, VD_MAX_PART_LEN, PartText, &sel_flag );
	   sscanf( PartText, "%s %s %s", AssCat1, AssPart1, AssRev1 );
	   if ( !strcmp( AssCat, AssCat1) && !strcmp( AssPart, AssPart1)
		&& strcmp( AssRev, AssRev1 ) )
	   {    
		VDfld_set_list_text( fp, field2, i1, 0, PartText, 0);
		i1++;
		if ( i1 == 1 )
		{ FIfld_set_text( fp, field2, 0, 0, PartText, 0);
		  *Part2 = 0;
		}
	   }
	}

	if ( i1 == 0 )
	{  ex$message( msgnumb=VD_E_NoRvPt, buff=msg_buff);
	   FIg_set_text( fp, FI_MSG_FIELD, msg_buff );
	   *Part2 = -1;
	   FIfld_set_text( fp, field2, 0, 0, "", 0);
	   FIfld_set_list_num_rows( fp, field2, 0, 0);
	   goto wrapup;
	}
	else
	   FIfld_set_list_num_rows( fp, field2, 0, i1 );

wrapup:
	return;
}

end implementation Root;

