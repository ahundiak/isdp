/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
VRDbStruct.h
This include file defines the structures used for accessing the  
Reference and PDM/PDU tables                                     

CHANGE HISTORY:

	Date     |  Name | Description
        ---------------------------------------------------------------
        10/26/94  Lori     CR#179422038 added VR_MAX_SPEC_NAME_LEN


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#ifndef vrdbstruct_include

#define vrdbstruct_include

#include       "igrtypedef.h"
#include       "ACrg_collect.h"

#define         MAX_RIS_QUERY_PAR   200

#define         MAX_MACRO_PARAMS    150 
#define		MAX_ATTR_LEN   	    200
#define		MAX_SELECT_SIZE     200
#define		MAX_WHERE_SIZE	    400
#define         MAX_RIS_STR_SIZE    700

#define         MAX_COD_TABLE_ATTR  200
#define         MAX_BR_TABLE_SIZE   200
#define         MAX_ADPT_TABLE_SIZE 200
#define         MAX_PDM_PARTNO_SIZE  60   
#define         MAX_PIP_SPEC_TABS    10

#define         MAX_COLNAME_SIZE     30

#define         VR_VDS                    10
#define         VR_STRUCT                 11
#define         VR_MAX_SPEC_NAME        1000
#define         VR_MAX_SPEC_NAME_LEN      20
#define         VR_MAX_CODELIST_CACHE     20
#define         VR_MAX_FIELDLIST_CACHE    20        /* add for cr179528329 */
#define         VR_MAX_CODELIST_SIZE     250

#define         VR_MAX_FIELDLIST_SIZE   1000        /* add for cr179528329 */

#define         VR_MAX_NPDLIST_SIZE      150
#define         VR_MAX_NPDLIST_SIZE1    1000        /* add for cr179528329 */
#define         VR_MAX_PARAMLIST_SIZE     10
#define         VR_SHORT_CODETEXT_SIZE     9
#define         VR_SHORT_FIELDTEXT_SIZE    9        /* add for cr179528329 */
#define         VR_SHORT_MACROTEXT_SIZE   20        /* add for cr179528329 */
#define         VR_LONG_FIELDTEXT_SIZE    20        /* add for cr179528329 */
#define         VR_LONG_CODETEXT_SIZE     81           
#define         VR_MAX_HVSELCOD_TABLE_SIZE   300
#define         VR_MAX_HVCAT_OCC             200

/* definitions of param types for HVAC_SELECT_CODES table  */

#define         VR_HVSELCOD_TEXT             1
#define         VR_HVSELCOD_INT              2
#define         VR_HVSELCOD_DOUBLE           3

/* definitions for statement ids for select statements */

#define         PIP_COMPS1_PREP_ID2           2
#define         PIP_COMCOD_PREP_ID3           3
#define         PIP_SCHTHK_PREP_ID4           4
#define         PIP_COMPTYP_PREP_ID5          5
#define         PIP_COMPS2_PREP_ID6           6         
#define         HVAC_COMPS_PREP_ID7           7         
#define         HVAC_COMPTYP_PREP_ID8         8
#define         PIP_CODLST_PREP_ID9           9                 

/* definition of datatypes for the attributes    */

#define VR_RISDB_TEXT           0x0002
#define VR_RISDB_INT            0x0004
#define VR_RISDB_DOUBLE         0x0006
#define VR_RISDB_NODEF          0x0008

#define VR_IMPERIAL_UNITS	0
#define VR_MIXED_UNITS		1
#define VR_METRIC_UNITS		2

/* definition of missing in dynamic search   */
#define VR_MISSING_IN_SEARCH		3



#define		MAX_VDS_UNITS_PARAMS	200
#define		MAX_VDS_CONVERT_COLS	20


/* definition of structures for attributes */

struct attr_data
{

     short          type;
     union
     {
              
           char      attr_c[300];
           int       attr_int;
           double    attr_dbl;
     } val;
};

struct VRrisdat
{
     
          char                name[80];
          struct attr_data    data;

};
           

           
struct VDSunits
{
	char	param_name[20];
	int	units_set;
	int	units_code;
	double	resolution;
};

struct VDSconvert
{
	int	units_in;
	int	units_out;
	double	cnvr_fctr;
	double	cnvr_offset;
	double	rnd_off_fctr;
};


struct VRcodelist
{
   int                     application;
   int                     list_num;
   int                     count;
   char                    code[VR_MAX_CODELIST_SIZE][VR_SHORT_CODETEXT_SIZE];
   short                   code_num[VR_MAX_CODELIST_SIZE];
};


struct pipe_npd_allowed
{
     int     prj_no;
     double  npd;
     double  npd_equiv;
     char    spec_name[10];
};

struct pip_spec
{
    char     spec_name[10];
    int      prj_no;
    double   gask_sep;
    int      units_set;
    int      spec_no;
};


struct VRSelectAttr
       {
            short                   range;
            short                   type;
            struct ACrg_coll        sel;
       };
    

struct hvselcodtable
       {
          short   code_num;
          char    param_name[80];
          short   param_type;
       };

struct VRfieldlist
{
   int            application;
   int            count;
   char           field_name[VR_LONG_FIELDTEXT_SIZE];
   char           field[VR_MAX_FIELDLIST_SIZE][VR_SHORT_FIELDTEXT_SIZE];
};


struct VRmacrolist
{
   int            application;
   int            count;
   char           field_name[VR_SHORT_MACROTEXT_SIZE];
   char           field[VR_MAX_FIELDLIST_SIZE][VR_SHORT_MACROTEXT_SIZE];
};

struct VRriscol
{
   IGRchar        colname[MAX_COLNAME_SIZE];
   IGRint         coltype;
   IGRint         partype;
};

#endif
