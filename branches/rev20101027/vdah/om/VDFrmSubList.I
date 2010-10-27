/* $Id: VDFrmSubList.I,v 1.4 2001/04/17 23:03:26 anand Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        $VDS/vdah/VDFrmSubList.I
 *
 * Description:
 *
 *	The file at the time of creation contains one function, viz.,
 *	VDfrm_fld_set_sub_list. This function empowers the user to type in 
 *	regular expressions in fields that have associative lists, to query
 *	for items populated in those associative lists.
 *
 *	Another VDS function viz., VD_matchRE is used to enable the user
 *	type in UNIX-like regular expressions (eg., a*b[1-3] to include all
 *	of the following: awerb2, anb3, etc).
 *
 *	One of the main objectives that this function achieved was avoiding
 *	use of any of the memory allocation functions.
 *
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDFrmSubList.I,v $
 *	Revision 1.4  2001/04/17 23:03:26  anand
 *	JTS TR MP 4485
 *	
 *	Revision 1.3  2001/01/11 16:34:30  art
 *	sp merge
 *	
 *	Revision 1.1  2001/01/11 16:20:58  art
 *	s merge
 *	
# Revision 1.1  2000/12/06  14:53:10  pinnacle
# ah
#
# Revision 1.2  2000/06/09  19:29:38  pinnacle
# Replaced: vds/vdah/VDFrmSubList.I for:  by aharihar for Service Pack
#
# Revision 1.1  2000/05/08  15:23:38  pinnacle
# Created: vds/vdah/VDFrmSubList.I by apazhani for Service Pack
#
# Revision 1.4  1998/09/01  17:27:12  pinnacle
# ah
#
# Revision 1.3  1998/07/21  14:39:48  pinnacle
# tr179801212
#
# Revision 1.2  1998/06/24  19:08:28  pinnacle
# tr179801131
#
# Revision 1.1  1998/05/22  20:00:10  pinnacle
# Created: vdah/VDFrmSubList.I by kddinov for vds
#
 *
 * History:
 *
 * MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * 06/12/98	law	TR179800042-scan from master-list
 * 07/21/98	ah	TR179801212 The case insensitive search ends up
 *			converting the results to upper case which is not
 *			wanted.
 * 09/01/98	ah	Merged VDfrmdef.h into VDfrm.h                   
 * 05/08/00	Alwin	Modified to blank out the field, when matches not found
 * 06/09/00	Anand	Allowed messages to be displayed in forms without
 *			message fields.
 ***************************************************************************/


class implementation Root;

/*
#define vdsDEBUG	1
*/

#include "VDfrm.h"
#include "VDfrmProto.h"

#include <ctype.h>

#include "v_dbgmacros.h"
#include "v_strngproto.h"	/* Prototype for VD_matchRE */

#define CHAR_LENGTH 256

/*-----------------------------------------------------------------------------
* PARAMETERS
*
* I: Form	fp 		- pointer to the form
*
* I: IGRint	GadgetLabel	- gadget label with associative list. 
*
* I: IGRint     MessageLabel    - message field, if <= 0 UI_status is used.
*
* I: char       *MasterList     - pointer to original sub-list array
*
* I: IGRint     mstrlstsiz      - row length of master array.
*
* I: IGRint     mstrlstcnt      - number of rows in master array.
*
* I: IGRint	*p_NewListCount - Output number of rows in sublist.
*
* I: IGRint     CaseFlag        - 1  case sensitive search,
*                                 otherwise case insensitive search.
*
* O: IGRint     *p_UniqueMatch  - 1 if exact match is found,
*                                 0 otherwise.
*
* O: IGRint     *item_index     - Row number of match in original list.
*
* O: IGRint     *p_NewListCount - New number of entries in the associated list.
*------------------------------
*
* RETURN status:
*
* 1 if OK
* even if problems.
*------------------------------
*
* Macro interface:
* vdfrm$SetSubList( ....) in VDfrm.h 
-----------------------------------------------------------------------------*/
IGRlong VDfrm_fld_set_sub_list(	Form		fp,
				IGRint		GadgetLabel,
				IGRint		MessageLabel,
                                char            *MasterList,
                                IGRint          mstrlstsiz,
                                IGRint          mstrlstcnt,
				IGRint		*p_NewListCount,
				IGRint		CaseFlag,
                                IGRint          *item_index,
				IGRint		*p_UniqueMatch	)
{
    IGRint	i, j, sf, 
		StringLen    = 0,
		NewListCount = 0,
		UniqueMatch  = 0; 

    IGRlong	mask = 0,sts = 1;

    char	SearchString[CHAR_LENGTH] = {""},
		MessageText[ CHAR_LENGTH] = {""},
    		ListItem[CHAR_LENGTH] = {""};

    IGRchar ListItemX[CHAR_LENGTH];
		
    SetProc(VDfrm_fld_set_sub_list); Begin

/* Insure valid output arguments */
    if( p_UniqueMatch )
	*p_UniqueMatch = 0;

/* Validate Input arguments */
    if( (GadgetLabel < 0) || (!fp) )
    { 
	strcpy( MessageText, " Error in input arguments"); 
	sts=VD_FRM_ERROR_OCCURRED;
	goto quit;
    }


/* Verify that it is an associative list */
    FIfld_get_attr( fp, GadgetLabel, 0, &mask);

    if( ! mask & ( FI_VERT_SCROLL | FI_ASSOCIATED_LIST | FI_POPUP_ASSO_LIST |
		   FI_VALIDATE_BY_LIST | FI_DISMISS_LIST_ON_SEL) )
    {
	strcpy( MessageText, " This field does not have an associative list!");
	sts=VD_FRM_NO_ASSOCIATIVE_LIST;
	goto quit;
    }

/* Check if it is empty */
    if( ! mstrlstcnt )
    {
	strcpy( MessageText," No items in the associative list!");
	sts=VD_FRM_ASSOCIATIVE_LIST_EMPTY;
	goto quit;
    }


/* Get the text from the field - this is the search string */

    FIg_get_text( fp, GadgetLabel, SearchString );
    __DBGpr_str(" SearchString",SearchString);

    StringLen = strlen( SearchString ) ;
    if ( StringLen <= 0 )
	goto quit;

    for( i=0; i < mstrlstcnt ; i=i+1 ) 
    {
	if( strcmp( SearchString, &MasterList[i*mstrlstsiz] ) == 0 )
	{
	    strcpy( MessageText, "Single match is found" );
	    __DBGpr_com(" Exact match - picked from list?");

	    UniqueMatch = 1;
	    NewListCount = mstrlstcnt;
	    if( item_index )
		*item_index = i;

	    /* Reset all original items back into the list */
	    FIfld_set_list_num_rows( fp, GadgetLabel, 0, mstrlstcnt);
	    for( j=0; j<mstrlstcnt ; j=j+1 ) 
	    {
		FIfld_set_list_text( fp, GadgetLabel, j, 0,
				     (IGRuchar*) &MasterList[j*mstrlstsiz],
				     (j==*item_index)?TRUE:FALSE );
	    }

	    goto quit;
	}
    }

/* If needed, convert to uppercase for making the search case-insensitive */
    if ( CaseFlag != 1 )
    {
       __DBGpr_com(" Case-insensitive search");
       for (i=0; i < StringLen; i++)
	   SearchString[i] = toupper(SearchString[i]);
    }

/*  Append a '*' at the end of the search string, if needed (for VD_matchRE).
 */
    if ( SearchString[ StringLen - 1 ] != '*' )
	strcat( SearchString, "*");

/*-----------------------
 * Main loop: search pattern SearchString for all items in the associative list.
 *----------------------*/

    for( i=0; i < mstrlstcnt ; i=i+1 ) 
    {
        strcpy(ListItem,&MasterList[i*mstrlstsiz]);
	__DBGpr_str(" ListItem", ListItem);

	/* ---------------------------------------------------
	 * TR179801212 Save in case it get changed by the
	 * case insensitive search
	 * ---------------------------------------------------*/
	strcpy(ListItemX,ListItem);
	
        /* convert to upper case if case insensitive search is wanted */
        if ( CaseFlag != 1 )
	{
	    j = 0;
	    while (ListItem[j])
	    {
		ListItem[j] = toupper(ListItem[j]);
		j++;
	    }
	}


/*------------------
*   Use function VD_matchRE implemented in VDregexp.C
*  (prototype in v_strngproto.h) for doing a "grep-like" search
*-----------------*/
	if( VD_matchRE( (const char *)SearchString, (const char *)ListItem ) )
	{
	    __DBGpr_com(" Match found!");
	    FIfld_set_list_text( fp, GadgetLabel, NewListCount, 0,
						(unsigned char*) ListItemX, 0);
	    NewListCount++;

	    /* Is this an exact match? */
	    StringLen = strlen( ListItem );
	    if( strncmp( ListItem, SearchString, StringLen ) == 0 )
	    {
		FIg_set_text( fp, GadgetLabel, (char *) ListItemX);
		UniqueMatch = 1;
		if( item_index )
		    *item_index = i;
	    }
	}
    }

/* Reset the number of items in the associative list */
    __DBGpr_int(" NewListCount",NewListCount);
    FIfld_set_list_num_rows( fp, GadgetLabel, 0, NewListCount);

/* single entry handling */
    if ( NewListCount == 1 )
    {
	strcpy( MessageText, "Single match is found" );

	FIfld_get_list_text( fp, GadgetLabel, 0, 0, CHAR_LENGTH,
					      (unsigned char *) ListItem, &sf);
	FIg_set_text( fp, GadgetLabel, ListItem); 

	/* Reset all original items back into the list */
	FIfld_set_list_num_rows( fp, GadgetLabel, 0, mstrlstcnt);
	for( i=0; i < mstrlstcnt ; i=i+1 ) 
	{
	    FIfld_set_list_text( fp, GadgetLabel, i, 0,
				 (unsigned char*) &MasterList[i*mstrlstsiz], 0);
	}
    }
    else if (NewListCount > 1) 
	strcpy( MessageText, "Select from the associative list");
    else      
    {
		/*strcpy( MessageText, "No matches found");*/
    	FIg_get_text( fp, GadgetLabel, SearchString );
	sprintf( MessageText, "No matches found for '%s'", SearchString );
	FIg_set_text( fp, GadgetLabel, "" );
    }

quit:
    __DBGpr_com( MessageText );

    if ( p_NewListCount )
	*p_NewListCount = NewListCount;

    if ( p_UniqueMatch )
	*p_UniqueMatch = UniqueMatch;

    if ( MessageLabel > 0 )
	FIg_set_text( fp, MessageLabel, MessageText); 
 /* Below else condition added by Anand */
    else
	UI_status( MessageText );

    End
    return (sts) ;
}

end implementation Root;

