part of 'generated.dart';

class UpdateJobApplicationStatusVariablesBuilder {
  String id;
  String status;

  final FirebaseDataConnect _dataConnect;
  UpdateJobApplicationStatusVariablesBuilder(this._dataConnect, {required  this.id,required  this.status,});
  Deserializer<UpdateJobApplicationStatusData> dataDeserializer = (dynamic json)  => UpdateJobApplicationStatusData.fromJson(jsonDecode(json));
  Serializer<UpdateJobApplicationStatusVariables> varsSerializer = (UpdateJobApplicationStatusVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<UpdateJobApplicationStatusData, UpdateJobApplicationStatusVariables>> execute() {
    return ref().execute();
  }

  MutationRef<UpdateJobApplicationStatusData, UpdateJobApplicationStatusVariables> ref() {
    UpdateJobApplicationStatusVariables vars= UpdateJobApplicationStatusVariables(id: id,status: status,);
    return _dataConnect.mutation("UpdateJobApplicationStatus", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class UpdateJobApplicationStatusJobApplicationUpdate {
  final String id;
  UpdateJobApplicationStatusJobApplicationUpdate.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateJobApplicationStatusJobApplicationUpdate otherTyped = other as UpdateJobApplicationStatusJobApplicationUpdate;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  UpdateJobApplicationStatusJobApplicationUpdate({
    required this.id,
  });
}

@immutable
class UpdateJobApplicationStatusData {
  final UpdateJobApplicationStatusJobApplicationUpdate? jobApplication_update;
  UpdateJobApplicationStatusData.fromJson(dynamic json):
  
  jobApplication_update = json['jobApplication_update'] == null ? null : UpdateJobApplicationStatusJobApplicationUpdate.fromJson(json['jobApplication_update']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateJobApplicationStatusData otherTyped = other as UpdateJobApplicationStatusData;
    return jobApplication_update == otherTyped.jobApplication_update;
    
  }
  @override
  int get hashCode => jobApplication_update.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (jobApplication_update != null) {
      json['jobApplication_update'] = jobApplication_update!.toJson();
    }
    return json;
  }

  UpdateJobApplicationStatusData({
    this.jobApplication_update,
  });
}

@immutable
class UpdateJobApplicationStatusVariables {
  final String id;
  final String status;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  UpdateJobApplicationStatusVariables.fromJson(Map<String, dynamic> json):
  
  id = nativeFromJson<String>(json['id']),
  status = nativeFromJson<String>(json['status']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateJobApplicationStatusVariables otherTyped = other as UpdateJobApplicationStatusVariables;
    return id == otherTyped.id && 
    status == otherTyped.status;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, status.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['status'] = nativeToJson<String>(status);
    return json;
  }

  UpdateJobApplicationStatusVariables({
    required this.id,
    required this.status,
  });
}

