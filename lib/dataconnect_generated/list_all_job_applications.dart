part of 'generated.dart';

class ListAllJobApplicationsVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  ListAllJobApplicationsVariablesBuilder(this._dataConnect, );
  Deserializer<ListAllJobApplicationsData> dataDeserializer = (dynamic json)  => ListAllJobApplicationsData.fromJson(jsonDecode(json));
  
  Future<QueryResult<ListAllJobApplicationsData, void>> execute() {
    return ref().execute();
  }

  QueryRef<ListAllJobApplicationsData, void> ref() {
    
    return _dataConnect.query("ListAllJobApplications", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class ListAllJobApplicationsJobApplications {
  final String id;
  final DateTime applicationDate;
  final String companyName;
  final String jobTitle;
  final String status;
  ListAllJobApplicationsJobApplications.fromJson(dynamic json):
  
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

    final ListAllJobApplicationsJobApplications otherTyped = other as ListAllJobApplicationsJobApplications;
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

  ListAllJobApplicationsJobApplications({
    required this.id,
    required this.applicationDate,
    required this.companyName,
    required this.jobTitle,
    required this.status,
  });
}

@immutable
class ListAllJobApplicationsData {
  final List<ListAllJobApplicationsJobApplications> jobApplications;
  ListAllJobApplicationsData.fromJson(dynamic json):
  
  jobApplications = (json['jobApplications'] as List<dynamic>)
        .map((e) => ListAllJobApplicationsJobApplications.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListAllJobApplicationsData otherTyped = other as ListAllJobApplicationsData;
    return jobApplications == otherTyped.jobApplications;
    
  }
  @override
  int get hashCode => jobApplications.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['jobApplications'] = jobApplications.map((e) => e.toJson()).toList();
    return json;
  }

  ListAllJobApplicationsData({
    required this.jobApplications,
  });
}

