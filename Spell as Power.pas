{
  Create Powers and Books for selected Spells then adds Books to Leveled Lists accordingly
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
  spel, book, brec, llrec, llcopy: IInterface;
  refs: TList;
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

  // Check if "Cast Type" is not "Concentration"
  if GetElementEditValues(e, 'SPIT\Cast Type') = 'Concentration' then
    Exit;

  // Check if "SPEL" has "BOOK"
  for i := 0 to Pred(ReferencedByCount(e)) do begin
    if Signature(ReferencedByIndex(e, i)) = 'BOOK' then begin
      brec := ReferencedByIndex(e, i);
      Break;
    end;
  end;
  if not Assigned(brec) then
    Exit;

  // Add Required Masters
  AddRequiredElementMasters(e, ToFile, False);

  // Add Power
  spel := wbCopyElementToFile(e, ToFile, True, True);
  SetElementEditValues(spel, 'EDID', GetElementEditValues(e, 'EDID') + 'Power');
  SetElementEditValues(spel, 'ETYP', '00025BEE');
  SetElementEditValues(spel, 'SPIT\Type', 'Lesser Power');

  // Add Book
  book := wbCopyElementToFile(brec, ToFile, True, True);
  SetElementEditValues(book, 'EDID', GetElementEditValues(brec, 'EDID') + 'Power');
  SetElementEditValues(book, 'FULL', GetElementEditValues(brec, 'FULL') + ' (Power)');
  SetElementEditValues(book, 'DESC', GetElementEditValues(brec, 'DESC') + ' (Power)');
  SetElementEditValues(book, 'DATA\Spell', IntToHex(GetLoadOrderFormID(spel), 8));

  // Add Book to Leveled Lists
  refs := TList.Create;
  try
    // Store LL References
    for i := 0 to Pred(ReferencedByCount(brec)) do
      if (Signature(ReferencedByIndex(brec, i)) = 'LVLI') and (GetFileName(ToFile) <> GetFileName(ReferencedByIndex(brec, i))) then
        refs.Add(ReferencedByIndex(brec, i));

    // Copy LL References
    for i := 0 to Pred(refs.Count) do begin
      llcopy := wbCopyElementToFile(ObjectToElement(refs[i]), ToFile, False, True);
      llrec := ElementAssign(ElementByName(llcopy, 'Leveled List Entries'), LowInteger, ElementByIndex(ElementByName(llcopy, 'Leveled List Entries'), 0), False);
      SetElementEditValues(llrec, 'LVLO\Reference', IntToHex(GetLoadOrderFormID(book), 8));
    end;
  finally
    refs.Free;
  end;
end;

end.