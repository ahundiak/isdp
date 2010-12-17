#include <stdio.h>
#include "SQLerrordef.h"
#include "PDMdbs_err.h"
#include "MEMerrordef.h"
#include "MEMstruct.h"
#include "PDUerror.h"
#include "PDMproto.h"
#include "PDUpdmrpro.h"
#include "NFMerrordef.h"

extern int	PDMdebug_on;
extern char PDM_DEBUG_FILE[];
extern PDMexec_ptr PDMexec;

 /* APOGEE START static	long   RIScode; APOGEE END */
static	long   status;
static	char   s[1024];


/* Returns all the families defined for a particular
   Library. PDMexec->catalog is "pdmlibraries"
			PDMexec->part_num
			PDMexec->revision specify the library 

   Return Codes.

	PDM_E_LIBRARY_NOT_FOUND
	PDM_I_NO_FAMILIES_DEFINED
	PDM_S_SUCCESS
*/

int	PDMsget_families(bufr)
	MEMptr	*bufr;
{

	PDMdebug("ENTER:PDMsget_families\n");
	status = PDMi_query_families(PDMexec->catalog,
								 PDMexec->part_num,
								 PDMexec->revision,0,bufr);
	if(status != PDM_S_SUCCESS)
	{
		sprintf(s,"PDMi_query_families failed status %d\n",
		status); PDMdebug(s);
		return(status);
	}
	PDMdebug("EXIT:PDMsget_families\n");
	return(PDM_S_SUCCESS);
}


int PDMi_create_family(user_id,catalog,
					   part_num,part_rev,
					   fly_name,fly_desc,
					   loc_attr,loc_data,
					   catalog_buffer,catalog_data,catalog_lists,
					   parm_bufr,prompt_bufr)
	long		user_id;
	char		*catalog;
	char		*part_num;
	char		*part_rev;
	char		*fly_name;
	char		*fly_desc;
	MEMptr		parm_bufr;
	MEMptr		prompt_bufr;
	MEMptr		loc_attr;
	MEMptr		loc_data;
	MEMptr		catalog_buffer;
	MEMptr		catalog_data;
	MEMptr		catalog_lists;
{
	char		sql_str[1024], str1[512];
/* APOGEE START char		**data, **data1, **data2; APOGEE END */
	char		**data1;
/* APOGEE START int			i, j, nxi, nxj; APOGEE END */
	int			i, nxi;
	int			p_seqno, sts = 0, n_catalogno;
	int			p_familyno, p_libraryno, p_parameterno;
	char		pdc_table[20];

    PDMdebug("ENTER:PDMi_create_family \n");

   if(PDMdebug_on)
   {
		MEMprint_buffer("parm_buffer",parm_bufr,PDM_DEBUG_FILE);
		MEMprint_buffer("prompt_buffer",prompt_bufr,PDM_DEBUG_FILE);
		MEMprint_buffer("loc_attr",loc_attr,PDM_DEBUG_FILE);
		MEMprint_buffer("loc_data",loc_data,PDM_DEBUG_FILE);
		MEMprint_buffer("catalog_buffer",catalog_buffer,PDM_DEBUG_FILE);
		MEMprint_buffer("catalog_data",catalog_data,PDM_DEBUG_FILE);
   }

	/* Set p_libraryno */

    status = PDMquery_partno(catalog,
							 part_num,
							 part_rev,
							 &p_libraryno);
    if(status != PDM_S_SUCCESS)
    {
		sprintf(s,"PDMquery_partno failed : status %d\n",status);
		PDMdebug(s);
		return(status);		
    }

   /* See if macro name is within limits */

   if(strlen(fly_name) > 14)
   {
		PDMdebug("Family_name is too big to create pdc table\n");
		return(PDM_E_FAILURE);
   }

/* PARIS BETH should check for empty buffer */
   pdc_table[0] = '\0';

   if (prompt_bufr->rows)
      {
	   status = MEMbuild_array(prompt_bufr);
	   if(status != MEM_S_SUCCESS)
	   {
	       sprintf(s,"\tMEMbuild_array failed : status %d\n",status);
	       PDMdebug(s);
	       status = PDM_E_BUILD_ARRAY;
		return(status);
	   }

	   /* create pdc_familyname table */

	   sprintf(pdc_table,"y_%s",fly_name);
	   status = PDMi_create_pdc_table(user_id,
								pdc_table,
								parm_bufr,
								prompt_bufr);
	   if(status != PDM_S_SUCCESS)
	   {
		sprintf(s,
		"PDMi_create_pdc_table failed status %d\n",status);
		PDMdebug(s);
		return(status);
	   }
      }
/* PARIS BETH end */

   /* create parametric part catalog */

   status = PDMi_create_catalog(user_id,
								loc_attr,
								loc_data,
								catalog_buffer,
								catalog_data,
								catalog_lists,
                                                                 NULL,NULL);
   if(status != PDM_S_SUCCESS)
   {
        sprintf(s,"PDMi_create_catalog failed : status %d\n",
		status);
        PDMdebug(s);
		goto wrapup;
   }

   /* Turn off AUTO_COMMIT */

   status = PDMstop_transaction(1200);
   if(status != PDM_S_SUCCESS)
   {
        sprintf(s,"PDMstop_transaction failed : status %d\n",status);
        PDMdebug(s);
		goto wrapup1;
   }

   /* add family-entry to pdmfamilies table */

   status = PDMi_maxrow_no("pdmfamilies","p_familyno",&p_familyno);
   if(status != PDM_S_SUCCESS)
   {
	  sprintf(s,"PDMi_maxrow_no failed status %d\n",status);
	  PDMdebug(s);
	  goto wrapup2;
   }	

   p_familyno = p_familyno + 1;
	
   sprintf(sql_str,"%s (%s) VALUES (%d,%d,'%s','%s')",
   "INSERT INTO pdmfamilies ",
   "p_familyno,p_libraryno,p_familyname,p_familydesc ",
   p_familyno,p_libraryno,fly_name,fly_desc);
   status = SQLstmt(sql_str);
   if(status != SQL_S_SUCCESS)
   {
	 sprintf(s,"SQLstmt failed status %d\n",status);
	 PDMdebug(s);
	 status = PDM_E_SQL_STMT;
	 goto wrapup2;
   }

   /* add parameters to pdmparameters table */

   p_seqno = 0;

   sprintf(str1,"%s (%s,%s) ",
   "INSERT INTO pdmparameters ",
   "p_parameterno,p_familyno,p_seqno",
   "p_name,p_parametertype,p_iotype");

   status = MEMbuild_array(parm_bufr);
   if(status != MEM_S_SUCCESS)
   {
       sprintf(s,"\tMEMbuild_array failed : status %d\n",
		status);
       PDMdebug(s);
       status = PDM_E_BUILD_ARRAY;
	   goto wrapup2;
   }
   data1 = (char **) parm_bufr->data_ptr;
   for(i=0;i<parm_bufr->rows;i++)
   {
		nxi = i * parm_bufr->columns;
/* BETH iotype is in 4th col
           if(!strcmp(data1[nxi + 3],"UD"))
*/
           if(strcmp(data1[nxi + 4],"UD"))
           {
             p_seqno = p_seqno + 1;
	    status = PDMi_maxrow_no("pdmparameters",
						   "p_parameterno",
						   &p_parameterno);
 	    if(status != PDM_S_SUCCESS)
  	 	{
	  		sprintf(s,"PDMi_maxrow_no failed status %d\n",status);
	  		PDMdebug(s);
	  		goto wrapup2;
   		}	
		sprintf(sql_str,"%s VALUES(%d,%d,%d,'%s','%s','%s')",
		str1,p_parameterno+1,p_familyno,p_seqno,data1[nxi+1],
		data1[nxi+3],data1[nxi+4]);
		status = SQLstmt(sql_str);
		if(status != SQL_S_SUCCESS)
		{
			sprintf(s,"SQLstmt failed status %d\n",status);
			PDMdebug(s);
			status = PDM_E_SQL_STMT;
			goto wrapup2;
		}
            }
   }

   /* commit work */

   status = PDMstart_transaction(1200);
   if(status != PDM_S_SUCCESS)
   {
        sprintf(s,"PDMstart_transaction failed : status %d\n",status);
        PDMdebug(s);
        goto wrapup2;
   }
   PDMdebug("EXIT:PDMi_create_family\n");
   return(PDM_S_SUCCESS);

wrapup2:

	PDMrollback_transaction(1200);

wrapup1:

	sts = NFMdelete_catalog(user_id,fly_name,&n_catalogno);
	if(sts != NFM_S_SUCCESS)
	{
		sprintf(s,"Failed to delete catalog %s\n",fly_name);
		PDMdebug(s);
		sprintf(s,"NFMdelete_catalog failed status %d\n",sts);
		PDMdebug(s);
	}

wrapup:

	/* drop table pdc_table */

	if(strlen(pdc_table))
	sts = NFMdelete_table(user_id,pdc_table,pdc_table);
	if(sts != NFM_S_SUCCESS)
	{
		sprintf(s,"Failed to delete table %s\n",pdc_table);
		PDMdebug(s);
		sprintf(s,"NFMdelete_table failed status %d\n",sts);
		PDMdebug(s);
	}	
	return(status);
}

