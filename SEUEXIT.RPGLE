     H dftactgrp(*no) actgrp('QILE') indent(*none)

      * dbgview(*list)

      * Buck Calabro April 2000
      * large portions lifted from the SEU User's Guide and Reference SC09-2605-00
      * If you have a really large source file, increase the size of SourceStmt
      * Note that this is really a boiler-plate more than anything else.

      * To activate, STRSEU, press F13, page down and fill in the name of this program

      * SEU puts data in QTEMP/QSUSPC
      * this space has 3 data blocks:
      *   1. Input from SEU
      *   2. Output back to SEU
      *   3. Actual source lines

      * Supports the following line commands:
      * ATTRxx - set line attribute (colour, hilight, etc.)

      * Supports the following F keys:
      * F7 - Split/join a line (Splits this line to next if cursor in the middle of a line,
      *                         joins next line to this if cursor at the end of a line)

      * Uses messages in a user-created message file:
      *   Message ID  Severity  Message Text
      *    SEU0001        0     Cursor is not positioned within a source statement.
      *    SEU0002        0     Line split complete.
      *    SEU0003        0     Line join complete.
      *    SEU0004        0     Cannot update in Browse mode
      *    SEU0005        0     ATTR command processed
      *    SEU0006        0     ATTR command not valid for this member type
      *    SEU0007        0     &1

      * Input from SEU
     D SEUInput        DS                  BASED(SEUInputP)
     D  StmtLength                   10i 0
     D  CurRec                       10i 0
     D  CurCol                       10i 0
     D  CCSID                        10i 0
     D  InputRecords                 10i 0
     D  SrcMbr                       10
     D  SrcFil                       10
     D  SrcLib                       10
     D  MbrType                      10
     D  FnKey                         1
     D  SEUMode                       1
     D  SplitSession                  1
     D  ReservedInp                   1

      * Output to SEU
     D SEUOutput       DS                  BASED(SEUOutputP)
     D  ReturnCode                    1
     D  ReservedOut1                  3
     D  OutputRecords                10i 0
     D  InsertedSeq                   7
     D  ReservedOut2                 21

      * Source statements.  SEU passes the line the cursor is on,
      *                     and the next line
     D SEUSource       DS                  BASED(SEUSourceP)
     D  LineCmd                       7
     D  LineRetCode                   1
     D  SourceSeq                     6
     D  SourceDate                    6
     D  SourceStmt                  256

      * Work variables
     D SEUInputPParm   s               *
     D SEUOutputPParm  s               *
     D SEUSourcePParm  s               *
     D ThisLineP       s               *
     D NextLineP       s               *
     D WorkLineP       s               *

     D i               s             10i 0 inz
     D CutColumns      s                   like(SourceStmt)
     D ThisLineCmd     s                   like(LineCmd)
     D ThisStmt        s                   like(SourceStmt)
     D NextStmt        s                   like(SourceStmt)
     D SourceLength    s             10i 0
     D CutLen          s             10i 0
     D BlankLineCmd    s                   like(LineCmd)
     D RtnCode         s              7

     DSndMsg           pr
     D MsgID                          7    const
     D RtnCodeOut                          Like(RtnCode)
     D MsgDta                        80    options(*nopass) const

     DLoadWorkFromInp  pr
     D SrcDtaPtrInp                    *   const
     D LineCmdOut                          like(LineCmd)     Options(*Omit)
     D LineRetCodeOut                      like(LineRetCode) Options(*Omit)
     D SourceSeqOut                        like(SourceSeq)   Options(*Omit)
     D SourceDateOut                       like(SourceDate)  Options(*Omit)
     D SourceStmtOut                       like(SourceStmt)  Options(*Omit)

     DLoadOutFromWork  pr
     D SrcDtaPtrInp                    *                     const
     D LineCmdInp                          like(LineCmd)     Options(*Omit)
     D LineRetCodeInp                      like(LineRetCode) Options(*Omit)
     D SourceSeqInp                        like(SourceSeq)   Options(*Omit)
     D SourceDateInp                       like(SourceDate)  Options(*Omit)
     D SourceStmtInp                       like(SourceStmt)  Options(*Omit)

     DGetAttrFromCmd   pr             1
     D LineCmdInp                          like(LineCmd) const

      *================================================================
     C     *Entry        Plist
     C                   Parm                    SEUInputPParm
     C                   Parm                    SEUOutputPParm
     C                   Parm                    SEUSourcePParm

      * Get the data referred to by the input pointers
     C                   Eval      SEUInputP    = SEUInputPParm
     C                   Eval      SourceLength = %len(SEUSource) -
     C                                            %len(SourceStmt) +
     C                                            StmtLength
     C                   Eval      SEUOutputP   = SEUOutputPParm
     C                   Eval      ThisLineP    = SEUSourcePParm
     C                   Eval      NextLineP    = SEUSourcePParm + SourceLength

      * Set default values
     C                   Eval      ReturnCode = '0'
     C                   Eval      OutputRecords = InputRecords - 1
     C                   Eval      InsertedSeq = '0000000'

      * Allow updates only if in Update mode
     C                   If        SeuMode = 'U'
     C                   Exsr      LineCommands
     C                   Exsr      CmdKeys
     C                   Else
     C                   Eval      ReturnCode = '1'
      * Send back "Not in update mode" message
     C*#*                   CallP     SndMsg('SEU0004': RtnCode)
     C                   CallP     SndMsg('SEU0007': RtnCode: 'In browse!')
     C                   EndIf

     C                   Eval      *InLR = *On
     C                   Return

      *================================================================
      * Process all the line commands (commands typed in the seq number area)
      * InputRecords includes the "next" line.
      * For example, if a line command is placed on lines 1 and 5, InputRecords will be 6

     C     LineCommands  Begsr

     C                   Eval      WorkLineP = ThisLineP
     C                   Eval      i = 1

     C                   DoW       i <= (InputRecords - 1)
     C                   Callp     LoadWorkFromInp(WorkLineP:
     C                                             ThisLineCmd:
     C                                             *Omit:
     C                                             *Omit:
     C                                             *Omit:
     C                                             ThisStmt)

     C                   Select

      * Line command to set the attribute of the line
     C                   When      %subst(ThisLineCmd: 1: 4)  = 'ATTR'

      * Blank out the line command
     C                   Callp     LoadOutFromWork(WorkLineP:
     C                                             BlankLineCmd:
     C                                             *Omit:
     C                                             *Omit:
     C                                             *Omit:
     C                                             *Omit)

      * Highlight the line by forcing an attribute byte in the proper column
      * based on the source member type
     C                   If        MbrType = 'RPG'      or
     C                             MbrType = 'RPGLE'    or
     C                             MbrType = 'SQLRPG'   or
     C                             MbrType = 'SQLRPGLE' or
     C                             MbrType = 'PF'       or
     C                             MbrType = 'PRTF'     or
     C                             MbrType = 'DSPF'
     C                   Eval      %subst(ThisStmt: 1: 1) =
     C                               GetAttrFromCmd(ThisLineCmd)

      * Put the work fields back into the source space
     C                   Callp     LoadOutFromWork(ThisLineP:
     C                                             *Omit:
     C                                             *Omit:
     C                                             *Omit:
     C                                             *Omit:
     C                                             ThisStmt)

      * Send back a message to show that we saw and processed the line cmd
     C                   CallP     SndMsg('SEU0005': RtnCode)
     C                   Else
      * Send back a message to show that we saw and ignored the line cmd
     C                   CallP     SndMsg('SEU0006': RtnCode)
     C                   EndIf

     C                   EndSL

     C                   Eval      i = i + 1
     C                   Eval      WorkLineP = WorkLineP + SourceLength
     C                   EndDO

     C                   EndSR

      *================================================================
      * Process the command keys (F7/F8)

     C     CmdKeys       Begsr

     C                   Select

      * Is the cursor outside of the source statement with an F key press?
     C                   When      (FnKey = '7'  or
     C                              FnKey = '8') and
     C                             CurCol = 0

      * Tell SEU that the cursor is outside the source area
     C                   CallP     SndMsg('SEU0001': RtnCode)

      * F7 = split/join
     C                   When      FnKey = '7'

      * Should we do a split or a join?
      * Get the line the cursor is on
     C                   Callp     LoadWorkFromInp(ThisLineP:
     C                                             *Omit:
     C                                             *Omit:
     C                                             *Omit:
     C                                             *Omit:
     C                                             ThisStmt)
      * Get the next line
     C                   Callp     LoadWorkFromInp(NextLineP:
     C                                             *Omit:
     C                                             *Omit:
     C                                             *Omit:
     C                                             *Omit:
     C                                             NextStmt)

      * If there is data beyond the current column, split it
      * If the rest of the line is blank, join the next line to this one
     C                   If        %subst(ThisStmt: CurCol:
     C                                    StmtLength - CurCol - 1) <>
     C                                      *Blanks
     C                   Exsr      SplitLine
     C                   Else
     C                   Exsr      JoinLine
     C                   EndIf

     C                   EndSL

     C                   EndSR

      *================================================================
      * Split line at blank

     C     SplitLine     Begsr

      * Cut the columns to the right including the column the cursor is in
     C                   Eval      CutColumns = %subst(ThisStmt:
     C                                                 CurCol)

      * Drop the rightmost columns into the next line
     C                   Eval      NextStmt = CutColumns

      * Trim the cut columns off the right side of this line
     C                   If        CurCol > 1
     C                   Eval      ThisStmt = %subst(ThisStmt:
     C                                               1:
     C                                               CurCol - 1)
     C                   Else
     C                   Eval      ThisStmt = *Blanks
     C                   EndIf

      * Put the work fields back into the source space
     C                   Callp     LoadOutFromWork(ThisLineP:
     C                                             *Omit:
     C                                             *Omit:
     C                                             *Omit:
     C                                             *Omit:
     C                                             ThisStmt)

     C                   Callp     LoadOutFromWork(NextLineP:
     C                                             *Omit:
     C                                             *Omit:
     C                                             *Omit:
     C                                             *Omit:
     C                                             NextStmt)

      * Tell SEU that we're returning 2 lines
     C                   Eval      OutputRecords = 2

      * Tell SEU that the split is complete
     C                   CallP     SndMsg('SEU0002': RtnCode)
     C                   EndSR

      *================================================================
      * Join line

     C     JoinLine      Begsr

      * Don't try to join if the next line is a blank
     C                   If        NextStmt <> *Blanks

      * Grab the leftmost columns from the next line (as many columns
      * as are blank at the end of this line)
     C                   Eval      CutColumns = %subst(NextStmt:
     C                                                 1:
     C                                                 (StmtLength -
     C                                                  CurCol +
     C                                                  1               ))

      * Add the columns from the next line onto the end of this line
     C     ' '           Checkr    CutColumns    CutLen
     C                   Eval      ThisStmt = %subst(ThisStmt:
     C                                               1:
     C                                               CurCol - 1)       +
     C                                         %subst(CutColumns:
     C                                                1:
     C                                                CutLen)

      * Blank out the cut columns
     C                   Eval      %subst(NextStmt: 1: CutLen) = *Blanks

      * If we've cut the entire next line, delete it.  Otherwise,
      * simply cut the columns out - don't shift the remainder of the line
     C                   If        NextStmt = *Blanks
     C                   Eval      OutputRecords = 1
     C                   Eval      InsertedSeq = 'A000000'
     C                   Else
     C                   Eval      OutputRecords = 2
     C                   Eval      InsertedSeq = 'A000000'
     C                   EndIf

      * Put the work fields back into the source space
     C                   Callp     LoadOutFromWork(ThisLineP:
     C                                             *Omit:
     C                                             *Omit:
     C                                             *Omit:
     C                                             *Omit:
     C                                             ThisStmt)

     C                   Callp     LoadOutFromWork(NextLineP:
     C                                             *Omit:
     C                                             *Omit:
     C                                             *Omit:
     C                                             *Omit:
     C                                             NextStmt)

      * Tell SEU that the join is complete
     C                   CallP     SndMsg('SEU0003': RtnCode)
     C                   EndIf

     C                   EndSR

      *================================================================
      * Send a "status" message back to SEU
      * There's a trick in use here that you need to be aware of.
      * the message stack count is determined by how deep in the call stack the
      * subprocedure is!  Here's why it was set to 3:
      *     STRSEU      1
      *       SEUEXIT   2
      *         SndMsg  3

     PSndMsg           b
     DSndMsg           pi
     D MsgID                          7    const
     D RtnCodeOut                          Like(ErrSMsgID)
     D MsgDta                        80    options(*nopass) const

      * Send message API parameters
     D MsgIDWrk        s                   like(MsgID)
     D MsgFil          s             20    inz('SEUEXIT   *LIBL     ')
     D MsgData         s             80
     D MsgDataLen      s             10i 0
     D MsgType         s             10    inz('*DIAG')
     D MsgStackEnt     s             10    inz('*')
     D MsgStackCnt     s             10i 0 inz(3)
     D MsgKey          s              4
     D MsgErrStruc     s                   like(ErrStruc)

      * API error structure
     D ErrStruc        DS                  inz
     D  ErrSSize                     10i 0 inz(%len(ErrStruc))
     D  ErrSUse                      10i 0
     D  ErrSMsgID                     7
     D  ErrSResrv                     1
     D  ErrSData                     80

     C                   Eval      MsgIdWrk = MsgID
     C                   Eval      MsgErrStruc = ErrStruc
      * was message data provided?
     C                   If        %parms >= 3
     C                   Eval      MsgData = msgDta
     C                   Eval      MsgDataLen = %len(%trimr(MsgData))
     C                   Else
     C                   Eval      MsgData = *blanks
     C                   Eval      MsgDataLen = 1
     C                   EndIf

     C                   Call      'QMHSNDPM'
     C                   Parm                    MsgIDWrk
     C                   Parm                    MsgFil
     C                   Parm                    MsgData
     C                   Parm                    MsgDataLen
     C                   Parm                    MsgType
     C                   Parm                    MsgStackEnt
     C                   Parm                    MsgStackCnt
     C                   Parm                    MsgKey
     C                   Parm                    MsgErrStruc

     C                   Eval      ErrStruc = MsgErrStruc
     C                   Eval      RtnCodeOut = ErrSMsgID

     PSndMsg           e

      *================================================================
      * Load the work fields from the data SEU sent us

     PLoadWorkFromInp  b
     DLoadWorkFromInp  pi
     D SrcDtaPtrInp                    *   const
     D LineCmdOut                          like(LineCmd)     Options(*Omit)
     D LineRetCodeOut                      like(LineRetCode) Options(*Omit)
     D SourceSeqOut                        like(SourceSeq)   Options(*Omit)
     D SourceDateOut                       like(SourceDate)  Options(*Omit)
     D SourceStmtOut                       like(SourceStmt)  Options(*Omit)

      * Point to the data within the SEU space
     C                   Eval      SEUSourceP = SrcDtaPtrInp

     C                   If        %addr(LineCmdOut) <> *Null
     C                   Eval            LineCmdOut  =  LineCmd
     C                   Endif
     C                   If        %addr(LineRetCodeOut) <> *Null
     C                   Eval            LineRetCodeOut  =  LineRetCode
     C                   Endif
     C                   If        %addr(SourceSeqOut) <> *Null
     C                   Eval            SourceSeqOut  =  SourceSeq
     C                   Endif
     C                   If        %addr(SourceDateOut) <> *Null
     C                   Eval            SourceDateOut  =  SourceDate
     C                   Endif
     C                   If        %addr(SourceStmtOut) <> *Null
     C                   Eval            SourceStmtOut  =  %subst(SourceStmt: 1:
     C                                                       StmtLength)
     C                   Endif

     P                 e

      *================================================================
      * Load data back to SEU from the work fields

     PLoadOutFromWork  b
     DLoadOutFromWork  pi
     D SrcDtaPtrInp                    *                     const
     D LineCmdInp                          like(LineCmd)     Options(*Omit)
     D LineRetCodeInp                      like(LineRetCode) Options(*Omit)
     D SourceSeqInp                        like(SourceSeq)   Options(*Omit)
     D SourceDateInp                       like(SourceDate)  Options(*Omit)
     D SourceStmtInp                       like(SourceStmt)  Options(*Omit)

      * Point to the data within the SEU space
     C                   Eval      SEUSourceP = SrcDtaPtrInp

     C                   If        %addr(LineCmdInp) <> *Null
     C                   Eval            LineCmd     =  LineCmdInp
     C                   Endif
     C                   If        %addr(LineRetCodeInp) <> *Null
     C                   Eval            LineRetCode     =  LineRetCodeInp
     C                   Endif
     C                   If        %addr(SourceSeqInp) <> *Null
     C                   Eval            SourceSeq     =  SourceSeqInp
     C                   Endif
     C                   If        %addr(SourceDateInp) <> *Null
     C                   Eval            SourceDate     =  SourceDateInp
     C                   Endif
     C                   If        %addr(SourceStmtInp) <> *Null
     C                   Eval            SourceStmt     =  SourceStmtInp
     C                   Endif

     P                 e

      *================================================================
      * Extract an attribute byte from the input line command
      * The line command is formatted "ATTRxx" where XX is a mnemnonic for
      * the attribute byte to assign to the line.  The mnemnonics are the same
      * as used by DDS with the addition of colours.

     PGetAttrFromCmd   b
     DGetAttrFromCmd   pi             1
     D LineCmdInp                          like(LineCmd) const

     D AttributeByte   s              1
     D AttrTest        s              2
     D i               s             10i 0

     DAttrMnemDS       ds
     D                                2    inz('  ')
     D                                2    inz('RI')
     D                                2    inz('HI')
     D                                2    inz('UL')
     D                                2    inz('BL')
     D                                2    inz('CS')
     D                                2    inz('CP')
     D                                2    inz('CL')
     D AttrMnem                       2    dim(8) overlay(AttrMnemDS)

     DAttrDS           ds
     D                                1    inz(x'20')
     D                                1    inz(x'21')
     D                                1    inz(x'22')
     D                                1    inz(x'24')
     D                                1    inz(x'28')
     D                                1    inz(x'30')
     D                                1    inz(x'38')
     D                                1    inz(x'3A')
     D Attr                           1    dim(8) overlay(AttrDS)

      * Default to normal
     C                   Eval      AttributeByte = Attr(1)

      * Extract the mnemnonic from the line command
     C                   Eval      AttrTest = %subst(ThisLineCmd: 5: 2)

      * Convert the mnemnonic to an attribute byte
     C                   Eval      i = 1
     C     AttrTest      Lookup    AttrMnem(i)                            20
     C                   If        *In20 = *On
     C                   Eval      AttributeByte = Attr(i)
     C                   EndIf

     C                   Return    AttributeByte
     P                 e

