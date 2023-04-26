{
  Create Books for selected Spells
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
  book, brec: IInterface;
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

  // Add Required Masters
  AddRequiredElementMasters(e, ToFile, False);

  // Get base BOOK record
  brec := RecordByFormID(FileByIndex(0), $000A2706, True);

  // Add Book
  book := wbCopyElementToFile(brec, ToFile, True, True);
  SetElementEditValues(book, 'EDID', 'SpellTome'+GetElementEditValues(e, 'EDID'));
  SetElementEditValues(book, 'FULL', 'Spell Tome: '+GetElementEditValues(e, 'FULL'));
  SetElementEditValues(book, 'DESC', '<font face''$HandwrittenFont''><font size=''40''><p align=''center''> ' + GetElementEditValues(e, 'FULL'));
  SetElementEditValues(book, 'DATA\Spell', IntToHex(GetLoadOrderFormID(e), 8));

end;

end.