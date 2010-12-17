/*  Global structure to store QUI info in  */

struct QUIglobal_st
  {
    char    username[NFM_USERNAME + 1];
    char    query_name[NFM_REPORTNAME + 1];
    char    attribute_source;
    char    use_lu_table_form;
    char    bezel_message_style;
    Form    field_form;
    int     field_label;
    char    *field_ptr;
    char    *text;
    long    text_size;
    long    QUI_delete_or_reorder;
    long    QUI_offset;
    long    QUI_numofattr;
    short   from_array[QUI_MAX_ATTR_NUM][2];
    MEMptr  catalogs;
    MEMptr  attributes[QUI_MAX_ATTR_NUM];
    MEMptr  values[QUI_MAX_ATTR_NUM];
  };

typedef struct Display
{
    char  *value;
    short catalog_no;
    short attrib_no;
    short oper;
    short and_or;
    short data_type;
    short query_display;
    short browse_display;
    short used;
    short join;
    short lookup_cat;
    char  field1[30];
    char  field2[30];
    short item_code;
    short write_code;
    short repeats;
    short order_by;
    short browse_scroll;
} Display_info;

/*  Externs  */

extern long         QUI_attrib_index[];
extern Display_info QUI_attrib_displayed[];

/*  Structure definition for text and field font information  */

typedef struct qfont
  {
    char    title_font[20];
    float   title_bodysize;
    char    label_font[20];
    float   label_bodysize;
    char    fields_font[20];
    float   fields_bodysize;
    char    operators_font[20];
    float   operators_bodysize;
  } QFONT;

/*  Structure definition for color information  */

typedef struct qcolor
  {
    int     buttons_on;
    int     buttons_off;
    int     and_or_on;
    int     and_or_off;
    int     revision_on;
    int     revision_off;
    int     checkin_on;
    int     checkin_off;
    int     fields_on;
    int     fields_off;
    int     checkboxes_on;
    int     checkboxes_off;
  } QCOLOR;
