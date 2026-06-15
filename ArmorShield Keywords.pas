unit UserScript;

function Process(e: IInterface): integer;
var
  flagsElement, kwda, newKw, kwItem: IInterface;
  armorType: string;
  targetKwString: string;
  i: integer;
begin
  Result := 0;

  if Signature(e) <> 'ARMO' then Exit;

  flagsElement := ElementByPath(e, 'BOD2\First Person Flags\39 - Shield');
  
  if Assigned(flagsElement) and (GetEditValue(flagsElement) = '1') then begin
    armorType := GetElementEditValues(e, 'BOD2\Armor Type');
    
    if armorType = 'Heavy Armor' then
      targetKwString := 'ArmorShield_Heavy [KYWD:01CD112B]'
    else if armorType = 'Light Armor' then
      targetKwString := 'ArmorShield_Light [KYWD:01CD112C]'
    else 
      Exit;

    kwda := ElementByPath(e, 'KWDA');
    if Assigned(kwda) then begin
      for i := 0 to ElementCount(kwda) - 1 do begin
        kwItem := ElementByIndex(kwda, i);
        if GetEditValue(kwItem) = targetKwString then 
          Exit;
      end;
    end else begin
      kwda := Add(e, 'KWDA', True);
    end;

    AddMasterIfMissing(GetFile(e), 'Update.esm');
    
    if Assigned(kwda) then begin
      newKw := ElementAssign(kwda, HighInteger, nil, False);
      if Assigned(newKw) then
        SetEditValue(newKw, targetKwString);
    end;
  end;
end;

end.
