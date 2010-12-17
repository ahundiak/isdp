#include		<stdio.h>
#include                "PDUerror.h"
#include		"MEMstruct.h"
#include		"MEMerrordef.h"
#include		"NFMerrordef.h"
#include		"SQLerrordef.h"
#include		"PDUris_incl.h"
#include		"NFMfile.h"
#include		"PDMproto.h"

extern		int		PDMdebug_on;
extern	 PDMpart_ptr PDMpart;
extern		char	PDM_DEBUG_FILE[];
static 		long		status;
static		char		s[1024];


int PDMload_fmgr_ris(n_itemname, p_catno, n_itemno, n_sano,p_filename,attach_count, p_mtype)

int     n_itemname;
int     p_catno;
int	n_itemno;
int	n_sano;
char	*p_filename;
int     attach_count;
int     p_mtype;
{
	int		p_fileno, p_ref1, p_ref2;
	char	sql_str[300];
        char	p_mdate[12];
        char	p_mtime[12];
        int     maxrow;
	
	PDMdebug("ENTER:PDMload_fmgr_ris\n");

/* ANSI */
	n_itemname = 0;
	p_catno = 0;
	n_itemno = 0;

	if(p_mtype == 1)/*CHECK OUT*/
    {
		p_ref1 = 1;
		p_ref2 = 0;
    }
	else if(p_mtype == 2)/*COPY*/
    {
		p_ref1 = 0;
		p_ref2 = 0;
	}
	else if(p_mtype == 3)/*  ATTACH*/
    {
		p_ref1 = 0;
		p_ref2 = attach_count;
	}
	else if(p_mtype == 9)/*  COPY AND ATTACH*/
    {
		p_ref1 = 0;
		p_ref2 = attach_count;
	}
    else
    {
		sprintf(s,"Unknown p_mtype %d\n",p_mtype);
		PDMdebug(s);
		return(PDM_E_FAILURE);
    }
                p_mdate[0] = '\0';
                p_mtime[0] = '\0';
      status = PDMi_get_date(p_mdate,p_mtime);
       if(status != PDM_S_SUCCESS)
         {
           sprintf(s,"PDMi_get_date failed status %d\n",status);
           PDMdebug(s);
           return(status);
         }
	/* check to see if the part is already in the pdmwsparts table */
        /* There is no need to check the entry for the parts in the
           pdmwsparts table. Now an unique index is created for the 
           three columns in the pdmwsparts table*/
		/* get next n_itemname and insert into pdmwsparts */

		status = PDMris_maxrow_no("pdmwsparts","n_itemname",&maxrow);
		if(status != SQL_S_SUCCESS && SQL_I_NO_ROWS_FOUND)
		{
			sprintf(s,"PDMi_maxrow_no failed status %d\n",
			status); PDMdebug(s); 
			return(status);
		}
		/* PDMpart.n_itemname = maxrow + 1 ;*/

                sql_str[0] = '\0';
		sprintf(sql_str,"%s VALUES(%d,%d,%d)",
		"INSERT INTO pdmwsparts (n_itemname,n_catalogno,n_itemno)",
		PDMpart.n_itemname,PDMpart.n_catalogno,PDMpart.n_itemno);
		status = SQLstmt(sql_str);
		if(status != SQL_S_SUCCESS)
		{
			sprintf(s,"SQLstmt failed status %d\n",
			status); PDMdebug(s);
			return(PDM_E_SQL_STMT);
		}
	
	/* get next p_fileno and insert into pdmwsfiles */

	status = PDMris_maxrow_no("pdmwsfiles","p_fileno",&p_fileno);
	if(status != SQL_S_SUCCESS)
	{
		sprintf(s,"PDMi_maxrow_no failed status %d\n",
		status); PDMdebug(s); 
		return(status);
	}
	p_fileno = p_fileno + 1 ;

	sprintf(sql_str,"%s VALUES(%d,'%s','%s','%s')",
	"INSERT INTO pdmwsfiles (p_fileno,p_filename,p_mdate,p_mtime)",
	p_fileno,p_filename,p_mdate,p_mtime);
	status = SQLstmt(sql_str);
	if(status != SQL_S_SUCCESS)
	{
		sprintf(s,"SQLstmt failed status %d\n",
		status); PDMdebug(s);
		return(PDM_E_SQL_STMT);
	}

	/* insert into pdmfmgr */

	sprintf(sql_str,"%s %s VALUES (%d,%d,%d,%d,%d)",
	"INSERT INTO pdmfmgr ",
	" (n_itemname,p_fileno,p_sano,p_ref1,p_ref2) ",
	PDMpart.n_itemname,p_fileno,n_sano,p_ref1,p_ref2);
	status = SQLstmt(sql_str);
	if(status != SQL_S_SUCCESS)
	{
		sprintf(s,"SQLstmt failed status %d\n",
		status); PDMdebug(s);
		return(PDM_E_SQL_STMT);
	}
	PDMdebug("EXIT:PDMload_fmgr_ris\n");
	return(PDM_S_SUCCESS);
}

int PDMfmgr_increment(n_itemname,n_sano, p_mtype,attach_count,p_ref2)
 int     n_itemname;
int	n_sano;
int	p_mtype;
int     attach_count;
int     p_ref2;
{
	char	sql_str[300];
        int     p_ref1 = 0;

	PDMdebug("ENTER:PDMfmgr_increment\n");

	/* Update pdmfmgr  */

       
	if(p_mtype == 1) /* Just a CHECK OUT */
          {
            p_ref1 = 1;
            p_ref2 = p_ref2;
          }
	 else if(p_mtype == 2) /* Just a COPY */
          {
            p_ref1 = 0;
            p_ref2 = p_ref2;
          }
	 else if(p_mtype == 3) /* Just a ATTACH */
          {
            p_ref1 = p_ref1;
            p_ref2 = p_ref2 +attach_count;
          }
	 else if(p_mtype == 9) /* COPY AND ATTACH */
          {
            p_ref1 = p_ref1;
            p_ref2 = p_ref2 +attach_count;
          }
	 else if(p_mtype == 4) /* Just a DETACH */
          {
            p_ref1 = p_ref1;
            p_ref2 = p_ref2  - attach_count;
          }
	 else if(p_mtype == 5) /*  CHECKIN */
          {
            p_ref1 = 0;
            p_ref2 = p_ref2 ;
          }
	 else if(p_mtype == 6) /*  CANCEL CHECKOUT ASSEMBLY */
          {
            p_ref1 = 0;
            p_ref2 = p_ref2 ;
          }
	 else if(p_mtype == 7) /*  CANCEL CHECKOUT PART OF A ASSEMBLY*/
          {
            p_ref1 = p_ref1;
            if(p_ref2 != 0) p_ref2 = p_ref2 - attach_count ;
            else p_ref2 = 0;
          }
     
   
	sprintf(sql_str,"%s  %d %s %d %s %d %s %d",
        "UPDATE pdmfmgr SET p_ref2 = ",p_ref2,",p_ref1 = ",p_ref1,
	"WHERE p_sano = ",n_sano,
	"AND n_itemname = ",n_itemname);
  
	status = PDMris_stmt(sql_str);
	if(status != SQL_S_SUCCESS)
	{
		sprintf(s,"SQLstmt failed status %d\n",
		status); PDMdebug(s);
		PDMdebug("Failed While updating pdmfmgr \n");
		return(PDM_E_SQL_STMT);
	}
	PDMdebug("EXIT:PDMfmgr_increment\n");
	return(PDM_S_SUCCESS);
}

int PDMfmgr_decrement(n_itemname,n_sano,attach_count)
 int     n_itemname;
int	n_sano;
int     attach_count;
{
	char	sql_str[300];
        int     p_ref2 = 0;

	PDMdebug("ENTER:PDMfmgr_decrement\n");

	/* Update pdmfmgr  */

       
            if(p_ref2 != 0) p_ref2 = p_ref2 - attach_count ;
            else p_ref2 = 0;
            if(p_ref2 < 0) p_ref2 = 0;
     
   
	sprintf(sql_str,"%s  %d  %s %d %s %d",
        "UPDATE pdmfmgr SET p_ref2 = ",p_ref2,
	"WHERE p_sano = ",n_sano,
	"AND n_itemname = ",n_itemname);
  
	status = PDMris_stmt(sql_str);
	if(status != SQL_S_SUCCESS)
	{
		sprintf(s,"SQLstmt failed status %d\n",
		status); PDMdebug(s);
		PDMdebug("Failed While updating pdmfmgr \n");
		return(PDM_E_SQL_STMT);
	}
	PDMdebug("EXIT:PDMfmgr_decrement\n");
	return(PDM_S_SUCCESS);
}


