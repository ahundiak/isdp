/* $Id: VDSmenuops.C,v 1.1.1.1 2001/01/04 21:08:18 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vddb/source / VDSmenuops.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSmenuops.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:18  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.2  1997/07/17  17:48:18  pinnacle
 * Fix for TR# 179701386 -- ap
 *
 * Revision 1.2  1997/01/30  23:59:10  pinnacle
 * ah CR179602053
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.8  1996/05/20  03:32:46  pinnacle
 * Replaced: vddb/source/VDSmenuops.C for:  by tlbriggs for vds.240
 *
 * Revision 1.6  1996/04/21  23:49:20  pinnacle
 * Replaced: vddb/source/*.C for:  by v240_int for vds.240
 *
 * Revision 1.5  1996/04/01  12:50:52  pinnacle
 * Replaced: vdris/imp/VdsRisTbl.C for:  by msbraju for vds.240
 *
 * Revision 1.4  1996/03/18  11:02:10  pinnacle
 * Replaced: smcomp/func/SMCmpFn.I for:  by ksundar for vds.240
 *
 * Revision 1.3  1996/02/20  12:00:18  pinnacle
 * Replaced: vddb/source/VDSmenuops.C for:  by msbraju for vds.240
 *
 * Revision 1.2  1995/12/13  19:37:28  pinnacle
 * Replaced: vddb/source/VDSmenuops.C for:  by hverstee for vds.240
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	04/15/96    tlb		Add VDS memory checking
 *				Add prototypes
 *				VdbGetCatalogs - zero byte allocation
 *	05/08/96     tlb  	Change prototype file name
 *				Remove VDBfreeuids_menu_oper
 *	05/09/96     tlb	Remove externs, add VDBblankfield
 *				Add new error handling routines
 *				VdbGetCatalogs - return status
 *      01/30/97     ah         Added get parts and projects routines
 *
 * -------------------------------------------------------------------*/

/* modification : changed this file from .c to .C for omcpp for compilation.
 * this was due to macros included from vdbmacros.h,hence changed .m also.
 */

#include <string.h>
#include <curses.h>
#include <stdlib.h>
#include <unistd.h>
#include "VDDbDef.h"
#include "VDBload.h"
#include "VDSdberrdef.h"
#include "VDSris_def.h"
#include "vdbmacros.h"
#include "VDmem.h"
#include "v_risproto.h"
#include "v_dbloadprot.h"

/*=============== Internal Functions =====================================*/ 
/* --------------------------------------------------------------------------
Doc :  VDBblankfield

  Desc : It checks if the given string is contains only space characters.
         
  Return values:
    1  -  string contains only blank charaters.
    0  -  string contains chars other than blanks.
----------------------------------------------------------------------------*/
static
int  VDBblankfield( char *str)
{
int   len, ii;

    len = strlen( str );
    for( ii=0; ii<len; ii++)
      if ( !isspace(str[ii]) ) 
         return 0;

    return 1;
}

/*=============== Public Functions =====================================*/ 
/* --------------------------------------------------------------------------
Doc :  VDBuser_menu_oper

  Desc : This function performs user data menu operations.

  Return values:
   VDB_PROCESS - continue the process
   VDB_EXIT    - exit the menu

  History:
   10-20-93   2.2   Raju  creation

---------------------------------------------------------------------------*/
long VDBuser_menu_oper (
 WINDOW **userwin,     /*  I - user window */
 int    maxlen,        /*  I - length of the input field */
 int    first_line,    /*  I - line no. of the first keyin field */
 int    first_col,     /*  I - column no. of the first col. of kyin fields */
 int    nostr,         /*  I - no. of keyin fields in the window */
 char    *outstrs[]    /*  O - strings keyed in by user */
)

{
int    ii;
long   sts;

   for ( ii=0; ii<4; ii++)
     strcpy( VDBmsgstrs[ii], "");

   VDB_DISP_PADED_MSG ( "Enter user data and press PROCESS" );

   sts = VDBmenu_input_oper(userwin, maxlen, first_line, first_col, nostr, 1, 1,
			   VDBmsgstrs,  outstrs);

   /* sts = 1 -> process; sts = 0 -> cancel */
   return sts;

}

/* --------------------------------------------------------------------------
Doc :  VDBmain_menu_oper

  Desc : This performs main menu operations.

  Return values:
   1 - always

---------------------------------------------------------------------------*/
long VDBmain_menu_oper (
 WINDOW **mainwin,     /* I - main windiw */
 int    maxlen,        /* I - max. length of any strings in the window */
 int    *selno         /* O - no. of the selected entry */
)

{
long   sts;


   strcpy(VDBmsgstrs[0],"Create, load, delete VDS support tables");
   strcpy(VDBmsgstrs[1],"VDS catalogs/parts operations");
   strcpy(VDBmsgstrs[2],"Administrative utilities");
   strcpy(VDBmsgstrs[3],"Exit");

   sts = VDBmenu_select_oper ( mainwin, maxlen, 4, VDBmsgstrs, selno );

   return 1;

}

/* --------------------------------------------------------------------------
Doc :  VDBtables_menu_oper

  Desc : This performs vds tables menu operations.

  Return values:
   1 - always

---------------------------------------------------------------------------*/
long VDBtables_menu_oper (
 WINDOW **tablewin,      /* I - tables windiw */
 int    maxlen,          /* I - max. length of any strings in the window */
 int    *selno           /* O - no. of the selected entry */
)

{
long   sts;


   strcpy(VDBmsgstrs[0],"Create VDS support table");
   strcpy(VDBmsgstrs[1],"Load VDS support table");
   strcpy(VDBmsgstrs[2],"Delete VDS support table");
   strcpy(VDBmsgstrs[3],"Exit");

   sts = VDBmenu_select_oper ( tablewin, maxlen, 4, VDBmsgstrs, selno );

   return 1;

}

/* --------------------------------------------------------------------------
Doc :  VDBcatalog_menu_oper

  Desc : This performs vds catalogs menu operations.

  Return values:
   1 - always

---------------------------------------------------------------------------*/
long VDBcatalog_menu_oper (
 WINDOW **catalogwin,     /* I - catalogs windiw */
 int    maxlen,           /* I - max. length of any strings in the window */
 int    *selno            /* O - no. of the selected entry */
)

{
long   sts;


   strcpy(VDBmsgstrs[0],"Create, delete catalogs and generate .f file");
   strcpy(VDBmsgstrs[1],"Add, delete parts and generate .p file");
   strcpy(VDBmsgstrs[2],"Exit");

   sts = VDBmenu_select_oper ( catalogwin, maxlen, 3, VDBmsgstrs, selno );
   return 1;

}

/* --------------------------------------------------------------------------
Doc :  VDBprod_menu_oper

  Desc : This performs products menu operations. One or more
         products can be selected.

  Return values:
   1 - always

---------------------------------------------------------------------------*/
long VDBprod_menu_oper (
 WINDOW **prodwin,     /* I - products windiw */
 int    maxlen,        /* I - max. length of any strings in the window */
 char   *prod_list[VDB_MAX_NO_PROD],
		       /* I - list of products */
 char   selflag[]      /* O - flags indicating selection of products
                              1 - selected, 0 - not selected           */
)

{
int    ii;
long   sts;
char   (*prod)[81];


   for ( ii=0; ii<4; ii++)
     strcpy( VDBmsgstrs[ii], "");

   prod = _MALLOC_ARR ( VDB_MAX_NO_PROD, char, 81 );
   _CheckAlloc(prod, "product menu", sts, FALSE, quit )

   for( ii=0; ii<VDB_MAX_NO_PROD; ii++)
    strcpy( prod[ii], prod_list[ii] );
   VDB_DISP_PADED_MSG ( "Select products and press PROCESS" );


   VDBhilite ( prodwin, 0, maxlen );
   wrefresh ( *prodwin );


   sts = VDBmenu_multi_select_oper ( prodwin, maxlen, VDB_FIRST_LINE,
	   VDB_FIRST_COL, VDB_MAX_NO_PROD, VDB_MAX_NO_PROD, 1, VDBmsgstrs,
	   prod, TRUE, selflag );

    _FREE(prod);
quit:
   return (sts);
}

/* --------------------------------------------------------------------------
Doc :  VDBpath_menu_oper

  Desc : This performs paths menu operations. User accepts the
         default paths for selected products or keys in new paths.

  Return values:
   VDB_PROCESS - user selected process
   VDB_EXIT    - user selected exit

---------------------------------------------------------------------------*/
long VDBpath_menu_oper (
 WINDOW **pathwin,      /* I - paths window */
 int    maxlen,         /* I - max. length of keyin field, ie, paths  */
 int    first_line,     /* I - line no. of the first keyin field */
 int    first_col,      /* I - column no. of the first col. of kyin fields */
 int    nostr,          /* I - no. paths in the menu */
 char    *path_list[]   /* O - keyed in paths */
)

{
int    ii;
long   sts;


   for ( ii=0; ii<4; ii++)
     strcpy( VDBmsgstrs[ii], "");

   VDB_DISP_PADED_MSG ( "Keyin paths and press PROCESS" );

menu_oper3:
   sts = VDBmenu_input_oper ( pathwin, maxlen, first_line, first_col, nostr, -1,
			     1, VDBmsgstrs, path_list );

   /* sts = 1 -> process; sts = 0 -> exit */
   if ( sts )
   { for ( ii=0; ii<nostr; ii++)
         if ( access ( path_list[ii], F_OK ) )
	 { sprintf( VDBtmps, "Invalid path name for product %d", ii+1);
           VDB_DISP_PADED_MSG ( VDBtmps );
           goto menu_oper3;
	 }
      return 1;
   }
   else
      return 0;
}

/* --------------------------------------------------------------------------
Doc :  VDBlist_menu_oper

  Desc : This displays the list of catalogs or parts in the
         paths and allows user to select one or more from the list.

  Return values:
   1 - user selected process.
   0 - user either selected exit or not selected any from the list.

---------------------------------------------------------------------------*/
long VDBlist_menu_oper (
 WINDOW **listwin,      /* I - window displaying list */
 int    maxlen,         /* I - max. length of any string in the list */
 int    first_line,     /*  I - line no. of the first keyin field */
 int    first_col,      /*  I - column no. of the first col. of kyin fields */
 int    nofampart,      /* I - no. of families or parts in the list */
 int    nostrdis,       /* I - no. strings dispalyed in the window  */
 char   fampartflag,    /* I - = VDB_FAM, catalog operation,
                               = VDB_PART, part operation */
 char   (*fam_part_list)[81],
                        /* I - list of families or parts */
 short	bSelectAll,	/* I - Enable/Disable SEL_ALL key.
			       1 => Enable,     0 => Disable */
 char   *listselflag    /* O - list of flags indicating selection */
)

{
int    ii;
long   sts;
char   selected;

   for ( ii=0; ii<4; ii++)
     strcpy( VDBmsgstrs[ii], "");

   switch(fampartflag) {
    case VDB_FAM:  strcpy(VDBtmps,"Select catalogs and press PROCESS"); break;
    case VDB_PART: strcpy(VDBtmps,"Select parts    and press PROCESS"); break;
    case VDB_PROJ: strcpy(VDBtmps,"Select project  and press PROCESS"); break;
    default:       strcpy(VDBtmps,"Do whatever you want!");
   }

   VDBpadstr( (char *) VDBtmps, 81, ' ' );
   mvwaddstr( VDBmsgwin, 0, 0, VDBtmps);
   wrefresh ( VDBmsgwin );

   sts = VDBmenu_multi_select_oper ( listwin, maxlen, first_line, first_col,
	      nofampart, nostrdis, 0, VDBmsgstrs, fam_part_list, bSelectAll,
	      listselflag );

   if ( sts == 0 ) goto wrapup1;

   selected = FALSE;
   for( ii=0; ii<nofampart; ii++)
     if ( listselflag[ii] )
     {  selected = TRUE;
        break;
     }
   if ( !selected ) goto wrapup1;

   return 1;

wrapup1:
   return 0;
}

/* --------------------------------------------------------------------------
Doc :  VDBcat2_menu_oper

  Desc : This gets additional input for catalog operations.
         from user. Additional input may be add, delete, generate
         family file . User selects one of the options. This
         is also used for additional input for part operations.

  Return values:
   1 - alwyas

Silly thing has number of options hardcoded.

---------------------------------------------------------------------------*/
long VDBcat2_menu_oper (
 WINDOW **catwin2,      /* I - window showing the entries  */
 int    maxlen,         /* I - max. length of any strings  */
 int    *selno          /* O - no. of the output string    */
)

{
int    ii;
long   sts;


   for ( ii=0; ii<5; ii++)
     strcpy( VDBmsgstrs[ii], "");

   sts = VDBmenu_select_oper ( catwin2, maxlen, 5, VDBmsgstrs, selno );

   return 1;

}

/* --------------------------------------------------------------------------
Doc :  VDBcatname_menu_oper

  Desc : This gets the catalog name. This is used by delete catalog,
         generate a family file and generate part file.

  Return values:
   1 - alwyas

---------------------------------------------------------------------------*/
long VDBcatname_menu_oper (
 WINDOW **catnamewin,     /* I - window for getting catalog name  */
 int    maxlen,           /* I - max. length of the keyin field   */
 int    first_line,       /* I - line no. of the first keyin field */
 int    first_col,        /* I - column no. of the first col. of kyin fields */
 int    nostr,             /*     */
 char    *catname[]        /*     */
)

{
int    ii;
long   sts;

   for ( ii=0; ii<4; ii++)
     strcpy( VDBmsgstrs[ii], "");

   VDB_DISP_PADED_MSG ( "Enter catalog name and press PROCESS" );

   sts = VDBmenu_input_oper(catnamewin, maxlen, first_line, first_col, nostr, -1,
			   1, VDBmsgstrs, catname);

#ifdef VDB_DEBUG
    VDSdebug( "Catalog Name : %s\n", catname[0] );
#endif
   /* sts = 1 -> process; sts = 0 -> cancel */
   return sts;

}

/* --------------------------------------------------------------------------
Doc :  VDBdelpart_menu_oper

  Desc : This performs delete parts operations.

  Return values:
  VDB_PROCESS - conitnue processing
  VDB_EXIT    - exit delete parts window
---------------------------------------------------------------------------*/
long VDBdelpart_menu_oper (
 WINDOW **delpartwin,
 int    maxlen,
 int    first_line,
 int    first_col,
 int    nostr,
 char    *catdata[]
)

{
int    ii;
long   sts;
char   yn;


   for ( ii=0; ii<4; ii++)
     strcpy( VDBmsgstrs[ii], "");

   VDB_DISP_PADED_MSG ( "Enter part data and press PROCESS" );

menu_oper:
   sts = VDBmenu_input_oper(delpartwin, maxlen, first_line, first_col, nostr, -1,
			   1, VDBmsgstrs, catdata);

   if ( sts == VDB_EXIT )
      goto cancel;

/* verify if the catalog exists */
   sts = VDSverify_catalog ( catdata[0] );
   if ( sts == VDS_E_FAILURE )
   {  VDBgetyesno ( "Can not verify catalog, Enter 'y' to continue : ", &yn );
      goto cancel;
   }
   if ( sts == VDS_E_CATALOG_NOT_FOUND )
   {  sprintf( VDBtmps, "Can not find catalog <%s>", catdata[0] );
      VDB_DISP_PADED_MSG ( VDBtmps );
      goto menu_oper;
   }

#ifdef  VDB_DEBUG
    VDSdebug(  "Delete part\n");
    VDSdebug(  "Catalog Name : [%s]\n", catdata[0] );
    VDSdebug(  "Part num : [%s]\n", catdata[1] );
    VDSdebug( "Part rev : [%s]\n", catdata[2] );
#endif

   return VDB_PROCESS;

cancel:
   return VDB_EXIT;

}

/* --------------------------------------------------------------------------
Doc :  VDButil_menu_oper

  Desc : This performs utilities menu operations. Selects one of the
         options from the window. Sets the next state.

  Return values:
   1 - always

---------------------------------------------------------------------------*/
long VDButil_menu_oper (
 WINDOW **utilwin,     /* I - utilities windiw */
 int    maxlen,        /* I - max. length of any strings in the window */
 int    *selno,        /* O - no. of the selected entry */
 int    *state         /* O - next state  */
)

{
long   sts;


   strcpy(VDBmsgstrs[0],"Update VDS database");
   strcpy(VDBmsgstrs[1],"Convert project units to metric or imperial ");
   /****** "freeze" - fix for TR# 179701386 *****************************
    ****** To find other places where this fix has been applied, search *
    ****** on keyword "freeze" in source code ***************************

   strcpy(VDBmsgstrs[2],"Create, modify, clean up Dynamic tables");

   ***************** end "freeze" ***************************************/

   strcpy(VDBmsgstrs[2],"Create and modify Dynamic tables");
   strcpy(VDBmsgstrs[3],"Create, modify, delete Regular tables");
   strcpy(VDBmsgstrs[4],"Exit");

/* strcpy(VDBmsgstrs[4],"");
   strcpy(VDBmsgstrs[5],"Exit");

   sts = VDBmenu_select_oper ( utilwin, maxlen, 6, VDBmsgstrs, selno ); */

   sts = VDBmenu_select_oper ( utilwin, maxlen, 5, VDBmsgstrs, selno );

   if ( *selno == 0 )
   {  sts = VDBupdateVdsDbase();
      if ( sts )
        *state = VDB_UTILITIES_MENU;
      else
        *state = VDB_MAIN_EXIT;
   }
   else if ( *selno == 1 )
   {  *state = VDB_CONVERT_UNITS_MENU;
   }
   else if ( *selno == 2 )
   {  *state = VDB_DYN_TBL_MENU;
   }
   else if ( *selno == 3 )
   {  *state = VDB_REG_TBL_MENU;
   }
/* else if ( *selno == 4 )
   {  *state = VDB_FREE_UIDS;
   } */
   else
   {  VDB_DELETE_WIN ( *utilwin );
      *state = VDB_MAIN_MENU;
   }

   return 1;

}


/* --------------------------------------------------------------------------
Doc :  VDBdyntbl_menu_oper

  Desc : This performs dynamic table operations. Sets the next state.

  Return values:
   1 - always

---------------------------------------------------------------------------*/
long VDBdyntbl_menu_oper (
 WINDOW **dyntblwin,   /* I - utilities windiw */
 int    maxlen,        /* I - max. length of any strings in the window */
 int    *selno,        /* O - no. of the selected entry */
 int    *state         /* O - next state  */
)

{
long   sts;


   strcpy(VDBmsgstrs[0],"Create dynamic table");
   strcpy(VDBmsgstrs[1],"Modify dynamic table");
   /* "freeze" 
   strcpy(VDBmsgstrs[2],"Cleanup dynamic table"); 
   strcpy(VDBmsgstrs[3],"Exit");
   */
   strcpy(VDBmsgstrs[2],"Exit");

   /* "freeze" 
   sts = VDBmenu_select_oper ( dyntblwin, maxlen, 4, VDBmsgstrs, selno );
   */
   sts = VDBmenu_select_oper ( dyntblwin, maxlen, 3, VDBmsgstrs, selno );

   if ( *selno == 0 )
       *state = VDB_CREATE_DYN_TBL;
   else if ( *selno == 1 )
       *state = VDB_MODIFY_DYN_TBL;
   /* "freeze" 
   else if ( *selno == 2 )
       *state = VDB_CLEANUP_DYN_TBL;
   */
   else
   {    *state = VDB_UTILITIES_MENU;
        VDB_DELETE_WIN ( *dyntblwin );
   }
   return 1;

}

/* --------------------------------------------------------------------------
Doc :  VDBvalidateDatatype

  Desc : It validates a given string for ris datatype. The valid datatypes
         are smallint, real, double, integer, timestamp, char(n).

  return values
  VDB_VALID_DATATYPE.
  VDB_INVALID_DATATYPE.
----------------------------------------------------------------------------*/
long  VDBvalidateDatatype(
char *str
)
{
int    ii, width;
char   datastr[81];


#ifdef VDB_DEBUG
   VDSdebug( "validate datatype , string = [%s]\n", str );
#endif

   strcpy( datastr, str );
   VDBdelTrailSpaces( datastr );
   if ( strcmp( datastr, "smallint") && strcmp( datastr, "real" )
        && strcmp( datastr, "double" ) && strcmp( datastr, "integer" )
        && strcmp( datastr, "timestamp" ) && strncmp( datastr, "char(", 5 ) )
      return VDB_INVALID_DATATYPE;

   if ( !strncmp( datastr, "char(", 5) )
   {  for(ii=5; ii< strlen(datastr); ii++)
        if ( datastr[ii] >= '0' && datastr[ii] <= '9' )
           VDBtmps[ii-5] = datastr[ii];
        else
           break;
      VDBtmps[ii-5] = '\0';
      if( datastr[ii] != ')' )
        return VDB_INVALID_DATATYPE;

      width = atoi( VDBtmps );
      if( width <= 0 || width >= 256 )
        return VDB_INVALID_DATATYPE;
   }

   return VDB_VALID_DATATYPE;
}

/* --------------------------------------------------------------------------
Doc :  VDBvalidateDatavalue

  Desc : This validates data value in a record.

  Return vlaues:
  VDB_VALID_DATAVALUE.
  VDB_INVALID_DATAVALUE.
----------------------------------------------------------------------------*/
long  VDBvalidateDatavalue( struct   VDBtable  record)
{
int     type;
char    valstr[81];
char    *endp = NULL;
long    intvalue;
double  realvalue;

#ifdef VDB_DEBUG
    VDSdebug( "validate datavalue , data type=[%s], data value=[%s]\n",
			record.dtype, record.dval );
#endif


   type = atoi( record.dtype );
   strcpy( valstr, record.dval );
   /*VDBdelTrailSpaces( valstr );*/
   VdsDelTrailBlanks( valstr );
   if ( !strcmp( valstr, "" ) )  goto error;

   switch ( type )
   {
        case INT:
        case SMALLINT:
		intvalue = strtol ( valstr, &endp, 10 );
		if ( endp[0] != '\0' )  goto error;
		break;

        case REAL:
        case DOUBLE:
		realvalue = strtod ( valstr, &endp );
		if ( endp[0] != '\0' )  goto error;
		break;

        case CHAR:
        	/* if string is not null, it is valid */
        	break;
   }

   return VDB_VALID_DATAVALUE;

error:
   return VDB_INVALID_DATAVALUE;

}

/* --------------------------------------------------------------------------
Doc :  VDBvalidateAttribData

  Desc : Validates table data that is keyed in by the user.

  Return values:
   1 - valid data
   0 - invalid data
---------------------------------------------------------------------------*/
long  VDBvalidateAttribData(
 int	*norecs,		/* i - no. of records in the list 'recs' */
 struct VDBtable  **recs,	/* i - list of records to be validated   */
 int    startrec,		/* i - record no. to start validation from
 				       ( Needed because, when modifying table
 				         by adding attributes abd types, the old
 				         records need no be checked ) */
 char   DtypeorValFlg,		/* i = VDB_DTYPE, datatype in records is validated
 				     = VDB_DVAL, data value is validated */
 int    *filled_norecs		/* o - no. of records that are actually filled by
 					user. ( *norecs represent memory allocated
 					for recs which might not have been totally filled) */

)

{

int	ii, value;
char	attrib[VDB_MAX_ATTRIB_LEN];
long	sts;


/* find the first blank field */
   for(ii=startrec; ii<*norecs; ii++)
   {   if ( VDBblankfield((char *)(*recs)[ii].attrib) ) break;
       if ( DtypeorValFlg == VDB_DTYPE )
       {  if ( VDBblankfield((char *)(*recs)[ii].dtype) )
          { sprintf( VDBtmps, "Blank datafield in row %d", ii+1);
            VDB_DISP_PADED_MSG( VDBtmps );
            goto invalid_data;
          }
       }
       else  /* data value */
       {  if ( VDBblankfield((char *)(*recs)[ii].dval) )
          { /*sprintf( VDBtmps, "Data not found in row %d", ii+1);*/
	    value = atoi( (char *)(*recs)[ii].dtype );
	    switch( value )
	    {
	      case CHAR:
	      case DATE:
	       *(char *)(*recs)[ii].dval = ' ';
	       break;

	      case NUMERIC:
	      case INT:
	      case SMALLINT:
	       sprintf( (char *)(*recs)[ii].dval, "%d", 0 );
	       break;

	      case REAL:
	      case DOUBLE:
	       sprintf( (char *)(*recs)[ii].dval, "%f", 0.0 );
	       break;

	      default:
	       sprintf( VDBtmps, "Data not found in row %d", ii+1);
               VDB_DISP_PADED_MSG( VDBtmps );
               goto invalid_data;
	    }
            /*VDB_DISP_PADED_MSG( VDBtmps );
            goto invalid_data;*/
          }
       }
   }

   *filled_norecs = ii;
   if ( *filled_norecs == *norecs ) goto validate_data;  /* no blanks */

/* check if datafield in next row is filled */
   if ( DtypeorValFlg == VDB_DTYPE )
      if ( ! VDBblankfield((char *)(*recs)[*filled_norecs].dtype ) )
      {	sprintf( VDBtmps, "Non-blank field in row %d", *filled_norecs );
        VDB_DISP_PADED_MSG( VDBtmps );
        goto invalid_data;
      }
   else  /* check data value */
      if ( ! VDBblankfield((char *)(*recs)[*filled_norecs].dval ) )
      { sprintf( VDBtmps, "Non-blank field in row %d", *filled_norecs );
        VDB_DISP_PADED_MSG( VDBtmps );
        goto invalid_data;
      }

/* check if there are any more fiiled fields */
   for(ii= *filled_norecs+1; ii<*norecs; ii++)
   {
     if( ! VDBblankfield( (char *)(*recs)[ii].attrib ) ||
         ! VDBblankfield( (char *)(*recs)[ii].dtype ) )
     {  sprintf( VDBtmps, "Non-blank field in row %d",ii+1 );
        VDB_DISP_PADED_MSG( VDBtmps );
        goto invalid_data;
     }
   }


validate_data:
/* check if any keywords are present in attributes */
  for( ii = startrec; ii < *filled_norecs; ii++ )
  {
     strcpy( attrib, (*recs)[ii].attrib );
     VDBdelTrailSpaces ( (char *) attrib );
     sts = VDSdbcheck_keyword ( (char *) attrib );
     if ( sts == KEYWORD_FOUND )
     {  sprintf( VDBtmps, "RIS keyword in row %d", ii+1);
        VDB_DISP_PADED_MSG( VDBtmps );
        goto invalid_data;
     }
  }

/* validate datatypes */
   if ( DtypeorValFlg == VDB_DTYPE )
   {  for(ii=startrec; ii<*filled_norecs; ii++ )
      { sts = VDBvalidateDatatype( (char *) (*recs)[ii].dtype );
        if ( sts == VDB_INVALID_DATATYPE )
        {  sprintf( VDBtmps, "Invalid datatype in row %d", ii+1);
           VDB_DISP_PADED_MSG( VDBtmps );
           goto invalid_data;
        }
      }
   }
   else   /* datavalue */
   {  for(ii=startrec; ii<*filled_norecs; ii++ )
      { sts = VDBvalidateDatavalue( (*recs)[ii] );
        if ( sts == VDB_INVALID_DATAVALUE )
        {  sprintf( VDBtmps, "Invalid datavalue in row %d", ii+1);
           VDB_DISP_PADED_MSG( VDBtmps );
           goto invalid_data;
        }
      }
   }

   return 1;

invalid_data:
   return 0;

}

/* --------------------------------------------------------------------------
Doc :  VDBcreatdyntbl_menu_oper

  Desc : This performs create dynamic operations.

  Return values:
  VDB_PROCESS - continue processing.
  VDB_EXIT -    exit.
---------------------------------------------------------------------------*/
long VDBcreatdyntbl_menu_oper (
 WINDOW *dyntblwin,     /* i - create dyn. table window*/
 int    maxlen1,	/* i - max. length of any of attributes */
 int    maxlen2,        /* i - max. length of any of data type strings */
 int    norowsdisp,     /* i - no. of rows displayed in the table window */
 int    *norecs,        /* i - no. of records in the list */
 struct VDBtable **recs /* i - list of records */
)

{
long   sts;
int    ii, tmp_norecs, filled_norecs;
char   tbltype;


   for ( ii=0; ii<8; ii++ )
      strcpy( VDBmsgstrs[ii], "" );

   VDB_DISP_PADED_MSG( "Enter data and press PROCESS" );

   tbltype = VDB_DTYPE;

   for( ii=0; ii<*norecs; ii++)
   { VDBpadstr( (*recs)[ii].attrib, VDB_MAX_ATTRIB_LEN, ' ' );
     VDBpadstr( (*recs)[ii].dtype, VDB_MAX_DTYPE_LEN, ' ' );
   }

attrib_win:
   sts = VDBattrib_win_oper ( dyntblwin, maxlen1, maxlen2, VDB_FIRST_LINE,
			     VDB_FIRST_COL, norowsdisp,
			     VDB_NONEDITABLE,  100000, -1, 10000, -1,
			     norecs, recs, tbltype );

   if ( sts == VDB_EXIT )  /* user selected exit */
        goto cancel;

/* post-processing
 */
   tmp_norecs = *norecs;

/* remove leading blanks and pad blanks at end of string */
   for(ii=0; ii<*norecs; ii++)
   {  VDBdelLeadSpaces ( (char *) (*recs)[ii].attrib );
      VDBpadstr( (char *)(*recs)[ii].attrib, maxlen1+1, ' ');
      VDBdelLeadSpaces ( (char *) (*recs)[ii].dtype );
      VDBpadstr( (char *)(*recs)[ii].dtype, maxlen2+1, ' ');
   }

   sts = VDBvalidateAttribData( norecs, recs , 0, VDB_DTYPE, &filled_norecs );
   if ( sts == 0 )  /* invalid data */
   {  *norecs = tmp_norecs;
      goto attrib_win;
   }

   *norecs = filled_norecs;
   return VDB_PROCESS;

cancel:

   return VDB_EXIT;

}

/* --------------------------------------------------------------------------
Doc :  VDBmodiftbl_menu_oper

  Desc : This performs modify table operations. (for both dynamic and regular
	 tables ).

  Return values:
  VDB_PROCESS - continue processing
  VDB_EXIT - exit
---------------------------------------------------------------------------*/
long VDBmodiftbl_menu_oper (
 WINDOW *modiftblwin,        /* i - modif. table window*/
 int    maxlen1,             /* i - max. length of any of attribute strings */
 int    maxlen2,	     /* i - max. length of any of datatype strings */
 int    norowsdisp,	     /* i - no. of rows of attributes to be displayed in window */
 char   *tablename,	     /* i - name of the table */
 int    *norecs,	     /* i/o - no. of records in the list 'recs' */
 struct VDBtable **recs      /* i/o - list of records */
)

{
long   sts;
int    ii, tmp_norecs, number, oldnorecs, filled_norecs;
char   tbltype, **oldattribs, **olddatatype;

   sts=
   vdb$RetrieveAttributes (     table_name   =    tablename,
                                p_num        =    &oldnorecs,
                                p_attr       =    &oldattribs,
                                p_type       =    &olddatatype );

   if ( sts != 1 )  /* not success  */
   {
     VDSdebug( "Could not get the attributes from table <%s>\n", tablename );
     VDBerrstat = 1;
     goto cancel;
   }

   for ( ii=0; ii<8; ii++ )
      strcpy( VDBmsgstrs[ii], "" );

   VDB_DISP_PADED_MSG( "Enter data and press PROCESS" );

   tbltype = VDB_DTYPE;
   if ( oldnorecs > *norecs )
   { *recs = _REALLOC (*recs, oldnorecs+30, struct VDBtable);
     _CheckAlloc( *recs, "record list", sts, VDS_E_ALLOC_MEMORY, cancel )

     for(ii=*norecs; ii<oldnorecs+30; ii++)
     {  (*recs)[ii].attrib[0] = '\0';
        (*recs)[ii].dtype[0] = '\0';
     }
     *norecs = oldnorecs+30;
   }

   /* convert datatypes to strings */
   for( ii=0; ii<oldnorecs; ii++)
   {    number = atoi( olddatatype[ii] );
        sts = VdsConvertDatatype( number, olddatatype[ii] );
   }

   for ( ii=0; ii<oldnorecs; ii++)
   {  strcpy( (*recs)[ii].attrib, oldattribs[ii] );
      strcpy( (*recs)[ii].dtype,  olddatatype[ii] );
   }

   /* free memory */
   for ( ii=0; ii<oldnorecs; ii++)
   {
	_FREE (oldattribs[ii] );
        _FREE (olddatatype[ii]);
   }
   _FREE ( oldattribs );
   _FREE ( olddatatype );

   /* pad the strings with blanks */
   for( ii=0; ii<*norecs; ii++)
   { VDBpadstr( (*recs)[ii].attrib, VDB_MAX_ATTRIB_LEN, ' ' );
     VDBpadstr( (*recs)[ii].dtype, VDB_MAX_DTYPE_LEN, ' ' );
   }

attrib_win:
   sts = VDBattrib_win_oper ( modiftblwin, maxlen1, maxlen2, VDB_FIRST_LINE,
			     VDB_FIRST_COL, norowsdisp,
			     VDB_NONEDITABLE,  0, oldnorecs-1, 0, 1,
			     norecs, recs, tbltype );

   if ( sts == VDB_EXIT ) /* user selected cancel */
        goto cancel;

/* post-processing
 */
   tmp_norecs = *norecs;

/* remove leading blanks and pad blanks at end of string */
   for(ii=0; ii<*norecs; ii++)
   {  VDBdelLeadSpaces ( (char *) (*recs)[ii].attrib );
      VDBpadstr( (char *)(*recs)[ii].attrib, maxlen1+1, ' ');
      VDBdelLeadSpaces ( (char *) (*recs)[ii].dtype );
      VDBpadstr( (char *)(*recs)[ii].dtype, maxlen2+1, ' ');
   }

   sts = VDBvalidateAttribData( norecs, recs , oldnorecs, VDB_DTYPE,
					&filled_norecs );
   if ( sts == 0 )
   {  *norecs = tmp_norecs;
      goto attrib_win;
   }

   if ( filled_norecs > oldnorecs )
   for ( ii=0; ii<(filled_norecs-oldnorecs); ii++)
   {  strcpy( (*recs)[ii].attrib, (*recs)[ii+oldnorecs].attrib );
      strcpy( (*recs)[ii].dtype, (*recs)[ii+oldnorecs].dtype );
   }
   *norecs = filled_norecs - oldnorecs;

   return VDB_PROCESS;

cancel:
   return VDB_EXIT;

}

/*--------------------------------------------------------------------------------
  Doc : VDBcvrt_menu_oper

  Description: This performs menu operations for setting project units.

  return values:
  VDB_PROCESS : continue processing
  VDB_EXIT    : exit
--------------------------------------------------------------------------------*/
long VDBcvrt_menu_oper (
 WINDOW **cvrtunitswin, /* I - convert units window */
 int    maxlen,         /* I - max. length of any of the keyin fields  */
 int    first_line,     /* I - line no. of the first keyin field */
 int    first_col,      /* I - column no. of the first col. of keyin fields */
 int    nostr,          /* I - no. of fields in the window */
 char    *outstrs[]     /* O - keyed in strings */
)

{
int    ii, len;
long   sts;
char   c1;


   for ( ii=0; ii<4; ii++)
     strcpy( VDBmsgstrs[ii], "");

   VDB_DISP_PADED_MSG ( "Keyin data and press PROCESS" );

menu_oper:
   sts = VDBmenu_input_oper ( cvrtunitswin, maxlen, first_line, first_col, nostr,
			     -1, 1, VDBmsgstrs, outstrs );

   if ( sts == VDB_PROCESS )
   {  len = strlen ( outstrs[2] );
      for ( ii=0; ii<len; ii++)
      { c1 = toupper ( outstrs[2][ii] );
        outstrs[2][ii] = c1;
      }
      if ( strcmp( outstrs[2], "METRIC") &&
	       strcmp( outstrs[2], "IMPERIAL" ) )
      { VDB_DISP_PADED_MSG( "Units should be either 'METRIC' or 'IMPERIAL'" );
        goto menu_oper;
      }
      return VDB_PROCESS;
   }
   else
      return VDB_EXIT;
}


/* --------------------------------------------------------------------------
Doc :  VDBregtbl_menu_oper

  Desc : This performs operations of regular tables. Sets the next state.

  Return values:
   1 - always

---------------------------------------------------------------------------*/
long VDBregtbl_menu_oper (
 WINDOW **regtblwin,   /* I - regular table window */
 int    maxlen,        /* I - max. length of any strings in the window */
 int    *selno,        /* O - no. of the selected entry */
 int    *state         /* O - next state  */
)

{
long   sts;

   strcpy(VDBmsgstrs[0],"Create regular table");
   strcpy(VDBmsgstrs[1],"Modify regular table");
   strcpy(VDBmsgstrs[2],"Delete data from table");
   strcpy(VDBmsgstrs[3],"");
   strcpy(VDBmsgstrs[4],"Add data to table");
   strcpy(VDBmsgstrs[5],"Exit");

   sts = VDBmenu_select_oper ( regtblwin, maxlen, 6, VDBmsgstrs, selno );

   if ( *selno == 0 )
       *state = VDB_CREATE_REG_TBL;
   else if ( *selno == 1 )
       *state = VDB_MODIFY_REG_TBL;
   else if ( *selno == 2 )
       *state = VDB_DELETE_DATA;
   else if ( *selno == 3 )
       *state = VDB_DROP_TABLE;
   else if ( *selno == 4 )
       *state = VDB_ADD_DATA;
   else
   {    *state = VDB_UTILITIES_MENU;
        VDB_DELETE_WIN ( *regtblwin );
   }
   return 1;

}

/* --------------------------------------------------------------------------
Doc :  VDBcreatregtbl_menu_oper

  Desc : Performs create regular table operataions.

  Return values:
  VDB_PROCESS : continue processing
  VDB_EXIT    : exit
---------------------------------------------------------------------------*/
long VDBcreatregtbl_menu_oper (
 WINDOW *regtblwin,     /* i - create regular table window*/
 int    maxlen1,        /* i - max. length of any attribute in the window */
 int    maxlen2,	/* i - max. length of any datatype string in window */
 int    norowsdisp,     /* i - no. of rows displayed in the window */
 int    *norecs,	/* i - no. of records in the list 'recs' */
 struct VDBtable **recs /* i - list of records */
)

{
long   sts;
int    ii, tmp_norecs, filled_norecs;
char   tbltype;

   for ( ii=0; ii<8; ii++ )
      strcpy( VDBmsgstrs[ii], "" );

   VDB_DISP_PADED_MSG( "Enter data and press PROCESS" );

   tbltype = VDB_DTYPE;
   for( ii=0; ii<*norecs; ii++)
   { VDBpadstr( (*recs)[ii].attrib, VDB_MAX_ATTRIB_LEN, ' ' );
     VDBpadstr( (*recs)[ii].dtype, VDB_MAX_DTYPE_LEN, ' ' );
   }

attrib_win:
   sts = VDBattrib_win_oper ( regtblwin, maxlen1, maxlen2, VDB_FIRST_LINE,
			     VDB_FIRST_COL, norowsdisp,
			     VDB_NONEDITABLE,  0, -1, 0, -1,
			     norecs, recs, tbltype );

   if ( sts == VDB_EXIT )  /* user selected exit */
        goto cancel;

/* post-processing
 */
   tmp_norecs = *norecs;

/* remove leading blanks and pad blanks at end of string */
   for(ii=0; ii<*norecs; ii++)
   {  VDBdelLeadSpaces ( (char *) (*recs)[ii].attrib );
      VDBpadstr( (char *)(*recs)[ii].attrib, maxlen1+1, ' ');
      VDBdelLeadSpaces ( (char *) (*recs)[ii].dtype );
      VDBpadstr( (char *)(*recs)[ii].dtype, maxlen2+1, ' ');
   }

   sts = VDBvalidateAttribData( norecs, recs , 0, VDB_DTYPE, &filled_norecs );
   if ( sts == 0 )  /* invalid data */
   {  *norecs = tmp_norecs;
      goto attrib_win;
   }

   *norecs = filled_norecs;
   return VDB_PROCESS;

cancel:

   return VDB_EXIT;

}

/*------------------------------------------------------------------------------
  Doc : VDBgetCatalogName

  Description : This gets the catalog name. Used by delete catalog, generate .f file
		generate .p file operations.

  return values :
  VDB_PROCESS : continue process
  VDB_EXIT : exit
---------------------------------------------------------------------------------*/
long  VDBgetCatalogName(
 char  NeworOldCat,		/* i = VDB_NEW_CATALOG, catalog should not exist,
				     = VDB_OLD_CATALOG, catalog should exist */
 char  catname[]		/* o - name of catalog keyed in by user */
)

{
long       sts;
WINDOW     *catwin = NULL;
int        maxlen1, maxlen2, ii;
char       *outstrs[1], yn;

   maxlen1 = 0;
   maxlen2 = VDB_MAX_CATALOG_LEN-1;

   sts = VDBmake_input_win( &catwin, 11, 2, &maxlen1, &maxlen2, 3,
			   "", "Catalog", "");

   for ( ii=0; ii<8; ii++)
     strcpy( VDBmsgstrs[ii], "");

   outstrs[0] = catname;

   VDB_DISP_PADED_MSG( "Enter name of catalog and press PROCESS" );

menu_oper:
   sts = VDBmenu_input_oper( &catwin, maxlen2, VDB_FIRST_LINE,
               VDB_FIRST_COL+maxlen1+VDB_GAP, 1, -1, 1, VDBmsgstrs, outstrs );

   if ( sts == VDB_EXIT )
   {   VDB_DELETE_WIN ( catwin );
       goto cancel;
   }

   sts = VDSverify_catalog ( catname );
   if ( sts == VDS_E_FAILURE )
   {  VDBgetyesno ( "Can not verify catalog, Enter 'y' to continue : ", &yn );
      goto cancel;
   }
   if ( NeworOldCat == VDB_NEW_CATALOG && sts == VDS_E_CATALOG_EXISTS )
   {  sprintf( VDBtmps, "Catalog <%s> already exists", catname );
      VDB_DISP_PADED_MSG( VDBtmps );
      goto menu_oper;
   }
   if ( NeworOldCat == VDB_OLD_CATALOG && sts == VDS_E_CATALOG_NOT_FOUND )
   {  sprintf( VDBtmps, "Can not find catalog <%s>", catname );
      VDB_DISP_PADED_MSG( VDBtmps );
      goto menu_oper;
   }

#ifdef VDB_DEBUG
if ( sts == VDB_PROCESS )
  VDSdebug( "VDBgetCatalogName \n\tcatalog_name = %s\n", catname );
#endif

   VDB_DELETE_WIN ( catwin );

   return VDB_PROCESS;

cancel:
   return VDB_EXIT;

}
/*---------------------------------------------------------------------------
 VdbGetCatalogs:
 Retrieves the names of existing catalogs from "nfmcatalogs".
 ----------------------------------------------------------------------------*/

 VdbGetCatalogs( CatList, NumbCat )
 char (**CatList)[81];
 int  *NumbCat;
 {
   int   VDSstatus, ii;
   int   cols = 0, rows = 0;
   char  **result;
   char  query[200];

   *NumbCat = 0;
   *CatList = NULL;

   sprintf( query,
   "select n_catalogname from nfmcatalogs where n_type='P' order by n_catalogname" );

   VDSstatus = VDSsql_query( query, &cols, &rows, &result );
   if( !VDSstatus ) {
	VDSstatus = VDS_E_FAILURE;
	goto wrapup;
	}
   else
	VDSstatus = VDS_S_SUCCESS;

   if ( !rows )
	goto wrapup;

   _FREE(*CatList );
   *CatList = _MALLOC_ARR  (rows, char, 81);
    _CheckAlloc(*CatList, "catalog list", VDSstatus, VDS_E_ALLOC_MEMORY, 
								wrapup )
    for( ii=0; ii < rows; ++ii )
     strcpy( (*CatList)[ii], result[ii] );

wrapup:
   *NumbCat = rows;

   vdb$RisFreeBuffer (  buffer   =       result,
                        size     =       rows*cols );
   return (VDSstatus);
 }

/*---------------------------------------------------------------------------
 VdbGetParts:
 Retrieves the names of existing parts from the catalog.
 ----------------------------------------------------------------------------*/

int VdbGetParts( CatName, PartList, NumbPart )
 char* CatName;
 char (**PartList)[81];
 int  *NumbPart;
 {
   int   VDSstatus, ii;
   int   cols = 0, rows = 0;
   char  **result;
   char  query[200];

   *NumbPart = 0;
   *PartList = NULL;


   sprintf( query,
   "select n_itemname,n_itemrev from %s order by n_itemname,n_itemrev" ,
   CatName);
/*
   printf("Query: '%s'\n",query);
   fflush(stdout);
*/
   VDSstatus = VDSsql_query( query, &cols, &rows, &result );
   if( !VDSstatus ) {
	VDSstatus = VDS_E_FAILURE;
	goto wrapup;
	}
   else
	VDSstatus = VDS_S_SUCCESS;

   if ( !rows )
	goto wrapup;

   *PartList = _MALLOC_ARR  (rows, char, 81);
    _CheckAlloc(*PartList, "part list", VDSstatus, VDS_E_ALLOC_MEMORY, wrapup);
							
    for( ii=0; ii < rows; ii++ ) {
     sprintf((*PartList)[ii],"%s %s",result[(2*ii)+1],result[(2*ii)]);
    }
    
wrapup:
   *NumbPart = rows;

   vdb$RisFreeBuffer (  buffer   =       result,
                        size     =       rows*cols );
   return (VDSstatus);
 }
/*---------------------------------------------------------------------------
 VdbGetProjs:
 Retrieves the names of existing projects in enviroment.
 ----------------------------------------------------------------------------*/

int VdbGetProjs( ProjList, NumbProj )
 char (**ProjList)[81];
 int  *NumbProj;
 {
   int   VDSstatus, ii,iii;
   int   cols = 0, rows = 0;
   char  **result;
   char  query[200];
   char  units[32];

   *NumbProj = 0;
   *ProjList = NULL;

   sprintf( query,
    "select prj_no,prj_number,prj_version,prj_units_set from vds_project");

   VDSstatus = VDSsql_query( query, &cols, &rows, &result );
   if( !VDSstatus ) {
	VDSstatus = VDS_E_FAILURE;
	goto wrapup;
	}
   else
	VDSstatus = VDS_S_SUCCESS;
    
   if ( !rows )
	goto wrapup;

   *ProjList = _MALLOC_ARR  (rows, char, 81);
    _CheckAlloc(*ProjList, "proj list", VDSstatus, VDS_E_ALLOC_MEMORY, wrapup);
							
    for( ii=0; ii < rows; ii++ ) {
     iii = 4*ii;
     strcpy(units,"UNKNOWN");
     if (!strcmp(result[iii+3],"1" )) strcpy(units,"IMPERIAL");
     if (!strcmp(result[iii+3],"20")) strcpy(units,"METRIC"  );
    
     sprintf((*ProjList)[ii],"%s %s %s",
      result[iii+2],
      result[iii+1],units);
    }
    
wrapup:
   *NumbProj = rows;

   vdb$RisFreeBuffer (  buffer   =       result,
                        size     =       rows*cols );
   return (VDSstatus);
 }

/*----------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------
  Doc : VDBcreatTableOption

  Description : This gets name of the default template file for creating
                dynamic table and reads the contents of the file.

  return values :
  VDB_PROCESS : continue process
  VDB_EXIT : exit
 ----------------------------------------------------------------------------*/

long  VDBcreatTableOption(
 int   *norecs,			/* i/o - no. of records in the list recs */
 struct VDBtable  **recs	/* i/o - list of records */
)

{
long       sts;
WINDOW     *filewin = NULL;

int        maxlen1, maxlen2, ii;

char       *outstrs[1], deffile[VDB_MAX_FILE_LEN],
           filename[VDB_MAX_FILE_LEN], attrib[VDB_MAX_ATTRIB_LEN],
           datatype[VDB_MAX_DTYPE_LEN];

FILE       *fp = NULL;


       /*  read from ascii file */
       maxlen1 = 0;
       maxlen2 = VDB_MAX_FILE_LEN-1;

       sprintf( deffile, "%s/config/VDSDynTbl.def", VDBvds );
       sts = VDBmake_input_win( &filewin, 12, 2, &maxlen1, &maxlen2, 3,
			   "", "Template File", deffile );

       for ( ii=0; ii<8; ii++)
	  strcpy( VDBmsgstrs[ii], "");

       outstrs[0] = filename;
       VDB_DISP_PADED_MSG( "Enter filename and press PROCESS" );

       sts = VDBmenu_input_oper( &filewin, maxlen2, VDB_FIRST_LINE,
		VDB_FIRST_COL+maxlen1+VDB_GAP, 1, -1, 1, VDBmsgstrs, outstrs );

#ifdef VDB_DEBUG
       VDSdebug( "VDBcreatTableOption \n\tfilename = %s\n", filename );
#endif

       if ( sts == VDB_EXIT )
       {  VDB_DELETE_WIN ( filewin );
          goto cancel;
       }

/*   check if filename is specified  */
       if ( !strcmp( filename, "" ) )
       { VDB_DELETE_WIN ( filewin );
         goto wrapup;
       }

/*   open and read the file */
       fp = (FILE *) fopen( filename, "r" );
       if ( fp == NULL )
       { sprintf( VDBtmps, " Can not open file <%s> for reading", filename );
         VDB_DISP_PADED_MSG ( VDBtmps );
         goto wrapup;
       }

       ii = 0;
       while( fgets( VDBbuff, 256, fp ) )
       {
       	   if ( VDBbuff[0] == VDB_COMMENT_CHAR ) continue;
       	   attrib[0] = datatype[0] = '\0';
	   sscanf( VDBbuff, "%s %s", attrib, datatype );
	   if ( ii == *norecs )
	   { *recs = _REALLOC (*recs, (*norecs + 30 ), struct VDBtable );
             _CheckAlloc(*recs, "attribute list", sts, VDS_E_ALLOC_MEMORY, 
								cancel )
	     *norecs += 30;
	   }
           strcpy( (*recs)[ii].attrib, attrib );
           strcpy( (*recs)[ii].dtype, datatype );
           ii++;
       }
       fclose( fp );
       while ( ii < *norecs )
       {  (*recs)[ii].attrib[0] = '\0';
          (*recs)[ii].dtype[0] = '\0';
          ii++;
       }

       VDB_DELETE_WIN ( filewin );

wrapup:
  return VDB_PROCESS;

cancel :
  return VDB_EXIT;

}

/* --------------------------------------------------------------------------
Doc :  VDBadddata_menu_oper

  Desc : This performs "add data to table" menu operations.

  Return values:
  VDB_PROCESS : continue process.
  VDB_EXIT    : exit.
---------------------------------------------------------------------------*/
long VDBadddata_menu_oper (
 WINDOW *adddatawin,         /* i - add data window*/
 int    maxlen1,             /* i - max. length of any of attribues */
 int    maxlen2,	     /* i - max. length of any of data values */
 int    norowsdisp,	     /* i - no. of rows displayed in the window */
 char   *tablename,	     /* i - name of the table */
 int    *norecs,	     /* i - no. of records in the list 'recs' */
 struct VDBtable **recs	     /* o - data values keyed in by user */
)

{
long   sts;
int    ii, oldnorecs, filled_norecs, norecs_allocated, number, len;
char   tbltype, **oldattribs, **olddatatype, dtypestr[20];

   sts=
   vdb$RetrieveAttributes (     table_name    =    tablename,
                                p_num         =    &oldnorecs,
                                p_attr        =    &oldattribs,
                                p_type        =    &olddatatype );

   if ( sts != 1 )  /* not success  */
   {
     VDSprintUsrMsg( "\tCan not get attributes from table <%s>\n", tablename );
     VDSprintVdsErr( "\t", "VdsRetrieveAttributes", sts );
     VDBerrstat = 1;
     goto cancel;
   }

   for ( ii=0; ii<8; ii++ )
      strcpy( VDBmsgstrs[ii], "" );

   VDB_DISP_PADED_MSG( "Enter attribute values and press PROCESS" );

   tbltype = VDB_DVAL;
   /* Allocate minimum of no. of table rows.
    *	If oldnorecs < VDB_TABLE_ROWS, the remaining
    * 	will be filled with blanks. This is for display purposes only
    */
   norecs_allocated = MAX( oldnorecs, VDB_TABLE_ROWS );
   *recs = _CALLOC (norecs_allocated, struct VDBtable );
   _CheckAlloc(*recs, "attribute list", sts, VDS_E_ALLOC_MEMORY, cancel )

   for ( ii=0; ii< oldnorecs; ii++)
   {  strcpy( (*recs)[ii].attrib, oldattribs[ii] );
      strcpy( (*recs)[ii].dtype,  olddatatype[ii] );

/*  concatenate datatype at the end of attribute string */
      number = atoi( olddatatype[ii] );
      sts = VdsConvertDatatype ( number, dtypestr );
      len = strlen ( oldattribs[ii] );
      if ( maxlen1 - len > 3 )
      {  strcat( (*recs)[ii].attrib, "[" );
         strncat ( (*recs)[ii].attrib, dtypestr, maxlen1-len-2 );
         strcat( (*recs)[ii].attrib, "]" );
      }
   }

   /* pad the strings with blanks */
   for( ii = 0; ii < norecs_allocated; ii++)
   { VDBpadstr( (*recs)[ii].attrib, maxlen1+1, ' ' );
     VDBpadstr( (*recs)[ii].dval, maxlen2+1, ' ' );
   }

attrib_win:
   sts = VDBattrib_win_oper ( adddatawin, maxlen1, maxlen2, VDB_FIRST_LINE,
			     VDB_FIRST_COL, norowsdisp,
			     VDB_EDITABLE,  0, oldnorecs-1, 1, 1,
			     &norecs_allocated, recs, tbltype );

   if ( sts == VDB_EXIT ) /* user selected cancel */
        goto cancel;

/* post-processing
 */

/* remove leading blanks and pad blanks at end of string */
   for(ii=0; ii<norecs_allocated; ii++)
   {  VDBdelLeadSpaces ( (char *) (*recs)[ii].attrib );
      VDBpadstr( (char *)(*recs)[ii].attrib, maxlen1+1, ' ');
      VDBdelLeadSpaces ( (char *) (*recs)[ii].dval );
      VDBpadstr( (char *)(*recs)[ii].dval, maxlen2+1, ' ');
   }

   sts = VDBvalidateAttribData( &norecs_allocated, recs , 0 , VDB_DVAL,
				&filled_norecs);
#ifdef VDB_DEBUG
   VDSdebug( "VDB_attrib_oper(after validate)\n" );

for( ii=0; ii< oldnorecs; ii++ )
{
  VDSdebug( "ii=[%d], attrib=[%s], \n\tdtype=[%s], dval=[%s]\n", ii,
          (*recs)[ii].attrib, (*recs)[ii].dtype, (*recs)[ii].dval );
}
#endif

   if ( sts == 0 )   /* invalid data values */
      goto attrib_win;

   /* copy attributes. recs contain datatypes also in attribute strings */
   for ( ii=0; ii< oldnorecs; ii++)
      strcpy( (*recs)[ii].attrib, oldattribs[ii] );


   /* free memory */
   for ( ii=0; ii<oldnorecs; ii++)
   {  _FREE ( oldattribs[ii] );
      _FREE ( olddatatype[ii] );
   }
   _FREE ( oldattribs );
   _FREE ( olddatatype );

   *norecs = oldnorecs;
   return VDB_PROCESS;

cancel:
   return VDB_EXIT;

}

/*------------------------------------------------------------------------------
  Doc : VDBgetTableName

  Description: This gets table name to be used by create, modify tables etc.

  Return values:
  VDB_PROCESS : continue process
  VDB_EXIT :    exit
-----------------------------------------------------------------------------*/
VDBgetTableName(
 char	*tablename,	/* o - name keyed in by user */
 char    NeworOldFlag	/* i - VDB_NEW_TABLE, make sure table does not exist.
				     - VDB_OLD_TABLE, make sure table exists. */
)
{
long       sts;
WINDOW     *tablewin = NULL;

int        maxlen1, maxlen2, ii;

char       *outstrs[1], do_menu_oper;


   maxlen1 = 0;
   maxlen2 = VDB_MAX_TABLE_LEN-1;

   sts = VDBmake_input_win( &tablewin, 12, 2, &maxlen1, &maxlen2, 3,
			   "", "Tablename", "");

   for ( ii=0; ii<8; ii++)
        strcpy( VDBmsgstrs[ii], "");

   outstrs[0] = tablename;
   VDB_DISP_PADED_MSG( "Enter name of table and press PROCESS" );

   do_menu_oper = TRUE;
   while ( do_menu_oper )
   {
        VDB_REFRESH_WIN ( tablewin );
	sts = VDBmenu_input_oper( &tablewin, maxlen2, VDB_FIRST_LINE,
		VDB_FIRST_COL+maxlen1+VDB_GAP, 1, -1, 1, VDBmsgstrs, outstrs );

	if ( sts == VDB_EXIT )
   	{  VDB_DELETE_WIN ( tablewin );
	   goto cancel;
	}

#ifdef VDB_DEBUG
    VDSdebug( "VDBgetTableName \n\ttablename = [%s]\n", tablename );
#endif

	ENDWIN;

	sts = VdsVerifyRisTable ( tablename );

	if ( NeworOldFlag == VDB_NEW_TABLE && sts == VDS_DBTABLE_FOUND )
	{
	   printf( "\nTable <%s> already exists\n\n", tablename );
	   VDB_GET_RETURN;
	}
	else if( NeworOldFlag == VDB_OLD_TABLE && sts == VDS_DBTABLE_NOT_FOUND )
	{
	   printf( "\nTable <%s> does not exist\n\n", tablename );
	   VDB_GET_RETURN;
	}
	else
	   do_menu_oper = FALSE;

   } /*    while ( do_menu_oper )  */

   VDB_DELETE_WIN ( tablewin );

   return VDB_PROCESS;

cancel :
   return VDB_EXIT;
}

/*---------------------------------------------------------------------------
  Doc : VDBgetVdsTableFile

  Description: This gets file for performing VDS_SUPPORT_TABLE operations.

  Return values:
  VDB_PROCESS : continue process
  VDB_EXIT :    exit
-----------------------------------------------------------------------------*/
long  VDBgetVdsTableFile(
 char  tableoperflag,		/* i =VDB_CREATE_TABLES, create VDS support tables.
 				     =VDB_LOAD_TABLES, load VDS support tables.
 				     =VDB_DELETE_TABLES, delete VDS support tables. */
 char  *pathname,		/* o - path keyed in by user */
 char  *filename,		/* o - file keyed in by user */
 char  *filename2		/* o - map file for loading tables, since
				       Create & Load needs two filenames now */
)

{
long       sts;
WINDOW     *filewin = NULL;
int        maxlen1, maxlen2, ii, len, len2;
char       defpath[VDB_MAX_PATH_LEN], deffile[15], deffile2[15];
char	   *outstrs[3];

   if( filename2 )
    filename2[0] = '\0';

   deffile2[0] = '\0';

   maxlen1 = 0;
   maxlen2 = VDB_MAX_PATH_LEN-1;
   strcpy( defpath, VDBvds );
   strcat( defpath, "/data/vds" );
   if ( tableoperflag == VDB_CREATE_TABLES )
   {
     strcpy( deffile, "vds.ddl" );
     strcpy( deffile2, "vdsld.ris" );
   }
   else if ( tableoperflag == VDB_LOAD_TABLES )
     strcpy( deffile, "vdsld.ris" );
   else
     strcpy( deffile, "vdsrm.ris" );

   /*sts = VDBmake_input_win( &filewin, 11, 2, &maxlen1, &maxlen2, 5,
			   " FILENAME ", "Path", defpath, "File", deffile);*/

   if( tableoperflag == VDB_CREATE_TABLES )
    sts = VDBmake_input_win( &filewin, 11, 2, &maxlen1, &maxlen2, 7,
			     " FILENAME ", "Path", defpath, "DdlFile", deffile,
			     "MapFile", deffile2 );
   else
    sts = VDBmake_input_win( &filewin, 11, 2, &maxlen1, &maxlen2, 5,
			     " FILENAME ", "Path", defpath, "File", deffile );

   for ( ii=0; ii<4; ii++)
     strcpy( VDBmsgstrs[ii], "");

   outstrs[0] = pathname;
   outstrs[1] = filename;

   outstrs[2] = filename2;

   VDB_DISP_PADED_MSG( "Enter data and press PROCESS" );

menu_oper:
   /*sts = VDBmenu_input_oper( &filewin, maxlen2, VDB_FIRST_LINE,
	      VDB_FIRST_COL+maxlen1+VDB_GAP, 2, -1, 1, VDBmsgstrs, outstrs );*/

   if( tableoperflag == VDB_CREATE_TABLES )
    sts = VDBmenu_input_oper( &filewin, maxlen2, VDB_FIRST_LINE,
	      VDB_FIRST_COL+maxlen1+VDB_GAP, 3, -1, 1, VDBmsgstrs, outstrs );
   else
    sts = VDBmenu_input_oper( &filewin, maxlen2, VDB_FIRST_LINE,
	      VDB_FIRST_COL+maxlen1+VDB_GAP, 2, -1, 1, VDBmsgstrs, outstrs );

   if ( sts == VDB_EXIT )
   {   VDB_DELETE_WIN ( filewin );
       return sts;
   }

   len = strlen( filename );
   len2 = strlen( filename2 );

   if ( len  > 14 ||
        len2 > 14 )
   {  VDB_DISP_PADED_MSG( "Length of filename > 14" );
      goto menu_oper;
   }

   sprintf( VDBtmps, "%s/%s", pathname, filename );
   if ( access ( VDBtmps, F_OK ) )
   {  sprintf( VDBbuff, "File <%s> does not exist", VDBtmps );
      VDB_DISP_PADED_MSG ( VDBbuff );
      goto menu_oper;
   }

   if( tableoperflag == VDB_CREATE_TABLES )
   {
     sprintf( VDBtmps, "%s/%s", pathname, filename2 );
     if( access ( VDBtmps, F_OK ) )
     {
       sprintf( VDBbuff, "File <%s> does not exist", VDBtmps );
       VDB_DISP_PADED_MSG ( VDBbuff );
       goto menu_oper;
     }
   }

#ifdef VDB_DEBUG
   VDSdebug( "VDBgetVdsTableFile \n\ttabeloperflag = %d\n", tableoperflag );

   VDSdebug( "\tpathname = %s\n\tfilename = %s\n", pathname, filename );
#endif

   VDB_DELETE_WIN ( filewin );

   return sts;

}
