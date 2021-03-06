' ASPEN PowerScript sample program
'
' PERUNIT1.BAS
'
' Per-Unit calculator
' 
' PowerScript functions called:
'   GetEquipment()
'   GetData()
'
' ===================== Dialog box spec (generated by Dialog Editor) ==========
'
Begin Dialog PUDLG 17,16, 139, 111, "PU Calculator "
  Text 28,40,20,12, "Ohm"
  TextBox 16,52,36,12, .Ohm
  PushButton 4,68,56,12, "Ohm   ->  PU", .Convert1
  TextBox 84,52,36,12, .PU
  Text 96,40,12,12, "p.u."
  PushButton 76,68,56,12, "Ohm   <-  PU", .Convert2
  Text 8,8,64,12, "Base MVA (3PH) ="
  TextBox 76,8,36,12, .BaseMVA
  Text 20,24,52,12, "Base kV (L-L) ="
  TextBox 76,24,36,12, .BasekV
  PushButton 48,92,40,12, "Done ", .Done
End Dialog
'
' ===================== main() ================================================
'
Sub main()
  Dim dlg As PUDLG
  ' Get system MVA
  If GetData( HND_SYS, SY_dBaseMVA, BaseMVA ) = 0 Then BaseMVA = 0
  ' Figure out kV base from picked object
  If 0 <> GetEquipment( TC_PICKED, PickedHnd ) Then
    ' Probe to see what's being picked
    Select Case EquipmentType( PickedHnd )
      Case TC_LINE
        If 0 = GetData( PickedHnd, LN_nBus1Hnd, nBusHnd& ) Then GoTo HasError
        If 0 = GetData( nBusHnd&, BUS_dKVNorminal, BaseKV ) Then GoTo HasError
      Case TC_BUS
        If 0=GetData( PickedHnd, BUS_dKVNorminal, BaseKV ) Then GoTo HasError
    End Select
    dlg.BasekV  = BaseKV
  End If
  ' Put BaseMVA and L-L Voltage in dialog box
  dlg.BaseMVA = BaseMVA
  ' Bring up the dialog
  Do
    button = Dialog( dlg )
    If button = 3 Then Exit Do ' Done
    BaseZ = dlg.BaseKV * dlg.BaseKV / dlg.BaseMVA
    If button = 1 Then 
       dlg.PU = dlg.Ohm / BaseZ
    Else
       dlg.Ohm = dlg.PU * BaseZ
    End If
  Loop 
Exit Sub
  ' Error handling
  HasError:
  Print "Error: ", ErrorString( )
End Sub  ' End of Sub Main()