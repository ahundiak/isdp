# ifndef EMSmsgassist_include
# define EMSmsgassist_include 1

/* This file holds macros and definitions to help construct the
messages and to help extract information from standardized
messages.  One need not use any OM preprocessors to include this
file.

HISTORY

13-Apr-1988 jBk Added EMS_MessageSubsystem_FacilityCode.
23-Mar-1988 jBk Added PROMPT, MESSAGE and SLEV7 to list of
                message severities.
??-???-???? jBk Genesis.
*/

/* EMS facility code (in decimal) */

# define EMS_FacilityCode 40
# define EMS_MessageSubsystem_FacilityCode 60

/* OM facility code */

# ifndef OM_FACILITY_CODE
# define OM_FACILITY_CODE 0x250
# endif

/* severity levels */

# ifndef WARN
# define WARN 0
# endif

# ifndef SUCC
# define SUCC 1
# endif

# ifndef ERRO
# define ERRO 2
# endif

# ifndef INFO
# define INFO 3
# endif

# ifndef FATL
# define FATL 4 /* very severe */
# endif

/* PROMPT and MESSAGE are not severity levels, per se, but
    different types of messages. */

# ifndef PROMPT
# define PROMPT 5
# endif

# ifndef MESSAGE
# define MESSAGE 6
# endif

/* SLEV7 simply rounds out the possible three-bit severity list */
# ifndef SLEV7
# define SLEV7 7
# endif

/* definitions to help define the messages */

# define EMS_FacilityField(fcode) (((fcode) << 16) | 0X8000)

# define EMS_MakeMsgFC(fcode, num, sev) \
    ((EMS_FacilityField(fcode)) | ((num) << 3) | (sev))

# define EMS_MakeMsg(num,sev) \
    (EMS_MakeMsgFC (EMS_FacilityCode, num, sev))

/* mask to find severity */

# ifndef SLEV
# define SLEV 7
# endif

/* mask to find message number */

# ifndef MESS
# define MESS (0xfff << 3)
# endif

/* macros for testing fields of messages */

# define EMS_SeverityLevel(x) ((x) & SLEV)
# define EMS_Message(x) (((x) & MESS) >> 3)
# define EMS_Facility(x) (((x) & 0x7ff0000) >> 16)

# endif /* EMSmsgassist_include */
