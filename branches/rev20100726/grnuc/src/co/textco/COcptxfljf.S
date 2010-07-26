class specification COcptxfljf (1:0) of CEO_LOCATE;



/******************************************************************************

Description:

    This command copies an existing text element, reformats the text string
so that its lines are of a user specified length, and repositions the text
string to a user specified position.

Abstract class:      No.

Override methods:    None.

Messages:

    message place_empty_text();

History:  Bill Cecil     07/24/89  Design and Implementation

Algorithm:

Notes:

******************************************************************************/


instance COcptxfljf
{
    struct  GRid        text_grid;
    struct  GRmd_env    module_info;
    IGRpoint            first_point;
    IGRdouble           distance;      /* distance between the two points */
    IGRint              autowrap;      /* TRUE if autowrap is on          */
};


message set_autowrap (int autowrap);

message erase_highlight ();

message get_text ();

message save_left_margin ();

message find_distance ();

message place_text ();

end specification COcptxfljf;
