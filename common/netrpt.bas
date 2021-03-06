' ASPEN PowerScript Sample Program
'
' NETRPT.BAS
'
' Generate a network report. This report is identical to 
' the one generated by Network | Report command in OneLiner
' and PowerFlow
' 
' Demonstrate how to generate a customize report from
' PowerScript program
'
' PowerScript functions called:
'   GetData()
'   NextBusByName()
'   GetBusEquipment()
'
Sub main()
   ' Variable declaration
'   Dim IntVal1&, IntVal2&, nVal3&
'   Dim BusHnd&, DeviceHnd&
   Dim DblVal1#
   Dim Array1(10) As Double
   Dim Array2(10) As Double
   Dim Array3(10) As Double
   Dim Array4(10) As Double
   Dim Array5(10) As Long
   Dim StringVal1$, StringVal2$
   Dim fileName$, errStr$, aLine$
   Dim nHnd1&

   ' Open output file
   If OpenOutput() = 0 Then GoTo hasError
'   GoTo branch:

   ' Print the header

   Print #1, "                                                      -- ASPEN Power Flow --"
   Print #1, "                                                    (Gererated by PowerScript)"
   Print #1, ""
   If GetData( HND_SYS, SY_dBaseMVA, DblVal1 ) = 0 Then GoTo HasError
   Print #1, "BASE MVA =  ", Format(DblVal1,"##0.0")
   If GetData( HND_SYS, SY_nNObus, IntVal1 ) = 0 Then GoTo HasError
   Print #1, "THIS FILE HAS:"; Space(7-Len(str$(IntVal1)));IntVal1; " BUSES"
   If GetData( HND_SYS, SY_nNOgen, IntVal1 ) = 0 Then GoTo HasError
   Print #1, "              "; Space(7-Len(str$(IntVal1)));IntVal1; " GENERATORS"
   If GetData( HND_SYS, SY_nNOload, IntVal1 ) = 0 Then GoTo HasError
   Print #1, "              "; Space(7-Len(str$(IntVal1)));IntVal1; " LOADS"
   If GetData( HND_SYS, SY_nNOshunt, IntVal1 ) = 0 Then GoTo HasError
   Print #1, "              "; Space(7-Len(str$(IntVal1)));IntVal1; " SHUNTS"
   If GetData( HND_SYS, SY_nNOline, IntVal1 ) = 0 Then GoTo HasError
   Print #1, "              "; Space(7-Len(str$(IntVal1)));IntVal1; " LINES"
   If GetData( HND_SYS, SY_nNOxfmr, IntVal1 ) = 0 Then GoTo HasError
   Print #1, "              "; Space(7-Len(str$(IntVal1)));IntVal1; " 2-WINDING TRANSFORMERS"
   If GetData( HND_SYS, SY_nNOxfmr3, IntVal1 ) = 0 Then GoTo HasError
   Print #1, "              "; Space(7-Len(str$(IntVal1)));IntVal1; " 3-WINDING TRANSFORMERS"
   If GetData( HND_SYS, SY_nNOps, IntVal1 ) = 0 Then GoTo HasError
   Print #1, "              "; Space(7-Len(str$(IntVal1)));IntVal1; " PHASE SHIFTERS"
   If GetData( HND_SYS, SY_nNOmutual, IntVal1 ) = 0 Then GoTo HasError
   Print #1, "              "; Space(7-Len(str$(IntVal1)));IntVal1; " MUTUAL COUPLING GROUPS"
   Print #1, ""
   Print #1, "FILE COMMENTS:"
   If GetData( HND_SYS, SY_sFComment, StringVal1 ) = 0 Then GoTo HasError
   Print #1, "  "; StringVal1
   ' Write bus data
   Print #1, ""
   Print #1, "                                                            -- BUS DATA --"

   BusHnd& = 0
   While NextBusByName( BusHnd& ) > 0
      ' Print bus info
      If GetData( BusHnd&, BUS_sName, StringVal1$ ) = 0 Then GoTo HasError
      If GetData( BusHnd&, BUS_dKVnorminal, DblVal1# ) = 0 Then GoTo HasError
      If GetData( BusHnd&, BUS_nNumber, IntVal1& ) = 0 Then GoTo HasError
      If GetData( BusHnd&, BUS_nArea, IntVal2& ) = 0 Then GoTo HasError
      If GetData( BusHnd&, BUS_nZone, nVal3& ) = 0 Then GoTo HasError
      Print #1, "BUS    ";  FullBusName( BusHnd& );"  AREA=";IntVal2&;"  ZONE="; nVal3& 

      ' Print Gen info
      If GetData( BusHnd&, GE_nCtrlBusHnd, nBusHnd1& ) > 0 Then
         If GetData( BusHnd&, GE_dRefAngle, DblVal2# ) = 0 Then GoTo HasError
         If GetData( nBusHnd1&, BUS_sName, StringVal1$ ) = 0 Then GoTo HasError
         If GetData( nBusHnd1&, BUS_dKVnorminal, DblVal1# ) = 0 Then GoTo HasError
         If GetData( nBusHnd1&, BUS_nNumber, IntVal1& ) = 0 Then GoTo HasError
         If GetData( BusHnd&, GE_nActive, IntVal2& ) = 0 Then GoTo HasError
         If IntVal2& = 1 Then StringVal2$ = "   On-Line" Else StringVal2$ = "   Off-Line"
         If GetData( BusHnd&, GE_nFixedPQ, IntVal2& ) = 0 Then GoTo HasError
         If IntVal2& = 1 Then StringVal3$ = "  Fixed PQ" Else StringVal3$ = " Regulate V="
         StringVal4$ = "    GENERATOR:       " & StringVal2$ & frmt( DblVal2#, "####0.00RefAng", 14) _
                     & StringVal3$
         If IntVal2&<>1 Then 
            If GetData( BusHnd&, GE_dScheduledV, DblVal2# ) = 0 Then GoTo HasError
            StringVal4$ = StringVal4$ & frmt( DblVal2#,"0.00p\.u\. at bus:", 19 ) _
                     & frmt( IntVal1&,"0",6 ) & " " & StringVal1$ _
                     & Space( 20 - Len( StringVal1$ ) - Len( Format(DblVal1#,"###0.##KV") ) )  _
                     & Format( DblVal1#,"###0.##KV" )
         End If
         Print #1, StringVal4$
              
         DeviceHnd& = 0
         ' Loop thru genunits
         While GetBusEquipment( BusHnd&, TC_GENUNIT, DeviceHnd& ) > 0
            If GetData( DeviceHnd&, GU_sID, StringVal1$ ) = 0 Then GoTo HasError
            If GetData( DeviceHnd&, GU_nOnLine, IntVal1& ) = 0 Then GoTo HasError
            If IntVal1& = 1 Then StringVal2$ = "  On-Line" Else StringVal2$ = "  Off-Line"
            If GetData( DeviceHnd&, GU_dMVArating, DblVal1# ) = 0 Then GoTo HasError
'            If GetData( DeviceHnd&, GU_vdR, Array1() ) = 0 Then GoTo HasError
            If GetData( DeviceHnd&, GU_vdR, Array1() ) = 0 Then GoTo HasError
            If GetData( DeviceHnd&, GU_vdX, Array2() ) = 0 Then GoTo HasError

            Print #1,"               Unit  "; StringVal1$; StringVal2$; _
                 frmt( DblVal1#,"######.00MVA", 12 ); _
                 frmt( Array1(1),"###0.00000R", 11 ); frmt( Array2(1),"###0.00000X", 11); _
                 frmt( Array1(5),"###0.000000R\0", 12 ); frmt( Array2(5),"###0.000000X\0", 12); _
                 frmt( Array1(4),"###0.00000R2", 12 ); frmt( Array2(4),"###0.00000X2", 12)
         Wend
      End If
      ' Print Load info
      DeviceHnd& = 0
      While GetBusEquipment( BusHnd, TC_LOADUNIT, DeviceHnd& ) > 0
         If GetData( DeviceHnd&, LU_sID, StringVal1$ ) = 0 Then GoTo HasError
         If GetData( DeviceHnd&, LU_nOnLine, IntVal1& ) = 0 Then GoTo HasError
         If IntVal1& = 1 Then StringVal2$ = "  On-Line" Else StringVal2$ = "  Off-Line"
         If GetData( DeviceHnd&, LU_vdMW, Array1() ) = 0 Then GoTo HasError
         If GetData( DeviceHnd&, LU_vdMVAR, Array2() ) = 0 Then GoTo HasError

         Print #1,"    LOAD:      Unit  "; StringVal1$; StringVal2$; _
              " CP:";frmt( Array1(1),"0.00MW", 11 ); frmt( Array2(1),"0.00MVAR", 13); _
              " CC:";frmt( Array1(2),"0.00MW", 11 ); frmt( Array2(2),"0.00MVAR", 13); _
              " CI:";frmt( Array1(3),"0.00MW", 11 ); frmt( Array2(3),"0.00MVAR", 13)
      Wend
      ' Print Shunt info
      DeviceHnd& = 0
      While GetBusEquipment( BusHnd, TC_SHUNTUNIT, DeviceHnd& ) > 0
         If GetData( DeviceHnd&, SU_sID, StringVal1$ ) = 0 Then GoTo HasError
         If GetData( DeviceHnd&, SU_nOnLine, IntVal1& ) = 0 Then GoTo HasError
         If IntVal1& = 1 Then StringVal2$ = "  On-Line" Else StringVal2$ = "  Off-Line"
         If GetData( DeviceHnd&, SU_dG, DblVal1# ) = 0 Then GoTo HasError
         If GetData( DeviceHnd&, SU_dB, DblVal2# ) = 0 Then GoTo HasError
         If GetData( DeviceHnd&, SU_dG0, DblVal3# ) = 0 Then GoTo HasError
         If GetData( DeviceHnd&, SU_dB0, DblVal4# ) = 0 Then GoTo HasError

         Print #1,"    SHUNT:     Unit  "; StringVal1$; StringVal2$; _
              frmt( DblVal1#,"0.00000G", 11 ); frmt( DblVal2#,"0.00000B", 11); _
              frmt( DblVal3#,"0.000000#G\0", 12 ); frmt( DblVal4#,"0.000000#B\0", 12)
      Wend
      ' Print SVD
      If GetData( BusHnd&, SV_nActive, IntVal1& ) > 0 Then
      ' There's some SVD at this bus
         If IntVal1& = 1 Then StringVal1$ = "   On-Line" Else StringVal1$ = "  Off-Line"
         If GetData( BusHnd&, SV_nCtrlMode, IntVal1& ) = 0 Then GoTo HasError
         If IntVal1& = 0 Then 
            StringVal2$ = "         Fixed Mode"
         ElseIf IntVal1& = 1 Then
            StringVal2$ = "      Discrete Mode"
         Else
            StringVal2$ = "    Continuous Mode"
         End If
         If GetData( BusHnd&, SV_dVmin, DblVal1# ) = 0 Then GoTo HasError
         If GetData( BusHnd&, SV_dVmax, DblVal2# ) = 0 Then GoTo HasError
         If GetData( BusHnd&, SV_dB, DblVal3# ) = 0 Then GoTo HasError
         If GetData( BusHnd&, SV_vdBinc, Array1() ) = 0 Then GoTo HasError
         If GetData( BusHnd&, SV_vdB0inc, Array2() ) = 0 Then GoTo HasError
         If GetData( BusHnd&, SV_vnNoStep, Array5() ) = 0 Then GoTo HasError
         Print #1,"    SWITCHED SHUNT:  "; StringVal1$; StringVal2$; _
              frmt( DblVal1#,"0.00Vmin", 11 ); frmt( DblVal2#,"0.00Vmax", 12); frmt( DblVal3#,"0.00000B", 11 )
         StringVal3$ = "                        NO steps: "
         For nIndex& = 1 To 8
            StringVal3$ = StringVal3$ & frmt( Array5(nIndex&), "0", 9 )
         Next
         Print #1, StringVal3$
         StringVal3$ = "                        Binc    : "
         For nIndex& = 1 To 8
            StringVal3$ = StringVal3$ & frmt( Array1(nIndex&), "#0.00000", 9 )
         Next
         Print #1, StringVal3$
         StringVal3$ = "                        B0inc   : "
         For nIndex& = 1 To 8
            StringVal3$ = StringVal3$ & frmt( Array2(nIndex&), "#0.00000", 9 )
         Next
         Print #1, StringVal3$
      End If
   Wend

   Branch:
   Print #1, ""
   Print #1, "                                                           -- BRANCH DATA --"
   Print #1, ""
   BusHnd& = 0
   While NextBusByName( BusHnd& ) > 0
      Print #1, "BUS    " & FullBusName( BusHnd& )
      DeviceHnd& = 0
      ' Loop thru branches
      While GetBusEquipment( BusHnd, TC_BRANCH, DeviceHnd& ) > 0
         If GetData( DeviceHnd&, BR_nType, nBrType& ) = 0 Then GoTo HasError
         If GetData( DeviceHnd&, BR_nHandle, nBrHnd& ) = 0 Then GoTo HasError
         Select Case nBrType&
            Case TC_LINE		' Line
               If GetData( nBrHnd&, LN_sID,   StringVal1$ ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, LN_sName, StringVal2$ ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, LN_nBus1Hnd, IntVal1& ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, LN_nBus2Hnd,   IntVal2& ) = 0 Then GoTo HasError
               Print #1, Space( 4 - Len(StringVal1$) ) & StringVal1$ & "L " & _
                         FullBusName( IntVal1& )& " -"; FullBusName( IntVal2& ) & " " & StringVal2$
               If GetData( nBrHnd&, LN_dR,  DblVal1# ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, LN_dX,  DblVal2# ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, LN_dG1, DblVal3# ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, LN_dB1, DblVal4# ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, LN_dG2, DblVal5# ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, LN_dB2, DblVal6# ) = 0 Then GoTo HasError
               Print #1, "      "; frmt( DblVal1, "0.000000R", 9 ) ; _
                         "   "; frmt( DblVal2#, "0.000000X", 9 )  ; _
                         "   "; frmt( DblVal3#, "0.000000G1", 9 ) ; _
                         "   "; frmt( DblVal4#, "0.000000B1", 9 ) ; _
                         "   "; frmt( DblVal5#, "0.000000G2", 9 ) ; _ 
                         "   "; frmt( DblVal6#, "0.000000B2", 9 ) 
               If GetData( nBrHnd&, LN_dR0,  DblVal1# ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, LN_dX0,  DblVal2# ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, LN_dG10, DblVal3# ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, LN_dB10, DblVal4# ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, LN_dG20, DblVal5# ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, LN_dB20, DblVal6# ) = 0 Then GoTo HasError
               Print #1, "      "; frmt( DblVal1, "0.0000000R\0", 9 ) ; _
                         "  "; frmt( DblVal2#, "0.0000000X\0", 9 )  ; _
                         "  "; frmt( DblVal3#, "0.0000000G1\0", 9 ) ; _
                         "  "; frmt( DblVal4#, "0.0000000B1\0", 9 ) ; _
                         "  "; frmt( DblVal5#, "0.0000000G2\0", 9 ) ; _ 
                         "  "; frmt( DblVal6#, "0.0000000B2\0", 9 ) 
               ' Print Mutual Coupling info
               nMuHnd& = 0
               Print #1, "       Mutual coupling:"
               While GetData( nBrHnd&, LN_nMuPairHnd, nMuHnd& ) > 0 
                  If GetData( nMuHnd&, MU_nHndLine1,  nHndLine1& ) = 0 Then GoTo HasError
                  nFlip& = 0
                  If nHndLine1& = nBrHnd& Then	' Get the other line
                     If GetData( nMuHnd&, MU_nHndLine2,  nHndLine1& ) = 0 Then GoTo HasError
                     nFlip& = 1
                  End If
                  If GetData(  nHndLine1&, LN_sID,   StringVal1$ ) = 0 Then GoTo HasError
                  If GetData(  nHndLine1&, LN_sName, StringVal2$ ) = 0 Then GoTo HasError
                  If GetData( nHndLine1&, LN_nBus1Hnd, IntVal1& ) = 0 Then GoTo HasError
                  If GetData( nHndLine1&, LN_nBus2Hnd,   IntVal2& ) = 0 Then GoTo HasError
                  Print #1, "       With: " ; Space( 4 - Len(StringVal1$) ), StringVal1$ ; "L "; _
                            FullBusName( IntVal1& ); " -"; FullBusName( IntVal2& ); " "; StringVal2$
                  If nFlip = 0 Then 
                     If GetData( nMuHnd&, MU_dFrom1, DblVal1# ) = 0 Then GoTo HasError
                     If GetData( nMuHnd&, MU_dTo1,   DblVal2# ) = 0 Then GoTo HasError
                     If GetData( nMuHnd&, MU_dFrom2, DblVal3# ) = 0 Then GoTo HasError
                     If GetData( nMuHnd&, MU_dTo2,   DblVal4# ) = 0 Then GoTo HasError
                  Else
                     If GetData( nMuHnd&, MU_dFrom2, DblVal1# ) = 0 Then GoTo HasError
                     If GetData( nMuHnd&, MU_dTo2,   DblVal2# ) = 0 Then GoTo HasError
                     If GetData( nMuHnd&, MU_dFrom1, DblVal3# ) = 0 Then GoTo HasError
                     If GetData( nMuHnd&, MU_dTo1,   DblVal4# ) = 0 Then GoTo HasError
                  End If 
                  If GetData( nMuHnd&, MU_dR, DblVal5# ) = 0 Then GoTo HasError
                  If GetData( nMuHnd&, MU_dX, DblVal6# ) = 0 Then GoTo HasError
                  Print #1, "            "; frmt( DblVal1#/100, "0.00%Fr1", 9 )  ; _
                            "  "; frmt( DblVal2#/100, "0.00%To1", 9 )  ; _
                            "  "; frmt( DblVal3#/100, "0.00%Fr2", 9 )  ; _
                            "  "; frmt( DblVal4#/100, "0.00%To2", 9 )  ; _
                            "  ";  frmt( DblVal5#, "0.000000R", 9 ) ; _
                            "  ";  frmt( DblVal6#, "0.000000X", 9 )  
               Wend
            Case TC_XFMR		' Xfmr
               If GetData( nBrHnd&, XR_sID, StringVal1$ ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, XR_sName, StringVal2$ ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, XR_nBus1Hnd, IntVal1& ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, XR_nBus2Hnd, IntVal2& ) = 0 Then GoTo HasError
               Print #1, Space( 4 - Len(StringVal1$) ), StringVal1$ ; "T "; _
                         FullBusName( IntVal1& ); " -"; FullBusName( IntVal2& ); " "; StringVal2$
               If GetData( nBrHnd&, XR_dR,  DblVal1# ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, XR_dX,  DblVal2# ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, XR_dB,  DblVal3# ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, XR_dPriTap, DblVal4# ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, XR_dSecTap, DblVal5# ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, XR_sCfgP,   StringVal1$ ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, XR_sCfgS,   StringVal2$ ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, XR_sCfgST,  StringVal3$ ) = 0 Then GoTo HasError
               Print #1, "      "; frmt( DblVal1#, "0.000000R", 9 ) ; _
                         "   "; frmt( DblVal2#, "0.000000X", 9 )  ; _
                         "   "; frmt( DblVal3#, "0.000000B", 9 ) ; _
                         "   "; frmt( DblVal4#, "0.00PTAP", 6 ) ; _
                         "  ";  frmt( DblVal5#, "0.00STAP", 6 ) ; _ 
                         " "; StringVal1$; StringVal2$; " G"; StringVal3$; "-CONFIG"
               If GetData( nBrHnd&, XR_dR0,  DblVal1# ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, XR_dX0,  DblVal2# ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, XR_dB0, DblVal3# ) = 0 Then GoTo HasError
               Print #1, "      "; frmt( DblVal1#, "0.0000000R\0", 9 ) ; _
                         "  ";     frmt( DblVal2#, "0.0000000X\0", 9 )  ; _
                         "  ";     frmt( DblVal3#, "0.0000000B\0", 9 )
               If GetData( nBrHnd&, XR_dRG1,  DblVal1# ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, XR_dXG1,  DblVal2# ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, XR_dRG2, DblVal3# ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, XR_dXG2, DblVal4# ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, XR_dRGN, DblVal5# ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, XR_dXGN, DblVal6# ) = 0 Then GoTo HasError
               Print #1, "      "; frmt( DblVal1#, "0.##RG1", 13 ) ; _
                         "  ";     frmt( DblVal2#, "0.##XG1", 13 ) ; _
                         "  ";     frmt( DblVal3#, "0.##RG2", 13 ) ; _
                         "  ";     frmt( DblVal4#, "0.##XG2", 13 ) ; _
                         "  ";     frmt( DblVal5#, "0.##RGN", 13 ) ; _
                         "  ";     frmt( DblVal6#, "0.##XGN", 13 )
            Case TC_PS		' Phase shifter
               If GetData(  nBrHnd&,  PS_sID, StringVal1$ ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, PS_sName, StringVal2$ ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, PS_nBus1Hnd, IntVal1& ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, PS_nBus2Hnd, IntVal2& ) = 0 Then GoTo HasError
               Print #1, Space( 4 - Len(StringVal1$) ), StringVal1$ ; "P "; _
                         FullBusName( IntVal1& ); " -"; FullBusName( IntVal2& ); " "; StringVal2$
               If GetData( nBrHnd&, PS_dR,     DblVal1# ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, PS_dX,     DblVal2# ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, PS_dB,     DblVal3# ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, PS_dAngle, DblVal4# ) = 0 Then GoTo HasError
               Print #1, "      "; frmt( DblVal1#, "0.000000R", 9 ) ; _
                         "   ";     frmt( DblVal2#, "0.000000X", 9 ) ; _
                          "  ";     frmt( DblVal3#, "0.000000B", 9 ) ; _
                         "   ";     frmt( DblVal4#, "0.00Deg\.", 9 )
               If GetData( nBrHnd&, PS_dR0,  DblVal1# ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, PS_dX0,  DblVal2# ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, PS_dB0,  DblVal3# ) = 0 Then GoTo HasError
               Print #1, "      "; frmt( DblVal1#, "0.0000000R\0", 9 ) ; _
                         "  ";     frmt( DblVal2#, "0.0000000X\0", 9 )  ; _
                          " ";     frmt( DblVal3#, "0.0000000B\0", 9 )
            Case Else	' 3W Xfmr
               If GetData( nBrHnd&,  X3_sID, StringVal1$ ) = 0 Then GoTo HasError
               If GetData( nBrHnd&,  X3_sName, StringVal2$ ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, X3_nBus1Hnd, IntVal1& ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, X3_nBus2Hnd, IntVal2& ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, X3_nBus3Hnd, nVal3& ) = 0 Then GoTo HasError
               Print #1, Space( 4 - Len(StringVal1$) ), StringVal1$ ; "X "; FullBusName( IntVal1& ); " -"; _
                         FullBusName( IntVal2& ); " -"; FullBusName( nVal3& ); " "; StringVal2$
               If GetData( nBrHnd&, X3_dRps,     DblVal1# ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, X3_dXps,     DblVal2# ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, X3_dRpt,     DblVal3# ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, X3_dXpt,     DblVal4# ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, X3_dRst,     DblVal5# ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, X3_dXst,     DblVal6# ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, X3_dB,       DblVal7# ) = 0 Then GoTo HasError
               Print #1, "      ";  frmt( DblVal1#, "0.000000RPS", 11 ) ; _
                         "   ";     frmt( DblVal2#, "0.000000XPS", 11 ) ; _
                         "   ";     frmt( DblVal3#, "0.000000RPT", 11 ) ; _
                         "   ";     frmt( DblVal4#, "0.000000XPT", 11 ) ; _
                         "   ";     frmt( DblVal5#, "0.000000RST", 11 ) ; _
                         "   ";     frmt( DblVal6#, "0.000000XST", 11 ) ; _
                         "  ";      frmt( DblVal7#, "0.000000B",   11 )
               If GetData( nBrHnd&, X3_dR0ps,     DblVal1# ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, X3_dX0ps,     DblVal2# ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, X3_dR0pt,     DblVal3# ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, X3_dX0pt,     DblVal4# ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, X3_dR0st,     DblVal5# ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, X3_dX0st,     DblVal6# ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, X3_dB0,       DblVal7# ) = 0 Then GoTo HasError
               Print #1, "      "; frmt( DblVal1#, "0.0000000RPS\0", 11 ) ; _
                         "  ";     frmt( DblVal2#, "0.0000000XPS\0", 11 ) ; _
                         "  ";     frmt( DblVal3#, "0.0000000RPT\0", 11 ) ; _
                         "  ";     frmt( DblVal4#, "0.0000000XPT\0", 11 ) ; _
                         "  ";     frmt( DblVal5#, "0.0000000RST\0", 11 ) ; _
                         "  ";     frmt( DblVal6#, "0.0000000XST\0", 11 ) ; _
                         " ";      frmt( DblVal7#, "0.0000000B\0",   11 )
               If GetData( nBrHnd&, X3_dPriTap, DblVal1# ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, X3_dSecTap, DblVal2# ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, X3_dTerTap, DblVal3# ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, X3_sCfgP,   StringVal1$ ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, X3_sCfgS,   StringVal2$ ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, X3_sCfgT,   StringVal3$ ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, X3_sCfgST,  StringVal4$ ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, X3_sCfgTT,  StringVal5$ ) = 0 Then GoTo HasError
               Print #1, "      "; frmt( DblVal1#, "0.0PTAP", 6 ) ; _
                         "   ";    frmt( DblVal2#, "0.0STAP", 6 ) ; _ 
                         "   ";    frmt( DblVal3#, "0.0TTAP", 6 ) ; _ 
                         "  "; StringVal1$; StringVal2$; StringVal3$; " G"; StringVal4$; StringVal5$; "-CONFIG"
               If GetData( nBrHnd&, X3_dRG1, DblVal1# ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, X3_dXG1, DblVal2# ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, X3_dRG2, DblVal3# ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, X3_dXG2, DblVal4# ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, X3_dRGN, DblVal5# ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, X3_dXGN, DblVal6# ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, X3_dRG3, DblVal7# ) = 0 Then GoTo HasError
               If GetData( nBrHnd&, X3_dXG3, DblVal8# ) = 0 Then GoTo HasError
               Print #1, "      "; frmt( DblVal1#, "0RG1", 13 ) ; _
                         "  ";     frmt( DblVal2#, "0XG1", 13 ) ; _
                         "  ";     frmt( DblVal3#, "0RG2", 13 ) ; _
                         "  ";     frmt( DblVal4#, "0XG2", 13 ) ; _
                         "  ";     frmt( DblVal5#, "0RGN", 13 ) ; _
                         "  ";     frmt( DblVal6#, "0XGN", 13 ) ; _
                         "  ";     frmt( DblVal7#, "0RG3", 13 ) ; _
                         "  ";     frmt( DblVal8#, "0XG3", 13 )
         End Select
      Wend
      Print #1, ""
   Wend
   Print "Report written successfully"
   Close
   Stop
   HasError:
   Print "Error: ", ErrorString( )
   Close 
   Stop
End Sub

' ===================== Dialog box spec (generated by Dialog Editor) ==========
'
   Begin Dialog Dialog_1 49,60, 202, 56, "Output File"
      Text 24,12,56,12, "Enter file name: "
      TextBox 84,12,84,12, .EditBox_1
      OKButton 44,36,52,12
      CancelButton 108,36,48,12
   End Dialog
'
' ===================== InputDialog() =========================================
' Purpose:
'   Get Fault spec. inputs from user
Function OpenOutput() As Long
   Dim dlg As Dialog_1
   Dlg.EditBox_1 = "c:\0tmp\a2.rep"         ' Default name
   ' Dialog returns -1 for OK, 0 for Cancel, button # for PushButtons
   button = Dialog( Dlg )
   If button = 0 Then 
     OpenOutput = 0
     Exit Function
   End If
   fileName = Dlg.EditBox_1
   Open fileName For Output As #1
   OpenOutput = 1
End Function
'
' ===================== frmt() ================================================
' Purpose:
'   Return right aligned numval which is formated according to Fmt$
Function frmt( numVal As Variant, Fmt$, wd& ) As String
  slen& = Len( Format(numVal,Fmt$) )
  If slen& < wd& Then nsp& = wd& - slen& Else nsp& = 1
  frmt = Space( nsp& ) & Format(numVal,Fmt$)
End Function 