﻿// ***************************************************************************
//
// Delphi MVC Framework
//
// Copyright (c) 2010-2019 Daniele Teti and the DMVCFramework Team
//
// https://github.com/danieleteti/delphimvcframework
//
// Collaborators with this file: Ezequiel Juliano Müller (ezequieljuliano@gmail.com)
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

unit RenderSampleControllerU;

interface

uses
  MVCFramework,
  MVCFramework.Commons,
  MVCFramework.Serializer.Intf,
  System.Rtti;

type

  [MVCPath('/')]
  TRenderSampleController = class(TMVCController)
  protected
    procedure OnBeforeAction(AContext: TWebContext; const AActionName: string;
      var AHandled: Boolean); override;
  public
    [MVCHTTPMethod([httpGET])]
    [MVCPath('/customers/($id)')]
    [MVCProduces('text/plain')]
    procedure GetPerson_AsText(const id: Integer);

    [MVCHTTPMethod([httpGET])]
    [MVCPath('/customers/hateoas')]
    [MVCProduces('application/json')]
    procedure GetCustomers_AsDataSet_HATEOAS;

    [MVCHTTPMethod([httpGET])]
    [MVCPath('/customers')]
    [MVCProduces('application/json')]
    procedure GetCustomers_AsDataSet;

    [MVCHTTPMethod([httpGET])]
    [MVCPath('/customers/metadata')]
    [MVCProduces('application/json')]
    procedure GetDataSetWithMetadata;

    [MVCHTTPMethod([httpGET])]
    [MVCPath('/multi')]
    [MVCProduces('application/json')]
    procedure GetCustomersAndCountry_AsDataSet;

    [MVCHTTPMethod([httpGET])]
    [MVCPath('/people')]
    [MVCProduces('application/json')]
    procedure GetPeople_AsObjectList;

    [MVCHTTPMethod([httpGET])]
    [MVCPath('/people/hateoas')]
    [MVCProduces('application/json')]
    procedure GetPeople_AsObjectList_HATEOAS;

    [MVCHTTPMethod([httpGET])]
    [MVCPath('/people/withtiming')]
    [MVCProduces('application/json')]
    procedure GetPeopleWithTiming;

    [MVCHTTPMethod([httpGET])]
    [MVCPath('/people/($id)')]
    [MVCProduces('application/json')]
    procedure GetPersonById(const id: Integer);

    [MVCHTTPMethod([httpGET])]
    [MVCPath('/lotofobjects')]
    procedure GetLotOfPeople;

    // this action is polymorphic
    [MVCHTTPMethod([httpGET])]
    [MVCPath('/skilledpeople')]
    [MVCProduces('application/json')]
    procedure GetProgrammersAndPhilosophersAsObjectList;

    [MVCHTTPMethod([httpGET])]
    [MVCPath('/customers/view/($id).html')]
    [MVCProduces('text/html', 'UTF-8')]
    procedure GetPerson_AsHTMLView;

    [MVCHTTPMethod([httpGET])]
    [MVCPath('/customers/($id).html')]
    [MVCProduces('text/html')]
    procedure GetPerson_AsHTML;

    [MVCHTTPMethod([httpGET])]
    [MVCPath('/customers.csv')]
    procedure GetPeopleAsCSV;

    [MVCHTTPMethod([httpGET])]
    [MVCPath('/customers/unicode/($id).html')]
    [MVCProduces('text/html', 'UTF-8')]
    procedure GetUnicodeText_AsHTML;

    [MVCHTTPMethod([httpGET])]
    [MVCPath('/customers/($id)')]
    [MVCProduces('application/json')]
    procedure GetCustomerByID_AsTObject(const id: Integer);

    [MVCHTTPMethod([httpGET])]
    [MVCPath('/files/customers.json')]
    [MVCProduces('application/json')]
    procedure GetPersonJSON;

    [MVCHTTPMethod([httpGET])]
    [MVCPath('/files/customers.png')]
    [MVCProduces('image/png')]
    procedure GetPersonPhoto;

    [MVCHTTPMethod([httpGET])]
    [MVCPath('/images/customers/($id)')]
    procedure GetPersonPhotoAsStream;

    [MVCHTTPMethod([httpPOST])]
    [MVCConsumes(TMVCMediaType.MULTIPART_FORM_DATA)]
    [MVCPath('/files')]
    procedure UploadBinaryData;

    [MVCHTTPMethod([httpGET])]
    [MVCPath('/files/($filename)')]
    procedure GetBinaryData(const filename: string);

    [MVCHTTPMethod([httpGET])]
    [MVCPath('/exception')]
    procedure RaiseException;

    [MVCHTTPMethod([httpGET])]
    [MVCPath('/customserializationtype')]
    procedure GetCustomSerializationType;

  end;

implementation

uses
  BusinessObjectsU,
  Generics.Collections,
  MVCFramework.DataSet.Utils,
  MVCFramework.Serializer.Commons,
  MVCFramework.Serializer.Defaults,
  MVCFramework.Logger,
  MyDataModuleU,
  System.IOUtils,
  System.Classes,
  System.SysUtils,
  WebModuleU,
  CustomTypesU,
  InMemoryDataU,
  JsonDataObjects,
  MVCFramework.Serializer.JsonDataObjects,
  Data.DB,
  Web.HTTPApp;

{ TRoutingSampleController }

procedure TRenderSampleController.GetUnicodeText_AsHTML;
var
  s: string;
begin
  s := '<html><body>';
  s := s + '什么是Unicode(统一码)? in Simplified Chinese <br>';
  s := s + 'Što je Unicode? in Croatian <br>';
  s := s + 'Co je Unicode? in Czech';
  s := s + '</body></html>';
  Render(s);
end;

procedure TRenderSampleController.OnBeforeAction(AContext: TWebContext; const AActionName: string;
  var AHandled: Boolean);
begin
  inherited;

end;

procedure TRenderSampleController.RaiseException;
var
  a: Integer;
begin
  a := 0;
  Render(IntToStr(10 div a));
end;

procedure TRenderSampleController.UploadBinaryData;
var
  lFile: TAbstractWebRequestFile;
  lFileExt: string;
  lOutputFileName: string;
  lOutputFullPath: string;
  lOutFile: TFileStream;
  lOutputFolder: string;
begin
  if Context.Request.Files.Count <> 1 then
  begin
    raise EMVCException.Create(HTTP_STATUS.BadRequest, 'Expected exactly 1 file');
  end;
  lFile := Context.Request.Files[0];

  LogI(Format('Upload: [FieldName: %s] [FileName: %s] [ContentType: %s] [Size: %d bytes]',
    [lFile.FieldName, lFile.filename, lFile.ContentType, lFile.Stream.Size]));

  { Be sure that our data directory always exists. We could also do it in the server startup. }
  lOutputFolder := TPath.Combine(AppPath, 'uploadedfiles');
  if not TDirectory.Exists(lOutputFolder) then
  begin
    TDirectory.CreateDirectory(lOutputFolder);
  end;

  lFileExt := TPath.GetExtension(lFile.filename);
  {
    Here we could check for allowed extensions or check the file contents looking for
    accepted file headers (e.g. Zip, PNG, BMP, TIFF etc).
    In this case we just use the extension of the filename sent by the client.
  }

  { Find a valid random filename to store the stream on disk. }
  repeat
    lOutputFileName := TPath.ChangeExtension(TPath.GetRandomFileName, lFileExt);
    lOutputFullPath := TPath.Combine(lOutputFolder, lOutputFileName);
  until not TFile.Exists(lOutputFullPath);

  lOutFile := TFileStream.Create(lOutputFullPath, fmCreate);
  try
    lOutFile.CopyFrom(lFile.Stream, 0);
  finally
    lOutFile.Free;
  end;

  { Inform the client about the name assigned to the file
    on disk and how to retrieve it. }
  Context.Response.ContentType := TMVCMediaType.APPLICATION_JSON;
  Context.Response.StatusCode := HTTP_STATUS.OK;
  Render(Dict(['filename', 'ref'], [lOutputFileName, '/files/' + lOutputFileName]));
end;

procedure TRenderSampleController.GetBinaryData(const filename: string);
var
  lFilesFolder: string;
  lFullFilePath: string;
begin
  lFilesFolder := TPath.Combine(AppPath, 'uploadedfiles');
  lFullFilePath := TPath.Combine(lFilesFolder, filename);
  if not TFile.Exists(lFullFilePath) then
  begin
    raise EMVCException.Create('File not found');
  end;
  Context.Response.ContentType := TMVCMediaType.APPLICATION_OCTET_STREAM;
  Context.Response.StatusCode := HTTP_STATUS.OK;
  Context.Response.CustomHeaders.Values['Content-Disposition'] := 'attachment; filename=' +
    filename + ';';
  Render(TFileStream.Create(lFullFilePath, fmOpenRead or fmShareDenyNone));
end;

procedure TRenderSampleController.GetCustomerByID_AsTObject(const id: Integer);
var
  Cust: TCustomer;
begin
  if id = 7 then // just a sample
    Render(HTTP_STATUS.NotFound, 'Customer Not Found')
  else
  begin
    Cust := TCustomer.Create;
    Cust.Name := 'Daniele Teti Inc.';
    Cust.ContactFirst := 'Daniele';
    Cust.ContactLast := 'Teti';
    Cust.AddressLine1 := 'Rome Street 12';
    Cust.AddressLine2 := '00100';
    Cust.City := 'ROME';
    Render(Cust);
  end;
end;

procedure TRenderSampleController.GetCustomersAndCountry_AsDataSet;
var
  lDM: TMyDataModule;
  lJObj: TJSONObject;
  lSer: TMVCJsonDataObjectsSerializer;
begin
  lDM := TMyDataModule.Create(nil);
  try
    lDM.qryCustomers.Open;
    lDM.qryCountry.Open;

    lJObj := TJSONObject.Create;
    try
      // We need a non standard representation, let's create a specific serializer.
      lSer := TMVCJsonDataObjectsSerializer.Create;
      try
        lSer.DataSetToJsonArray(lDM.qryCustomers, lJObj.a['customers'],
          TMVCNameCase.ncLowerCase, []);
        lSer.DataSetToJsonArray(lDM.qryCountry, lJObj.a['countries'], TMVCNameCase.ncLowerCase, []);
      finally
        lSer.Free;
      end;
      Render(lJObj);
    except // avoid memory leaks in case of exceptions
      lJObj.Free;
      raise;
    end;
  finally
    lDM.Free;
  end;
end;

procedure TRenderSampleController.GetCustomers_AsDataSet;
var
  lDM: TMyDataModule;
begin
  lDM := TMyDataModule.Create(nil);
  try
    lDM.qryCustomers.Open;
    Render(lDM.qryCustomers, False);
  finally
    lDM.Free;
  end;
end;

procedure TRenderSampleController.GetCustomers_AsDataSet_HATEOAS;
var
  lDM: TMyDataModule;
begin
  lDM := TMyDataModule.Create(nil);
  try
    lDM.qryCustomers.Open;
    Render(lDM.qryCustomers, False,
      procedure(const DS: TDataset; const Links: TMVCStringDictionary)
      begin
        Links['x-ref'] := '/api/customers/' + DS.FieldByName('cust_no').AsString;
      end);
  finally
    lDM.Free;
  end;
end;

procedure TRenderSampleController.GetCustomSerializationType;
begin
  // TSysUser contains a type with a custom serializer
  Render(TSysUser.Create('daniele', ['poweruser', 'role1', 'role2']), True);
end;

procedure TRenderSampleController.GetDataSetWithMetadata;
var
  lDM: TMyDataModule;
  lHolder: TDataSetHolder;
begin
  lDM := TMyDataModule.Create(nil);
  try
    lDM.qryCustomers.Open;
    lHolder := TDataSetHolder.Create(lDM.qryCustomers);
    lHolder.Metadata.Add('page', '1');
    lHolder.Metadata.Add('count', lDM.qryCustomers.RecordCount.ToString);
    Render(lHolder);
  finally
    lDM.Free;
  end;

end;

procedure TRenderSampleController.GetLotOfPeople;
begin
  Render<TPerson>(GetPeopleList, False);
end;

procedure TRenderSampleController.GetPerson_AsHTML;
begin
  ResponseStream.Append('<html><body><ul>').Append('<li>FirstName: Daniele</li>')
    .Append('<li>LastName: Teti')
    .AppendFormat('<li>DOB: %s</li>', [DateToISODate(EncodeDate(1975, 5, 2))])
    .Append('<li>Married: yes</li>')
    .Append('</ul></body></html>');
  RenderResponseStream;
end;

procedure TRenderSampleController.GetPerson_AsHTMLView;
var
  Cust: TCustomer;
begin
  Cust := TCustomer.Create;
  Cust.Name := 'Daniele Teti Inc.';
  Cust.ContactFirst := 'Daniele';
  Cust.ContactLast := 'Teti';
  Cust.AddressLine1 := 'Rome Street 12';
  Cust.AddressLine2 := '00100';
  Cust.City := 'ROME';
  ViewData['customer'] := Cust;
  LoadView(['header', 'customer', 'footer']);
  RenderResponseStream;
  { If you need more flexibility, you can use GetRenderedView to compose your
    output using small views.
    Here's an example:

    ContentType := TMVCMediaType.TEXT_HTML;
    Render(GetRenderedView(['header', 'customer','footer']));
  }
end;

procedure TRenderSampleController.GetPerson_AsText(const id: Integer);
begin
  ResponseStream
    .AppendLine('ID        :  ' + id.ToString)
    .AppendLine('FirstName : Daniele')
    .AppendLine('LastName  : Teti')
    .AppendLine('DOB       : ' + DateToStr(EncodeDate(1979, 5, 2)))
    .AppendLine('Married   : yes');
  RenderResponseStream;
end;

procedure TRenderSampleController.GetProgrammersAndPhilosophersAsObjectList;
var
  List: TObjectList<TPerson>;
  p: TProgrammer;
  ph: TPhilosopher;
begin
  List := TObjectList<TPerson>.Create(True);
  p := TProgrammer.Create;
  p.Married := True;
  p.FirstName := 'Peter';
  p.LastName := 'Parker';
  p.Skills := 'Delphi, JavaScript, Python, C++';
  List.Add(p);
  ph := TPhilosopher.Create;
  p.Married := False;
  ph.FirstName := 'Bruce';
  ph.LastName := 'Banner';
  ph.Mentors := 'Abbagnano, Algarotti, Cavalieri, Pareyson';
  List.Add(ph);
  p := TProgrammer.Create;
  p.Married := False;
  p.FirstName := 'Sue';
  p.LastName := 'Storm';
  p.Skills := 'Delphi, JavaScript';
  List.Add(p);
  Render<TPerson>(List);
end;

procedure TRenderSampleController.GetPeopleAsCSV;
begin
  ResponseStream.AppendLine('first_name;last_name;age');
  ResponseStream.AppendLine('Daniele;Teti;38');
  ResponseStream.AppendLine('Peter;Parker;22');
  ResponseStream.AppendLine('Bruce;Banner;60');
  ContentType := TMVCMediaType.TEXT_CSV;
  RenderResponseStream;
end;

procedure TRenderSampleController.GetPeopleWithTiming;
var
  p: TPerson;
  People: TPeopleWithMetadata;
begin
  People := TPeopleWithMetadata.Create;
  try
    People.Metadata.StartProcessing := Now;

{$REGION 'Fake data'}
    Sleep(1000); // processing...

    p := TPerson.Create;
    p.FirstName := 'Daniele';
    p.LastName := 'Teti';
    p.DOB := EncodeDate(1979, 11, 4);
    p.Married := True;
    People.Items.Add(p);

    p := TPerson.Create;
    p.FirstName := 'John';
    p.LastName := 'Doe';
    p.DOB := EncodeDate(1879, 10, 2);
    p.Married := False;
    People.Items.Add(p);

    p := TPerson.Create;
    p.FirstName := 'Jane';
    p.LastName := 'Doe';
    p.DOB := EncodeDate(1883, 1, 5);
    p.Married := True;
    People.Items.Add(p);

{$ENDREGION}
    People.Metadata.CustomData := Format('There are %d people in the list', [People.Items.Count]);
    People.Metadata.StopProcessing := Now;
    Render(People, False);
  finally
    People.Free;
  end;
end;

procedure TRenderSampleController.GetPeople_AsObjectList;
var
  p: TPerson;
  People: TObjectList<TPerson>;
begin
  People := TObjectList<TPerson>.Create(True);

{$REGION 'Fake data'}
  p := TPerson.Create;
  p.FirstName := 'Daniele';
  p.LastName := 'Teti';
  p.DOB := EncodeDate(1979, 11, 4);
  p.Married := True;
  People.Add(p);

  p := TPerson.Create;
  p.FirstName := 'John';
  p.LastName := 'Doe';
  p.DOB := EncodeDate(1879, 10, 2);
  p.Married := False;
  People.Add(p);

  p := TPerson.Create;
  p.FirstName := 'Jane';
  p.LastName := 'Doe';
  p.DOB := EncodeDate(1883, 1, 5);
  p.Married := True;
  People.Add(p);

{$ENDREGION}
  Render<TPerson>(People);
end;

procedure TRenderSampleController.GetPeople_AsObjectList_HATEOAS;
var
  p: TPerson;
  People: TObjectList<TPerson>;
begin
  People := TObjectList<TPerson>.Create(True);

{$REGION 'Fake data'}
  p := TPerson.Create;
  p.FirstName := 'Daniele';
  p.LastName := 'Teti';
  p.DOB := EncodeDate(1979, 11, 4);
  p.Married := True;
  People.Add(p);

  p := TPerson.Create;
  p.FirstName := 'John';
  p.LastName := 'Doe';
  p.DOB := EncodeDate(1879, 10, 2);
  p.Married := False;
  People.Add(p);

  p := TPerson.Create;
  p.FirstName := 'Jane';
  p.LastName := 'Doe';
  p.DOB := EncodeDate(1883, 1, 5);
  p.Married := True;
  People.Add(p);

{$ENDREGION}
  Render<TPerson>(People, True,
    procedure(const APerson: TPerson; const Dict: TMVCStringDictionary)
    begin
      Dict['ref'] := '/api/people/' + APerson.LastName;
      Dict['x-ref'] := '/api/people/' + APerson.LastName;
    end);
end;

procedure TRenderSampleController.GetPersonById(const id: Integer);
var
  lPerson: TPerson;
begin
  lPerson := TPerson.Create;
  try
    lPerson.id := id;
    lPerson.FirstName := 'Daniele';
    lPerson.LastName := 'Daniele';
    lPerson.DOB := EncodeDate(1979, 11, 4);
    lPerson.Married := True;
    Render(lPerson, False,
      procedure(const AObject: TObject; const Links: TMVCStringDictionary)
      begin
        Links['x-self'] := '/people/' + TPerson(AObject).id.ToString;
        Links['x-self-list'] := '/people';
      end);
  finally
    lPerson.Free;
  end;
end;

procedure TRenderSampleController.GetPersonJSON;
var
  lJSONPerson: TJSONObject;
begin
  lJSONPerson := TJSONObject.Create;
  lJSONPerson.s['FirstName'] := 'Daniele';
  lJSONPerson.s['LastName'] := 'Teti';
  lJSONPerson.s['DOB'] := DateToISODate(EncodeDate(1975, 5, 2));
  lJSONPerson.B['Married'] := True;
  Render(lJSONPerson);
end;

procedure TRenderSampleController.GetPersonPhoto;
begin
  // ContentType := 'image/jpeg';
  SendFile('..\..\_\customer.png');
end;

procedure TRenderSampleController.GetPersonPhotoAsStream;
var
  LPhoto: TFileStream;
begin
  LPhoto := TFileStream.Create('..\..\_\customer.png', fmOpenRead or fmShareDenyWrite);
  ContentType := 'image/png'; // you can also use MVCProduces attribute

  // LPhoto is a plain TStream descendant, so it can be rendered as usual
  Render(LPhoto, True);
end;

end.
