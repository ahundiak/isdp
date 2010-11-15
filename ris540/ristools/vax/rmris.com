$ ! Do not alter this line: $Revision: 1.1.54.1 $
$ set noon
$ del [.bin]*.*;*
$ del [.build]*.*;*
$ del [.arch.prototype]*.*;*
$ set prot=(w:d) [.arch]*.dir
$ del [.arch]*.*;*
$ del [.common.prototype]*.*;*
$ set prot=(w:d) [.common]*.dir
$ del [.common]*.*;*
$ del [.dd.oradir]*.*;*
$ del [.dd.igsdir]*.*;*
$ del [.dd.rdbdir]*.*;*
$ del [.dd.prototype]*.*;*
$ set prot=(w:d) [.dd]*.dir
$ del [.dd]*.*;*
$ del [.dbms.oradir]*.*;*
$ del [.dbms.igsdir]*.*;*
$ del [.dbms.rdbdir]*.*;*
$ del [.dbms.prototype]*.*;*
$ set prot=(w:d) [.dbms]*.dir
$ del [.dbms]*.*;*
$ del [.include]*.*;*
$ del [.internal]*.*;*
$ del [.lib]*.*;*
$ del [.misc.prototype]*.*;*
$ set prot=(w:d) [.misc]*.dir
$ del [.misc]*.*;*
$ del [.network.prototype]*.*;*
$ set prot=(w:d) [.network]*.dir
$ del [.network]*.*;*
$ del [.remote.prototype]*.*;*
$ set prot=(w:d) [.remote]*.dir
$ del [.remote]*.*;*
$ del [.server.prototype]*.*;*
$ set prot=(w:d) [.server]*.dir
$ del [.server]*.*;*
$ del [.shipigs]*.*;*
$ del [.shipora]*.*;*
$ del [.shiprdb]*.*;*
$ del [.kit]*.*;*
$ set prot=(w:d) *.dir;*
$ del *.*;*
$ junk = 'f$locate("]",f$directory())
$ temp := 'f$extract(0,junk,f$directory())
$ junk = 'f$locate(".",temp)
$ temp := 'f$extract(junk+1,20,temp)'.dir
$ set def [.-]
$ set prot=(w:d) 'temp'
$ del 'temp';*
$ set on
