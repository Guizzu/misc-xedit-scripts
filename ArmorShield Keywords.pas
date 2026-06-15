{
  Add Keywords for ArmorShield_Heavy/ArmorShield_Light as necessary
  Created by Guizz
  v1.0
}

unit UserScript;

function Process(e: IInterface): integer;
var
  flagsElement: IInterface;
  armorType: string;
begin
  Result := 0;

  if Signature(e) <> 'ARMO' then Exit;

  flagsElement := ElementByPath(e, 'BOD2\First Person Flags\39 - Shield');
  
  if Assigned(flagsElement) and (GetEditValue(flagsElement) = '1') then begin
    AddMasterIfMissing(GetFile(e), 'Update.esm');
    armorType := GetElementEditValues(e, 'BOD2\Armor Type');
    
    if armorType = 'Heavy Armor' then
      SetEditValue(ElementByPath(e, 'KWDA\Keyword'), 'ArmorShield_Heavy [KYWD:01CD112B]');

    if armorType = 'Light Armor' then
      SetEditValue(ElementByPath(e, 'KWDA\Keyword'), 'ArmorShield_Light [KYWD:01CD112C]');
  end;
end;

end.
