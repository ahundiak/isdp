#include                <stdio.h>
#include		"SQLerrordef.h"
#include 		"MEMerrordef.h"
#include 		"NFMerrordef.h"
#include                "MEMstruct.h"
#include		"PDMdbs_err.h"
#include		"PDUerror.h"
#include		"PDMproto.h"

static char		s[1024];
static long		status;
/*static int		curbuf_no;*/
extern		int		PDMdebug_on;
extern		char	PDM_DEBUG_FILE[];
extern PDMexec_ptr PDMexec;


/* 
   Kumar Narayanan - 10.10.91

   The BOM content is first defined during PDM initialization.
   It contains all the req & user attrbs that go into a BOM generation.
   Later on, the content of the BOM can be modified.  All the attributes 
   that have a 2 nd character == "_" are unchangable by the user, 
   But the synonyms may be changed. The 
   user defined attributes can be modified, added, or dropped.
   However, since PDM req. attrbs in pdmbomcontent have n_delete 
   set to 'N', PDU can keep up with user attrbs by setting n_delete
   to 'Y' every time pdmbomcontent is modified.

 
   NOTE :

   The template stores the Names (req + user) along with 
   the corresponding DATATYPE. Eventhough the user attrbs come 
   from different catalogs/columns they all have the same datatype
   in BOM tables.

   The pdmbommap stores all the mappings in the product.
 
   Every time the template is modified the pdmbommap table is 
   updated. 

   FOR ACTUAL BOM GENERATION : 
	
		"pdmbomcontent" wil determine the required and user attribute 
	names and datatypes to create BOM table.

        "pdmbommap" will determine the content of user defined 
	attributes. If the size of the actual data is greater than that 
    can be stored in BOM-table it will be truncated.
  
   The ws_buffer contains attribute and data buffers from a 
   previous call to NFMquery_change_template_information()
*/

int PDMsmodify_bom_content(attr_bufr, data_bufr, list_bufr, bommap_bufr)
MEMptr		attr_bufr;
MEMptr		data_bufr;
MEMptr		list_bufr;
MEMptr          bommap_bufr;
{
        char            *fname = "PDMsmodify_bom_content";
	MEMptr		attr_bufr1 = NULL;
        MEMptr          bufr = NULL;
        char            sql_str[1024];
        char            sql_str1[512];
        char            sql_str2[512];
        char            **data, **column_ptr, **column;
        char            **bufr_data;
        int             n1 = 0, n2, n3, n4 = 0;
        int		c1 = -1, c2 = -1, c3 =0, c4 =0, c5 = 0;
        int             i, nxi;
        int             p_catalogno, p_bomattrno, n_tmpltno;

    _PDMdebug(fname, "ENTER:\n");

    status = MEMbuild_array(attr_bufr);
    if(status != MEM_S_SUCCESS)
     {
      _PDMdebug(fname, "MEMbuild_array failes status <0x%.8x>\n", status);
      return(status);
      }
      column = (char **) attr_bufr->column_ptr;

     for(i=0; i < attr_bufr->columns; i++)
     {
      if(!strcmp(column[i], "n_advice")) n1= i;
      else if(!strcmp(column[i], "new_n_valueno")) n3= i;
      else if(!strcmp(column[i], "n_valueno")) n4= i;
      else if(!strcmp(column[i], "new_n_advice")) n2= i;
     }
     for(i=0; i < attr_bufr->rows; i++)
     {
        MEMwrite_data(attr_bufr, "0", i+1, n1+1);
        MEMwrite_data(attr_bufr, "0", i+1, n4+1);
     }
if(PDMdebug_on)
{
	MEMprint_buffer("attr_bufr", attr_bufr, PDM_DEBUG_FILE);
	MEMprint_buffer("data_bufr", data_bufr, PDM_DEBUG_FILE);
	MEMprint_buffer("bommap_bufr", bommap_bufr, PDM_DEBUG_FILE);
}

   status = NFMchange_template ("bom_template", "t_appltable", "BOM", attr_bufr, data_bufr, list_bufr);
   if(status != NFM_S_SUCCESS)
   {
        _PDMdebug(fname, "%s %s %d %s", 
		"PDMsmodify_bom_content : NFMchange_template ", 
		" failed : status", status, "\n");
       return(PDM_E_MODIFY_TEMPLATE);
   }
   if(bommap_bufr != NULL)
   {
status = MEMopen(&bufr, 1024);
   if(status != MEM_S_SUCCESS)
   {
       _PDMdebug(fname, "MEMopen failed status %d\n", status);
                return(PDM_E_OPEN_BUFFER);
   }
   status = MEMwrite_format(bufr, "p_bomattrno", "integer");
   if(status == MEM_S_SUCCESS)
   status = MEMwrite_format(bufr, "p_catalogno", "integer");
   if(status == MEM_S_SUCCESS)
   status = MEMwrite_format(bufr, "p_mapattrno", "integer");
   if(status == MEM_S_SUCCESS)
   status = MEMwrite_format(bufr, "n_name", "char(20)");
   if(status != MEM_S_SUCCESS)
   {
                MEMclose(&bufr);
                _PDMdebug(fname, "MEMwrite_format failed status %d\n", status);
                return(PDM_E_WRITE_FORMAT);
   }
        status = MEMbuild_array(bommap_bufr);
        if(status != MEM_S_SUCCESS)
        {
                _PDMdebug(fname, "MEMbuild_array failed status %d\n", status);
                MEMclose(&bufr);
                      return(PDM_E_BUILD_ARRAY);
        }
      if(bommap_bufr->rows > 0)
     {
        data = (char **) bommap_bufr->data_ptr;
        column_ptr = (char **) bommap_bufr->column_ptr;
        c1 = -1; c2 = -1;
        for(i=0;i<bommap_bufr->columns;i++)
        {
         if(!strcmp(column_ptr[i], "p_bomattrno")) c1 = i;
        else  if(!strcmp(column_ptr[i], "p_attrname")) c2 = i;
        else  if(!strcmp(column_ptr[i], "n_catalogno")) c3 = i;
        else  if(!strcmp(column_ptr[i], "n_catalogname")) c4 = i;
        else   if(!strcmp(column_ptr[i], "p_mapattrno")) c5 = i;
        }

        if(c1 == -1 || c2 == -1)
        {
                _PDMdebug(fname, "Could not set offsets in attr_bufr1\n");
                return(PDM_E_BUFFER_FORMAT);
        }
        status = PDMget_table_no("bom_template", "t_appltable", &n_tmpltno);
        if(status != PDM_S_SUCCESS)
        {
                sprintf(s, "PDMget_table_no failed status %d\n", 
                status);PDMdebug(s);
                return(status);
        }

        /* get all user defined attribute names into bufr */

        data = (char **) bommap_bufr->data_ptr;
        for(i=0;i< bommap_bufr->rows;i++)
        {
                 nxi = i * bommap_bufr->columns;

                p_catalogno = 0;
                p_bomattrno=0;
               if(!strcmp(data[nxi+c3], ""))
                    {
             status = PDMris_get_catno(data[nxi+c4], &p_catalogno);
                      if(status != SQL_S_SUCCESS)
                      {
                      MEMclose(&bufr);
      _PDMdebug(fname, "%s %d\n", "PDMget_attribute_no failed status ", status);
                      continue;
                      }
                    }
                    else p_catalogno = atoi(data[nxi+c3]);
               if(!strcmp(data[nxi+c1], ""))
                    {
   status = PDMget_attribute_no(n_tmpltno, data[nxi+c2], &p_bomattrno);
                      if(status != PDM_S_SUCCESS)
                      {
                      MEMclose(&bufr);
      _PDMdebug(fname, "%s %d\n", "PDMget_attribute_no failed status ", status);
                      continue;
                      }
                     }
                    else p_bomattrno = atoi(data[nxi+c1]);
            if(p_catalogno != 0 && p_bomattrno != 0)
            {
         sprintf(s, "%d\1%d\1%s\1\1", p_bomattrno, p_catalogno, data[nxi+c5]);
                        status = MEMwrite(bufr, s);
                        if(status != MEM_S_SUCCESS)
                        {
                       MEMclose(&attr_bufr1);
                        MEMclose(&bufr);
                        _PDMdebug(fname, "MEMwrite failed status %d\n", status);
                         return(PDM_E_WRITE_ROW);
                        }
               }
               /*   } If it's not a system attribute */
        }/* End of for loop */
    MEMclose(&attr_bufr1);
        status = MEMbuild_array(bufr);
    if(status != MEM_S_SUCCESS)
        {
                _PDMdebug(fname, "MEMbuild_array failed status %d\n", status);
                MEMclose(&bufr);
                return(PDM_E_BUILD_ARRAY);
        }

        bufr_data = (char **) bufr->data_ptr;
        data = (char **) attr_bufr->data_ptr;

if(PDMdebug_on)
MEMprint_buffer("bufr with all the data", bufr, PDM_DEBUG_FILE);

   /* delete any previous entry for this catalog */

   status = PDMstop_transaction(1200);
   if(status != PDM_S_SUCCESS)
   {
           _PDMdebug(fname, "PDMstop_transaction failed status %d\n", status);
           MEMclose(&bufr);
           return(status);
   }

    /* insert the new entry for this catalog */

   sprintf(sql_str1, "%s %s ", "INSERT INTO pdmbommap ", 
   "(p_bomattrno, n_catalogno, p_mapattrno)");
   for(i=0;i<bufr->rows;i++)
   {
        nxi = i * bufr->columns;
        if (strcmp(bufr_data[nxi+2], "0"))
          {
       sql_str[0]='\0';
sprintf(sql_str, "DELETE from PDMBOMMAP where p_bomattrno = %s and n_catalogno = %s", bufr_data[nxi], bufr_data[nxi+1]);
                SQLstmt(sql_str);
       sql_str[0]='\0';
                sprintf(sql_str2, "VALUES(%s, %s, %s)", 
                bufr_data[nxi+0], bufr_data[nxi+1], bufr_data[nxi+2]);
                sprintf(sql_str, "%s %s", sql_str1, sql_str2);
                status = SQLstmt(sql_str);
                if(status != SQL_S_SUCCESS)
                {
                   MEMclose(&bufr);
                   switch (status)
                   {
                         case PDMS_NO_SUCH_ATTRIBUTE:
                                PDMdebug("Unknown Column \n");
                                status = PDM_E_REQ_COLUMN_NOT_FOUND;
                                goto wrapup;
                        case PDMS_NO_SUCH_TABLE:
                                PDMdebug("Unknown Relation \n");
                                status = PDM_E_UNKNOWN_TABLE;
                                goto wrapup;
                        default:
                                goto wrapup;
                  }
                }
        }
      }
     }
   MEMclose(&bufr);
    }
   status = PDMstart_transaction(1200);
   if(status != PDM_S_SUCCESS)
   {
    _PDMdebug(fname, "PDMstart_transaction failed status %d\n", status);
     goto wrapup;
   }
   _PDMdebug(fname, "EXIT:-SUCCESS\n");
   return(PDM_S_SUCCESS);
 wrapup:

    _PDMdebug(fname, "Rolling Back\n");
   status = PDMrollback_transaction(1200);
   if(status != PDM_S_SUCCESS)
   {
   }
   return(status);
}

/*
	Query for a modify template attr_bufr of pdmbomcontent
    n_name contains the name of the attribute as in template 
	pdmbomcontent. n_datatype contains the datatype as in 
	pdmbomcontent. For all the attributes n_name = new_n_name
	For user defined attributes if mapping is present
        new_n_name is the name of the catalog attribute.
	If there is no mapping new_n_name is empty
*/

int  PDMsget_bommap_attributes(attr_bufr)
        MEMptr		*attr_bufr;
{
	MEMptr		nfm_bufr = NULL;
	MEMptr		data_bufr = NULL;
	MEMptr		list_bufr = NULL;
	MEMptr		bufr	= NULL;
	char		sql_str[512];
	char		n_name[40];
	char		**column_ptr;
	char		**data;
	char		**data1;
	int			p_catalogno;
	int			p_mapattrno;
	int			i, nxi;
	int			a1 = -1;
	int			a2 = -1;
	int			a3 = -1;

	PDMdebug("ENTER:PDMsget_bommap_attributes\n");

	*attr_bufr = NULL;

	status = PDMverify_catalog(PDMexec->catalog);
        if(status != PDM_S_SUCCESS)
 	{
		PDMdebug("Required catalog does not exist\n");
		return(status);
        }
    status = PDMquery_catalogno(PDMexec->catalog, &p_catalogno);
    if(status != PDM_S_SUCCESS)
        {
	 	sprintf(s, "PDMquery_catalogno failed status %d\n", status);
		PDMdebug(s);
		return(status);
        }
	status = NFMquery_change_template_information
		    ("t_appltable", "bom_template", "BOM", 
			&nfm_bufr, &data_bufr, &list_bufr);
	if(status != NFM_S_SUCCESS)
	{
	    MEMclose(&nfm_bufr);
		MEMclose(&data_bufr);
		MEMclose(&list_bufr);
		sprintf(s, "%s %s %d \n", 
		"NFMquery_change_template_information ", 
		"failed status ", status);
		PDMdebug(s);
		return(PDM_E_QUERY_MODIFY_TABLE_ATTR);
	}			
	MEMclose(&data_bufr);
	MEMclose(&list_bufr);

	status = PDMmodify_attribute_buffer(nfm_bufr, attr_bufr);
	if(status != PDM_S_SUCCESS)
	{
		MEMclose(&nfm_bufr);
		sprintf(s, "MEMbuild_array failed status %d\n", 
		status); PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
	}
	MEMclose(&nfm_bufr);    

	/* Check if any mapping exists for the catalog */

	sprintf(sql_str, "%s %d", 
	"SELECT n_catalogno FROM pdmbommap WHERE p_catalogno = ", 
	p_catalogno);
	status = SQLquery(sql_str, &bufr, 512);
	if(status != SQL_S_SUCCESS)
	{
		if(status != SQL_I_NO_ROWS_FOUND)
		{
			MEMclose(&bufr);
			sprintf(s, "SQLquery failed status %d\n", status);
			PDMdebug(s);
			return(PDM_E_SQL_QUERY);
		}
		else
		{
			MEMclose(&bufr); 
if(PDMdebug_on)
MEMprint_buffer("no mapping:attr_bufr", *attr_bufr, PDM_DEBUG_FILE);
			PDMdebug("EXIT:PDMget_bom_map_attributes\n");
			return(PDM_S_SUCCESS);
		}
	}
	MEMclose(&bufr); bufr = NULL;

	/* Mapping exists */

if(PDMdebug_on)
MEMprint_buffer("before mapping attr_bufr", *attr_bufr, PDM_DEBUG_FILE);

	status = MEMbuild_array(*attr_bufr);
	if(status != MEM_S_SUCCESS)
	{
		sprintf(s, "MEMbuild_array failed status %d\n", 
		status); PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
	}
	column_ptr = (char **) (*attr_bufr)->column_ptr;
    for(i=0;i<(*attr_bufr)->columns;i++)
    {
		if(!strcmp(column_ptr[i], "n_name"))  	 	a1 = i;
		if(!strcmp(column_ptr[i], "n_attrno"))  		a2 = i;
		if(!strcmp(column_ptr[i], "new_n_name"))  	a3 = i;
    }
    if(a1 == -1 || a2 == -1 || a3 == -1)
    {
		PDMdebug("Failed to set offsets attr_bufr\n");
		return(PDM_E_BUFFER_FORMAT);
    }
	data = (char **) (*attr_bufr)->data_ptr;

	/* set new_n_name = "" for user def. attributes */

	for(i=0;i<(*attr_bufr)->rows;i++)
	{
		nxi = i * (*attr_bufr)->columns;
		if(strncmp(data[nxi+a1], "n_", 2))
		{
			status = MEMwrite_data(*attr_bufr, "", i+1, a3+1);
			if(status != MEM_S_SUCCESS)
			{
				sprintf(s, "%s %d\n", 
			    "MEMwrite_data failed status ", status);
				PDMdebug(s);
				return(PDM_E_WRITE_COLUMN);
			}			
		}
    }
	for(i=0;i<(*attr_bufr)->rows;i++)
	{
		nxi = i * (*attr_bufr)->columns;
		if(strncmp(data[nxi+a1], "n_", 2))
		{
			sprintf(sql_str, "%s %s %d %s %s", 
			"SELECT p_mapattrno FROM pdmbommap ", 
			"WHERE n_catalogno = ", p_catalogno, 
			"AND p_bomattrno = ", data[nxi+a2]);
			status = SQLquery(sql_str, &bufr, 512);
			if(status != SQL_S_SUCCESS)
			{
				if(status == SQL_I_NO_ROWS_FOUND)
				{
					MEMclose(&bufr); bufr = NULL;
					continue;
				}
				else
				{
					MEMclose(&bufr); 
					return(PDM_E_SQL_QUERY);
				}
			}
			else
			{
				status = MEMbuild_array(bufr);
				if(status != MEM_S_SUCCESS)
				{
					MEMclose(&bufr);
					sprintf(s, "MEMbuild_array failed status %d\n", 
					status);PDMdebug(s);
					return(PDM_E_BUILD_ARRAY);
				}	
				data1 = (char **) bufr->data_ptr;
				p_mapattrno = atoi(data1[0]);				
				MEMclose(&bufr); bufr = NULL;
				status = PDMget_attribute_name(p_catalogno, 
						 p_mapattrno, n_name);
				if(status != PDM_S_SUCCESS && 
				   status != PDM_I_ATTR_NOT_FOUND)
				{
					MEMclose(&bufr);
					sprintf(s, 
					"PDMget_attribute_name failed status %d\n", 
					status);PDMdebug(s);
					return(status);
				}
				else
				{
					status = MEMwrite_data
							(*attr_bufr, n_name, i+1, a3+1);
					if(status != MEM_S_SUCCESS)
					{
						sprintf(s, "%s %d\n", 
					    "MEMwrite_data failed status ", status);
						PDMdebug(s);
						return(PDM_E_WRITE_COLUMN);
					}
				}
		 	}
		}
	}
if(PDMdebug_on)
MEMprint_buffer("after mapping attr_bufr", *attr_bufr, PDM_DEBUG_FILE);
	PDMdebug("EXIT:PDMsget_bommap_attributes\n");
	return(PDM_S_SUCCESS);
}

/* 
   nfm_bufr is output from NFMquery_change_template()
   nfm_bufr doesn't contain the n_attrno

   The format of the nfm_bufr is copied and extended 
   by n_attrno. All the attributes (minus p_seqno, p_tagno, 
   n_level, p_parentno) are copied with their n_attrno set
*/

int	PDMmodify_attribute_buffer(nfm_bufr, attr_bufr)
MEMptr		nfm_bufr;
MEMptr		*attr_bufr;
{
	char		**column_ptr;
	char		**format_ptr;
	char		**data;
	int			i, j, nxi, a1, a2, a3;
	int			n_tableno;
	int			n_attrno;

	PDMdebug("ENTER PDMmodify_attribute_buffer\n");

	status = PDMget_table_no("t_appltable", 
			 "bom_template", &n_tableno);
	if(status != PDM_S_SUCCESS)
	{
		sprintf(s, "PDMget_table_no failed status %d\n", status);
		PDMdebug(s);
		return(status);
	}

	status = MEMbuild_array(nfm_bufr);
	if(status != MEM_S_SUCCESS)
	{
		sprintf(s, "MEMbuild_array failed status %d\n", status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
	}
	status = MEMopen(attr_bufr, 1024);
	if(status != MEM_S_SUCCESS)
	{
		sprintf(s, "MEMopen failed status %d\n", status);
		PDMdebug(s);
		return(PDM_E_OPEN_BUFFER);
	}
	column_ptr = (char **) nfm_bufr->column_ptr;
	a1 = -1; a2 = -1; a3 = -1;
	for(i=0;i<nfm_bufr->columns;i++)
	{
		if(!strcmp(column_ptr[i], "n_name"))
		{	
			a1 = i; 
		}
		if(!strcmp(column_ptr[i], "new_n_name"))
		{	
			a2 = i;
		}
	}
        if(PDMdebug_on)
        {

	MEMprint_buffer("nfm_bufr", nfm_bufr, PDM_DEBUG_FILE);
         }
	if(a1 == -1 || a2 == -1)
	{
		PDMdebug("failed to set offsets in nfm_bufr\n");
		MEMclose(attr_bufr);
		return(PDM_E_BUFFER_FORMAT);
	}
	format_ptr = (char **) nfm_bufr->format_ptr;
	status = MEMwrite_format(*attr_bufr, "n_attrno", "integer");
	if(status != MEM_S_SUCCESS)
	{
		sprintf(s, "MEMwrite_format failed status %d\n", status);
		PDMdebug(s);
		MEMclose(attr_bufr);
		return(PDM_E_WRITE_FORMAT);
	}
	for(i=0;i<nfm_bufr->columns;i++)
	{
		status = MEMwrite_format(*attr_bufr, 
					column_ptr[i], format_ptr[i]);
		if(status != MEM_S_SUCCESS)
		{
			sprintf(s, "MEMwrite_format failed status %d\n", status);
			PDMdebug(s);
			MEMclose(attr_bufr);
			return(PDM_E_WRITE_FORMAT);
		}
	}
	data = (char **) nfm_bufr->data_ptr;
	for(i=0;i<nfm_bufr->rows;i++)
	{
		nxi = i * nfm_bufr->columns;

	 	/* Eliminate the System Attributes */

		if(strcmp(data[nxi+a1], "p_seqno") 		&&
		   strcmp(data[nxi+a1], "p_tagno") 		&&
		   strcmp(data[nxi+a1], "n_level") 		&&
		   strcmp(data[nxi+a1], "p_parentno") 	&&
		   strcmp(data[nxi+a1], "p_catalogname") &&
		   strcmp(data[nxi+a1], "p_attached") 	&&
		   strcmp(data[nxi+a1], "p_history")		&&
		   strcmp(data[nxi+a1], "p_orient") 		&&
		   strcmp(data[nxi+a1], "p_quantity")	&&
		   strcmp(data[nxi+a1], "p_childno") 	&&
		   strcmp(data[nxi+a1], "p_usageid") 	&&
		   strcmp(data[nxi+a1], "p_viewid"))
		{
			status = PDMget_attribute_no(n_tableno, 
						data[nxi+a1], &n_attrno);
			if(status != PDM_S_SUCCESS)
			{
				sprintf(s, 
				"PDMget_attribute_no failed status %d\n", status);
				PDMdebug(s);
				return(status);
			}			
			sprintf(s, "%d\1", n_attrno);
			for(j=0;j<nfm_bufr->columns;j++)
			{
				strcat(s, data[nxi+j]);strcat(s, "\1");
			}
			status = MEMwrite(*attr_bufr, s);
			if(status != MEM_S_SUCCESS)
			{
				MEMclose(attr_bufr);
				sprintf(s, "MEMwrite failed status %d\n", status);
				PDMdebug(s);
				return(PDM_E_WRITE_ROW);
			}
		}
	}
	status = MEMbuild_array(*attr_bufr);
	if(status != MEM_S_SUCCESS)
	{
		sprintf(s, "MEMbuild_array failed status %d \n", status);
		PDMdebug(s);
		MEMclose(attr_bufr);
		return(PDM_E_BUILD_ARRAY);
	}
	column_ptr = (char **) (*attr_bufr)->column_ptr;
	data = (char **) (*attr_bufr)->data_ptr;
	a3 = -1; a1 = -1;
	for(i=0;i<(*attr_bufr)->columns;i++)
	{
		if(!strcmp(column_ptr[i], "n_name"))
		{	
			a1 = i; 
		}
		if(!strcmp(column_ptr[i], "new_n_name"))
		{	
			a3 = i; 
		}
	}
	if(a3 == -1 || a1 == -1)
	{
		PDMdebug("failed to set offsets in attr_bufr\n");
		MEMclose(attr_bufr);
		return(PDM_E_BUFFER_FORMAT);
	}

	/* For user defined attributes new_n_name = "" */

	for(i=0;i<(*attr_bufr)->rows;i++)
	{
		nxi = i * (*attr_bufr)->columns;

		if(strncmp(data[nxi+a1], "p_", 2))
		{
			status = MEMwrite_data(*attr_bufr, "", i+1, a3+1);
			if(status != MEM_S_SUCCESS)
			{
				sprintf(s, "MEMwrite_data failed status %d\n", 
				status);PDMdebug(s);
				MEMclose(attr_bufr);
				return(PDM_E_WRITE_COLUMN);
			}
		}
	}
	PDMdebug("EXIT PDMmodify_attribute_buffer\n");
	return(PDM_S_SUCCESS);
}

int	PDMmodify_dynamic_buffer(pdu_bufr, attr_bufr)
MEMptr		pdu_bufr;
MEMptr		*attr_bufr;
{
	char		**column_ptr;
	char		**format_ptr;
	char		**data;
	char		sql[1024];
	int			i, j, nxi;

	PDMdebug("ENTER PDMmodify_dynamic_buffer\n");

	status = MEMbuild_array(pdu_bufr);
	if(status != MEM_S_SUCCESS)
	{
		sprintf(s, "MEMbuild_array failed status %d\n", status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
	}
        if(PDMdebug_on)
        {

	MEMprint_buffer("pdu_bufr", pdu_bufr, PDM_DEBUG_FILE);
         }
	status = MEMopen(attr_bufr, 1024);
	if(status != MEM_S_SUCCESS)
	{
		sprintf(s, "MEMopen failed status %d\n", status);
		PDMdebug(s);

		return(PDM_E_OPEN_BUFFER);
	}
	format_ptr = (char **) pdu_bufr->format_ptr;
	column_ptr = (char **) pdu_bufr->column_ptr;
	for(i=0;i<pdu_bufr->columns;i++)
	{
		status = MEMwrite_format(*attr_bufr, 
					column_ptr[i], format_ptr[i]);
		if(status != MEM_S_SUCCESS)
		{
			sprintf(s, "MEMwrite_format failed status %d\n", status);
			PDMdebug(s);
			MEMclose(attr_bufr);
			return(PDM_E_WRITE_FORMAT);
		}
	}
	data = (char **) pdu_bufr->data_ptr;
	for(i=0;i<pdu_bufr->rows;i++)
	{
		nxi = i * pdu_bufr->columns;

                sql[0] = NULL;
	 	/* Eliminate the System Attributes */

		if(strcmp(data[nxi], "p_pdcno")) 
		{
			for(j=0;j<pdu_bufr->columns;j++)
			{
				strcat(sql, data[nxi+j]);strcat(sql, "\1");
			}
			status = MEMwrite(*attr_bufr, sql);
			if(status != MEM_S_SUCCESS)
			{
				MEMclose(attr_bufr);
				sprintf(s, "MEMwrite failed status %d\n", status);
				PDMdebug(s);
				
			}
		}
	}
        if(PDMdebug_on)
        {

	MEMprint_buffer("attr_bufr", *attr_bufr, PDM_DEBUG_FILE);
         }
	PDMdebug("EXIT PDMmodify_dynamic_buffer\n");
	return(PDM_S_SUCCESS);
}

int	PDMchange_attr_data(user_id, pdu_bufr, pdc_tbl, 
                            attr_bufr, data_bufr, value_bufr)
long            user_id;
MEMptr		pdu_bufr;
char            *pdc_tbl;
MEMptr		*attr_bufr;
MEMptr		*data_bufr;
MEMptr		*value_bufr;
{
	char		**column_ptr1;
	char		**format_ptr1;
	char		**data1;
	char		sql[1024];
	int			j, l, nxj;

	PDMdebug("ENTER PDMchange_attr_data\n");

	status = MEMbuild_array(pdu_bufr);
	if(status != MEM_S_SUCCESS)
	{
		sprintf(s, "MEMbuild_array failed status %d\n", status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
	}
	format_ptr1 = (char **) pdu_bufr->format_ptr;
	column_ptr1 = (char **) pdu_bufr->column_ptr;
	data1 = (char **) pdu_bufr->data_ptr;
        if(PDMdebug_on)
        {

	MEMprint_buffer("pdu_bufr", pdu_bufr, PDM_DEBUG_FILE);
         }
        status = NFMquery_change_table_information(user_id, "t_appltable", pdc_tbl, attr_bufr, data_bufr, value_bufr);
	if(status != NFM_S_SUCCESS)
         {
		MEMclose(attr_bufr); MEMclose(data_bufr);
		MEMclose(value_bufr);
		sprintf(s, "%s %s %s %d %s", 
		"PDMchange_attr_data : ", "NFMquery_change_table_attributes ", 
		"failed status ", status, "\n"); PDMdebug(s); return(status);
	}	
        if(PDMdebug_on)
        {
	MEMprint_buffer("attrribute bufr", *attr_bufr, PDM_DEBUG_FILE);
        }

	for(j=0;j<pdu_bufr->rows;j++)
	{
		nxj = j * pdu_bufr->columns;

	 	/* Eliminate the System Attributes */
                strcpy(sql, "");
		if(strcmp(data1[nxj], "p_pdcno")) 
		{
			for(l=0;l<pdu_bufr->columns;l++)
			{
				strcat(sql, data1[nxj+l]);strcat(sql, "\1");
			}
			for(l=pdu_bufr->columns;l<(*attr_bufr)->columns;l++)
			{
				strcat(sql, "\1");
			}
			status = MEMwrite(*attr_bufr, sql);
			if(status != MEM_S_SUCCESS)
			{
				MEMclose(attr_bufr);
				sprintf(s, "MEMwrite failed status %d\n", status);
				PDMdebug(s);
				
			}
		}
	}
        if(PDMdebug_on)
        {
	MEMprint_buffer("modified attrribute bufr", *attr_bufr, PDM_DEBUG_FILE);
	MEMprint_buffer("data bufr", *data_bufr, PDM_DEBUG_FILE);
        }
        status = PDMupdate_data_buffer(data_bufr, *attr_bufr);
	if(status != PDM_S_SUCCESS)
	{
		sprintf(s, "PDMupdate_data_buffer failed status %d\n", status);
		PDMdebug(s);
		return(status);
	}
        if(PDMdebug_on)
        {
	MEMprint_buffer("data_bufr", *data_bufr, PDM_DEBUG_FILE);
         }
	PDMdebug("EXIT PDMmodify_dynamic_buffer\n");
	return(PDM_S_SUCCESS);
}


/* 
   nfm_bufr is an output of NFMquery_template_definition()

   nfm_bufr doesn't contain the n_attrno

   The format of the nfm_bufr is copied and extended 
   by n_attrno. All the attributes (minus p_seqno, p_tagno, 
   n_level, p_parentno, ...) are copied with their n_attrno set
*/

int	PDMmodify_template_buffer(nfm_bufr, attr_bufr)
MEMptr		nfm_bufr;
MEMptr		*attr_bufr;
{
	char		**column_ptr;
	char		**format_ptr;
	char		**data;
	int			i, j, nxi, a1;
	int			n_tableno;
	int			n_attrno;

	PDMdebug("ENTER PDMmodify_template_buffer\n");

	status = PDMget_table_no("t_appltable", 
			 "bom_template", &n_tableno);
	if(status != PDM_S_SUCCESS)
	{
		sprintf(s, "PDMget_table_no failed status %d\n", status);
		PDMdebug(s);
		return(status);
	}
	status = MEMbuild_array(nfm_bufr);
	if(status != MEM_S_SUCCESS)
	{
		sprintf(s, "MEMbuild_array failed status %d\n", status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
	}
	status = MEMopen(attr_bufr, 1024);
	if(status != MEM_S_SUCCESS)
	{
		sprintf(s, "MEMopen failed status %d\n", status);
		PDMdebug(s);
		return(PDM_E_OPEN_BUFFER);
	}
	column_ptr = (char **) nfm_bufr->column_ptr;
	a1 = -1; 
	for(i=0;i<nfm_bufr->columns;i++)
	{
		if(!strcmp(column_ptr[i], "n_name"))
		{	
			a1 = i; 
		}
	}
	if(a1 == -1 )
	{
		PDMdebug("failed to set offsets in nfm_bufr\n");
		MEMclose(attr_bufr);
		return(PDM_E_BUFFER_FORMAT);
	}
	format_ptr = (char **) nfm_bufr->format_ptr;
	status = MEMwrite_format(*attr_bufr, "n_attrno", "integer");
	if(status != MEM_S_SUCCESS)
	{
		sprintf(s, "MEMwrite_format failed status %d\n", status);
		PDMdebug(s);
		MEMclose(attr_bufr);
		return(PDM_E_WRITE_FORMAT);
	}
	for(i=0;i<nfm_bufr->columns;i++)
	{
		status = MEMwrite_format(*attr_bufr, 
					column_ptr[i], format_ptr[i]);
		if(status != MEM_S_SUCCESS)
		{
			sprintf(s, "MEMwrite_format failed status %d\n", status);
			PDMdebug(s);
			MEMclose(attr_bufr);
			return(PDM_E_WRITE_FORMAT);
		}
	}
	data = (char **) nfm_bufr->data_ptr;
	for(i=0;i<nfm_bufr->rows;i++)
	{
		nxi = i * nfm_bufr->columns;

	 	/* Eliminate the System Attributes */

		if(strcmp(data[nxi+a1], "p_seqno") 		&&
		   strcmp(data[nxi+a1], "p_tagno") 		&&
		   strcmp(data[nxi+a1], "n_level") 		&&
		   strcmp(data[nxi+a1], "p_parentno") 	&&
		   strcmp(data[nxi+a1], "p_catalogname") &&
		   strcmp(data[nxi+a1], "p_attached") 	&&
		   strcmp(data[nxi+a1], "p_history")		&&
		   strcmp(data[nxi+a1], "p_orient") 		&&
		   strcmp(data[nxi+a1], "p_quantity")	&&
		   strcmp(data[nxi+a1], "p_childno") 	&&
		   strcmp(data[nxi+a1], "p_usageid") 	&&
		   strcmp(data[nxi+a1], "p_viewid"))
		{
			status = PDMget_attribute_no(n_tableno, 
						data[nxi+a1], &n_attrno);
			if(status != PDM_S_SUCCESS)
			{
				sprintf(s, 
				"PDMget_attribute_no failed status %d\n", status);
				PDMdebug(s);
				return(status);
			}			
			sprintf(s, "%d\1", n_attrno);
			for(j=0;j<nfm_bufr->columns;j++)
			{
				strcat(s, data[nxi+j]);strcat(s, "\1");
			}
			status = MEMwrite(*attr_bufr, s);
			if(status != MEM_S_SUCCESS)
			{
				MEMclose(attr_bufr);
				sprintf(s, "MEMwrite failed status %d\n", status);
				PDMdebug(s);
				return(PDM_E_WRITE_ROW);
			}
		}
	}
	PDMdebug("EXIT PDMmodify_template_buffer\n");
	return(PDM_S_SUCCESS);
}
/******************************************************************************

Doc:	PDMupdate_data_buffer

Abstract:
	Create a new data buffer which matches the attribute buffer.

Algorithm:
	.bp
		1.	Build new array of pointers to the modified attribute buffer.
		2.	Open a new data buffer.
		3.	Put the old data buffer column names and formats in the new buffer.
		4.	Put the new attributes and data type in new buffer column names and format information.
		5.	Add the data from the old buffer in the new buffer.
	.ep

Return Status:

	PDM_S_SUCCESS			-	Successful completion
	PDM_E_BUILD_BUFFER_ARRAY	-	Could not build array of pointers to the new attribute buffer
	PDM_E_OPEN_BUFFER		-	Could not open a new buffer
	PDM_E_WRITE_BUFFER		-	Could not write data to the new buffer
	PDM_E_WRITE_FORMAT		-	Could not write the format information to the new buffer

Caveats:

History:

*****************************************************************************/

int PDMupdate_data_buffer(data_buffer, attr_buffer)
MEMptr	*data_buffer;	/* i/o - buffer containing old data for defaults 
                                 and new user defined attribute defaults 
                                 and initial values */
MEMptr	attr_buffer;	/* i   - buffer of attributes 
                                 (default and user defined */
{
    int		status = PDM_S_SUCCESS; /* PDM status */
    MEMptr	new_buffer = NULL;	/* new buffer containing 
                                           new defaults and initials */
    int		row = 0; /* row index for buffer */
    int		col = 0; /* column index for buffer */
    char	*string = NULL; /* string to concatenate the 
                                   data to put in new buffer */
    int		string_len = 0; /* length of string used to add 
                                   a row to new buffer */
    int		string_index = 0; /* character index for string */
    char	**data_cols = NULL; /* array of pointers to column names 
                                       of old data buffer */
    char	**data_format = NULL; /* array of pointers to data types 
                                         of columns in old data buffer */
    char	**data_data = NULL; /* array of pointers to old default 
                                       and initial values */
    char	**attr_data; /* array of pointers to default 
                                and user defined attributes */
    int         max_col;
    int         max_row;

    PDMdebug("In the function PDMupdate_data_buffer\n");

    /* construct array of pointers to attribute data */
    status = MEMbuild_array(attr_buffer);
    if ( status != MEM_S_SUCCESS)
      return(PDM_E_BUILD_BUFFER_ARRAY);

    if (*data_buffer)
     {
      status = MEMbuild_array(*data_buffer);
      if ( status != MEM_S_SUCCESS)
      {
      PDMdebug("MEMbuild_array failed status\n");
         return(PDM_E_BUILD_BUFFER_ARRAY);
      }
     }

    /* open the new buffer */
    status = MEMopen(&new_buffer, 1024);
    if (status != MEM_S_SUCCESS)
      return(PDM_E_OPEN_BUFFER);

    if (*data_buffer)
     {
      data_cols = (char **)(*data_buffer)->column_ptr;
      data_format = (char **)(*data_buffer)->format_ptr;
      data_data = (char **)(*data_buffer)->data_ptr;
      max_col = (*data_buffer)->columns;
      max_row = (*data_buffer)->rows;
     }
    else
{
max_col = 0;
max_row = 1;
}
      attr_data = (char **) attr_buffer->data_ptr;

    /* write the format information from the old buffer to the new buffer */
    for (col=0; col<max_col; ++col)
      {
        status = MEMwrite_format (new_buffer, data_cols[col], data_format[col]);

        if (status != MEM_S_SUCCESS)
          {
            MEMclose(new_buffer);
            return(PDM_E_WRITE_FORMAT);
          }
          
      }

    /* put the attribute name and data types for new attribute in column data */
    for (row=max_col;col<attr_buffer->rows; ++row, ++col)
      {
        status = MEMwrite_format(new_buffer, 
                   attr_data[(attr_buffer->columns * row)+0], 
                   attr_data[(attr_buffer->columns * row)+1]);

        if (status != MEM_S_SUCCESS)
          {
            MEMclose(new_buffer);
            return(PDM_E_WRITE_FORMAT);
          }
      }

   if(PDMdebug_on)
   MEMprint_buffer("new_buffer", new_buffer, PDM_DEBUG_FILE);

    string_len = new_buffer->row_size;

    string = (char *)malloc (string_len);

    for (row=0; row < max_row; ++row)
      {
        string_index=0;
        memset(string, NULL, string_len);

	/* copy the old defaults and initials */
       for (col=0; col<max_col; ++col)
         {
	   if (strcmp(data_data[(max_col * row) + col], "") == 0)
             string[string_index++] = '\1';
           else
             PDMadd_buffer_string(string, &string_index, 
			data_data[(max_col * row) + col]);
         }
       /* add the blank values for the user defined attributes */
       for (; col<attr_buffer->rows; ++col)
         string[string_index++] = '\1';

     _PDMdebug("string", "%s\n", string);

       status = MEMwrite(new_buffer, string);

       if (status != MEM_S_SUCCESS)
         {
           MEMclose(&new_buffer);
           free(string);
           return(PDM_E_WRITE_BUFFER);
         }
      }

    MEMclose(data_buffer);
    *data_buffer = new_buffer;
    
    return(PDM_S_SUCCESS);
}
