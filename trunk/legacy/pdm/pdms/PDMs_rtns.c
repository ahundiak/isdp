#include		<stdio.h>
#include		"PDUerror.h"
#include		"MEMstruct.h"
#include		"MEMerrordef.h"
#include		"NFMerrordef.h"
#include		"SQLerrordef.h"
#include		"PDMdbs_err.h"
#include		"PDUpdmrpro.h"
#include		"PDMproto.h"

#include		"NFMschema.h"
#include		"NFMapi.h"
#include		"NFMitemfiles.h"
#include		"NFMitems.h"
#include		"NFMfto_buf.h"
#include		"PDMmessage.h"

extern int      PDMdebug_on;
extern PDMpart_ptr PDMpart;
extern char     PDM_DEBUG_FILE[];
static long     status;
static char     s[1024];
static char     prev_cat[25];
static char     prev_part[240];
static char     prev_rev[40];
static char     prev_ind[4];
static char     prev_type[8];
static int     prev_catno;
static int     prev_itemno;



/*
 * Updates the first level children of the part By dropping the children that
 * dont appear in child_bufr and adding new ones that are not in set_data
 * buffer.
 * 
 * If the part was not an assembly before it is converted to an assembly.
 * 
 * The old set info is returned
 * 
 * If error occurs and if the part was not an assembly before it is converted to
 * an item
 * - Kumar Narayanan
 */

int PDMupdate_set_members(catalog, n_itemname, n_itemrev, p_catno, p_itemno, child_bufr, citno_bufr, cit_bufr)
	char           *catalog;
	char           *n_itemname;
	char           *n_itemrev;
        int            p_catno;
        int            p_itemno;
	MEMptr         child_bufr;
        MEMptr        *citno_bufr;
        MEMptr        *cit_bufr;
{
	int             m1 = -1, m2 = -1, m3 = -1, m4 = -1, m5 = -1;
	int             m6 = -1, m7 = -1, m8 = -1,  m10 = -1;
	int             m11 = -1, m12 = -1, m13 = -1, m14 = -1, m15 = -1;
	int             actual_citno = 0, citno = 0, pdcno = 0;
	int             i = 0;
	int             nxi = 0;
        int             c_catno = 0, c_itemno = 0;
        char          sql_str[512] = "", mem_str[1024] = "";
        char          dumb_str[2]="";
	char          **column_ptr = NULL;
	char          **child_data = NULL, **data = NULL;
        char         *fname = "PDMupdate_set_members";
        char           *msg=NULL;
 	int 		PDMadd_child ();
        MEMptr         n_citno_bufr = NULL, dumb_list = NULL;

	_PDMdebug(fname, "ENTER : \n");

	/* set offsets in child_bufr */
     prev_cat[0] = '\0';
     prev_part[0] = '\0';
     prev_rev[0]  = '\0';
     prev_ind[0]   = '\0';
     prev_type[0]  = '\0';
     prev_catno = 0;
     prev_itemno = 0;

	if (PDMdebug_on) MEMprint_buffer("child_bufr:PDMupdate_set_members",
				child_bufr, PDM_DEBUG_FILE);

        status = MEMbuild_array(child_bufr);
        if(status != MEM_S_SUCCESS)
         {
          _PDMdebug(fname,"MEMbuild_array status %d\n", status);
          return(status);
         }
	column_ptr = (char **) child_bufr->column_ptr;
	child_data  = (char **) child_bufr->data_ptr;
	for (i = 0; i < child_bufr->columns; i++) {
                if (!strcmp(column_ptr[i], "n_catalogname"))
                        m1 = i;
                if (!strcmp(column_ptr[i], "n_itemname"))
                        m2 = i;
                if (!strcmp(column_ptr[i], "n_itemrev"))
                        m3 = i;
                if (!strcmp(column_ptr[i], "p_attached"))
                        m4 = i;
                if (!strcmp(column_ptr[i], "p_quantity"))
                        m5 = i;
                if (!strcmp(column_ptr[i], "p_history"))
                        m6 = i;
                if (!strcmp(column_ptr[i], "p_childno"))
                        m7 = i;
                if (!strcmp(column_ptr[i], "p_usageid"))
                        m8 = i;
                if (!strcmp(column_ptr[i], "p_tagno"))
                        m10 = i;
                if (!strcmp(column_ptr[i], "p_alttagno"))
                        m11 = i;
                if (!strcmp(column_ptr[i], "p_incbom"))
                        m12 = i;
                if (!strcmp(column_ptr[i], "p_explode"))
                        m13 = i;
                if (!strcmp(column_ptr[i], "n_cofilename"))
                        m14 = i;
                if (!strcmp(column_ptr[i], "p_incstr"))
                        m15 = i;
        }
        if (m1 == -1 || m2 == -1 || m3 == -1 ||
            m4 == -1 || m5 == -1 || m6 == -1 || m15 == -1 ||
            m7 == -1 || m8 == -1 || m14 == -1 ||
            m10 == -1 || m11 == -1 || m12 == -1 || m13 == -1) {
	_PDMdebug(fname, "%s %s ", "PDMupdate_set_members : Failed to set ",
			"offsets in child buffer \n");
		return (PDM_E_BUFFER_FORMAT);
	}

       /* 
          Instead of locking NFMSETCIT, it's better to lock
          NFMINDEX table and resolve concurrency and the incorrect
          usage of n_citnos and p_pdcnos
        */

      status = NFMstop_transaction (0);
      if (status != NFM_S_SUCCESS)
       {
          NFMrollback_transaction (0);
         _PDMdebug(fname, "Stop Transaction : status = <0x%.8x>\n", status);
         return (status);
       }  

       sprintf(sql_str,"LOCK TABLES NFMINDEX IN EXCLUSIVE MODE");
        status = SQLstmt(sql_str);
         if(status != SQL_S_SUCCESS)
         {
           status = _PDMget_db_error(status);
           if(status == PDM_I_TABLE_LOCKED)
            {
             PDMupdate_dots ();
             msg = (char *)PDUtranslate_message(PDS_M_CONCURRENT_CHECKIN);
             UI_status(msg);
             while(sleep(30)) PDMupdate_dots ();
             sprintf(sql_str,"LOCK TABLES NFMINDEX IN EXCLUSIVE MODE");
             status = SQLstmt(sql_str);
             if(status != SQL_S_SUCCESS)
              {
               status = _PDMget_db_error(status);
                if(status == PDM_I_TABLE_LOCKED)
                  {
                   PDMupdate_dots ();
                   msg = (char *)PDUtranslate_message(PDS_M_CONCURRENT_CHECKIN);
                   UI_status(msg);
                   while(sleep(30)) PDMupdate_dots ();
                    sprintf(sql_str,"LOCK TABLES NFMINDEX IN EXCLUSIVE MODE");
                    status = SQLstmt(sql_str);
                     if(status != SQL_S_SUCCESS)
                      {
                      status = _PDMget_db_error(status);
                      if(status == PDM_I_TABLE_LOCKED)
                        {
                   PDMupdate_dots ();
                   msg = (char *)PDUtranslate_message(PDS_M_CONCURRENT_CHECKIN);
                   UI_status(msg);
                   while(sleep(30)) PDMupdate_dots ();
                    sprintf(sql_str,"LOCK TABLES NFMINDEX IN EXCLUSIVE MODE");
                    status = SQLstmt(sql_str);
                     if(status != SQL_S_SUCCESS)
                      {
                     NFMrollback_transaction (0);
                  _PDMdebug(fname, "LOCK NFMINDEX failed status %d\n", status);
                      return(PDM_E_LOCK_CIT);
                       }
                     }
                     else
                      {
           NFMrollback_transaction (0);
                  _PDMdebug(fname, "LOCK NFMINDEX failed status %d\n", status);
                      return(status);
                      }
                  }
               }
               else
                {
           NFMrollback_transaction (0);
                  _PDMdebug(fname, "LOCK NFMINDEX failed status %d\n", status);
                      return(status);
                 }
           }
         }
          else
             {
           NFMrollback_transaction (0);
                  _PDMdebug(fname, "LOCK NFMINDEX failed status %d\n", status);
                      return(status);
             }
      }
        
	/*
          One nested statement on both pdmcit and nfmsetcit would suffice
to delete the entries both from nfmsetcit and pdmcit. But here it's done
seperately because, join of pdmcit and nfmsetcit in large databases are 
 costly.
	 */

         status = MEMopen(cit_bufr,512);
         if(status != MEM_S_SUCCESS)
         {
           NFMrollback_transaction (0);
          _PDMdebug(fname,"MEMopen failed status %d\n", status);
           return(status);
         }
        status = MEMwrite_format(*cit_bufr, "n_catalogname", "char(20)");
        if (status == MEM_S_SUCCESS)
        status = MEMwrite_format(*cit_bufr, "n_itemname", "char(240)");
        if (status == MEM_S_SUCCESS) 
        status = MEMwrite_format(*cit_bufr, "n_itemrev", "char(240)");
        if (status == MEM_S_SUCCESS) 
        status = MEMwrite_format(*cit_bufr, "p_quantity", "char(32)");
        if (status == MEM_S_SUCCESS) 
        status = MEMwrite_format(*cit_bufr, "p_childno", "integer");
        if (status == MEM_S_SUCCESS) 
        status = MEMwrite_format(*cit_bufr, "p_history", "char(20)");
        if (status == MEM_S_SUCCESS) 
        status = MEMwrite_format(*cit_bufr, "p_usageid", "char(25)");
        if (status == MEM_S_SUCCESS) 
        status = MEMwrite_format(*cit_bufr, "p_attached", "char(2)");
        if (status == MEM_S_SUCCESS) 
        status = MEMwrite_format(*cit_bufr, "p_tagno", "integer");
        if (status == MEM_S_SUCCESS) 
        status = MEMwrite_format(*cit_bufr, "p_alttagno", "char(25)");
        if (status == MEM_S_SUCCESS) 
        status = MEMwrite_format(*cit_bufr, "p_incbom", "char(2)");
        if (status == MEM_S_SUCCESS) 
        status = MEMwrite_format(*cit_bufr, "p_incstr", "char(2)");
        if (status == MEM_S_SUCCESS) 
        status = MEMwrite_format(*cit_bufr, "n_cofilename", "char(15)");
        if (status == MEM_S_SUCCESS) 
        status = MEMwrite_format(*cit_bufr, "p_explode", "char(2)");
        if (status == MEM_S_SUCCESS) 
        status = MEMwrite_format(*cit_bufr, "n_catalogno", "integer");
        if (status == MEM_S_SUCCESS) 
        status = MEMwrite_format(*cit_bufr, "n_itemno", "integer");
        if (status == MEM_S_SUCCESS) 
        status = MEMwrite_format(*cit_bufr, "n_citno", "integer");
        if (status == MEM_S_SUCCESS) 
        status = MEMwrite_format(*cit_bufr, "p_pdcno", "integer");
        if (status != MEM_S_SUCCESS) {
                MEMclose(cit_bufr);
                NFMrollback_transaction (0);
                _PDMdebug(fname, "MEMwrite_format failed status %d\n", status);
                return (PDM_E_WRITE_FORMAT);
        }

        sql_str[0] = '\0';
        sprintf(sql_str,"SELECT n_indexslot from NFMINDEX where n_tablename = 'nfmsetcit' or n_tablename = 'NFMSETCIT'" );
          status = SQLquery(sql_str, &n_citno_bufr,512);
           if(status != SQL_S_SUCCESS)
           {
           _PDMdebug(fname, "NO entry in NFMIDEX table for nfmsetcit  - %d\n", status);
         strcpy (sql_str, "select max(n_citno) from nfmsetcit");
         status = NFMretrieve_values (sql_str, 1, dumb_str,&citno, &dumb_list);
            if (status != NFM_S_SUCCESS)
             {
                NFMrollback_transaction (0);
               _PDMdebug (fname, "SQLquery(%s) 0x%.8x\n", sql_str, status);
                return (NFM_E_SQL_QUERY);
                }
               MEMclose(&dumb_list);
             citno++;
           }
          else
           {
            status = MEMbuild_array(n_citno_bufr);
            if(status != MEM_S_SUCCESS)
            {
             NFMrollback_transaction (0);
              MEMclose(&n_citno_bufr);
             _PDMdebug(fname, "MEMbuild_array status %d\n", status);
             return(status);
            }
           data = (char **) n_citno_bufr->data_ptr;
           citno = atoi(data[0]);
           }
         MEMclose(&n_citno_bufr);

        sql_str[0] = '\0';
        sprintf(sql_str,"SELECT  n_indexslot from NFMINDEX where n_tablename = 'pdmcit' or n_tablename = 'PDMCIT' ");
          status = SQLquery(sql_str, &n_citno_bufr,512);
           if(status != SQL_S_SUCCESS)
           {
           _PDMdebug(fname, "NO entry in NFMIDEX table for nfmsetcit  - %d\n", status);
          strcpy (sql_str, "select max(p_citno) from pdmcit");
         status = NFMretrieve_values (sql_str, 1, dumb_str, &pdcno, &dumb_list);
            if (status != NFM_S_SUCCESS)
             {
                NFMrollback_transaction (0);
               _PDMdebug (fname, "SQLquery(%s) 0x%.8x\n", sql_str, status);
                return (NFM_E_SQL_QUERY);
                }
               MEMclose(&dumb_list);
             pdcno++;
           }
          else
           {
            status = MEMbuild_array(n_citno_bufr);
            if(status != MEM_S_SUCCESS)
            {
              NFMrollback_transaction (0);
              MEMclose(&n_citno_bufr);
             _PDMdebug(fname, "MEMbuild_array status %d\n", status);
             return(status);
            }
           data = (char **) n_citno_bufr->data_ptr;
           pdcno = atoi(data[0]);
           }
         MEMclose(&n_citno_bufr);

          /* Update the citnos and pdcnos in the NFMINDEX table */
         _PDMdebug(fname,"N_CITNO %d\n", citno);
         _PDMdebug(fname,"P_PDCNO %d\n", pdcno);
         sql_str[0] = '\0';
         sprintf(sql_str,"UPDATE NFMINDEX SET n_indexslot = %d  WHERE n_tablename = 'nfmsetcit' ", (citno + child_bufr->rows));
          status = SQLstmt(sql_str);
          if(status != SQL_S_SUCCESS)
           {
     sprintf(sql_str,"DELETE FROM NFMINDEX  WHERE n_tablename = 'nfmsetcit'");
          status = SQLstmt(sql_str);
         sprintf(sql_str,"INSERT INTO NFMINDEX (n_indexslot, n_tablename) VALUES (%d, 'nfmsetcit') ", (citno + child_bufr->rows));
          status = SQLstmt(sql_str);
          if(status != SQL_S_SUCCESS)
           {
            status = NFMrollback_transaction(0);
        _PDMdebug(fname, "Insert into NFMINDEX failed : status = <0x%.8x>\n", status);
            return(status);
           }
          }
         sql_str[0] = '\0';
         sprintf(sql_str,"UPDATE NFMINDEX SET n_indexslot = %d  WHERE n_tablename = 'pdmcit' ", (pdcno + child_bufr->rows));
          status = SQLstmt(sql_str);
          if(status != SQL_S_SUCCESS)
           {
     sprintf(sql_str,"DELETE FROM NFMINDEX  WHERE n_tablename = 'pdmcit'");
          status = SQLstmt(sql_str);
         sprintf(sql_str,"INSERT INTO NFMINDEX (n_indexslot, n_tablename) VALUES (%d, 'pdmcit') ", (pdcno + child_bufr->rows));
          status = SQLstmt(sql_str);
          if(status != SQL_S_SUCCESS)
           {
            status = NFMrollback_transaction(0);
        _PDMdebug(fname, "Insert into NFMINDEX failed : status = <0x%.8x>\n", status);
            return(status);
           }
          }
      /* Release the lock on the NFMINDEXES TABLE */

      status = NFMstart_transaction (0);
      if (status != NFM_S_SUCCESS)
       {
         NFMrollback_transaction (0);
        _PDMdebug(fname, "Start Transaction : status = <0x%.8x>\n", status);
         return (status); 
       }

       if(citno >= 2147483648) /* 2^31 - Two to the power of 31 */
        {
          _PDMdebug(fname, "Cleanup your CIT, by rearranging your data\n");
          return(PDM_E_LOCK_CIT);
        }
            
        
	if (PDMdebug_on)
	MEMprint_buffer("cit_bufr", *cit_bufr, PDM_DEBUG_FILE);
	/* add new children /
	 adding rows to MEMbuffer increments no of rows 
	 this part of the logic will be on set_copy */

      status = NFMstop_transaction (0);
      if (status != NFM_S_SUCCESS)
       {
         NFMrollback_transaction (0);
        _PDMdebug(fname, "Start Transaction : status = <0x%.8x>\n", status);
         return (status); 
       }
        status = PDMdelete_pdm_entries(p_catno,p_itemno, citno_bufr);
	if (status != PDM_S_SUCCESS) {
            NFMrollback_transaction (0);
	_PDMdebug(fname, "PDMdelete_pdm_entries failed status -> %d", status);
		return (PDM_E_QUERY_SET_MEMBERS);
                }
        sql_str[0]='\0';
       /* delete all the first level children for the given part
          There is no need for calling the function
          NFMupdate_set_members with the level as 1. NFMupdate_set_members
          should be called only to get children with more than
          1 level */
       sprintf(sql_str,"DELETE FROM NFMSETCIT WHERE n_pcatalogno = %d AND n_pitemno = %d ",p_catno,p_itemno);
        status = SQLstmt(sql_str);

  status = SQLstmt (sql_str);
  if (status != SQL_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND) {
      /*   locking the catalog tables during update
            to keep spinning for 30+30+30+30 seconds. The right fix is row
            level locking supported by informix and oracle */
      if (status == SQL_E_MESSAGE) {
          msg = (char *)PDUtranslate_message(PDS_M_CONCURRENT_TAB_ACCESS_HOLD);
          UI_status (msg);
          sleep (30);
          status = SQLstmt (sql_str);
          if (status != SQL_S_SUCCESS) {
              UI_status (msg);
              sleep (30);
              status = SQLstmt (sql_str);
              if (status != SQL_S_SUCCESS) {
                 msg = (char *)PDUtranslate_message(PDS_M_CONCURRENT_TAB_ACCESS);
                 UI_status (msg);
                    if (status == NFM_E_LOCK_TABLE_FAILED)
                    status = PDM_I_TABLE_LOCKED;
                    _PDMdebug (fname, "NFMlock_table(%s) failed 0x%.8x\n", 
                              "NFMSETCIT",status);
                   return (status);
                     }
             }
        }
      else  {
     _PDMdebug (fname, "SQLstmt failed status %d\n", status);
     status = _PDMget_db_error (status);
     PDMrollback_transaction (1200);
     return (status);
     }
    }

	for (i = 0; i < child_bufr->rows; i++) 
         {
         nxi = i * child_bufr->columns;
	_PDMdebug(fname, "adding row %d\n", i);

         status = PDMadd_child(catalog, n_itemname, n_itemrev, p_catno, p_itemno, child_data[nxi +m1], child_data[nxi + m2], child_data[nxi + m3], &c_catno, &c_itemno, citno, &actual_citno);
           if(status != PDM_S_SUCCESS)
             {
    sprintf(sql_str,"DELETE FROM NFMINDEX  WHERE n_tablename = 'pdmcit' \
                   or n_tablename = 'nfmsetcit';");
          SQLstmt(sql_str);
          strcpy (sql_str, "select max(p_pdcno) from pdmcit");
         NFMretrieve_values (sql_str, 1, dumb_str, &pdcno, &dumb_list);
           MEMclose(&dumb_list);
         sprintf(sql_str,"INSERT INTO NFMINDEX (n_indexslot, n_tablename) VALUES (%d, 'pdmcit') ", pdcno );
           SQLstmt(sql_str);
          strcpy (sql_str, "select max(n_citno) from nfmsetcit");
         NFMretrieve_values (sql_str, 1, dumb_str, &pdcno, &dumb_list);
           MEMclose(&dumb_list);
         sprintf(sql_str,"INSERT INTO NFMINDEX (n_indexslot, n_tablename) VALUES (%d, 'nfmsetcit') ", pdcno );
           SQLstmt(sql_str);
               _PDMdebug(fname, "PDMadd_child failed status %d\n", status);
               _PDMdebug(fname, "catalog <%s> partnum <%s> revision <%s>\n", child_data[nxi+m1], child_data[nxi + m2], child_data[nxi + m3]);
         NFMrollback_transaction (0);
                return(status);
            }

         mem_str[0] = '\0';
        sprintf(mem_str,"%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%d\1%d\1%d\1%d\1",child_data[nxi + m1], child_data[nxi +m2], child_data[nxi+m3],child_data[nxi +m5], child_data[nxi+m7], child_data[nxi+m6], child_data[nxi+m8], child_data[nxi + m4], child_data[nxi + m10], child_data[nxi +m11], child_data[nxi + m12], child_data[nxi +m15], child_data[nxi +m14], child_data[nxi + m13],c_catno, c_itemno, actual_citno,pdcno); 
			
			_PDMdebug(fname,"%s\n",mem_str);
			status = MEMwrite(*cit_bufr, mem_str);
			if (status != MEM_S_SUCCESS) {
			_PDMdebug(fname, "MEMwrite failed status", status);
                        NFMrollback_transaction (0);
				MEMclose(cit_bufr);
				return (PDM_E_WRITE_ROW);
			}
          citno++;
          pdcno++;
	}		/* end of if newchild */

	if (PDMdebug_on)
	MEMprint_buffer("cit_bufr", *cit_bufr, PDM_DEBUG_FILE);

	_PDMdebug(fname, "EXIT:\n");
	return (PDM_S_SUCCESS);
}


/*
 * This function is to be called whenever (during checkin) the n_citnos are
 * changed by NFM.
 * 
 * DESCRIPTION:
 * 
 * (a)Keeps up with the changes to pdmcit table. old_set contains p_citno's
 * prior to checkin. All the entries in pdmcit with the matching p_citno can
 * be deleted. Then all the entries in child_bufr are inserted into pdmcit
 * using set_data. It works because .. set_data contains the new n_citnos ->
 * by matching the catalog,partnum,partrev entries the new n_citno in nfmcit
 * can be found
 * 
 * (b)Keeps up with changes to y_xxx entries
 * 
 *  Kumar Narayanan
 */


int PDMinsert_citinfo(p_catalogno,p_itemno,child_bufr, parm_buffer, parmdata_buffers,citno,p_update)
int   p_catalogno;
int   p_itemno;
MEMptr          child_bufr;
MEMptr          parm_buffer;
MEMptr          parmdata_buffers;
MEMptr          citno;
char *p_update;
{
	char          **column_ptr = NULL;
	char          **child_data = NULL, **fly_data = NULL;
	int             m1 = -1, m2 = -1, m3 = -1, m4 = -1, m5 = -1, m6 = -1, m7 = -1, m8 = -1, m9 = -1, m10 = -1, m11 = -1, m12 = -1, m13 = -1, m14 = -1,m15 = -1, m16 =-1,m17 = -1, m19 = -1, m20 = -1, m21 = -1;
	int             i = 0, nxi = 0;
        char            sql_str[2049] = "", sql_str1[1024] = "", sql_str2[1024] = "";
        char            *fname = "PDMinsert_citinfo";

	_PDMdebug(fname,"ENTER:\n");
	_PDMdebug(fname,"UPDATE FLAG %s:\n", p_update);
   _PDMdebug(fname,"p_catalogno %d - p_itemno %d \n", p_catalogno, p_itemno);

        status = MEMbuild_array(child_bufr);
        if(status != MEM_S_SUCCESS)
         {
          NFMrollback_transaction (0);
          _PDMdebug(fname,"MEMbuild_array status %d\n", status);
          return(status);
         }
	m1 = -1;
	m2 = -1;
	m3 = -1;
	m4 = -1;
	m5 = -1;
	m6 = -1;
	m7 = -1;
	m8 = -1;
	m9 = -1;
	m10 = -1;
	m11 = -1;
	m12 = -1;
	m13 = -1;
	m14 = -1;
	m15 = -1;
	m16 = -1;
	m17 = -1;
	m19 = -1;
	m20 = -1;
	m21 = -1;
	column_ptr = (char **) child_bufr->column_ptr;
	child_data = (char **) child_bufr->data_ptr;
	for (i = 0; i < child_bufr->columns; i++) {
		if (!strcmp(column_ptr[i], "n_catalogname"))
			m1 = i;
	else	if (!strcmp(column_ptr[i], "n_itemname"))
			m2 = i;
	else	if (!strcmp(column_ptr[i], "n_itemrev"))
			m3 = i;
	else	if (!strcmp(column_ptr[i], "p_quantity"))
			m4 = i;
	else	if (!strcmp(column_ptr[i], "p_history"))
			m5 = i;
	else	if (!strcmp(column_ptr[i], "p_childno"))
			m6 = i;
	else	if (!strcmp(column_ptr[i], "p_usageid"))
			m7 = i;
	else	if (!strcmp(column_ptr[i], "p_tagno"))
			m8 = i;
	else	if (!strcmp(column_ptr[i], "p_alttagno"))
			m9 = i;
	else	if (!strcmp(column_ptr[i], "p_incbom"))
			m10 = i;
	else	if (!strcmp(column_ptr[i], "p_explode"))
			m11 = i;
	else	if (!strcmp(column_ptr[i], "p_attached"))
			m12 = i;
	else	if (!strcmp(column_ptr[i], "n_cofilename"))
			m13 = i;
        else    if (!strcmp(column_ptr[i], "p_incstr"))
                        m14 = i;
        else    if (!strcmp(column_ptr[i], "n_citno"))
                        m15 = i;
        else    if (!strcmp(column_ptr[i], "p_pdcno"))
                        m16 = i;
	}
	if (m1 == -1 || m2 == -1 || m3 == -1 || m4 == -1 ||
	    m5 == -1 || m6 == -1 || m9 == -1 ||
	    m7 == -1 || m8 == -1 ||  m10 == -1 ||  
	    m11 == -1 || m12 == -1 || m13 == -1 || m14 == -1 
                      || m15 == -1 || m16 == -1) {
	_PDMdebug(fname, "%s  \n", " Incorrect buffer format in child_bufr");
          NFMrollback_transaction (0);
		return (PDM_E_BUFFER_FORMAT);

	}

	/* cleanup pdmcit, pdc_xxx */

	status = PDMi_delete_dynamic_info(citno);
	if (status != PDM_S_SUCCESS) {
	_PDMdebug(fname, "PDMi_delete_pdcentries failed status %d\n", status);
          NFMrollback_transaction (0);
                 return(status);
	}

	/* insert new entries in child_bufr into pdmcit */

	sql_str1[0] = '\0';
	sprintf(sql_str1, "INSERT INTO pdmcit (p_citno,n_catalogname,n_itemname,n_itemrev,n_cofilename,p_childno,p_attached, p_history,p_quantity,p_usageid,p_tagno,p_alttagno,p_incbom,p_explode,p_pdcno) VALUES ");
	for (i = 0; i < child_bufr->rows; i++) {
		nxi = i * child_bufr->columns;
		sql_str2[0] = '\0';

/* support added for background part (p_incstr):
     p_incstr   p_incbom        p_incbom
     Y          Y               Y
     N          N               N
     Y          N               A
     N          Y               B
  */
     if ((!strcmp (child_data[nxi+m10], "Y") ||
                          !strcmp (child_data[nxi+m10], "y")) &&
         (!strcmp (child_data[nxi+m14], "Y") ||
                          !strcmp (child_data[nxi+m14], "y")))
                                        strcpy (child_data[nxi+m10], "Y");
     else if ((!strcmp (child_data[nxi+m10], "N") ||
                          !strcmp (child_data[nxi+m10], "n")) &&
         (!strcmp (child_data[nxi+m14], "N") ||
                          !strcmp (child_data[nxi+m14], "n")))
                                        strcpy (child_data[nxi+m10], "N");
     else if ((!strcmp (child_data[nxi+m10], "N") ||
                          !strcmp (child_data[nxi+m10], "n")) &&
         (!strcmp (child_data[nxi+m14], "Y") ||
                          !strcmp (child_data[nxi+m14], "y")))
                           strcpy (child_data[nxi+m10], "A");
        else if ((!strcmp (child_data[nxi+m10], "Y") ||
                          !strcmp (child_data[nxi+m10], "y")) &&
         (!strcmp (child_data[nxi+m14], "N") ||
                          !strcmp (child_data[nxi+m14], "n")))
                                        strcpy (child_data[nxi+m10], "B");

        sprintf(sql_str2, "(%s,'%s','%s','%s','%s',%s,'%s','%s',%s,'%s',%s,'%s', '%s','%s',%s)", child_data[nxi + m15], child_data[nxi + m1], child_data[nxi + m2], child_data[ nxi + m3], child_data[nxi + m13],child_data[nxi+m6],child_data[nxi+m12],child_data[nxi+m5],child_data[nxi+m4],child_data[nxi+m7],child_data[nxi+m8],child_data[nxi+m9],child_data[nxi+m10],child_data[nxi + m11], child_data[nxi +m16]);
  
		sql_str[0] = '\0';
		sprintf(sql_str, "%s %s", sql_str1, sql_str2);
		status = SQLstmt(sql_str);
		if (status != SQL_S_SUCCESS) {
                      NFMrollback_transaction (0);
			switch (status) {
			case PDMS_NO_SUCH_TABLE:
			_PDMdebug(fname, "%s \n", "pdmcit not found");
			break;
			default:
			break;
			}
			return (status);
		}
	}			/* end .. for all children */

	if ((parm_buffer == NULL) || (parm_buffer->rows == 0)) {
	_PDMdebug(fname,"EXIT:PDMinsert_citinfo - No dynamic part info\n");
		return (PDM_S_SUCCESS);
	}
	/* set offsets in parm_buffer */

	m1 = -1;
	m2 = -1;
	m3 = -1;
	m4 = -1;
	m5 = -1;
	m6 = -1;
	m7 = -1;
	m8 = -1;
	m9 = -1;

	status = MEMbuild_array(parm_buffer);
	if (status != MEM_S_SUCCESS) {
	_PDMdebug(fname, "MEMbuild_array failed status %d\n", status);
                NFMrollback_transaction (0);
		return (PDM_E_BUILD_ARRAY);
	}
	fly_data = (char **) parm_buffer->data_ptr;
	for (i = 0; i < parm_buffer->rows; i++) {
		status = MEMreset_buffer_no(parmdata_buffers, i + 1);
		if (status != MEM_S_SUCCESS) {
	_PDMdebug(fname, "MEMreset_buffer_no failed status %d\n", status);
                NFMrollback_transaction (0);
			return (PDM_E_RESET_BUFFER);
		}
	status = PDMinsert_dynamic_table_info(fly_data[i], child_bufr, parmdata_buffers);
	if (status != PDM_S_SUCCESS) {
_PDMdebug(fname, "PDMinsert_dynamic_table_info failed status %d\n", status);
                        NFMrollback_transaction (0);
			return (PDM_E_COPY_BUFFER);
		}
	}
      status = NFMstart_transaction (0);
      if (status != NFM_S_SUCCESS)
       {
         NFMrollback_transaction (0);
        _PDMdebug(fname, "Start Transaction : status = <0x%.8x>\n", status);
         return (status); 
       }
	_PDMdebug(fname,"EXIT:\n");
	return (PDM_S_SUCCESS);
}

/* Written to delete the entries from pdmcit and nfmsetcit
   in a more efficient way  - Kumar 7/19/92 */

int PDMdelete_pdm_entries(n_pcatalogno,n_pitemno, citno)
int n_pcatalogno,n_pitemno;
MEMptr *citno;
{
        char		*fname = "PDMdelete_pdm_entries";
	int             i, nxi;
	char            *sql_str, *sql_str2;
	char            sql_str1[512];
	char          **data_ptr;
        char           *msg = NULL;
        MEMptr        set_data = NULL;

	PDMdebug("ENTER:PDMdelete_pdm_entries\n");


 sql_str1[0]='\0';
       /* select all the first level children for the given part
          There is no need for calling the function
          PDMsetup_assembly_buffer with the level as 1. PDMsetup_assembly_buffer
          should be called only to get children with more than
          1 level */
       sprintf(sql_str1,"SELECT n_citno,n_pcatalogno,n_pitemno,n_ccatalogno, n_citemno FROM NFMSETCIT WHERE n_pcatalogno = %d AND n_pitemno = %d",n_pcatalogno,n_pitemno);
        status = SQLquery(sql_str1,&set_data,1024);
        if (status == SQL_I_NO_ROWS_FOUND)
           {
	PDMdebug("Nothing to delete from nfmsetcit, pdmcit for this part\n");
	PDMdebug("EXIT:PDMdelete_pdm_entries\n");
             return(PDM_S_SUCCESS);
           }
        else if (status != SQL_S_SUCCESS)
           {
             MEMclose(&set_data);
status = _PDMget_db_error (status);
             return(status);
           }

       /* delete all the first level children for the given part
          There is no need for calling the function
          NFMupdate_set_members with the level as 1. NFMupdate_set_members
          should be called only to get children with more than
          1 level */
       

	status = MEMbuild_array(set_data);
	if (status != MEM_S_SUCCESS) {
		sprintf(s, " %s %s %d \n",
			"PDMdelete_pdm_entriesbers : MEMbuild_array ",
			" failed status -> ", status);
		PDMdebug(s);
		MEMclose(&set_data);
		return (status);
	}

	data_ptr = (char **) set_data->data_ptr;
        sql_str = (char *) malloc( (set_data->rows * 25) + 100);
        memset(sql_str,NULL,( (set_data->rows * 25) + 100));
        sql_str2 = (char *) malloc( (set_data->rows * 25) + 100);
        memset(sql_str2,NULL,( (set_data->rows * 25) + 100));

        sql_str[0]='\0';
        sql_str2[0]='\0';
 

	/* delete old pdmcit assembly structure */
	for (i = 0; i < set_data->rows; i++) {
		nxi = i * set_data->columns;
               if (i == 0 && atol(data_ptr[nxi])) {
		sprintf(sql_str, "%s %s %s %d",
			"DELETE FROM ", "pdmcit",
			" WHERE p_citno = ", atol(data_ptr[nxi]));
		sprintf(sql_str2, "%s %s %s %d",
		"SELECT p_citno, p_pdcno, n_catalogname FROM ", "pdmcit",
			" WHERE p_citno = ", atol(data_ptr[nxi]));
                     } else {
                        if(atol(data_ptr[nxi]))
                         {
                            strcat(sql_str, " OR p_citno = ");
                            strcat(sql_str2, " OR p_citno = ");
                            strcat(sql_str, data_ptr[nxi]);
                            strcat(sql_str2, data_ptr[nxi]);

                          }
                 }
           }
		status = SQLquery(sql_str2, citno, 512);
	if (status != SQL_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND) {

			sprintf(s, "SQLstmt failed status %d\n", status);
			PDMdebug(s);
                         free(sql_str);
                         free(sql_str2);
			MEMclose(&set_data);
			return (PDM_E_SQL_STMT);
		}

  status = SQLstmt (sql_str);
  if (status != SQL_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND) {
      /*   locking the catalog tables during update
            to keep spinning for 30+30+30+30 seconds. The right fix is row
            level locking supported by informix and oracle */
      if (status == SQL_E_MESSAGE) {
          msg = (char *)PDUtranslate_message(PDS_M_CONCURRENT_TAB_ACCESS_HOLD);
          UI_status (msg);
          sleep (30);
          status = SQLstmt (sql_str);
          if (status != SQL_S_SUCCESS) {
              UI_status (msg);
              sleep (30);
              status = SQLstmt (sql_str);
              if (status != SQL_S_SUCCESS) {
                msg = (char *)PDUtranslate_message(PDS_M_CONCURRENT_TAB_ACCESS);
                 UI_status (msg);
                    if (status == NFM_E_LOCK_TABLE_FAILED)
                    status = PDM_I_TABLE_LOCKED;
                    _PDMdebug (fname, "NFMlock_table(%s) failed 0x%.8x\n",
                              "NFMSETCIT",status);
                   return (status);
                     }
             }
        }
      else  {
     _PDMdebug (fname, "SQLstmt failed status %d\n", status);
     status = _PDMget_db_error (status);
     PDMrollback_transaction (1200);
     free(sql_str);
     free(sql_str2);
     MEMclose(&set_data);
     return (status);
     }
    }


                         free(sql_str);
                         free(sql_str2);
			MEMclose(&set_data);
	PDMdebug("EXIT:PDMdelete_pdm_entries\n");
	return (PDM_S_SUCCESS);
}


 int PDMadd_child 
    (
    char  *catalog,
    char  *n_itemname,
    char  *n_itemrev,
    int   p_catno,
    int   p_itemno,
    char  *c_catalog,
    char  *c_itemname,
    char  *c_itemrev,
    int    *child_catno, 
    int    *child_itemno, 
    int    next_citno,
    int    *n_citno
      )
{
      static char *fname = "PDMadd_child" ;
      long      status = PDM_S_SUCCESS;
      char      p_assembly[8], type [8];
      char      cit_str[512] = "";
      int       p_citno = 0;
      int       c_catno = 0;
      int       c_itemno = 0;

      _PDMdebug (fname, "Parent - Cat   = <%s> : Parent Item  = <%s> Parent Rev <%s>: \n", catalog, n_itemname, n_itemrev);
      _PDMdebug (fname, "Parent - Cat  No = <%d> : Parent Item No = <%d>\n", p_catno, p_itemno);
      _PDMdebug (fname, "Child - Cat  No = <%d> : Child Item No = <%d> : Row No = <%d>\n", c_catno, c_itemno, next_citno);

       type[0]='\0';
       p_assembly[0]='\0';

    if(!strcmp(prev_cat,c_catalog)) 
     {
       _PDMdebug (fname, "Saved one query - prev cat No :%d\n", prev_catno);
          c_catno = prev_catno; 
           strcpy(type, prev_type);
     }
     else
     {
        status = PDMquery_catalogno_type (c_catalog, &c_catno, type);
        if (status != PDM_S_SUCCESS)
         {
         _PDMdebug (fname, "Get Cat No : status = <0x%.8x>\n", status);
         return (status); 
          }
            strcpy(prev_cat, c_catalog);
             prev_catno = c_catno; 
             strcpy(prev_type,type);
         _PDMdebug (fname, "Loading prev cat No :%d\n", prev_catno);
     }

      if(!strcmp(prev_cat,c_catalog) &&
         !strcmp(prev_part,c_itemname) &&
         !strcmp(prev_rev, c_itemrev))
        {
        _PDMdebug (fname, "Saved one query prev Item No :%d\n", prev_itemno);
           strcpy(p_assembly, prev_ind);
           c_itemno =  prev_itemno;
         }
        else
         {
      status = PDMquery_itemno_assind (c_catalog,
        c_itemname, c_itemrev, type, p_assembly, &c_itemno);
      if (status != PDM_S_SUCCESS)
       {
         _PDMdebug (fname, "Get Item No : status = <0x%.8x>\n", status);
         return (status); 
       }
             strcpy(prev_part, c_itemname);
             strcpy(prev_rev, c_itemrev);
            strcpy(prev_ind,p_assembly);
            prev_itemno = c_itemno;
         _PDMdebug (fname, "Loading prev Item No :%d\n", prev_itemno);
         }

   
      status = PDMget_citno(p_catno, p_itemno, c_catno, c_itemno, &p_citno);
          if(status != PDM_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND)
       {
         _PDMdebug (fname, "PDMget_citno : status = <0x%.8x>\n",
         status);
         return (status); 
       }

      if(status  == SQL_I_NO_ROWS_FOUND)
        {
         *n_citno = next_citno;
        cit_str[0] = '\0';  
      sprintf (cit_str,  "INSERT INTO NFMSETCIT (n_citno, n_pcatalogno, n_pitemno, n_ccatalogno, n_citemno, n_type) VALUES (%d, %d, %d, %d, %d, '%s')", *n_citno, p_catno, p_itemno, c_catno, c_itemno, "S");

      status = SQLstmt (cit_str);
      if (status != SQL_S_SUCCESS)
       {
        _PDMdebug (fname, "SQL Stmt Syntax : status = <0x%.8x>\n", status);
        _PDMdebug (fname, "Error Adding a child to the assembly \n");
         return (NFM_E_SQL_STMT); 
       }

       }
       else  if(status  == PDM_S_SUCCESS)
       {
         *n_citno = p_citno;
       }
       else
          {
           _PDMdebug(fname, "Couldn't add the part <0x%.8x>\n", status);
            return(status);
           }
       
      *child_catno = c_catno;
      *child_itemno = c_itemno;
      _PDMdebug (fname, "SUCCESSFUL : status = <0x%.8x>\n", PDM_S_SUCCESS);
      return (PDM_S_SUCCESS); 
} 


/* Written to delete the duplicate entries in the dynamic table
   - Kumar 6.15.93 */

int  PDMi_delete_dynamic_info(pdcno)
MEMptr  pdcno;
{
        char    *fname = "PDMi_delete_dynamic_info";
        char    *sql_str = NULL, temp_cat[20] = "";
        char    **cit_data = NULL;
        char   dyn_table[20] = "";
        int     nxi = 0, i= 0;

        _PDMdebug(fname, "ENTER:\n");

        if(pdcno)
       {
        status = MEMbuild_array(pdcno);
        if(status != MEM_S_SUCCESS)
        {
           _PDMdebug (fname, "SQLquery : status = <0x%.8x>\n", status);
           return (status) ;
         }
        cit_data = (char **) pdcno->data_ptr;

         if(pdcno->rows == 0)
            return (PDM_S_SUCCESS) ;
         else
        {
         sql_str = (char *) malloc (pdcno->rows * 30 + 100);
         sql_str[0] = '\0';
      temp_cat[0] = '\0';
      for (i = 0; i < pdcno->rows; i++) 
      {
      nxi = i * pdcno->columns; 
         if(!strcmp(temp_cat, cit_data[nxi + 2]))
         {
             if(atol(cit_data[nxi+1]))
             {
              strcat(sql_str, " OR p_pdcno = ");
              strcat(sql_str, cit_data[nxi+1]);
             }
             else
              strcat(sql_str, " OR p_pdcno = 0");
         }
       else
         {
         if(i != 0) 
           {
             if(strcmp(sql_str,""))
              {
            status = SQLstmt(sql_str);
             if(status != SQL_S_SUCCESS)
              _PDMdebug(fname,"SQLstmt failed status %d\n", status);
             sql_str[0] = '\0';
              }
             }
         sql_str[0] = '\0';
         strcpy(temp_cat,cit_data[nxi + 2]);
         status = PDMget_dyntable_for_catalog(cit_data[nxi +2], &dyn_table);
          if(status != PDM_S_SUCCESS)
          {
      _PDMdebug(fname,"PDMget_dyntable_for_catalog failed status %d\n",status);
        return(status);
           }
            if(strcmp(dyn_table,""))
            {
            if(strlen(cit_data[nxi +1]))
           sprintf(sql_str, "%s %s %s %s", "DELETE FROM ", dyn_table,
                        " WHERE p_pdcno = ", cit_data[nxi+1]);
             else
           sprintf(sql_str, "%s %s %s ", "DELETE FROM ", dyn_table,
                        " WHERE p_pdcno = 0");
            }

           if(i == 0 && (pdcno->rows == 1))
            {
             if(strcmp(sql_str,""))
              {
             status = SQLstmt(sql_str);
              if(status != SQL_S_SUCCESS)
              _PDMdebug(fname, "SQLstmt failed status %d\n", status);
              sql_str[0] = '\0';
               }
             }
          }
        }
       if (strcmp(sql_str,""))
        {
          status = SQLstmt(sql_str);
          if(status != SQL_S_SUCCESS)
            _PDMdebug(fname,"SQLstmt failed status %d\n", status);
          sql_str[0] = '\0';
        }  
       free(sql_str);
      }
    }
        _PDMdebug(fname, "EXIT:\n");
        return(PDM_S_SUCCESS);
}


int PDMget_citno
              (
             int p_catno, 
             int p_itemno,
             int c_catno,
             int c_itemno,
             int *n_citno
              )

{
 long status = PDM_S_SUCCESS;
 MEMptr bufr = NULL;
 char **data = NULL;
 char  sql_str[250] = "";
 char  *fname = "PDMget_citno";

   _PDMdebug(fname,"Enter\n");

    sprintf(sql_str,"SELECT n_citno from NFMSETCIT where n_pcatalogno = %d AND n_pitemno = %d AND n_ccatalogno = %d AND n_citemno = %d", p_catno, p_itemno, c_catno, c_itemno);

        status = SQLquery(sql_str,&bufr,512);
         if(status != SQL_S_SUCCESS )
           {
            MEMclose(&bufr); 
            _PDMdebug(fname,"SQLquery failed status %d\n", status);
             return(status);
           }

        status = MEMbuild_array(bufr);
          if(status != MEM_S_SUCCESS)
           {
            MEMclose(&bufr); 
            _PDMdebug(fname, "PDMget_citno failed status %d\n", status);
             return(status);
            }
        data = (char **) bufr->data_ptr;
       *n_citno = atoi(data[0]);

       MEMclose(&bufr); 

        _PDMdebug(fname,"Exit\n");
    return(PDM_S_SUCCESS);
}

int PDMinsert_dynamic_table_info (n_catalogname, cit_bufr, parm_data)
char     *n_catalogname;
MEMptr    cit_bufr;
MEMptr    parm_data;
{
     char     *fname = "PDMinsert_dynamic_table_info";
     char     dynamic_table[20] = "";
     char     p_pdcno[40] = "";
     char     val[512];
     int      i = 0, m = 0, nx = 0, nx1 = 0, j = 0, k = 0;
     int      size = 0,length = 0, found = 0;
     char     **data = NULL, **cit_data = NULL;
     char     **column = NULL, **format = NULL, **attr_col = NULL;
     char     sql_str1[512], *attrbs =NULL, *values = NULL, *sql_str = NULL;
     MEMptr   attr_bufr = NULL;

     _PDMdebug(fname, "ENTER:\n");

     if(PDMdebug_on) 
          {
           _PDMdebug(fname, "catalogname [%s]\n", n_catalogname);
          }

    status = PDMget_dyntable_for_catalog(n_catalogname, &dynamic_table);
    if(status != PDM_S_SUCCESS) {
           _PDMdebug(fname,
              "PDMget_dyntable_for_catalog failed status <0x%.8x>\n",status);
           return(status);
           }

    _PDMdebug (fname, "dynamic_table [%s]\n", dynamic_table);

   /* Query the table directly instead of querying the nfmattributes table 
      to validate the attributes of the dynamic table */

     sql_str1[0] = '\0';

    sprintf(sql_str1,"SELECT * from %s WHERE p_pdcno = -1", dynamic_table);
    status = SQLquery(sql_str1, &attr_bufr, 512);
    if(status != SQL_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND)
        {
         _PDMdebug(fname, "SQLquery failed status <0x%.8x>\n", status);
          return(status);
        }

    if (PDMdebug_on) {
	   MEMprint_buffer("cit_bufr", cit_bufr, PDM_DEBUG_FILE);
	   MEMprint_buffer("parm_data", parm_data, PDM_DEBUG_FILE);
         }

    status = MEMbuild_array(cit_bufr);
    if(status != MEM_S_SUCCESS)
       {
        _PDMdebug(fname, "MEMbuild_array failed status <0x%.8x>\n", status);
        return(status);
        }
    cit_data = (char **) cit_bufr->data_ptr;

    status = MEMbuild_array(attr_bufr);
    if(status != MEM_S_SUCCESS)
       {
        _PDMdebug(fname, "MEMbuild_array failed status <0x%.8x>\n", status);
        return(status);
        }
    /* there is no need to set the parm_data pointers. Because it's already
        set in the MEMreset_buffers */
 
    attr_col = (char **) attr_bufr->column_ptr;
    column = (char **) parm_data->column_ptr;
    size = 512;
    for(i=1;i<parm_data->columns;i++)
    {
          size = size + strlen(column[i]);
     }

    _PDMdebug(fname, "column size <%d>\n", size);

    attrbs = (char *) malloc(size);
    if(attrbs == NULL)
     {
          _PDMdebug(fname, "malloc failed \n");
          return(PDM_E_COULD_NOT_MALLOC);
     }

    format = (char **) parm_data->format_ptr;
    size = 512;
    for(i=1;i<parm_data->columns;i++)
    {
          if(!strncmp(format[i],"char",4))
          sscanf(format[i],"char(%d)",&length);
          else length = 40;
          size = size + length;
    }
    _PDMdebug(fname, "format size <%d>\n", size);
    values = (char *) malloc(size);
    if(values == NULL)
    {
          _PDMdebug(fname, "values malloc failed \n");
          free(attrbs);
          return(PDM_E_COULD_NOT_MALLOC);
     }
    sql_str = (char *) malloc(strlen(attrbs) + strlen(values) +512);
    if(sql_str == NULL)
     {
          _PDMdebug(fname, "sql_str malloc failed \n");
          free(attrbs); free(values);
          return(PDM_E_COULD_NOT_MALLOC);
     }

     /* set the type for the family once */

    strcpy (attrbs,"(p_pdcno");
    for(i=2;i<parm_data->columns;i++)
    {
         found = 0;
          for(m = 0; m < attr_bufr->columns; m++)
           {
            if(!strcmp(attr_col[m], column[i]))
             {
              found = 1; break;
             }
           }
           if(found) 
               {
               strcat(attrbs,",");
               strcat(attrbs,column[i]);
                }
            else continue;

     }
    strcat(attrbs,")");

    _PDMdebug(fname, "attrbs <%s> \n", attrbs);
    data = (char **) parm_data->data_ptr;
    format = (char **) parm_data->format_ptr;
    for(i=0;i<parm_data->rows;i++)
     {
          nx = i * parm_data->columns;
          strcpy(values," VALUES (");
          strcpy(p_pdcno,"");
          for(k=0;k<cit_bufr->rows;k++)
          {
               nx1 = k * cit_bufr->columns;
                 if(!strcmp(n_catalogname,cit_data[nx1]))
                 {
                  if(!strcmp(cit_data[nx1+4],data[nx]))
                     {
                    strcpy(p_pdcno,cit_data[nx1+17]);
                    break;
                   }
                  }
          }
          if(strlen(p_pdcno) == 0)
          {
         _PDMdebug(fname,"p_pdcno not found for child <%d>\n", atoi(data[nx])); 
          return(PDM_E_FAILURE);
          }
           strcat(values,p_pdcno);
           strcat(values,",");
          for(j=2;j<parm_data->columns;j++)
          {
	            found = 0; 
                    for(m = 0; m < attr_bufr->columns; m++)
	            {
	              if(!strcmp(attr_col[m], column[j]))
	              {
	                found = 1; break;
	              }
	            }
	            if(!found)
	              continue;

/* Replaced code to use more complete datatype checking
         MaC 051994
                    if(!strncmp(format[j],"char",4))
                    {
                         strcat(values,"'");
                         strcat(values,data[nx+j]);
                         strcat(values,"'");
                    }
                    else
                    {
                        if((strlen(data[nx+j])== 0)) strcat(values,"NULL");
                        else
                        strcat(values,data[nx+j]);
                    }
      ...*/
/*************************************************************************/
                     val[0] = '\0';
                     status = _PDMget_data_type (format[j], 
                                                  data[nx+j], val);
                     if (status != PDM_S_SUCCESS) {
                         if(attrbs) free(attrbs); if(values) free(values);
                         if(sql_str) free(sql_str);
                         _PDMdebug (fname, "_PDMget_data_type 0x%.8x\n", 
                                                                status );
                         return (status);
                       }
                     strcat (values, val);
                     _PDMdebug ("values", "%s\n", values);
/*************************************************************************/

                    if(j != parm_data->columns-1)
                    {
                         strcat(values,",");
                    }
          }
          strcat(values,")");
         _PDMdebug(fname,"attrbs <%s> - values <%s>\n", attrbs, values); 
          sql_str[0]='\0';
          sprintf(sql_str,"INSERT INTO %s %s %s ",dynamic_table,attrbs,values);
          status = SQLstmt(sql_str);
          if(status != SQL_S_SUCCESS)
          {
           if(attrbs) free(attrbs); if(values) free(values);
           if(sql_str) free(sql_str);
            _PDMdebug(fname,"SQLstmt failed status <0x%.8x>\n",status);
           return(status);
          }
     }
    if(sql_str)free(sql_str);if(attrbs) free(attrbs);if( values) free(values);
     _PDMdebug(fname, "EXIT:\n");
     return(PDM_S_SUCCESS);
}




/*
 * pdmsv_table is the name of the existing saved views table
 * 
 * partno 	 is the part's no in catalog
 * 
 * sv_bufr	 is the new buffer
 * 
 * The old views are deleted and new ones are added
 */

int PDMinsert_views(pdmsv_table, p_partno, sv_bufr)
	char           *pdmsv_table;
	int             p_partno;
	MEMptr          sv_bufr;
{
        char            *fname = "PDMinsert_views";
	char            sql_str[1024];
	char            sql_str1[1024];
	char            sql_str2[1024];
	char          **data;
	char          **column_ptr;
	int             i, nxi;
	int             n1, n2, n3;

	_PDMdebug(fname,"ENTER:\n");
	n1 = -1;
	n2 = -1;
	n3 = -1;
	/* if there are no saved views return */

	if (sv_bufr->rows == 0) {
		return (PDM_S_SUCCESS);
	}
        status = MEMbuild_array(sv_bufr);
        if(status != MEM_S_SUCCESS)
        {
	return (PDM_S_SUCCESS);
        }
	column_ptr = (char **) sv_bufr->column_ptr;
	for (i = 0; i < sv_bufr->columns; i++) {
	if (!strcmp(column_ptr[i], "p_origin"))
			n1 = i;
       else if (!strcmp(column_ptr[i], "p_rotation"))
			n2 = i;
       else if (!strcmp(column_ptr[i], "p_viewname"))
			n3 = i;
	}
	if (n1 == -1 || n2 == -1 || n3 == -1) {
		PDMdebug("Could not set offsets in sv_bufr\n");
		return (PDM_E_BUFFER_FORMAT);
	}
	/* delete old saved views from pdmsv_table */

	sql_str[0] = '\0';
	sprintf(sql_str, "%s %s %s %d",
		"DELETE FROM ", pdmsv_table,
		"WHERE n_itemno = ", p_partno);
	status = SQLstmt(sql_str);
	if (status != SQL_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND) {
		switch (status) {
		case PDMS_NO_SUCH_ATTRIBUTE:
			_PDMdebug(fname, "%s %s %s \n",
				"PDMinsert_views: Could not ",
			   "find a required column in table ", pdmsv_table);
			status = PDM_E_REQ_COLUMN_NOT_FOUND;
			return (status);
		case PDMS_NO_SUCH_TABLE:
			_PDMdebug(fname, "%s %s %s \n",
				"PDMinsert_views: Could not find table ",
				pdmsv_table);
			status = PDM_E_SV_TABLE_NOT_FOUND;
			return (status);
		default:
			break;
		}
	}
	/* insert saved view info into pdmsv_table */

	data = (char **) sv_bufr->data_ptr;

	sql_str1[0] = '\0';
	sprintf(sql_str1, "%s %s %s %s %d,",
		"INSERT INTO ", pdmsv_table,
		"( n_itemno, p_origin, p_rotation, p_viewname)",
		" VALUES (", p_partno);
	for (i = 0; i < sv_bufr->rows; i++) {
		nxi = i * sv_bufr->columns;
		sql_str2[0] = '\0';
		sprintf(sql_str2, "'%s','%s','%s')", data[nxi + n1],
			data[nxi + n2], data[nxi + n3]);
		sql_str[0] = '\0';
		sprintf(sql_str, "%s %s", sql_str1, sql_str2);
		status = SQLstmt(sql_str);
		if (status != SQL_S_SUCCESS) {
			switch (status) {
			case PDMS_NO_SUCH_ATTRIBUTE:
				sprintf(s, "%s %s  \n",
					"PDMinsert_views: Could not ",
					"find a required column in table ",
					pdmsv_table);
				PDMdebug(s);
				status = PDM_E_REQ_COLUMN_NOT_FOUND;
			case PDMS_NO_SUCH_TABLE:
				sprintf(s, "%s %s \n",
				   "PDMinsert_views: Could not find table ",
					pdmsv_table);
				PDMdebug(s);
				status = PDM_E_SV_TABLE_NOT_FOUND;
			default:
				break;
			}
			return (status);
		}
	}			/* end of for all saved view rows */

	_PDMdebug(fname,"EXIT:-SUCCESS\n");
	return (PDM_S_SUCCESS);
}



/*
 * Deletes the first level children of the part .
 * 
 * 
 * - Arun Madhwesh
 */

int PDMConvertToAtomic (catalog, n_itemname, n_itemrev, 
                          p_catno, p_itemno, citno_bufr, cit_bufr)
	char           *catalog;
	char           *n_itemname;
	char           *n_itemrev;
        int            p_catno;
        int            p_itemno;
        MEMptr        *citno_bufr;
        MEMptr        *cit_bufr;
{
	int             m1 = -1, m2 = -1, m3 = -1, m4 = -1, m5 = -1;
	int             m6 = -1, m7 = -1, m8 = -1,  m10 = -1;
	int             m11 = -1, m12 = -1, m13 = -1, m14 = -1, m15 = -1;
	int             actual_citno = 0, citno = 0, pdcno = 0;
	int             i = 0;
	int             nxi = 0;
        int             c_catno = 0, c_itemno = 0;
        char          sql_str[512] = "", mem_str[1024] = "";
        char          dumb_str[2]="";
        char          *msg = NULL;
	char          **column_ptr = NULL;
	char          **child_data = NULL, **data = NULL;
        char         *fname = "PDMConvertToAtomic";
 	int 		PDMadd_child ();
        MEMptr         n_citno_bufr = NULL, dumb_list = NULL;

	_PDMdebug(fname, "ENTER : \n");

	/* set offsets in child_bufr */
     prev_cat[0] = '\0';
     prev_part[0] = '\0';
     prev_rev[0]  = '\0';
     prev_ind[0]   = '\0';
     prev_type[0]  = '\0';
     prev_catno = 0;
     prev_itemno = 0;


       /* 
          Instead of locking NFMSETCIT, it's better to lock
          NFMINDEX table and resolve concurrency and the incorrect
          usage of n_citnos and p_pdcnos
        */

      status = NFMstop_transaction (0);
      if (status != NFM_S_SUCCESS)
       {
          NFMrollback_transaction (0);
         _PDMdebug(fname, "Stop Transaction : status = <0x%.8x>\n", status);
         return (status);
       }  

       sprintf(sql_str,"LOCK TABLES NFMINDEX IN EXCLUSIVE MODE");
        status = SQLstmt(sql_str);
         if(status != SQL_S_SUCCESS)
         {
           status = _PDMget_db_error(status);
           if(status == PDM_I_TABLE_LOCKED)
            {
             PDMupdate_dots ();
             msg = (char *)PDUtranslate_message(PDS_M_CONCURRENT_CHECKIN);
             UI_status(msg);
             while(sleep(30)) PDMupdate_dots ();
             sprintf(sql_str,"LOCK TABLES NFMINDEX IN EXCLUSIVE MODE");
             status = SQLstmt(sql_str);
             if(status != SQL_S_SUCCESS)
              {
               status = _PDMget_db_error(status);
                if(status == PDM_I_TABLE_LOCKED)
                  {
                   PDMupdate_dots ();
                   msg = (char *)PDUtranslate_message(PDS_M_CONCURRENT_CHECKIN);
                   UI_status(msg);
                   while(sleep(30)) PDMupdate_dots ();
                    sprintf(sql_str,"LOCK TABLES NFMINDEX IN EXCLUSIVE MODE");
                    status = SQLstmt(sql_str);
                     if(status != SQL_S_SUCCESS)
                      {
                      status = _PDMget_db_error(status);
                      if(status == PDM_I_TABLE_LOCKED)
                        {
                   PDMupdate_dots ();
                   msg = (char *)PDUtranslate_message(PDS_M_CONCURRENT_CHECKIN);
                   UI_status(msg);
                   while(sleep(30)) PDMupdate_dots ();
                    sprintf(sql_str,"LOCK TABLES NFMINDEX IN EXCLUSIVE MODE");
                    status = SQLstmt(sql_str);
                     if(status != SQL_S_SUCCESS)
                      {
                     NFMrollback_transaction (0);
                  _PDMdebug(fname, "LOCK NFMINDEX failed status %d\n", status);
                      return(PDM_E_LOCK_CIT);
                       }
                     }
                     else
                      {
           NFMrollback_transaction (0);
                  _PDMdebug(fname, "LOCK NFMINDEX failed status %d\n", status);
                      return(status);
                      }
                  }
               }
               else
                {
           NFMrollback_transaction (0);
                  _PDMdebug(fname, "LOCK NFMINDEX failed status %d\n", status);
                      return(status);
                 }
           }
         }
          else
             {
           NFMrollback_transaction (0);
                  _PDMdebug(fname, "LOCK NFMINDEX failed status %d\n", status);
                      return(status);
             }
      }
        
/*
      One nested statement on both pdmcit and nfmsetcit would suffice
      to delete the entries both from nfmsetcit and pdmcit. But here it's done
      seperately because, join of pdmcit and nfmsetcit in large databases are 
      costly.
	 */

         status = MEMopen(cit_bufr,512);
         if(status != MEM_S_SUCCESS)
         {
           NFMrollback_transaction (0);
          _PDMdebug(fname,"MEMopen failed status %d\n", status);
           return(status);
         }
        status = MEMwrite_format(*cit_bufr, "n_catalogname", "char(20)");
        if (status == MEM_S_SUCCESS)
        status = MEMwrite_format(*cit_bufr, "n_itemname", "char(240)");
        if (status == MEM_S_SUCCESS) 
        status = MEMwrite_format(*cit_bufr, "n_itemrev", "char(240)");
        if (status == MEM_S_SUCCESS) 
        status = MEMwrite_format(*cit_bufr, "p_quantity", "char(32)");
        if (status == MEM_S_SUCCESS) 
        status = MEMwrite_format(*cit_bufr, "p_childno", "integer");
        if (status == MEM_S_SUCCESS) 
        status = MEMwrite_format(*cit_bufr, "p_history", "char(20)");
        if (status == MEM_S_SUCCESS) 
        status = MEMwrite_format(*cit_bufr, "p_usageid", "char(25)");
        if (status == MEM_S_SUCCESS) 
        status = MEMwrite_format(*cit_bufr, "p_attached", "char(2)");
        if (status == MEM_S_SUCCESS) 
        status = MEMwrite_format(*cit_bufr, "p_tagno", "integer");
        if (status == MEM_S_SUCCESS) 
        status = MEMwrite_format(*cit_bufr, "p_alttagno", "char(25)");
        if (status == MEM_S_SUCCESS) 
        status = MEMwrite_format(*cit_bufr, "p_incbom", "char(2)");
        if (status == MEM_S_SUCCESS) 
        status = MEMwrite_format(*cit_bufr, "p_incstr", "char(2)");
        if (status == MEM_S_SUCCESS) 
        status = MEMwrite_format(*cit_bufr, "n_cofilename", "char(15)");
        if (status == MEM_S_SUCCESS) 
        status = MEMwrite_format(*cit_bufr, "p_explode", "char(2)");
        if (status == MEM_S_SUCCESS) 
        status = MEMwrite_format(*cit_bufr, "n_catalogno", "integer");
        if (status == MEM_S_SUCCESS) 
        status = MEMwrite_format(*cit_bufr, "n_itemno", "integer");
        if (status == MEM_S_SUCCESS) 
        status = MEMwrite_format(*cit_bufr, "n_citno", "integer");
        if (status == MEM_S_SUCCESS) 
        status = MEMwrite_format(*cit_bufr, "p_pdcno", "integer");
        if (status != MEM_S_SUCCESS) {
                MEMclose(cit_bufr);
                NFMrollback_transaction (0);
                _PDMdebug(fname, "MEMwrite_format failed status %d\n", status);
                return (PDM_E_WRITE_FORMAT);
        }

        sql_str[0] = '\0';
        sprintf(sql_str, " %s = %s ", 
              "SELECT n_indexslot from NFMINDEX where n_tablename",
              " 'nfmsetcit' or n_tablename = 'NFMSETCIT'" );
        status = SQLquery(sql_str, &n_citno_bufr,512);
        if(status != SQL_S_SUCCESS) {
           _PDMdebug(fname, 
            "NO entry in NFMIDEX table for nfmsetcit - 0x%.8x\n", status);

           sql_str[0] = '\0';
           strcpy (sql_str, "select max(n_citno) from nfmsetcit");

           status = NFMretrieve_values (sql_str, 1, 
                                  dumb_str,&citno, &dumb_list);
            if (status != NFM_S_SUCCESS) {
                NFMrollback_transaction (0);
               _PDMdebug (fname, "SQLquery(%s) 0x%.8x\n", sql_str, status);
                return (NFM_E_SQL_QUERY);
                }
               MEMclose(&dumb_list);
             citno++;
           }
          else
           {
            status = MEMbuild_array(n_citno_bufr);
            if(status != MEM_S_SUCCESS)
            {
             NFMrollback_transaction (0);
              MEMclose(&n_citno_bufr);
             _PDMdebug(fname, "MEMbuild_array status %d\n", status);
             return(status);
            }
           data = (char **) n_citno_bufr->data_ptr;
           citno = atoi(data[0]);
           }

         MEMclose(&n_citno_bufr);

        sql_str[0] = '\0';
        sprintf(sql_str, "%s = %s",
         "SELECT  n_indexslot from NFMINDEX where n_tablename ",
         " 'pdmcit' or n_tablename = 'PDMCIT' ");
          status = SQLquery(sql_str, &n_citno_bufr,512);
           if(status != SQL_S_SUCCESS)
           {
           _PDMdebug(fname, 
             "NO entry in NFMIDEX table for nfmsetcit  - 0x%.8x\n", status);
          strcpy (sql_str, "select max(p_citno) from pdmcit");
         status = NFMretrieve_values (sql_str, 1, dumb_str, &pdcno, &dumb_list);
            if (status != NFM_S_SUCCESS)
             {
                NFMrollback_transaction (0);
               _PDMdebug (fname, "SQLquery(%s) 0x%.8x\n", sql_str, status);
                return (NFM_E_SQL_QUERY);
                }
               MEMclose(&dumb_list);
             pdcno++;
           }
          else
           {
            status = MEMbuild_array(n_citno_bufr);
            if(status != MEM_S_SUCCESS)
            {
              NFMrollback_transaction (0);
              MEMclose(&n_citno_bufr);
             _PDMdebug(fname, "MEMbuild_array status %d\n", status);
             return(status);
            }
           data = (char **) n_citno_bufr->data_ptr;
           pdcno = atoi(data[0]);
           }
         MEMclose(&n_citno_bufr);

          /* Update the citnos and pdcnos in the NFMINDEX table */
        
	if (PDMdebug_on)
	   MEMprint_buffer("cit_bufr", *cit_bufr, PDM_DEBUG_FILE);

      status = NFMstop_transaction (0);
      if (status != NFM_S_SUCCESS)
       {
         NFMrollback_transaction (0);
        _PDMdebug(fname, "Start Transaction : status = <0x%.8x>\n", status);
         return (status); 
       }

        status = PDMdelete_pdm_entries(p_catno,p_itemno, citno_bufr);
	if (status != PDM_S_SUCCESS) {
            NFMrollback_transaction (0);
	_PDMdebug(fname, "PDMdelete_pdm_entries failed status -> %d", status);
		return (PDM_E_QUERY_SET_MEMBERS);
                }

       /* delete all the first level children for the given part
          There is no need for calling the function
          NFMupdate_set_members with the level as 1. NFMupdate_set_members
          should be called only to get children with more than
          1 level */

        sql_str[0]='\0';
       sprintf(sql_str,"DELETE FROM NFMSETCIT WHERE n_pcatalogno = %d AND n_pitemno = %d ",p_catno,p_itemno);
        status = SQLstmt(sql_str);

  status = SQLstmt (sql_str);
  if (status != SQL_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND) {

      /*   locking the catalog tables during update
            to keep spinning for 30+30+30+30 seconds. The right fix is row
            level locking supported by informix and oracle */
      if (status == SQL_E_MESSAGE) {
          msg = (char *)PDUtranslate_message(PDS_M_CONCURRENT_TAB_ACCESS_HOLD);
          UI_status (msg);
          sleep (30);
          status = SQLstmt (sql_str);
          if (status != SQL_S_SUCCESS) {
              UI_status (msg);
              sleep (30);
              status = SQLstmt (sql_str);
              if (status != SQL_S_SUCCESS) {
                 msg = (char *)PDUtranslate_message(PDS_M_CONCURRENT_TAB_ACCESS);
                 UI_status (msg);
                    if (status == NFM_E_LOCK_TABLE_FAILED)
                    status = PDM_I_TABLE_LOCKED;
                    _PDMdebug (fname, "NFMlock_table(%s) failed 0x%.8x\n", 
                              "NFMSETCIT",status);
                   return (status);
                     }
             }
        }
      else  {
     _PDMdebug (fname, "SQLstmt failed status %d\n", status);
     status = _PDMget_db_error (status);
     PDMrollback_transaction (1200);
     return (status);
     }
    }

	/* cleanup pdmcit, pdc_xxx */

	status = PDMi_delete_dynamic_info(*citno_bufr);
	if (status != PDM_S_SUCCESS) {
	_PDMdebug(fname, "PDMi_delete_pdcentries failed status %d\n", status);
          NFMrollback_transaction (0);
                 return(status);
	}

	_PDMdebug(fname, "EXIT:\n");
	return (PDM_S_SUCCESS);
}

