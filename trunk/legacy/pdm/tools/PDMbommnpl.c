#include	<stdio.h>
#include	"SQLerrordef.h"
#include	"MEMerrordef.h"
#include	"NFMerrordef.h"
#include	"PDMdbs_err.h"
#include	"MEMstruct.h"
#include	"PDMproto.h"
#include	"PDUerror.h"

static		long		status;
static		char		s[1024];
extern		int		PDMdebug_on;
extern		char		PDM_DEBUG_FILE[];
/*
	deletes the first level child and its children 
	till n-th level
*/

int	PDMdelete_sub_tree(bom,p_seqno)
char	*bom;
int		p_seqno;
{
	MEMptr		tree_bufr = NULL;
	int			i;
	char		sql_str[1024];
	char		**data;

	PDMdebug("ENTER:PDMdelete_sub_tree\n");
	status = MEMopen(&tree_bufr,1024);
	if(status != MEM_S_SUCCESS)
	{
		sprintf(s,"MEMopen failed status %d\n",status);
		PDMdebug(s);
		return(PDM_E_OPEN_BUFFER);
	}
	status = MEMwrite_format(tree_bufr,"p_seqno","integer");
	if(status != MEM_S_SUCCESS)
	{
		sprintf(s,"MEMwrite_format failed status %d\n",status);
		PDMdebug(s);
		return(PDM_E_WRITE_FORMAT);
	}	
	sprintf(s,"%d\1",p_seqno);
	status = MEMwrite(tree_bufr,s);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(&tree_bufr);
		sprintf(s,"MEMwrite failed status %d\n",status);
		PDMdebug(s);
		return(PDM_E_WRITE_ROW);
	}	
	status = MEMbuild_array(tree_bufr);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(&tree_bufr);
		sprintf(s,"MEMwrite failed status %d\n",status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
	}	
	status = PDMrecursive_fetch(bom,p_seqno,&tree_bufr);
	if(status)
	{
		MEMclose(&tree_bufr);
		sprintf(s,"PDMrecursive_fetch failed status %d \n",status);
		PDMdebug(s);
		return(status);
	}
	status = MEMbuild_array(tree_bufr);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(&tree_bufr);
		sprintf(s,"MEMwrite failed status %d\n",status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
	}	
	data = (char **) tree_bufr->data_ptr;
	for(i=0;i<tree_bufr->rows;i++)
	{
           sql_str[0] = '\0';
		sprintf(sql_str,"DELETE FROM %s WHERE p_seqno = %d",
		bom,atol(data[i]));
		status = SQLstmt(sql_str);
	}	
	MEMclose(&tree_bufr);
	PDMdebug("EXIT:PDMdelete_sub_tree\n");
	return(PDM_S_SUCCESS);
}

/* recursively accumulate all the p_seqno s */

int	PDMrecursive_fetch(bom,p_seqno,tree_bufr)
char	*bom;
int		p_seqno;
MEMptr	*tree_bufr;
{
	char	sql_str[512];
	char	**data;
	MEMptr	temp_bufr = NULL;
	int		i;

        sql_str[0] = '\0';
	sprintf(sql_str,"%s %s %s %d",
	"SELECT p_seqno FROM ",bom,
	"WHERE p_parentno = ",p_seqno);
	status = SQLquery(sql_str,&temp_bufr,1024);
	if(status != SQL_S_SUCCESS)
	{
		MEMclose(&temp_bufr);
		if(status == SQL_I_NO_ROWS_FOUND)
		{
			return(PDM_S_SUCCESS);	
		}
		else
		{
			return(PDM_E_SQL_QUERY);
		}
	}
	else
	{
		status = MEMbuild_array(temp_bufr);
		if(status != MEM_S_SUCCESS)
		{
			MEMclose(&temp_bufr);	
			return(PDM_E_BUILD_ARRAY);
		}
		data = (char **) temp_bufr->data_ptr;
		for(i=0;i<temp_bufr->rows;i++)
		{
			sprintf(s,"%s\1",data[i]);
			status = MEMwrite(*tree_bufr,s);
			if(status != MEM_S_SUCCESS)
			{
				MEMclose(&temp_bufr);
				return(PDM_E_WRITE_ROW);
			}
			status = PDMrecursive_fetch
						(bom,atol(data[i]),tree_bufr);
			if(status != PDM_S_SUCCESS)
			{
				MEMclose(&temp_bufr);	
				return(status);
			}
		}     /* for all children */
		MEMclose(&temp_bufr);
		return(PDM_S_SUCCESS);
	}  /* if there are children */
}

/* build the subtree from the given p_seqno */

int	PDMbuild_assembly(bom,p_seqno,tree_bufr)
char	*bom;
int		p_seqno;
MEMptr	*tree_bufr;
{
	char	sql_str[512];
	char	**data;
	MEMptr	temp_bufr = NULL;
	int		i,nxi;

        sql_str[0] = '\0';
	sprintf(sql_str,"%s %s %s %s %d",
	"SELECT p_seqno,n_catalogname,n_itemname,",
	 "n_itemrev,p_attached,p_level FROM ",bom,
	"WHERE p_parentno = ",p_seqno);
	status = SQLquery(sql_str,&temp_bufr,1024);
	if(status != SQL_S_SUCCESS)
	{
		if(status == SQL_I_NO_ROWS_FOUND)
		{
		}
		else
		{
		}
		MEMclose(&temp_bufr);
		return(0);
	}
	else
	{
		status = MEMbuild_array(temp_bufr);
		if(status != MEM_S_SUCCESS)
		{
			MEMclose(&temp_bufr);
			return(0);
		}
		data = (char **) temp_bufr->data_ptr;
		for(i=0;i<temp_bufr->rows;i++)
		{
			nxi = i * temp_bufr->columns;
			sprintf(s,"%s\1%s\1%s\1%s\1%s\1%s\1",data[nxi+0],data[nxi+1],
				data[nxi+2],data[nxi+3],data[nxi+4],data[nxi+5]);
			MEMwrite(*tree_bufr,s);
			PDMbuild_assembly(bom, atol(data[nxi+0]),tree_bufr);
		}
		MEMclose(&temp_bufr);
		return(0);
	}
}

/*
	Inserts the given info into the bom table
	p_seqno is queried from the existing table
	inserted at level 1
*/

int	PDMinsert_new_child(bom,n_catalogname,n_itemname,
	n_itemrev,p_orient,p_quantity,p_history,p_childno,
	p_usageid,p_viewid,p_tagno,p_alttagno,p_incbom,p_explode)
char	*bom;
char	*n_catalogname;
char	*n_itemname;
char	*n_itemrev;
char	*p_orient;
double  p_quantity;
char	*p_history;
char	*p_childno;
char	*p_usageid;
char	*p_viewid;
int      p_tagno;
char    *p_alttagno;
char    *p_incbom;
char    *p_explode;
{
	char	sql_str1[1024];
	char	sql_str2[1024];
	char	sql_str[2048];
	char	**data;
	long	p_seqno;
	MEMptr	temp_bufr = NULL;
	int		p_level;

	PDMdebug("ENTER:PDMinsert_new_child\n");
        sql_str1[0] = '\0';
        sql_str2[0] = '\0';
        sql_str[0] = '\0';
	p_level = 1;
	sprintf(s,"%s %s",
	"SELECT MAX(p_seqno) FROM ",bom);
	status = SQLquery(sql_str,&temp_bufr,512);
	if(status != SQL_S_SUCCESS)
    {
		switch(status)
		{
			case SQL_I_NO_ROWS_FOUND:
				MEMclose(&temp_bufr);
				p_seqno = 0;
			case PDMS_NO_SUCH_ATTRIBUTE:
				PDMdebug("A req. column is missing in SQL query\n");
				return(PDM_E_REQ_COLUMN_NOT_FOUND);
			case PDMS_NO_SUCH_TABLE:
				PDMdebug("Bom table can not be found \n");
				return(PDM_E_UNKNOWN_TABLE);
			default:
				sprintf(s,"%s %d\n",
			 	"SQLquery failed status ",status);
				PDMdebug(s);
				return(status);
		}
	}
	else
	{
		status = MEMbuild_array(temp_bufr);
		if(status != MEM_S_SUCCESS)
		{
			MEMclose(&temp_bufr);
			sprintf(s,"MEMbuild_array failed status %d\n",status);
			PDMdebug(s);
			return(PDM_E_BUILD_ARRAY);
		}
		data = (char **) temp_bufr->data_ptr;
		p_seqno = atol(data[0]);
		MEMclose(&temp_bufr);
    }

	p_seqno = p_seqno + 1;
	sprintf(sql_str1,"%s %s %s %s %s ",
	"INSERT INTO ",bom,
	"VALUES (n_catalogname,n_itemname,n_itemrev,",
	"p_orient,p_quantity,p_history,p_childno,",
	"p_usageid,p_viewid,p_tagno,p_alttagno,p_incbom,p_explode,p_seqno,p_level)");
	sprintf(sql_str2,
	"VALUES('%s','%s','%s','%s',%s,'%s','%s','%s','%s',%d,'%s','%s','%s',%d,%d)",
	n_catalogname,n_itemname,n_itemrev,
	p_orient,p_quantity,p_history,
	p_childno,p_usageid,p_viewid,
        p_tagno,p_alttagno,p_incbom,p_explode,
	p_seqno,p_level);
	sprintf(sql_str,"%s %s",sql_str1,sql_str2);
	status = SQLstmt(sql_str);
	if(status != SQL_S_SUCCESS)
	{
		sprintf(s,"SQLstmt failed status %d\n",status);
		PDMdebug(s);
		return(PDM_E_SQL_STMT);
	}
	PDMdebug("EXIT:PDMinsert_new_child\n");
	return(PDM_S_SUCCESS);
}

/*
	called from checkin function
	if review bom exists it is dropped
	if active bom exists it is copied as review bom
*/

int	PDMcopy_active_bom(active_bom,review_bom)
char	*active_bom;
char	*review_bom;
{
	char	sql_str[1024];

	PDMdebug("ENTER:PDMcopy_active_bom\n");
        sql_str[0] = '\0';
	if(!strlen(review_bom) && !strlen(active_bom)) return(PDM_S_SUCCESS);
	if(!strlen(review_bom) && strlen(active_bom))
             {

		sprintf(sql_str,"UPDATE pdmboms SET p_bomtype = 'R' WHERE p_bomname = '%s'",active_bom);
		status = SQLstmt(sql_str);
		if(status != SQL_S_SUCCESS)
		{
			sprintf(s,"SQLstmt failed status %d\n",status);
			PDMdebug(s);
			return(PDM_E_SQL_STMT);
		}
             }
        
	if(strlen(review_bom) && strlen(active_bom))
	{
		sprintf(sql_str,"DELETE FROM %s",review_bom);
		status = SQLstmt(sql_str);
		if(status != SQL_S_SUCCESS)
		{
			sprintf(s,"SQLstmt failed status %d\n",status);
			PDMdebug(s);
			return(PDM_E_SQL_STMT);
		}
		status = PDMcopy_table(active_bom,review_bom);
		if(status != PDM_S_SUCCESS)
		{
			sprintf(s,"PDMcopy_table failed status %d\n",status);
			PDMdebug(s);
			return(status);
		}
	}
	else if(strlen(review_bom) && !strlen(active_bom))  	
               {
	/*	status = PDMdrop_a_bom(review_bom);
		if(status != SQL_S_SUCCESS)
		{
			sprintf(s,"PDMdrop_a_bom failed status %d\n",status);
			PDMdebug(s);
			return(status);
		}
        */
	}
	PDMdebug("EXIT:PDMcopy_active_bom\n");
	return(PDM_S_SUCCESS);
}

int	PDMcopy_review_bom(review_bom,active_bom)
char	*active_bom;
char	*review_bom;
{
	char	sql_str[1024];

	PDMdebug("ENTER:PDMcopy_review_bom\n");
        sql_str[0] = '\0';
	if(strlen(review_bom) && strlen(active_bom))
	{
		sprintf(sql_str,"DELETE FROM %s",active_bom);
		status = SQLstmt(sql_str);
		if(status != SQL_S_SUCCESS)
		{
			sprintf(s,"SQLstmt failed status %d\n",status);
			PDMdebug(s);
			return(PDM_E_SQL_STMT);
			/* APOGEE return(status); APOGEE END */
		}
		status = PDMcopy_table(review_bom,active_bom);
		if(status != PDM_S_SUCCESS)
		{
			sprintf(s,"PDMcopy_table failed status %d\n",status);
			PDMdebug(s);
			return(status);
		}
	}
	else if(strlen(active_bom) && !strlen(review_bom))  	
            {
		status = PDMdrop_a_bom(active_bom);
		if(status != SQL_S_SUCCESS)
		{
			sprintf(s,"PDMdrop_a_bom failed status %d\n",status);
			PDMdebug(s);
			return(status);
		}
	    }
       else	if(strlen(review_bom) && !strlen(active_bom))
               {

		sprintf(sql_str,"UPDATE pdmboms SET p_bomtype = 'A' WHERE p_bomname = '%s'",review_bom);
		status = SQLstmt(sql_str);
		if(status != SQL_S_SUCCESS)
		{
			sprintf(s,"SQLstmt failed status %d\n",status);
			PDMdebug(s);
			return(PDM_E_SQL_STMT);
		}
               }
	PDMdebug("EXIT:PDMcopy_review_bom\n");
	return(PDM_S_SUCCESS);
}

/*
	Copies  table1 to table2
	Both the tables must exist
*/

int PDMcopy_table(table1,table2)
char	*table1;
char	*table2;
{
	char	sql_str[512];
	char	*s1;
	char	*s2;
	char	*s3;
	char	**columns;
	char	**format;
	char	**data;
	int		size;
	int		i,j,nxi;
	MEMptr	bufr1 = NULL;

	PDMdebug("ENTER:PDMcopy_table\n");
	size = 0;
        sql_str[0] = '\0';
	sprintf(sql_str,"SELECT * FROM %s ",table1);
	status = SQLquery(sql_str,&bufr1,1024);
	if(status != SQL_S_SUCCESS)
	{
		if(status == PDMS_NO_SUCH_TABLE )
		{
			sprintf(s,"%s not found \n",table1);
			PDMdebug(s);
			return(PDM_E_SQL_QUERY);
		}
	}
	status = MEMbuild_array(bufr1);
	if(status != MEM_S_SUCCESS)
	{
		sprintf(s,"%s %d\n",
		"MEMbuild_array failed status",status);
		PDMdebug(s);
		MEMclose(&bufr1);
		return(PDM_E_BUILD_ARRAY);
	}
	columns = (char **) bufr1->column_ptr;
	format	= (char **) bufr1->format_ptr;
	for(i=0;i<bufr1->columns;i++)
	{
		size = size + strlen(columns[i]);
	}
	s1 = (char *) malloc(size + 100);
	if(s1 == NULL)
	{
		PDMdebug("Couldnot malloc\n");
		return(PDM_E_COULD_NOT_MALLOC);
	}
	s2 = (char *) malloc(bufr1->row_size+100);
	if(s2 == NULL)
	{
		free(s1);
		PDMdebug("Couldnot malloc\n");
		return(PDM_E_COULD_NOT_MALLOC);
	}
	s3 = (char *) malloc(size + bufr1->row_size+100 );
	if(s3 == NULL)
	{
		free(s1);
		free(s2);
		PDMdebug("Could not malloc\n");
		return(PDM_E_COULD_NOT_MALLOC);
	}
	strcpy(s1,"");
	strcpy(s2,"");
	strcpy(s3,"");	
	strcat(s1,"(");
	strcat(s1,columns[0]);
	for(i=1;i<bufr1->columns;i++)
	{
		strcat(s1,",");
		strcat(s1,columns[i]);
	}
	strcat(s1,")");

	data = (char **) bufr1->data_ptr;
	for(i = 0;i<bufr1->rows;i++)
	{
		sprintf(s2,"VALUES (");
		nxi = i * bufr1->columns;
		for(j=0;j<bufr1->columns;j++)
		{
			if(!strncmp(format[j],"char",4))
			{
				strcat(s2,"'");
				strcat(s2,data[nxi+j]);
				strcat(s2,"'");
			    if(j != bufr1->columns-1)
					strcat(s2,",");
			}
			else
			{
			   if(strlen(data[nxi+j]))
			   {
					strcat(s2,data[nxi+j]);
			   }
			   else
			   {
					strcat(s2,"null");
			   }
			   if(j != bufr1->columns-1)
					strcat(s2,",");
			}
		}
		strcat(s2,")");

		sprintf(s3,"%s %s %s %s",
		"INSERT INTO ",table2,s1,s2);
		status = SQLstmt(s3);
		if(status != SQL_S_SUCCESS)
		{
			free(s1);
			free(s2);
			free(s3);
			return(status);
		}
	}
	free(s1);
	free(s2);
	free(s3);
	PDMdebug("EXIT:PDMcopy_table\n");
	return(PDM_S_SUCCESS);
}

/* 
	Copies attachments from attach_bufr to new_bom
	
	attach_bufr is not NULL at this point
	attach_bufr is not used if old_bom doesnot exist
	{Since PDU doesnot know attach_bufr is set to zeros}

	if(old_bom exists)
		translate p_seqno in attach_bufr
		set p_attached in new_bom
		load new p_seqno into ret_bufr
	else
		set p_attached in new_bom using p_seqno
*/

int PDMcopy_abom_attachments(old_bom,new_bom,
				attach_bufr,ret_bufr)
char	*old_bom;
char	*new_bom;
MEMptr	attach_bufr;
MEMptr  *ret_bufr;
{
	char	sql_str[1024];
	char	**data;
	char	**attach_data;
        char    **attach_col;
	int		old_seqno;
	int		new_seqno;
	MEMptr	temp_bufr = NULL;
	MEMptr	bufr = NULL;
	int		i,k,of1,ofx;

	PDMdebug("ENTER:PDMcopy_abom_attachments\n");
	status = MEMbuild_array(attach_bufr);
	if(status != MEM_S_SUCCESS)
	{
		sprintf(s,"MEMbuild_array failed status %d\n",status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
	}
	status = MEMopen(ret_bufr,1024);
	if(status != MEM_S_SUCCESS)
	{
		sprintf(s,"MEMopen failed status %d\n",status);
		PDMdebug(s);
		return(PDM_E_OPEN_BUFFER);
	}
	status = MEMwrite_format(*ret_bufr,"p_seqno","integer");
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(ret_bufr);
		sprintf(s,"MEMwrite_format failed status %d\n",status);
		PDMdebug(s);
		return(PDM_E_WRITE_FORMAT);
	}
        if(PDMdebug_on)
        {
          MEMprint_buffer("attach_bufr", attach_bufr, PDM_DEBUG_FILE);
        }
        of1 = -1;
	attach_data = (char **) attach_bufr->data_ptr;
        attach_col  = (char **) attach_bufr->column_ptr;
        for(k=0;k<attach_bufr->columns;k++)
          {
           if(!strcmp(attach_col[k],"p_seqno")) of1=k;
           }
       if (of1 == -1)
         {
           MEMclose(&attach_bufr);
           PDMdebug("Couldn't find cols in attach_bufr\n");
           return(PDM_E_BUFFER_FORMAT);
         }
	/* if no OLD A-BOM or no rows in attach_bufr return */
	
	if(!strlen(old_bom) || !attach_bufr->rows)
	{	
		PDMdebug("There are no attachments to copy \n");
		return(PDM_S_SUCCESS);
	}

        sql_str[0] = '\0';
        for(i=0;i<attach_bufr->rows;i++)
    	{
           ofx = i * attach_bufr->columns;
	  old_seqno = atoi(attach_data[ofx + of1]);
	  if(old_seqno)
	  {
		sprintf(sql_str,"%s %s %s %s %d",
		"SELECT p_parentno,p_level,p_tagno,p_childno,",
		"p_seqno FROM ",old_bom,"WHERE p_seqno = ",old_seqno);
		status = SQLquery(sql_str,&bufr,512);
		if(status != SQL_S_SUCCESS)
		{
			MEMclose(&bufr); bufr = NULL;
			sprintf(s,"SQLquery failed status %d\n",status);
			PDMdebug(s);
			MEMclose(ret_bufr);
			return(status);
		}
		status = MEMbuild_array(bufr);
		if(status != MEM_S_SUCCESS)
		{
			MEMclose(ret_bufr);MEMclose(bufr);
			sprintf(s,"MEMbuild_array failed status %d\n",
			status);  PDMdebug(s);
			return(PDM_E_BUILD_ARRAY);
		}
             if(PDMdebug_on)
                { PDMdebug("Old bom p_parentno,p_level,p_tagno,p_childno");
                  MEMprint_buffer("bufr",bufr,PDM_DEBUG_FILE);
                }
		data = (char **) bufr->data_ptr;
			
		/* build (in bufr) the assembly of the child */
	        status = PDMassemble_bottomup(atoi(data[0]),
					 atoi(data[1]),atoi(data[2]),
					 data[3],atoi(data[4]),
					 old_bom,&temp_bufr);
               if(PDMdebug_on)
                    {PDMdebug("temp_bufr after PDMassemble_bottomup");
    
                      MEMprint_buffer("temp_bufr",temp_bufr,PDM_DEBUG_FILE);
                    }
		if(status != PDM_S_SUCCESS)
		   {
			MEMclose(ret_bufr);MEMclose(&bufr);
			sprintf(s,"PDMassemble_bottomup failed status %d\n",
			status); PDMdebug(s);
			return(status);
		   }
		MEMclose(&bufr); bufr = NULL;

		/* check if the assembly exists in new_bom */

		status = PDMverify_assembly(new_bom,temp_bufr,&new_seqno);
		if(status != PDM_S_SUCCESS)
		{
			MEMclose(&temp_bufr); temp_bufr = NULL;
			new_seqno = -1;
		}
		else
		{
			MEMclose(&temp_bufr); temp_bufr = NULL;
			status = PDMset_attached_flag(new_bom,new_seqno);
			if(status != PDM_S_SUCCESS)
			{
			sprintf(s,"PDMset_attached_flag failed status %d\n",
			status); PDMdebug(s);
			MEMclose(ret_bufr);
			return(status);
			}
                }
		
		sprintf(s,"%d\1",new_seqno);
		status = MEMwrite(*ret_bufr,s);
                if(PDMdebug_on)
                 {PDMdebug("Return buffer of new seq nos");
                  MEMprint_buffer("ret_bufr",ret_bufr,PDM_DEBUG_FILE);
                 }
		if(status != MEM_S_SUCCESS)
		{
			sprintf(s,"MEMwrite failed status %d\n",status);
			PDMdebug(s);
			MEMclose(ret_bufr);
			return(PDM_E_WRITE_ROW);
		}
	}	/* if old_seqno is not zero (A-BOM attachment) */
    }		/* for all rows in attach_bufr */
    PDMdebug("EXIT:PDMcopy_abom_attachments\n");
	return(PDM_S_SUCCESS);
}

/* 
	Copies attachments from old_bom to new_bom
	if old_bom exists
	
*/

int PDMcopy_rbom_attachments(old_bom,new_bom)
char	*old_bom;
char	*new_bom;
{
	char	sql_str[1024];
	char	**data;
/* APOGEE START char	**data1; 
	int		p_level;
	int		p_tagno;
	char	p_childno[30];
	int		p_parentno; APOGEE END */
	int		p_seqno;
	MEMptr	attach_bufr = NULL;
	MEMptr	temp_bufr = NULL;
	int		i,nxi;

	PDMdebug("ENTER:PDMcopy_rbom_attachments\n");

	if(!strlen(old_bom))
	return(PDM_S_SUCCESS);

	/* get all the attachments from from_bom */

        sql_str[0] = '\0';
	sprintf(sql_str,"%s %s %s %s ",
	"SELECT p_parentno,p_level,p_tagno,p_childno,",
	"p_seqno FROM ",old_bom,
	"WHERE p_attached = 'Y' ");		
	status = SQLquery(sql_str,&attach_bufr,2048);
	if(status != SQL_S_SUCCESS)
	{
		MEMclose(&attach_bufr);
		if(status == SQL_I_NO_ROWS_FOUND)
		{
			sprintf(s,"No attachments found in %s\n",old_bom);
			PDMdebug(s);
			return(PDM_S_SUCCESS);
		}
		sprintf(s,"SQLquery failed status %d\n",status);
		return(PDM_E_SQL_QUERY);
	}
	status = MEMbuild_array(attach_bufr);
	if(status != MEM_S_SUCCESS)
	{
		sprintf(s,"MEMbuild_array failed status %d\n",status);
		PDMdebug(s);
		MEMclose(&attach_bufr);
		return(PDM_E_BUILD_ARRAY);
	}
	data  = (char **) attach_bufr->data_ptr;

	/* each attachment needs to be translated to the appr. row
	   in new_bom.A check is made to see if the assembly structure 
	   is the same in new_bom */

	for(i=0;i<attach_bufr->rows;i++)
	{
		nxi = i * attach_bufr->columns;

		/* build (in bufr) the assembly of the child */

		status = PDMassemble_bottomup(atoi(data[nxi]),
				 atoi(data[nxi+1]),
				 atoi(data[nxi+2]),
				 data[nxi+3],
				 atoi(data[nxi+4]),
				 old_bom,&temp_bufr);
		if(status != PDM_S_SUCCESS)
		{
			sprintf(s,"PDMassemble_bottomup failed status %d\n",
			status); PDMdebug(s);
			return(status);
		}

		/* check if the assembly exists in new_bom */

		status = PDMverify_assembly(new_bom,temp_bufr,&p_seqno);
		if(status != PDM_S_SUCCESS)
		{
			MEMclose(&temp_bufr); temp_bufr = NULL;
		}
		else
		{
			MEMclose(&temp_bufr); temp_bufr = NULL;
			status = PDMset_attached_flag(new_bom,p_seqno);
			if(status != PDM_S_SUCCESS)
			{
				MEMclose(&attach_bufr);
				sprintf(s,"PDMset_attached_flag failed status %d\n",
				status); PDMdebug(s);
			}
		}
	}  /* end for each attachment */
	PDMdebug("EXIT:PDMcopy_rbom_attachments\n");
	return(PDM_S_SUCCESS);
}

int	PDMset_attached_flag(bom,p_seqno)
char	*bom;
int		p_seqno;
{
	char	sql_str[1024];
/* APOGEE START MEMptr	temp_bufr; APOGEE END */

	PDMdebug("ENTER:PDMset_attached_flag\n");
        sql_str[0] = '\0';
	sprintf(sql_str,"UPDATE %s %s %s %d",
	bom,"SET p_attached = 'Y'","WHERE p_seqno = ",p_seqno);
	status =  SQLstmt(sql_str);
	if(status != SQL_S_SUCCESS)
	{
		sprintf(s,"SQLstmt failed status %d\n",status);
		return(PDM_E_SQL_STMT);
	}
	PDMdebug("EXIT:PDMset_attached_flag\n");
	return(PDM_S_SUCCESS);
}


/* builds the structure from the given (leaf) entry */

int  PDMassemble_bottomup(p_parentno,p_level,p_tagno,
						p_childno,p_seqno,bom,bufr)
int		p_parentno;
int 	p_level;
int		p_tagno;
char	p_childno[30];
int		p_seqno;
char 	*bom;
MEMptr	*bufr;
{
		status = MEMopen(bufr,1024);
		if(status != MEM_S_SUCCESS)
		{

			sprintf(s,"MEMopen failed status %d\n",
			status);PDMdebug(s);
			return(PDM_E_OPEN_BUFFER);
		}
		status = MEMwrite_format(*bufr,"p_parentno","integer");
		if(status == MEM_S_SUCCESS)
		status = MEMwrite_format(*bufr,"p_level","integer");
		if(status == MEM_S_SUCCESS)
		status = MEMwrite_format(*bufr,"p_tagno","integer");
		if(status == MEM_S_SUCCESS)
		status = MEMwrite_format(*bufr,"p_childno","char(30)");
		if(status == MEM_S_SUCCESS)
		status = MEMwrite_format(*bufr,"p_seqno","integer");
	    if(status != MEM_S_SUCCESS)
		{
			sprintf(s,"MEMwrite_format failed status %d\n",
			status);PDMdebug(s);
			MEMclose(bufr);
			return(PDM_E_WRITE_FORMAT);
		}
		sprintf(s,"%d\1%d\1%d\1%s\1%d\1",p_parentno,p_level,
		p_tagno,p_childno,p_seqno);
		status = MEMwrite(*bufr,s);
		if(status != MEM_S_SUCCESS)
		{
			sprintf(s,"MEMwrite failed status %d\n",
			status);PDMdebug(s);
			MEMclose(bufr);
			return(PDM_E_WRITE_ROW);
		}
                if (p_parentno)
                  {
  			status = PDMaccumulate_parent(p_parentno,bom,bufr);
			if(status != PDM_S_SUCCESS)
			{
				MEMclose(bufr);
				return(status);
			}
                  }
		PDMdebug("EXIT:PDMassemble_bottomup \n");
		return(PDM_S_SUCCESS);
}

int	 PDMaccumulate_parent(p_no,bom,bufr)
int	    p_no;
char	*bom;
MEMptr	*bufr;
{
		char	**data;
		char	sql_str[512];
		MEMptr	bufr1 = NULL;
		
        sql_str[0] = '\0';
		sprintf(sql_str,"%s %s %s %d",
	    "SELECT p_parentno,p_level,p_tagno,p_childno,p_seqno FROM ",
	    bom,"WHERE p_seqno = ",p_no);
		status = SQLquery(sql_str,&bufr1,512);
		if(status != SQL_S_SUCCESS)
		{
			MEMclose(&bufr1);
			if(status == SQL_I_NO_ROWS_FOUND)
			{
				return(PDM_S_SUCCESS);
			}
			return(PDM_E_SQL_QUERY);
		}
	    status = MEMbuild_array(bufr1);
		if(status != MEM_S_SUCCESS)
		{
			MEMclose(&bufr1);
			return(PDM_E_BUILD_ARRAY);
		}
                if(PDMdebug_on)
                 {
                  PDMdebug("p_parentno,p_level,p_tagno,p_childno,p_seqno of bufr1\n"); MEMprint_buffer("bufr1",bufr1,PDM_DEBUG_FILE);
                 }
		data = (char **) bufr1->data_ptr;
		sprintf(s,"%s\1%s\1%s\1%s\1%s\1",
		data[0],data[1],data[2],data[3],data[4]);

		status = MEMwrite(*bufr,s);
		if(status != MEM_S_SUCCESS)
		{
			MEMclose(&bufr1);
			return(PDM_E_WRITE_ROW);
		}
		MEMclose(&bufr1);
		if (atol(data[0]))
                  {
			status = PDMaccumulate_parent(atoi(data[0]),bom,bufr);
			if(status != PDM_S_SUCCESS)
			{
				return(status);
			}
                  }
		return(PDM_S_SUCCESS);
}

/*
	Verifies if assembly in bufr exists in bom
	and returns the seqno
*/

int PDMverify_assembly(bom,bufr,seqno)
char	*bom;
MEMptr	bufr;
int		*seqno;
{

	MEMptr		bufr1 = NULL;
	MEMptr		bufrx = NULL;
	char		sql_str[512];
	char		**data;
	int			i,nx;
	int			p_parentno,p_seqno,p_level,p_tagno;
	char		p_childno[30];

	PDMdebug("ENTER:PDMverify_assembly\n");
	status = MEMbuild_array(bufr);
	if(status != MEM_S_SUCCESS)
	{
		sprintf(s,"MEMbuild_array failed status %d\n",status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
	}
	data = (char **) bufr->data_ptr;

	/* select all the leaves from bom */
	
        sql_str[0] = '\0';
	sprintf(sql_str,"%s  %s %s %s %s %s %s '%s'",
    "SELECT p_parentno,p_level,p_tagno,p_childno,p_seqno FROM ",
	bom, "WHERE p_parentno =", data[0],
	"AND p_tagno = ",data[2],
	"AND p_childno = ",data[3]);
	status = SQLquery(sql_str,&bufr1,1024);
	if(status != SQL_S_SUCCESS)
	{
		MEMclose(&bufr1);
		if(status == SQL_I_NO_ROWS_FOUND)
		{
			return(PDM_E_FAILURE);
		}
		else
		{
			sprintf(s,"SQLquery failed status %d\n",status);
			PDMdebug(s);
			return(PDM_E_SQL_QUERY);
		}
	}
	status = MEMbuild_array(bufr1);
	if(status != MEM_S_SUCCESS)
	{
		MEMclose(&bufr1);
		sprintf(s,"MEMbuild_array failed status %d\n",status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
	}
	data = (char **) bufr1->data_ptr;

	/* check for each leaf if the assembly exists */

	for(i=0;i<bufr1->rows;i++)
	{
		nx = i * bufr1->columns;
		p_parentno = atoi(data[nx]);
		p_level = atoi(data[nx+1]);
		p_tagno = atoi(data[nx+2]);
		strcpy(p_childno,data[nx+3]);
		p_seqno = atoi(data[nx+4]);
		if (p_parentno == 0)
                  {
		    *seqno = p_seqno;
                    return(PDM_S_SUCCESS);
                  }

   		status = PDMassemble_bottomup(p_parentno,p_level,
			 p_tagno,p_childno,p_seqno,bom,&bufrx);
		if(status != PDM_S_SUCCESS)
		{
			sprintf(s,
			"PDMassemble_bottomup failed status %d\n",status);
			PDMdebug(s);
			MEMclose(&bufr1);
			return(status);
		}
		status = MEMbuild_array(bufrx);
	    if(status != MEM_S_SUCCESS)
		{
			sprintf(s,"MEMbuild_array failed status %d\n",status);
			PDMdebug(s);
			MEMclose(&bufr1);	MEMclose(&bufrx);
			return(PDM_E_BUILD_ARRAY);
		}
		if (PDMdebug_on)
		{       PDMdebug("Comparison of assemblies and p_seqnos");
			MEMprint_buffer("oldassem", bufr, PDM_DEBUG_FILE);
			MEMprint_buffer("newassem", bufrx, PDM_DEBUG_FILE);
		}
		status = PDMcompare_assemblies(bufr,bufrx,&p_seqno);
		if(status == PDM_S_SUCCESS)
		{
			*seqno = p_seqno;
			MEMclose(&bufrx); bufrx = NULL;
			break;
		}
		MEMclose(&bufrx); bufrx = NULL;
	}	/* end for all leaves */
	MEMclose(&bufr1);
	PDMdebug("EXIT:PDMverify_assembly\n");
	return(status);
}

/*
	Compares assemblies in bufr1 bufr2 and 
	if similar sets p_seqno
*/

int	PDMcompare_assemblies(bufr1,bufr2,p_seqno)
MEMptr	bufr1;
MEMptr	bufr2;
int		*p_seqno;
{
	int		i, nx;
	char	**data1;
	char	**data2;
	int		found;

	status = MEMbuild_array(bufr1);
	if(status != MEM_S_SUCCESS)
	{
			return(PDM_E_BUILD_ARRAY);
	}
	data1 = (char **) bufr1->data_ptr;
	status = MEMbuild_array(bufr2);
	if(status != MEM_S_SUCCESS)
	{
			return(PDM_E_BUILD_ARRAY);
	}
	data2 = (char **) bufr2->data_ptr;
	if(bufr1->rows != bufr2->rows)
	{
		return(PDM_E_FAILURE);
	}
	found = 1;
	for(i=0;i<bufr1->rows;i++)
	{
		nx = i * bufr1->columns;
		if(!strcmp(data1[nx+1],data2[nx+1]) &&
		   !strcmp(data1[nx+2],data2[nx+2]) &&
		   !strcmp(data1[nx+3],data2[nx+3]))
		{
		}
		else
		{
			found = 0;
			break;
		}
	}
	if(found)
	{
		*p_seqno = atoi(data2[4]);
		return(PDM_S_SUCCESS);
	}
	else
	{
		return(PDM_E_FAILURE);
	}
}
