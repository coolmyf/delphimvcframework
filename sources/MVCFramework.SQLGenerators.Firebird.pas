// *************************************************************************** }
//
// Delphi MVC Framework
//
// Copyright (c) 2010-2019 Daniele Teti and the DMVCFramework Team
//
// https://github.com/danieleteti/delphimvcframework
//
// ***************************************************************************
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// ***************************************************************************

unit MVCFramework.SQLGenerators.Firebird;

interface

uses
  System.Rtti,
  System.Generics.Collections,
  FireDAC.Phys.FB,
  FireDAC.Phys.FBDef,
  MVCFramework.ActiveRecord,
  MVCFramework.Commons,
  MVCFramework.RQL.Parser;

type
  TMVCSQLGeneratorFirebird = class(TMVCSQLGenerator)
  protected
    function GetCompilerClass: TRQLCompilerClass; override;
  public
    function CreateSelectSQL(
      const TableName: string;
      const Map: TDictionary<TRttiField, string>;
      const PKFieldName: string;
      const PKOptions: TMVCActiveRecordFieldOptions): string; override;
    function CreateInsertSQL(
      const TableName: string;
      const Map: TDictionary<TRttiField, string>;
      const PKFieldName: string;
      const PKOptions: TMVCActiveRecordFieldOptions): string; override;
    function CreateUpdateSQL(
      const TableName: string;
      const Map: TDictionary<TRttiField, string>;
      const PKFieldName: string;
      const PKOptions: TMVCActiveRecordFieldOptions): string; override;
    function CreateDeleteSQL(
      const TableName: string;
      const Map: TDictionary<TRttiField, string>;
      const PKFieldName: string;
      const PKOptions: TMVCActiveRecordFieldOptions;
      const PrimaryKeyValue: Int64): string; override;
    function CreateSelectByPKSQL(
      const TableName: string;
      const Map: TDictionary<TRttiField, string>; const PKFieldName: string;
      const PKOptions: TMVCActiveRecordFieldOptions;
      const PrimaryKeyValue: Int64): string; override;
    function CreateSelectSQLByRQL(
      const RQL: string;
      const Mapping: TMVCFieldsMapping): string; override;
    function CreateSelectCount(
      const TableName: String): String; override;
  end;

implementation

uses
  System.SysUtils,
  MVCFramework.RQL.AST2FirebirdSQL;

function TMVCSQLGeneratorFirebird.CreateInsertSQL(const TableName: string; const Map: TDictionary<TRttiField, string>;
  const PKFieldName: string; const PKOptions: TMVCActiveRecordFieldOptions): string;
var
  lKeyValue: TPair<TRttiField, string>;
  lSB: TStringBuilder;
begin
  lSB := TStringBuilder.Create;
  try
    lSB.Append('INSERT INTO ' + TableName + '(');
    for lKeyValue in Map do
      lSB.Append(lKeyValue.value + ',');
    lSB.Remove(lSB.Length - 1, 1);
    lSB.Append(') values (');
    for lKeyValue in Map do
    begin
      lSB.Append(':' + lKeyValue.value + ',');
    end;
    lSB.Remove(lSB.Length - 1, 1);
    lSB.Append(')');

    if TMVCActiveRecordFieldOption.foAutoGenerated in PKOptions then
    begin
      lSB.Append(' RETURNING ' + PKFieldName);
      // case GetBackEnd of
      // cbFirebird:
      // begin
      // lSB.Append(' RETURNING ' + fPrimaryKeyFieldName);
      // end;
      // cbMySQL:
      // begin
      // lSB.Append(';SELECT LAST_INSERT_ID() as ' + fPrimaryKeyFieldName);
      // end;
      // else
      // raise EMVCActiveRecord.Create('Unsupported backend engine');
      // end;
    end;
    Result := lSB.ToString;
  finally
    lSB.Free;
  end;
end;

function TMVCSQLGeneratorFirebird.CreateSelectByPKSQL(
  const TableName: string;
  const Map: TDictionary<TRttiField, string>; const PKFieldName: string;
  const PKOptions: TMVCActiveRecordFieldOptions;
  const PrimaryKeyValue: Int64): string;
begin
  Result := CreateSelectSQL(TableName, Map, PKFieldName, PKOptions) + ' WHERE ' +
    PKFieldName + '= :' + PKFieldName; // IntToStr(PrimaryKeyValue);
end;

function TMVCSQLGeneratorFirebird.CreateSelectCount(
  const TableName: String): String;
begin
  Result := 'SELECT count(*) FROM ' + TableName;
end;

function TMVCSQLGeneratorFirebird.CreateSelectSQL(const TableName: string;
  const Map: TDictionary<TRttiField, string>; const PKFieldName: string;
  const PKOptions: TMVCActiveRecordFieldOptions): string;
begin
  Result := 'SELECT ' + TableFieldsDelimited(Map, PKFieldName, ',') + ' FROM ' + TableName;
end;

function TMVCSQLGeneratorFirebird.CreateSelectSQLByRQL(const RQL: string;
  const Mapping: TMVCFieldsMapping): string;
var
  lFirebirdCompiler: TRQLFirebirdCompiler;
begin
  lFirebirdCompiler := TRQLFirebirdCompiler.Create(Mapping);
  try
    GetRQLParser.Execute(RQL, Result, lFirebirdCompiler);
  finally
    lFirebirdCompiler.Free;
  end;
end;

function TMVCSQLGeneratorFirebird.CreateUpdateSQL(const TableName: string; const Map: TDictionary<TRttiField, string>;
  const PKFieldName: string; const PKOptions: TMVCActiveRecordFieldOptions): string;
var
  keyvalue: TPair<TRttiField, string>;
begin
  Result := 'UPDATE ' + TableName + ' SET ';
  for keyvalue in Map do
  begin
    Result := Result + keyvalue.value + ' = :' + keyvalue.value + ',';
  end;
  Result[Length(Result)] := ' ';
  if not PKFieldName.IsEmpty then
  begin
    Result := Result + ' where ' + PKFieldName + '= :' + PKFieldName;
  end;
end;

function TMVCSQLGeneratorFirebird.GetCompilerClass: TRQLCompilerClass;
begin
  Result := TRQLFirebirdCompiler;
end;

function TMVCSQLGeneratorFirebird.CreateDeleteSQL(const TableName: string; const Map: TDictionary<TRttiField, string>;
  const PKFieldName: string; const PKOptions: TMVCActiveRecordFieldOptions; const PrimaryKeyValue: Int64): string;
begin
  Result := 'DELETE FROM ' + TableName + ' WHERE ' + PKFieldName + '= ' + IntToStr(PrimaryKeyValue);
end;

initialization

TMVCSQLGeneratorRegistry.Instance.RegisterSQLGenerator('firebird', TMVCSQLGeneratorFirebird);
TMVCSQLGeneratorRegistry.Instance.RegisterSQLGenerator('interbase', TMVCSQLGeneratorFirebird);

finalization

TMVCSQLGeneratorRegistry.Instance.UnRegisterSQLGenerator('firebird');
TMVCSQLGeneratorRegistry.Instance.UnRegisterSQLGenerator('interbase');

end.
