/*

Module:  COgetevent()

Abstract: This is a filter that takes a mask and returns events that are
          specified in the mask.  Certain events will always be returned, 
          regardless of the event mask received. They are the events that
          select a command, kill a command, step forward, backward in the
          command stack, and selecting help and status display.

Arguments:

   *returnmsg      IGRlong         Return message:
                                     MSSUCC - success
                                     MSFAIL - severe error
                                     GRw_no_value - user enter null string
                                     GRw_ev_trunc - data in event truncated
                                     CO_e_syntax - expression had syntax error
                                     CO_e_divide_by_zero - division by 0 
                                           attempted

    scaleflag      IGRlong         A Flag specifying what kind of scaling
                                   ( if any ) should be applied to values
                                   returned in Event->event.value.
                                     GRIO_NO_SCALE (0): no scaling is desired
                                     GRIO_X_SCALE  (1): use X scale of ACS 
                                     GRIO_Y_SCALE  (2): use Y scale of ACS
                                     GRIO_Z_SCALE  (3): use Z scale of ACS
                                     N>3              : use Nth scale of ACS

    eventmask      IGRlong         A mask specifying events that are wanted

    EventSize      IGRlong         Size of event buffer passed

   *Prompt         IGRchar         Used to specify a literal prompt string to
                                   be issued to the user when interaction is
                                   required to get an event.  If NULL, and 
                                   msgnum is GRIO_NO_MSG, then the prompt field
                                   is left uneffected.

    MsgNumber      IGRshort        If not equal to GRIO_NO_MSG this is used to 
                                   specify the prompt via the message subsystem.
 
   *MsgName        IGRchar         If not equal to NULL, this is used to 
                                   specify the name of the prompt to be 
                                   issued.

  ****************************************************************************
  NOTE:  no more than one of the above three arguments should be used to
         specify a prompt.  If no prompt is wanted, then Prompt and MsgName
         should be set to NULL and MsgNumber should be set to GRIO_NO_MSG.
  ****************************************************************************

   *ValueType      IGRchar         If mask includes GRm_VALUE, then the 
                                   value type is generated from this string.
                                   Otherwise this parameter is ignored.
                                   This allows a useful interface with the
                                   UOM subsystem since applications will 
                                   have their own value types.

    Mode           IGRlong         mode of keyboard input:
                                     EX_LINE_MODE     - return after <CR>
                                     EX_ALL_CHAR_MODE - return as soon as 
                                                        the keyboard buffer
                                                        contains input

   *nbytes         IGRint          The number of bytes returned in the 
                                   response_data buffer; this is very useful
                                   if data stored in the GRevent structure
                                   is truncated and must be retrieved manually
                                   from this buffer

   *response       IGRlong         Executive response type

   *response_data  IGRchar         Executive response_data buffer

   *Event          struct GRevent  The event returned


 Example:  status = COgetevent( returnmsg,
                                scaleflag,
                                eventmask,
                                EventSize,
                                Prompt,
                                MsgNumber,
                                MsgName,
                                ValueType,
                               Mode,
                               nbytes,
                               response,
                               response_data,
                               Event );


 Notes:

   The Event Mask:

     The event mask indicates the type of event(s) needed by the command.

     Example:  if a command needs a data event or a reject/move-on event, then
               the mask should be set as follows:
               
                  event_mask = ( GRm_RJT_MOVEON | GRm_DATA );

     Mask bits that the getevent filters recognize are:

        GRm_DATA - for data points

        GRm_RJT_MOVEON - for reset events

        GRm_STRING - for raw ( uninterpreted ) text input 

        GRm_TEXT_VALUE  ( lots to discuss here )
           
           For text strings ( delimiters recognized for separating 
           arguments )  Set this mask bit if you want to be able to
           enter more than one argument in a single keyin.  
           
           For example, if we are writing a command called Delete Windows
           we may want an interface where a user can specify several
           windows by name in a single keyin.  

                delete window = window1,window2,window3

           Here, a comma separates three text strings: "window1", 
           "window2", and "window3".  

           By setting the GRm_TEXT_VALUE bit in the event mask and 
           iteratively calling the getevent filter each of the three 
           strings can extracted separately.

           Unless raw text is wanted, use GRm_TEXT_VALUE as the mask
           for getting text string.

           Note:  Do NOT set both the GRm_STRING and GRm_TEXT_VALUE
           bits in the event mask!  The results are not predictable.

        GRm_CHAR  -  for keyboard input as it is typed ( Mode should be set
                     to EX_ALL_CHAR_MODE );

        GRm_MOVE_ON - for MOVE_ON events

        GRm_OBJID - special purpose event for locate interface

        GRm_VALUE - used in conjunction with the unit_type argument in 
                    COgetevent, this can specify any unit value
                    supported by the application ( scalar, distance, 
                    angle, etc. )

        GRm_FORM_FINISHED - used to signal that a form is finished.

        A note about precedence:  It is possible for there to be more
        than one way to interpret an input.  The most common example
        of this is when the event mask requests a value OR a text 
        string ( e.g. mask = GRm_VALUE | GRm_TEXT_VALUE ).  Because a
        value can be keyed in as text, a precedence has to exist.  If
        the user keys in a string such as "150" then is this a string
        ( EX_STRING ) or a numeric ( EX_VALUE )? 
      
     The getevent filter always places a higher precedence on EX_VALUE than on
     text! Thus, if the event mask is set to recognize a scalar value or a
     text string, and the user keys in "150", then the EX_VALUE 150 is returned
     in the event and event->response is set to EX_VALUE.  If the user had 
     keyed in "150A", which is not a proper scalar expression, then the 
     EX_STRING "150A" is returned in the event and event->response is set to 
     EX_STRING.

     If a software event is found that is of a type requested in the
     event mask, then the event structure is loaded with the appropriate
     information.  On return, event->response indicates the format of 
     data which is stored in the event->event ( union ) buffer.  It will
     have one of the following values:

        EX_RJT_MOVEON
            
           The event mask included GRm_RJT_MOVEON and a EX_RJT_MOVEON event
           was found ( the event->event buffer is loaded ) 

        EX_MOVE_ON 
               
           The event_mask included GRm_MOVE_ON and a MOVE_ON event
           was found ( the event->event buffer is loaded )

        EX_OBJID 

           The event_mask included GRm_OBJID and a response of
           EX_OBJID event was found ( the event->event.button
           buffer is loaded with window information from the 
           "specified object" )

        EX_DATA 
              
           The event_mask included GRm_DATA and a EX_DATA event was 
           found ( the event->event.button buffer is loaded ).  

        EX_VALUE 
           
           The event_mask included GRm_VALUE a EX_VALUE event was returned
           ( the event->event.value buffer is loaded )

        EX_STRING 
               
           The event_mask included GRm_STRING or GRm_TEXT_VALUE and 
           a EX_STRING event was found ( the event->event.keyin buffer
           is loaded )

        EX_CHAR
               
           The event_mask included GRm_CHAR and an EX_CHAR event was found
           ( the event->event.keyin buffer is loaded with a string of length
           event->nbytes - it is NOT terminated with a null character )

        EX_FORM_FINISHED

           The event mask included GRm_FORM_FINISHED and an EX_FORM_FINISHED
           event was found (the event->event buffer is NOT loaded).

        GR_UNKNOWN_TYPE 
           
           The event found did not match any of the types indicated in
           the event mask.  This usually flags the command to exit, 
           returning response and response_data to the Command Server
           for evaluation.

      The event->subtype field is used to qualify the event returned.  Data
      points may subtypes such as GRst_REGULAR or GRst_PERPENDICULAR_TO, etc.
      The subtype filed is also used to indicate default argument detection.
      If the event->mask includes GR_VALUE, GR_STRING, or GR_Text_VALUE, and
      if a null string argument is provided, then the subtype field will 
      be set to GRst_DEFAULT upon return from COgetevent.


      On return, *response indicates the format of data which is returned in
      response_data ( NOT the event!!!).  For example, if the getevent filter
      is called with a request for a value ( e.g. an angle ) and the value is
      keyed in by the user ( e.g. "45 degrees" ) then *response will be
      EX_STRING ( not EX_VALUE ), because response_data will contain the keyed
      in string.

      WARNING:  do not check *response to find out what kind of event was
      returned!  Instead, check event->response.

      Documentation on the use of the COgetevent can be found in the include
      file "griomacros.h", which is delivered in the GRIO package.


 Caveates:
    
    If a prompt is specified, it will only be displayed if both the Software
    Event Queue and the Variable String Descriptor ( VSD ) buffer are empty.

    The following C Macros are defined in the include file 
    ./grio/include/griomacros.h and are for use by the general programming
    community.  

            vsd_empty      - calls a function defined in this source file
            clear_vsd      - calls a function defined in this source file
            queue_empty    - calls an executive function

    The following C Macros are defined in the include file 
    ./grio/include/griopriv.h and can only be used in the context of
    this source file!

           _command_line_arg
           _not_command_line_arg

    The following C Macros are defined in this source file can are private to 
    this file alone!

            VSD_EMPTY       - same as vsd_empty except accesses VSD directly
            CLEAR_VSD       - same as clear_vsd except accesses VSD directly
           _load_vsd
           _get_arg_from_vsd
           _get_rest_of_vsd


 History:

    srh   03/31/87  -  created, a rewrite of Ching Ng's GRgetevent
                       filter with a new expression evaluator, a more
                       flexible Unit Subsystem interface, and "smart"
                       prompting.

    srh   06/26/87  -  When default is indicated by null string argument
                       the event->subtype filed in the returned event is
                       set to GRst_DEFAULT;

    srh   08/18/87  -  New masks are supported for the new response types:

                  mask                         response
              -------------      ------------------------------------------
               GRm_RESTART        EX_RESTART    ( new )
               GRm_BACK_UP        EX_BACK_UP    ( new )
               GRm_RJT_MOVEON     EX_RJT_MOVEON ( replaces *_RESET )
               GRm_OBJID          EX_OBJID      ( replaces *_SPECIFIED_OBJ )

    srh   08/20/87  -  Added variable interpretation code;  this allows 
                       data points, strings, and values to be entered by 
                       by name.

    srh   09/02/87  -  Added new parameter added for specifying the mode in 
                       which keyboard input is handled.  

                       IF Mode == EX_ALL_CHAR_MODE
                       THEN the mask has to include GRm_CHAR and the event
                            returned will have event->nbytes characters in
                            the event->event.keyin buffer ( Not NULL 
                            terminated !)

                       IF Mode == EX_LINE_MODE
                       THEN a charage return has to be entered before an
                            keyin type event is returned.

    srh   09/04/87  -  Changed the way the getevent filter handles an
                       EX_OBJID reponse.  Instead of the filter building
                       the GRevent structure, it expects response_data
                       to be in the form of a GRevent ( from the union 
                       field down ).  The filter just does a memory copy
                       using the byte count returned from ex$wait_for_input
                       as the number of bytes copied.

    srh   10/02/87  -  Fixed bug:  values failing expression evaluation
                       did not return a msg of CO_e_syntax, when GRm_VALUE
                       was the only "string" mask bit set.
 
    srh   10/07/87  -  Made prompting even smarter!  If this filter issues
                       a prompt to the prompt field, then on successful 
                       completion it will clear that prompt.  There is 
                       one exception to this rule: if the response type
                       returned from ex$wait_for_input is EX_CHAR, then
                       the prompt filed is not cleared.

    srh   10/11/87  -  Fixed bug - error message was caused by attempt to
                       clear prompt; caused by bad arguement list to 
                       ex$message.

    srh   10/12/87  -  Added argument MsgName for specifying a message by
                       its ASCII string name ( for ex$message interface )

    jsd   03/21/88  -  New mask is supported for the new response type :
       
                              mask                       response
                       -------------------      --------------------------- 
                        GRm_FORM_FINISHED        EX_FORM_FINISHED     (new)

    srh   04/20/88  -  Added nbytes argument which returns to the caller the
                       actual number of significant bytes stored in the
                       response_data buffer, as returned from the executive.

    srh   07/01/88  -  BUG FIX; now returns GRw_no_value when mask has 
                       GRm_STRING bit set and user enters a zero length 
                       ( null ) string to indicate default.

    srh   08/02/88  -  Made the Variable String Descriptor ( VSD ) static. C
                       macros used to access it are replaced by funtions; The
                       filter itself accesses the VSD directly for the sake of
                       efficiency. This version is for the 1.2.0 release of
                       I/DRAFT.

    srh   04/18/89  -  Added scaleflag argument; "scalable" values are now 
                       scaled wrt the Active Coordinate System if the scaleflag
                       is set >= 0;  A value of -1 indicates no scaling. For
                       version 1.3.0 of GRNUC.

    srh   06/06/89  -  Implemented recognition of a quoting character ( the
                       back slash '\' ). Two back slashes are treated as one.
                       a terminal back slash is ignored.  This is implemented
                       in the _get_arg_from_vsd() C macro ( #define'd below ). 
                       This does not effect text retrieved when the GRm_STRING
                       bit is set in the event mask. (Version 1.3.0 of GRNUC)
                       ALSO, fixed bug in processing of EX_STRING data when
                       mask set with GRm_STRING ( memcpy had bad args ).

    srh   11/10/89  -  Bug fix - quoted numbers were being treated as numbers
                       instead of string.  Thus if a command prompts for a
                       number OR a name, the name "4" can be entered as "\4"
                       without ambiguity.

    rlw   02/01/92  -  The code assumed that a Reset had no response_data
                       associated with it.  Modified to copy the number of
                       bytes that it returned by the exec.
 
    scw   07/14/92  -  Ansi conversion

    srh   05/25/93  -  Added support for Smart Sketch in Phoenix/2.4 release.

    02/17/94 : Rajiv Agrawal : Added support to read the proper x,y,z values from a
                               journal file when smart sketch is ON.  See related file
                               in src/co/misc/GRrapapnd.I to see how the journal is
                               written (TR119417282).
 */

#include   <stdio.h>
#include   <memory.h>
#include   <string.h>
#include   "grimport.h"
#include   "codebug.h"
#include   "igrtypedef.h"
#include   "OMminimum.h"
#include   "OMDB.h"
#include   "igetypedef.h"
#include   "OMlimits.h"
#include   "igr.h"
#include   "gr.h"
#include   "msdef.h"
#include   "msmacros.h"
#include   "exdef.h"
#include   "ex.h"
#include   "igrdp.h"
#include   "godef.h"
#include   "go.h"
#include   "griodef.h"
#include   "grio.h"
#include   "griomacros.h"
#include   "griopriv.h"
#include   "grdpbdef.h"
#include   "grdpbmacros.h"
#include   "exmacros.h"
#include   "codef.h"
#include   "igrmacros.h"
#include   "SSdef.h"
#include   "SSmacros.h"
#include   "journal.h"

/*

  Notes about the VSD ( Variable String Descriptor ) and C macros that 
  manipulate it:

  The GR_vsd structure as defined in ./draft/grio/include/grio.h:

    struct GR_vsd
    {
       IGRlong  start;
       IGRlong  end_ptr;
       IGRchar  delimiter;
       IGRchar  field_delimiter;
       IGRlong  buffer_size;
       IGRchar  buffer[MAX_BUF_SIZE];
    };

  Rules/Definitions:

    1. The VSD is "clear" when vsd.start and vsd.end_ptr both equal zero.

    2. The VSD buffer is null terminated.  Each argument in it is 
       terminated by the vsd.delimiter except for the last argument
       which is terminated by having vsd.end_ptr point to the character
       following it.

    3. The VSD is "empty" when vsd.start and vsd.end_ptr are equal.

    4. When the VSD buffer is loaded, vsd.start is set to 0 and vsd.end_ptr 
       is set to the length of the string ( counting the terminal NULL
       character ).  Thus if a null string is loaded into the VSD, vsd.start
       will equal 0 and vsd.end_ptr will equal 1. If the string "hello" is
       loaded into the VSD  then vsd.end_ptr will equal 6.

       The macro for loading the VSD is called _load_vsd.
       
          _load_vsd(size,data,bytes_copied);

       This macro copies the number of characters indicated by <size> from 
       the buffer <data> into vsd.buffer and returns the actual number of 
       characters copied in <bytes_copied>.  After the macro has been called,
       vsd.start is equal to zero ( 0 ) and vsd.end_ptr is equal to <size>.

    5. Arguments in the VSD are separated by what is called an argument 
       delimeter.  This is either the vsd.delimiter character or the 
       vsd.end_ptr position ( index ) in the vsd.buffer.

    6. When an argument is retrieved from the VSD, vsd.start is incremented
       by the length of the argument retrieved plus one.  The "plus one" 
       accounts for the argument delimiter.  This allows vsd.start to be use 
       as an index into vsd.buffer.

       Two macros exist for retrieving arguments from the VSD.  The following
       macro gets the next avaliable argument from the VSD.

            _get_arg_from_vsd( bufsize, argbuf, nbytes, quoted );

       The argument retrieved is put in <argbuf>, terminated with a NULL 
       character.  <bufsize> indicates the maximum number of characters in
       <argbuf> and thus limits the argument size.  <nbytes> will return 
       the length of the argument ( including the terminal NULL character ).

       Note: 05/11/89 - This is where the quoting character '\' is respected.
       If arg is quoted ( e.g. "\4" ), quoted = TRUE on return (11/8/89:srh)

       The following macro gets all remaining arguments from the VSD and 
       places them as a single string ( NULL terminated ).

          _get_rest_of_vsd( bufsize, argbuf, nbytes );

       The string retrieved is placed in <argbuf>.  <bufsize> indicates
       the maximum number of characters in <argbuf> and thus limits the 
       length of the string copied into <argbuf>.

 */

/* may want to make quoting character a static char and configurable */
#define  QUOTE                '\\'

#define  VSD_EMPTY            ( vsd.start >= vsd.end_ptr )
#define  VSD_NOT_EMPTY        ( ! VSD_EMPTY )
#define  CLEAR_VSD            vsd.start = 0 ; vsd.end_ptr = 0 

#define _load_vsd(size,data,bytes_copied)                                   \
                                                                            \
       vsd.start = 0;                                                       \
       bytes_copied = MIN(vsd.buffer_size, size);                           \
       memcpy( vsd.buffer, data, bytes_copied );                            \
       vsd.end_ptr = bytes_copied;

#define _is_quote (vsd.buffer[vsd.start] == QUOTE)

/*****************************************************************************
#define _debug_vsd( bufsize, argbuf, nbytes )
  printf( "   vsd.start     :   %d\n", vsd.start );
  printf( "   vsd .end_ptr  :   %d\n", vsd.end_ptr );
  printf( "   vsd from start:   \"%s\"\n", &vsd.buffer[vsd.start] );
  printf( "   Argument  : \"%s\"\n", argbuf  );
  printf( "   ArgLength : \"%d\"\n", nbytes );
 *****************************************************************************/

#define _get_arg_from_vsd( bufsize, argbuf, nbytes, quoted )                \
                                                                            \
  quoted = FALSE;                                                           \
  nbytes = 0;                                                               \
  while( vsd.buffer[vsd.start] == ' ' ) vsd.start++;                        \
  while( vsd.start != ( vsd.end_ptr - 1 )        &&                         \
         vsd.buffer[vsd.start] != vsd.delimiter  &&                         \
         nbytes < ( bufsize - 1 )  )                                        \
  {                                                                         \
    if ( _is_quote )                                                        \
    {                                                                       \
       argbuf[nbytes] = vsd.buffer[++vsd.start];                            \
       quoted = TRUE;                                                       \
    }                                                                       \
    else                                                                    \
       argbuf[nbytes] = vsd.buffer[vsd.start];                              \
                                                                            \
    nbytes++;                                                               \
    vsd.start++;                                                            \
  }                                                                         \
  argbuf[nbytes++] = NULL;                                                  \
  vsd.start++;



#define _get_rest_of_vsd( bufsize, argbuf, nbytes )                         \
                                                                            \
       for ( nbytes = 0;                                                    \
             ( ( vsd.start != ( vsd.end_ptr - 1 ) )    &&                   \
               ( nbytes < bufsize - 1 )                                     \
             );                                                             \
             nbytes++, vsd.start++ )                                        \
       {                                                                    \
          argbuf[nbytes] = vsd.buffer[vsd.start];                           \
       }                                                                    \
       argbuf[nbytes++] = NULL;                                             \
       vsd.start = vsd.end_ptr = 0;      /* clear VSD */                    \
       vsd.buffer[0] = NULL;

/*
    Other C macros local to COgetevent()
  
       WeMustPrompt   - boolean expression that is true if a prompt should 
                        be issued to the prompt field
  
       _set_nbytes()  - macro that assigns a value to nbytes if nbytes 
                        is not a NULL pointer
 */


#define   WeMustPrompt    (   (queue_empty)                               \
                           && (   (Prompt != NULL)                        \
                               || (MsgNumber != GRIO_NO_MSG))             \
                               || (MsgName   != NULL ) )

#define   _set_nbytes(nbytes,value)  if (nbytes) *nbytes = value



/*
 *  Definition/initialization/allocation of the Variable String Descriptor
 *  (VSD) which is used to store arguments entered in ascii string format
 *  for individual retrieval.
 */
static struct GR_vsd vsd = {
                              0,                  /*  start          */
                              0,                  /* end_ptr         */
                              ',',                /* delimiter       */
                              '\0',               /* field_delimiter */
                              MAX_BUF_SIZE,       /* buffer_size     */
                              NULL,               /* buffer          */
                           };


/*  ========================================================================  */


IGRlong COgetevent( returnmsg,
                    scaleflag,
                    eventmask,
                    EventSize,
                    Prompt,
                    MsgNumber,
                    MsgName,
                    ValueType,
                    Mode,
                    nbytes,
                    response,
                    response_data,
                    Event )

                                /* Notation:  (-) output; (+) input;          */
       IGRlong  *returnmsg;     /* (-) return information code                */
       IGRlong   scaleflag;     /* (+) flag specifying what kind of scaling   */
                                /*     (if any) is applied to values returned */
       IGRlong   eventmask;     /* (+) mask indicating types of event wanted  */
       IGRlong   EventSize;     /* (+) size of memory allocated for event     */
       IGRchar  *Prompt;        /* (+) Prompt issued before waiting for input */
       IGRlong   MsgNumber;     /* (+) if Prompt not specified, this is index */
                                /*     in the message subsystem               */
       IGRchar  *MsgName;       /* (+) name of message used as a prompt       */
       IGRchar  *ValueType;     /* (+) value type identifier string           */
       IGRlong   Mode;          /* (+) mode for getting keyboard input        */
       IGRint   *nbytes;        /* (-) nbr of bytes returned in response_data */
       IGRint   *response;      /* (-) response type from Exec's WFI          */
       IGRchar  *response_data; /* (-) response data from Exec's WFI          */
struct GRevent  *Event;         /* (-) returned event                         */

{
    /* 
     *  Flags
     */
    IGRboolean 
        FromWFI = FALSE,          /* TRUE if input came directly from WFI    */
        PromptIssued = FALSE,     /* TRUE if a prompt was issued             */
        FromVSD = TRUE,           /* TRUE iff mask permits args in ascii     */
                                  /*   format and VSD is not empty           */
        HaveEvent = FALSE,        /* When TRUE, this means event satisfying  */
                                  /* eventmask has been found                */
        IsQuoted = FALSE,         /* TRUE if arg from vsd is quoted          */
        ArgFromPreviousCall = TRUE; /* Is GRm_STRING input from this or a    */
                                    /*  previous call to COgetevent          */
    IGRlong  
       ReturnStatus = MSSUCC,     /* message code returned by COgetevent     */
       LocalStatus  = MSSUCC,     /* msg code returned by functions called   */
       LocalMsg     = MSSUCC,     /* msg code returned by functions called   */
       VSD_StartOnEntry = 0,      /* saves entry value of the vsd start ptr  */
       BytesReturned;             /* # bytes returned from gr$get_last_point */

    IGRint
       BufferSize,
       ArgumentLength;

    IGRchar 
       Argument[MAX_BUF_SIZE],       /* verbatim argument from VSD         */
       Expression[MAX_BUF_SIZE],     /* result of co$epp on Argument       */
       VariablePrefix = '$';         /* some day this will be configurable */

    struct GRIOvar_def  
       Variable;               /* place to put contents of variables */

   IGRboolean 
       software_queue_event = FALSE;
   
   extern int GRrap_and_jnl_append();

    /* EV - end variable declarations */

    _m_debug_str( "> COgetevent:\n" ); 

    /* 
     *  Initialization of variables
     */
    *returnmsg  = MSSUCC;
    
    /*
     *  Event->subtype is set assuming regular data point or value; it will
     *  be overriden if event is software generated
     */
    Event->subtype = GRst_REGULAR;

    /* 01/19/89 - if small little events are received */
    Event->num_id  = 0;
    Event->num_val = 0; 

    /*
     * Determine source of event: VSD or WFI
     */
  
    if (( _not_command_line_arg( eventmask ) || ( Mode == EX_ALL_CHAR_MODE )))
    {
       FromVSD = FALSE;
       CLEAR_VSD;  /* ... since what we want cannot be supplied from vsd */
    }
    else if ( VSD_EMPTY ) 
    {
       /*
        * Argument can be in ascii format but vsd is empty
        */
       FromVSD = FALSE;
       CLEAR_VSD;  /* reset it */
    }
    else 
    {
       /*
        *  Argument can be in ascii format and vsd is NOT empty 
        */
       FromVSD = TRUE;

       /*
        *  The getevent filter simulates a call to ex$wait_for_input 
        *  in this situation so it has to return meaningful values for
        *  response, response_data, and nbytes.
        */
       *response = EX_STRING;   /* whatever we get is in ascii string format */
       response_data[0] = NULL; /* initialize                                */
       _set_nbytes( nbytes, 1); /* initialize                                */

       /*
        *  The vsd.start pointer must be saved in case the event mask contains 
        *  GRm_STRING and one of the following: GRm_VALUE, GRm_TEXT_VALUE, 
        *  GRm_DATA. This is because we will have to reset the VSD to its
        *  original state before we handle the case of GRm_STRING, which 
        *  requires that the entire VSD contents be retrieved.
        */
        VSD_StartOnEntry = vsd.start;

    }
 
    /*
     *  Now we get the event either from the VSD or WFI, depending on the 
     *  results of the above checks
     */
    if ( !FromVSD )
    {
       /* 
        *  Conditional Prompting:  prompt only when the VSD and software
        *  queue are empty
        */
       if ( WeMustPrompt )
       {
          if ( MsgNumber != GRIO_NO_MSG )
          {
             /* then use MsgNumber to get Prompt */
             ex$message( msgnumb = MsgNumber,
                         field   = PROMPT_FIELD,
                         justification = RIGHT_JUS );
          }
          else if ( Prompt != NULL ) /* use specified literal Prompt */
          {
             ex$message( msgname = NULL,
                         in_buff = Prompt,
                         field   = PROMPT_FIELD,
                         justification = RIGHT_JUS );
          }
          else /* MsgName != NULL ( see WeMustPrompt #define above ) */
          {
             ex$message( msgname = MsgName,
                         field   = PROMPT_FIELD,
                         justification = RIGHT_JUS );
          }

          PromptIssued = TRUE; /* flag for clearing prompt on exit */
       }

       /*
        * If we are looking for a data point and no input is pending, then
        * we must call the Smart Sketch as well.  Note, ss$is_active() may
        * seem redundant (because SSDynamics() will not engage if Smart 
        * Sketch is not active), but here it prevents all the DPB work as well.
        * (9/03/93 srh)
        */
       if (   (eventmask & GRm_DATA ) 
           && (queue_empty) 
           && VSD_EMPTY 
           && ss$is_active() )
       {
         IGRboolean dyn_on,
                    turn_dyn_on = 1;

         /*
          * Override the dpdynamics lock for Smart Sketch.  
          * WARNING! Don't try this at home!  SRH 9/6/93.
          */
         LocalStatus = gr$get_dynamics_on( buffer = &dyn_on );
         if (!dyn_on && (LocalStatus&1))
         {
           LocalStatus = gr$put_dynamics_on( buffer = &turn_dyn_on );
         }
         
         SSDynamics ();  // Smart Sketch in action

         if (!dyn_on && (LocalStatus&1))
         {
           /* reset to original condition */
           LocalStatus = gr$put_dynamics_on( buffer = &dyn_on );
         }
       }

       software_queue_event = ex$peek_event_queue();
       
       ex$wait_for_input( response =  response,
                          buffer   =  response_data,
                          mode     =  Mode,
                          byte     = &Event->nbytes );

       _set_nbytes( nbytes, Event->nbytes );

       FromWFI = TRUE;  /* signifies that a call to WFI was made this pass */

       DPerasecross(&LocalMsg); 
       /**** msg is not set by DPerasecross so don't check it ****/
       if ( ( _command_line_arg( eventmask ) && ( *response == EX_STRING ) ) )
       {
 
          _load_vsd( Event->nbytes, 
                     response_data,
                     BufferSize );

          ArgFromPreviousCall = FALSE;
          VSD_StartOnEntry    = vsd.start;
          FromVSD             = TRUE;
       }
    }

    /*
     *  Get argument from VSD if that is the argument source;
     *  If the argument is a NULL string, flag the event as a default.
     *  Otherwise,  expand string variables in Argument using co$epp 
     *  ( expression preprocessor ) and put the results in Expression.
     */
    if ( FromVSD )
    {
       _get_arg_from_vsd( MAX_BUF_SIZE,
                          Argument,
                          ArgumentLength,
                          IsQuoted ); 

       /* only set nbytes this way if vsd contained info on entry */
       if ( ! FromWFI ) _set_nbytes( nbytes, ArgumentLength );

       if ( ArgumentLength == 1 )    /* length includes terminal NULL */
       { 
          Event->subtype = GRst_DEFAULT;
          Event->nbytes =  1;

          Expression[0] = NULL;
       }
       else if ( IsQuoted )
       {
          strncpy( Expression, Argument, MAX_BUF_SIZE );
       }
       else /* not default, expand string variables to build expression */
       {
          /*
           * put Argument through the expression preprocessor to expand
           * string variables.
           */
          Argument[ArgumentLength-1] = NULL;  /* assure null termination */

          LocalStatus = co$epp( msg     = &LocalMsg, 
                                string  =  Argument,
                                sizebuf =  MAX_BUF_SIZE,
                                buffer  =  Expression );

       }
    }

    /*
     *  response types handled:
     *
     *     RESET
     *     EX_CHAR 
     *     EX_DATA 
     *     EX_RJT_MOVEON
     *     EX_STRING
     *     EX_VALUE
     *     EX_OBJID
     *     EX_RESTART
     *     EX_BACK_UP
     *     EX_FORM_FINISHED
     *
     *  any other response type will cause the Event->response to be
     *  GR_UNKNOWN_TYPE
     */
    switch ( *response )
    {
       case EX_CMD_KEY:
          Event->response = GR_UNKNOWN_TYPE;
 
          if( eventmask & GRm_STATUS_DISP && 
              strcmp( response_data, "GRStFr" ) == 0 )
             Event->response = STATUS_DISP;
          break; 
       
      case  EX_CHAR : 

         if ( eventmask & GRm_CHAR )
         {
            Event->response = EX_CHAR;
            memcpy( Event->event.keyin, response_data, Event->nbytes );
         }
         else
         {
            Event->response = GR_UNKNOWN_TYPE;
         }
            
         break;

 
      case  MOVE_ON :  /* obsolete but still supported */

         /* 
          *  if GRm_MOVE_ON is in the event mask, return an event 
          *  response of MOVE_ON; otherwise, we want it flagged for
          *   return to super_command;
          */
         Event->response = 
            ( eventmask & GRm_MOVE_ON ) ? MOVE_ON : GR_UNKNOWN_TYPE;

         /* break statement omitted on purpose */

      case  EX_RJT_MOVEON : /* same as the old RESET */

         /* 
          *  If GRm_RJT_MOVEON is in the event mask, then return an 
          *  event response of EX_RJT_MOVEON; otherwise, we want it 
          *  flagged for return to super_command;
          */
         if (*response == EX_RJT_MOVEON)
          Event->response = 
             ( eventmask & GRm_RJT_MOVEON ) ? EX_RJT_MOVEON : GR_UNKNOWN_TYPE;

         /*
          * 02/01/92 : rlw
          *
          * Modified to copy over response_data in case (and there is now)
          * some data associated with the reset.
          */
         BufferSize = MIN((EventSize - 2 * sizeof(IGRlong)),Event->nbytes);
         Event->nbytes = BufferSize;
         memcpy( &Event->event.button, response_data, BufferSize );

         *returnmsg  = MSSUCC;
         ReturnStatus = MSSUCC;

         break;


      case  EX_RESTART : 

         /* 
          *  if GRm_RESTART is in the event mask, return an event response 
          *  of EX_RESTART; otherwise, we want it flagged for return to 
          *  super_command;
          */
         Event->response = 
            ( eventmask & GRm_RESTART ) ? EX_RESTART : GR_UNKNOWN_TYPE;

         *returnmsg  = MSSUCC;
         ReturnStatus = MSSUCC;

         break;


      case  EX_BACK_UP :

         /* 
          *  if GRm_BACK_UP is in the event mask, return an event response 
          *  of EX_BACK_UP; otherwise, we want it flagged for return to 
          *  super_command;
          */
         Event->response = 
            ( eventmask & GRm_BACK_UP ) ? EX_BACK_UP : GR_UNKNOWN_TYPE;

         *returnmsg  = MSSUCC;
         ReturnStatus = MSSUCC;

         break;


      case  EX_OBJID :

         /* 
          *  If GRm_OBJID is in the event mask, return an event response 
          *  of EX_OBJID and copy response_data into the event structure.
          *  It is assumed that the response_data is in the GRevent format
          *  ( from union field down )
          */

         if ( eventmask & GRm_OBJID )
         {

            Event->response =  EX_OBJID;

            if ( EventSize < Event->nbytes )
            {
               *returnmsg  = GRw_ev_trunc;
            }

            /*
             *  Set up info for specified object event
             */
            BufferSize = MIN((EventSize - 2 * sizeof(IGRlong)),Event->nbytes);
            Event->nbytes = BufferSize;
            memcpy( &Event->event.button, response_data, BufferSize );
         }
         else
         {
            Event->response = GR_UNKNOWN_TYPE;
         }

         *returnmsg  = MSSUCC;
         ReturnStatus = MSSUCC;

         break;


      case  EX_DATA :

         /* 
          *  if GRm_DATA is in the event mask, return an event response 
          *  of EX_DATA; otherwise, we flag it as unknown
          */
         if ( eventmask & GRm_DATA )
         {
            Event->response = EX_DATA;
            if ( EventSize < Event->nbytes )
            {
               *returnmsg  = GRw_ev_trunc;
            }

            /*
             *  build data event
             */
            BufferSize = MIN((EventSize - 2 * sizeof(IGRlong)),Event->nbytes);
            Event->nbytes = BufferSize;
            memcpy( &Event->event.button, response_data, BufferSize );

	    /*
	     * We do not want to alter the Event if it was generated by 
	     * an event generator command.  Otherwise, journalling fails
	     * in a big way.  SRH 2/12/94
	     */
            if ( ss$is_active() && Event->subtype == GRst_REGULAR)
            {
              int response_data_size;
              extern int JNL_playback();

              /*
               * Check with the smart sketch if we locked onto something
               */
              SSCheckEvent ( Event );
              /*
               * retract the last RAP and replace it with the new (possibly altered) Event.
               * Also append a smart sketch entry to the journal log.
               */
              response_data_size = sizeof(struct GRevent) - 2*sizeof(IGRlong);
              LocalStatus = GRrap_and_jnl_append( 1,
                                                  response, 
                                                  &Event->event.button, 
                                                  &response_data_size );
              if (JNL_playback() && !software_queue_event)
              {
                 char   string[JNL_MAX_CHAR], identifier[JNL_MAX_CHAR];
                 int    event, type, num_bytes, *xyz_int;
                 double xyz[3];
                 extern int JNL_adjust_echo();
#if defined (X11)
                 XEvent xevent;
#endif          

#if defined (ENV5)
                 JNL_echo_input(4, (char *)&event);
                 JNL_echo_input(4, (char *)&type);
                 JNL_echo_input(4, (char *)&num_bytes);
                 if (!((event == JNL_INFO_EVENT) && (type == JNL_CHAR)))
                 {
                   fprintf(stderr, "journaling mismatch %d %d\n", event, type);
                   *returnmsg = MSFAIL;
                   ReturnStatus = MSFAIL;
                   return( ReturnStatus );
                 }
#elif defined (X11)
                 JNL_echo_input (sizeof(XEvent), (char *)&xevent );
                 event = xevent.type;
                 type = xevent.xkey.serial;
                 num_bytes = xevent.xbutton.x;
                 if (!((event == JNL_INFO_EVENT) && (type == JNL_WINDOW_CHANGE)))
                 {
                   fprintf(stderr, "journaling mismatch, event = %d type = %d\n", event, type);
                   *returnmsg = MSFAIL;
                   ReturnStatus = MSFAIL;
                   return( ReturnStatus );
                 }
#endif
                 JNL_echo_input(num_bytes, (char *)string);
                 sscanf(string, "%s", identifier);
                 
                 if (strcmp("SSpoint", identifier))
                 {
                   fprintf(stderr, "journaling mismatch, string = %s\n", string);
                   *returnmsg = MSFAIL;
                   ReturnStatus = MSFAIL;
                   return( ReturnStatus );
                 }

                 xyz_int = (int *) &xyz[0];
                 sscanf(string, "%s %x %x %x %x %x %x", identifier,
                        &xyz_int[0], &xyz_int[1], &xyz_int[2],
                        &xyz_int[3], &xyz_int[4], &xyz_int[5]);
                 
                 /*
                  * Update the event world coordinates.
                  */
                 Event->event.button.x = xyz[0];
                 Event->event.button.y = xyz[1];
                 Event->event.button.z = xyz[2];
              }
            }
            /*
             *  update last point in dpb
             */
            BufferSize = sizeof( struct EX_button );
            gr$put_last_point( msg    = &LocalMsg,
                               sizbuf = &BufferSize,
                               buffer = (char *) &Event->event.button );
            /* 
             * Update the Current Point Form
             */
            LocalStatus = co$update_current_point_form( msg = &LocalMsg );
         }
         else
         {
            Event->response = GR_UNKNOWN_TYPE;
         }

         *returnmsg  = MSSUCC;
         ReturnStatus = MSSUCC;

         break;


      case  EX_VALUE :

         /* 
          *  if GRm_VALUE is in the event mask,  return an event response 
          *  of EX_VALUE; otherwise, we want it flagged as unknown
          */
         if ( eventmask & GRm_VALUE )
         {
            if ( EventSize < Event->nbytes )
            {
               *returnmsg  = GRw_ev_trunc;
            }
            /*
             *  build value event
             */
            Event->response = EX_VALUE;  /* probably unnecessary */
            BufferSize = 
               MIN( ( EventSize -2 * sizeof(IGRlong) ), Event->nbytes );
            Event->nbytes = BufferSize;
            memcpy( &Event->event.value, response_data, BufferSize );
         }
         else
         {
            Event->response = GR_UNKNOWN_TYPE;
         }

         *returnmsg  = MSSUCC;
         ReturnStatus = MSSUCC;

         break;


      case  EX_STRING :   /* lots of room for interpretation here!!!  */

         /*
          *  An ascii string is in the VSD now; the masks that we are 
          *  concerned with are:
          *
          *         GRm_DATA     ( highest precedence )
          *         GRm_VALUE
          *         GRm_STRING 
          *     and GRm_TEXT_VAL ( lowest precedence )
          *
          *   GRm_STRING and GRm_TEXT_VALUE should never be in the same event
          *   mask.  If they are, GRm_STRING will have override GRm_TEXT_VALUE.
          */

         /*
          *  --------------------------------------------------------------
          *     Case #1 - see if Argument is a POINT variable 
          *  --------------------------------------------------------------
          */
         if (    ( eventmask & GRm_DATA )
              && ( Argument[0] == VariablePrefix )
              && ( ! IsQuoted ) )
         {
            OMuword   ModuleOsnum;  /* object space where variable is stored */

            /* 
             *  Check to see if Argument is a variable of type GRIO_VAR_POINT
             */
            ex$get_cur_mod( osnum = &ModuleOsnum );

            LocalStatus = co$cvtvar( msg   = &LocalMsg,
                                     alias = &Argument[1], /* ignore prefix */
                                     osnum =  ModuleOsnum,
                                     var   = &Variable );

            if ( LocalMsg & 1 ) /* if convertion was successfull */
            {
               if ( Variable.type & GRIO_VAR_POINT ) 
               {
                  HaveEvent = TRUE;
                  Event->response = EX_DATA;

                  BufferSize = sizeof( struct EX_button );
                  gr$get_last_point( msg    = &LocalMsg,
                                     sizbuf = &BufferSize,
                                     buffer = &Event->event.button,
                                     nret   = &BytesReturned );
                  /*
                   *  override last point coordinates with those of the variable
                   */
                  Event->event.button.x =  Variable.contents.point[0];
                  Event->event.button.y =  Variable.contents.point[1];
                  Event->event.button.z =  Variable.contents.point[2];

                  /*
                   *  update DPB's Last Point with new coordiantes
                   */
                  gr$put_last_point( msg    = &LocalMsg,
                                     sizbuf = &BufferSize,
                                     buffer = &Event->event.button );

                  Event->nbytes = BufferSize;
                  if ( EventSize < Event->nbytes )
                  {
                     *returnmsg  = GRw_ev_trunc;
                  }

                  /* 
                   * Update the Current Point Form
                   */
                  LocalStatus = co$update_current_point_form( msg = &LocalMsg );
               }
            }
            else
            {
               *returnmsg = LocalMsg;
            }
         }

         if (    ( eventmask & GRm_VALUE )
              && ( ! HaveEvent )
              && ( ! IsQuoted ) )
         {

            /* 
             * get expression to be evaluated from VSD
             */

            if ( Event->subtype == GRst_DEFAULT )
            { 
               *returnmsg  = GRw_no_value;
               Event->response = EX_VALUE;
               *response = EX_VALUE;            /* TR#1190194 */
               Event->event.value = 0.0;
               Event->nbytes = sizeof( IGRdouble);
               HaveEvent = TRUE;
            }
            else  /* use Expression ( from co$epp ) to get the value */
            {
               /*
                * evalutate expression and put result in event value field
                */
               LocalStatus = co$expreval( 
                                 scale_flag   =  scaleflag,
                                 msg          = &LocalMsg, 
                                 expression   =  Expression,
                                 unit_type    =  ValueType,
                                 result       = &Event->event.value );

               if ( COERROR(LocalStatus) )
               {
                  /*
                   * We return the string that failed the evaluation so 
                   * that it may be passed back to the command server    
                   */

                  switch ( LocalMsg )
                  {
                     case MSFAIL :
                        *returnmsg = MSFAIL;
                        ReturnStatus = MSFAIL;
                        break;
   
                     case CO_e_syntax :
                        *returnmsg = CO_e_syntax;
                        break;
   
                     default :
                        *returnmsg = LocalMsg;
                        break;

                  } /* end switch ( LocalMsg ) */

                  Event->response = GR_UNKNOWN_TYPE;
                  Event->event.value = 0.0;
                  ReturnStatus = MSSUCC;
               }
               else
               {
                  /* 
                   *  We have found an event satisfying the eventmask 
                   */
                  HaveEvent = TRUE;
                  Event->nbytes = sizeof( IGRdouble);
                  Event->response = EX_VALUE;
                  *response = EX_VALUE;         /* TR#1190194 */
               }
            }
            /*
             *  in case command returns to command server, set response type
             *  to EX_STRING
             */
         }

         
         if ( ! HaveEvent ) 
         {
            if ( eventmask & GRm_STRING )
            {
               /* 
                *  In this case we want everything in the VSD from start
                *  to end! including any commas;  since we may have already
                *  gotten an argument from the VSD, we reset the start pointer
                *  before we get its contents.
                */
               vsd.start = VSD_StartOnEntry;

               /*
                *  Copy rest of vsd into the event keyin buffer and clear vsd;
                *  Reset the vsd to its original value if a value
                */
               _get_rest_of_vsd( GR_MAX_CHAR,
                                 Event->event.keyin,
                                 Event->nbytes );
   
               if ( Event->nbytes == 1 ) 
               { 
                  Event->subtype = GRst_DEFAULT;
                  *returnmsg = GRw_no_value;
               }
               else
               {
                  *returnmsg = MSSUCC;
               }

               if ( ArgFromPreviousCall )
               {
                  /* setup response as if from wfi */
                  memcpy( response_data, Event->event.keyin, Event->nbytes );
                  _set_nbytes( nbytes, Event->nbytes );
               }

               Event->response = EX_STRING;
               CLEAR_VSD; 
            }
            else if  ( eventmask & GRm_TEXT_VALUE )
            {
               /*
                *  Copy the Expression ( from co$epp ) into the event keyin 
                *  buffer and clear vsd;
                */
               strncpy( Event->event.keyin, Expression, MAX_BUF_SIZE );

               if ( Event->nbytes == 1 ) 
               { 
                  *returnmsg  = GRw_no_value;
                  Event->subtype = GRst_DEFAULT;
               }
               else
               {
                  *returnmsg  = MSSUCC;
               }
               Event->response = EX_STRING;
               *response = EX_STRING;
            }
            else 
            {
               /*
                *  At this point we know that the user's input did not satisfy
                *  the eventmask.  We thus return an Event->response of
                *  GR_UNKNOWN_TYPE.  Since we have to return to the caller
                *  response_data which is meaningfull, we reset the VSD to
                *  its original state and copy its contents into the 
                *  response_data buffer before exit.  This allows the command 
                *  strings to be returned in total for execution by the 
                *  command server.
                *
                *  Note: we only want to reload response data here if
                *  there is something in the vsd; this check was added 
                *  in version 1.2.0 of I/Draft (srh)
                */
               
               if( VSD_NOT_EMPTY )
               {
                  vsd.start = VSD_StartOnEntry;

                  _get_rest_of_vsd( EX_RESPONSE_DATA_SIZE,
                                    response_data, 
                                    BufferSize );

                  CLEAR_VSD;
               }

               Event->response = GR_UNKNOWN_TYPE;
               *returnmsg  = MSSUCC;
            }
         }

         ReturnStatus = MSSUCC;
         break;


      case  EX_FORM_FINISHED :

         /* 
          *  If GRm_FORM_FINISHED is in the event mask, then return an 
          *  event response of EX_FORM_FINISHED; otherwise, we want it 
          *  flagged for return to super_command;
          */
         Event->response = 
           (eventmask & GRm_FORM_FINISHED) ? EX_FORM_FINISHED : GR_UNKNOWN_TYPE;

         *returnmsg  = MSSUCC;
         ReturnStatus = MSSUCC;

         break;

      default: /* all the cases we automatically return to command server */

         Event->response = GR_UNKNOWN_TYPE;

         *returnmsg  = MSSUCC;
         ReturnStatus = MSSUCC;

         break;

   } /* end  switch ( *response ) */

    /* clear prompt of successful exit if prompt was issued */
    if (   ( ReturnStatus & 1 )  
        && PromptIssued  
        && ( *response != EX_CHAR ) ) 
    {
       ex$message( msgname = NULL,
                   in_buff = "",
                   field   = PROMPT_FIELD );
    }

    _m_debug_str( "< COgetevent:\n" ); 
    return( ReturnStatus );

} /* end COgetevent */


/*
 * ------------------------------------------------------------------------
 *  Functions used to query and clear contents of VSD; These functions 
 *  provide the only means of accessing the VSD outside the realm of
 *  the co$getevent() filter.
 * ------------------------------------------------------------------------
 */
IGRboolean COvsd_empty()
{
   return ( vsd.start >= vsd.end_ptr );
}

void COclear_vsd()
{
   vsd.start = vsd.end_ptr = 0;
}

