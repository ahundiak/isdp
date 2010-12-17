#include 	<stdio.h>
#include	"PDUerror.h"
#include	"SQLerrordef.h"
#include	"PDMproto.h"

extern  int		PDMdebug_on ;
extern  char	 PDM_DEBUG_FILE[];

/* for report system */
FILE		*NFMdbg_ptr;

PDMdebug(s)
char	s[300];
{

FILE		*fp1,*fopen();
 short          do_not_close;

  if(!PDMdebug_on)
	return(PDM_S_SUCCESS);
if ((strcmp (PDM_DEBUG_FILE, "")) == 0)
      {
        /*  Default to stderr  */

        fp1 = stderr;

        do_not_close = 1;
      }
    else
      {
        if ((fp1 = fopen (PDM_DEBUG_FILE, "a")) == NULL)
                                return(PDM_S_SUCCESS);
        do_not_close = 0;
      }


  fprintf(fp1,"%s\n\n",s); 
    if(do_not_close == 0)
  fclose(fp1);
  return(PDM_S_SUCCESS);
}


int PDMcreate_rptopts()
{
           static char *fname = "PDMcreate_rptopts";
            long status;
            char sql_str[512];

        _PDMdebug(fname,"ENTER: PDMcreate_rptopts");


      sql_str[0] = '\0';

sprintf(sql_str, "%s"," create table psurptopts (p_templateno int not null, p_table char(30), p_templatename char(20) not null,  p_templatetype char(2), p_description char(50), p_output char(50),  p_title char(50), p_subtotals int,  p_totals int, p_width int,  p_lines int, p_templib char(20))");
status = SQLstmt(sql_str);
        if(status != SQL_S_SUCCESS)
        {
                _PDMdebug(fname,"SQLstmt failed status %d\n",status);
                return(PDM_E_SQL_STMT);
        }
        

      sql_str[0] = '\0';
 
sprintf (sql_str, "%s"," create table psurptlist (p_templateno int not null, p_name char(18) not null, p_header char(30) not null,  p_type int, p_start int, p_length int, p_decimal int, p_sort int, p_subtotal int, p_total int, p_justification int)");
status = SQLstmt(sql_str);
        if(status != SQL_S_SUCCESS)
        {
                _PDMdebug(fname,"SQLstmt failed status %d\n",status);
                return(PDM_E_SQL_STMT);
        }
        

        _PDMdebug(fname,"EXIT: PDMcreate_rptopts");
        return(PDM_S_SUCCESS);
}



int PDMcreate_reports_tables()
{
           static char *fname = "PDMcreate_reports_tables";
            long status;
            char sql_str[512];

        _PDMdebug(fname,"ENTER: PDMcreate_reports_tables");


      sql_str[0] = '\0';

/* p_qty is no longer used MaC 022694  p_qty is p_quantity now
      sprintf(sql_str,"%s","create table pdmbomparts_rpt (n_catalogname char(20) not null, n_itemname char(40), n_itemrev char(20) not null, n_itemdesc char(40), p_seqno integer, p_alttagno char(25), p_qty double)");
*/
      sprintf(sql_str,"%s","create table pdmbomparts_rpt (n_catalogname char(20) not null, n_itemname char(40), n_itemrev char(20) not null, n_itemdesc char(40), p_alttagno char(25), p_quantity double)");
        status = SQLstmt(sql_str);
        if(status != SQL_S_SUCCESS)
        {
                _PDMdebug(fname,"SQLstmt failed status %d\n",status);
                return(PDM_E_SQL_STMT);
        }
/* p_seqno, p_qty is no longer used MaC 022694  p_qty is p_quantity now
      sprintf(sql_str,"%s","create table pdmsumbom_rpt (p_seqno integer, n_catalogname char(20) not null, n_itemname char(40), n_itemrev char(20) not null, n_itemdesc char(40), p_qty double)");
*/
      sprintf(sql_str,"%s","create table pdmsumbom_rpt (n_catalogname char(20) not null, n_itemname char(40), n_itemrev char(20) not null, n_itemdesc char(40), p_quantity double)");
        status = SQLstmt(sql_str);
        if(status != SQL_S_SUCCESS)
        {
                _PDMdebug(fname,"SQLstmt failed status %d\n",status);
                sprintf(sql_str,"DROP TABLE pdmbomparts_rpt");
                 status = SQLstmt(sql_str);
                _PDMdebug(fname,"SQLstmt status %d\n",status);
                return(PDM_E_SQL_STMT);
        }
      sprintf(sql_str,"%s","create table pdmbom_rpt (n_catalogname char(20) not null, n_itemname char(40), n_itemrev char(20) not null)");
        status = SQLstmt(sql_str);
        if(status != SQL_S_SUCCESS)
        {
                _PDMdebug(fname,"SQLstmt failed status %d\n",status);
                sprintf(sql_str,"DROP TABLE pdmbomparts_rpt");
                 status = SQLstmt(sql_str);
                sprintf(sql_str,"DROP TABLE pdmsumbom_rpt");
                 status = SQLstmt(sql_str);
                _PDMdebug(fname,"SQLstmt status %d\n",status);
                return(PDM_E_SQL_STMT);
        }
/* Typo in p_mrpbomiuom...MaC 022694
      sprintf(sql_str,"%s","create table pdmexpbom_rpt (p_tagno integer, p_alttagno char(25), n_catalogname char(20) not null, n_itemname char(40), n_itemrev char(20) not null, n_itemdesc char(40), n_creationdate timestamp, n_updatedate timestamp, p_attached char(1), p_history char(10), p_quantity double, p_childno integer, p_usageid char(25), p_viewid char(25), p_incpartrpt char(1), p_mrpbomiuom char(10), p_mrpeffectdate char(25), p_mrpinvuom char(10))");
*/
      sprintf(sql_str,"%s","create table pdmexpbom_rpt (p_tagno integer, p_alttagno char(25), n_catalogname char(20) not null, n_itemname char(40), n_itemrev char(20) not null, n_itemdesc char(40), n_creationdate timestamp, n_updatedate timestamp, p_attached char(1), p_history char(10), p_quantity double, p_childno integer, p_usageid char(25), p_viewid char(25), p_incpartrpt char(1), p_mrpbomuom char(10), p_mrpeffectdate char(25), p_mrpinvuom char(10))");
        status = SQLstmt(sql_str);
        if(status != SQL_S_SUCCESS)
        {
                _PDMdebug(fname,"SQLstmt failed status %d\n",status);
                sprintf(sql_str,"DROP TABLE pdmbomparts_rpt");
                 status = SQLstmt(sql_str);
                sprintf(sql_str,"DROP TABLE pdmsumbom_rpt");
                 status = SQLstmt(sql_str);
                sprintf(sql_str,"DROP TABLE pdmexpbom_rpt");
                 status = SQLstmt(sql_str);
                _PDMdebug(fname,"SQLstmt status %d\n",status);
                return(PDM_E_SQL_STMT);
        }
        
      sql_str[0] = '\0';

      sprintf(sql_str,"%s","create table pdmloc_rpt (n_catalogno integer, n_catalogname char(20) not null, n_catalogdesc char(40), n_creator char(14) not null, n_creationdate timestamp, n_updater char(14), n_updatedate timestamp, n_identifier char(20), n_stateno integer, n_aclno integer, n_type char(3), n_archiveno integer, n_archivestate char(1), n_pendingflag char(2))");
        status = SQLstmt(sql_str);
        if(status != SQL_S_SUCCESS)
        {
                _PDMdebug(fname,"SQLstmt failed status %d\n",status);
                sprintf(sql_str,"DROP TABLE pdmbomparts_rpt");
                 status = SQLstmt(sql_str);
                sprintf(sql_str,"DROP TABLE pdmsumbom_rpt");
                 status = SQLstmt(sql_str);
                sprintf(sql_str,"DROP TABLE pdmexpbom_rpt");
                 status = SQLstmt(sql_str);
                sprintf(sql_str,"DROP TABLE pdmbom_rpt");
                 status = SQLstmt(sql_str);
                _PDMdebug(fname,"SQLstmt status %d\n",status);
                return(PDM_E_SQL_STMT);
        }
        
      sprintf(sql_str,"%s","create table pdmparts_rpt (n_itemno integer, n_itemname char(40) not null, n_itemrev char(20), n_itemdesc char(40) , n_setindicator char(1), n_versionlimit integer, n_status char(2), n_pendingflag char(2), n_itemlock char(1), n_aclno integer, n_stateno integer, n_prevstateno integer, n_creator char(14) not null, n_creationdate timestamp, n_updater char(14), n_updatedate timestamp, n_colevel integer, n_archivestate char(1), n_iconname char(40), n_lgfiletype char(40))");
        status = SQLstmt(sql_str);
        if(status != SQL_S_SUCCESS)
        {
                _PDMdebug(fname,"SQLstmt failed status %d\n",status);
                sprintf(sql_str,"DROP TABLE pdmbomparts_rpt");
                 status = SQLstmt(sql_str);
                sprintf(sql_str,"DROP TABLE pdmsumbom_rpt");
                 status = SQLstmt(sql_str);
                sprintf(sql_str,"DROP TABLE pdmexpbom_rpt");
                 status = SQLstmt(sql_str);
                sprintf(sql_str,"DROP TABLE pdmbom_rpt");
                 status = SQLstmt(sql_str);
                sprintf(sql_str,"DROP TABLE pdmloc_rpt");
                 status = SQLstmt(sql_str);
                _PDMdebug(fname,"SQLstmt status %d\n",status);
                return(PDM_E_SQL_STMT);
        }
        
      sql_str[0] = '\0';
      sprintf(sql_str,"%s","create table pdmwhereimm_rpt (n_catalogname char(20) not null, n_itemname char(40), n_itemrev char(20) not null)");
        status = SQLstmt(sql_str);
        if(status != SQL_S_SUCCESS)
         {
                _PDMdebug(fname,"SQLstmt failed status %d\n",status);
                sprintf(sql_str,"DROP TABLE pdmbomparts_rpt");
                 status = SQLstmt(sql_str);
                sprintf(sql_str,"DROP TABLE pdmsumbom_rpt");
                 status = SQLstmt(sql_str);
                sprintf(sql_str,"DROP TABLE pdmexpbom_rpt");
                 status = SQLstmt(sql_str);
                sprintf(sql_str,"DROP TABLE pdmbom_rpt");
                 status = SQLstmt(sql_str);
                sprintf(sql_str,"DROP TABLE pdmloc_rpt");
                 status = SQLstmt(sql_str);
                sprintf(sql_str,"DROP TABLE pdmparts_rpt");
                 status = SQLstmt(sql_str);
                _PDMdebug(fname,"SQLstmt status %d\n",status);
                return(PDM_E_SQL_STMT);
         } 
        
      sql_str[0] = '\0';
      sprintf(sql_str,"%s","create table pdmwherehigh_rpt (n_catalogname char(20) not null, n_itemname char(40), n_itemrev char(20) not null)");
        status = SQLstmt(sql_str);
        if(status != SQL_S_SUCCESS)
         {
                _PDMdebug(fname,"SQLstmt failed status %d\n",status);
                sprintf(sql_str,"DROP TABLE pdmbomparts_rpt");
                 status = SQLstmt(sql_str);
                sprintf(sql_str,"DROP TABLE pdmsumbom_rpt");
                 status = SQLstmt(sql_str);
                sprintf(sql_str,"DROP TABLE pdmexpbom_rpt");
                 status = SQLstmt(sql_str);
                sprintf(sql_str,"DROP TABLE pdmbom_rpt");
                 status = SQLstmt(sql_str);
                sprintf(sql_str,"DROP TABLE pdmloc_rpt");
                 status = SQLstmt(sql_str);
                sprintf(sql_str,"DROP TABLE pdmparts_rpt");
                 status = SQLstmt(sql_str);
                sprintf(sql_str,"DROP TABLE pdmwhereimm_rpt");
                 status = SQLstmt(sql_str);
                _PDMdebug(fname,"SQLstmt status %d\n",status);
                return(PDM_E_SQL_STMT);
         } 
        

        _PDMdebug(fname,"EXIT: PDMcreate_reports_tables");
        return(PDM_S_SUCCESS);
}


int PDMmap_attribute_function()
{
           static char *fname = "PDMmap_attribute_function";
            long status;
            char sql_str[512];

        _PDMdebug(fname,"ENTER: PDMmap_attribute_function");


      sql_str[0] = '\0';

      sprintf(sql_str,"%s","create table pdmfnattrmap (n_catalogname char(20) not null, n_name char(20), n_filename char(14) not null)");
        status = SQLstmt(sql_str);
        if(status != SQL_S_SUCCESS)
        {
                _PDMdebug(fname,"SQLstmt failed status %d\n",status);
                return(PDM_E_SQL_STMT);
        }

        _PDMdebug(fname,"EXIT: PDMmap_attribute_function");
        return(PDM_S_SUCCESS);
}

