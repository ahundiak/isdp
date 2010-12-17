/* $Revision: 1.2 $ */
#include "dba.ext"

extern char *dba_fldval;

/* Function:	dba_parse_relop */
int dba_parse_relop (att_ptr, relop)
struct dba_att *att_ptr;
char *relop;
{
  int jj, kk;
  switch (att_ptr->atyp) { 
    case ATT_ASC:  case ATT_RIS_TEXT:
      if (strncmp (dba_fldval, "!!", 2) == 0) { 
        strcpy (relop, "!!");
        for (jj=0; jj<strlen (dba_fldval); ++jj)
          dba_fldval[jj] = dba_fldval[jj+2];
      }
      break;
    case ATT_INT: case ATT_DOUBLE:
      for (jj=0; jj<2; ++jj) { 
        if (dba_fldval[0] >= '<' && dba_fldval[0] <= '>') { 
          relop[jj] = dba_fldval[0];
          relop[jj+1] = 0;
          for (kk=0; kk<strlen (dba_fldval); ++kk)
            dba_fldval[kk] = dba_fldval[kk+1];
        } 
      }
      break; 
  }
  return (0);
}
