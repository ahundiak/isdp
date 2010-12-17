#include "machine.h"
#include "QUI.h"

long QUIparse_trio (trio)
  char *trio;
  {
  char cat_alias[20];
  short catalog_no;
  short attrib_no;
  char attribute[NFM_NAME + 1];
  char operator[20];
  long oper, status;
  char value[80];
  long index,index1,length;
  char *dummy_trio;
  int   data_offset;
  char  **data, terminator;
  short data_type, data_length;
  static  char    *fname = "QUIparse_trio";
  char  nfm_date[100];
  char  ris_date[100];

  _NFIdebug ((fname, "trio = <%s>\n", trio));

  nfm_date[0] = 0;
  ris_date[0] = 0;

  length = strlen(trio);
  dummy_trio = (char *) malloc(length+1);
  strcpy(dummy_trio,trio);
  index=0;
  index1=0;
  while ((index<length)&&(trio[index]!='.'))
  {
    index++;
    index1++;
  }
  dummy_trio[index1]=0;
  strcpy(cat_alias,dummy_trio);
  _NFIdebug ((fname, "cat_alias=.%s.\n",cat_alias));

  QUIget_catalog_from_alias(cat_alias,&catalog_no);

  strcpy(dummy_trio,&trio[index+1]);
  index1=0;
  while ((index<length)&&(trio[index]!=' ')) 
  {
    index++;
    index1++;
  }
  dummy_trio[index1-1]=0;
  strcpy(attribute,dummy_trio);
  _NFIdebug ((fname, "attribute=.%s.\n",attribute));
  while ((index<length)&&(trio[index]==' ')) index++;
  index1=0;
  strcpy(dummy_trio,&trio[index]);

  /*  Make sure we don't skip over IS NOT NULL, NOT LIKE, and TIMESTAMP  */

  while ((index < length) && ((trio[index] != ' ') ||
        ((strncmp (&trio[index], " NOT ", 5)) == 0) ||
        ((strncmp (&trio[index], " TIMESTAMP ", 11)) == 0) ||
        ((strncmp (&trio[index], " LIKE ", 6)) == 0)))
    {
      index++;
      index1++;
    }

  operator[0] = 0;
  dummy_trio[index1] = NULL;
  strcpy (operator, dummy_trio);
  _NFIdebug ((fname, "operator = <%s>\n", operator));

  if (strcmp (operator, "LIKE") == 0) strcpy (operator, "=");
  else if (strcmp (operator, "NOT LIKE") == 0) strcpy (operator, "!=");
  else if (strcmp (operator, "IS") == 0) strcpy (operator, "=");
  else if (strcmp (operator, "IS NOT") == 0) strcpy (operator, "!=");

  /*  Check for TIMESTAMP after the real operator  */

  else if (strcmp (&operator[strlen (operator - 9)], "TIMESTAMP") == 0)
      operator[strlen (operator - 8)] = NULL;

  oper=QUI_get_op(operator);
  _NFIdebug ((fname, "oper=.%d.\n",oper));

  /*  This code assumes that there are
      spaces between the operator and any values  */

  while ((index<length)&&(trio[index]==' ')) index++;

  terminator = ' ';
  if (trio[index]=='\'')
    {
      /*  Hit the first tic (char value)  */

      index++;
      terminator = '\'';
    }

  index1=0;
  strcpy(dummy_trio,&trio[index]);
  while ((index<length)&&(trio[index] != terminator))
  {
    index++;
    index1++;
  }

  if (dummy_trio[index1-1]=='\'') index1--;
  dummy_trio[index1]=0;
  strcpy(value,dummy_trio);

  /*  Check for wildcard characters  */

  for (index=0;index<strlen(value);index++)
  {
    if (value[index]=='%')
      value[index]='*';
  }
  _NFIdebug ((fname, "value=.%s.\n",value));

/* Added by Ravi 13 June 1998 */
  if( strcmp(&operator[strlen(operator) - 9], "TIMESTAMP") == 0 )
  {
  _NFIdebug ((fname, "Ravi - Before NFMRvalidate_and_format_date - for display\n"));
      status = QUIformat_date(value);
      status = NFMRvalidate_and_format_date(value, nfm_date, ris_date);
  _NFIdebug ((fname, "Ravi value = %s, nfm_date = %s, ris_date = %s\n", value, nfm_date, ris_date));
      if(status == NFM_S_SUCCESS)
          strcpy(value, nfm_date);
  }
/* End of Addition by Ravi */

  /*  Jim said to put an if statement right HERE  */

  if ((strcmp (value, "f_a.n_itemnum")) != 0)
    {
      /*  This is NOT a join; use it  */

      if ((status = QUIget_attributes (catalog_no)) != QUI_S_SUCCESS)
        {
          _NFIdebug ((fname, "QUIget_attributes = <0x%.8x>\n", status));
          if (dummy_trio) free (dummy_trio);
          _NFIdebug ((fname, "returning <0x%.8x>\n", status));
          return (status);
        }

      if ((status = QUIget_number_from_attribute
          (catalog_no, attribute, &attrib_no)) != QUI_S_SUCCESS)
        {
          _NFIdebug ((fname,
              "QUIget_number_from_attribute = <0x%.8x>\n", status));
          if (dummy_trio) free (dummy_trio);
          if (status == QUI_E_BUFFER)
              ERRload_struct (NFI, QUI_W_ATTR_NOT_FOUND, "%s", attribute);
          _NFIdebug ((fname, "returning <0x%.8x>\n", status));
          return (status);
        }

      QUI_attrib_displayed[QUIglobal.QUI_numofattr].catalog_no = catalog_no;
      QUI_attrib_displayed[QUIglobal.QUI_numofattr].attrib_no = attrib_no;

      /*  Find the datatype for this attribute  */

      data = (char **) QUIglobal.attributes[catalog_no]->data_ptr;
      data_offset = (attrib_no *
          QUIglobal.attributes[catalog_no]->columns) + 1;

      _NFIdebug ((fname, "datatype = <%s>\n", data[data_offset]));

      QUIget_type (data[data_offset], &data_type, &data_length);
      QUI_attrib_displayed[QUIglobal.QUI_numofattr].data_type = data_type;

      /*  Initialize the values list pointer  */

      QUIglobal.values[QUIglobal.QUI_numofattr] = NULL;

      QUI_attrib_displayed[QUIglobal.QUI_numofattr].oper=oper;
      if (strlen (value) > QUI_MIN_VALUE_LEN)
      {
        QUI_attrib_displayed[QUIglobal.QUI_numofattr].value = 
        (char *) realloc (QUI_attrib_displayed[QUIglobal.QUI_numofattr].value, 
           strlen (value) + 1);
      }
      strcpy(QUI_attrib_displayed[QUIglobal.QUI_numofattr].value,value);
      QUI_attrib_displayed[QUIglobal.QUI_numofattr].query_display=1;
    }
  else
    {
      /*  This IS a join; decrement number of attributes
          because it will get incremented upon return from here  */

      QUIglobal.QUI_numofattr--;
    }

  if (dummy_trio) free (dummy_trio);

  _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", QUI_S_SUCCESS));
  return (QUI_S_SUCCESS);
}

long QUIformat_date(value)
char *value;
{

char timestr[100];
char mm[10], dd[10], yy[10];
char *tempstr;
char date_type[40], time_type[40], format_string[80];
static  char    *fname = "QUIformat_date";

  _NFIdebug ((fname, "value = <%s>\n", value));
timestr[0] = mm[0] = dd[0] = yy[0] = 0;

NFMRget_date_info(date_type, time_type, format_string);
  _NFIdebug ((fname, "Date Type = <%s>\n", date_type));
  _NFIdebug ((fname, "Time Type = <%s>\n", time_type));
  _NFIdebug ((fname, "Format String = <%s>\n", format_string));

tempstr = value;
strcpy(timestr, strchr(tempstr, ':'));
value[strlen(value) - strlen(strchr(tempstr, ':'))] = 0;
tempstr = strtok(value, "-");
strcpy(yy, tempstr);
  _NFIdebug ((fname, "yy = <%s>\n", yy));
tempstr = strtok(NULL, "-");
strcpy(mm, tempstr);
  _NFIdebug ((fname, "mm = <%s>\n", mm));
tempstr = strtok(NULL, "-");
strcpy(dd, tempstr);
  _NFIdebug ((fname, "dd = <%s>\n", dd));
value[0] = 0;

if(strcmp(date_type, "BRITISH") == 0)
    sprintf(value, "%s/%s/%s%s", dd, mm, yy, timestr);
else if(strcmp(date_type, "ITALIAN") == 0)
    sprintf(value, "%s-%s-%s%s", dd, mm, yy, timestr);
else if(strcmp(date_type, "FRENCH") == 0 || 
        strcmp(date_type, "GERMAN") == 0 ||
        strcmp(date_type, "SPANISH") == 0)
    sprintf(value, "%s.%s.%s%s", dd, mm, yy, timestr);
else  /* AMERICAN or default */
    sprintf(value, "%s/%s/%s%s", mm, dd, yy, timestr);

  _NFIdebug ((fname, "return value = <%s>\n", value));
return(QUI_S_SUCCESS);

}
