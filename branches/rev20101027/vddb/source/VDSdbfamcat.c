/* $Id: VDSdbfamcat.c,v 1.1.1.1 2001/01/04 21:08:13 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vddb/source / VDSdbfamcat.c
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSdbfamcat.c,v $
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
 * Revision 1.6  1996/06/11  22:59:50  pinnacle
 * Replaced: vddb/source/VDSdbfamcat.c for:  by v240_int for vds.240
 *
 * Revision 1.5  1996/05/20  14:33:58  pinnacle
 * Replaced: vddb/source/VDSdbfamcat.c for:  by v240_int for vds.240
 *
 * Revision 1.4  1996/05/20  04:27:26  pinnacle
 * Replaced: vddb/source/VDSdbfamcat.c for:  by v240_int for vds.240
 *
 * Revision 1.3  1996/04/22  15:14:02  pinnacle
 * Replaced: vddb/source/VDSdbfamcat.c for:  by v240_int for vds.240
 *
 * Revision 1.2  1996/04/21  23:49:32  pinnacle
 * Replaced: vddb/source/VDSdbfamcat.c for:  by v240_int for vds.240
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	04/15/96   tlb		Use VDS memory checking
 *				Simplify debug messages to user screen
 *				Rename VDSdbstr.h constants 
 *				Add prototypes
 *	04/22/96   tlb		Fix log comment problem 
 *	04/29/96   tlb		Remove extra comments to user - 'Treatment'
 *				Add NFM prototypes
 *				Use new memory routines
 *				Add goto's after failed MEM writes
 * 	06/10/96   tlb	MEMprint_buffer crashes on NULL output for Solaris
 *
 * -------------------------------------------------------------------*/

#include 	<stdio.h>
#include	<string.h>
#include	"MEMerrordef.h"
#include	"MEMstruct.h"
#include	"MEMproto.h"
#include	"VDSdbstr.h"
#include	"VDSdberrdef.h"
#include	"VDmem.h"
#include	"v_risproto.h"
#include	"v_dbloadprot.h"

#define         N_DATATYPE        	"n_datatype"
#define         N_NAME	        	"n_name"
#define         N_SYNONYM        	"n_synonym"

/*--------------------------------------------------------------------*/
int VDScreate_family_catalog( 
  char		*macro_name,		/* macro name			  (I) */
  MEMptr	parm_bufr,		/* macro parameters buffer	  (I) */
  MEMptr	user_bufr,		/* user's parameters buffer	  (I) */
  MEMptr	*p_loc_attr_bufr,	/* get_table_data : attributes    (O) */
  MEMptr	*p_loc_data_bufr,	/* get_table_data : default data  (O) */
  MEMptr	*p_cat_attr_bufr,	/* get_table_attr : attributes    (O) */
  MEMptr	*p_cat_data_bufr,	/* get_table_attr : default data  (O) */
  MEMptr	*p_cat_list_bufr,       /* get_table_attr : default list  (O) */
  MEMptr	loc_attr,		/* loc_attr definition 		  (I) */
  MEMptr	loc_data,		/* loc_data definition 		  (I) */
  MEMptr	loc_list,        	/* loc_list definition 		  (I) */
  MEMptr	cat_attr,		/* cat_attr definition 		  (I) */
  MEMptr	cat_data,		/* cat_data definition 		  (I) */
  MEMptr	cat_list,        	/* cat_list definition 		  (I) */
  MEMptr	dyn_attr,		/* Template Dynamic Attributes    (I) */
  MEMptr	*p_dyn_attr,		/* Dynamic Attribute list         (O) */
  char		*dyn_data_row		/* Data containg default values   (O) */
  )
{

   /***************************************************************************/
   /*                                                                         */
   /*   	This routine is the heart of VDSdbinit.			      */
   /*                                                                         */
   /*   This routine is a simplified version of PDUfam_cat.c from PDU source. */
   /*   The access to the PDU forms has been nullified.			      */
   /*   This function fills up the buffers for List Of Cat buffers and the    */
   /*   Catalog buffers and default data and the dynamic attribute buffers.   */
   /*                                                                         */
   /*   Algorithm :							      */
   /*			1)  get table data (loc_buffer, loc_data & loc_list)  */
   /*			2)  write data in  loc_attr 			      */
   /*			3)  write data in  loc_data 			      */
   /*			4)  get table attr (cat_attr, cat_data & cat_list)    */
   /*			5)  extend cat_attr with parm_bufr		      */
   /*			6)  rebuild cat_data with cat_attr attributes	      */
   /*			7)  close loc_list				      */
   /*                                                                         */
   /*   Routines called :						      */
   /*				memset					      */
   /*                                                                         */
   /*				MEMbuild_array				      */
   /*				MEMclose				      */
   /*				MEMwrite				      */
   /*				MEMwrite_data				      */
   /*                                                                         */
   /*				VDSget_table_attributes			      */
   /*				VDSget_table_data			      */
   /*                                                                         */
   /*				VDSadd_buffer_string			      */
   /*				VDSfind_attr_in_buffer			      */
   /*				VDSupdate_data_buffer			      */
   /*                                                                         */
   /*				VDSwrite_in_buffer			      */
   /*                                                                         */
   /***************************************************************************/

    int		i;
    int		row;
    int		static_row;
    int		col;
    int		attr_row;
    int		attr_rows;
    char	**cat_attr_data;
    char	**parameters;
    char	**paramusers = NULL;
    char	description[41];
    char	*string = NULL;
    int		char_index = 0;
    int		seq_number;
    int		PDMattr_number;
    char	seq_no[10];
    char	row_of_data[VDS_BUF_MAX_STRING];
    char	attr_format[VDS_BUF_MAX_WORD];
    char	attr_data[VDS_BUF_MAX_WORD];
    int		attr_index;

    int		dynamic_row;
    char	*string1 = NULL;

    int		MEMstatus, status;
    int		ptype_row;
    int		n_acl_row;

#ifdef DEBUG
    	VDSdebug ("++++++++++++++++++++++++++++++++++++++++++++++++++");
   	MEMprint_buffer ("PARM BUFFER", parm_bufr, VDS_DEBUG_FILE);
    	VDSdebug ("++++++++++++++++++++++++++++++++++++++++++++++++++");
   	MEMprint_buffer ("USER BUFFER", user_bufr, VDS_DEBUG_FILE);
#endif

   VDSdebug("ENTER: VDScreate_family_catalog\n");

    /* put the catalog name in the buffer */
    attr_row = VDSfind_attr_in_buffer(loc_attr, VDS_NFM_CATALOG_NAME);
    if (attr_row != -1) {
        MEMstatus = MEMwrite_data( loc_data,
					   macro_name,
					   1,
					   attr_row + 1 );
        if( MEMstatus != MEM_S_SUCCESS ) {
	 status = VDS_E_WRITE_COLUMN;
         VDSprintMemErr( "\t", "MEMwrite_data", MEMstatus, status);
         goto quit;
	 }


        MEMstatus = MEMwrite_data( loc_attr,
				   	   "N",
				   	   attr_row + 1,
				   	   VDS_NFM_WRITE_COL + 1 );
        if( MEMstatus != MEM_S_SUCCESS ) {
	 status = VDS_E_WRITE_COLUMN;
         VDSprintMemErr( "\t", "MEMwrite_data", MEMstatus, status);
         goto quit;
	}

        MEMstatus = MEMwrite_data( loc_attr,
				   	   "N",
				   	   attr_row + 1,
				   	   VDS_NFM_UPDATE_COL + 1 );
        if( MEMstatus != MEM_S_SUCCESS ) {
	 status = VDS_E_WRITE_COLUMN;
         VDSprintMemErr( "\t", "MEMwrite_data", MEMstatus, status);
         goto quit;
	}
      }

    /* put the catalog description in the buffer */
    sprintf(description, "I/VDS Parametric Catalog");
    attr_row = VDSfind_attr_in_buffer(loc_attr, VDS_NFM_CATALOG_DESC);
    if (attr_row != -1) {
        MEMstatus = MEMwrite_data( loc_data,
					   description,
					   1,
					   attr_row + 1 );
        if( MEMstatus != MEM_S_SUCCESS ) {
	  status = VDS_E_WRITE_COLUMN;
          VDSprintMemErr( "\t", "MEMwrite_data", MEMstatus, status);
          goto quit;
	}

      }

    /* MF put the aclno in the buffer */
    status = VDSwrite_in_buffer ( loc_data,
                             ((char**)(loc_list->column_ptr))[0],
                             0,
                             ((char**)(loc_list->data_ptr))[0] );
    if ( status != VDS_S_SUCCESS) {
       VDSprintVdsErr ("\t", "VDSwrite_in_buffer", status);
       goto quit;
      }

    /* put the catalog application in the buffer */
    attr_row = VDSfind_attr_in_buffer(loc_attr, VDS_NFM_CATALOG_APPL);
    if (attr_row != -1)
      {
        MEMstatus = MEMwrite_data(loc_data, "PDM", 1, (attr_row + 1));

        if( MEMstatus != MEM_S_SUCCESS ) {
	 status = VDS_E_WRITE_COLUMN;
         VDSprintMemErr( "\t", "MEMwrite_data", MEMstatus, status);
         goto quit;
	}
      }

    /* put the catalog type in the buffer */
    attr_row = VDSfind_attr_in_buffer(loc_attr, VDS_NFM_CATALOG_TYPE);
    if (attr_row != -1)
      {
        MEMstatus = MEMwrite_data(loc_data, "P", 1, (attr_row + 1));

        if( MEMstatus != MEM_S_SUCCESS ) {
	  status = VDS_E_WRITE_COLUMN;
          VDSprintMemErr( "\t", "MEMwrite_data", MEMstatus, status);
          goto quit;
	}


        MEMstatus = MEMwrite_data( loc_attr,
				   	   "N",
				   	   attr_row + 1,
				   	   VDS_NFM_WRITE_COL + 1 );
        if( MEMstatus != MEM_S_SUCCESS ) {
	  status = VDS_E_WRITE_COLUMN;
          VDSprintMemErr( "\t", "MEMwrite_data", MEMstatus, status);
          goto quit;
	}


        MEMstatus = MEMwrite_data( loc_attr,
				   	   "N",
				   	   attr_row + 1,
				   	   VDS_NFM_UPDATE_COL + 1 );
        if( MEMstatus != MEM_S_SUCCESS ) {
	  status = VDS_E_WRITE_COLUMN;
          VDSprintMemErr( "\t", "MEMwrite_data", MEMstatus, status);
          goto quit;
	}
      }

    /* add the static attributes to the attribute buffer */
    MEMstatus = MEMbuild_array(parm_bufr);
    if( MEMstatus != MEM_S_SUCCESS ) {
      status = VDS_E_BUILD_ARRAY;
      VDSprintMemErr( "\t", "MEMbuild_array", MEMstatus, status);
      goto quit;
    }

    parameters = (char **) parm_bufr->data_ptr;

    /* MF add the user's attributes to the attribute buffer */
    if ( user_bufr != NULL)
      {
       MEMstatus = MEMbuild_array(user_bufr);
       if( MEMstatus != MEM_S_SUCCESS ) {
         status = VDS_E_BUILD_ARRAY;
         VDSprintMemErr( "\t", "MEMbuild_array", MEMstatus, status);
         goto quit;
       }

       paramusers = (char **) user_bufr->data_ptr;
      }

    attr_rows = cat_attr->rows;

    cat_attr_data = (char **)cat_attr->data_ptr;

    string = _MALLOC (cat_attr->row_size, char);
    _CheckAlloc(string, "row string", status, VDS_E_ALLOC_MEMORY, quit )

    sscanf( cat_attr_data[(cat_attr->columns *(attr_rows - 1))
            + VDS_NFM_SEQNO_COL], "%d", &PDMattr_number);
    static_row = 0;

    for (row = 0; row < parm_bufr->rows; ++row)
      {
#ifdef BEDUG
       if (VDSdebug_on) 
         VDSdebug ( "\n\tRow number = %d\n", row);
#endif

	if ( strcmp ( parameters[(parm_bufr->columns * row) + VDS_IOTYPE_COL],
                      VDS_IOTYPE_STATIC) == 0)
          {
            static_row++;
            memset(string, NULL, (cat_attr->row_size));
            char_index = 0;

	    /* put the parameter for the attribute name */
	    VDSadd_buffer_string(string, &char_index,
		parameters[(parm_bufr->columns * row) + VDS_PARANAME_COL]);

	    VDSadd_buffer_string(string, &char_index,
		parameters[(parm_bufr->columns * row) + VDS_PARADATA_COL]);

            /* synonym for attribute */
	    VDSadd_buffer_string(string, &char_index,
		parameters[(parm_bufr->columns * row) + VDS_PARASYNO_COL]);

            /* put the default attribute characteristics in the buffer */
            for (col = 3; col<VDS_NFM_BUFF_COLS; ++col)
              {
                switch(col)
                  {
			case VDS_NFM_PDM_COL:
				VDSadd_buffer_string(string, &char_index,"PDM");
				break;

            	        case VDS_NFM_READ_COL:
                	case VDS_NFM_WRITE_COL:
	                case VDS_NFM_UPDATE_COL:
			case VDS_NFM_DELETE_COL:
				VDSadd_buffer_string(string, &char_index,"Y");
				break;

			case VDS_NFM_REQ_COL:
				VDSadd_buffer_string(string, &char_index,"N");
				break;

                        case VDS_NFM_LISTNO_COL:
				VDSadd_buffer_string(string, &char_index,"0");
				break;

			case VDS_NFM_SEQNO_COL:
                                seq_number = PDMattr_number + static_row + 1;
				sprintf(seq_no,"%d",seq_number);
				VDSadd_buffer_string(string, &char_index,
							seq_no);
                                break;

                        default:
				string[char_index++] = VDS_BUFFER_TERM;
				break;

	              } /* end switch */
                 } /* end for col < VDS_NFM_COLS */

            MEMstatus = MEMwrite(cat_attr, string);
	    if( MEMstatus != MEM_S_SUCCESS ) {
	     status = VDS_E_WRITE_BUFFER;
             VDSprintMemErr( "\t", "MEMwrite", MEMstatus, status);
             goto quit;
	    }

          } /* if IO type == static */
      } /* end for row < parm_bufr->rows */


    MEMstatus = MEMbuild_array ( cat_attr);
    if( MEMstatus != MEM_S_SUCCESS ) {
      status = VDS_E_BUILD_BUFFER_ARRAY;
      VDSprintMemErr( "\t", "MEMbuild_array", MEMstatus, status);
      goto quit;
    }

    MEMstatus = MEMbuild_array ( cat_data);
    if( MEMstatus != MEM_S_SUCCESS ) {
      status = VDS_E_BUILD_BUFFER_ARRAY;
      VDSprintMemErr( "\t", "MEMbuild_array", MEMstatus, status);
      goto quit;
    }


    if ( user_bufr != NULL)
      {
/*
       VDSdebug ("++++++++++++++++++++++++++++++++++++++++++++++++++");
       MEMstatus =
          MEMprint_array ("CAT ATTR before modify", cat_attr, VDS_DEBUG_FILE);
*/

       for (row = 0; row < user_bufr->rows; ++row)
	{
#ifdef DEBUG
	  if(VDSdebug_on) {
           VDSdebug ( "\n\tRow number = %d\n", row);
	   }
#endif

           attr_index = -1;

           for ( i=0; i<(cat_attr->rows); i++)
             {
              status =
                  VDSread_in_buffer (
                     cat_attr,
		     N_NAME,
                     i,
                     attr_format,
                     attr_data );
              if ( status != VDS_S_SUCCESS) {
		 VDSprintVdsErr( "\t", "VDSread_in_buffer", status );
                 goto quit;
	         }

              if ( strcmp(
                      paramusers[(user_bufr->columns * row) + VDS_PARANAME_COL],
		      attr_data ) == 0)
                {
                 attr_index = i;
		 if(VDSdebug_on) {
                   VDSdebug(" row= %d, index=%d, column : <%s>, format : <%s>, data : <%s>\n",
                          row, attr_index, N_NAME, attr_format, attr_data);
		   }

                 i = (cat_attr->rows);
                }
             }

           if ( attr_index == -1)
             {
		if (strcmp( paramusers[(user_bufr->columns * row) + VDS_IOTYPE_COL], "UA") == 0)
                {
                  memset(string, NULL, (cat_attr->row_size));
                  char_index = 0;

	          /* put the parameter for the attribute name */
	          VDSadd_buffer_string(string, &char_index,
		      paramusers[(user_bufr->columns * row) +VDS_PARANAME_COL]);

	          VDSadd_buffer_string(string, &char_index,
		      paramusers[(user_bufr->columns * row) + VDS_PARADATA_COL]);

                  /* synonym for attribute */
	          VDSadd_buffer_string(string, &char_index,
		      paramusers[(user_bufr->columns * row) +VDS_PARASYNO_COL]);


                  /* put the default attribute characteristics in the buffer */
                  for (col = 3; col<VDS_NFM_BUFF_COLS; ++col)
                    {
                      switch(col)
                        {
			 case VDS_NFM_PDM_COL:
				VDSadd_buffer_string(string, &char_index,"PDM");
				break;

            	        case VDS_NFM_READ_COL:
                	case VDS_NFM_WRITE_COL:
	                case VDS_NFM_UPDATE_COL:
			case VDS_NFM_DELETE_COL:
				VDSadd_buffer_string(string, &char_index,"Y");
				break;

			case VDS_NFM_REQ_COL:
				VDSadd_buffer_string(string, &char_index,"N");
				break;

                        case VDS_NFM_LISTNO_COL:
				VDSadd_buffer_string(string, &char_index,"0");
				break;

			case VDS_NFM_SEQNO_COL:
                                seq_number = 2*(PDMattr_number+parm_bufr->rows)
                                             +row;
				sprintf(seq_no,"%d",seq_number);
				VDSadd_buffer_string(string, &char_index,
							seq_no);
                                break;

                        default:
				string[char_index++] = VDS_BUFFER_TERM;
				break;

	              } /* end switch */
                    } /* end for col < VDS_NFM_COLS */

                 MEMstatus = MEMwrite(cat_attr, string);
		 if( MEMstatus != MEM_S_SUCCESS ) {
		  status = VDS_E_WRITE_BUFFER;
          	  VDSprintMemErr( "\t", "MEMwrite", MEMstatus, status);
                  goto quit;
		 }

                 MEMstatus = MEMbuild_array ( cat_attr);
		 if( MEMstatus != MEM_S_SUCCESS ) {
		   status = VDS_E_BUILD_BUFFER_ARRAY;
          	   VDSprintMemErr( "\t", "MEMbuild_array", MEMstatus, status);
                   goto quit;
		 }

                } /* if IO type == user */
             }
           else
             {
              status =
                  VDSwrite_in_buffer(
                     cat_attr,
                     N_DATATYPE,
                     attr_index,
                     paramusers[(user_bufr->columns * row) + VDS_PARADATA_COL]);
              if ( status != VDS_S_SUCCESS) {
		 VDSprintVdsErr( "\t", "VDSwrite_in_buffer", status );
                 goto quit;
	      }


              /* synonym for attribute */
              status =
                  VDSwrite_in_buffer(
		     cat_attr,
		     N_SYNONYM,
                     attr_index,
                     paramusers[(user_bufr->columns * row) + VDS_PARASYNO_COL]);
              if ( status != VDS_S_SUCCESS) {
		 VDSprintVdsErr( "\t", "VDSwrite_in_buffer", status );
                 goto quit;
	      }

	      MEMstatus = MEMbuild_array ( cat_attr);
	      if( MEMstatus != MEM_S_SUCCESS ) {
		 status = VDS_E_BUILD_BUFFER_ARRAY;
                 VDSprintMemErr( "\t", "MEMbuild_array", MEMstatus, status);
                 goto quit;
	      }
             }
         } /* end for row < user_bufr->rows */
      }

    MEMstatus = MEMbuild_array ( cat_attr);
    if( MEMstatus != MEM_S_SUCCESS ) {
      status = VDS_E_BUILD_BUFFER_ARRAY;
      VDSprintMemErr( "\t", "MEMbuild_array", MEMstatus, status);
      goto quit;
    }

#ifdef DEBUG
    	VDSdebug ("++++++++++++++++++++++++++++++++++++++++++++++++++");
    	MEMstatus = MEMprint_array ( "CAT ATTR after user's attributes",
				           cat_attr, VDS_DEBUG_FILE);
    	VDSdebug ("++++++++++++++++++++++++++++++++++++++++++++++++++");
    	MEMstatus = MEMprint_array ( "CAT DATA after user's attributes",
				           cat_data, VDS_DEBUG_FILE);
#endif

   /* parm_buffer values */
   col = (parm_bufr->columns);
   row = (parm_bufr->rows);

   /* close existing MEMptr buffer cat_data 
    *	Add an explict goto quit here
    */
   MEMstatus = MEMclose ( &cat_data);
   if( MEMstatus != MEM_S_SUCCESS ) {
       status = VDS_E_CLOSE_BUFFER;
       VDSprintMemErr( "\t", "MEMclose", MEMstatus, status);
       goto quit;
	}

   /* open a new MEMptr buffer cat_data */
   MEMstatus = MEMopen ( &cat_data, VDS_BUF_SIZE);
   if( MEMstatus != MEM_S_SUCCESS ) {
     status = VDS_E_BUILD_BUFFER_ARRAY;
     VDSprintMemErr( "\t", "MEMopen", MEMstatus, status);
     goto quit;
   }

   /* define names and datatypes of the new MEMptr buffer cat_data */
   for ( i=0; i<(cat_attr->rows); i++)
     {
      MEMstatus = MEMwrite_format (
            cat_data,
            ((char**)(cat_attr->data_ptr))[0 + i*(cat_attr->columns)],
            ((char**)(cat_attr->data_ptr))[1 + i*(cat_attr->columns)] );
      if( MEMstatus != MEM_S_SUCCESS ) {
        status = VDS_E_WRITE_FORMAT;
        VDSprintMemErr( "\t", "MEMwrite_format", MEMstatus, status);
        goto quit;
      }
     }

   n_acl_row = VDSfind_attr_in_buffer( cat_attr, "n_aclno");
   ptype_row = VDSfind_attr_in_buffer( cat_attr, "p_parttype");

   /* fill MEMptr buffer cat_data with null values */
   row_of_data[0] = 0;
   for ( i=0; i<cat_data->columns; i++)
   {
      if (i > VDS_BUF_MAX_STRING) printf("WARNING i > VDS_BUF_MAX_STRING\n");
	/* Adding ACCESS CONTROL LIST to n_aclno */
	/* adding default parametric part as catalog */
      if ( i == n_acl_row) strcat ( row_of_data, "6");
      if ( i == ptype_row) strcat ( row_of_data, "P");
      strcat ( row_of_data, ONE);
   }

   MEMstatus = MEMwrite ( cat_data, row_of_data);
   if( MEMstatus != MEM_S_SUCCESS ) {
     status = VDS_E_WRITE_BUFFER;
     VDSprintMemErr( "\t", "MEMwrite", MEMstatus, status);
     goto quit;
   }

   /* resize the MEMptr buffer cat_data */
   MEMstatus = MEMbuild_array ( cat_data);
   if( MEMstatus != MEM_S_SUCCESS ) {
     status = VDS_E_BUILD_BUFFER_ARRAY;
     VDSprintMemErr( "\t", "MEMbuild_array", MEMstatus, status);
     goto quit;
   }

   /* Getting Dynamic Data from the parm_buffer */
    string1 = _MALLOC ( dyn_attr->row_size, char);
    _CheckAlloc(string1, "row string", status, VDS_E_ALLOC_MEMORY, quit )

    attr_rows = dyn_attr->rows;
    dynamic_row = 0;
    dyn_data_row[0] = 0;

    for (row = 0; row < parm_bufr->rows; ++row)
      {

#ifdef DEBUG
	if (VDSdebug_on) 
    	   VDSdebug ("\n\tRow number = %d\n", row);
#endif

	if ( (strcmp ( parameters[(parm_bufr->columns * row) + VDS_IOTYPE_COL],
                      VDS_IOTYPE_LOCATE) == 0) ||
		(strcmp ( parameters[(parm_bufr->columns * row) + VDS_IOTYPE_COL],
		      VDS_IOTYPE_OUTPUT) == 0 ) ||
		(strcmp ( parameters[(parm_bufr->columns * row) + VDS_IOTYPE_COL],
		      VDS_IOTYPE_DYNAMIC) == 0) ||
		(strcmp ( parameters[(parm_bufr->columns * row) + VDS_IOTYPE_COL],
		      VDS_IOTYPE_USER_DYN) == 0))
          {
            dynamic_row++;
            memset(string1, NULL, (dyn_attr->row_size));
            char_index = 0;

	    /* put the parameter for the attribute name */
	    VDSadd_buffer_string(string1, &char_index,
		parameters[(parm_bufr->columns * row) + VDS_PARANAME_COL]);

	    VDSadd_buffer_string(string1, &char_index,
		parameters[(parm_bufr->columns * row) + VDS_PARADATA_COL]);

            /* synonym for attribute */
	    VDSadd_buffer_string(string1, &char_index,
		parameters[(parm_bufr->columns * row) + VDS_PARASYNO_COL]);

            /* put the default attribute characteristics in the buffer */
            for (col = 3; col<VDS_NFM_BUFF_COLS; ++col)
              {
                switch(col)
                  {
			case VDS_NFM_PDM_COL:
				VDSadd_buffer_string(string1, &char_index,"PDM");
				break;

            	        case VDS_NFM_READ_COL:
                	case VDS_NFM_WRITE_COL:
	                case VDS_NFM_UPDATE_COL:
			case VDS_NFM_DELETE_COL:
				VDSadd_buffer_string(string1, &char_index,"Y");
				break;

			case VDS_NFM_REQ_COL:
				VDSadd_buffer_string(string1, &char_index,"N");
				break;

                        case VDS_NFM_LISTNO_COL:
				VDSadd_buffer_string(string1, &char_index,"0");
				break;

			case VDS_NFM_SEQNO_COL:
                                seq_number = dynamic_row + 1;
				sprintf(seq_no,"%d",seq_number);
				VDSadd_buffer_string(string1, &char_index,
							seq_no);
                                break;

                        default:
				string1[char_index++] = VDS_BUFFER_TERM;
				break;

	              } /* end switch */
                 } /* end for col < VDS_NFM_COLS */

            MEMstatus = MEMwrite(dyn_attr, string1);
            if( MEMstatus != MEM_S_SUCCESS ) {
	      status = VDS_E_WRITE_BUFFER;
              VDSprintMemErr( "\t", "MEMwrite", MEMstatus, status);
              goto quit;
	    }

	    /* Prepare the row for the default dynamic data  */
	    strcat( dyn_data_row,
		    parameters[(parm_bufr->columns * row)+VDS_PARAVAL_COL] );
	    strcat( dyn_data_row, ONE );

          } /* if IO type == DYNAMIC */
      } /* end for row < parm_bufr->rows */

    MEMstatus = MEMbuild_array ( dyn_attr);
    if( MEMstatus != MEM_S_SUCCESS ) {
      status = VDS_E_BUILD_BUFFER_ARRAY;
      VDSprintMemErr( "\t", "MEMbuild_array", MEMstatus, status);
      goto quit;
    }

   /* fill output MEMptr bufr */
   *p_dyn_attr = dyn_attr;
   *p_loc_attr_bufr = loc_attr;
   *p_loc_data_bufr = loc_data;
   *p_cat_attr_bufr = cat_attr;
   *p_cat_data_bufr = cat_data;
   *p_cat_list_bufr = cat_list;

quit :
   _FREE(string1);
   _FREE(string);

   VDSdebug("EXIT: VDScreate_family_catalog\n");
   return( status);
}
