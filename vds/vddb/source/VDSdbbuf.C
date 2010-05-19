/* $Id: VDSdbbuf.C,v 1.1.1.1 2001/01/04 21:08:13 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vddb/source / VDSdbbuf.C
 *
 * Description:
 *	Buffer managment routines
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSdbbuf.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:13  cvs
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
 * Revision 1.7  1996/06/11  23:01:36  pinnacle
 * Replaced: vddb/source/VDSdbbuf.C for:  by v240_int for vds.240
 *
 * Revision 1.6  1996/05/23  23:54:28  pinnacle
 * Replaced: vddb/source/*buf.C for:  by tlbriggs for vds.240
 *
 * Revision 1.5  1996/05/20  03:53:36  pinnacle
 * Replaced: vddb/source/VDSdbbuf.C for:  by v240_int for vds.240
 *
 * Revision 1.4  1996/04/21  23:49:20  pinnacle
 * Replaced: vddb/source/*.C for:  by v240_int for vds.240
 *
 * Revision 1.3  1996/04/09  21:45:50  pinnacle
 * Replaced: vddb/source/VDSdbbuf.C for:  by v240_int for vds.240
 *
 * Revision 1.2  1996/02/08  17:13:40  pinnacle
 * Replaced: vddb/source/VDSdbbuf.C for:  by v240_int for vds.240
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY    AUTHOR	DESCRIPTION
 *	02/07/96    adz		keyword.doc for client/server.
 *	04/08/96    tlb		Fix VDSread_in_buffer strcmp - NULL used
 *	04/15/96    tlb		Use VDS memory checking
 *				Add prototypes
 *				SImplify debug messages to the screen
 *				Fix strchk error in VDScheck_attribute
 *				Rename VDSdbstr.h constants
 *	04/29/96    tlb		Fix user message - just output catalog name
 *				VDSascii_to_buffer - combine free/quit labels
 *				Replace function good
 *				Remove dead code
 *				Use new error handling routines:
 *				    check return status of all MEM calls
 *				VDSwrite_in_buffer - now returns status
 *			        Replace '<' with '!=' for  MEM_S_SUCCESS check
 *				VDSwrite_in_buffer, check if writes succeeeds
 *	05/22/96    tlb		Fix error messages
 *	06/10/96    tlb	Fix debug messages
 *			MEMprint_buffer crashes on NULL output for Solaris
 *			Fix key work message, processing
 *
 * -------------------------------------------------------------------*/

/* modification : changed this file from .c to .C for omcpp for compilation.
 * this was due to macros included from vdbmacros.h,hence changed .m also.
 */

#include 	<stdio.h>
#include	<string.h>
#include 	"MEMerrordef.h"
#include 	"MEMstruct.h"
#include 	"MEMproto.h"
#include 	"NETstruct.h"
#include 	"VDSdbmsg.h"
#include 	"VDSdbstr.h"
#include 	"VDSdbio.h"
#include	"VDSdberrdef.h"
#include        "vdbmacros.h"
#include        "VDmem.h"
#include	"v_risproto.h"
#include	"v_dbloadprot.h"

#define         CHAR240         "char(240)"
#define         INTEGER         "integer"
#define         NEW_LINE        10
#define         BEGIN           "["
#define         END             "]"
#define         SEPARATOR       "|"
#define         SLASH_TERM  	"/"

#define         CISANO          "n_cisano"
#define         VERSIONLIMIT    "n_versionlimit"
#define         PARM1           "p_seqno"
#define         PARM2           "p_name"
#define         PARM3           "p_datatype"
#define         PARM4           "p_parametertype"
#define         PARM5           "p_iotype"
#define         PARM6           "synonym"
#define         PARM7           "v_defaultvalue"

#define         SYNO_LEN        40
#define         PMPT1           "p_seqno"
#define         PMPT2           "p_prompt"
#define         NODE_NAME       "node_name"
#define         PASS_WORD       "passwd"
#define         PATH_NAME       "path_name"
#define         USER_NAME       "user_name"
#define         CHECKIN_NO      "4"
#define         LIMIT           "3"
#define         MACRO           "M"

#define		START_ALLOC	1024
#define		STEP_ALLOC	512

/*----------------------------------------------------------------------------*/
   /***************************************************************************/
   /*									      */
   /*   This routine build and fill a MEMptr buffer from an ASCII file. The   */
   /* resulting buffer contains many MEMptr buffers. Each of them are linked  */
   /* to a family description.						      */
   /*									      */
   /*   Algorithm :						      	      */
   /*		1)  open the output buffer				      */
   /*		2)  open ASCII file					      */
   /*		3)  read ASCII file					      */
   /*		4)  open a work buffer for each family description	      */
   /*		5)  split up the lines descriting the family into components  */
   /*		6)  file the MFlin struct with components from 5)	      */
   /*		7)  convert units to I/PDM datatypes' rules		      */
   /*		8)  build columns of the work buffer whith MFlin data  	      */
   /*		9)  fill the work buffer's columns whith MFlin data	      */
   /*		10) append the work buffer to the output buffer		      */
   /*		11) close the work buffer				      */
   /*									      */
   /*   Routines called :						      */
   /*				MEMappend				      */
   /*				MEMbuild_array				      */
   /*				MEMopen					      */
   /*				MEMprint_buffers			      */
   /*				MEMwrite				      */
   /*				MEMwrite_format				      */
   /*									      */
   /*				VDSconvert				      */
   /*				VDSsplit_line				      */
   /*									      */
   /***************************************************************************/

int VDSascii_to_buffer (
   	char	*file_name,	/* directory & name of the ASCII file  (I)    */
   	MEMptr	*p_buffer	/* pointer on the output MEMptr buffer (O)    */
	)
{
   int		n = 0; 				/* index on ASCII file line   */
   char 	string[VDS_BUF_MAX_STRING];	/* line from ASCII file       */
   char 	column[VDS_BUF_MAX_WORD];	/* name of the parameter      */
   char 	*row_of_data; 			/* row of buffer data 	      */
   short	row_allocated;			/* allocated length of
								row_of_data*/
   struct MFlin line;				/* struct to store line data  */
   FILE		*p_file;			/* file pointer 	      */

   int  n_stat;         /* Number of static attributes in stat_attrs */
   int  stat_alloc;     /* Allocated memory for stat_attrs           */
   char **stat_attrs;   /* Earlier used static attributes            */
   int  n_dyn;          /* Number of dynamic attributes in dyn_attrs */
   int  dyn_alloc;      /* Allocated memory for dyn_attrs            */
   char **dyn_attrs;    /* Earlier used dynamic attributes           */
   int	sts, MEMstatus;
   MEMptr	buffer = NULL;			/* working buffer 	      */
   int  	VDSstatus = VDS_S_SUCCESS;

   VDSdebug("ENTER: VDSascii_to_buffer\n");

   /* opening ASCII file */
   p_file = fopen ( file_name, "r");
   if ( (int)p_file == NULL) {
      VDSprintErr ("\t", "%s <%s>\n", VDS_E1, file_name);
      return (VDS_E_OPEN_FILE);
     }

   /* initialization */
   string[0]  = '\0';
   *p_buffer  = (MEMptr) NULL;
   row_of_data = NULL;
   stat_attrs = NULL;
   dyn_attrs = NULL;

   /* opening MEMptr buffer */
   MEMstatus = MEMopen ( p_buffer, VDS_BUF_SIZE);
   if ( MEMstatus != MEM_S_SUCCESS) {
      	VDSstatus = VDS_E_OPEN_BUFFER;
      	VDSprintMemErr( "\t", "MEMopen", MEMstatus, VDSstatus);
      	goto quit;
     	}

   /* allocate memory for row of data */
   row_allocated = START_ALLOC;
   row_of_data = _MALLOC ( row_allocated, char );
   _CheckAlloc(row_of_data, "data row", VDSstatus, VDS_E_ALLOC_MEMORY, quit )

   /* reading ASCII file line by line */
   while ( ( fgets ( string, VDS_BUF_MAX_STRING, p_file) != 0 )) {

      VDSstatus = 0;

#     ifdef STEP
         printf ( "\nn = %d, string : %s", n, string);
#     endif

      /* Check for duplicate attribute names */
      VDSstatus = VDScheck_attribute ( string, &n_stat, &stat_alloc,
           &stat_attrs, &n_dyn, &dyn_alloc, &dyn_attrs );
      if (VDSstatus != VDS_S_SUCCESS) {
		/* error message printed in routine */
		goto quit;
		}

      /* increment line counter */
      n = n + 1;

      if ( (strcmp(string, NULLSTR) != 0) && (string[0] != NEW_LINE) )
        {
         /* fill MFlin structure with current line data */
         if ( VDSsplit_line ( string, &line) != VDS_S_SUCCESS )
		goto quit ;

         /* first line of a part */
         if (strcmp ( line.name[0].text, BEGIN) == 0)
           {
#ifdef STEP
            printf ( VDS_S1);
#endif
            row_of_data[0] = 0;
            n_stat = 0;
            n_dyn = 0;

	    /* open working buffer */
            MEMstatus = MEMopen ( &buffer, VDS_BUF_SIZE);
            if ( MEMstatus != MEM_S_SUCCESS) {
               	VDSstatus = VDS_E_OPEN_BUFFER;
      		VDSprintMemErr( "\t", "MEMopen", MEMstatus, VDSstatus);
               	goto quit;
              	}
           }

         /* last line of a part */
         else if (strcmp ( line.name[0].text, END) == 0)
           {
#ifdef STEP
            printf ( VDS_S2);
#endif

            /* fill working buffer with part's data */
            MEMstatus = MEMwrite ( buffer, row_of_data);
            if ( MEMstatus != MEM_S_SUCCESS) {
               	VDSstatus = VDS_E_WRITE_BUFFER;
      		VDSprintMemErr( "\t", "MEMwrite", MEMstatus, VDSstatus);
               	goto quit;
              	}

            MEMstatus = MEMbuild_array ( buffer);
            if ( MEMstatus != MEM_S_SUCCESS) {
               	VDSstatus = VDS_E_BUILD_BUFFER_ARRAY;
      		VDSprintMemErr( "\t", "MEMopen", MEMstatus, VDSstatus);
               	goto quit;
              	}

#ifdef DEBUG
    	    VDSdebug ("++++++++++++++++++++++++++++++++++++++++++++++++++");
            MEMprint_array ( "VDSascii_to_buffer BUFFER", buffer, 
							VDS_DEBUG_FILE);
#endif DEBUG

	    /* append working buffer to output buffer */
            MEMstatus = MEMappend ( buffer, *p_buffer);
            if ( MEMstatus != MEM_S_SUCCESS) {
               	VDSstatus = VDS_E_APPEND_BUFFER;
      		VDSprintMemErr( "\t", "MEMappend", MEMstatus, VDSstatus);
               	goto quit;
              	}
           }

         /* current part's line, 1 "=" case */
         else if ( line.seg_num == 2)
           {
	    /* convert unit with I/PDM datatypes's rules */
#ifdef STEP
            printf ( "text0 : <%s>, unit0: <%s>\ntext1 : <%s>, unit1: <%s>\n",
	             line.name[0].text, line.name[0].unit,
	             line.name[1].text, line.name[1].unit );
#endif
            if ( !VDSconvert ( line.name[0].unit ) ) {
	       	VDSstatus = VDS_E_CONVERT_DATATYPE;
      		VDSprintVdsErr( "\t", "VDSconvert", VDSstatus);
	       	goto quit;
              	}

#ifdef STEP
            printf ( "text0 : <%s>, unit0: <%s>\ntext1 : <%s>, unit1: <%s>\n",
	             line.name[0].text, line.name[0].unit,
	             line.name[1].text, line.name[1].unit );
#endif

            strcpy ( column, line.name[0].text);
            strcat ( column, SEPARATOR);
            strcat ( column, line.name[0].unit);

            /* fill working buffer with columns */
            MEMstatus = MEMwrite_format ( buffer, column, CHAR240);
            if ( MEMstatus != MEM_S_SUCCESS) {
               	VDSstatus = VDS_E_WRITE_BUFFER;
      		VDSprintMemErr( "\t", "MEMwrite_format", MEMstatus, VDSstatus);
               	goto quit;
              	}

            if (row_allocated <= strlen(row_of_data) + SYNO_LEN + 2) {
               row_allocated = row_allocated + STEP_ALLOC;
               row_of_data = _REALLOC ( row_of_data, row_allocated, char );
    	  	_CheckAlloc(row_of_data, "row string", VDSstatus,
						VDS_E_ALLOC_MEMORY, quit )
              }

	    /* include units */
            if ( strcmp ( line.name[1].unit, NULLSTR) != 0)
              {
	       /* kludge to shorten synonym */
               strncat ( row_of_data,
		         line.name[1].text,
		         SYNO_LEN - 5 );
               strcat  ( row_of_data, "[");
               strncat ( row_of_data, line.name[1].unit, 2 );
               strcat  ( row_of_data, "]");
              }
	    else strncat ( row_of_data, line.name[1].text, SYNO_LEN);

            strcat ( row_of_data, ONE);
           }

         else
           {
            VDSprintErr ("\t", "%s%s\n", VDS_E2, string);
           }
        }
     }  /* end of file read loop */

   MEMstatus = MEMbuild_array ( *p_buffer);
   if ( MEMstatus != MEM_S_SUCCESS) {
      	VDSstatus = VDS_E_BUILD_BUFFER_ARRAY;
      	VDSprintMemErr( "\t", "MEMbuild_array", MEMstatus, VDSstatus);
      	goto quit;
     	}

#ifdef DEBUG
      VDSdebug ("++++++++++++++++++++++++++++++++++++++++++++++++++");
      MEMprint_buffers ( "VDSascii_to_buffer return BUFFER", *p_buffer, 
								VDS_DEBUG_FILE);
#endif DEBUG

quit :
   fclose ( p_file);
   _FREE(row_of_data);
   vdb$RisFreeBuffer (  buffer   =   stat_attrs,
       			size     =   stat_alloc);
   vdb$RisFreeBuffer (  buffer   =   dyn_attrs,
                       	size     =   dyn_alloc);

   sts = MEMclose ( &buffer);
   if (sts != MEM_S_SUCCESS )
      	VDSprintMemErr( "\t", "MEMclose", sts, VDS_E_CLOSE_BUFFER);

   VDSdebug("EXIT: VDSascii_to_buffer\n");
   return ( VDSstatus );
}

/*----------------------------------------------------------------------------*/

int VDSwrite_in_buffer ( buffer, attr_name, n_row, attr_value)

   MEMptr	buffer;		/* data buffer     (I/O) 		      */
   char		*attr_name;	/* attribute name  (I) 			      */
   int		n_row;		/* row number	   (I)			      */
   char		*attr_value;	/* attribute value (I) 			      */

{

   /***************************************************************************/
   /*									      */
   /*   This routine write an attribute value in a given one row MEMptr	      */
   /*   buffer. The attribute name must exist in the buffer's columns.        */
   /*									      */
   /*   Algorithm :						      	      */
   /*		1)  search attribute name in given buffer's columns	      */
   /*		2)  write attribute name in given buffer's data		      */
   /*									      */
   /*   Routines called :						      */
   /*				MEMprint_array				      */
   /*				MEMwrite_data				      */
   /*									      */
   /***************************************************************************/

   int	i;				/* index 			      */
   int	found = FALSE;			/* attribute existence flag 	      */
   int  status = VDS_E_FAILURE;

   VDSdebug("ENTER: VDSwrite_in_buffer\n");


   /* loop over columns -  
    * 	    search attribute name in data_buffer 
    */
   for ( i=0; !found && i<buffer->columns; i=i+1) {

      /* column name  matches attribute */
      if (strcmp( ((char**)(buffer->column_ptr))[i], attr_name ) == 0) {

#	ifdef TRACE
     	   printf ("column : <%s>, format : <%s>, old_data : <%s>, new_data : <%s>\n",
		((char **)(buffer->column_ptr))[i],
		((char **)(buffer->format_ptr))[i],
		((char **)(buffer->data_ptr))[i + (n_row*(buffer->columns))],
        	attr_value );
#      	endif

	found = TRUE;

        status = MEMwrite_data ( buffer, attr_value, n_row + 1, i + 1 );
	if (status != MEM_S_SUCCESS) {
      		VDSprintMemErr( "\t", "MEMwrite_data", status,
							VDS_E_WRITE_BUFFER);
		status = VDS_E_WRITE_BUFFER;
		}
	else
   		status = VDS_S_SUCCESS;

#      	ifdef DEBUG_BUF
    		VDSdebug ("++++++++++++++++++++++++++++++++++++++++++++++++++");
         	MEMprint_array ( "VDSwrite_in_buffer MODIFY", buffer, 
								VDS_DEBUG_FILE);
#   	endif DEBUG_BUF

        }
     }
   if ( !found )
      VDSprintErr ( "\t",  "%s: attribute <%s> does not exist in buffer\n",
					"cannot write to buffer", attr_name);

   VDSdebug("EXIT: VDSwrite_in_buffer\n");
   return  (status);
}


/*----------------------------------------------------------------------------*/


int VDSread_in_buffer ( buffer, attr_name, n_row, attr_format, attr_value)

   MEMptr	buffer;		/* data buffer        (I) 		      */
   char		*attr_name;	/* attribute name     (I) 		      */
   int		n_row;		/* row number	      (I)		      */
   char		*attr_format;	/* attribute datatype (O) 		      */
   char		*attr_value;	/* attribute value    (O) 		      */

{

   /***************************************************************************/
   /*									      */
   /*   This routine read an attribute datatype and an attribute value in a   */
   /* given one row MEMptr buffer. The attribute name must exist in the       */
   /* buffer's columns.							      */
   /*									      */
   /*   Algorithm :						      	      */
   /*		1)  search attribute name in given buffer's columns	      */
   /*		2)  extract attribute datatype & attribute value	      */
   /*									      */
   /***************************************************************************/

   int	i;			/* loop index 				      */
   int	index;  		/* column index 			      */
   int	len1;			/* length of attribute name 		      */
   int  col=buffer->columns;	/* number of columns of MEMptr buffer	      */

#ifdef DEBUG
   VDSdebug("ENTER: VDSread_in_buffer\n");
#endif

   /* Empty buffer or null attribute name */
   if ( (strcmp( attr_name, NULL_STRING) == 0) || (buffer == NULL) ) {
      VDSprintErr ("\t", "cannot read attribute <%s>: %s \n", attr_name,VDS_E3);
      return VDS_E_FAILURE;
     }

   /* initialization */
   index       = -1;
   len1        = strlen( attr_name);

   /* searching column index corresponding to attribute name */
   for ( i=0; index == -1 && i<col; i=i+1) {
      	if (!strncmp (attr_name, ((char**)(buffer->column_ptr))[i], len1)) 
         	index = i;
      }

   /* fill output arguments : datatype and value */

   /* attribute not found - use null values */
   if (index == -1) {
      /*if ( strcmp ( attr_name, PDU_DESCRIPTION_ATTR) != 0)
         VDSprintErr ( "\t", "attribute <%s> doesn't exist in buffer\n",
								attr_name);*/
      strcpy ( attr_format, NULL_FORMAT);
      strcpy ( attr_value , NULL_STRING);
     }
   /* attribute found - copy values */
   else {
      strcpy ( attr_format , ((char**)(buffer->format_ptr))[index] );
      strcpy ( attr_value  , ((char**)(buffer->data_ptr))[(n_row*col)+index] );
     }

#ifdef TEST
    VDSdebug ( "  row_number=%d, column : <%s>, format : <%s>, data : <%s>\n",
            n_row,
            index == -1 ? "-1" : ((char**)(buffer->column_ptr))[index],
            attr_format,
            attr_value );
#endif

#ifdef DEBUG
   VDSdebug("EXIT: VDSread_in_buffer\n");
#endif

   return VDS_S_SUCCESS;
}

/*----------------------------------------------------------------------------*/

int VDSclose_buffers ( buffer1, buffer2, buffer3)

   MEMptr	*buffer1;	/* MEMptr buffer number 1 to close (I) 	      */
   MEMptr	*buffer2;	/* MEMptr buffer number 2 to close (I) 	      */
   MEMptr	*buffer3;	/* MEMptr buffer number 3 to close (I) 	      */
{

   /***************************************************************************/
   /*									      */
   /*   This routine closes 3 MEMptr buffers.				      */
   /*									      */
   /*   Algorithm :						      	      */
   /*		1)  close each non null given MEMptr buffer		      */
   /*									      */
   /*   Routines called :						      */
   /*				MEMclose				      */
   /*									      */
   /***************************************************************************/

   int MEMstatus = MEM_S_SUCCESS;
   int VDSstatus = VDS_E_CLOSE_BUFFER;

   VDSdebug("ENTER: VDSclose_buffers\n");

   if ( buffer1 != NULL) {
      MEMstatus =   MEMclose ( buffer1);
      if ( MEMstatus !=  MEM_S_SUCCESS)
      	VDSprintMemErr( "\t", "MEMclose", MEMstatus, VDSstatus);
       }

   if ( buffer2 != NULL) {
      MEMstatus =  MEMclose ( buffer2);
      if ( MEMstatus !=  MEM_S_SUCCESS)
      	VDSprintMemErr( "\t", "MEMclose", MEMstatus, VDSstatus);
     }

   if ( buffer3 != NULL) {
      MEMstatus =  MEMclose ( buffer3);
      if ( MEMstatus !=  MEM_S_SUCCESS)
      	VDSprintMemErr( "\t", "MEMclose", MEMstatus, VDSstatus);
      }

   VDSdebug("EXIT: VDSclose_buffers\n");

   VDSstatus = (1&MEMstatus) ?  VDS_S_SUCCESS : VDS_E_CLOSE_BUFFER;
   return (VDSstatus);
}


/*----------------------------------------------------------------------------*/
   /***************************************************************************/
   /*									      */
   /*   This routine extracts the names defining the macro (macro library,    */
   /*   macro name, macro description and dynamic table name ) from the       */
   /*   description buffer.	      					      */
   /*									      */
   /*   Algorithm :						      	      */
   /*		1)  read names in description buffer			      */
   /*									      */
   /*   Routines called :						      */
   /*				VDSread_in_buffer			      */
   /*				VDSextract_cofilename			      */
   /*									      */
   /***************************************************************************/


int VDSfamily_parameters (
   MEMptr	desc_buffer,	 /* description buffer       (I)	   */
   char		*macro_library,	 /* macro library name       (O)	   */
   char		*macro_name,	 /* macro name	       	     (O)	   */
   char		*macro_desc	 /* macro description        (O)           */
   )

{
   char		format[VDS_BUF_MAX_WORD];	/* dummy string for datatype  */
   char		partnum[VDS_BUF_MAX_WORD];	/* relative addr of macro lib */
   char		path[VDS_BUF_MAX_WORD];	  	/* relative path to macro lib */
   int		VDSstatus;


   /* extract macro library data */
   VDSdebug("ENTER: VDSfamily_parameters\n");
   VDSstatus =  VDSread_in_buffer ( desc_buffer,
				         VDS_FILENAME_ATTR ,
 					 0,
				         format,
				         partnum );
   if ( VDSstatus != VDS_S_SUCCESS) {
     VDSprintVdsErr( "\t", "VDSread_in_buffer", VDSstatus );
     goto quit;
     }

   /* extract macro library : name & relative path */
   VDSstatus =  VDSextract_cofilename ( partnum, path,  macro_library );
   if ( VDSstatus != VDS_S_SUCCESS) {
      	VDSprintVdsErr( "\t", "VDSextract_cofilename", VDSstatus);
     	goto quit;
	}


   /* extract family name */
   VDSstatus =  VDSread_in_buffer ( desc_buffer,
                                         VDS_NFM_CATALOG_NAME,
					 0,
                                         format,
                                         macro_name );
   if ( VDSstatus != VDS_S_SUCCESS) {
         VDSprintVdsErr( "\t", "VDSread_in_buffer", VDSstatus );
     	goto quit;
    	}


   /* extract family description */
   VDSstatus =  VDSread_in_buffer ( desc_buffer,
 				         VDS_NFM_CATALOG_DESC,
					 0,
 				         format,
 				         macro_desc);
   if ( VDSstatus != VDS_S_SUCCESS) {
     VDSprintVdsErr( "\t", "VDSread_in_buffer", VDSstatus );
     goto quit;
    }


quit :

  VDSdebug("EXIT: VDSfamily_parameters\n");
  return ( VDSstatus );
}


/*----------------------------------------------------------------------------*/


int VDSparm_pmpt_user ( desc_buffer,
			p_parm_buffer,
			p_user_buffer )

   MEMptr	desc_buffer;		/* buffer from ASCII file (I) 	      */
   MEMptr	*p_parm_buffer;		/* parameter buffer       (O) 	      */
   MEMptr	*p_user_buffer;		/* user parameter buffer  (O) 	      */

{

   /***************************************************************************/
   /*									      */
   /*   This routine build and fill the parameter & the pmpt MEMptr buffers   */
   /* from the description MEMptr buffer.				      */
   /*									      */
   /*   Algorithm :						      	      */
   /*		1)  open parameter buffer				      */
   /*		2)  build parameter buffer's columns			      */
   /*		3)  open user buffer					      */
   /*		4)  build user buffer's columns			     	      */
   /*		5)  search dynamic and static parameters in source buffer     */
   /*		6)  fill parameter buffer with dynamic and static data	      */
   /*		7)  fill user buffer with dynamic data			      */
   /*									      */
   /*   Routines called :						      */
   /*				MEMbuild_array				      */
   /*				MEMopen					      */
   /*				MEMprint_array				      */
   /*				MEMwrite				      */
   /*				MEMwrite_format				      */
   /*									      */
   /*				VDSdecrypt_string			      */
   /*									      */
   /***************************************************************************/

   int	i;				/* loop index 			      */
   int	parameter_count = 0;		/* number of order of parameters      */
   int	order;				/* number of order of attributes      */
   int	dummy;				/* number of order of attributes      */
   char	row_of_parm[VDS_BUF_MAX_WORD*6]; /* row of data to parm_buffer */
   char	row_of_user[VDS_BUF_MAX_WORD*6]; /* row of data to user_buffer */
   char	key[VDS_BUF_MAX_WORD];		/* attribute type */
   char	column[VDS_BUF_MAX_WORD];	/* attribute name */
   char	m_column[VDS_BUF_MAX_WORD];	/* attribute name with prefix */
   char	format[VDS_BUF_MAX_WORD];	/* attribute datatype 	      */
   char	number[VDS_BUF_MAX_WORD];	/* sequence number for attribute      */
   char synonym[VDS_BUF_MAX_WORD];
   char defval[VDS_BUF_MAX_WORD];

   int	MEMstatus = MEM_S_SUCCESS;
   int  VDSstatus = VDS_S_SUCCESS;

   VDSdebug("ENTER: VDSparm_pmpt_user\n");

   /* build MEMptr parm_buffer */
   MEMstatus = MEMopen ( p_parm_buffer, VDS_BUF_SIZE);
   if ( MEMstatus != MEM_S_SUCCESS) {
      	VDSstatus = VDS_E_OPEN_BUFFER;
      	VDSprintMemErr( "\t", "MEMopen", MEMstatus, VDSstatus);
      	goto quit;
     	}

   MEMstatus =  MEMwrite_format ( *p_parm_buffer, PARM1, INTEGER);
   if ( MEMstatus != MEM_S_SUCCESS) {
      	VDSstatus = VDS_E_INVALID_BUFFER_FORMAT;
      	VDSprintMemErr( "\t", "MEMwrite_format", MEMstatus, VDSstatus);
      	goto quit;
     	}

   MEMstatus =  MEMwrite_format ( *p_parm_buffer, PARM2, VDS_DATATYPE_MACRO);
   if ( MEMstatus != MEM_S_SUCCESS) {
      	VDSstatus = VDS_E_INVALID_BUFFER_FORMAT;
      	VDSprintMemErr( "\t", "MEMwrite_format", MEMstatus, VDSstatus);
      	goto quit;
     	}

   MEMstatus = MEMwrite_format ( *p_parm_buffer, PARM3, VDS_DATATYPE_MACRO);
   if ( MEMstatus != MEM_S_SUCCESS) {
      	VDSstatus = VDS_E_INVALID_BUFFER_FORMAT;
      	VDSprintMemErr( "\t", "MEMwrite_format", MEMstatus, VDSstatus);
      	goto quit;
     	}

   MEMstatus = MEMwrite_format ( *p_parm_buffer, PARM4, VDS_DATATYPE_MACRO);
   if ( MEMstatus != MEM_S_SUCCESS) {
      	VDSstatus = VDS_E_INVALID_BUFFER_FORMAT;
      	VDSprintMemErr( "\t", "MEMwrite_format", MEMstatus, VDSstatus);
      	goto quit;
     	}

   MEMstatus = MEMwrite_format ( *p_parm_buffer, PARM5, VDS_DATATYPE_MACRO);
   if ( MEMstatus != MEM_S_SUCCESS) {
      	VDSstatus = VDS_E_INVALID_BUFFER_FORMAT;
      	VDSprintMemErr( "\t", "MEMwrite_format", MEMstatus, VDSstatus);
      	goto quit;
     	}

   MEMstatus =  MEMwrite_format ( *p_parm_buffer, PARM6, CHAR240);
   if ( MEMstatus != MEM_S_SUCCESS) {
      	VDSstatus = VDS_E_INVALID_BUFFER_FORMAT;
      	VDSprintMemErr( "\t", "MEMwrite_format", MEMstatus, VDSstatus);
      	goto quit;
     	}

   MEMstatus =  MEMwrite_format ( *p_parm_buffer, PARM7, VDS_DATATYPE_MACRO);
   if ( MEMstatus != MEM_S_SUCCESS) {
      	VDSstatus = VDS_E_INVALID_BUFFER_FORMAT;
      	VDSprintMemErr( "\t", "MEMwrite_format", MEMstatus, VDSstatus);
      	goto quit;
     	}

#ifdef DEBUG
    VDSdebug ("++++++++++++++++++++++++++++++++++++++++++++++++++");
    MEMprint_array ( "PARM_BUFFER empty", *p_parm_buffer, VDS_DEBUG_FILE);
#endif

   /* build MEMptr user_buffer */
   MEMstatus = MEMopen ( p_user_buffer, VDS_BUF_SIZE);
   if ( MEMstatus != MEM_S_SUCCESS) {
      	VDSstatus = VDS_E_OPEN_BUFFER;
      	VDSprintMemErr( "\t", "MEMwrite_format", MEMstatus, VDSstatus);
      	goto quit;
     	}

   MEMstatus = MEMwrite_format ( *p_user_buffer, PARM1, INTEGER);
   if ( MEMstatus != MEM_S_SUCCESS) {
      	VDSstatus = VDS_E_INVALID_BUFFER_FORMAT;
      	VDSprintMemErr( "\t", "MEMwrite_format", MEMstatus, VDSstatus);
      	goto quit;
     	}

   MEMstatus = MEMwrite_format ( *p_user_buffer, PARM2, VDS_DATATYPE_MACRO);
   if ( MEMstatus != MEM_S_SUCCESS) {
	VDSstatus = VDS_E_INVALID_BUFFER_FORMAT;
      	VDSprintMemErr( "\t", "MEMwrite_format", MEMstatus, VDSstatus);
	goto quit;
	}
   MEMstatus =  MEMwrite_format ( *p_user_buffer, PARM3, VDS_DATATYPE_MACRO);
   if ( MEMstatus != MEM_S_SUCCESS) {
	VDSstatus = VDS_E_INVALID_BUFFER_FORMAT;
      	VDSprintMemErr( "\t", "MEMwrite_format", MEMstatus, VDSstatus);
	goto quit;
	}
   MEMstatus =  MEMwrite_format ( *p_user_buffer, PARM4, VDS_DATATYPE_MACRO);
   if ( MEMstatus != MEM_S_SUCCESS) {
	VDSstatus = VDS_E_INVALID_BUFFER_FORMAT;
      	VDSprintMemErr( "\t", "MEMwrite_format", MEMstatus, VDSstatus);
	goto quit;
	}
   MEMstatus =  MEMwrite_format ( *p_user_buffer, PARM5, VDS_DATATYPE_MACRO);
   if ( MEMstatus != MEM_S_SUCCESS) {
	VDSstatus = VDS_E_INVALID_BUFFER_FORMAT;
      	VDSprintMemErr( "\t", "MEMwrite_format", MEMstatus, VDSstatus);
	goto quit;
	}
   MEMstatus =  MEMwrite_format ( *p_user_buffer, PARM6, CHAR240);
   if ( MEMstatus != MEM_S_SUCCESS) {
	VDSstatus = VDS_E_INVALID_BUFFER_FORMAT;
      	VDSprintMemErr( "\t", "MEMwrite_format", MEMstatus, VDSstatus);
	goto quit;
	}

   MEMstatus =  MEMwrite_format ( *p_parm_buffer, PARM7, VDS_DATATYPE_MACRO);
   if ( MEMstatus != MEM_S_SUCCESS) {
	VDSstatus = VDS_E_INVALID_BUFFER_FORMAT;
      	VDSprintMemErr( "\t", "MEMwrite_format", MEMstatus, VDSstatus);
	goto quit;
	}

#ifdef DEBUG
    	VDSdebug ("++++++++++++++++++++++++++++++++++++++++++++++++++");
   	MEMprint_array ( "USER_BUFFER empty", *p_user_buffer, VDS_DEBUG_FILE);
#endif


   /* fill parm & prompt buffers */
   for ( i=0; i<(desc_buffer->columns); i++) {
      order = 0;
      VDSstatus = VDSdecrypt_string (
			    ((char**)(desc_buffer->column_ptr))[i],
			     key,
			     column,
			     format,
                             &order );

#ifdef TEST
    printf ("VDSdecrypt_string, key:<%s>, column:<%s>, format:<%s>, order=%d\n",
         key, column, format, order);
#endif
      if ( VDSstatus != VDS_S_SUCCESS ) {
         VDSprintVdsErr( "\t", "VDSdecrypt_string", VDSstatus );
         goto quit;
      	 }

      VDSsepsyndef( ((char**)(desc_buffer->data_ptr))[i], synonym, defval );
      /*  This is a KLUDGE because RIS does not let outer joins.   */
      /*  So we have to put a default value for out dynamic values */
      if(defval[0] == '\0' ) {
	if(!strncmp(format,"char",4)) strcpy(defval,"NULL");
	else strcpy( defval,"0");
      }

      if ( (strcmp ( key, DC) == 0) &&   (order > 0) ) {
         /* fill parm_buffer with dynamic create macro template */
         sprintf ( number, "%d", parameter_count);
         parameter_count++;

         strcpy ( row_of_parm, number);		strcat ( row_of_parm, ONE);
	 strcat ( row_of_parm, column); 	strcat ( row_of_parm, ONE);
         strcat ( row_of_parm, format); 	strcat ( row_of_parm, ONE);
	 strcat ( row_of_parm, format); 	strcat ( row_of_parm, ONE);
	 strcat ( row_of_parm, VDS_IOTYPE_DYNAMIC);
         strcat ( row_of_parm, ONE);
	 strcat ( row_of_parm, synonym );
         strcat ( row_of_parm, ONE);
/* I put the synonym I need to change */
	 strcat ( row_of_parm, defval );
         strcat ( row_of_parm, ONE);

         MEMstatus = MEMwrite ( *p_parm_buffer, row_of_parm);
         if ( MEMstatus != MEM_S_SUCCESS) {
            	VDSstatus = VDS_E_WRITE_BUFFER;
      		VDSprintMemErr( "\t", "MEMwrite", MEMstatus, VDSstatus);
            	goto quit;
           	}
         }

      else if ( (strcmp ( key, DL) == 0) && (order > 0) ) {
         /* fill parm_buffer with dynamic locate macro template */
         sprintf ( number, "%d", parameter_count);
         parameter_count++;

         strcpy ( row_of_parm, number);		strcat ( row_of_parm, ONE);
	 strcat ( row_of_parm, column); 	strcat ( row_of_parm, ONE);

         /* if other dynamic attributes than coordinate system */
         if ( strncmp( format,
                       VDS_PARTYPE_COORDSYS,
                       strlen(VDS_PARTYPE_COORDSYS) ) == 0)
            {
             strcat ( row_of_parm, VDS_DATATYPE_COORDSYS);
             strcat ( row_of_parm, ONE);
            }
	 else if( strcmp( format, VDS_PARTYPE_GENERIC ) == 0 )
	    {
	     strcat ( row_of_parm, VDS_DATATYPE_MACRO );
             strcat ( row_of_parm, ONE);
            }
         else
            {
             strcat ( row_of_parm, format);
             strcat ( row_of_parm, ONE);
            }

	 strcat ( row_of_parm, format); 	strcat ( row_of_parm, ONE);
	 strcat ( row_of_parm, VDS_IOTYPE_LOCATE);
         strcat ( row_of_parm, ONE);
	 strcat ( row_of_parm, synonym );
         strcat ( row_of_parm, ONE);
/* I put the synonym I need to change */
	 strcat ( row_of_parm, defval );
         strcat ( row_of_parm, ONE);

         MEMstatus = MEMwrite ( *p_parm_buffer, row_of_parm);
         if ( MEMstatus != MEM_S_SUCCESS) {
            	VDSstatus = VDS_E_WRITE_BUFFER;
      		VDSprintMemErr( "\t", "MEMwrite", MEMstatus, VDSstatus);
            	goto quit;
           	}
       }

      else if ( (strcmp ( key, DO) == 0) && (order > 0) ) {

         /* fill parm_buffer with dynamic macro feet */
         sprintf ( number, "%d", parameter_count);
         parameter_count++;

         strcpy ( row_of_parm, number); 	strcat ( row_of_parm, ONE);
	 strcat ( row_of_parm, column); 	strcat ( row_of_parm, ONE);

         /* if other dynamic output than macro */
         if      ( strcmp( format, VDS_PARTYPE_DOUBLE) == 0)
            {
             strcat ( row_of_parm, VDS_DATATYPE_DOUBLE);
             strcat ( row_of_parm, ONE);
            }
         else if ( strcmp( format, VDS_PARTYPE_TEXT) == 0)
            {
             strcat ( row_of_parm, VDS_DATATYPE_TEXT);
             strcat ( row_of_parm, ONE);
            }
         else if ( strcmp( format, VDS_PARTYPE_COORDSYS) == 0)
            {
             strcat ( row_of_parm, VDS_DATATYPE_COORDSYS);
             strcat ( row_of_parm, ONE);
            }
	 else if( strcmp( format, VDS_PARTYPE_GENERIC ) == 0 )
	    {
	     strcat ( row_of_parm, VDS_DATATYPE_MACRO );
             strcat ( row_of_parm, ONE);
            }
         else if ( strcmp( format, VDS_PARTYPE_POINT) == 0)
            {
             strcat ( row_of_parm, VDS_DATATYPE_POINT);
             strcat ( row_of_parm, ONE);
            }
         else if ( strcmp( format, VDS_PARTYPE_MACRO) == 0)
            {
             strcat ( row_of_parm, VDS_DATATYPE_MACRO);
             strcat ( row_of_parm, ONE);
            }
         else if ( strcmp( format, VDS_PARTYPE_LINE) == 0)
            {
             strcat ( row_of_parm, VDS_DATATYPE_LINE);
             strcat ( row_of_parm, ONE);
            }
         else if ( strcmp( format, VDS_PARTYPE_CONIC) == 0)
            {
             strcat ( row_of_parm, VDS_DATATYPE_CONIC);
             strcat ( row_of_parm, ONE);
            }
         else if ( strcmp( format, VDS_PARTYPE_CIRCLE) == 0)
            {
             strcat ( row_of_parm, VDS_DATATYPE_CIRCLE);
             strcat ( row_of_parm, ONE);
            }
         else if ( strcmp( format, VDS_PARTYPE_ARC) == 0)
            {
             strcat ( row_of_parm, VDS_DATATYPE_ARC);
             strcat ( row_of_parm, ONE);
            }
         else if ( strcmp( format, VDS_PARTYPE_LBS) == 0)
            {
             strcat ( row_of_parm, VDS_DATATYPE_LBS);
             strcat ( row_of_parm, ONE);
            }
         else if ( strcmp( format, VDS_PARTYPE_PLANE) == 0)
            {
             strcat ( row_of_parm, VDS_DATATYPE_PLANE);
             strcat ( row_of_parm, ONE);
            }
         else if ( strcmp( format, VDS_PARTYPE_CURVE) == 0)
            {
             strcat ( row_of_parm, VDS_DATATYPE_CURVE);
             strcat ( row_of_parm, ONE);
            }
         else
            {
             strcat ( row_of_parm, format); 	strcat ( row_of_parm, ONE);
            }

	 strcat ( row_of_parm, VDS_PARTYPE_MACRO);
         strcat ( row_of_parm, ONE);
	 strcat ( row_of_parm, VDS_IOTYPE_OUTPUT);
         strcat ( row_of_parm, ONE);
	 strcat ( row_of_parm, synonym );
         strcat ( row_of_parm, ONE);
/* I put the synonym I need to change */
	 strcat ( row_of_parm, defval );
         strcat ( row_of_parm, ONE);

         MEMstatus = MEMwrite ( *p_parm_buffer, row_of_parm);
         if ( MEMstatus != MEM_S_SUCCESS) {
            	VDSstatus = VDS_E_WRITE_BUFFER;
      		VDSprintMemErr( "\t", "MEMwrite", MEMstatus, VDSstatus);
            	goto quit;
           	}
        }

      else if ( (strcmp ( key, SC) == 0) && (order > 0) )
        {
         /* fill parm_buffer with static user attributes definition */
	 /* add VDS prefix */
         sprintf ( m_column, "%s", column);
         sprintf ( number, "%d", parameter_count);
         parameter_count++;

         strcpy ( row_of_parm, number); 	strcat ( row_of_parm, ONE);
	 strcat ( row_of_parm, m_column); 	strcat ( row_of_parm, ONE);
	 strcat ( row_of_parm, format); 	strcat ( row_of_parm, ONE);
	 strcat ( row_of_parm, format); 	strcat ( row_of_parm, ONE);
	 strcat ( row_of_parm, VDS_IOTYPE_STATIC);
         strcat ( row_of_parm, ONE);
	 strcat ( row_of_parm, synonym );
         strcat ( row_of_parm, ONE);
/* I put the synonym I need to change */
	 strcat ( row_of_parm, defval );
         strcat ( row_of_parm, ONE);

         MEMstatus = MEMwrite ( *p_parm_buffer, row_of_parm);
         if ( MEMstatus != MEM_S_SUCCESS) {
            	VDSstatus = VDS_E_WRITE_BUFFER;
      		VDSprintMemErr( "\t", "MEMwrite", MEMstatus, VDSstatus);
            	goto quit;
           	}
        }

      else if ( (strcmp ( key, UD) == 0) && (order > 0) )
        {
         /* fill parm_buffer with dynamic user attributes definition */
	 /* add VDS prefix */
         sprintf ( m_column, "%s", column);
         sprintf ( number, "%d", parameter_count);
         parameter_count++;

         strcpy ( row_of_parm, number); 	strcat ( row_of_parm, ONE);
	 strcat ( row_of_parm, m_column); 	strcat ( row_of_parm, ONE);
	 strcat ( row_of_parm, format); 	strcat ( row_of_parm, ONE);
	 strcat ( row_of_parm, format); 	strcat ( row_of_parm, ONE);
/*	 strcat ( row_of_parm, VDS_IOTYPE_USER_DYN);	 */
	 strcat ( row_of_parm, VDS_IOTYPE_DYNAMIC);
         strcat ( row_of_parm, ONE);
/*	 strcat ( row_of_parm, ((char**)(desc_buffer->data_ptr))[i]);	*/
	 strcat ( row_of_parm, synonym );
         strcat ( row_of_parm, ONE);
/* I put the synonym I need to change */
/*	 strcat ( row_of_parm, ((char**)(desc_buffer->data_ptr))[i]);	 */
	 strcat ( row_of_parm, defval );
         strcat ( row_of_parm, ONE);

         MEMstatus = MEMwrite ( *p_parm_buffer, row_of_parm);
         if ( MEMstatus != MEM_S_SUCCESS) {
            	VDSstatus = VDS_E_WRITE_BUFFER;
      		VDSprintMemErr( "\t", "MEMwrite", MEMstatus, VDSstatus);
            	goto quit;
           	}
        }

      else if ( (strcmp ( key, DC)      != 0)
           &&   (strcmp ( key, DL)      != 0)
           &&   (strcmp ( key, DO)      != 0)
           &&   (strcmp ( key, FAMY)    != 0)
           &&   (strcmp ( key, NULLSTR) != 0)
           &&   (strcmp ( key, SC)      != 0)
           &&   (strcmp ( key, UA)      != 0)
           &&   (strcmp ( key, UD)      != 0) )
        {
	 VDSprintErr ( "\t", "unknown prefix: %s\n", key);

	/* return added - 5/17/96 */
	VDSstatus = VDS_E_FAILURE;
	goto quit;
        }
     } /* end of buffer fillling loop */


   MEMstatus = MEMbuild_array ( *p_parm_buffer);
   if ( MEMstatus != MEM_S_SUCCESS) {
      	VDSstatus = VDS_E_BUILD_BUFFER_ARRAY;
      	VDSprintMemErr( "\t", "MEMbuild_array", MEMstatus, VDSstatus);
      	goto quit;
     	}

   /* fill user buffer */
   order           = 0;
   parameter_count = 0;

   for ( i=0; i<(desc_buffer->columns); i++) {
       VDSstatus =
         VDSdecrypt_string ( ((char**)(desc_buffer->column_ptr))[i],
			     key,
			     column,
			     format,
                             &dummy );

#ifdef TEST
printf ("VDSdecrypt_string, key:<%s>, column:<%s>, format:<%s>, order=%d\n",
         key, column, format, dummy);
#endif
      if ( VDSstatus != VDS_S_SUCCESS) {
         VDSprintVdsErr( "\t", "VDSdecrypt_string", VDSstatus );
         goto quit;
        }

	VDSsepsyndef( ((char**)(desc_buffer->data_ptr))[i], synonym, defval );
        if(defval[0] == '\0' ) {
	  if(!strncmp(format,"char",4)) strcpy(defval,"NULL");
	  else strcpy( defval,"0");
        }

      if (strcmp ( key, UA) == 0)
        {
         /* fill user_buffer with user data */
         parameter_count++;
         sprintf ( number, "%d", parameter_count);

         strcpy ( row_of_user, number);         strcat ( row_of_user, ONE);
         strcat ( row_of_user, column);         strcat ( row_of_user, ONE);
         strcat ( row_of_user, format);         strcat ( row_of_user, ONE);
         strcat ( row_of_user, format);         strcat ( row_of_user, ONE);
	 strcat ( row_of_user, "UA"); 		strcat ( row_of_user, ONE);
	 strcat ( row_of_user, synonym );
         strcat ( row_of_user, ONE);
/* I put the synonym I need to change */
	 strcat ( row_of_parm, defval );
         strcat ( row_of_parm, ONE);

         MEMstatus = MEMwrite ( *p_user_buffer, row_of_user);
         if ( MEMstatus != MEM_S_SUCCESS) {
            	VDSstatus = VDS_E_WRITE_BUFFER;
      		VDSprintMemErr( "\t", "MEMwrite", MEMstatus, VDSstatus);
            	goto quit;
           	}
        }
      else if (strcmp ( key, UD) == 0)
        {
         /* fill user_buffer with user data */
         parameter_count++;
         sprintf ( number, "%d", parameter_count);

         strcpy ( row_of_user, number);         strcat ( row_of_user, ONE);
         strcat ( row_of_user, column);         strcat ( row_of_user, ONE);
         strcat ( row_of_user, format);         strcat ( row_of_user, ONE);
         strcat ( row_of_user, format);         strcat ( row_of_user, ONE);
/*	 strcat ( row_of_user, VDS_IOTYPE_USER_DYN);   No more User dyn */
	 strcat ( row_of_parm, VDS_IOTYPE_DYNAMIC);
	 strcat ( row_of_user, ONE);
	 strcat ( row_of_user, synonym );
         strcat ( row_of_user, ONE);
/* I put the synonym I need to change */
	 strcat ( row_of_parm, defval );
         strcat ( row_of_parm, ONE);

         MEMstatus = MEMwrite ( *p_user_buffer, row_of_user);
         if ( MEMstatus != MEM_S_SUCCESS) {
            	VDSstatus = VDS_E_WRITE_BUFFER;
      		VDSprintMemErr( "\t", "MEMwrite", MEMstatus, VDSstatus);
            	goto quit;
           	}
        }
     } /* end of user buffer filling loop */

   MEMstatus = MEMbuild_array ( *p_user_buffer);
   if ( MEMstatus != MEM_S_SUCCESS) {
      	VDSstatus = VDS_E_BUILD_BUFFER_ARRAY;
      	VDSprintMemErr( "\t", "MEMbuild_array", MEMstatus, VDSstatus);
      	goto quit;
     	}


quit :
   VDSdebug("EXIT: VDSparm_pmpt_user\n");

   return ( VDSstatus);
}


/*----------------------------------------------------------------------------*/


int VDSfill_part_data_buffer (
   MEMptr	*p_buffer,	/* data buffer			(I/O)	      */
   char		*partnum,	/* macro name			(I)	      */
   char		*description,	/* macro description		(I)	      */
   char		*n_acl_format, 	/* datatype of n_aclno		(I)	      */
   char		*n_acl_value  	/* data of n_aclno		(I)	      */
   )
{

   /***************************************************************************/
   /*									      */
   /*   This routine fill a data MEMptr buffer to add a part in "pdmlibraries"*/
   /*									      */
   /*   Algorithm :						      	      */
   /*		1)  write in data buffer				      */
   /*									      */
   /*   Routines called :						      */
   /*				VDSwrite_in_buffer			      */
   /*									      */
   /***************************************************************************/

    int VDSstatus = VDS_S_SUCCESS;

    VDSdebug("ENTER: VDSfill_part_data_buffer\n");

   /* complete *p_buffer with n_itemname */
    VDSstatus = VDSwrite_in_buffer ( *p_buffer, VDS_PARTID_ATTR, 0, partnum);
    if ( VDSstatus != VDS_S_SUCCESS) {
     VDSprintVdsErr( "\t", "VDSwrite_in_buffer", VDSstatus );
     goto quit;
    }

   /* complete *p_buffer with n_itemrev */
    VDSstatus = VDSwrite_in_buffer ( *p_buffer, VDS_REVISION_ATTR, 0, LIBREV);
    if ( VDSstatus != VDS_S_SUCCESS) {
     VDSprintVdsErr( "\t", "VDSwrite_in_buffer", VDSstatus );
     goto quit;
    }

   /* complete *p_buffer with n_itemdesc */
    if ( (strcmp (description, NULL_STRING) != 0) && (description[0] != 0) )
     {
      VDSstatus = VDSwrite_in_buffer ( *p_buffer, VDS_DESCRIPTION_ATTR,
								0, description);
      if ( VDSstatus != VDS_S_SUCCESS) {
       VDSprintVdsErr( "\t", "VDSwrite_in_buffer", VDSstatus );
       goto quit;
      }
     }


   /* complete *p_buffer with n_versionlimit */
     VDSstatus = VDSwrite_in_buffer ( *p_buffer, VERSIONLIMIT, 0, LIMIT);
      if ( VDSstatus != VDS_S_SUCCESS)
      {
       VDSprintVdsErr( "\t", "VDSwrite_in_buffer", VDSstatus );
       goto quit;
      }

   /* complete *p_buffer with n_aclno */
      VDSstatus = VDSwrite_in_buffer ( *p_buffer, n_acl_format, 0, n_acl_value);
      if ( VDSstatus != VDS_S_SUCCESS) {
       VDSprintVdsErr( "\t", "VDSwrite_in_buffer", VDSstatus );
       goto quit;
      }

   /* complete *p_buffer with n_cisano */
      VDSstatus = VDSwrite_in_buffer ( *p_buffer, CISANO, 0, CHECKIN_NO);
      if ( VDSstatus != VDS_S_SUCCESS) {
       VDSprintVdsErr( "\t", "VDSwrite_in_buffer", VDSstatus );
       goto quit;
      }

   /* complete *p_buffer with n_cofilename */
      VDSstatus = VDSwrite_in_buffer ( *p_buffer, VDS_FILENAME_ATTR, 0, partnum );
      if ( VDSstatus != VDS_S_SUCCESS) {
       VDSprintVdsErr( "\t", "VDSwrite_in_buffer", VDSstatus );
       goto quit;
      }

   /* complete *p_buffer with p_parttype */
      VDSstatus = VDSwrite_in_buffer ( *p_buffer, VDS_PARTTYPE_ATTR, 0, MACRO);
      if ( VDSstatus != VDS_S_SUCCESS) {
       VDSprintVdsErr( "\t", "VDSwrite_in_buffer", VDSstatus );
       goto quit;
      }

quit :

   VDSdebug("EXIT: VDSfill_part_data_buffer\n");
   return (VDSstatus);;
}

/*----------------------------------------------------------------------------*/

int VDSdefault_buffer ( p_loc_attr_def, p_loc_data_def, p_loc_list_def,
			p_cat_attr_def, p_cat_data_def, p_cat_list_def )

   MEMptr	*p_loc_attr_def;		/* loc attr buffer(I/O)	      */
   MEMptr	*p_loc_data_def;		/* loc data buffer(I/O)	      */
   MEMptr	*p_loc_list_def;		/* loc list buffer(I/O)	      */
   MEMptr	*p_cat_attr_def;		/* cat attr buffer(I/O)	      */
   MEMptr	*p_cat_data_def;		/* cat data buffer(I/O)	      */
   MEMptr	*p_cat_list_def;		/* cat list buffer(I/O)	      */

{

   int	VDSstatus;
   int	MEMstatus;


   VDSdebug("ENTER: VDSdefault_buffer\n");
   /* update refresh area */

   VDSstatus = VDSget_table_data ( ADD_DATA,
				  PDM_LOC,
				  NULLSTR,
				  p_loc_attr_def,
				  p_loc_data_def,
				  p_loc_list_def );
   if ( VDSstatus != VDS_S_SUCCESS) {
      VDSprintUsrMsg( "\tFailed to get attributes for list of catalogs\n" );
      VDSprintVdsErr( "\t", "VDSget_table_data", VDSstatus );
      goto quit;
     }

   if ( *p_loc_attr_def != NULL)
     {
      MEMstatus = MEMbuild_array ( *p_loc_attr_def);
      if ( MEMstatus != MEM_S_SUCCESS) {
         VDSstatus = VDS_E_BUILD_BUFFER_ARRAY;
      	 VDSprintMemErr( "\t", "MEMbuild_array", MEMstatus, VDSstatus);
         goto quit;
        }
     }


   if ( *p_loc_data_def != NULL)
     {
      MEMstatus = MEMbuild_array ( *p_loc_data_def);
      if ( MEMstatus != MEM_S_SUCCESS) {
         VDSstatus = VDS_E_BUILD_BUFFER_ARRAY;
      	 VDSprintMemErr( "\t", "MEMbuild_array", MEMstatus, VDSstatus);
         goto quit;
        }
     }


   if ( *p_loc_list_def != NULL)
     {
      MEMstatus = MEMbuild_array ( *p_loc_list_def);
      if ( MEMstatus != MEM_S_SUCCESS) {
         VDSstatus = VDS_E_BUILD_BUFFER_ARRAY;
      	 VDSprintMemErr( "\t", "MEMbuild_array", MEMstatus, VDSstatus);
         goto quit;
        }
     }

   VDSstatus = VDSget_table_attributes( ADD_TABLE,
                                        PDM_CATALOG,
                                        p_cat_attr_def,
                                        p_cat_data_def,
                                        p_cat_list_def );
   if ( VDSstatus != VDS_S_SUCCESS) {
      VDSprintUsrMsg( "\tError getting table/catalog attributes\n" );
      VDSprintVdsErr( "\t", "VDSget_table_attributes", VDSstatus );
      goto quit;
    }


   if ( *p_cat_attr_def != NULL)
     {
      MEMstatus = MEMbuild_array ( *p_cat_attr_def);
      if ( MEMstatus != MEM_S_SUCCESS) {
         VDSstatus = VDS_E_BUILD_BUFFER_ARRAY;
      	 VDSprintMemErr( "\t", "MEMbuild_array", MEMstatus, VDSstatus);
         goto quit;
        }
     }


   if ( *p_cat_data_def != NULL)
     {
      MEMstatus = MEMbuild_array ( *p_cat_data_def);
      if ( MEMstatus != MEM_S_SUCCESS) {
         VDSstatus = VDS_E_BUILD_BUFFER_ARRAY;
      	 VDSprintMemErr( "\t", "MEMbuild_array", MEMstatus, VDSstatus);
         goto quit;
        }
     }


   if ( *p_cat_list_def != NULL)
     {
      MEMstatus = MEMbuild_array ( *p_cat_list_def);
      if ( MEMstatus != MEM_S_SUCCESS) {
         VDSstatus = VDS_E_BUILD_BUFFER_ARRAY;
      	 VDSprintMemErr( "\t", "MEMbuild_array", MEMstatus, VDSstatus);
         goto quit;
        }
     }


quit :

   VDSdebug("EXIT: VDSdefault_buffer\n");
   return ( VDSstatus);
}

/******************************************************************************
 * VDScheck_attribute - Check for duplicates of attribute names
 *
 * This function allocates memory for stat_attrs and dyn_attrs buffers and
 * should be initialized to NULL and freed by the caller
 *
 * Returns VDS_S_SUCCESS if OK
 *         VDS_E_FAILURE if error ( Duplicate of attribute or memory fault)
 *         VDS_E_FAILURE if the attribute/catalog is a keyword reserved by RIS.
******************************************************************************/
int VDScheck_attribute (
   char		line[],		/* line of data with following contents  (I)
                                static attributes:
                                   p_s<number>|<attribute>(<type>)...
                                   p_u<number>|<attribute>(<type>)...
                                dynamic attributes:
                                   p_d<number>|<attribute>(<type>)...
                                   p_v<number>|<attribute>(<type>)...
                                   p_c<number>|<attribute>(<type>)... */

   int	*n_stat,	/* Number of static attributes in stat_attrs    (I/O)*/
   int	*stat_alloc,    /* Allocated memory for stat_attrs              (I/O)*/
   char	**stat_attrs[], /* Earlier used static attributes               (I/O)*/
   int	*n_dyn,		/* Number of dynamic attributes in dyn_attrs    (I/O)*/
   int	*dyn_alloc,     /* Allocated memory for dyn_attrs               (I/O)*/
   char	**dyn_attrs[]   /* Earlier used dynamic attributes              (I/O)*/
   )

{
   char attribute[VDS_BUF_MAX_ATTR_LEN];
   int attr_type;	           /* =0 static =1 dynamic */
   int i,j,found;
   char *ptr;
   int status;
   static char catalog[VDS_BUF_MAX_WORD];

   /* allocate memory for attributes buffers */
   if ( *stat_attrs == NULL ) {
      *stat_alloc = VDS_BUF_MEM_START;
      *n_stat = 0;
      *stat_attrs = _MALLOC ( *stat_alloc, char* );
      _CheckAlloc(*stat_attrs, "static attribute list", status,
						VDS_E_ALLOC_MEMORY, fail )

      for (i=0;i< *stat_alloc; i=i+1) {
         /*|Malloc buffer's string */
         (*stat_attrs)[i] = NULL;
         (*stat_attrs)[i] = _MALLOC (VDS_BUF_MAX_ATTR_LEN, char);
          _CheckAlloc((*stat_attrs)[i], "static attributes", status,
						VDS_E_ALLOC_MEMORY, fail  )
         }
      }

   /* allocate memory for dyanamic attribute buffers */
   if ( *dyn_attrs == NULL ) {
      *dyn_alloc = VDS_BUF_MEM_START;
      *n_dyn = 0;
      *dyn_attrs = _MALLOC ( *dyn_alloc, char* );
      _CheckAlloc(*dyn_attrs, "dynamic attribute list", status,
						VDS_E_ALLOC_MEMORY, fail )
      for (i=0;i< *dyn_alloc; i=i+1) {
         /*|Malloc buffer's string */
         (*dyn_attrs)[i] = NULL;
         (*dyn_attrs)[i] = _MALLOC (VDS_BUF_MAX_ATTR_LEN, char);
         _CheckAlloc((*dyn_attrs)[i], "dynamic attributes", status,
						VDS_E_ALLOC_MEMORY, fail )
         }
       }

   /* Get the catalog name */
   if (!strncmp(line,"n_catalogname",13)) {
      for (i=14;i<strlen(line);i=i+1) {
         if (line[i] == '=') {
            strcpy(catalog,&line[i+1]);
            /*k=strchr(catalog,catalog[0]); */
            if (ptr=strchr(catalog,'\n'))
			ptr = NULL; /* remove NL */
            break; /*????*/
            }
         }
       }

   /* Ensure catalog name is not a keyword */
   status = VDSdbcheck_keyword( catalog );
   if( status == KEYWORD_FOUND ) {
      VDSprintErr ("\t", "the catalog name <%s> is a KEY WORD \n", catalog );
      return (VDS_E_FAILURE);
      }
   else if ( status == VDS_E_OPEN_RIS_KEYWORDFILE ) {
      VDSprintUsrMsg("\tUnable to open $VDS/config/loaddata/keyword.doc file\n"
									);
      return (VDS_E_FAILURE);
      }

   /* Get attribute type */
   if (!strncmp(line,"p_s",3) || !strncmp(line,"p_u",3)) attr_type = 0; /*static*/
   else if (!strncmp(line,"p_d",3) || !strncmp(line,"p_v",3)          /*dynamic*/
            ||!strncmp(line,"p_c",3)) attr_type = 1;
   else return (VDS_S_SUCCESS);                          /* another */
   /* Get attribute name */
   found = 0;
   j = 0;
   for (i=3;i<strlen(line);i=i+1) {
      /* search for first '|' */
      if (!found) {
         /* static or dynamic attribute is only preceded by digits and one '|' */
         if (isdigit(line[i])) continue;
         else if ( line[i] == '|')
         {
            found = 1;
            continue;
         }
         else return (VDS_S_SUCCESS);	/* Not a static or dynamic definition line */
      }
      else
      {
         if ( line[i] == '(') break; /* attribute name ended */
         else
         {
            attribute[j] = line[i];
            /* convert to lower case */
            if ((int)attribute[j] >= 65 && (int)attribute[j] <= 90 )
                attribute[j] = (int)attribute[j] + 32;
            j = j + 1;
         }
      }
   }

   /* Ensure attribute name is not a keyword */
   attribute[j] = NULL;
   status = VDSdbcheck_keyword( attribute );
   if( status == KEYWORD_FOUND )
   {
      VDSprintUsrMsg ("\tError: the Attribute name <%s> is a KEY WORD in catalog <%s>\n", attribute, catalog );
      return (VDS_E_FAILURE);
   } else if ( status == VDS_E_OPEN_RIS_KEYWORDFILE )
   {
      VDSprintUsrMsg("\tUnable to open $VDS/config/loaddata/keyword.doc file\n");
      return (VDS_E_FAILURE);
   }

   /* Check if attribute is already used */
   if (attr_type) /* Dynamic attribute */
   {
      for (i=0;i< *n_dyn;i=i+1)
      {
         if (!strcmp(attribute,(*dyn_attrs)[i]))
         {
            /*Dynamic attribute already in use */
            VDSprintUsrMsg ("\tError: Dynamic attribute %s of catalog %s is already defined\n",attribute,catalog);
            VDSprintUsrMsg("\t(Attribute names are case insensitive, change name or make one of them static)\n");
            return (VDS_E_FAILURE);
         }
      }
      /* Dynamic attribute unique - add it to buffer */
      if ( *dyn_alloc <= *n_dyn )
      {
         /* Get more memory for dynamic buffer */
         j = *dyn_alloc + VDS_BUF_MEM_STEP;
         *dyn_attrs = _REALLOC ( *dyn_attrs,j, char* );
         _CheckAlloc(*dyn_attrs, "dynamic attribute list", status,
						VDS_E_ALLOC_MEMORY, fail )
         for (i= *dyn_alloc;i<j; i=i+1)
         {
            /*|Malloc buffer's string */
            (*dyn_attrs)[i] = NULL;
            (*dyn_attrs)[i] = _MALLOC (VDS_BUF_MAX_ATTR_LEN, char);
            _CheckAlloc((*dyn_attrs)[i], "dynamic attribute", status,
						VDS_E_ALLOC_MEMORY, fail )
         }
         *dyn_alloc = j;
      }
      strcpy((*dyn_attrs)[*n_dyn],attribute);
      *n_dyn = *n_dyn + 1;
      return (VDS_S_SUCCESS);
   }
   else /* Static attribute */
   {
      for (i=0;i< *n_stat;i=i+1)
      {
         if (!strcmp(attribute,(*stat_attrs)[i]))
         {
            /*Static attribute already in use */
            VDSprintUsrMsg("\tError: Static attribute %s of catalog %s is already defined\n",attribute,catalog);
            VDSprintUsrMsg ("\t(Attribute names are case insensitive, change name or make one of them dynamic)\n");
            return (VDS_E_FAILURE);
         }
      }
      /* Static attribute unique - add it to buffer */
      if ( *stat_alloc <= *n_stat )
      {
         /* Get more memory for static buffer */
         j = *stat_alloc + VDS_BUF_MEM_STEP;
         *stat_attrs = _REALLOC ( *stat_attrs, j , char * );
         _CheckAlloc(*stat_attrs, "static attribute list", status,
						VDS_E_ALLOC_MEMORY, fail )

         for (i= *stat_alloc;i<j; i=i+1)
         {
            /*|Malloc buffer's string */
            (*stat_attrs)[i] = NULL;
            (*stat_attrs)[i] = _MALLOC (VDS_BUF_MAX_ATTR_LEN, char);
            _CheckAlloc((*stat_attrs)[i], "static attributes", status,
						VDS_E_ALLOC_MEMORY, fail  )
         }
         *stat_alloc = j;
      }
      strcpy((*stat_attrs)[*n_stat],attribute);
      *n_stat = *n_stat + 1;
      return (VDS_S_SUCCESS);
fail:
      return (status);
   }
}

/*****************************************************************************/
/*									     */
/*	Function: VDSpdm_parm_buf()					     */
/*		  Fills up the buffer for pdmparameters and pdmparamloc.     */
/*	Algorithm:							     */
/*		  In the input buffer (desc_buffer) look for all the params  */
/*		  Format the buffer.					     */
/*		  Fill in the buffer the parameters and values.		     */
/*		  Same for the macro buffer.				     */
/*									     */
/*****************************************************************************/
int  VDSpdm_parm_buf (
  MEMptr    desc_buffer,          /* Buffer from ASCII file     I  */
  char	    *catalog_name,	  /* Family name		I  */
  char	    *macro_lib,		  /* pdmlibraries		I  */
  char	    *macropart,		  /* macro lib			I  */
  char	    *macrorev,		  /* Revision num		I  */
  MEMptr    *param_buf,		  /* pdmparameters buffer	O  */
  MEMptr    *macro_buf		  /* buffer for pdmparamloc	O  */
  )
{
   int	i;
   int  order;
   char row_of_parm[VDS_BUF_MAX_WORD*6];
   char key[VDS_BUF_MAX_WORD];
   char column[VDS_BUF_MAX_WORD];
   char format[VDS_BUF_MAX_WORD];
   char macroname[VDS_BUF_MAX_WORD];
   char synonym[VDS_BUF_MAX_WORD];
   char defval[VDS_BUF_MAX_WORD];
   int	MEMstatus;
   int  VDSstatus  = VDS_S_SUCCESS;

   VDSdebug("ENTER: VDSpdm_parm_buf\n");

   /* build MEMptr parm_buffer */
   MEMstatus = MEMopen ( param_buf, VDS_BUF_SIZE);
   if ( MEMstatus != MEM_S_SUCCESS) {
      VDSstatus = VDS_E_OPEN_BUFFER;
      VDSprintMemErr( "\t", "MEMopen", MEMstatus, VDSstatus);
      goto quit;
     }

   /* Open Buffer macro buffer  */
   MEMstatus = MEMopen ( macro_buf, VDS_BUF_SIZE);
   if ( MEMstatus != MEM_S_SUCCESS) {
      VDSstatus = VDS_E_OPEN_BUFFER;
      VDSprintMemErr( "\t", "MEMopen", MEMstatus, VDSstatus);
      goto quit;
     }

#ifdef DEBUG 
    VDSdebug ("++++++++++++++++++++++++++++++++++++++++++++++++++");
    MEMprint_buffer("VDSpdm_parm_buf: open pdm parameters", *param_buf,
							VDS_DEBUG_FILE);
#endif

   MEMstatus = MEMwrite_format ( *param_buf, "n_catalogname",
					 "char(18)");
   if ( MEMstatus != MEM_S_SUCCESS) {
      VDSstatus = VDS_E_INVALID_BUFFER_FORMAT;
      VDSprintMemErr( "\t", "MEMwrite_format", MEMstatus, VDSstatus);
      goto quit;
     }
   MEMstatus = MEMwrite_format ( *param_buf, "n_synonym",
					 "char(40)");
   if ( MEMstatus != MEM_S_SUCCESS) {
      VDSstatus = VDS_E_INVALID_BUFFER_FORMAT;
      VDSprintMemErr( "\t", "MEMwrite_format", MEMstatus, VDSstatus);
      goto quit;
     }
   MEMstatus = MEMwrite_format ( *param_buf, "p_templatename",
					 "char(20)");
   if ( MEMstatus != MEM_S_SUCCESS) {
      VDSstatus = VDS_E_INVALID_BUFFER_FORMAT;
      VDSprintMemErr( "\t", "MEMwrite_format", MEMstatus, VDSstatus);
      goto quit;
     }
   MEMstatus = MEMwrite_format ( *param_buf, "p_type",
					 "char(20)");
   if ( MEMstatus != MEM_S_SUCCESS) {
      VDSstatus = VDS_E_INVALID_BUFFER_FORMAT;
      VDSprintMemErr( "\t", "MEMwrite_format", MEMstatus, VDSstatus);
      goto quit;
     }
   MEMstatus = MEMwrite_format ( *param_buf, "p_iotype",
					 "char(3)");
   if ( MEMstatus != MEM_S_SUCCESS) {
      VDSstatus = VDS_E_INVALID_BUFFER_FORMAT;
      VDSprintMemErr( "\t", "MEMwrite_format", MEMstatus, VDSstatus);
      goto quit;
     }
   MEMstatus = MEMwrite_format ( *param_buf, "p_units",
					 "char(10)");
   if ( MEMstatus != MEM_S_SUCCESS) {
      VDSstatus = VDS_E_INVALID_BUFFER_FORMAT;
      VDSprintMemErr( "\t", "MEMwrite_format", MEMstatus, VDSstatus);
      goto quit;
     }

#ifdef DEBUG 
    VDSdebug ("++++++++++++++++++++++++++++++++++++++++++++++++++");
    MEMprint_buffer("VDSpdm_parm_buf: write pdm format parameters", *param_buf,
							VDS_DEBUG_FILE);
#endif

   for ( i=0; i<(desc_buffer->columns); i++)
     {
      order = 0;
      VDSstatus =
         VDSdecrypt_string ( ((char**)(desc_buffer->column_ptr))[i],
			     key,
			     column,
			     format,
                             &order );

#ifdef DEBUG
    printf ("VDSdecrypt_string, key:<%s>, column:<%s>, format:<%s>, order=%d\n",
         key, column, format, order);
#endif

      if ( VDSstatus != VDS_S_SUCCESS) {
         VDSprintVdsErr( "\t", "VDSddecrypt_string", VDSstatus );
         goto quit;
        }

      else if ( (strcmp ( key, DC) == 0) || (strcmp ( key, DL) == 0) ||
	  (strcmp ( key, DO) == 0) || (strcmp ( key, SC) == 0) ||
	  (strcmp ( key, UD) == 0) && (order > 0) )
        {
         VDSsepsyndef( ((char**)(desc_buffer->data_ptr))[i], synonym, defval );
         if(defval[0] == '\0' ) {
	   if(!strncmp(format,"char",4)) strcpy(defval,"NULL");
	   else strcpy( defval,"0");
         }
         strcpy ( row_of_parm, catalog_name);	strcat ( row_of_parm, ONE);
/*	 strcat ( row_of_parm, ((char**)(desc_buffer->data_ptr))[i]);	 */
         strcat ( row_of_parm, synonym);
         strcat ( row_of_parm, ONE);
	 strcat ( row_of_parm, column);   strcat ( row_of_parm, ONE);
	 strcat ( row_of_parm, format); strcat ( row_of_parm, ONE);
	 if( !strcmp (key, DC )) strcpy(key,"DC");
	 if( !strcmp (key, DL )) strcpy(key,"DL");
	 if( !strcmp (key, DO )) strcpy(key,"DO");
	 if( !strcmp (key, SC )) strcpy(key,"SC");
	 if( !strcmp (key, UD )) strcpy(key,"UD");
	 strcat ( row_of_parm, key);	strcat ( row_of_parm, ONE);
	 strcat ( row_of_parm, ONE);

         MEMstatus = MEMwrite ( *param_buf, row_of_parm);
         if ( MEMstatus != MEM_S_SUCCESS) {
            VDSstatus = VDS_E_WRITE_BUFFER;
      	    VDSprintMemErr( "\t", "MEMwrite", MEMstatus, VDSstatus);
            goto quit;
	   }
	}
      else if ( (strcmp ( key, DC)      != 0)
           &&   (strcmp ( key, DL)      != 0)
           &&   (strcmp ( key, DO)      != 0)
           &&   (strcmp ( key, FAMY)    != 0)
           &&   (strcmp ( key, NULLSTR) != 0)
           &&   (strcmp ( key, SC)      != 0)
           &&   (strcmp ( key, UA)      != 0)
           &&   (strcmp ( key, UD)      != 0) )
        {
	 VDSprintUsrMsg ("\tUnknown prefix : <%s>\n", key);
	/* return added - 5/17/96 */
	VDSstatus = VDS_E_FAILURE;
	goto quit;
        }
      }

   MEMstatus = MEMbuild_array ( *param_buf);
   if ( MEMstatus != MEM_S_SUCCESS) {
      VDSstatus = VDS_E_BUILD_BUFFER_ARRAY;
      VDSprintMemErr( "\t", "MEMbuild_array", MEMstatus, VDSstatus);
      goto quit;
     }

#ifdef DEBUG 
    VDSdebug ("++++++++++++++++++++++++++++++++++++++++++++++++++");
    MEMprint_buffer("VDSpdm_parm_buf: pdm parameters", *param_buf,
							VDS_DEBUG_FILE);
#endif

   MEMstatus = MEMwrite_format ( *macro_buf, "n_catalogname",
					 "char(18)");
   if ( MEMstatus != MEM_S_SUCCESS) {
      VDSstatus = VDS_E_INVALID_BUFFER_FORMAT;
      VDSprintMemErr( "\t", "MEMwrite_format", MEMstatus, VDSstatus);
      goto quit;
     }

   MEMstatus = MEMwrite_format ( *macro_buf, "p_macrocat",
					 "char(18)");
   if ( MEMstatus != MEM_S_SUCCESS) {
      VDSstatus = VDS_E_INVALID_BUFFER_FORMAT;
      VDSprintMemErr( "\t", "MEMwrite_format", MEMstatus, VDSstatus);
      goto quit;
     }

   MEMstatus = MEMwrite_format ( *macro_buf, "p_macropartno",
					 "char(40)");
   if ( MEMstatus != MEM_S_SUCCESS) {
      VDSstatus = VDS_E_INVALID_BUFFER_FORMAT;
      VDSprintMemErr( "\t", "MEMwrite_format", MEMstatus, VDSstatus);
      goto quit;
     }

   MEMstatus = MEMwrite_format ( *macro_buf, "p_macrorev",
					 "char(40)");
   if ( MEMstatus != MEM_S_SUCCESS) {
      VDSstatus = VDS_E_INVALID_BUFFER_FORMAT;
      VDSprintMemErr( "\t", "MEMwrite_format", MEMstatus, VDSstatus);
      goto quit;
     }
   MEMstatus = MEMwrite_format ( *macro_buf, "p_macroname",
					 "char(30)");
   if ( MEMstatus != MEM_S_SUCCESS) {
      VDSstatus = VDS_E_INVALID_BUFFER_FORMAT;
      VDSprintMemErr( "\t", "MEMwrite_format", MEMstatus, VDSstatus);
      goto quit;
     }

   MEMstatus = MEMwrite_format ( *macro_buf, "p_rle",
					 "char(14)");
   if ( MEMstatus != MEM_S_SUCCESS) {
      VDSstatus = VDS_E_INVALID_BUFFER_FORMAT;
      VDSprintMemErr( "\t", "MEMwrite_format", MEMstatus, VDSstatus);
      goto quit;
     }

   if ( strcmp(catalog_name,"channel_") == 0)
      strcpy ( macroname, "channel" );
   else
      strcpy ( macroname, catalog_name );
   strcpy ( row_of_parm, catalog_name);	strcat ( row_of_parm, ONE);
   strcat ( row_of_parm, macro_lib);   strcat ( row_of_parm, ONE);
   strcat ( row_of_parm, macropart);   strcat ( row_of_parm, ONE);
   strcat ( row_of_parm, macrorev);   strcat ( row_of_parm, ONE);
   strcat ( row_of_parm, macroname);	strcat ( row_of_parm, ONE);
   strcat ( row_of_parm, ONE);

   MEMstatus = MEMwrite ( *macro_buf, row_of_parm);
   if ( MEMstatus != MEM_S_SUCCESS) {
      VDSstatus = VDS_E_WRITE_BUFFER;
      VDSprintMemErr( "\t", "MEMwrite", MEMstatus, VDSstatus);
      goto quit;
     }

   MEMstatus = MEMbuild_array ( *macro_buf);
   if ( MEMstatus != MEM_S_SUCCESS) {
      VDSstatus = VDS_E_BUILD_BUFFER_ARRAY;
      VDSprintMemErr( "\t", "MEMbuild_array", MEMstatus, VDSstatus);
      goto quit;
     }

#ifdef DEBUG 
    VDSdebug ("++++++++++++++++++++++++++++++++++++++++++++++++++");
    MEMprint_buffer("VDSpdm_parm_buf: macro parameters", *macro_buf,
							VDS_DEBUG_FILE);
#endif


quit :

   VDSdebug("EXIT: VDSpdm_parm_buf\n");
   return ( VDSstatus);
}


/**************************************************************************/
/*									  */
/*	Function:	VDSclass_path.					  */
/*		  Function creates a classification buffer.		  */
/*	Algorithm:							  */
/*		  Look at the input buffer and extract levels of 	  */
/*		  classification and fill the buffer.			  */
/*									  */
/**************************************************************************/
int VDSclass_path (
  MEMptr    desc_buffer,          /* Buffer from ASCII file     I  */
  char	    *catalog_name,	  /* Family name		I  */
  MEMptr    *class_path          /* Classification Path        O  */
  )
{
   char row_of_parm[VDS_BUF_MAX_WORD*6];
   char format[VDS_BUF_MAX_WORD];
   int	MEMstatus;
   int	VDSstatus = VDS_S_SUCCESS;
   char vds_level[10], level_attr[10], level[41];
   int  i,current_depth=0;

   VDSdebug("ENTER: VDSclass_path\n");

   /* build MEMptr parm_buffer */
   MEMstatus = MEMopen ( class_path, VDS_BUF_SIZE);
   if ( MEMstatus != MEM_S_SUCCESS) {
      VDSstatus = VDS_E_OPEN_BUFFER;
      VDSprintMemErr( "\t", "MEMopen", MEMstatus, VDSstatus);
      goto quit;
     }

   MEMstatus = MEMwrite_format ( *class_path, "n_catalogname",
					 "char(20)");
   if ( MEMstatus != MEM_S_SUCCESS) {
      VDSstatus = VDS_E_INVALID_BUFFER_FORMAT;
      VDSprintMemErr( "\t", "MEMwrite_format", MEMstatus, VDSstatus);
      goto quit;
     }

   MEMstatus = MEMwrite_format ( *class_path, "p_usageid",
					 "char(40)");
   if ( MEMstatus != MEM_S_SUCCESS) {
      VDSstatus = VDS_E_INVALID_BUFFER_FORMAT;
      VDSprintMemErr( "\t", "MEMwrite_format", MEMstatus, VDSstatus);
      goto quit;
     }

   strcpy ( row_of_parm, catalog_name);	strcat ( row_of_parm, ONE);
   strcat ( row_of_parm, ONE);

   /* Look for the levels and then write the buffer formats and the buffers */
   for ( i = 0; i < 10; i++ )
   {
      sprintf ( vds_level, "%s%d", VDS_PDM_CLASS_LEVEL,i+1 );
      sprintf ( level_attr, "%s%d", "level_", i+1 );
      VDSstatus = VDSread_in_buffer ( desc_buffer,
					vds_level,
					0,
					format,
					level);
      if( level[0] == '\0' || (!strcmp(level,"NULL")) )
	break;
      else
      {
	current_depth++;
	MEMstatus = MEMwrite_format ( *class_path,level_attr,"char(40)");
   	if ( MEMstatus != MEM_S_SUCCESS) {
      		VDSstatus = VDS_E_INVALID_BUFFER_FORMAT;
      		VDSprintMemErr( "\t", "MEMwrite_format", MEMstatus, VDSstatus);
      		goto quit;
		}
	strcat ( row_of_parm, level );  strcat( row_of_parm, ONE );
      }
   }

   MEMstatus = MEMwrite ( *class_path, row_of_parm);
   if ( MEMstatus != MEM_S_SUCCESS) {
      VDSstatus = VDS_E_WRITE_BUFFER;
      VDSprintMemErr( "\t", "MEMwrite", MEMstatus, VDSstatus);
      goto quit;
     }

   MEMstatus = MEMbuild_array ( *class_path);
   if ( MEMstatus != MEM_S_SUCCESS) {
      VDSstatus = VDS_E_BUILD_BUFFER_ARRAY;
      VDSprintMemErr( "\t", "MEMbuild_array", MEMstatus, VDSstatus);
      goto quit;
     }

quit :

   VDSdebug("EXIT: VDSclass_path\n");
   return ( VDSstatus);
}

/***************************************************************************
 * VDSdbcheck_keyword -- Verifies whether the attribute name is a key word *
 * or not. The list of key words are provided by RIS			   *
 *
 * Creates a static table of keywords - should not be freed
 ***************************************************************************/

int	VDSdbcheck_keyword( char	*attr_name)
{
	FILE	*ris_file = NULL ;
	char	string[VDS_BUF_MAX_STRING];
	int	i;
	char	tmp_str[25];
	char	RisKeywordFile[81];
	int	status;
	int	keyword_start = 0;

	static	int	keyword_cnt=0;
	static	int	first_time=1;
	static	char	*key_word[1000];

	string[0] = '\0';
	i = 0;

	/*
	 * VDSloadata can be called from client and server. For both calls
	 * the checking for keyword.doc need to be performed.
	 */

	if( first_time ){
	    sprintf( RisKeywordFile, "%s/data/vds/keyword.doc",VDBvds );
	    ris_file = fopen( RisKeywordFile, "r");
	    if( ris_file == NULL ){
	    	sprintf( RisKeywordFile, "%s/config/loaddata/keyword.doc",
								VDBvds );
	    	ris_file = fopen( RisKeywordFile, "r");
	    	}
	    if( ris_file == NULL ){
	    	VDSprintUsrMsg("\t Error: File <%s>not found\n",
							RisKeywordFile );
	    	return VDS_E_OPEN_RIS_KEYWORDFILE;
	  	}

	     while(fgets(string,VDS_BUF_MAX_STRING, ris_file )){

		/* Keywords start after underline*/
	    	if( strncmp(" ------",string,7) == 0){
	      		keyword_start = 1;
	      		continue;
	    		}

	    	if(keyword_start){
	      		if( strncmp(" ******",string,7) == 0) break;
	      		sscanf(string,"%s", tmp_str );

			/* Use standard malloc -
		  	 *	these are used in a static table
		  	 */
     			key_word[i] = (char *) malloc ( (1+strlen(tmp_str))
								*sizeof(char));
			if (!key_word[i]) {
				printf ("Allocation failed at line %d of the file %s\n",
                                                	__LINE__,__FILE__);
				status = VDS_E_ALLOC_MEMORY;
				goto quit;
				}

	      		strcpy(key_word[i],tmp_str);
	      		keyword_cnt++; i++;
	    		}
		if (keyword_cnt >= 1000) {
			VDSprintUsrMsg ("\tError: number of key words exceeds array size of 1000\n");
	    		status = KEYWORD_FOUND;
			goto quit;
			}
	  	}
	  	first_time = 0;
	    }

	status = KEYWORD_NOT_FOUND;
	for (i=0; i < keyword_cnt; i++){
	    if(strcmp( attr_name, key_word[i]) == 0){
	    	VDSprintUsrMsg( "\tRIS key word found: '%s'\n", attr_name );
	    	status = KEYWORD_FOUND;
		break;
	  	}
	  }
quit:
	/* No Free - static table created for later use */
	return (status);
}

/* ----------------------------------------------------------------------
 * Seperate the synonym from the default value. The string is 	
 *	"Synonym[Default]"
 */

int VDSsepsyndef ( string , synonym, defstr )
char    *string;
char    *synonym;
char    *defstr;
{
        int     stringlength;
        int     i=0,j=0;

        synonym[0]=0;
        defstr[0]=0;

        stringlength = strlen(string);
        while( string[i] != '\0' && string[i] != '[' )
        {
                synonym[i] = string[i];
                i++;
        }
        synonym[i] = '\0';

        while( string[i] != '\0' && string[i] != ']' )
        {
           if( string[i] != '[' ) {
                defstr[j] = string[i];
                j++;
           }
           i++;
        }
        defstr[j]='\0';

 return 1;
}
