#include "NFFadd.h"

/*  Commands that use this file  */

#define CREATE                    1
#define CHANGE                    2

/*  Display flags  */

#define ERASE                     1
#define DISPLAY                   2

/*  Value buffer conditions  */

#define EXISTING_LIST             1
#define NO_LIST                   2
#define NO_BUFFER                 3

/*  Gadget labels  */

#define TITLE1                   11
#define TITLE2                  108

#define ATTRIBUTES_GROUP         83
#define ATTRIBUTES_BUTTON        26
#define ATTRIBUTES_MCF           20

#define INFORMATION_GROUP        82
#define INFORMATION_BUTTON       25

#define TOP_BEZEL                12
#define LEFT_BEZEL               76
#define MID_TOP_BEZEL           120 
#define MID_BOTTOM_BEZEL         52
#define RIGHT_BEZEL              46

#define USER_DEFINED_BUTTONS     94
#define ADD_USER_DEFINED         95
#define DELETE_USER_DEFINED      96

#define KEYIN_FIELD_GROUP        73
#define ORDER_FIELD              58
#define ATTRIBUTE_FIELD          92
#define DATATYPE_FIELD          110
#define SYNONYM_FIELD            60
#define DEFAULT_FIELD            37

#define CHARACTERISTICS_GROUP    59
#define READ_TOGGLE              39
#define WRITE_TOGGLE             40
#define UPDATE_TOGGLE            41
#define DELETE_TOGGLE            42
#define NULLS_TOGGLE             43
#define CHECKIN_ROLLTHRU         44
#define CHECKOUT_ROLLTHRU        38

#define VALIDATE_BUTTON_PALETTE  27
#define VALIDATE_BUTTON          36
#define ADVISE_BUTTON            69

#define VALIDATE_TOGGLE          55
#define ADVISORY_FIELD           32

#define INFO_RANGE_GROUP         65
#define INFO_MIN_FIELD           63
#define INFO_MAX_FIELD           64

#define VALIDATE_LIST_GROUP      75
#define VALIDATE_LIST_FIELD      70

/*  Labels for the LOC half of the form  */

#define LOC_BEZEL                98
#define LOC_VALUE_TEXT           99
