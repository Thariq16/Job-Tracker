part of 'generated.dart';

class GetJobApplicationsByUserVariablesBuilder {
  String userId;

  final FirebaseDataConnect _dataConnect;
  GetJobApplicationsByUserVariablesBuilder(this._dataConnect, {required  this.userId,});
  Deserializer<GetJobApplicationsByUserData> dataDeserializer = (dynamic json)  => GetJobApplicationsByUserData.fromJson(jsonDecode(json));
  Serializer<GetJobApplicationsByUserVariables> varsSerializer = (GetJobApplicationsByUserVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<GetJobApplicationsByUserData, GetJobApplicationsByUserVariables>> execute() {
    return ref().execute();
  }

  QueryRef<GetJobApplicationsByUserData, GetJobApplicationsByUserVariables> ref() {
    GetJobApplicationsByUserVariables vars= GetJobApplicationsByUserVariables(userId: userId,);
    return _dataConnect.query("GetJobApplicationsByUser", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class GetJobApplicationsByUserJobApplications {
  final String id;
  final DateTime applicationDate;
  final String companyName;
  final String jobTitle;
  final String status;
  GetJobApplicationsByUserJobApplications.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
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

    final GetJobApplicationsByUserJobApplications otherTyped = other as GetJobApplicationsByUserJobApplications;
    return id == otherTyped.id && 
    applicationDate == otherTyped.applicationDate && 
    companyName == otherTyped.companyName && 
    jobTitle == otherTyped.jobTitle && 
    status == otherTyped.status;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, applicationDate.hashCode, companyName.hashCode, jobTitle.hashCode, status.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['applicationDate'] = nativeToJson<DateTime>(applicationDate);
    json['companyName'] = nativeToJson<String>(companyName);
    json['jobTitle'] = nativeToJson<String>(jobTitle);
    json['status'] = nativeToJson<String>(status);
    return json;
  }

  GetJobApplicationsByUserJobApplications({
    required this.id,
    required this.applicationDate,
    required this.companyName,
    required this.jobTitle,
    required this.status,
  });
}

@immutable
class GetJobApplicationsByUserData {
  final List<GetJobApplicationsByUserJobApplications> jobApplications;
  GetJobApplicationsByUserData.fromJson(dynamic json):
  
  jobApplications = (json['jobApplications'] as List<dynamic>)
        .map((e) => GetJobApplicationsByUserJobApplications.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetJobApplicationsByUserData otherTyped = other as GetJobApplicationsByUserData;
    return jobApplications == otherTyped.jobApplications;
    
  }
  @override
  int get hashCode => jobApplications.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['jobApplications'] = jobApplications.map((e) => e.toJson()).toList();
    return json;
  }

  GetJobApplicationsByUserData({
    required this.jobApplications,
  });
}

@immutable
class GetJobApplicationsByUserVariables {
  final String userId;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  GetJobApplicationsByUserVariables.fromJson(Map<String, dynamic> json):
  
  userId = nativeFromJson<String>(json['userId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetJobApplicationsByUserVariables otherTyped = other as GetJobApplicationsByUserVariables;
    return userId == otherTyped.userId;
    
  }
  @override
  int get hashCode => userId.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['userId'] = nativeToJson<String>(userId);
    return json;
  }

  GetJobApplicationsByUserVariables({
    required this.userId,
  });
}

