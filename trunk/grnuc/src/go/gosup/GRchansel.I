/*
Name
        GRchansel - get channel selectors

Synopsis
        OM_p_CHANSELECT GRget_"class"_"channel"(OM_p_CHANSELECT p_chan)

        ()              Each function returns a pointer to a static channel
                        selector stored here.
        
        p_chan          If not NULL, each function will fill in *p_chan with
                        the appropriate channel selector.

Description
        This file contains functions used to minimize the making of channel
        selectors.

        A macro is defined up front to simplify all the functions below.  It
        is essentially the entire body of the function.  Each function gets a
        static copy of a chanselect and a pointer to the chanselect.  That
        chanselect gets initialized to the channel name specified the first
        time the function is called.

        Adding new retrieval functions should be simple.  Just copy one of the
        other functions and change the class & channel names in the function
        name and the macro call.

History
        mrm     07/21/93        creation
*/

class implementation Root;

#define get_chanselect(name)                                    \
    static OM_S_CHANSELECT chan_local;                          \
    static OM_p_CHANSELECT p_chan_local = NULL;                 \
                                                                \
    if (p_chan_local == NULL)                                   \
    {                                                           \
        p_chan_local = &chan_local;                             \
        om$make_chanselect(channame = name,                     \
                           p_chanselect = p_chan_local);        \
    }                                                           \
                                                                \
    if (p_chan)                                                 \
        *p_chan = *p_chan_local;                                \
                                                                \
    return(p_chan_local);
        

OM_p_CHANSELECT GRget_GRreffile_to_mgr(OM_p_CHANSELECT p_chan)
{
    get_chanselect("GRreffile.to_mgr");
}

OM_p_CHANSELECT GRget_GRreffile_to_clone(OM_p_CHANSELECT p_chan)
{
    get_chanselect("GRreffile.to_clone");
}

OM_p_CHANSELECT GRget_GRreffile_to_clip(OM_p_CHANSELECT p_chan)
{
    get_chanselect("GRreffile.to_clip");
}

OM_p_CHANSELECT GRget_GRreffile_to_context(OM_p_CHANSELECT p_chan)
{
    get_chanselect("GRreffile.to_context");
}

OM_p_CHANSELECT GRget_GRcontext_to_super(OM_p_CHANSELECT p_chan)
{
    get_chanselect("GRcontext.to_super");
}

OM_p_CHANSELECT GRget_GRcontext_to_reffile(OM_p_CHANSELECT p_chan)
{
    get_chanselect("GRcontext.to_reffile");
}

OM_p_CHANSELECT GRget_GRcontext_to_misc(OM_p_CHANSELECT p_chan)
{
    get_chanselect("GRcontext.to_misc");
}

OM_p_CHANSELECT GRget_GRcontext_to_nested_files(OM_p_CHANSELECT p_chan)
{
    get_chanselect("GRcontext.to_nested_files");
}

OM_p_CHANSELECT GRget_GRclippoly_to_attachment(OM_p_CHANSELECT p_chan)
{
    get_chanselect("GRclippoly.to_attachment");
}

OM_p_CHANSELECT GRget_Super_rfmgr_mgr(OM_p_CHANSELECT p_chan)
{
    get_chanselect("Super_rfmgr.mgr");
}

OM_p_CHANSELECT GRget_Super_rfmgr_to_context(OM_p_CHANSELECT p_chan)
{
    get_chanselect("Super_rfmgr.to_context");
}

end implementation Root;
