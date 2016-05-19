000100160518     h dftactgrp(*no) actgrp('QILE') indent(*none)
000200160518
000300160518      * dbgview(*list)
000400160518
000500160518      * Buck Calabro April 2000
000600160518      * large portions lifted from the SEU User's Guide and Reference SC09-2605-00
000700160518      * If you have a really large source file, increase the size of SourceStmt
000800160518      * Note that this is really a boiler-plate more than anything else.
000900160518
001000160518      * To activate, STRSEU, press F13, page down and fill in the name of this program
001100160518
001200160518      * SEU puts data in QTEMP/QSUSPC
001300160518      * this space has 3 data blocks:
001400160518      *   1. Input from SEU
001500160518      *   2. Output back to SEU
001600160518      *   3. Actual source lines
001700160518
001800160518      * Supports the following line commands:
001900160518      * ATTRxx - set line attribute (colour, hilight, etc.)
002000160518
002100160518      * Supports the following F keys:
002200160518      * F7 - Split/join a line (Splits this line to next if cursor in the middle of a line,
002300160518      *                         joins next line to this if cursor at the end of a line)
002400160518
002500160518      * Uses messages in a user-created message file:
002600160518      *   Message ID  Severity  Message Text
002700160518      *    SEU0001        0     Cursor is not positioned within a source statement.
002800160518      *    SEU0002        0     Line split complete.
002900160518      *    SEU0003        0     Line join complete.
003000160518      *    SEU0004        0     Cannot update in Browse mode
003100160518      *    SEU0005        0     ATTR command processed
003200160518      *    SEU0006        0     ATTR command not valid for this member type
003300160518      *    SEU0007        0     &1
003400160518
003500160518      * Input from SEU
003600160518     D SEUInput        DS                  BASED(SEUInputP)
003700160518     D  StmtLength                   10i 0
003800160518     D  CurRec                       10i 0
003900160518     D  CurCol                       10i 0
004000160518     D  CCSID                        10i 0
004100160518     D  InputRecords                 10i 0
004200160518     D  SrcMbr                       10
004300160518     D  SrcFil                       10
004400160518     D  SrcLib                       10
004500160518     D  MbrType                      10
004600160518     D  FnKey                         1
004700160518     D  SEUMode                       1
004800160518     D  SplitSession                  1
004900160518     D  ReservedInp                   1
005000160518
005100160518      * Output to SEU
005200160518     D SEUOutput       DS                  BASED(SEUOutputP)
005300160518     D  ReturnCode                    1
005400160518     D  ReservedOut1                  3
005500160518     D  OutputRecords                10i 0
005600160518     D  InsertedSeq                   7
005700160518     D  ReservedOut2                 21
005800160518
005900160518      * Source statements.  SEU passes the line the cursor is on,
006000160518      *                     and the next line
006100160518     D SEUSource       DS                  BASED(SEUSourceP)
006200160518     D  LineCmd                       7
006300160518     D  LineRetCode                   1
006400160518     D  SourceSeq                     6
006500160518     D  SourceDate                    6
006600160518     D  SourceStmt                  256
006700160518
006800160518      * Work variables
006900160518     D SEUInputPParm   S               *
007000160518     D SEUOutputPParm  S               *
007100160518     D SEUSourcePParm  S               *
007200160518     D ThisLineP       S               *
007300160518     D NextLineP       S               *
007400160518     D WorkLineP       S               *
007500160518
007600160518     D i               s             10i 0 inz
007700160518     D CutColumns      s                   like(SourceStmt)
007800160518     D ThisLineCmd     s                   like(LineCmd)
007900160518     D ThisStmt        s                   like(SourceStmt)
008000160518     D NextStmt        s                   like(SourceStmt)
008100160518     D SourceLength    s             10i 0
008200160518     D CutLen          s             10i 0
008300160518     D BlankLineCmd    s                   like(LineCmd)
008400160518     D RtnCode         s              7
008500160518
008600160518     DSndMsg           pr
008700160518     D MsgID                          7    const
008800160518     D RtnCodeOut                          Like(RtnCode)
008900160518     D MsgDta                        80    options(*nopass) const
009000160518
009100160518     DLoadWorkFromInp  pr
009200160518     D SrcDtaPtrInp                    *   const
009300160518     D LineCmdOut                          like(LineCmd)     Options(*Omit)
009400160518     D LineRetCodeOut                      like(LineRetCode) Options(*Omit)
009500160518     D SourceSeqOut                        like(SourceSeq)   Options(*Omit)
009600160518     D SourceDateOut                       like(SourceDate)  Options(*Omit)
009700160518     D SourceStmtOut                       like(SourceStmt)  Options(*Omit)
009800160518
009900160518     DLoadOutFromWork  pr
010000160518     D SrcDtaPtrInp                    *                     const
010100160518     D LineCmdInp                          like(LineCmd)     Options(*Omit)
010200160518     D LineRetCodeInp                      like(LineRetCode) Options(*Omit)
010300160518     D SourceSeqInp                        like(SourceSeq)   Options(*Omit)
010400160518     D SourceDateInp                       like(SourceDate)  Options(*Omit)
010500160518     D SourceStmtInp                       like(SourceStmt)  Options(*Omit)
010600160518
010700160518     DGetAttrFromCmd   pr             1
010800160518     D LineCmdInp                          like(LineCmd) const
010900160518
011000160518      *================================================================
011100160518     C     *Entry        Plist
011200160518     C                   Parm                    SEUInputPParm
011300160518     C                   Parm                    SEUOutputPParm
011400160518     C                   Parm                    SEUSourcePParm
011500160518
011600160518      * Get the data referred to by the input pointers
011700160518     C                   Eval      SEUInputP    = SEUInputPParm
011800160518     C                   Eval      SourceLength = %len(SEUSource) -
011900160518     C                                            %len(SourceStmt) +
012000160518     C                                            StmtLength
012100160518     C                   Eval      SEUOutputP   = SEUOutputPParm
012200160518     C                   Eval      ThisLineP    = SEUSourcePParm
012300160518     C                   Eval      NextLineP    = SEUSourcePParm + SourceLength
012400160518
012500160518      * Set default values
012600160518     C                   Eval      ReturnCode = '0'
012700160518     C                   Eval      OutputRecords = InputRecords - 1
012800160518     C                   Eval      InsertedSeq = '0000000'
012900160518
013000160518      * Allow updates only if in Update mode
013100160518     C                   If        SeuMode = 'U'
013200160518     C                   Exsr      LineCommands
013300160518     C                   Exsr      CmdKeys
013400160518     C                   Else
013500160518     C                   Eval      ReturnCode = '1'
013600160518      * Send back "Not in update mode" message
013700160518     C*#*                   CallP     SndMsg('SEU0004': RtnCode)
013800160518     C                   CallP     SndMsg('SEU0007': RtnCode: 'In browse!')
013900160518     C                   EndIf
014000160518
014100160518     C                   Eval      *InLR = *On
014200160518     C                   Return
014300160518
014400160518      *================================================================
014500160518      * Process all the line commands (commands typed in the seq number area)
014600160518      * InputRecords includes the "next" line.
014700160518      * For example, if a line command is placed on lines 1 and 5, InputRecords will be 6
014800160518
014900160518     C     LineCommands  Begsr
015000160518
015100160518     C                   Eval      WorkLineP = ThisLineP
015200160518     C                   Eval      i = 1
015300160518
015400160518     C                   DoW       i <= (InputRecords - 1)
015500160518     C                   Callp     LoadWorkFromInp(WorkLineP:
015600160518     C                                             ThisLineCmd:
015700160518     C                                             *Omit:
015800160518     C                                             *Omit:
015900160518     C                                             *Omit:
016000160518     C                                             ThisStmt)
016100160518
016200160518     C                   Select
016300160518
016400160518      * Line command to set the attribute of the line
016500160518     C                   When      %subst(ThisLineCmd: 1: 4)  = 'ATTR'
016600160518
016700160518      * Blank out the line command
016800160518     C                   Callp     LoadOutFromWork(WorkLineP:
016900160518     C                                             BlankLineCmd:
017000160518     C                                             *Omit:
017100160518     C                                             *Omit:
017200160518     C                                             *Omit:
017300160518     C                                             *Omit)
017400160518
017500160518      * Highlight the line by forcing an attribute byte in the proper column
017600160518      * based on the source member type
017700160518     C                   If        MbrType = 'RPG'      or
017800160518     C                             MbrType = 'RPGLE'    or
017900160518     C                             MbrType = 'SQLRPG'   or
018000160518     C                             MbrType = 'SQLRPGLE' or
018100160518     C                             MbrType = 'PF'       or
018200160518     C                             MbrType = 'PRTF'     or
018300160518     C                             MbrType = 'DSPF'
018400160518     C                   Eval      %subst(ThisStmt: 1: 1) =
018500160518     C                               GetAttrFromCmd(ThisLineCmd)
018600160518
018700160518      * Put the work fields back into the source space
018800160518     C                   Callp     LoadOutFromWork(ThisLineP:
018900160518     C                                             *Omit:
019000160518     C                                             *Omit:
019100160518     C                                             *Omit:
019200160518     C                                             *Omit:
019300160518     C                                             ThisStmt)
019400160518
019500160518      * Send back a message to show that we saw and processed the line cmd
019600160518     C                   CallP     SndMsg('SEU0005': RtnCode)
019700160518     C                   Else
019800160518      * Send back a message to show that we saw and ignored the line cmd
019900160518     C                   CallP     SndMsg('SEU0006': RtnCode)
020000160518     C                   EndIf
020100160518
020200160518     C                   EndSL
020300160518
020400160518     C                   Eval      i = i + 1
020500160518     C                   Eval      WorkLineP = WorkLineP + SourceLength
020600160518     C                   EndDO
020700160518
020800160518     C                   EndSR
020900160518
021000160518      *================================================================
021100160518      * Process the command keys (F7/F8)
021200160518
021300160518     C     CmdKeys       Begsr
021400160518
021500160518     C                   Select
021600160518
021700160518      * Is the cursor outside of the source statement with an F key press?
021800160518     C                   When      (FnKey = '7'  or
021900160518     C                              FnKey = '8') and
022000160518     C                             CurCol = 0
022100160518
022200160518      * Tell SEU that the cursor is outside the source area
022300160518     C                   CallP     SndMsg('SEU0001': RtnCode)
022400160518
022500160518      * F7 = split/join
022600160518     C                   When      FnKey = '7'
022700160518
022800160518      * Should we do a split or a join?
022900160518      * Get the line the cursor is on
023000160518     C                   Callp     LoadWorkFromInp(ThisLineP:
023100160518     C                                             *Omit:
023200160518     C                                             *Omit:
023300160518     C                                             *Omit:
023400160518     C                                             *Omit:
023500160518     C                                             ThisStmt)
023600160518      * Get the next line
023700160518     C                   Callp     LoadWorkFromInp(NextLineP:
023800160518     C                                             *Omit:
023900160518     C                                             *Omit:
024000160518     C                                             *Omit:
024100160518     C                                             *Omit:
024200160518     C                                             NextStmt)
024300160518
024400160518      * If there is data beyond the current column, split it
024500160518      * If the rest of the line is blank, join the next line to this one
024600160518     C                   if        %subst(ThisStmt: CurCol:
024700160518     C                                    StmtLength - CurCol - 1) <>
024800160518     C                                      *Blanks
024900160518     C                   Exsr      SplitLine
025000160518     C                   Else
025100160518     C                   Exsr      JoinLine
025200160518     C                   EndIf
025300160518
025400160518     C                   EndSL
025500160518
025600160518     C                   EndSR
025700160518
025800160518      *================================================================
025900160518      * Split line at blank
026000160518
026100160518     C     SplitLine     Begsr
026200160518
026300160518      * Cut the columns to the right including the column the cursor is in
026400160518     C                   Eval      CutColumns = %subst(ThisStmt:
026500160518     C                                                 CurCol)
026600160518
026700160518      * Drop the rightmost columns into the next line
026800160518     C                   Eval      NextStmt = CutColumns
026900160518
027000160518      * Trim the cut columns off the right side of this line
027100160518     C                   If        CurCol > 1
027200160518     C                   Eval      ThisStmt = %subst(ThisStmt:
027300160518     C                                               1:
027400160518     C                                               CurCol - 1)
027500160518     C                   Else
027600160518     C                   Eval      ThisStmt = *Blanks
027700160518     C                   EndIf
027800160518
027900160518      * Put the work fields back into the source space
028000160518     C                   Callp     LoadOutFromWork(ThisLineP:
028100160518     C                                             *Omit:
028200160518     C                                             *Omit:
028300160518     C                                             *Omit:
028400160518     C                                             *Omit:
028500160518     C                                             ThisStmt)
028600160518
028700160518     C                   Callp     LoadOutFromWork(NextLineP:
028800160518     C                                             *Omit:
028900160518     C                                             *Omit:
029000160518     C                                             *Omit:
029100160518     C                                             *Omit:
029200160518     C                                             NextStmt)
029300160518
029400160518      * Tell SEU that we're returning 2 lines
029500160518     C                   Eval      OutputRecords = 2
029600160518
029700160518      * Tell SEU that the split is complete
029800160518     C                   CallP     SndMsg('SEU0002': RtnCode)
029900160518     C                   EndSR
030000160518
030100160518      *================================================================
030200160518      * Join line
030300160518
030400160518     C     JoinLine      Begsr
030500160518
030600160518      * Don't try to join if the next line is a blank
030700160518     C                   If        NextStmt <> *Blanks
030800160518
030900160518      * Grab the leftmost columns from the next line (as many columns
031000160518      * as are blank at the end of this line)
031100160518     C                   Eval      CutColumns = %subst(NextStmt:
031200160518     C                                                 1:
031300160518     C                                                 (StmtLength -
031400160518     C                                                  CurCol +
031500160518     C                                                  1               ))
031600160518
031700160518      * Add the columns from the next line onto the end of this line
031800160518     C     ' '           Checkr    CutColumns    CutLen
031900160518     C                   Eval      ThisStmt = %subst(ThisStmt:
032000160518     C                                               1:
032100160518     C                                               CurCol - 1)       +
032200160518     C                                         %subst(CutColumns:
032300160518     C                                                1:
032400160518     C                                                CutLen)
032500160518
032600160518      * Blank out the cut columns
032700160518     C                   Eval      %subst(NextStmt: 1: CutLen) = *Blanks
032800160518
032900160518      * If we've cut the entire next line, delete it.  Otherwise,
033000160518      * simply cut the columns out - don't shift the remainder of the line
033100160518     C                   If        NextStmt = *Blanks
033200160518     C                   Eval      OutputRecords = 1
033300160518     C                   Eval      InsertedSeq = 'A000000'
033400160518     C                   Else
033500160518     C                   Eval      OutputRecords = 2
033600160518     C                   Eval      InsertedSeq = 'A000000'
033700160518     C                   EndIf
033800160518
033900160518      * Put the work fields back into the source space
034000160518     C                   Callp     LoadOutFromWork(ThisLineP:
034100160518     C                                             *Omit:
034200160518     C                                             *Omit:
034300160518     C                                             *Omit:
034400160518     C                                             *Omit:
034500160518     C                                             ThisStmt)
034600160518
034700160518     C                   Callp     LoadOutFromWork(NextLineP:
034800160518     C                                             *Omit:
034900160518     C                                             *Omit:
035000160518     C                                             *Omit:
035100160518     C                                             *Omit:
035200160518     C                                             NextStmt)
035300160518
035400160518      * Tell SEU that the join is complete
035500160518     C                   CallP     SndMsg('SEU0003': RtnCode)
035600160518     C                   EndIf
035700160518
035800160518     C                   EndSR
035900160518
036000160518      *================================================================
036100160518      * Send a "status" message back to SEU
036200160518      * There's a trick in use here that you need to be aware of.
036300160518      * the message stack count is determined by how deep in the call stack the
036400160518      * subprocedure is!  Here's why it was set to 3:
036500160518      *     STRSEU      1
036600160518      *       SEUEXIT   2
036700160518      *         SndMsg  3
036800160518
036900160518     PSndMsg           b
037000160518     DSndMsg           pi
037100160518     D MsgID                          7    const
037200160518     D RtnCodeOut                          Like(ErrSMsgID)
037300160518     D MsgDta                        80    options(*nopass) const
037400160518
037500160518      * Send message API parameters
037600160518     D MsgIDWrk        s                   like(MsgID)
037700160518     D MsgFil          s             20    inz('SEUEXIT   *LIBL     ')
037800160518     D MsgData         s             80
037900160518     D MsgDataLen      s             10i 0
038000160518     D MsgType         s             10    inz('*DIAG')
038100160518     D MsgStackEnt     s             10    inz('*')
038200160518     D MsgStackCnt     s             10i 0 inz(3)
038300160518     D MsgKey          s              4
038400160518     D MsgErrStruc     s                   like(ErrStruc)
038500160518
038600160518      * API error structure
038700160518     D ErrStruc        DS                  inz
038800160518     D  ErrSSize                     10i 0 inz(%len(ErrStruc))
038900160518     D  ErrSUse                      10i 0
039000160518     D  ErrSMsgID                     7
039100160518     D  ErrSResrv                     1
039200160518     D  ErrSData                     80
039300160518
039400160518     C                   eval      MsgIdWrk = MsgID
039500160518     C                   eval      MsgErrStruc = ErrStruc
039600160518      * was message data provided?
039700160518     c                   if        %parms >= 3
039800160518     c                   eval      MsgData = msgDta
039900160518     c                   eval      MsgDataLen = %len(%trimr(MsgData))
040000160518     c                   else
040100160518     c                   eval      MsgData = *blanks
040200160518     c                   eval      MsgDataLen = 1
040300160518     c                   endif
040400160518
040500160518     C                   Call      'QMHSNDPM'
040600160518     C                   Parm                    MsgIDWrk
040700160518     C                   Parm                    MsgFil
040800160518     C                   Parm                    MsgData
040900160518     C                   Parm                    MsgDataLen
041000160518     C                   Parm                    MsgType
041100160518     C                   Parm                    MsgStackEnt
041200160518     C                   Parm                    MsgStackCnt
041300160518     C                   Parm                    MsgKey
041400160518     C                   Parm                    MsgErrStruc
041500160518
041600160518     C                   Eval      ErrStruc = MsgErrStruc
041700160518     C                   Eval      RtnCodeOut = ErrSMsgID
041800160518
041900160518     PSndMsg           e
042000160518
042100160518      *================================================================
042200160518      * Load the work fields from the data SEU sent us
042300160518
042400160518     PLoadWorkFromInp  b
042500160518     DLoadWorkFromInp  pi
042600160518     D SrcDtaPtrInp                    *   const
042700160518     D LineCmdOut                          like(LineCmd)     Options(*Omit)
042800160518     D LineRetCodeOut                      like(LineRetCode) Options(*Omit)
042900160518     D SourceSeqOut                        like(SourceSeq)   Options(*Omit)
043000160518     D SourceDateOut                       like(SourceDate)  Options(*Omit)
043100160518     D SourceStmtOut                       like(SourceStmt)  Options(*Omit)
043200160518
043300160518      * Point to the data within the SEU space
043400160518     C                   Eval      SEUSourceP = SrcDtaPtrInp
043500160518
043600160518     C                   If        %addr(LineCmdOut) <> *Null
043700160518     C                   Eval            LineCmdOut  =  LineCmd
043800160518     C                   Endif
043900160518     C                   If        %addr(LineRetCodeOut) <> *Null
044000160518     C                   Eval            LineRetCodeOut  =  LineRetCode
044100160518     C                   Endif
044200160518     C                   If        %addr(SourceSeqOut) <> *Null
044300160518     C                   Eval            SourceSeqOut  =  SourceSeq
044400160518     C                   Endif
044500160518     C                   If        %addr(SourceDateOut) <> *Null
044600160518     C                   Eval            SourceDateOut  =  SourceDate
044700160518     C                   Endif
044800160518     C                   If        %addr(SourceStmtOut) <> *Null
044900160518     C                   Eval            SourceStmtOut  =  %subst(SourceStmt: 1:
045000160518     C                                                       StmtLength)
045100160518     C                   Endif
045200160518
045300160518     P                 e
045400160518
045500160518      *================================================================
045600160518      * Load data back to SEU from the work fields
045700160518
045800160518     PLoadOutFromWork  b
045900160518     DLoadOutFromWork  pi
046000160518     D SrcDtaPtrInp                    *                     const
046100160518     D LineCmdInp                          like(LineCmd)     Options(*Omit)
046200160518     D LineRetCodeInp                      like(LineRetCode) Options(*Omit)
046300160518     D SourceSeqInp                        like(SourceSeq)   Options(*Omit)
046400160518     D SourceDateInp                       like(SourceDate)  Options(*Omit)
046500160518     D SourceStmtInp                       like(SourceStmt)  Options(*Omit)
046600160518
046700160518      * Point to the data within the SEU space
046800160518     C                   Eval      SEUSourceP = SrcDtaPtrInp
046900160518
047000160518     C                   If        %addr(LineCmdInp) <> *Null
047100160518     C                   Eval            LineCmd     =  LineCmdInp
047200160518     C                   Endif
047300160518     C                   If        %addr(LineRetCodeInp) <> *Null
047400160518     C                   Eval            LineRetCode     =  LineRetCodeInp
047500160518     C                   Endif
047600160518     C                   If        %addr(SourceSeqInp) <> *Null
047700160518     C                   Eval            SourceSeq     =  SourceSeqInp
047800160518     C                   Endif
047900160518     C                   If        %addr(SourceDateInp) <> *Null
048000160518     C                   Eval            SourceDate     =  SourceDateInp
048100160518     C                   Endif
048200160518     C                   If        %addr(SourceStmtInp) <> *Null
048300160518     C                   Eval            SourceStmt     =  SourceStmtInp
048400160518     C                   Endif
048500160518
048600160518     P                 e
048700160518
048800160518      *================================================================
048900160518      * Extract an attribute byte from the input line command
049000160518      * The line command is formatted "ATTRxx" where XX is a mnemnonic for
049100160518      * the attribute byte to assign to the line.  The mnemnonics are the same
049200160518      * as used by DDS with the addition of colours.
049300160518
049400160518     PGetAttrFromCmd   b
049500160518     DGetAttrFromCmd   pi             1
049600160518     D LineCmdInp                          like(LineCmd) const
049700160518
049800160518     D AttributeByte   s              1
049900160518     D AttrTest        s              2
050000160518     D i               s             10i 0
050100160518
050200160518     DAttrMnemDS       ds
050300160518     D                                2    inz('  ')
050400160518     D                                2    inz('RI')
050500160518     D                                2    inz('HI')
050600160518     D                                2    inz('UL')
050700160518     D                                2    inz('BL')
050800160518     D                                2    inz('CS')
050900160518     D                                2    inz('CP')
051000160518     D                                2    inz('CL')
051100160518     D AttrMnem                       2    dim(8) overlay(AttrMnemDS)
051200160518
051300160518     DAttrDS           ds
051400160518     D                                1    inz(x'20')
051500160518     D                                1    inz(x'21')
051600160518     D                                1    inz(x'22')
051700160518     D                                1    inz(x'24')
051800160518     D                                1    inz(x'28')
051900160518     D                                1    inz(x'30')
052000160518     D                                1    inz(x'38')
052100160518     D                                1    inz(x'3A')
052200160518     D Attr                           1    dim(8) overlay(AttrDS)
052300160518
052400160518      * Default to normal
052500160518     C                   Eval      AttributeByte = Attr(1)
052600160518
052700160518      * Extract the mnemnonic from the line command
052800160518     C                   Eval      AttrTest = %subst(ThisLineCmd: 5: 2)
052900160518
053000160518      * Convert the mnemnonic to an attribute byte
053100160518     C                   Eval      i = 1
053200160518     C     AttrTest      Lookup    AttrMnem(i)                            20
053300160518     C                   If        *In20 = *On
053400160518     C                   Eval      AttributeByte = Attr(i)
053500160518     C                   EndIf
053600160518
053700160518     C                   Return    AttributeByte
053800160518     P                 e
053900160518
