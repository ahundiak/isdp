/* $Id: VDIdManage.C,v 1.1.1.1 2001/01/04 21:09:31 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdutil / VDIdManage.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDIdManage.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:31  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/


/************************************************************************/
/*									*/
/*	File: VDIdManage.C						*/
/*	By  : Mallik.							*/
/*	Date: 9.16.93							*/
/*									*/
/*	Description:	This file contains functions needed to manage   */
/*			Unique ID's in the database.			*/
/*									*/
/************************************************************************/

/* The defines to be in a include file used by the caller */

#include	<stdio.h>

#include        "exmacros.h"
#include        "OMerrordef.h"

#include 	"ms.h"
#include 	"msdef.h"
#include 	"msmacros.h"
 
#include	"VDDbDef.h"
#include	"vdbmacros.h"
#include	"VDSutil.h"
#include	"VDmsg.h"
#include	"VDSris_def.h"
#include	"PDUerror.h"

/************************************************************************/
/*									*/
/*	int VRGetListOfIDs( PrjNumber,SystemName,CompCategory, IdList ) */
/*	char	*PrjNumber;		(I)  Project Number		*/
/*	char	*SystemName;		(I)  System name of Network	*/
/*	char	*CompCategory;		(I)  Category for ID mgmnt	*/
/* 	char	*IdList[VDS_LIST_OF_IDS];(I)  Proposed list of ID's	*/
/*									*/
/************************************************************************/

int	VDGetListOfIDs( SystemName, CompCategory, IdList )
char	*SystemName;
int	CompCategory;			/* Category may be a short */
int	IdList[];
{
	char	*table=VDS_PLACED_ID_TBL;
	char	*select="distinct ID_NUM";	/* query for ID_NUM */
	char	*order="ID_NUM";	/* query for ID_NUM */
	char	where[MAX_WHERE_SIZE];
	char	**UsedIds;
	char	PrjNumber[40], PrjRevision[40];
	int	PrjUnits;
	int	n_usedids, n_select;
	int	*numbarray, left, right, startval, index;
	int	i,ret_msg;

	if ( VDSverify_login() != PDM_S_SUCCESS )
	{
		ex$message(msgnumb = VD_E_PrUsNotLog );
		return 0;
	}
	if ( VDSverify_project() != OM_S_SUCCESS )
	{
		ex$message(msgnumb = VD_E_PrVdsPrj );
		return 0;
	}
	if(!VDGetProjectNumRev ( PrjNumber, PrjRevision, &PrjUnits ))
		return 0;

	/* query the database for the list of ID's placed */
	sprintf(where,"prj_number ='%s' and system_name ='%s' and category =%d and id_num > 0 ",
		 PrjNumber, SystemName, CompCategory );
	n_select=1;
        ret_msg =
                vdb$RisSelect(  select        =       select,
                                table_name    =       table,
                                where         =       where,
                                order         =       order,
                                group         =       NULL,
                                numselect     =       n_select,
                                p_numrows     =       &n_usedids,
                                p_buffer      =       &UsedIds );
        if(  ret_msg != 1) return 0;

	/* Fill up the IdList with the first 10 available ID's */
	/* The available ID's are from 0 - 99999 	       */

	if( n_usedids == 0 )   /* Nothing in the database */
	{
		for ( i=0; i < VDS_LIST_OF_IDS; i++ )
			IdList[i] = i+1;
	}
	else
	{
		int	j;

		numbarray = (int *) calloc ( n_usedids, sizeof (int) );

		for ( i=0; i < n_usedids; i++ )
			numbarray[i] = atoi(UsedIds[i]);

		left = 0; right = n_usedids-1; startval = 1;

		for ( i=0; i < VDS_LIST_OF_IDS; i++ )
		{
			IdList[i]=LocateAvailableID( left, right, startval, numbarray, &index );
			if(IdList[i] == -1 ) break;
			startval = IdList[i] + 1;
			left = index;
		}
		for ( j = i; j < VDS_LIST_OF_IDS; j++ )
			IdList[j] = atoi(UsedIds[right])+(j-i+1);

		vdb$RisFreeBuffer(  buffer     =      UsedIds,
                                    size       =      n_select * n_usedids );
		free(numbarray);
	}
	return 1;
}


int   LocateAvailableID( left, right, startval, numbarray, index )
int   left;
int   right;
int   startval;
int   numbarray[];
int   *index;
{

	/* The function locates the available ID's in the range selected */
	/* from the database. If not available it returns immediately.   */ 

	int	l,r,mid,checkval;

	if( numbarray[left] > startval )
	{
	   *index = left;
	   return startval;
	}

	/*  If there is nothing available return immediately  */

	if((numbarray[left] == startval) 
	    && ( numbarray[right] == (startval+right-left) ))
	   return -1;

	/* Search for the first available number in the list */

	l = left;
	r = right;
	mid = (left+right)/2;
	checkval = mid - left + startval;

	while ( r > l+1 )
	{
	   if(numbarray[mid] == checkval )
	      l = mid;
	   else
	      r = mid;
	   mid = (l+r)/2;
	   checkval = mid - l + numbarray[l];
	}
	*index = l+1;
	return (numbarray[l] + 1);
}

/*D
	This function is called when a particular ID is used by any component.
	This makes it unusable by any other component. This is used for comp-
	onents, equipments and also Line sequence numbers.

	System Name 			char[13];
	CompCategory			integer;
	UsedID				integer;
*/


int VDLockSelectedID ( SystemName, CompCategory, UsedID )
char	*SystemName;
int	CompCategory;			/* Category may be a short */
int	UsedID;
{

	int	columns=5;	/* No of columns in VDS_USED_ID_LIST */
	char	*table=VDS_PLACED_ID_TBL;
	int	col_typ[5];
	int	i;
	char	*col_value[5];
	char	PrjNumber[40], PrjRevision[40];
	int	PrjUnits;

	if (UsedID < 0) return 1;

	if ( VDSverify_login() != PDM_S_SUCCESS )
	{
		ex$message(msgnumb = VD_E_PrUsNotLog );
		return 0;
	}
	if ( VDSverify_project() != OM_S_SUCCESS )
	{
		ex$message(msgnumb = VD_E_PrVdsPrj );
		return 0;
	}
	if(!VDGetProjectNumRev ( PrjNumber, PrjRevision, &PrjUnits ))
		return 0;

	if( VDVerifyIfIDisUsed(SystemName, CompCategory, UsedID) == 
		VDS_ID_IS_USED ) return VDS_ID_IS_USED;

	for ( i=0; i<columns; i++ )
	{ col_value[i]=NULL; col_value[i]=(char *)calloc (20, sizeof(char)); }
	col_typ[0]=col_typ[1]=col_typ[2]= CHAR;
	col_typ[3]=col_typ[4]= INT;
	
	strcpy( col_value[0], PrjNumber );
	strcpy( col_value[1], PrjRevision );
	strcpy( col_value[2],SystemName );
	sprintf( col_value[3],"%d",CompCategory );
	sprintf( col_value[4],"%d",UsedID );

	if(!VdsSqlInsert( table,columns,col_typ, col_value ))
		return 0;
	for(i=0; i<columns; i++ ) free(col_value[i]);

	return 1;
}

/*D
	This function is called when a particular ID is modified or a component
	is deleted. A history of modifications is maintained in the database 
	done for any component. 

	System Name 			char[13];
	CompCategory			integer;
	OldID				integer;
	NewID				integer;
*/

int	VDModifyID( SystemName, CompCategory, OldId, NewId )
char	*SystemName;
int	CompCategory;
int	OldId;
int	NewId;			/* If Deleted then NewId is -1 */
{
	int	columns=6;	/* No of columns in VDS_ID_HISTORY */
	char	*table=VDS_ID_HISTORY_TBL;
	int	col_typ[6];
	int	i;
	char	*col_value[6];
	char	PrjNumber[40], PrjRevision[40];
	int	PrjUnits;

	if ( VDSverify_login() != PDM_S_SUCCESS )
	{
		ex$message(msgnumb = VD_E_PrUsNotLog );
		return 0;
	}
	if ( VDSverify_project() != OM_S_SUCCESS )
	{
		ex$message(msgnumb = VD_E_PrVdsPrj );
		return 0;
	}
	if(!VDGetProjectNumRev ( PrjNumber, PrjRevision, &PrjUnits ))
		return 0;

	if( OldId == NewId ) return 1;

	for ( i=0; i<columns; i++ )
	{ col_value[i]=NULL; col_value[i]=(char *)calloc (20, sizeof(char)); }
	col_typ[0]=col_typ[1]=col_typ[2]=CHAR;
	col_typ[3]=col_typ[4]=col_typ[5]=INT;

	strcpy( col_value[0],PrjNumber );
	strcpy( col_value[1],PrjRevision );
	strcpy( col_value[2],SystemName );
	sprintf( col_value[3],"%d",CompCategory );
	sprintf( col_value[4],"%d",OldId );
	sprintf( col_value[5],"%d",NewId );

	if(!VdsSqlInsert( table,columns,col_typ, col_value ))
		return 0;
	for(i=0; i<columns; i++ ) free(col_value[i]);
	return 1;
}

/*D
	This function is called to verify if an ID is already used by another
	component/Line. 

	System Name 			char[13];
	CompCategory			integer;
	ID				integer;
	Return Codes: 	VDS_ID_IS_USED;
			VDS_ID_ISNOT_USED;
*/

int VDVerifyIfIDisUsed( SystemName, CompCategory, ID )
char	*SystemName;
int	CompCategory;			/* Category may be a short */
int	ID;
{
	char	*table=VDS_PLACED_ID_TBL;
	char	*select="ID_NUM";	/* query for ID_NUM */
	char	where[MAX_WHERE_SIZE];
	char	**UsedIds;
	int	n_usedids, n_select;
	char	PrjNumber[40], PrjRevision[40];
	int	PrjUnits,ret_msg;

	if ( VDSverify_login() != PDM_S_SUCCESS )
	{
		ex$message(msgnumb = VD_E_PrUsNotLog );
		return 0;
	}
	if ( VDSverify_project() != OM_S_SUCCESS )
	{
		ex$message(msgnumb = VD_E_PrVdsPrj );
		return 0;
	}
	if(!VDGetProjectNumRev ( PrjNumber, PrjRevision, &PrjUnits ))
		return 0;


	/* query the database for the list of ID's placed */
	sprintf(where,"prj_number = '%s' and system_name = '%s' and category = %d and id_num = %d ",
		PrjNumber, SystemName, CompCategory,ID );
	n_select=1;
        ret_msg =
                vdb$RisSelect(  select        =        select,
                                table_name    =        table,
                                where         =        where,
                                order         =        NULL,
                                group         =        NULL,
                                numselect     =        n_select,
                                p_numrows     =        &n_usedids,
                                p_buffer      =        &UsedIds );
        if(  ret_msg != 1) return 0;

	if( n_usedids != 0) 
	{ 
		vdb$RisFreeBuffer(    buffer   =     UsedIds,
                                      size     =      n_select * n_usedids );
		return VDS_ID_IS_USED;
	}
	else
		return VDS_ID_ISNOT_USED;
}

/*D
	This function returns the new ID of a component/Equipment if the
	original is modified. This should be called only if it references
	an original. NewID is returned.

	System Name 			char[13];
	CompCategory			integer;
	OldID				integer;
	NewID				integer;
*/


int	VDGetNewID( SystemName, CompCategory, OldId, NewId )
char	*SystemName;
int	CompCategory;
int	OldId;
int	*NewId;			/* If Deleted then NewId is -1 */
{
	char	*table=VDS_ID_HISTORY_TBL;
	char	*select="new_id";
	char	where[MAX_WHERE_SIZE];
	char	PrjNumber[40], PrjRevision[40];
	int	PrjUnits,ret_msg;
	int	n_select, n_newid, count;
	char	**NewIds;

	if ( VDSverify_login() != PDM_S_SUCCESS )
	{
		ex$message(msgnumb = VD_E_PrUsNotLog );
		return 0;
	}
	if ( VDSverify_project() != OM_S_SUCCESS )
	{
		ex$message(msgnumb = VD_E_PrVdsPrj );
		return 0;
	}
	if(!VDGetProjectNumRev ( PrjNumber, PrjRevision, &PrjUnits ))
		return 0;

	n_select=1;
	n_newid=1;
	count = 0;

	while ( n_newid != 0 )
	{
		sprintf(where,"prj_number ='%s' and system_name ='%s' and category =%d and old_id = %d ",
		     PrjNumber, SystemName, CompCategory, OldId );

	/* Query the database if this ID has been modified */
                ret_msg = 
                vdb$RisSelect(  select         =       select,
                                table_name     =       table,
                                where          =       where,
                                order          =       NULL,
                                group          =       NULL,
                                numselect      =       n_select,
                                p_numrows      =       &n_newid,
                                p_buffer       =       &NewIds );

		if( ret_msg != 1 ) return 0; 
		if( n_newid == 0 && count == 0 )
			return VDS_ID_NOT_MODIFIED; /* Id has not been modified */
		else if( n_newid == 0 && count != 0 )
			return VDS_NEW_ID_FOUND;     /* Found the New Id */
		else
		{
			*NewId = atoi(NewIds[0]);
			if( *NewId == -1 ) {
			  return VDS_ID_IS_DELETED;  /* This Id has been Deleted */
			}
			else {
			  OldId = *NewId;
			}
			count ++;
		}
		vdb$RisFreeBuffer(   buffer     =      NewIds,
                                     size       =      n_select*n_newid );
	}
	return 1;
}

/*D
	This function releases an ID if it is not used. Care should be taken
	to use this. This should not be called if the component has been
	approved or it is not the original.
*/

int VDUnLockID ( SystemName, CompCategory, UsedID )
char	*SystemName;
int	CompCategory;
int	UsedID;
{
	char	*table=VDS_PLACED_ID_TBL;
	char	where[MAX_WHERE_SIZE];
	char	PrjNumber[40], PrjRevision[40];
	int	PrjUnits,ret_msg;

	if ( VDSverify_login() != PDM_S_SUCCESS )
	{
		ex$message(msgnumb = VD_E_PrUsNotLog );
		return 0;
	}
	if ( VDSverify_project() != OM_S_SUCCESS )
	{
		ex$message(msgnumb = VD_E_PrVdsPrj );
		return 0;
	}
	if(!VDGetProjectNumRev ( PrjNumber, PrjRevision, &PrjUnits ))
		return 0;
	sprintf(where,"prj_number = '%s' and system_name = '%s' and category = %d and id_num = %d ",
		PrjNumber, SystemName, CompCategory,UsedID );
        ret_msg =
        vdb$RisDelete(  table_name  =   table,
                        where       =   where );
	if ( ret_msg != 1 ) return 0;

	return 1;
}

/*C   This function returns the ID's that are used previously. The ID's also */
/*C   contains a "Complete Description of the ID's. This is obtained from    */
/*C   sch_pid_id_view table and sch_eqp_view. For the moment it is schematic */
/*C   dynamic tables that are considered.				     */

int VDGetIDDescription (SystemName, CompCategory, nbIDs, p_sIDdesc )
char		*SystemName;		/* I  SystemName		   */
int		CompCategory;		/* I  Component Category	   */
int		*nbIDs;			/* O  Number of Used ID's	   */
struct id_desc	**p_sIDdesc;		/* O  Description of ID's returned */
{
	char	where[MAX_WHERE_SIZE];
	char	select[MAX_SELECT_SIZE];
	char	PrjNumber[40], PrjRevision[40];
	int	PrjUnits;
	char	**buf;
	int	i,j,nbSelect,count,old_count,size;

	if ( VDSverify_login() != PDM_S_SUCCESS )
	{
		ex$message(msgnumb = VD_E_PrUsNotLog );
		return 0;
	}
	if ( VDSverify_project() != OM_S_SUCCESS )
	{
		ex$message(msgnumb = VD_E_PrVdsPrj );
		return 0;
	}
	if(!VDGetProjectNumRev ( PrjNumber, PrjRevision, &PrjUnits ))
		return 0;

        nbSelect = 7;
	strcpy(select,"distinct auto_id,functional_id, descript, commodity, comp_note, macro_name, original");
	sprintf(where,"prj_number = '%s' and system_name = '%s' and id_category = %d and auto_id != '' and auto_id != '-1' and auto_id is not NULL", PrjNumber, SystemName, CompCategory );
	
        vdb$RisSelect(  select = select,
                        table_name = "sch_pid_id_view",
			where = where,
                        numselect = nbSelect,
                        p_numrows = &count,
                        p_buffer = &buf );
        *p_sIDdesc = (struct id_desc *) calloc (count, sizeof(struct id_desc));
	for(i =0; i < count; i++ )
	{
		strcpy( (*p_sIDdesc)[i].tag_number, buf[i*nbSelect] );
		strcpy( (*p_sIDdesc)[i].functional_id, buf[i*nbSelect+1]);
		strcpy( (*p_sIDdesc)[i].descript, buf[i*nbSelect+2]);
		strcpy( (*p_sIDdesc)[i].commodity, buf[i*nbSelect+3]);
		strcpy( (*p_sIDdesc)[i].comp_note, buf[i*nbSelect+4]);
		strcpy( (*p_sIDdesc)[i].macro_name, buf[i*nbSelect+5]);
		(*p_sIDdesc)[i].original = atoi(buf[i*nbSelect+6]);
	}
	size = nbSelect * count;
	vdb$RisFreeBuffer ( buffer = buf, size = size );
	*nbIDs = count;
	old_count = *nbIDs;

        vdb$RisSelect(  select = select,
                        table_name = "sch_hvac_id_view",
			where = where,
                        numselect = nbSelect,
                        p_numrows = &count,
                        p_buffer = &buf );
	*nbIDs += count;
	if ( count > 0 )
           *p_sIDdesc = (struct id_desc *) realloc (*p_sIDdesc, *nbIDs * sizeof(struct id_desc));
	for(i =0,j=old_count; i < count; i++,j++ )
	{
		strcpy( (*p_sIDdesc)[j].tag_number, buf[i*nbSelect] );
		strcpy( (*p_sIDdesc)[j].functional_id, buf[i*nbSelect+1]);
		strcpy( (*p_sIDdesc)[j].descript, buf[i*nbSelect+2]);
		strcpy( (*p_sIDdesc)[j].commodity, buf[i*nbSelect+3]);
		strcpy( (*p_sIDdesc)[j].comp_note, buf[i*nbSelect+4]);
		strcpy( (*p_sIDdesc)[j].macro_name, buf[i*nbSelect+5]);
		(*p_sIDdesc)[j].original = atoi(buf[i*nbSelect+6]);
	}
	size = nbSelect * count;
	vdb$RisFreeBuffer ( buffer = buf, size = size );
	old_count = *nbIDs;

	strcpy(select,"distinct tag_number, functional_id, eqp_descr, commodity, comp_note, macro_name, original");
	sprintf(where,"prj_number = '%s' and system_name = '%s' and id_category = %d and tag_number != '' and tag_number is not NULL", PrjNumber, SystemName, CompCategory );
        vdb$RisSelect(  select = select,
                        table_name = "eqp_id_view",
			where = where,
                        numselect = nbSelect,
                        p_numrows = &count,
                        p_buffer = &buf );
	*nbIDs += count;

	if ( count > 0 )
           *p_sIDdesc = (struct id_desc *) realloc (*p_sIDdesc, *nbIDs * sizeof(struct id_desc));
	for(i =0,j=old_count; i < count; i++,j++ )
	{
		strcpy( (*p_sIDdesc)[j].tag_number, buf[i*nbSelect] );
		strcpy( (*p_sIDdesc)[j].functional_id, buf[i*nbSelect+1]);
		strcpy( (*p_sIDdesc)[j].descript, buf[i*nbSelect+2]);
		strcpy( (*p_sIDdesc)[j].commodity, buf[i*nbSelect+3]);
		strcpy( (*p_sIDdesc)[j].comp_note, buf[i*nbSelect+4]);
		strcpy( (*p_sIDdesc)[j].macro_name, buf[i*nbSelect+5]);
		(*p_sIDdesc)[j].original = atoi(buf[i*nbSelect+6]);
	}
	size = nbSelect * count;
	vdb$RisFreeBuffer ( buffer = buf, 
                            size = size );

/*
for ( i = 0; i < *nbIDs; i++ )
{
	printf("Tag number = %s\n", (*p_sIDdesc)[i].tag_number );
	printf("Function = %s\n", (*p_sIDdesc)[i].functional_id );
	printf("Descript = %s\n", (*p_sIDdesc)[i].descript );
}
*/
	return 1;
}

/************************************************************************/
/*									*/
/*	int VRGetIDs( PrjNumber,SystemName,CompCategory,nbIds,IdList ) 	*/
/*	char	*PrjNumber;		(I)  Project Number		*/
/*	char	*SystemName;		(I)  System name of Network	*/
/*	int	CompCategory;		(I)  Category for ID mgmnt	*/
/*	int	nbIds			(I)  Number of Ids asked.	*/
/* 	char	*IdList[VDS_LIST_OF_IDS];(I)  Proposed list of ID's	*/
/*									*/
/************************************************************************/

int	VDGetIDs( SystemName, CompCategory, nbIds, IdList )
char	*SystemName;
int	CompCategory;			/* Category may be a short */
int	nbIds;
int	IdList[];
{
	char	*table=VDS_PLACED_ID_TBL;
	char	*select="distinct ID_NUM";	/* query for ID_NUM */
	char	*order="ID_NUM";	/* query for ID_NUM */
	char	where[MAX_WHERE_SIZE];
	char	**UsedIds;
	char	PrjNumber[40], PrjRevision[40];
	int	PrjUnits;
	int	n_usedids, n_select;
	int	*numbarray, left, right, startval, index;
	int	i,ret_msg;

	if ( VDSverify_login() != PDM_S_SUCCESS )
	{
		ex$message(msgnumb = VD_E_PrUsNotLog );
		return 0;
	}
	if ( VDSverify_project() != OM_S_SUCCESS )
	{
		ex$message(msgnumb = VD_E_PrVdsPrj );
		return 0;
	}
	if(!VDGetProjectNumRev ( PrjNumber, PrjRevision, &PrjUnits ))
		return 0;

	/* query the database for the list of ID's placed */
	sprintf(where,"prj_number ='%s' and system_name ='%s' and category =%d and id_num > 0 ",
		 PrjNumber, SystemName, CompCategory );
	n_select=1;
        ret_msg =
                vdb$RisSelect(  select        =        select,
                                table_name    =        table,
                                where         =        where,
                                order         =        order,
                                group         =        NULL,
                                numselect     =        n_select,
                                p_numrows     =        &n_usedids,
                                p_buffer      =        &UsedIds );
        if(  ret_msg != 1) return 0;


	/* Fill up the IdList with the first 10 available ID's */
	/* The available ID's are from 0 - 99999 	       */

	if( n_usedids == 0 )   /* Nothing in the database */
	{
		for ( i=0; i < nbIds; i++ )
			IdList[i] = i+1;
	}
	else
	{
		int	j;

		numbarray = (int *) calloc ( n_usedids, sizeof (int) );

		for ( i=0; i < n_usedids; i++ )
			numbarray[i] = atoi(UsedIds[i]);

		left = 0; right = n_usedids-1; startval = 1;

		for ( i=0; i < nbIds; i++ )
		{
			IdList[i]=LocateAvailableID( left, right, startval, numbarray, &index );
			if(IdList[i] == -1 ) break;
			startval = IdList[i] + 1;
			left = index;
		}
		for ( j = i; j < nbIds; j++ )
			IdList[j] = atoi(UsedIds[right])+(j-i+1);

		vdb$RisFreeBuffer(   buffer  =    UsedIds,
                                     size    =    n_select * n_usedids );
		free(numbarray);
	}
	return 1;
}

int	VDGetAndLockID ( SystemName, CompCategory, IdNum )
char	*SystemName;
int	CompCategory;			/* Category may be a short */
int	*IdNum;
{
	int	nbIds=1;
	int	IdList;
	int	sts;

	/* Get only one ID */
	sts = VDGetIDs( SystemName, CompCategory, nbIds, &IdList );
	if( sts != 1 )
	   return 0;
	*IdNum = IdList;

	/* Lock the ID obtained */
	sts = VDLockSelectedID ( SystemName, CompCategory, IdList );
	if( sts != 1)
	   return 0;

	return 1;
}
