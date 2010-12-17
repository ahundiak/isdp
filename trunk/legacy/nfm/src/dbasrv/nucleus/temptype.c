/* $Revision: 1.1 $ */
#include "dba.ext"

extern char *dba_errtxt;

/* Function:	dba_template_type_from_string */
int dba_template_type_from_string (ctype, itype)
char *ctype;
int *itype;
{
  while (ctype[strlen (ctype) - 1] == ' ') ctype[strlen (ctype) - 1] = 0;

  if (strcmp (ctype, "Report") == 0) *itype = 0;
  else if (strcmp (ctype, "DB Rpt") == 0) *itype = DATBAS;
  else if (strcmp (ctype, "Database") == 0) *itype = DATBAS;
  else if (strcmp (ctype, "UD Rpt") == 0) *itype = USERDATA;
  else if (strcmp (ctype, "Userdata") == 0) *itype = USERDATA;
  else if (strcmp (ctype, "ASC Rpt") == 0) *itype = ASCII;
  else if (strcmp (ctype, "ASCII") == 0) *itype = ASCII;
  else if (strcmp (ctype, "UD Str") == 0) *itype = UD_S;
  else if (strcmp (ctype, "ASC Str") == 0) *itype = ASC_S;
  else if (strcmp (ctype, "Dialog") == 0) *itype = MENU;
  else if (strcmp (ctype, "SQL") == 0) *itype = SQL_TEMPLATE;
  else if (strcmp (ctype, "Query") == 0) *itype = QUERY;
  else if (strcmp (ctype, "Script") == 0) *itype = SCRIPT;
  else if (strcmp (ctype, "Options") == 0) *itype = OPTIONS;
  else if (strcmp (ctype, "Bin Rpt") == 0) *itype = BINARY;
  else if (strcmp (ctype, "Structure") == 0) *itype = ALL_STR;
  else if (strcmp (ctype, "Bin Str") == 0) *itype = BIN_S;
  else if (strcmp (ctype, "Object") == 0) *itype = OBJECT;
  else if (strcmp (ctype, "Application") == 0) *itype = APPLICATION;
  else if (strcmp (ctype, "Palette") == 0) *itype = PALETTE;
  else if (strcmp (ctype, "Toolbar") == 0) *itype = TOOLBAR;
  else if (strcmp (ctype, "Statusbar") == 0) *itype = STATUSBAR;  
  else if (strcmp (ctype, "Bitmap") == 0) *itype = BITMAP;  
  else if (strcmp (ctype, "Relations") == 0) *itype = RELATIONS;  
  else {
    *itype = 0;
    strcpy (dba_errtxt, dba_get_msg (DBA_E_INV_TEMP_TYPE, NP, 0, NP, NP));
    return (99);
  }

  return (0);
}
/* Function:    dba_template_type_from_number */
int dba_template_type_from_number (ctype, itype)
char *ctype;
int itype;
{
  switch (itype)
    { case 0:  strcpy (ctype, "Report");  break;
    case DATBAS:  strcpy (ctype, "DB Rpt");  break;
    case USERDATA:  strcpy (ctype, "UD Rpt");  break;
    case ASCII:  strcpy (ctype, "ASC Rpt");  break;
    case UD_S:  strcpy (ctype, "UD Str");  break;
    case ASC_S:  strcpy (ctype, "ASC Str");  break;
    case MENU:  strcpy (ctype, "Dialog");  break;
    case SQL_TEMPLATE:  strcpy (ctype, "SQL");  break;
    case QUERY:  strcpy (ctype, "Query");  break;
    case SCRIPT:  strcpy (ctype, "Script");  break;
    case OPTIONS:  strcpy (ctype, "Options");  break;
    case BINARY:  strcpy (ctype, "Bin Rpt");  break;
    case ALL_STR:  strcpy (ctype, "Structure");  break;
    case BIN_S:  strcpy (ctype, "Bin Str");  break;
    case OBJECT:  strcpy (ctype, "Object");  break;
    case APPLICATION:  strcpy (ctype, "Application");  break;
    case PALETTE:  strcpy (ctype, "Palette");  break;
    case TOOLBAR:  strcpy (ctype, "Toolbar");  break;
    case STATUSBAR:  strcpy (ctype, "Statusbar");  break;    
    case BITMAP:  strcpy (ctype, "Bitmap");  break;        
    case RELATIONS:  strcpy (ctype, "Relations");  break;        
    default:
    strcpy (ctype, "Unknown");
    strcpy (dba_errtxt, dba_get_msg (DBA_E_INV_TEMP_TYPE, NP, 0, NP, NP));
    return (99);
  }
  return (0);
}
