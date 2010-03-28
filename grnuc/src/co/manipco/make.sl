SLIC = slic -p $(GRNUC)/spec

ALL:	SI TFILES

IDRAW:	SI DRAW

SI:	COmanip.S COmanipi.I \
	COchange.S COchangei.I \
	COcpparal.S COcpparali.I

TFILES:	$(GRNUC)/config/commands/GRAlE     \
        $(GRNUC)/config/commands/GRMrEAbVrA    \
        $(GRNUC)/config/commands/GRMrEAbHrA    \
        $(GRNUC)/config/commands/GRMrEAbAx     \
        $(GRNUC)/config/commands/GRMvE      \
        $(GRNUC)/config/commands/GRRtE3Pn    \
        $(GRNUC)/config/commands/GRRtE     \
        $(GRNUC)/config/commands/GRRtEAbAx     \
        $(GRNUC)/config/commands/GRScE3Pn    \
        $(GRNUC)/config/commands/GRScE     \
        $(GRNUC)/config/commands/GRDlE       \
        $(GRNUC)/config/commands/GRUnE     \
        $(GRNUC)/config/commands/GRCSy  \
        $(GRNUC)/config/commands/GRCENm   \
        $(GRNUC)/config/commands/GRTrOfELc  \
        $(GRNUC)/config/commands/GRCpPr

DRAW:	$(GRNUC)/config/commands/GRAlE     \
        $(GRNUC)/config/commands/GRMrEAbVrA    \
        $(GRNUC)/config/commands/GRMrEAbHrA    \
        $(GRNUC)/config/commands/GRMrEAbAx     \
        $(GRNUC)/config/commands/GRMvE      \
        $(GRNUC)/config/commands/GRRtE3Pn    \
        $(GRNUC)/config/commands/GRRtE     \
        $(GRNUC)/config/commands/GRRtEAbAx     \
        $(GRNUC)/config/commands/GRScE     \
        $(GRNUC)/config/commands/GRDlE       \
        $(GRNUC)/config/commands/GRCSy  \
        $(GRNUC)/config/commands/GRCENm   \
        $(GRNUC)/config/commands/GRTrOfELc  \
        $(GRNUC)/config/commands/GRCpPr

COmanip.S COmanipi.I: COmanip.sl
	$(SLIC) $?
	rm -f $(GRNUC)/spec/$@
	ln $@ $(GRNUC)/spec

COchange.S COchangei.I: COchange.sl
	$(SLIC) $?
	rm -f $(GRNUC)/spec/$@
	ln $@ $(GRNUC)/spec

COcpparal.S COcpparali.I: COcpparal.sl
	$(SLIC) $?
	rm -f $(GRNUC)/spec/$@
	ln $@ $(GRNUC)/spec

$(GRNUC)/config/commands/GRAlE: COalign.t
	$(SLIC) $?

$(GRNUC)/config/commands/GRMrEAbVrA: COmirrorv.t
	$(SLIC) $?

$(GRNUC)/config/commands/GRMrEAbHrA: COmirrorh.t
	$(SLIC) $?

$(GRNUC)/config/commands/GRMrEAbAx: COmirrorl.t
	$(SLIC) $?

$(GRNUC)/config/commands/GRMvE: COmove.t
	$(SLIC) $?

$(GRNUC)/config/commands/GRRtE3Pn: COrot3pt.t
	$(SLIC) $?

$(GRNUC)/config/commands/GRRtE: COrotaa.t
	$(SLIC) $?

$(GRNUC)/config/commands/GRRtEAbAx: COrotax.t
	$(SLIC) $?

$(GRNUC)/config/commands/GRScE3Pn: COscale3pt.t
	$(SLIC) $?

$(GRNUC)/config/commands/GRScE: COscaleas.t
	$(SLIC) $?

$(GRNUC)/config/commands/GRDlE: COdelete.t
	$(SLIC) $?

$(GRNUC)/config/commands/GRUnE: COundel.t
	$(SLIC) $?

$(GRNUC)/config/commands/GRCSy: COchattr.t
	$(SLIC) $?

$(GRNUC)/config/commands/GRTrOfELc: COdisloc.t
	$(SLIC) $?

$(GRNUC)/config/commands/GRCENm: COchname.t
	$(SLIC) $?

$(GRNUC)/config/commands/GRCpPr: COcpparal.sl
	$(SLIC) $?
