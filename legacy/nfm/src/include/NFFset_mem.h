/*  Selectable Gadget labels on the form  */

#define TITLE1                12
#define TITLE2                13

#define TEXT_RECTANGLE        37 

#define SET_MEMBERS_MCF       11 
#define CATALOG_FIELD         22 
#define ITEM_FIELD            24 
#define REVISION_FIELD        26 

#define HIDDEN_SCF            25 

#define CATALOG_BUTTON        31 
#define ITEM_BUTTON           32 
#define REVISION_BUTTON       33 
#define ADD_BUTTON            34 
#define DELETE_BUTTON         36 

#define TYPE_TOGGLE           29      /*  SETS : off = "S",  on = "P"  */
                                  /*  PROJECTS : off = "R",  on = "O"  */

/* #defines for default type_toggle text */

#define S_OFF_TEXT            "S"     /*  Sibbling     */ 
#define S_ON_TEXT             "P"     /*  Parent       */
#define P_OFF_TEXT            "R"     /*  Referenced   */
#define P_ON_TEXT             "O"     /*  Owned        */


/* Assumed columns in INFORMATION_MCF */

#define CATALOG_COLUMN         0
#define ITEM_COLUMN            1 
#define REVISION_COLUMN        2 
#define TYPE_COLUMN            3 
