/* $Id: VDSquery.C,v 1.1.1.1 2001/01/04 21:07:57 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdcheckin/func / VDSquery.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSquery.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:57  cvs
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
 * Revision 1.2  1996/05/08  15:58:40  pinnacle
 * Replaced: vdcheckin/func/VDSquery.C for:  by sljenks for vds.240
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

/* cvr   modification  changed filename to VDSquery.C.
 * The file was originally query.c. This was done since macros
 * from file vdbmacros.h were included. Hence a .c would not
 * accomodate the include file because of #omdef. The .m file
 * therefore has also been modified.
 */
 
#include        <stdio.h>

#include        "VDSris_def.h"
#include        "VDSris_siz.h"

#include        "vdbmacros.h"

#define         AS_DEBUG        1

extern char     Ris_SchemaName[];

int VdsRetrievePartAttributes ( catalog, part_num, revision, io_status,
                                checkin_user,checkout_user,checkout_node,
                                checkout_dir,err_msg)

char        catalog[];          /* Catalog                              (I)*/
char        part_num[];         /* Part Number                          (I)*/
char        revision[];         /* Revision                             (I)*/
char        io_status[3];       /* Checked In or Checked Out (NULL if   (O)*/
                                /* never checked in)                       */
char        checkin_user[15];   /* User who checked part in (NULL if    (O)*/
                                /* never checked in)                       */
char        checkout_user[15];  /* User who checked part out (NULL if   (O)*/
                                /* never checked out)                      */
char        checkout_node[31];  /* Nodename where part is checked out   (O)*/
                                /* (NULL if not checked out)               */
char        checkout_dir[81];   /* Directory where part is checked out  (O)*/
                                /* (NULL if not checked out)               */
char        err_msg[101];	/* Output error message                 (O)*/

/*		Returns SUCCESS if ok
			FAILURE if not */
 {
        int                p_num;
        char               n_itemno[10];
        char               f_table[50];
        char               n_cosano[10];
        char               n_nodeno[10];
	char		   n_fileversion[10];
        int                status;
        char               where[MAXBUFF];
        char               **buffer;
	int		   buffer_size;

        strcpy(io_status    ,"");
        strcpy(checkin_user ,"");
        strcpy(checkout_user,"");
        strcpy(checkout_node,"");
        strcpy(checkout_dir ,"");
        strcpy(err_msg ,"");
	buffer_size = 0;

        /*|Open the RIS schema */
        if (VdsRisAttach() != SUCCESS)
        { sprintf(err_msg,"Error in VdsRisAttach"); return FAILURE; }

        sprintf ( where, "n_itemname=\'%s\' and n_itemrev=\'%s\'", part_num,
                  revision);

        status = vdb$RisSelect ( select       =       "n_itemno,n_status",
                                 table_name   =       catalog,
                                 where        =       where,
                                 order        =       NULL,
                                 group        =       NULL,
                                 numselect    =       2,
                                 p_numrows    =       &p_num,
                                 p_buffer     =       &buffer );
	buffer_size = 2 * p_num;
        if (status == FAILURE)
        {
           sprintf(err_msg,"Error in VdsRisSelect");
           goto error;
        }

        if (p_num == 0)
        {
           sprintf(err_msg,"Part %s rev %s not found in catalog %s",
                   part_num,revision,catalog);
           status = FAILURE;
 	   goto error;
        }
        status = vdb$RisExtractValue ( nbrows    =   p_num,
                                       nbcolumns =   2,
                                       buffer    =   buffer,
                                       row       =   0,
                                       column    =   0,
                                       value     =   n_itemno ); 
        if (status != SUCCESS)
        {
           printf("VdsRisExtractValue failed to fetch n_itemno\n");
           goto error;
        }
        
       status = vdb$RisExtractValue ( nbrows   =   p_num,
                                      nbcolumns =   2,
                                      buffer    =   buffer,
                                      row       =   0,
                                      column    =   1,
                                      value     =   io_status );

        if (status != SUCCESS)
        {
           printf("VdsRisExtractValue failed to fetch io_status\n");
           goto error;
        }

        vdb$RisFreeBuffer ( buffer     =        buffer, 
                            size       =        2 * p_num );

        sprintf ( where, "n_itemnum=%s", n_itemno);
        sprintf ( f_table, "f_%s", catalog);

	/* Select the Maximum file version for this part */
        status = vdb$RisSelect (  select      =    "max(n_fileversion)",
                                  table_name  =    f_table,
                                  where       =    where,
                                  order       =    NULL,
                                  group       =    NULL,
                                  numselect   =    1,
                                  p_numrows   =    &p_num,
                                  p_buffer    =    &buffer );
	buffer_size = 1 * p_num;
        if (status == FAILURE)
        {
           sprintf(err_msg,"Error in VdsRisSelect");
           goto error;
        }

        if (p_num == 0)
        {
           sprintf(err_msg,"Part %s rev %s not found in table f_%s",
                   part_num,revision,catalog);
           status = FAILURE;
	   goto error;
        }

	strcpy( n_fileversion, buffer[0] );

        vdb$RisFreeBuffer ( buffer     =        buffer, 
                            size       =        1 * p_num );

	/* Retrieve the ciuser, couser and the storage area */
        sprintf ( where, "n_itemnum=%s and n_fileversion=%s", 
					n_itemno,n_fileversion);

        status = vdb$RisSelect ( select     =     "n_ciuser,n_couser,n_cosano",
                                 table_name =      f_table,
                                 where      =      where,
                                 order      =      NULL,
                                 group      =      NULL,
                                 numselect  =      3,
                                 p_numrows  =      &p_num,
                                 p_buffer   =      &buffer );
        buffer_size = 3 * p_num;
        if (status == FAILURE)
        {
           sprintf(err_msg,"Error in VdsRisSelect");
           goto error;
        }

        if (p_num == 0)
        {
           sprintf(err_msg,"Part %s rev %s not found in table f_%s",
                   part_num,revision,catalog);
           status = FAILURE;
	   goto error;
        }
        status = vdb$RisExtractValue ( nbrows    =     p_num,
                                       nbcolumns =     3,
                                       buffer    =     buffer,
                                       row       =     0,
                                       column    =     0,
                                       value     =     checkin_user ); 
        if (status != SUCCESS)
        {
           printf("VdsRisExtractValue failed to fetch checkin_user\n");
           goto error;
        }
        
        status = vdb$RisExtractValue ( nbrows     =      p_num,
                                       nbcolumns  =      3,
                                       buffer     =      buffer,
                                       row        =      0,
                                       column     =      1,
                                       value      =      checkout_user ); 
        if (status != SUCCESS)
        {
           printf("VdsRisExtractValue failed to fetch checkout_user\n");
           goto error;
        }

        status = vdb$RisExtractValue ( nbrows       =        p_num,
                                       nbcolumns    =        3,
                                       buffer       =        buffer,
                                       row          =        0,
                                       column       =        2,
                                       value        =        n_cosano ); 
        if (status != SUCCESS)
        {
           printf("VdsRisExtractValue failed to fetch n_cosano\n");
           goto error;
        }

        vdb$RisFreeBuffer (  buffer     =       buffer,
                             size       =       buffer_size);

        if (!strcmp(io_status, "O") || !strcmp(io_status, "S"))
        {
           sprintf ( where, "n_sano=%s", n_cosano);
           status = vdb$RisSelect ( select     =     "n_nodeno,n_pathname",
                                    table_name =     "nfmstoragearea",
                                    where      =      where,
                                    order      =      NULL,
                                    group      =      NULL,
                                    numselect  =      2,
                                    p_numrows  =      &p_num,
                                    p_buffer   =      &buffer );
	   buffer_size = 2 * p_num;
           if (status == FAILURE)
           {
              sprintf(err_msg,"Error in VdsRisSelect");
              goto error;
           }

           if (p_num == 0)
           {
              sprintf(err_msg,"Storage area %s not found in table nfmstoragearea",
                      n_cosano);
              status = FAILURE;
 	      goto error;
           }

           status = vdb$RisExtractValue ( nbrows    =      p_num,
                                          nbcolumns =      2,
                                          buffer    =      buffer,
                                          row       =      0,
                                          column    =      0,
                                          value     =      n_nodeno ); 
           if (status != SUCCESS)
           {
             printf("VdsRisExtractValue failed to fetch n_nodeno\n");
             goto error;
           }

           status = vdb$RisExtractValue ( nbrows      =      p_num,
                                         nbcolumns   =      2,
                                         buffer      =      buffer,
                                         row         =      0,
                                         column      =      1,
                                         value       =      checkout_dir ); 
           if (status != SUCCESS)
           {
             printf("VdsRisExtractValue failed to fetch checkout_dir\n");
             goto error;
           }

           vdb$RisFreeBuffer ( buffer   =     buffer,
                               size     =     buffer_size);

           sprintf ( where, "n_nodeno=%s", n_nodeno);
           status = vdb$RisSelect ( select      =         "n_nodename",
                                    table_name  =         "nfmnodes",
                                    where       =         where,
                                    order       =         NULL,
                                    group       =         NULL,
                                    numselect   =         1,
                                    p_numrows   =         &p_num,
                                    p_buffer    =         &buffer );
	   buffer_size = 1 * p_num;
           if (status == FAILURE)
           {
              sprintf(err_msg,"Error in VdsRisSelect");
              goto error;
           }

           if (p_num == 0)
           {
              sprintf(err_msg,"Node %s not found in table nfmnodes", n_nodeno);
              status = FAILURE;
	      goto error;
           }
           status = vdb$RisExtractValue (  nbrows       =       p_num,
                                           nbcolumns    =       1,
                                           buffer       =       buffer,
                                           row          =       0,
                                           column       =       0,
                                           value        =       checkout_node ); 
           if (status != SUCCESS)
           {
             printf("VdsRisExtractValue failed to fetch checkout_node\n");
             goto error;
           }

           vdb$RisFreeBuffer ( buffer  =      buffer,
                               size    =      buffer_size);
        }

        return (status);
   
error:
        if (buffer != NULL )
         {
	   vdb$RisFreeBuffer (buffer = buffer,
	                      size   = buffer_size );
	 }

        return (status);
 }
