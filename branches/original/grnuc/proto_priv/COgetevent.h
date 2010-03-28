#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/grio/getevent/COgetevent.C */
extern IGRlong COgetevent __((IGRlong *ReturnMsg, IGRlong ScaleFlag, IGRlong EventMask, IGRlong EventSize, IGRchar *Prompt, IGRlong MsgNumber, IGRchar *MsgName, IGRchar *ValueType, IGRlong Mode, IGRint *nbytes, IGRlong *response, IGRchar *response_data, struct GRevent *Event));
extern IGRboolean COvsd_empty __((void));
extern void COclear_vsd __((void));

#if defined(__cplusplus)
}
#endif


#undef __
