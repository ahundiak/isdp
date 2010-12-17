/*______________________________________________________________________
 |									|
 |	Unpublished, but if published:					|
 |	Copyright Intergraph Corporation, 1989,1990 including software	|
 |	and its file formats, and audio-visual displays;   this is the	|
 |	property  of  Intergraph  Corporation;   All  Rights  Reserved	|
 |	May only be used pursuant to the applicable  software  license	|
 |	agreement; contains confidential and  proprietary  information	|
 |	of Intergraph and/or other third parties which is protected by	|
 |	copyright,  trade secret  and  trademark law  and  may  not be	|
 |	provided or otherwise  made  available  without  prior written	|
 |	authorization;							|
 |	Restricted Rights Legend:					|
 |	Use, duplication or disclosure by the government is subject to	|
 |	restrictions as set forth in  subdivision (b) (3) (ii)  of the	|
 |	rights  in  technical  data  and  computer software  clause at	|
 |	52.227-7013.							|
 |									|
 |	Intergraph Corporation						|
 |	One Madison Industrial Park					|
 |	Huntsville, Alabama 35807					|
 |______________________________________________________________________|
*/

/* Header File for Help Library Calls   Version 7.1.0 */


/* Help_gadget_select */

#define TOC_BUTTON      0
#define INDEX_BUTTON    1
#define SEARCH_BUTTON   2
#define UP_BUTTON       3
#define NEXT_BUTTON     4
#define BACK_BUTTON     5
#define GLOSSARY_BUTTON 6
#define PRINT_BUTTON    7


/* Help_locations */

struct helpLocations
{
   char *processExecutableFileName;
   char *defaultsFileName;
   char *fontDirectoryName;
   char *messagesDirectoryName;
   char *symbolsDirectoryName;
};


/* Help_mode */

#define SR_WINDOW_ONLY             0
#define STANDARD_WINDOW_ONLY       1
#define SR_CONVERTIBLE_TO_STANDARD 2


/* Help_screen */

#define PHYSICAL_SCREEN_0 0
#define PHYSICAL_SCREEN_1 1


/* Help_standard_color_map, Help_standard_vlt_loading */

#define TWO_COLOR_VLT   0
#define FOUR_COLOR_VLT  1
#define GS_MINIMAL_VLT  2
#define GS_EXTENDED_VLT 3
#define GX_GZ_VLT       4


/* Help_status */

/* Note that passing these strings to Help_topic will _not_ cause display of the
   corresponding nontopics. */
#define HELP_MESSAGE_LOGICAL_NAME                  "helpMessage"
#define HELP_TABLE_OF_CONTENTS_LOGICAL_NAME        "helpTableOfContents"
#define HELP_INDEX_LOGICAL_NAME                    "helpIndex"
#define HELP_SEARCH_SUBFORM_LOGICAL_NAME           "helpSearchSubform"
#define HELP_GLOSSARY_LOGICAL_NAME                 "helpGlossary"
#define HELP_PRINT_ASCII_SUBFORM_LOGICAL_NAME      "helpAsciiPrintSubform"
#define HELP_PRINT_POSTSCRIPT_SUBFORM_LOGICAL_NAME "helpPostScriptPrintSubform"

/* The Help library malloc's space for the character strings returned in
   struct helpStatus.  A program using Help_status should free this space when
   it is finished with it. */
struct helpStatus
{
   char *libraryVersion; /* version of Help library */
   char *processVersion; /* version of Help process */
   int displayed; /* nonzero if Help form is displayed, 0 otherwise */
   int saveRestore; /* nonzero if Help form form is save/restore or would be if
                       displayed */ 
   int collapsed; /* nonzero if Help form is displayed and collapsed, 0
                     otherwise */
   int x, y, width, height; /* Help form location, where would be if not
                               collapsed or undisplayed */
   char *displayLogicalName; /* NULL if Help form is not displayed; see above
                                for #defines of logical names of nontopic
                                displays */
};


/* Help_font (obsolete) Avoid using this routine. */

#define BASIC_TEXT_FONT      0 /* <T> */
#define SUBHEADER_TEXT_FONT  1 /* <S> */
#define HEADER_TEXT_FONT     2 /* <H> */
#define MONOSPACED_TEXT_FONT 3 /* <F> */
#define EXTRA_TEXT_FONT      4 /* <X> */

#define FONT_7_OR_8_BIT_MODE   0
#define FONT_7_AND_16_BIT_MODE 1


/* Help_gadget_state (obsolete) Avoid using this routine. */

#define DISABLED    0
#define ENABLED     1
#define UNDISPLAYED 2
