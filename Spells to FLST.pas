{
  Create FormID Lists for selected Spells
  Created by Guizz
  v1.0
}

unit UserScript;

var
  ToFile: IInterface;

function Process(e: IInterface): integer;
var
  i: integer;
  frm: TForm;
  clb: TCheckListBox;
  mflst, baseflst, eff, formids, mname: IInterface;
begin
  if Signature(e) = 'TES4' then
    Exit;
    
  if not Assigned(ToFile) then begin
    frm := frmFileSelect;
    try
      frm.Caption := 'Select a plugin';
      clb := TCheckListBox(frm.FindComponent('CheckListBox1'));
      clb.Items.Add('<new file>');
      for i := Pred(FileCount) downto 0 do
        if GetFileName(e) <> GetFileName(FileByIndex(i)) then
          clb.Items.InsertObject(1, GetFileName(FileByIndex(i)), FileByIndex(i))
        else
          Break;
      if frm.ShowModal <> mrOk then begin
        Result := 1;
        Exit;
      end;
      for i := 0 to Pred(clb.Items.Count) do
        if clb.Checked[i] then begin
          if i = 0 then ToFile := AddNewFile else
            ToFile := ObjectToElement(clb.Items.Objects[i]);
          Break;
        end;
    finally
      frm.Free;
    end;
    if not Assigned(ToFile) then begin
      Result := 1;
      Exit;
    end;
  end;

  // Check if 'SPEL'
  if Signature(e) <> 'SPEL' then
    Exit;

  // Get Effect
  eff := GetElementEditValues(LinksTo(ElementByPath(ElementByIndex(ElementByName(e, 'Effects'), 0), 'EFID')), 'Magic Effect Data\DATA\Magic Skill');
  if not Assigned(eff) then
    Exit;
  if eff = 'None' then
    Exit;

  // Set Name
  mname := 'MFLST_' + eff;
  AddMessage(GetElementEditValues(e, 'SPIT\Cast Type'));
  if GetElementEditValues(e, 'SPIT\Cast Type') = 'Concentration' then
    mname := 'MFLST_Concentration';   

  // Add Required Masters
  AddRequiredElementMasters(e, ToFile, False);

  // Get or Create MFLST Record
  mflst := MainRecordByEditorID(GroupBySignature(ToFile, 'FLST'), mname);
  if not Assigned(mflst) then begin
    // Get Base FLST Record
    baseflst := RecordByFormID(FileByIndex(0), $00000D14, True);
    mflst := wbCopyElementToFile(baseflst, ToFile, True, True);
    SetElementEditValues(mflst, 'EDID', mname);
    Add(mflst, 'FormIDs', False);
  end;

  // Add Element to FormID List
  formids := ElementByPath(mflst, 'FormIDs');
  SetEditValue(ElementAssign(formids, HighInteger, nil, False), Name(e));
  if not Assigned(LinksTo(ElementByIndex(formids, 0))) then
    RemoveByIndex(formids, 0, False);

end;

end.