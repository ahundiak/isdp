/* ###################   APOGEE COMPILED   ################## */
class implementation EMSloop;

/*
HISTORY

11 Jul 1989 jBk Replaced arguments matrix and matrix_type of
                EMareaDisplay with p_env.
*/

EMSrc EFareasTreeDraw (
    rc,
    p_areasTree,
    p_env,
    mode,
    osnum
)
    EMSrc *rc;
    struct EMStreeHeap *p_areasTree;
    struct GRmd_env *p_env;
    enum GRdpmode mode;
    OMuword osnum;
{
    EMSrc omrc = OM_S_SUCCESS;
    extern EMSrc EFtreeLeftmostNode ();
    struct EMStreeNode *p_node = NULL;
    struct EMStreeHeap *p_area = NULL;

    *rc = EFtreeLeftmostNode (
        p_areasTree,
        &p_node,
        &p_area
    );

    while (*rc IS EMS_I_Found AND EMSokay (omrc))
    {
        EMSrc EFareaDraw ();

        omrc = EFareaDraw (
            rc,
            p_area,
            p_env,
            mode,
            osnum
        );

        if (EMSokay (*rc) AND EMSokay (omrc))
        {
            extern EMSrc EFnodeNextToRight ();

            *rc = EFnodeNextToRight (
                p_node,
                &p_node,
                &p_area
            );
        }        
    }

    return omrc;
}

EMSrc EFareaDraw (
    rc,
    p_area,
    p_env,
    mode,
    osnum
)
    EMSrc *rc;
    struct EMStreeHeap *p_area;
    struct GRmd_env *p_env;
    enum GRdpmode mode;
    OMuword osnum;
{
    EMSrc omrc = OM_S_SUCCESS;
    extern EMSrc EFtreeLeftmostNode ();
    struct EMStreeNode *p_node = NULL;
    OM_S_OBJID loopid;

    *rc = EFtreeLeftmostNode (
        p_area,
        &p_node,
        &loopid
    );

    while (*rc IS EMS_I_Found AND EMSokay (omrc))
    {
        om$send (
            msg = message EMSloop.EMareaDisplay (
                (IGRlong *)rc,
                p_env,
                mode
            ),
            senderid = NULL_OBJID,
            targetid = loopid,
            targetos = osnum
        );

        if (EMSokay (*rc) AND EMSokay (omrc))
        {
            extern EMSrc EFnodeNextToRight ();

            *rc = EFnodeNextToRight (
                p_node,
                &p_node,
                &loopid
            );
        }        
    }

    return omrc;
}

end implementation EMSloop;
