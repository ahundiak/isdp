class specification EMSvsgd (1:0) of EMSgradata;

instance EMSvsgd
{
    struct GRid     window_id;
};

message EMput_window(IGRlong        *EMmsg;
                     struct GRid    *window_id);
/*
Abstract

    This message is used to store the window information.

Arguments

    window_id - input
        the objid/osnum of the window in which this graphics data
        is to apear.

File

    EMvsgdi.I
*/

override

    /*
        Motivation
            Return a message to put the window information.

            EMvsgdi.I
    */
    EMget_class_info,

    /*
        Motivation
            Do not process unless action is occurring in my
            window.

        File
            EMvsgdi.I
    */
    EMlocate,
    EMkeypoint,
    EMdisplay;

end specification EMSvsgd;
