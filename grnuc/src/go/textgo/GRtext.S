/*----
%GP%  CODE CLASSIFICATION                           
----
%HD%

      CLASS NAME:  GRtext
      SUBCLASS OF: GRlbsys

-----
%CD%

      CHANNELS DECLARED:        
-----
%MD%

      MESSAGES DECLARED:   GRtext_edit

      METHODS OVERRIDDEN:  GRclip
                           GRdisyourself
                           GRlocate
                           GRkeypoint

-----
%NB%

      NOTES:
-----
%CH%

      CHANGE HISTORY:
        
        DEK/WBC     3/25/86:   Creation date.
        SCW        05/08/92:   ANSI conversion
-----
%PD%
--------------------------------------------------------------------
                 C L A S S    D E S C R I P T I O N
--------------------------------------------------------------------

        The class GRtext is the subclass of GRlbsys which
defines the text specific attributes of the 2d, 3d, and 3i text
objexts.
----*/
/*EH*/

class specification GRtext (1:0) of GRlbsys;

/* 
 * Instance data defined for the GRtext subclass:
 */

instance GRtext                               /* Text specific data      */
{
    struct IGRestx attr;                      /* Text specific structure */
    variable IGRuchar text_string[];          /* Text string             */
};

/* 
 * Method declarations for the GRtext subclass.
 */


/*
Abstract
     This method changes one or more of the text object's attributes
     (font, justification, line spacing, character spacing, height, width)
     and posts the abstract geometry of the object.  This will update the
     range in the R-tree (unless tne module environments object id is
     equal to NULL_OBJID).

Arguments

        NAME       DATA TYPE               DESCRIPTION
     ----------   ------------   ------------------------------------

INPUT

     *module_env  struct GRmd_env module environment information
     attr         IGRuint bitmask indicating attribute(s) to
                                  change; #defines for this bitmask
                                  are defined in gotextdef.h
     *text_symb   struct GRdpb_text_symb text symbology structure
                                         containing attributes to

OUTPUT

     *msg           IGRlong         completion code
                                      MSSUCC - successful completion
*/

message GRchgtextattr(IGRlong *msg; struct GRmd_env *module_env;
                      IGRuint attr; struct GRdpb_text_symb *text_symb);

/*
Abstract
     This method justifies a text string and returns the updated
     extents of the text string.  The text string and text length
     (of the text object) may be changed.  The number of displayable
     characters is also updated.


Arguments

        NAME       DATA TYPE               DESCRIPTION
    ------------  ------------   ------------------------------------

INPUT

    *text_symb    struct GRdpb_text_symb     text symbology
    *font_info    struct vfont_entry         font information
    num_positions IGRint                     # of positions to update
    *positions[]  IGRshort                   positions in the text
                                             string to update (NULL
                                             pointer if num_positions
                                             == 0)

OUTPUT

    *msg          IGRlong           completion code
                                      MSSUCC - successful completion
                                      MSFAIL - failure
    *positions[]  IGRshort                   updated positions in
                                             the text string
    *text_extents struct extents             updated extents of the
                                             text object
*/

message GRchgtxstring(IGRlong *msg; struct GRdpb_text_symb *text_symb; 
                      struct vfont_entry *font_info; IGRint num_positions;
                      IGRshort *positions[]; struct extents *text_extents);

/*
Abstract
     This method returns the requested text information:  the text
     specific attributes, the text length (in bytes) and the text
     string.


Arguments

        NAME       DATA TYPE               DESCRIPTION
      -----------  ------------   ------------------------------------

INPUT

OUTPUT

     *msg          IGRlong        completion code
                                    MSSUCC - successful completion
                                    MSFAIL - couldn't allocate memory
     *text_attr    struct IGRestx text specific information; if a
                                  NULL pointer is sent the structure
                                  is not returned
     *text_length  IGRshort       text string length (in bytes); if
                                  a NULL pointer is sent the length
                                  is not returned
     **text_string IGRuchar       text string; if a NULL pointer is
                                    sent the string is not returned

                                    NOTE:  memory for the text string
                                    will be allocated in this method;
                                    the caller is responsible for
                                    deallocating this memory when they
                                    are through with it
*/

message GRgettxattr(IGRlong *msg; struct IGRestx *text_attr;
                    IGRshort *text_length; IGRuchar **text_string);

/*
Abstract
     This implementation file loads the data
     necessary to display a text element.


Arguments

        NAME       DATA TYPE                      DESCRIPTION
     ----------   ------------   ------------------------------------

INPUT

     *matrix_type IGRshort       type of matrix 
     matrix       IGRmatrix      environment transformation matrix

OUTPUT

        NAME       DATA TYPE                      DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg          IGRlong         completion code:
                                     MSSUCC - successful completion
                                     MSFAIL - failure of routine
     *ele_header   struct DPele_header
                                   pointer to structure containing
                                   info. necessary to display the
                                   text element
*/


message GRtxfillbuf(IGRlong *msg; IGRshort *matrix_type; IGRmatrix matrix; 
                    struct DPele_header *ele_header);


/*
Abstract
     This routine accepts a query for information about a
     specified field. A query can be made on any or all of
     the field's data (contents, range, attributes, extents,
     or justification points). If information is not required
     about a particular type of data a NULL pointer must be
     passed in. If the specified field is not found, MSFAIL
     will be returned.


Arguments

        NAME       DATA TYPE                      DESCRIPTION
    ------------  ---------------   ---------------------------------------

INPUT

    *field_num    IGRchar           which field number to use
    *type         IGRshort          type of environment matrix
    matrix        IGRmatrix         environment matrix of text object

OUTPUT

    *msg          IGRlong           completion code
                                      MSSUCC - if successful
                                      MSFAIL - if failure
    *length       IGRshort          length of field
    **contents    IGRuchar          contents of the field
    *attributes   IGRuchar          attributes of the field
    *extents      struct extents    extents of the field
    range         GRrange           range of the field
    just_pts      struct just_pts   justification points of the field
*/

message GRfield_inquire(IGRlong *msg; IGRuchar *field_num;
                        IGRshort *type; IGRmatrix matrix; IGRshort *length;
                        IGRuchar **contents;
                        IGRuchar *attributes; struct extents *extents;
                        GRrange range; struct just_pts *just_pts);

/*
Abstract
     This method will either display an empty text element and set
     its display and locate bits or erase an empty text element
     and clear its display and locate bits.


Arguments

        NAME       DATA TYPE               DESCRIPTION
    ------------  ------------   ------------------------------------

INPUT

    display       IGRboolean     - TRUE if empty text element is to
                                 be displayed and the elements locate
                                 and display bits are to be set;
                                 - FALSE if empty text element is
                                 to be erased and the elements locate
                                 and display bits are to be cleared
    *matrix_type  IGRshort       matrix type
    matrix        IGRmatrix      matrix

OUTPUT

    *msg           IGRlong         completion code
                                     MSSUCC - successful completion
*/

message GRdpemptytext(IGRlong *msg; IGRboolean display; IGRshort *matrix_type;
                      IGRmatrix matrix);

/*
Abstract
     This method replaces a text object's text string with a
     specified text string, updates the justification moves in the
     text string and posts the abstract geometry of the text object.


Arguments

        NAME       DATA TYPE               DESCRIPTION
    ------------  ------------   ------------------------------------

INPUT

     *env         struct GRmd_env environment structure
     text_length  IGRshort        length of text string (in bytes)
     *text_string IGRuchar        replacement text string

OUTPUT

     *msg         IGRlong         completion code
                                    MSSUCC - successful completion
                                    MSFAIL - failure
*/

message GRreplace_text(IGRlong *msg; struct GRmd_env *env;
                       IGRshort text_length;  IGRuchar *text_string);

/*
Abstract
     This method sets or clears the specified bits of the text
     object's flag.


Arguments

        NAME       DATA TYPE              DESCRIPTION
     ----------   ------------   ------------------------------------

INPUT

     set          IGRint         TRUE if the specified bits are to be
                                 set, FALSE if they are to be cleared
     bitmask      IGRshort       bits to be set or cleared

OUTPUT

     *msg         IGRlong        completion code
                                   MSSUCC - successful completion
*/

message GRchange_flag(IGRlong *msg; IGRint set; IGRshort bitmask);


/*
 *  methods to override
 */

override GRdisyourself, GRconstruct, GRgetobjinfo, GRclip, GRcopy, GRchgname,
         GRlocate_processing, DEdisyourself, GRadd_to_display_list,
	 GRanalyze_element;


end specification GRtext;
