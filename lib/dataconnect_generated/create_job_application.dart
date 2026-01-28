part of 'generated.dart';

class CreateJobApplicationVariablesBuilder {
  String userId;
  DateTime applicationDate;
  String companyName;
  String jobTitle;
  String status;

  final FirebaseDataConnect _dataConnect;
  CreateJobApplicationVariablesBuilder(this._dataConnect, {required  this.userId,required  this.applicationDate,required  this.companyName,required  this.jobTitle,required  this.status,});
  Deserializer<CreateJobApplicationData> dataDeserializer = (dynamic json)  => CreateJobApplicationData.fromJson(jsonDecode(json));
  Serializer<CreateJobApplicationVariables> varsSerializer = (CreateJobApplicationVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<CreateJobApplicationData, CreateJobApplicationVariables>> execute() {
    return ref().execute();
  }

  MutationRef<CreateJobApplicationData, CreateJobApplicationVariables> ref() {
    CreateJobApplicationVariables vars= CreateJobApplicationVariables(userId: userId,applicationDate: applicationDate,companyName: companyName,jobTitle: jobTitle,status: status,);
    return _dataConnect.mutation("CreateJobApplication", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class CreateJobApplicationJobApplicationInsert {
  final String id;
  CreateJobApplicationJobApplicationInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateJobApplicationJobApplicationInsert otherTyped = other as CreateJobApplicationJobApplicationInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  CreateJobApplicationJobApplicationInsert({
    required this.id,
  });
}

@immutable
class CreateJobApplicationData {
  final CreateJobApplicationJobApplicationInsert jobApplication_insert;
  CreateJobApplicationData.fromJson(dynamic json):
  
  jobApplication_insert = CreateJobApplicationJobApplicationInsert.fromJson(json['jobApplication_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateJobApplicationData otherTyped = other as CreateJobApplicationData;
    return jobApplication_insert == otherTyped.jobApplication_insert;
    
  }
  @override
  int get hashCode => jobApplication_insert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['jobApplication_insert'] = jobApplication_insert.toJson();
    return json;
  }

  CreateJobApplicationData({
    required this.jobApplication_insert,
  });
}

@immutable
class CreateJobApplicationVariables {
  final String userId;
  final DateTime applicationDate;
  final String companyName;
  final String jobTitle;
  final String status;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  CreateJobApplicationVariables.fromJson(Map<String, dynamic> json):
  
  userId = nativeFromJson<String>(json['userId']),
  applicationDate = nativeFromJson<DateTime>(json['applicationDate']),
  companyName = nativeFromJson<String>(json['companyName']),
  jobTitle = nativeFromJson<String>(json['jobTitle']),
  status = nativeFromJson<String>(json['status']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateJobApplicationVariables otherTyped = other as CreateJobApplicationVariables;
    return userId == otherTyped.userId && 
    applicationDate == otherTyped.applicationDate && 
    companyName == otherTyped.companyName && 
    jobTitle == otherTyped.jobTitle && 
    status == otherTyped.status;
    
  }
  @override
  int get hashCode => Object.hashAll([userId.hashCode, applicationDate.hashCode, companyName.hashCode, jobTitle.hashCode, status.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['userId'] = nativeToJson<String>(userId);
    json['applicationDate'] = nativeToJson<DateTime>(applicationDate);
    json['companyName'] = nativeToJson<String>(companyName);
    json['jobTitle'] = nativeToJson<String>(jobTitle);
    json['status'] = nativeToJson<String>(status);
    return json;
  }

  CreateJobApplicationVariables({
    required this.userId,
    required this.applicationDate,
    required this.companyName,
    required this.jobTitle,
    required this.status,
  });
}

