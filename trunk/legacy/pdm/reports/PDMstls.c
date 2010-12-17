#include	<string.h>
#include	<sys/types.h>
#include	<sys/stat.h>
#include	<stdio.h>
#include	<ctype.h>
#include 	"FI.h"
#include	"rMRPstr.h"
#include 	"MRPmessage.h"
#include 	"MEMstruct.h"
#include 	"SQLerrordef.h"
#include 	"PDUerror.h"
#include 	"PDMproto.h"
#include 	"PDUstorage.h"
#include 	"PDUpdmrpro.h"
#include        "PDUprompt.h"

#define		finished = -1;

/* Externs */
static char errmsg[132];
extern int dba_message_strip;
extern int dba_columns_per_page;
extern struct PDUstorage *storage;

/* Written to support generation of reports using DBAccess 
   
   Original code - Lynn Mettlen
   Modified to suit PDM's needs - Kumar Narayanan
*/

int PSUexe_rpt ( psurpt, schema )
  struct PSUrpt	*psurpt;
  char		*schema;
  {
  int	i,just_cnt;
  int	total, subtotal;
  long	status = MRP_S_Success;
  char   err_msg[80];
  char  *fname = "PSUexe_rpt";

 _PDMdebug(fname,"Enter:PSUexe_rpt\n");
  /* update format values in database */

/*
psurpt->options.subtotals = 1;
psurpt->options.totals = 1;
*/
_PDMdebug(fname,"psurpt->options.table = %s\n", psurpt->options.table);
_PDMdebug(fname,"psurpt->options.template_name = %s\n", psurpt->options.template_name);
_PDMdebug(fname,"psurpt->options.output = %s\n", psurpt->options.output);
_PDMdebug(fname,"psurpt->options.subtotals = %d\n", psurpt->options.subtotals);
_PDMdebug(fname,"psurpt->options.width = %d\n", psurpt->options.width);
_PDMdebug(fname,"psurpt->options.totals = %d\n", psurpt->options.totals);
_PDMdebug(fname,"psurpt->options.lines = %d\n", psurpt->options.lines);
_PDMdebug(fname,"psurpt->options.description = %s\n", psurpt->options.description);
_PDMdebug(fname,"psurpt->list_total = %d\n", psurpt->list_total);

 subtotal = 0;
 total    = 0;
 for ( i = 0; i < psurpt->list_total; ++i ) {
   _PDMdebug(fname,"psurpt->list[i].name = %s\n", psurpt->list[i].name);
   _PDMdebug(fname,"psurpt->list[i].header= %s\n", psurpt->list[i].header);
   _PDMdebug(fname,"psurpt->list[i].type = %d\n", psurpt->list[i].type);
   _PDMdebug(fname,"psurpt->list[i].start = %d\n", psurpt->list[i].start);
   _PDMdebug(fname,"psurpt->list[i].length = %d\n", psurpt->list[i].length);
   _PDMdebug(fname,"psurpt->list[i].decimal = %d\n", psurpt->list[i].decimal);
   _PDMdebug(fname,"psurpt->list[i].sort = %d\n", psurpt->list[i].sort);
   _PDMdebug(fname,"psurpt->list[i].subtotal = %d\n", psurpt->list[i].subtotal);
   _PDMdebug(fname,"psurpt->list[i].total = %d\n", psurpt->list[i].total);

/* if either list.total/subtotal is set;  options.total/subtotal needs
              to be set */
   if (psurpt->list[i].subtotal == 1)
          subtotal = 1;
   if (psurpt->list[i].total == 1)
          total = 1;
    }

   psurpt->options.subtotals = subtotal;
   psurpt->options.totals = total;

/* Modifications to support DBADEV 4.4.2.0. MaC 120293 */

/*
#if defined (__sgi) || defined (__Sol2__)
*/
/* Since SGI and Sun have DBA at vers 4.4.2.0 MaC */

  dba_setup_script (); 
  dba_setup_report ();
  dba_setup_dbnuc ();
  dba_setup_dbforms ();
  dba_setup_gui ();

errmsg[0] = '\0';

status = dba_setup (0, 0, 0, errmsg);
_PDMdebug(fname,"after dba_setup status = %d\n", status);

dba_message_strip = 0;

if (status) 
   _PDMdebug(fname, "status [%d] errmsg %s = \n", status, errmsg);
else
   {
   status = dba_schema_select( schema );
   _PDMdebug(fname,"after dba_schema_select status = %d\n", status);
   if (status) 
     {
     _PDMdebug(fname,"errmsg = %s\n", errmsg);
     return(PDM_E_OUTPUT_REPORT);
     }
   }

  status = dba_add_to_table_list(0,psurpt->options.table);
  _PDMdebug(fname,"after dba_add_to_table_list status = %d\n", status);
   if (status) 
     {
     _PDMdebug(fname,"errmsg = %s\n", errmsg);
     return(PDM_E_OUTPUT_REPORT);
     }

if ((!strcmp(psurpt->templatetype, "Y") ||
   (!strcmp(psurpt->templatetype, "y"))) && ( !status ))
   {
    _PDMdebug (fname, "Template Type [%s]\n", psurpt->templatetype);
    dba_columns_per_page =  psurpt->options.width;
   status = dba_execute_default(psurpt->options, psurpt->list,
                                  psurpt->list_total, 0, psurpt->where, 0);
   _PDMdebug(fname,"after dba_execute_default status = %d\n", status);
   if (status)
     {
     _PDMdebug(fname,"dba_execute_default status = %s\n ", errmsg);
     return(PDM_E_OUTPUT_REPORT);
     }
status = dba_set_variable_start ( 5, 1, "c_n_level");
_PDMdebug(fname,"after dba_set_variable_start status = %d\n", status);
   if (status)
      {
      _PDMdebug("dba_set_variable_start status = %s\n ", errmsg);
     return(PDM_E_OUTPUT_REPORT);
     }
 
   status = dba_set_field_justify( 5, 1, 1 );
_PDMdebug(fname,"after dba_set_field_justify status = %d\n", status);
   if (status)
      {
      _PDMdebug(fname,"dba_set_field_justify status = %s\n ", errmsg);
       return(PDM_E_OUTPUT_REPORT);
     }
   for ( just_cnt = 1; just_cnt < psurpt->list_total; ++just_cnt )
       {
       status = dba_set_field_justify( 5, just_cnt+1,
                                        psurpt->justification[just_cnt] );
      _PDMdebug(fname,"dba_set_field_justify status = %d\n ", status);
       if (status)
          {
          _PDMdebug(fname,"dba_set_field_justify status = %s\n", errmsg);
          return(PDM_E_OUTPUT_REPORT);
          }
       else
     {_PDMdebug(fname,"justifcation[%d] = %d\n", just_cnt,psurpt->justification[
just_cnt]);}
     }
    dba_columns_per_page =  psurpt->options.width;
      _PDMdebug(fname,"calling dba_process_report\n");
   status = dba_process_report (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 );
      _PDMdebug(fname,"dba_process_report status = %d\n ", status);
   if (status) {
      _PDMdebug (fname,"dba_process_report failed status = %d\n", status);
      _PDMdebug (fname,"dba_process_report failed errmsg = %s\n", errmsg);
      return(PDM_E_OUTPUT_REPORT);
       }
   }
  else
   {
    _PDMdebug (fname, "TemplateType [%s]\n", psurpt->templatetype);
    dba_columns_per_page =  psurpt->options.width;
      _PDMdebug(fname,"calling dba_execute_default\n");
  status = dba_execute_default(psurpt->options, psurpt->list,
			       psurpt->list_total, 0, psurpt->where, 0);
      _PDMdebug(fname,"dba_execute_default status = %d\n ", status);
  if (status) _PDMdebug(fname,"dba status = %s\n", errmsg);
   for ( just_cnt = 0; just_cnt < psurpt->list_total; ++just_cnt )
       {
       status = dba_set_field_justify( 5, just_cnt+1,
                                        psurpt->justification[just_cnt] );
      _PDMdebug(fname,"dba_set_field_justify status = %d\n ", status);
       if (status)
          {
          _PDMdebug(fname,"dba_set_field_justify status = %s\n", errmsg);
          return(PDM_E_OUTPUT_REPORT);
           }
       else
     {_PDMdebug(fname,"justifcation[%d] = %d\n", just_cnt,psurpt->justification[
just_cnt]);}
     }
    dba_columns_per_page =  psurpt->options.width;
if (!strcmp(psurpt->templatetype, "C") && ( !status ))
   status = dba_process_report(0, 0, 0, 0, 0, psurpt->where, 0, 0, 0, 0, 0, 0 );
 else
   status = dba_process_report(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 );
 _PDMdebug(fname,"dba_process_report status = %d\n ", status);

   if (status) {
      _PDMdebug (fname,"dba_process_report failed status = %d\n", status);
      _PDMdebug (fname,"DBAprocess_report errmsg = %s\n", errmsg);
      return(PDM_E_OUTPUT_REPORT);
       }
    psurpt->templib = NULL;
  if ( psurpt->templib != NULL )
      {
      status = dba_save_default(psurpt->options, psurpt->list,
			     psurpt->list_total, psurpt->templib, 0, 0);
      _PDMdebug(fname,"dba_save_default status = %d\n ", status);
      }
   }
  if (status)
     {
      _PDMdebug(fname,"dba status = %s\n", errmsg);
      if(errmsg) strncpy(err_msg, errmsg, 79);
      UI_status(err_msg);
      status = MRP_E_NoCatInfo;
      return(PDM_E_OUTPUT_REPORT);
      }
  else
      status = MRP_S_Success;

 _PDMdebug(fname,"Exit:PSUexe_rpt\n");
  return (status);
  }


/* Written to support generation of reports using DBAccess template 
   libraries 
   - Kumar 
*/


int PDMreport_from_tmpfile 
( 
char *schema, 
char *table, 
char *templib, 
char *template,
char *saname, 
char *output 
)
  {
  long	status = PDM_S_SUCCESS;
  char          template_name[40];
  char       msg_str[200], err_msg[80];
  char           *msg = NULL;
  char *fname = "PDMreport_from_tmpfile";

_PDMdebug(fname, "Enter");

 _PDMdebug (fname, 
            "schema[%s] table[%s] templib[%s] template[%s], saname[%s]\n",
             schema, table, templib, template, saname);


status = PDMexport_ris_rpt(saname,template);
              if(status != PDM_S_SUCCESS)
              {
    _PDMdebug(fname, "%s %d\n", "PDMexport_ris_rpt failed status ", status);
               return(status);
              }
     msg = (char *)PDUtranslate_message(PDP_P_ENTER_TEMPLATE);
     sprintf(msg_str,"%s <%s>", msg,template);
     UI_prompt (msg_str);
     template_name[0] = '\0';
     do
        PDUget_keyin(template_name);
        while(strlen(template_name) <= 0);

     UI_prompt ("");

  dba_setup_script (); 
  dba_setup_report ();
  dba_setup_dbnuc ();
  dba_setup_dbforms ();
  dba_setup_gui ();

/* Since SGI and Sun have DBA at vers 4.4.2.0 MaC */

errmsg[0] = '\0';

status = dba_setup (0, 0, 0, errmsg);
_PDMdebug(fname,"after setup status = %d\n", status);
  if (status) _PDMdebug(fname,"errmsg = %s\n", errmsg);
else
   {
   status = dba_schema_select( schema );
   if (status)
     {
   _PDMdebug(fname, "dba_schema_select error status = %d\n", status);
     _PDMdebug(fname,"dba_schema_select errmsg = %s\n", errmsg);
     _PDMdebug(fname, "Exit- DB Access Error");
      if(errmsg) strncpy(err_msg, errmsg, 79);
      UI_status(err_msg);
      return(status);
     }
    }
  /* Added by kumar to add the table to the schema list - 070293*/
  status = dba_add_to_table_list(0,table);
_PDMdebug(fname,"after dba_add_to_table_list status = %d\n", status);
   if (status) _PDMdebug(fname,"errmsg = %s\n", errmsg);

dba_message_strip = 0;
  /* status = dba_single_report(templib, template,schema,0, table,
			       output, "", 0,0,0,0,0,0); */
  status = dba_single_report(template, template_name,0,0, table,
			       output, "", 0,0,0,0,0,0);
  if (status)
  {
  _PDMdebug(fname, "dba_single_report error status = %d\n", status);
  _PDMdebug(fname, "dba_single_report errmsg = %s\n", errmsg);
      if(errmsg) strncpy(err_msg, errmsg, 79);
      UI_status(err_msg);
     _PDMdebug(fname, "Exit- DB Access Error");
  return (PDM_E_DBA_SINGLE);
  }

_PDMdebug(fname, "Exit");
return(PDM_S_SUCCESS);

}


/*
   Wrote this function to edit the report file generated 
   This function rearranges the value in n_level attribute to
   have indentation.  level 1 will not be indented. level 2
   will have indentation of 1 etc. 
  
   Created: 070194
   Creator: MaC
*/

int PDMIndentReportFile (ReportFile, LevelSize)
char	*ReportFile;
int	LevelSize;
{
 int	x, GotLevel, z, Level, Indent;
 int	LineNo;
 char	*fn = "PDMIndentReportFile";
 char	LineBuf[2096];
 char	TmpLineBuf[2096];
 char	TmpLevelBuf1[2096];
 char	TmpLevelBuf2[2096];
 char	SystemString[2096];
 FILE	*infile, *outfile;

 _PDMdebug (fn, "Enter: ReportFile[%s]\n", ReportFile);

 if ((infile = fopen (ReportFile, "r")) == NULL ) {
    _PDMdebug (fn, "Could not open the report file\n");
       /*perror ("Could not open input file");*/
     return (PDM_E_OPEN_FILE);
       }

 if ((outfile = fopen ("/usr/tmp/PDMBOMFILE", "w")) == NULL ) {
    _PDMdebug (fn, "Could not open the tmp output file\n");
     return (PDM_E_WRITE_FILE);
       /*perror ("Could not open output file");*/
       }

 if (LevelSize == 0) { 
      LevelSize = 10;
     }

/*****************************************************************/

 LineNo = 1;
 while (fgets(LineBuf,sizeof (LineBuf), infile) != NULL) {
   _PDMdebug ("Input Line", "%s\n", LineBuf);
    GotLevel = 0;
    z = 0;
    _PDMdebug (fn, "Line # [%d] -> length [%d]\n", LineNo, strlen (LineBuf));
    for (x=0; x<=strlen (LineBuf); x++) {
     if ((GotLevel != 0) && (LineBuf [x] == ' ') ) {
        break;
         }
     if (LineBuf [x] != ' ') {
        TmpLevelBuf1[z] = LineBuf[x];
        GotLevel = 1;
        z++;
        }
      else {
        TmpLevelBuf1[z] = ' ';
        z++;
        }
      }

    TmpLevelBuf1[z] = '\0';
    _PDMdebug (fn, "x[%d] level = [%s]\n", x, TmpLevelBuf1);

    if (Level = atol (TmpLevelBuf1) == NULL) {
     _PDMdebug (fn, "TmpLevelBuf1[%s] -> could not convert \n", TmpLevelBuf1);
          }
    else if (strlen (TmpLevelBuf1) > 50) {
     _PDMdebug (fn, "TmpLevelBuf1[%s] -> size[%d] greater than 50 \n", 
                                    TmpLevelBuf1, strlen (TmpLevelBuf1));
          }
    else {
     Level = atol (TmpLevelBuf1);
     _PDMdebug (fn, "Level [%d]\n", atol (TmpLevelBuf1));
     for (z=0; z<=(strlen (LineBuf) - x); z++) {
      TmpLineBuf[z] = LineBuf[z+LevelSize];
       }
      TmpLineBuf[z] = '\0';

     _PDMdebug ("TmpLineBuf", "[%s]\n", TmpLineBuf);
      
      z = 0;
      for (Indent = 0; Indent < LevelSize; Indent++) {
        if (Indent == Level) {
          for (x = 0; x < strlen (TmpLevelBuf1); x++) {
           TmpLevelBuf2[z] = TmpLevelBuf1[x];
           z++;
           }
          }
        else {
          TmpLevelBuf2[z] = ' ';
          z++;
          }
       }
     TmpLevelBuf2[z] = '\0';
     sprintf (LineBuf, "%s%s", TmpLevelBuf2, TmpLineBuf);
     /*_PDMdebug ("line", "%s\n", LineBuf); */
     }   
   _PDMdebug ("Putting Line", "%s\n", LineBuf);
   fputs (LineBuf, outfile);
   LineNo++;
   }
  fclose (outfile);

/* System command seems to have problems... 
 sprintf (SystemString, "/bin/cp /usr/tmp/PDMBOMFILE %s/%s", 
                                    storage->path_name, ReportFile);
 _PDMdebug ("System", "%s\n", SystemString);
 system (SystemString);
*/

 sprintf (SystemString, "%s/%s", storage->path_name, ReportFile);
 _PDMdebug ("System", "%s\n", SystemString);
 if ((infile = fopen (SystemString, "w")) == NULL ) {
    _PDMdebug (fn, "Could not open the report file for writing\n");
     return (PDM_E_OPEN_FILE);
       }

 if ((outfile = fopen ("/usr/tmp/PDMBOMFILE", "r")) == NULL ) {
    _PDMdebug (fn, "Could not open the tmp output file\n");
     return (PDM_E_WRITE_FILE);
       }


 while (fgets(LineBuf,sizeof (LineBuf), outfile) != NULL) {
   _PDMdebug ("Putting Line", "%s\n", LineBuf);
   fputs (LineBuf, infile);
   }

  fclose (outfile);
  fclose (infile);
/*****************************************************************/
_PDMdebug (fn, "Exit\n");
return (PDM_S_SUCCESS);
}
